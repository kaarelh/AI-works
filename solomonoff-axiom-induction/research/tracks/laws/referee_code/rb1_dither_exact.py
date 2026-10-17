"""rb1_dither_exact.py -- Referee B, thread `laws`: exact checks of the dither lemmas and the selection formulas
of notes sections 2-3, written independently of the developer's l2/l3 (no Monte Carlo where an exact value exists).

A. Lemma 3.2 in EXACT rational arithmetic, all regimes: for band [e-eps, e+eps] and cell [-u D, (1-u) D),
   u ~ U[0,1), the u-sets {band inside cell} and {band misses cell} are intervals, computed here from the two
   inequalities directly and intersected with [0,1); compared with the record's closed forms
   refute = min((|e|-eps)^+/D, 1), prove = (1 - (eps + max(|e|,eps))/D)^+.
B. Lemma 3.6: the coarse straddle cost log2 e - H2(w) by quadrature; the fine-regime bound
   E[-log2(y/D)] <= 2 log2 e (y = q's cell inside the band) maximised over a grid of (w, L/D).
C. Prop 3.5 with discrete error distributions WITH ATOMS, exact rationals: argmin set of
   c(eps) = 2 eps gamma + (lam pi_c + gamma) E(|e| - eps)^+ over [0, eps*] against the quantile rule
   {eps : Pr[|e| > eps] <= theta <= Pr[|e| >= eps]}, theta = 2 gamma/(lam pi_c + gamma) (and eps = 0 if theta >= 1).
D. Prop 3.4: thresholds gamma_ex/(2 gamma_si) for the four pricings, sinusoid (E|e| = 2/pi exactly) and the
   peaked error, pi_c = 22, lambda = 1, Delta in {3', 10', 60'} (record: Q/rand 0.64, 0.74, 0.97; R/rand
   9.2-9.3 sinusoid, 20.4-20.5 peaked); beta_e exact (record 0.885, 0.493).
E. Prop 2.4 regime G: r(delta) = Pr[|e - eta| > delta], eta ~ U[-1/2, 1/2], by quadrature (record l2 A:
   0.218 at delta = 1, 6.14e-4 at 1.49, 0 at >= 1.5).
F. Prop 2.5 regime R: exact p_Delta and 1/p_Delta (record l2 B uses Monte Carlo values 94.2, 943.4, 12006).
Seed 20261016.  Writes rb1_dither_exact.out next to itself.
"""
import math
import os
import random
import sys
import time
from fractions import Fraction as Fr
import numpy as np

SEED = 20261016
OUT = []
HERE = os.path.dirname(os.path.abspath(__file__))
LOG2E = math.log2(math.e)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def ilen(lo, hi, closed_lo=True):
    """length of [lo, hi) intersected with [0, 1)."""
    a, b = max(lo, Fr(0)), min(hi, Fr(1))
    return b - a if b > a else Fr(0)


def exact_events(e, eps, D):
    """exact Pr over u of prove / refute (band closed [e-eps, e+eps], cell [-uD, (1-u)D))."""
    # prove: -uD <= e - eps  and  e + eps < (1-u) D   <=>  u >= (eps - e)/D  and  u < (D - e - eps)/D
    pr = ilen((eps - e) / D, (D - e - eps) / D)
    if eps == 0:
        # exact law: point e inside cell: -uD <= e < (1-u)D <=> u >= -e/D and u < 1 - e/D
        pr = ilen(-e / D, 1 - e / D)
        return pr, 1 - pr
    # refute: e - eps >= (1-u) D  or  e + eps < -u D   <=>  u >= 1 - (e - eps)/D  or  u < -(e + eps)/D
    r1 = ilen(1 - (e - eps) / D, Fr(10))
    r2 = ilen(Fr(-10), -(e + eps) / D)
    return pr, r1 + r2


