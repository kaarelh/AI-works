"""Sanity check of Lemma 5.2 (width-free Rademacher bound):
   Rad_S(Z_K) <= (K/H)^{H/2} * D_n / sqrt(n),   D_n = sqrt(2(d+1) ln(n+1)) + (H-1)/2.
We compute LOWER estimates of E_eps sup_{kappa_N(w) <= K} (1/n) sum eps_i z_w(x_i) by L-BFGS over
networks of width N (scaled onto the energy sphere kappa = K), and compare with the bound and with
the trivial bound sqrt(K).  A lower estimate above the bound would refute the lemma.
"""
import numpy as np
from scipy.optimize import minimize
from nn_utils import *

rng = np.random.default_rng(5)

def sup_estimate(X, eps, K, H, N, restarts, rng):
    n, d = X.shape
    lam2 = lam2_vector(d, N, H)
    def obj(th):
        kap = np.sum(lam2 * th ** 2)
        s = np.sqrt(K / kap)
        Ws, v = unflatten(s * th, d, N, H)
        z, gWs, gv = grad_linear_functional(Ws, v, X, eps / n)
        J = eps @ z / n
        g = flatten(gWs, gv)                      # gradient at s*th
        # d/dth of J(s(th) th) = s g - (s/kap) (g.th) lam2 th
        gth = s * g - (s / kap) * (g @ th) * lam2 * th
        return -J, -gth
    best = -np.inf
    for _ in range(restarts):
        th0 = flatten(*random_net(rng, d, N, H, (2.0, 1.0 / np.sqrt(N), 1.0 / N)))
        res = minimize(obj, th0, jac=True, method="L-BFGS-B", options=dict(maxiter=3000))
        best = max(best, -res.fun)
    return best

print(" d  H    n    N    K   E sup (lower est.)   bound (K/H)^{H/2} D/sqrt(n)   sqrt(K)")
for (d, H, n, N) in [(1, 1, 60, 20), (2, 1, 60, 20), (1, 2, 400, 24), (2, 2, 400, 24), (1, 3, 400, 16)]:
    X = rng.uniform(-1, 1, size=(n, d))
    Dn = np.sqrt(2 * (d + 1) * np.log(n + 1)) + (H - 1) / 2
    for K in [1.0, 4.0, 16.0]:
        vals = [sup_estimate(X, rng.choice([-1.0, 1.0], size=n), K, H, N, 3, rng) for _ in range(6)]
        bound = (K / H) ** (H / 2) * Dn / np.sqrt(n)
        flag = "VIOLATION" if np.mean(vals) > bound else ""
        print(f"{d:2d} {H:2d} {n:4d} {N:4d} {K:4.0f}   {np.mean(vals):10.4f} +- {np.std(vals)/np.sqrt(len(vals)):.4f}"
              f"        {bound:10.4f}                {np.sqrt(K):6.3f}  {flag}")
