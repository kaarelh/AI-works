"""Sound lower bounds on the failure probability of an MLP (nets.py).

Setting: f is an MLP from nets.py, D is uniform on {-1,+1}^d, and the rare
event is [F(x) < t*] (t* = net.threshold). F is the network evaluated in
EXACT real arithmetic with the stored float64 weights. Everything below is a
lower bound on

    p = Pr_D[F(x) < t*],

and in fact on Pr_D[F(x) < t* - E*/2], which is at most both p and the
probability of [f(x) < t*] for f evaluated in floating point in ANY admissible
way (the reference p_exact of experiments/nets is one such evaluation),
because every admissible evaluation is within E*/2 of F
(forward_error_bound). Admissible: every operation is a correctly rounded
binary64 addition, multiplication or fused multiply-add, with gradual
underflow, in any order.

Methods (all sound for every net of the architecture and every float64
weight, bias and threshold; efficiency is measured on trained nets):

1. Witness lists. Every evaluated x with f_fl(x) finite and below
   t_cert <= t* - E* is a certified failure; |distinct witnesses| / 2^d is an
   exact lower bound (no probability of error).

2. Fixed-level SMC (multilevel splitting). Levels t_1 > ... > t_K = t_cert,
   A_k = {F < t_k}. N particles from D; at level k keep the particles in A_k
   (c_k of them), resample N of them uniformly with replacement, and move
   each with Metropolis steps that flip a random set of coordinates (chosen
   independently of x, so the proposal is symmetric) and accept iff the new
   point is in A_k. The kernel leaves D | A_k exactly invariant, so
   Z = prod_k c_k / N is an unbiased estimator of D(A_K) <= p (Del Moral's
   Feynman-Kac unbiasedness; for N = 1 it is the annealed-importance-sampling
   identity), however badly the chain mixes. Levels, N, the number of moves
   and the flip sizes are fixed by a pilot run whose randomness is
   independent of the final batch. Z is computed as an exact rational and
   rounded down.

   Floating point: the code decides x in A_k by f_fl(x) < t_k, which can
   differ from the ideal decision F(x) < t_k only if |f_fl(x) - t_k| <= E*/2.
   A replicate in which some score is not finite or has |f_fl(x) - t_k| < E*
   is "flagged" and reports Z = 0. Coupling the run with the ideal run on the
   same random numbers, the runs agree until the first flag, so the reported
   Z is at most the ideal Z, whose mean is D(A_K) exactly. The final level
   t_cert is at least E* below t*, so an output exactly at the threshold
   (a tie, f_fl = F = t*) is not flagged.

3. A lower confidence bound from R i.i.d. nonnegative estimators Z_i with
   E Z_i <= p (no upper bound on Z needed), betting_lower: the e-value
   mixture
       E(p0) = (1/G) sum_g prod_i (1 - lam_g + lam_g Z_i / p0)
   has E[E(p)] <= 1, so by Markov Pr[E(p) >= 1/delta] <= delta; E is
   decreasing in p0, so the largest p0 with E(p0) >= 1/delta is a lower
   bound with probability >= 1 - delta. Each product is a nonnegative
   supermartingale in the number of replicates, so (Ville) replicates may be
   added until the bound is good enough, and the running maximum is still
   valid (sequential mode: lower_bound(..., target_ratio=...)).

4. Stratification: given a witness set S fixed before the final batch, the
   SMC can target the event A_K minus S, and |S|/2^d + (lower bound for the
   rest) is a lower bound.

The variants compared in the design round and found no better on the trained
nets (block-Gibbs moves, selection pooled over Metropolis trajectories, soft
tempered levels, self-certifying proposals, and the clipped-KL and
min-Markov rules for combining replicates) are in
experiments/nets_lower/ablation.py.

Randomness is numpy's generator, treated as ideal (as in the paper).
"""

from __future__ import annotations

import math
import sys
import time
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .nets import MLP
from .stats import kl_interval

# ------------------------------------------------- certified evaluation

_U = Fraction(1, 1 << 53)  # unit roundoff of binary64
_ETA = Fraction(1, 1 << 1075)  # absolute error of an operation whose result is subnormal
_FMAX = Fraction(sys.float_info.max)


def _gamma(n: int) -> Fraction:
    return n * _U / (1 - n * _U)


def _float_up(q: Fraction) -> float:
    """The least float64 >= q (math.inf if there is none)."""
    try:
        x = float(q)
    except OverflowError:
        return math.inf if q > 0 else -sys.float_info.max
    if Fraction(x) < q:
        x = math.nextafter(x, math.inf)
    return x


