"""Re-referee (logic and computation of the changed passages) of depth-two.md, round 3.

Independent of the author's scripts: binomial statistics through log-gamma (not the pmf recursion), the worst
case on the event written from the formulas of section 4 (not from Theorem 5.1 at the event corner), and the
Hadamard bound written from the proof of Proposition 5.3.

Checks, numbered as in the report:
  N1  Corollary 5.2 "Numbers", c = 1: a = 1/n and a = 1/d (first positive d, first d with bound >= 2 eps_d,
      the d = 33 values for a = 1/d, the ratio at d = 33 / 34, monotonicity of the ratio, maximum and location).
  N2  Table after Proposition 5.3: c = 0.1 sqrt M at M = 2^10 (0.01549 -> 0.015); the other entries.
  N3  Proposition 5.3, case c <= sqrt M, as now proved with Q <= M: the constant 2 sqrt 3 and the size of the
      O(M^{-1/3}) remainder, uniformly over c in [1/M, sqrt M].
  N4  Remark 5.2a: g*, Delta, Delta^2/6, and a brute-force search over width-one networks (clipped and not).
  N5  Remark 5.3a: |U|/n, 1/(2e) > 1/7, the d = ceil(n/b) variant (e^{-b}/2), the competitor accuracy,
      and the Gibbs-risk variant (averaging over a posterior that depends on the sample only).
  N6  Section 6 erratum, numerics bullet: phi and phi - c/G from the red-team run files.
  N7  Remark 5.7a algebra: E_* + 1 <= (d(d+1)+4) n^{4 alpha}, 4 + (U+1)^2 <= 8 n^{4 alpha}; the c-range of
      Corollary 8.1 at H = 1; the n_delta step; the rate at c = log^3 n.
  N8  Fixed-d row: (8 M/delta + 4 c t)/n at t = 1 and the probability 1 - delta - M e^{-n/(8M)}, by simulation.
"""
import math
import mpmath as mp
import numpy as np

mp.mp.dps = 120
rng = np.random.default_rng(20261111)


def bin_stats(d, lam=1):
    """beta_d = E[1/K; K>=1], p_d = P(K>=1), K ~ Bin(n, 1/M), M = 2^d, n = ceil(lam M), via log-gamma."""
    M = mp.mpf(2) ** d
    n = mp.ceil(mp.mpf(lam) * M)
    lp, lq = -mp.log(M), mp.log1p(-1 / M)
    p0 = mp.e ** (n * lq)
    s = mp.mpf(0)
    k = 1
    lfall = mp.mpf(0)  # log of n (n-1) ... (n-k+1), accumulated as k ln n + sum log1p(-j/n): no cancellation
    while True:
        lfall += mp.log(n) + mp.log1p(-(k - 1) / n)
        lpmf = lfall - mp.loggamma(k + 1) + k * lp + (n - k) * lq
        t = mp.e ** lpmf
        s += t / k
        if k > 5 and t < mp.mpf(10) ** (-100):
            break
        k += 1
        if k > n:
            break
    return M, n, s, 1 - p0


def F_d(d):
    return 1 + (d + 1) * (d + 2) ** 2


def gam(l):
    l = mp.mpf(l)
    return (1 - mp.e ** (-l)) ** 2 / (4 * l)


def beta_series(l):
    l = mp.mpf(l)
    return mp.e ** (-l) * mp.nsum(lambda k: l ** k / (k * mp.factorial(k)), [1, mp.inf])


def psi_lower(d, c, a, lam=1, st=None):
    """underline Psi_tri and underline Psi_cor of section 4, written from their displayed formulas."""
    M, n, b, p = st or bin_stats(d, lam)
    lamp = n / M
    h = 2 * n ** (mp.mpf(2) / 3) / M
    c = mp.mpf(c); a = mp.mpf(a)
    th = 1 / (18 * d * c + 1)
    e0m = c * (d * F_d(d) + 1) / M
    u1 = b - h
    u2 = (1 - th) * (p + h) + e0m + th * lamp * a
    sq = lambda u: mp.sqrt(u) if u > 0 else mp.mpf(0)
    tri = max(sq(u1) - sq(u2), 0) ** 2
    num = th * (p - h - lamp * a) - e0m
    cor = max(num, 0) ** 2 / (4 * (lamp + h / 2))
    return tri, cor, th


