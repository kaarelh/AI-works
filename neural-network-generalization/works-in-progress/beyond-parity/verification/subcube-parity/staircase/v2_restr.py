# claim 8: restriction equals +-parity of free set T only if T = prefix {b_1..b_j} of free set and |c_j|> sum others
import itertools, numpy as np
def fwht(a):
    a=a.astype(float).copy(); h=1; n=len(a)
    while h<n:
        a=a.reshape(-1,2*h); u=a[:,:h].copy(); v=a[:,h:].copy(); a[:,:h]=u+v; a[:,h:]=u-v; a=a.reshape(-1); h*=2
    return a/n
def run(d, weights=None):
    w=np.ones(d) if weights is None else np.asarray(weights,float)
    viol=0; events=0; tot=0
    for K in range(1,d+1):
        for B in itertools.combinations(range(d),K):
            A=[i for i in range(d) if i not in B]
            Y=np.array(list(itertools.product([-1,1],repeat=K)))  # free values, bit order: B[0] is most significant
            for rho in itertools.product([-1,1],repeat=len(A)):
                X=np.zeros((len(Y),d)); X[:,list(B)]=Y
                if A: X[:,A]=rho
                S=(np.cumprod(X,axis=1)*w).sum(1)
                assert (S!=0).all()
                g=np.sign(S)
                c=fwht(g)
                tot+=1
                nz=np.nonzero(np.abs(c)>1e-9)[0]
                if len(nz)==1 and abs(abs(c[nz[0]])-1)<1e-9:
                    idx=nz[0]
                    # itertools.product with first coord most significant; fwht index bit (K-1-k) <-> coordinate k
                    T=[k for k in range(K) if (idx>>(K-1-k))&1]
                    if len(T)==0: continue
                    events+=1
                    j=len(T)
                    if T!=list(range(j)): viol+=1; continue
                    # coefficients c_0..c_K
                    a=np.ones(d)
                    pa=1; jt=[]
                    for t in range(d):
                        if t in A: pa*=rho[A.index(t)]
                        a[t]=pa; jt.append(sum(1 for b in B if b<=t))
                    cc=np.zeros(K+1)
                    for t in range(d): cc[jt[t]]+=w[t]*a[t]
                    if not abs(cc[j])>np.abs(cc).sum()-abs(cc[j]): viol+=1
    return tot,events,viol
for d in [5,7,9]:
    print("d",d,"(restrictions, parity events, violations)",run(d))
print("weighted d=7",run(7,[1,2,1.5,3,1,2.5,1.25]))
