# Independent checks of claim 1 (structure, J, arcsine) and claim 8 (restriction structure)
import itertools, numpy as np
from math import comb
def allx(d):
    return np.array(list(itertools.product([-1,1],repeat=d)),dtype=np.int64)
for d in [3,5,7,9,11,13]:
    X=allx(d); P=np.cumprod(X,axis=1); S=P.sum(1); f=np.sign(S)
    assert (S!=0).all()
    # J = first t>=1 with S_t = S_d
    J=np.array([np.argmax(P[i].cumsum()==S[i])+1 for i in range(len(X))])
    chiJ=np.array([np.prod(X[i,:J[i]]) for i in range(len(X))])
    ok=(chiJ==f).all()
    # distribution of d-J vs discrete arcsine u_{2k}u_{2n-2k}, 2n=d-1
    n=(d-1)//2
    u=lambda k2: comb(k2,k2//2)/2**k2
    emp=np.bincount(d-J,minlength=d)/len(X)
    pred=np.zeros(d)
    for k in range(n+1): pred[2*k]=u(2*k)*u(2*n-2*k)
    # split identity for every m
    okm=True
    for m in range(1,d):
        chim=np.prod(X[:,:m],axis=1)
        theta=np.array([sum(np.prod(X[i,t:m]) for t in range(1,m+1)) for i in range(len(X))])
        W=(np.cumprod(X[:,m:],axis=1)).sum(1)
        okm&= (chim*np.sign(theta+W)==f).all()
    print(d,"J-identity",ok,"split",okm,"arcsine maxdiff",np.abs(emp-pred).max())
