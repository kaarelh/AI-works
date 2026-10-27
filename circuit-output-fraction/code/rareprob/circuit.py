"""Boolean circuits over n input bits, with batched bit-parallel evaluation.

A circuit is a list of gates in topological order. Gates 0..n-1 are the inputs.
Every other gate is one of

    ('CONST', (), b)          constant b in {0, 1}
    ('NOT', (a,), None)
    ('AND', (a, b, ...), None)  any fan-in >= 1
    ('OR',  (a, b, ...), None)
    ('XOR', (a, b, ...), None)
    ('THR', (a, b, ...), (w, t))  1 iff sum_i w_i * g_i >= t, exactly

Threshold semantics are exact. Weights and the threshold may be Python ints,
floats or Fractions (a float is taken at its exact binary value; weights must
be finite, t may be +-inf), and the gate computes [sum_i w_i g_i >= t] in
rational arithmetic, with no tolerance. Circuit.add stores the parameter in
an equivalent integer form (thr_canonical): the weights are scaled by their
least common denominator and divided by their gcd, the threshold is scaled
the same way and rounded up (the sum is then an integer), and it is clipped
to [sum of negative weights, sum of positive weights + 1]. Every module reads
THR parameters in integer form (thr_param, or thr_canonical where the
canonical one matters), so all of them compute this one function.
CONST parameters are normalised to the int 0 or 1; any other value is
rejected.

Evaluation is bit-parallel: each wire is a numpy array of uint64 words, one bit
per sample, so a batch of N samples costs about |C| * N / 64 word operations.
THR gates are evaluated on unpacked bits: with machine-integer sums (int16,
int32 or int64) when the sum of the absolute weights and |t| is below 2^14,
2^30 or 2^62 (no partial sum can overflow), by table lookup for fan-in <= 16,
and with Python integers otherwise.
"""

from __future__ import annotations

import math
import numbers
from dataclasses import dataclass, field
from fractions import Fraction
from functools import lru_cache
from typing import Iterable, Sequence

import numpy as np

OPS = ("IN", "CONST", "NOT", "AND", "OR", "XOR", "THR")
_INT64_SAFE = 1 << 62
_TABLE_FANIN = 16


# ------------------------------------------------------------ gate parameters
def as_rational(v) -> Fraction:
    """The exact value of a number as a Fraction: an int or a Fraction as it
    is, a float (or numpy float, Decimal) at its exact binary (decimal)
    value. Raises ValueError for NaN and infinities and TypeError for
    anything that is not a real number."""
    if isinstance(v, (bool, np.bool_, int, np.integer)):
        return Fraction(int(v))
    if isinstance(v, Fraction):
        return v
    if isinstance(v, numbers.Rational):
        return Fraction(int(v.numerator), int(v.denominator))
    ratio = getattr(v, "as_integer_ratio", None)
    if ratio is None or isinstance(v, (str, bytes)):
        raise TypeError(f"not a real number: {v!r}")
    try:
        a, b = ratio()
    except (OverflowError, ValueError):
        raise ValueError(f"not a finite number: {v!r}") from None
    return Fraction(int(a), int(b))


