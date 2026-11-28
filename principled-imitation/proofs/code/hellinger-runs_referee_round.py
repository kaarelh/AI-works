"""Referee round of the editor of the part hellinger-runs (28 November 2026).

Tests of the sentences that the referee round put into Sections 3.2 and 5.2 of the note
(research/sections/hellinger-runs.md): the proof of Lemma L4 as the note now prints it, the
sentence on the converse, the step to expectations in the proof of R2, the thresholds of the
example for the per-call mixture, and the example with the ratio 2.96399.

The script imports no other script of the project.  It needs numpy and mpmath.  Parts (A) to (H)
are exact finite sums evaluated in floating point, except where "exact" says rational arithmetic;
part (J) is 30-digit arithmetic.  The run takes under one minute; the time is printed on standard
error, so that the saved output does not depend on it.

Usage:  python3 hellinger-runs_referee_round.py > hellinger-runs_referee_round.out

The letters are those of the note: Psi is the square root of the likelihood ratio of B to A along
a run of A (Lambda in the proof file), m the number in max(m - u, 0)^2 (the m of Lemma 2.10 of the
proof file), kappa the factor before Q_B(G) (1 + eta in the proof file).

(A) the one-step inequality in the form printed in the note,
        E[max(m - c v, 0)^2] <= max(m - c, 0)^2 + 2 m^2 (1 - E v)   for v >= 0 with E v^2 <= 1;
(B) the three pointwise inequalities of the printed proof, with the stated differences (exact);
(C) random scaffolds with a random top-level input, runs that stop early and answerers that see
    the history: the three identities for Psi, the summed inequality, and parts (a), (b), (c) of
    the lemma, also in the form with a general factor kappa before Q_B(G);
(D) the choice m = 1 + sigma + sqrt(sigma^2 + 2 sigma) in part (b), and min{1, .} <= 2 sqrt(sigma);
(E) the converse sigma <= 2 L H^2, and the example in which sigma >= (L - 1) H^2;
(F) the proof of R2: the function min{1, u + sqrt(u^2 + 2u)} is non-decreasing and concave, and
    u + sqrt(u^2 + 2u) = eps exactly at u = eps^2/(2(1 + eps)); the comparison with H1 in "Cost";
(G) the example for the per-call mixture, by enumeration of all records: the divergence is at least
    L/(8N) whatever the records, it exceeds ln 2/N once L >= 6, and H1 holds for the draw per run;
(H) two inequalities quoted in the ideas of H1 and H2, the numbers of Example 4.4 (the expected
    divergence is not monotone in the number of runs), and the arithmetic of H2 at lambda = 2, s = 1/2;
(J) Example 2.8(ii) of the proof file recomputed in 30-digit arithmetic from its description.
"""
import itertools
import math
import random
import sys
import time
from fractions import Fraction as F

import numpy as np
import mpmath as mp

T0 = time.time()
rng = random.Random(2811202601)
nrng = np.random.default_rng(2811202601)
LN2 = math.log(2.0)
TOL = 1e-12


def phi(u):
    return min(1.0, u + math.sqrt(u * u + 2.0 * u))


def rand_dist(k, zero_prob=0.3):
    """A random distribution on k points, with some coordinates set to zero now and then."""
    p = nrng.dirichlet(np.ones(k))
    if k > 1 and rng.random() < zero_prob:
        kill = rng.sample(range(k), rng.randint(1, k - 1))
        p[kill] = 0.0
        p = p / p.sum()
    return p


def hell2(p, q):
    return 1.0 - float(np.sum(np.sqrt(p * q)))


