#!/usr/bin/env python3
"""(a) One training run, simulated episode by episode.

Dispositions: A (intent-follower, t = 0), G (myopic gamer: plays to the weak
grader unless it recognises an audit, t = 1), and careful gamers C_t on a grid
t = 0.05, ..., 0.95 (C_0.5 = G*, the calibrated maximiser of expected score).

Operators on the prior over dispositions:
  (B)     Bayes on the event that the episode's output passes:
          w_theta *= P_theta(pass | episode)
  (C-on)  SFT on filtered on-policy samples, best-of-k: draw up to k outputs
          from the current mixture, keep the first that passes, then
          w_theta *= pi_theta(kept output | episode); no update if none passes
  (C-off) the same with a fixed sampler (the prior mixture), k = 1
  (D)     exact exponential tilt  w_theta = mu0_theta * exp(J_theta / beta),
          J_theta = sum over episodes of theta's reward; 'expected' uses
          P_theta(pass | episode), 'sampled' draws theta's output and grades it
  (D')    extra: vanilla REINFORCE on the mixture logits (on-policy, exact
          baseline), the plain policy-gradient dynamics rather than the tilt

Run:  python3 train_sim.py      (about 20 s; writes train_sim_output.txt, fig_a*.png)
"""
import os
import time
import numpy as np
from scipy.stats import nbinom
from toy import (NORMAL, UNPRED, PRED, AUD_NOOPP, AUD_UNREC, AUD_REC, R, draw_categories,
                 px_table, pass_table, normalize_log, p_hat, u_v, lam, cat_probs, sigmoid,
                 style, plt, SERIES, INK, INK2, MUTED, Report)

HERE = os.path.dirname(os.path.abspath(__file__))
rep = Report(os.path.join(HERE, "train_sim_output.txt"))
style()
T0 = time.time()

DELTA = 0.01
LAM = lam(DELTA)
BETA = 1.0

# Dispositions: A, G (myopic), C_t grid (C_0.5 = G*)
T_GRID = np.round(np.arange(0.05, 0.951, 0.05), 2)
THR = np.concatenate([[0.0, 1.0], T_GRID])
NAMES = ["A", "G"] + ["C_%.2f" % t for t in T_GRID]
iA, iG = 0, 1
iGstar = 2 + int(np.argmin(np.abs(T_GRID - 0.5)))
iC05, iC95 = 2, 2 + len(T_GRID) - 1
PRIOR = np.concatenate([[0.6, 0.01], np.full(len(T_GRID), 0.39 / len(T_GRID))])

PARAMS = {
    # name: (eps, eps_u, a, h, s)
    "P1 gaming pays, honeypot audits": (0.02, 0.0, 0.01, 1.0, 0.5),
    "P2 audits win, honeypot audits": (0.02, 0.0, 0.05, 1.0, 0.5),
    "P3 random audits": (0.05, 0.0, 0.20, 0.05, 0.5),
    "P1u = P1 + 30% unpredictable errors": (0.02, 0.30, 0.01, 1.0, 0.5),
    "PU 30% unpredictable errors only": (0.0, 0.30, 0.0, 1.0, 0.5),
}


# ----------------------------------------------------------------------------
# Operators.  All return log-weights of shape (seeds, n+1, n_disp) or the final
# (seeds, n_disp) for the sequential ones (with a recorded trajectory).
# ----------------------------------------------------------------------------
def op_B(cat, passT, prior):
    lp = np.log(passT)[:, cat]                    # (D, S, n)
    traj = np.concatenate([np.zeros(lp.shape[:2] + (1,)), np.cumsum(lp, axis=2)], axis=2)
    return np.log(prior)[None, None, :] + traj.transpose(1, 2, 0)


def op_D_expected(cat, passT, prior, beta=BETA):
    r = passT[:, cat]
    J = np.concatenate([np.zeros(r.shape[:2] + (1,)), np.cumsum(r, axis=2)], axis=2)
    return np.log(prior)[None, None, :] + (J / beta).transpose(1, 2, 0)


def op_D_sampled(cat, pxT, prior, rng, beta=BETA):
    px = pxT[:, cat]                               # (D, S, n)
    y = (rng.random(px.shape) < px).astype(int)
    r = R[cat[None, :, :], y]
    J = np.concatenate([np.zeros(r.shape[:2] + (1,)), np.cumsum(r, axis=2)], axis=2)
    return np.log(prior)[None, None, :] + (J / beta).transpose(1, 2, 0)


