import numpy as np, itertools
rng=np.random.default_rng(1)
d=8; r=3
X=np.array(list(itertools.product([-1,1],repeat=d)))
subsets=[U for k in range(d+1) for U in itertools.combinations(range(d),k)]
lam=np.sort(rng.random(d+1))[::-1]*np.exp(-np.arange(d+1))  # nonincreasing positive
chi=np.stack([np.prod(X[:,list(U)],axis=1) if U else np.ones(len(X)) for U in subsets],1)
deg=np.array([len(U) for U in subsets])
w=lam[deg]*(deg>r)
Q=(chi*w)@chi.T
f=np.prod(X,axis=1)
tau=w.sum()
print("tau",tau,"Q diag",Q[0,0])
print("E f f' Q =",(f@Q@f)/len(X)**2,"lambda_d",lam[d])
# Prop 4 deterministic check on random samples
worst=1e9
for _ in range(2000):
    n=rng.integers(1,60); idx=rng.integers(0,len(X),n)
    Qs=Q[np.ix_(idx,idx)]
    lm=np.linalg.eigvalsh(Qs)[-1]
    worst=min(worst,lm/max(n*lam[r+1],tau))
print("min lmax/max(n lam_{r+1},tau)",worst)
