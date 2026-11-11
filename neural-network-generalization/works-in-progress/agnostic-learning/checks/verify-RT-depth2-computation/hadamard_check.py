"""Check of redteam.md Proposition 5.3 (Hadamard atoms, d = M, depth two).

1. Sylvester-Hadamard rows a_j in {-1,1}^M with a_j . a_k = M delta_jk.
2. u = M^{-1} sum_{j in T} ybar_j a_j:  u . a_k = ybar_k 1_T(k),  ||u||^2 = Q/M.
3. Width-N network: rows (0, eps u), readout 1/(N eps):  z = eps^{-1} tanh(eps u.x),
   kappa_N = (d/N)||W1||_F^2 + N||v||^2 = eps^2 Q + eps^{-2}  (= 2 sqrt Q at eps^2 = Q^{-1/2}),
   |z(a_k) - ybar_k| <= eps^2/3,  R <= n eps^4/9 = n/(9Q).
4. Near-minimizer residual budget R <= c(2 sqrt Q + 1) + n/(9Q) and the resulting excess lower bound
   (sqrt Q - sqrt R)_+^2 / M vs beta(lambda), for several c(M); finite-M size of the o(1).
5. L-BFGS on F_c at M = d = 64, 128: consistency (any w with F(w) <= F(w_lin)+1 obeys the bound).
"""
import math
import numpy as np
from scipy.optimize import minimize
from scipy.linalg import hadamard

rng = np.random.default_rng(99)
BETA1 = 0.4848291069956878

def sample(M, lam, rng):
    n = int(math.ceil(lam * M))
    idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=ys, minlength=M)
    seen = k > 0; ybar = np.zeros(M); ybar[seen] = S[seen] / k[seen]
    W = float(np.sum((ys - ybar[idx]) ** 2))
    return n, idx, ys, k, ybar, seen, W

print("== exact construction checks ==")
for M in [16, 64, 256, 1024, 4096]:
    A = hadamard(M).astype(float)        # Sylvester construction, rows a_j
    d = M
    assert np.array_equal(A @ A.T, M * np.eye(M))
    n, idx, ys, k, ybar, seen, W = sample(M, 1.0, rng)
    Q = float(np.sum(ybar ** 2)); G = float(np.sum(k * ybar ** 2))
    u = (A[seen].T @ ybar[seen]) / M
    assert np.allclose(A @ u, ybar * seen, atol=1e-12)
    assert abs(u @ u - Q / M) < 1e-12
    eps = Q ** -0.25
    for N in [1, 2, 7]:
        W1 = np.tile(np.concatenate([[0.0], eps * u]), (N, 1))
        v = np.full(N, 1.0 / (N * eps))
        Xb = np.hstack([np.ones((M, 1)), A])
        z = np.tanh(Xb @ W1.T) @ v
        kap = (d / N) * np.sum(W1 ** 2) + N * np.sum(v ** 2)
        R = float(np.sum(k * (z - ybar) ** 2))
        err = float(np.max(np.abs(z - ybar)[seen]))
        unseen_max = float(np.max(np.abs(z[~seen]))) if (~seen).any() else 0.0
        assert abs(kap - (eps ** 2 * Q + eps ** -2)) < 1e-9 * kap and abs(kap - 2 * math.sqrt(Q)) < 1e-9 * kap
        assert err <= eps ** 2 / 3 + 1e-15 and R <= n / (9 * Q) + 1e-12
    print("M=d=%5d n=%5d Q=%.1f (Q/M=%.4f) kappa=%.4f=2sqrtQ  max|z-ybar|_T=%.3e <= eps^2/3=%.3e  R=%.3e <= n/(9Q)=%.3e  max|z| unseen=%.1e" % (
        M, n, Q, Q / M, kap, err, eps ** 2 / 3, R, n / (9 * Q), unseen_max))

