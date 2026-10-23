"""Shared helpers for the C-bridge checks (kl inversion, Cover counts, log binomials)."""
import math
import numpy as np


def kl(p, q):
    p = min(max(p, 0.0), 1.0)
    q = min(max(q, 1e-300), 1 - 1e-16)
    a = p * math.log(p / q) if p > 0 else 0.0
    b = (1 - p) * math.log((1 - p) / (1 - q)) if p < 1 else 0.0
    return a + b


def klinv_upper(p_hat, eps):
    """sup{p in [p_hat, 1] : kl(p_hat || p) <= eps} (bisection)."""
    if eps <= 0:
        return p_hat
    lo, hi = p_hat, 1.0
    if kl(p_hat, hi) <= eps:
        return 1.0
    for _ in range(100):
        mid = (lo + hi) / 2
        if kl(p_hat, mid) > eps:
            hi = mid
        else:
            lo = mid
    return hi


def log_binom(a, b):
    if b < 0 or b > a:
        return -math.inf
    return math.lgamma(a + 1) - math.lgamma(b + 1) - math.lgamma(a - b + 1)


def logsumexp(v):
    v = [x for x in v if x > -math.inf]
    m = max(v)
    return m + math.log(sum(math.exp(x - m) for x in v))


def log_Phi(npts, T):
    """log of Phi(N, T) = 2 * sum_{i=0}^{T} C(N-1, i): number of affine threshold dichotomies of N points in R^T."""
    if npts <= 0:
        return 0.0
    if T >= npts - 1:
        return npts * math.log(2.0)
    return math.log(2.0) + logsumexp([log_binom(npts - 1, i) for i in range(T + 1)])


def log_Phi_cube(T, rank_cap):
    """Points are (+-1)^T vectors from a GF(2)-linear image of rank <= rank_cap: at most 2^min(T, rank_cap) points."""
    r = min(T, rank_cap)
    # number of points is 2^r; use exact big-int when small, else log formula
    npts = 2 ** r
    return log_Phi(npts, T)
