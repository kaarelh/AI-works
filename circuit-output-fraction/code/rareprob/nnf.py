"""Negation normal form (NNF) DAGs and conversion from circuits.

Node kinds: 'T' (true), 'F' (false), 'L' (literal x_var = val), 'A' (and),
'O' (or), 'X' (opaque: an arbitrary sub-circuit, kept as a black box; used
for gates such as large-weight thresholds that have no small NNF).

Nodes are hash-consed, so structurally equal nodes are shared.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from .circuit import Circuit


@dataclass
class NNF:
    kind: list = field(default_factory=list)
    data: list = field(default_factory=list)  # (var, val) for L, children tuple for A/O, (gate, pol) for X
    sup: list = field(default_factory=list)  # variable support bitmask
    _cons: dict = field(default_factory=dict)
    root: int = -1

    def _mk(self, kind: str, data, sup: int) -> int:
        key = (kind, data)
        v = self._cons.get(key)
        if v is not None:
            return v
        self.kind.append(kind)
        self.data.append(data)
        self.sup.append(sup)
        v = len(self.kind) - 1
        self._cons[key] = v
        return v

    def true(self) -> int:
        return self._mk("T", None, 0)

    def false(self) -> int:
        return self._mk("F", None, 0)

    def lit(self, var: int, val: int) -> int:
        return self._mk("L", (int(var), int(val)), 1 << int(var))

    def opaque(self, gate: int, pol: int, sup: int) -> int:
        return self._mk("X", (int(gate), int(pol)), sup)

    def AND(self, ch) -> int:
        out = []
        for c in ch:
            k = self.kind[c]
            if k == "F":
                return self.false()
            if k == "T":
                continue
            if k == "A":
                out.extend(self.data[c])
            else:
                out.append(c)
        out = tuple(sorted(set(out)))
        # x and not-x
        lits = {self.data[c] for c in out if self.kind[c] == "L"}
        if any((v, 1 - b) in lits for (v, b) in lits):
            return self.false()
        if not out:
            return self.true()
        if len(out) == 1:
            return out[0]
        s = 0
        for c in out:
            s |= self.sup[c]
        return self._mk("A", out, s)

    def OR(self, ch) -> int:
        out = []
        for c in ch:
            k = self.kind[c]
            if k == "T":
                return self.true()
            if k == "F":
                continue
            if k == "O":
                out.extend(self.data[c])
            else:
                out.append(c)
        out = tuple(sorted(set(out)))
        lits = {self.data[c] for c in out if self.kind[c] == "L"}
        if any((v, 1 - b) in lits for (v, b) in lits):
            return self.true()
        if not out:
            return self.false()
        if len(out) == 1:
            return out[0]
        s = 0
        for c in out:
            s |= self.sup[c]
        return self._mk("O", out, s)

    def restrict(self, v: int, rho: dict, _memo: dict | None = None) -> int:
        """Node for v with the variables in rho fixed, simplified (constants
        propagated, nested gates flattened). Opaque nodes keep their
        restriction in their data."""
        if not rho:
            return v
        memo = {} if _memo is None else _memo
        # iterative post-order over the cone of v
        order = self.cone(v)
        for u in order:
            if u in memo:
                continue
            s = self.sup[u]
            k = self.kind[u]
            if not any((s >> i) & 1 for i in rho):
                memo[u] = u
                continue
            if k == "L":
                i, b = self.data[u]
                memo[u] = self.true() if rho[i] == b else self.false()
            elif k == "A":
                memo[u] = self.AND([memo[c] for c in self.data[u]])
            elif k == "O":
                memo[u] = self.OR([memo[c] for c in self.data[u]])
            elif k == "X":
                g, pol = self.data[u][:2]
                old = dict(self.data[u][2]) if len(self.data[u]) > 2 else {}
                old.update({i: b for i, b in rho.items() if (s >> i) & 1})
                newsup = s & ~sum(1 << i for i in old)
                memo[u] = self._mk("X", (g, pol, tuple(sorted(old.items()))), newsup)
            else:
                memo[u] = u
        return memo[v]

    def children(self, v: int) -> tuple:
        return self.data[v] if self.kind[v] in ("A", "O") else ()

    def cone(self, v: int | None = None) -> list[int]:
        v = self.root if v is None else v
        seen, stack, order = set(), [v], []
        while stack:
            u = stack.pop()
            if u in seen:
                continue
            seen.add(u)
            stack.extend(self.children(u))
        return sorted(seen)  # children always have smaller ids

    def size(self, v: int | None = None) -> int:
        return len(self.cone(v))

    def is_decomposable(self, v: int | None = None) -> bool:
        for u in self.cone(v):
            if self.kind[u] == "A":
                acc = 0
                for c in self.data[u]:
                    if acc & self.sup[c]:
                        return False
                    acc |= self.sup[c]
        return True

    def eval_batch(self, X, v: int | None = None, rho: dict | None = None):
        """Evaluate node v on rows of X ((N, n) bool), with the variables in
        rho overwritten by their values. Returns a bool array of length N."""
        import numpy as _np

        X = _np.asarray(X, dtype=bool)
        if rho:
            X = X.copy()
            for i, b in rho.items():
                X[:, i] = bool(b)
        Nr = X.shape[0]
        v = self.root if v is None else v
        val = {}
        for u in self.cone(v):
            k = self.kind[u]
            if k == "T":
                val[u] = _np.ones(Nr, dtype=bool)
            elif k == "F":
                val[u] = _np.zeros(Nr, dtype=bool)
            elif k == "L":
                i, b = self.data[u]
                val[u] = X[:, i] if b else ~X[:, i]
            elif k == "A":
                r = val[self.data[u][0]].copy()
                for c in self.data[u][1:]:
                    r &= val[c]
                val[u] = r
            elif k == "O":
                r = val[self.data[u][0]].copy()
                for c in self.data[u][1:]:
                    r |= val[c]
                val[u] = r
            else:
                g, pol = self.data[u][:2]
                Xu = X
                if len(self.data[u]) > 2 and self.data[u][2]:
                    Xu = X.copy()
                    for i, b in self.data[u][2]:
                        Xu[:, i] = bool(b)
                C = self.circuit
                sub = Circuit(C.n, list(C.ops), list(C.args), list(C.params), g)
                r = sub.eval_bits(Xu)
                val[u] = r if pol else ~r
        return val[v]

    def eval(self, x, v: int | None = None, circuit: Circuit | None = None) -> int:
        """Evaluate at a single assignment (list/array of bits)."""
        memo: dict[int, int] = {}
        for u in self.cone(v):
            k = self.kind[u]
            if k == "T":
                memo[u] = 1
            elif k == "F":
                memo[u] = 0
            elif k == "L":
                i, b = self.data[u]
                memo[u] = int(int(x[i]) == b)
            elif k == "A":
                memo[u] = int(all(memo[c] for c in self.data[u]))
            elif k == "O":
                memo[u] = int(any(memo[c] for c in self.data[u]))
            else:
                g, pol = self.data[u]
                assert circuit is not None
                sub = Circuit(circuit.n, list(circuit.ops), list(circuit.args), list(circuit.params), g)
                memo[u] = int(sub(x) == pol)
        return memo[self.root if v is None else v]


def _small_cone_nnf(N: NNF, C: Circuit, g: int, sup_mask: int, q: int) -> int:
    """Exact reduced-OBDD NNF (a d-DNNF) of [gate g == q], by tabulating g on
    all assignments of its (small) support."""
    import numpy as _np

    vs = [i for i in range(C.n) if (sup_mask >> i) & 1]
    k = len(vs)
    X = _np.zeros((1 << k, C.n), dtype=bool)
    X[:, vs] = ((_np.arange(1 << k)[:, None] >> _np.arange(k)) & 1).astype(bool)
    sub = Circuit(C.n, list(C.ops), list(C.args), list(C.params), g)
    tt = sub.eval_bits(X) == bool(q)
    memo: dict = {}

    def build_sub(seg, depth):
        if seg.all():
            return N.true()
        if not seg.any():
            return N.false()
        key = seg.tobytes()
        r = memo.get((depth, key))
        if r is not None:
            return r
        f0 = build_sub(seg[0::2], depth + 1)
        f1 = build_sub(seg[1::2], depth + 1)
        v = vs[depth]
        r = f0 if f0 == f1 else N.OR([N.AND([N.lit(v, 0), f0]), N.AND([N.lit(v, 1), f1])])
        memo[(depth, key)] = r
        return r

    return build_sub(tt, 0)


def to_nnf(C: Circuit, thr_max_states: int = 4096, small_cone: int = 10) -> NNF:
    """NNF of C's output, size O(|C|) for AND/OR/NOT/XOR gates.

    Gates whose support has at most `small_cone` variables are tabulated and
    replaced by their exact reduced OBDD (a sound, exact simplification:
    e.g. (x XOR r) XOR r becomes x). THR gates with small nonnegative-integer
    weights are expanded by a sequential-counter DP; other THR gates become
    opaque nodes.
    """
    N = NNF()
    N.circuit = C
    memo: dict[tuple[int, int], int] = {}
    sup = C.supports()

    def rec(g: int, pol: int) -> int:
        # iterative post-order to avoid deep recursion
        stack = [(g, pol, False)]
        while stack:
            h, q, done = stack.pop()
            if (h, q) in memo:
                continue
            op = C.ops[h]
            a = C.args[h]
            if op == "IN":
                memo[(h, q)] = N.lit(h, q)
                continue
            if small_cone and op != "CONST" and 0 < bin(sup[h]).count("1") <= small_cone:
                memo[(h, q)] = _small_cone_nnf(N, C, h, sup[h], q)
                continue
            if op == "CONST":
                memo[(h, q)] = N.true() if C.params[h] == q else N.false()
                continue
            if op == "NOT":
                key = (a[0], 1 - q)
                if key in memo:
                    memo[(h, q)] = memo[key]
                else:
                    stack.append((h, q, True))
                    stack.append((a[0], 1 - q, False))
                continue
            if op in ("AND", "OR"):
                need = [(c, q) for c in a if (c, q) not in memo]
                if need:
                    stack.append((h, q, True))
                    stack.extend((c, q2, False) for c, q2 in need)
                    continue
                ch = [memo[(c, q)] for c in a]
                if (op == "AND") == (q == 1):
                    memo[(h, q)] = N.AND(ch)
                else:
                    memo[(h, q)] = N.OR(ch)
                continue
            if op == "XOR":
                need = [(c, b) for c in a for b in (0, 1) if (c, b) not in memo]
                if need:
                    stack.append((h, q, True))
                    stack.extend((c, b, False) for c, b in need)
                    continue
                # fold: par[b] = NNF node for "XOR of first k children == b"
                par = {0: memo[(a[0], 0)], 1: memo[(a[0], 1)]}
                for c in a[1:]:
                    c0, c1 = memo[(c, 0)], memo[(c, 1)]
                    par = {
                        0: N.OR([N.AND([par[0], c0]), N.AND([par[1], c1])]),
                        1: N.OR([N.AND([par[0], c1]), N.AND([par[1], c0])]),
                    }
                memo[(h, q)] = par[q]
                continue
            if op == "THR":
                w, t = C.params[h]
                small = all(float(x).is_integer() and x >= 0 for x in w) and sum(w) <= thr_max_states
                if not small:
                    memo[(h, q)] = N.opaque(h, q, sup[h])
                    continue
                need = [(c, b) for c in a for b in (0, 1) if (c, b) not in memo]
                if need:
                    stack.append((h, q, True))
                    stack.extend((c, b, False) for c, b in need)
                    continue
                memo[(h, q)] = _thr_nnf(N, [memo[(c, 1)] for c in a], [memo[(c, 0)] for c in a],
                                        [int(x) for x in w], t, q)
                continue
            raise ValueError(op)
        return memo[(g, pol)]

    N.root = rec(C.output, 1)
    return N


def _thr_nnf(N: NNF, pos, neg, w, t, q) -> int:
    """NNF for [sum_i w_i g_i >= t] == q via suffix DP over achievable sums.

    state(k, s) = NNF for 'sum over children k.. of w_i g_i >= t - s' (q=1).
    The OR at each state is deterministic (it branches on child k).
    """
    m = len(w)
    import math as _m

    need = _m.ceil(t - 1e-12)
    suffix = [0] * (m + 1)
    for k in range(m - 1, -1, -1):
        suffix[k] = suffix[k + 1] + w[k]
    memo: dict[tuple[int, int], int] = {}

    def st(k: int, s: int) -> int:
        # returns node for: sum_{i>=k} w_i g_i >= need - s  (if q == 1), or < (if q == 0)
        key = (k, s)
        if key in memo:
            return memo[key]
        r = need - s
        if r <= 0:
            res = N.true() if q == 1 else N.false()
        elif r > suffix[k]:
            res = N.false() if q == 1 else N.true()
        else:
            res = N.OR([N.AND([pos[k], st(k + 1, s + w[k])]), N.AND([neg[k], st(k + 1, s)])])
        memo[key] = res
        return res

    import sys

    old = sys.getrecursionlimit()
    sys.setrecursionlimit(max(old, 10 * m + 1000))
    try:
        return st(0, 0)
    finally:
        sys.setrecursionlimit(old)