def thr_canonical(w, t) -> tuple[tuple[int, ...], int]:
    """The integer form (W, T) of a threshold gate [sum_i w_i y_i >= t]:
    [sum_i W_i y_i >= T] for every y in {0,1}^k, the W_i coprime integers (or
    all 0) and T in [sum of negative W_i, sum of positive W_i + 1].

    With den the least common denominator of the w_i, den * sum w_i y_i is an
    integer, so it is >= den * t iff it is >= ceil(den * t); dividing by the
    gcd g of the scaled weights likewise turns the threshold into ceil(./g);
    a threshold below the least attainable sum (above the largest) is moved
    to that sum (one above it). Every step is exact."""
    W = [as_rational(x) for x in w]
    k = len(W)
    try:
        T = as_rational(t)
    except ValueError:
        f = float(t)
        if f == math.inf:
            return (0,) * k, 1  # never fires
        if f == -math.inf:
            return (0,) * k, 0  # always fires
        raise ValueError(f"THR threshold is not a number: {t!r}") from None
    den = 1
    for x in W:
        den = den * x.denominator // math.gcd(den, x.denominator)
    Wi = [x.numerator * (den // x.denominator) for x in W]
    Ti = math.ceil(T * den)
    g = math.gcd(*Wi) if Wi else 0
    if g > 1:
        Wi = [x // g for x in Wi]
        Ti = -(-Ti // g)
    lo = sum(x for x in Wi if x < 0)
    hi = sum(x for x in Wi if x > 0)
    return tuple(Wi), int(min(max(Ti, lo), hi + 1))


def thr_param(param) -> tuple[tuple[int, ...], int]:
    """(W, T) with integer entries for a THR parameter: the parameter itself
    when it already has integer entries (the stored form), else its
    canonical form. Every module reads THR parameters through this."""
    w, t = param
    if type(t) is int and all(type(x) is int for x in w):
        return tuple(w), t
    return thr_canonical(w, t)


def const_value(b) -> int:
    """A CONST parameter as the int 0 or 1. Raises ValueError for any value
    other than 0 or 1 (True, False, 0.0, 1.0 and the like are accepted)."""
    if type(b) is int and (b == 0 or b == 1):
        return b
    try:
        v = as_rational(b)
    except (TypeError, ValueError):
        v = None
    if v == 0 or v == 1:
        return int(v)
    raise ValueError(f"CONST parameter must be 0 or 1, got {b!r}")


def thr_value(w, t, bits) -> int:
    """[sum_i w_i b_i >= t] for one assignment, in exact integer arithmetic
    (w, t in integer form, e.g. from thr_param)."""
    return int(sum(wi for wi, b in zip(w, bits) if b) >= t)


@lru_cache(maxsize=256)
def _thr_table(w: tuple, t: int) -> np.ndarray:
    sums = [0]
    for wi in w:  # sums[a] = sum of w_j over the bits j of a
        sums = sums + [s + wi for s in sums]
    return np.array([s >= t for s in sums], dtype=bool)


def thr_eval(w, t, cols, N: int) -> np.ndarray:
    """[sum_i w_i c_i >= t] on bool arrays c_i of length N, exactly (w, t in
    integer form)."""
    bound = sum(abs(x) for x in w) + abs(t)
    if bound < _INT64_SAFE:  # no partial sum, nor t, leaves the integer type
        dt = np.int16 if bound < 1 << 14 else np.int32 if bound < 1 << 30 else np.int64
        s = np.zeros(N, dtype=dt)
        for wi, c in zip(w, cols):
            if wi == 1:
                s += c
            elif wi == -1:
                s -= c
            elif wi:
                s += dt(wi) * c.view(np.int8)
        return s >= t
    if len(w) <= _TABLE_FANIN:
        idx = np.zeros(N, dtype=np.int64)
        for j, c in enumerate(cols):
            idx |= c.astype(np.int64) << j
        return _thr_table(tuple(w), t)[idx]
    s = np.zeros(N, dtype=object)
    for wi, c in zip(w, cols):
        if wi:
            s = s + c.astype(object) * wi  # Python ints: exact
    return (s >= t).astype(bool)


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
        elif "CONST" in self.ops or "THR" in self.ops:
            # gates given directly (not through add): normalise their parameters
            self.params = list(self.params)
            for v, op in enumerate(self.ops):
                if op == "CONST":
                    self.params[v] = const_value(self.params[v])
                elif op == "THR":
                    self.params[v] = thr_param(self.params[v])

    # ------------------------------------------------------------------ build
    def add(self, op: str, args: Sequence[int] = (), param=None) -> int:
        if op not in OPS or op == "IN":
            raise ValueError(f"unknown gate type {op!r}")
        args = tuple(int(a) for a in args)
        for a in args:
            if not 0 <= a < len(self.ops):
                raise ValueError("gates must be added in topological order")
        if op == "CONST":
            if args:
                raise ValueError("CONST takes no arguments")
            param = const_value(param)
        elif op == "NOT" and len(args) != 1:
            raise ValueError("NOT takes one argument")
        elif op in ("AND", "OR", "XOR", "THR") and not args:
            raise ValueError(f"{op} needs at least one argument")
        if op == "THR":
            w, t = param
            w = list(w)
            if len(w) != len(args):
                raise ValueError("THR needs one weight per argument")
            param = thr_canonical(w, t)
        elif op != "CONST":
            param = None
        self.ops.append(op)
        self.args.append(args)
        self.params.append(param)
        return len(self.ops) - 1

    def const(self, b) -> int:
        return self.add("CONST", (), b)

    def NOT(self, a: int) -> int:
        return self.add("NOT", (a,))

    def AND(self, *a: int) -> int:
        return self.add("AND", _flat(a))

    def OR(self, *a: int) -> int:
        return self.add("OR", _flat(a))

    def XOR(self, *a: int) -> int:
        return self.add("XOR", _flat(a))

    def THR(self, a: Sequence[int], w: Sequence, t) -> int:
        """[sum_i w_i a_i >= t], exactly (ints, floats at their binary value,
        or Fractions)."""
        return self.add("THR", a, (w, t))

    def lit(self, i: int, b: int) -> int:
        """Gate computing [x_i == b]."""
        return i if b else self.NOT(i)

    def set_output(self, g: int) -> "Circuit":
        self.output = int(g)
        return self

    def with_output(self, g: int) -> "Circuit":
        """A copy of this circuit with output g (parameters already normalised)."""
        c = Circuit.__new__(Circuit)
        c.n, c.ops, c.args, c.params, c.output = self.n, list(self.ops), list(self.args), list(self.params), int(g)
        return c

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
                val[v] = ones.copy() if const_value(self.params[v]) else np.zeros(W, dtype=np.uint64)
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
                w, t = thr_param(self.params[v])
                cols = {u: unpack_bits(val[u], W * 64) for u in dict.fromkeys(a)}
                val[v] = pack_bits(thr_eval(w, t, [cols[u] for u in a], W * 64))
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
