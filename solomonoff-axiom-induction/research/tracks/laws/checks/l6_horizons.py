"""l6_horizons.py -- derivation horizons of honest approximate dynamical laws, and the sound criterion for
combining approximate models (thread `laws`, T4; notes section 4).

Seed 20261016.  Writes l6_horizons.out next to itself.

Parts:
  A. 1-D linear maps x_{s+1} = L x_s + err, |err| <= eps, |x_0 - a| <= e0: the derived tolerance
     e_r = L^r e0 + eps (L^r - 1)/(L - 1) (Prop 4.1) against exact interval propagation (the reachable
     set is an interval, computed by iterating its endpoints), and the horizon r*(delta) formula against the
     iterated computation, for L in {0.5, 0.9, 1, 1.01, 1.1, 2} and delta/eps in {10, 100, 10^4}.
  B. d-dimensional linear maps (random Gaussian matrices rescaled to spectral radius rho): the exact
     tightest derivable tolerance on each coordinate after r steps (the half-width of the reachable zonotope,
     eps * sum_{s<r} ||row_i(A^s)||_1, Prop 4.1(c)), checked by constructing the maximising error sequence;
     box (interval-arithmetic) propagation w <- |A| w + eps; and the Lipschitz bound with L = ||A||_inf.
     Checks exact <= box <= Lipschitz, with equality in d = 1.
  C. typical against worst case (Remark 4.4): after r steps with L = 1, random-sign errors +-eps give
     E|sum| = eps r C(r, r/2)/2^r (exact) against the worst case r eps; uniform errors on [-eps, eps] by
     simulation; and for L > 1.
  D. joint consistency of honest models (Prop 4.3): in 1-D, pairwise overlap of tolerance intervals implies a
     common point (Helly, dimension 1): checked on 10^5 random families; boxes in R^2 likewise; Euclidean
     discs in R^2 need triples (an explicit family of three pairwise intersecting discs with no common point).
"""
import math
import sys
import time
import numpy as np

