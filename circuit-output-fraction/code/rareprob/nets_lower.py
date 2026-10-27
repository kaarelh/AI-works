"""Sound lower bounds on the failure probability of an MLP (nets.py).

Setting: f is an MLP from nets.py, D is uniform on {-1,+1}^d, and the rare
event is [F(x) < t*] (t* = net.threshold). F is the network evaluated in
EXACT real arithmetic with the stored float64 weights. Everything below is a
lower bound on

    p = Pr_D[F(x) < t*],

and in fact on Pr_D[F(x) < t* - E*/2], which is at most both p and the
probability of [f(x) < t*] for f evaluated in float64 in ANY summation order
(the reference p_exact of experiments/nets is one such order), because every
float64 evaluation is within E*/2 of F (forward_error_bound).

Methods (all sound for every net of the architecture; efficiency is
measured on trained nets):

1. Witness lists. Every evaluated x with f_fl(x) < t* - E* is a certified
   failure; |distinct witnesses| / 2^d is an exact lower bound (no
   probability of error).

2. Fixed-level SMC (multilevel splitting). Levels t_1 > ... > t_K = t* - E*,
   A_k = {F < t_k}. N particles from D; at level k keep the particles in A_k
   (fraction a_k), resample N of them uniformly with replacement, and move
   each with Metropolis steps that flip a random set of coordinates (chosen
   independently of x, so the proposal is symmetric) and accept iff the new
   point is in A_k. The kernel leaves D | A_k exactly invariant, so
   Z = prod_k a_k is an unbiased estimator of D(A_K) <= p (Del Moral's
   Feynman-Kac unbiasedness; for N = 1 it is the annealed-importance-sampling
   identity), however badly the chain mixes. Levels, N, the number of moves
   and the flip sizes are fixed by a pilot run whose randomness is
   independent of the final batch.

   Floating point: the code decides x in A_k by f_fl(x) < t_k, which may
   differ from the ideal decision F(x) < t_k only if |f_fl(x) - t_k| <= E*/2.
   A replicate in which some decision had |f_fl(x) - t_k| <= E* is
   "flagged" and reports Z = 0. Coupling the run with the ideal run on the
   same random numbers, the runs agree until the first flag, so the reported
   Z is at most the ideal Z, whose mean is D(A_K) exactly.

3. Lower confidence bounds from R i.i.d. nonnegative estimators Z_i with
   E Z_i <= p (no upper bound on Z needed):
   * betting_lower (default): the e-value mixture
       E(p0) = (1/G) sum_g prod_i (1 - lam_g + lam_g Z_i / p0)
     has E[E(p)] <= 1, so by Markov Pr[E(p) >= 1/delta] <= delta; E is
     decreasing in p0, so the largest p0 with E(p0) >= 1/delta is a lower
     bound with probability >= 1 - delta. With lam = 1 it is
     delta^(1/R) * geometric mean of the Z_i. Each product is a nonnegative
     supermartingale in the number of replicates, so (Ville) replicates may
     be added until the bound is good enough, and the running maximum is
     still valid (lower_bound(..., target_ratio=...)).
   * clipped_kl_lower: M * (KL lower end for the mean of min(Z, M)/M), M fixed
     before the batch (as in the paper's prop:proposal).
   * min_markov_lower: delta^(1/R) * min_i Z_i (Markov on each replicate).

4. Stratification: given a witness set S fixed before the final batch, the
   SMC can target the event A_K minus S, and |S|/2^d + (lower bound for the
   rest) is a lower bound.

5. Self-certifying proposals (prop:proposal of the paper): an autoregressive
   logistic law, or a mixture of product distributions around witnesses,
   with exactly computable pmf and exact (dyadic) sampler;
   W = 1[certified] D(x)/Q(x) (rounded down), batch means to betting_lower.

6. Variants kept for comparison (all exactly unbiased, all worse or no
   better on the trained nets): block-Gibbs moves, selection pooled over the
   Metropolis trajectories, and soft (tempered) levels 2^(-ceil(theta (F -
   t*)_+)) with exact dyadic acceptance and exact rejection resampling.

Randomness is numpy's generator, treated as ideal (as in the paper).
"""

from __future__ import annotations

import math
import time
from dataclasses import dataclass, field

import numpy as np

from .nets import MLP
from .stats import kl_interval, sum_rel_err

_U = 2.0 ** -53


def _gamma(n: int) -> float:
    return n * _U / (1 - n * _U)


def forward_error_bound(net: MLP) -> float:
    """E* such that |f_fl(x) - F(x)| <= E*/2 for every x in {-1,+1}^d and every
    float64 evaluation of the net (any summation order, with or without FMA).

    Higham's bound |fl(b + w.h) - (b + w.h)| <= gamma_{n+1} (|b| + |w|.|h|)
    holds for every order of a dot product of length n; with H_l a bound on
    the computed and the exact hidden values of layer l and e_l a bound on
    their difference:
        A = |W| H_{l-1} + |b|,  e_l = gamma_{n+1} A + |W| e_{l-1},
        H_l = A + e_l,
    starting from H_0 = 1 (|x_i| = 1, products x_i w exact), e_0 = 0. ReLU is
    exact and 1-Lipschitz. The result is doubled (and inflated by 1e-6 for
    the rounding of this computation itself) to give E*."""
    H = np.ones(net.d)
    e = np.zeros(net.d)
    for W, b in zip(net.Ws, net.bs):
        n = W.shape[1]
        absW = np.abs(W)
        A = absW @ H + np.abs(b)
        e = _gamma(n + 1) * A + absW @ e
        H = A + e
    return float(e[0]) * 2.0 * (1 + 1e-6) + 1e-300


