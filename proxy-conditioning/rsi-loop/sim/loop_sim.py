#!/usr/bin/env python3
"""(b) The loop: K generations, each trained under (B) with a grader built by the
previous generation (collusion raises the grader's predictable-error rate and
weakens audits).  Two regimes: continued training, and a fresh prior each
generation shifted by a data channel.  See loopcore.py for the model.

Run:  python3 loop_sim.py      (about 60 s; writes loop_sim_output.txt, fig_b*.png)
"""
import os
import time
import numpy as np
from scipy.stats import skellam, binom, poisson
from loopcore import (default_params, run_loop, mean_map_L, fixed_points_fresh, q_dagger, D_of_q,
                      train, data_channel, base_logw, grader, p_fail_fresh)
from toy import lam, normalize_log, style, plt, SERIES, INK, INK2, MUTED, Report, blue_cmap

HERE = os.path.dirname(os.path.abspath(__file__))
rep = Report(os.path.join(HERE, "loop_sim_output.txt"))
style()
T0 = time.time()

P = default_params()
LAM = lam(P["delta"])
XI = P["m"] * 2 * P["rho"] * np.log((1 + 2 * P["rho"]) / (1 - 2 * P["rho"]))

rep("=" * 78)
rep("(b) THE LOOP -- loop_sim.py")
rep("=" * 78)
rep("parameters: delta=%(delta)g s=%(s)g a0=%(a0)g eps_h=%(eps_h)g d_eps=%(d_eps)g n=%(n)d "
    "L_base=%(L_base)g m=%(m)d rho=%(rho)g K=%(K)d" % P)
rep("grader for generation k+1: eps = eps_h + q_k d_eps, a = a0 (1 - q_k); honeypot audits (h = 1)")
rep("Lam = %.4f; data-channel strength Xi = 2 m rho ln((1+2rho)/(1-2rho)) = %.3f nats" % (LAM, XI))
rep("Derived (two types A, G):  D(q) = Lam [(1 - a(q)) eps(q) - a(q)(1-s)]")
rep("   D(0) = %+.5f, D(1) = %+.5f per episode" % (D_of_q(0, P), D_of_q(1, P)))
rep("   continued regime: L_{k+1} = L_k - n D(q_k); fixed point only where D(q) = 0: q_dagger = %.4f" % q_dagger(P))
rep("   fresh regime: L_{k+1} = L_base + Xi (1 - 2 q_k) - n D(q_k) (+ noise); fixed points:")
FP = fixed_points_fresh(P)
for L, q, st in FP:
    rep("      L* = %+12.3f  q* = %.4g  %s" % (L, q, "stable" if st else "UNSTABLE (basin boundary)"))
q_u = [q for L, q, st in FP if not st]
q_u = q_u[0] if q_u else np.nan
L_u = [L for L, q, st in FP if not st]
L_u = L_u[0] if L_u else np.nan
rep("")

# ----------------------------------------------------------------------------
# 1. Explicit episodes vs category counts vs mean map, one generation
# ----------------------------------------------------------------------------
rep("1. One generation from q = 0.02 (fresh regime), n = 5000, 300 seeds")
p1 = dict(P, n=5000)
S1 = 300
rng = np.random.default_rng(1)
teacher = np.tile(np.log([0.98, 0.02, 1e-300]), (S1, 1))
q_t = np.full(S1, 0.02)
res = {}
for mode in ("episodes", "counts", "mean"):
    prior = data_channel(teacher, p1, S1, rng, mean=(mode == "mean"))
    lw = train(prior, q_t, p1, rng, mode=mode)
    res[mode] = lw[:, 0] - lw[:, 1]
eps1, a1 = grader(0.02, p1)
u1, v1 = a1 * (1 - p1["s"]), (1 - a1) * eps1
sd_pred = np.sqrt(p1["n"] * LAM ** 2 * (u1 + v1) + p1["m"] * (2 * np.log((1 + 2 * p1["rho"]) / (1 - 2 * p1["rho"]))) ** 2
                  * (0.5 + p1["rho"] * 0.96) * (0.5 - p1["rho"] * 0.96))
