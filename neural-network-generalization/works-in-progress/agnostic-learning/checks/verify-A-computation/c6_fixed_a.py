"""Remark 4.7 / Sec. 0.2 item 3: certified excess e of (4.3) at a FIXED accuracy a, for finite d
(c=t=1, delta=0.01, lambda=1), against the d->infinity limit (sqrt(beta(1)) - a)^2 quoted in the text."""
from math import log, sqrt, floor
import mpmath as mp
mp.mp.dps = 40
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)
def alpha(d): return 0.5*log(4*sqrt(2*d))
def Kmem(d, s, a, H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*s)**(1/H), 9/(2*a))
def beta_n(n, M):
    n = mp.mpf(n); p = mp.mpf(1)/M; lp, lq = mp.log(p), mp.log(1-p); tot = mp.mpf(0)
    for k in range(1, 120):
        tot += mp.e**(mp.loggamma(n+1)-mp.loggamma(k+1)-mp.loggamma(n-k+1)+k*lp+(n-k)*lq)/k
    return float(tot)
b1 = float(mp.e**(-1)*(mp.ei(1)-mp.euler))
for a in (0.1, 0.3):
    P(f"a = {a}: limit (sqrt(beta(1)) - a)^2 = {(sqrt(b1)-a)**2:.4f}")
    for H in (2, 3):
        row = []
        for d in (20, 30, 40, 60):
            M = 2.0**d; bn = beta_n(M, M)
            q = bn - sqrt(2*log(100)/M)
            eps = (Kmem(d, M, a, H) + 1)/M + a*a
            row.append(f"d={d}: {max(sqrt(q)-sqrt(eps),0)**2:.4f}")
        P(f"   H={H}: " + ", ".join(row))
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