class Evaluator:
    """Counts evaluations; certifies failures; checks decisions for flags."""

    def __init__(self, net: MLP):
        self.net = net
        self.d = net.d
        self.thr = float(net.threshold)
        # (at least 8 ulps of the threshold, so that t_cert below is exact enough)
        self.E = max(forward_error_bound(net), 8 * math.ulp(self.thr), 2.0 ** -1000)
        # certified final level: f_fl < t_cert implies F < thr - E/2 and
        # f'_fl < thr for every float evaluation f'_fl
        self.t_cert = self.thr - self.E
        # the subtraction is exact up to an ulp of thr, far below E/4 here
        assert self.thr - self.t_cert >= 0.75 * self.E and math.ulp(self.thr) < 0.25 * self.E
        self.evals = 0

    def score(self, X: np.ndarray) -> np.ndarray:
        self.evals += X.shape[0]
        return self.net.forward(X)

    def ambiguous(self, s: np.ndarray, t: float) -> bool:
        return bool(np.any(np.abs(s - t) <= self.E))


def random_cube(rng, n: int, d: int) -> np.ndarray:
    return np.where(rng.random((n, d)) < 0.5, -1.0, 1.0)


def pack(X: np.ndarray) -> list:
    """Hashable codes of rows of a +-1 matrix."""
    P = np.packbits(X > 0, axis=1)
    return [r.tobytes() for r in P]


def unpack(codes, d: int) -> np.ndarray:
    P = np.frombuffer(b"".join(codes), dtype=np.uint8).reshape(len(codes), -1)
    B = np.unpackbits(P, axis=1)[:, :d]
    return np.where(B > 0, 1.0, -1.0)


class Witnesses:
    """Distinct certified failing inputs (exact lower bound |S| / 2^d)."""

    def __init__(self, ev: Evaluator):
        self.ev = ev
        self.codes: set = set()

    def add(self, X: np.ndarray, s: np.ndarray):
        m = s < self.ev.t_cert
        if m.any():
            self.codes.update(pack(X[m]))

    @property
    def count(self) -> int:
        return len(self.codes)

    def lower(self) -> float:
        return math.ldexp(float(len(self.codes)), -self.ev.d)


# ---------------------------------------------------------------- SMC

@dataclass
class Plan:
    """A fixed SMC plan: levels t_1 > ... > t_K (t_K = the certified level),
    particles N, Metropolis steps moves[k] and flip sizes flips[k] after the
    selection at level k (k = 0..K-2; nothing moves after the last level)."""

    levels: list
    N: int
    moves: list
    flips: list
    exclude: frozenset = frozenset()  # codes removed from the last level
    kernel: str = "mh"  # "mh" (Metropolis, flips = number of flipped coordinates)
    #                     or "gibbs" (block Gibbs, flips = block size)
    pool: bool = False  # select from every state of the Metropolis trajectories

    @property
    def cost(self) -> int:
        """Evaluations per replicate."""
        K = len(self.levels) - 1
        if self.kernel == "gibbs":
            return self.N * (1 + sum(m * ((1 << r) - 1) for m, r in zip(self.moves[:K], self.flips[:K])))
        return self.N * (1 + sum(self.moves[:K]))


def move(ev, X, s, t, kernel: str, steps: int, r: int, rng, witnesses=None, flag=None, trace=None) -> float:
    if kernel == "gibbs":
        assert trace is None
        return block_gibbs(ev, X, s, t, steps, r, rng, witnesses, flag)
    return metropolis(ev, X, s, t, steps, r, rng, witnesses, flag, trace)


def metropolis(ev: Evaluator, X: np.ndarray, s: np.ndarray, t: float, steps: int, flips: int,
               rng, witnesses: Witnesses | None = None, flag: list | None = None, trace: list | None = None):
    """`steps` Metropolis steps for the uniform law on {x: F(x) < t}: flip
    `flips` distinct uniformly random coordinates, accept iff the new point is
    in the set. Returns the acceptance rate. X, s updated in place."""
    N, d = X.shape
    acc_total = 0
    rows = np.arange(N)[:, None]
    for _ in range(steps):
        if flips == 1:
            J = rng.integers(0, d, size=(N, 1))
        else:
            J = np.argpartition(rng.random((N, d)), flips - 1, axis=1)[:, :flips]
        Y = X.copy()
        Y[rows, J] *= -1.0
        sy = ev.score(Y)
        if flag is not None and ev.ambiguous(sy, t):
            flag[0] = True
        if witnesses is not None:
            witnesses.add(Y, sy)
        acc = sy < t
        X[acc] = Y[acc]
        s[acc] = sy[acc]
        acc_total += int(acc.sum())
        if trace is not None:
            trace.append((X.copy(), s.copy()))
    return acc_total / max(1, N * steps)


