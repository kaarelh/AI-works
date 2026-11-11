"""Referee check of redteam.md Section 5 constants.
(1) gamma(lambda) = (1-e^{-lambda})^2/(4 lambda): value at 1, argmax, max.
(2) beta(lambda) = e^{-l} sum_{k>=1} l^k/(k k!) = e^{-l}(Ei(l) - gamma_E - ln l).
(3) Theorem 5.1 explicit lower bound (theta G - E0)_+^2/(4 M V) at c=1, lambda=1:
    (a) with the asymptotic surrogates G=(1-e^-l)M, V=lM (as bounds_table.py does),
    (b) with the exact binomial means G=M p_d, V=n,
    (c) worst case on the event of Lemma 1.3: G = M p_d - 2 n^{2/3}, V = n + n^{2/3}.
    Also: first d where positive; ratio to the asymptotic gamma*theta^2; first d where >= 2 eps_d.
(4) Bracket minimization alpha t^2 + (1-t)^2 (sympy).
"""
import math
import mpmath as mp
import sympy as sp
from scipy import optimize

mp.mp.dps = 40

def gam(l):
    return (1 - math.exp(-l))**2 / (4*l)

print("== gamma(lambda) ==")
print("gamma(1) =", gam(1.0))
res = optimize.minimize_scalar(lambda l: -gam(l), bounds=(0.05, 6), method='bounded', options={'xatol': 1e-12})
print("argmax gamma = %.6f, max = %.6f" % (res.x, -res.fun))
# stationarity: 2 l = e^l - 1
root = optimize.brentq(lambda l: math.exp(l) - 1 - 2*l, 0.5, 3)
print("root of e^l - 1 = 2l: %.6f, gamma there = %.6f" % (root, gam(root)))

print("\n== beta(lambda) ==")
def beta(l):
    l = mp.mpf(l)
    return mp.e**(-l) * (mp.ei(l) - mp.euler - mp.log(l))
def beta_series(l):
    l = mp.mpf(l)
    return mp.e**(-l) * mp.nsum(lambda k: l**k/(k*mp.factorial(k)), [1, mp.inf])
for l in [0.5, 1, 1.5, 2]:
    print("beta(%.1f) = %s  (series %s)" % (l, mp.nstr(beta(l), 10), mp.nstr(beta_series(l), 10)))
bm = mp.findroot(lambda l: mp.diff(beta, l), 1.5)
print("argmax beta = %s, max = %s" % (mp.nstr(bm, 8), mp.nstr(beta(bm), 8)))

print("\n== Theorem 5.1 explicit bound, c=1, lambda=1 ==")
def FD(d):
    return 1 + (d+1)*(d+2)**2

def t51(d, c=1.0, lam=1.0, mode='asym'):
    M = mp.mpf(2)**d
    n = mp.ceil(lam*M)
    p_d = -mp.expm1(n*mp.log1p(-1/M))  # stable for huge M
    th = 1/(18*d*c + 1)
    E0 = c*(d*FD(d) + 1) + 2
    if mode == 'asym':
        G = (1 - mp.e**(-lam))*M; V = lam*M
    elif mode == 'mean':
        G = M*p_d; V = n
    elif mode == 'event':
        G = M*p_d - 2*n**(mp.mpf(2)/3); V = n + n**(mp.mpf(2)/3)
    val = max(th*G - E0, 0)**2/(4*M*V)
    asym = gam(lam)*th**2
    return val, asym, th*G, E0

first_pos = {}
for mode in ['asym', 'mean', 'event']:
    for d in range(20, 80):
        v, a, tg, e0 = t51(d, mode=mode)
        if v > 0:
            first_pos[mode] = d
            break
print("first d with positive bound:", first_pos)
print(" d   asym-surrogate   exact-mean     event-worst    gamma*theta^2   ratio(event/asym)  eps_d=gamma th^2/3   bound>=2eps_d?")
for d in [29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 40, 45, 50, 60, 80, 100, 200]:
    va, aa, _, _ = t51(d, mode='asym')
    vm, _, _, _ = t51(d, mode='mean')
    ve, _, _, _ = t51(d, mode='event')
    eps = aa/3
    print("%3d  %.4e      %.4e     %.4e     %.4e      %.4f            %.4e          %s" % (
        d, float(va), float(vm), float(ve), float(aa), float(ve/aa), float(eps), ve >= 2*eps))
# the location of the maximum of the explicit bound
best = max(range(25, 120), key=lambda d: t51(d, mode='event')[0])
print("max of event-worst bound over d: d=%d, value=%.4e" % (best, float(t51(best, mode='event')[0])))
# first d at which the bound is >= 2 eps_d (needed in Cor 5.2), c=1
for mode in ['asym', 'event']:
    for d in range(25, 400):
        v, a, _, _ = t51(d, mode=mode)
        if v >= 2*a/3:
            print("first d with bound >= 2 eps_d (c=1, %s): %d" % (mode, d)); break

print("\n== bracket minimization ==")
t, al = sp.symbols('t alpha', positive=True)
f = al*t**2 + (1 - t)**2
ts = sp.solve(sp.diff(f, t), t)
print("argmin:", ts, " value:", sp.simplify(f.subs(t, ts[0])), " 1 - 1/(alpha+1) =", sp.simplify(1 - 1/(al + 1)))
print("second derivative:", sp.diff(f, t, 2))
