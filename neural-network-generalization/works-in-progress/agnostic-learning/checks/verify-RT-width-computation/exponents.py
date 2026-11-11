"""Exponent bookkeeping for the 'In particular' clause of Proposition 6.1 (redteam.md, Sec. 6.3).

Setting of the clause: c = 1, learner width N = ceil(n^alpha), competitor width m <= N and weights
B <= n^alpha, d <= n^alpha.  We take the extreme admissible values m = N, B = n^alpha, d = n^alpha
(rounded down to an integer), U = m B, E* = d(d+1)B^2 + 2(L-1) m^2 B^2, K = E* + 1 + n (U+1)^2 / c,
P_N = N(d+1) + (L-2) N^2 + N, delta = 0.05.

Terms of the displayed bound of Prop. 6.1:
  T1 = c(E*+1)/n
  T2 = 8/n
  T3 = 4 sqrt((P_N ln(2 + 2 n sqrt(K N) H (d+N+1)(K+1)^{H/2}) + ln(4/delta)) / (2n))
  T4 = (U+1)^2 sqrt(ln(4/delta)/(2n))                [Hoeffding for the competitor]
Bernstein replacement for T4 when L_D(g) <= 1 (always WLOG: the zero network is in the class):
  T4B = (U+1) sqrt(2 ln(4/delta)/n) + 2 (U+1)^2 ln(4/delta) / (3n)
Claimed rate in the report: O(n^{4 alpha - 1} + n^{alpha - 1/2} sqrt(log n)).
"""
import mpmath as mp

mp.mp.dps = 60
delta = mp.mpf("0.05")
ld = mp.log(4 / delta)


def terms(n, alpha, L, c=1):
    H = L - 1
    na = n ** alpha
    N = mp.ceil(na)
    m = N
    B = na
    d = mp.floor(na)
    U = m * B
    E = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    K = E + 1 + n * (U + 1) ** 2 / c
    P = N * (d + 1) + (L - 2) * N ** 2 + N
    T1 = c * (E + 1) / n
    T2 = 8 / n
    logG = P * mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2))
    T3 = 4 * mp.sqrt((logG + ld) / (2 * n))
    T4 = (U + 1) ** 2 * mp.sqrt(ld / (2 * n))
    T4B = (U + 1) * mp.sqrt(2 * ld / n) + 2 * (U + 1) ** 2 * ld / (3 * n)
    claimed = n ** (4 * alpha - 1) + n ** (alpha - mp.mpf(1) / 2) * mp.sqrt(mp.log(n))
    return dict(T1=T1, T2=T2, T3=T3, T4=T4, T4B=T4B, claimed=claimed,
                total=T1 + T2 + T3 + T4, totalB=T1 + T2 + T3 + T4B)


def slope(f, n1, n2):
    return (mp.log(f(n2)) - mp.log(f(n1))) / (mp.log(n2) - mp.log(n1))


print("Local log-log slopes between n = 1e100 and n = 1e200 (L = 3 unless stated)")
print(f"{'alpha':>6} | {'T1':>7} {'4a-1':>7} | {'T3':>7} {'a-1/2':>7} | {'T4':>7} {'4a-1/2':>7} | {'T4B':>7} {'2a-1/2':>7} | dominant term at n=1e100")
for alpha in [mp.mpf(x) for x in ("0.05", "0.1", "0.125", "0.15", "0.2", "0.24", "0.249")]:
    n1, n2 = mp.mpf(10) ** 100, mp.mpf(10) ** 200
    s = {k: slope(lambda n: terms(n, alpha, 3)[k], n1, n2) for k in ("T1", "T3", "T4", "T4B")}
    t = terms(n1, alpha, 3)
    dom = max(("T1", "T2", "T3", "T4"), key=lambda k: t[k])
    print(f"{float(alpha):6.3f} | {float(s['T1']):7.3f} {float(4*alpha-1):7.3f} | {float(s['T3']):7.3f} "
          f"{float(alpha-0.5):7.3f} | {float(s['T4']):7.3f} {float(4*alpha-0.5):7.3f} | {float(s['T4B']):7.3f} "
          f"{float(2*alpha-0.5):7.3f} | {dom}")

print()
print("Values of the terms (L = 3, delta = 0.05)")
for alpha in (mp.mpf("0.1"), mp.mpf("0.2")):
    for k in (6, 9, 12, 20, 40):
        n = mp.mpf(10) ** k
        t = terms(n, alpha, 3)
        print(f"alpha={float(alpha):.2f} n=1e{k:<3d} T1={mp.nstr(t['T1'],3):>9} T3={mp.nstr(t['T3'],3):>9} "
              f"T4={mp.nstr(t['T4'],3):>9} T4B={mp.nstr(t['T4B'],3):>9} claimed-rate={mp.nstr(t['claimed'],3):>9} "
              f"total(displayed)={mp.nstr(t['total'],3):>9} total(Bernstein)={mp.nstr(t['totalB'],3):>9}")

print()
print("Does the displayed bound tend to 0?  (total at n = 1e100, 1e200, 1e400; L = 2, 3, 4)")
for L in (2, 3, 4):
    for alpha in [mp.mpf(x) for x in ("0.1", "0.12", "0.13", "0.2", "0.24")]:
        vals = [terms(mp.mpf(10) ** k, alpha, L) for k in (100, 200, 400)]
        print(f"L={L} alpha={float(alpha):.2f}: displayed {[mp.nstr(v['total'],3) for v in vals]}  "
              f"Bernstein {[mp.nstr(v['totalB'],3) for v in vals]}")

print()
print("Same slopes at L = 2 (the clause says 'for L >= 3'; check whether L = 2 differs)")
for alpha in [mp.mpf(x) for x in ("0.1", "0.2")]:
    n1, n2 = mp.mpf(10) ** 100, mp.mpf(10) ** 200
    s = {k: slope(lambda n: terms(n, alpha, 2)[k], n1, n2) for k in ("T1", "T3", "T4")}
    print(f"L=2 alpha={float(alpha):.2f}: slopes T1={float(s['T1']):.3f} T3={float(s['T3']):.3f} T4={float(s['T4']):.3f}")

print()
print("Coefficient of ln n in ln(grid points per coordinate) for L=3: ln(2 n sqrt(KN) H (d+N+1) (K+1)^{H/2})/ln n at n=1e200")
for alpha in [mp.mpf(x) for x in ("0.1", "0.2")]:
    n = mp.mpf(10) ** 200
    H = 2
    na = n ** alpha
    N = mp.ceil(na); m = N; B = na; d = mp.floor(na); U = m * B
    E = d * (d + 1) * B ** 2 + 2 * 2 * m ** 2 * B ** 2
    K = E + 1 + n * (U + 1) ** 2
    val = mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2)) / mp.log(n)
    pred = 1 + (1 + 5 * alpha) / 2 + alpha + H * (1 + 4 * alpha) / 2
    print(f"alpha={float(alpha):.1f}: measured {mp.nstr(val,6)}, predicted 1+(1+5a)/2+a+H(1+4a)/2 = {mp.nstr(pred,6)}")