se_e, se_c = res["episodes"].std() / np.sqrt(S1), res["counts"].std() / np.sqrt(S1)
rep.check("explicit-episode and count-level simulations agree in distribution (ln mu(A)/mu(G) after training)",
          "mean %.2f (mean map), sd %.2f" % (res["mean"][0], sd_pred),
          "episodes: mean %.2f +- %.2f, sd %.2f;  counts: mean %.2f +- %.2f, sd %.2f" %
          (res["episodes"].mean(), se_e, res["episodes"].std(), res["counts"].mean(), se_c, res["counts"].std()),
          abs(res["episodes"].mean() - res["counts"].mean()) < 4 * np.hypot(se_e, se_c)
          and abs(res["episodes"].mean() - res["mean"][0]) < 4 * se_e
          and abs(res["episodes"].std() / sd_pred - 1) < 0.15 and abs(res["counts"].std() / sd_pred - 1) < 0.15)
rep("")

# ----------------------------------------------------------------------------
# 2. Trajectories from several initial conditions (explicit episodes)
# ----------------------------------------------------------------------------
rep("2. q_k trajectories, two types {A, G}, explicit episodes, 12 seeds per start, K = 25, n = 20000 and 2000")
Q0 = [0.005, 0.02, 0.03, 0.04, 0.06, 0.2]
S2 = 12
lam_r0 = np.log((1 + 2 * P["rho"]) / (1 - 2 * P["rho"]))
traj = {}
for n2 in (20000, 2000):
    p2 = dict(P, K=25, n=n2)
    fps2 = fixed_points_fresh(p2)
    qu2 = [q for L, q, st in fps2 if not st]
    qu2 = qu2[0] if qu2 else np.nan
    for regime in ("fresh", "continued"):
        for j, q0 in enumerate(Q0):
            qs, _ = run_loop(np.full(S2, q0), p2, regime,
                             np.random.default_rng(1000 + 10 * j + (regime == "fresh") + n2), mode="episodes")
            lo = run_loop.last_logodds
            qm, _ = run_loop(np.array([q0]), p2, regime, None, mode="mean")
            lom = run_loop.last_logodds[0]
            boundary = qu2 if regime == "fresh" else q_dagger(p2)
            traj[(n2, regime, q0)] = (lo, lom, boundary)
            pred = "A (q -> 0)" if q0 < boundary else "G (q -> 1)"
            fracG = np.mean(qs[:, -1] > 0.5)
            fracG1 = np.mean(qs[:, 1] > 0.5)
            e0, a0_ = grader(q0, p2)
            u0_, v0_ = a0_ * (1 - p2["s"]), (1 - a0_) * e0
            pz0 = 0.5 + p2["rho"] * (1 - 2 * q0)
            sd1 = np.sqrt(n2 * LAM ** 2 * (u0_ + v0_)
                          + (4 * lam_r0 ** 2 * p2["m"] * pz0 * (1 - pz0) if regime == "fresh" else 0.0))
            z = (lom[1] - np.log(boundary / (1 - boundary))) / sd1
            ok = (fracG1 < 0.5) == (q0 < boundary)
            notes = []
            if abs(z) < 1.5:
                notes.append("one-step mean lies %.1f noise sd from the boundary" % z)
            if regime == "fresh" and fracG > fracG1 + 0.15:
                notes.append("the aligned state leaks: noise-driven escapes accumulate over generations")
            note = "; ".join(notes)
            rep.check("n = %d, %s regime, q0 = %.3f: state after generation 1 and after 25 (mean-map boundary q = %.4f)"
                      % (n2, regime, q0, boundary), pred,
                      "fraction of seeds with q > 1/2: %.2f after one generation, %.2f after 25" % (fracG1, fracG),
                      ok, note)
