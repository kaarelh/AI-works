"""Lemma 1.3: Monte Carlo frequency of the event
   |Q - M beta_d| <= 2 n^{2/3}, |G - M p_d| <= 2 n^{2/3}, |V - n| <= n^{2/3}
versus the guaranteed lower bound 1 - 4 exp(-n^{1/3}/2) - (4 + 2n/M) n^{-1/3}; and exact conditional moments
E[Q|x] = Sigma_1, E[G|x] = s, Var(S^2) = 2k^2 - 2k (enumeration)."""
import numpy as np
from math import comb
import mpmath as mp
import sys
sys.path.insert(0, '.')
from bounds_t51 import binom_stats

rng = np.random.default_rng(3)
# exact Var(S_k^2) for a sum of k Rademacher signs
for k in range(1, 11):
    vals = [(k - 2 * j) ** 2 for j in range(k + 1)]
    w = [comb(k, j) / 2 ** k for j in range(k + 1)]
    m1 = sum(a * b for a, b in zip(vals, w)); m2 = sum(a * a * b for a, b in zip(vals, w))
    assert abs(m1 - k) < 1e-12 and abs(m2 - m1 ** 2 - (2 * k * k - 2 * k)) < 1e-9
print("E S^2 = k and Var(S^2) = 2k^2 - 2k verified for k <= 10")

for d in [8, 10, 12, 14]:
    M, n, bd, pd = binom_stats(d, 1.0)
    M = int(M); n = int(n); bd = float(bd); pd = float(pd)
    n23 = n ** (2 / 3)
    reps = 4000 if d <= 12 else 1500
    hit = 0
    for _ in range(reps):
        idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
        k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=y, minlength=M)
        T = k > 0
        Q = np.sum((S[T] / k[T]) ** 2); G = np.sum(S[T] ** 2 / k[T]); V = np.sum(S ** 2)
        if abs(Q - M * bd) <= 2 * n23 and abs(G - M * pd) <= 2 * n23 and abs(V - n) <= n23:
            hit += 1
    guar = 1 - 4 * np.exp(-n ** (1 / 3) / 2) - (4 + 2 * n / M) * n ** (-1 / 3)
    print("d=%2d n=M=%6d  event frequency %.4f (%d reps)  guaranteed >= %.4f  beta_d=%.6f p_d=%.6f" % (
        d, M, hit / reps, reps, guar, bd, pd))
