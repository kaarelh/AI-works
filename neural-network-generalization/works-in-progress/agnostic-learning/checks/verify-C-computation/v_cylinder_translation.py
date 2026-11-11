"""Checks of the coordinate-law facts used in Appendix C.A (Lemma C.3.1), for Gaussian and non-Gaussian nu.

 (1) Step 1: P(|Y| <= s) >= c_nu s for 0 < s <= 1, c_nu = (3/8) min(1, sqrt(m_nu)), where Y is a single coordinate or a
     normalized group sum k^{-1/2} (xi_1+...+xi_k)  (density by repeated numerical convolution).
 (2) eq. translation (1-D and 2-D product, symmetric sets): nu(E + a) >= nu(E) exp(-M_nu |a|^2 / 2).
 (3) eq. subgaussian with conditioning on a symmetric convex set: E[e^{theta Y} | |Y| <= c] <= e^{theta^2/(2 m_nu)},
     and for a 2-D linear form <u, Z> conditioned on a symmetric box.
nu: Gaussian, and the variance-standardized law ~ exp(-t^2/2 - b log cosh t) (paper.tex line 156) with b = 1, 5.
"""
import numpy as np
rng = np.random.default_rng(7)
grid = np.linspace(-30, 30, 120001); du = grid[1] - grid[0]

def logcosh(x):
    return np.logaddexp(x, -x) - np.log(2.0)

def law(b):
    if b == 0:
        q = np.exp(-grid ** 2 / 2); q /= q.sum() * du; return q, 1.0, 1.0
    p = np.exp(-grid ** 2 / 2 - b * logcosh(grid)); p /= p.sum() * du
    sd = np.sqrt(np.sum(grid ** 2 * p) * du)
    q = np.exp(-(sd * grid) ** 2 / 2 - b * logcosh(sd * grid)); q /= q.sum() * du
    return q, sd ** 2, sd ** 2 * (1 + b)

def cdf_abs(q, s):
    return np.sum(q[np.abs(grid) <= s]) * du

print("(1) cylinder estimate: min over s in (0,1] of P(|Y|<=s)/(c_nu s)  (must be >= 1)")
for b in [0, 1, 5]:
    q, m_nu, M_nu = law(b)
    c_nu = 3 / 8 * min(1.0, np.sqrt(m_nu))
    out = []
    for k in [1, 2, 3, 5, 10]:
        dens = q.copy()
        for _ in range(k - 1):
            dens = np.convolve(dens, q, mode='same') * du       # density of the sum (grid symmetric, odd length)
        # normalized sum Y = S / sqrt(k): density_Y(y) = sqrt(k) dens_S(sqrt(k) y)
        dY = np.sqrt(k) * np.interp(np.sqrt(k) * grid, grid, dens, left=0, right=0)
        dY /= dY.sum() * du
        var = np.sum(grid ** 2 * dY) * du
        ratios = [cdf_abs(dY, s) / (c_nu * s) for s in np.linspace(0.002, 1, 400)]
        out.append(f"k={k}: {min(ratios):.3f} (var {var:.4f})")
    print(f"  b={b} (m_nu={m_nu:.4f}, M_nu={M_nu:.4f}, c_nu={c_nu:.4f}): " + "; ".join(out))

print("\n(2) translation inequality nu(E+a) >= nu(E) exp(-M a^2/2) for symmetric E (intervals, symmetric pairs of intervals)")
print("    interval masses from the CDF (trapezoid cumulative integral + linear interpolation), not from grid point counts")
for b in [0, 1, 5]:
    q, m_nu, M_nu = law(b)
    F = np.concatenate([[0.0], np.cumsum((q[1:] + q[:-1]) / 2 * du)]); F /= F[-1]
    mass = lambda lo, hi: np.interp(hi, grid, F) - np.interp(lo, grid, F)
    worst = np.inf
    for _ in range(20000):
        a = rng.uniform(-4, 4)
        if rng.uniform() < 0.5:
            s = np.exp(rng.uniform(np.log(1e-3), np.log(5)))
            lhs = mass(a - s, a + s); base = mass(-s, s)
        else:
            s1, s2 = np.sort(rng.uniform(0, 5, 2))
            lhs = mass(a - s2, a - s1) + mass(a + s1, a + s2); base = 2 * mass(s1, s2)
        rhs = base * np.exp(-M_nu * a * a / 2)
        if rhs > 1e-12: worst = min(worst, lhs / rhs)
    print(f"  b={b}: min ratio nu(E+a)/[nu(E) e^(-M a^2/2)] = {worst:.6f}  (must be >= 1)")

print("\n(3) sub-Gaussian MGF after conditioning on a symmetric interval/box: max of log E e^{theta<u,Y>} / (theta^2 |u|^2/(2 m_nu))")
for b in [0, 1, 5]:
    q, m_nu, M_nu = law(b)
    worst = 0
    for c in [0.05, 0.5, 1.0, 3.0, 30.0]:
        mask = np.abs(grid) <= c; qc = q * mask; qc /= qc.sum() * du
        for th in np.linspace(-6, 6, 241):
            if th == 0: continue
            lm = np.log(np.sum(qc * np.exp(th * grid)) * du)
            worst = max(worst, lm / (th * th / (2 * m_nu)))
    # 2-D: <u, Z> with Z conditioned on box |Z1|<=c1, |Z2|<=c2 (product of conditioned 1-D laws)
    g2 = grid[::40]; q2 = np.interp(g2, grid, q)
    for _ in range(200):
        c1, c2 = rng.uniform(0.05, 4, 2); u = rng.normal(size=2)
        m1 = (np.abs(g2) <= c1) * q2; m1 /= m1.sum(); m2 = (np.abs(g2) <= c2) * q2; m2 /= m2.sum()
        for th in [-3, -1, 0.5, 2, 5]:
            lm = np.log(np.sum(m1 * np.exp(th * u[0] * g2))) + np.log(np.sum(m2 * np.exp(th * u[1] * g2)))
            worst = max(worst, lm / (th * th * (u @ u) / (2 * m_nu)))
    print(f"  b={b}: max ratio = {worst:.6f}  (must be <= 1)")
