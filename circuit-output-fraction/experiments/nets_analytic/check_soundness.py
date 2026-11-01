"""Brute-force soundness checks of rareprob.nets_analytic on small adversarial
nets (d <= 12), against the exact failure set computed independently in
exact integer arithmetic (every float64 weight is an integer times a power of
two, so F(x) is evaluated exactly with Python integers; nothing of the module
is used for the ground truth).

Families: random Gaussian weights with thresholds at many quantiles; integer
weights (arithmetic structure, exact ties); 3-CNF encodings (failure = all
clauses satisfied, an AND of halfspaces with positive output weights);
extreme scales (1e-6 .. 1e6 mixed); overflow scales (per-layer scales up to
1e+-300, and the counterexamples of the adversarial review: McDiarmid's
overflowing square, overflowing cells of the narrow-net DP, NaN forward
passes, the depth-3 CROWN overflow); zero and duplicated units; constant nets
at the threshold and within the floating-point band; small trained nets; two
and three hidden layers.

Checks (a method may refuse a net with ValueError / FloatingPointError: that
is recorded, never counted as a failure; a wrong answer is):
  0. fails_exact equals the exact indicator on every point.
  1. forward_error_bound: |f_fl - F| <= tau on sampled inputs (tau = inf
     whenever a float value is not finite).
  2. form_dp: the DP law of N x equals the enumerated histogram.
  3. chernoff_holder (relu/even, groups of size 1/2/3) >= p; mcdiarmid >= p
     (and never NaN).
  4. tilt envelopes (box relaxations; CROWN for deep nets): on every failing
     x the importance weight is <= 1 before clipping (domination), and
     E_Q W = p / Z exactly (enumeration).
  5. sign-pattern (softplus) envelopes: domination on every failing x, the
     mass equals sum_x D(x) phi(x) (within logZ_err), the sampler matches the
     ideal law (chi-square, d = 8), and the barrier Z >= exp(theta (t - F(0))).
  6. perturb-and-MAP: the certified bound (EnumMAPOracle, n = 200,
     delta = 0.05) is >= p; and the Hazan-Jaakkola inequality
     log E e^{-theta F} <= E R holds for the sample mean of R up to 4 standard
     errors (a statistical check of the implementation).
  7. coverage of envelope_interval (two-sided) over repeated runs (tilt and
     sign-pattern envelopes).
  8. small_width_interval (nets with <= 3 hidden units): lo <= p <= hi.
  9. cube-certified tilt envelopes (when symmetric_gap > 0): domination on
     every failing x and E_Q W = p / Z exactly (enumeration).
Output: results/soundness.json and a summary line per family.
"""

import json
import math
import os
import sys
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import MLP, all_inputs, train_constant  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

REFUSE = (ValueError, FloatingPointError)


# ------------------------------------------------ exact ground truth

def _scaled(arr):
    """Integers N and K with arr = N / 2^K exactly (object array of ints)."""
    arr = np.asarray(arr, dtype=np.float64)
    if not np.isfinite(arr).all():
        raise ValueError("non-finite weight")
    parts = [(0, 0) if v == 0 else (int(math.ldexp(math.frexp(v)[0], 53)), math.frexp(v)[1] - 53)
             for v in arr.ravel()]
    K = max([0] + [-e for m, e in parts if m])
    N = np.array([m << (e + K) if m else 0 for m, e in parts], dtype=object).reshape(arr.shape)
    return N, K


def exact_fails(net, X):
    """[F(x) < t] for the rows of X (+-1), in exact integer arithmetic."""
    H = np.array(X, dtype=np.int64).astype(object)
    Kh = 0
    for k, (W, b) in enumerate(zip(net.Ws, net.bs)):
        Wn, Kw = _scaled(W)
        bn, Kb = _scaled(b)
        Z = H.dot(Wn.T)  # denominator 2^(Kh + Kw)
        K = max(Kh + Kw, Kb)
        Z = Z * (1 << (K - Kh - Kw)) + bn * (1 << (K - Kb))
        H = Z if k == len(net.Ws) - 1 else np.where(Z > 0, Z, 0)
        Kh = K
    tn, Kt = _scaled(np.array([net.threshold]))
    K = max(Kh, Kt)
    lhs = H[:, 0] * (1 << (K - Kh))
    rhs = tn[0] * (1 << (K - Kt))
    return np.array([v < rhs for v in lhs], dtype=bool)


def exact_p(net):
    X = all_inputs(net.d, 0, 1 << net.d)
    fails = exact_fails(net, X)
    return float(fails.mean()), X, fails


