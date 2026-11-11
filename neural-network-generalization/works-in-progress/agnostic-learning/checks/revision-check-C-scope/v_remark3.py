"""Independent re-derivation of the numbers added to Remark 3 after Theorem C.1 (scope issue 12).

Two-point prior: Theta={w1,w2}, mu uniform, z_{w1}=M, z_{w2}=-1, y=-1, eta=1/8, Q=delta_{w2}.
Clipped likelihood: l(w1)=(clip M+1)^2=4 for M>=1, l(w2)=0.
"""
from mpmath import mp, mpf, exp, log, sqrt

mp.dps = 40
eta = mpf(1) / 8


def p(t):
    """posterior weight of w1 after t samples (clipped likelihood), independent of M for M >= 1"""
    return exp(-4 * eta * t) / (1 + exp(-4 * eta * t))


def zbar(t, M):
    return p(t) * M + (1 - p(t)) * (-1)


def clip(u):
    return max(mpf(-1), min(mpf(1), u))


print("== (b) first item: chain (C.2.3) with clip zbar_t, M=10")
M = mpf(10)
rhs_chain = log(2) / eta  # sum_i int l_i dQ = 0, KL(delta_{w2}||mu)=log 2
print("RHS of (C.2.3) = 8 log 2 =", mp.nstr(rhs_chain, 10))
print("zbar_0 =", zbar(0, M), " (zbar_0+1)^2 =", (zbar(0, M) + 1) ** 2,
      " (clip zbar_0 +1)^2 =", (clip(zbar(0, M)) + 1) ** 2)
mid1 = -log((exp(-4 * eta) + 1) / 2) / eta
print("-(1/eta) log(Z1/Z0) =", mp.nstr(mid1, 10))
lhs = mpf(0)
for T in range(1, 31):
    lhs += (clip(zbar(T - 1, M)) + 1) ** 2
    if T <= 6 or T == 30:
        print(f"  T={T}: LHS={mp.nstr(lhs, 8)}  zbar_(T-1)={mp.nstr(zbar(T-1, M), 6)}  LHS>=8: {lhs >= 8}  LHS>RHS: {lhs > rhs_chain}")
print("  min M for which clip zbar_1 = 1 (so LHS_2 = 8):", mp.nstr(2 / p(1) - 1, 8))

print("\n== (b) averaged bound (C.2.4) with clip zbar_t, M=10, n=10")
n = 10
avg = sum((clip(zbar(t, M)) + 1) ** 2 for t in range(n + 1)) / (n + 1)
rhs24 = log(2) / (eta * (n + 1))
print("  left side =", mp.nstr(avg, 10), " right side =", mp.nstr(rhs24, 10))

print("\n== (a) unclipped Gibbs risk vs right side of (C.7.2)")
# right side with Q = delta_{w2}: 0 + 4 eta + (log 2 + 2 log(1/delta))/(eta n)
for n_, d_ in [(100, mpf('0.1')), (10, mpf('0.1')), (1000, mpf('0.1'))]:
    r = 4 * eta + (log(2) + 2 * log(1 / d_)) / (eta * n_)
    print(f"  n={n_}, delta={d_}: RHS = {mp.nstr(r, 10)}")


def gibbs_closed(n_):
    u = exp(-2 * eta * n_)
    return (10 + u) ** 2 / (1 + u ** 2)


def gibbs_direct(n_):
    Mn = 10 * exp(2 * eta * n_)
    return p(n_) * (Mn + 1) ** 2


mx, mn = mpf(-1), mpf(10 ** 9)
for n_ in range(0, 2001):
    g1, g2 = gibbs_closed(n_), gibbs_direct(n_)
    assert abs(g1 - g2) < mpf(10) ** -25 * max(1, g1), (n_, g1, g2)
    if n_ >= 10:
        mx, mn = max(mx, g1), min(mn, g1)
print("  closed form (10+e^{-2 eta n})^2/(1+e^{-4 eta n}) equals p_n (M+1)^2 at M=10e^{2 eta n} for n=0..2000")
print("  over 10<=n<=2000: min =", mp.nstr(mn, 15), " max =", mp.nstr(mx, 15))
print("  values n=7..12:", [mp.nstr(gibbs_closed(k), 8) for k in range(7, 13)])
# Cauchy-Schwarz: (10*1 + 1*u)^2 <= 101 (1+u^2), equality at u = 1/10, i.e. n = 4 ln 10
print("  sup over all n of the closed form is 101, attained at n = 4 ln 10 =", mp.nstr(4 * log(10), 6))
print("  closed form >= 100 iff u <= 20/99, i.e. n >= 4 ln(99/20) =", mp.nstr(4 * log(mpf(99) / 20), 6))

print("\n== Remark 2 (i): E[T]/n for T uniform on {0..n}")
for n_ in [1, 10, 1000]:
    print(f"  n={n_}: E T / n = {sum(range(n_ + 1)) / (n_ + 1) / n_}")
