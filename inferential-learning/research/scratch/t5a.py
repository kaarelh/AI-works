import numpy as np
from math import log2, log
from scipy.optimize import brentq
H=lambda p: -(p*log2(p)+(1-p)*log2(1-p))
f=lambda p: 1-2*p/log(2)-H(p)
p0=brentq(f,0.01,0.24); print("p where 1-2p/ln2 = H(p):",p0)
for p in [1/64,0.05,0.1,0.14,0.15,0.2,0.24]:
    print(p, "bound 1-2p/ln2=",round(1-2*p/log(2),4)," H(p)=",round(H(p),4))
# Lemma 2.5a / 2.5b brute force
rng=np.random.default_rng(1)
d=6; n=2**d
X=np.array([[(x>>i)&1 for i in range(d)] for x in range(n)])
A=np.array([[(t>>i)&1 for i in range(d)] for t in range(n)])
chi=(-1)**((A@X.T)%2)   # chi[a',x]
viol=0; viol2=0; maxratio=0
for trial in range(20000):
    kind=trial%4
    if kind==0: h0=rng.random(n)
    elif kind==1: h0=rng.choice([0.0,1.0,0.5],n)
    elif kind==2:
        b=rng.integers(0,2,d); h0=np.where((X@b)%2==0, rng.uniform(0.5,1), rng.uniform(0,0.5))*np.ones(n)
    else:
        h0=rng.beta(0.3,0.3,n)
    s=2*h0-1   # s=h(0|x)-h(1|x)
    sh=chi@s/n
    for t in [0,0.5,1,2,3]:
        cnt=(sh>=2**-t).sum()
        if cnt>2**(2*t)+1e-9: viol+=1
    # lemma 2.5b
    a=rng.integers(0,n); pn=rng.integers(0,n//4)
    E=rng.choice(n,pn,replace=False); e=np.zeros(n,int); e[E]=1
    fa=((A[a]@X.T)%2)
    ys=(fa+e)%2
    hy=np.where(ys==0,h0,1-h0)
    with np.errstate(divide='ignore'):
        R=np.mean(-np.log2(hy))
    p=pn/n
    lb=-log2((1+sh[a])/2+p) if (1+sh[a])/2+p>0 else -np.inf
    if R < lb-1e-9: viol2+=1
    # exact identity: E h(y*|x) = 1/2 + 1/2 <s, (-1)^y*>
    ex=np.mean(hy); ident=0.5+0.5*np.mean(s*(-1)**ys)
    assert abs(ex-ident)<1e-12
print("Lemma 2.5a violations:",viol," Lemma 2.5b violations:",viol2)
