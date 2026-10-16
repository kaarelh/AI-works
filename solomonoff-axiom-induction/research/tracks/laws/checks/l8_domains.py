"""l8_domains.py -- domains of applicability and retention of superseded theories (thread `laws`, T6;
notes section 6).  Small computed instances of Props 6.1 and 6.2 on the real residuals of l4.

Seed 20261016.  Reads l4_residuals.npz; writes l8_domains.out next to itself.

Revision note (notes-final.md, Setting S3; referee A M1): the draw t ~ U[0,1) stands for a FRESH time at each
datum (distinct numerals t_j) with the error e(t_j) and the dither u_j i.i.d.; a law on numerals cannot be atomless.
The deterministic-patch pricings (Q/det, R/det) with a constant pi_c are a finite-horizon cost model
(notes-final Prop 3.3a); the randomised pricings are exact theory-machine costs for all n.
Revision note (referee B 4, 5): part A's code-Q cell Delta = 600', lam = 2 is decided by Monte Carlo noise
(exactly, P has the lower rate), and part B's code-R column c_N = 1 uses the fine-regime UPPER bound; both are
recomputed exactly in l10_revision.out parts E, F.

A. Domain restriction (Prop 6.1).  A Kepler law for the bodies of a population, which also contains the
   Moon (geocentric, residuals of one fixed ellipse over one year).  Per-datum rates for the Moon's data under:
     P  : the unrestricted law with exceptions (Moon elements in the theory; refuted data patched),
     H  : the unrestricted law with an honest Moon tolerance (eps*_Moon; Moon elements in the theory),
     X  : the law restricted to a domain that excludes the Moon (Moon data literal, rate gamma),
   in code Q (det patches, pi_c = log2 365 + 2) and code R (random completion, random exceptions).
   Restriction costs lam |Dom| once (|Dom| = 4 bits for a base predicate 'Planet', 7 bits for 'b != Moon'
   among 8 bodies); the honest tolerance costs lam h once (h = 20 bits); elements cost lam k (k = 60).
   Reported: asymptotic winner (least rate) and the number of Moon data after which it beats the others.
B. Retention by usage cost (Prop 6.2).  The honest Kepler law K (tolerance eps*_K on a window) against an
   exact successor N, with derivation charges: c_N = r_d dl_N bits per datum derived from N and
   c_K = c_N / 1000 per datum derived from K (ASSUMED ratio dl_N / dl_K = 1000, e.g. a validated integration
   against solving Kepler's equation; not measured), c_N in {0.01, 0.1, 1} bits.  Per-datum rates:
     K: gamma_si * q_K + (1 - q_K) c_K,    N: c_N,
   with q_K = min(2 eps*/Delta, 1) and gamma_si = gamma (code Q) or the code-R cost of silence.  Reported:
   the precision Delta* above which K is retained (K's rate below N's), per body and window.
"""
import math
import os
import sys
import time
import numpy as np

SEED = 20261016
OUT = []
RANGE = 21600.0


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = min(max(x, 1e-300), 1 - 1e-16)
    return -x * math.log2(x) - (1 - x) * math.log2(1 - x)