rep("")

# ----------------------------------------------------------------------------
# 3. Bifurcation in eps_h and basin map over (eps_h, q0)
# ----------------------------------------------------------------------------
rep("3. Fixed points of the fresh-regime mean map vs eps_h, and the basin over (eps_h, q0)")
EPS = np.linspace(0.0, 0.06, 31)
bif = {}
for n in (2000, 20000):
    rows = []
    for e in EPS:
        rows.append(fixed_points_fresh(dict(P, eps_h=e, n=n)))
    bif[n] = rows
    nfp = [len(r) for r in rows]
    bist = [e for e, r in zip(EPS, rows) if len(r) == 3]
    rep("   n = %5d: number of fixed points by eps_h: %s" % (n, " ".join(str(k) for k in nfp)))
    if bist:
        rep("            bistable for eps_h in [%.3f, %.3f] (grid resolution 0.002)" % (min(bist), max(bist)))
    eps_star = P["a0"] * (1 - P["s"]) / (1 - P["a0"])
    rep("            D(0) = 0 at eps_h* = a0 (1-s)/(1-a0) = %.4f" % eps_star)
# basin map
Q0g = np.concatenate([np.linspace(0.0025, 0.1, 40)])
S3 = 30
EPSb = np.linspace(0.0, 0.05, 26)
basin = np.zeros((len(Q0g), len(EPSb)))
qu_curve = np.full(len(EPSb), np.nan)
agree, total = 0, 0
for jj, e in enumerate(EPSb):
    pe = dict(P, eps_h=e, K=15)
    fps = fixed_points_fresh(pe)
    qu = [q for L, q, st in fps if not st]
    qu_curve[jj] = qu[0] if qu else (np.nan)
    stable_q = [q for L, q, st in fps if st]
    q0v = np.repeat(Q0g, S3)
    qs, _ = run_loop(q0v, pe, "fresh", np.random.default_rng(3000 + jj), mode="counts")
    fA = (qs[:, -1] < 0.5).reshape(len(Q0g), S3).mean(1)
    basin[:, jj] = fA
    for ii, q0 in enumerate(Q0g):
        if qu:
            predA = q0 < qu[0]
        else:
            predA = min(stable_q) < 0.5
        agree += (fA[ii] > 0.5) == predA
        total += 1
rep.check("basin over (eps_h, q0) in [0, 0.05] x [0.0025, 0.1], fresh regime, n = %d: majority outcome of 30 seeds "
          "matches the mean-map prediction (A iff q0 < unstable fixed point q_u(eps_h))" % P["n"],
          "all %d cells" % total, "%d / %d cells agree" % (agree, total), agree >= 0.95 * total,
          "disagreements sit on the boundary, where the noise of one generation decides")
rep("")

# ----------------------------------------------------------------------------
# 4. Basin over (eps_h, n) from the human start (fresh regime)
# ----------------------------------------------------------------------------
rep("4. Failure probability over (eps_h, n) from the human start, fresh regime, K = 30, 40 seeds")
rep("   Semi-analytic prediction (loopcore.p_fail_fresh): escape from the A state when L_{k+1} < L_u (the")
rep("   unstable fixed point); L_{k+1} = L_base + lambda_rho (2Z - m) + Lam (N_caught - N_rewarded),")
rep("   Z ~ Bin(m, 1/2 + rho), N_caught - N_rewarded ~ Skellam(n u0, n v0); the G state is absorbing, so")
rep("   P(fail by K) = 1 - (1 - p_esc)^(K-1) (1 - P(L_K < 0)).")
EPSn = np.linspace(0.0, 0.05, 21)
NS = np.unique(np.round(np.logspace(2, 5, 16)).astype(int))
S4, K4 = 40, 30
sim_fail = np.zeros((len(NS), len(EPSn)))
pred_fail = np.zeros_like(sim_fail)
mean_fail = np.zeros_like(sim_fail)
lam_r = np.log((1 + 2 * P["rho"]) / (1 - 2 * P["rho"]))
zs = np.arange(P["m"] + 1)
pz = binom.pmf(zs, P["m"], 0.5 + P["rho"])
for ii, n in enumerate(NS):
    for jj, e in enumerate(EPSn):
        pe = dict(P, eps_h=e, n=int(n), K=K4)
        qs, _ = run_loop(None, pe, "fresh", np.random.default_rng(5000 + 100 * ii + jj), mode="counts", S=S4)
        sim_fail[ii, jj] = np.mean(qs[:, -1] > 0.5)
        qm, _ = run_loop(None, pe, "fresh", None, mode="mean", S=1)
        mean_fail[ii, jj] = float(qm[0, -1] > 0.5)
        pred_fail[ii, jj] = p_fail_fresh(pe, K4)
