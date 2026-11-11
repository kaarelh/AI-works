"""Scope issue 10: complexity term of Prop C.3(a) for SP_c, eta = 1/(2 c sigma^2), as a function of N.

Right side of (C.3.1):
  R(N) = M_nu E_*/(2 sigma^2) + N [d+2+(L-2)m] (log(1/(c_nu h_rho)) + (L-1) log^+(sigma sqrt N)) + log 2
Complexity term = R(N)/(eta (n+1)) = 2 c sigma^2 R(N)/(n+1).
For N <= 1/sigma^2 Lemma C.3.1 bounds R(N) by A_L/sigma^2, giving 2 c A_L/(n+1).
Gaussian coordinates (m_nu = M_nu = 1).  Checks: (i) the A_L/sigma^2 bound holds for N <= 1/sigma^2;
(ii) beyond, R(N) grows at least linearly and like N log N; (iii) eta <= 1/8 <=> sigma^2 >= 4/c.
"""
from math import log, sqrt

def consts(d, m, B, L, rho):
    m_nu = M_nu = 1.0
    c_nu = 3 / 8 * min(1, sqrt(m_nu))
    b0 = 2 * sqrt(2 / m_nu * (2 * log(9) + log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = rho / (2 * P0)
    Estar = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    AL = 1 + M_nu / 2 * Estar + (d + 2 + (L - 2) * m) * log(1 / (c_nu * h)) + log(2)
    return M_nu, Estar, c_nu, h, AL

def R(N, sigma2, d, m, B, L, rho):
    M_nu, Estar, c_nu, h, AL = consts(d, m, B, L, rho)
    lp = max(0.0, 0.5 * log(sigma2 * N))
    return M_nu * Estar / (2 * sigma2) + N * (d + 2 + (L - 2) * m) * (log(1 / (c_nu * h)) + (L - 1) * lp) + log(2)

d, m, B, L, rho = 10, 1, 2, 3, 0.25
for c in [16.0, 400.0, 4e4]:
    sigma2 = 4 / c
    eta = 1 / (2 * c * sigma2)
    AL = consts(d, m, B, L, rho)[4]
    print(f"c={c:g}: sigma^2=4/c={sigma2:g}, eta={eta:g}, 1/sigma^2=c/4={1/sigma2:g}, A_L={AL:.4g}")
    n = 10 ** 6
    prev = None
    for N in [1, int(c / 8) or 1, int(c / 4), int(c / 2), int(c), int(10 * c), int(100 * c), int(1000 * c)]:
        if N < 1:
            continue
        r = R(N, sigma2, d, m, B, L, rho)
        term = r / (eta * (n + 1))
        ok = (r <= AL / sigma2 + 1e-9) if N <= 1 / sigma2 else None
        lin = r / N
        print(f"   N={N:>9d}: R/(eta(n+1))={term:10.4g}  2cA_L/(n+1)={2*c*AL/(n+1):8.4g}  "
              f"R<=A_L/sigma^2 (N<=1/sigma^2): {ok}   R/N={lin:9.4g}  R/(N log N)={r/(N*log(N)) if N>1 else float('nan'):8.4g}")
