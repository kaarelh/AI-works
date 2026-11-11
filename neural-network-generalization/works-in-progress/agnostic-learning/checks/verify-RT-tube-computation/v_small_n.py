"""Does hard conditioning within the residual budget 'never memorize'?

Strong-prior TUBE limit = minimum-energy networks in the (closed) feasible set
{ |z(x_i) - y_i| <= rho for all i }  (red-team / paper Cor. exact: the sigma->0 limit concentrates on
energy b_rho = inf over the open set, which equals the min over the closure).

Setting: d = 1, teacher g == 0.6 (width 1, depth L), labels y = 0.6 + 0.3*eps, eps a fair sign,
so rho0 = 0.3; tolerance rho = 0.35 > rho0 (inside Prop 4.1's hypotheses).
Feasible windows: eps = -1 -> z in [-0.05, 0.65] (contains 0); eps = +1 -> z in [0.55, 1.25].

Part 1 (n = 2): inputs -1 and +1.  Compare the min-energy fits for the samples
(eps_1, eps_2) = (-,+) and (+,+).  If the prediction at x = -1 changes with the training noise at
x = -1, the posterior tracks (fits) that noise.
Part 2 (n grid points, iid signs): fraction of the noise tracked by the min-energy fit as n grows.
Local optimization (SLSQP, restarts) gives an upper bound on the min energy; the reported fits are
the best found.
"""
import numpy as np
from scipy.optimize import minimize

rng = np.random.default_rng(3)


def unpack(theta, N, L, d=1):
    i = 0
    W1 = theta[i:i + N * (d + 1)].reshape(N, d + 1); i += N * (d + 1)
    Ws = [W1]
    for _ in range(L - 2):
        Ws.append(theta[i:i + N * N].reshape(N, N)); i += N * N
    v = theta[i:i + N]
    return Ws, v


def out(theta, X, N, L):
    Ws, v = unpack(theta, N, L)
    h = np.hstack([np.ones((len(X), 1)), X[:, None]])
    for W in Ws:
        h = np.tanh(h @ W.T)
    return h @ v


def energy(theta, N, L, d=1):
    Ws, v = unpack(theta, N, L)
    return d / N * np.sum(Ws[0] ** 2) + sum(np.sum(W ** 2) for W in Ws[1:]) + N * np.sum(v ** 2)


def min_energy(X, y, rho, N, L, restarts=40):
    P = N * 2 + (L - 2) * N * N + N
    cons = [{'type': 'ineq', 'fun': lambda t: rho - (out(t, X, N, L) - y)},
            {'type': 'ineq', 'fun': lambda t: rho + (out(t, X, N, L) - y)}]
    best = None
    for r in range(restarts):
        t0 = rng.normal(0, 1.0, P)
        res = minimize(energy, t0, args=(N, L), constraints=cons, method='SLSQP',
                       options={'maxiter': 2000, 'ftol': 1e-12})
        if not res.success:
            continue
        viol = np.max(np.abs(out(res.x, X, N, L) - y)) - rho
        if viol > 1e-6:
            continue
        if best is None or res.fun < best.fun - 1e-10:
            best = res
    return best


rho, g = 0.35, 0.6
print("Part 1: n = 2, inputs x = -1, +1; test MSE at a point = (z - 0.6)^2 + 0.09")
for L in [2, 3]:
    for N in [1, 2, 4]:
        for eps in [(-1, 1), (1, 1)]:
            X = np.array([-1.0, 1.0]); y = g + 0.3 * np.array(eps, float)
            res = min_energy(X, y, rho, N, L)
            z = out(res.x, X, N, L)
            mse = (z - g) ** 2 + 0.09
            print(f"  L={L} N={N} noise signs {eps}: min energy {res.fun:.4f}; z(-1) = {z[0]:+.4f}, z(+1) = {z[1]:+.4f};"
                  f" test MSE at -1: {mse[0]:.4f}, at +1: {mse[1]:.4f}")

print("\nPart 2: n equally spaced inputs in [-1,1], iid noise signs; L = 2, N = 6.")
print("  'tracked' = mean z on (-)-noise points minus mean z on (+)-noise points (0 means no noise tracking;")
print("  a full tracker of the windows would show about -0.55).  Also test MSE averaged over the training inputs")
print("  with fresh labels, and the training-input average of (z - 0.6)^2.")
for n in [2, 4, 8, 16, 32]:
    tr, mses = [], []
    for rep in range(3):
        X = np.linspace(-1, 1, n)
        eps = rng.choice([-1.0, 1.0], n)
        if np.all(eps == eps[0]):
            eps[0] = -eps[0]
        y = g + 0.3 * eps
        res = min_energy(X, y, rho, 6, 2, restarts=25)
        z = out(res.x, X, 6, 2)
        tr.append(z[eps < 0].mean() - z[eps > 0].mean())
        mses.append(np.mean((z - g) ** 2) + 0.09)
    print(f"  n={n:>3}: tracked = {np.round(tr, 3)}, test MSE at training inputs = {np.round(mses, 4)}")
