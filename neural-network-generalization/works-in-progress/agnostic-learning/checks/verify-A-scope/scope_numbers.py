"""Numbers used in the scope referee report on A.r1.md.

1. N_0/n at a fixed memoriser accuracy a (Lemma 2.1 with s = n = 2^d).
2. B.md Corollary 8.1's error term Xi_n * n^{-beta}: it vanishes along n = 2^d with
   d = log2 n, but not uniformly over d <= n^alpha once alpha >= 1/(6H+4).
3. E W / n at lambda = 1 (training MSE of the tight learner's near-minimisers).
4. A' density ratio at (H,d) = (2,20), c = t = 1.
5. beta(lambda) at a few lambda (for the "window" discussion).
"""
import math
import numpy as np
from scipy import integrate

LOG2 = math.log(2)

print("1. N_0/n = 64 log2 d(d+1)/a^2 (s = n):")
for a in (0.1, 0.3):
    vals = [64 * LOG2 * d * (d + 1) / a ** 2 for d in (20, 30, 40)]
    print(f"   a={a}: d=20,30,40 -> " + ", ".join(f"{v:.3g}" for v in vals))

print("\n2. B.md Cor 8.1 error term Xi_n n^-beta (H=2, L=3, delta=0.05):")
H, L, delta = 2, 3, 0.05
def xi(n, d):
    return d * (d + 1) + 2 * L + 8 * (2 / H) ** (H / 2) * (math.sqrt(2 * (d + 1) * math.log(n + 1)) + (H - 1) / 2) \
        + 4 * math.sqrt(2 * math.log(2 / delta))
print(f"   threshold alpha* = 1/(6H+4) = {1/(6*H+4):.4f}; Cor 8.1 needs alpha < 1/(4H) = {1/(4*H):.4f}")
for alpha in (0.04, 0.0625, 0.1):
    beta = (1 - 4 * alpha * H) / (H + 2)
    rows = []
    for log2n in (40, 80, 160, 320):
        n = 2.0 ** log2n
        d_log = log2n
        d_pow = n ** alpha
        rows.append((log2n, xi(n, d_log) * n ** (-beta), xi(n, d_pow) * n ** (-beta)))
    print(f"   alpha={alpha}, beta={beta:.4f}: (log2 n, term at d=log2 n, term at d=n^alpha) = "
          + "; ".join(f"({a},{b:.3g},{c:.3g})" for a, b, c in rows))

print("\n3. E W/n at lambda=1, n=M=2^d (W = within-atom sum of squares):")
for d in (10, 20, 30):
    M = 2.0 ** d
    n = M
    ES = M * (1 - (1 - 1 / M) ** n)
    print(f"   d={d}: E W/n = 1 - E|S|/n = {1 - ES/n:.6f}   (e^-1 = {math.exp(-1):.6f})")

print("\n4. A' density ratio log10 r^-d at (H,d)=(2,20), c=t=1, a=a_d:")
H, d = 2, 20
L = H + 1
n = 2 ** d
M = 2 ** d
c, t = 1.0, 1.0
a = (max(c, 1) / 2 ** d) ** (1 / 3)
alpha_d = 0.5 * math.log(4 * math.sqrt(2 * d))
Kmem = d * (d + 1) * alpha_d ** 2 + (H + 1) * max((8 * d * n) ** (1 / H), 9 / (2 * a))
K2 = max(n / c + t, Kmem)
log10r = -math.log10(n) + (L / 2) * math.log10(L / K2)
print(f"   K_mem={Kmem:.4g}, K2={K2:.4g}, log10 r = {log10r:.3f}, log10 r^-d = {-d*log10r:.1f}")

print("\n5. beta(lambda) = e^-lambda int_0^lambda (e^u-1)/u du:")
def beta(lam):
    val, _ = integrate.quad(lambda u: math.expm1(u) / u if u > 0 else 1.0, 0, lam, limit=200)
    return math.exp(-lam) * val
for lam in (0.01, 0.1, 0.5, 1.0, 1.50286, 4.0, 16.0, 64.0):
    print(f"   beta({lam}) = {beta(lam):.6f}   lambda*beta = {lam*beta(lam):.4f}")
