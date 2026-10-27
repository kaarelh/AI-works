"""The Part-1 meta-procedure: run every applicable sound method and intersect.

Methods (each sound on every input, each recognises its class syntactically):
  ve       exact variable elimination when the min-fill width is small
  janson   Harris-Janson sandwich when C is a unate CNF
  tilting  exponential tilting when C is a unit-weight threshold of
           sub-circuits on disjoint small blocks
  dfsb     Decompose-Force-Sample-Branch (always applicable)
With probability >= 1 - delta all intervals are valid simultaneously (each
method gets delta / #methods), hence so is their intersection.
"""

from __future__ import annotations

import math

import numpy as np

from .circuit import Circuit
from .dfsb import dfsb_estimate
from .dist import Product
from .janson import is_unate, janson_interval
from .stats import Estimate
from .tilting import Block, tilted_estimate
from .ve import exact_ve


def as_cnf(C: Circuit):
    """Clauses [(i, b), ...] if C is syntactically an AND of ORs of literals."""
    g = C.output
    if C.ops[g] != "AND":
        return None

    def lit(u):
        if C.ops[u] == "IN":
            return (u, 1)
        if C.ops[u] == "NOT" and C.ops[C.args[u][0]] == "IN":
            return (C.args[u][0], 0)
        return None

    clauses = []
    for c in C.args[g]:
        if C.ops[c] == "OR":
            ls = [lit(u) for u in C.args[c]]
        else:
            ls = [lit(c)]
        if any(l is None for l in ls):
            return None
        clauses.append(ls)
    return clauses


def as_block_threshold(C: Circuit, max_block: int = 12):
    """(blocks, t) if C's output is THR with unit weights over sub-circuits on
    pairwise disjoint supports of at most max_block variables."""
    g = C.output
    if C.ops[g] != "THR":
        return None
    w, t = C.params[g]
    if any(x != 1.0 for x in w):
        return None
    sup = C.supports()
    used = 0
    blocks = []
    for u in C.args[g]:
        s = sup[u]
        if s & used or bin(s).count("1") > max_block:
            return None
        used |= s
        vs = [i for i in range(C.n) if (s >> i) & 1]
        sub = Circuit(C.n, list(C.ops), list(C.args), list(C.params), u)
        blocks.append(Block(vs, sub, 1.0))
    return blocks, t


def meta_estimate(C: Circuit, D: Product, eps: float = 0.1, delta: float = 0.05, rng=None,
                  ve_width: int = 18, **dfsb_kw) -> Estimate:
    rng = np.random.default_rng() if rng is None else rng
    results = []
    cnf = as_cnf(C)
    thr = as_block_threshold(C)
    methods = 2 + (cnf is not None and is_unate(cnf)) + (thr is not None)
    dm = delta / methods
    # exact variable elimination
    p = exact_ve(C, D, max_width=ve_width)
    if p is not None:
        return Estimate(p, p * (1 - 1e-9), p * (1 + 1e-9), 0, 0, 0.0, "exact (variable elimination)")
    if cnf is not None and is_unate(cnf):
        e = janson_interval(cnf, D)
        e.note = "janson: " + e.note
        results.append(e)
    if thr is not None:
        blocks, t = thr
        e = tilted_estimate(blocks, t, D, C.n, eps=eps, delta=dm, rng=rng)
        e.note = "tilting: " + e.note
        results.append(e)
    if not any(r.lo > 0 and r.hi <= (1 + eps) * r.lo for r in results):
        e = dfsb_estimate(C, D, eps=eps, delta=dm, rng=rng, **dfsb_kw)
        e.note = "dfsb: " + e.note
        results.append(e)
    lo = max(r.lo for r in results)
    hi = min(r.hi for r in results)
    if lo > hi:  # possible only on the delta-probability failure event
        lo, hi = min(lo, hi), max(lo, hi)
    val = math.sqrt(lo * hi) if lo > 0 else hi / 2
    return Estimate(val, lo, hi, sum(r.samples for r in results), sum(r.evaluations for r in results),
                    delta, " | ".join(r.note for r in results))
