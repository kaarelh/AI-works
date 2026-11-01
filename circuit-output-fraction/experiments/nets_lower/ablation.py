"""Ablation: the variants of the SMC lower bound that were compared in the
design round and are not part of the method (rareprob.nets_lower), with the
experiments that compare them with it.

Variants (each sound for every net: exactly unbiased for D(A_K) <= p, or a
valid confidence bound; they reuse the library's certified evaluation, so
the floating-point argument of nets_lower applies unchanged):

  * kernels: block-Gibbs moves (resample a random block of r coordinates
    uniformly among the 2^r assignments that stay in the level set, 2^r - 1
    evaluations per step), and selection pooled over the Metropolis
    trajectories (SMC with the averaged kernel (1/(m+1)) sum_j M^j, which is
    invariant too, Rao-Blackwellised over j);
  * soft (tempered) levels 2^(-ceil(theta (F - t*)_+)) with exact dyadic
    Metropolis acceptance and exact rejection resampling, then a hard cut at
    the certified level;
  * self-certifying proposals (prop:proposal of the paper): an
    autoregressive logistic law, or a mixture of product kernels around
    witnesses, with exactly computable pmf and exact dyadic sampler,
    W = 1[certified] D(x)/Q(x) rounded down, batch means to betting_lower;
  * combining rules: clipped KL (M fixed before the batch) and min-Markov
    (delta^(1/R) min_i Z_i), on the same replicates as the betting bound.

usage: python3 ablation.py [--jobs J] combine | unbiased | kernels | soft | proposals | all
       (writes results/ablation_<part>.jsonl)
"""

import json
import math
import os
import sys
import time
from fractions import Fraction

from common import DELTA, RES, append_row, get_net, jobs_arg, load_rows, run_parallel, seed_of
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets import all_inputs, exact_failure_count, train_constant
from rareprob.nets_lower import (Evaluator, Plan, SMCResult, _float_down, betting_lower, metropolis, pack,
                                 pilot_plan, random_cube, run_smc, unpack)
from rareprob.stats import kl_interval, sum_rel_err


# ------------------------------------------------------------ combining rules

def clipped_kl_lower(Z, M: float, delta: float) -> float:
    """M times the one-sided (1 - delta) KL lower end for the mean of
    min(Z, M)/M (M fixed before the batch)."""
    Z = np.asarray(Z, dtype=float)
    Y = np.minimum(Z, M) / M
    lo, _ = kl_interval(float(Y.mean()), len(Y), 2 * delta, rel_err=sum_rel_err(len(Y)))
    return M * lo * (1 - 1e-12)


def min_markov_lower(Z, delta: float) -> float:
    """delta^(1/R) min_i Z_i: Pr[Z_i > p / a] <= a for each replicate (Markov)."""
    Z = np.asarray(Z, dtype=float)
    return float(delta ** (1.0 / len(Z)) * Z.min()) * (1 - 1e-12)


# ------------------------------------------------------------ kernel variants

def block_gibbs(ev, X, s, t, steps, r, rng, witnesses=None, flag=None) -> float:
    """`steps` block-Gibbs steps for the uniform law on {x: F(x) < t}: pick r
    distinct coordinates uniformly (independently of x) and resample them
    uniformly among the 2^r assignments that keep x in the set (the current
    one always does). Returns the fraction of steps that changed x."""
    N, d = X.shape
    pats = np.where((np.arange(1 << r)[:, None] >> np.arange(r)) & 1, -1.0, 1.0)  # row 0 = no flip
    moved = 0
    for _ in range(steps):
        J = np.argpartition(rng.random((N, d)), r - 1, axis=1)[:, :r]
        Y = np.repeat(X[:, None, :], 1 << r, axis=1)
        Y[np.arange(N)[:, None, None], np.arange(1 << r)[None, :, None], J[:, None, :]] *= pats[None, :, :]
        Yf = Y[:, 1:, :].reshape(-1, d)
        sy = ev.score(Yf)
        if flag is not None and ev.ambiguous(sy, t):
            flag[0] = True
            return moved / max(1, N * steps)
        if witnesses is not None:
            witnesses.add(Yf, sy)
        sy = sy.reshape(N, (1 << r) - 1)
        ok = np.concatenate([np.ones((N, 1), bool), sy < t], axis=1)
        # an integer uniform in [0, #allowed) selects the allowed assignment of that rank
        k = rng.integers(0, ok.sum(axis=1))
        pick = np.argmax(np.cumsum(ok, axis=1) > k[:, None], axis=1)
        ch = pick > 0
        X[ch] = Y[np.flatnonzero(ch), pick[ch]]
        s[ch] = sy[np.flatnonzero(ch), pick[ch] - 1]
        moved += int(ch.sum())
    return moved / max(1, N * steps)