def mk(W, b, a, c, t, loss="mse"):
    return MLP([np.asarray(W, float), np.asarray([a], float)], [np.asarray(b, float), np.asarray([c], float)],
               threshold=float(t), loss=loss)


# ----------------------------------------------------------- families

def families(rng):
    nets = []
    # random Gaussian, thresholds at quantiles
    for _ in range(40):
        d = int(rng.integers(6, 13))
        m = int(rng.integers(2, 10))
        W = rng.normal(0, 1, (m, d)) * rng.choice([0.3, 1, 3])
        b = rng.normal(0, 1, m)
        a = rng.normal(0, 1, m)
        c = rng.normal()
        net = mk(W, b, a, c, 0.0)
        f = net.forward(all_inputs(d, 0, 1 << d))
        net.threshold = float(np.quantile(f, rng.choice([0.0, 0.001, 0.01, 0.05, 0.2, 0.5])) + rng.choice([0, 1e-9]))
        nets.append(("gauss", net))
    # integer weights (ties at the threshold are exact)
    for _ in range(25):
        d = int(rng.integers(6, 13))
        m = int(rng.integers(2, 8))
        W = rng.integers(-2, 3, (m, d)).astype(float)
        b = rng.integers(-2, 3, m).astype(float)
        a = rng.integers(-2, 3, m).astype(float)
        nets.append(("integer", mk(W, b, a, float(rng.integers(-1, 3)), float(rng.integers(0, 4)) * 0.5)))
    # 3-CNF encodings: unit per clause relu(-(l1+l2+l3) - 2) = 1 iff violated
    for _ in range(20):
        d = int(rng.integers(6, 13))
        m = int(rng.integers(2, 3 * d))
        W = np.zeros((m, d))
        for j in range(m):
            vs = rng.choice(d, 3, replace=False)
            W[j, vs] = -rng.choice([-1.0, 1.0], 3)
        nets.append(("cnf", mk(W, -2 * np.ones(m), np.ones(m), 0.0, 0.5)))
    # extreme scales
    for _ in range(15):
        d = int(rng.integers(6, 11))
        m = int(rng.integers(2, 6))
        W = rng.normal(0, 1, (m, d)) * 10.0 ** rng.integers(-6, 7, (m, 1))
        b = rng.normal(0, 1, m) * 10.0 ** rng.integers(-6, 7, m)
        a = rng.normal(0, 1, m) * 10.0 ** rng.integers(-6, 7, m)
        net = mk(W, b, a, 0.0, 0.0)
        f = net.forward(all_inputs(d, 0, 1 << d))
        net.threshold = float(np.quantile(f, 0.1))
        nets.append(("extreme", net))
    nets += overflow_family(rng)
    # zero / duplicated units, constant nets at and near the threshold
    for _ in range(8):
        d = 8
        W = rng.normal(0, 1, (4, d))
        W[1] = 0
        W[3] = W[2]
        b = np.array([0.1, 0.0, -0.2, -0.2])
        a = np.array([1.0, 0.0, 0.7, -0.7])
        nets.append(("degenerate", mk(W, b, a, 0.3, 0.3 + rng.choice([0, 1e-16, -1e-16]))))
    nets.append(("constant_at_t", mk(np.zeros((2, 6)), np.zeros(2), np.zeros(2), 0.5, 0.5)))
    nets.append(("constant_below", mk(np.zeros((2, 6)), np.zeros(2), np.zeros(2), 0.5 - 2 ** -53, 0.5)))
    # small trained nets
    for s in [50, 200, 800]:
        net, _ = train_constant(10, [8], s, rng)
        nets.append(("trained", net))
        net, _ = train_constant(10, [8], s, rng, loss="bce")
        nets.append(("trained", net))
    return nets