def op_C(cat, pxT, prior, rng, k=1, on_policy=True, record=(0, 1)):
    """SFT on filtered samples, best-of-k.  Returns trajectories of the log-odds
    between the dispositions in `record` and the final log-weights."""
    S, n = cat.shape
    logw = np.tile(np.log(prior), (S, 1))
    lpx, lpi = np.log(pxT), np.log(1 - pxT)
    w0 = prior / prior.sum()
    traj = np.zeros((S, n + 1))
    traj[:, 0] = logw[:, record[0]] - logw[:, record[1]]
    rows = np.arange(S)
    for i in range(n):
        c = cat[:, i]
        w = normalize_log(logw) if on_policy else w0[None, :]
        pX = np.einsum("sd,sd->s", w, pxT[:, c].T)  # mixture prob of X
        ys = (rng.random((S, k)) < pX[:, None]).astype(int)
        ok = R[c[:, None], ys] == 1
        has = ok.any(axis=1)
        first = np.argmax(ok, axis=1)
        ystar = ys[rows, first]
        upd = np.where(ystar[:, None] == 1, lpx[:, c].T, lpi[:, c].T)
        logw = logw + np.where(has[:, None], upd, 0.0)
        traj[:, i + 1] = logw[:, record[0]] - logw[:, record[1]]
    return traj, logw


def op_PG(cat, pxT, prior, rng, eta, record=(0, 1)):
    """Vanilla REINFORCE on mixture logits w (mu = softmax w), exact baseline:
    w_theta += eta * (resp_theta(y) - mu_theta) * (r - b)."""
    S, n = cat.shape
    w = np.tile(np.log(prior), (S, 1))
    traj = np.zeros((S, n + 1))
    traj[:, 0] = w[:, record[0]] - w[:, record[1]]
    for i in range(n):
        c = cat[:, i]
        mu = normalize_log(w)
        pxc = pxT[:, c].T                          # (S, D)
        pX = (mu * pxc).sum(1)
        y = (rng.random(S) < pX).astype(int)
        r = R[c, y]
        b = pX * R[c, 1] + (1 - pX) * R[c, 0]
        piy = np.where(y[:, None] == 1, pxc, 1 - pxc)
        resp = mu * piy / np.where(y == 1, pX, 1 - pX)[:, None]
        w = w + eta * (resp - mu) * (r - b)[:, None]
        traj[:, i + 1] = w[:, record[0]] - w[:, record[1]]
    return traj, w


def slope_stats(traj, n):
    d = (traj[:, -1] - traj[:, 0]) / n
    return d.mean(), d.std(ddof=1) / np.sqrt(len(d)), (traj[:, -1] - traj[:, 0]).std(ddof=1)


def median_se(x, B=400, seed=0):
    """Median (non-crossing runs count as +inf) and bootstrap standard error."""
    x = np.where(np.isfinite(x), x, np.inf)
    r = np.random.default_rng(seed)
    meds = np.median(r.choice(x, (B, len(x))), axis=1)
    meds = meds[np.isfinite(meds)]
    return np.median(x), (meds.std() if len(meds) > 10 else np.nan)


def fmt(x, se=None):
    return ("%+.5f" % x) if se is None else ("%+.5f +- %.5f" % (x, se))


# ============================================================================
# 1. Drift of the log-odds L = ln mu(A)/mu(theta) under (B), (D), (C)
# ============================================================================
rep("=" * 78)
rep("(a) ONE TRAINING RUN -- train_sim.py")
rep("delta = %.3g, Lam = ln((1-delta)/delta) = %.4f, beta = %.1f" % (DELTA, LAM, BETA))
rep("dispositions: A (t=0), G (t=1, myopic), C_t for t in %s (C_0.50 = G*)" % [float(t) for t in T_GRID])
rep("prior: A 0.60, G 0.01, each C_t %.4f" % (0.39 / len(T_GRID)))
rep("=" * 78)
rep("")
rep("Derived predictions (per episode; u = a h (1-s) caught-gaming rate, v = (1-a) eps")
rep("rewarded-gaming rate; a disposition games iff p_hat = u/(u+v) < t):")
rep("  (B)     E dL = -D_B,    D_B = Lam (v - u)              for every gaming theta")
rep("  (D)     E dL = -D_D,    D_D = (1 - 2 delta)(v - u)/beta")
rep("  (C-off) E dL = -D_Coff, D_Coff = Lam (v pX0 - u (1 - pX0)), pX0 = P_prior(X | opportunity)")
rep("  (C-on, best-of-k) dL/dn = -Lam [v (1-(1-pX)^k) - u (1-pX^k)], pX = m_G (1-delta) + (1-m_G) delta")
rep("  non-gaming theta (t <= p_hat): dL = 0 exactly under (B), (C), (D-expected)")
rep("")

