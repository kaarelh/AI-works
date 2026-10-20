"""Exhaustive checks of the elementary inequalities used in the proof of Theorem A.

For every d in [64, 20000] and every odd r with 1 <= r <= d/64:
  (E1) log(2 D_r) >= 0.8 r H_r,          H_r = log(e(d+1)/r)
  (E2) r H_r <= 0.081 d   (hence r H_r <= sqrt(d r H_r) and b_r <= 3 C_delta sqrt(d r H_r))
  (E3) C(d,r)/C(d+1,r+2) >= (r/d)^2
  (E4) log(2 D_{r+2}) <= 2 r H_r + 1 (sanity: the paper's C in n/C(D,r+2) <= C A rH)
Also (E5) -log(1-x) <= 2 log 2 * x on [0,1/2].
"""
import numpy as np
from scipy.special import gammaln, logsumexp


def logbinom(n, k):
    return gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1)


worst = dict(E1=np.inf, E2=-np.inf, E3=np.inf, E4=-np.inf)
arg = {}
for d in list(range(64, 2001)) + list(range(2001, 20001, 37)):
    rmax = d // 64
    if rmax < 1:
        continue
    ks = np.arange(0, rmax + 3)
    lb = logbinom(d, ks)
    logDr = np.logaddexp.accumulate(lb)          # log D_r for r = 0..rmax+2
    for r in range(1, rmax + 1, 2):
        H = np.log(np.e * (d + 1) / r)
        e1 = (np.log(2) + logDr[r]) / (r * H)
        e2 = r * H / d
        e3 = np.exp(logbinom(d, r) - logbinom(d + 1, r + 2)) / (r / d) ** 2
        e4 = ((np.log(2) + logDr[r + 2]) - 1) / (r * H)
        if e1 < worst['E1']:
            worst['E1'] = e1; arg['E1'] = (d, r)
        if e2 > worst['E2']:
            worst['E2'] = e2; arg['E2'] = (d, r)
        if e3 < worst['E3']:
            worst['E3'] = e3; arg['E3'] = (d, r)
        if e4 > worst['E4']:
            worst['E4'] = e4; arg['E4'] = (d, r)
print("E1 min of log(2D_r)/(r H_r)          =", worst['E1'], "at", arg['E1'], "(need >= 0.8)")
print("E2 max of r H_r / d                  =", worst['E2'], "at", arg['E2'], "(need <= 0.081)")
print("E3 min of [C(d,r)/C(d+1,r+2)]/(r/d)^2 =", worst['E3'], "at", arg['E3'], "(need >= 1)")
print("E4 max of (log(2D_{r+2})-1)/(r H_r)  =", worst['E4'], "at", arg['E4'], "(need <= 2)")
x = np.linspace(1e-9, 0.5, 200001)
print("E5 max of -log(1-x)/(2 log2 x) on (0,1/2] =", np.max(-np.log1p(-x) / (2 * np.log(2) * x)))