def rates(e_mean, e_max, Delta, lam, pic, rng):
    """per-datum rates of P (exact with exceptions) and H (honest, eps* = max|e_max|) in codes Q and R."""
    g = math.log2(RANGE / Delta)
    eps = float(np.max(np.abs(e_max)))
    # exact law: refutation probability, exact over the dither (Lemma 3.2)
    p = float(np.mean(np.minimum(np.abs(e_mean) / Delta, 1.0)))
    PQ = p * (lam * pic + g)
    PR = min(p * (lam * pic + g), H2(p) + p * g) if p > 0 else 0.0
    # honest law: silence; code Q cost gamma per silent datum; code R by Monte Carlo over 20 dithers
    u = rng.random(e_max.size * 20)
    e = np.repeat(e_max, 20)
    lo, hi = -u * Delta, (1 - u) * Delta
    blo, bhi = e - eps, e + eps
    pr = (blo >= lo) & (bhi < hi)
    ov = np.clip(np.minimum(hi, bhi) - np.maximum(lo, blo), 0, None)
    sil = ~pr
    HQ = float(np.mean(sil)) * g
    HR = float(np.mean(np.where(sil, -np.log2(np.where(sil, ov, 1.0) / (2 * eps)), 0.0)))
    return dict(g=g, p=p, PQ=PQ, PR=PR, HQ=HQ, HR=HR, eps=eps)


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    here = os.path.dirname(os.path.abspath(__file__))
    Z = np.load(os.path.join(here, "l4_residuals.npz"))
    out("# l8_domains.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. the Moon (one fixed ellipse over one year) inside a Kepler law: per-datum rates of its data")
    em, ex = Z["Moon_1year_e_mean"].astype(float), Z["Moon_1year_e_max"].astype(float)
    pic = math.log2(365.25) + 2
    k, h, dom_pred, dom_name = 60.0, 20.0, 4.0, 7.0
    out("   eps*_Moon = %.1f', E|e| = %.1f'; pi_c = %.2f; k = %g, h = %g, |Dom| = %g (Planet) or %g (b != Moon)" % (
        float(np.max(np.abs(ex))), float(np.mean(np.abs(em))), pic, k, h, dom_pred, dom_name))
    out("   %6s %4s | %7s | %8s %8s %8s | %8s %8s %8s | winner Q / R; n after which the winner leads (Q / R)" % (
        "Delta", "lam", "gamma", "P(Q)", "H(Q)", "X", "P(R)", "H(R)", "X"))
    for Delta in (10.0, 60.0, 300.0, 600.0, 1800.0):
        for lam in (1.0, 2.0):
            r = rates(em, ex, Delta, lam, pic, rng)
            g = r["g"]
            fixed = {"P": lam * k, "H": lam * (k + h), "X": lam * dom_pred}
            res = []
            for code, rP, rH in (("Q", r["PQ"], r["HQ"]), ("R", r["PR"], r["HR"])):
                rate = {"P": rP, "H": rH, "X": g}
                w = min(rate, key=lambda x: (rate[x], fixed[x]))
                # data after which w beats every other form forever (in expectation)
                n_star = 0.0
                for o in rate:
                    if o == w:
                        continue
                    if fixed[w] > fixed[o]:
                        n_star = max(n_star, (fixed[w] - fixed[o]) / max(rate[o] - rate[w], 1e-12))
                res.append((w, n_star))
            out("   %6g %4g | %7.2f | %8.3f %8.3f %8.3f | %8.3f %8.3f %8.3f | %s / %s;  n* = %.0f / %.0f" % (
                Delta, lam, g, r["PQ"], r["HQ"], g, r["PR"], r["HR"], g, res[0][0], res[1][0], res[0][1], res[1][1]))

    # ---------------- B
    out("\n== B. retention of the honest Kepler law against an exact successor with derivation charges")
    out("   ASSUMED: c_N = bits per datum to derive it from N; c_K = c_N/1000 (derivation-size ratio 1000)")
    out("   Delta* = least cell width (grid of 400 log-spaced values in [0.01', 10800']) at which K's rate is below N's"
        " (K is then retained for all coarser data; '-' if never)")
    out("   %-8s %7s | %8s | %10s %10s %10s | %10s %10s %10s" % ("body", "window", "eps*", "Q c_N=.01", "Q c_N=.1",
                                                             "Q c_N=1", "R c_N=.01", "R c_N=.1", "R c_N=1"))
    grid = np.logspace(-2, math.log10(10800.0), 400)
    for body, W in (("Mercury", "100"), ("Mars", "12"), ("Mars", "2000"), ("Jupiter", "100"), ("Saturn", "2000"),
                    ("Moon", "1month")):
        ex = Z["%s_%s_e_max" % (body, W)].astype(float)
        eps = float(np.max(np.abs(ex)))
        cells = []
        for code in ("Q", "R"):
            for cN in (0.01, 0.1, 1.0):
                cK = cN / 1000
                ds = None
                for D in grid:
                    q = min(2 * eps / D, 1.0)
                    g = math.log2(RANGE / D)
                    if code == "Q":
                        gsi = g
                    else:
                        # code-R cost of silence: coarse-regime formula (Lemma 3.6) or the fine-regime upper bound
                        if D >= 2 * eps:
                            w = np.clip((eps - ex) / (2 * eps), 1e-12, 1 - 1e-12)
                            gsi = math.log2(math.e) - float(np.mean(-w * np.log2(w) - (1 - w) * np.log2(1 - w)))
                        else:
                            gsi = math.log2(2 * eps / D) + 2 * math.log2(math.e)
                    rK = gsi * q + (1 - q) * cK
                    if rK < cN:
                        ds = D
                        break
                cells.append(("%.3g'" % ds) if ds is not None else "-")
        out("   %-8s %7s | %7.2f' | %s" % (body, W, eps, " ".join("%10s" % c for c in cells)))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