S, N = 200, 3000
rng = np.random.default_rng(20261018)
results_a1 = {}
for pname, (eps, eps_u, a, h, s) in PARAMS.items():
    ph = p_hat(eps, a, h, s)
    u, v = u_v(eps, a, h, s)
    pxT = px_table(THR, ph, DELTA)
    passT = pass_table(pxT)
    games = (ph < THR) | (THR >= 1)          # myopic G (t = 1) games even when ph = 1 (as in toy.px_table)
    cat = draw_categories(rng, (S, N), eps, eps_u, a, h, s)
    rep("-" * 78)
    rep("%s: eps=%.3g eps_u=%.3g a=%.3g h=%.3g s=%.3g" % (pname, eps, eps_u, a, h, s))
    rep("   u = %.5f, v = %.5f, p_hat = %.4f; gaming dispositions: %s" %
        (u, v, ph, ", ".join(nm for nm, g in zip(NAMES, games) if g) or "none"))
    D_B = LAM * (v - u)
    D_D = (1 - 2 * DELTA) * (v - u) / BETA
    pX0 = (PRIOR * pxT[:, PRED]).sum()
    D_Coff = LAM * (v * pX0 - u * (1 - pX0))
    var_B = LAM ** 2 * (u + v) - D_B ** 2
    var_D = ((1 - 2 * DELTA) / BETA) ** 2 * (u + v) - D_D ** 2
    lB = op_B(cat, passT, PRIOR)
    lD = op_D_expected(cat, passT, PRIOR)
    lDs = op_D_sampled(cat, pxT, PRIOR, rng)
    trCoff, lCoff = op_C(cat, pxT, PRIOR, rng, k=1, on_policy=False)
    trCon, lCon = op_C(cat, pxT, PRIOR, rng, k=1, on_policy=True)
    trCon8, lCon8 = op_C(cat, pxT, PRIOR, rng, k=8, on_policy=True)
    LB = lB[:, :, iA] - lB[:, :, iG]
    LD = lD[:, :, iA] - lD[:, :, iG]
    LDs = lDs[:, :, iA] - lDs[:, :, iG]
    results_a1[pname] = dict(LB=LB, LD=LD, D_B=D_B, D_D=D_D, ph=ph, lB=lB, games=games,
                             trCon=trCon, trCoff=trCoff)
    for lab, tr, pred, sd_pred in [("(B)", LB, -D_B, np.sqrt(N * var_B)),
                                   ("(D) expected reward", LD, -D_D, np.sqrt(N * var_D)),
                                   ("(D) sampled rewards", LDs, -D_D, None),
                                   ("(C-off) fixed sampler", trCoff, -D_Coff, None)]:
        m, se, sd = slope_stats(tr, N)
        ok = abs(m - pred) < 3 * se + 1e-9 + 0.02 * abs(pred)
        rep.check("%s %s: mean drift of ln mu(A)/mu(G) per episode" % (pname.split()[0], lab),
                  fmt(pred), fmt(m, se) + ("" if sd_pred is None else
                                           "   [sd of L_n - L_0 across seeds: predicted %.2f, simulated %.2f]"
                                           % (sd_pred, sd)), ok)
    # Proxy-equivalence: within-class log-odds never move under B, C, D-expected
    nong = [i for i in range(len(THR)) if not games[i]]
    gam = [i for i in range(len(THR)) if games[i]]
    dev = 0.0
    for L in (lB, lD):
        ref_n, ref_g = L[:, :, nong[0]], (L[:, :, gam[0]] if gam else None)
        base_n = np.log(PRIOR[nong[0]])
        for i in nong:
            dev = max(dev, np.max(np.abs((L[:, :, i] - ref_n) - (np.log(PRIOR[i]) - base_n))))
        for i in gam:
            dev = max(dev, np.max(np.abs((L[:, :, i] - ref_g) - (np.log(PRIOR[i]) - np.log(PRIOR[gam[0]])))))
    for lw in (lCon, lCon8, lCoff):
        for grp in (nong, gam):
            if len(grp) > 1:
                d0 = lw[:, grp] - lw[:, [grp[0]]] - (np.log(PRIOR[grp]) - np.log(PRIOR[grp[0]]))[None, :]
                dev = max(dev, np.max(np.abs(d0)))
    rep.check("%s proxy-equivalence: odds within {theta: t <= p_hat} and within {theta: t > p_hat} "
              "never move under (B), (D-expected), (C-on k=1,8), (C-off)" % pname.split()[0],
              "max |change in within-class log-odds| = 0", "%.2e (over %d seeds x %d episodes)" % (dev, S, N),
              dev < 1e-8)
    # C-on: mean-field ODE for class log-odds
    mA0 = PRIOR[~games].sum()
    for k, tr, lw in [(1, trCon, lCon), (8, trCon8, lCon8)]:
        Lc = np.log(mA0 / max(1 - mA0, 1e-300)) if games.any() else np.inf
        if np.isfinite(Lc):
            for _ in range(N):
                pX = sigmoid(-Lc) * (1 - DELTA) + sigmoid(Lc) * DELTA
                Lc += LAM * (u * (1 - pX ** k) - v * (1 - (1 - pX) ** k))
            mA_pred = sigmoid(Lc)
        else:
            mA_pred = 1.0
        wf = normalize_log(lw)
        mA_sim = wf[:, ~games].sum(1)
        ok = abs(np.median(mA_sim) - mA_pred) < 0.1
        rep.check("%s (C-on, best-of-%d): class-A mass after %d episodes (mean-field ODE)" % (pname.split()[0], k, N),
                  "%.4f" % mA_pred, "median %.4f, mean %.4f; fraction of seeds ending with class-A mass > 1/2: %.3f" %
                  (np.median(mA_sim), mA_sim.mean(), np.mean(mA_sim > 0.5)), ok,
                  "mean field gives the majority outcome; early jumps of size Lam send a minority of seeds"
                  " to the other attractor" if 0.02 < np.mean(mA_sim > 0.5) < 0.98 else "")

