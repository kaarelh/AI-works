"""Claim C (C-fixed-temperature-bayes.md): explicit constants, Section C.8 item 6.
(1) A_L(d,m,B,rho) of (C.3.2) = paper.tex eq. (A) (Gaussian coordinates: m_nu = M_nu = 1, c_nu = 3/8), and the
    sample size of Corollary C.2.1 for E L_D(fbar_n) <= L_D(g) + eps (rho = eps/8, eta = 1/8, gamma = 1, learner
    width N = m); the printed value is the right side 2 A_L N^gamma/(eta eps) of the condition on n+1.
(2) The rate eps_n(d) of Corollary C.2.2, exactly as defined in (C.4.2):
    eps_n(d) = 4/n + (2 n^a)^gamma A_L(d, n^a, n^a, 1/n) / (eta (n+1)).
    (An earlier version of this script used ceil(n^a)^gamma in place of (2 n^a)^gamma, i.e. the bound that
    Theorem C.2 gives directly at N_n = ceil(n^a); that quantity is smaller by a factor between 1.87 and 2.00 on this grid.)
(3) The two width thresholds of Theorem C.5(d) for the constant target, and their ratio.
"""
import numpy as np

def A_L(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    E_star = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    c = 3 / 8 * min(1.0, np.sqrt(m_nu))
    b0 = 2 * np.sqrt((2 / m_nu) * (2 * np.log(9) + np.log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = min(0.5, rho / (2 * P0))
    return 1 + M_nu / 2 * E_star + (d + 2 + (L - 2) * m) * np.log(1 / (c * h)) + np.log(2), E_star

print("A_L and sufficient n for excess <= eps (eta=1/8, gamma=1, N=m):")
for (d, m, B, L, eps) in [(10, 1, 2, 2, 0.1), (10, 10, 2, 2, 0.1), (10, 10, 2, 3, 0.1), (10, 10, 2, 4, 0.1), (100, 10, 2, 3, 0.1), (10, 100, 2, 3, 0.1), (10, 10, 2, 3, 0.01)]:
    A, E = A_L(d, m, B, eps / 8, L)
    n = 2 * A * m / (0.125 * eps)
    print(f"  d={d:3d} m={m:3d} B={B} L={L} eps={eps}: E_*={E:9.0f}  A_L={A:10.1f}  n >= {n:.3e}")

gamma = 1.0
print("\nRate eps_n(d) of (C.4.2) (competitors: width, weights <= n^a; learner width N = ceil(n^a) <= 2 n^a; gamma=1, eta=1/8, d=10, L=3):")
for a in [0.05, 0.1, 0.15, 0.19]:
    row = []
    for n in [1e6, 1e9, 1e12, 1e15, 1e18]:
        m = B = n ** a
        A, _ = A_L(10, m, B, 1 / n, 3)
        row.append(4 / n + (2 * n ** a) ** gamma * A / (0.125 * (n + 1)))   # eps_n(d) as defined in (C.4.2)
    print(f"  a={a}: " + "  ".join(f"n=1e{int(np.log10(nn))}: {v:.2e}" for nn, v in zip([1e6, 1e9, 1e12, 1e15, 1e18], row)))

print("\nConstant target y = 1 (competitor g = 1: width 1, weights <= 2), Gaussian, gamma = 1, eta = 1/8:")
for (d, n) in [(2, 10 ** 4), (10, 10 ** 6), (10, 10 ** 8)]:
    A, _ = A_L(d, 1, 2, 1 / 16, 2)
    up = 0.125 * (n + 1) / (4 * A)      # N^gamma below this: upper bound gives excess <= 1/4 + 1/4
    k = 0.125 * n
    low = 4 * (4 * k + np.sqrt(2 * k))  # N^gamma above this: excess >= 1/2 for every sample
    print(f"  d={d} n={n:.0e}: works (excess<=1/2) for N <= {up:.3e};  fails (excess>=1/2) for N >= {low:.3e};  ratio {low/up:.1f}"
          f"  (limit 64 A_L/m_nu = {64 * A:.1f}, A_L(d,1,2,1/16) = {A:.1f})")
