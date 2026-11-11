"""Scope check 3: A-prime does not transfer to TUBE.

In Theorem 7.2's law D'_{d,r} (r chosen from K_2 = max{n/c+t, K_mem}), suppose some cluster holds two
training points with different labels.  Any w in U_{rho,S} (rho<1) has |z_w(x_i)-z_w(x_j)| > 2-2rho with
||x_i-x_j|| <= r sqrt(d).  Lemma 3.1(b): |z(x)-z(x')| <= (kappa/L)^{L/2} ||x-x'|| / sqrt(d)  =>
   kappa > L ((2-2rho)/r)^{2/L} = (2-2rho)^{2/L} n^{2/L} K_2.
So every TUBE-feasible network has energy far above K_2 and can vary by ~2 inside a cluster: Step 2 of
Theorem 7.2 (near-constancy on clusters) is unavailable for TUBE.

We also Monte-Carlo the probability that some cluster carries both labels (pairs (p_i,y_i) are iid D_d).
"""
import math
import numpy as np

rng = np.random.default_rng(7)
print("Energy floor for TUBE-feasible networks on A-prime data (c=t=1, lambda=1, rho=1/2):")
for H in (2, 3):
    L = H + 1
    for d in (20, 30, 40):
        n = 2 ** d
        K2 = n + 1.0
        floor = (2 - 2 * 0.5) ** (2 / L) * n ** (2 / L) * K2
        print(f"  H={H} d={d}: K_2={K2:.3g}, TUBE energy floor={floor:.3g}, ratio floor/K_2={floor/K2:.3g}")

print("\nP(some atom/cluster carries both labels), fair labels, n = M (Monte Carlo, 2000 reps):")
for d in (6, 8, 10, 12):
    M = 2 ** d; n = M; reps = 2000; hits = 0
    for _ in range(reps):
        xs = rng.integers(0, M, size=n); ys = rng.integers(0, 2, size=n)
        pos = np.bincount(xs, weights=ys, minlength=M); cnt = np.bincount(xs, minlength=M)
        hits += np.any((pos > 0) & (pos < cnt))
    print(f"  d={d}: {hits/reps:.4f}")

print("\nFixed d, non-centred labels P(y=1)=(1+eta0)/2, eta0=0.5: P(no atom carries both labels) as n grows")
p = 0.75
for d in (1, 3):
    M = 2 ** d
    for n in (4, 16, 64, 256):
        reps = 4000; ok = 0
        for _ in range(reps):
            xs = rng.integers(0, M, size=n); ys = (rng.random(n) < p).astype(int)
            pos = np.bincount(xs, weights=ys, minlength=M); cnt = np.bincount(xs, minlength=M)
            ok += not np.any((pos > 0) & (pos < cnt))
        print(f"  d={d}, n={n}: {ok/reps:.4f}")
