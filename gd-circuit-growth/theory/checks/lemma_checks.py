"""Checks of the elementary lemmas in ../A-discrete-model.md, and the table of A1 bounds.

1. Lemma 1 (Cover-type count): the number of threshold functions sgn(c0 + c.z) on
   {-1,1}^T is at most Phi(2^T, T) = 2 sum_{i<=T} C(2^T - 1, i) <= 2^(T^2+1).
   Brute force by LP feasibility for T <= 3 (and T = 4 if --t4).
2. kl(q||p) >= (p-q)^2/(2p) for q <= p, and the Bernstein-form inversion.
3. Table of the A1 realizable bound (kl inversion) for the NN experiment's d = 30,
   library sizes |G| in {6, 16}, fan-in k = 2, delta = 0.05.

Run: python3 lemma_checks.py > lemma_checks.txt   (a few seconds; --t4 adds ~1 min)
"""
import itertools, math, sys
import numpy as np
from scipy.optimize import linprog

def is_threshold(vals, Z):
    # feasibility of  s_j (c0 + c.z_j) >= 1  for all j
    A = -(vals[:, None] * np.hstack([np.ones((len(Z), 1)), Z]))
    res = linprog(np.zeros(Z.shape[1] + 1), A_ub=A, b_ub=-np.ones(len(Z)), bounds=[(None, None)] * (Z.shape[1] + 1),
                  method="highs")
    return res.status == 0

def phi(N, T):
    return 2 * sum(math.comb(N - 1, i) for i in range(0, min(T, N - 1) + 1))

print("## 1. Threshold-function counts on {-1,1}^T: brute force vs Phi(2^T,T) vs 2^(T^2+1)")
Tmax = 4 if "--t4" in sys.argv else 3
for T in range(1, Tmax + 1):
    Z = np.array(list(itertools.product([-1.0, 1.0], repeat=T)))
    cnt = sum(is_threshold(np.array(v), Z) for v in itertools.product([-1.0, 1.0], repeat=len(Z)))
    print(f"T={T}: exact {cnt}, Phi = {phi(2**T, T)}, 2^(T^2+1) = {2**(T*T+1)}")
print("Known exact counts (OEIS A000609, from memory): 4, 14, 104, 1882, 94572, 15028134, ...")
for T in range(1, 9):
    print(f"   T={T}: Phi(2^T,T) = {phi(2**T, T):.4g}")

print("\n## 2. kl(q||p) >= (p-q)^2/(2p) on a grid; Bernstein inversion p <= q + sqrt(2qL) + 2L")
def kl(q, p):
    a = 0 if q == 0 else q * math.log(q / p)
    b = 0 if q == 1 else (1 - q) * math.log((1 - q) / (1 - p))
    return a + b
worst = min(kl(q, p) - (p - q) ** 2 / (2 * p) for p in np.linspace(1e-4, 1 - 1e-4, 300) for q in np.linspace(0, p, 50))
print(f"min over grid of kl - (p-q)^2/(2p) = {worst:.3e} (should be >= 0)")
bad = 0
for p in np.linspace(1e-4, 1 - 1e-4, 200):
    for q in np.linspace(0, p, 40):
        L = kl(q, p)
        if p > q + math.sqrt(2 * q * L) + 2 * L + 1e-12:
            bad += 1
print(f"violations of the Bernstein inversion on the grid: {bad}")

print("\n## 3. A1 realizable bound (test error when train error = 0), kl inversion, delta = 0.05, d = 30, k = 2")
def kl_inv(q, c):
    lo, hi = q, 1.0 - 1e-15
    for _ in range(100):
        mid = (lo + hi) / 2
        if kl(q, mid) <= c: lo = mid
        else: hi = mid
    return lo
def L_T(T, G, d=30, k=2, delta=0.05):
    W = sum(math.log(G) + k * math.log(d + t - 1) for t in range(1, T + 1))
    R = math.log(phi(2 ** min(T, d), T))
    return W + R + math.log((T + 1) * (T + 2) / delta), W, R
ns = [16, 64, 256, 1024, 4096, 16384]
for G in [6, 16]:
    print(f"\n|G| = {G}")
    print(f"{'T':>3} {'L_T':>7} {'wiring':>7} {'readout':>7} | " + " ".join(f"n={n:>5}" for n in ns) + " | n for bound<=0.1")
    for T in [1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 30]:
        L, W, R = L_T(T, G)
        vals = [min(1.0, kl_inv(0.0, L / n)) for n in ns]
        n01 = math.ceil(L / -math.log(0.9))
        print(f"{T:3d} {L:7.1f} {W:7.1f} {R:7.1f} | " + " ".join(f"{v:7.3f}" for v in vals) + f" | {n01}")
print("\nAgnostic (Hoeffding) gap sqrt(L_T/2n), |G| = 6:")
for T in [1, 3, 5, 10, 20]:
    L = L_T(T, 6)[0]
    print(f"T={T:2d}: " + " ".join(f"{math.sqrt(L/(2*n)):.3f}" for n in ns))
