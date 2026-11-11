"""Scope check of C-fixed-temperature-bayes.md, "Relation to SP_c" (Section C.5.1):
"Part (a) would then give the width- and scale-free complexity term 2cA_L/(n+1)".

SP_c at scale sigma has eta = 1/(2 c sigma^2); Theorem C.1 needs eta <= 1/8, i.e. sigma^2 >= 4/c.
Proposition C.3(a): complexity term = A_L/(eta sigma^2 (n+1)) = 2 c A_L/(n+1) when sigma^2 <= 1/N;
for sigma^2 > 1/N it is (right side of (C.3.1))/(eta (n+1)).
At the smallest admissible scale sigma^2 = 4/c we evaluate the complexity term as a function of the learner width N.
It equals (at most) 2cA_L/(n+1) only for N <= 1/sigma^2 = c/4, and grows (about linearly in N log N) beyond.
Gaussian coordinates, competitor d = 10, m = 1, B = 2, rho = 1/16, depth L = 3.
"""
import numpy as np

def consts(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    E_star = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    c_nu = 3 / 8 * min(1.0, np.sqrt(m_nu))
    b0 = 2 * np.sqrt((2 / m_nu) * (2 * np.log(9) + np.log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = rho / (2 * P0)
    logterm = np.log(1 / (c_nu * h))
    A = 1 + M_nu / 2 * E_star + (d + 2 + (L - 2) * m) * logterm + np.log(2)
    return E_star, logterm, A

def rhs_C31(sigma2, N, d, m, B, rho, L, M_nu=1.0):
    E_star, logterm, _ = consts(d, m, B, rho, L)
    return M_nu * E_star / (2 * sigma2) + N * (d + 2 + (L - 2) * m) * (logterm + (L - 1) * max(0.0, np.log(np.sqrt(sigma2 * N)))) + np.log(2)

d, m, B, rho, L = 10, 1, 2, 1 / 16, 3
E_star, logterm, A = consts(d, m, B, rho, L)
for n, theta in [(10 ** 6, 0.25), (10 ** 9, 0.25)]:
    c = n ** (1 - theta)
    sigma2 = 4 / c
    eta = 1 / (2 * c * sigma2)   # = 1/8
    print(f"n=1e{int(np.log10(n))}, theta={theta}: c={c:.4g}, sigma^2=4/c={sigma2:.3g}, eta={eta}, 1/sigma^2=c/4={1/sigma2:.4g};"
          f" 2cA_L/(n+1)={2*c*A/(n+1):.4g}")
    for N in [int(c / 400), int(c / 4), int(c), int(10 * c), int(100 * c)]:
        if sigma2 <= 1 / N:
            term = A / (eta * sigma2 * (n + 1))
        else:
            term = rhs_C31(sigma2, N, d, m, B, rho, L) / (eta * (n + 1))
        print(f"   N={N:>12d}: sigma^2<=1/N: {sigma2 <= 1/N!s:5}  complexity term of Prop C.3(a) = {term:.4g}")