# --------------------------------------------------------------------------------------------
print("(A) one step: E[max(m - c v, 0)^2] <= max(m - c, 0)^2 + 2 m^2 (1 - E v), E v^2 <= 1")
worst = -1e9
cases = 0
tight = 0.0
for _ in range(200000):
    kind = rng.randint(0, 3)
    if kind == 0:
        # v = sqrt(q/p) under p, as in the proof (q may have mass outside the support of p)
        k = rng.randint(2, 6)
        p, q = rand_dist(k), rand_dist(k)
        sup = p > 0
        vals = np.sqrt(q[sup] / p[sup])
        probs = p[sup]
    elif kind == 1:
        # an arbitrary law with second moment at most 1
        k = rng.randint(1, 5)
        probs = nrng.dirichlet(np.ones(k))
        vals = nrng.exponential(1.0, size=k)
        m2 = float(np.sum(probs * vals * vals))
        vals = vals * math.sqrt(rng.random() / m2) if m2 > 0 else vals
    elif kind == 2:
        # two-point laws with second moment exactly 1 (extreme points of the constraint set)
        t = rng.random()
        lo = rng.random()
        hi = math.sqrt((1.0 - (1.0 - t) * lo * lo) / t) if t > 0 else 1.0
        probs = np.array([1.0 - t, t])
        vals = np.array([lo, hi])
    else:
        # point masses at a value in [0, 1]
        probs = np.array([1.0])
        vals = np.array([rng.random()])
    ev = float(np.sum(probs * vals))
    ev2 = float(np.sum(probs * vals * vals))
    assert ev2 <= 1.0 + 1e-9
    b = rng.choice([1.0, 2.0, 0.5 + 4.5 * rng.random()])
    c = rng.choice([0.0, b, b * rng.random(), b * (1.0 + 3.0 * rng.random()), 10.0 * rng.random()])
    lhs = float(np.sum(probs * np.maximum(b - c * vals, 0.0) ** 2))
    rhs = max(b - c, 0.0) ** 2 + 2.0 * b * b * (1.0 - ev)
    worst = max(worst, lhs - rhs)
    if rhs > 1e-9:
        tight = max(tight, lhs / rhs)
    cases += 1
print("    %d random cases: max of lhs - rhs = %.3e (must be <= 0 up to rounding); largest lhs/rhs = %.6f"
      % (cases, worst, tight))
assert worst <= 1e-9

# --------------------------------------------------------------------------------------------
print("(B) the three pointwise inequalities of the printed proof (exact rational arithmetic)")
cnt = 0
for _ in range(20000):
    x = F(rng.randint(0, 600), 100)
    b = 1 + F(rng.randint(1, 500), 100)
    a = 1 + F(rng.randint(1, 900), 100)
    # (a): (1/2) max(2 - x, 0)^2 >= 3/2 - x, with difference (1/2)(x - 1)^2 up to x = 2
    u = F(1, 2) * max(2 - x, 0) ** 2
    assert u >= F(3, 2) - x
    if x <= 2:
        assert u - (F(3, 2) - x) == F(1, 2) * (x - 1) ** 2
    # (b): max(m - u, 0)^2 >= (m^2 - 1) max(1 - u^2, 0), with difference (1 - m u)^2 up to u = 1
    # (the variables b, x and a of this part are the m, u and kappa of the note)
    lhs = max(b - x, 0) ** 2
    rhs = (b * b - 1) * max(1 - x * x, 0)
    assert lhs >= rhs
    if x <= 1:
        assert lhs - rhs == (1 - b * x) ** 2
    # (c): max(1 - u, 0)^2 >= (1 - 1/kappa)(1 - kappa u^2), with difference (1 - kappa u)^2 / kappa up to u = 1
    lhs = max(1 - x, 0) ** 2
    rhs = (1 - 1 / a) * (1 - a * x * x)
    assert lhs >= rhs
    if x <= 1:
        assert lhs - rhs == (1 - a * x) ** 2 / a
    # the case c <= m of the one-step inequality: m^2 - 2mc Ev + c^2 = (m - c)^2 + 2mc(1 - Ev)
    c = F(rng.randint(0, 800), 100)
    ev = F(rng.randint(0, 100), 100)
    assert b * b - 2 * b * c * ev + c * c == (b - c) ** 2 + 2 * b * c * (1 - ev)
    cnt += 1
print("    %d random rational points: all three inequalities and the three stated differences hold" % cnt)

