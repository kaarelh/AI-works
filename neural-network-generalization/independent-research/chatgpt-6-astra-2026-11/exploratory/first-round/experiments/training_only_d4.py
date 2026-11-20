"""Exact-cone SOCP comparison on the existing 4-bit bad query order.
Numerical optimization, NOT a rational certificate or posterior sampler.
The cone list is read from the repository's already-verified complete enumeration.
"""
import json,time
from pathlib import Path
import numpy as np
import cvxpy as cp
ROOT=Path(__file__).resolve().parents[1]
REPO=Path(__file__).resolve().parents[6]
source=REPO/'neural-network-generalization/works-in-progress/online-mistakes/relu-fourbit-mistakes/verification/d4_certificate_input.npz'
a=np.load(source);X=a['X'].astype(float);D=a['D'].astype(float);J=len(D)
y=X[:,1]*X[:,2]*np.where(np.all(X[:,3:]==1,axis=1),1.,-1.)
order=[15,14,13,11,10,9,7,6,3,5,2,8,12,4,1,0]
start=time.time()
with (ROOT/'results'/'training_only_d4.jsonl').open('w',buffering=1) as f:
 for t,idx in enumerate(order):
  if t==0:
   row=dict(t=t,query=idx,cost=0.,score=0.,signed_score=0.,status='zero_prior_mode')
  else:
   ids=order[:t+1];Xs=X[ids];Ds=np.unique(D[:,ids],axis=0)
   Ds=Ds[Ds.sum(axis=1)>0];Js=len(Ds)
   U=cp.Variable((Js,5));V=cp.Variable((Js,5))
   pu=U@Xs.T;pv=V@Xs.T;z=cp.sum(cp.multiply(Ds,pu-pv),axis=0)
   norm=cp.sum(cp.norm(U,axis=1))+cp.sum(cp.norm(V,axis=1))
   cons=[cp.multiply(2*Ds-1,pu)>=0,cp.multiply(2*Ds-1,pv)>=0,
         cp.multiply(y[ids[:-1]],z[:-1])>=.5]
   opts=dict(solver='CLARABEL',tol_gap_abs=1e-8,tol_gap_rel=1e-8,tol_feas=1e-9,max_iter=300)
   prob=cp.Problem(cp.Minimize(norm),cons)
   value=prob.solve(**opts)
   if prob.status not in ('optimal','optimal_inaccurate') or z.value is None:
    raise RuntimeError((t,prob.status,value))
   base_z=z.value.copy();base_U=U.value.copy();base_V=V.value.copy()
   base_violation=max(float(np.max(c.violation())) for c in cons)
   ranges=[];statuses=[]
   for sign in [1.,-1.]:
    extreme=cp.Problem(cp.Minimize(sign*y[idx]*z[-1]),cons+[norm<=value+1e-5])
    try:
     obj=extreme.solve(**opts);ranges.append(float(sign*obj));statuses.append(extreme.status)
    except cp.error.SolverError:
     ranges.append(None);statuses.append('solver_failed')
   row=dict(t=t,query=idx,activation_patterns=Js,cost=float(value),score=float(base_z[-1]),signed_score=float(y[idx]*base_z[-1]),
            signed_min=ranges[0],signed_max=ranges[1],range_statuses=statuses,objective_tolerance=1e-5,
            constraint_violation=base_violation,status=prob.status,elapsed_s=time.time()-start)
   np.savez_compressed(ROOT/'results'/f'training_only_d4_prefix{t}.npz',U=base_U,V=base_V,X=Xs,D=Ds,z=base_z,y=y[ids])
  f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
