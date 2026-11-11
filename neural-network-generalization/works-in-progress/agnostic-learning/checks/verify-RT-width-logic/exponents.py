"""Evaluate every term of the display of redteam.md Proposition 6.1 in the 'in particular' regime.

c = 1, learner width N = ceil(n^alpha), competitor width m = N (the class allows width <= N),
weights B = n^alpha, d = floor(n^alpha) (the class allows d <= n^alpha), U = mB,
E_* = d(d+1)B^2 + 2(L-1)m^2B^2, K = E_* + 1 + n(U+1)^2/c, P_N = N(d+1) + (L-2)N^2 + N.

Terms of the display:
  T1 = c(E_*+1)/n
  T2 = 8/n
  T3 = 4 sqrt( (P_N ln(2 + 2n sqrt(KN) H (d+N+1) (K+1)^{H/2}) + ln(4/delta)) / (2n) )
  T4 = (U+1)^2 sqrt( ln(4/delta) / (2n) )                         [Hoeffding for g, as displayed]
Repair:
  T4b = (U+1) sqrt( 8 ln(4/delta) / n ) + 2 (U+1)^2 ln(4/delta) / (3n)   [Bernstein, L_D(g) < 4]
"""
import mpmath as mp

mp.mp.dps = 60


def terms(n, alpha, L, delta=mp.mpf("0.05")):
    n = mp.mpf(n)
    H = L - 1
    na = n ** alpha
    N = mp.ceil(na)
    m = N
    B = na
    d = mp.floor(na)
    U = m * B
    Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    c = 1
    K = Es + 1 + n * (U + 1) ** 2 / c
    P = N * (d + 1) + (L - 2) * N ** 2 + N
    lg = mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2))
    T1 = c * (Es + 1) / n
    T2 = 8 / n
    T3 = 4 * mp.sqrt((P * lg + mp.log(4 / delta)) / (2 * n))
    T4 = (U + 1) ** 2 * mp.sqrt(mp.log(4 / delta) / (2 * n))
    T4b = (U + 1) * mp.sqrt(8 * mp.log(4 / delta) / n) + 2 * (U + 1) ** 2 * mp.log(4 / delta) / (3 * n)
    claimed = n ** (4 * alpha - 1) + n ** (alpha - mp.mpf(1) / 2) * mp.sqrt(mp.log(n))
    return dict(T1=T1, T2=T2, T3=T3, T4=T4, T4b=T4b,
                display=T1 + T2 + T3 + T4, repaired=T1 + T2 + T3 + T4b, claimed=claimed)


def slope(f, n1, n2):
    return float((mp.log10(f(n2)) - mp.log10(f(n1))) / (mp.log10(n2) - mp.log10(n1)))


L = 3
print("L = 3, c = 1, delta = 0.05; worst case of the stated class (m = N = ceil(n^a), B = n^a, d = floor(n^a))")
print()
for alpha in [mp.mpf("0.05"), mp.mpf("0.1"), mp.mpf("0.125"), mp.mpf("0.15"), mp.mpf("0.2"), mp.mpf("0.24")]:
    print(f"alpha = {float(alpha):.3f}")
    print("   log10 n | log10 T1  T3     T4(Hoeff) T4b(Bern) | log10 display  repaired  claimed-rate")
    for e in [6, 12, 24, 48, 96, 192]:
        t = terms(mp.mpf(10) ** e, alpha, L)
        print(f"   {e:7d} | {float(mp.log10(t['T1'])):7.2f} {float(mp.log10(t['T3'])):6.2f} "
              f"{float(mp.log10(t['T4'])):9.2f} {float(mp.log10(t['T4b'])):9.2f} | "
              f"{float(mp.log10(t['display'])):12.2f} {float(mp.log10(t['repaired'])):9.2f} "
              f"{float(mp.log10(t['claimed'])):12.2f}")
    n1, n2 = mp.mpf(10) ** 150, mp.mpf(10) ** 300
    for key, theo in [("T1", 4 * alpha - 1), ("T3", alpha - mp.mpf(1) / 2), ("T4", 4 * alpha - mp.mpf(1) / 2),
                      ("T4b", 2 * alpha - mp.mpf(1) / 2), ("display", None), ("repaired", None)]:
        s = slope(lambda n: terms(n, alpha, L)[key], n1, n2)
        extra = f" (theory {float(theo):+.3f}, up to log factors)" if theo is not None else ""
        print(f"   asymptotic slope of {key:9s}: {s:+.4f}{extra}")
    print()

# exponent bookkeeping with sympy
import sympy as sp
a = sp.symbols("alpha", positive=True)
ex = {"c(E*+1)/n": 4 * a - 1, "grid term": a - sp.Rational(1, 2), "Hoeffding g-term": 4 * a - sp.Rational(1, 2),
      "Bernstein g-term (linear part)": 2 * a - sp.Rational(1, 2), "Bernstein g-term (range part)": 4 * a - 1}
print("Exponents of n (fixed L, delta):")
for k, v in ex.items():
    print(f"   {k:32s}: {v}   negative iff alpha < {sp.solve(sp.Eq(v, 0), a)[0]}")
print("Displayed bound (Hoeffding): max exponent =", sp.Max(*[ex[k] for k in ['c(E*+1)/n', 'grid term', 'Hoeffding g-term']]),
      "-> polynomially small iff alpha < 1/8")
print("Repaired bound (Bernstein):  max exponent =", sp.Max(*[ex[k] for k in ['c(E*+1)/n', 'grid term', 'Bernstein g-term (linear part)', 'Bernstein g-term (range part)']]),
      "-> polynomially small iff alpha < 1/4")