def H2(x):
    x = np.clip(np.asarray(x, float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


def main():
    t0 = time.time()
    rng = random.Random(SEED)
    nrng = np.random.default_rng(SEED)
    out("# rb1_dither_exact.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. Lemma 3.2 in exact rational arithmetic, random (e, eps, Delta) in all regimes")
    bad = 0
    N = 20000
    for _ in range(N):
        D = Fr(rng.randint(1, 60), rng.randint(1, 6))
        eps = Fr(rng.randint(0, 40), rng.randint(1, 8)) if rng.random() < 0.9 else Fr(0)
        e = Fr(rng.randint(-80, 80), rng.randint(1, 8))
        pr, rf = exact_events(e, eps, D)
        a = abs(e)
        f_rf = min(max(a - eps, Fr(0)) / D, Fr(1))
        f_pr = max(1 - (eps + max(a, eps)) / D, Fr(0))
        if eps == 0:
            f_rf = min(a / D, Fr(1))
            f_pr = 1 - f_rf
        if pr != f_pr or rf != f_rf:
            bad += 1
            if bad <= 5:
                out("   mismatch e=%s eps=%s D=%s: exact prove %s refute %s, formula %s %s" % (e, eps, D, pr, rf, f_pr, f_rf))
    out("   %d random cases (D in (0,60], eps in [0,40], e in [-80,80]): %d mismatches with the closed forms" % (N, bad))
    # coarse-regime silence = 2 eps / D exactly
    bad = 0
    for _ in range(5000):
        D = Fr(rng.randint(10, 100))
        eps = Fr(rng.randint(1, 40), 8)
        e = Fr(rng.randint(-int(8 * eps), int(8 * eps)), 8)
        if D < eps + max(abs(e), eps):
            continue
        pr, rf = exact_events(e, eps, D)
        bad += (1 - pr - rf) != 2 * eps / D
    out("   coarse regime (D >= eps + max(|e|, eps)): silence probability = 2 eps/D exactly; mismatches: %d" % bad)

    # ---------------- B
    out("\n== B. Lemma 3.6")
    V = (np.arange(200000) + 0.5) / 200000
    worst = 0.0
    for w in np.linspace(0, 1, 41):
        c = float(np.mean(np.where(V > w, -np.log2(V), -np.log2(1 - V))))
        worst = max(worst, abs(c - (LOG2E - float(H2(np.array([w]))[0]))))
    out("   coarse straddle cost vs log2 e - H2(w) on 41 values of w: max deviation %.2e (quadrature, 2e5 nodes)" % worst)
    U = (np.arange(20000) + 0.5) / 20000
    worst = (0.0, None)
    for LD in np.concatenate([np.linspace(1.0, 2.0, 41), np.linspace(2.0, 20.0, 37)]):
        for w in np.linspace(0, 1, 101):
            a, b = w * LD, (1 - w) * LD
            y = np.minimum(1 - U, b) + np.minimum(U, a)
            c = float(np.mean(-np.log2(np.maximum(y, 1e-300))))
            if c > worst[0]:
                worst = (c, (LD, w))
    out("   fine regime: max over (L/D in [1,20], w in [0,1]) of E[-log2(y/D)] = %.4f at L/D=%.3f, w=%.3f;"
        " record's bound 2 log2 e = %.4f; single-edge bound log2 e = %.4f" % (
            worst[0], worst[1][0], worst[1][1], 2 * LOG2E, LOG2E))

    # ---------------- C
    out("\n== C. Prop 3.5 (optimal tolerance) with atoms, exact rationals")
    bad = tested = 0
    for _ in range(3000):
        k = rng.randint(1, 6)
        vals = sorted(set(Fr(rng.randint(0, 20), 4) for _ in range(k)))
        wts = [Fr(rng.randint(1, 9)) for _ in vals]
        tot = sum(wts)
        probs = [w_ / tot for w_ in wts]
        epsstar = vals[-1]
        g = Fr(rng.randint(2, 14))
        lpc = Fr(rng.randint(0, 40))
        theta = 2 * g / (lpc + g)

        def c(eps):
            return 2 * eps * g + (lpc + g) * sum(p * max(v - eps, Fr(0)) for v, p in zip(vals, probs))
        # c is piecewise linear with kinks at the atoms: its minimum set over [0, eps*] is a point or a segment
        # between consecutive breakpoints; evaluate at breakpoints and test segments by their endpoints.
        bps = sorted(set([Fr(0)] + vals))
        cv = [c(x) for x in bps]
        m = min(cv)
        argset = [x for x, y in zip(bps, cv) if y == m]
        # the quantile rule at breakpoints and at midpoints of segments
        def rule(eps):
            if theta >= 1:
                return eps == 0 if c(Fr(0)) < c(min(bps[1:], default=Fr(1))) or len(bps) == 1 else c(eps) == m
            gt = sum(p for v, p in zip(vals, probs) if v > eps)
            ge = sum(p for v, p in zip(vals, probs) if v >= eps)
            return gt <= theta <= ge
        pts = bps + [(bps[i] + bps[i + 1]) / 2 for i in range(len(bps) - 1)]
        for x in pts:
            tested += 1
            is_min = c(x) == m
            if theta >= 1:
                pred = (x == 0) or c(x) == c(Fr(0))
                pred = pred and c(Fr(0)) == m
                is_min_v = is_min
                if pred != is_min_v:
                    bad += 1
            else:
                if rule(x) != is_min:
                    bad += 1
                    if bad <= 5:
                        out("   mismatch: vals %s probs %s theta %s eps %s: rule %s, is_min %s" % (
                            [str(v) for v in vals], [str(p) for p in probs], theta, x, rule(x), is_min))
    out("   3000 random discrete |e| distributions, %d (eps, case) tests at atoms and between them: %d mismatches" % (
        tested, bad))
    # pure honest law optimal iff Pr[|e| >= eps*] >= theta
    bad = 0
    for _ in range(3000):
        k = rng.randint(1, 6)
        vals = sorted(set(Fr(rng.randint(0, 20), 4) for _ in range(k)))
        wts = [Fr(rng.randint(1, 9)) for _ in vals]
        probs = [w_ / sum(wts) for w_ in wts]
        g = Fr(rng.randint(2, 14))
        lpc = Fr(rng.randint(1, 40))
        theta = 2 * g / (lpc + g)
        if theta >= 1 or vals[-1] == 0:
            continue

        def c(eps):
            return 2 * eps * g + (lpc + g) * sum(p * max(v - eps, Fr(0)) for v, p in zip(vals, probs))
        m = min(c(x) for x in [Fr(0)] + vals)
        bad += (c(vals[-1]) == m) != (probs[-1] >= theta)
    out("   'pure honest law (eps = eps*) optimal iff Pr[|e| >= eps*] >= theta': mismatches %d" % bad)

    # ---------------- D
    out("\n== D. Prop 3.4 thresholds (pi_c = 22, lambda = 1), exact E|e|, beta_e by quadrature")
    T = (np.arange(2_000_000) + 0.5) / 2_000_000
    es = {"sinusoid": np.sin(2 * np.pi * T), "peaked": np.where(T < 0.025, 1.0, np.where((T >= 0.5) & (T < 0.525), -1.0, 0.0))}
    for name, e in es.items():
        Ee = 2 / math.pi if name == "sinusoid" else 0.05
        beta = LOG2E - float(np.mean(H2((1 - e) / 2)))
        out("   %-8s E|e| = %.6f (exact), pk = %.4f, beta_e = %.4f" % (name, Ee, 1 / Ee, beta))
        for D in (3.0, 10.0, 60.0):
            g = math.log2(21600 / D)
            p = Ee / D
            h2p = float(H2(np.array([p]))[0])
            thr = {"Q/det": (22 + g) / (2 * g), "Q/rand": (g + h2p / p) / (2 * g), "R/det": (22 + g) / (2 * beta),
                   "R/rand": (g + h2p / p) / (2 * beta)}
            out("      Delta=%3.0f: " % D + "  ".join("%s %.3f -> %s" % (k, v, "H" if 1 / Ee < v else "P") for k, v in thr.items()))

    # ---------------- E
    out("\n== E. Prop 2.4 regime G: r(delta) = Pr[|e - eta| > delta], eta ~ U[-1/2, 1/2], exact in eta, quadrature in t")
    for name, e in es.items():
        cells = []
        for d in (1.0, 1.25, 1.4, 1.45, 1.49, 1.5, 1.6):
            # for fixed e, measure of eta in [-1/2,1/2] with |e - eta| > d: eta < e - d or eta > e + d
            m = np.clip(e - d - (-0.5), 0, 1) + np.clip(0.5 - (e + d), 0, 1)
            cells.append("%.2f: %.3e" % (d, float(np.mean(np.minimum(m, 1.0)))))
        out("   %-8s " % name + "; ".join(cells))

    # ---------------- F
    out("\n== F. Prop 2.5 regime R: exact p_Delta = E min(|e|/Delta, 1) and 1/p_Delta")
    for name, e in es.items():
        cells = []
        for D in (2.0, 10.0, 60.0, 600.0):
            p = float(np.mean(np.minimum(np.abs(e) / D, 1.0)))
            pex = (2 / math.pi / D if name == "sinusoid" else 0.05 / D)
            cells.append("D=%g: p=%.6f (closed form %.6f), 1/p=%.2f" % (D, p, pex, 1 / pex))
        out("   %-8s " % name + "; ".join(cells))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb1_dither_exact.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
