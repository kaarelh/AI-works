#!/usr/bin/env python3
"""Independent randomized checks of three structural statements of Paper 2 (seeded, numpy only).
(1) prop:absorb:price key step: sum_pi 2^{-lam l} nu_pi(D_beta) <= R~(beta)^{min(lam,2)} on random finite product classes.
(2) lem:teacher:list / lem:teacher:floor at small d: Parseval list size and the floor E nu(y*) <= u + p.
(3) lem:setup:hull (iii): 'unique minimiser on an open c-interval' iff 'vertex of C' on random point sets.
"""
import numpy as np, itertools
rng = np.random.default_rng(20261012)

# (1) price inequality
viol = 0; tests = 0; worst = 0.0
for trial in range(300):
    k = int(rng.integers(1, 5))
    nprog = int(rng.integers(1, 7))
    lens = rng.integers(1, 6, nprog)
    if (2.0**-lens).sum() > 1: lens = lens + 3
    nus = []
    for _ in range(nprog):
        # conditional semimeasure on inputs a_i, b_i (i<k): nu(1|x), nu(0|x) with total <= 1
        a = rng.dirichlet(np.ones(3), size=2*k)[:, :2]*rng.uniform(0.5, 1.0)
        nus.append(a)  # rows 0..k-1 for a_i, k..2k-1 for b_i; columns label 0,1
    for lam in (1.0, 1.3, 1.7, 2.0, 2.5, 4.0):
        g = min(lam, 2.0)
        for beta in itertools.product((0, 1), repeat=k):
            lhs = 0.0; Rt = 0.0
            for l, nu in zip(lens, nus):
                lik = np.prod([nu[i, beta[i]]*nu[k+i, beta[i]] for i in range(k)])
                Q = np.prod([(nu[i, beta[i]] + nu[k+i, beta[i]])/2 for i in range(k)])
                lhs += 2.0**(-lam*l)*lik; Rt += 2.0**(-l)*Q
            tests += 1
            if lhs > Rt**g*(1+1e-12): viol += 1
            worst = max(worst, lhs/Rt**g)
print(f"(1) price inequality: {tests} cases, violations {viol}, max ratio lhs/R^gamma = {worst:.4f}")

# (2) list decoding and floor at d = 6
d = 6; N = 2**d
X = np.array([[(x >> (d-1-i)) & 1 for i in range(d)] for x in range(N)])
chars = (-1.0)**((X @ X.T) % 2)  # chars[a', x]
viol_list = 0; viol_floor = 0; viol_id = 0
for trial in range(400):
    h0 = rng.uniform(0, 1, N)**rng.uniform(0.2, 3); h1 = (1 - h0)*rng.uniform(0, 1, N)
    if trial % 4 == 0:  # make it correlated with a parity
        a = rng.integers(0, 2, d); fa = (X @ a) % 2
        h0 = np.where(fa == 0, 0.9, 0.05); h1 = np.where(fa == 1, 0.9, 0.05)
    s = h0 - h1
    shat = chars @ s / N
    for t in range(1, 4):
        theta = 0.5 + 2.0**(-t-1)
        u_all = np.array([np.mean(np.where((X @ np.array(ap)) % 2 == 0, h0, h1)) for ap in itertools.product((0,1), repeat=d)])
        # identity u(a') = (E[h0+h1] + shat(a'))/2 with matching enumeration order
        u_id = (np.mean(h0+h1) + shat)/2
        if np.max(np.abs(u_all - u_id)) > 1e-12: viol_id += 1
        if np.sum(u_all > theta) >= 2**(2*t): viol_list += 1
    # floor: E nu(y*|x) <= u + p for a random error set E of density p
    a = rng.integers(0, 2, d); fa = (X @ a) % 2
    E = rng.choice(N, size=4, replace=False); p = 4/N
    ystar = fa.copy(); ystar[E] ^= 1
    u = np.mean(np.where(fa == 0, h0, h1)); Ey = np.mean(np.where(ystar == 0, h0, h1))
    if Ey > u + p + 1e-12: viol_floor += 1
print(f"(2) list decoding: identity violations {viol_id}, list-size violations {viol_list}; floor violations {viol_floor} (400 hypotheses, d=6)")

# (3) hull lemma (iii)
from fractions import Fraction as Fr
def lower_vertices(pts):
    pts = sorted(set(pts))
    # lower-left convex hull of point set + orthant: vertices are Pareto-optimal points on the lower convex chain
    # build chain from least-l point (least R among those) moving right with steepest descent
    cur = min(pts, key=lambda q: (q[0], q[1]))
    verts = [cur]
    while True:
        cand = [q for q in pts if q[0] > cur[0] and q[1] < cur[1]]
        if not cand: break
        best = max(cand, key=lambda q: (Fr(cur[1]-q[1], q[0]-cur[0]), q[0]))
        verts.append(best); cur = best
    return verts
mism = 0; total = 0
for trial in range(400):
    npts = int(rng.integers(2, 12))
    pts = [(int(rng.integers(0, 15)), int(rng.integers(0, 15))) for _ in range(npts)]
    V = set(lower_vertices(pts))
    for a in set(pts):
        # unique minimising point for every c in some open interval: test on a fine rational grid of c and look for 2 consecutive grid points
        cs = [Fr(i, 64) for i in range(1, 64*20)]
        uniq = []
        for c in cs:
            vals = {q: c*q[0] + q[1] for q in set(pts)}
            mn = min(vals.values())
            arg = [q for q in vals if vals[q] == mn]
            uniq.append(len(arg) == 1 and arg[0] == a)
        has_int = any(uniq[i] and uniq[i+1] for i in range(len(uniq)-1))
        total += 1
        if has_int != (a in V): mism += 1
print(f"(3) hull (iii): {total} (set, point) pairs, mismatches {mism} (integer points; c-grid step 1/64, which resolves all slopes of integer points with coordinates < 15)")