# --------------------------------------------------------------------------------------------
print("(C) random scaffolds (random top-level input, early stops, answerers that see the history)")


def random_scaffold(L, ny, nz):
    """Returns the list of runs.  A run is (prob of z, list of (a, b, y) along its calls)."""
    d0 = nrng.dirichlet(np.ones(nz))
    runs = []

    def grow(z, path, depth):
        stop = (depth == L) or (rng.random() < (0.08 if depth == 0 else 0.25))
        if stop:
            runs.append((float(d0[z]), list(path)))
            return
        a, b = rand_dist(ny), rand_dist(ny)
        for y in range(ny):
            if a[y] > 0 or b[y] > 0:
                path.append((a, b, y))
                grow(z, path, depth + 1)
                path.pop()

    for z in range(nz):
        grow(z, [], 0)
    return runs


stats = dict(n=0, id1=0.0, id2=0.0, id3=-1e9, summed=-1e9, step=-1e9, a=0.0, b=0.0, b2=0.0, b_nontrivial=0.0,
             c=-1e9, c0=0.0, ca=-1e9, conv=0.0, n_c0=0, n_runs=0, short=0)
for inst in range(3000):
    L = rng.randint(1, 4)
    ny = rng.randint(2, 3)
    nz = rng.randint(1, 3)
    runs = random_scaffold(L, ny, nz)
    QA, QB, S, PSI = [], [], [], []
    step_worst = -1e9
    bs = [1.0, 1.5, 2.0, 3.0, 1.0 + 4.0 * rng.random()]
    for pz, path in runs:
        qa, qb, s, psi = pz, pz, 0.0, 1.0
        for (a, b, y) in path:
            h = hell2(a, b)
            if qa > 0:
                # the conditional one-step inequality at this call, with c = psi
                sup = a > 0
                v = np.sqrt(b[sup] / a[sup])
                for bb in bs:
                    lhs = float(np.sum(a[sup] * np.maximum(bb - psi * v, 0.0) ** 2))
                    rhs = max(bb - psi, 0.0) ** 2 + 2.0 * bb * bb * h
                    step_worst = max(step_worst, lhs - rhs)
            s += h
            if qa > 0 and a[y] > 0:
                psi *= math.sqrt(b[y] / a[y])
            qa *= float(a[y])
            qb *= float(b[y])
        QA.append(qa)
        QB.append(qb)
        S.append(s)
        PSI.append(psi if qa > 0 else float("nan"))
        if len(path) < L:
            stats["short"] += 1
    QA, QB, S, PSI = np.array(QA), np.array(QB), np.array(S), np.array(PSI)
    assert abs(QA.sum() - 1.0) < 1e-9 and abs(QB.sum() - 1.0) < 1e-9
    onA = QA > 0
    H2 = 1.0 - float(np.sum(np.sqrt(QA * QB)))
    TV = 0.5 * float(np.sum(np.abs(QA - QB)))
    sigma = float(np.sum(QA * S))
    psi = PSI[onA]
    qa = QA[onA]
    # the three identities
    stats["id1"] = max(stats["id1"], abs(float(np.sum(qa * psi)) - (1.0 - H2)))
    stats["id2"] = max(stats["id2"], abs(float(np.sum(qa * np.maximum(1.0 - psi ** 2, 0.0))) - TV))
    stats["step"] = max(stats["step"], step_worst)
    for bb in bs:
        lhs = float(np.sum(qa * np.maximum(bb - psi, 0.0) ** 2))
        stats["summed"] = max(stats["summed"], lhs - ((bb - 1.0) ** 2 + 2.0 * bb * bb * sigma))
    if sigma > 1e-12:
        stats["a"] = max(stats["a"], H2 / (4.0 * sigma))
        stats["b"] = max(stats["b"], TV / phi(sigma))
        if phi(sigma) < 1.0:
            stats["b_nontrivial"] = max(stats["b_nontrivial"], TV / phi(sigma))
        stats["b2"] = max(stats["b2"], phi(sigma) / (2.0 * math.sqrt(sigma)))
        stats["conv"] = max(stats["conv"], sigma / (2.0 * L * H2)) if H2 > 1e-12 else stats["conv"]
    else:
        assert H2 < 1e-9 and TV < 1e-9
    # sets of runs
    nr = len(runs)
    for _ in range(6):
        G = nrng.random(nr) < rng.choice([0.2, 0.5, 0.8])
        qaG, qbG = float(QA[G].sum()), float(QB[G].sum())
        stats["id3"] = max(stats["id3"], float(np.sum(QA[G & onA] * PSI[G & onA] ** 2)) - qbG)
        stats["c"] = max(stats["c"], qaG - 2.0 * qbG - 4.0 * sigma)
        aa = 1.0 + 5.0 * rng.random()
        stats["ca"] = max(stats["ca"], qaG - aa * qbG - 2.0 * aa * sigma / (aa - 1.0))
    G0 = QB == 0
    if G0.any() and float(QA[G0].sum()) > 0:
        stats["n_c0"] += 1
        stats["c0"] = max(stats["c0"], float(QA[G0].sum()) / (2.0 * sigma))
    stats["n"] += 1
    stats["n_runs"] += nr
