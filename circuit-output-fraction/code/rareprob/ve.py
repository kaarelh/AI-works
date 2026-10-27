"""Exact output probability by variable elimination on the circuit's
constraint graph (the Tseitin factor graph), with a greedy min-degree elimination order.

Cost is O(|C| * 2^(w+1)) where w is the width of the elimination order found, so
this is polynomial when the order has width O(log |C|); a greedy order is a
heuristic, so a circuit of small treewidth may still be refused.
Factors are dense numpy tables over at most `max_width + 1` binary variables;
if the order needs more, we give up (return None) - an honest "no verdict".
"""

from __future__ import annotations

import numpy as np

from .circuit import Circuit
from .dist import Product


class Factor:
    __slots__ = ("vars", "table")

    def __init__(self, vars_, table):
        self.vars = tuple(vars_)
        self.table = table  # shape (2,)*len(vars)


def _gate_factor(C: Circuit, g: int) -> Factor:
    op, a = C.ops[g], C.args[g]
    vs = list(dict.fromkeys(list(a) + [g]))
    k = len(vs)
    T = np.zeros((2,) * k)
    pos = {v: j for j, v in enumerate(vs)}
    for idx in np.ndindex(*(2,) * k):
        ins = [idx[pos[u]] for u in a]
        if op == "CONST":
            out = C.params[g]
        elif op == "NOT":
            out = 1 - ins[0]
        elif op == "AND":
            out = int(all(ins))
        elif op == "OR":
            out = int(any(ins))
        elif op == "XOR":
            out = sum(ins) % 2
        elif op == "THR":
            w, t = C.params[g]
            out = int(sum(wi * xi for wi, xi in zip(w, ins)) >= t - 1e-12)
        else:
            raise ValueError(op)
        T[idx] = 1.0 if idx[pos[g]] == out else 0.0
    return Factor(vs, T)


def _multiply(fs: list[Factor]) -> Factor:
    vs = []
    for f in fs:
        for v in f.vars:
            if v not in vs:
                vs.append(v)
    letters = {v: chr(97 + j) if j < 26 else chr(65 + j - 26) for j, v in enumerate(vs)}
    assert len(vs) <= 52
    expr = ",".join("".join(letters[v] for v in f.vars) for f in fs) + "->" + "".join(letters[v] for v in vs)
    return Factor(vs, np.einsum(expr, *[f.table for f in fs]))


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


def exact_ve(C: Circuit, D: Product, max_width: int = 22):
    """Pr_D[C = 1] exactly (float), or None if the min-fill width exceeds max_width."""
    C = binarize(C)
    cone = C.cone()
    if any(len(C.args[g]) + 1 > max_width + 1 for g in cone):
        return None  # a single gate factor is already too wide
    factors: list[Factor] = []
    for g in cone:
        if C.ops[g] == "IN":
            q = D.q[g]
            factors.append(Factor((g,), np.array([1 - q, q])))
        else:
            factors.append(_gate_factor(C, g))
    factors.append(Factor((C.output,), np.array([0.0, 1.0])))
    # adjacency for min-fill
    adj: dict[int, set] = {v: set() for v in cone}
    for f in factors:
        for u in f.vars:
            adj[u].update(x for x in f.vars if x != u)
    remaining = set(cone)
    bucket: dict[int, list[Factor]] = {v: [] for v in cone}
    for f in factors:
        bucket_key = f.vars
        for v in bucket_key:
            bucket[v].append(f)
    alive = {id(f): f for f in factors}
    scale = 0.0  # log-scale to avoid underflow
    import heapq

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
        fs = [f for f in bucket[v] if id(f) in alive]
        for f in fs:
            del alive[id(f)]
        prod = _multiply(fs) if fs else Factor((v,), np.ones(2))
        ax = prod.vars.index(v)
        new = Factor(prod.vars[:ax] + prod.vars[ax + 1:], prod.table.sum(axis=ax))
        mx = new.table.max() if new.table.size else 0.0
        if mx > 0 and new.vars:
            new.table = new.table / mx
            scale += np.log(mx)
        elif not new.vars:
            if mx == 0:
                return 0.0
            scale += np.log(float(new.table))
            new.table = np.array(1.0)
        alive[id(new)] = new
        for u in new.vars:
            bucket[u].append(new)
        for a_ in nb:
            adj[a_].update(nb - {a_})
            adj[a_].discard(v)
        remaining.discard(v)
        for a_ in nb:
            heapq.heappush(heap, (len(adj[a_] & remaining), a_))
    rest = 1.0
    for f in alive.values():
        rest *= float(f.table) if not f.vars else float(f.table.sum())
    return float(np.exp(scale) * rest)