def overflow_family(rng):
    """Float64 at its edges: the counterexamples of the adversarial review and
    random nets with per-layer scales up to 1e+-300."""
    out = []
    d = 10
    out.append(("overflow", mk(np.full((1, d), 2e53), [11 * 2e53], [1e100], -8e153, 0.5)))  # McDiarmid
    out.append(("overflow", mk(np.zeros((2, 6)), [1e150, 1e150], [1e160, -1e160], 0.0, 0.5)))  # DP cells
    v = np.ones(6)
    out.append(("overflow", mk(np.vstack([1e150 * v, 1e150 * v, np.eye(6)[0]]), [1e151, 1e151, 0.0],
                               [1e160, -1e160, 1.0], 0.0, 0.5)))
    out.append(("overflow", mk(np.array([[1e308, 1e308, 0, 0, 0, 0], [1e308, 1e308, 0, 0, 0, 0]]), [0.0, 0.0],
                               [1.0, -1.0], 0.0, 0.5)))  # NaN forward
    for _ in range(25):
        d = int(rng.integers(5, 10))
        m = int(rng.integers(1, 5))
        sw, sa = 10.0 ** rng.uniform(-300, 300), 10.0 ** rng.uniform(-300, 300)
        W = rng.normal(0, 1, (m, d)) * sw
        b = rng.normal(0, 1, m) * sw
        a = rng.normal(0, 1, m) * sa
        net = mk(W, b, a, float(rng.normal()) * sa * min(sw, 1e300 / max(sa, 1e-300)), 0.0)
        with np.errstate(all="ignore"):
            f = net.forward(all_inputs(d, 0, 1 << d))
        if np.isfinite(f).all():
            net.threshold = float(np.quantile(f, rng.uniform(0.05, 0.5)))
        out.append(("overflow", net))
    return out


def deep_families(rng):
    out = []
    for _ in range(20):
        d = int(rng.integers(6, 11))
        w1, w2 = int(rng.integers(2, 8)), int(rng.integers(2, 6))
        net = MLP([rng.normal(0, 1, (w1, d)), rng.normal(0, 1, (w2, w1)), rng.normal(0, 1, (1, w2))],
                  [rng.normal(0, 1, w1), rng.normal(0, 1, w2), rng.normal(0, 1, 1)], 0.0, "mse")
        f = net.forward(all_inputs(d, 0, 1 << d))
        net.threshold = float(np.quantile(f, rng.choice([0.01, 0.1, 0.5])))
        out.append(("deep", net))
    for s in [30, 200]:
        net, _ = train_constant(9, [6, 6], s, rng)
        out.append(("deep_trained", net))
    # the depth-3 CROWN overflow of nets_verify (every point fails)
    d = 3
    out.append(("deep_overflow", MLP([np.full((1, d), 1e-200), np.array([[1e154], [1e154]]),
                                      np.array([[1e154, 1e154]]), np.array([[-0.4]])],
                                     [np.array([1e-15]), np.zeros(2), np.zeros(1), np.array([2e291])], 0.0)))
    return out


# -------------------------------------------------------------- checks

