"""ra1_checks.py -- referee A's independent numerical checks for thread `laws` (notes.md of 2026-10-16).

Seed 20261016.  Writes ra1_checks.out next to itself.  Written from the statements in notes.md, not from the
thread's scripts.

Parts
  A. Lemma 3.2: the "coarse regime" condition Delta >= eps + eps* is too weak when eps > eps*.
  B. Lemma 3.6, fine regime: the expected code-R cost of the honest law minus log(L/Delta) (L = 2 eps*), maximised
     over the position w of q in the band and over L/Delta >= 1; compared with the claimed bound 2 log e.
  C. Prop 6.2(c): is the code-R price of silence gamma_si(Delta) = g(Delta)/q(Delta) non-increasing in Delta, and is
     the expected code-R cost g(Delta) of the honest law non-increasing?  (Needed for the interval [Delta*, inf).)
  D. Q/rand threshold 1/2 + H2(p)/(2 p gamma) of Prop 3.4 as p -> 0 ("stays near 1"?).
  E. Setting S3 with times drawn from a finite grid of days (the only way to have i.i.d. times that are numerals
     and have bounded names pi_c): repeated times change the per-datum costs of Prop 3.3.
  F. Prop 7.1(d) and its reading: a model of H^{eps_min} that is a model of neither T_0 nor T_N, so H^{eps_min}
     does not imply the common consequence T_0 \/ T_N.
  G. Myrvold's identity: U(D1,D2;h) = I(D1;D2|h) - I(D1;D2|b) holds without any product assumption on P_b.
  H. The 24-degree constant of Props 3.7 and 6.1(c).
"""
import math
import sys
import time
from fractions import Fraction as Fr

import numpy as np

