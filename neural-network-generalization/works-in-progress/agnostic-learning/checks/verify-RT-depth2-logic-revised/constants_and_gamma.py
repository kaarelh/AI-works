"""Independent checks of the constants and the Gamma_lambda table of RT-depth2.fixed.md.

Checks:
  (1) beta(lambda) series vs closed form; beta(1), gamma(1), argmax of each.
  (2) inequality (1.0): 4 gamma <= beta < 1 - e^{-lambda} on a grid.
  (3) Gamma_1(nu) table, crossing point of the two branches, vanishing point of branch 2.
  (4) Remark 5.4 limits beta (1 - sqrt(2c/sqrt(beta)))_+^2 at c = 0.01, 0.1; threshold sqrt(beta)/2.
  (5) elementary inequality (sqrt q - r)_+^2 >= q - 2 r for 0 <= q <= 1, r >= 0 (Prop 5.3 proof).
  (6) bracket minimisation alpha t^2 + (1-t)^2 (sympy).
  (7) Lemma 1.1 pointwise inequality (1+t) e^{-t/(2s)} <= (1 + 2 s / rho) e^{-(1-rho) t/(2s)}.
"""
import math
import random

import mpmath as mp
import sympy as sp

mp.mp.dps = 40


def beta_series(lam, K=400):
    lam = mp.mpf(lam)
    s = mp.mpf(0)
    term = mp.mpf(1)
    for k in range(1, K):
        term = term * lam / k          # lam^k / k!
        s += term / k
    return mp.e ** (-lam) * s


def beta_closed(lam):
    lam = mp.mpf(lam)
    return mp.e ** (-lam) * (mp.ei(lam) - mp.euler - mp.log(lam))


def gam(lam):
    lam = mp.mpf(lam)
    return (1 - mp.e ** (-lam)) ** 2 / (4 * lam)


def Gamma(lam, nu):
    lam = mp.mpf(lam); nu = mp.mpf(nu)
    b1 = gam(lam) / (18 * nu + 1) ** 2
    inner = mp.sqrt(beta_closed(lam)) - mp.sqrt((1 - mp.e ** (-lam)) * 18 * nu / (18 * nu + 1))
    b2 = max(inner, 0) ** 2
    return b1, b2, max(b1, b2)


print("(1) constants")
for lam in [0.5, 1, 1.5, 2]:
    print("  lambda=%.2f  beta(series)=%s  beta(closed)=%s  gamma=%s" % (
        lam, mp.nstr(beta_series(lam), 10), mp.nstr(beta_closed(lam), 10), mp.nstr(gam(lam), 10)))
lg = mp.findroot(lambda l: mp.e ** l - 1 - 2 * l, 1.25)
lb = mp.findroot(lambda l: mp.diff(beta_closed, l), 1.5)
print("  argmax gamma = %s (gamma = %s); argmax beta = %s (beta = %s)" % (
    mp.nstr(lg, 9), mp.nstr(gam(lg), 9), mp.nstr(lb, 9), mp.nstr(beta_closed(lb), 9)))

print("(2) inequality (1.0) on lambda in [0.01, 20]")
worst_left = mp.inf; worst_right = mp.inf
for i in range(1, 2001):
    lam = mp.mpf(i) / 100
    b = beta_closed(lam)
    worst_left = min(worst_left, b - 4 * gam(lam))
    worst_right = min(worst_right, (1 - mp.e ** (-lam)) - b)
print("  min(beta - 4 gamma) = %s (>=0 needed); min((1-e^-l) - beta) = %s (>0 needed)" % (
    mp.nstr(worst_left, 6), mp.nstr(worst_right, 6)))

print("(3) Gamma_1(nu) table (note: 0.4848 0.3488 0.1488 0.0277 0.0250 0.0127 0.0003)")
for nu in [0, 0.001, 0.01, 0.05, 1 / 18, 0.1, 1]:
    b1, b2, g = Gamma(1, nu)
    print("  nu=%.5f  branch1=%.5f  branch2=%.5f  Gamma=%.4f" % (nu, float(b1), float(b2), float(g)))
cross = mp.findroot(lambda nu: Gamma(1, nu)[0] - Gamma(1, nu)[1], (0.02, 0.06), solver='bisect')
vanish = mp.findroot(lambda nu: mp.sqrt(beta_closed(1)) - mp.sqrt((1 - mp.e ** (-1)) * 18 * nu / (18 * nu + 1)), (0.1, 0.3), solver='bisect')
print("  crossing nu = %s (note 0.0390); branch-2 vanishing nu = %s (note 0.1829)" % (
    mp.nstr(cross, 5), mp.nstr(vanish, 5)))
# monotone and continuous on a grid
prev = None; mono = True
for i in range(0, 5001):
    nu = mp.mpf(i) / 1000
    g = Gamma(1, nu)[2]
    if prev is not None and g > prev + mp.mpf(10) ** -30:
        mono = False
    prev = g
print("  Gamma_1 nonincreasing on [0,5]:", mono)

print("(4) Remark 5.4 limits")
b = beta_closed(1)
for c in [0.01, 0.1, 0.3, 0.5, 1]:
    val = max(1 - mp.sqrt(2 * c / mp.sqrt(b)), 0) ** 2 * b
    print("  c=%.2f  beta(1-sqrt(2c/sqrt beta))_+^2 = %.4f" % (c, float(val)))
print("  threshold sqrt(beta)/2 = %.4f" % float(mp.sqrt(b) / 2))

print("(5) (sqrt q - r)_+^2 >= q - 2r for 0<=q<=1, r>=0")
random.seed(1)
viol = 0
for _ in range(200000):
    q = random.random(); r = random.random() * 3
    lhs = max(math.sqrt(q) - r, 0) ** 2
    if lhs < q - 2 * r - 1e-15:
        viol += 1
print("  violations:", viol)

print("(6) bracket")
t, a = sp.symbols('t alpha', positive=True)
expr = a * t ** 2 + (1 - t) ** 2
tstar = sp.solve(sp.diff(expr, t), t)[0]
print("  argmin t =", sp.simplify(tstar), "; min value =", sp.simplify(expr.subs(t, tstar)),
      "; 1 - 1/(1+alpha) =", sp.simplify(1 - 1 / (1 + a)))

print("(7) Lemma 1.1 pointwise inequality")
viol = 0; worst = 0.0
for _ in range(200000):
    s = 10 ** random.uniform(-4, 1)        # s = sigma^2
    rho = random.uniform(1e-3, 1 - 1e-3)
    tt = 10 ** random.uniform(-3, 4)
    lhs = (1 + tt) * math.exp(-tt / (2 * s))
    rhs = (1 + 2 * s / rho) * math.exp(-(1 - rho) * tt / (2 * s))
    if rhs > 0 and lhs > rhs * (1 + 1e-12):
        viol += 1
    if rhs > 1e-300:
        worst = max(worst, lhs / rhs)
print("  violations:", viol, " max ratio lhs/rhs = %.6f" % worst)
