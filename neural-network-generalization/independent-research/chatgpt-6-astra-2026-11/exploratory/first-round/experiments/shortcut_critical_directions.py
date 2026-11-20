"""Enumerate candidate spherical local maxima of the frozen neuron utility.
The finite polyhedral enumeration is numerical; witnesses are not yet exact.
All adjacent activation cones are tested by linear programming for a
positive directional derivative, including nondifferentiable faces.
"""
import itertools,json,math,time,argparse
from pathlib import Path
import numpy as np
from scipy.optimize import linprog
ROOT=Path(__file__).resolve().parents[1]
cube=np.array(list(itertools.product([-1.,1.],repeat=3)));y=cube[:,1]*cube[:,2]
def setup(L,bias):
 X=cube.copy();X[:,0]*=L
 if bias:X=np.c_[X,np.ones(8)]
 dim=X.shape[1];patterns=[]
 for mask in itertools.product([0.,1.],repeat=8):
  mask=np.array(mask);A=(2*mask-1)[:,None]*X
  fit=linprog(np.zeros(dim),A_ub=-A,b_ub=-np.ones(8),bounds=[(None,None)]*dim,method='highs')
  if fit.success:patterns.append(mask)
 patterns=np.array(patterns);projections=[]
 for k in range(dim):
  for inds in itertools.combinations(range(8),k):
   if not k:P=np.eye(dim)
   else:
    T=X[list(inds)]
    if np.linalg.matrix_rank(T)<k:continue
    P=np.eye(dim)-T.T@np.linalg.solve(T@T.T,T)
   projections.append(P)
 return X,patterns,np.array(projections)
def maxima(L,rho,bias,cache):
 X,patterns,projections=cache;dim=X.shape[1]
 P=(1+rho*cube[:,0]*y)/8;g=(patterns*(P*y))@X
 candidates={}
 for i,mask in enumerate(patterns):
  qs=projections@g[i];norms=np.linalg.norm(qs,axis=1)
  vals=qs@X.T
  valid=(norms>1e-9)&np.all(vals*(2*mask-1)>=-1e-9,axis=1)
  for q in qs[valid]:
   key=tuple(np.round(q,9));candidates[key]=q
 results=[]
 for q in candidates.values():
  norm=np.linalg.norm(q);v=q/norm;act=X@q
  adjacent=np.flatnonzero(np.all((2*patterns-1)*act>=-1e-8,axis=1))
  zeros=np.flatnonzero(np.abs(act)<1e-8);worst=0.
  for j in adjacent:
   AA=(2*patterns[j,zeros]-1)[:,None]*X[zeros]
   test=linprog(-(g[j]-q),A_ub=-AA if len(zeros) else None,
    b_ub=np.zeros(len(zeros)) if len(zeros) else None,A_eq=q[None,:],b_eq=[0],bounds=[(-1,1)]*dim,method='highs')
   assert test.success
   worst=max(worst,-test.fun)
   if worst>1e-7:break
  if worst<=1e-7:
   results.append(dict(direction=v.tolist(),utility=float(norm),zero_points=zeros.tolist(),
                       adjacent_cones=len(adjacent),maximum_directional_derivative=float(worst)))
 return dict(L=L,rho=rho,bias=bias,activation_cones=len(patterns),candidates=len(candidates),local_maxima=results)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--Ls',default='1,2,3,10');ap.add_argument('--rhos',default='.5,.7,.8,.9,.99');args=ap.parse_args()
 with (ROOT/'results'/'shortcut_critical_directions.jsonl').open('w',buffering=1) as f:
  for bias in [False,True]:
   for L in map(float,args.Ls.split(',')):
    cache=setup(L,bias)
    for rho in map(float,args.rhos.split(',')):
     row=maxima(L,rho,bias,cache);f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