def run_smc_variant(ev, plan: Plan, rng, kernel: str = "mh", pool: bool = False, witnesses=None) -> SMCResult:
    """run_smc with another kernel ("mh" or "gibbs": plan.flips = block
    sizes) and/or selection pooled over the trajectories: the population at
    each selection is every state since the last resampling (N (m + 1)
    states), and the N new particles are drawn uniformly from the selected
    ones; Z = prod_k (selected / population), exact and rounded down."""
    N = plan.N
    e0 = ev.evals
    X = random_cube(rng, N, ev.d)
    s = ev.score(X)
    K = len(plan.levels)
    num, den, counts = 1, 1, []
    PX, Ps = X, s
    flag = [False]
    for k, t in enumerate(plan.levels):
        if ev.ambiguous(Ps, t):
            return SMCResult(0.0, -math.inf, counts, ev.evals - e0, True)
        alive = Ps < t
        c = int(alive.sum())
        counts.append(c)
        if c == 0:
            return SMCResult(0.0, -math.inf, counts, ev.evals - e0, False)
        num, den = num * c, den * len(Ps)
        if k == K - 1:
            break
        idx = np.flatnonzero(alive)[rng.integers(0, c, size=N)]
        X, s = PX[idx].copy(), Ps[idx].copy()
        trace = [(X.copy(), s.copy())]
        for _ in range(plan.moves[k]):
            if kernel == "gibbs":
                block_gibbs(ev, X, s, t, 1, plan.flips[k], rng, witnesses, flag)
            else:
                metropolis(ev, X, s, t, 1, plan.flips[k], rng, witnesses, flag)
            if flag[0]:
                return SMCResult(0.0, -math.inf, counts, ev.evals - e0, True)
            if pool:
                trace.append((X.copy(), s.copy()))
        if pool:
            PX, Ps = np.concatenate([a for a, _ in trace]), np.concatenate([b for _, b in trace])
        else:
            PX, Ps = X, s
    Z = _float_down(Fraction(num, den))
    return SMCResult(Z, math.log10(Z) if Z > 0 else -math.inf, counts, ev.evals - e0, False)


# ------------------------------------------------------------ soft levels
#
# gamma_k(x) = 2^(-n_k(x)), n_k(x) = ceil(theta_k (F(x) - t*)_+), an integer,
# for 0 = theta_0 < theta_1 < ... < theta_{K-1}; the last step is the hard cut
# [F < t_cert] (where n_{K-1} = 0). Incremental weights 2^(n_{k-1} - n_k) are
# exact powers of two; the Metropolis acceptance 2^-(n_k(y) - n_k(x)) is
# realised exactly with integer coin flips; resampling proportional to the
# weights is exact by rejection. A weight that underflows to 0 only lowers the
# potential, which lowers the mean of Z. A decision is flagged (Z = 0) when a
# score is not finite, theta_k (f_fl - t*) is within theta_k E of an integer,
# or f_fl is within E of t*, so that the run coincides with the ideal run.

