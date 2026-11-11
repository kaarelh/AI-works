# Lemma E(ii) of RT-width.fixed.md:  Z_i in [0,b] iid, mean mu,
#   Pr( Zbar - mu >= sqrt(2 b mu l/n) + 2 b l/(3n) ) <= exp(-l).
# Exact check for two-point laws Z in {0, b} (worst case for the variance proxy b*mu),
# and for three-point laws via exact convolution (small n).
import numpy as np
from scipy import stats
import itertools, math

worst = 0.0; worst_case = None; cases = 0
for n in [1, 2, 3, 5, 10, 30, 100, 1000, 10**4, 10**5, 10**6, 10**8]:
    for p in [1e-9, 1e-6, 1e-4, 1e-3, 0.01, 0.05, 0.1, 0.3, 0.5, 0.9, 0.999]:
        for delta in [1e-9, 1e-4, 0.01, 0.05, 0.25, 0.9]:
            b = 1.0  # scale-free for two-point laws
            mu = b * p
            l = math.log(1 / delta)
            thr = mu + math.sqrt(2 * b * mu * l / n) + 2 * b * l / (3 * n)
            # Zbar = b*Bin(n,p)/n >= thr  <=>  Bin >= ceil(n*thr/b) (with float guard)
            k = math.ceil(n * thr / b - 1e-12)
            tail = stats.binom.sf(k - 1, n, p)
            ratio = tail / delta
            cases += 1
            if ratio > worst:
                worst = ratio; worst_case = (n, p, delta, tail)
print("two-point laws: cases=%d, max exact tail/delta = %.4g at (n,p,delta,tail)=%s" % (cases, worst, worst_case))

# three-point laws {0, b/2, b} with exact multinomial convolution for n <= 60
rng = np.random.default_rng(7)
worst3 = 0.0; cases3 = 0
for n in [1, 2, 4, 8, 16, 32, 60]:
    for _ in range(60):
        pr = rng.dirichlet([0.3, 0.3, 0.3])
        vals = np.array([0.0, 0.5, 1.0])
        # distribution of sum of n iid draws, support on multiples of 0.5 -> integer index 0..2n
        pmf = np.array([1.0])
        step = np.array([pr[0], pr[1], pr[2]])  # index 0,1,2 in units of 0.5
        for _i in range(n):
            pmf = np.convolve(pmf, step)
        mu = float(pr @ vals)
        for delta in [1e-6, 0.01, 0.05, 0.25]:
            l = math.log(1 / delta)
            thr = mu + math.sqrt(2 * 1.0 * mu * l / n) + 2 * 1.0 * l / (3 * n)
            idx = np.arange(len(pmf)) * 0.5 / n  # Zbar values
            tail = pmf[idx >= thr - 1e-12].sum()
            worst3 = max(worst3, tail / delta); cases3 += 1
print("three-point laws: cases=%d, max exact tail/delta = %.4g" % (cases3, worst3))

# The spiky competitor of Remark 6(b): Z = (G+1)^2 w.p. p=(G+1)^{-2}, else 0; L_D(g)=1.
# Theorem 1(b) Bernstein event with b=(U+1)^2, U>=G: check failure prob <= delta/4.
worst_s = 0.0
for n in [10**4, 10**6, 10**8, 10**10, 10**12]:
    for alpha in [0.1, 0.2, 0.24]:
        m = math.ceil(n**alpha); B = n**alpha
        G = m * B * math.tanh(m * B * math.tanh(B))
        U = m * B
        p = (G + 1) ** -2
        for delta in [0.01, 0.05, 0.2]:
            l = math.log(4 / delta)
            Gam = (U + 1) * math.sqrt(2 * 1.0 * l / n) + 2 * (U + 1) ** 2 * l / (3 * n)
            # hat L(g) = (G+1)^2 Bin/n  > 1 + Gam  <=> Bin > n(1+Gam)/(G+1)^2
            k = math.floor(n * (1 + Gam) / (G + 1) ** 2 + 1e-12) + 1
            tail = stats.binom.sf(k - 1, n, p)
            worst_s = max(worst_s, tail / (delta / 4))
print("Remark 6(b) competitor, Bernstein event of Theorem 1(b): max failure/(delta/4) = %.4g" % worst_s)
