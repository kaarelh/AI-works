"""l3_phases.py -- honest approximate laws against laws with exceptions (thread `laws`, T3): event
probabilities, per-datum rates, the peakedness criterion, the optimal tolerance, almost-sure phases and
switch times, ties.

Seed 20261016.  Writes l3_phases.out next to itself.  Independent of scout N2's n3 (written from the
statements of notes.md section 3).

Setting (notes section 3.1).  A quantity q on a circle of circumference 21600' (360 deg); exact law f = q + e(t),
t ~ U[0,1); data: the dithered cell of width Delta containing q(t).  Relative to q (placed at 0) the cell is
[-u Delta, (1-u) Delta), u ~ U[0,1), and the band of the tolerance law T^eps is [e - eps, e + eps].
    T^eps proves the datum  iff band inside the cell;  refutes it iff band and cell are disjoint;  silent otherwise.
    code R cost of a datum (random completion inside the band) = -log2(|cell & band| / 2 eps).
Error shapes: spread e = A sin(2 pi t) (pk = pi/2); peaked e = +-A on 5% of times (pk = 20); A = eps* = 1'.
Forms: 0 (no law), E (exact law, refuted -> infinite), P (exact law patched at refuted times, deterministic:
lam pi_c + gamma per refuted datum), H (honest law T^{eps*}, code Q: gamma per silent datum), N (exact true law).
Parts:
    A. Lemma 3.2: proves/silent/refutes probabilities against the formulas; Lemma 3.6: code-R silent cost.
    B. per-datum rates of P and H (code Q, deterministic patches) against Prop 3.3, and the criterion.
    C. Prop 3.5: the optimal tolerance of a patched tolerance law and the exception share theta_ex.
    D. Thm 3.8 / Cor 3.9: phase sequences of the lambda-MAP as n grows, and switch times against Wald's bounds.
    E. ties (Thm 3.8(iii)): sign changes of J(P) - J(H) when the rates are equal.
    F. Thm 3.8(iii): first-passage time over level L, divided by L, against 1/(m_P - m_H).
    G. Prop 3.4 under the four pricings (Q/det, Q/rand, R/det, R/rand) for the two error shapes.
"""
import math
import sys
import time
import numpy as np

SEED = 20261016
OUT = []
RANGE = 21600.0


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def err(kind, t, A=1.0, rho=0.05):
    if kind == "spread":
        return A * np.sin(2 * np.pi * t)
    e = np.zeros_like(t)
    e[t < rho / 2] = A
    e[(t >= 0.5) & (t < 0.5 + rho / 2)] = -A
    return e


def events(e, eps, Delta, u):
    """returns (proves, refutes, overlap_length) for band [e-eps, e+eps] and cell [-u D, (1-u) D)."""
    lo, hi = -u * Delta, (1 - u) * Delta
    blo, bhi = e - eps, e + eps
    proves = (blo >= lo) & (bhi < hi)
    ov = np.clip(np.minimum(hi, bhi) - np.maximum(lo, blo), 0, None)
    refutes = ov <= 0
    if eps == 0:
        proves = (e >= lo) & (e < hi)
        refutes = ~proves
    return proves, refutes, ov