def check_net(kind, net, rng, report):
    p, X, fails = exact_p(net)
    rec = {"kind": kind, "d": net.d, "p": p, "refused": []}

    def fail(*args):
        report["fail"].append(args)

    def guarded(name, fn):
        try:
            return fn()
        except REFUSE as e:
            rec["refused"].append(f"{name}: {e}")
            return None

    # 0. the module's exact indicator
    if (na.fails_exact(net, X) != fails).any():
        fail("fails_exact", kind)
    # 1. forward error
    tau = na.forward_error_bound(net)
    with np.errstate(all="ignore"):
        fx = net.forward(X)
    if not np.isfinite(fx).all() and tau != math.inf:
        fail("tau_nonfinite", kind, tau)
    for x in X[rng.choice(len(X), 5)]:
        with np.errstate(all="ignore"):
            v = float(net.forward(x[None])[0])
        if math.isfinite(v) and math.isfinite(tau):
            if abs(Fraction(v) - na.exact_output(net, x)) > Fraction(tau):
                fail("tau", kind)
    if len(net.Ws) == 2:
        W, b, a, c = na.one_layer(net)
        # 2. DP law (uniform measure)
        G = list(rng.choice(W.shape[0], min(2, W.shape[0]), replace=False))
        fm = guarded("quantize", lambda: na.quantize(W[G], b[G], na.grid_for(W[G], 40)))
        if fm is not None:
            law = na.form_dp(fm.N)
            S = (X @ fm.N.T).astype(np.int64) + fm.S
            H = np.zeros(law.P.shape)
            np.add.at(H, tuple(S.T), np.ones(len(X)) / len(X))
            if np.max(np.abs(H - law.P)) > 1e-12:
                fail("dp", kind)
        # 3. bounds
        for form in ("relu", "even"):
            m = W.shape[0]
            for gs in (1, 2, 3):
                groups = [list(range(i, min(i + gs, m))) for i in range(0, m, gs)]
                bd = guarded("chernoff_holder", lambda: na.chernoff_holder(net, groups, form=form, restarts=2))
                if bd is None:
                    continue
                rec[f"CH_{form}{gs}"] = bd.value
                if not bd.value >= p:
                    fail(f"CH_{form}{gs}", kind, p, bd.value)
        bd = guarded("mcdiarmid", lambda: na.mcdiarmid(net))
        if bd is not None and not bd.value >= p:
            fail("mcd", kind, p, bd.value)
        envs = [guarded("tilt_envelope", lambda: na.tilt_envelope(net, restarts=1, rng=rng))]
    else:
        envs = []
    if len(net.Ws) > 2 or rng.random() < 0.3:
        envs.append(guarded("tilt_envelope_deep", lambda: na.tilt_envelope_deep(net)))
    # 4. tilt envelopes
    for env in envs:
        if env is None:
            continue
        lw = env.A0 + X @ env.alpha - env.logZ
        if np.any(lw[fails] > 1e-12):
            fail("tilt_domination", kind, float(lw[fails].max()))
        Q = np.prod(np.where(X > 0, env.pi, 1 - env.pi), axis=1)
        EW = float(np.sum(Q * env.weight(X, fails)))
        # E_Q W = p / Z, compared in logs (Z can exceed the float range)
        if p > 0 and EW > 0 and abs(math.log(EW) + env.logZ - math.log(p)) > 1e-9:
            fail("tilt_mass", kind, math.log(EW) + env.logZ - math.log(p))
        if p > 0 and EW == 0 and env.logZ < 600:
            fail("tilt_mass_zero", kind, env.logZ)
        rec["tilt_logK"] = env.logZ - math.log(p) if p > 0 else None
    # 5. sign-pattern envelope
    if len(net.Ws) == 2 and np.any(na.one_layer(net)[2] < 0):
        W, b, a, c = na.one_layer(net)
        spe = guarded("sign_pattern", lambda: na.sign_pattern_envelope(net, n_split=min(4, int((a < 0).sum())),
                                                                        restarts=1, rng=rng))
        if spe is not None:
            lphi = spe.log_phi(X)
            if np.any(lphi[fails] < -1e-12):
                fail("signpat_domination", kind, float(lphi[fails].min()))
            mx = float(lphi.max())
            logZb = mx + math.log(float(np.mean(np.exp(lphi - mx))))
            if abs(logZb - spe.logZ) > spe.logZ_err + 1e-12 * (1 + abs(logZb)):
                fail("signpat_mass", kind, logZb - spe.logZ)
            F0 = float(na.exact_output(net, np.zeros(net.d)))
            if spe.logZ < spe.theta * (float(net.threshold) - F0) - 1e-9 * (1 + abs(spe.logZ)):
                fail("signpat_barrier", kind, spe.logZ, spe.theta * (net.threshold - F0))
            rec["signpat_logK"] = spe.logZ - math.log(p) if p > 0 else None
            if net.d == 8:
                n = 200000
                Xs = spe.sample(n, rng)
                idx = ((Xs > 0) * (1 << np.arange(8))).sum(1)
                obs = np.bincount(idx, minlength=256)
                ids = ((X > 0) * (1 << np.arange(8))).sum(1)
                ideal = np.zeros(256)
                ideal[ids] = np.exp(lphi - mx) / np.sum(np.exp(lphi - mx))
                ok = ideal * n > 5
                chi2 = float(np.sum((obs[ok] - n * ideal[ok]) ** 2 / (n * ideal[ok])))
                dof = int(ok.sum()) - 1
                rec["signpat_chi2_z"] = (chi2 - dof) / math.sqrt(2 * dof) if dof > 0 else 0.0
                if rec["signpat_chi2_z"] > 5 or obs[~ok].sum() > 5 * max(1, n * ideal[~ok].sum()) + 20:
                    fail("signpat_sampler", kind, rec["signpat_chi2_z"])
    # 8. exact DP interval for narrow nets
    if len(net.Ws) == 2 and net.Ws[0].shape[0] <= 3:
        iv = guarded("small_width_interval", lambda: na.small_width_interval(net, budget=60))
        if iv is not None:
            rec["dp_interval"] = iv
            if not (iv[0] <= p <= iv[1]):
                fail("small_width_interval", kind, p, *iv)
    # 6. perturb-and-MAP
    if net.d >= 4:
        orc = guarded("EnumMAPOracle", lambda: na.EnumMAPOracle(net))
        if orc is not None:
            # 9. cube-certified tilt
            if na.symmetric_gap(orc.F, float(net.threshold)) > 0:
                env = guarded("cube_tilt", lambda: na.cube_tilt_envelope(net, orc, iters=60))
                if env is not None:
                    lw = env.A0 + X @ env.alpha - env.logZ
                    if np.any(lw[fails] > 1e-12):
                        fail("cubetilt_domination", kind, float(lw[fails].max()))
                    Q = np.prod(np.where(X > 0, env.pi, 1 - env.pi), axis=1)
                    EW = float(np.sum(Q * env.weight(X, fails)))
                    if p > 0 and EW > 0 and abs(math.log(EW) + env.logZ - math.log(p)) > 1e-9:
                        fail("cubetilt_mass", kind, math.log(EW) + env.logZ - math.log(p))
                    if p > 0 and EW == 0 and env.logZ < 600:
                        fail("cubetilt_mass_zero", kind, env.logZ)
                    rec["cubetilt_logK"] = env.logZ - math.log(p) if p > 0 else None
            Fx = np.array([float(v) for v in net.forward(X)])
            for th in (1.0, 5.0):
                for blk in (1, 2):
                    bd = na.perturb_map_bound(orc, th, blk, 200, 0.05, rng)
                    rec[f"PM_{th:g}_{blk}"] = bd.value
                    if not bd.value >= p:
                        fail("pmap_bound", kind, p, bd.value)
                    with np.errstate(all="ignore"):
                        m0 = float((-th * Fx).max())
                        lz = m0 + math.log(float(np.mean(np.exp(-th * Fx - m0))))
                        R = na.perturb_map_samples(orc, th, blk, 400, rng)
                    if math.isfinite(lz) and np.isfinite(R).all() and \
                            R.mean() + 4 * R.std(ddof=1) / math.sqrt(R.size) + 1e-9 < lz:
                        fail("pmap_HJ", kind, float(R.mean()), lz)
    report["nets"].append(rec)


