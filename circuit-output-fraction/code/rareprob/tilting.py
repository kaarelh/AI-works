"""Soft envelopes: exponential tilting for thresholds of independent blocks,
and proposal-based lower bounds.

Threshold of blocks. Let C(x) = [sum_j w_j g_j(x_{B_j}) >= t] where the
blocks B_j are disjoint and D is a product distribution. For theta >= 0,

    phi_theta(x) = exp(theta * (S(x) - t)),  S = sum_j w_j g_j,

dominates C (phi >= 1 when S >= t), and E_D[phi] = e^{-theta t} prod_j
E[e^{theta w_j g_j}] is the Chernoff bound, an exact, deductively valid
upper bound on p. Sampling from D * phi / E[phi] is block-wise: pick g_j = b
with probability proportional to Pr[g_j = b] e^{theta w_j b}, then draw
x_{B_j} from D conditioned on g_j = b (here by exact enumeration of the
block, which is small). The weight C/phi lies in [0, 1], so p = E[phi] *
E_Q[C/phi] with relative variance at most K - 1, K = Chernoff / p.
"""

from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np
from scipy.optimize import minimize_scalar

from .circuit import Circuit
from .dist import Product
from .envelope import _exp_down, _exp_up
from .stats import Estimate, kl_interval, sequential_mean


@dataclass
class Block:
    vars: list
    circuit: Circuit  # over the full n inputs, output = block gate
    weight: float
    pts1: np.ndarray = None  # assignments to vars with g = 1
    pts0: np.ndarray = None
    w1: np.ndarray = None  # their D-probabilities (within the block)
    w0: np.ndarray = None

    def tabulate(self, D: Product):
        k = len(self.vars)
        X = ((np.arange(1 << k)[:, None] >> np.arange(k)) & 1).astype(bool)
        full = np.zeros((1 << k, self.circuit.n), dtype=bool)
        full[:, self.vars] = X
        g = self.circuit.eval_bits(full)
        q = D.q[self.vars]
        w = np.prod(np.where(X, q, 1 - q), axis=1)
        self.pts1, self.w1 = X[g], w[g]
        self.pts0, self.w0 = X[~g], w[~g]

    @property
    def p1(self) -> float:
        return float(math.fsum(self.w1))

    @property
    def p0(self) -> float:
        """Pr[g = 0], summed directly (1 - p1 loses relative precision near p1 = 1)."""
        return float(math.fsum(self.w0))


def log_chernoff(blocks, t: float, theta: float) -> float:
    terms = [-theta * t]
    for b in blocks:
        terms.append(math.log(b.p0 + b.p1 * math.exp(theta * b.weight)))
    return math.fsum(terms)


def chernoff(blocks, t: float, theta: float) -> float:
    return math.exp(log_chernoff(blocks, t, theta))


def best_theta(blocks, t: float) -> float:
    def f(th):
        lm = -th * t
        for b in blocks:
            lm += math.log((1 - b.p1) + b.p1 * math.exp(th * b.weight))
        return lm

    r = minimize_scalar(f, bounds=(0.0, 50.0), method="bounded")
    return float(r.x)


def tilted_estimate(blocks, t: float, D: Product, n: int, eps: float = 0.1, delta: float = 0.05,
                    theta: float | None = None, max_samples: int = 10**6, rng=None) -> Estimate:
    rng = np.random.default_rng() if rng is None else rng
    for b in blocks:
        if b.pts1 is None:
            b.tabulate(D)
    th = best_theta(blocks, t) if theta is None else theta
    logB = log_chernoff(blocks, t, th)  # log E[phi]: the Chernoff bound
    # per-block tilted probability of g = 1
    pt = [b.p1 * math.exp(th * b.weight) / (b.p0 + b.p1 * math.exp(th * b.weight)) for b in blocks]

    def draw(k):
        S = np.zeros(k)
        for b, pj in zip(blocks, pt):
            g = rng.random(k) < pj
            S += b.weight * g
        # C(x) depends on x only through S (blocks are disjoint), so we never
        # need to materialize x: W = C / phi = [S >= t] * exp(-theta (S - t)).
        return np.where(S >= t - 1e-12, np.exp(-th * (S - t)), 0.0)

    est = sequential_mean(draw, 0.999 * eps, delta, max_samples=max_samples)
    # Outward rounding. eta bounds the relative floating-point error of the
    # block masses, of log B and of the sampler's law (a product over blocks of
    # per-block probabilities, each off by a few ulps); tau is the absolute
    # error in E[W] from the 53-bit uniform draws (one per block per sample).
    k = len(blocks)
    eta = 2.0 ** -48 * (sum(len(b.w0) + len(b.w1) for b in blocks) + 4 * k + 4) \
        + 2.0 ** -50 * (abs(logB) + 1) * (k + 2)
    tau = (k + 8) * 2.0 ** -52
    lo = _exp_down(math.log(est.lo - tau) + logB - eta) if est.lo > tau else 0.0
    hi = _exp_up(math.log(min(1.0, est.hi + tau)) + logB + eta)
    val = min(max(est.value * math.exp(logB), lo), hi)
    return Estimate(val, lo, hi, est.samples, est.evaluations, delta,
                    f"theta={th:.3g}, Chernoff bound {math.exp(logB):.4g}, K~{math.exp(logB) / max(val, 1e-300):.3g}")


def poisson_binomial_tail(ps, ws, t) -> float:
    """Exact Pr[sum w_j Bernoulli(p_j) >= t] for nonnegative integer weights."""
    tot = int(sum(ws))
    dist = np.zeros(tot + 1)
    dist[0] = 1.0
    for p, w in zip(ps, ws):
        w = int(w)
        new = dist * (1 - p)
        new[w:] += dist[: tot + 1 - w] * p
        dist = new
    return float(dist[int(math.ceil(t - 1e-12)):].sum())


def proposal_lower_bound(C: Circuit, D: Product, Q: Product, M: float, eps: float = 0.1,
                         delta: float = 0.05, N: int = 10**5, rng=None) -> Estimate:
    """Sound lower bound on p from ANY product proposal Q (lower-bound arguments).

    W = min(C(X) D(X)/Q(X), M) / M lies in [0, 1] and E_Q[W] <= p / M, so the
    lower end of a (1 - delta) interval for E_Q[W], times M, is a valid lower
    bound on p, whatever Q and M are. It is tight when D(x)/Q(x) <= M on C
    and M is close to p (i.e. Q is close to D conditioned on C).
    """
    rng = np.random.default_rng() if rng is None else rng
    X = Q.sample(N, rng)
    c = C.eval_bits(X)
    lr = np.exp(D.logpmf(X) - Q.logpmf(X))
    W = np.minimum(np.where(c, lr, 0.0), M) / M
    lo, hi = kl_interval(float(W.mean()), N, delta)
    return Estimate(float(W.mean()) * M, lo * M, math.inf, N, N, delta, "lower bound only")
