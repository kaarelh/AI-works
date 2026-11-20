"""Importance integration of a ReLU parity neuron's critical exponential tilt.

The proposal deliberately samples narrow tubes around all maximizing rays,
with a Pareto(1) axial radius. This gives finite-variance estimates of the
critical first moment despite its infinite variance under the tilted law.
These estimates are numerical, not interval-certified quadrature.
"""
import argparse,itertools,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import logsumexp,gammaln
ROOT=Path(__file__).resolve().parents[1]
def run(d=4,r=4,n=1000000,b=1.,seed=0,beta=None):
 assert r%2==0 and 2<=r<=d
 rng=np.random.default_rng(seed);D=d+1
 X=np.c_[np.ones(2**d),np.array(list(itertools.product([-1.,1.],repeat=d)))]
 chi=np.prod(X[:,1:r+1],axis=1)
 rays=np.zeros((2**r,D));rays[:,1:r+1]=np.array(list(itertools.product([-1.,1.],repeat=r)))/math.sqrt(r)
 rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r));tc=1/rho
 VX=rays@X.T;VX[np.abs(VX)<1e-12]=0
 kappa=np.maximum(VX,0)@chi/(2**d)
 lognorm=math.log(2)+(d/2)*math.log(math.pi)-gammaln(d/2)+gammaln(d)+d*math.log(b)
 sums=np.zeros(4);squares=np.zeros(4);count=0;max_weight=0.;start=time.time()
 for offset in range(0,n,32768):
  m=min(32768,n-offset);ii=rng.integers(len(rays),size=m);v=rays[ii]
  rad=rng.random(m);rad=rad/(1-rad)
  z=rng.normal(size=(m,D));z-=np.sum(z*v,axis=1)[:,None]*v
  z/=np.linalg.norm(z,axis=1)[:,None]
  zr=rng.gamma(d,b,size=m)/(1+rad);z*=zr[:,None]
  u=rad[:,None]*v+z;ZX=z@X.T;UX=rad[:,None]*VX[ii]+ZX
  G=np.maximum(UX,0)@chi/(2**d)
  smooth=np.zeros(m) if beta is None else (np.log1p(np.exp(-beta*np.abs(UX)))@chi)/(beta*2**d)
  G+=smooth
  stable=np.all((VX[ii]==0)|(UX*VX[ii]>0),axis=1)
  delta=(np.where(VX[ii]>0,ZX,0)+np.where(VX[ii]==0,np.maximum(ZX,0),0))@chi/(2**d)+smooth
  stable &= (np.sign(G)==np.sign(kappa[ii]))
  deficit=np.sum(u*u,axis=1)-tc*tc*G*G
  # Avoid cancellation of O(radius^2) terms in the ray tubes.
  gap=-np.sign(kappa[ii])*delta/rho
  deficit[stable]=gap[stable]*(2*rad[stable]-gap[stable])+zr[stable]**2
  assert deficit.min()>-1e-7,deficit.min()
  proj=u@rays.T;dist2=np.maximum(0,np.sum(u*u,axis=1)[:,None]-proj*proj)
  dist2[np.arange(m),ii]=zr*zr;proj[np.arange(m),ii]=rad
  lp=np.where(proj>=0,(d-2)*np.log1p(np.maximum(proj,0))-(1+proj)*np.sqrt(dist2)/b-lognorm,-np.inf)
  logq=logsumexp(lp,axis=1)-math.log(len(rays))
  logtarget=-D/2*math.log(2*math.pi)-deficit/2
  weights=np.exp(logtarget-logq);values=np.c_[weights,tc*G*G*weights,
       weights*(rad>10),tc*G*G*weights*(rad>10)]
  sums+=values.sum(axis=0);squares+=(values*values).sum(axis=0);count+=m
  max_weight=max(max_weight,float(weights.max()))
 means=sums/count;se=np.sqrt(np.maximum(0,squares/count-means*means)/count)
 return dict(d=d,r=r,n=n,proposal_scale=b,seed=seed,beta=beta,rho=rho,critical_t=tc,
   M=float(means[0]),M_se=float(se[0]),M_prime=float(means[1]),M_prime_se=float(se[1]),
   critical_mean=float(means[1]/means[0]),M_tail10=float(means[2]),M_prime_tail10=float(means[3]),
   maximum_weight=max_weight,seconds=time.time()-start)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--n',type=int,default=1000000)
 ap.add_argument('--d',type=int,default=4);ap.add_argument('--r',type=int,default=4)
 ap.add_argument('--scales',default='.5,1,2');ap.add_argument('--seeds',type=int,default=4)
 ap.add_argument('--beta',type=float,default=None)
 args=ap.parse_args()
 label='relu' if args.beta is None else f'softplus_beta{args.beta:g}'
 with (ROOT/'results'/f'{label}_critical_tilt_d{args.d}_r{args.r}.jsonl').open('a',buffering=1) as f:
  for b in map(float,args.scales.split(',')):
   for seed in range(args.seeds):
    row=run(args.d,args.r,args.n,b,seed,args.beta);f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
