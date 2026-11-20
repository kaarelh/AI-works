"""Truncated-Gaussian SMC for Boolean ReLU and product kernels.

Numerical only. Rao--Blackwellized incremental probabilities and exact
elliptical-slice invariant moves; particle and sweep replication needed.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import log_ndtr,ndtri_exp,logsumexp
from scipy.linalg import cholesky,solve_triangular
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--d',type=int,default=4);ap.add_argument('--bias2',type=float,default=1.)
ap.add_argument('--particles',type=int,default=4096);ap.add_argument('--sweeps',type=int,default=64);ap.add_argument('--seed',type=int,default=0)
ap.add_argument('--order',choices=['lex','random','gray'],default='lex');args=ap.parse_args();M=2**args.d;P=args.particles
rng=np.random.default_rng(args.seed);ids=np.arange(M)
if args.order=='random':rng.shuffle(ids)
if args.order=='gray':ids=ids^(ids>>1)
ham=np.array([i.bit_count() for i in range(M)]);H=ham[ids[:,None]^ids[None,:]];sign=(-1.)**ham[ids]
c=np.clip((args.d-2*H+args.bias2)/(args.d+args.bias2),-1,1);K=(np.sqrt(1-c*c)+(np.pi-np.arccos(c))*c)/np.pi;K*=sign[:,None]*sign[None,:]
L=cholesky(K,lower=True);T=solve_triangular(L,np.eye(M),lower=True);V=np.zeros((P,0));logZ=0.;start=time.time()
dest=ROOT/'results'/'relu_gp';dest.mkdir(exist_ok=True);path=dest/f'd{args.d}_b{args.bias2:g}_{args.order}_p{P}_s{args.sweeps}_seed{args.seed}.jsonl'
with path.open('w',buffering=1) as f:
 for j in range(M):
  mu=-(V@T[j,:j])/T[j,j];sd=1/T[j,j];logp=log_ndtr(mu/sd);loginc=float(logsumexp(logp)-math.log(P));logZ+=loginc
  weights=np.exp(logp-logsumexp(logp));ess=1/float(np.sum(weights**2));c=np.cumsum(weights);c[-1]=1.;idx=np.searchsorted(c,(rng.random()+np.arange(P))/P)
  V=V[idx].copy();mu=mu[idx];new=mu-sd*ndtri_exp(np.log(rng.random(P))+log_ndtr(mu/sd));V=np.c_[V,new];assert np.all(V>0)
  for sweep in range(args.sweeps):
   noise=rng.normal(size=V.shape)@L[:j+1,:j+1].T;phase=np.arctan2(noise,V);low=phase.max(axis=1)-np.pi/2;high=phase.min(axis=1)+np.pi/2;angle=rng.uniform(low,high)
   V=V*np.cos(angle)[:,None]+noise*np.sin(angle)[:,None];assert V.min()>-1e-10;V=np.maximum(V,np.finfo(float).tiny)
  row=dict(d=args.d,bias2=args.bias2,order=args.order,particles=P,sweeps=args.sweeps,seed=args.seed,query=j,input=int(ids[j]),correct_probability=math.exp(loginc),log_evidence=logZ,increment_ess=ess,seconds=time.time()-start)
  f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
np.savez_compressed(path.with_suffix('.npz'),V=V,L=L,T=T,ids=ids)
