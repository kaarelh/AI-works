import numpy as np, random
random.seed(4)
bad=0
for trial in range(300):
    m=random.randint(1,5)
    s=sorted([random.uniform(0.001,0.2) for _ in range(m)],reverse=True)
    d=[random.randint(1,10) for _ in range(m)]
    tot=sum(si*di for si,di in zip(s,d))
    if tot>1: s=[si/tot*random.uniform(0.3,1) for si in s]
    pi=[si*di for si,di in zip(s,d)]; pi0=1-sum(pi)
    Psi=lambda c: pi0+sum(min(c*dj,pj) for dj,pj in zip(d,pi))
    cs=np.concatenate([[0],np.logspace(-6,4,20000)])
    def P_leg(k): return max(Psi(c)-c*k for c in cs) if k>=0 else np.inf
    def P_poly(k):
        y=1.0; x=0.0
        for sj,dj in zip(s,d):
            if k<=x+dj: return y-sj*(k-x)
            x+=dj; y-=sj*dj
        return y
    for k in np.linspace(0,sum(d)+3,40):
        if abs(P_leg(k)-P_poly(k))>1e-3: bad+=1
print("polygon mismatches:",bad)