def _n_level(ev, s, theta, flag):
    with np.errstate(over="ignore", invalid="ignore"):
        r = theta * (s - ev.thr)
        if flag is not None:
            near = (np.abs(r - np.rint(r)) <= theta * ev.E * (1 + 1e-9) + 1e-12) | (np.abs(s - ev.thr) <= ev.E)
            if not np.isfinite(r).all() or np.any(near & (s > ev.thr - ev.E)):
                flag[0] = True
        return np.where(s > ev.thr, np.ceil(np.nan_to_num(r, posinf=2.0 ** 62)), 0.0).astype(np.int64)


def bern_pow2(m, rng):
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
        out[act[(u >> (62 - c)) != 0]] = False
        rem[act] -= c


def resample_pow2(k, N, rng):
    """N indices i.i.d. with probability proportional to 2^-k_i, exactly."""
    k = np.asarray(k, dtype=np.int64)
    k = k - k.min()
    out = np.empty(0, dtype=np.int64)
    while out.size < N:
        i = rng.integers(0, k.size, size=2 * (N - out.size))
        out = np.concatenate([out, i[bern_pow2(k[i], rng)]])
    return out[:N]


def soft_metropolis(ev, X, s, theta, steps, flips, rng, flag=None):
    N, d = X.shape
    rows = np.arange(N)[:, None]
    n = _n_level(ev, s, theta, None)
    for _ in range(steps):
        J = rng.integers(0, d, size=(N, 1)) if flips == 1 else \
            np.argpartition(rng.random((N, d)), flips - 1, axis=1)[:, :flips]
        Y = X.copy()
        Y[rows, J] *= -1.0
        sy = ev.score(Y)
        ny = _n_level(ev, sy, theta, flag)
        acc = bern_pow2(np.maximum(ny - n, 0), rng)
        X[acc], s[acc], n[acc] = Y[acc], sy[acc], ny[acc]


def run_soft_smc(ev, thetas, N, moves, flips, rng) -> SMCResult:
    e0 = ev.evals
    X = random_cube(rng, N, ev.d)
    s = ev.score(X)
    flag = [False]
    logZ, counts = 0.0, []
    n_prev = np.zeros(N, dtype=np.int64)
    for th in thetas:
        n = _n_level(ev, s, th, flag)
        inc = n - n_prev
        w = np.ldexp(1.0, -np.minimum(inc, 1100))
        if w.max() == 0:
            return SMCResult(0.0, -math.inf, counts, ev.evals - e0, flag[0])
        logZ += math.log(math.fsum(w) / N)
        counts.append(float(w.mean()))
        idx = resample_pow2(inc, N, rng)
        X, s = X[idx], s[idx]
        soft_metropolis(ev, X, s, th, moves, flips, rng, flag)
        n_prev = _n_level(ev, s, th, None)
    if flag[0] or ev.ambiguous(s, ev.t_cert):
        return SMCResult(0.0, -math.inf, counts, ev.evals - e0, True)
    c = int((s < ev.t_cert).sum())
    counts.append(c / N)
    if c == 0:
        return SMCResult(0.0, -math.inf, counts, ev.evals - e0, False)
    logZ += math.log(c / N)
    # the weights' sums are float sums of powers of two (relative error far below 1e-9)
    return SMCResult(math.exp(logZ) * (1 - 1e-9), logZ / math.log(10), counts, ev.evals - e0, False)


