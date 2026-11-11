"""research-notes/A-tight-conditioning-fails.md (script added in revision 1): remaining numbers.
(1) Section 8.2 'Numbers': K_mem(d, 2^d, 1/2, H) versus the lower bound H((1-a) sqrt(s)/D_{d,H})^{2/H}, s = 2^d, a = 1/2.
(2) beta(lambda): beta(1), the maximiser, and beta'(lambda) = h - beta near 0 (sup |beta'| = 1, approached as lambda -> 0).
(3) Proposition 6.1(a') at n = M (all atoms seen once): for random y in {+-1}^M and random f with
    sum (f-y)^2 <= M eps', check 1 + (1 - sqrt eps')^2 <= 1 + mean f^2 <= 1 + (1 + sqrt eps')^2.
(4) Proposition 5.2 consequence: n_0 = max{8M log(2M/delta), (16M/delta + 4ct)/eps} for a few (d, eps, delta).
"""
import math
import numpy as np
from scipy import optimize, stats

def Kmem(d, s, a, H):
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    return d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))

print("(1) Section 8.2 numbers (s = 2^d, a = 1/2):")
for (H, d) in [(2, 40), (3, 40)]:
    s = 2 ** d; a = 0.5
    D = math.sqrt(2 * math.log(2)) * (d + 1) + (H - 1) / 2
    low = H * ((1 - a) * math.sqrt(s) / D) ** (2 / H)
    print(f"  (H,d)=({H},{d}): K_mem = {Kmem(d, s, a, H):.4e}, lower bound = {low:.4e}, D_dH = {D:.3f}")

def beta(lam):
    k = np.arange(1, int(lam + 40 * math.sqrt(lam) + 200))
    return float(np.sum(stats.poisson.pmf(k, lam) / k))
def h(lam):
    return (1 - math.exp(-lam)) / lam
print("\n(2) beta:")
print(f"  beta(1) = {beta(1.0):.7f}")
res = optimize.minimize_scalar(lambda l: -beta(l), bounds=(0.5, 3), method="bounded", options={"xatol": 1e-10})
print(f"  argmax = {res.x:.6f}, max = {-res.fun:.7f}, (1-e^-l)/l at argmax = {h(res.x):.7f}")
for lam in (1e-3, 1e-2, 0.1, 1.0, 5.0):
    print(f"  beta'({lam:g}) = h - beta = {h(lam) - beta(lam):+.5f}")
grid = np.linspace(0.01, 20, 2000)
print(f"  max |beta'| on [0.01, 20] = {max(abs(h(l) - beta(l)) for l in grid):.4f}  (sup over (0,inf) is 1, at 0+)")

print("\n(3) Proposition 6.1(a') two-sided bound at n = M, random instances:")
rng = np.random.default_rng(3)
viol = 0
for _ in range(20000):
    M = int(rng.integers(2, 200)); eps = float(rng.uniform(0, 1.5))
    y = rng.choice([-1.0, 1.0], size=M)
    u = rng.normal(size=M); u *= math.sqrt(M * eps) * rng.uniform(0, 1) / np.linalg.norm(u)
    f = y + u
    m = float(np.mean(f ** 2))
    lo = max(0.0, 1 - math.sqrt(eps)) ** 2; hi = (1 + math.sqrt(eps)) ** 2
    viol += not (lo - 1e-12 <= m <= hi + 1e-12)
print(f"  violations: {viol} / 20000")

print("\n(4) Proposition 5.2: sample size for excess <= eps with probability >= 1 - delta (c = t = 1):")
for d in (4, 8, 12):
    M = 2 ** d
    for (eps, delta) in [(0.1, 0.05), (0.01, 0.05)]:
        n0 = max(8 * M * math.log(2 * M / delta), (16 * M / delta + 4) / eps)
        print(f"  d={d}: eps={eps}, delta={delta}: n_0 = {n0:.3g} = {n0 / M:.3g} M")
