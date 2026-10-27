"""Tail-inversion bounds used throughout.

All bounds are upper confidence bounds on a Bernoulli mean p from k
"successes" (errors, disagreements, uncertified points) in n independent
trials, at confidence level 1 - delta.

* `binom_upper(k, n, log_delta)`: exact binomial tail inversion,
      sup { p : P[Bin(n, p) <= k] >= exp(log_delta) }.
  For a single fixed hypothesis this is the one-sided Clopper-Pearson bound.
  With log_delta = ln(delta) - L ln 2 it is the Occam bound for a hypothesis
  of prior mass 2^-L (Langford 2005, "Tutorial on practical prediction
  theory"): a union bound over a countable class with prior P gives, with
  probability >= 1 - delta, err(h) <= binom_upper(k_h, n, ln delta + ln P(h))
  simultaneously for all h.
* `kl_upper(q, c)`: sup { p >= q : kl(q || p) <= c }, the Chernoff/kl
  relaxation of the same quantity (always >= binom_upper for c = ln(1/delta)/n).

Everything is computed in log space, so priors of 2^-100000 are fine.
"""

import math

import numpy as np
from scipy.special import gammaln, logsumexp

LN2 = math.log(2.0)


def kl_bern(q, p):
    """kl(q || p) for Bernoulli parameters, with the conventions 0 ln 0 = 0."""
    q = float(q)
    p = float(p)
    if p <= 0.0:
        return 0.0 if q <= 0.0 else math.inf
    if p >= 1.0:
        return 0.0 if q >= 1.0 else math.inf
    out = 0.0
    if q > 0.0:
        out += q * math.log(q / p)
    if q < 1.0:
        out += (1.0 - q) * math.log((1.0 - q) / (1.0 - p))
    return out


def kl_upper(q, c, iters=200):
    """sup { p in [q, 1] : kl(q || p) <= c }."""
    q = min(max(float(q), 0.0), 1.0)
    if c <= 0.0:
        return q
    if q <= 0.0:
        return -math.expm1(-c)  # kl(0||p) = -ln(1-p)
    lo, hi = q, 1.0
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if kl_bern(q, mid) > c:
            hi = mid
        else:
            lo = mid
    return hi


def log_binom_cdf(k, n, p):
    """ln P[Bin(n, p) <= k], computed by log-sum-exp over the pmf."""
    if k >= n:
        return 0.0
    if p <= 0.0:
        return 0.0
    if p >= 1.0:
        return -math.inf
    j = np.arange(0, k + 1, dtype=np.float64)
    logpmf = (gammaln(n + 1) - gammaln(j + 1) - gammaln(n - j + 1)
              + j * math.log(p) + (n - j) * math.log1p(-p))
    return float(logsumexp(logpmf))


def binom_upper(k, n, log_delta, iters=200):
    """sup { p : P[Bin(n, p) <= k] >= exp(log_delta) } (exact tail inversion).

    log_delta may be extremely negative (e.g. ln delta - L ln 2 for a code of
    length L bits).  Returns 1.0 when the bound is vacuous.
    """
    k = int(k)
    n = int(n)
    if not 0 <= k <= n:
        raise ValueError("need 0 <= k <= n")
    if log_delta >= 0.0:
        return k / n
    if k == n:
        return 1.0
    if k == 0:
        # P[Bin(n,p) = 0] = (1-p)^n >= delta'  <=>  p <= 1 - delta'^(1/n)
        return -math.expm1(log_delta / n)
    lo, hi = k / n, 1.0
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if log_binom_cdf(k, n, mid) < log_delta:
            hi = mid
        else:
            lo = mid
        if hi - lo < 1e-12:
            break
    return hi


def occam_bound(k_err, n, code_bits, delta):
    """Occam bound for a hypothesis with a prefix code of `code_bits` bits.

    Holds simultaneously over all hypotheses of a fixed code with
    probability >= 1 - delta over the n training examples.
    """
    return binom_upper(k_err, n, math.log(delta) - code_bits * LN2)


def occam_bound_kl(k_err, n, code_bits, delta):
    """kl relaxation of `occam_bound` (looser; reported for comparison)."""
    return kl_upper(k_err / n, (code_bits * LN2 + math.log(1.0 / delta)) / n)


def cp_upper(k, n, delta):
    """One-sided Clopper-Pearson upper bound for a single Bernoulli mean."""
    return binom_upper(k, n, math.log(delta))


def bits_for_vacuity(k_err, n, delta, target=0.5):
    """Largest code length (bits) for which the Occam bound stays <= target."""
    lo, hi = 0.0, 1e9
    if occam_bound(k_err, n, 0.0, delta) > target:
        return 0.0
    for _ in range(100):
        mid = 0.5 * (lo + hi)
        if occam_bound(k_err, n, mid, delta) > target:
            hi = mid
        else:
            lo = mid
    return lo


def vc_bound(k_err, n, vc_dim, delta):
    """A standard VC bound for comparison (Vapnik; see Shalev-Shwartz &
    Ben-David, Thm 6.11 constants are not sharp; we use the classical
    err <= emp + sqrt( (d (ln(2n/d) + 1) + ln(4/delta)) / n ) form).
    Returned value is capped at 1.
    """
    emp = k_err / n
    if vc_dim >= n:
        return 1.0
    term = (vc_dim * (math.log(2.0 * n / vc_dim) + 1.0) + math.log(4.0 / delta)) / n
    return min(1.0, emp + math.sqrt(term))
