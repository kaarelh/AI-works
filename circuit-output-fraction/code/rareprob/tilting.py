"""Soft envelopes: exponential tilting for thresholds of independent blocks,
and proposal-based lower bounds.

Threshold of blocks. Let C(x) = [S(x) >= t] with S = sum_j w_j g_j(x_{B_j}),
nonnegative integer weights w_j, disjoint blocks B_j and D a product
distribution. S is an integer, so t is replaced by the integer ceil(t)
(exactly; a THR gate's stored threshold already is one), and every
comparison below is in integer arithmetic. For theta >= 0,

    phi_theta(x) = exp(theta * (S(x) - t))

dominates C (phi >= 1 exactly when S >= t), and E_D[phi] = e^{-theta t}
prod_j E[e^{theta w_j g_j}] is the Chernoff bound, an exact, deductively
valid upper bound on p. Sampling from D * phi / E[phi] is block-wise: g_j = 1
with probability proportional to Pr[g_j = 1] e^{theta w_j}. The weight
C/phi = [S >= t] e^{-theta (S - t)} lies in [0, 1] and depends on x only
through S, so p = E[phi] * E_Q[C/phi] with relative variance at most K - 1,
K = Chernoff / p.

The tilt is found by bisection on the tilted mean E_Q S, to within 1/(k+2)
of t (prop:tilting), with no fixed cap other than theta * max w <= 700,
which keeps every term finite and bounds the effect of underflowed block
masses (see tilted_estimate).
"""

from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np
from scipy.special import expit

from .circuit import Circuit, as_rational
from .dist import Product
from .envelope import _exp_down, _exp_up
from .stats import Estimate, kl_interval, sequential_mean, sum_rel_err

_U = 2.0 ** -53
_TINY_ABS = 2.0 ** -1074  # an ulp of 0
_THETA_W_CAP = 700.0       # theta * max_j w_j stays below this


def _int_weight(w) -> int:
    """A block weight as a nonnegative int (integer-valued floats and
    Fractions are accepted)."""
    v = as_rational(w)
    if v.denominator != 1 or v < 0:
        raise ValueError(f"tilting needs nonnegative integer block weights, got {w!r}")
    return int(v)


def int_threshold(t) -> int | float:
    """ceil(t) exactly (S is an integer, so [S >= t] = [S >= ceil(t)]); +-inf
    is returned as such. Raises ValueError for NaN."""
    try:
        return math.ceil(as_rational(t))
    except ValueError:
        f = float(t)
        if math.isinf(f):
            return f
        raise


@dataclass
class Block:
    vars: list
    circuit: Circuit  # over the full n inputs, output = block gate
    weight: int
    pts1: np.ndarray = None  # assignments to vars with g = 1
    pts0: np.ndarray = None
    w1: np.ndarray = None  # their D-probabilities (within the block)
    w0: np.ndarray = None

    def __post_init__(self):
        self.weight = _int_weight(self.weight)

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


def _logs(b: Block) -> tuple[float, float]:
    p0, p1 = b.p0, b.p1
    return (math.log(p0) if p0 > 0 else -math.inf), (math.log(p1) if p1 > 0 else -math.inf)


def _log_term(lp0: float, lp1: float, a: float) -> float:
    """log(e^lp0 + e^(lp1 + a)), without overflow."""
    if lp1 == -math.inf:
        return lp0
    if lp0 == -math.inf:
        return lp1 + a
    return float(np.logaddexp(lp0, lp1 + a))


def log_chernoff(blocks, t, theta: float) -> float:
    terms = [-theta * t]
    for b in blocks:
        lp0, lp1 = _logs(b)
        terms.append(_log_term(lp0, lp1, theta * b.weight))
    return math.fsum(terms)


def chernoff(blocks, t, theta: float) -> float:
    return math.exp(log_chernoff(blocks, t, theta))


def _tilted_probs(blocks, theta: float, logs=None) -> np.ndarray:
    """Pr_{Q_theta}[g_j = 1] for every block (logs: the blocks' (log P0,
    log P1), if already computed)."""
    logs = [_logs(b) for b in blocks] if logs is None else logs
    lp0 = np.array([l0 for l0, _ in logs])
    lp1 = np.array([l1 for _, l1 in logs])
    w = np.array([b.weight for b in blocks], dtype=float)
    with np.errstate(invalid="ignore"):
        out = expit(lp1 - lp0 + theta * w)
    out[lp1 == -math.inf] = 0.0
    out[(lp0 == -math.inf) & (lp1 > -math.inf)] = 1.0
    return out