err = np.abs(sim_fail - pred_fail)
se = np.sqrt(np.maximum(pred_fail * (1 - pred_fail), 1 / S4) / S4)
rep.check("failure probability over the (eps_h, n) grid (%d cells): semi-analytic vs simulated" % err.size,
          "within 3 binomial SE in most cells", "max |diff| = %.3f, mean |diff| = %.3f, cells beyond 3 SE: %d"
          % (err.max(), err.mean(), int(np.sum(err > 3 * se + 0.02))),
          np.mean(err > 3 * se + 0.02) < 0.05)
rep.check("the deterministic mean map alone (no noise) predicts the failure region",
          "matches where p_esc is 0 or 1", "mean map disagrees with simulation (majority) in %d / %d cells"
          % (int(np.sum((sim_fail > 0.5) != (mean_fail > 0.5))), err.size),
          np.sum((sim_fail > 0.5) != (mean_fail > 0.5)) < 0.05 * err.size,
          "noise-driven escape at intermediate n is invisible to the mean map")
eps_star = P["a0"] * (1 - P["s"]) / (1 - P["a0"])
for n in (100, 1000, 10000, 100000):
    ii = int(np.argmin(np.abs(NS - n)))
    rep("   n = %6d: simulated P(fail by K=30) at eps_h = 0, 0.01, 0.02, 0.025, 0.03, 0.04: %s" %
        (NS[ii], " ".join("%.2f" % sim_fail[ii, int(np.argmin(np.abs(EPSn - e)))]
                          for e in (0, 0.01, 0.02, 0.025, 0.03, 0.04))))
rep("")

# ----------------------------------------------------------------------------
# 5. Hidden cautious schemers C: proxy-equivalent to A in training, collude as graders
# ----------------------------------------------------------------------------
rep("5. Three types {A, G, C_0.3}; C behaves like A in training (while p_hat >= 0.3) but colludes.")
rep("   Failure = misaligned mass (G + C) > 1/2 after 30 generations; human start; 30 seeds per point.")
rep("   Mean-map prediction: the A state survives iff the C mass at the A state stays below the basin boundary.")
rep("     continued, or fresh with C mimicking A's signature: C:A odds stay r (training cannot see C), so")
rep("       r* = q_u/(1 - q_u) (q_u = q_dagger = %.4f for continued, %.4f for fresh)." % (q_dagger(P), q_u))
rep("     fresh, C carrying the misaligned signature: the data channel from an aligned teacher multiplies C:A")
rep("       by exp(-Xi) on average, so r* = q_u/(1-q_u) exp(Xi (1 - 2 q_u)).")
rep("   Semi-analytic prediction with noise (fresh regime): per generation, the student's ln C:A =")
rep("       ln r + lambda_rho (m - 2 Z) (misaligned signature) or ln r (mimic), Z ~ Bin(m, p_z), and")
rep("       ln G:A = -L_base + lambda_rho (m - 2 Z) + Lam (N_rewarded - N_caught), Skellam; escape when the")
rep("       misaligned mass exceeds q_u; P(fail by K) = 1 - (1 - p_esc,1)(1 - p_esc)^(K-1).")
rep("   Continued regime: the mean-map step at r* (training noise accumulates into L, so escape is rare).")
qd = q_dagger(P)
lam_r = np.log((1 + 2 * P["rho"]) / (1 - 2 * P["rho"]))
zs = np.arange(P["m"] + 1)
pz = binom.pmf(zs, P["m"], 0.5 + P["rho"])


