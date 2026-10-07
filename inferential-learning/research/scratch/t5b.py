import numpy as np, itertools
from math import log2
from scipy.optimize import minimize
rng=np.random.default_rng(0)
# Thm 2.1(i): minimax over product h vs max_Q sum H(Q_x); class without uniform-marginal Q
F=[('a','a'),('a','b'),('b','a'),('c','a')]  # values at x1,x2
vals=[sorted(set(f[i] for f in F)) for i in range(2)]
def negHQ(q):
    q=np.abs(q); q=q/q.sum(); tot=0
    for i in range(2):
        for v in vals[i]:
            m=sum(q[k] for k,f in enumerate(F) if f[i]==v)
            if m>0: tot-=m*log2(m)
    return -tot
best=min((minimize(negHQ,rng.random(4),method='Nelder-Mead',options={'xatol':1e-10,'fatol':1e-12,'maxiter':20000}) for _ in range(30)),key=lambda r:r.fun)
print("max_Q sum H(Q_x) =",-best.fun," vs sum log|F(x)| =",log2(3)+1)
# minimax over product h by grid / optimization
def worst(hp):
    # h at x1: distribution over a,b,c ; at x2 over a,b
    p1=np.abs(hp[:3]);p1/=p1.sum(); p2=np.abs(hp[3:]);p2/=p2.sum()
    d1=dict(zip(['a','b','c'],p1)); d2=dict(zip(['a','b'],p2))
    return max(-log2(d1[f[0]])-log2(d2[f[1]]) for f in F)
bm=min((minimize(worst,rng.random(5)+0.1,method='Nelder-Mead',options={'xatol':1e-10,'fatol':1e-12,'maxiter':40000}) for _ in range(50)),key=lambda r:r.fun)
print("min_h max_f loss ~",bm.fun)
# Prop 2.6 telescoping identity with history-dependent personas
T=3; K=6
w=rng.dirichlet(np.ones(T))*0.9
def nu(th,y,hist):  # arbitrary history-dependent persona predictive over {0,1,2}
    s=(th*7+len(hist)*3+sum(hist))%5+1
    p=np.array([s,1+th,2+len(hist)%3],float); p/=p.sum(); return p[y]
for trial in range(5):
    ys=list(rng.integers(0,3,K)); tot=0; hist=[]
    for y in ys:
        W=np.array([w[t]*np.prod([nu(t,hist[j],hist[:j]) for j in range(len(hist))]) for t in range(T)])
        pred=sum(W[t]*nu(t,y,hist) for t in range(T))/W.sum()
        tot+=-log2(pred); hist.append(y)
    bound=min(log2(1/w[t])+sum(-log2(nu(t,ys[j],ys[:j])) for j in range(K)) for t in range(T))
    print(f"block loss {tot:.4f} <= bound {bound:.4f}: {tot<=bound+1e-12}")
