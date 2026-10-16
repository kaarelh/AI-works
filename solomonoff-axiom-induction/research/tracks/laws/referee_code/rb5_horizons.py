"""rb5_horizons.py -- Referee B, thread `laws`: notes section 4 (derivation horizons, the sound criterion),
in exact rational arithmetic where possible, independently of l6.

A. Prop 4.1(b): the exact range of x_{r,i} over the models of the honest linear law is the zonotope projection
   (A^r a)_i +- h_{r,i}.  Checked in d = 2 with small rational A by enumerating ALL sign vectors of the
   deviations (x_0 - a, u_0, ..., u_{r-1}) in {-1, +1}^{2(r+1)} (the extreme points of the box), exactly.
B. Prop 4.1(c): the horizon r*(delta) = max{r : e_r <= delta} in exact rationals against the record's closed
   forms (floor of logs), for L in {1/2, 9/10, 1, 11/10, 2} and many delta/eps; the contraction-limit case.
C. Scope of Prop 4.1(c) and Prop 4.2 ("provable iff r <= r*(delta)"): a NONLINEAR F with Lipschitz constant 2
   that is constant near the trajectory; exact interval images show the honest law proves the datum at every
   depth while the formula's horizon is 1.
D. Prop 4.3(c): Helly in dimension 1 exhaustively on small integer intervals (all families of 2-4 intervals
   with endpoints in 0..5); boxes in the plane from products; the disc counterexample (exact: pairwise
   distances 2 <= 2.2, circumradius 2/sqrt(3) > 1.1).
E. Remark 4.4: exact mean |sum of r random signs| = r C(r, r/2) 2^-r (r = 100: record 7.96); r = 1000 (25.2);
   uniform errors by exact convolution (record about 4.6); L = 1.1, r = 100: worst case and the Gaussian value
   (record 1.38e5 and about 2.4e4).
Seed 20261016.  Writes rb5_horizons.out next to itself.
"""
import itertools
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


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def matmul(A, B):
    return [[sum(A[i][k] * B[k][j] for k in range(len(B))) for j in range(len(B[0]))] for i in range(len(A))]


def matpow(A, r):
    d = len(A)
    R = [[Fr(int(i == j)) for j in range(d)] for i in range(d)]
    for _ in range(r):
        R = matmul(R, A)
    return R