@dataclass
class SMCResult:
    Z: float            # the estimate (0 if flagged or extinct)
    log10Z: float
    counts: list        # survivors at each level
    evals: int
    flagged: bool
    final_X: np.ndarray = None


def run_smc(ev: Evaluator, plan: Plan, rng, witnesses: Witnesses | None = None,
            keep_final: bool = False) -> SMCResult:
    """One replicate of fixed-level SMC; Z = prod_k (selected / population).

    With plan.pool, the population at each selection is every state of the
    Metropolis trajectories since the last resampling (N (m + 1) states), and
    the N new particles are drawn uniformly from the selected ones. This is
    SMC with the averaged kernel (1/(m+1)) sum_j M^j, Rao-Blackwellised over
    the choice of j; the averaged kernel is invariant too, so Z stays
    unbiased (the Feynman-Kac recursion E[gamma_k(f) | past] =
    gamma_{k-1}(Kbar(G_k f)) holds with Kbar in place of M)."""
    N, d = plan.N, ev.d
    e0 = ev.evals
    X = random_cube(rng, N, d)
    s = ev.score(X)
    if witnesses is not None:
        witnesses.add(X, s)
    flag = [False]
    counts = []
    K = len(plan.levels)
    logZ = 0.0
    PX, Ps = X, s  # the population that the next selection sees
    for k, t in enumerate(plan.levels):
        if ev.ambiguous(Ps, t):
            flag[0] = True
        alive = Ps < t
        if k == K - 1 and plan.exclude:
            codes = pack(PX)
            alive &= np.array([c not in plan.exclude for c in codes], dtype=bool)
        c = int(alive.sum())
        counts.append(c)
        if c == 0:
            return SMCResult(0.0, -math.inf, counts, ev.evals - e0, flag[0])
        logZ += math.log(c / len(Ps))
        if k == K - 1:
            break
        idx = np.flatnonzero(alive)[rng.integers(0, c, size=N)]
        X, s = PX[idx].copy(), Ps[idx].copy()
        if plan.pool:
            trace = [(X.copy(), s.copy())]
            move(ev, X, s, t, plan.kernel, plan.moves[k], plan.flips[k], rng, witnesses, flag, trace)
            PX = np.concatenate([a for a, _ in trace])
            Ps = np.concatenate([b for _, b in trace])
        else:
            move(ev, X, s, t, plan.kernel, plan.moves[k], plan.flips[k], rng, witnesses, flag)
            PX, Ps = X, s
    # Z = prod c_k / n_k, computed in floating point with relative error below
    # 4 K u; we shrink it by (1 - 1e-10) so that it is below the exact product
    Z = 0.0 if flag[0] else math.exp(logZ) * (1 - 1e-10)
    res = SMCResult(Z, logZ / math.log(10) if not flag[0] else -math.inf, counts, ev.evals - e0, flag[0])
    if keep_final:
        res.final_X = PX[Ps < plan.levels[-1]]
    return res


def tune_flips(ev: Evaluator, X, s, t, rng, choices=(1, 2, 3, 4, 6, 8, 12, 16), trials: int = 2,
               min_acc: float = 0.15) -> int:
    """Largest flip size whose Metropolis acceptance on (a copy of) the
    particles is at least min_acc (1 if none). Pilot only."""
    best = 1
    m = min(len(X), 512)
    for r in choices:
        if r > ev.d // 2:
            break
        Xc, sc = X[:m].copy(), s[:m].copy()
        acc = metropolis(ev, Xc, sc, t, trials, r, rng)
        if acc >= min_acc:
            best = r
    return best


def _split_level(s: np.ndarray, rho: float, ev: Evaluator) -> float:
    """A level near the rho-quantile of the scores s, placed at the midpoint of
    a gap wider than 4 E* between consecutive sorted scores (so that later
    runs rarely meet ambiguous decisions), and never below the certified
    level. Pilot only."""
    ss = np.sort(s)
    if ss[0] < ev.t_cert:
        q = ss[max(0, int(rho * len(ss)) - 1)]
        if q < ev.t_cert:
            return ev.t_cert
    gaps = np.flatnonzero(np.diff(ss) > 4 * ev.E) + 1  # ss[j] - ss[j-1] > 4E
    if len(gaps) == 0:
        return ev.t_cert if ss[0] < ev.t_cert else math.inf
    m = max(1, int(rho * len(ss)))
    j = gaps[np.argmin(np.abs(gaps - m))]
    t = 0.5 * (ss[j - 1] + ss[j])
    return max(float(t), ev.t_cert)


@dataclass
class PilotResult:
    plan: Plan
    Z: float
    log10Z: float
    evals: int
    accept: list
    seconds: float