# Calibrated G* vs myopic G in the audits-win regime
r2 = results_a1["P2 audits win, honeypot audits"]
LAGs = r2["lB"][:, :, iA] - r2["lB"][:, :, iGstar]
m, se, _ = slope_stats(LAGs, N)
rep("")
rep.check("P2: calibrated G* (= C_0.50) is never selected against under (B): drift of ln mu(A)/mu(G*) "
          "= -Lam max(v - u, 0)", fmt(0.0), fmt(m, se), abs(m) < 1e-12)

# ============================================================================
# 2. Unpredictable errors: zero drift between A and G
# ============================================================================
rep("")
rep("=" * 78)
rep("2. Unpredictable vs predictable grader errors")
rep("=" * 78)
for pa, pb in [("P1 gaming pays, honeypot audits", "P1u = P1 + 30% unpredictable errors")]:
    for key, lab in [("LB", "(B)"), ("LD", "(D)")]:
        ma, sea, _ = slope_stats(results_a1[pa][key], N)
        mb, seb, _ = slope_stats(results_a1[pb][key], N)
        rep.check("adding 30%% unpredictable errors to P1 leaves the %s drift of ln mu(A)/mu(G) unchanged" % lab,
                  "difference 0", "P1 %s, P1u %s, difference %+.5f" % (fmt(ma, sea), fmt(mb, seb), mb - ma),
                  abs(mb - ma) < 3 * np.hypot(sea, seb) + 1e-9)
rU = results_a1["PU 30% unpredictable errors only"]
for key, lab in [("LB", "(B)"), ("LD", "(D-expected)")]:
    m, se, _ = slope_stats(rU[key], N)
    rep.check("PU (grader wrong on 30%% of episodes, unpredictably): %s drift" % lab, fmt(0.0), fmt(m, se), abs(m) < 1e-12)
# sampled versions for PU
eps, eps_u, a, h, s = PARAMS["PU 30% unpredictable errors only"]
pxT = px_table(THR, p_hat(eps, a, h, s), DELTA)
catU = draw_categories(np.random.default_rng(7), (S, N), eps, eps_u, a, h, s)
lDsU = op_D_sampled(catU, pxT, PRIOR, np.random.default_rng(8))
trU, _ = op_C(catU, pxT, PRIOR, np.random.default_rng(9), k=1, on_policy=True)
for lab, tr in [("(D-sampled)", lDsU[:, :, iA] - lDsU[:, :, iG]), ("(C-on k=1)", trU)]:
    m, se, sd = slope_stats(tr, N)
    rep.check("PU: %s drift (zero mean, nonzero noise)" % lab, fmt(0.0),
              fmt(m, se) + "   [sd of L_n - L_0: %.3f]" % sd, abs(m) < 3 * se + 1e-12)

