#!/usr/bin/env python3
"""Referee's recomputation of every numerical constant in research/prove-c/rehearsal-core.md.

Each line prints the constant as recomputed, the value stated in the proof file, and OK / FAIL.
Nothing is sampled.
"""
from math import log, log1p, exp, sqrt, e, ceil

ok_all = True


def check(name, value, stated, relation):
    """relation: 'le' means the proof needs value <= stated; 'ge' means value >= stated;
    'approx' means |value - stated| <= 6e-5 * max(1, |stated|) (rounded figure)."""
    global ok_all
    if relation == 'le':
        ok = value <= stated
    elif relation == 'ge':
        ok = value >= stated
    else:
        ok = abs(value - stated) <= 6e-5 * max(1.0, abs(stated))
    ok_all &= ok
    print(f"{'OK  ' if ok else 'FAIL'} {name}: recomputed {value:.6g}; stated {relation} {stated:g}")


print("== Section 0 ==")
# (E1): sup_u ln(u)/u = 1/e
grid = [i / 1000 for i in range(1, 20001)]
check("(E1) sup (ln u)^+ / u", max(max(log(u), 0) / u for u in grid), 1 / e + 1e-9, 'le')

print("== Proposition 5.2(d) ==")
check("1 - e^{-1/delta} at delta = 1 (the minimum over delta <= 1)", 1 - exp(-1), 0.63, 'ge')
check("0.63/(2 ln 2)", 0.63 / (2 * log(2)), 0.45, 'ge')
# exact probability in the example for a few (n, delta)
for n, delta in ((10, 0.1), (10, 1.0), (100, 0.05), (1000, 0.5), (7, 1 / 7)):
    q = 1 / (delta * n)
    pr = (1 - (1 - q) ** n) / (q * n)
    check(f"  Pr[beta(M^(T)) = q/2], n={n}, delta={delta:.4g}", pr, 0.63 * delta, 'ge')

print("== Proposition 5.5 ==")
check("(1-p)^2/(4 ln(1/p)) at p = 1/2", 0.25 / (4 * log(2)), 0.09, 'ge')
# E[R] and Var[R] for a sum of L geometric(1/L) variables
for L in (2, 5, 40):
    ER, VarR = L * L, L * (1 - 1 / L) * L * L
    check(f"  L={L}: E[R^2] = Var + E^2 against 2 L^4", VarR + ER ** 2, 2 * L ** 4, 'le')

print("== Proposition 6.2 ==")
for L in (2, 3, 10, 40):
    phi = exp(-80 * L)
    eta = 2 * exp(-8 * L)
    Wp = 1 + eta + eta * phi
    Kln2 = 88 * L - log(2) + log(Wp)          # ln(W'/(eta*phi))
    check(f"  L={L}: K ln 2 = 88L - ln 2 + ln W'", Kln2, 88 * L, 'le')
    check(f"  L={L}: ln(3 + 2 phi)/24", log(3 + 2 * phi) / 24, 0.0458, 'le')
    check(f"  L={L}: psi_(n+1) = (1+phi)/(3/2+phi)", (1 + phi) / (1.5 + phi), 2 / 3, 'ge')
check("2/3 - 0.0458", 2 / 3 - 0.0458, 0.6208, 'ge')
check("0.6208 * (1/3) * (2/3) * 80", 0.6208 * (1 / 3) * (2 / 3) * 80, 11.03, 'ge')
check("88/8 (so that 11.03 > 88/8)", 88 / 8, 11.03, 'le')
check("remark (iii): 8 + 1/3", 8 + 1 / 3, 8.4, 'le')
check("remark (i): 0.14 (L-1) against 5.649 at L = 40", 5.649 / 39, 0.1448, 'approx')