def pilot_plan(ev: Evaluator, N: int, rho: float, moves: int, rng, witnesses: Witnesses | None = None,
               max_levels: int = 400, kernel: str = "mh", tune: bool = True, fixed_flips: int = 1,
               target_moves: float = 0.0, max_moves: int | None = None) -> PilotResult:
    """Adaptive multilevel splitting: each level is near the rho-quantile of
    the current particles' scores (never below the certified level). Its
    levels, flip sizes and step counts become a fixed Plan for the final
    batch; its own estimate is NOT used for the bound (it is biased by the
    adaptivity).

    kernel "mh": the flip size is tuned per level (tune_flips) unless
    tune=False; if target_moves > 0 the number of steps at a level is
    ceil(target_moves / acceptance), between `moves` and `max_moves`.
    kernel "gibbs": block size fixed_flips, `moves` steps per level."""
    t0 = time.time()
    e0 = ev.evals
    d = ev.d
    X = random_cube(rng, N, d)
    s = ev.score(X)
    if witnesses is not None:
        witnesses.add(X, s)
    levels, flips, steps, accs = [], [], [], []
    logZ = 0.0
    prev = math.inf
    max_moves = max_moves or 20 * moves
    while len(levels) < max_levels:
        t = _split_level(s, rho, ev)
        if t >= prev:  # no progress possible (all particles at one value)
            break
        alive = s < t
        c = int(alive.sum())
        levels.append(t)
        if c == 0:
            logZ = -math.inf
            break
        logZ += math.log(c / N)
        if t == ev.t_cert:
            break
        prev = t
        idx = np.flatnonzero(alive)[rng.integers(0, c, size=N)]
        X, s = X[idx], s[idx]
        if kernel == "gibbs":
            r, m = fixed_flips, moves
        else:
            r = tune_flips(ev, X, s, t, rng) if tune else fixed_flips
            m = moves
            if target_moves > 0:
                Xc, sc = X[:512].copy(), s[:512].copy()
                a = metropolis(ev, Xc, sc, t, 2, r, rng)
                m = int(min(max_moves, max(moves, math.ceil(target_moves / max(a, 1e-3)))))
        flips.append(r)
        steps.append(m)
        accs.append(move(ev, X, s, t, kernel, m, r, rng, witnesses))
    if not levels or levels[-1] != ev.t_cert:
        levels.append(ev.t_cert)
    while len(flips) < len(levels) - 1:
        flips.append(1)
        steps.append(moves)
    plan = Plan(levels=levels, N=N, moves=steps, flips=flips, kernel=kernel)
    return PilotResult(plan, math.exp(logZ) if logZ > -math.inf else 0.0,
                       logZ / math.log(10), ev.evals - e0, accs, time.time() - t0)


# ------------------------------------------------- confidence bounds (sound)

def betting_lower(Z, delta: float, lams=(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 1.0),
                  weights=None) -> float:
    """Largest p0 with sum_g c_g prod_i (1 - lam_g + lam_g Z_i/p0) >= 1/delta
    (c_g = weights, default uniform 1/G; checked with a safety margin for
    rounding); 0 if all Z_i are 0. Valid for independent nonnegative Z_i with
    E Z_i <= p, for weights fixed in advance."""
    Z = np.asarray(Z, dtype=float)
    if Z.size == 0 or Z.max() <= 0:
        return 0.0
    if not np.isfinite(Z).all() or Z.min() < 0:
        raise ValueError("betting_lower: Z must be finite and nonnegative")
    lams = np.asarray(lams, dtype=float)
    target = math.log(1.0 / delta)
    c = np.full(len(lams), 1.0 / len(lams)) if weights is None else np.asarray(weights, dtype=float)
    if c.shape != lams.shape or c.min() < 0 or c.sum() > 1 + 1e-12:
        raise ValueError("betting_lower: weights must be nonnegative, one per lambda, summing to at most 1")
    logc = np.log(np.maximum(c, 1e-300))

    with np.errstate(divide="ignore"):
        logZ = np.log(Z)

    def rejected(lp0: float) -> bool:
        ratio = np.exp(np.minimum(logZ - lp0, 700.0))  # Z_i / p0 (0 for Z_i = 0)
        with np.errstate(divide="ignore"):
            T = np.log1p(lams[:, None] * (ratio[None, :] - 1.0))  # (G, R); -inf if lam = 1, Z = 0
        S = T.sum(axis=1) + logc
        if not np.isfinite(S).any():
            return False
        T = np.where(np.isfinite(T), T, 0.0)
        m = S.max()
        logE = m + math.log(np.exp(S - m).sum())
        margin = 1e-9 * (1.0 + np.abs(T).sum(axis=1).max())
        return logE - margin >= target

    hi = math.log(Z.max())  # E(p0) < 1 for p0 > max Z
    lo = hi - 25.0
    while not rejected(lo):
        lo -= 25.0
        if lo < hi - 650.0:
            return 0.0
    for _ in range(100):
        mid = (lo + hi) / 2
        if rejected(mid):
            lo = mid
        else:
            hi = mid
        if hi - lo < 1e-9:
            break
    return math.exp(lo) * (1 - 1e-12)


def clipped_kl_lower(Z, M: float, delta: float) -> float:
    """M times the one-sided (1 - delta) KL lower end for the mean of
    min(Z, M)/M (M fixed before the batch)."""
    Z = np.asarray(Z, dtype=float)
    Y = np.minimum(Z, M) / M
    rel = sum_rel_err(len(Y))
    lo, _ = kl_interval(float(Y.mean()), len(Y), 2 * delta, rel_err=rel)
    return M * lo * (1 - 1e-12)