# ============================================================================
# 3. The Goodhart threshold n*: first time ln mu(A)/mu(G) < 0, two dispositions
# ============================================================================
rep("")
rep("=" * 78)
rep("3. Goodhart threshold: first episode at which mu(G) > mu(A); dispositions {A, G}; no audits")
rep("   eps = 0.02, eps_u = 0, a = 0.  Predictions: (B) n* ~ ln O / (Lam eps); (D) n* ~ beta ln O / ((1-2delta) eps).")
rep("   framing.md R4 states n* ~ ln O / eps for (B); that is the (D) answer with beta = 1, or the")
rep("   expected (not typical) odds under (B).")
rep("=" * 78)
eps0 = 0.02
thr2 = np.array([0.0, 1.0])
nstar_rows = []
S3, N3 = 400, 4000
for delta in (0.01, 1e-6):
    Lm = lam(delta)
    pxT = px_table(thr2, p_hat(eps0, 0, 1, 0.5), delta)
    passT = pass_table(pxT)
    for O in (1e2, 1e4, 1e6):
        prior2 = np.array([O, 1.0]) / (O + 1)
        cat = draw_categories(np.random.default_rng(int(O) % 9973 + int(1e6 * delta)), (S3, N3), eps0, 0, 0, 1, 0.5)
        lB = op_B(cat, passT, prior2)
        L = lB[:, :, 0] - lB[:, :, 1]
        cross = np.where((L < 0).any(1), np.argmax(L < 0, axis=1), np.nan)
        pred = np.log(O) / (Lm * eps0)
        med, mse = median_se(cross)
        nstar_rows.append(("B", delta, O, pred, med, np.log(O) / eps0))
        # exact prediction: L flips after ceil(ln O / Lam) gaming events; events ~ Bernoulli(eps)
        kreq = int(np.floor(np.log(O) / Lm)) + 1
        med_exact = nbinom.median(kreq, eps0) + kreq
        rep.check("(B) delta=%g, O=%.0e: median n*" % (delta, O),
                  "ln O/(Lam eps) = %.0f; exact (flip at the %d-th gaming event, negative binomial) median = %.0f;"
                  " framing R4 ln O/eps = %.0f" % (pred, kreq, med_exact, np.log(O) / eps0),
                  "median %.0f +- %.1f (crossed in %d/%d seeds)" % (med, mse, np.isfinite(cross).sum(), S3),
                  abs(med - med_exact) <= 3 * mse + 1,
                  "drift formula is the large-O limit; with O small the flip needs a whole number of events")
    if delta == 0.01:
        for O in (1e2, 1e4, 1e6):
            prior2 = np.array([O, 1.0]) / (O + 1)
            cat = draw_categories(np.random.default_rng(31 + int(np.log10(O))), (S3, N3), eps0, 0, 0, 1, 0.5)
            lD = op_D_expected(cat, passT, prior2)
            L = lD[:, :, 0] - lD[:, :, 1]
            cross = np.where((L < 0).any(1), np.argmax(L < 0, axis=1), np.nan)
            pred = BETA * np.log(O) / ((1 - 2 * delta) * eps0)
            med, mse = median_se(cross)
            nstar_rows.append(("D", delta, O, pred, med, np.log(O) / eps0))
            kD = int(np.floor(np.log(O) * BETA / (1 - 2 * delta))) + 1
            medD = nbinom.median(kD, eps0) + kD
            rep.check("(D) beta=1, delta=%g, O=%.0e: median n*" % (delta, O),
                      "beta ln O/((1-2 delta) eps) = %.0f; exact (flip at the %d-th gaming event) median = %.0f"
                      % (pred, kD, medD),
                      "median %.0f +- %.1f (crossed in %d/%d seeds)" % (med, mse, np.isfinite(cross).sum(), S3),
                      abs(med - medD) < 3 * mse + 0.03 * medD)

# ============================================================================
# 4. (C-on, k=1) is bistable within one run; (B) is not
# ============================================================================
rep("")
rep("=" * 78)
rep("4. On-policy filtered SFT (C-on, k=1): bistable within a single run.  Dispositions {A, G}, P1.")
rep("   Mean-field separatrix: pX* = u/(u+v), m_A* = ((1-delta) - pX*)/(1-2 delta), L* = logit(m_A*).")
rep("=" * 78)
eps, eps_u, a, h, s = PARAMS["P1 gaming pays, honeypot audits"]
u, v = u_v(eps, a, h, s)
pX_star = u / (u + v)
mA_star = ((1 - DELTA) - pX_star) / (1 - 2 * DELTA)
L_star = np.log(mA_star / (1 - mA_star))
pxT2 = px_table(thr2, p_hat(eps, a, h, s), DELTA)
L0_grid = np.array([-2, -1, 0, 0.5, 1, 1.5, 2, 2.5, 3, 4, 5, 6, 8])
S4, N4 = 300, 6000
fracA, fracA_B, med_traj = [], [], {}
passT2 = pass_table(pxT2)
for j, L0 in enumerate(L0_grid):
    prior2 = np.array([sigmoid(L0), sigmoid(-L0)])
    cat = draw_categories(np.random.default_rng(100 + j), (S4, N4), eps, eps_u, a, h, s)
    tr, _ = op_C(cat, pxT2, prior2, np.random.default_rng(200 + j), k=1, on_policy=True)
    fracA.append(np.mean(tr[:, -1] > 0))
    med_traj[L0] = np.median(tr, axis=0)
    lB2 = op_B(cat, passT2, prior2)
    fracA_B.append(np.mean(lB2[:, -1, 0] > lB2[:, -1, 1]))
fracA, fracA_B = np.array(fracA), np.array(fracA_B)
rep("   u = %.4f, v = %.4f, separatrix L* = %.3f (prior odds A:G = %.2f)" % (u, v, L_star, np.exp(L_star)))
for L0, f in zip(L0_grid, fracA):
    rep("   L0 = %+5.1f  fraction of seeds ending with mu(A) > 1/2 after %d episodes: %.3f" % (L0, N4, f))