def coverage(rng, report, runs=60):
    """Two-sided intervals from the tilt and sign-pattern envelopes on nets
    where they are useful (mostly-active units make F nearly affine, plus two
    kinked units), threshold at a low quantile; every interval is compared
    with the exact p. delta = 0.1 per interval."""
    cnt = {"runs": 0, "miss": 0, "p": [], "K": [], "kind": []}
    for trial in range(6):
        d = 10
        W = rng.normal(0, 1, (5, d))
        b = rng.normal(0, 1, 5)
        b[:3] = np.abs(W[:3]).sum(1) + 0.5  # always active on the cube
        a = rng.normal(0, 1, 5)
        net = mk(W, b, a, 0.0, 0.0)
        f = net.forward(all_inputs(d, 0, 1 << d))
        net.threshold = float(np.quantile(f, rng.choice([0.01, 0.03, 0.1])))
        p, X, _ = exact_p(net)
        envs = [na.tilt_envelope(net, restarts=2, rng=rng)]
        if np.any(a < 0):
            envs.append(na.sign_pattern_envelope(net, n_split=int(min(3, (a < 0).sum())), restarts=2, rng=rng))
        for env in envs:
            if env.logZ > 0 or p == 0:  # worse than Monte Carlo: envelope_interval refuses it
                continue
            cnt["p"].append(p)
            cnt["K"].append(math.exp(env.logZ) / p)
            cnt["kind"].append(type(env).__name__)
            for r in range(runs):
                est = na.envelope_interval(env, eps=0.3, delta=0.1, max_samples=40000, rng=rng)
                cnt["runs"] += 1
                if not (est.lo <= p <= est.hi):
                    cnt["miss"] += 1
    report["coverage"] = cnt


if __name__ == "__main__":
    import warnings
    warnings.filterwarnings("ignore", category=RuntimeWarning)  # the overflow family overflows on purpose
    rng = np.random.default_rng(20261028)
    report = {"fail": [], "nets": []}
    for kind, net in families(rng) + deep_families(rng):
        check_net(kind, net, rng, report)
    coverage(rng, report)
    kinds = sorted(set(r["kind"] for r in report["nets"]))
    for k in kinds:
        rs = [r for r in report["nets"] if r["kind"] == k]
        print(f"{k:14s} nets={len(rs):3d} p=0: {sum(r['p'] == 0 for r in rs):2d} "
              f"refusals: {sum(len(r['refused']) for r in rs)}")
    print("coverage", {k: v for k, v in report["coverage"].items() if k in ("runs", "miss")})
    print("FAILURES:", report["fail"] if report["fail"] else "none")
    with open(os.path.join(HERE, "results", "soundness.json"), "w") as f:
        json.dump(report, f, indent=1, default=float)