def pilot_soft(ev, N, rho, moves, rng, flips=1, max_levels=200):
    """Adaptive temperatures: theta_k with mean incremental weight about rho,
    moved to the middle of its step (away from flagged crossings); stops
    when a fraction >= rho of the particles is certified."""
    X = random_cube(rng, N, ev.d)
    s = ev.score(X)
    thetas, th_prev = [], 0.0
    n_prev = np.zeros(N, dtype=np.int64)
    while len(thetas) < max_levels and np.mean(ev.certified(s)) < rho:
        def meanw(th):
            return float(np.mean(np.ldexp(1.0, -np.minimum(_n_level(ev, s, th, None) - n_prev, 1100))))
        lo, hi = th_prev, max(2 * th_prev, 1.0)
        while meanw(hi) > rho and hi < 1e12:
            hi *= 2
        for _ in range(50):
            mid = (lo + hi) / 2
            lo, hi = (mid, hi) if meanw(mid) > rho else (lo, mid)
        th = hi
        c = s[s > ev.thr] - ev.thr
        if c.size:
            j = np.floor(th * c)
            th = 0.5 * (float(np.max(j / c)) + float(np.min((j + 1) / c)))
        inc = _n_level(ev, s, th, None) - n_prev
        idx = resample_pow2(inc, N, rng)
        X, s = X[idx], s[idx]
        soft_metropolis(ev, X, s, th, moves, flips, rng)
        thetas.append(th)
        th_prev = th
        n_prev = _n_level(ev, s, th, None)
    return thetas


# ------------------------------------------------------------ proposals

_QBITS = 32
_QDEN = float(1 << _QBITS)


def _dyadic(q):
    """Numerators k in [1, 2^32 - 1] of the dyadic probabilities k / 2^32 nearest to q."""
    return np.clip(np.rint(np.asarray(q, dtype=float) * _QDEN), 1, _QDEN - 1).astype(np.int64)


class ARLogistic:
    """Pr[x_i = +1 | x_<i] = k_i(x_<i) / 2^32, k_i the dyadic rounding of
    sigmoid(a_i + B_i . x_<i); sampler and pmf use the same integers."""

    def __init__(self, d):
        self.d = d
        self.a = np.zeros(d)
        self.B = np.zeros((d, d))

    def fit(self, X, l2=1.0, iters=30):
        n, d = X.shape
        y = (X > 0).astype(float)
        for i in range(d):
            F = np.concatenate([np.ones((n, 1)), X[:, :i]], axis=1)
            beta = np.zeros(i + 1)
            reg = l2 * np.eye(i + 1)
            reg[0, 0] = 1e-6
            for _ in range(iters):
                m = 1 / (1 + np.exp(-F @ beta))
                step = np.linalg.solve((F * (m * (1 - m))[:, None]).T @ F + reg, F.T @ (m - y[:, i]) + reg @ beta)
                beta -= step
                if np.abs(step).max() < 1e-8:
                    break
            self.a[i], self.B[i, :i] = beta[0], beta[1:]
        return self

    def sample(self, n, rng):
        X = np.zeros((n, self.d))
        logQ = np.zeros(n)
        for i in range(self.d):
            k = _dyadic(1 / (1 + np.exp(-(self.a[i] + X[:, :i] @ self.B[i, :i]))))
            plus = rng.integers(0, 1 << _QBITS, size=n) < k
            X[:, i] = np.where(plus, 1.0, -1.0)
            logQ += np.log(np.where(plus, k, (1 << _QBITS) - k) / _QDEN)
        return X, logQ


class KernelMixture:
    """Q(x) = (1/m) sum_j eta^H(x, c_j) (1 - eta)^(d - H(x, c_j)), eta = k / 2^32."""

    def __init__(self, centers, eta):
        self.C = np.asarray(centers, dtype=float)
        self.k = int(_dyadic(eta))
        self.eta = self.k / _QDEN

    def logpmf(self, X):
        H = (X.shape[1] - X @ self.C.T) / 2
        L = H * math.log(self.eta) + (X.shape[1] - H) * math.log1p(-self.eta)
        m = L.max(axis=1, keepdims=True)
        return (m + np.log(np.exp(L - m).sum(axis=1, keepdims=True)))[:, 0] - math.log(len(self.C))

    def sample(self, n, rng):
        j = rng.integers(0, len(self.C), size=n)
        flip = rng.integers(0, 1 << _QBITS, size=(n, self.C.shape[1])) < self.k
        X = np.where(flip, -self.C[j], self.C[j])
        return X, self.logpmf(X)