def main():
    t0 = time.time()
    rng = random.Random(SEED)
    out("# rb5_horizons.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. Prop 4.1(b), d = 2: exact range of x_r over sign vectors vs the zonotope half-width")
    bad = 0
    tests = 0
    for _ in range(60):
        A = [[Fr(rng.randint(-6, 6), 4) for _ in range(2)] for _ in range(2)]
        e0, eps = Fr(rng.randint(0, 3), 2), Fr(rng.randint(1, 3), 4)
        for r in range(0, 5):
            pw = [matpow(A, s) for s in range(r + 1)]
            # x_r - A^r a = A^r d0 + sum_{s<r} A^{r-1-s} u_s, d0, u_s in boxes of half-widths e0, eps
            best_lo = [None, None]
            best_hi = [None, None]
            nvec = 2 * (r + 1)
            for signs in itertools.product((-1, 1), repeat=nvec):
                d0 = [e0 * signs[0], e0 * signs[1]]
                v = [sum(pw[r][i][k] * d0[k] for k in range(2)) for i in range(2)]
                for s in range(r):
                    us = [eps * signs[2 + 2 * s], eps * signs[3 + 2 * s]]
                    M = pw[r - 1 - s]
                    v = [v[i] + sum(M[i][k] * us[k] for k in range(2)) for i in range(2)]
                for i in range(2):
                    best_lo[i] = v[i] if best_lo[i] is None else min(best_lo[i], v[i])
                    best_hi[i] = v[i] if best_hi[i] is None else max(best_hi[i], v[i])
            for i in range(2):
                h = e0 * sum(abs(x) for x in pw[r][i]) + eps * sum(sum(abs(x) for x in pw[s][i]) for s in range(r))
                tests += 1
                bad += not (best_hi[i] == h and best_lo[i] == -h)
    out("   %d (matrix, r <= 4, coordinate) cases: extreme values = +-h_{r,i} exactly in all but %d" % (tests, bad))

    # ---------------- B
    out("\n== B. Prop 4.1(c): horizon r*(delta) exact vs the closed forms (e_0 = 0)")
    bad = 0
    tests = 0
    for L in (Fr(1, 2), Fr(9, 10), Fr(1), Fr(11, 10), Fr(2)):
        for dd in [Fr(x, 4) for x in range(1, 400)] + [Fr(10), Fr(100), Fr(1000), Fr(10000)]:
            eps = Fr(1)
            # iterate e_r
            limit = eps / (1 - L) if L < 1 else None
            if limit is not None and dd >= limit:
                rstar = math.inf
            else:
                e, r = Fr(0), 0
                while True:
                    en = L * e + eps
                    if en > dd:
                        break
                    e, r = en, r + 1
                    if r > 100000:
                        break
                rstar = r
            # closed form of the record
            Lf, df = float(L), float(dd)
            if L == 1:
                cf = math.floor(df / 1.0)
            elif L > 1:
                cf = math.floor(math.log(1 + df * (Lf - 1)) / math.log(Lf) + 1e-12)
            else:
                # the contraction-limit test is done in exact rationals (a float test misfires at delta = eps/(1-L))
                cf = math.inf if dd >= Fr(1) / (1 - L) else math.floor(math.log(1 - df * (1 - Lf)) / math.log(Lf) + 1e-12)
            tests += 1
            if cf != rstar:
                bad += 1
                if bad <= 3:
                    out("   mismatch L=%s delta/eps=%s: exact %s, closed form %s" % (L, dd, rstar, cf))
    out("   %d (L, delta/eps) cells: %d mismatches (closed forms in floating point with a 1e-12 guard; contraction-limit test exact)" % (
        tests, bad))
    for L, dd in ((Fr(1), Fr(10000)), (Fr(101, 100), Fr(10000)), (Fr(11, 10), Fr(10000)), (Fr(2), Fr(10000))):
        e, r = Fr(0), 0
        while L * e + 1 <= dd:
            e, r = L * e + 1, r + 1
        out("   delta/eps = 10^4, L = %s: r* = %d" % (L, r))

    # ---------------- C
    out("\n== C. scope: a nonlinear F with Lipschitz constant 2, F(x) = 0 on [-1,1], F(x) = 2(x - sign(x)) outside")

    def F_img(lo, hi):
        # image of [lo, hi] under the monotone piecewise-linear F
        def F(x):
            if abs(x) <= 1:
                return Fr(0)
            return 2 * (x - (1 if x > 0 else -1))
        return F(lo), F(hi)
    eps = Fr(1, 10)
    lo, hi = Fr(0), Fr(0)                   # x_0 = a = 0, e_0 = 0
    rows = []
    for r in range(1, 31):
        flo, fhi = F_img(lo, hi)
        lo, hi = flo - eps, fhi + eps       # exact set of possible x_r in the models (interval)
        e_r = eps * (2 ** r - 1)            # the record's derived tolerance with L = 2
        rows.append((r, hi - lo, e_r))
    out("   exact width/2 of the set of x_r over the models: %s for every r = 1..30" % (set(str((w) / 2) for _, w, _ in rows)))
    out("   record's e_r (L = 2): r=1: %s, r=5: %s, r=30: %s; so at precision delta = 1/10 the formula's horizon"
        " is r* = 1, yet the honest law proves 'x_r in [-1/10, 1/10]' (centred at F^r(a) = 0) at every depth r" % (
            rows[0][2], rows[4][2], rows[29][2]))

    # ---------------- D
    out("\n== D. Prop 4.3(c): Helly in dimension 1 (exhaustive), boxes, discs")
    ivs = [(a, b) for a in range(6) for b in range(a, 6)]
    bad = cnt = 0
    for k in (2, 3, 4):
        for fam in itertools.combinations_with_replacement(ivs, k):
            pair = all(max(x[0], y[0]) <= min(x[1], y[1]) for x, y in itertools.combinations(fam, 2))
            joint = max(x[0] for x in fam) <= min(x[1] for x in fam)
            cnt += 1
            bad += pair != joint
    out("   all %d families of 2-4 closed integer intervals in [0,5]: pairwise <=> joint fails in %d" % (cnt, bad))
    bad = cnt = 0
    for _ in range(20000):
        k = rng.randint(2, 5)
        fam = [(sorted([rng.randint(0, 9), rng.randint(0, 9)]), sorted([rng.randint(0, 9), rng.randint(0, 9)])) for _ in range(k)]
        pair = all(all(max(x[c][0], y[c][0]) <= min(x[c][1], y[c][1]) for c in (0, 1)) for x, y in itertools.combinations(fam, 2))
        joint = all(max(x[c][0] for x in fam) <= min(x[c][1] for x in fam) for c in (0, 1))
        cnt += 1
        bad += pair != joint
    out("   %d random families of 2-5 integer boxes in the plane: pairwise <=> joint fails in %d" % (cnt, bad))
    # discs: centres (0,0), (2,0), (1, sqrt 3); radius 11/10. pairwise: distance 2 <= 2.2. common point iff the
    # minimal enclosing circle of the centres (circumradius 2/sqrt 3 for an acute triangle) has radius <= 1.1
    out("   discs of radius 1.1 at the vertices of an equilateral triangle of side 2: pairwise distance 2 <= 2.2;"
        " circumradius^2 = 4/3 = %.4f > 1.21 = 1.1^2, so no common point (exact)" % (4 / 3))

    # ---------------- E
    out("\n== E. Remark 4.4: typical against worst case")
    for r in (100, 1000):
        m = Fr(r * math.comb(r, r // 2), 2 ** r)
        out("   r = %d, random signs +-eps: E|S_r| = r C(r, r/2) 2^-r = %.4f eps (sqrt(2r/pi) = %.4f); worst case %d eps" % (
            r, float(m), math.sqrt(2 * r / math.pi), r))
    # uniform errors on [-1,1]: exact density of the sum by numerical convolution on a fine grid
    h = 1e-3
    g = np.ones(int(2 / h) + 1)
    g /= g.sum()
    dens = g.copy()
    for _ in range(99):
        dens = np.convolve(dens, g)
    xs = (np.arange(dens.size) - (dens.size - 1) / 2) * h
    out("   r = 100, errors uniform on [-eps, eps]: E|S| = %.3f eps (record about 4.6)" % float(np.sum(np.abs(xs) * dens)))
    L = 1.1
    worst = (L ** 100 - 1) / (L - 1)
    sd_sign = math.sqrt(sum(L ** (2 * s) for s in range(100)))
    out("   L = 1.1, r = 100: worst case %.4g eps (record 1.38e5); random signs: E|.| ~ sqrt(2/pi) * %.4g = %.4g eps"
        " (Gaussian approximation; record about 2.4e4)" % (worst, sd_sign, math.sqrt(2 / math.pi) * sd_sign))
    # exact E|sum_s c_s sigma_s| for c_s = L^s, s < 100, by Monte Carlo with many draws (not exact; seeded)
    nr = np.random.default_rng(SEED)
    c = L ** np.arange(100)
    acc = 0.0
    nd = 0
    for _ in range(20):
        sg = nr.choice([-1.0, 1.0], size=(50000, 100))
        acc += float(np.sum(np.abs(sg @ c)))
        nd += 50000
    out("   L = 1.1, r = 100, random signs, Monte Carlo (10^6 draws, seeded): E|.| = %.4g eps" % (acc / nd))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb5_horizons.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
