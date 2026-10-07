# Prop 3.10: EU-coherence (exists u: u.(p-q)>0 strict rows, u.(r-s)>=0 weak rows) vs Motzkin certificate.
import numpy as np, random
from scipy.optimize import linprog
random.seed(5); rng=np.random.default_rng(5)
def lot(n):
    x=rng.integers(0,3,size=n).astype(float)
    if x.sum()==0: x[0]=1
    return x/x.sum()
mism=0; tot=0; inc=0
for t in range(3000):
    n=random.randint(2,3); a=random.randint(1,4); b=random.randint(0,3)
    A=np.array([lot(n)-lot(n) for _ in range(a)]); B=np.array([lot(n)-lot(n) for _ in range(b)]) if b else np.zeros((0,n))
    # coherence: by homogeneity, exists u with A u >= 1, B u >= 0
    Aub=-np.vstack([A,B]); bub=-np.concatenate([np.ones(a),np.zeros(b)])
    r=linprog(np.zeros(n),A_ub=Aub,b_ub=bub,bounds=[(None,None)]*n,method='highs')
    coh=(r.status==0)
    # certificate: lam>=0, kap>=0, sum lam =1, A^T lam + B^T kap = 0
    Aeq=np.vstack([np.hstack([A.T,B.T]), np.concatenate([np.ones(a),np.zeros(b)])[None,:]])
    beq=np.concatenate([np.zeros(n),[1]])
    r2=linprog(np.zeros(a+b),A_eq=Aeq,b_eq=beq,bounds=[(0,None)]*(a+b),method='highs')
    cert=(r2.status==0)
    tot+=1; inc+= (not coh)
    if coh==cert: mism+=1
print("trials",tot,"incoherent",inc,"cases where coherent AND certificate both/neither (should be 0):",mism)
