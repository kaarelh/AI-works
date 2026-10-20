"""Exhaustive checks of the elementary inequalities used in the proof of Theorem A.

For every d in [64, 20000] (all d up to 2000, then every 37th) and every odd r with 1 <= r <= d/64:
  (E1) log(2 D_r) >= 0.8 r H_r,          H_r = log(e(d+1)/r)
  (E2) r H_r <= 0.081 d   (hence r H_r <= sqrt(d r H_r) and b_r <= 3 C_delta sqrt(d r H_r))
  (E3) C(d,r)/C(d+1,r+2) >= (r/d)^2
  (E4) D_{r+2} log(2 D_{r+2}) <= 8 C(D,r+2) r H_r,   D = d+1.
       This is the inequality n < A_delta D_{r+2} log(2D_{r+2}) <= C A_delta C(D,r+2) r H_r
       of (I4), with the explicit constant C = 8.  Analytic proof: D_{r+2} <= 2 C(d,r+2)
       for r+2 <= (d+1)/3, and log(2 D_{r+2}) <= log 2 + (r+2) H_r <= 4 r H_r.
  (E4b) informational: (log(2 D_{r+2}) - log 2)/(r H_r) <= (r+2)/r <= 3, from D_k <= (ed/k)^k.
       (Version 1 of this script printed (log(2D_{r+2})-1)/(rH_r) with the label "need <= 2";
        that label was wrong: no such constant is used anywhere, and the maximum is 2.53, at r=1.)
Also (E5) -log(1-x) <= 2 log 2 * x on [0,1/2].
"""
import numpy as np
from scipy.special import gammaln


def logbinom(n, k):
    return gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1)


worst = dict(E1=np.inf, E2=-np.inf, E3=np.inf, E4=-np.inf, E4b=-np.inf, E4c=-np.inf)
arg = {}


def upd(key, val, where, is_min):
    if (is_min and val < worst[key]) or ((not is_min) and val > worst[key]):
        worst[key] = val
        arg[key] = where


for d in list(range(64, 2001)) + list(range(2001, 20001, 37)):
    rmax = d // 64
    if rmax < 1:
        continue
    ks = np.arange(0, rmax + 3)
    lb = logbinom(d, ks)
    logDr = np.logaddexp.accumulate(lb)          # log D_r for r = 0..rmax+2
    rlow = np.log(d) ** 2 / 4
    for r in range(1, rmax + 1, 2):
        H = np.log(np.e * (d + 1) / r)
        e1 = (np.log(2) + logDr[r]) / (r * H)
        e2 = r * H / d
        e3 = np.exp(logbinom(d, r) - logbinom(d + 1, r + 2)) / (r / d) ** 2
        l2D = np.log(2) + logDr[r + 2]
        e4 = np.exp(logDr[r + 2] + np.log(l2D) - logbinom(d + 1, r + 2)) / (r * H)
        e4b = (l2D - np.log(2)) / (r * H)
        upd('E1', e1, (d, r), True)
        upd('E2', e2, (d, r), False)
        upd('E3', e3, (d, r), True)
        upd('E4', e4, (d, r), False)
        upd('E4b', e4b, (d, r), False)
        if r >= rlow:
            upd('E4c', e4b, (d, r), False)
print("E1  min of log(2D_r)/(r H_r)                        =", worst['E1'], "at", arg['E1'], "(need >= 0.8)")
print("E2  max of r H_r / d                                =", worst['E2'], "at", arg['E2'], "(need <= 0.081)")
print("E3  min of [C(d,r)/C(d+1,r+2)]/(r/d)^2               =", worst['E3'], "at", arg['E3'], "(need >= 1)")
print("E4  max of D_{r+2} log(2D_{r+2})/(C(D,r+2) r H_r)    =", worst['E4'], "at", arg['E4'], "(need <= 8; analytic bound 8)")
print("E4b max of (log(2D_{r+2})-log 2)/(r H_r)             =", worst['E4b'], "at", arg['E4b'], "(informational; analytic bound 3)")
print("E4c same, restricted to r >= (log d)^2/4             =", worst['E4c'], "at", arg['E4c'], "(informational)")
x = np.linspace(1e-9, 0.5, 200001)
print("E5  max of -log(1-x)/(2 log2 x) on (0,1/2]           =", np.max(-np.log1p(-x) / (2 * np.log(2) * x)), "(need <= 1)")