SEED = 20261016
OUT = []
LOG2E = 1.0 / math.log(2.0)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = np.clip(np.asarray(x, dtype=float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


def honest_events(e, eps, Delta, u):
    """band [e-eps, e+eps] (q at 0), cell [-u Delta, (1-u) Delta): proves / refutes / silent."""
    lo, hi = -u * Delta, (1 - u) * Delta
    blo, bhi = e - eps, e + eps
    proves = (blo >= lo) & (bhi < hi)
    ov = np.minimum(hi, bhi) - np.maximum(lo, blo)
    refutes = ov < 0
    return proves, refutes


def coderR_cost(w, r, u):
    """expected code-R cost (bits) of a datum for the honest band of length L, q at relative position w in the band,
    cell width Delta, r = L/Delta; u the dither.  |cell & band|/L = (min(1-u, b) + min(u, a)) / r with a = w r,
    b = (1-w) r; the cost is -log2 of that (0 when the band lies in the cell)."""
    a, b = w * r, (1 - w) * r
    y = np.minimum(1 - u, b) + np.minimum(u, a)
    frac = np.minimum(y / r, 1.0)
    return -np.log2(frac)


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    out("# ra1_checks.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. Lemma 3.2 with eps > eps*: |e| = eps* = 1, eps = 2, Delta = 3 = eps + eps* (claimed coarse regime)")
    m = 1_000_000
    u = rng.random(m)
    pr, rf = honest_events(np.full(m, 1.0), 2.0, 3.0, u)
    out("   simulated: Pr[prove] = %.4f, Pr[refute] = %.4f, Pr[silent] = %.4f" % (pr.mean(), rf.mean(),
                                                                              1 - pr.mean() - rf.mean()))
    out("   Lemma 3.2 coarse-regime formula: Pr[silent] = 2 eps/Delta = %.4f  (> 1: impossible)" % (4 / 3))
    out("   the general formulas give prove = (1-(eps+max(|e|,eps))/Delta)^+ = %.4f, refute = 0, silent = 1"
        % max(0.0, 1 - 4 / 3))
    out("   => the coarse regime must be Delta >= eps + max(eps, eps*), i.e. Delta >= 2 eps when eps > eps*.")

    # ---------------- B
    out("\n== B. Lemma 3.6 fine regime: max over w of E_u[cost] - log2(L/Delta), r = L/Delta >= 1")
    out("   claimed: in [0, 2 log e] = [0, %.4f]; log e = %.4f" % (2 * LOG2E, LOG2E))
    ug = (np.arange(400_000) + 0.5) / 400_000
    ws = np.linspace(0.0, 1.0, 401)
    overall = (0.0, None, None)
    for r in [1.0, 1.001, 1.01, 1.05, 1.1, 1.25, 1.5, 1.75, 1.9, 1.99, 2.0, 2.5, 3.0, 5.0, 10.0, 50.0]:
        best = (-1.0, None)
        for w in ws:
            val = coderR_cost(w, r, ug).mean() - math.log2(r)
            if val > best[0]:
                best = (val, w)
        out("   r = %6.3f: max excess %.4f at w = %.3f" % (r, best[0], best[1]))
        if best[0] > overall[0]:
            overall = (best[0], r, best[1])
    out("   overall max excess %.4f (r = %.3f, w = %.3f); bound 2 log e = %.4f holds: %s; log e = %.4f holds: %s"
        % (overall[0], overall[1], overall[2], 2 * LOG2E, overall[0] <= 2 * LOG2E + 1e-9, LOG2E,
           overall[0] <= LOG2E + 1e-9))

    # ---------------- C
    out("\n== C. Prop 6.2(c): code-R price of silence gamma_si(Delta) = g(Delta)/q(Delta), q = min(L/Delta, 1)")
    out("   g = expected code-R cost per datum of the honest law; L = 2 eps* = 1; w-laws: point masses, uniform,")
    out("   arcsine (sinusoidal error, w = (1 - sin(2 pi t))/2)")
    ug2 = (np.arange(100_000) + 0.5) / 100_000
    tg = (np.arange(2000) + 0.5) / 2000
    wlaws = {
        "w=0.5": np.array([0.5]),
        "w=0.1": np.array([0.1]),
        "w=0.02": np.array([0.02]),
        "uniform": (np.arange(200) + 0.5) / 200,
        "arcsine": (1 - np.sin(2 * np.pi * tg)) / 2,
    }
    Deltas = np.array([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 1.0, 1.01, 1.05, 1.1, 1.25, 1.5, 2.0,
                       3.0, 5.0, 10.0])
    for name, wv in wlaws.items():
        gs, gsi = [], []
        for D in Deltas:
            r = 1.0 / D
            g = np.mean([coderR_cost(w, r, ug2).mean() for w in wv])
            q = min(r, 1.0)
            gs.append(g)
            gsi.append(g / q)
        gs, gsi = np.array(gs), np.array(gsi)
        inc_g = np.where(np.diff(gs) > 1e-9)[0]
        inc_si = np.where(np.diff(gsi) > 1e-9)[0]
        out("   %-8s g: %s" % (name, " ".join("%.3f" % x for x in gs)))
        out("   %-8s gamma_si: %s" % (name, " ".join("%.3f" % x for x in gsi)))
        out("   %-8s g non-increasing: %s; gamma_si non-increasing: %s%s" % (
            name, len(inc_g) == 0, len(inc_si) == 0,
            "" if len(inc_si) == 0 else "  (increases between Delta = %s)" % ", ".join(
                "%.2f->%.2f" % (Deltas[i], Deltas[i + 1]) for i in inc_si)))
    out("   (Delta in units of L = 2 eps*: %s)" % " ".join("%.2f" % d for d in Deltas))

    # ---------------- D
    out("\n== D. Q/rand threshold thr(p) = 1/2 + H2(p)/(2 p gamma), gamma = log2(360) (Delta = 60', full circle)")
    gam = math.log2(360)
    for p in [1e-2, 5e-3, 1e-3, 1e-4, 1e-6, 1e-9, 1e-12, 1e-15]:
        thr = 0.5 + float(H2(p)) / (2 * p * gam)
        out("   p = %.0e: threshold %.3f" % (p, thr))
    out("   the threshold grows like log2(e/p)/(2 gamma) as p -> 0; it does not 'stay near 1'.")

    # ---------------- E
    out("\n== E. Setting S3 with times i.i.d. uniform on a grid of N days (repeats), sinusoidal error eps* = 1',")
    out("   Delta = 60', R = 21600', gamma = log2(R/Delta), lambda = 1, pi_c = log2(N) + 2 (as in section 3.6)")
    N = 4383
    Delta, epsS, Rr = 60.0, 1.0, 21600.0
    gamma = math.log2(Rr / Delta)
    pic = math.log2(N) + 2
    nmax = 200_000
    k = rng.integers(0, N, size=nmax)
    uu = rng.random(nmax)
    e_k = epsS * np.sin(2 * np.pi * (np.arange(N) + 0.5) / N)
    e = e_k[k]
    lo = -uu * Delta
    hi = (1 - uu) * Delta
    refute0 = ~((e >= lo) & (e < hi))
    blo, bhi = e - epsS, e + epsS
    Hprove = (blo >= lo) & (bhi < hi)
    p = np.mean(np.abs(e_k)) / Delta
    q = 2 * epsS / Delta
    mP_formula = p * (pic + gamma)
    mHQ_formula = q * gamma
    # beta_e for the arcsine law of w, coarse regime: log e - E H2(w)
    wk = (epsS - e_k) / (2 * epsS)
    beta = LOG2E - float(np.mean(H2(wk)))
    mHR_formula = q * beta
    out("   Prop 3.3 rates (distinct times): m_P(Q/det) = %.4f, m_H(Q) = %.4f, m_H(R) = %.4f, m_0 = %.4f"
        % (mP_formula, mHQ_formula, mHR_formula, gamma))
    out("   %8s %8s %12s %12s %12s %12s" % ("n", "K_n/n", "P(Q/det)/n", "H(Q)/n", "H(R)/n", "P refuted t"))
    for n in [1000, 3000, 10_000, 30_000, 100_000, 200_000]:
        kk = k[:n]
        Kn = len(np.unique(kk))
        # patched exact law: patch set = times with a refuting datum; all data at patched times are exceptions
        refuted_time = np.zeros(N, dtype=bool)
        refuted_time[kk[refute0[:n]]] = True
        nS = refuted_time.sum()
        data_at_S = refuted_time[kk].sum()
        costP = pic * nS + gamma * data_at_S
        costHQ = gamma * np.sum(~Hprove[:n])
        # honest law, code R: product over distinct times of |C_t & band| / 2 eps*, C_t = intersection of cells
        clo = np.full(N, -np.inf)
        chi = np.full(N, np.inf)
        np.maximum.at(clo, kk, lo[:n])
        np.minimum.at(chi, kk, hi[:n])
        seen = np.zeros(N, dtype=bool)
        seen[kk] = True
        ov = np.minimum(chi, e_k + epsS) - np.maximum(clo, e_k - epsS)
        costHR = float(np.sum(-np.log2(np.minimum(ov[seen] / (2 * epsS), 1.0))))
        out("   %8d %8.4f %12.4f %12.4f %12.4f %12d" % (n, Kn / n, costP / n, costHQ / n, costHR / n, nS))
    out("   With repeated times the patched law withdraws the law at every refuted time, so all later data there")
    out("   are exceptions: its per-datum cost rises towards gamma*Pr[t eventually refuted], while code R's honest")
    out("   cost per datum falls (cells at one time intersect).  Prop 3.3's rates hold only for distinct times.")

    # ---------------- F
    out("\n== F. Prop 7.1(d): H^{eps_min} does not imply the common consequence T_0 \\/ T_N (W = 1, P = J R)")
    R = [[Fr(3, 5), Fr(-4, 5)], [Fr(4, 5), Fr(3, 5)]]
    J = [[Fr(0), Fr(-1)], [Fr(1), Fr(0)]]

    def mul(A, B):
        return [[sum(A[i][l] * B[l][j] for l in range(2)) for j in range(2)] for i in range(2)]

    def app(A, v):
        return [sum(A[i][l] * v[l] for l in range(2)) for i in range(2)]

    P = mul(J, R)
    eta = Fr(1, 100)
    a = [Fr(1), Fr(0)]
    Ra = app(R, a)
    etaPa = [eta * x for x in app(P, a)]
    Aa = [Ra[i] + etaPa[i] for i in range(2)]
    eps2 = sum(x * x for x in etaPa)
    x1 = [Ra[i] + etaPa[i] / 2 for i in range(2)]
    d2 = sum((x1[i] - Ra[i]) ** 2 for i in range(2))
    out("   Ra = %s, Aa = %s, eps_min(1)^2 = %s" % ([str(x) for x in Ra], [str(x) for x in Aa], eps2))
    out("   x_1 := Ra + eta P a / 2 = %s: |x_1 - Ra|^2 = %s <= eps_min^2: %s; x_1 = Ra: %s; x_1 = Aa: %s"
        % ([str(x) for x in x1], d2, d2 <= eps2, x1 == Ra, x1 == Aa))
    out("   so (x_0, x_1) = (a, x_1) is a real model of H^{eps_min}_1 and of neither T_0^1 nor T_N^1; the strongest")
    out("   common consequence of T_0^1 and T_N^1 is their disjunction, strictly stronger than H^{eps_min}_1.")

    # ---------------- G
    out("\n== G. Myrvold's decomposition without a product assumption (random joint laws on 3x4 outcomes)")
    worst = 0.0
    for _ in range(1000):
        Ph = rng.random((3, 4))
        Ph /= Ph.sum()
        Pb = rng.random((3, 4))
        Pb /= Pb.sum()
        i, j = rng.integers(0, 3), rng.integers(0, 4)
        I12 = math.log2(Ph[i, j] / Pb[i, j])
        I1 = math.log2(Ph[i].sum() / Pb[i].sum())
        I2 = math.log2(Ph[:, j].sum() / Pb[:, j].sum())
        U = I12 - I1 - I2
        Ih = math.log2(Ph[i, j] / (Ph[i].sum() * Ph[:, j].sum()))
        Ib = math.log2(Pb[i, j] / (Pb[i].sum() * Pb[:, j].sum()))
        worst = max(worst, abs(U - (Ih - Ib)))
    out("   max |U - (I(D1;D2|h) - I(D1;D2|b))| over 1000 random cases: %.2e" % worst)

    # ---------------- H
    out("\n== H. The constant of Props 3.7, 6.1(c): R/(2 e^2) for R = 21600' is %.1f' = %.2f deg"
        % (21600 / (2 * math.e ** 2), 21600 / (2 * math.e ** 2) / 60))

    out("\n# runtime %.1f s" % (time.time() - t0))
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
