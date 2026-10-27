"""Exact output probability by variable elimination on the circuit's
constraint graph (the Tseitin factor graph), with a greedy min-degree elimination order.

Cost is O(|C| * 2^(w+1)) where w is the width of the elimination order found, so
this is polynomial when the order has width O(log |C|); a greedy order is a
heuristic, so a circuit of small treewidth may still be refused.
Factors are dense numpy tables over at most `max_width + 1` binary variables;
if the order needs more, we give up (return None) - an honest "no verdict".

Floating point (ve_bounds). Every table entry is held as a mantissa in
[1/2, 1) (or 0) and an integer binary exponent, so nothing can underflow or
overflow. A product of tables costs one IEEE multiplication of mantissas per
factor and entry (frexp renormalisation is exact); summing out a variable
aligns the smaller of two entries to the larger one's exponent (exact, or an
absolute error below 2^-1075 against a sum of at least 1/2) and adds them.
All quantities are nonnegative, so with r(f) the number of roundings on any
path into the entries of factor f (0 for gate tables and marginals q, 1 for
1 - q, r = sum r(f_i) + #factors - 1 for a product and + 2 for a sum), every
computed entry equals its exact value times (1 + theta) with
|theta| <= gamma_r = r u / (1 - r u) (Higham, Lemmas 3.1 and 3.3). So the
result is p = mant * 2^exp * (1 + theta), |theta| <= rel, with a proved rel,
and an exact zero (no positive term) is reported separately; a tiny p never
becomes 0.
"""

from __future__ import annotations

import heapq
import math
import sys
from dataclasses import dataclass

import numpy as np

from .circuit import Circuit, const_value, thr_param, thr_value
from .dist import Product

_U = 2.0 ** -53            # unit roundoff (round to nearest)
_TINY = sys.float_info.min  # smallest positive normal double


def _gamma(k: int) -> float:
    """gamma_k = k u / (1 - k u), inflated slightly so that the bound
    survives its own rounding."""
    ku = k * _U
    if ku >= 0.25:
        return math.inf
    return 1.01 * ku / (1.0 - ku)


class Factor:
    """A nonnegative table over binary variables: entry = M * 2^E with M in
    [1/2, 1) or M = 0 (then E is ignored); r is its rounding count."""

    __slots__ = ("vars", "M", "E", "r")

    def __init__(self, vars_, table=None, r: int = 0, M=None, E=None):
        self.vars = tuple(vars_)
        if table is not None:
            M, E = np.frexp(np.asarray(table, dtype=float))  # exact
        self.M = M
        self.E = np.asarray(E, dtype=np.int64)
        self.r = r


def _gate_factor(C: Circuit, g: int) -> Factor:
    """0/1 table of [gate value == gate function of its children]; threshold
    gates exactly, in the integer form of circuit.thr_param."""
    op, a = C.ops[g], C.args[g]
    vs = list(dict.fromkeys(list(a) + [g]))
    k = len(vs)
    T = np.zeros((2,) * k)
    pos = {v: j for j, v in enumerate(vs)}
    if op == "THR":
        w, t = thr_param(C.params[g])
    for idx in np.ndindex(*(2,) * k):
        ins = [idx[pos[u]] for u in a]
        if op == "CONST":
            out = const_value(C.params[g])
        elif op == "NOT":
            out = 1 - ins[0]
        elif op == "AND":
            out = int(all(ins))
        elif op == "OR":
            out = int(any(ins))
        elif op == "XOR":
            out = sum(ins) % 2
        elif op == "THR":
            out = thr_value(w, t, ins)
        else:
            raise ValueError(op)
        T[idx] = 1.0 if idx[pos[g]] == out else 0.0
    return Factor(vs, T)


