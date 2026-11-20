"""Test whether the certified four-bit phenomenon extends to plain parity.

Uses the repository's complete affine activation-cone list. Numerical SOCP
costs only; strict gaps require a subsequent integer certificate.
"""
import itertools,json,time,argparse
from pathlib import Path
import numpy as np
import cvxpy as cp
ROOT=Path(__file__).resolve().parents[1]
REPO=Path(__file__).resolve().parents[6]
SRC=REPO/'neural-network-generalization/works-in-progress/online-mistakes/relu-fourbit-mistakes/verification/d4_certificate_input.npz'
data=np.load(SRC);X=data['X'].astype(float);D=data['D'].astype(float)
ap=argparse.ArgumentParser();ap.add_argument('--target',default='parity');ap.add_argument('--order',default='lex');ap.add_argument('--fixed-coordinates',type=int,default=0)
args=ap.parse_args()
assert args.fixed_coordinates>=0
X[:,0]*=np.sqrt(1+args.fixed_coordinates)
if args.target=='parity':y=np.prod(X[:,1:],axis=1)
elif args.target=='majority':y=np.where(X[:,1:].sum(axis=1)>=0,1.,-1.)
elif args.target=='exacttwo':y=np.where(X[:,1:].sum(axis=1)==0,1.,-1.)
else:raise ValueError(args.target)
if args.order=='lex':order=list(range(16))
elif args.order=='gray':order=[i^(i>>1) for i in range(16)]
elif args.order=='weight':order=sorted(range(16),key=lambda i:(int(i).bit_count(),i))
elif args.order=='fourbit':order=[15,14,13,11,10,9,7,6,3,5,2,8,1,12,4,0]
else:raise ValueError(args.order)
opts=dict(solver='CLARABEL',tol_gap_abs=1e-8,tol_gap_rel=1e-8,tol_feas=1e-9,max_iter=300)
start=time.time()
suffix=f'_fixed{args.fixed_coordinates}' if args.fixed_coordinates else ''
with (ROOT/'results'/f'd4_{args.target}_{args.order}_observed{suffix}.jsonl').open('w',buffering=1) as f:
 for t in range(1,16):
  ids=order[:t+1];Xs=X[ids];Ds=np.unique(D[:,ids],axis=0);Ds=Ds[Ds.sum(axis=1)>0];J=len(Ds)
  U=cp.Variable((J,5));V=cp.Variable((J,5));pu=U@Xs.T;pv=V@Xs.T
  z=cp.sum(cp.multiply(Ds,pu-pv),axis=0);norm=cp.sum(cp.norm(U,axis=1))+cp.sum(cp.norm(V,axis=1))
  cons=[cp.multiply(2*Ds-1,pu)>=0,cp.multiply(2*Ds-1,pv)>=0,cp.multiply(y[ids[:-1]],z[:-1])>=.5]
  base=cp.Problem(cp.Minimize(norm),cons);cost=base.solve(**opts);score=float(y[ids[-1]]*z.value[-1])
  correct=cp.Problem(cp.Minimize(norm),cons+[y[ids[-1]]*z[-1]>=0]);cc=correct.solve(**opts)
  wrong=cp.Problem(cp.Minimize(norm),cons+[y[ids[-1]]*z[-1]<=0]);wc=wrong.solve(**opts)
  row=dict(target=args.target,order=args.order,fixed_coordinates=args.fixed_coordinates,t=t,query=ids[-1],cost=cost,signed_score=score,
           correct_cost=cc,wrong_cost=wc,correct_gap=cc-cost,wrong_gap=wc-cost,seconds=time.time()-start)
  f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
