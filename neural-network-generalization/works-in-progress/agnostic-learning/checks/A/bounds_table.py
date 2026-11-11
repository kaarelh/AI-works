"""Explicit values of the high-probability lower bound of Theorem 4.1 in A.md:
   excess >= e_low = ( sqrt( (beta_n - sqrt(2 lam log(1/delta)/M))_+ ) - sqrt(eps) )_+^2,
   eps = c (K_mem + t)/M + lam a^2,  K_mem = d(d+1) alpha_d^2 + (H+1) max{(8 d s)^{1/H}, 9/(2a)},  s = min(n, M),
   width threshold N_0 = floor(64 log2 d (d+1) s / a^2) + 1.
We optimize a on a grid; delta = 0.01, t = 1.  Also the largest c for which e_low >= beta/2 (c-threshold check).
"""
import math
import numpy as np
from scipy import stats

def beta_bin(n, M):
    k = np.arange(1, min(n, 400) + 1)
    return float(np.sum(stats.binom.pmf(k, float(n), 1.0 / M) / k))

def e_low(d, H, lam, c, a, t=1.0, delta=0.01):
    M = 2 ** d; n = int(round(lam * M)); s = min(n, M)
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    Kmem = d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))
    eps = c * (Kmem + t) / M + (n / M) * a ** 2
    bn = beta_bin(n, M)
    conc = math.sqrt(2 * (n / M) * math.log(1 / delta) / M)
    val = max(0.0, math.sqrt(max(0.0, bn - conc)) - math.sqrt(eps)) ** 2
    N0 = math.floor(64 * math.log(2) * d * (d + 1) * s / a ** 2) + 1
    return val, Kmem, eps, bn, N0

def best_over_a(d, H, lam, c):
    best = None
    for e in np.linspace(0, 14, 561):
        a = 10 ** (-e)
        out = e_low(d, H, lam, c, a)
        if best is None or out[0] > best[0][0]:
            best = (out, a)
    return best

print("c = 1, lambda = 1 (beta = 0.4848) and lambda = 1.5 (beta = 0.5174); delta = 0.01, t = 1")
for H in [2, 3, 4]:
    for lam in [1.0, 1.5]:
        for d in [20, 30, 40, 50, 60, 80]:
            (val, Kmem, eps, bn, N0), a = best_over_a(d, H, lam, 1.0)
            print(f"  H={H} lam={lam} d={d:2d}: excess LB={val:.4f} (beta_n={bn:.4f}), a*={a:.2e}, "
                  f"K_mem={Kmem:.3e}, eps={eps:.2e}, N0={N0:.2e}")
print("\nLargest c (on a log grid) with excess LB >= beta_n/2, compared with n^{1-1/H} d^{-1/H}:")
for H in [2, 3]:
    for d in [30, 40, 60]:
        n = 2 ** d; cbest = None
        for e in np.linspace(0, 1.0 * math.log10(n), 400):
            c = 10 ** e
            (val, Kmem, eps, bn, N0), a = best_over_a(d, H, 1.0, c)
            if val >= bn / 2:
                cbest = c
        print(f"  H={H} d={d}: c_max ~ {cbest:.3e};  n^(1-1/H) d^(-1/H) = {n**(1-1/H) * d**(-1/H):.3e}")