def _expand(arr: np.ndarray, fvars, vs) -> np.ndarray:
    """View of a table over fvars, broadcastable to the axes vs."""
    pos = {v: j for j, v in enumerate(vs)}
    order = sorted(range(len(fvars)), key=lambda a: pos[fvars[a]])
    shape = [1] * len(vs)
    for a in order:
        shape[pos[fvars[a]]] = 2
    return np.transpose(arr, order).reshape(shape)


_ZERO_E = -(1 << 40)  # exponent used for zero entries when aligning


def _multiply(fs: list[Factor]) -> Factor:
    """Product table: one IEEE multiplication of mantissas per factor and
    entry, each followed by an exact frexp renormalisation."""
    vs = []
    for f in fs:
        for v in f.vars:
            if v not in vs:
                vs.append(v)
    full = (2,) * len(vs)
    M = np.broadcast_to(_expand(fs[0].M, fs[0].vars, vs), full).copy()
    E = np.broadcast_to(_expand(fs[0].E, fs[0].vars, vs), full).copy()
    for f in fs[1:]:
        M, e = np.frexp(M * _expand(f.M, f.vars, vs))  # product in [1/4, 1): normal
        E = E + _expand(f.E, f.vars, vs) + e
    return Factor(vs, r=sum(f.r for f in fs) + len(fs) - 1, M=M, E=E)


def _sum_out(f: Factor, v: int) -> Factor:
    """Sum the two slices of f along v: align the smaller entry to the larger
    one's exponent (np.ldexp: exact, or an absolute error below 2^-1075
    against a sum >= 1/2) and add (one rounding); renormalise exactly."""
    ax = f.vars.index(v)
    M0, M1 = np.take(f.M, 0, axis=ax), np.take(f.M, 1, axis=ax)
    E0 = np.where(M0 > 0, np.take(f.E, 0, axis=ax), _ZERO_E)
    E1 = np.where(M1 > 0, np.take(f.E, 1, axis=ax), _ZERO_E)
    Em = np.maximum(E0, E1)
    S = (np.ldexp(M0, np.maximum(E0 - Em, -2000).astype(np.int32))
         + np.ldexp(M1, np.maximum(E1 - Em, -2000).astype(np.int32)))
    M, e = np.frexp(S)
    E = np.where(M > 0, Em + e, 0)
    return Factor(f.vars[:ax] + f.vars[ax + 1:], r=f.r + 2, M=M, E=E)


def binarize(C: Circuit) -> Circuit:
    """Equivalent circuit whose AND/OR/XOR gates have fan-in <= 2."""
    B = Circuit(C.n)
    m = list(range(C.n))
    for v in range(C.n, len(C.ops)):
        op, a = C.ops[v], [m[u] for u in C.args[v]]
        if op in ("AND", "OR", "XOR") and len(a) > 2:
            while len(a) > 1:
                a = [B.add(op, (a[k], a[k + 1])) if k + 1 < len(a) else a[k] for k in range(0, len(a), 2)]
            m.append(a[0])
        else:
            m.append(B.add(op, a, C.params[v]))
    B.output = m[C.output]
    return B


@dataclass
class VEResult:
    """p = 0 if zero; otherwise p = mant * 2^exp * (1 + theta), |theta| <= rel."""

    zero: bool
    mant: float = 0.0
    exp: int = 0
    rel: float = 0.0
    width: int = 0

    def log2_bounds(self) -> tuple[float, float]:
        if self.zero:
            return -math.inf, -math.inf
        lm = math.log2(self.mant) + self.exp
        # log2 is accurate to a few ulps of a value of size <= |lm|: widen generously
        slack = 2.0 ** -40 * (abs(lm) + 1)
        lo = lm + math.log2(1 - self.rel) - slack if self.rel < 1 else -math.inf
        return lo, lm + math.log2(1 + self.rel) + slack

    def interval(self) -> tuple[float, float]:
        """[lo, hi] in floats, rounded outwards: lo may flush to 0 below the
        normal range, hi is positive whenever p is."""
        if self.zero:
            return 0.0, 0.0
        a = math.nextafter(math.nextafter(1.0 - self.rel, 0.0) * self.mant, 0.0)
        b = math.nextafter(math.nextafter(1.0 + self.rel, math.inf) * self.mant, math.inf)
        lo = math.ldexp(a, self.exp)
        if lo < _TINY:  # subnormal or 0: ldexp rounded; step down
            lo = max(0.0, math.nextafter(lo, 0.0))
        try:
            hi = math.ldexp(b, self.exp)
        except OverflowError:
            hi = math.inf
        if hi < _TINY:
            hi = math.nextafter(hi, math.inf)
        return lo, min(1.0, hi)

    @property
    def value(self) -> float:
        """Nearest float (0.0 if p underflows)."""
        return 0.0 if self.zero else math.ldexp(self.mant, self.exp)


