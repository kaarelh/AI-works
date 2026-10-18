"""p4_toy.py -- track `purpose`, target T4(a): two wrong laws ranked in opposite orders by SAI's pricing (log loss
with the best calibrated error model, regime R of the paper) and by squared, absolute or maximum error.

Deterministic.  Writes p4_toy.out next to itself.  Rates in bits per datum, from the identity of T3
(rate of the best calibrated error model at cell width Delta = h(e + V_Delta) - log2 Delta, V_Delta uniform on
[0, Delta)), evaluated in closed form or by exact piecewise integration of the smoothed density.

Toy 1 (T4a).  Law A: errors uniform on [-1, 1].  Law B: errors -M, 0, M with probabilities rho/2, 1 - rho, rho/2,
          M = 1000, rho = 0.2 (exactly right on 80% of times, off by 1000 on the rest).
Toy 2 (pointwise dominance).  Law B': error s(t) in {-1, +1} (fair sign); law A': error s(t) U(t), U uniform on
          [0, 1]; so |e_A'(t)| <= |e_B'(t)| at every time t.
For each: max |e|, RMS, mean |e|, ML-fitted Gaussian / Laplace / uniform log-loss rates (fine limit, + log2 Delta),
CRPS of the calibrated forecast ((1/2) E|e - e'|), and SAI's rate at cell widths Delta; the crossover Delta_c.
"""
import math
import os

import numpy as np
from scipy import optimize

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LN2 = math.log(2)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def smoothed_entropy_pl(cdf_knots, Delta):
    """h(e + V), V ~ U[0, Delta), for an error law whose CDF is piecewise linear with jumps, given as a function F;
    the density of e + V is (F(y) - F(y - Delta)) / Delta, piecewise linear between the knots {k, k + Delta}:
    integrate -f log2 f exactly on each linear piece."""
    F, knots = cdf_knots
    pts = sorted(set([k for k in knots] + [k + Delta for k in knots]))
    tot = 0.0
    for a, b in zip(pts[:-1], pts[1:]):
        if b - a <= 0:
            continue
        # f is linear on (a, b): evaluate it at two interior points and extrapolate to the ends
        x1, x2 = a + (b - a) / 4, a + 3 * (b - a) / 4
        f1 = (F(x1) - F(x1 - Delta)) / Delta
        f2 = (F(x2) - F(x2 - Delta)) / Delta
        fa = max(f1 - (f2 - f1) / 2, 0.0)
        fb = max(f2 + (f2 - f1) / 2, 0.0)
        # exact integral of -f log2 f for f linear from fa to fb on [a, b]
        def G(x):
            return 0.0 if x <= 0 else x * x * math.log(x) / 2 - x * x / 4
        if abs(fb - fa) < 1e-12 * max(fa, fb, 1e-300):
            v = -(fa * math.log(fa)) * (b - a) if fa > 0 else 0.0
        else:
            v = -(G(fb) - G(fa)) * (b - a) / (fb - fa)
        tot += v / LN2
    return tot


def rate(law, Delta):
    return smoothed_entropy_pl(law, Delta) - math.log2(Delta)


def law_uniform(a, b):
    return (lambda x: min(max((x - a) / (b - a), 0.0), 1.0), [a, b])


def law_atoms(vals, probs):
    def F(x):
        return sum(p for v, p in zip(vals, probs) if x >= v)
    return (F, list(vals))


def summarize(name, law, moments, deltas):
    mx, rms, mae, crps = moments
    out("   %-34s max %8.3f  RMS %8.3f  mean|e| %8.3f  CRPS(calibrated) %8.3f" % (name, mx, rms, mae, crps))
    gauss = 0.5 * math.log2(2 * math.pi * math.e * rms ** 2)
    lap = math.log2(2 * math.e * mae)
    uni = math.log2(2 * mx)
    out("   %-34s fitted Gaussian %.4f, Laplace %.4f, uniform %.4f  (+ log2(1/Delta) at fine Delta)" % ("", gauss, lap, uni))
    out("   %-34s SAI rate: %s" % ("", "  ".join("D=%g: %.4f" % (D, rate(law, D)) for D in deltas)))


