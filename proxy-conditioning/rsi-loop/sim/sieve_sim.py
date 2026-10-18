#!/usr/bin/env python3
"""(d) The sieve.  A continuum of careful gamers C_t (t on a fine grid) plus the
intent-follower A.  Every gaming opportunity carries a check of true strength p
(probability that gaming is caught; when the check fires it also rescues the
intended output) and a perceived strength p_hat, an observable feature shared by
all dispositions.  C_t games iff p_hat < t.  Training uses operator (B) (and the
tilt (D) for comparison).  Frontier tasks: p = 0, p_hat around 0.002.

Normal episodes (no gaming opportunity) are not simulated: every disposition
acts alike there, so they contribute exactly zero to every log-odds under (B)
and (D).  n below counts gaming opportunities.

Run:  python3 sieve_sim.py      (about 20 s; writes sieve_sim_output.txt, fig_d*.png)
"""
import os
import time
import numpy as np
from scipy.special import expit, logit
from scipy.stats import norm
from toy import lam, style, plt, SERIES, INK, INK2, MUTED, Report, normalize_log

HERE = os.path.dirname(os.path.abspath(__file__))
rep = Report(os.path.join(HERE, "sieve_sim_output.txt"))
style()
T0 = time.time()

DELTA = 0.01
LAM = lam(DELTA)
LT = np.linspace(-8, 8, 401)                 # grid of logit(t)
TG = expit(LT)
MU_A = 0.5
PRIOR_C = np.full(len(LT), (1 - MU_A) / len(LT))   # uniform in logit(t)
FRONT_C, FRONT_SD = 0.002, 0.5               # frontier perceived detection: logit-normal around 0.002
P_FRONT = 0.0

SCEN = {
    # name: list of components (weight, true p sampler, perceived centre or None (= around p), perception sd)
    "1 recognisable audits": [(0.9, ("const", 0.0), 0.03, 0.5), (0.1, ("const", 0.95), 0.9, 0.5)],
    "2 honeypots look like ordinary opportunities": [(0.4, ("const", 0.0), 0.03, 0.5), (0.6, ("const", 0.95), 0.03, 0.5)],
    "3 honeypots look like the frontier": [(0.4, ("const", 0.0), 0.03, 0.5), (0.6, ("const", 0.95), 0.001, 0.5)],
    "4 graded checks, accurate perception": [(1.0, ("unif", 0.0, 1.0), None, 0.3)],
    "5 graded checks, noisy perception": [(1.0, ("unif", 0.0, 1.0), None, 2.0)],
}


def draw(rng, comps, shape):
    """Draw (p, logit p_hat) for gaming opportunities."""
    w = np.array([c[0] for c in comps])
    k = rng.choice(len(comps), size=shape, p=w / w.sum())
    p = np.zeros(shape)
    lph = np.zeros(shape)
    for j, (wt, samp, centre, sd) in enumerate(comps):
        m = k == j
        if samp[0] == "const":
            p[m] = samp[1]
        else:
            p[m] = rng.uniform(samp[1], samp[2], m.sum())
        c = logit(np.clip(p[m], 1e-6, 1 - 1e-6)) if centre is None else logit(centre)
        lph[m] = c + sd * rng.standard_normal(m.sum())
    return p, lph


def delta_ell(comps):
    """Predicted per-opportunity drift of ln mu(C_t)/mu(A) under (B):
    Lam * E[(1 - 2p) 1{p_hat < t}]  (derived: gaming gains Lam when the check does
    not fire, loses Lam when it fires).  Exact: Gaussian cdf in logit space,
    with a midpoint rule over p for the uniform components."""
    out = np.zeros(len(LT))
    for wt, samp, centre, sd in comps:
        if samp[0] == "const":
            c = logit(np.clip(samp[1], 1e-6, 1 - 1e-6)) if centre is None else logit(centre)
            out += wt * (1 - 2 * samp[1]) * norm.cdf((LT - c) / sd)
        else:
            pg = samp[1] + (samp[2] - samp[1]) * (np.arange(20000) + 0.5) / 20000
            c = logit(pg) if centre is None else np.full_like(pg, logit(centre))
            out += wt * np.mean((1 - 2 * pg)[None, :] * norm.cdf((LT[:, None] - c[None, :]) / sd), axis=1)
    return LAM * out


