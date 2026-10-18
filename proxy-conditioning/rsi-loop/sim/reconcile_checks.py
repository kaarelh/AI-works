#!/usr/bin/env python3
"""Reconciliation of the simulations with the revised theory sections
(drafts/T1-ledger.md, drafts/T2-sieve.md, drafts/T4-protocols.md).

Each section R1..R14 takes one quantitative prediction of the revised theory
that the existing simulations do not test (or test only indirectly), computes
the prediction from the theory's own formula, and compares it with a
simulation built from the toy's definitions (toy.py, loopcore.py, or the
sieve model of sieve_sim.py, re-implemented here so that importing does not
re-run that script).  Disagreements are kept and explained in
reconciliation.md.

Run:  python3 reconcile_checks.py            (all sections, about 3 minutes)
      python3 reconcile_checks.py R3 R11     (selected sections)
Writes reconcile_checks_output.txt (only when all sections are run).
"""
import os
import sys
import time
import numpy as np
from scipy.special import expit, logit, logsumexp
from scipy.stats import norm, poisson, skellam, binom
from scipy.optimize import brentq

from toy import (PRED, AUD_UNREC, NORMAL, UNPRED, draw_categories, px_table, pass_table,
                 lam, u_v, p_hat, cat_probs, Report)
import loopcore as lc

HERE = os.path.dirname(os.path.abspath(__file__))
rep = Report(os.path.join(HERE, "reconcile_checks_output.txt"))
DELTA = 0.01
LAM = lam(DELTA)
T0 = time.time()


def hdr(title):
    rep("")
    rep("=" * 78)
    rep(title)
    rep("=" * 78)


def se_p(p, n):
    return np.sqrt(max(p * (1 - p), 1.0 / n) / n)


# ============================================================================
# R1. T1.6(3)-(4): the (B) ledger is a lattice walk with steps +-Lam.
# ============================================================================
def R1():
    hdr("R1. T1.6: ever-flip probability (v/u)^m, m = floor(L0/Lam)+1, and end-of-generation Skellam tails")
    cases = [("P2 of train_sim (eps=0.02, a=0.05, honeypots, s=0.5)", (0.02, 0.0, 0.05, 1.0, 0.5), np.log(1e6), 9000, None),
             ("T1 honeypot example (eps=0.01, a=0.03, honeypots, s=0.5)", (0.01, 0.0, 0.03, 1.0, 0.5), np.log(1e6), 12000, 500)]
    thr = np.array([0.0, 1.0])
    for name, (eps, eps_u, a, h, s), L0, N, n_end in cases:
        u, v = u_v(eps, a, h, s)
        ph = p_hat(eps, a, h, s)
        passT = pass_table(px_table(thr, ph, DELTA))
        inc = np.log(passT[0]) - np.log(passT[1])          # increment of L = ln mu(A)/mu(G) per category
        m = int(np.floor(L0 / LAM)) + 1
        pred_ever = (v / u) ** m
        S, chunk = 6000, 1000
        ever, endL = [], []
        for c0 in range(0, S, chunk):
            cat = draw_categories(np.random.default_rng(11 + c0), (chunk, N), eps, eps_u, a, h, s)
            L = L0 + np.cumsum(inc[cat], axis=1)
            ever.append((L.min(axis=1) < 0))
            if n_end:
                endL.append(L[:, n_end - 1])
        ever = np.concatenate(ever)
        rep("   %s: u = %.4f, v = %.4f, Lam = %.4f, L0 = %.3f, m = %d" % (name, u, v, LAM, L0, m))
        rep.check("%s: P(L ever < 0) within %d episodes (%d seeds, explicit episodes)" % (name.split(" (")[0], N, S),
                  "(v/u)^m = %.4f (T1.6(3), gambler's ruin on the +-Lam lattice)" % pred_ever,
                  "%.4f +- %.4f" % (ever.mean(), se_p(ever.mean(), S)),
                  abs(ever.mean() - pred_ever) < 3 * se_p(pred_ever, S) + 0.005)
        if n_end:
            endL = np.concatenate(endL)
            qd = brentq(lambda q: lc.D_of_q(q, lc.default_params(a0=a, eps_h=eps, d_eps=0.05, s=s)), 0, 1)
            Ldag = np.log((1 - qd) / qd)
            for thr_L, lab in ((0.0, "0"), (Ldag, "L_dag = %.3f" % Ldag)):
                kk = (L0 - thr_L) / LAM
                kreq = int(np.floor(kk)) + 1
                pred = 1 - skellam.cdf(kreq - 1, n_end * v, n_end * u)
                sim = np.mean(endL < thr_L)
                rep.check("T1 honeypot example: P(L_%d < %s) (Skellam(nv, nu) tail, T1.6(4))" % (n_end, lab),
                          "%.4f" % pred, "%.4f +- %.4f" % (sim, se_p(sim, S)),
                          abs(sim - pred) < 3 * se_p(pred, S) + 0.003)


# ============================================================================
# R2. (C-on) best-of-k as an exact lattice Markov chain (T1 §1.2 table row)
# ============================================================================
def con_chain(L0, u, v, k, N, Lam=LAM, delta=DELTA, J=80):
    """Exact distribution of L = ln m_A/m_G (class log-odds) after N episodes of
    (C-on, best-of-k).  Per episode: with prob v (rewarded opportunity) L -= Lam
    w.p. 1-(1-pX)^k; with prob u (caught opportunity) L += Lam w.p. 1-pX^k;
    otherwise no change.  pX = m_G (1-delta) + m_A delta.  Returns P(L_N > 0)."""
    js = np.arange(-J, J + 1)
    L = L0 + js * Lam
    mG = expit(-L)
    pX = mG * (1 - delta) + (1 - mG) * delta
    down = v * (1 - (1 - pX) ** k)
    up = u * (1 - pX ** k)
    stay = 1 - down - up
    dist = (js == 0).astype(float)
    for _ in range(N):
        new = dist * stay
        new[:-1] += dist[1:] * down[1:]
        new[1:] += dist[:-1] * up[:-1]
        new[0] += dist[0] * down[0]          # absorbing edges (never reached in practice)
        new[-1] += dist[-1] * up[-1]
        dist = new
    return dist[L > 0].sum() + 0.5 * dist[L == 0].sum()


