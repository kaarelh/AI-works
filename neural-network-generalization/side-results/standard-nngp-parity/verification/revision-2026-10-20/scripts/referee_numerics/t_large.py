import numpy as np
from scipy.special import gammaln
from myspec import *
def lb(n,k): return gammaln(n+1)-gammaln(k+1)-gammaln(n-k+1)
# elementary scan
w1, w2, w3 = np.inf, -np.inf, np.inf
for d in list(range(64, 5001)) + list(range(5001, 100001, 997)):
    rmax = d//64
    ks = np.arange(0, rmax+1); logDr = np.logaddexp.accumulate(lb(d, ks))
    rs = np.arange(1, rmax+1, 2)
    H = np.log(np.e*(d+1)/rs)
    w1 = min(w1, np.min((np.log(2)+logDr[rs])/(rs*H)))
    w2 = max(w2, np.max(rs*H/d))
    w3 = min(w3, np.min(np.exp(lb(d, rs)-lb(d+1, rs+2))/(rs/d)**2))
print(f"E1 min log(2D_r)/(rH_r)={w1:.4f}  E2 max rH_r/d={w2:.5f}  E3 min ratio={w3:.4f}")
c, v = coeffs_tanh(4001, 1.0); A = v
res = []
for d in [200, 400, 800, 1600, 3200]:
    D = d+1; W = level_masses(D, c)
    th = []
    for r in range(1, min(194, d//2), 2):
        tail = W[r+2::2].sum()
        th.append(W[r+2]/tail*np.sqrt(r))
    # rho ~ 0.06, A_delta = 1, n = D_r log(2 D_r)
    r = int(round(0.06*d)); r += (r % 2 == 0)
    if abs((r-2)/d-0.06) < abs(r/d-0.06): r -= 2
    ks = np.arange(0, r+1); logDr = np.logaddexp.accumulate(lb(d, ks))[r]
    logn = logDr + np.log(np.log(2)+logDr)
    tau = A*W[r+2::2].sum(); lam1 = A*W[r+2]/np.exp(lb(D, r+2))
    nl = np.exp(logn)*lam1/tau
    # monotone/level check: C(D,r+2) lam_{r+1} <= tau
    res.append((d, min(th), max(th), r, nl))
    print(f"d={d}: theta_r sqrt r in [{min(th):.3f},{max(th):.3f}] (odd r<=193); rho=0.06 -> r={r}, n lam_(r+1)/tau_r={nl:.3f}, tau_r={tau:.3e}")
