"""Lemma 3.1 in a toy case: width N = 1, depth 2, d = 1, parameters (w0, w1, v), z = v tanh(w0 + w1 x),
kappa = (d/N)(w0^2+w1^2) + N v^2.  Posterior density proportional to exp(-F/(2 sigma^2)) with
F = kappa + (1/c) sum_i (z(x_i) - y_i)^2.  Integrate on a 3-D grid; report Pi(F > min F + zeta), E_Pi[(1+F) 1{F > min F + zeta}],
and E_Pi F - min F as sigma decreases.  Lemma 3.1 predicts all three -> 0 (the first two like poly(sigma) e^{-zeta/(4 sigma^2)}
or faster)."""
import numpy as np
rng = np.random.default_rng(3)
n, c, zeta = 20, 4.0, 0.2
x = rng.uniform(-1, 1, n); y = np.clip(np.tanh(2 * x) + 0.3 * rng.normal(size=n), -1, 1)
g = np.linspace(-4, 4, 161)
W0, W1, V = np.meshgrid(g, g, g, indexing="ij")
F = W0 ** 2 + W1 ** 2 + V ** 2
for i in range(n):
    F = F + (V * np.tanh(W0 + W1 * x[i]) - y[i]) ** 2 / c
mF = F.min()
print(f"grid min F = {mF:.4f} (F(0) = {np.sum(y**2)/c:.4f}); zeta = {zeta}")
print(" sigma    Pi(F > minF+zeta)   E[(1+F)1{F>minF+zeta}]   E_Pi F - min F")
for s in [1.0, 0.5, 0.3, 0.2, 0.15, 0.1, 0.07]:
    logw = -(F - mF) / (2 * s * s)
    wts = np.exp(logw); wts /= wts.sum()
    out = F > mF + zeta
    print(f" {s:5.2f}      {wts[out].sum():.3e}            {np.sum(wts[out] * (1 + F[out])):.3e}            {np.sum(wts * F) - mF:.3e}")
