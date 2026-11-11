"""Sanity checks for squared loss on [-1,1].

1. Exp-concavity: p -> exp(-eta (p-y)^2) is concave on [-1,1] for every y in [-1,1]
   iff eta <= 1/8.  (Symbolic second derivative + grid check.)
2. Mixability (Vovk): for every finite mixture of predictions p_j in [-1,1] with
   weights w_j there is a single p in [-1,1] with
       (p-y)^2 <= -(1/eta) log sum_j w_j exp(-eta (p_j-y)^2)   for all y in [-1,1].
   Literature value for outcomes in [-Y,Y]: eta <= 1/(2Y^2), i.e. 1/2 here.
   We test random mixtures numerically at eta = 0.5 (expect no violation) and at
   eta = 0.6 (expect violations).  Numerical evidence only, not a proof.
"""
import numpy as np
import sympy as sp

# ---------- 1. exp-concavity ----------
p, y, eta = sp.symbols('p y eta', real=True)
phi = sp.exp(-eta * (p - y) ** 2)
d2 = sp.simplify(sp.diff(phi, p, 2) / phi)
print("phi''/phi =", sp.factor(d2))  # expect 2*eta*(2*eta*(p-y)**2 - 1)

def concave_everywhere(e, m=401):
    grid = np.linspace(-1, 1, m)
    P, Y = np.meshgrid(grid, grid)
    val = 2 * e * (2 * e * (P - Y) ** 2 - 1)
    return val.max() <= 1e-12

for e in [0.1, 0.125, 0.126, 0.2]:
    print(f"eta={e:.3f}: exp-concave on [-1,1]^2 grid: {concave_everywhere(e)}")

# ---------- 2. mixability ----------
rng = np.random.default_rng(0)
ys = np.linspace(-1, 1, 801)

def mix_gap(ps, ws, e):
    # r(y)^2 = -(1/e) log sum w exp(-e (p_j - y)^2) >= 0
    g = -np.log((ws[None, :] * np.exp(-e * (ps[None, :] - ys[:, None]) ** 2)).sum(1)) / e
    r = np.sqrt(np.maximum(g, 0.0))
    lo = max(np.max(ys - r), -1.0)
    hi = min(np.min(ys + r), 1.0)
    return hi - lo  # feasible iff >= 0

for e in [0.5, 0.6]:
    worst = np.inf
    for _ in range(20000):
        k = rng.integers(2, 6)
        ps = rng.uniform(-1, 1, size=k)
        if rng.random() < 0.5:  # bias toward extreme two-point mixtures
            ps[:2] = [-1.0, 1.0]
        ws = rng.dirichlet(np.ones(k))
        worst = min(worst, mix_gap(ps, ws, e))
    print(f"eta={e}: min feasibility gap over random mixtures = {worst:.3e} "
          f"({'no violation found' if worst >= -1e-9 else 'VIOLATION found'})")