def proposal_weights(ev, X, logQ):
    """W = 1[x certified] D(x)/Q(x), rounded down (the computed log Q is a sum
    of at most d + m logs, so its error is far below the margin subtracted)."""
    s = ev.score(X)
    logW = -ev.d * math.log(2.0) - logQ
    W = np.exp(np.minimum(logW - 1e-9 * (1.0 + np.abs(logQ) + ev.d), 700.0))
    return np.where(ev.certified(s), W, 0.0)


def proposal_lower(ev, Q, n, R, rng, delta=DELTA, chunk=1 << 15):
    """Betting bound from R batch means of n samples of Q (fixed before)."""
    per, means = n // R, []
    for _ in range(R):
        acc, left = 0.0, per
        while left > 0:
            k = min(chunk, left)
            X, lq = Q.sample(k, rng)
            acc += float(proposal_weights(ev, X, lq).sum())
            left -= k
        means.append(acc / per * (1 - 1e-12))
    means = np.array(means)
    return betting_lower(means, delta), means


# ------------------------------------------------------------ experiments

def stats(Z, cost):
    Z = np.asarray(Z)
    m = Z.mean()
    rv = float(Z.var() / m ** 2) if m > 0 else None
    return dict(mean=float(m), relvar=rv, cost_per_replicate=cost, kappa=rv * cost if rv is not None else None)


def part_combine(n_jobs):
    """Clipped KL (M = 2 x pilot estimate, fixed before the batch) and
    min-Markov on the replicates of results/suite.jsonl, vs betting."""
    out = []
    for r in load_rows(os.path.join(RES, "suite.jsonl")):
        if r["p_exact"] <= 0:
            continue
        M = 2 * 10 ** r["pilot_log10Z"]
        Lc, Lm = clipped_kl_lower(r["Z"], M, DELTA), min_markov_lower(r["Z"], DELTA)
        out.append(dict(name=r["name"], budget=r["budget"], trial=r["trial"], p=r["p_exact"], r_bet=r["r_bet"],
                        r_clip=Lc / r["p_exact"], r_min=Lm / r["p_exact"],
                        miss_clip=bool(Lc > r["p_exact"]), miss_min=bool(Lm > r["p_exact"])))
    path = os.path.join(RES, "ablation_combine.jsonl")
    open(path, "w").write("".join(json.dumps(o) + "\n" for o in out))
    print(f"combine: {len(out)} runs")


def small_net(d=12, frac=2e-3):
    rng = np.random.default_rng(2026)
    _, s = train_constant(d, [16], 400, rng, snapshots=(400,))
    net = s[400]
    f = np.sort(net.forward(all_inputs(d, 0, 1 << d)))
    k = max(1, int(frac * len(f)))
    net.bs[-1] = net.bs[-1] + (net.threshold - (f[k - 1] + f[k]) / 2)
    return net


def unbiased_job(variant):
    net = small_net()
    ev = Evaluator(net)
    rng = np.random.default_rng(seed_of("unbiased", variant))
    f = net.forward(all_inputs(net.d, 0, 1 << net.d))
    target = float(np.mean(f < ev.t_cert))
    base = pilot_plan(ev, 200, 0.3, 2, rng).plan
    nm = len(base.moves)
    reps = 20000
    if variant.startswith("soft"):
        flips = 3 if "3 flips" in variant else 1
        thetas = pilot_soft(ev, 200, 0.3, 2, rng, flips=flips)
        Z = [run_soft_smc(ev, thetas, 20, 2, flips, rng).Z for _ in range(reps)]
    else:
        kern, pool, plan = {
            "MH, 2 steps": ("mh", False, Plan(base.levels, 20, [2] * nm, [1] * nm)),
            "MH, 0 steps (no mixing)": ("mh", False, Plan(base.levels, 20, [0] * nm, [1] * nm)),
            "MH, 1 step, 3 flips": ("mh", False, Plan(base.levels, 20, [1] * nm, [3] * nm)),
            "block Gibbs r=2, 1 step": ("gibbs", False, Plan(base.levels, 20, [1] * nm, [2] * nm)),
            "MH, 2 steps, pooled": ("mh", True, Plan(base.levels, 20, [2] * nm, [1] * nm)),
            "block Gibbs r=3, 3 steps": ("gibbs", False, Plan(base.levels, 20, [3] * nm, [3] * nm)),
            "MH, 5 steps, tuned flips, pooled": ("mh", True, Plan(base.levels, 20, [5] * nm, list(base.flips))),
        }[variant]
        Z = [run_smc_variant(ev, plan, rng, kern, pool).Z for _ in range(reps)]
    Z = np.array(Z)
    se = Z.std(ddof=1) / math.sqrt(len(Z))
    return dict(part="unbiased", variant=variant, d=net.d, target=target, replicates=reps,
                mean_over_target=Z.mean() / target,
                z=float((Z.mean() - target) / se))