def _float_down(q: Fraction) -> float:
    """The greatest float64 <= q (-math.inf if there is none; 0.0, not -0.0)."""
    x = -_float_up(-q)
    return 0.0 if x == 0 else x


def forward_error_bound(net: MLP) -> float:
    """E* such that |f_fl(x) - F(x)| <= E*/2 for every x in {-1,+1}^d and every
    admissible floating-point evaluation f_fl of the net (any order of the
    sums, with or without fused multiply-add, with gradual underflow);
    math.inf if no such bound is established (a weight or bias that is not
    finite, or an intermediate value that might overflow).

    Model (Higham, with underflow): fl(a op b) = (a op b)(1 + e) + eta with
    |e| <= u = 2^-53 and |eta| <= 2^-1075 (eta = 0 for additions), as long as
    nothing overflows. A dot product b + w.h of length n, computed in any
    order, then satisfies
        |fl(b + w.h) - (b + w.h)| <= gamma_{n+1} (|b| + |w|.|h|) + (2n + 2) 2^-1075,
    and every partial sum is at most (1 + gamma_{n+1}) (|b| + |w|.|h|) +
    (2n + 2) 2^-1075 in absolute value. With H_l a bound on the computed and
    the exact values of layer l and e_l a bound on their difference:
        A = |W| H_{l-1} + |b|,  e_l = gamma_{n+1} A + (2n + 2) 2^-1075 + |W| e_{l-1},
        H_l = A + e_l,
    from H_0 = 1 (|x_i| = 1), e_0 = 0; ReLU is exact and 1-Lipschitz. If every
    H_l is at most the largest float, no operation of any admissible
    evaluation can overflow, so the model applies throughout. All of this is
    computed in exact rational arithmetic, and E* = 2 e_L is rounded up."""
    try:
        layers = [([[abs(Fraction(float(w))) for w in row] for row in np.asarray(W)],
                   [abs(Fraction(float(v))) for v in np.asarray(b).reshape(-1)])
                  for W, b in zip(net.Ws, net.bs)]
    except (ValueError, OverflowError):  # nan or inf among the parameters
        return math.inf
    H = [Fraction(1)] * net.d
    e = [Fraction(0)] * net.d
    for absW, absb in layers:
        n = len(H)
        if any(len(row) != n for row in absW) or len(absb) != len(absW):
            raise ValueError("forward_error_bound: inconsistent layer shapes")
        g, under = _gamma(n + 1), (2 * n + 2) * _ETA
        A = [sum(w * h for w, h in zip(row, H) if w) + bj for row, bj in zip(absW, absb)]
        e = [g * a + under + sum(w * x for w, x in zip(row, e) if w) for a, row in zip(A, absW)]
        H = [a + x for a, x in zip(A, e)]
        if max(H) > _FMAX:  # some evaluation might overflow: no bound
            return math.inf
    return _float_up(2 * e[0])


class Evaluator:
    """Counts evaluations; certifies failures; checks decisions for flags.

    E is forward_error_bound(net) and t_cert the greatest float64 <= t* - E,
    so that f_fl(x) < t_cert implies F(x) < t* - E/2 and f'_fl(x) < t* for
    every admissible evaluation f'_fl. If no bound is established (E = inf)
    or the threshold is not finite, t_cert = -inf and nothing is decided
    (`decided` is False)."""

    def __init__(self, net: MLP):
        self.net = net
        self.d = net.d
        self.thr = float(net.threshold)
        self.E = forward_error_bound(net)
        if math.isfinite(self.thr) and math.isfinite(self.E):
            self.t_cert = _float_down(Fraction(self.thr) - Fraction(self.E))
        else:
            self.t_cert = -math.inf
        self.evals = 0

    @property
    def decided(self) -> bool:
        return math.isfinite(self.t_cert)

    def score(self, X: np.ndarray) -> np.ndarray:
        self.evals += X.shape[0]
        with np.errstate(over="ignore", invalid="ignore", under="ignore"):
            return self.net.forward(X)

    def ambiguous(self, s: np.ndarray, t: float) -> bool:
        """True if some decision [s_i < t] might differ from the exact decision
        [F(x_i) < t]: s_i is not finite, or |s_i - t| < E (outside that band
        |s_i - F(x_i)| <= E/2 forces the same sign)."""
        with np.errstate(over="ignore", invalid="ignore"):
            return bool(not np.isfinite(s).all() or np.any(np.abs(s - t) < self.E))

    def certified(self, s: np.ndarray) -> np.ndarray:
        """Mask of the scores that certify a failure: finite and < t_cert."""
        with np.errstate(invalid="ignore"):
            return np.isfinite(s) & (s < self.t_cert)


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