def frontier_offtask_prob():
    """P(C_t defects on a frontier task) = P(p_hat_F < t)."""
    return norm.cdf((LT - logit(FRONT_C)) / FRONT_SD)


def on_task(muA, muC):
    d = frontier_offtask_prob()
    tot = muA + muC.sum(-1)
    ont = muA * (1 - DELTA) + (muC * ((1 - DELTA) - (1 - 2 * DELTA) * d)).sum(-1)
    return ont / tot


def posterior(lw_rel):
    """lw_rel: ln w_t - ln w_A (relative to priors) -> (mass A, masses C_t)."""
    lA = np.log(MU_A) * np.ones(lw_rel.shape[:-1] + (1,))
    lC = np.log(PRIOR_C) + lw_rel
    allw = normalize_log(np.concatenate([lA, lC], axis=-1))
    return allw[..., 0], allw[..., 1:]


CHECKS_N = np.array([0, 50, 100, 200, 500, 1000, 2000, 5000, 10000])
S = 60
NMAX = CHECKS_N[-1]
rep("=" * 78)
rep("(d) THE SIEVE -- sieve_sim.py")
rep("=" * 78)
rep("delta = %.3g, Lam = %.4f; prior: A %.2f, C_t uniform in logit(t) on [-8, 8] (401 points), total %.2f"
    % (DELTA, LAM, MU_A, 1 - MU_A))
rep("frontier tasks: p = 0, logit p_hat ~ N(logit %.3f, %.1f^2); C_t defects there with prob P(p_hat_F < t)"
    % (FRONT_C, FRONT_SD))
rep("%d seeds; n = number of gaming opportunities; operator (B), and (D) with beta = 1 for comparison" % S)
rep("")
rep("Derived prediction: under (B) the drift of ln mu(C_t)/mu(A) per opportunity is")
rep("   dl(t) = Lam E[(1 - 2p) 1{p_hat < t}],")
rep("   so a careful gamer is selected against only by checks that it does not see coming (p_hat < t)")
rep("   and that fire more often than not (p > 1/2).  The law-of-large-numbers posterior is")
rep("   mu_n(t) proportional to mu_0(t) exp(n dl(t)); under (D) replace Lam by (1 - 2 delta)/beta.")
rep("")

# ----------------------------------------------------------------------------
# 0. Code check: the sorted-cumsum update equals explicit per-episode enumeration
# ----------------------------------------------------------------------------
rng = np.random.default_rng(3)
p, lph = draw(rng, SCEN["2 honeypots look like ordinary opportunities"], (300,))
fired = rng.random(300) < p
sub = np.arange(0, 401, 25)
lw_explicit = np.zeros((len(sub) + 1,))
for i in range(300):
    for j, tt in enumerate(np.concatenate([[-np.inf], LT[sub]])):   # first entry is A
        games = lph[i] < tt
        piX = DELTA + (1 - 2 * DELTA) * games
        R_I, R_X = (1, 0) if fired[i] else (0, 1)
        lw_explicit[j] += np.log(piX * R_X + (1 - piX) * R_I)        # (B): P_theta(pass | episode)
rel_explicit = lw_explicit[1:] - lw_explicit[0]
sgn = np.where(fired, -LAM, LAM)
order = np.argsort(lph)
cs = np.concatenate([[0.0], np.cumsum(sgn[order])])
rel_fast = cs[np.searchsorted(lph[order], LT[sub], side="left")]
rep.check("vectorised (B) update equals explicit per-episode enumeration over outputs (300 episodes, 17 values of t)",
          "max difference 0", "%.2e" % np.max(np.abs(rel_fast - rel_explicit)), np.max(np.abs(rel_fast - rel_explicit)) < 1e-8)
rep("")