def coverage_rows(rng, trials=1000, delta=0.1):
    """Clipped KL and min-Markov on synthetic laws with mean 1 (and betting for reference)."""
    laws = {"two-point q=0.05": lambda n: (rng.random(n) < 0.05) / 0.05,
            "lognormal sigma=2": lambda n: np.exp(rng.normal(-2.0, 2.0, n)),
            "exponential": lambda n: rng.exponential(1.0, n)}
    out = []
    for name, draw in laws.items():
        for R in (8, 32):
            miss = dict(bet=0, clip=0, minm=0)
            for _ in range(trials):
                Z = draw(R)
                miss["bet"] += betting_lower(Z, delta) > 1
                miss["clip"] += clipped_kl_lower(Z, 2.0, delta) > 1
                miss["minm"] += min_markov_lower(Z, delta) > 1
            out.append(dict(part="coverage", law=name, R=R, delta=delta, trials=trials,
                            **{f"miss_{k}": v / trials for k, v in miss.items()}))
    return out


def part_unbiased(n_jobs):
    path = os.path.join(RES, "ablation_unbiased.jsonl")
    open(path, "w").close()
    run_parallel(unbiased_job, ["MH, 2 steps", "MH, 0 steps (no mixing)", "MH, 1 step, 3 flips",
                                "block Gibbs r=2, 1 step", "MH, 2 steps, pooled", "block Gibbs r=3, 3 steps",
                                "MH, 5 steps, tuned flips, pooled", "soft", "soft, 3 flips"], path, n_jobs)
    for row in coverage_rows(np.random.default_rng(7)):
        append_row(path, row)
        print(row)


KERNEL_NETS = ["mse_d24_w32_s1500", "mse_d28_w64_s1000", "bce_d28_w32_s60"]
VARIANTS = ["MH tuned (the method)", "MH 1 flip", "block Gibbs r=3, 3 steps", "MH tuned, pooled"]


def kernel_job(args):
    name, variant = args
    net = get_net(name)
    p = exact_failure_count(net) / 2.0 ** net.d
    ev = Evaluator(net)
    rng = np.random.default_rng(seed_of("kernels", name, variant))
    base = pilot_plan(ev, 1000, 0.2, 10, rng).plan
    nm = len(base.moves)
    plan, kern, pool = {
        "MH tuned (the method)": (base, "mh", False),
        "MH 1 flip": (Plan(base.levels, 1000, list(base.moves), [1] * nm), "mh", False),
        "block Gibbs r=3, 3 steps": (Plan(base.levels, 1000, [3] * nm, [3] * nm), "gibbs", False),
        "MH tuned, pooled": (base, "mh", True),
    }[variant]
    t = time.time()
    e0 = ev.evals
    Z = [run_smc_variant(ev, plan, rng, kern, pool).Z for _ in range(40)]
    cost = (ev.evals - e0) / 40
    return dict(part="kernels", name=name, p=p, variant=variant, K=len(plan.levels), **stats(np.array(Z) / p, cost),
                r_bet=betting_lower(Z, DELTA) / p, seconds_per_replicate=(time.time() - t) / 40)


