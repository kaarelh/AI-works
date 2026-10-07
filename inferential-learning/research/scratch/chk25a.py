import numpy as np, itertools
from math import log2
rng=np.random.default_rng(2)
def H(p): return -(p*log2(p)+(1-p)*log2(1-p))
for d,pn in [(5,2),(6,4),(6,15),(7,30),(4,3)]:
    n=2**d; p=pn/n
    X=np.array([[(x>>i)&1 for i in range(d)] for x in range(n)])
    a=rng.integers(0,2,d); fa=(X@a)%2
    E=rng.choice(n,pn,replace=False); y=fa.copy(); y[E]^=1
    allA=np.array(list(itertools.product([0,1],repeat=d)))
    F=(X@allA.T)%2  # n x 2^d
    for u in range(d+1):
        comps=[ap for ap in allA if (ap[:d-u]==a[:d-u]).all()]
        def logP(yv):
            ws=[np.sum(((X@ap)%2)!=yv) for ap in comps]
            return np.log2(sum(2.0**-u * p**w*(1-p)**(n-w) for w in ws))
        lp=-logP(y)
        lo=u+n*H(p)
        # argmax over a' of P_u(f_{a'})
        scores=[logP(F[:,j]) for j in range(len(allA))]
        j=int(np.argmax(scores)); ok=(allA[j][:d-u]==a[:d-u]).all()
        if not (lo-1e-9-np.log2(1+2**u*(p/(1-p))**(n*(0.5-2*p)))<=lp<=lo+1e-9) or not ok:
            print("VIOL",d,pn,u,lp,lo,ok)
    print("d",d,"p",p,"checked; 4p<1:",4*p<1)
