import numpy as np, random
random.seed(4)
bad=0
cs=np.concatenate([[0],np.logspace(-6,4,4000)])
for trial in range(200):
    m=random.randint(1,5)
    s=sorted([random.uniform(0.001,0.2) for _ in range(m)],reverse=True)
    d=np.array([random.randint(1,10) for _ in range(m)])
    tot=sum(si*di for si,di in zip(s,d))
    if tot>1: s=[si/tot*random.uniform(0.3,1) for si in s]
    s=np.array(sorted(s,reverse=True)); pi=s*d; pi0=1-pi.sum()
    if pi0<0: continue
    Psi=pi0+np.minimum(np.outer(cs,d),pi).sum(axis=1)
    def P_poly(k):
        y=1.0; x=0.0
        for sj,dj in zip(s,d):
            if k<=x+dj: return y-sj*(k-x)
            x+=dj; y-=sj*dj
        return y
    for k in np.linspace(0,d.sum()+3,40):
        if abs((Psi-cs*k).max()-P_poly(k))>1e-3: bad+=1
print("polygon mismatches:",bad)
random.seed(4)
m=3; s=np.array([0.1,0.05,0.01]); d=np.array([2,3,5]); pi=s*d; pi0=1-pi.sum()
Psi=pi0+np.minimum(np.outer(cs,d),pi).sum(axis=1)
def P_poly(k):
    y=1.0; x=0.0
    for sj,dj in zip(s,d):
        if k<=x+dj: return y-sj*(k-x)
        x+=dj; y-=sj*dj
    return y
for k in [0,1,2,3,5,7,10,12]:
    print(k,(Psi-cs*k).max(),P_poly(k))
