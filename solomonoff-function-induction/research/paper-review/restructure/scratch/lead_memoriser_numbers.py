import math
from mpmath import mp, mpf, log, binomial, ceil
mp.dps=40
d,m=100,20; p=mpf(2)**-10; s0=1024
LS=log(binomial(2**m,s0),2)
print("LS",LS)
for kappa in (0,30):
    kb=2*log(d,2)+2*log(m,2)+2*log(s0,2)+kappa
    L1=2*log(d,2)+2*log(m,2)+kappa
    out=[]
    for x in (0.5,0.8,0.9,0.94,0.97):
        c=mpf(x)*mpf(2)**-m
        rho=c*(ceil(LS)-LS+0+4+L1+kb)
        RB=rho/(1-c*2**m)
        e=mpf(2)**(-RB/p)
        out.append(float(e))
    print(kappa,["%.5f"%v for v in out])
