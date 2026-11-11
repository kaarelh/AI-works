"""Sanity check for issue 1 of the report: (P_2^{o(1)}[phi]) in RT-depth2.fixed.md section 1.4 quantifies over
"every learner width N >= 1", while the competitor class has width up to n^alpha.  At N = 1 a depth-two network
z(x) = v tanh(w0 + w1 x) is monotone in x (d = 1), so it cannot fit the width-2 bump
     g*(x) = (tanh(1 + 2x) + tanh(1 - 2x)) / 2,   x uniform on {-1, 0, 1},  y = g*(x) (|g*| <= 1, weights in [-2, 2]).
Isotonic regression gives  inf_{monotone f} E (f - g*)^2 = Delta^2 / 6  with Delta = g*(0) - g*(1).
Here we (i) evaluate Delta^2/6 and (ii) minimise E(z - g*)^2 over width-1 networks numerically (many restarts),
also after clipping, to confirm the infimum is bounded away from 0 while inf over the class G_n^(alpha) is 0.
"""
import numpy as np
from scipy.optimize import minimize

xs = np.array([-1.0, 0.0, 1.0])
gstar = 0.5 * (np.tanh(1 + 2 * xs) + np.tanh(1 - 2 * xs))
Delta = gstar[1] - gstar[0]
print("g* values:", np.round(gstar, 5), " Delta = %.5f, Delta^2/6 = %.5f" % (Delta, Delta ** 2 / 6))


def loss(p, clip=False):
    v, w0, w1 = p
    z = v * np.tanh(w0 + w1 * xs)
    if clip:
        z = np.clip(z, -1, 1)
    return np.mean((z - gstar) ** 2)


rng = np.random.default_rng(0)
best = np.inf; bestc = np.inf
for _ in range(3000):
    p0 = rng.normal(scale=rng.choice([0.5, 3, 20]), size=3)
    r = minimize(loss, p0, method='Nelder-Mead', options=dict(xatol=1e-10, fatol=1e-14, maxiter=20000))
    best = min(best, r.fun)
    rc = minimize(lambda p: loss(p, True), p0, method='Nelder-Mead', options=dict(xatol=1e-10, fatol=1e-14, maxiter=20000))
    bestc = min(bestc, rc.fun)
print("min over width-1 networks found: %.5f (unclipped), %.5f (clipped); isotonic bound %.5f" % (
    best, bestc, Delta ** 2 / 6))
