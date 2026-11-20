"""Finite-atom LP pilot, not a global ReLU-norm certificate.
Odd parity on a face of a higher-dimensional Boolean cube. The duplicated
bias metric is the minimum norm inherited from a fixed extra input bit.
"""
import os
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[key]='1'
from pathlib import Path
from itertools import product
import json,time
import numpy as np
from scipy.optimize import linprog
ROOT=Path(__file__).resolve().parents[1]
d=5;M=2**d
X=np.array(list(product([-1,1],repeat=d)),dtype=float)
y=np.prod(X,axis=1)
W=np.array(list(product(range(-2,3),repeat=d+1)),dtype=float)
W=W[np.any(W!=0,axis=1)]
norm=np.sqrt(W[:,0]**2/2+np.sum(W[:,1:]**2,axis=1))
H=np.maximum(W[:,0,None]+W[:,1:]@X.T,0).T/norm
# Unit features may repeat; duplicate removal only accelerates the finite LP.
H=np.unique(np.round(H,13),axis=1)
H=np.concatenate([H,-H],axis=1)
A=-y[:,None]*H;cost=np.ones(H.shape[1]);start=time.time()
path=ROOT/'results/odd_parity_prefix_pilot.jsonl'
with path.open('w',buffering=1) as f:
 for t in range(1,M):
  p=linprog(cost,A_ub=A[:t],b_ub=np.full(t,-.5),bounds=(0,None),method='highs')
  c=linprog(cost,A_ub=A[:t+1],b_ub=np.r_[np.full(t,-.5),0.],bounds=(0,None),method='highs')
  if not p.success or not c.success:raise RuntimeError((p.message,c.message))
  row=dict(dimension=d,observed=t,features=H.shape[1],cost=p.fun,signed_score=float(y[t]*(H[t]@p.x)),correct_cost=c.fun,gap=c.fun-p.fun,seconds=time.time()-start,status='finite-dictionary exploratory LP; not a global certificate')
  f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