def _dyadic_down(k: int, d: int) -> float:
    """k / 2^d rounded DOWN to a float64 (math.ldexp rounds to nearest, which
    rounds up in the subnormal range, d >= 1075)."""
    return _float_down(Fraction(k, 1 << d))


class Witnesses:
    """Distinct certified failing inputs (exact lower bound |S| / 2^d).

    `add` takes rows of X with their scores s = ev.score(X); rows that are
    not cube points are refused (pack would store them as cube points that
    were never evaluated)."""

    def __init__(self, ev: Evaluator):
        self.ev = ev
        self.codes: set = set()

    def add(self, X: np.ndarray, s: np.ndarray):
        X = np.asarray(X)
        if X.ndim != 2 or X.shape[1] != self.ev.d or not np.all((X == 1.0) | (X == -1.0)):
            raise ValueError("Witnesses.add: rows must be points of {-1,+1}^d")
        m = self.ev.certified(s)
        if m.any():
            self.codes.update(pack(X[m]))

    @property
    def count(self) -> int:
        return len(self.codes)

    def lower(self) -> float:
        return _dyadic_down(len(self.codes), self.ev.d)

    def recertify(self, ev: Evaluator) -> "Witnesses":
        """The codes re-evaluated with `ev` (one forward pass each): a list
        collected elsewhere, on another net or with a forged code, keeps only
        the points that `ev` itself certifies."""
        out = Witnesses(ev)
        codes = [c for c in self.codes if isinstance(c, bytes) and len(c) == (ev.d + 7) // 8]
        if codes and ev.decided:
            X = unpack(codes, ev.d)
            keep = ev.certified(ev.score(X))
            out.codes = {c for c, k in zip(codes, keep) if k}
        return out


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

    @property
    def cost(self) -> int:
        """Evaluations per replicate (if not flagged)."""
        return self.N * (1 + sum(self.moves[:len(self.levels) - 1]))


def metropolis(ev: Evaluator, X: np.ndarray, s: np.ndarray, t: float, steps: int, flips: int,
               rng, witnesses: Witnesses | None = None, flag: list | None = None) -> float:
    """`steps` Metropolis steps for the uniform law on {x: F(x) < t}: flip
    `flips` distinct uniformly random coordinates, accept iff the new point is
    in the set. Returns the acceptance rate. X, s updated in place. If `flag`
    is given, flag[0] is set when a decision is ambiguous (then the caller
    stops: nothing after the first flag is used)."""
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
            return acc_total / max(1, N * steps)
        if witnesses is not None:
            witnesses.add(Y, sy)
        acc = sy < t
        X[acc] = Y[acc]
        s[acc] = sy[acc]
        acc_total += int(acc.sum())
    return acc_total / max(1, N * steps)


@dataclass
class SMCResult:
    Z: float            # the estimate (0 if flagged or extinct), rounded down
    log10Z: float
    counts: list        # survivors at each level
    evals: int
    flagged: bool
    final_X: np.ndarray = None


def run_smc(ev: Evaluator, plan: Plan, rng, witnesses: Witnesses | None = None,
            keep_final: bool = False) -> SMCResult:
    """One replicate of fixed-level SMC; Z = prod_k c_k / N (exact, rounded
    down), or 0 if a decision was flagged."""
    N, d = plan.N, ev.d
    e0 = ev.evals
    X = random_cube(rng, N, d)
    s = ev.score(X)
    if witnesses is not None:
        witnesses.add(X, s)
    K = len(plan.levels)
    counts = []

    def stop(flagged: bool) -> SMCResult:
        return SMCResult(0.0, -math.inf, counts, ev.evals - e0, flagged)

    flag = [False]
    for k, t in enumerate(plan.levels):
        if ev.ambiguous(s, t):
            return stop(True)
        alive = s < t
        if k == K - 1 and plan.exclude:
            alive &= np.array([c not in plan.exclude for c in pack(X)], dtype=bool)
        c = int(alive.sum())
        counts.append(c)
        if c == 0:
            return stop(False)
        if k == K - 1:
            break
        idx = np.flatnonzero(alive)[rng.integers(0, c, size=N)]
        X, s = X[idx].copy(), s[idx].copy()
        metropolis(ev, X, s, t, plan.moves[k], plan.flips[k], rng, witnesses, flag)
        if flag[0]:
            return stop(True)
    num = math.prod(counts)
    Z = _float_down(Fraction(num, N ** K))
    res = SMCResult(Z, sum(math.log10(c / N) for c in counts), counts, ev.evals - e0, False)
    if keep_final:
        res.final_X = X[alive]
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
    """A level near the rho-quantile of the scores s, inside a gap wider than
    4 E* between consecutive sorted scores a < b (so that later runs rarely
    meet ambiguous decisions), and never below the certified level. The level
    is a + 0.382 (b - a), not the midpoint: on nets whose outputs lie on a
    lattice (integer weights) the midpoint of two observed outputs is often
    an unobserved output, which would flag replicates. Pilot only: any
    choice is sound, since the levels are fixed before the final batch."""
    ss = np.sort(s[np.isfinite(s)])
    if len(ss) == 0:
        return math.inf
    if ss[0] < ev.t_cert:
        q = ss[max(0, int(rho * len(ss)) - 1)]
        if q < ev.t_cert:
            return ev.t_cert
    gaps = np.flatnonzero(np.diff(ss) > 4 * ev.E) + 1  # ss[j] - ss[j-1] > 4E
    if len(gaps) == 0:
        return ev.t_cert if ss[0] < ev.t_cert else math.inf
    m = max(1, int(rho * len(ss)))
    j = gaps[np.argmin(np.abs(gaps - m))]
    t = ss[j - 1] + 0.381966 * (ss[j] - ss[j - 1])
    if not math.isfinite(t):  # the difference overflowed
        t = 0.5 * ss[j - 1] + 0.5 * ss[j]
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
               max_levels: int = 400, tune: bool = True, fixed_flips: int = 1,
               target_moves: float = 0.0, max_moves: int | None = None) -> PilotResult:
    """Adaptive multilevel splitting: each level is near the rho-quantile of
    the current particles' scores (never below the certified level). Its
    levels, flip sizes and step counts become a fixed Plan for the final
    batch; its own estimate is NOT used for the bound (it is biased by the
    adaptivity).

    The flip size is tuned per level (tune_flips) unless tune=False (then
    fixed_flips); if target_moves > 0 the number of steps at a level is
    ceil(target_moves / acceptance), between `moves` and `max_moves`."""
    t0 = time.time()
    e0 = ev.evals
    X = random_cube(rng, N, ev.d)
    s = ev.score(X)
    if witnesses is not None:
        witnesses.add(X, s)
    levels, flips, steps, accs = [], [], [], []
    logZ = 0.0
    prev = math.inf
    max_moves = max_moves or 20 * moves
    while len(levels) < max_levels:
        t = _split_level(s, rho, ev)
        if not t < prev:  # no progress possible (all particles at one value)
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
        r = tune_flips(ev, X, s, t, rng) if tune else fixed_flips
        m = moves
        if target_moves > 0:
            Xc, sc = X[:512].copy(), s[:512].copy()
            a = metropolis(ev, Xc, sc, t, 2, r, rng)
            m = int(min(max_moves, max(moves, math.ceil(target_moves / max(a, 1e-3)))))
        flips.append(r)
        steps.append(m)
        accs.append(metropolis(ev, X, s, t, m, r, rng, witnesses))
    if not levels or levels[-1] != ev.t_cert:
        levels.append(ev.t_cert)
    while len(flips) < len(levels) - 1:
        flips.append(1)
        steps.append(moves)
    plan = Plan(levels=levels, N=N, moves=steps, flips=flips)
    return PilotResult(plan, math.exp(logZ) if logZ > -math.inf else 0.0,
                       logZ / math.log(10), ev.evals - e0, accs, time.time() - t0)


