"""Numerical test of the quantitative strong-prior bound (3.2) of A.md Lemma 3.2 on a 2-parameter toy objective
F(w) = w^T Gamma w + (1/c) sum_i (v tanh(u x_i) - y_i)^2  >=  kappa(w) = w^T Gamma w,  P = 2.

LHS = int_{F > F*+t} (1+F)^p dPi_sigma  (grid quadrature, exponent shifted by F* to avoid underflow)
RHS = (1+F*+t)^p / (V_delta sqrt(det Gamma)) * (8 pi sigma^2 (F*+t)/t)^{P/2} * exp(-t/(4 sigma^2)),
with delta the (numerically certified, then shrunk by 2%) largest radius such that F <= F*+t/4 on B(w*,delta).
"""
import math
import numpy as np
from scipy import optimize

g1, g2 = 0.5, 2.0
xs = np.array([1.0, -0.5, 0.3, 0.9]); ys = np.array([0.8, -0.6, 0.1, 0.7]); c = 0.2

def F(u, v):
    z = v[..., None] * np.tanh(u[..., None] * xs)
    return g1 * u ** 2 + g2 * v ** 2 + np.sum((z - ys) ** 2, axis=-1) / c

best = None
rng = np.random.default_rng(0)
for _ in range(200):
    w0 = rng.normal(0, 2, size=2)
    r = optimize.minimize(lambda w: float(F(np.array(w[0]), np.array(w[1]))), w0, method="Nelder-Mead",
                          options={"xatol": 1e-12, "fatol": 1e-14, "maxiter": 20000})
    if best is None or r.fun < best.fun:
        best = r
ws = best.x; Fs = best.fun
print(f"minimizer w*=({ws[0]:.5f},{ws[1]:.5f}), F*={Fs:.6f}  (F(0)={float(F(np.array(0.0),np.array(0.0))):.4f})")

# grid
h = 0.002
U, V = np.meshgrid(np.arange(-6, 6, h), np.arange(-4, 4, h), indexing="ij")
FF = F(U, V)
print("grid min F =", float(FF.min()), " (should be ~F*)")

def delta_for(t):
    # largest delta with max_{B(w*,delta)} F <= F* + t/4, checked on a fine polar grid, then shrunk 2%
    th = np.linspace(0, 2 * np.pi, 2001)
    lo, hi = 0.0, 3.0
    for _ in range(60):
        mid = (lo + hi) / 2
        rr = np.linspace(0, mid, 400)
        RR, TT = np.meshgrid(rr, th, indexing="ij")
        vals = F(ws[0] + RR * np.cos(TT), ws[1] + RR * np.sin(TT))
        if vals.max() <= Fs + t / 4: lo = mid
        else: hi = mid
    return 0.98 * lo

worst = 0.0
for t in [0.5, 1.0, 2.0, 4.0]:
    dl = delta_for(t); Vd = math.pi * dl ** 2
    for p in [0.0, 0.5, 1.0, 2.0]:
        for s2 in [0.4, 0.2, 0.1, 0.05, 0.03, 0.02]:
            if p > 0 and s2 > 3 / (8 * p):
                continue
            wgt = np.exp(-(FF - Fs) / (2 * s2))
            Z = wgt.sum()
            mask = FF > Fs + t
            lhs = float(((1 + FF[mask]) ** p * wgt[mask]).sum() / Z)
            rhs = (1 + Fs + t) ** p / (Vd * math.sqrt(g1 * g2)) * (8 * math.pi * s2 * (Fs + t) / t) ** (2 / 2) * math.exp(-t / (4 * s2))
            # LHS uses the unshifted normalisation implicitly: both numerator and Z carry exp(F*/(2s2)), which cancels.
            ratio = lhs / rhs
            worst = max(worst, ratio)
            print(f"t={t:3.1f} delta={dl:.4f} p={p:3.1f} sigma^2={s2:5.3f}: LHS={lhs:.3e}  RHS={rhs:.3e}  LHS/RHS={ratio:.3e}")
print("max LHS/RHS =", worst, "(must be <= 1)")