SEED = 20261016
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def e_formula(L, eps, e0, r):
    if L == 1:
        return e0 + r * eps
    return L ** r * e0 + eps * (L ** r - 1) / (L - 1)


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    out("# l6_horizons.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. 1-D: derived tolerance and horizon r*(delta) = max{r : e_r <= delta}, eps = 1, e0 = 0")
    out("   %-6s | %s | %s" % ("L", "max |e_r(formula) - e_r(interval propagation)| over r <= 200 (rel.)",
                              "r*(delta) formula / iterated, for delta/eps = 10, 100, 10^4"))
    for L in (0.5, 0.9, 0.99, 1.0, 1.01, 1.1, 2.0):
        lo, hi = 0.0, 0.0  # reachable set of x_r - L^r a (a = 0)
        worst = 0.0
        for r in range(1, 201):
            # x_r = L x_{r-1} + err: image of [lo, hi] under x -> L x, plus [-1, 1]
            cand = (L * lo, L * hi)
            lo, hi = min(cand) - 1.0, max(cand) + 1.0
            ef = e_formula(L, 1.0, 0.0, r)
            worst = max(worst, abs(hi - ef) / ef)
        cells = []
        for dl in (10.0, 100.0, 1e4):
            if L < 1 and dl >= 1 / (1 - L) - 1e-9:
                rf = "inf"
            elif L == 1:
                rf = "%d" % math.floor(dl)
            elif L > 1:
                rf = "%d" % math.floor(math.log(1 + dl * (L - 1)) / math.log(L) + 1e-12)
            else:
                rf = "%d" % math.floor(math.log(1 - dl * (1 - L)) / math.log(L) + 1e-12)
            r, e = 0, 0.0
            while r < 10 ** 6:
                en = e_formula(L, 1.0, 0.0, r + 1)
                if en > dl * (1 + 1e-12):
                    break
                r, e = r + 1, en
            ri = "inf" if r >= 10 ** 6 else "%d" % r
            cells.append("%s/%s" % (rf, ri))
        out("   %-6g | %.2e | %s" % (L, worst, "   ".join(cells)))

    # ---------------- B
    out("\n== B. d-dim random linear maps: per-coordinate tolerance after r steps (eps = 1, e0 = 0); medians over")
    out("   coordinates and 50 matrices per row; exact = zonotope half-width (attained by the sign sequence),"
        " box = interval arithmetic, Lip = Lipschitz bound with L = ||A||_inf")
    for d in (1, 3, 10):
        for rho in (0.95, 1.0, 1.05):
            for r in (10, 30):
                ratios_box, ratios_lip, attained, order_ok = [], [], 0, True
                for _ in range(50):
                    A = rng.normal(size=(d, d))
                    A *= rho / max(abs(np.linalg.eigvals(A)))
                    P = np.eye(d)
                    exact = np.zeros(d)
                    pows = []
                    for s in range(r):
                        pows.append(P.copy())
                        exact += np.abs(P).sum(axis=1)
                        P = A @ P
                    # attained: for coordinate 0 choose err_s = sign(row_0(A^{r-1-s}))
                    x = np.zeros(d)
                    for s in range(r):
                        M = pows[r - 1 - s]
                        x = A @ x + np.sign(M[0])
                    attained += abs(x[0] - exact[0]) < 1e-8 * max(1.0, exact[0])
                    w = np.zeros(d)
                    for s in range(r):
                        w = np.abs(A) @ w + 1.0
                    Linf = np.abs(A).sum(axis=1).max()
                    lip = e_formula(Linf, 1.0, 0.0, r)
                    order_ok &= bool(np.all(exact <= w * (1 + 1e-12)) and np.all(w <= lip * (1 + 1e-12)))
                    ratios_box.extend(list(w / exact))
                    ratios_lip.extend(list(lip / exact))
                out("   d=%2d rho=%.2f r=%2d: median box/exact = %.3g  median Lip/exact = %.3g  exact attained %d/50"
                    "  exact <= box <= Lip in all: %s" % (d, rho, r, np.median(ratios_box), np.median(ratios_lip),
                                                       attained, order_ok))

    # ---------------- C
    out("\n== C. typical against worst case after r steps, L = 1, eps = 1")
    for r in (10, 100, 1000):
        exact_rad = r * math.comb(r, r // 2) / 2 ** r if r % 2 == 0 else float("nan")
        S = rng.choice([-1.0, 1.0], size=(20000, r)).sum(axis=1)
        U = rng.uniform(-1, 1, size=(20000, r)).sum(axis=1)
        out("   r=%5d: worst case %d; random signs E|S| = %.3f exact (simulated %.3f; sqrt(2r/pi) = %.3f);"
            " uniform errors E|S| simulated %.3f (sqrt(2r/(3pi)) = %.3f)" % (
                r, r, exact_rad, float(np.mean(np.abs(S))), math.sqrt(2 * r / math.pi), float(np.mean(np.abs(U))),
                math.sqrt(2 * r / (3 * math.pi))))
    for L in (1.01, 1.1):
        r = 100
        E = np.zeros(20000)
        for s in range(r):
            E = L * E + rng.choice([-1.0, 1.0], size=20000)
        out("   L=%.2f r=%d: worst case %.1f; random signs E|x_r| simulated %.2f; sqrt(sum L^(2s)) * sqrt(2/pi) = %.2f" % (
            L, r, e_formula(L, 1.0, 0.0, r), float(np.mean(np.abs(E))),
            math.sqrt(sum(L ** (2 * s) for s in range(r))) * math.sqrt(2 / math.pi)))

    # ---------------- D
    out("\n== D. joint consistency of honest models: pairwise overlap against a common point")
    bad1 = 0
    for _ in range(100000):
        k = rng.integers(2, 7)
        c = rng.normal(size=k)
        rad = rng.uniform(0.1, 1.5, size=k)
        pairwise = all(abs(c[i] - c[j]) <= rad[i] + rad[j] for i in range(k) for j in range(i + 1, k))
        joint = (c - rad).max() <= (c + rad).min()
        bad1 += pairwise != joint
    out("   1-D intervals (10^5 random families of 2-6 models): pairwise <=> joint fails in %d families" % bad1)
    bad2 = 0
    for _ in range(20000):
        k = rng.integers(2, 6)
        c = rng.normal(size=(k, 2))
        rad = rng.uniform(0.1, 1.5, size=(k, 2))
        pairwise = all(np.all(np.abs(c[i] - c[j]) <= rad[i] + rad[j]) for i in range(k) for j in range(i + 1, k))
        joint = bool(np.all((c - rad).max(axis=0) <= (c + rad).min(axis=0)))
        bad2 += pairwise != joint
    out("   axis-parallel boxes in R^2 (2*10^4 families): pairwise <=> joint fails in %d families" % bad2)
    # discs: centres at the vertices of an equilateral triangle of side 2, radius 1.1
    cs = np.array([[0.0, 0.0], [2.0, 0.0], [1.0, math.sqrt(3)]])
    rr = 1.1
    pair = all(np.linalg.norm(cs[i] - cs[j]) <= 2 * rr for i in range(3) for j in range(i + 1, 3))
    circum = 2 / math.sqrt(3)
    out("   Euclidean discs in R^2: centres at an equilateral triangle of side 2, radius 1.1: pairwise intersect: %s;"
        " common point exists iff radius >= circumradius %.4f: %s" % (pair, circum, rr >= circum))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
