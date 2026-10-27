"""The Part-1 meta-procedure: run every applicable sound method and intersect.

Methods (each sound on every input, each recognises its class syntactically):
  ve       exact variable elimination when a greedy elimination order is narrow
           (certified floating-point bounds; deterministic)
  janson   Harris-Janson sandwich when C is a unate CNF (deterministic)
  tilting  exponential tilting when C is a unit-weight threshold of
           sub-circuits on disjoint small blocks
  ltc      tilted Glauber sampling (TG) when C is a local threshold circuit
           [S >= t] (AND H) with overlapping scopes
  presolve exact affine / solved-form presolve when the AND-spine has such
           conjuncts and the factor M is at most 1/2, with DFSB on the reduced
           circuit when every pivot is uniform
  affine   the affine-union envelope (Karp-Luby-Madras) when its mass is at
           most 1/2
  ctx      context-width compilation to a DNNF (envelope estimator on it)
  dfsb     Decompose-Force-Sample-Branch (always applicable)
Applicability is decided before any sampling. Each method gets confidence
delta / (3 M), M the number of methods that may run, so with probability
>= 1 - delta/3 all intervals are valid simultaneously, hence so is their
intersection; and a method that is complete on C (tight with probability
>= 1 - 2 delta/(3M)) makes the intersection tight with probability >= 1 - delta.
A method is skipped once some interval is already tight (this changes neither
soundness nor completeness), and a deterministic certificate (VE, p = 0 from
the affine structure) is returned at once. An empty intersection (possible
only on the failure event) gives [0, 1]. Every method has a polynomial
running-time bound (width cut-offs, sample caps, budgets), so the whole
procedure does too.
"""

from __future__ import annotations

import math

import numpy as np

from .affine import affine_envelope, anf_all, klm_estimate, make_pieces, presolve, presolve_estimate
from .circuit import Circuit
from .ctxwidth import compile_ctx
from .dfsb import dfsb_estimate
from .dist import Product
from .envelope import _TINY, _exp_down, _exp_up, envelope_estimate
from .janson import is_unate, janson_interval
from .localthr import ltc_from_circuit, tg_estimate
from .nnf import to_nnf
from .stats import Estimate
from .tilting import Block, tilted_estimate
from .ve import ve_bounds


def as_cnf(C: Circuit):
    """Clauses [(i, b), ...] if C is syntactically an AND of ORs of literals,
    canonicalised: repeated literals are merged (a literal is one condition,
    however often it occurs), tautological clauses (x OR NOT x) are dropped
    and repeated clauses are kept once. Each change preserves the function,
    and the Harris/Janson/CFTP bounds need exactly these clause sets: a
    repeated literal would be counted twice in P(clause false), and a
    tautology would make the CNF look non-unate. An empty clause (an OR
    without children) stays: then p = 0."""
    g = C.output
    if C.ops[g] != "AND":
        return None

    def lit(u):
        if C.ops[u] == "IN":
            return (u, 1)
        if C.ops[u] == "NOT" and C.ops[C.args[u][0]] == "IN":
            return (C.args[u][0], 0)
        return None

    clauses, seen = [], set()
    for c in C.args[g]:
        if C.ops[c] == "OR":
            ls = [lit(u) for u in C.args[c]]
        else:
            ls = [lit(c)]
        if any(l is None for l in ls):
            return None
        s = set(ls)
        if any((i, 1 - b) in s for (i, b) in s):
            continue  # tautology: identically true
        key = tuple(sorted(s))
        if key not in seen:
            seen.add(key)
            clauses.append(list(key))
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


def _tight(results, eps: float) -> bool:
    return any(r.lo > 0 and r.hi <= (1 + eps) * r.lo for r in results)


def _from_log(le, prefix: str) -> Estimate:
    """Estimate from an interval in natural-log coordinates, rounded outwards
    (lower ends below the normal range flush to 0)."""
    lo = _exp_down(le.log_lo)
    hi = min(1.0, _exp_up(le.log_hi))
    val = min(max(math.exp(le.log_value) if le.log_value > -math.inf else 0.0, lo), hi)
    return Estimate(val, lo, hi, le.samples_ti + le.samples_is, le.samples_ti + le.samples_is,
                    le.delta, prefix + le.note + f"; ln-bounds [{le.log_lo:.6g}, {le.log_hi:.6g}]")


