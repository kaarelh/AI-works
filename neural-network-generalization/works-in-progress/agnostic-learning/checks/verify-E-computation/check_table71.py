"""Independent recomputation of beta(lambda), its maximizer, exact binomial beta_n, and Table 7.1
(certified excess e of Theorem 5.2 at c=1, t=1, delta=0.01, a optimised), K_rob/n and log10 N_*.
Written from the formulas in E.md Prop 4.4 / Thm 5.2, not from bounds_table_fs.py."""
import numpy as np
from math import log, sqrt, exp, floor, lgamma, log10
from scipy import optimize, special, stats

def beta_pois(lam):
    return np.exp(-lam)*(special.expi(lam) - np.euler_gamma - np.log(lam))
lam_star = optimize.minimize_scalar(lambda l: -beta_pois(l), bounds=(0.5, 3), method='bounded').x
print(f"beta(1) = {beta_pois(1.0):.6f}; argmax lambda* = {lam_star:.5f}; beta(lambda*) = {beta_pois(lam_star):.6f}")
print("first-order condition beta(l*) = (1-e^-l*)/l*:", beta_pois(lam_star), (1-np.exp(-lam_star))/lam_star)

def beta_binom_exact(n, M):
    # E[1/K; K>=1], K ~ Bin(n, 1/M); stable log-pmf: log C(n,k) = sum_{i<k} log(n-i) - log k!
    import math
    n = int(round(n)); p = 1.0/M
    tot = 0.0; logc = 0.0
    for k in range(1, 400):
        logc += math.log(n - (k-1)) - math.log(k)
        lp = logc + k*math.log(p) + (n-k)*math.log1p(-p)
        tot += math.exp(lp)/k
    return tot

def params(d, s, a, H):
    Sb = 3**((H-1)/2) + 0.25
    Amax = 2*sqrt(2*d*s)*3**((H-1)/2)
    ad = 0.5*log(4*sqrt(2*d))
    alpha = 2 + max(ad, 0.5*log(256*H*Sb/a))
    R = max(Amax**(1/H), sqrt(128*H**2*Sb**3/a), 2.0)
    K = d*(d+1)*alpha**2 + (H+1)*R**2
    u0 = min(a/(16*R**(H-1)), a/(32*H**2*Sb))
    ld = (d+1)*log(2) + log(8*H)
    mf = floor(128*log(2)*Amax**2*(d+1)/a**2) + 1
    Nst = max(mf, 256*Amax**2*ld/a**2, 512*H**2*Sb**2*ld/a**2, 2*ld/u0**2)
    return K, Nst

print("\nH  d  lam  beta_n(exact)  e_cert   a*        K_rob/n     log10 N*")
for H in [2, 3]:
    for d in [30, 40, 60]:
        for lam in [1.0, 1.5]:
            M = 2.0**d; n = lam*M; s0 = min(n, M); delta = 0.01; t = 1.0; c = 1.0
            bn = beta_binom_exact(n, M)
            dev = sqrt(2*lam*log(1/delta)/M)
            def e_of(a):
                K, _ = params(d, s0, a, H)
                eta = a**2 + c*(K + 2*t)/n
                return max(0.0, sqrt(max(0.0, bn - dev)) - sqrt(lam*eta))**2
            grid = np.logspace(-13, 0, 1300)
            vals = [e_of(a) for a in grid]
            i = int(np.argmax(vals)); a_best = grid[i]
            res = optimize.minimize_scalar(lambda la: -e_of(10**la), bounds=(log10(grid[max(i-1,0)]), log10(grid[min(i+1,len(grid)-1)])), method='bounded')
            a_best = 10**res.x; eb = e_of(a_best)
            K, Nst = params(d, s0, a_best, H)
            print(f"{H}  {d}  {lam:.1f}  {bn:.6f}      {eb:.4f}   {a_best:.2e}  {K/n:.2e}    {log10(Nst):.1f}")
