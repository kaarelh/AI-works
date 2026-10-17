"""rb7_domains.py -- Referee B, thread `laws`: notes section 6 (domain restriction, retention), recomputed
independently of l8 from the saved residual series checks/l4_residuals.npz (read only).

A. Prop 6.1 on the Moon over one year: per-datum rates of its data under X (domain restriction: literal,
   gamma), P (exact law with deterministic patches, code Q; random exceptions, code R) and H (honest law, code Q
   / code R), exact over the dither in the coarse regime and with 512 stratified dithers per time otherwise.
   The point: in code Q with Delta <= 2 eps*, H is silent on EVERY datum, so its per-datum cost equals X's
   (gamma) identically; by Thm 3.8(ii) the constants decide forever (X: lam |Dom|, H: lam (k + h)), so X wins
   although gamma < min(m_P, m_H) FAILS (gamma = m_H).  Prop 6.1(b) as stated says the restriction is
   eventually in the MAP iff gamma < min(m_P, m_H) -- false at this tie, which is the record's own main example.
B. Prop 6.2: Delta* (least cell width at which the honest Kepler law K, tolerance eps* of the window, has a
   lower rate than an exact successor N with derivation charges c_N per datum, c_K = c_N/1000), codes Q and R,
   for Mars over 12 years and the Moon over a month (record: Mars 12 y Q 1200', 197', 28'; R 177', 17.8', 2.92';
   Moon 1 month Q 8460', 2100', 369'; R 4520', 454', 62.4'), by bisection on the exact rate (no grid).
   Also checks that the code-R rate of K is non-increasing in Delta (used in Prop 6.2(c)).
Deterministic.  Writes rb7_domains.out next to itself.
"""
import math
import os
import sys
import time
import numpy as np

OUT = []
RANGE = 21600.0
HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "checks", "l4_residuals.npz")
LOG2E = math.log2(math.e)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = np.clip(np.asarray(x, float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


def honest_rates(e, eps, D, nu=512):
    """(Pr[silent], code-R expected cost) of the honest law with tolerance eps (eps >= max|e|)."""
    if D >= 2 * eps:                      # coarse regime: exact (Lemma 3.2, Lemma 3.6)
        q = 2 * eps / D
        w = (eps - e) / (2 * eps)
        return q, q * (LOG2E - float(np.mean(H2(w))))
    u = (np.arange(nu) + 0.5) / nu
    E = e[:, None]
    lo, hi = -u[None, :] * D, (1 - u[None, :]) * D
    blo, bhi = E - eps, E + eps
    pr = (blo >= lo) & (bhi < hi)
    ov = np.clip(np.minimum(hi, bhi) - np.maximum(lo, blo), 0, None)
    costR = np.where(pr, 0.0, -np.log2(np.maximum(ov, 1e-300) / (2 * eps)))
    return float(np.mean(~pr)), float(np.mean(costR))


def main():
    t0 = time.time()
    out("# rb7_domains.py (deterministic) python %s numpy %s" % (sys.version.split()[0], np.__version__))
    Z = np.load(RES, allow_pickle=False)

    # ---------------- A
    out("\n== A. Prop 6.1, the Moon over one year (k = 60, h = 20, |Dom| = 4, pi_c = log2 365 + 2)")
    em = Z["Moon_1year_e_mean"].astype(float)
    ex = Z["Moon_1year_e_max"].astype(float)
    eps = float(np.max(np.abs(ex)))
    pic = math.log2(365.25) + 2
    k, h, dom = 60.0, 20.0, 4.0
    out("   eps* = %.2f', E|e| (mean fit) = %.2f'" % (eps, float(np.mean(np.abs(em)))))
    out("   Delta lam | gamma | P(Q)    H(Q)    | P(R)    H(R)    | H(Q) - gamma | asymptotic winner Q (rates, then constants on exact ties) / R")
    for D in (10.0, 60.0, 300.0, 600.0, 1800.0):
        g = math.log2(RANGE / D)
        p = float(np.mean(np.minimum(np.abs(em) / D, 1.0)))
        qs, hR = honest_rates(ex, eps, D)
        for lam in (1.0, 2.0):
            PQ = p * (lam * pic + g)
            PR = float(H2(np.array([p]))[0]) + p * g if p > 0 else 0.0
            HQ = qs * g
            # Q: candidates (rate, constant): X (g, lam dom), P (PQ, lam k), H (HQ, lam (k + h))
            candQ = sorted([(g, lam * dom, "X"), (PQ, lam * k, "P"), (HQ, lam * (k + h), "H")])
            exact_tie = abs(HQ - g) < 1e-12 and qs == 1.0
            # winner: least rate; if the two least rates are equal AND the per-datum costs are identical a.s.
            # (H silent on every datum: qs == 1), the constant decides
            if exact_tie and min(PQ, g) == g:
                winQ = "X" if lam * dom < lam * (k + h) else "H"
                note = " (exact tie X = H per datum; constants decide)"
            else:
                winQ = candQ[0][2]
                note = ""
            candR = sorted([(g, "X"), (PR, "P"), (hR, "H")])
            out("   %5.0f %3.0f | %5.2f | %7.3f %7.3f | %7.3f %7.3f | %12.2e | %s%s / %s" % (
                D, lam, g, PQ, HQ, PR, hR, HQ - g, winQ, note, candR[0][1]))
            if exact_tie:
                out("         gamma < min(m_P, m_H)? %s  (Prop 6.1(b) predicts restriction iff this holds)" % (g < min(PQ, HQ)))

    # ---------------- B
    out("\n== B. Prop 6.2: Delta* by bisection on the exact rates (c_K = c_N/1000)")
    for key, label in (("Mars_12", "Mars 12 y"), ("Moon_1month", "Moon 1 month")):
        e = Z[key + "_e_max"].astype(float)
        eps = float(np.max(np.abs(e)))

        def mK(D, code, cN):
            cK = cN / 1000
            qs, hR = honest_rates(e, eps, D)
            g = math.log2(RANGE / D)
            if code == "Q":
                return qs * g + (1 - qs) * cK
            return hR + (1 - qs) * cK      # hR already includes the silence probability
        cells = []
        for code in ("Q", "R"):
            for cN in (0.01, 0.1, 1.0):
                lo, hi = 0.01, 10800.0
                if mK(hi, code, cN) >= cN:
                    cells.append("%s c_N=%g: never" % (code, cN))
                    continue
                for _ in range(60):
                    mid = math.sqrt(lo * hi)
                    if mK(mid, code, cN) < cN:
                        hi = mid
                    else:
                        lo = mid
                cells.append("%s c_N=%g: %.4g'" % (code, cN, hi))
        out("   %-12s eps* = %6.2f' | %s" % (label, eps, " | ".join(cells)))
        # monotonicity of the code-R rate of K (without derivation charges) in Delta
        Ds = np.exp(np.linspace(math.log(0.05), math.log(10800), 120))
        vals = [honest_rates(e, eps, D)[1] for D in Ds]
        inc = [(Ds[i], vals[i], vals[i + 1]) for i in range(len(Ds) - 1) if vals[i + 1] > vals[i] + 1e-9]
        out("      code-R rate of K non-increasing on a 120-point log grid of Delta in [0.05', 10800']: %s%s" % (
            not inc, "" if not inc else " (first increase at Delta=%.3g: %.5f -> %.5f)" % inc[0]))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb7_domains.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
