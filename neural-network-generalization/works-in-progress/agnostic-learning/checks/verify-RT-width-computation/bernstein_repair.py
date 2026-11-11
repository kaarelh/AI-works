"""Proposed repair of the competitor step of Prop. 6.1: replace Hoeffding by Bernstein.

For iid losses l_i = (g(x_i) - y_i)^2 in [0, b], b = (U+1)^2, mean L = L_D(g), Var <= b L:
  P(hat L(g) - L >= t) <= exp(-n t^2 / (2 b L + 2 b t / 3)),
so with probability >= 1 - delta/4:
  hat L(g) <= L + (U+1) sqrt(2 L ln(4/delta)/n) + 2 (U+1)^2 ln(4/delta)/(3n).          (B)
(1) Check (B) against exact binomial tails for two-valued losses (the worst case for given mean and range).
(2) Exponents with separate competitor-weight exponent beta: width <= n^alpha, weights <= n^beta, d <= n^alpha.
"""
import numpy as np
import mpmath as mp
from scipy.stats import binom

delta = 0.05
ld = np.log(4 / delta)
print("(1) exact tail P(hat L - L >= t_B) for losses in {0, b} with mean L (must be <= delta/4 = 0.0125)")
worst = 0
for n in (10 ** 3, 10 ** 5, 10 ** 7, 10 ** 9):
    for U in (1.0, 10.0, 100.0, 1000.0):
        b = (U + 1) ** 2
        for L in (1e-3, 0.1, 0.5, 1.0, 4.0):
            if L >= b:
                continue
            p = L / b  # loss = b with prob p, 0 otherwise
            tB = (U + 1) * np.sqrt(2 * L * ld / n) + 2 * b * ld / (3 * n)
            k = np.ceil(n * (L + tB) / b - 1e-12)  # hat L - L >= tB  <=>  K >= n (L + tB)/b
            tail = binom.sf(k - 1, n, p)
            worst = max(worst, tail)
print(f"   worst exact tail over the grid: {worst:.3e}")

print()
print("(2) slopes d ln(term)/d ln n between n = 1e100 and 1e200, L = 3, c = 1, N = m = ceil(n^a), B = n^b, d = n^a")
mp.mp.dps = 50


def terms(n, a, b, L=3):
    H = L - 1
    N = mp.ceil(n ** a); m = N; B = n ** b; d = mp.floor(n ** a); U = m * B
    E = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    K = E + 1 + n * (U + 1) ** 2
    P = N * (d + 1) + (L - 2) * N ** 2 + N
    T1 = (E + 1) / n
    T3 = 4 * mp.sqrt((P * mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2)) + mp.log(4 / mp.mpf(delta))) / (2 * n))
    T4 = (U + 1) ** 2 * mp.sqrt(mp.log(4 / mp.mpf(delta)) / (2 * n))
    T4B = (U + 1) * mp.sqrt(2 * mp.log(4 / mp.mpf(delta)) / n) + 2 * (U + 1) ** 2 * mp.log(4 / mp.mpf(delta)) / (3 * n)
    return dict(T1=T1, T3=T3, T4=T4, T4B=T4B)


for a, b in [("0.2", "0.2"), ("0.4", "0"), ("0.3", "0.15"), ("0.45", "0.04"), ("0.3", "0.25")]:
    a, b = mp.mpf(a), mp.mpf(b)
    n1, n2 = mp.mpf(10) ** 100, mp.mpf(10) ** 200
    t1, t2 = terms(n1, a, b), terms(n2, a, b)
    s = {k: (mp.log(t2[k]) - mp.log(t1[k])) / (mp.log(n2) - mp.log(n1)) for k in t1}
    print(f"alpha={float(a):.2f} beta={float(b):.2f}: T1 {float(s['T1']):+.3f} (2a+2b-1={float(2*a+2*b-1):+.3f})  "
          f"T3 {float(s['T3']):+.3f} (a-1/2={float(a-0.5):+.3f})  Hoeffding {float(s['T4']):+.3f} (2a+2b-1/2={float(2*a+2*b-0.5):+.3f})  "
          f"Bernstein {float(s['T4B']):+.3f} (a+b-1/2={float(a+b-0.5):+.3f})")