def min_markov_lower(Z, delta: float) -> float:
    Z = np.asarray(Z, dtype=float)
    return float(delta ** (1.0 / len(Z)) * Z.min()) * (1 - 1e-12)


def mc_lower_samples(p: float, ratio: float, delta: float) -> float:
    """Monte Carlo samples N for which the one-sided (1 - delta) KL lower end,
    at empirical mean exactly p (which favours Monte Carlo), reaches
    ratio * p. For p < 1e-6 scaled from p = 1e-6 (N ~ c/p)."""
    if ratio <= 0:
        return 0.0
    if p < 1e-6:
        return mc_lower_samples(1e-6, ratio, delta) * 1e-6 / p

    def ok(N):
        lo, _ = kl_interval(p, int(N), 2 * delta)
        return lo >= ratio * p

    b = 1.0
    while not ok(b):
        b *= 2
        if b > 1e18:
            return math.inf
    a = b / 2
    while b - a > max(1.0, 1e-3 * b):
        m = (a + b) / 2
        if ok(m):
            b = m
        else:
            a = m
    return b


def mc_two_sided_samples(p: float, eps: float, delta: float) -> float:
    """The task's yardstick: 3 ln(2/delta) / (eps^2 p)."""
    return 3 * math.log(2 / delta) / (eps ** 2 * p)


# ---------------------------------------------- the full lower-bound driver

@dataclass
class LowerBound:
    lower: float           # the reported bound (betting mixture + stratification)
    witness_lower: float   # exact witness bound (no error probability)
    smc_lower: float       # betting bound on the stratified remainder (or the whole event)
    clipped_lower: float   # alternatives on the same replicates (each valid alone)
    minmarkov_lower: float
    Z: list
    evals_pilot: int
    evals_final: int
    plan: Plan
    pilot_log10Z: float
    seconds: float
    flagged: int
    notes: dict = field(default_factory=dict)


def lower_bound(net: MLP, delta: float = 0.05, N: int = 1000, rho: float = 0.2, moves: int = 10, R: int = 32,
                rng=None, pilot_N: int | None = None, stratify: bool = False, clip_factor: float = 2.0,
                witnesses: Witnesses | None = None, verbose: bool = False, target_ratio: float | None = None,
                min_R: int = 8, **pilot_kw) -> LowerBound:
    """Pilot (adaptive levels, tuned flips), then R independent fixed-plan SMC
    replicates; returns a (1 - delta) lower bound on p.

    With target_ratio, replicates are added one at a time (at most R) until the
    betting bound reaches target_ratio times the mean of the replicates
    (anytime-valid; the reported bound is the running maximum).

    If stratify, the witnesses found by the pilot are excluded from the last
    level and added back exactly. The clipped-KL alternative uses
    M = clip_factor * (pilot estimate), fixed before the batch."""
    rng = np.random.default_rng() if rng is None else rng
    t0 = time.time()
    ev = Evaluator(net)
    W = Witnesses(ev) if witnesses is None else witnesses
    pil = pilot_plan(ev, pilot_N or N, rho, moves, rng, W, **pilot_kw)
    plan = pil.plan
    plan.N = N
    S_fixed = frozenset(W.codes) if stratify else frozenset()
    plan.exclude = S_fixed
    base = math.ldexp(float(len(S_fixed)), -ev.d)
    if verbose:
        print(f"  pilot: K={len(plan.levels)} log10Z={pil.log10Z:.3f} evals={pil.evals} "
              f"witnesses={len(S_fixed)} flips={plan.flips}", flush=True)
    e1 = ev.evals
    Zs, flagged = [], 0
    L_run = 0.0
    for i in range(R):
        r = run_smc(ev, plan, rng, W)
        Zs.append(r.Z)
        flagged += r.flagged
        if target_ratio is not None and i + 1 >= min_R:
            # anytime-valid: the e-value mixture is a nonnegative
            # supermartingale in the number of replicates for every p0, so by
            # Ville's inequality Pr[some L_i > p] <= delta, and we may stop
            # when we like and report the running maximum
            L_run = max(L_run, betting_lower(np.array(Zs), delta))
            if L_run >= target_ratio * float(np.mean(Zs)):
                break
    evals_final = ev.evals - e1
    Zs = np.array(Zs)
    L_smc = betting_lower(Zs, delta) if target_ratio is None else L_run
    M = clip_factor * max(pil.Z - base, 1e-300)
    if target_ratio is None:
        L_clip = clipped_kl_lower(Zs, M, delta)
        L_min = min_markov_lower(Zs, delta)
    else:  # these are not anytime-valid: not reported after data-dependent stopping
        L_clip = L_min = float("nan")
    lower = base + L_smc
    # the witness bound uses witnesses found anywhere (it holds surely)
    wl = W.lower()
    return LowerBound(lower=max(lower, wl), witness_lower=wl, smc_lower=L_smc, clipped_lower=base + L_clip,
                      minmarkov_lower=base + L_min, Z=list(Zs), evals_pilot=pil.evals,
                      evals_final=evals_final, plan=plan, pilot_log10Z=pil.log10Z,
                      seconds=time.time() - t0, flagged=flagged,
                      notes=dict(stratum=base, n_witness_pilot=len(S_fixed)))