# ------------------------------------------------- confidence bound (sound)

def betting_lower(Z, delta: float, lams=(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 1.0),
                  weights=None) -> float:
    """Largest p0 with sum_g c_g prod_i (1 - lam_g + lam_g Z_i/p0) >= 1/delta
    (c_g = weights, default uniform 1/G; checked with a safety margin for
    rounding); 0 if all Z_i are 0. Valid for independent nonnegative Z_i with
    E Z_i <= p, for weights fixed in advance."""
    lams = np.asarray(lams, dtype=float)
    if lams.ndim != 1 or lams.size == 0 or not np.isfinite(lams).all() or lams.min() < 0 or lams.max() > 1:
        # lam > 1 makes a factor 1 - lam + lam Z/p0 negative (no e-value);
        # lam < 0 makes its mean exceed 1 when p0 > p (no supermartingale)
        raise ValueError("betting_lower: every lambda must lie in [0, 1]")
    Z = np.asarray(Z, dtype=float)
    if Z.size == 0 or Z.max() <= 0:
        return 0.0
    if not np.isfinite(Z).all() or Z.min() < 0:
        raise ValueError("betting_lower: Z must be finite and nonnegative")
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
    v = math.exp(lo) * (1 - 1e-12)  # the margin covers the rounding of exp and of the product ...
    if v < sys.float_info.min:  # ... except in the subnormal range, where an ulp is not relative
        v = max(0.0, v - 2 * 2.0 ** -1074)
    return v


