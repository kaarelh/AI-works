import math, numpy as np
from scipy.stats import binom, norm
from scipy.integrate import quad
# exact E_W[(e_r(m)-dist_W)_+] using log-space binomials
def LB(d,r,m):
    if r>=m: return 0.0
    e=binom.cdf((m-r-1)//2,m,0.5)
    N=d-m; kW=np.arange(N+1); Wv=2*kW-N; Wp=binom.pmf(kW,N,0.5)
    kV=np.arange(m); th=1+2*kV-(m-1); Vp=binom.pmf(kV,m-1,0.5)
    # cdf of theta
    tot=0.0
    for w,pw in zip(Wv,Wp):
        if w>0: dist=Vp[th<-w].sum()
        elif w<0: dist=Vp[th>-w].sum()
        else: dist=1.0  # conservative
        tot+=pw*max(0.0,e-dist)
    return tot
def er(m,r): return binom.cdf((m-r-1)//2,m,0.5)
# check e_r(m) >= 1/2-(r+3)/(2 sqrt m), and explicit bound
bad=0
for m in range(2,400):
    for r in range(1,m,2):
        if er(m,r) < 0.5-(r+3)/(2*math.sqrt(m))-1e-12: bad+=1
print("e_r(m) bound violations:",bad)
# check E dist <= (2 sqrt m+1)/sqrt(d-m)
bad=0
for d in [21,51,101,201]:
    for m in range(1,d):
        N=d-m; kW=np.arange(N+1); Wv=2*kW-N; Wp=binom.pmf(kW,N,0.5)
        kV=np.arange(m); th=1+2*kV-(m-1); Vp=binom.pmf(kV,m-1,0.5)
        Ed=0
        for w,pw in zip(Wv,Wp):
            Ed+=pw*(Vp[th<-w].sum() if w>0 else (Vp[th>-w].sum() if w<0 else 1.0))
        if Ed>(2*math.sqrt(m)+1)/math.sqrt(d-m)+1e-12: bad+=1
print("E dist bound violations:",bad)
# m=cd/4 explicit 1/2-2.1sqrt c
for d in [10001, 100001]:
    for c in [0.001,0.005,0.01,0.05]:
        r=int(c*math.sqrt(d)); r-= (r%2==0); r=max(r,1)
        m=int(c*d/4)
        expl=0.5-(r+3)/(2*math.sqrt(m))-(2*math.sqrt(m)+1)/math.sqrt(d-m)
        print(f"d={d} c={c} r={r} m={m} explicit={expl:.4f} 1/2-2.1sqrtc={0.5-2.1*math.sqrt(c):.4f}")
# finite-d values claimed
for d,r in [(6401,7),(6401,39),(6401,79)]:
    best=max((LB(d,r,m),m) for m in range(r+1,d,max(1,(d-r)//200)))
    print("d",d,"r",r,"best LB",best)
# kappa(c) with positive part, via quad
def kap_delta(c,delta):
    a=norm.cdf(-c/math.sqrt(delta)); s=math.sqrt((1-delta)/delta)
    f=lambda z: 2*norm.pdf(z)*max(0.0,a-norm.sf(z*s))
    return quad(f,0,40,limit=200)[0]
for c in [0.01,0.1,0.5,1,2,3]:
    best=max((kap_delta(c,dl),dl) for dl in np.concatenate([np.linspace(1e-4,0.05,100),np.linspace(0.05,0.999,200)]))
    nopos=max(norm.cdf(-c/math.sqrt(dl))-math.asin(math.sqrt(dl))/math.pi for dl in np.linspace(1e-5,0.999,20000))
    print(f"c={c}: kappa≈{best[0]:.4g} at delta={best[1]:.4f}; without positive part {nopos:.4f}")
