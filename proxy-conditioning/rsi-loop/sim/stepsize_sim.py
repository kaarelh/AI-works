#!/usr/bin/env python3
"""(c) Step size.  A fixed capability range (normalised to 1) is crossed in N = 1/g
generations.  The human grader's predictable-error rate grows with the capability
gap: eps_h(g) = eps_0 + kappa * g.  Each generation is trained under (B) with a
grader built by the previous one (collusion as in loopcore.py), human start.

Run:  python3 stepsize_sim.py      (about 30 s; writes stepsize_sim_output.txt, fig_c*.png)
"""
import os
import time
import numpy as np
from loopcore import default_params, run_loop, p_fail_fresh, p_fail_continued, D_of_q
from toy import style, plt, SERIES, INK, INK2, Report

HERE = os.path.dirname(os.path.abspath(__file__))
rep = Report(os.path.join(HERE, "stepsize_sim_output.txt"))
style()
T0 = time.time()

KAPPA = 0.02
EPS0 = (0.0, 0.01, 0.02)
NGEN = np.array([1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 25, 32, 40, 50, 64])
G = 1.0 / NGEN
S = 200
P = default_params()
eps_star = P["a0"] * (1 - P["s"]) / (1 - P["a0"])

rep("=" * 78)
rep("(c) STEP SIZE -- stepsize_sim.py")
rep("=" * 78)
rep("capability range 1 crossed in N = 1/g generations; eps_h(g) = eps_0 + kappa g, kappa = %.3f" % KAPPA)
rep("other parameters as in loop_sim.py: a0=%(a0)g s=%(s)g d_eps=%(d_eps)g delta=%(delta)g L_base=%(L_base)g "
    "m=%(m)d rho=%(rho)g" % P)
rep("two types {A, G}, operator (B), human start, %d seeds per point; failure = q_N > 1/2" % S)
rep("")
rep("Predictions (derived here):")
rep("  mean map: the aligned state exists iff D(0) < 0, i.e. eps_h(g) < eps* = a0(1-s)/(1-a0) = %.4f," % eps_star)
rep("     so g* = (eps* - eps_0)/kappa; deterministic failure iff g > g*.")
rep("  fresh regime, with noise: each generation leaves the aligned basin independently with p_esc(g)")
rep("     (loopcore.p_fail_fresh), so P(fail) ~ 1 - (1 - p_esc(g))^(1/g).  If p_esc(eps_0) > 0, then")
rep("     P(fail) -> 1 as g -> 0 and there is an interior optimum (roughly where g p_esc'(g)/p_esc(g) = 1);")
rep("     if p_esc(eps_0) is negligible, small steps are safe.")
rep("  continued regime: the log-odds is a random walk with drift -n D(0) per generation, absorbed at")
rep("     logit(1 - q_dagger); smaller steps add more generations of positive drift, so P(fail) is")
rep("     non-increasing as g -> 0 while g < g* (loopcore.p_fail_continued, exact DP).")
rep("")

configs = [("fresh", 2000), ("fresh", 20000), ("continued", 2000)]
results = {}
for regime, n in configs:
    for e0 in EPS0:
        sim, pred, medlo = [], [], []
        for j, (N, g) in enumerate(zip(NGEN, G)):
            p = dict(P, eps_h=e0 + KAPPA * g, n=n, K=int(N))
            qs, _ = run_loop(None, p, regime, np.random.default_rng(int(1e5 * e0) + 7 * j + n + (regime == "fresh")),
                             mode="counts", S=S)
            lo = run_loop.last_logodds[:, -1]
            sim.append(np.mean(qs[:, -1] > 0.5))
            medlo.append(np.median(lo))
            if regime == "fresh":
                pred.append(p_fail_fresh(p, int(N)))
            else:
                pred.append(p_fail_continued(p, int(N)))
        sim, pred = np.array(sim), np.array(pred)
        results[(regime, n, e0)] = (sim, pred, np.array(medlo))
        se = np.sqrt(np.maximum(pred * (1 - pred), 1.0 / S) / S)
        bad = np.abs(sim - pred) > 3 * se + 0.02
        gstar = (eps_star - e0) / KAPPA
        rep("-" * 78)
        rep("%s regime, n = %d, eps_0 = %.3f  (mean-map threshold g* = %.3f)" % (regime, n, e0, gstar))
        rep("   g       : " + " ".join("%6.3f" % g for g in G))
        rep("   P(fail) : " + " ".join("%6.3f" % x for x in sim) + "   simulated")
        rep("   P(fail) : " + " ".join("%6.3f" % x for x in pred) + "   predicted")
        rep.check("%s, n = %d, eps_0 = %.3f: failure probability against g (%d step sizes)" % (regime, n, e0, len(G)),
                  "semi-analytic curve above", "max |sim - pred| = %.3f; points beyond 3 SE + 0.02: %d"
                  % (np.max(np.abs(sim - pred)), bad.sum()), bad.sum() <= 1)
        ibest = int(np.argmin(sim))
        rep("   best simulated step size: g = %.3f (N = %d), P(fail) = %.3f; predicted best g = %.3f, P(fail) = %.3f"
            % (G[ibest], NGEN[ibest], sim[ibest], G[int(np.argmin(pred))], pred.min()))