def parse_train_output():
    path = os.path.join(HERE, "train_sim_output.txt")
    lines = open(path).read().splitlines()
    sweep, classfrac = {}, {}
    cur = None
    for i, ln in enumerate(lines):
        if ln.startswith("P1 ") or ln.startswith("P2 ") or ln.startswith("P3 ") or ln.startswith("P1u ") or ln.startswith("PU "):
            cur = ln.split()[0]
        if "(C-on, best-of-" in ln and "class-A mass" in ln and ln.startswith("CHECK"):
            k = int(ln.split("best-of-")[1].split(")")[0])
            sim = lines[i + 2]
            f = float(sim.split("class-A mass > 1/2:")[1])
            classfrac[(cur, k)] = f
        if ln.strip().startswith("L0 =") and "fraction of seeds ending with mu(A)" in ln:
            L0 = float(ln.split("=")[1].split()[0])
            sweep[L0] = float(ln.split(":")[-1])
    return sweep, classfrac


def R2():
    hdr("R2. (C-on, best-of-k): exact lattice-chain prediction of the fraction of runs that end at A")
    rep("   T1 §1.2: lambda_+ = Lam(1-(1-pX)^k), lambda_- = Lam(1-pX^k) are the *expected* jumps; the actual jumps")
    rep("   are +-Lam or 0, so the class log-odds is a state-dependent lattice walk. Its exact law gives the")
    rep("   minority outcomes that the mean-field separatrix (T1: t* = pX at k = 1) cannot.")
    sweep, classfrac = parse_train_output()
    u, v = u_v(0.02, 0.01, 1.0, 0.5)
    pred = {L0: con_chain(L0, u, v, 1, 6000) for L0 in sweep}
    S4 = 300
    rows = []
    for L0 in sorted(sweep):
        rows.append((L0, pred[L0], sweep[L0]))
    rep("   P1, {A, G}, k = 1, 6000 episodes, 300 seeds per start (simulated values parsed from train_sim_output.txt)")
    rep("   L0      : " + " ".join("%6.1f" % r[0] for r in rows))
    rep("   chain   : " + " ".join("%6.3f" % r[1] for r in rows))
    rep("   train_sim: " + " ".join("%6.3f" % r[2] for r in rows))
    dev = np.array([abs(r[1] - r[2]) / se_p(r[1], S4) for r in rows])
    rep.check("P1 (C-on, k=1) fraction ending at A against L0 (13 starts)",
              "exact chain (mean-field separatrix L* = 1.41 gives only the 50% point)",
              "max |z| = %.2f; mean |diff| = %.3f" % (dev.max(), np.mean([abs(r[1] - r[2]) for r in rows])),
              dev.max() < 3.5)
    # section-2 runs: 21 dispositions, prior A 0.6, G 0.01, C_t 0.39/19 each; classes {t <= p_hat} vs {t > p_hat}
    T_GRID = np.round(np.arange(0.05, 0.951, 0.05), 2)
    prior = np.concatenate([[0.6, 0.01], np.full(len(T_GRID), 0.39 / len(T_GRID))])
    thr = np.concatenate([[0.0, 1.0], T_GRID])
    sets = {"P1": (0.02, 0.01, 1.0, 0.5), "P2": (0.02, 0.05, 1.0, 0.5), "P3": (0.05, 0.20, 0.05, 0.5),
            "P1u": (0.02, 0.01, 1.0, 0.5)}
    for nm, (eps, a, h, s) in sets.items():
        u, v = u_v(eps, a, h, s)
        ph = u / (u + v)
        games = thr > ph
        mg = prior[games].sum() / prior.sum()
        L0 = np.log((1 - mg) / mg)
        for k in (1, 8):
            pr = con_chain(L0, u, v, k, 3000)
            Lmf = L0
            for _ in range(3000):
                pX = expit(-Lmf) * (1 - DELTA) + expit(Lmf) * DELTA
                Lmf += LAM * (u * (1 - pX ** k) - v * (1 - (1 - pX) ** k))
            sim = classfrac.get((nm, k), np.nan)
            ok = abs(pr - sim) < 3 * se_p(pr, 200) + 0.01
            rep.check("%s (C-on, best-of-%d), 21 dispositions: fraction of 200 seeds whose class-A mass ends > 1/2" % (nm, k),
                      "%.3f (exact chain from class log-odds %.2f; mean-field ODE ends at %s)" % (pr, L0, "A" if Lmf > 0 else "G"),
                      "%.3f" % sim, ok)