print("    %d scaffolds, %d runs in all, of which %d stopped before the horizon" % (stats["n"], stats["n_runs"], stats["short"]))
print("    identities: max |E Psi - (1 - H2)| = %.2e ; max |E max(1 - Psi^2, 0) - TV| = %.2e ; max of E[1_G Psi^2] - Q_B(G) = %.2e"
      % (stats["id1"], stats["id2"], stats["id3"]))
print("    one step at every call, max of lhs - rhs = %.2e ; summed inequality, max of lhs - rhs = %.2e"
      % (stats["step"], stats["summed"]))
print("    (a) max H2/(4 sigma) = %.4f ; (b) max TV/min{1, sigma + sqrt(sigma^2 + 2 sigma)} = %.4f (%.4f where that bound is below 1) ; max of that bound over 2 sqrt(sigma) = %.4f"
      % (stats["a"], stats["b"], stats["b_nontrivial"], stats["b2"]))
print("    (c) max of Q_A(G) - 2 Q_B(G) - 4 sigma = %.2e ; with a general factor kappa > 1: max of Q_A(G) - kappa Q_B(G) - 2 kappa sigma/(kappa - 1) = %.2e (both <= 0)"
      % (stats["c"], stats["ca"]))
print("    (c) sets with Q_B(G) = 0 (%d scaffolds): max Q_A(G)/(2 sigma) = %.4f" % (stats["n_c0"], stats["c0"]))
print("    converse: max sigma/(2 L H2) = %.4f" % stats["conv"])
assert stats["id1"] < 1e-9 and stats["id2"] < 1e-9 and stats["id3"] < 1e-9
assert stats["step"] < 1e-9 and stats["summed"] < 1e-9
assert stats["a"] <= 1 + 1e-9 and stats["b"] <= 1 + 1e-9 and stats["b2"] <= 1 + 1e-9 and stats["b_nontrivial"] <= 1 + 1e-9
assert stats["c"] <= 1e-9 and stats["ca"] <= 1e-9 and stats["c0"] <= 1 + 1e-9 and stats["conv"] <= 1 + 1e-9

# --------------------------------------------------------------------------------------------
print("(D) part (b): the choice of m, and the bound 2 sqrt(sigma)")
worst_eq, worst_min, worst_2 = 0.0, -1e9, 0.0
for i in range(1, 4001):
    sig = 10.0 ** (-6.0 + 7.0 * i / 4000.0)        # sigma from 1e-6 to 10
    v = sig + math.sqrt(sig * sig + 2.0 * sig)
    b = 1.0 + v
    val = ((b - 1.0) ** 2 + 2.0 * b * b * sig) / (b * b - 1.0)
    worst_eq = max(worst_eq, abs(val - v) / v)
    # no other b > 1 gives less
    for bb in [1.0 + v * f for f in (0.25, 0.5, 0.9, 0.99, 1.01, 1.1, 2.0, 4.0)]:
        worst_min = max(worst_min, v - ((bb - 1.0) ** 2 + 2.0 * bb * bb * sig) / (bb * bb - 1.0))
    worst_2 = max(worst_2, phi(sig) / (2.0 * math.sqrt(sig)))