# where does fracA cross 1/2 (interpolated)?
idx = np.where(np.diff(np.sign(fracA - 0.5)) != 0)[0]
L_half = np.interp(0.5, fracA[idx[0]:idx[0] + 2], L0_grid[idx[0]:idx[0] + 2]) if len(idx) else np.nan
rep.check("(C-on, k=1) bistable: runs started above L* end at A, below L* end at G",
          "50%% point at L0 = L* = %.2f" % L_star, "50%% point at L0 = %.2f" % L_half,
          abs(L_half - L_star) < 1.0,
          "each event moves L by Lam = %.2f, so the switch is smeared over about one jump" % LAM)
rep.check("(B) with the same parameters and the same episodes is not bistable: D_B = Lam (v - u) > 0 from every start",
          "D_B = %+.4f per episode: fraction ending at A is 0 for every L0 <= 8 (n D_B = %.0f)" % (LAM * (v - u), N4 * LAM * (v - u)),
          "fractions ending at A by L0: " + " ".join("%.2f" % f for f in fracA_B), np.all(fracA_B == 0))

# ============================================================================
# 5. (D') vanilla policy gradient on mixture logits: protection linear in O
# ============================================================================
rep("")
rep("=" * 78)
rep("5. Vanilla REINFORCE on the mixture logits (D'), dispositions {A, G}, P1")
rep("   Mean dynamics: dL/dn = -2 eta mu_A mu_G Dr, Dr = (1-2delta)(v-u), so")
rep("   F(L) = e^L - e^-L + 2L decreases at rate 2 eta Dr and n* = F(ln O)/(2 eta Dr): linear in O,")
rep("   versus n* = beta ln O / Dr for the tilt (D).  eta = 2/beta matches the tilt's rate at L = 0.")
rep("   Two step sizes: eta = 0.25 (close to the mean-field limit) and eta = 2 (noisy).")
rep("=" * 78)
Dr = (1 - 2 * DELTA) * (v - u)
pg_rows = {}
S5 = 60
for ETA in (0.25, 2.0):
    pg_rows[ETA] = []
    for O in (3.0, 10.0, 30.0, 100.0, 300.0):
        prior2 = np.array([O, 1.0]) / (O + 1)
        LO = np.log(O)
        pred_pg = (O - 1 / O + 2 * LO) / (2 * ETA * Dr)
        pred_tilt = BETA * LO / Dr
        N5 = int(2.5 * pred_pg + 500)
        cat = draw_categories(np.random.default_rng(int(O) + 500), (S5, N5), eps, eps_u, a, h, s)
        tr, _ = op_PG(cat, pxT2, prior2, np.random.default_rng(int(O) + 600), ETA)
        cross = np.where((tr < 0).any(1), np.argmax(tr < 0, axis=1), np.nan)
        med, mse = median_se(cross)
        pg_rows[ETA].append((O, pred_pg, med, pred_tilt))
        rep.check("(D') eta = %g, O = %g: median n* (runs that never flip within %d episodes count as infinite)"
                  % (ETA, O, N5),
                  "%.0f  (tilt with beta = 2/eta would give %.0f)" % (pred_pg, 2 / ETA * pred_tilt),
                  "median %s +- %.0f (flipped in %d/%d seeds)" % ("%.0f" % med if np.isfinite(med) else "> %d" % N5,
                                                                mse, np.isfinite(cross).sum(), S5),
                  np.isfinite(med) and abs(med - pred_pg) < 3 * mse + 0.1 * pred_pg,
                  "" if ETA < 1 else "large noisy steps: the drift falls off like e^-L, so upward excursions cost more time than downward ones save")
# within-class odds under D'
thr3 = np.array([0.0, 0.05, 1.0])         # A, C_0.05 (in class A for P1), G
prior3 = np.array([0.5, 0.3, 0.2])
pxT3 = px_table(thr3, p_hat(eps, a, h, s), DELTA)
cat = draw_categories(np.random.default_rng(77), (100, 3000), eps, eps_u, a, h, s)
tr3, w3 = op_PG(cat, pxT3, prior3, np.random.default_rng(78), 2.0, record=(0, 1))
dchg = np.median(tr3[:, -1] - tr3[:, 0])
rep.check("(D') does NOT preserve odds within a proxy-equivalence class: ln mu(A)/mu(C_0.05) "
          "(identical behaviour) after 3000 episodes, prior 0.5:0.3:0.2 for A:C_0.05:G",
          "change 0 under (B), (C), (D); under (D') each logit moves by eta mu_theta (r_class - r_bar), so the larger"
          " member of a losing class loses faster (here class A is losing: L(A:C_0.05) should fall)",
          "median change %+.3f" % dchg, dchg < 0,
          "an observation beyond the note: plain PG on logits breaks proxy-equivalence (R2)")