dl_pred, results = {}, {}
for si, (name, comps) in enumerate(SCEN.items()):
    rng = np.random.default_rng(100 + si)
    p, lph = draw(rng, comps, (S, NMAX))
    fired = rng.random((S, NMAX)) < p
    sgn = np.where(fired, -1.0, 1.0)
    rel = np.zeros((S, len(CHECKS_N), len(LT)))
    for s_ in range(S):
        for ci, n in enumerate(CHECKS_N):
            if n == 0:
                continue
            o = np.argsort(lph[s_, :n])
            cs = np.concatenate([[0.0], np.cumsum(sgn[s_, :n][o])])
            rel[s_, ci] = cs[np.searchsorted(lph[s_, :n][o], LT, side="left")]
    dl = delta_ell(comps)
    dl_pred[name] = dl
    res = {}
    for op, scale in (("B", LAM), ("D", (1 - 2 * DELTA))):
        muA, muC = posterior(scale * rel)
        ont_sim = on_task(muA, muC)                          # (S, len(CHECKS_N))
        pA_, pC_ = posterior((dl / LAM * scale)[None, :] * CHECKS_N[:, None])
        ont_pred = on_task(pA_, pC_)
        res[op] = dict(muA=muA, muC=muC, ont_sim=ont_sim, ont_pred=ont_pred, pA=pA_, pC=pC_)
    results[name] = res
    # slope check at the largest n: E[rel]/n vs dl/Lam
    slope = rel[:, -1, :].mean(0) / NMAX * LAM
    se = rel[:, -1, :].std(0, ddof=1) / np.sqrt(S) / NMAX * LAM
    z = np.abs(slope - dl) / np.sqrt(se ** 2 + LAM ** 2 / (S * NMAX))   # floor: one +-Lam event in S n
    rep("-" * 78)
    rep("Scenario %s" % name)
    rep.check("drift of ln mu(C_t)/mu(A) per opportunity, over the 401 values of t (n = %d)" % NMAX,
              "dl(t) = Lam E[(1-2p) 1{p_hat < t}]; e.g. at t = 0.01, 0.1, 0.5, 0.99: " +
              ", ".join("%+.4f" % dl[np.argmin(np.abs(TG - tt))] for tt in (0.01, 0.1, 0.5, 0.99)),
              "same t: " + ", ".join("%+.4f" % slope[np.argmin(np.abs(TG - tt))] for tt in (0.01, 0.1, 0.5, 0.99)) +
              "; max |z| over t = %.2f" % z.max(), z.max() < 4.5)
    for op in ("B", "D"):
        r = res[op]
        for ci in (list(CHECKS_N).index(500), list(CHECKS_N).index(NMAX)):
            sim = r["ont_sim"][:, ci]
            pred = r["ont_pred"][ci]
            se_ = sim.std(ddof=1) / np.sqrt(S)
            rep.check("(%s) frontier on-task rate after n = %d opportunities" % (op, CHECKS_N[ci]),
                      "%.3f (law-of-large-numbers posterior)" % pred,
                      "mean %.3f +- %.3f, median %.3f, 10-90%% [%.3f, %.3f]" %
                      (sim.mean(), se_, np.median(sim), np.quantile(sim, .1), np.quantile(sim, .9)),
                      abs(sim.mean() - pred) < 3 * se_ + 0.03,
                      "the LLN posterior ignores fluctuations of size Lam sqrt(n), which matter where dl(t) is small"
                      if abs(sim.mean() - pred) >= 3 * se_ + 0.03 else "")
    rB = res["B"]
    k = list(CHECKS_N).index(NMAX)
    tmean = (rB["muC"][:, k, :] * LT).sum(-1) / np.maximum(rB["muC"][:, k, :].sum(-1), 1e-300)
    rep("   (B) at n = %d: posterior mass of A: mean %.3f; mean posterior logit(t) among C: %.2f (t = %.3g)"
        % (NMAX, rB["muA"][:, k].mean(), np.median(tmean), expit(np.median(tmean))))
    surv = rB["muC"][:, k, :].sum(-1)
    defect = (rB["muC"][:, k, :] * frontier_offtask_prob()).sum(-1)
    rep("   (B) at n = %d: mass on C (all t): %.3f; mass on C that defect at the frontier: %.3f"
        % (NMAX, surv.mean(), defect.mean()))