def H2(x):
    x = np.clip(x, 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    out("# l3_phases.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. Lemma 3.2: Pr[prove], Pr[refute] given e, for T^eps and cell width Delta (2*10^6 dithers each)")
    out("   formulas: refute = min((|e|-eps)^+/Delta, 1); prove = (1 - (eps + max(|e|, eps))/Delta)^+; silent = rest")
    m = 2_000_000
    worst = 0.0
    for (e0, eps, Delta) in [(0.3, 1.0, 10.0), (1.0, 1.0, 10.0), (2.5, 1.0, 10.0), (0.7, 0.0, 10.0), (0.7, 1.0, 1.5),
                             (3.0, 1.0, 1.5), (0.2, 0.5, 0.5), (12.0, 1.0, 10.0)]:
        u = rng.random(m)
        pr, rf, _ = events(np.full(m, e0), eps, Delta, u)
        f_rf = min(max(abs(e0) - eps, 0) / Delta, 1.0)
        f_pr = max(1 - (eps + max(abs(e0), eps)) / Delta, 0.0)
        worst = max(worst, abs(pr.mean() - f_pr), abs(rf.mean() - f_rf))
        out("   e=%5.2f eps=%4.2f Delta=%5.2f: prove %.4f (formula %.4f)  refute %.4f (formula %.4f)  silent %.4f" % (
            e0, eps, Delta, pr.mean(), f_pr, rf.mean(), f_rf, 1 - pr.mean() - rf.mean()))
    out("   largest deviation from the formulas: %.4f (Monte Carlo standard error ~ 3.5e-4)" % worst)
    out("\n   Lemma 3.6: code-R cost given a straddle, E[-log2(|cell & band|/2eps)], against log2(e) - H2(w),"
        " w = (eps - e)/(2 eps); Delta = 10, eps = 1")
    for e0 in (0.0, 0.5, 0.9, 0.999, -0.6):
        u = rng.random(m)
        pr, rf, ov = events(np.full(m, e0), 1.0, 10.0, u)
        sil = ~pr & ~rf
        c = -np.log2(ov[sil] / 2.0)
        w = (1.0 - e0) / 2.0
        out("   e=%6.3f: simulated %.4f  formula %.4f   (straddle share %.4f vs 2eps/Delta = 0.2)" % (
            e0, c.mean(), math.log2(math.e) - H2(np.array([w]))[0], sil.mean()))
    for kind in ("spread", "peaked"):
        tt = rng.random(m)
        e = err(kind, tt)
        w = (1.0 - e) / 2.0
        beta = math.log2(math.e) - float(np.mean(H2(w)))
        out("   beta_e for the %s error: %.4f  (bounds log2 e - 1 = %.4f, log2 e = %.4f)" % (
            kind, beta, math.log2(math.e) - 1, math.log2(math.e)))

    # ---------------- B
    out("\n== B. rates per datum, code Q, deterministic patches (Prop 3.3): m_P = p(lam pi_c + gamma), m_H = q gamma")
    out("   pi_c = 22 bits; gamma = log2(21600/Delta); simulated over 4*10^6 data; criterion: H wins iff"
        " pk < (lam pi_c + gamma)/(2 gamma)")
    pi_c = 22.0
    for kind, pk in (("spread", math.pi / 2), ("peaked", 20.0)):
        for Delta in (2.0, 3.0, 10.0, 60.0):
            g = math.log2(RANGE / Delta)
            tt = rng.random(4_000_000)
            u = rng.random(4_000_000)
            e = err(kind, tt)
            _, rf0, _ = events(e, 0.0, Delta, u)
            prH, rfH, _ = events(e, 1.0, Delta, u)
            p_sim, q_sim = rf0.mean(), (~prH).mean()
            Ee = 2 / math.pi if kind == "spread" else 0.05
            for lam in (1.0, 2.0):
                mP, mH = p_sim * (lam * pi_c + g), q_sim * g
                thr = (lam * pi_c + g) / (2 * g)
                out("   %-6s Delta=%5.1f lam=%.0f: p=%.5f (E|e|/D=%.5f) q=%.5f (2/D=%.5f)  m_P=%7.4f m_H=%7.4f -> %s;"
                    " pk=%.2f vs threshold %.2f -> %s" % (
                        kind, Delta, lam, p_sim, Ee / Delta, q_sim, min(2 / Delta, 1), mP, mH,
                        "H" if mH < mP else "P", pk, thr, "H" if pk < thr else "P"))

    # ---------------- C
    out("\n== C. optimal tolerance of a patched tolerance law (Prop 3.5), code Q, deterministic patches, Delta = 10'")
    out("   rate(eps) = gamma Pr[not proved] + lam pi_c Pr[refuted]; predicted: Pr[|e| > eps_opt] = theta_ex ="
        " 2 gamma/(gamma + lam pi_c)")
    Delta = 10.0
    g = math.log2(RANGE / Delta)
    tt = rng.random(1_000_000)
    u = rng.random(1_000_000)
    for kind in ("spread", "uniform-abs"):
        e = err("spread", tt) if kind == "spread" else (2 * tt - 1)  # |e| ~ U[0,1] for the second
        for lam in (1.0, 2.0, 4.0):
            theta = 2 * g / (g + lam * pi_c)
            grid = np.linspace(0, 1, 101)
            rates = []
            for eps in grid:
                pr, rf, _ = events(e, eps, Delta, u)
                rates.append(g * (1 - pr.mean()) + lam * pi_c * rf.mean())
            rates = np.array(rates)
            i = int(np.argmin(rates))
            # predicted eps_opt: the (1-theta) quantile of |e|
            eps_pred = float(np.quantile(np.abs(e), 1 - theta)) if theta < 1 else 0.0
            out("   %-11s lam=%.0f: theta_ex=%.3f  eps_opt(grid)=%.2f  eps_opt(predicted)=%.3f  rate(opt)=%.4f"
                "  rate(eps=0)=%.4f  rate(eps*=1)=%.4f" % (kind, lam, theta, grid[i], eps_pred, rates[i], rates[0],
                                                          rates[-1]))

    # ---------------- D
    out("\n== D. phases of the lambda-MAP as n grows (code Q, deterministic patches); 400 runs per row")
    out("   lengths: l_0 = 200 (exact law), h = 20 (tolerance clause), h_N = 2000 (better theory); pi_c = 22")
    out("   phase string = successive lambda-MAP forms (0 no law, E exact law unpatched, P patched, H honest, N better)")
    runs = 400
    l0, h, hN = 200.0, 20.0, 2000.0
    for kind, Delta, lam, nmax in (("spread", 1.5, 1.0, 4000), ("spread", 3.0, 2.0, 4000), ("spread", 10.0, 2.0, 4000),
                                   ("spread", 3.0, 1.0, 4000), ("spread", 60.0, 1.0, 12000),
                                   ("spread", 60.0, 2.0, 30000), ("peaked", 10.0, 1.0, 4000)):
        g = math.log2(RANGE / Delta)
        seqs = {}
        sw = {"P->H": [], "H->N": [], "first refutation": []}
        mP = mH = None
        for r_ in range(runs):
            tt = rng.random(nmax)
            u = rng.random(nmax)
            e = err(kind, tt)
            _, rf0, _ = events(e, 0.0, Delta, u)
            prH, _, _ = events(e, 1.0, Delta, u)
            n = np.arange(1, nmax + 1)
            R0 = np.cumsum(rf0)
            S = np.cumsum(~prH)
            J = {"0": n * g,
                 "E": np.where(R0 == 0, lam * l0, np.inf),
                 "P": np.where(R0 > 0, lam * l0 + R0 * (lam * pi_c + g), np.inf),
                 "H": lam * (l0 + h) + S * g,
                 "N": np.full(nmax, lam * (l0 + hN))}
            order = ["0", "E", "P", "H", "N"]  # ties -> earlier (shorter) form
            M = np.vstack([J[k] for k in order])
            win = np.argmin(M, axis=0)
            s = []
            for w in win:
                if not s or s[-1] != order[w]:
                    s.append(order[w])
            key = "".join(s)
            seqs[key] = seqs.get(key, 0) + 1
            if np.any(rf0):
                sw["first refutation"].append(int(np.argmax(rf0)) + 1)
            dPH = (lam * l0 + R0 * (lam * pi_c + g)) - J["H"]  # P with no patch is E
            idx = np.where(dPH > 0)[0]
            if idx.size:
                sw["P->H"].append(int(idx[0]) + 1)
            dHN = J["H"] - J["N"]
            idx = np.where(dHN > 0)[0]
            if idx.size:
                sw["H->N"].append(int(idx[0]) + 1)
        p = float(np.mean(np.minimum(np.abs(err(kind, rng.random(10 ** 6))) / Delta, 1)))
        q = min(2.0 / Delta, 1.0)
        mP, mH = p * (lam * pi_c + g), q * g
        top = sorted(seqs.items(), key=lambda kv: -kv[1])[:4]
        out("   %-6s Delta=%4.1f lam=%.0f: rates m_P=%.3f m_H=%.3f; sequences %s" % (
            kind, Delta, lam, mP, mH, ", ".join("%s (%d)" % kv for kv in top)))
        # Wald bounds for the P/H race started at n=0: level lam*h, increments in [-g, lam pi_c + g]
        if mP > mH:
            lo_, hi_ = lam * h / (mP - mH), (lam * h + lam * pi_c + g) / (mP - mH)
            out("      first n with J(H) < J(P): mean %.1f (%d runs), Wald bounds for the race from n = 0: [%.1f, %.1f]" % (
                np.mean(sw["P->H"]) if sw["P->H"] else float("nan"), len(sw["P->H"]), lo_, hi_))
        lo_, hi_ = lam * (hN - h) / mH, (lam * (hN - h) + g) / mH
        out("      first n with J(N) < J(H): mean %.1f (%d runs), Wald bounds [%.1f, %.1f];"
            " first refutation: mean %.1f vs 1/p = %.1f" % (
                np.mean(sw["H->N"]) if sw["H->N"] else float("nan"), len(sw["H->N"]), lo_, hi_,
                np.mean(sw["first refutation"]) if sw["first refutation"] else float("nan"), 1 / p))

    # ---------------- E
    out("\n== E. ties (Thm 3.8(iii)): spread error, Delta = 10', lam = 1, pi_c chosen so that m_P = m_H")
    Delta = 10.0
    g = math.log2(RANGE / Delta)
    p = 2 / math.pi / Delta
    q = 2 / Delta
    pi_tie = (q * g / p - g)
    out("   pi_c(tie) = %.4f; increments c_P - c_H have mean 0 and positive variance" % pi_tie)
    for label, pic in (("tie", pi_tie), ("m_P > m_H by 10%", pi_tie * 1.1 + 0.1 * g)):
        ch = []
        for r_ in range(100):
            nn = 200_000
            tt = rng.random(nn)
            u = rng.random(nn)
            e = err("spread", tt)
            _, rf0, _ = events(e, 0.0, Delta, u)
            prH, _, _ = events(e, 1.0, Delta, u)
            d = np.cumsum(rf0 * (pic + g) - (~prH) * g) - 20.0  # J(P) - J(H), lam = 1, h = 20
            sgn = np.sign(d)
            changes = np.nonzero(sgn[1:] != sgn[:-1])[0]
            ch.append((int(np.sum(changes < 2000)), int(np.sum(changes < 200_000)),
                       int(changes[-1]) + 2 if changes.size else 0))
        ch = np.array(ch)
        out("   %-17s: mean sign changes of J(P)-J(H) up to n=2000: %.1f, up to n=200000: %.1f;"
            " median last change %d; share of runs with a change after n=100000: %.2f" % (
                label, ch[:, 0].mean(), ch[:, 1].mean(), int(np.median(ch[:, 2])), np.mean(ch[:, 2] > 100_000)))

    # ---------------- F
    out("\n== F. (Thm 3.8(iii)) first passage over level L of S_n = sum (c_P - c_H), divided by L, against 1/(m_P - m_H)")
    Delta, lam = 3.0, 2.0
    g = math.log2(RANGE / Delta)
    nn = 400_000
    tt = rng.random(nn)
    u = rng.random(nn)
    e = err("spread", tt)
    _, rf0, _ = events(e, 0.0, Delta, u)
    prH, _, _ = events(e, 1.0, Delta, u)
    inc = rf0 * (lam * pi_c + g) - (~prH) * g
    mu = (2 / math.pi / Delta) * (lam * pi_c + g) - (2 / Delta) * g
    S = np.cumsum(inc)
    for L in (10.0, 100.0, 1000.0, 10000.0, 30000.0, 100000.0):
        tau = int(np.argmax(S > L)) + 1 if np.any(S > L) else -1
        out("   L=%8.0f: tau=%7d  tau/L=%.4f  (1/mu = %.4f)" % (L, tau, tau / L, 1 / mu))

    # ---------------- G
    out("\n== G. the four pricings (Prop 3.4), coarse regime, exact formulas: m_P = p gamma_ex, m_H = q gamma_si;"
        " pi_c = 22, lambda = 1")
    out("   gamma_ex: det lam pi_c + gamma, rand gamma + H2(p)/p; gamma_si: Q gamma, R beta_e (Lemma 3.6)")
    tt = rng.random(2_000_000)
    for kind in ("spread", "peaked"):
        e = err(kind, tt)
        Ee = float(np.mean(np.abs(e)))
        w = (1.0 - e) / 2.0
        beta = math.log2(math.e) - float(np.mean(H2(w)))
        for Delta in (3.0, 10.0, 60.0):
            g = math.log2(RANGE / Delta)
            p, q = Ee / Delta, 2.0 / Delta
            h2p = float(H2(np.array([p]))[0])
            cells = []
            for pr, gex, gsi in (("Q/det", 22 + g, g), ("Q/rand", g + h2p / p, g), ("R/det", 22 + g, beta),
                                 ("R/rand", g + h2p / p, beta)):
                mP, mH = p * gex, q * gsi
                cells.append("%s: P %.3f H %.3f -> %s (thr %.2f)" % (pr, mP, mH, "H" if mH < mP else "P",
                                                                     gex / (2 * gsi)))
            out("   %-6s pk=%5.2f Delta=%4.0f: %s" % (kind, 1 / Ee, Delta, ";  ".join(cells)))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
