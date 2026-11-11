"""Referee checks for B.md (logic lens), part 2.
(a) Lemma 4.2: exact source count  P_J ln(1+2(J+1)/Delta_J)  <=  Gamma_L  <=  polynomial form, on a grid.
(b) Lemma 5.1(v) clip-mixture identity by quadrature (independent of B_checks).
(c) Thm 6.3 step: ln(n+1) <= n^g/g for g in (0,1/2], n >= 1 (grid).
(d) Lemma 7.2 step 6: (|g|^3/3) sum_{i=1}^{H-1} R^{-2i} <= 2|g|^3/(3R^2) when R^2 >= 2.
"""
import math
import numpy as np
from scipy.integrate import quad

def source_params(d, K, a, L):
    r = min(1.0, a * math.sqrt(d) / (8 * K ** (L / 2)))
    lns = d * math.log(1 + 2 * math.sqrt(d) / r)            # ln of the net-size bound
    DT = max(1, math.ceil(lns / math.log(2)))
    lam = a * 2 ** (-L) * K ** (-(L - 1) / 2) / (4 * (L - 1))
    J = max(math.ceil(4 * K), math.ceil(256 * lam ** -4 * (DT + math.log(L / lam))))
    lnDelta = math.log(a) - math.log(4 * (d + L + 1)) - L * math.log(2 * J * J)
    P = J * (d + 1) + (L - 2) * J * J + J
    # ln(1 + 2(J+1)/Delta) computed stably
    x = math.log(2 * (J + 1)) - lnDelta
    lncount = P * (x + math.log1p(math.exp(-x)))
    return J, lncount

def gamma_bounds(d, K, a, L):
    ell = math.log(17 * d * K / a)
    CJ = 196609 * L * (L - 1) ** 4 * 16 ** L
    Jbar = CJ * d * K ** (2 * (L - 1)) * a ** -4 * ell
    Gam = ((L - 2) * Jbar ** 2 + (d + 2) * Jbar) * ((2 * L + 1) * math.log(Jbar) + math.log(2 ** (L + 5) * (d + L + 1) / a))
    Clog = (2 * L + 1) * (math.log(CJ) + 2 * L + 1) + L + 6
    if L >= 3: poly = (L - 1) * CJ ** 2 * Clog * d ** 2 * K ** (4 * (L - 1)) * a ** -8 * ell ** 3
    else:      poly = 3 * CJ * Clog * d ** 2 * K ** 2 * a ** -4 * ell ** 2
    return Jbar, Gam, poly

bad = 0; cnt = 0
for L in [2, 3, 4]:
    for d in [1, 2, 10, 100]:
        for K in [1, 1.5, 10, 1e3]:
            for a in [1, 0.3, 1e-2, 1e-4]:
                J, lc = source_params(d, K, a, L)
                Jbar, Gam, poly = gamma_bounds(d, K, a, L)
                cnt += 1
                ok = (J <= Jbar) and (lc <= Gam * (1 + 1e-12)) and (Gam <= poly * (1 + 1e-12))
                if not ok:
                    bad += 1; print("  Lemma 4.2 VIOLATION", L, d, K, a, J, Jbar, lc, Gam, poly)
print(f"(a) Lemma 4.2: {cnt} cases, {bad} violations")

maxerr = 0.0
rng = np.random.default_rng(1)
for _ in range(200):
    r = 10 ** rng.uniform(-2, 1.5); u = rng.uniform(-1, 1)
    clip = lambda t: max(-t, min(t, u))
    w = lambda t: 2 * r * math.tanh(r * t) / math.cosh(r * t) ** 2
    I, _ = quad(lambda t: clip(t) * w(t), 0, 1, points=[abs(u)], limit=200)
    rhs = I + (1 / math.cosh(r) ** 2) * max(-1, min(1, u))
    mass, _ = quad(w, 0, 1, limit=200)
    maxerr = max(maxerr, abs(rhs - math.tanh(r * u) / r), abs(mass + 1 / math.cosh(r) ** 2 - 1))
print(f"(b) Lemma 5.1(v): max abs error over 200 random (r,u): {maxerr:.2e}")

worst = float('inf')
for g in np.linspace(1e-3, 0.5, 200):
    for n in np.unique(np.round(np.logspace(0, 12, 400))):
        worst = min(worst, n ** g / g - math.log(n + 1))
print(f"(c) min over grid of n^g/g - ln(n+1): {worst:.4f} (should be > 0)")

worst = -float('inf')
for H in range(2, 12):
    for R2 in [2, 2.5, 4, 10, 100]:
        lhs = sum(R2 ** (-i) for i in range(1, H)) / 3
        worst = max(worst, lhs - 2 / (3 * R2))
print(f"(d) max of LHS - RHS (per |g|^3): {worst:.3e} (should be <= 0)")
