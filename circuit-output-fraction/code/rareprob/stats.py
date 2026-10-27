"""Confidence intervals for means of [0,1]-valued samples, and a sequential
relative-error estimator built from them.

All intervals here are valid for i.i.d. samples with values in [0, 1], by
Hoeffding's (1963, Thm. 1) relative-entropy form of the Chernoff bound:
Pr[mean >= mu + t] <= exp(-N KL(mu + t || mu)), and symmetrically.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable

import numpy as np


_U = 2.0 ** -53  # unit roundoff


def _kl_terms(a: float, b: float) -> tuple[float, float]:
    """The two summands a log(a/b) and (1-a) log((1-a)/(1-b)) of KL(a||b),
    with a clipped to [0, 1] and b to [1e-300, 1 - 1e-16] (clipping b only
    lowers KL(a||b) on the side of a it is on, so a test that excludes b
    when KL is large stays conservative)."""
    a = min(max(a, 0.0), 1.0)
    b = min(max(b, 1e-300), 1 - 1e-16)
    t1 = a * math.log(a / b) if a > 0 else 0.0
    t2 = (1 - a) * math.log((1 - a) / (1 - b)) if a < 1 else 0.0
    return t1, t2


def kl_bern(a: float, b: float) -> float:
    t1, t2 = _kl_terms(a, b)
    return t1 + t2


def _kl_exceeds(a: float, b: float, c: float) -> bool:
    """True only if KL(a||b) > c in exact arithmetic (a, b, c as given).

    The computed value carries an absolute error below
    4u + 5u(|t1| + |t2|) (u = 2^-53: the quotients, 1 - a, 1 - b, the logs
    and the products each add a relative error of an ulp or two, and the
    two terms nearly cancel when b is close to a); we subtract the larger
    bound 2^-49 (1 + |t1| + |t2|) before comparing."""
    t1, t2 = _kl_terms(a, b)
    return (t1 + t2) - 2.0 ** -49 * (1.0 + abs(t1) + abs(t2)) > c


def kl_interval(mean: float, N: int, delta: float, rel_err: float = 0.0) -> tuple[float, float]:
    """Two-sided (1 - delta) interval for the mean of N i.i.d. [0,1] samples,
    the Hoeffding-KL interval {m : N KL(mean||m) <= ln(2/delta)}.

    Floating point: a candidate endpoint is excluded only if its KL value is
    certainly above c = ln(2/delta)/N (see _kl_exceeds; c is inflated by a
    relative 2^-49 for its own rounding), and the bisection returns excluded
    points, so the result contains the exact interval. `rel_err` bounds the
    relative error of `mean` itself (e.g. of a floating-point sum): the
    lower end is computed at mean (1 - rel_err) and the upper end at
    mean (1 + rel_err); both ends increase with the mean."""
    if N == 0:
        return 0.0, 1.0
    c = math.log(2.0 / delta) / N * (1 + 2.0 ** -49)
    mean = min(max(mean, 0.0), 1.0)
    m_lo = mean * (1 - rel_err) if rel_err else mean
    m_hi = min(1.0, mean * (1 + rel_err)) if rel_err else mean

    def lo(mean: float) -> float:
        if mean <= 0.0:
            return 0.0
        a, b = 0.0, mean  # kl(mean||mu) decreasing in mu on [0, mean]; a is excluded or 0
        if not _kl_exceeds(mean, 1e-300, c):
            return 0.0
        for _ in range(200):
            m = math.sqrt(a * b) if a > 0 else b / 2
            if not a < m < b:
                break
            if _kl_exceeds(mean, m, c):
                a = m
            else:
                b = m
            if b - a <= 1e-14 * b:
                break
        return a

    def hi(mean: float) -> float:
        if mean >= 1.0:
            return 1.0
        a, b = mean, 1.0  # kl(mean||mu) increasing in mu on [mean, 1]; b is excluded or 1
        if not _kl_exceeds(mean, 1 - 1e-16, c):
            return 1.0
        for _ in range(200):
            m = (a + b) / 2
            if not a < m < b:
                break
            if _kl_exceeds(mean, m, c):
                b = m
            else:
                a = m
            if b - a <= 1e-14 * max(b, 1e-300):
                break
        return b

    return lo(m_lo), hi(m_hi)


@dataclass
class Estimate:
    """Interval [lo, hi] for an unknown nonnegative quantity, plus a point value."""

    value: float
    lo: float
    hi: float
    samples: int
    evaluations: int  # circuit evaluations spent
    delta: float
    note: str = ""

    @property
    def ratio(self) -> float:
        return self.hi / self.lo if self.lo > 0 else math.inf

    def contains(self, p: float) -> bool:
        return self.lo <= p <= self.hi

    def scaled(self, c: float) -> "Estimate":
        return Estimate(self.value * c, self.lo * c, self.hi * c, self.samples,
                        self.evaluations, self.delta, self.note)


def sum_rel_err(kmax: int) -> float:
    """A bound on the relative error of the mean computed by sequential_mean
    when its largest batch with values other than 0 and 1 has kmax samples
    (kmax = 0 if there is none): (kmax + 3) u / (1 - (kmax + 3) u), u = 2^-53,
    inflated slightly for its own rounding."""
    m = (kmax + 3) * _U
    return m / (1 - m) * (1 + 2.0 ** -40)


def sequential_mean(
    draw: Callable[[int], np.ndarray],
    eps: float,
    delta: float,
    max_samples: int = 10**7,
    first: int = 1024,
    cost_per_sample: int = 1,
) -> Estimate:
    """Estimate the mean mu of a [0,1]-valued sampler to relative error eps.

    draw(k) returns k fresh i.i.d. samples in [0,1]. Batches double in size;
    after stage j the KL interval is computed at level delta_j = delta * 6 /
    (pi^2 j^2) on all samples so far, so that with probability >= 1 - delta
    every interval ever computed contains mu (union bound). We stop when
    hi <= (1 + eps) * lo or when max_samples is reached; the returned interval
    is valid in either case.

    A sample outside [0, 1] (or not finite) raises ValueError: it means that
    the caller's weights are wrong (e.g. an envelope that does not dominate),
    and clipping it would hide that. Floating point: a batch of 0/1 samples is
    summed exactly; otherwise the computed sum of k nonnegative samples is
    within a relative (k - 1) u / (1 - (k - 1) u) of the exact one, u = 2^-53,
    whatever the summation order, and kl_interval is told this relative error
    (plus 3u for combining the batches and dividing by N).
    """
    parts: list[float] = []
    N = 0
    j = 0
    k = first
    kmax = 0  # largest batch with non-0/1 values
    lo, hi = 0.0, 1.0
    while True:
        j += 1
        k = min(k, max_samples - N)
        if k <= 0:
            break
        z = np.asarray(draw(k), dtype=float).ravel()
        if z.size != k:
            raise ValueError("sequential_mean: draw(k) must return k samples")
        # the KL interval needs samples in [0, 1]: checked explicitly (an
        # assert would vanish under python -O), with no tolerance
        if not np.isfinite(z).all() or z.min(initial=0.0) < 0.0 or z.max(initial=0.0) > 1.0:
            raise ValueError("sequential_mean: samples must lie in [0, 1]")
        parts.append(float(z.sum()))
        if not np.all((z == 0.0) | (z == 1.0)):
            kmax = max(kmax, k)
        N += k
        total = math.fsum(parts)
        rel = sum_rel_err(kmax)
        dj = delta * 6.0 / (math.pi**2 * j * j)
        l, h = kl_interval(total / N, N, dj, rel_err=rel)
        lo, hi = max(lo, l), min(hi, h)  # intersection of valid intervals is valid
        if lo > 0 and hi <= (1 + eps) * lo:
            break
        if N >= max_samples:
            break
        k = N  # double
    mean = math.fsum(parts) / max(N, 1)
    point = min(max(mean, lo), hi)
    return Estimate(point, lo, hi, N, N * cost_per_sample, delta)


def dklr_stopping_rule(draw1: Callable[[], float], eps: float, delta: float,
                       max_samples: int = 10**8) -> tuple[float | None, int]:
    """Dagum-Karp-Luby-Ross Stopping Rule Algorithm for a [0,1] mean mu > 0.

    Returns (estimate, samples) with Pr[|est/mu - 1| > eps] <= delta for
    0 < eps < 1, provided the rule stops by itself. If max_samples samples
    are drawn first, the rule has no guarantee and the estimate is None.
    Samples outside [0, 1] raise ValueError.
    """
    if not (0 < eps < 1 and 0 < delta < 1):
        raise ValueError("dklr_stopping_rule needs 0 < eps < 1 and 0 < delta < 1")
    lam = math.e - 2
    ups = 4 * lam * math.log(2 / delta) / eps**2
    ups1 = 1 + (1 + eps) * ups
    s, N = 0.0, 0
    while s < ups1:
        if N >= max_samples:
            return None, N
        x = float(draw1())
        if not 0.0 <= x <= 1.0:
            raise ValueError("dklr_stopping_rule: samples must lie in [0, 1]")
        s += x
        N += 1
    return ups1 / N, N


def mc_samples_needed(p: float, eps: float, delta: float) -> float:
    """Samples a Monte-Carlo run needs before its (1 - delta) KL interval
    has ratio <= 1 + eps, when the empirical mean equals p (fixed-N
    interval, no sequential correction: this favours Monte Carlo).
    For tiny p uses the asymptotic N ~ c / p with c computed at p0 = 1e-6."""
    def ok(N):
        lo, hi = kl_interval(p, int(N), delta)
        return lo > 0 and hi <= (1 + eps) * lo

    if p < 1e-6:
        return mc_samples_needed(1e-6, eps, delta) * 1e-6 / p
    a, b = 1.0, 1.0
    while not ok(b):
        b *= 2
    a = b / 2
    while b - a > max(1.0, 1e-3 * b):
        m = (a + b) / 2
        if ok(m):
            b = m
        else:
            a = m
    return b
