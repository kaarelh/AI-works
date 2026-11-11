"""Larger Monte Carlo for Var(V) = 2n(n-1)/M (Lemma 1.3), V = sum_x S_x^2; also exact formula check
by brute-force enumeration on a tiny instance (M=3, n=4)."""
import itertools, math
import numpy as np
rng = np.random.default_rng(2024)
for d, reps in [(6, 200000), (10, 40000), (12, 20000)]:
    M = 2**d; n = M
    Vs = np.empty(reps)
    for r in range(reps):
        idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
        S = np.bincount(idx, weights=ys, minlength=M)
        Vs[r] = np.sum(S**2)
    v = Vs.var(ddof=1); se = v*math.sqrt(2/(reps-1) + (np.mean((Vs-Vs.mean())**4)/v**2 - 3)/reps)
    print("d=%d reps=%d: E V=%.2f (n=%d), Var V=%.1f +- %.1f, formula 2n(n-1)/M=%.1f" % (d, reps, Vs.mean(), n, v, se, 2*n*(n-1)/M))
# exact enumeration
M, n = 3, 4
vals = []
for xs in itertools.product(range(M), repeat=n):
    for ys in itertools.product([-1, 1], repeat=n):
        S = [0]*M
        for x, y in zip(xs, ys): S[x] += y
        vals.append(sum(s*s for s in S))
vals = np.array(vals, float)
print("exact M=3,n=4: E V=%.6f (n=4), Var V=%.6f, formula=%.6f" % (vals.mean(), vals.var(), 2*n*(n-1)/M))