def ve_bounds(C: Circuit, D: Product, max_width: int = 22) -> VEResult | None:
    """Pr_D[C = 1] with a proved relative error bound (see the module
    docstring), or None if the greedy order is wider than max_width."""
    C = binarize(C)
    cone = C.cone()
    if any(len(C.args[g]) + 1 > max_width + 1 for g in cone):
        return None  # a single gate factor is already too wide
    factors: list[Factor] = []
    for g in cone:
        if C.ops[g] == "IN":
            q = float(D.q[g])
            factors.append(Factor((g,), np.array([1.0 - q, q]), r=1))
        else:
            factors.append(_gate_factor(C, g))
    factors.append(Factor((C.output,), np.array([0.0, 1.0])))
    adj: dict[int, set] = {v: set() for v in cone}
    for f in factors:
        for u in f.vars:
            adj[u].update(x for x in f.vars if x != u)
    remaining = set(cone)
    bucket: dict[int, list[Factor]] = {v: [] for v in cone}
    for f in factors:
        for v in f.vars:
            bucket[v].append(f)
    alive = {id(f): f for f in factors}
    mant, ex, r_acc = 1.0, 0, 0  # product of the eliminated scalars
    width = 0
    heap = [(len(adj[v]), v) for v in remaining]
    heapq.heapify(heap)
    while remaining:
        # greedy min-degree order (lazy heap); give up as soon as the
        # cheapest elimination is wider than max_width
        while True:
            dgr, best = heapq.heappop(heap)
            if best in remaining and dgr == len(adj[best] & remaining):
                break
            if best in remaining:
                heapq.heappush(heap, (len(adj[best] & remaining), best))
        v = best
        nb = adj[v] & remaining
        if len(nb) > max_width:
            return None
        width = max(width, len(nb))
        fs = [f for f in bucket[v] if id(f) in alive]
        if not fs:  # cannot happen: a product keeps the variables it was built on
            return None
        for f in fs:
            del alive[id(f)]
        new = _sum_out(_multiply(fs), v)
        if not np.any(new.M > 0):
            return VEResult(True, width=width)  # no positive term: p = 0 exactly
        if new.vars:
            alive[id(new)] = new
            for u in new.vars:
                bucket[u].append(new)
        else:
            mant, e = math.frexp(mant * float(new.M))  # both in [1/2, 1)
            ex += e + int(new.E)
            r_acc += new.r + 1
        for a_ in nb:
            adj[a_].update(nb - {a_})
            adj[a_].discard(v)
        remaining.discard(v)
        for a_ in nb:
            heapq.heappush(heap, (len(adj[a_] & remaining), a_))
    if alive:  # cannot happen: every factor's variables were eliminated
        return None
    return VEResult(False, mant, ex, _gamma(r_acc), width)


def exact_ve(C: Circuit, D: Product, max_width: int = 22):
    """Pr_D[C = 1] as the nearest float (which may underflow to 0 for a tiny
    positive p; use ve_bounds for certified bounds), or None if declined."""
    res = ve_bounds(C, D, max_width)
    return None if res is None else res.value