# ============================================================================
# R3. T1.7q quenched builders, with (B) training noise
# ============================================================================
def R3():
    hdr("R3. T1.7q quenched reading: P(loop fails) with and without (B) training noise (T1 honeypot example, n = 500)")
    a, eps, s, n = 0.03, 0.01, 0.5, 500
    u, v = a * (1 - s), (1 - a) * eps
    nD0 = n * LAM * (v - u)
    rep("   Each generation is A or G, drawn from its posterior; G is absorbing (nD(1) = +138). After an all-A history")
    rep("   T1.7q uses the deterministic ledger L_k = L0 + k n|D(0)| (n|D(0)| = %.2f). With operator (B) the ledger" % -nD0)
    rep("   after training is L_k = L_{k-1} + Lam (N_caught - N_rewarded), sd %.1f nats per generation." % (LAM * np.sqrt(n * (u + v))))
    R, K = 200000, 40
    rng = np.random.default_rng(5)
    for L0 in (1.0, 2.0, 2.4, 3.0, np.log(1e6)):
        det = 1 - np.prod([1 - expit(-(L0 - k * nD0)) for k in range(400)])
        L = np.full(R, L0)
        surv = 1 - expit(-L)
        for k in range(1, K):
            cnt = rng.multinomial(n, [u, v, 1 - u - v], size=R)
            L = L + LAM * (cnt[:, 0] - cnt[:, 1])
            surv *= 1 - expit(-L)
        pf = 1 - surv.mean()
        se = surv.std() / np.sqrt(R)
        # annealed reading with the same noise, for comparison: q_k = sigma(-L_k) sets the next grader
        La = np.full(R // 4, L0)
        dead = np.zeros(R // 4, bool)
        for k in range(1, K):
            q = expit(-La)
            uq, vq = a * (1 - q) * (1 - s), (1 - a * (1 - q)) * (eps + 0.05 * q)
            La = La + LAM * (rng.poisson(n * uq) - rng.poisson(n * vq))
            dead |= La < -20
        rep("   L0 = %5.2f: annealed reading with the same (B) noise: P(L < -20 by generation %d) = %.4f; "
            "noise-free annealed map: %s" % (L0, K, dead.mean(), "collapse" if L0 < 2.4034 else "survives"))
        rep.check("quenched P(fail), L0 = %.2f" % L0, "%.4f (T1.7q, noise-free ledger)" % det,
                  "%.4f +- %.4f (multinomial episode counts, %d runs)" % (pf, se, R), abs(pf - det) < 3 * se + 0.003,
                  "" if abs(pf - det) < 3 * se + 0.003 else "training noise dominates the first generation")


# ============================================================================
# R4. T1.10s regime (i) collapse probability, via loopcore (independent code)
# ============================================================================
def R4():
    hdr("R4. T1.10s table, regime (i) row: collapse probability by generation, recomputed with loopcore")
    p = lc.default_params(a0=0.03, eps_h=0.01, d_eps=0.05, s=0.5, n=500, L_base=np.log(1e6), K=50)
    S = 20000
    qs, _ = lc.run_loop(None, p, "continued", np.random.default_rng(41), mode="counts", S=S)
    lo = lc.run_loop.last_logodds            # ln mu(G)/mu(A) = -L
    T1 = {1: 0.0018, 5: 0.1226, 10: 0.1315, 20: 0.1326, 50: 0.1326}
    for K in (1, 5, 10, 20, 50):
        sim = np.mean((lo[:, 1:K + 1] > 20).any(axis=1))
        rep.check("regime (i), L0 = ln 1e6, n = 500: P(L < -20 by generation %d)" % K,
                  "%.4f (T1 revision checks, Poisson counts); loopcore DP absorbed below L_dag: %.4f"
                  % (T1[K], lc.p_fail_continued(dict(p, K=K), K)),
                  "%.4f +- %.4f (loopcore multinomial counts, %d seeds)" % (sim, se_p(sim, S), S),
                  abs(sim - T1[K]) < 3 * se_p(T1[K], S) + 0.004)


# ============================================================================
# R5. T1.10 existence condition with leakage (D(0) > 0), in the sim's fresh map
# ============================================================================
def aligned_exists(p):
    fps = lc.fixed_points_fresh(p)
    return any(st and q < 0.5 for L, q, st in fps)


def R5():
    hdr("R5. T1.10: existence of an aligned fixed point when D(0) > 0, in the sim's fresh map (bounded data channel)")
    rep("   T1.10's sharpened condition, rederived for chi(L) = Xi(1-2q): with q ~ e^-L, the fixed-point equation is")
    rep("   L + (2 Xi + n D1) e^-L = L_b + Xi - n D0, so an aligned fixed point exists iff")
    rep("   L_b + Xi - n D0 >= 1 + ln(2 Xi + n D1), D1 = D'(0).  The sim's criterion is D(0) < 0 (eps_h < eps*).")
    P = lc.default_params()
    rho = P["rho"]
    Xi = P["m"] * 2 * rho * np.log((1 + 2 * rho) / (1 - 2 * rho))
    eps_star = P["a0"] * (1 - P["s"]) / (1 - P["a0"])
    for n in (2000, 20000):
        def cond(e):
            p = dict(P, eps_h=e, n=n)
            D0 = lc.D_of_q(0.0, p)
            h = 1e-7
            D1 = (lc.D_of_q(h, p) - D0) / h
            return P["L_base"] + Xi - n * D0 - 1 - np.log(2 * Xi + n * D1)
        e_pred = brentq(cond, eps_star - 0.001, eps_star + 0.003)
        lo_, hi_ = eps_star - 0.001, eps_star + 0.003
        for _ in range(40):
            mid = 0.5 * (lo_ + hi_)
            if aligned_exists(dict(P, eps_h=mid, n=n)):
                lo_ = mid
            else:
                hi_ = mid
        rep.check("n = %d: largest eps_h with an aligned stable fixed point of the fresh mean map" % n,
                  "%.6f (T1.10 sharpened, adapted); the D(0) < 0 criterion gives eps* = %.6f" % (e_pred, eps_star),
                  "%.6f (bisection on loopcore.fixed_points_fresh)" % lo_,
                  abs(lo_ - e_pred) < 0.1 * (e_pred - eps_star) + 2e-6)


# ============================================================================
# R6. T1.10s Gaussian hazard against the sim's per-generation escape probability
# ============================================================================
def R6():
    hdr("R6. T1.10s: Gaussian hazard Phi(-z) against the per-generation escape probability of the fresh regime")
    rep("   z as in T1.10s with eta = 0 (the sim's channel saturates at the aligned end), anchor L_b + Xi, separatrix")
    rep("   L_u (unstable fixed point of the fresh map): z = (L_b + Xi + n Lam (u - v) - L_u) / sd.")
    rep("   'as written' uses sd = Lam sqrt(n w); '+ data noise' adds the data channel's variance 4 m p(1-p) lam_rho^2.")
    P = lc.default_params()
    rho = P["rho"]
    lam_r = np.log((1 + 2 * rho) / (1 - 2 * rho))
    Xi = P["m"] * 2 * rho * lam_r
    var_data = lam_r ** 2 * 4 * P["m"] * (0.5 + rho) * (0.5 - rho)
    rng = np.random.default_rng(66)
    S = 20000
    for eps_h, n in ((0.02, 2000), (0.02, 5000), (0.015, 1000), (0.01, 500), (0.024, 5000)):
        p = dict(P, eps_h=eps_h, n=n, K=1)
        fps = lc.fixed_points_fresh(p)
        Lu = [L for L, q, st in fps if not st][0]
        u, v = P["a0"] * (1 - P["s"]), (1 - P["a0"]) * eps_h
        mean = P["L_base"] + Xi + n * LAM * (u - v)
        sd1 = LAM * np.sqrt(n * (u + v))
        z1 = (mean - Lu) / sd1
        z2 = (mean - Lu) / np.sqrt(sd1 ** 2 + var_data)
        pesc, _ = lc.p_escape_fresh(p)
        prior = lc.data_channel(np.tile(np.log([1.0, 1e-300, 1e-300]), (S, 1)), p, S, rng)
        lw = lc.train(prior, np.zeros(S), p, rng, mode="counts")
        Lsim = lw[:, 0] - lw[:, 1]
        sim = np.mean(Lsim < Lu)
        rep("   eps_h = %.3f, n = %5d: L_u = %6.2f, mean %7.2f, z = %.2f / %.2f -> Phi(-z) = %.4f / %.4f; "
            "semi-analytic p_esc = %.4f; simulated %.4f +- %.4f"
            % (eps_h, n, Lu, mean, z1, z2, norm.cdf(-z1), norm.cdf(-z2), pesc, sim, se_p(sim, S)))
        rep.check("eps_h = %.3f, n = %d: per-generation escape from the aligned state" % (eps_h, n),
                  "Phi(-z) = %.4f (T1.10s as written), %.4f (with data-channel variance)" % (norm.cdf(-z1), norm.cdf(-z2)),
                  "%.4f +- %.4f (one generation from an aligned teacher, %d seeds)" % (sim, se_p(sim, S), S),
                  abs(sim - norm.cdf(-z2)) < max(0.5 * sim, 3 * se_p(sim, S) + 0.003),
                  "order of magnitude only: the Skellam tail is skewed" if abs(sim - norm.cdf(-z2)) >= 0.25 * sim else "")


# ============================================================================
# R7. T1.11: time to failure in the leaking continued regime
# ============================================================================
def R7():
    hdr("R7. T1.11: time to failure when the aligned end leaks (D(0) > 0), continued regime")
    P = lc.default_params(eps_h=0.03, n=2000)
    D0 = lc.D_of_q(0.0, P)
    h = 1e-7
    D1 = (lc.D_of_q(h, P) - D0) / h
    n = P["n"]
    eps, a = lc.grader(0.0, P)
    w = a * (1 - P["s"]) + (1 - a) * eps
    rep("   eps_h = 0.03 (> eps* = 0.0263): D0 = %.5f, D1 = D'(0) = %.4f, n D0 = %.2f nats/generation, "
        "noise sd Lam sqrt(nw) = %.1f" % (D0, D1, n * D0, LAM * np.sqrt(n * w)))
    S = 4000
    for L0 in (50.0, 100.0, 200.0):
        T_ode = L0 / (n * (D0 + D1)) + D1 / (n * D0 * (D0 + D1)) * (np.log(D0) + L0 + np.log1p((D0 + D1) * np.exp(-L0) / D0) - np.log(2 * D0 + D1))
        p = dict(P, L_base=L0, K=int(3 * L0 / (n * D0)) + 10)
        qs, _ = lc.run_loop(None, p, "continued", np.random.default_rng(int(L0)), mode="mean", S=1)
        Lm = -lc.run_loop.last_logodds[0]
        T_map = int(np.argmax(Lm < 0))
        qs, _ = lc.run_loop(None, p, "continued", np.random.default_rng(int(L0) + 1), mode="counts", S=S)
        Ls = -lc.run_loop.last_logodds
        Tsim = np.argmax(Ls < 0, axis=1).astype(float)
        Tsim[~(Ls < 0).any(axis=1)] = np.nan
        rep.check("L0 = %.0f: generations until L < 0" % L0,
                  "T1.11 ODE T = %.2f, so first integer generation %d; discrete mean map %d; "
                  "Wald L0/(nD0) = %.2f" % (T_ode, int(np.ceil(T_ode)), T_map, L0 / (n * D0)),
                  "mean %.2f, median %.1f, 10-90%% [%.0f, %.0f] (%d seeds)" %
                  (np.nanmean(Tsim), np.nanmedian(Tsim), np.nanquantile(Tsim, .1), np.nanquantile(Tsim, .9), S),
                  abs(np.nanmean(Tsim) - T_map) < 1.0)


# ============================================================================
# R8. Step size with episodes per generation proportional to g (T1.12's assumption)
# ============================================================================
def R8():
    hdr("R8. Step size when episodes per generation scale with the step (n = g/r, T1.12) instead of fixed n (stepsize_sim)")
    P = lc.default_params()
    KAPPA, e0 = 0.02, 0.02
    NGEN = np.array([1, 2, 4, 8, 16, 32, 64])
    G = 1.0 / NGEN
    for n_ref in (2000, 20000):
        rep("   fresh regime, eps_0 = 0.02, kappa = 0.02; fixed n = %d versus n(g) = %d x 4g (equal at g = 1/4)" % (n_ref, n_ref))
        fixed, scaled, sim_scaled = [], [], []
        for N, g in zip(NGEN, G):
            pf = dict(P, eps_h=e0 + KAPPA * g, n=n_ref, K=int(N))
            ps = dict(P, eps_h=e0 + KAPPA * g, n=max(1, int(round(4 * g * n_ref))), K=int(N))
            fixed.append(lc.p_fail_fresh(pf, int(N)))
            scaled.append(lc.p_fail_fresh(ps, int(N)))
            qs, _ = lc.run_loop(None, ps, "fresh", np.random.default_rng(800 + int(N) + n_ref), mode="counts", S=400)
            sim_scaled.append(np.mean(qs[:, -1] > 0.5))
        rep("   g                   : " + " ".join("%6.3f" % g for g in G))
        rep("   P(fail), fixed n    : " + " ".join("%6.3f" % x for x in fixed) + "   (semi-analytic, as in stepsize_sim)")
        rep("   P(fail), n prop. g  : " + " ".join("%6.3f" % x for x in scaled) + "   (semi-analytic)")
        rep("   P(fail), n prop. g  : " + " ".join("%6.3f" % x for x in sim_scaled) + "   (simulated, 400 seeds)")
        dev = max(abs(a_ - b_) / se_p(a_, 400) for a_, b_ in zip(scaled, sim_scaled))
        rep.check("n = %d x 4g: semi-analytic escape model against simulation (7 step sizes)" % n_ref,
                  "curve above", "max |z| = %.2f" % dev, dev < 3.5)
    for Lb in (4.0, 10.0):
        rep("   continued regime, eps_0 = 0.02, n(g) = 2000 x 4g, L_base = %.0f (L_dag = 3.30): exact DP and simulation" % Lb)
        cdp, csim = [], []
        for N, g in zip(NGEN, G):
            ps = dict(P, eps_h=e0 + KAPPA * g, n=max(1, int(round(4 * g * 2000))), K=int(N), L_base=Lb)
            cdp.append(lc.p_fail_continued(ps, int(N)))
            qs, _ = lc.run_loop(None, ps, "continued", np.random.default_rng(900 + int(N)), mode="counts", S=400)
            csim.append(np.mean(qs[:, -1] > 0.5))
        rep("   g                   : " + " ".join("%6.3f" % g for g in G))
        rep("   P(fail), n prop. g  : " + " ".join("%6.3f" % x for x in cdp) + "   (exact DP)")
        rep("   P(fail), n prop. g  : " + " ".join("%6.3f" % x for x in csim) + "   (simulated, 400 seeds)")
        dev = max(abs(a_ - b_) / se_p(a_, 400) for a_, b_ in zip(cdp, csim))
        mono = all(np.diff(cdp) <= 1e-9)
        rep.check("continued, n = 2000 x 4g, L_base = %.0f: smaller steps never worse (T1 takeaway 9 with psi = 0)" % Lb,
                  "P(fail) non-increasing as g falls", "DP vs sim max |z| = %.2f; DP monotone: %s" % (dev, mono),
                  dev < 3.5 and mono, "" if mono else "the collusion feedback acts at every generation boundary; with a fixed total budget, more boundaries let it act on transient dips of the same event walk")


# ============================================================================
# R9. T1.1b: the competence (slop) axis
# ============================================================================
def R9():
    hdr("R9. T1.1b: unpredictable errors act on softness (competence axis), explicit episodes")
    eps_u, dA = 0.05, 0.01
    S, N = 200, 5000
    cat = draw_categories(np.random.default_rng(9), (S, N), 0.0, eps_u, 0.0, 1.0, 0.5)
    err = (cat == UNPRED)
    for dS in (0.02, 0.05, 0.1, 0.2):
        predB = (1 - eps_u) * np.log((1 - dS) / (1 - dA)) + eps_u * np.log(dS / dA)
        predD = (dS - dA) * (2 * eps_u - 1)
        incB = np.where(err, np.log(dS / dA), np.log((1 - dS) / (1 - dA)))
        incD = np.where(err, dS - dA, -(dS - dA))
        slB = incB.sum(1) / N
        slD = incD.sum(1) / N
        rep.check("delta_S = %.2f: drift of ln mu(S)/mu(A) per episode, (B) and (D, beta = 1)" % dS,
                  "(B) %+.4f, (D) %+.4f" % (predB, predD),
                  "(B) %+.4f +- %.4f, (D) %+.4f +- %.4f" % (slB.mean(), slB.std() / np.sqrt(S), slD.mean(), slD.std() / np.sqrt(S)),
                  abs(slB.mean() - predB) < 3 * slB.std() / np.sqrt(S) + 1e-4 and abs(slD.mean() - predD) < 3 * slD.std() / np.sqrt(S) + 1e-4)
    # posterior over a grid of softnesses concentrates at delta = eps_u under (B)
    grid = np.array([0.005, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.1, 0.15, 0.2, 0.3])
    nerr = err.sum(1)
    ll = nerr[:, None] * np.log(grid)[None, :] + (N - nerr)[:, None] * np.log(1 - grid)[None, :]
    am = grid[np.argmax(ll, axis=1)]
    rep.check("(B) posterior mode over 12 softness values after %d episodes (uniform prior)" % N,
              "delta = eps_u = 0.05", "mode = 0.05 in %.0f%% of seeds; modes seen: %s" % (100 * np.mean(am == 0.05), ", ".join("%.2f" % x for x in sorted(set(am)))),
              np.mean(np.abs(am - 0.05) <= 0.011) > 0.9)


# ============================================================================
# R10. T1.4c: ROC (binormal) recognition; audits built from real opportunities
# ============================================================================
def R10():
    hdr("R10. T1.4c: best-responder drift under binormal recognition, explicit episodes (T1 honeypot example, (B))")
    a, eps = 0.03, 0.01
    ah, v = a * 1.0, (1 - a) * eps
    S, N = 20, 400000
    rng = np.random.default_rng(10)
    pred_tab = {0.70: 0.001540, 0.83: 0.010410, 0.95: 0.026634}
    for auc, pred in pred_tab.items():
        dp = np.sqrt(2) * norm.ppf(auc)
        sl = []
        for _ in range(S):
            kind = rng.choice(3, size=N, p=[ah, v, 1 - ah - v])     # 0 audit opp, 1 real opp, 2 nothing
            z = rng.standard_normal(N) + dp * (kind == 0)
            llr = np.log(ah / v) + dp * z - dp ** 2 / 2               # ln [ah f_a / (v f_r)]
            games = llr < 0                                           # G*: game iff d(z) < t* = 1/2
            inc = LAM * games * ((kind == 1).astype(float) - (kind == 0))
            sl.append(inc.sum() / N)
        sl = np.array(sl)
        rep.check("AUC %.2f: drift of ln mu(G*)/mu(A) per episode" % auc, "%+.6f (T1.4c table)" % pred,
                  "%+.6f +- %.6f" % (sl.mean(), sl.std() / np.sqrt(S)), abs(sl.mean() - pred) < 3 * sl.std() / np.sqrt(S) + 2e-5)
    dp = np.sqrt(2) * norm.ppf(0.83)
    for c, pred in ((0.2, 0.001885), (0.5, 0.0)):
        sl = []
        for _ in range(S):
            kind = rng.choice(3, size=N, p=[ah, v, 1 - ah - v])
            real_like = rng.random(N) < c
            z = rng.standard_normal(N) + dp * ((kind == 0) & ~real_like)
            fa = c * norm.pdf(z) + (1 - c) * norm.pdf(z - dp)
            fr = norm.pdf(z)
            games = ah * fa < v * fr
            inc = LAM * games * ((kind == 1).astype(float) - (kind == 0))
            sl.append(inc.sum() / N)
        sl = np.array(sl)
        rep.check("audits a mixture: fraction %.1f drawn from the real-opportunity distribution, rest AUC 0.83" % c,
                  "%+.6f (T1.4c design condition)" % pred, "%+.6f +- %.6f" % (sl.mean(), sl.std() / np.sqrt(S)),
                  abs(sl.mean() - pred) < 3 * sl.std() / np.sqrt(S) + 2e-5)


# ============================================================================
# R11. T2 Example 1 with per-episode updates
# ============================================================================
def R11():
    hdr("R11. T2 Example 1 (AUC 0.8, pbar = 0.3, w = 0.05, alpha = 0.99, uniform m): per-episode updates on the continuum")
    pbar, w, alpha = 0.3, 0.05, 0.99
    dp = np.sqrt(2) * norm.ppf(0.8)
    TG = (np.arange(4000) + 0.5) / 4000
    mC = (1 - alpha) / len(TG)
    # exact drift D(t)/w per opportunity for given lambda+, lambda-
    zt = (logit(TG) - logit(pbar) + dp ** 2 / 2) / dp

    def Dt(lp, lm):
        return (1 - pbar) * lp * norm.cdf(zt) - pbar * lm * norm.cdf(zt - dp)

    def pon_from_rel(rel):
        lA = np.log(alpha)
        lC = np.log(mC) + rel
        return np.exp(lA - logsumexp(np.concatenate([np.full(rel.shape[:-1] + (1,), lA), lC], -1), axis=-1))

    for label, lp, lm, ns, S in (("(D) per-episode, lambda = (0.1, 0.4)", 0.1, 0.4, (1000, 2000, 5000, 10000), 200),
                                 ("(B), lambda = (Lam, Lam)", LAM, LAM, (20, 43, 100, 1000), 400)):
        D = Dt(lp, lm)
        rng = np.random.default_rng(int(lp * 1000))
        nmax = max(ns)
        res = {n: [] for n in ns}
        for _ in range(S):
            nop = rng.binomial(nmax, w)
            ck = rng.random(nop) < pbar
            z = rng.standard_normal(nop) + dp * ck
            ph = expit(logit(pbar) + dp * z - dp ** 2 / 2)
            ep = np.sort(rng.choice(nmax, size=nop, replace=False))     # episode index of each opportunity
            stepv = np.where(ck, -lm, lp)
            for n in ns:
                m_ = ep < n
                o = np.argsort(ph[m_])
                cs = np.concatenate([[0.0], np.cumsum(stepv[m_][o])])
                rel = cs[np.searchsorted(ph[m_][o], TG, side="left")]
                res[n].append(pon_from_rel(rel))
        if lp < 1:
            # where does the median (and the mean) of P_on cross 1/2, against the S4d posterior?
            grid_n = np.arange(3000, 9001, 250)
            med, mn, ll = [], [], []
            rng2 = np.random.default_rng(77)
            runs = []
            for _ in range(S):
                nop = rng2.binomial(grid_n[-1], w)
                ck = rng2.random(nop) < pbar
                z = rng2.standard_normal(nop) + dp * ck
                ph = expit(logit(pbar) + dp * z - dp ** 2 / 2)
                ep = np.sort(rng2.choice(grid_n[-1], size=nop, replace=False))
                runs.append((ph, ep, np.where(ck, -lm, lp)))
            for n in grid_n:
                vals = []
                for ph, ep, stepv in runs:
                    m_ = ep < n
                    o = np.argsort(ph[m_])
                    cs = np.concatenate([[0.0], np.cumsum(stepv[m_][o])])
                    vals.append(pon_from_rel(cs[np.searchsorted(ph[m_][o], TG, side="left")]))
                med.append(np.median(vals)); mn.append(np.mean(vals)); ll.append(pon_from_rel(n * w * D))
            cross = lambda y: float(np.interp(-0.5, -np.array(y), grid_n))
            rep.check("(D) per-episode: number of episodes at which the frontier on-task rate crosses 1/2",
                      "%.0f (S4d posterior, T2.3)" % cross(ll),
                      "median over runs %.0f, mean %.0f (%d runs)" % (cross(med), cross(mn), S),
                      abs(cross(med) - cross(ll)) < 0.1 * cross(ll),
                      "per-episode updates flip %.0f%% earlier: the posterior follows the supremum of the random field over t"
                      % (100 * (1 - cross(med) / cross(ll))))
        for n in ns:
            sim = np.array(res[n])
            lln = pon_from_rel(n * w * D)
            se = sim.std(ddof=1) / np.sqrt(S)
            rep.check("%s: P_on = mu_n(A) after n = %d episodes" % (label, n),
                      "%.3f (T2.3 under S4d: mu_n proportional to mu_0 exp(n D(t)))" % lln,
                      "mean %.3f +- %.3f, median %.3f, 25-75%% [%.3f, %.3f]" %
                      (sim.mean(), se, np.median(sim), np.quantile(sim, .25), np.quantile(sim, .75)),
                      abs(sim.mean() - lln) < 3 * se + 0.02)


# ============================================================================
# R12. T2 / sieve scenario 2: the leak through rarely-triggered thresholds, against step size lambda
# ============================================================================
def R12():
    hdr("R12. Sieve scenario 2 (pooled honeypots, uninformative perception noise): capture against evidence per event")
    rep("   Heuristic law (this file): a run is captured when lambda M >= x, x = ln(mu(A)/g), M = max of the +-1 walk")
    rep("   over opportunities sorted by perceived detection, P(M >= k) = (P+/P-)^k, so P(capture) ~ (P+/P-)^ceil(x/lambda),")
    rep("   independent of n. g = prior mass between neighbouring low-tail opportunities (~0.0036 at n = 1e4).")
    LT = np.linspace(-8, 8, 401)
    MU_A = 0.5
    PRIOR_C = np.full(len(LT), (1 - MU_A) / len(LT))
    FRONT_C, FRONT_SD = 0.002, 0.5
    off = norm.cdf((LT - logit(FRONT_C)) / FRONT_SD)

    def on_task(rel):
        lA = np.log(MU_A)
        lC = np.log(PRIOR_C) + rel
        allw = np.concatenate([[lA], lC])
        wts = np.exp(allw - logsumexp(allw))
        return wts[0] * (1 - DELTA) + (wts[1:] * ((1 - DELTA) - (1 - 2 * DELTA) * off)).sum()

    Pp = 0.4 + 0.6 * 0.05
    ratio = Pp / (1 - Pp)
    g = (1 - MU_A) / 16 * 0.5 / np.sqrt(2 * np.log(1e4))
    x = np.log(MU_A / g)
    S = 600
    for lab, lamb in (("(B), Lam", LAM), ("(D) beta=0.25", 4 * (1 - 2 * DELTA)), ("(D) beta=0.5", 2 * (1 - 2 * DELTA)),
                      ("(D) beta=1", (1 - 2 * DELTA)), ("(D) beta=2", 0.5 * (1 - 2 * DELTA)), ("(D) beta=4", 0.25 * (1 - 2 * DELTA))):
        out = {}
        for n in (1000, 10000):
            rng = np.random.default_rng(int(1000 * lamb) + n)
            capt = []
            for _ in range(S):
                lph = logit(0.03) + 0.5 * rng.standard_normal(n)
                hp = rng.random(n) < 0.6
                fired = hp & (rng.random(n) < 0.95)
                o = np.argsort(lph)
                Sj = np.concatenate([[0], np.cumsum(np.where(fired[o], -1, 1))])
                rel = lamb * Sj[np.searchsorted(lph[o], LT, side="left")]
                capt.append(on_task(rel) < 0.5)
            out[n] = np.mean(capt)
        k = int(np.ceil(x / lamb))
        pred = ratio ** k
        rep.check("%s (lambda = %.3f): fraction of runs captured (frontier on-task < 1/2), n = 1e3 and 1e4" % (lab, lamb),
                  "(P+/P-)^ceil(x/lambda) = %.3f^%d = %.3f, independent of n (x = %.2f)" % (ratio, k, pred, x),
                  "n = 1e3: %.3f; n = 1e4: %.3f (+- %.3f)" % (out[1000], out[10000], se_p(out[10000], S)),
                  abs(out[10000] - pred) < max(0.5 * pred, 3 * se_p(pred, S) + 0.01),
                  "heuristic: within a factor 1.5" if abs(out[10000] - pred) > 0.2 * pred else "")


# ============================================================================
# R13. T4.5 / T4.7: flags under operator (B); fixed versus fresh verifier randomness
# ============================================================================
def R13():
    hdr("R13. T4.5 and T4.7: the flag protocol under (B), explicit episodes")
    rep("   A emits I + flag w.p. 1-delta (X w.p. delta); G emits X w.p. 1-delta (I + flag w.p. delta). In an error cell")
    rep("   the flag is accepted w.p. v. Two readings of 'accepted w.p. v' under (B):")
    rep("   fresh coin: the verdict on the flagged I is random for every evaluation, so P_A(pass) = (1-delta) v + delta")
    rep("      (T4.5's formula); fixed verdict: the episode determines whether this flag is accepted (an event of prob v),")
    rep("      and (B) conditions on that realised verdict, P_A(pass) = (1-delta) 1[acc] + delta.")
    kinds = np.array([0.95, 0.6, 0.1])
    share = np.array([0.6, 0.25, 0.15])
    eps = 0.02
    fresh_pred = eps * np.sum(share * np.log(((1 - DELTA) + DELTA * kinds) / ((1 - DELTA) * kinds + DELTA)))
    fixed_pred = eps * np.sum(share * (1 - kinds)) * LAM
    S, N = 100, 100000
    rng = np.random.default_rng(13)
    fr, fx = [], []
    for _ in range(S):
        err = rng.random(N) < eps
        kind = rng.choice(3, size=N, p=share)
        vv = kinds[kind]
        acc = rng.random(N) < vv
        pA_fresh = (1 - DELTA) * vv + DELTA
        pG_fresh = (1 - DELTA) + DELTA * vv
        pA_fix = (1 - DELTA) * acc + DELTA
        pG_fix = (1 - DELTA) + DELTA * acc
        fr.append(np.sum(err * (np.log(pG_fresh) - np.log(pA_fresh))) / N)
        fx.append(np.sum(err * (np.log(pG_fix) - np.log(pA_fix))) / N)
    fr, fx = np.array(fr), np.array(fx)
    rep.check("T4.5 worked example (eps = 0.02, v = 0.95/0.6/0.1 in 60/25/15%): drift of ln mu(G)/mu(A) under (B), fresh coin",
              "%.5f (T4.5)" % fresh_pred, "%.5f +- %.5f" % (fr.mean(), fr.std() / np.sqrt(S)),
              abs(fr.mean() - fresh_pred) < 3 * fr.std() / np.sqrt(S) + 1e-5)
    rep.check("same, fixed verdict per episode",
              "%.5f (T4.5's formula) -- the fixed reading gives eps Lam E(1-v) = %.5f" % (fresh_pred, fixed_pred),
              "%.5f +- %.5f" % (fx.mean(), fx.std() / np.sqrt(S)), abs(fx.mean() - fresh_pred) < 3 * fx.std() / np.sqrt(S) + 1e-5,
              "T4.5 holds only for fresh verifier randomness; with a fixed verdict the protocol cuts (B) drift by %.1fx, not %.1fx"
              % (eps * LAM / fixed_pred, eps * LAM / fresh_pred))
    # T4.7 under (B): honeypot example eps=0.01, a=0.03, s; sign flip of the naive gamer's drift
    a, e2 = 0.03, 0.01
    lp_fresh = np.sum(share * np.log(((1 - DELTA) + DELTA * kinds) / ((1 - DELTA) * kinds + DELTA)))
    lp_fixed = LAM * np.sum(share * (1 - kinds))
    for lab, lp in (("fresh coin", lp_fresh), ("fixed verdict", lp_fixed)):
        s_flip = 1 - (1 - a) * e2 * lp / (a * LAM)
        rep("   T4.7 under (B), %s: lambda_+ = %.3f nats per rewarded opportunity, t* = %.3f, sign flip at s = %.3f"
            % (lab, lp, lp / (lp + LAM), s_flip))
    for s in (0.95, 0.98):
        u = a * (1 - s)
        v = (1 - a) * e2
        pred = v * lp_fresh - u * LAM
        sl = []
        for _ in range(S):
            r = rng.random(N)
            aud = r < a
            unrec = aud & (rng.random(N) > s)
            err = (~aud) & (rng.random(N) < e2)
            kind = rng.choice(3, size=N, p=share)
            vv = kinds[kind]
            inc = err * (np.log((1 - DELTA) + DELTA * vv) - np.log((1 - DELTA) * vv + DELTA)) - unrec * LAM
            sl.append(inc.sum() / N)
        sl = np.array(sl)
        rep.check("T4.7 (B), fresh coin, s = %.2f: drift of the naive gamer per episode (sign flips at 0.966)" % s,
                  "%+.6f" % pred, "%+.6f +- %.6f" % (sl.mean(), sl.std() / np.sqrt(S)),
                  abs(sl.mean() - pred) < 3 * sl.std() / np.sqrt(S) + 1e-5)


# ============================================================================
# R14. T4.18: the loop map with the protocol (deterministic and with (D) event noise)
# ============================================================================
def t4_D(k, q, sc, eps0=0.01, kappa=0.15, deps=0.05, a=0.03, s0=0.5, sigma=0.3, r0=0.3, omega=0.3):
    nu, proto = sc
    epsh = min(1.0, eps0 * np.exp(kappa * k))
    epsq = np.minimum(1.0, epsh + q * deps)
    if proto:
        rA = r0 * np.exp(-nu * k)
        rX = min(1.0, r0 * np.exp(omega * k))
        rho = (1 - q) * rA + q * rX
    else:
        rho = 1.0
    one_m_s = (1 - s0) * np.exp(-sigma * k)
    rew = (1 - a * (1 - q)) * epsq * rho
    cau = a * (1 - q) * one_m_s
    return rew, cau


def R14():
    hdr("R14. T4.18: the protocol loop map (scenarios S0-S3), recomputed; and with (D) event noise")
    nlam, lamb = 1000.0, 0.05
    n = nlam / lamb
    scen = {"S0 no protocol": (0.0, False), "S1 nu=0.3": (0.3, True), "S2 nu=0.05": (0.05, True), "S3 nu=0.5": (0.5, True)}
    T4 = {"S0 no protocol": (0.083, 1, "fails at k=3", "fails"), "S1 nu=0.3": (0.405, 11, 40.4, 38.7),
          "S2 nu=0.05": (0.405, 5, "fails at k=12", "fails"), "S3 nu=0.5": (0.405, None, 48.6, 49.6)}
    for name, sc in scen.items():
        f = lambda q: (lambda r, c: r - c)(*t4_D(0, q, sc))
        qd = brentq(f, 1e-9, 1 - 1e-9) if f(1e-9) * f(1 - 1e-9) < 0 else np.nan
        first = next((k for k in range(400) if (lambda r, c: r - c)(*t4_D(k, 0.0, sc)) > 0), None)
        L = 3.0
        Ls, fail = [L], None
        for k in range(200):
            q = expit(-L)
            r, c = t4_D(k, q, sc)
            L = L - nlam * (r - c)
            Ls.append(L)
            if L < 0 and fail is None:
                fail = k + 1
        t = T4[name]
        L13 = "fails at k=%d" % fail if (fail is not None and fail <= 13) else "%.2f" % Ls[13]
        L200 = "fails" if fail is not None else "%.2f" % Ls[200]
        okk = (abs(qd - t[0]) < 0.001) and (first == t[1]) and (str(t[2]) == L13 or (isinstance(t[2], float) and abs(Ls[13] - t[2]) < 0.06)) \
            and (str(t[3]) == L200 or (isinstance(t[3], float) and abs(Ls[200] - t[3]) < 0.06))
        rep.check("%s: q_dag_0, first k with nD_k(0) > 0, L_13, L_200 (L0 = 3)" % name,
                  "%s, %s, %s, %s (T4.18 table; failure = first k with L_k < 0)" % t, "%.3f, %s, %s, %s (re-implemented map)" % (qd, first, L13, L200),
                  okk, "" if okk else "check indexing of the generation counter")
    # noise: (D) per-episode, event counts Poisson(n x rate), step lambda
    rng = np.random.default_rng(14)
    R = 2000
    for L0 in (0.5, 1.0, 2.0, 3.0):
        L = np.full(R, L0)
        dead = np.zeros(R, bool)
        for k in range(200):
            q = expit(-L)
            r, c = t4_D(k, q, scen["S1 nu=0.3"])
            L = L + lamb * (rng.poisson(n * c) - rng.poisson(n * r))
            dead |= L < -50
        Ldet = L0
        for k in range(200):
            r, c = t4_D(k, expit(-Ldet), scen["S1 nu=0.3"])
            Ldet = Ldet - nlam * (r - c)
        rep.check("S1 with (D) event noise (lambda = %.2f, n = %d): P(fail by k = 200), L0 = %.1f" % (lamb, n, L0),
                  "deterministic map: %s (separatrix L_dag = 0.385)" % ("fails" if Ldet < 0 else "survives at %.1f" % Ldet),
                  "%.3f; surviving runs end at mean %.2f, sd %.2f" % (dead.mean(), L[~dead].mean() if (~dead).any() else np.nan,
                                                                      L[~dead].std() if (~dead).any() else np.nan),
                  (dead.mean() > 0.5) == (Ldet < 0) and (dead.mean() < 0.02 or Ldet < 0 or L0 < 1.5),
                  "noise matters only within ~1 nat of the separatrix")


SECTIONS = dict(R1=R1, R2=R2, R3=R3, R4=R4, R5=R5, R6=R6, R7=R7, R8=R8, R9=R9, R10=R10, R11=R11, R12=R12, R13=R13, R14=R14)

if __name__ == "__main__":
    which = sys.argv[1:] or list(SECTIONS)
    rep("Reconciliation checks: simulations against the revised theory (T1, T2, T4).  delta = %.2f, Lam = %.4f" % (DELTA, LAM))
    for w_ in which:
        t0 = time.time()
        SECTIONS[w_]()
        rep("   [%s: %.1f s]" % (w_, time.time() - t0))
    rep("")
    ncheck = sum(1 for l in rep.lines if l.startswith("CHECK"))
    nno = sum(1 for l in rep.lines if "agrees: NO" in l)
    rep("checks: %d; disagreements: %d; runtime %.1f s" % (ncheck, nno, time.time() - T0))
    if not sys.argv[1:]:
        rep.save()
