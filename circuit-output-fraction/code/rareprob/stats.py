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


def kl_bern(a: float, b: float) -> float:
    a = min(max(a, 0.0), 1.0)
    b = min(max(b, 1e-300), 1 - 1e-16)
    r = 0.0
    if a > 0:
        r += a * math.log(a / b)
    if a < 1:
        r += (1 - a) * math.log((1 - a) / (1 - b))
    return r


def kl_interval(mean: float, N: int, delta: float) -> tuple[float, float]:
    """Two-sided (1 - delta) interval for the mean of N i.i.d. [0,1] samples."""
    if N == 0:
        return 0.0, 1.0
    c = math.log(2.0 / delta) / N
    mean = min(max(mean, 0.0), 1.0)

    def lo() -> float:
        if mean == 0.0:
            return 0.0
        a, b = 0.0, mean  # kl(mean||mu) decreasing in mu on [0, mean]
        if kl_bern(mean, a + 1e-300) <= c:
            return 0.0
        for _ in range(200):
            m = math.sqrt(a * b) if a > 0 else b / 2
            if kl_bern(mean, m) > c:
                a = m
            else:
                b = m
            if b - a <= 1e-14 * b:
                break
        return a

    def hi() -> float:
        if mean == 1.0:
            return 1.0
        a, b = mean, 1.0
        if kl_bern(mean, 1 - 1e-16) <= c:
            return 1.0
        for _ in range(200):
            m = (a + b) / 2
            if kl_bern(mean, m) > c:
                b = m
            else:
                a = m
            if b - a <= 1e-14 * max(b, 1e-300):
                break
        return b

    return lo(), hi()


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
    """
    total = 0.0
    N = 0
    j = 0
    k = first
    lo, hi = 0.0, 1.0
    while True:
        j += 1
        k = min(k, max_samples - N)
        if k <= 0:
            break
        z = np.asarray(draw(k), dtype=float)
        # the KL interval needs samples in [0, 1]: check explicitly (an assert
        # would vanish under python -O); tolerate only float noise at the ends
        if not np.isfinite(z).all() or z.min(initial=0.0) < -1e-12 or z.max(initial=0.0) > 1 + 1e-9:
            raise ValueError("sequential_mean: samples must lie in [0, 1]")
        z = np.clip(z, 0.0, 1.0)
        total += float(z.sum())
        N += k
        dj = delta * 6.0 / (math.pi**2 * j * j)
        l, h = kl_interval(total / N, N, dj)
        lo, hi = max(lo, l), min(hi, h)  # intersection of valid intervals is valid
        if lo > 0 and hi <= (1 + eps) * lo:
            break
        if N >= max_samples:
            break
        k = N  # double
    mean = total / max(N, 1)
    point = min(max(mean, lo), hi)
    return Estimate(point, lo, hi, N, N * cost_per_sample, delta)


def dklr_stopping_rule(draw1: Callable[[], float], eps: float, delta: float,
                       max_samples: int = 10**8) -> tuple[float, int]:
    """Dagum-Karp-Luby-Ross Stopping Rule Algorithm for a [0,1] mean.

    Returns (estimate, samples); Pr[|est/mu - 1| > eps] <= delta for eps < 1.
    """
    lam = math.e - 2
    ups = 4 * lam * math.log(2 / delta) / eps**2
    ups1 = 1 + (1 + eps) * ups
    s, N = 0.0, 0
    while s < ups1 and N < max_samples:
        s += draw1()
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
