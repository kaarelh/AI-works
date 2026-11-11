"""Tolerance bias of the strong-prior TUBE learner with continuous inputs (not an atom artefact).

d = 1, x uniform on [-1,1]; teacher g == -0.8 (width 1); y = -0.8 + 0.3*Bernoulli(p), rho0 = 0.3.
Learner tolerance rho in {0.35, 0.6 (= 2 rho0)}.  sigma -> 0 limit = minimum-energy feasible networks
(local optimization with restarts; depth 2 and 3, width 6).  Test MSE computed exactly from the
label law on a fine x-grid: E(z(x)-y)^2 = (z(x) - eta)^2 + Var(y), eta = -0.8 + 0.3 p.
"""
import numpy as np
from scipy.optimize import minimize

rng = np.random.default_rng(11)


def unpack(theta, N, L, d=1):
    i = 0
    Ws = [theta[i:i + N * (d + 1)].reshape(N, d + 1)]; i += N * (d + 1)
    for _ in range(L - 2):
        Ws.append(theta[i:i + N * N].reshape(N, N)); i += N * N
    return Ws, theta[i:i + N]


def out(theta, X, N, L):
    Ws, v = unpack(theta, N, L)
    h = np.hstack([np.ones((len(X), 1)), X[:, None]])
    for W in Ws:
        h = np.tanh(h @ W.T)
    return h @ v


def energy(theta, N, L, d=1):
    Ws, v = unpack(theta, N, L)
    return d / N * np.sum(Ws[0] ** 2) + sum(np.sum(W ** 2) for W in Ws[1:]) + N * np.sum(v ** 2)


def min_energy(X, y, rho, N, L, restarts=20):
    P = N * 2 + (L - 2) * N * N + N
    cons = [{'type': 'ineq', 'fun': lambda t: rho - (out(t, X, N, L) - y)},
            {'type': 'ineq', 'fun': lambda t: rho + (out(t, X, N, L) - y)}]
    best = None
    for _ in range(restarts):
        res = minimize(energy, rng.normal(0, 1, P), args=(N, L), constraints=cons, method='SLSQP',
                       options={'maxiter': 3000, 'ftol': 1e-12})
        if res.success and np.max(np.abs(out(res.x, X, N, L) - y)) <= rho + 1e-6:
            if best is None or res.fun < best.fun:
                best = res
    return best


p, n, N = 0.05, 60, 6
xg = np.linspace(-1, 1, 2001)
eta, var = -0.8 + 0.3 * p, 0.09 * p * (1 - p)
print(f"p={p}, n={n}: Bayes risk = {var:.5f}, L_D(g) = {0.09*p:.5f}")
for L in [2, 3]:
    for rho in [0.35, 0.6]:
        for rep in range(2):
            X = rng.uniform(-1, 1, n)
            y = -0.8 + 0.3 * (rng.uniform(0, 1, n) < p)
            res = min_energy(X, y, rho, N, L)
            zg = out(res.x, xg, N, L)
            mse = np.mean((np.clip(zg, -1, 1) - eta) ** 2) + var
            print(f"  L={L} rho={rho} rep={rep}: #(y=-0.5) = {int(np.sum(y > -0.7))}, min energy {res.fun:.4f},"
                  f" z range [{zg.min():+.3f},{zg.max():+.3f}] (limit -0.8+rho = {-0.8+rho:+.2f}),"
                  f" test MSE {mse:.4f}; atom-limit formula (rho-0.3p)^2+Var = {(rho-0.3*p)**2+var:.4f};"
                  f" rho^2 = {rho**2:.4f}; Prop 4.1 bound inf = {(rho+0.6)**2:.4f}")