print("    sigma from 1e-6 to 10: max relative error of [(m-1)^2 + 2 m^2 sigma]/(m^2 - 1) = sigma + sqrt(sigma^2 + 2 sigma) at the stated m: %.2e"
      % worst_eq)
print("    max over eight other values of m of (value at the stated m) - (value at that m) = %.2e (must be <= 0: the stated m is the best)" % worst_min)
print("    max of min{1, sigma + sqrt(sigma^2 + 2 sigma)}/(2 sqrt(sigma)) = %.6f (equality of the two branches at sigma = 1/4: %.6f = %.6f)"
      % (worst_2, 0.25 + math.sqrt(0.0625 + 0.5), 2 * math.sqrt(0.25)))
assert worst_eq < 1e-9 and worst_min < 1e-9 and worst_2 <= 1 + 1e-12

# --------------------------------------------------------------------------------------------
print("(E) the converse needs a factor of order L: the example of Proposition 2.5")
print("    scaffold: one call; after the answer 1, L - 1 further calls; A answers 1 with probability e at the first")
print("    call and 0 afterwards, B answers 0 at the first call and 1 afterwards")
for L in (2, 5, 20, 100):
    for e in (0.5, 0.1, 0.001):
        H2 = 1.0 - math.sqrt(1.0 - e)
        sigma = (1.0 - math.sqrt(1.0 - e)) + e * (L - 1)
        assert sigma >= (L - 1) * H2 and sigma <= 2 * L * H2
        if e == 0.001 or L == 2:
            print("    L = %3d, e = %.3f: H2 = %.6f, sigma = %.6f, sigma/H2 = %8.3f (between L - 1 = %d and 2L = %d)"
                  % (L, e, H2, sigma, sigma / H2, L - 1, 2 * L))

# --------------------------------------------------------------------------------------------
print("(F) the proof of R2")
# concavity and monotonicity of phi on a grid (midpoints), and Jensen on random laws of sigma
us = [10.0 ** (-6.0 + 7.5 * i / 3000.0) for i in range(3001)]
worst_mid, worst_mono = -1e9, -1e9
for i in range(len(us) - 2):
    u0, u1, u2 = us[i], us[i + 1], us[i + 2]
    lam = (u1 - u0) / (u2 - u0)
    worst_mid = max(worst_mid, (1 - lam) * phi(u0) + lam * phi(u2) - phi(u1))
    worst_mono = max(worst_mono, phi(u0) - phi(u1))
worst_j = -1e9
for _ in range(20000):
    k = rng.randint(2, 6)
    pr = nrng.dirichlet(np.ones(k))
    sg = nrng.exponential(rng.choice([0.01, 0.1, 0.5, 2.0]), size=k)
    worst_j = max(worst_j, float(np.sum(pr * np.array([phi(x) for x in sg]))) - phi(float(np.sum(pr * sg))))
print("    min{1, u + sqrt(u^2 + 2u)} on a grid from 1e-6 to 30: max of chord - function = %.2e, max decrease = %.2e (both <= 0)"
      % (worst_mid, worst_mono))
print("    Jensen, 20000 random laws of sigma: max of E phi(sigma) - phi(E sigma) = %.2e (<= 0)" % worst_j)
assert worst_mid < 1e-12 and worst_mono < 1e-15 and worst_j < 1e-12
worst_e = 0.0
for i in range(1, 1001):
    eps = F(i, 1000)
    u = eps * eps / (2 * (1 + eps))
    # u^2 + 2u is the square of eps(eps + 2)/(2(1 + eps)), exactly
    root = eps * (eps + 2) / (2 * (1 + eps))
    assert u * u + 2 * u == root * root
    assert u + root == eps
