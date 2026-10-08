"""Seeded data generators: well-specified (citation or chain derivations from a theory) and misspecified."""
import math
import random

from dtrc.syntax import parse, canon_params, num, S as SUCC, ZERO
from dtrc.templates import instantiate, meta_sort
from .grammar import Grammar
from .lik import Chain


def cite_sample(comps, w, Q, rng):
    """one L0 datum: component i ~ w, bodies from Q"""
    r = rng.random() * sum(w)
    acc = 0.0
    i = len(w) - 1
    for j, x in enumerate(w):
        acc += x
        if r < acc:
            i = j
            break
    c = comps[i]
    theta = {m: Q.sample_body(rng, meta_sort(m), ar, c.guards[m] == 'open') for m, ar in c.metas.items()}
    return canon_params(instantiate(c.T, theta)) if theta else c.T


def cite_data(theory, w, Q, n, seed):
    rng = random.Random(seed)
    return [cite_sample(theory.comps, w, Q, rng) for _ in range(n)]


def chain_data(theory, w, chain, n, seed):
    rng = random.Random(seed)
    return [chain.sample(theory.comps, w, rng) for _ in range(n)]


# ------------------------------------------------------------------------------------ misspecified
def zeta_numeral(rng, s=1.5, kmax=400):
    """numeral S^k 0 with P(k) proportional to (k+1)^-s, k <= kmax (heavy-tailed term sizes)"""
    return num(zeta_int(rng, s, kmax))


def zeta_int(rng, s=1.5, kmax=400):
    """k in 0..kmax with P(k) proportional to (k+1)^-s (inverse CDF, cached per (s, kmax))"""
    key = (s, kmax)
    cdf = _ZCACHE.get(key)
    if cdf is None:
        ws = [(k + 1) ** (-s) for k in range(kmax + 1)]
        z = sum(ws)
        acc, cdf = 0.0, []
        for x in ws:
            acc += x / z
            cdf.append(acc)
        _ZCACHE[key] = cdf
    r = rng.random()
    lo, hi = 0, len(cdf) - 1
    while lo < hi:
        mid = (lo + hi) // 2
        if cdf[mid] < r:
            lo = mid + 1
        else:
            hi = mid
    return lo


_ZCACHE = {}


def heavy_term(rng, s=1.5, kmax=400, p_num=0.7, Q=None):
    """heavy-tailed closed terms: a zeta numeral w.p. p_num, else S^k(t1 + t2) with zeta k and Q-terms"""
    if rng.random() < p_num:
        return zeta_numeral(rng, s, kmax)
    Q = Q or Grammar()
    t = ('+', Q.sample_term(rng), Q.sample_term(rng)) if rng.random() < 0.5 else \
        ('*', Q.sample_term(rng), Q.sample_term(rng))
    for _ in range(zeta_int(rng, s, kmax // 4)):
        t = SUCC(t)
    return t


def schema_data_with_terms(T, term_sampler, n, seed, var='t'):
    """instances of a one-term-metavariable template with terms from a custom sampler"""
    rng = random.Random(seed)
    return [canon_params(instantiate(T, {var: term_sampler(rng)})) for _ in range(n)]


def selected_data(gen_fn, keep, n, seed, max_tries=10 ** 6):
    """the first n data of a generator that pass a selection predicate (selected theorems)"""
    rng = random.Random(seed)
    out, k = [], 0
    while len(out) < n and k < max_tries:
        k += 1
        d = gen_fn(rng)
        if keep(d):
            out.append(d)
    return out
