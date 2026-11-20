"""Independent critical-law draws by an exact rejection envelope.
No neural-posterior MCMC is used. Floating-point arithmetic is not certified.
The all-positive incoming orthant suffices for G^2 and energies by cube symmetry.
"""
import os
for key in ['OMP_NUM_THREADS','OPENBLAS_NUM_THREADS','VECLIB_MAXIMUM_THREADS','MKL_NUM_THREADS']:os.environ[key]='1'
import argparse,json,time,math
from pathlib import Path
import numpy as np
from scipy.special import ndtri_exp,log_ndtr
ROOT=Path(__file__).resolve().parents[1]
def run(d,n,seed,batch=4096):
 rng=np.random.default_rng(seed);c=math.sqrt(2/math.pi);rho=math.comb(d-2,(d-2)//2)/(2**(d-1)*math.sqrt(d))
 cube=1-2*((np.arange(2**d)[:,None]>>np.arange(d))&1);chi=np.prod(cube,axis=1)
 count=0;proposals=0;sumv=np.zeros(5);sumv2=np.zeros(5);start=time.time();chunks=[]
 while proposals<n:
  B=min(batch,n-proposals);t=np.expm1(-np.log(rng.random(B))/(d-2))/c
  lp=log_ndtr(-t);logA=.5*math.log(2*math.pi)+t*t/2+lp
  keep=np.log(rng.random(B))<(d-1)*(logA+np.log1p(c*t)+math.log(c))
  tt=t[keep];ll=lp[keep];bb=rng.standard_normal(len(tt));v=-ndtri_exp(ll[:,None]+np.log(rng.random((len(tt),d-1))))-tt[:,None]
  w=np.concatenate([tt[:,None],tt[:,None]+v],axis=1)
  G=np.maximum(w@cube.T+bb[:,None],0)@chi/(2**d)
  logacc=-.5*np.maximum(0,d*tt*tt-G*G/(rho*rho))
  final=np.log(rng.random(len(tt)))<logacc
  g=G[final];ww=w[final];b=bb[final]
  vals=np.column_stack([g*g/rho,1+g*g/rho**2,b*b+np.sum(ww*ww,axis=1),np.min(ww,axis=1),g*g])
  count+=len(vals);proposals+=B;sumv+=vals.sum(axis=0);sumv2+=(vals*vals).sum(axis=0)
  if proposals%(batch*128)==0 or proposals==n:
   mean=sumv/count;var=np.maximum(0,sumv2/count-mean*mean);acc=count/proposals
   row=dict(dimension=d,seed=seed,proposals=proposals,accepted=count,acceptance=acc,M_star=acc*d/(d-2),M_star_se=math.sqrt(acc*(1-acc)/proposals)*d/(d-2),rho=rho,mc=mean[0],mc_se=math.sqrt(var[0]/count),readout_energy=mean[1],incoming_energy=mean[2],imbalance=mean[2]-mean[1],mean_min_weight=mean[3],parity_kernel=mean[4],seconds=time.time()-start)
   print(json.dumps(row),flush=True)
 return row
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--dimension',type=int,default=6);p.add_argument('--proposals',type=int,default=10000000);p.add_argument('--seed',type=int,default=0);args=p.parse_args();run(args.dimension,args.proposals,args.seed)