print("    exact: at u = eps^2/(2(1 + eps)), u + sqrt(u^2 + 2u) = eps, for eps = 0.001, ..., 1;")
print("    so with s = L K ln2/(2n) the first bound of R2(b) is at most eps once n >= (1 + eps) L K ln2/eps^2")
# the comparison in the paragraph Cost: n = N L rounds
for (K, L, N) in ((5, 10, 400), (30, 7, 10 ** 4)):
    n = N * L
    h1 = math.sqrt(K * LN2 / (2 * N))
    r2_last = math.sqrt(L * K * LN2 / (2 * n))
    r2_b = math.sqrt(2 * L * K * LN2 / n)
    print("    K = %d, L = %d, N = %d runs, n = N L: H1 %.5f ; R2, questions not depending on answers %.5f ; R2(b) %.5f = 2 x %.5f"
          % (K, L, N, h1, r2_last, r2_b, h1))
    assert abs(h1 - r2_last) < 1e-12 and abs(r2_b - 2 * h1) < 1e-12

# --------------------------------------------------------------------------------------------
print("(G) the per-call mixture after recorded runs: enumeration of all records")
print("    z uniform on 2N values, calls (z,1..L); human f = 0 with weight 1/2; for each value one function")
print("    of weight 1/(4N) that answers 1 at the L calls of that value")
print("    columns: N, L | per-call mixture: least divergence over all records and rounds, least divergence of the")
print("    law averaged over the rounds, its mean | L/(8N), ln2/N | a draw per run (H1): mean divergence of the averaged law")
first_L_min = {}
for N in (1, 2, 3, 4):
    B = 2 * N
    for L in (1, 2, 3, 4, 5, 6, 7, 8, 12):
        least_single = 1e9
        least_avg = 1e9
        mean_avg = 0.0
        mean_h1 = 0.0
        nrec = 0
        for rec in itertools.product(range(B), repeat=N - 1):
            # posterior before round t = 1..N, from the first t - 1 recorded runs, by Bayes' rule
            zeros_pc = np.zeros((N, B))   # probability of the run "all zeros" given z, per-call mixture
            zeros_dr = np.zeros((N, B))   # the same for one posterior draw per run
            for t in range(1, N + 1):
                seen = set(rec[: t - 1])
                wf = 0.5
                wg = [0.0 if z in seen else 1.0 / (4 * N) for z in range(B)]
                tot = wf + sum(wg)
                for z in range(B):
                    om = wg[z] / tot
                    zeros_pc[t - 1, z] = (1.0 - om) ** L
                    zeros_dr[t - 1, z] = 1.0 - om
                kl_t = float(np.mean(-np.log(zeros_pc[t - 1])))
                least_single = min(least_single, kl_t)
            kl_avg = float(np.mean(-np.log(zeros_pc.mean(axis=0))))
            kl_h1 = float(np.mean(-np.log(zeros_dr.mean(axis=0))))
            least_avg = min(least_avg, kl_avg)
            mean_avg += kl_avg
            mean_h1 += kl_h1
            nrec += 1
        mean_avg /= nrec
        mean_h1 /= nrec
        assert least_single >= L / (8.0 * N) - 1e-12 and least_avg >= L / (8.0 * N) - 1e-12
        assert mean_h1 <= LN2 / N + 1e-12
        if least_avg > LN2 / N and N not in first_L_min:
            first_L_min[N] = L
        if L in (1, 3, 5, 6, 12):
            print("    N = %d, L = %2d | %.5f %.5f %.5f | %.5f %.5f | %.5f"
                  % (N, L, least_single, least_avg, mean_avg, L / (8.0 * N), LN2 / N, mean_h1))
        if L >= 6:
            assert least_single > LN2 / N and least_avg > LN2 / N
print("    least L (among those tried) at which every record gives a divergence above ln2/N:", first_L_min)
print("    L/(8N) > ln2/N exactly when L > 8 ln 2 = %.4f, that is for L >= 6" % (8 * LN2))