def meta_estimate(C: Circuit, D: Product, eps: float = 0.1, delta: float = 0.05, rng=None,
                  ve_width: int = 18, ctx_max_cw: int = 10, use_ltc: bool = True, use_affine: bool = True,
                  ltc_L: int = 20_000, ltc_max_is: int = 20_000, affine_max_samples: int = 10**5,
                  **dfsb_kw) -> Estimate:
    rng = np.random.default_rng() if rng is None else rng
    # exact variable elimination: deterministic, with a proved relative error
    # bound and an exact zero kept separate (ve.ve_bounds); nothing else can
    # improve on it in floating point, so it is returned at once
    ve = ve_bounds(C, D, max_width=ve_width)
    if ve is not None:
        if ve.zero:
            return Estimate(0.0, 0.0, 0.0, 0, 0, 0.0, "exact (variable elimination): p = 0")
        lo, hi = ve.interval()
        l2lo, l2hi = ve.log2_bounds()
        return Estimate(min(max(ve.value, lo), hi), lo, hi, 0, 0, 0.0,
                        f"exact (variable elimination, width {ve.width}): "
                        f"log2 p in [{l2lo:.12g}, {l2hi:.12g}]")
    # applicability, decided before any sampling
    cnf = as_cnf(C)
    unate = cnf is not None and is_unate(cnf)
    thr = as_block_threshold(C)
    ltc = ltc_from_circuit(C) if use_ltc and thr is None else None
    pre, spaces = None, None
    if use_affine:
        A = anf_all(C)
        pre = presolve(C, D, anf=A)
        if pre.infeasible:  # deductive: the AND-spine is an inconsistent affine system
            return Estimate(0.0, 0.0, 0.0, 0, 0, 0.0, "affine presolve: inconsistent spine, p = 0")
        spaces = affine_envelope(C, anf=A)
        if not spaces:  # deductive: C^-1(1) lies in an empty union
            return Estimate(0.0, 0.0, 0.0, 0, 0, 0.0, "affine envelope: empty, p = 0")
        pieces = make_pieces(spaces, D)
        if sum(P.mass for P in pieces[0]) > 0.5:
            spaces = None  # explains less than one bit (e.g. the whole cube): not applicable
        if pre.rank == 0 or pre.log2_M > -1:
            pre = None  # explains less than one bit (e.g. one biased literal): DFSB's (F) does as well
    ctx_env = compile_ctx(to_nnf(C, flatten=False), max_cw=ctx_max_cw) if ctx_max_cw else None
    methods = (2 + unate + (thr is not None) + (ltc is not None) + (pre is not None)
               + (spaces is not None) + (ctx_env is not None))
    dm = delta / (3 * methods)
    results = []
    if unate:
        e = janson_interval(cnf, D)
        # below the normal range exp() has an absolute error of up to an ulp of 0,
        # which relative slack cannot absorb: flush the lower end, widen the upper
        if e.lo < 2 * _TINY:
            e.lo = 0.0
        if 0 < e.hi < _TINY:
            e.hi += 4 * math.ulp(0.0)
        e.note = "janson: " + e.note
        results.append(e)
    if thr is not None and not _tight(results, eps):
        blocks, t = thr
        e = tilted_estimate(blocks, t, D, C.n, eps=eps, delta=dm, rng=rng)
        e.note = "tilting: " + e.note
        results.append(e)
    if pre is not None and not _tight(results, eps):
        inner = None
        if not pre.nonuniform:
            def inner(Cr, DD, e_, d_):
                return dfsb_estimate(Cr, DD, eps=e_, delta=d_, rng=rng, **dfsb_kw)
        results.append(presolve_estimate(C, D, eps, dm, rng, max_samples=affine_max_samples,
                                         inner=inner, pre=pre))
    if spaces is not None and not _tight(results, eps):
        results.append(klm_estimate(C, D, pieces[0], eps, dm, rng, affine_max_samples,
                                    f"(relaxed {pieces[1]}) " if pieces[1] else ""))
    if ltc is not None and not _tight(results, eps):
        try:
            le = tg_estimate(ltc, D.q, eps=eps, delta=dm, rng=rng, L=ltc_L, max_is=ltc_max_is)
            results.append(_from_log(le, "local threshold (TG): "))
        except (ValueError, AssertionError):  # marginals in {0, 1}, neighbourhoods too large: decline
            pass
    if ctx_env is not None and not _tight(results, eps):
        e = envelope_estimate(C, D, ctx_env, eps=eps, delta=dm, rng=rng)
        e.note = "context-width DNNF: " + e.note
        results.append(e)
    if not _tight(results, eps):
        e = dfsb_estimate(C, D, eps=eps, delta=dm, rng=rng, **dfsb_kw)
        e.note = "dfsb: " + e.note
        results.append(e)
    lo = max(r.lo for r in results)
    hi = min(r.hi for r in results)
    if lo > hi:  # possible only on the failure event: no verdict
        lo, hi = 0.0, 1.0
    val = math.sqrt(lo * hi) if lo > 0 else hi / 2
    return Estimate(val, lo, hi, sum(r.samples for r in results), sum(r.evaluations for r in results),
                    delta, " | ".join(r.note for r in results))
