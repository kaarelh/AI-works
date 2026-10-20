import numpy as np
from scipy.special import gammaln
from myspec import *
def lb(n,k): return gammaln(n+1)-gammaln(k+1)-gammaln(n-k+1)
c, v = coeffs_tanh(4001, 1.0); A = v
for d in [200, 400, 800, 1600, 3200]:
    D = d+1; W = level_masses(D, c)
    ths = {}
    for r in range(1, min(194, d//2), 2):
        ths[r] = W[r+2]/W[r+2::2].sum()*np.sqrt(r)
    in64 = [ths[r] for r in ths if r <= max(1, 0.065*d)]
    bad = [r for r in ths if ths[r] > 3.03]
    r = int(round(0.06*d)); r += (r % 2 == 0)
    logDr = np.logaddexp.accumulate(lb(d, np.arange(r+1)))[r]
    logn = logDr + np.log(np.log(2)+logDr)
    logtau = np.log(A) + np.log(W[r+2::2].sum()); loglam = np.log(A)+np.log(W[r+2]) - lb(D, r+2)
    nl = np.exp(logn + loglam - logtau)
    # also: C(D,r+2) lam_{r+1} <= tau (I2) and n lam/tau >= 0.8 rho^2 rH theta (A_delta=1)
    H = np.log(np.e*D/r); theta = ths[r]/np.sqrt(r)
    print(f"d={d}: r<=0.065d theta*sqrt(r) in [{min(in64):.3f},{max(in64):.3f}]; first r with theta sqrt r>3.03: {bad[:1]} (r/d={bad[0]/d if bad else None})")
    print(f"      r={r}: n lam/tau={nl:.3f}, lower bound 0.8 rho^2 rH theta={0.8*(r/d)**2*r*H*theta:.4f}, theta(I2)<=1: {theta:.4f}")