# --------------------------------------------------------------------------------------------
print("(H) two inequalities quoted in the ideas of H1 and H2")
worst_ev, worst_h = -1e9, -1e9
for _ in range(50000):
    k = rng.randint(2, 7)
    qs = rand_dist(k, zero_prob=0.6)
    qh = nrng.dirichlet(np.ones(k))
    G = qs == 0
    if G.any():
        kl = float(np.sum(qs[~G] * np.log(qs[~G] / qh[~G])))
        qG = float(qh[G].sum())
        qc = float(qh[~G].sum())      # 1 - Q^(G), summed directly to avoid cancellation
        worst_ev = max(worst_ev, qG - (-math.log(qc)), -math.log(qc) - kl)
    # Hoelder: E_P[(q_nu/q_P)^s] <= (1 - H2)^(2 min(s, 1 - s))
    p, q = rand_dist(k), rand_dist(k)
    s = 0.02 + 0.96 * rng.random()
    sup = p > 0
    lhs = float(np.sum(p[sup] ** (1.0 - s) * q[sup] ** s))
    rhs = (1.0 - hell2(p, q)) ** (2.0 * min(s, 1.0 - s))
    worst_h = max(worst_h, lhs - rhs)
print("    Q^(G) <= -ln(1 - Q^(G)) <= KL(Q* || Q^) for G = {Q* = 0}: max violation %.2e" % worst_ev)
print("    E_P[(q/p)^s] <= (1 - H2(p, q))^(2 min(s, 1-s)): max of lhs - rhs = %.2e" % worst_h)
assert worst_ev < 1e-12 and worst_h < 1e-12
# Example 4.4 of the proof file: one call per run; P = Bern(1/2) with weight 0.01, Bern(0.4) with
# weight 0.89, Bern(0.99) with weight 0.10; expected divergence of Q_P from the law of a run answered
# by a draw from the posterior after t recorded runs
ex44 = []
cls = [(0.01, 0.5), (0.89, 0.4), (0.10, 0.99)]
for t in range(0, 6):
    e = 0.0
    for k in range(t + 1):
        post = [wt * (pp ** k) * ((1 - pp) ** (t - k)) for (wt, pp) in cls]
        ph = sum(x * pp for x, (wt, pp) in zip(post, cls)) / sum(post)
        e += math.comb(t, k) * 0.5 ** t * (0.5 * math.log(0.5 / ph) + 0.5 * math.log(0.5 / (1 - ph)))
    ex44.append(e)
print("    Example 4.4, expected divergence after t = 0, ..., 5 recorded runs: " + ", ".join("%.5f" % x for x in ex44))
assert ["%.5f" % x for x in ex44] == ["0.00321", "0.01058", "0.02451", "0.03794", "0.04298", "0.03988"]
assert ex44[4] > ex44[3] > ex44[2] > ex44[1] > ex44[0]
# H2 at lambda = 2, s = 1/2
for (K, eps, dl) in ((1, 0.5, 0.1), (10, 0.1, 0.05), (40, 0.03, 0.01)):
    N = math.ceil((K * LN2 + math.log(1 / dl)) / eps ** 2)
    bound = 2.0 ** K * (1.0 - eps * eps) ** N
    assert bound <= dl and eps * math.sqrt(2 - eps * eps) < math.sqrt(2) * eps
    print("    K = %d, eps = %.2f, delta = %.2f: N = %d runs, 2^K (1 - eps^2)^N = %.4g <= delta" % (K, eps, dl, N, bound))

# --------------------------------------------------------------------------------------------
print("(J) Example 2.8(ii) in 30-digit arithmetic, from its description in the proof file")
mp.mp.dps = 30


def g(q):
    return 1 + q * mp.exp(q * q / 4) * (1 / mp.sqrt(2) + mp.sqrt(mp.pi) / 2 * mp.erf(q / 2))


