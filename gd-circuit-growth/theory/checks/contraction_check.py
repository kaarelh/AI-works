"""Numerical check of Lemma B2.0 (comparison inequality for convex increasing G, psi_i(0) = 0).
Exact expectations over all 2^n sign vectors, random finite T, random 1-Lipschitz psi_i with psi_i(0)=0,
several convex increasing G.  Also shows that dropping psi(0)=0 breaks it."""
import itertools
import numpy as np

rng = np.random.default_rng(0)
n = 5
signs = np.array(list(itertools.product([-1, 1], repeat=n)), dtype=float)
psis = [lambda u: np.maximum(u, 0), np.tanh, np.abs, lambda u: np.clip(u, -0.3, 0.7),
        lambda u: np.sin(u), lambda u: 0.5 * u - 0.5 * np.maximum(u - 1, 0)]
Gs = [lambda s: np.exp(2 * s), lambda s: np.maximum(s, 0) ** 2, lambda s: s, lambda s: np.log1p(np.exp(3 * s))]
worst = -np.inf
for trial in range(3000):
    T = rng.standard_normal((rng.integers(1, 8), n)) * rng.uniform(0.1, 3)
    ps = [psis[rng.integers(len(psis))] for _ in range(n)]
    PT = np.stack([ps[i](T[:, i]) for i in range(n)], 1)
    G = Gs[rng.integers(len(Gs))]
    lhs = np.mean(G((signs @ PT.T).max(1)))
    rhs = np.mean(G((signs @ T.T).max(1)))
    worst = max(worst, lhs - rhs)
print(f"max over 3000 random instances of LHS - RHS = {worst:.3e}  (Lemma B2.0 says <= 0)")
# counterexample without psi(0) = 0
T = np.zeros((1, 1)); s1 = np.array([[-1.0], [1.0]])
print("psi(u)=u+5, T={0}, G=exp:  LHS =", np.mean(np.exp(s1 @ (T + 5).T)), " RHS =", np.mean(np.exp(s1 @ T.T)))