def fresh_escape(r, csig, q_teacher):
    """P(one fresh-regime generation ends with misaligned mass > q_u), given prior
    odds r of C:A, the signature mode, and the teacher's misaligned mass (which
    sets this generation's grader).  Sums over the data-channel count Z and the
    Skellam-distributed difference of rewarded and caught gaming events."""
    eps_t, a_t = grader(q_teacher, P)
    u_t, v_t = a_t * (1 - P["s"]), (1 - a_t) * eps_t
    pz_t = 0.5 + P["rho"] * (1 - 2 * q_teacher) if csig < 0 else 0.5 + P["rho"]
    pzz = binom.pmf(zs, P["m"], pz_t)
    tot = 0.0
    for z, w in zip(zs, pzz):
        shift = lam_r * (P["m"] - 2 * z)
        c = r * np.exp(shift if csig < 0 else 0.0)
        rhs = (q_u * (1 + c) - c) / (1 - q_u)
        if rhs <= 0:
            tot += w
            continue
        thr = (np.log(rhs) + P["L_base"] - shift) / LAM      # need K = N_rew - N_caught > thr
        tot += w * float(skellam.sf(np.floor(thr), P["n"] * v_t, P["n"] * u_t))
    return tot


RC = np.logspace(-3, 3, 25)
S5 = 30
hid = {}
for lab, regime, csig, qbd in [("continued", "continued", -1.0, qd),
                               ("fresh, C carries misaligned signature", "fresh", -1.0, q_u),
                               ("fresh, C mimics A's signature", "fresh", 1.0, q_u)]:
    lb = np.log(qbd / (1 - qbd))
    rstar = np.exp(lb + (XI * (1 - 2 * qbd) if csig < 0 and regime == "fresh" else 0.0))
    fails, finq, pred = [], [], []
    for jj, r in enumerate(RC):
        pe = dict(P, LC_base=np.log(r), c_sig=csig, K=30)
        qs, lw = run_loop(None, pe, regime, np.random.default_rng(7000 + jj + int(100 * csig) + (regime == "fresh")),
                          mode="counts", S=S5)
        fails.append(np.mean(qs[:, -1] > 0.5))
        finq.append(np.median(qs[:, -1]))
        if regime == "fresh":
            p1_ = fresh_escape(r, csig, 0.0)
            c_typ = r * np.exp(-XI if csig < 0 else 0.0)
            p_ = fresh_escape(r, csig, c_typ / (1 + c_typ))
            pred.append(1 - (1 - p1_) * (1 - p_) ** 29)
        else:
            pred.append(float(r > np.exp(lb)))
    fails, pred = np.array(fails), np.array(pred)
    hid[lab] = (fails, np.array(finq), rstar, pred)
    idx = np.where(fails > 0.5)[0]
    r_sim = RC[idx[0]] if len(idx) else np.nan
    idp = np.where(pred > 0.5)[0]
    r_pred = RC[idp[0]] if len(idp) else np.nan
    rep.check("%s: smallest prior odds C:A (grid ratio %.2f) at which the loop fails within 30 generations"
              % (lab, RC[1] / RC[0]),
              "mean map r* = %.4g; with noise: first grid point with P(fail) > 1/2 at r = %.4g"
              % (rstar, r_pred),
              "first grid point with failure > 1/2: r = %.4g; max |simulated - predicted P(fail)| over the grid = %.2f"
              % (r_sim, np.max(np.abs(fails - pred))),
              (not np.isnan(r_sim)) and r_sim == r_pred,
              ("mean map is off by a factor %.0f here: noise in the data channel, not its mean, sets the threshold"
               % (rstar / r_sim)) if (regime == "fresh" and csig < 0 and not np.isnan(r_sim)) else
              ("C's floor pushes D(q) toward 0, so training noise lets G escape below r*"
               if regime == "fresh" else ""))
    rep("   median misaligned mass q_30 by r: " + " ".join("%.3g" % x for x in finq))