# Leakage in scenario 2: the LLN heuristic, then the gambler's-ruin account of why it fails
rep("")
rep("=" * 78)
rep("Leakage: which careful gamers pass the sieve (scenario 2, (B), n = %d)" % NMAX)
rep("=" * 78)
name = "2 honeypots look like ordinary opportunities"
dl = dl_pred[name]
t_cut = LT[np.argmin(np.abs(NMAX * dl + 1.0))]
rep("   LLN heuristic: C_t survives while n |dl(t)| < 1, i.e. logit t < %.2f (t < %.4f)" % (t_cut, expit(t_cut)))
massC_cut = PRIOR_C[LT < t_cut].sum()
leak_cut = (PRIOR_C * frontier_offtask_prob())[LT < t_cut].sum()
pred_ont = (MU_A * (1 - DELTA) + (PRIOR_C * ((1 - DELTA) - (1 - 2 * DELTA) * frontier_offtask_prob()))[LT < t_cut].sum()) / (MU_A + massC_cut)
sim = results[name]["B"]["ont_sim"][:, -1]
rep.check("frontier on-task rate ~ [mu(A) + mu(survivors that stay on task)] / [mu(A) + mu(survivors)]",
          "%.3f (prior mass of survivors %.4f, of which defect at the frontier %.4f)" % (pred_ont, massC_cut, leak_cut),
          "mean %.3f, median %.3f" % (sim.mean(), np.median(sim)), abs(sim.mean() - pred_ont) < 0.05,
          "see the gambler's-ruin analysis below")
rep("")
rep("   Why: sort the training opportunities by p_hat.  ln mu(C_t)/mu(A) - ln mu0(C_t)/mu0(A) = Lam S_j(t), where")
rep("   S_j is a +-1 walk over the j opportunities with p_hat < t: +1 if the check did not fire (gaming paid),")
rep("   -1 if it fired.  In scenario 2 every step is +1 with prob P+ = 0.4 + 0.6 x 0.05 = 0.43, so the walk")
rep("   drifts down (the LLN), but the posterior over a continuum of t picks out the walk's maximum M.")
rep("   Gambler's ruin: P(M >= k) = (P+/P-)^k for an infinite walk, independent of n.  A threshold region")
rep("   between two neighbouring low-tail opportunities has prior mass g ~ 0.005, so a seed is captured")
rep("   by a lucky careful gamer once Lam M > ln(mu(A)/g), i.e. M >= 2 here.  More training does not")
rep("   remove the lucky region; it only shrinks g slowly as the tail fills in.")
Sw = 1000
rngw = np.random.default_rng(999)
pw, lphw = draw(rngw, SCEN[name], (Sw, NMAX))
firedw = rngw.random((Sw, NMAX)) < pw
Mw = np.zeros(Sw, int)
ontw = np.zeros(Sw)
for s_ in range(Sw):
    o = np.argsort(lphw[s_])
    Sj = np.concatenate([[0], np.cumsum(np.where(firedw[s_][o], -1, 1))])
    Mw[s_] = Sj.max()
    rel_ = Sj[np.searchsorted(lphw[s_][o], LT, side="left")]
    mA_, mC_ = posterior(LAM * rel_[None, :])
    ontw[s_] = on_task(mA_, mC_)[0]
Pp = 0.4 + 0.6 * 0.05
ratio = Pp / (1 - Pp)
for kk in (1, 2, 3, 4):
    emp = np.mean(Mw >= kk)
    se_ = np.sqrt(emp * (1 - emp) / Sw)
    rep.check("scenario 2: P(max of the threshold walk >= %d) over %d independent training runs" % (kk, Sw),
              "(P+/P-)^%d = %.3f" % (kk, ratio ** kk), "%.3f +- %.3f" % (emp, se_), abs(emp - ratio ** kk) < 3 * se_ + 0.01,
              "finite-n walk: slightly below the infinite-walk value" if emp < ratio ** kk - 3 * se_ - 0.01 else "")