print("\n== near-minimizer excess lower bound (sqrt Q - sqrt R)^2/M, R = c(2 sqrt Q+1)+n/(9Q), lambda=1, Q = M beta ==")
print("     M        c=1        c=M^0.25   c=M^0.4    c=M^0.5/10  c=M^0.5   (beta(1)=%.4f)" % BETA1)
for e in [6, 10, 14, 20, 30, 40, 60]:
    M = 2.0 ** e; n = M; Q = BETA1 * M
    row = []
    for c in [1.0, M ** 0.25, M ** 0.4, M ** 0.5 / 10, M ** 0.5]:
        R = c * (2 * math.sqrt(Q) + 1) + n / (9 * Q)
        row.append(max(math.sqrt(Q) - math.sqrt(R), 0) ** 2 / M)
    print("  2^%-3d  " % e + "  ".join("%.4f    " % x for x in row))

print("\n== L-BFGS on F_c at depth two, Hadamard atoms (consistency check) ==")
def run_opt(M, N, c, seed, restarts=2, maxit=4000):
    rng = np.random.default_rng(seed)
    A = hadamard(M).astype(float); d = M
    n, idx, ys, k, ybar, seen, W = sample(M, 1.0, rng)
    Q = float(np.sum(ybar ** 2)); G = float(np.sum(k * ybar ** 2))
    Xb = np.hstack([np.ones((M, 1)), A])
    def fg(p):
        W1 = p[:N * (d + 1)].reshape(N, d + 1); v = p[N * (d + 1):]
        h = np.tanh(Xb @ W1.T); z = h @ v; r = z - ybar
        kap = (d / N) * np.sum(W1 ** 2) + N * np.sum(v ** 2)
        F = kap + np.sum(k * r ** 2) / c
        dz = 2 * k * r / c
        gv = h.T @ dz + 2 * N * v
        gW1 = ((np.outer(dz, v)) * (1 - h ** 2)).T @ Xb + 2 * (d / N) * W1
        return F, np.concatenate([gW1.ravel(), gv])
    best = None
    for rs in range(restarts):
        p0 = np.concatenate([rng.normal(0, 1 / math.sqrt(d + 1), size=N * (d + 1)), rng.normal(0, 1 / N, size=N)])
        res = minimize(fg, p0, jac=True, method='L-BFGS-B', options={'maxiter': maxit, 'maxfun': 2 * maxit})
        if best is None or res.fun < best.fun: best = res
    p = best.x; W1 = p[:N * (d + 1)].reshape(N, d + 1); v = p[N * (d + 1):]
    z = np.tanh(Xb @ W1.T) @ v; R = float(np.sum(k * (z - ybar) ** 2))
    F_lin = 2 * math.sqrt(Q) + (n / (9 * Q) + 0) / c   # upper bound on F_c(w_lin) - W/c
    Rbudget = c * (2 * math.sqrt(Q) + 1) + n / (9 * Q)
    ex = float(np.mean(z ** 2)); lb = max(math.sqrt(Q) - math.sqrt(Rbudget), 0) ** 2 / M
    return dict(M=M, N=N, c=c, Q=Q, G=G, F=best.fun, F_lin_ub=F_lin, R=R, Rbudget=Rbudget, excess=ex, lb=lb, kappa=best.fun - R / c)

for (M, N, c) in [(64, 8, 1.0), (64, 64, 1.0), (128, 16, 1.0), (128, 16, 4.0), (128, 16, 16.0)]:
    out = run_opt(M, N, c, seed=M + N)
    inN1 = out['F'] <= out['F_lin_ub'] + 1
    print("M=d=%d N=%d c=%g: found F-W/c=%.2f (F(w_lin)-W/c <= %.2f, zero net %.2f) kappa=%.2f R=%.2f | budget %.2f | "
          "excess(found)=%.4f, proven LB=%.4f | found within 1 of w_lin: %s, consistent: %s" % (
              out['M'], out['N'], out['c'], out['F'], out['F_lin_ub'], out['G'] / out['c'], out['kappa'], out['R'], out['Rbudget'],
              out['excess'], out['lb'], inN1, (not inN1) or (out['R'] <= out['Rbudget'] + 1e-6 and out['excess'] >= out['lb'] - 1e-9)))