rep("")

# ============================================================================
# Figures
# ============================================================================
fig, axs = plt.subplots(2, 2, figsize=(13, 8.4), sharex=True)
for row, n2 in enumerate((20000, 2000)):
    for col, (regime, title) in enumerate([("fresh", "fresh prior + data channel"), ("continued", "continued training")]):
        ax = axs[row, col]
        for j, q0 in enumerate(Q0):
            lo, lom, bnd = traj[(n2, regime, q0)]
            c = SERIES[j]
            kk = np.arange(lo.shape[1])
            for srow in lo:
                ax.plot(kk, srow, color=c, lw=0.8, alpha=0.5)
            ax.plot(kk, lom, color=c, lw=2.2, ls="--", label="q0 = %g" % q0)
        ax.axhline(np.log(bnd / (1 - bnd)), color=INK2, lw=1.0)
        ax.annotate("basin boundary q = %.4f" % bnd, (0.6, np.log(bnd / (1 - bnd))), xycoords=("axes fraction", "data"),
                    xytext=(0, 4), textcoords="offset points", color=INK2, fontsize=8.5)
        ax.set_yscale("symlog", linthresh=10)
        ax.set_ylim(-3e4, 3e4)
        ax.set_title("n = %d, %s" % (n2, title))
        if row == 1:
            ax.set_xlabel("generation k")
        if col == 0:
            ax.set_ylabel("misaligned log-odds ln(q/(1-q)), symlog")
handles, labels = axs[0, 0].get_legend_handles_labels()
handles += [plt.Line2D([], [], color=INK, lw=0.8), plt.Line2D([], [], color=INK, lw=2.2, ls="--")]
labels += ["thin: 12 simulated seeds (explicit episodes)", "dashed: mean-map prediction"]
fig.legend(handles, labels, loc="lower center", ncol=8, fontsize=8)
fig.suptitle("(b) Loop trajectories: eps_h = %.2f, d_eps = %.2f, a0 = %.2f, L_base = %g, Xi = %.1f"
             % (P["eps_h"], P["d_eps"], P["a0"], P["L_base"], XI), color=INK)
fig.tight_layout(rect=(0, 0.05, 1, 1))
fig.savefig(os.path.join(HERE, "fig_b1_trajectories.png"))
plt.close(fig)

fig, axs = plt.subplots(1, 2, figsize=(13, 4.6))
ax = axs[0]
for n, c in ((2000, SERIES[1]), (20000, SERIES[0])):
    for e, rows in zip(EPS, bif[n]):
        for L, q, st in rows:
            qq = np.clip(q, 1e-6, 1 - 1e-6)
            if st:
                ax.plot(e, qq, "o", color=c, ms=7)
            else:
                ax.plot(e, qq, "o", mfc="none", mec=c, ms=7, mew=1.5)
    ax.plot([], [], "o", color=c, ms=7, label="n = %d: stable" % n)
    ax.plot([], [], "o", mfc="none", mec=c, ms=7, mew=1.5, label="n = %d: unstable (basin boundary)" % n)