rep("   frontier on-task rate (B) by walk maximum M (median over runs with that M):")
for kk in range(0, 6):
    m = Mw == kk if kk < 5 else Mw >= 5
    if m.any():
        rep("      M %s %d: %4d runs, median on-task %.3f" % ("=" if kk < 5 else ">=", kk, m.sum(), np.median(ontw[m])))
rep.check("scenario 2: fraction of runs captured by careful gamers (on-task < 1/2)",
          "about P(M >= 2) = %.3f (gambler's ruin with the M >= 2 capture rule)" % ratio ** 2,
          "%.3f (P(M >= 2) in these runs: %.3f)" % (np.mean(ontw < 0.5), np.mean(Mw >= 2)),
          abs(np.mean(ontw < 0.5) - ratio ** 2) < 0.1, "capture rule is a heuristic; M = 2 is borderline")

# ============================================================================
# Figures
# ============================================================================
fig, axs = plt.subplots(1, 5, figsize=(19, 4.2), sharey=False)
k = list(CHECKS_N).index(NMAX)
for ax, (name, res) in zip(axs, results.items()):
    r = res["B"]
    sim_mean = r["muC"][:, k, :].mean(0)
    dens = sim_mean / (LT[1] - LT[0])
    floor = 1e-5
    ax.fill_between(LT, floor, PRIOR_C / (LT[1] - LT[0]), color=MUTED, alpha=0.25, lw=0, label="prior density of C_t")
    ax.plot(LT, np.maximum(dens, floor), color=SERIES[0], lw=2, label="posterior, simulated (mean of %d seeds)" % S)
    ax.plot(LT, np.maximum(r["pC"][k] / (LT[1] - LT[0]), floor), color=INK, lw=1.0, ls="--",
            label="posterior, LLN prediction")
    ax.axvline(logit(FRONT_C), color=SERIES[1], lw=1.0, label="frontier perceived detection (logit 0.002)")
    ax.set_yscale("log")
    ax.set_ylim(floor, 200)
    ax.set_xlabel("logit t")
    ax.set_title(name, fontsize=9.5)
    ax.text(0.98, 0.97, "mass of A: %.2f\nfrontier on-task: %.2f" % (r["muA"][:, k].mean(), r["ont_sim"][:, k].mean()),
            transform=ax.transAxes, va="top", ha="right", fontsize=8.5, color=INK2)
axs[0].set_ylabel("posterior density over logit t (floored at 1e-5)")
handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="lower center", ncol=4)
fig.suptitle("(d) The sieve: posterior over careful-gamer thresholds after %d gaming opportunities, operator (B)" % NMAX,
             color=INK)
fig.tight_layout(rect=(0, 0.08, 1, 1))
fig.savefig(os.path.join(HERE, "fig_d1_sieve_posterior.png"))
plt.close(fig)

fig, axs = plt.subplots(1, 2, figsize=(13, 5.0), sharey=True)
for ax, op in zip(axs, ("B", "D")):
    for (name, res), c in zip(results.items(), SERIES):
        r = res[op]
        xs = CHECKS_N[1:]
        ax.semilogx(xs, r["ont_sim"][:, 1:].mean(0), color=c, marker="o", ms=6, label=name)
        ax.semilogx(xs, r["ont_pred"][1:], color=c, lw=1.0, ls="--")
    ax.set_xlabel("gaming opportunities seen in training n")
    ax.set_title("operator (%s)" % ("B: Bayes on pass events" if op == "B" else "D: tilt, beta = 1"))
axs[0].set_ylabel("on-task rate on frontier tasks")
axs[0].plot([], [], color=INK, lw=1, ls="--", label="LLN prediction")
handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="lower center", ncol=3, fontsize=8.5)
fig.suptitle("(d) Frontier on-task rate after training (mean of %d seeds); scenarios 1, 4, 5 sit at 0.01" % S,
             color=INK)
fig.tight_layout(rect=(0, 0.12, 1, 1))
fig.savefig(os.path.join(HERE, "fig_d2_ontask.png"))
plt.close(fig)

rep("")
rep("runtime %.1f s" % (time.time() - T0))
rep.save()
