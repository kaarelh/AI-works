"""Boundary-integral Monte Carlo for the critical normalizer's beta^-2 term.

The Gaussian readout is integrated analytically. Incoming absolute minima
use a full-support heavy-tailed proposal; signs are independent uniform.
No interval certification is claimed.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp,zeta
import full_label_independent as f

def batch(rng,n,shape=1.,include_mean=False,include_third=False):
 t=np.expm1(-np.log(rng.random(n))/shape);excess=np.zeros((n,f.R));small=t<1
 if small.any():
  tt=t[small,None];excess[small,1:]=-ndtri_exp(log_ndtr(-tt)+np.log(rng.random((small.sum(),f.R-1))))-tt
 ix=np.flatnonzero(~small)
 if len(ix):
  rates=np.repeat(t[ix],f.R-1);pending=np.arange(len(rates));v=np.empty(len(rates))
  while len(pending):
   u=rng.exponential(size=len(pending))/rates[pending];keep=np.log(rng.random(len(pending)))<-u*u/2
   v[pending[keep]]=u[keep];pending=pending[~keep]
  excess[ix,1:]=v.reshape(-1,f.R-1)
 signs=2*rng.integers(0,2,(n,f.R))-1;ss=signs.sum(1)
 layer=signs@f.X.T-ss[:,None]
 perturb=(excess*signs)@(f.X-1).T
 bias=-t*ss-np.sum(excess*signs,axis=1)
 balanced=(ss==0)&(np.max(abs(perturb),axis=1)<2*t)
 G=np.empty(n);lt=np.empty(n)
 if balanced.any():
  psi=np.where(layer[balanced]>0,perturb[balanced],np.where(layer[balanced]==0,np.maximum(perturb[balanced],0),0))
  gc=psi@f.CHI/f.M
  G[balanced]=-math.sqrt(f.R)*f.RHO*t[balanced]+gc
  lt[balanced]=-math.sqrt(f.R)*t[balanced]*gc/f.RHO+.5*(gc/f.RHO)**2
 if (~balanced).any():
  G[~balanced]=np.maximum(t[~balanced,None]*layer[~balanced]+perturb[~balanced],0)@f.CHI/f.M
  lt[~balanced]=.5*((G[~balanced]/f.RHO)**2-f.R*t[~balanced]**2)
 assert lt.max()<1e-7
 loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
 lqt=math.log(shape)-(shape+1)*np.log1p(t)
 lw=math.log(f.R)+f.R*math.log(f.HALF)+(f.R-1)*loga+lt-bias*bias/2-.5*math.log(2*math.pi)-lqt
 weights=np.exp(lw)
 normalizer=float(np.mean(weights*G))*math.pi**2/(6*f.RHO**2)
 if include_third:
  third=float(np.mean(weights*(1+(G/f.RHO)**2)))*zeta(3,1)/(f.M*f.RHO**2)
  return np.array([normalizer,third])
 if not include_mean:return normalizer
 mean=float(np.mean(weights*(2*G/f.RHO+(G/f.RHO)**3)))*math.pi**2/6
 return np.array([normalizer,mean])

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--blocks',type=int,default=2400);ap.add_argument('--batch',type=int,default=16384)
 ap.add_argument('--shape',type=float,default=1.);ap.add_argument('--seed',type=int,default=2026112271);ap.add_argument('--output',type=Path,required=True)
 args=ap.parse_args();rng=np.random.default_rng(args.seed);vals=[];start=time.monotonic()
 for i in range(args.blocks):
  vals.append(batch(rng,args.batch,args.shape))
  if (i+1)%100==0 or i+1==args.blocks:
   out=dict(status='complete' if i+1==args.blocks else 'in_progress',samples=len(vals)*args.batch,seed=args.seed,
       shape=args.shape,seconds=time.monotonic()-start,normalizer_beta2_coefficient=float(np.mean(vals)),
       block_standard_error=float(np.std(vals,ddof=1)/math.sqrt(len(vals))),
       scope='Non-interval boundary-integral Monte Carlo for M_beta-M_ReLU. The coefficient value is numerical; its strict negative sign is proved separately by the positive Fourier representation.')
   args.output.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
 np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(vals))
if __name__=='__main__':main()
