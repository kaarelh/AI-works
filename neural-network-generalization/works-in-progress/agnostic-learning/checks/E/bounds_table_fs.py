"""Certified finite-scale excess e of E-finite-prior-scale.md Theorem 5.2 (every gamma >= 1) at c=1, t=1,
delta=0.01, optimizing the accuracy a on a logarithmic grid (Table 7.1; Corollary 5.3).
Uses K_rob and N_* of Proposition 4.4.  beta_n is replaced by the lower bound beta(lambda) - n/M^2."""
import numpy as np
from math import log, sqrt, exp, lgamma
def beta_n(n, M):
    # E[1/K; K>=1], K~Bin(n,1/M); Poisson approx error <= n/M^2 (A-tight-conditioning-fails.md Lemma 4.3(c)); use Poisson(lambda) value
    lam = n/M
    # beta(lam) = e^{-lam} sum_{k>=1} lam^k/(k k!)
    s, term = 0.0, 1.0
    for k in range(1, 400):
        term *= lam/k
        s += term/k
    return exp(-lam)*s - n/M**2   # conservative lower bound for beta_n
def K_rob(d, s, a, H):
    Pimin = 3**(-(H-1)/2); Sb = 1/Pimin + 0.25
    Amax = 2*sqrt(2*d*s)/Pimin
    ad = 0.5*log(4*sqrt(2*d))
    alpha = 2 + max(ad, 0.5*log(256*H*Sb/a))
    R2 = max(Amax**(2/H), 128*H**2*Sb**3/a, 4.0)
    return d*(d+1)*alpha**2 + (H+1)*R2, R2, Amax, Sb
def Nstar(d, s, a, H):
    K, R2, Amax, Sb = K_rob(d, s, a, H)
    R = sqrt(R2); ld = (d+1)*log(2) + log(8*H)
    u0 = min(a/(16*R**(H-1)), a/(32*H**2*Sb))
    m0 = 128*log(2)*Amax**2*(d+1)/a**2 + 1
    return max(m0, 256*Amax**2*ld/a**2, 512*H**2*Sb**2*ld/a**2, 2*ld/u0**2)
print("H  d   lambda  e_cert(best a)   a*        K_rob       K_rob/n     log10 N_*")
for H in [2, 3]:
    for d in [30, 40, 50, 60, 80]:
        for lam in [1.0, 1.5]:
            M = 2.0**d; n = lam*M; s = min(n, M); delta = 0.01; t = 1.0; c = 1.0
            bn = beta_n(n, M)
            best = (-1, None, None)
            for a in np.logspace(-12, 0, 600):
                K = K_rob(d, s, a, H)[0]
                eps = lam*a**2 + c*(K+2*t)/M
                e = max(0.0, sqrt(max(0.0, bn - sqrt(2*lam*log(1/delta)/M))) - sqrt(eps))**2
                if e > best[0]: best = (e, a, K)
            e, a, K = best
            print(f"{H}  {d:2d}  {lam:4.1f}    {e:.4f} (beta={bn:.4f})  {a:.2e}  {K:.3e}  {K/n:.2e}   {log(Nstar(d,s,a,H),10):.1f}")