def block_gibbs(ev: Evaluator, X: np.ndarray, s: np.ndarray, t: float, steps: int, r: int, rng,
                witnesses: Witnesses | None = None, flag: list | None = None) -> float:
    """`steps` block-Gibbs steps for the uniform law on {x: F(x) < t}: pick r
    distinct coordinates uniformly (independently of x) and resample them
    uniformly among the 2^r assignments that keep x in the set (the current
    one always does). Costs 2^r - 1 evaluations per particle and step.
    Returns the fraction of steps that changed x."""
    N, d = X.shape
    pats = np.where((np.arange(1 << r)[:, None] >> np.arange(r)) & 1, -1.0, 1.0)  # (2^r, r); row 0 = no flip
    moved = 0
    for _ in range(steps):
        J = np.argpartition(rng.random((N, d)), r - 1, axis=1)[:, :r]
        Y = np.repeat(X[:, None, :], 1 << r, axis=1)  # (N, 2^r, d)
        rows = np.arange(N)[:, None, None]
        cand = np.arange(1 << r)[None, :, None]
        Y[rows, cand, J[:, None, :]] *= pats[None, :, :]
        Yf = Y[:, 1:, :].reshape(-1, d)
        sy = ev.score(Yf)
        if flag is not None and ev.ambiguous(sy, t):
            flag[0] = True
        if witnesses is not None:
            witnesses.add(Yf, sy)
        sy = sy.reshape(N, (1 << r) - 1)
        ok = np.concatenate([np.ones((N, 1), bool), sy < t], axis=1)
        # uniform choice among the allowed assignments (exact: an integer
        # uniform in [0, #allowed) selects the allowed one of that rank)
        cnt = ok.sum(axis=1)
        k = rng.integers(0, cnt)
        pick = np.argmax(np.cumsum(ok, axis=1) > k[:, None], axis=1)
        ch = pick > 0
        X[ch] = Y[np.flatnonzero(ch), pick[ch]]
        s[ch] = sy[np.flatnonzero(ch), pick[ch] - 1]
        moved += int(ch.sum())
    return moved / max(1, N * steps)


# ------------------------------------------- self-certifying proposals (prop:proposal)

_QBITS = 32
_QDEN = float(1 << _QBITS)


def _dyadic(q: np.ndarray) -> np.ndarray:
    """Integer numerators k in [1, 2^32 - 1] of the dyadic probabilities
    k / 2^32 nearest to q; sampling with them is exact (integer draws)."""
    return np.clip(np.rint(np.asarray(q, dtype=float) * _QDEN), 1, _QDEN - 1).astype(np.int64)


class ARLogistic:
    """Autoregressive logistic proposal on {-1,+1}^d:
    Pr[x_i = +1 | x_<i] = k_i(x_<i) / 2^32, k_i the dyadic rounding of
    sigmoid(a_i + B_i . x_<i). The sampler and the pmf are computed in the same
    pass from the same integers k_i, so they agree by construction."""

    def __init__(self, d: int):
        self.d = d
        self.a = np.zeros(d)
        self.B = np.zeros((d, d))  # strictly lower triangular

    def fit(self, X: np.ndarray, l2: float = 1.0, iters: int = 30, weights=None):
        """Per-coordinate L2-regularised logistic regression of x_i on x_<i
        (Newton's method). X: (n, d) samples, e.g. SMC particles."""
        n, d = X.shape
        w = np.ones(n) if weights is None else np.asarray(weights, float)
        y = (X > 0).astype(float)
        for i in range(d):
            F = np.concatenate([np.ones((n, 1)), X[:, :i]], axis=1)
            beta = np.zeros(i + 1)
            reg = l2 * np.eye(i + 1)
            reg[0, 0] = 1e-6
            for _ in range(iters):
                m = 1 / (1 + np.exp(-F @ beta))
                g = F.T @ (w * (m - y[:, i])) + reg @ beta
                Hs = (F * (w * m * (1 - m))[:, None]).T @ F + reg
                step = np.linalg.solve(Hs, g)
                beta -= step
                if np.abs(step).max() < 1e-8:
                    break
            self.a[i] = beta[0]
            self.B[i, :i] = beta[1:]
        return self

    def sample(self, n: int, rng):
        """Returns X (n, d) and log Q(X) (float, see proposal_weights)."""
        d = self.d
        X = np.zeros((n, d))
        logQ = np.zeros(n)
        for i in range(d):
            z = self.a[i] + X[:, :i] @ self.B[i, :i]
            k = _dyadic(1 / (1 + np.exp(-z)))
            u = rng.integers(0, 1 << _QBITS, size=n)
            plus = u < k
            X[:, i] = np.where(plus, 1.0, -1.0)
            logQ += np.log(np.where(plus, k, (1 << _QBITS) - k) / _QDEN)
        return X, logQ


