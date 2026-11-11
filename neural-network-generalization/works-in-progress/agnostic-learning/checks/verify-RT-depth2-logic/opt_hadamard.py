"""Depth-two numerical sanity check of Proposition 5.3 and of its dependence on the input scaling.

Hadamard atoms a_1..a_M in {-1,1}^M (d = M), uniform x, fair-sign labels, n = M.
F_c(w) = (d/N)||W1||_F^2 + N||v||^2 + (1/c) sum_x k_x (z(x)-ybar_x)^2 + W/c   (W constant)
Convention 'cube': inputs a_j (norm sqrt d)  -- the brief's X in [-1,1]^d.
Convention 'ball': inputs a_j/sqrt(d) (norm 1) -- paper.tex's main unit-ball model.
L-BFGS from the explicit memorizer, from small random inits, and from zero; report min F found,
the seen-atom residual R, and the test excess M^{-1} sum_j z(a_j)^2 of the best network found.
Prop. 5.3 (cube convention) predicts every near-minimizer has R <= c(2 sqrt Q + 1) + n/(9Q).
"""
import numpy as np
from scipy.linalg import hadamard
from scipy.optimize import minimize

rng = np.random.default_rng(3)

def run(M, N, c, conv, seeds=4):
    A = hadamard(M).astype(float); d = M
    X = A if conv == 'cube' else A/np.sqrt(d)
    Xbar = np.hstack([np.ones((M, 1)), X])
    n = M
    idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0; ybar = np.zeros(M); ybar[T] = S[T]/k[T]
    Q = float(np.sum(ybar[T]**2)); G = float(np.sum(k*ybar**2)); W = float(np.sum((y-ybar[idx])**2))
    P1 = N*(d+1)

    def unpack(p):
        return p[:P1].reshape(N, d+1), p[P1:]

    def F(p):
        W1, v = unpack(p)
        H = np.tanh(Xbar @ W1.T)            # M x N
        z = H @ v
        r = z - ybar
        val = (d/N)*np.sum(W1**2) + N*np.sum(v**2) + np.sum(k*r**2)/c
        gz = 2*k*r/c                         # dF/dz per atom
        gv = H.T @ gz + 2*N*v
        gH = np.outer(gz, v)*(1-H**2)        # M x N
        gW1 = gH.T @ Xbar + 2*(d/N)*W1
        return val, np.concatenate([gW1.ravel(), gv])

    # explicit memorizer (cube convention formula; in the ball convention rescale u by sqrt d)
    u = (ybar[T] @ A[T])/M
    scale = 1.0 if conv == 'cube' else np.sqrt(d)
    eps = Q**-0.25 if conv == 'cube' else (d*Q)**-0.25
    W1m = np.zeros((N, d+1)); W1m[:, 1:] = eps*scale*u
    vm = np.full(N, 1.0/(N*eps))
    pm = np.concatenate([W1m.ravel(), vm])
    Fm, _ = F(pm)
    starts = [pm, np.zeros(P1+N)] + [rng.normal(size=P1+N)*0.05 for _ in range(seeds)]
    best = None
    for p0 in starts:
        res = minimize(F, p0, jac=True, method='L-BFGS-B', options={'maxiter': 20000, 'maxfun': 40000, 'gtol': 1e-10})
        if best is None or res.fun < best.fun:
            best = res
    W1, v = unpack(best.x)
    z = np.tanh(Xbar @ W1.T) @ v
    R = float(np.sum(k*(z-ybar)**2)); kap = (d/N)*np.sum(W1**2) + N*np.sum(v**2)
    excess = float(np.mean(z**2))
    Rbound = c*(2*np.sqrt(Q)+1) + n/(9*Q)
    print(f"{conv:4s} M=d={M:4d} N={N:3d} c={c:4.1f}: Q={Q:6.1f} G={G:6.1f} | F(mem)-W/c={Fm:8.2f} "
          f"min F found-W/c={best.fun:8.2f} | best: kappa={kap:7.2f} R={R:7.2f} (R/G={R/G:.3f}) "
          f"test excess={excess:.3f}  [Prop5.3 R-bound {Rbound:.1f}]")

for M in [64, 256]:
    for conv in ['cube', 'ball']:
        for c in [1.0, 4.0]:
            run(M, 8, c, conv)