def best_theta(blocks, t) -> float:
    """theta >= 0 with |E_{Q_theta} S - t| < 1/(k+2) when one exists below
    the cap theta * max w <= 699 (bisection, upper bracket by doubling), else
    the cap; 0 when E_D S is already within 1/(k+2) of t or above it.
    prop:tilting bounds K for any such theta (unit weights)."""
    w = np.array([b.weight for b in blocks], dtype=float)
    if not len(blocks) or w.max() == 0:
        return 0.0
    tol = 0.5 / (len(blocks) + 2)
    cap = (_THETA_W_CAP - 1.0) / float(w.max())
    logs = [_logs(b) for b in blocks]

    def mean(th):
        return float((w * _tilted_probs(blocks, th, logs)).sum())

    if mean(0.0) >= t - tol:
        return 0.0
    hi = min(1.0, cap)
    while mean(hi) < t - tol and hi < cap:
        hi = min(2 * hi, cap)
    if mean(hi) < t - tol:
        return hi
    lo = 0.0  # mean(lo) < t - tol <= mean(hi)
    for _ in range(200):
        mid = (lo + hi) / 2
        m = mean(mid)
        if abs(m - t) < tol:
            return mid
        if m < t:
            lo = mid
        else:
            hi = mid
    return hi


def tilted_estimate(blocks, t, D: Product, n: int, eps: float = 0.1, delta: float = 0.05,
                    theta: float | None = None, max_samples: int = 10**6, rng=None) -> Estimate:
    """Sound interval for p = Pr_D[sum_j w_j g_j >= t] (nonnegative integer
    weights, disjoint blocks) by exponential tilting; t is any real (or
    +-inf), compared exactly. Deterministic answers when t is above the
    largest or at most the least attainable S."""
    rng = np.random.default_rng() if rng is None else rng
    for b in blocks:
        if b.pts1 is None:
            b.tabulate(D)
    t = int_threshold(t)
    # attainable range of S as a function (structural, not via D)
    s_max = sum(b.weight for b in blocks if len(b.pts1))
    s_min = sum(b.weight for b in blocks if not len(b.pts0))
    if t > s_max:
        return Estimate(0.0, 0.0, 0.0, 0, 0, 0.0, "tilting: t above the largest attainable sum, p = 0")
    if t <= s_min:
        return Estimate(1.0, 1.0, 1.0, 0, 0, 0.0, "tilting: t at most the least attainable sum, p = 1")
    if s_max >= 2 ** 53:
        raise ValueError("tilting: block weights too large for exact float differences")
    th = best_theta(blocks, t) if theta is None else float(theta)
    wmax = max(b.weight for b in blocks)
    if not (math.isfinite(th) and th >= 0) or th * wmax > _THETA_W_CAP:
        return Estimate(0.0, 0.0, 1.0, 0, 0, delta, f"tilting: theta={th!r} outside [0, 700/max w]: no verdict")
    k = len(blocks)
    logs = [_logs(b) for b in blocks]
    terms = [_log_term(lp0, lp1, th * b.weight) for b, (lp0, lp1) in zip(blocks, logs)]
    logB = math.fsum([-th * t] + terms)  # log E[phi]: the Chernoff bound
    pt = _tilted_probs(blocks, th, logs)  # per-block tilted probability of g = 1
    wts = np.array([b.weight for b in blocks], dtype=np.int64)

    def draw(m):
        S = np.zeros(m, dtype=np.int64)
        for wj, pj in zip(wts, pt):
            S += wj * (rng.random(m) < pj)
        # C(x) depends on x only through S (blocks are disjoint), so we never
        # need to materialize x: W = C / phi = [S >= t] * exp(-theta (S - t)),
        # S - t an exact integer, so W <= 1 exactly where S >= t.
        return np.where(S >= t, np.exp(-th * np.maximum(S - t, 0).astype(float)), 0.0)

    est = sequential_mean(draw, 0.999 * eps, delta, max_samples=max_samples)
    # Outward rounding (u = 2^-53).
    # Block masses: each point probability is a product of kb factors (q or
    # 1 - q), so P0, P1 carry a relative error <= (2 kb + 2) u, plus an
    # absolute one <= (#points) kb 2^-1074 from underflow, which the tilt
    # multiplies by at most e^{theta w}; every Chernoff factor
    # P0 + P1 e^{theta w} is >= 1, so the latter is also a relative error.
    under = [2 * (len(b.w0) + len(b.w1)) * max(len(b.vars), 1) * _TINY_ABS * math.exp(th * b.weight)
             for b in blocks]
    mag = lambda x: abs(x) if math.isfinite(x) else 0.0  # noqa: E731
    # eta: |computed log B - log B|: the masses, the logs, theta*w, logaddexp,
    # theta*t and the (correctly rounded) fsum, each a few ulps of its size
    eta = 2.0 ** -51 * (sum(len(b.vars) + 8 + 3 * mag(lp0) + 3 * mag(lp1) + 2 * th * b.weight + 4 * abs(L)
                            for b, (lp0, lp1), L in zip(blocks, logs, terms))
                        + th * abs(t) + abs(logB) + 4) + sum(under)
    # tau: |E W (computed sampler and weights) - E_Q W| <= total variation
    # between the sampler and Q_theta (per block: the rounding of pt_j, an
    # ulp of the 53-bit uniforms, and underflow) + the rounding of W <= 1,
    # which is <= u (x + 3) e^{-x} <= 3u for W = e^{-x}
    tau = sum(2.0 ** -52 * (mag(lp0) + mag(lp1) + th * b.weight + 2 * len(b.vars) + 8) + u
              for b, (lp0, lp1), u in zip(blocks, logs, under)) + k * _U + 4 * _U
    lo = _exp_down(math.log(est.lo - tau) + logB - eta) if est.lo > tau else 0.0
    up = math.log(min(1.0, est.hi + tau)) + logB + eta
    hi = 1.0 if up >= 0 else min(1.0, _exp_up(up))
    lo = min(lo, hi)
    val = min(max(est.value * math.exp(min(logB, 700.0)), lo), hi)
    return Estimate(val, lo, hi, est.samples, est.evaluations, delta,
                    f"theta={th:.3g}, Chernoff bound {math.exp(min(logB, 700.0)):.4g}, "
                    f"K~{math.exp(min(logB, 700.0)) / max(val, 1e-300):.3g}")