def soft_job(name):
    net = get_net(name)
    p = exact_failure_count(net) / 2.0 ** net.d
    ev = Evaluator(net)
    rng = np.random.default_rng(seed_of("soft", name))
    out = []
    for flips in (1, 3):
        thetas = pilot_soft(ev, 1000, 0.2, 10, rng, flips=flips)
        t = time.time()
        e0 = ev.evals
        Z = [run_soft_smc(ev, thetas, 1000, 10, flips, rng).Z for _ in range(40)]
        cost = (ev.evals - e0) / 40
        out.append(dict(part="soft", name=name, p=p, variant=f"soft levels, {flips} flip(s)", K=len(thetas) + 1,
                        **stats(np.array(Z) / p, cost), r_bet=betting_lower(Z, DELTA) / p,
                        seconds_per_replicate=(time.time() - t) / 40))
    return out


def part_kernels(n_jobs):
    path = os.path.join(RES, "ablation_kernels.jsonl")
    open(path, "w").close()
    run_parallel(kernel_job, [(n, v) for n in KERNEL_NETS for v in VARIANTS], path, n_jobs)


def part_soft(n_jobs):
    path = os.path.join(RES, "ablation_soft.jsonl")
    open(path, "w").close()
    run_parallel(soft_job, ["mse_d24_w32_s1500", "mse_d28_w64_s1000"], path, n_jobs)


PROPOSAL_NETS = ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d28_w64_s600", "mse_d28_w64_s1000",
                 "bce_d28_w32_s60", "smc_mse_d64_w64_s1000", "smc_mse_d64_w64_s1500", "smc_mse_d128_w64_s600"]
N_PROP = 1_000_000


def proposal_job(name):
    net = get_net(name)
    if net.d <= 28:
        p, pkind = exact_failure_count(net) / 2.0 ** net.d, "exact"
    else:
        ref = [r for r in load_rows(os.path.join(RES, "scaling.jsonl")) if r["kind"] == "ref" and r["name"] == name]
        if not ref:
            return []
        p, pkind = ref[0]["p_ref"], "ref"
    ev = Evaluator(net)
    rng = np.random.default_rng(seed_of("proposals", name))
    pil = pilot_plan(ev, 1000, 0.2, 10, rng)
    S = [run_smc(ev, pil.plan, rng, keep_final=True).final_X for _ in range(8)]
    S = np.concatenate([x for x in S if x is not None and len(x)])
    fit_evals = ev.evals
    codes = sorted(set(pack(S)))
    C = unpack(codes, net.d)
    if len(C) > 500:  # at most 500 kernel centres
        C = C[rng.choice(len(C), 500, replace=False)]
    out = []
    for kind in ("autoregressive logistic", "kernel mixture"):
        t = time.time()
        ev.evals = 0
        Q = ARLogistic(net.d).fit(S) if kind.startswith("auto") else KernelMixture(C, 0.02)
        L, means = proposal_lower(ev, Q, N_PROP, 32, rng)
        rv = float(means.var() / max(means.mean(), 1e-300) ** 2)
        out.append(dict(part="proposals", name=name, d=net.d, p=p, p_kind=pkind, proposal=kind, fit_samples=len(S),
                        fit_distinct=len(codes), fit_evals=fit_evals, n=N_PROP, r_bet=L / p,
                        mean_over_p=float(means.mean()) / p, per_sample_relvar=rv * (N_PROP // 32),
                        seconds=round(time.time() - t, 1)))
    return out


def part_proposals(n_jobs):
    path = os.path.join(RES, "ablation_proposals.jsonl")
    open(path, "w").close()
    run_parallel(proposal_job, PROPOSAL_NETS, path, n_jobs)


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args)
    parts = dict(combine=part_combine, unbiased=part_unbiased, kernels=part_kernels, soft=part_soft,
                 proposals=part_proposals)
    for a in (list(parts) if args == ["all"] else args):
        parts[a](n_jobs)


if __name__ == "__main__":
    main()