class KernelMixture:
    """Q(x) = (1/m) sum_j eta^H(x, c_j) (1 - eta)^(d - H(x, c_j)), eta = k/2^32:
    pick a centre uniformly, flip each coordinate with probability eta."""

    def __init__(self, centers: np.ndarray, eta: float):
        self.C = np.asarray(centers, dtype=float)
        self.k = int(_dyadic(eta))
        self.eta = self.k / _QDEN

    def logpmf(self, X: np.ndarray) -> np.ndarray:
        d = X.shape[1]
        H = (d - X @ self.C.T) / 2  # Hamming distances (exact small integers)
        L = H * math.log(self.eta) + (d - H) * math.log1p(-self.eta)
        m = L.max(axis=1, keepdims=True)
        return (m + np.log(np.exp(L - m).sum(axis=1, keepdims=True)))[:, 0] - math.log(len(self.C))

    def sample(self, n: int, rng):
        j = rng.integers(0, len(self.C), size=n)
        flip = rng.integers(0, 1 << _QBITS, size=(n, self.C.shape[1])) < self.k
        X = np.where(flip, -self.C[j], self.C[j])
        return X, self.logpmf(X)


def proposal_weights(ev: Evaluator, X: np.ndarray, logQ: np.ndarray, witnesses: Witnesses | None = None,
                     flag_free: bool = True) -> np.ndarray:
    """W = 1[x certified] * D(x)/Q(x), rounded DOWN: the computed log Q is a
    sum of at most d + m logs, each within a few ulps, so its absolute error is
    far below 1e-9 (1 + |log Q|); we subtract that margin. Certification is
    f_fl(x) < t_cert, valid for every float evaluation (no determinism needed:
    a certified x is a failure whatever the evaluation order)."""
    s = ev.score(X)
    if witnesses is not None:
        witnesses.add(X, s)
    logW = -ev.d * math.log(2.0) - logQ
    margin = 1e-9 * (1.0 + np.abs(logQ) + ev.d)
    W = np.exp(np.minimum(logW - margin, 700.0))
    return np.where(s < ev.t_cert, W, 0.0)


def proposal_lower(ev: Evaluator, Q, n: int, R: int, rng, delta: float = 0.05, witnesses=None,
                   chunk: int = 1 << 15):
    """(1 - delta) lower bound from n samples of a self-certifying proposal Q
    (fixed before the call): the n weights are split into R batches, and the
    batch means (i.i.d., nonnegative, mean <= p) go to betting_lower.
    Returns (bound, batch means, all-sample mean)."""
    per = n // R
    means = []
    tot = 0.0
    for _ in range(R):
        acc, left = 0.0, per
        while left > 0:
            k = min(chunk, left)
            X, lq = Q.sample(k, rng)
            acc += float(proposal_weights(ev, X, lq, witnesses).sum())
            left -= k
        means.append(acc / per * (1 - 1e-12))  # the float sum of nonnegative terms, shrunk
        tot += acc
    means = np.array(means)
    return betting_lower(means, delta), means, tot / (per * R)


# ----------------------------------------------- soft levels (tempered SMC)
#
# gamma_k(x) = 2^(-n_k(x)), n_k(x) = ceil(theta_k (F(x) - thr)_+), an integer,
# for 0 = theta_0 < theta_1 < ... < theta_{K-1}; the last step is the hard cut
# [F < t_cert] (where n_{K-1} = 0). Incremental weights 2^(n_{k-1} - n_k) are
# exact powers of two; the Metropolis acceptance 2^-(n_k(y) - n_k(x)) is
# realised exactly with integer coin flips; resampling proportional to the
# weights is exact by rejection (accept i with probability w_i / w_max, a
# power of two). A weight that underflows to 0 only lowers the potential, which
# lowers the mean of Z (still <= p). A decision is flagged (Z = 0) when
# theta_k (f_fl - thr) is within theta_k E of an integer or f_fl within E of
# thr, so that the run coincides with the ideal (exact-arithmetic) run.

def _n_level(ev: Evaluator, s: np.ndarray, theta: float, flag: list | None):
    r = theta * (s - ev.thr)
    if flag is not None:
        near = (np.abs(r - np.rint(r)) <= theta * ev.E * (1 + 1e-9) + 1e-12) | (np.abs(s - ev.thr) <= ev.E)
        if np.any(near & (s > ev.thr - ev.E)):
            flag[0] = True
    return np.where(s > ev.thr, np.ceil(r), 0.0).astype(np.int64)


def bern_pow2(m: np.ndarray, rng) -> np.ndarray:
    """Independent Bernoulli(2^-m_i) for integers m_i >= 0, exactly."""
    m = np.asarray(m, dtype=np.int64)
    out = np.ones(m.shape, dtype=bool)
    rem = m.copy()
    while True:
        act = np.flatnonzero(out & (rem > 0))
        if act.size == 0:
            return out
        c = np.minimum(rem[act], 62)
        u = rng.integers(0, 1 << 62, size=act.size, dtype=np.int64)
        ok = (u >> (62 - c)) == 0
        out[act[~ok]] = False
        rem[act] -= c


def resample_pow2(k: np.ndarray, N: int, rng) -> np.ndarray:
    """N indices drawn i.i.d. with probability proportional to 2^-k_i, exactly
    (uniform proposal, accepted with probability 2^-(k_i - min k))."""
    k = np.asarray(k, dtype=np.int64)
    k = k - k.min()
    out = np.empty(0, dtype=np.int64)
    while out.size < N:
        i = rng.integers(0, k.size, size=2 * (N - out.size))
        out = np.concatenate([out, i[bern_pow2(k[i], rng)]])
    return out[:N]