ax.axvline(eps_star, color=INK2, lw=1.0)
ax.annotate("D(0) = 0", (eps_star, 0.5), xytext=(4, 0), textcoords="offset points", color=INK2, fontsize=8.5)
ax.set_yscale("logit")
ax.set_ylim(1e-6, 1 - 1e-6)
ax.set_xlabel("human grader error eps_h")
ax.set_ylabel("fixed point q* (logit scale, clipped)")
ax.set_title("Fixed points of the fresh-regime mean map")
ax.legend(loc="center right")
ax = axs[1]
im = ax.imshow(basin, origin="lower", aspect="auto", cmap=blue_cmap(), vmin=0, vmax=1,
               extent=[EPSb[0] - 0.001, EPSb[-1] + 0.001, Q0g[0] - 0.00125, Q0g[-1] + 0.00125])
ax.plot(EPSb, qu_curve, color=SERIES[1], lw=2, label="predicted boundary q_u(eps_h)")
ax.set_ylim(Q0g[0] - 0.00125, Q0g[-1] + 0.00125)
ax.set_xlabel("human grader error eps_h")
ax.set_ylabel("initial misaligned mass q0")
ax.set_title("Fraction of 30 seeds ending aligned (K = 15, n = %d)" % P["n"])
cb = fig.colorbar(im, ax=ax)
cb.set_label("fraction ending with q < 1/2")
ax.legend(loc="upper right")
ax.grid(False)
fig.tight_layout()
fig.savefig(os.path.join(HERE, "fig_b2_bifurcation_basin.png"))
plt.close(fig)

fig, axs = plt.subplots(1, 2, figsize=(13, 4.6), sharey=True)
for ax, M, title in [(axs[0], sim_fail, "Simulated (40 seeds)"), (axs[1], pred_fail, "Semi-analytic prediction")]:
    im = ax.pcolormesh(EPSn, NS, M, cmap=blue_cmap(), vmin=0, vmax=1, shading="nearest")
    ax.set_yscale("log")
    ax.contour(EPSn, NS, mean_fail, levels=[0.5], colors=[SERIES[1]], linewidths=2)
    ax.axvline(eps_star, color=INK2, lw=1.0)
    ax.set_xlabel("human grader error eps_h")
    ax.set_title(title + ": P(misaligned by generation 30)")
    ax.grid(False)
axs[0].set_ylabel("episodes per generation n")
axs[0].plot([], [], color=SERIES[1], lw=2, label="mean map: failure region boundary")
axs[0].plot([], [], color=INK2, lw=1, label="eps_h* where D(0) = 0")
fig.legend(loc="lower center", ncol=2, bbox_to_anchor=(0.45, -0.06))
cb = fig.colorbar(im, ax=axs, shrink=0.9)
cb.set_label("failure probability")
fig.suptitle("(b) Basin of the aligned state over (eps_h, n), human start, fresh regime", color=INK)
fig.savefig(os.path.join(HERE, "fig_b3_basin_eps_n.png"), bbox_inches="tight")
plt.close(fig)

fig, ax = plt.subplots(figsize=(9, 4.6))
for (lab, (fails, finq, rstar, pred)), c in zip(hid.items(), (SERIES[0], SERIES[1], SERIES[2])):
    ax.semilogx(RC, fails, color=c, marker="o", ms=7, lw=0, label=lab + ": simulated")
    ax.semilogx(RC, pred, color=c, lw=1.5, ls="--")
    ax.axvline(rstar, color=c, lw=1.0)
ax.plot([], [], color=INK, lw=1.5, ls="--", label="prediction (with data-channel noise)")
ax.plot([], [], color=INK, lw=1.0, label="mean-map threshold r*")
ax.set_xlabel("prior odds of hidden cautious schemer C_0.3 vs A")
ax.set_ylabel("P(misaligned mass > 1/2 at generation 30)")
ax.set_title("(b) Hidden schemers pass every training check but break the loop through collusion")
ax.legend(loc="center right", fontsize=8)
fig.tight_layout()
fig.savefig(os.path.join(HERE, "fig_b4_hidden_schemers.png"))
plt.close(fig)

rep("runtime %.1f s" % (time.time() - T0))
rep.save()
