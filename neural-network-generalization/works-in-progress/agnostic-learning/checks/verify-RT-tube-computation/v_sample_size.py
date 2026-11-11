"""The sample size Prop 4.1 inherits from Theorem strong:
  n >= (6/eps) [ log|H_{K,a}| + log(1/delta) ],  K = E_* + 2,  a = min{1/2, (tau-rho-rho0)/4},
with the explicit cover of paper.tex Lemma compression / Prop energy-cover / Remark cube.
Also the sample size of the sharper bound E L_D(clip z) <= rho^2 + eps:
  n >= (72/eps^2) [ log|H_{K,eps/24}| + log(1/delta) ].
All logs natural; computed in log-space with mpmath.
"""
import mpmath as mp

mp.mp.dps = 30


def log_cover(d, K, a, L):
    K, a = mp.mpf(K), mp.mpf(a)
    lam = a * mp.mpf(2) ** (-L) * K ** (-(mp.mpf(L) - 1) / 2) / (4 * (L - 1))
    r = min(mp.mpf(1), a * mp.sqrt(d) / (8 * K ** (mp.mpf(L) / 2)))
    log2s = d * mp.log(1 + 2 * mp.sqrt(d) / r, 2)          # cube version (Remark cube)
    DT = max(1, int(mp.ceil(log2s)))
    J = max(int(mp.ceil(4 * K)), int(mp.ceil(256 * lam ** (-4) * (DT + mp.log(L / lam)))))
    J = mp.mpf(J)
    logDelta = mp.log(a) - mp.log(4 * (d + L + 1)) - L * mp.log(2 * J ** 2)
    P = J * (d + 1) + (L - 2) * J ** 2 + J
    return P * mp.log(1 + 2 * (J + 1) * mp.e ** (-logDelta)), J, lam


eps, delta = mp.mpf('0.1'), mp.mpf('0.01')
print("setting                          E_*      J            log|H|        n (Prop 4.1)    n (rho^2+eps bound)")
for (d, C, B, L, rho0) in [(1, 1, 1.05, 2, 0.1), (1, 1, 1.05, 3, 0.1), (5, 2, 1, 2, 0.1), (5, 2, 1, 3, 0.1), (5, 2, 1, 3, 0.02)]:
    Estar = d * (d + 1) * B ** 2 + 2 * (L - 1) * C ** 2 * B ** 2
    K = Estar + 2
    rho, tau = 2 * rho0, 4 * rho0
    a = min(0.5, (tau - rho - rho0) / 4)
    lH, J, lam = log_cover(d, K, a, L)
    n41 = 6 / eps * (lH + mp.log(1 / delta))
    lH2, J2, _ = log_cover(d, K, eps / 24, L)
    n2 = 72 / eps ** 2 * (lH2 + mp.log(1 / delta))
    print(f"d={d} C={C} B={B} L={L} rho0={rho0:<5} {Estar:7.2f}  {mp.nstr(J, 4):>10}  {mp.nstr(lH, 4):>12}  {mp.nstr(n41, 4):>14}  {mp.nstr(n2, 4):>14}")
print("Both sizes are polynomial but astronomically large; the dependence on rho0 enters Prop 4.1 only via")
print("u' = 1/min{1, tau-rho-rho0} (here 1/rho0), and the sharper bound's size does not depend on rho0 at all.")
