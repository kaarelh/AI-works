"""Shared helpers for the revision checks c8-c10 (track 'universal', after the referee report).

Pure numerics; no randomness here.  Everything is in natural logs.

  log_int(g)               log of the integral over the real line of exp(g(t)), for a vectorised, unimodal g
                           (iterative grid refinement around the maximum; the tails beyond 60 nats are dropped).
  log_beta_int(a, b, n, beta)
                           log int_0^1 u^(a-1) (1-u)^(b-1) (1 + beta u)^(-n) du   (a, b > 0, beta > -1).
                           The integrand is unimodal in u: the derivative of its log, times u(1-u)(1+beta u), is a
                           quadratic in u that is positive at 0 and negative at 1.
  log_dirmult(counts, alpha)
                           log of the Dirichlet(alpha,...,alpha)-multinomial probability of a sequence with the given
                           category counts (K = len(counts) categories), i.e. E_w prod_i w_i^{n_i}.
  geom_counts(...)         category counts of geometric data.
"""
import math
import numpy as np
from scipy.special import gammaln

LN2 = math.log(2.0)


def log_int(g, lo=-60.0, hi=60.0, drop=60.0, npts=2001, max_iter=40):
    """log int exp(g(t)) dt over [lo, hi]; g vectorised and unimodal on [lo, hi]."""
    for _ in range(max_iter):
        t = np.linspace(lo, hi, npts)
        v = g(t)
        m = np.max(v)
        idx = np.nonzero(v >= m - drop)[0]
        step = t[1] - t[0]
        if len(idx) >= 400 or (idx[0] == 0 and idx[-1] == npts - 1):
            # trapezoid in log space
            w = np.exp(v - m)
            w[0] *= 0.5
            w[-1] *= 0.5
            return m + math.log(np.sum(w) * step)
        lo, hi = t[max(idx[0] - 1, 0)], t[min(idx[-1] + 1, npts - 1)]
    raise RuntimeError('log_int did not converge')


def log_beta_int(a, b, n, beta):
    """log int_0^1 u^(a-1)(1-u)^(b-1)(1+beta u)^(-n) du, via t = logit(u) (Jacobian u(1-u))."""
    def g(t):
        lu = -np.logaddexp(0.0, -t)        # log u
        l1u = -np.logaddexp(0.0, t)        # log(1-u)
        u = np.exp(lu)
        return a * lu + b * l1u - n * np.log1p(beta * u)
    return log_int(g)


def log_beta_fn(a, b):
    return float(gammaln(a) + gammaln(b) - gammaln(a + b))


def log_dirmult(counts, alpha):
    counts = np.asarray(counts, dtype=float)
    K = len(counts)
    if K == 0:
        return 0.0
    n = counts.sum()
    return float(gammaln(K * alpha) - gammaln(n + K * alpha) + np.sum(gammaln(counts + alpha)) - K * gammaln(alpha))


def geom_logpmf(q, j):
    return math.log(1 - q) + j * math.log(q)


def counts_from_path(path, upto, J):
    return np.bincount(np.minimum(path[:upto], J - 1), minlength=J)


def multinomial_geom_counts(rng, n, q, J):
    """counts of n i.i.d. Geometric(q) values (P(j) = (1-q) q^j), values >= J-1 lumped into J-1 (mass q^(J-1))."""
    p = np.array([(1 - q) * q ** j for j in range(J - 1)] + [q ** (J - 1)])
    return rng.multinomial(n, p / p.sum())
