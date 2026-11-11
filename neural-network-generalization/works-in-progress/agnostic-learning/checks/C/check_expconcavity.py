"""Claim C, Lemma C.2.1 (exp-concavity of squared loss on [-1,1]) and the Jensen step after it (Section C.8 item 1).

1. Symbolic second derivative of phi_y(p) = exp(-eta (p-y)^2).
2. Grid check of concavity on [-1,1]^2 for several eta.
3. The Jensen step used in the proof: for a probability vector w and predictions p_j in [-1,1],
   sum_j w_j exp(-eta (p_j-y)^2) <= exp(-eta (sum_j w_j p_j - y)^2).
"""
import numpy as np
import sympy as sp

p, y, eta = sp.symbols('p y eta', real=True)
phi = sp.exp(-eta * (p - y) ** 2)
ratio = sp.simplify(sp.diff(phi, p, 2) / phi)
print("phi''/phi =", sp.factor(ratio))
# at p=-1, y=1 (|p-y|=2): sign of 2 eta (8 eta - 1)
print("phi''/phi at p=-1,y=1:", sp.factor(ratio.subs({p: -1, y: 1})))

grid = np.linspace(-1, 1, 801)
P, Y = np.meshgrid(grid, grid)
for e in [0.05, 0.1, 0.125, 0.12501, 0.13, 0.2, 0.5]:
    second = 2 * e * (2 * e * (P - Y) ** 2 - 1)
    print(f"eta={e:.5f}: max of phi''/phi on grid = {second.max():+.3e}  concave on [-1,1]^2: {second.max() <= 1e-15}")

rng = np.random.default_rng(0)
def jensen_gap(e, trials=200000, k=5):
    w = rng.dirichlet(np.ones(k), size=trials)
    pj = rng.uniform(-1, 1, size=(trials, k))
    # put extra mass on extreme configurations
    pj[: trials // 2] = np.sign(pj[: trials // 2])
    yy = rng.choice([-1.0, 1.0, 0.0], size=trials) * rng.uniform(0.5, 1, size=trials)
    yy[: trials // 4] = np.sign(yy[: trials // 4] + 1e-12)
    lhs = (w * np.exp(-e * (pj - yy[:, None]) ** 2)).sum(1)
    rhs = np.exp(-e * ((w * pj).sum(1) - yy) ** 2)
    return (rhs - lhs).min()
for e in [0.125, 0.2, 0.3]:
    print(f"eta={e}: min over random mixtures of [exp(-eta(mean-y)^2) - mean exp(-eta(p-y)^2)] = {jensen_gap(e):+.3e}")