def soft_metropolis(ev, X, s, theta, steps, flips, rng, witnesses=None, flag=None):
    N, d = X.shape
    rows = np.arange(N)[:, None]
    n = _n_level(ev, s, theta, None)
    acc_total = 0
    for _ in range(steps):
        J = rng.integers(0, d, size=(N, 1)) if flips == 1 else \
            np.argpartition(rng.random((N, d)), flips - 1, axis=1)[:, :flips]
        Y = X.copy()
        Y[rows, J] *= -1.0
        sy = ev.score(Y)
        if witnesses is not None:
            witnesses.add(Y, sy)
        ny = _n_level(ev, sy, theta, flag)
        acc = bern_pow2(np.maximum(ny - n, 0), rng)
        X[acc], s[acc], n[acc] = Y[acc], sy[acc], ny[acc]
        acc_total += int(acc.sum())
    return acc_total / max(1, N * steps)


@dataclass
class SoftPlan:
    thetas: list   # theta_1 < ... < theta_{K-1}
    N: int
    moves: list
    flips: list

    @property
    def cost(self) -> int:
        return self.N * (1 + sum(self.moves))


def run_soft_smc(ev: Evaluator, plan: SoftPlan, rng, witnesses=None) -> SMCResult:
    N, d = plan.N, ev.d
    e0 = ev.evals
    X = random_cube(rng, N, d)
    s = ev.score(X)
    if witnesses is not None:
        witnesses.add(X, s)
    flag = [False]
    logZ = 0.0
    counts = []
    n_prev = np.zeros(N, dtype=np.int64)
    for k, th in enumerate(plan.thetas):
        n = _n_level(ev, s, th, flag)
        inc = n - n_prev  # weight 2^-inc, inc >= 0
        w = np.ldexp(1.0, -np.minimum(inc, 1100))
        logZ += math.log(math.fsum(w) / N) if w.max() > 0 else -math.inf
        counts.append(float(w.mean()))
        if logZ == -math.inf:
            return SMCResult(0.0, -math.inf, counts, ev.evals - e0, flag[0])
        idx = resample_pow2(inc, N, rng)
        X, s = X[idx], s[idx]
        soft_metropolis(ev, X, s, th, plan.moves[k], plan.flips[k], rng, witnesses, flag)
        n_prev = _n_level(ev, s, th, None)
    if ev.ambiguous(s, ev.t_cert):
        flag[0] = True
    c = int((s < ev.t_cert).sum())
    counts.append(c / N)
    if c == 0:
        return SMCResult(0.0, -math.inf, counts, ev.evals - e0, flag[0])
    logZ += math.log(c / N)
    Z = 0.0 if flag[0] else math.exp(logZ) * (1 - 1e-9)
    return SMCResult(Z, logZ / math.log(10), counts, ev.evals - e0, flag[0])


def pilot_soft(ev: Evaluator, N: int, rho: float, moves: int, rng, flips: int = 1, max_levels: int = 200):
    """Adaptive temperatures: theta_k is chosen (bisection) so that the mean
    incremental weight is about rho; stops when a fraction >= rho of the
    particles is certified. Returns (SoftPlan, pilot log10 Z)."""
    X = random_cube(rng, N, ev.d)
    s = ev.score(X)
    thetas, logZ = [], 0.0
    th_prev = 0.0
    n_prev = np.zeros(N, dtype=np.int64)
    while len(thetas) < max_levels and np.mean(s < ev.t_cert) < rho:
        def meanw(th):
            return float(np.mean(np.ldexp(1.0, -np.minimum(_n_level(ev, s, th, None) - n_prev, 1100))))
        lo, hi = th_prev, max(2 * th_prev, 1.0)
        while meanw(hi) > rho and hi < 1e12:
            hi *= 2
        for _ in range(50):
            mid = (lo + hi) / 2
            if meanw(mid) > rho:
                lo = mid
            else:
                hi = mid
        th = hi
        # meanw is a step function of theta; move theta to the middle of its
        # step, away from the crossings theta (s_i - thr) in Z, so that later
        # runs rarely meet flagged (ambiguous) decisions
        c = s[s > ev.thr] - ev.thr
        if c.size:
            j = np.floor(th * c)
            th = 0.5 * (float(np.max(j / c)) + float(np.min((j + 1) / c)))
        n = _n_level(ev, s, th, None)
        inc = n - n_prev
        w = np.ldexp(1.0, -np.minimum(inc, 1100))
        logZ += math.log(w.mean())
        idx = resample_pow2(inc, N, rng)
        X, s = X[idx], s[idx]
        soft_metropolis(ev, X, s, th, moves, flips, rng)
        thetas.append(th)
        th_prev = th
        n_prev = _n_level(ev, s, th, None)
    logZ += math.log(max(np.mean(s < ev.t_cert), 1e-300))
    plan = SoftPlan(thetas=thetas, N=N, moves=[moves] * len(thetas), flips=[flips] * len(thetas))
    return plan, logZ / math.log(10)
