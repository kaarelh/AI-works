"""Exact enumeration checks of Lemma 1.3's moment identities and bounded differences, and of Lemma 1.1's scalar steps.
(1) M atoms, n inputs (all M^n input sequences, all 2^n label sequences) for (M,n) in {(3,4),(4,5),(2,6),(5,4)}:
    E Sigma_1 = M beta_d, E s = M p_d, E[Q|x] = Sigma_1, Var(Q|x) = sum_T (2k^2-2k)/k^4 <= 2n,
    E[G|x] = s, Var(G|x) = sum_T (2k^2-2k)/k^2 <= 2n, E V = n, Var V = 2n(n-1)/M;
    bounded differences of Sigma_1 and s under a change of one input (claimed <= 2).
(2) Lemma 1.1: sup_{t>=0} (1+t) e^{-st} <= max{1,1/s}; rho chosen by (1-rho)^2 (n/c+zeta) = n/c + zeta/2 works for all m* <= n/c."""
import itertools, numpy as np
from fractions import Fraction as Fr
from math import comb

def binom_beta_p(n, M):
    p = Fr(1, M); b = Fr(0); P0 = (1 - p)**n
    for k in range(1, n + 1):
        b += Fr(comb(n, k)) * p**k * (1 - p)**(n - k) / k
    return b, 1 - P0

for (M, n) in [(3, 4), (4, 5), (2, 6), (5, 4)]:
    b, pd = binom_beta_p(n, M)
    ES1 = Fr(0); Es = Fr(0); EV = Fr(0); EV2 = Fr(0); maxd1 = Fr(0); maxds = 0
    ok_cond = True
    labels = list(itertools.product([-1, 1], repeat=n))
    for xs in itertools.product(range(M), repeat=n):
        k = [xs.count(j) for j in range(M)]
        S1 = sum(Fr(1, kk) for kk in k if kk > 0); s = sum(1 for kk in k if kk > 0)
        ES1 += S1; Es += s
        # bounded differences: change coordinate i to value b'
        for i in range(n):
            for bb in range(M):
                if bb == xs[i]: continue
                k2 = list(k); k2[xs[i]] -= 1; k2[bb] += 1
                S1b = sum(Fr(1, kk) for kk in k2 if kk > 0); sb = sum(1 for kk in k2 if kk > 0)
                maxd1 = max(maxd1, abs(S1b - S1)); maxds = max(maxds, abs(sb - s))
        # conditional label moments
        EQ = Fr(0); EQ2 = Fr(0); EG = Fr(0); EG2 = Fr(0)
        for ys in labels:
            Sx = [0] * M
            for xi, yi in zip(xs, ys): Sx[xi] += yi
            Q = sum(Fr(Sx[j]**2, k[j]**2) for j in range(M) if k[j] > 0)
            G = sum(Fr(Sx[j]**2, k[j]) for j in range(M) if k[j] > 0)
            V = sum(Sx[j]**2 for j in range(M))
            EQ += Q; EQ2 += Q * Q; EG += G; EG2 += G * G; EV += V; EV2 += V * V
        L = len(labels)
        EQ /= L; EQ2 /= L; EG /= L; EG2 /= L
        vQ = sum(Fr(2 * kk * kk - 2 * kk, kk**4) for kk in k if kk > 0)
        vG = sum(Fr(2 * kk * kk - 2 * kk, kk**2) for kk in k if kk > 0)
        if EQ != S1 or EQ2 - EQ**2 != vQ or EG != s or EG2 - EG**2 != vG or vQ > 2 * n or vG > 2 * n: ok_cond = False
    tot = M**n
    ES1 /= tot; Es /= tot; EV /= tot * len(labels); EV2 /= tot * len(labels)
    print("M=%d n=%d: E Sigma1 = M beta_d: %s; E s = M p_d: %s; cond. moments exact: %s; E V = n: %s; Var V = 2n(n-1)/M: %s; max BD Sigma1 = %s, s = %s" % (
        M, n, ES1 == M * b, Es == M * pd, ok_cond, EV == n, EV2 - EV**2 == Fr(2 * n * (n - 1), M), maxd1, maxds))

# (2) Lemma 1.1 scalar steps
worst = 0.0
for s in np.logspace(-4, 4, 2001):
    t = np.concatenate([np.linspace(0, 50 / s, 20001), [max(1 / s - 1, 0)]])
    val = np.max((1 + t) * np.exp(-s * t))
    worst = max(worst, val / max(1, 1 / s))
print("sup_t (1+t)e^{-st} / max{1,1/s} over s in [1e-4,1e4]: %.6f (<=1 needed)" % worst)
bad = 0
for A in [0.1, 1, 10, 1e3, 1e6]:      # A = n/c
    for zeta in [0.1, 1, 5]:
        rho = 1 - np.sqrt((A + zeta / 2) / (A + zeta))
        for m in np.linspace(0, A, 101):
            if (1 - rho)**2 * (m + zeta) < m + zeta / 2 - 1e-9 * (A + zeta): bad += 1
print("rho choice: violations of (1-rho)^2 (m*+zeta) >= m*+zeta/2 for m* in [0, n/c]: %d" % bad)
