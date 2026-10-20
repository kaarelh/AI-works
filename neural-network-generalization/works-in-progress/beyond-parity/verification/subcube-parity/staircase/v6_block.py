import itertools, numpy as np
def fwht(a):
    a=a.astype(float).copy(); h=1; n=len(a)
    while h<n:
        a=a.reshape(-1,2*h); u=a[:,:h].copy(); v=a[:,h:].copy(); a[:,:h]=u+v; a[:,h:]=u-v; a=a.reshape(-1); h*=2
    return a/n
for K,b in [(3,3),(3,4),(5,2)]:
    d=K*b; X=np.array(list(itertools.product([-1,1],repeat=d)))
    P=np.cumprod(X,axis=1); f=np.sign(P[:,b-1::b].sum(1))
    c=fwht(f); sizes=[bin(i).count('1') for i in range(len(c)) if abs(c[i])>1e-12]
    # restriction: fix blocks 2..K -> +- parity of block 1
    ok=True
    for rest in itertools.product([-1,1],repeat=d-b):
        Y=np.array(list(itertools.product([-1,1],repeat=b)))
        Z=np.hstack([Y,np.tile(rest,(len(Y),1))]); PP=np.cumprod(Z,axis=1)
        g=np.sign(PP[:,b-1::b].sum(1)); chi=np.prod(Y,axis=1)
        ok&= (g==chi).all() or (g==-chi).all()
    print(f"K={K} b={b}: min Fourier set size {min(sizes)}, restriction is +-chi_B1 always: {ok}")
