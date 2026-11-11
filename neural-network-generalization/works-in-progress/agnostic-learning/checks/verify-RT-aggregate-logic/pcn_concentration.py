"""Toy check of the concentration step of Remark 6.2.
Prior mu_sigma: Gaussian with density prop. to exp(-kappa_N(w)/(2 sigma^2)) at width N, depth L=2.
Posterior: mu_sigma conditioned on the open set O = {w : Lhat(z_w) < tau}.
Sampler: preconditioned Crank-Nicolson (pCN) in standardized coordinates, which leaves
mu_sigma invariant; restricting to O means accept iff the proposal lies in O.
We check that as sigma -> 0 the energy concentrates at (or below) b_tau = inf_O kappa_N
<= kappa_N(clone) <= E_*."""
import numpy as np
from scipy.optimize import minimize
rng = np.random.default_rng(1)

d, N, n = 1, 4, 10
# competitor g: depth 2, width m=2, weights in [-B,B], B=1
B, m = 1.0, 2
T1 = np.array([[0.5, 1.0], [-0.3, -0.8]]); u = np.array([0.9, -0.7])
Estar = d * (d + 1) * B**2 + 2 * (2 - 1) * m**2 * B**2
X = rng.uniform(-1, 1, n)
Xb = np.stack([np.ones(n), X], 1)
gX = np.tanh(Xb @ T1.T) @ u
y = np.clip(gX + 0.35 * rng.standard_normal(n), -1, 1)
Lg = np.mean((gX - y) ** 2)

P = N * (d + 1) + N
lam = np.concatenate([np.full(N * (d + 1), np.sqrt(d / N)), np.full(N, np.sqrt(N))])  # kappa = |lam*w|^2
def unpack(w):
    return w[:N * (d + 1)].reshape(N, d + 1), w[N * (d + 1):]
def z(w):
    W1, v = unpack(w); return np.tanh(Xb @ W1.T) @ v
def Lhat(w): return np.mean((z(w) - y) ** 2)
def kap(w): return np.sum((lam * w) ** 2)

# clone of g at width N=4 (two groups of two)
grp = np.array([0, 0, 1, 1]); sizes = np.array([2, 2])
wc = np.concatenate([T1[grp].ravel(), u[grp] / sizes[grp]])
assert abs(Lhat(wc) - Lg) < 1e-12
print(f"Lhat(g)={Lg:.4f}  kappa(clone)={kap(wc):.4f}  E_*={Estar:.1f}")

def b_tau(tau, restarts=60):
    best = np.inf; bw = None
    cons = {'type': 'ineq', 'fun': lambda w: tau - 1e-9 - Lhat(w)}
    for r in range(restarts):
        w0 = wc + 0.5 * rng.standard_normal(P) if r % 2 else rng.standard_normal(P)
        res = minimize(kap, w0, constraints=[cons], method='SLSQP', options={'maxiter': 500})
        if res.success and Lhat(res.x) < tau and res.fun < best:
            best, bw = res.fun, res.x
    return best, bw

def pcn(tau, sigma, w_start, iters=200000, beta=0.15):
    xi = lam * w_start / sigma
    ks = []
    acc = 0
    for t in range(iters):
        prop = np.sqrt(1 - beta**2) * xi + beta * rng.standard_normal(P)
        wp = sigma * prop / lam
        if Lhat(wp) < tau:
            xi = prop; acc += 1
        if t > iters // 4 and t % 20 == 0:
            ks.append(np.sum(xi**2) * sigma**2)
    return np.array(ks), acc / iters

for margin in [0.05, 0.005]:
    tau = Lg + margin
    b, bw = b_tau(tau)
    print(f"\nmargin tau-Lhat(g)={margin}: tau={tau:.4f}, b_tau (SLSQP upper est.)={b:.4f}")
    for sigma in [0.5, 0.35, 0.25, 0.18, 0.13]:
        ks, a = pcn(tau, sigma, wc)
        q = np.quantile(ks, [0.5, 0.9, 0.99])
        print(f"  sigma={sigma:5.2f} acc={a:.2f}  kappa quantiles 50/90/99% = {q[0]:.3f} {q[1]:.3f} {q[2]:.3f}"
              f"   frac(kappa>E_*+1)={np.mean(ks > Estar + 1):.4f}")