print("== Proposition 6.3 ==")
s1 = 1 / (1 + exp(-1))
check("s_1 = 1/(1 + 1/e)", s1, 0.731, 'ge')
check("ln(1 + e)", log(1 + e), 1.31326, 'approx')
c_lam, c_N = 1.1272, 1.6262
abar_coeff = log(1 + e) / (3 * c_lam)
check("abar/sqrt(L) = ln(1+e)/(3 * 1.1272)", abar_coeff, 0.38836, 'le')
check("abar/N <= (ln(1+e)/(3*1.1272))/1.6262  [the file states 0.23881]", abar_coeff / c_N, 0.23881, 'le')
check("  the same against 0.23882", abar_coeff / c_N, 0.23882, 'le')
check("  bracket of (6.1) with 0.23882", 0.731 * (0.71633 - 0.23882) - 0.0011, 0.3479, 'ge')
check("(lambda+1) abar/(4n) coefficient of L/n", c_lam * 0.38836 / 4, 0.10944, 'le')
check("0.10944/100", 0.10944 / 100, 0.0011, 'le')
check("e^{-1/3} (1 - 1/(9*400)) (smallest n is 100 L = 400)", exp(-1 / 3) * (1 - 1 / 3600), 0.71633, 'ge')
bracket = 0.731 * (0.71633 - 0.23881) - 0.0011
check("bracket of (6.1)", bracket, 0.3479, 'ge')
check("0.3479/6", 0.3479 / 6, 0.05798, 'ge')
check("1.6262 ln 2 + 1.1272", c_N * log(2) + c_lam, 2.2544, 'le')
check("ln 2 - 1 (the constant term)", log(2) - 1, -0.3068, 'le')
check("e^{-lambda} at L = 4 (lambda = 1.2544)", exp(-(c_lam * 2 - 1)), 0.3068, 'le')
check("0.05798/2.2544", 0.05798 / 2.2544, 0.0257, 'ge')
check("1/40", 1 / 40, 0.0257, 'le')
# direct evaluation of (6.1) and of the final quotient for several L (n = 100 L, the worst allowed n)
for L in (4, 5, 9, 16, 100, 400, 1600, 6400, 10 ** 6):
    n = 100 * L
    lam = c_lam * sqrt(L) - 1
    N = ceil(c_N * sqrt(L))
    abar = L * log(1 + e) / (3 * (lam + 1))
    rhs = (L * (L - 1) / (6 * n)) * (s1 * (exp(-1 / 3) * (1 - 1 / (9 * n)) - abar / N) - (lam + 1) * abar / (4 * n))
    Kln2 = N * log(2) + lam + log1p(exp(-lam))    # = N ln 2 + ln(1 + e^lambda)
    quotient = rhs / (L * Kln2 / n)
    check(f"  L={L}: right side of (6.1) / (L K ln2/n), against (L-1)/(40 sqrt L)", quotient, (L - 1) / (40 * sqrt(L)), 'ge')

print("== Proposition 6.4 ==")
for B0 in (1e-6, 1e-3, 0.1, 0.4999):
    c = 2 * B0
    # integral of min(1, c/s) over [0,1] by a fine midpoint rule
    m = 200000
    integ = sum(min(1.0, c / ((i + 0.5) / m)) for i in range(m)) / m
    check(f"  B0={B0}: int_0^1 min(1, 2B0/s) ds against 2B0 (1 + ln(1/(2B0)))", integ, c * (1 + log(1 / c)), 'approx')

print("== Theorem 9.2 ==")
check("1/(8 sqrt 2)", 1 / (8 * sqrt(2)), 0.088, 'ge')
check("sqrt(ln 2 / 2)", sqrt(log(2) / 2), 0.59, 'le')
for th in (0.01, 0.1, 0.2, 0.25):
    kl = 2 * th * log((1 + 2 * th) / (1 - 2 * th))
    check(f"  kl(theta)/theta^2 at theta = {th}", kl / th ** 2, 16, 'le')

print("== Proposition 10.3 ==")
vals = [1 / (1 - (1 - 1 / L) ** L) for L in range(2, 2000)]
check("min over L >= 2 of 1/(1 - (1-1/L)^L)", min(vals), 4 / 3, 'ge')
check("max over 2 <= L < 2000 of the same", max(vals), 1.59, 'le')
check("e/(e-1)", e / (e - 1), 1.59, 'le')
check("monotone in L (1 if yes)", float(all(a <= b + 1e-15 for a, b in zip(vals, vals[1:]))), 1.0, 'ge')
check("max over L >= 2 of (1 - 1/L)^-(L-1)", max((1 - 1 / L) ** (-(L - 1)) for L in range(2, 5000)), e, 'le')

print("== Proposition 12.2 and Remark 12.3 ==")
# exp(-2 t^2 / (4L)) = delta for t = sqrt(2 L ln(1/delta))
for L, delta in ((10, 0.1), (1600, 0.01)):
    t = sqrt(2 * L * log(1 / delta))
    check(f"  L={L}, delta={delta}: exp(-2 t^2/(4L))", exp(-2 * t * t / (4 * L)), delta * (1 + 1e-12), 'le')
    t8 = sqrt(8 * L * log(1 / delta))
    check(f"  L={L}, delta={delta}: the note's t = sqrt(8 L ln(1/delta)) gives exp(-t^2/(8L)) (range [-2,2] form)", exp(-t8 * t8 / (8 * L)), delta * (1 + 1e-12), 'le')
check("12.3(iii): L >= 8 ln(1/delta)/(eta mu)^2 gives sqrt(2 L ln(1/delta)) <= eta mu L/2 (ratio at equality)",
      sqrt(2 * (8 * log(10) / 0.01) * log(10)) / (0.1 * (8 * log(10) / 0.01) / 2), 1 + 1e-12, 'le')

print("== Theorem 13.1(a2): (1-eps) ln(1-eps) >= -eps + eps^2/2 on [0,1) ==")
check("min over eps of (1-eps)ln(1-eps) + eps - eps^2/2", min((1 - x) * log(1 - x) + x - x * x / 2 for x in [i / 10000 for i in range(0, 10000)]), 0.0, 'ge')

print()
print("ALL CONSTANTS OK" if ok_all else "SOME CONSTANT FAILED")
