from math import log2, ceil, comb, lgamma, log
def H(q): return -(q*log2(q)+(1-q)*log2(1-q))
def log2binom(n,k): return log2(comb(n,k))
d,m,p=100,20,2.0**-10
for (jj,s1) in [(11,2**9),(13,2**7)]:
    s2=1024-s1; p1=s1/2**m; p2=s2/(2**m-s1); Re=(1-p1)*H(p2); L2=log2binom(2**m-s1,s2)
    print(f"j={jj}: L2={L2:.3f} H-Re={H(p)-Re:.6f}")
    for kappa in (0.0,30.0):
        Lam1=2*log2(d)+2*log2(m)+kappa; kg=2*log2(d)+2*log2(10)+kappa
        G=lambda j: 1-log2(1+2.0**(-j)+2*p); ts=(d-Lam1)/4; Hp=H(p)
        chi=min((G(1)-Hp)/(8+Lam1+kg),(G(ts-1)-Hp)/(d+kg)) if ts>=2 else (G(1)-Hp)/(d+kg)
        k1=2*log2(jj+1)+kappa; ke=2*log2(d)+2*log2(m)+2*log2(s2+1)+kappa; KS1=2*log2(m)+k1+kappa
        slack=k1+ke+4+Lam1; cenv=(Hp-Re)/slack; lo=2.0**-m
        share=(log2(min(cenv,chi))-log2(lo))/(log2(chi)-log2(lo))
        row=[]
        for dS2 in (0.0,20.0):
            for c in (1.01*lo,3e-5):
                Rbar=(c*slack+(dS2+log2(2**m+1)+KS1)/2**m)/p1
                row.append(f"dS2={dS2:.0f},c={c:.3e}: e1>={2**-Rbar:.5f}")
        print(f"  kappa={kappa:.0f}: chi={chi:.6e} cenv={cenv:.6e} share={share:.5f}; "+"; ".join(row))