# Shape claims
rep("")
rep("=" * 78)
rep("Shape of P(fail) against g")
rep("=" * 78)
for e0 in EPS0:
    sim_f2, pred_f2, _ = results[("fresh", 2000, e0)]
    sim_c, _, _ = results[("continued", 2000, e0)]
    gstar = (eps_star - e0) / KAPPA

    def ushape(x):
        return (x[-1] > x.min() + 0.05) and (x[0] > x.min() + 0.05)
    rep.check("fresh, n = 2000, eps_0 = %.2f: is P(fail) U-shaped in g (too many small steps fail through noise,"
              " too few large steps through grader error)?" % e0,
              "U-shaped: %s (predicted P(fail) at g = 1/64: %.2f, min %.2f at g = %.3f, at g = 1: %.2f)"
              % ("yes" if ushape(pred_f2) else "no", pred_f2[-1], pred_f2.min(), G[int(np.argmin(pred_f2))], pred_f2[0]),
              "U-shaped: %s (P(fail) at g = 1/64: %.2f, min %.2f at g = %.3f, at g = 1: %.2f)"
              % ("yes" if ushape(sim_f2) else "no", sim_f2[-1], sim_f2.min(), G[int(np.argmin(sim_f2))], sim_f2[0]),
              ushape(pred_f2) == ushape(sim_f2))
    rep.check("continued, n = 2000, eps_0 = %.2f: P(fail) non-increasing as g decreases below g* = %.2f" % (e0, gstar),
              "monotone", "P(fail) by g (large to small): " + " ".join("%.2f" % x for x in sim_c),
              all(sim_c[i + 1] <= sim_c[i] + 0.06 for i in range(len(G) - 1) if G[i] < gstar))

# ============================================================================
# Figures
# ============================================================================
fig, axs = plt.subplots(1, 3, figsize=(15, 4.4), sharey=True)
for ax, (regime, n) in zip(axs, configs):
    for e0, c in zip(EPS0, (SERIES[0], SERIES[1], SERIES[2])):
        sim, pred, _ = results[(regime, n, e0)]
        ax.semilogx(G, sim, "o", color=c, ms=7, label="eps_0 = %.2f: simulated" % e0)
        ax.semilogx(G, pred, color=c, lw=1.5, ls="--")
        gstar = (eps_star - e0) / KAPPA
        if gstar < 1:
            ax.axvline(gstar, color=c, lw=1.0)
    ax.set_xlabel("capability step per generation g  (N = 1/g generations)")
    ax.set_title("%s regime, n = %d per generation" % (regime, n))
axs[0].set_ylabel("P(misaligned at the end)")
axs[0].plot([], [], color=INK, lw=1.5, ls="--", label="semi-analytic prediction")
axs[0].plot([], [], color=INK, lw=1.0, label="mean-map threshold g*")
axs[0].legend(loc="center left", fontsize=8)
fig.suptitle("(c) Step size: eps_h(g) = eps_0 + %.2f g, capability range 1, %d seeds per point" % (KAPPA, S),
             color=INK)
fig.tight_layout()
fig.savefig(os.path.join(HERE, "fig_c1_stepsize.png"))
plt.close(fig)

rep("")
rep("runtime %.1f s" % (time.time() - T0))
rep.save()