def poisson_binomial_tail(ps, ws, t) -> float:
    """Pr[sum w_j Bernoulli(p_j) >= t] for nonnegative integer weights (t
    compared exactly: [S >= t] = [S >= ceil(t)] for integer S)."""
    ws = [_int_weight(w) for w in ws]
    tot = sum(ws)
    t = int_threshold(t)
    if t > tot:
        return 0.0
    if t <= 0:
        return 1.0
    dist = np.zeros(tot + 1)
    dist[0] = 1.0
    for p, w in zip(ps, ws):
        new = dist * (1 - p)
        new[w:] += dist[: tot + 1 - w] * p
        dist = new
    return float(dist[int(t):].sum())


def proposal_lower_bound(C: Circuit, D: Product, Q, M: float, eps: float = 0.1,
                         delta: float = 0.05, N: int = 10**5, rng=None) -> Estimate:
    """Sound lower bound on p from any product proposal Q (lower-bound arguments).

    Q is untrusted: only its marginals are read, copied and checked (finite,
    in [0, 1], one per input); anything else gives the trivial [0, 1]. The
    proposal actually sampled has marginals qt_i = ceil(q_i 2^53) / 2^53 (the
    law of [U < q_i] for a 53-bit uniform U), and the likelihood ratio uses
    qt, so E_Qt[C D / Qt] = p exactly. W = min(C D/Qt, M) / M lies in [0, 1]
    and E_Qt[W] <= p / M, so the lower end of a (1 - delta) interval for
    E_Qt[W], times M (deflated by the rounding of the ratio), is a valid
    lower bound on p, whatever Q and M are. It is tight when D(x)/Q(x) <= M
    on C and M is close to p (i.e. Q is close to D conditioned on C)."""
    rng = np.random.default_rng() if rng is None else rng
    trivial = Estimate(0.0, 0.0, 1.0, 0, 0, delta, "proposal lower bound: invalid proposal or M, no verdict")
    try:
        q = np.array(getattr(Q, "q"), dtype=float, copy=True).ravel()
        M = float(M)
    except (AttributeError, TypeError, ValueError):
        return trivial
    if q.shape != (C.n,) or not np.all(np.isfinite(q) & (q >= 0) & (q <= 1)) \
            or not (math.isfinite(M) and M > 0):
        return trivial
    qt = np.ceil(q * 2.0 ** 53) / 2.0 ** 53  # exact
    X = rng.random((N, C.n)) < qt
    c = C.eval_bits(X)
    with np.errstate(divide="ignore"):
        lD = np.where(X, np.log(D.q), np.log1p(-D.q))
        lQ = np.where(X, np.log(qt), np.log1p(-qt))
    lD, lQ = lD.sum(axis=1), lQ.sum(axis=1)  # lQ is finite: X has Qt-probability > 0
    lr = np.exp(np.minimum(lD - lQ, 745.0))
    W = np.minimum(np.where(c, lr, 0.0), M) / M
    # relative error of the computed ratio: the n logs and their sums (a few
    # ulps of sum |log|), the subtraction, exp and the division
    mags = np.where(c & np.isfinite(lD), np.abs(lD) + np.abs(lQ), 0.0)  # D(x) = 0: W = 0 exactly
    rel = math.expm1(2.0 ** -50 * (C.n + 4) * (float(mags.max(initial=0.0)) + 4))
    mean = float(W.mean())
    lo, _ = kl_interval(mean, N, delta, rel_err=sum_rel_err(N))  # rel_err: the float mean of N values
    lo_p = max(0.0, math.nextafter(lo * M / (1 + rel) * (1 - 2.0 ** -50), 0.0))
    return Estimate(min(max(mean * M, lo_p), 1.0), min(lo_p, 1.0), 1.0, N, N, delta, "lower bound only")