# ============================================================================
# Figures
# ============================================================================
fig, axs = plt.subplots(1, 3, figsize=(14, 4.2))
cols = {"P1 gaming pays, honeypot audits": SERIES[1], "P2 audits win, honeypot audits": SERIES[0],
        "P3 random audits": SERIES[2]}
nn = np.arange(N + 1)
for ax, key, title, Dk in [(axs[0], "LB", "(B) Bayes on pass events", "D_B"),
                           (axs[1], "LD", "(D) exponential tilt, beta = 1", "D_D")]:
    for pname, c in cols.items():
        r = results_a1[pname]
        L = r[key]
        ax.fill_between(nn, np.quantile(L, .1, 0), np.quantile(L, .9, 0), color=c, alpha=0.15, lw=0)
        ax.plot(nn, L.mean(0), color=c, label=pname.split(",")[0] + " (sim. mean, 10-90%)")
        ax.plot(nn, L[:, 0].mean() - r[Dk] * nn, color=INK, lw=1.0, ls="--")
    ax.plot([], [], color=INK, lw=1.0, ls="--", label="prediction L0 - n D")
    ax.set_xlabel("episodes n")
    ax.set_ylabel("ln mu(A)/mu(G)")
    ax.set_title(title)
    ax.legend(loc="lower left")
ax = axs[2]
for pname, c, lab in [("P1 gaming pays, honeypot audits", SERIES[1], "P1: 2% predictable errors"),
                      ("P1u = P1 + 30% unpredictable errors", SERIES[6], "P1 + 30% unpredictable errors"),
                      ("PU 30% unpredictable errors only", SERIES[2], "30% unpredictable errors only")]:
    L = results_a1[pname]["LB"]
    ax.plot(nn, L.mean(0), color=c, label=lab, lw=2.0 if "only" in lab else 3.0 if "+" not in lab else 1.4)
ax.set_xlabel("episodes n")
ax.set_ylabel("ln mu(A)/mu(G), mean over 200 seeds")
ax.set_title("(B): only predictable errors move the odds")
ax.legend(loc="lower left")
fig.suptitle("(a) Log-odds of intent-follower vs gamer during one training run", color=INK)
fig.tight_layout()
fig.savefig(os.path.join(HERE, "fig_a1_drift.png"))
plt.close(fig)

# Figure a2: change in log-odds relative to A, by disposition, after N episodes (B)
fig, axs = plt.subplots(1, 2, figsize=(12, 4.5))
for ax, pname, title in zip(axs, ["P1 gaming pays, honeypot audits", "P2 audits win, honeypot audits"],
                            ["P1: gaming pays (v > u)", "P2: audits win (u > v)"]):
    r = results_a1[pname]
    lB = r["lB"]
    chg = (lB[:, -1, :] - lB[:, -1, [iA]]) - (np.log(PRIOR) - np.log(PRIOR[iA]))[None, :]
    med = np.median(chg, 0)
    q10, q90 = np.quantile(chg, 0.1, 0), np.quantile(chg, 0.9, 0)
    xs = np.concatenate([[0.0], T_GRID, [1.0]])
    order = [iA] + list(range(2, 2 + len(T_GRID))) + [iG]
    g = np.array([r["games"][i] for i in order])
    tt = np.linspace(0, 1, 400)
    ax.plot(tt, np.where(tt > r["ph"], r["D_B"] * N, 0.0), color=INK, lw=1.0, ls="--",
            label="prediction: 0 if t <= p_hat, else n D_B")
    for mask, c, lab in [(~g, SERIES[0], "behaves like A in training (t <= p_hat)"),
                         (g, SERIES[1], "games in training (t > p_hat)")]:
        ax.errorbar(xs[mask], med[order][mask], yerr=[med[order][mask] - q10[order][mask],
                                                      q90[order][mask] - med[order][mask]],
                    fmt="o", ms=8, color=c, ecolor=c, elinewidth=1, capsize=0, label=lab + ", median, 10-90%")
    ax.axvline(r["ph"], color=INK2, lw=1.0)
    ax.annotate("p_hat = %.2f" % r["ph"], (r["ph"], 0.93), xycoords=("data", "axes fraction"),
                xytext=(4, 0), textcoords="offset points", color=INK2, fontsize=8.5)
    ax.set_xlabel("disposition threshold t   (A at t = 0, G* at 0.5, myopic G at 1)")
    ax.set_ylabel("change in ln mu(theta)/mu(A), %d episodes" % N)
    ax.set_title(title)
handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="lower center", ncol=3)
fig.suptitle("(a) Proxy-equivalence under (B): two classes, odds frozen inside each (200 seeds)", color=INK)
fig.tight_layout(rect=(0, 0.08, 1, 1))
fig.savefig(os.path.join(HERE, "fig_a2_classes.png"))
plt.close(fig)

