"""Scope check of C-fixed-temperature-bayes.md, Theorem C.5 vs the README phrase
"Ordinary Bayes at a fixed temperature works only at polynomial learner width".

Part 1 (theorem-level). Constant target y = 1, competitor g_1 (width 1, weights <= 2), Gaussian nu (m_nu = 1).
  Failure guaranteed by Thm C.5(c): excess >= 1 - 2 beta_N, beta_N = N^-gamma (4k + sqrt(2k)), k = eta n.
  Success guaranteed by Thm C.2 (rho = 1/16): expected excess <= 1/4 + A_L(d,1,2,1/16) N^gamma / (eta (n+1)).
  We print, for gamma = 1, 2, the excess lower bound at polynomial widths N = 3n^(1/gamma), n^(2/gamma), and
  the largest width at which Thm C.2 certifies excess <= 1/2, i.e. the width range the positive result covers.
Part 2 (exact one-dimensional model, the computation referee's extremal case). All last-layer features equal 1,
  so under mu_{N,gamma} the output is z ~ N(0, s2) with s2 = N^-gamma at every input. The FIX_eta posterior after n
  observations y = 1 has density prop. to exp(-eta n (clip z - 1)^2) phi_s(z). We compute the posterior mean of
  clip z by quadrature and find the variance s2* = N^-gamma at which the excess (1 - fhat)^2 equals 1/2.
  Since |h| <= 1, this model has the largest prior output variance, so it is the most favourable to learning;
  the crossover N^gamma = 1/s2* is therefore an indication (not a theorem) of where the real learner fails.
"""
import numpy as np
from scipy import integrate, optimize

def A_L(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    E_star = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    c = 3 / 8 * min(1.0, np.sqrt(m_nu))
    b0 = 2 * np.sqrt((2 / m_nu) * (2 * np.log(9) + np.log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = min(0.5, rho / (2 * P0))
    return 1 + M_nu / 2 * E_star + (d + 2 + (L - 2) * m) * np.log(1 / (c * h)) + np.log(2)

eta = 0.125
print("Part 1: theorem-level thresholds, constant target, eta = 1/8, m_nu = 1")
for gamma in [1.0, 2.0]:
    for d, L in [(1, 2), (10, 3)]:
        A = A_L(d, 1, 2, 1 / 16, L)
        for n in [10 ** 3, 10 ** 6, 10 ** 9]:
            k = eta * n
            def low(N):  # Thm C.5(c) lower bound on the excess, every sample
                beta = N ** (-gamma) * (4 * k + np.sqrt(2 * k))
                return max(0.0, 1 - 2 * beta)
            N_ok = (eta * (n + 1) / (4 * A)) ** (1 / gamma)   # Thm C.2: expected excess <= 1/2 for N <= N_ok
            N_fail = (4 * (4 * k + np.sqrt(2 * k))) ** (1 / gamma)  # Thm C.5(c): excess >= 1/2 for N >= N_fail
            N1 = 3 * n ** (1 / gamma); N2 = n ** (2 / gamma)
            print(f"  gamma={gamma:.0f} d={d:2d} L={L} n=1e{int(np.log10(n))}: A_L={A:7.1f}  Thm C.2 certifies excess<=1/2 only for N<={N_ok:.3g};"
                  f"  Thm C.5 forces excess>=1/2 for N>={N_fail:.3g} (= {N_fail / n ** (1 / gamma):.2f} n^(1/gamma));"
                  f"  excess lower bound at N=3n^(1/g): {low(N1):.3f}, at N=n^(2/g): {low(N2):.4f}")

print("\nPart 2: exact 1-D extremal model (z ~ N(0, s2), clipped likelihood exp(-eta n (clip z - 1)^2))")
import mpmath as mp
mp.mp.dps = 60
def post_mean_clip(s2, eta_n):
    s2 = mp.mpf(s2); en = mp.mpf(eta_n); s = mp.sqrt(s2)
    # on [-1,1]: exponent -en (z-1)^2 - z^2/(2 s2) = -a (z - zs)^2 + C
    a = en + 1 / (2 * s2); zs = en / a; C = -en + en ** 2 / a
    sd = 1 / mp.sqrt(2 * a)
    lo, hi = (-1 - zs) / sd, (1 - zs) / sd
    Phi = lambda u: mp.ncdf(u); phi = lambda u: mp.npdf(u)
    mass_in = mp.e ** C * mp.sqrt(mp.pi / a) * (Phi(hi) - Phi(lo))
    mean_in = zs + sd * (phi(lo) - phi(hi)) / (Phi(hi) - Phi(lo))
    tail = s * mp.sqrt(mp.pi / 2) * mp.erfc(1 / (s * mp.sqrt(2)))      # int_1^inf e^{-z^2/(2 s2)} dz
    mass_hi = tail                                                     # clip z = 1, likelihood factor 1
    mass_lo = mp.e ** (-4 * en) * tail                                 # clip z = -1, likelihood e^{-4 eta n}
    num = mass_in * mean_in + mass_hi * 1 - mass_lo * 1
    den = mass_in + mass_hi + mass_lo
    return num / den

target_f = 1 - 1 / mp.sqrt(2)   # excess (1 - f)^2 = 1/2
for eta_n in [1, 10, 100, 1000, 10 ** 4, 10 ** 5, 10 ** 6]:
    g = lambda logs2: post_mean_clip(mp.e ** logs2, eta_n) - target_f
    sol = mp.findroot(g, (mp.log(mp.mpf(10) ** -14), mp.log(mp.mpf(10) ** 3)), solver='anderson')
    inv = 1 / mp.e ** sol
    print(f"  eta*n={eta_n:8.0f}: excess crosses 1/2 at N^gamma = 1/s2* = {float(inv):.5g}  (ratio to eta*n: {float(inv/eta_n):.4f};"
          f"  Thm C.5(c) guarantees failure from N^gamma >= {4*(4*eta_n+eta_n**0.5*2**0.5):.4g})")
