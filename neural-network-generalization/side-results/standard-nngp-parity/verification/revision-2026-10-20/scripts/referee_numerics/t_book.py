import numpy as np
from scipy.special import gammaln
from myspec import *
def lb(n,k): return gammaln(n+1)-gammaln(k+1)-gammaln(n-k+1)
c, v = coeffs_tanh(4001, 1.0); A = v
Ad, Cd, dl, a = 50.0, 10.0, 0.1, 1.0
cdel = dl/2*min(1/16, 1/(480*Cd))
viol = 0
for d in [1000, 4000, 10000]:
    D = d+1; W = level_masses(D, c)
    for r in range(1, d//64+1, 2):
        H = np.log(np.e*D/r)
        logDr = np.logaddexp.accumulate(lb(d, np.arange(r+1)))[r]
        L2D = np.log(2)+logDr
        logn = np.log(Ad) + logDr + np.log(L2D)       # smallest n with cutoff r (log)
        tau = A*W[r+2::2].sum()
        if tau <= 0: break
        loglam = np.log(A)+np.log(W[r+2]) - lb(D, r+2)
        b = Cd*(1+np.sqrt(d*r*H)+r*H)
        mainA1 = dl/tau*min(1/16, Ad*L2D/(128*b))          # (A1) main term / (n a^2)
        A2 = cdel/tau*min(1, Ad*np.sqrt(r*H/d))             # (A2) / (a^2)
        # (A1) => (A2): need mainA1 - log2/n >= A2 (per n a^2)
        lhs = mainA1 - np.log(2)/np.exp(logn)
        if lhs < A2: viol += 1; print("A1->A2 fails", d, r, lhs, A2)
        # Cor 5 factor
        f5 = mainA1*tau*(b+r*H) - np.log(2)*tau*(b+r*H)/np.exp(logn)
        f5lb = dl/2*min(Cd*np.sqrt(d*r*H)/16, Ad*r*H/160)
        if f5 < f5lb: viol += 1; print("Cor5 factor fails", d, r, f5, f5lb)
        # Remark 8.5 term
        l85 = np.log(2*tau) - loglam
        if r in (1, 3, 9, 31, 61, 155) or r == (d//64 if (d//64)%2 else d//64-1):
            print(f"d={d} r={r}: Cor5 factor={f5:.3e} (lb {f5lb:.3e}); log(2tau/lam)={l85:.1f}, log C(d,r+1)={lb(d,r+1):.1f}, 2rH={2*r*H:.1f}, excess over logC/sqrt d={(l85-lb(d,r+1))/np.sqrt(d):.3f}")
print("violations:", viol)
