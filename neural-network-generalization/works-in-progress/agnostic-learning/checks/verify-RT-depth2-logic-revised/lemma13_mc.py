"""Monte Carlo of the event of Lemma 1.3 (|Q - M beta_d| <= 2 n^{2/3}, |G - M p_d| <= 2 n^{2/3}, |V - n| <= n^{2/3})
for n = M uniform draws on M atoms with fair signs, against the guaranteed level 1 - rho_n.
Exact beta_d, p_d from Bin(n, 1/M).  Also checks E[Q] = M beta_d and E[G] = M p_d, E[V] = n by simulation."""
import numpy as np
from scipy.stats import binom

rng = np.random.default_rng(11)
for d in (8, 10, 12, 14):
    M = 2 ** d; n = M
    ks = np.arange(1, 60)
    pk = binom.pmf(ks, n, 1 / M)
    beta_d = np.sum(pk / ks); p_d = 1 - binom.pmf(0, n, 1 / M)
    rho = 4 * np.exp(-n ** (1 / 3) / 2) + (4 + 2 * n / M) * n ** (-1 / 3)
    reps = 2000; hits = 0; Qs = []; Gs = []; Vs = []
    for _ in range(reps):
        idx = rng.integers(0, M, size=n)
        y = rng.choice([-1.0, 1.0], size=n)
        k = np.bincount(idx, minlength=M).astype(float)
        S = np.bincount(idx, weights=y, minlength=M)
        T = k > 0
        Q = np.sum((S[T] / k[T]) ** 2); G = np.sum(S[T] ** 2 / k[T]); V = np.sum(S ** 2)
        Qs.append(Q); Gs.append(G); Vs.append(V)
        n23 = n ** (2 / 3)
        hits += (abs(Q - M * beta_d) <= 2 * n23) and (abs(G - M * p_d) <= 2 * n23) and (abs(V - n) <= n23)
    print("d=%d: event freq %.4f, guarantee %.3f; mean Q/(M beta_d)=%.4f, mean G/(M p_d)=%.4f, mean V/n=%.4f" % (
        d, hits / reps, 1 - rho, np.mean(Qs) / (M * beta_d), np.mean(Gs) / (M * p_d), np.mean(Vs) / n))