# Figure a3: C-on bistability
fig, axs = plt.subplots(1, 2, figsize=(12, 4))
ax = axs[0]
for j, L0 in enumerate([-1, 1, 1.5, 2, 3, 6]):
    c = SERIES[j % len(SERIES)]
    ax.plot(np.arange(N4 + 1), med_traj[L0], color=c, label="L0 = %g (median of %d seeds)" % (L0, S4))
    # mean-field ODE
    Lc, path = float(L0), [float(L0)]
    for _ in range(N4):
        pX = sigmoid(-Lc) * (1 - DELTA) + sigmoid(Lc) * DELTA
        Lc += LAM * (u * (1 - pX) - v * pX)
        path.append(Lc)
    ax.plot(np.arange(N4 + 1), path, color=c, lw=1.0, ls="--")
ax.axhline(L_star, color=INK2, lw=1.0)
ax.text(4300, L_star + 1.5, "separatrix L* = %.2f" % L_star, color=INK2, fontsize=8.5)
ax.plot([], [], color=INK, lw=1, ls="--", label="mean-field ODE")
ax.set_ylim(-60, 60)
ax.set_xlabel("episodes n")
ax.set_ylabel("ln mu(A)/mu(G)")
ax.set_title("(C-on, k = 1): the dominant disposition supplies its own evidence")
ax.legend(loc="lower right", ncol=1)
ax = axs[1]
ax.plot(L0_grid, fracA, color=SERIES[0], marker="o", ms=8, label="(C-on, k=1) simulation")
ax.axvline(L_star, color=INK, lw=1.0, ls="--", label="predicted separatrix L*")
ax.plot(L0_grid, fracA_B, color=SERIES[1], marker="s", ms=8, label="(B) on the same episodes: simulation")
ax.set_xlabel("initial log-odds L0 = ln mu0(A)/mu0(G)")
ax.set_ylabel("fraction of seeds ending with mu(A) > 1/2")
ax.set_title("Final outcome vs prior odds, P1 (%d episodes)" % N4)
ax.legend(loc="center right")
fig.tight_layout()
fig.savefig(os.path.join(HERE, "fig_a3_onpolicy_bistability.png"))
plt.close(fig)

# Figure a4: thresholds
fig, axs = plt.subplots(1, 2, figsize=(12, 4))
ax = axs[0]
rowsB = [r for r in nstar_rows if r[0] == "B" and r[1] == 0.01]
rowsD = [r for r in nstar_rows if r[0] == "D"]
rowsH = [r for r in nstar_rows if r[0] == "B" and r[1] == 1e-6]
lo = [np.log(r[2]) for r in rowsB]
ax.plot(lo, [r[4] for r in rowsB], color=SERIES[0], marker="o", ms=8, label="(B), delta = 0.01: simulated median")
ax.plot(lo, [r[3] for r in rowsB], color=SERIES[0], lw=1, ls="--", label="ln O / (Lam eps)")
ax.plot(lo, [r[4] for r in rowsD], color=SERIES[1], marker="s", ms=8, label="(D), beta = 1: simulated median")
ax.plot(lo, [r[3] for r in rowsD], color=SERIES[1], lw=1, ls="--", label="beta ln O / ((1-2 delta) eps)  (= framing R4's ln O / eps)")
ax.plot(lo, [r[4] for r in rowsH], color=SERIES[2], marker="^", ms=8, label="(B), delta = 1e-6: simulated median")
ax.set_xlabel("ln O (prior log-odds of A over G)")
ax.set_ylabel("episodes until mu(G) > mu(A)")
ax.set_title("Goodhart threshold, eps = 2%, no audits")
ax.legend(loc="upper left")
ax = axs[1]
for ETA, c in ((0.25, SERIES[6]), (2.0, SERIES[4])):
    rows = pg_rows[ETA]
    Os = [r[0] for r in rows]
    meds = [r[2] if np.isfinite(r[2]) else np.nan for r in rows]
    ax.loglog(Os, np.array(meds) * ETA, color=c, marker="o", ms=8, label="(D') vanilla PG, eta = %g: simulated median" % ETA)
ax.loglog(Os, [r[1] * 0.25 for r in pg_rows[0.25]], color=INK, lw=1, ls="--", label="mean field (e^L0 - e^-L0 + 2 L0)/(2 Dr)")
ax.loglog(Os, [r[3] * 0.25 * 8 for r in pg_rows[0.25]], color=SERIES[1], lw=2, label="(D) tilt: 2 ln O / Dr")
ax.set_ylabel("eta x episodes until mu(G) > mu(A)")
ax.set_xlabel("prior odds O")
ax.set_title("On-policy PG: prior odds protect linearly, not logarithmically")
ax.legend(loc="upper left")
fig.tight_layout()
fig.savefig(os.path.join(HERE, "fig_a4_thresholds.png"))
plt.close(fig)

rep("")
rep("runtime %.1f s" % (time.time() - T0))
rep.save()
