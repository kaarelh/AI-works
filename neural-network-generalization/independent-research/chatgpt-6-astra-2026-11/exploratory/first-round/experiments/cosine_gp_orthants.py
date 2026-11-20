"""SMC orthant probabilities for the exact product-kernel Gaussian limit.

Rao--Blackwellized increments use the proven triangular autoregression.
Direct feasible-angle elliptical slice moves preserve truncated Gaussian
prefix laws. Replicate and mutation-budget checks assess numerical error.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import log_ndtr,ndtri_exp,logsumexp
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--d',type=int,default=4)
ap.add_argument('--r',type=float,default=.5);ap.add_argument('--particles',type=int,default=8192)
ap.add_argument('--sweeps',type=int,default=64);ap.add_argument('--seed',type=int,default=0)
args=ap.parse_args();M=2**args.d;P=args.particles;r=args.r;q=math.sqrt(1-r*r)
L=np.array([[1.]]);T=np.array([[1.]])
for i in range(args.d):
 L=np.kron(L,np.array([[1.,0.],[-r,q]]));T=np.kron(T,np.array([[1.,0.],[r/q,1/q]]))
assert np.max(np.abs(T@L-np.eye(M)))<1e-8
rng=np.random.default_rng(args.seed);V=np.zeros((P,0));logZ=0.;start=time.time()
dest=ROOT/'results'/'cosine_gp';dest.mkdir(exist_ok=True)
path=dest/f'd{args.d}_r{r:g}_p{P}_s{args.sweeps}_seed{args.seed}.jsonl'
with path.open('w',buffering=1) as f:
 for j in range(M):
  mu=-(V@T[j,:j])/T[j,j];sd=1/T[j,j]
  logp=log_ndtr(mu/sd);loginc=float(logsumexp(logp)-math.log(P));logZ+=loginc
  weights=np.exp(logp-logsumexp(logp));ess=1/float(np.sum(weights**2))
  c=np.cumsum(weights);c[-1]=1.;ids=np.searchsorted(c,(rng.random()+np.arange(P))/P)
  V=V[ids].copy();mu=mu[ids]
  new=mu-sd*ndtri_exp(np.log(rng.random(P))+log_ndtr(mu/sd))
  V=np.c_[V,new];assert np.all(V>0)
  for sweep in range(args.sweeps):
   noise=rng.normal(size=V.shape)@L[:j+1,:j+1].T
   phase=np.arctan2(noise,V);low=phase.max(axis=1)-np.pi/2;high=phase.min(axis=1)+np.pi/2
   angle=rng.uniform(low,high)
   V=V*np.cos(angle)[:,None]+noise*np.sin(angle)[:,None]
   assert np.all(V>=-1e-12),float(V.min())
   V=np.maximum(V,np.finfo(float).tiny)
  row=dict(d=args.d,r=r,particles=P,sweeps=args.sweeps,seed=args.seed,query=j,
       correct_probability=math.exp(loginc),log_evidence=logZ,increment_ess=ess,
       first_coordinate_mean=float(V[:,0].mean()),mean_square_radius=float(np.mean(np.sum(V*V,axis=1))),seconds=time.time()-start)
  f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
np.savez_compressed(path.with_suffix('.npz'),V=V,L=L,T=T)