def main():
    out("# p4_toy.py (deterministic)")
    deltas = [0.01, 0.1, 0.5, 1.0, 1.5, 2.0, 10.0, 100.0, 1000.0, 2000.0, 1e4]
    M, rho = 1000.0, 0.2
    A = law_uniform(-1.0, 1.0)
    B = law_atoms([-M, 0.0, M], [rho / 2, 1 - rho, rho / 2])
    out("\n== Toy 1: A errors U[-1,1]; B errors -M, 0, M w.p. rho/2, 1-rho, rho/2 (M = %g, rho = %g)" % (M, rho))
    momA = (1.0, 1 / math.sqrt(3), 0.5, 0.5 * (2 / 3))
    eB2 = rho * M * M
    EabsdiffB = 2 * ((rho / 2) * (1 - rho) * M * 2 + (rho / 2) ** 2 * 2 * M)   # sum over ordered pairs i != j
    momB = (M, math.sqrt(eB2), rho * M, 0.5 * EabsdiffB)
    summarize("A (U[-1,1])", A, momA, deltas)
    summarize("B (exact w.p. 0.8, else +-1000)", B, momB, deltas)
    HB = -((1 - rho) * math.log2(1 - rho) + rho * math.log2(rho / 2))
    out("   closed forms: rate_A = 1 + Delta/(4 ln 2) - log2 Delta for Delta <= 2, (1/ln 2)/Delta for Delta >= 2;"
        " rate_B = H(B) = %.5f for Delta <= M" % HB)
    f = lambda D: 1 + D / (4 * LN2) - math.log2(D) - HB
    Dc = optimize.brentq(f, 1.0, 2.0, xtol=1e-14)
    out("   crossover: SAI prefers B for Delta < Delta_c = %.6f and A for Delta > Delta_c (all Delta checked above)" % Dc)
    out("   max, RMS, mean|e|, the fitted Gaussian/Laplace/uniform rates and the calibrated CRPS all prefer A.")

    out("\n== Toy 2 (pointwise dominance): |e_A'(t)| <= |e_B'(t)| for every t")
    A2 = law_uniform(-1.0, 1.0)             # s U with s = +-1 fair and U uniform on [0,1]: uniform on [-1, 1]
    B2 = law_atoms([-1.0, 1.0], [0.5, 0.5])
    summarize("A' = s U (U[-1,1] marginally)", A2, (1.0, 1 / math.sqrt(3), 0.5, 1 / 3), [0.01, 0.1, 0.5, 1.0, 1.5, 2.0, 4.0])
    summarize("B' = s (+-1)", B2, (1.0, 1.0, 1.0, 0.5), [0.01, 0.1, 0.5, 1.0, 1.5, 2.0, 4.0])
    g = lambda D: 1 + D / (4 * LN2) - math.log2(D) - 1.0
    Dc2 = optimize.brentq(g, 1.0, 2.0, xtol=1e-14)
    out("   rate_B' = 1 bit for Delta <= 2; crossover Delta_c = %.6f: SAI prefers B' (pointwise worse at every time)"
        " for every Delta < Delta_c" % Dc2)
    out("   (A' is at least as close to the truth as B' at every time; every loss that is increasing in |error| and is")
    out("    applied to the law as a point predictor prefers A'.)")
    # numeric sanity of the closed form for A
    for D in (0.3, 1.0, 1.7):
        out("   check rate_A closed form at Delta=%.1f: %.10f vs piecewise integral %.10f" % (
            D, 1 + D / (4 * LN2) - math.log2(D), rate(A, D)))
    out("\n# done")
    with open(os.path.join(HERE, "p4_toy.out"), "w") as fo:
        fo.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