q0 = mp.findroot(lambda q: g(q) - 1 / (1 - q * q / 2), mp.mpf("1.15"))
cstar = 1 / (1 - q0 * q0 / 2)
print("    q0 = %s" % mp.nstr(q0, 25))
print("    c* = %s" % mp.nstr(cstar, 25))
assert mp.mpf("2.96414712") < cstar < mp.mpf("2.96414723")


def levels(beta, top=mp.mpf(10) ** 6):
    """The numbers (pi_k, d_k) of the levels k = 0, 1, ... with beta^k <= top."""
    beta = mp.mpf(beta)
    lam = mp.mpf(1)
    out = []
    q_prev = q0
    k = 0
    while lam <= top:
        if k == 0:
            d = beta ** mp.mpf("-0.01")
        elif lam < cstar:
            s = lam / cstar
            # q(s): the root of 1/g(q) = s; it lies in (0, q_prev) because 1/g decreases from 1
            qq = mp.findroot(lambda q: 1 / g(q) - s, (mp.mpf(0), q_prev), solver="anderson",
                             tol=mp.mpf(10) ** (-27), maxsteps=200)
            assert 0 < qq <= q0 and abs(1 / g(qq) - s) < mp.mpf(10) ** (-24)
            q_prev = qq
            d = qq * qq / (2 * (1 - s))        # q/p with p = 2(1 - s)/q
        else:
            d = mp.mpf(0)
        assert 0 <= d < 1
        pi_k = (beta * beta - 1) / (beta * beta - d * d)
        # S' is a sampler: "drop" with probability pi_k d^2, "up" with probability (1 - pi_k) beta^2
        assert abs(pi_k * d * d + (1 - pi_k) * beta * beta - 1) < mp.mpf(10) ** (-25)
        out.append((pi_k, d))
        lam *= beta
        k += 1
    return out


def example(beta):
    """H2 by the formula of Theorem 2.1(a), sigma, H2 directly from the run laws, and the S'-mass."""
    beta = mp.mpf(beta)
    lv = levels(beta)
    lam = mp.mpf(1)          # beta^k, the root likelihood ratio at level k
    R = mp.mpf(1)            # probability under S of reaching level k
    Rp = mp.mpf(1)           # probability under S' of reaching level k
    H2, sig, bc, mass = mp.mpf(0), mp.mpf(0), mp.mpf(0), mp.mpf(0)
    for (pi_k, d) in lv:
        h = 1 - pi_k * d - (1 - pi_k) * beta   # squared Hellinger distance of the two answer laws
        assert h >= 0
        H2 += R * lam * h
        sig += R * h
        # the run "up k times, then drop": probability R pi_k under S and Rp pi_k d^2 under S'
        bc += mp.sqrt(R * pi_k * Rp * pi_k * d * d)
        mass += Rp * pi_k * d * d
        R *= (1 - pi_k)
        Rp *= (1 - pi_k) * beta * beta
        lam *= beta
    bc += mp.sqrt(R * Rp)    # the run that reaches the top level and stops there
    mass += Rp
    return len(lv), H2, sig, 1 - bc, mass


for beta in ("1.1", "1.01", "1.001", "1.0001"):
    k, H2, sig, H2d, mass = example(beta)
    assert abs(H2d - H2) < mp.mpf(10) ** (-22)
    print("    beta = %-6s levels = %6d  H2 = %s  sigma = %s  ratio = %s  (from the run laws: %s; S'-mass - 1 = %s)  c* - ratio = %s"
          % (beta, k, mp.nstr(H2, 8), mp.nstr(sig, 8), mp.nstr(H2 / sig, 9), mp.nstr(H2d / sig, 9),
             mp.nstr(mass - 1, 3), mp.nstr(cstar - H2 / sig, 4)))
    sys.stdout.flush()
    assert H2 / sig < cstar
    if beta == "1.0001":
        assert mp.mpf("2.96399") < H2 / sig < mp.mpf("2.9640")

print("all assertions passed")
print("run time %.0f s" % (time.time() - T0), file=sys.stderr)