def mc_lower_samples(p: float, ratio: float, delta: float) -> float:
    """Monte Carlo samples N for which the one-sided (1 - delta) KL lower end,
    at empirical mean exactly p (which favours Monte Carlo), reaches
    ratio * p. For p < 1e-6 scaled from p = 1e-6 (N ~ c/p)."""
    if ratio <= 0:
        return 0.0
    if p < 1e-6:
        return mc_lower_samples(1e-6, ratio, delta) * 1e-6 / p

    def ok(N):
        # a hypothetical mean (exactly p), not a measured floating-point sum: no rounding error
        lo, _ = kl_interval(p, int(N), 2 * delta, rel_err=0.0)
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
    lower: float           # the reported bound: max(stratum + betting bound, witness bound)
    witness_lower: float   # exact witness bound (no error probability)
    smc_lower: float       # betting bound on the stratified remainder (or the whole event)
    Z: list                # the final replicates
    evals_pilot: int
    evals_final: int
    plan: Plan
    pilot_log10Z: float
    seconds: float
    seconds_pilot: float
    flagged: int
    notes: dict = field(default_factory=dict)

    @property
    def evals(self) -> int:
        return self.evals_pilot + self.evals_final


def lower_bound(net: MLP, delta: float = 0.05, N: int = 1000, rho: float = 0.2, moves: int = 10, R: int = 32,
                rng=None, pilot_N: int | None = None, stratify: bool = False,
                witnesses: Witnesses | None = None, verbose: bool = False, target_ratio: float | None = None,
                min_R: int = 8, **pilot_kw) -> LowerBound:
    """Pilot (adaptive levels, tuned flips), then R independent fixed-plan SMC
    replicates; returns a (1 - delta) lower bound on p.

    With target_ratio, replicates are added one at a time (at most R) until the
    betting bound reaches target_ratio times the mean of the replicates
    (anytime-valid; the reported bound is the running maximum).

    If stratify, the witnesses found by the pilot are excluded from the last
    level and added back exactly.

    Supplied `witnesses` are re-certified on `net` (one evaluation per
    code), so a list built for another net, or holding forged codes, can only
    lose points.

    If the net has no forward-error bound (non-finite parameters or
    threshold, or possible overflow), nothing is certified and the bound is 0.
    Every exact count k / 2^d is rounded down before it enters a float."""
    rng = np.random.default_rng() if rng is None else rng
    t0 = time.time()
    ev = Evaluator(net)
    if not ev.decided:
        return LowerBound(lower=0.0, witness_lower=0.0, smc_lower=0.0, Z=[], evals_pilot=0, evals_final=0,
                          plan=Plan([], N, [], []), pilot_log10Z=-math.inf, seconds=time.time() - t0,
                          seconds_pilot=0.0, flagged=0, notes=dict(undecided=True, stratum=0.0))
    e0 = ev.evals
    W = Witnesses(ev) if witnesses is None else witnesses.recertify(ev)
    evals_recert = ev.evals - e0  # counted with the pilot
    pil = pilot_plan(ev, pilot_N or N, rho, moves, rng, W, **pilot_kw)
    plan = pil.plan
    plan.N = N
    S_fixed = frozenset(W.codes) if stratify else frozenset()
    plan.exclude = S_fixed
    base_q = Fraction(len(S_fixed), 1 << ev.d)
    base = _float_down(base_q)
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
    L_smc = betting_lower(np.array(Zs), delta) if target_ratio is None else L_run
    # the witness bound uses witnesses found anywhere (it holds surely)
    wl = W.lower()
    return LowerBound(lower=max(_float_down(base_q + Fraction(L_smc)), wl), witness_lower=wl, smc_lower=L_smc, Z=list(Zs),
                      evals_pilot=pil.evals + evals_recert, evals_final=evals_final, plan=plan, pilot_log10Z=pil.log10Z,
                      seconds=time.time() - t0, seconds_pilot=pil.seconds, flagged=flagged,
                      notes=dict(stratum=base, n_witness_pilot=len(S_fixed), E=ev.E, t_cert=ev.t_cert))
