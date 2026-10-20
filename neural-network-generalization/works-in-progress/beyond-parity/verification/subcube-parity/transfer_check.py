"""Heuristic transfer check (NOT a test of the theorem, which is asymptotic):
GP-regression posterior mean (kernel interpolation, L=2 arcsine kernel on D=d+1 bits) for
  f*   : staircase on z=+1, parity on z=-1
  ctrl : x_1 on z=+1, parity on z=-1
  par  : parity on z=-1 only (z=+1 labels replaced by parity too -> chi_[d](x) everywhere, k=1 dummy)
Reports sign error of the mean on the z=-1 half (test points not in the sample)."""
import itertools, numpy as np, sys
d = int(sys.argv[1]) if len(sys.argv) > 1 else 11
D = d + 1
W = np.array(list(itertools.product([-1, 1], repeat=D)), dtype=float)
x, z = W[:, :d], W[:, d]
pref = np.cumprod(x, axis=1)
par = pref[:, -1]
stair = np.sign(pref.sum(1))
tg = {"fstar": np.where(z > 0, stair, par), "ctrl": np.where(z > 0, x[:, 0], par), "parall": par}
G = (1 + W @ W.T) / (D + 1)
K = 2 / np.pi * np.arcsin(np.clip(G, -1, 1))
rng = np.random.default_rng(1)
M = len(W)
for n in [M // 16, M // 8, M // 4, M // 2]:
    res = {k: [] for k in tg}
    for rep in range(5):
        S = rng.choice(M, n, replace=False)
        test = np.setdiff1d(np.arange(M), S)
        tneg = test[z[test] < 0]
        KS = K[np.ix_(S, S)] + 1e-10 * np.eye(n)
        for name, f in tg.items():
            alpha = np.linalg.solve(KS, f[S])
            m = K[np.ix_(tneg, S)] @ alpha
            res[name].append(np.mean(np.sign(m) != f[tneg]))
    print(f"d={d} n={n}: " + "  ".join(f"{k} {np.mean(v):.3f}" for k, v in res.items()))
