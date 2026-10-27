"""Boolean circuits over n input bits, with batched bit-parallel evaluation.

A circuit is a list of gates in topological order. Gates 0..n-1 are the inputs.
Every other gate is one of

    ('CONST', (), b)          constant b in {0, 1}
    ('NOT', (a,), None)
    ('AND', (a, b, ...), None)  any fan-in >= 1
    ('OR',  (a, b, ...), None)
    ('XOR', (a, b, ...), None)
    ('THR', (a, b, ...), (w, t))  1 iff sum_i w_i * g_i >= t  (real weights)

Evaluation is bit-parallel: each wire is a numpy array of uint64 words, one bit
per sample, so a batch of N samples costs about |C| * N / 64 word operations.
THR gates are evaluated on unpacked bits and are slower.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Iterable, Sequence

import numpy as np

OPS = ("IN", "CONST", "NOT", "AND", "OR", "XOR", "THR")


@dataclass
class Circuit:
    n: int
    ops: list = field(default_factory=list)
    args: list = field(default_factory=list)
    params: list = field(default_factory=list)
    output: int = -1

    def __post_init__(self):
        if not self.ops:
            for _ in range(self.n):
                self.ops.append("IN")
                self.args.append(())
                self.params.append(None)

    # ------------------------------------------------------------------ build
    def add(self, op: str, args: Sequence[int] = (), param=None) -> int:
        assert op in OPS and op != "IN"
        args = tuple(int(a) for a in args)
        for a in args:
            assert 0 <= a < len(self.ops), "gates must be added in topological order"
        if op == "NOT":
            assert len(args) == 1
        if op in ("AND", "OR", "XOR", "THR"):
            assert len(args) >= 1
        if op == "THR":
            w, t = param
            assert len(w) == len(args)
            param = (tuple(float(v) for v in w), float(t))
        self.ops.append(op)
        self.args.append(args)
        self.params.append(param)
        return len(self.ops) - 1

    def const(self, b: int) -> int:
        return self.add("CONST", (), int(bool(b)))

    def NOT(self, a: int) -> int:
        return self.add("NOT", (a,))

    def AND(self, *a: int) -> int:
        return self.add("AND", _flat(a))

    def OR(self, *a: int) -> int:
        return self.add("OR", _flat(a))

    def XOR(self, *a: int) -> int:
        return self.add("XOR", _flat(a))

    def THR(self, a: Sequence[int], w: Sequence[float], t: float) -> int:
        return self.add("THR", a, (w, t))

    def lit(self, i: int, b: int) -> int:
        """Gate computing [x_i == b]."""
        return i if b else self.NOT(i)

    def set_output(self, g: int) -> "Circuit":
        self.output = int(g)
        return self

    @property
    def size(self) -> int:
        return len(self.ops) - self.n

    def __len__(self) -> int:
        return len(self.ops)

    # -------------------------------------------------------------- analysis
    def cone(self, g: int | None = None) -> list[int]:
        """Gates in the cone of g (default: output), in topological order."""
        g = self.output if g is None else g
        seen = np.zeros(len(self.ops), dtype=bool)
        stack = [g]
        while stack:
            v = stack.pop()
            if seen[v]:
                continue
            seen[v] = True
            stack.extend(self.args[v])
        return [int(v) for v in np.nonzero(seen)[0]]

    def supports(self) -> list[int]:
        """Variable support of every gate, as Python int bitmasks."""
        sup = [0] * len(self.ops)
        for v, op in enumerate(self.ops):
            if op == "IN":
                sup[v] = 1 << v
            else:
                s = 0
                for a in self.args[v]:
                    s |= sup[a]
                sup[v] = s
        return sup

    def restrict(self, rho: dict[int, int]) -> "Circuit":
        """Circuit with inputs in rho replaced by constants (same input indexing)."""
        c = Circuit(self.n)
        m = list(range(self.n))
        for i, b in rho.items():
            m[i] = c.const(b)
        for v in range(self.n, len(self.ops)):
            m.append(c.add(self.ops[v], [m[a] for a in self.args[v]], self.params[v]))
        c.output = m[self.output]
        return c

    # ------------------------------------------------------------ evaluation
    def eval_packed(self, X: np.ndarray, gates: Iterable[int] | None = None) -> np.ndarray:
        """Evaluate on packed inputs.

        X has shape (n, W) and dtype uint64: bit j of word w of row i is input i
        of sample 64*w + j. Returns the packed output row, shape (W,).
        """
        W = X.shape[1]
        need = self.cone() if gates is None else sorted(set(gates))
        val: dict[int, np.ndarray] = {}
        ones = np.full(W, np.uint64(0xFFFFFFFFFFFFFFFF), dtype=np.uint64)
        for v in need:
            op = self.ops[v]
            a = self.args[v]
            if op == "IN":
                val[v] = X[v]
            elif op == "CONST":
                val[v] = ones.copy() if self.params[v] else np.zeros(W, dtype=np.uint64)
            elif op == "NOT":
                val[v] = ~val[a[0]]
            elif op == "AND":
                r = val[a[0]].copy()
                for u in a[1:]:
                    r &= val[u]
                val[v] = r
            elif op == "OR":
                r = val[a[0]].copy()
                for u in a[1:]:
                    r |= val[u]
                val[v] = r
            elif op == "XOR":
                r = val[a[0]].copy()
                for u in a[1:]:
                    r ^= val[u]
                val[v] = r
            elif op == "THR":
                w, t = self.params[v]
                s = np.zeros(W * 64)
                for wi, u in zip(w, a):
                    s += wi * unpack_bits(val[u], W * 64)
                val[v] = pack_bits(s >= t - 1e-12)
            else:  # pragma: no cover
                raise ValueError(op)
        return val[self.output if gates is None else max(need)]

    def eval_bits(self, X: np.ndarray) -> np.ndarray:
        """Evaluate on an (N, n) 0/1 array; returns a bool array of length N."""
        X = np.asarray(X, dtype=bool)
        N = X.shape[0]
        P = pack_rows(X)
        return unpack_bits(self.eval_packed(P), N)

    def __call__(self, x: Sequence[int]) -> int:
        return int(self.eval_bits(np.asarray(x, dtype=bool)[None, :])[0])


# ---------------------------------------------------------------- bit packing
def pack_rows(X: np.ndarray) -> np.ndarray:
    """(N, n) bool -> (n, ceil(N/64)) uint64, sample-major bits."""
    X = np.asarray(X, dtype=bool)
    N, n = X.shape
    W = (N + 63) // 64
    pad = np.zeros((W * 64, n), dtype=bool)
    pad[:N] = X
    b = np.packbits(np.ascontiguousarray(pad.T).reshape(n, W, 64), axis=2, bitorder="little")  # (n, W, 8)
    return np.ascontiguousarray(b).view(np.uint64).reshape(n, W)


def pack_bits(bits: np.ndarray) -> np.ndarray:
    bits = np.asarray(bits, dtype=bool)
    N = bits.shape[0]
    W = (N + 63) // 64
    pad = np.zeros(W * 64, dtype=bool)
    pad[:N] = bits
    return np.packbits(pad.reshape(W, 64), axis=1, bitorder="little").view(np.uint64).reshape(W)


def unpack_bits(words: np.ndarray, N: int) -> np.ndarray:
    b = np.unpackbits(np.ascontiguousarray(words).view(np.uint8), bitorder="little")
    return b[:N].astype(bool)


def popcount(words: np.ndarray, N: int | None = None) -> int:
    if N is not None:
        return int(unpack_bits(words, N).sum())
    return int(np.unpackbits(np.ascontiguousarray(words).view(np.uint8)).sum())


def _flat(a) -> list[int]:
    out: list[int] = []
    for t in a:
        if isinstance(t, (list, tuple)):
            out.extend(_flat(t))
        else:
            out.append(int(t))
    return out
