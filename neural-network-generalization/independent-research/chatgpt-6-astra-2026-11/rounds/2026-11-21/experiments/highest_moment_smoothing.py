"""Independent checks of the singular highest finite critical output moment.

Uses two different representations: a positive corner integral for the
limiting coefficient, or coupled full critical ReLU/softplus integrands.
All numbers are non-interval Monte Carlo estimates. Critical normalizers
are not divided out: the recorded observable is the unnormalized parity
moment, whose beta-scaled limit is M*rho**k times the corner integral.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.linalg import null_space
from scipy.special import erfcx,log_ndtr,ndtri_exp
ROOT=Path(__file__).resolve().parents[1]

def geometry(r):
 M=2**r;k=(r-2)//2;rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r))
 X=2*((np.arange(M)[:,None]>>np.arange(r))&1)-1;chi=X.prod(1)
 T=np.zeros((r+1,r));T[0,0]=1;T[1:,1:]=null_space(np.ones((1,r)))
 zero=X[X.sum(1)==0];rows=np.column_stack([np.ones(len(zero)),zero])@T
 return r,M,k,rho,X,chi,rows

def limit_batch(rng,n,g,shape=.5):
 r,M,k,rho,X,chi,rows=g
 direction=rng.normal(size=(n,r));direction/=np.linalg.norm(direction,axis=1)[:,None]
 lines=abs(direction@rows.T);H=lines.sum(1)/(2*rho*M)
 radius=np.expm1(-np.log(rng.random(n))/shape)
 delta=np.logaddexp(0,-radius[:,None]*lines).sum(1)/(rho*M)
 value=H**(-(r-1))*(-np.expm1(-(r-1)*np.log1p(delta/(radius*H))))
 density=shape*(1+radius)**(-shape-1)
 sphere=2*math.pi**(r/2)/math.gamma(r/2)
 pref=M*rho**k*(2*math.pi)**(-(r+1)/2)*math.gamma(r-1)*sphere
 return float(np.mean(value/density))*pref

def paired_batch(rng,n,g,beta):
 r,M,k,rho,X,chi,rows=g;t=beta*np.expm1(-np.log(rng.random(n)));e=np.zeros((n,r));small=t<1
 if small.any():
  tt=t[small,None];e[small,1:]=-ndtri_exp(log_ndtr(-tt)+np.log(rng.random((small.sum(),r-1))))-tt
 ix=np.flatnonzero(~small)
 if len(ix):
  rates=np.repeat(t[ix],r-1);pending=np.arange(len(rates));v=np.empty(len(rates))
  while len(pending):
   u=rng.exponential(size=len(pending))/rates[pending];ok=np.log(rng.random(len(pending)))<-u*u/2
   v[pending[ok]]=u[ok];pending=pending[~ok]
  e[ix,1:]=v.reshape(-1,r-1)
 bscale=4/(1+t);bias=rng.laplace(size=n)*bscale;pert=bias[:,None]+e@X.T;layer=X.sum(1)
 cone=np.max(abs(pert),axis=1)<2*t;G=np.empty(n);lt=np.empty(n);sign=(-1)**(r//2+1)
 if cone.any():
  psi=np.where(layer>0,pert[cone],np.where(layer==0,np.maximum(pert[cone],0),0));gc=psi@chi/M
  G[cone]=sign*math.sqrt(r)*rho*t[cone]+gc
  lt[cone]=sign*math.sqrt(r)*t[cone]*gc/rho+.5*(gc/rho)**2
 if (~cone).any():
  G[~cone]=np.maximum(t[~cone,None]*layer+pert[~cone],0)@chi/M
  lt[~cone]=.5*((G[~cone]/rho)**2-r*t[~cone]**2)
 pre=t[:,None]*layer+pert;dG=(np.logaddexp(0,-beta*abs(pre))/beta)@chi/M
 v=G*G;dv=2*G*dG+dG*dG;dlt=dv/(2*rho*rho)
 moment=np.zeros(n);increment=np.zeros(n)
 for j in range(k//2+1):
  power=k-j;coef=math.factorial(k)/(2**j*math.factorial(j)*math.factorial(k-2*j)*rho**(k-2*j))
  moment+=coef*v**power
  increment+=coef*sum(math.comb(power,m)*v**(power-m)*dv**m for m in range(1,power+1))
 loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
 logqt=-math.log(beta)-2*np.log1p(t/beta);logqb=-np.log(2*bscale)-abs(bias)/bscale
 lw=math.log(r)+r*math.log(math.sqrt(2/math.pi))+(r-1)*loga+lt-bias*bias/2-.5*math.log(2*math.pi)-logqt-logqb
 return float(np.mean(np.exp(lw)*(-np.expm1(dlt)*moment-np.exp(dlt)*increment)))*beta

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--dimension',type=int,default=8);ap.add_argument('--mode',choices=['limit','paired'],required=True)
 ap.add_argument('--beta',type=float,default=64.);ap.add_argument('--blocks',type=int,default=2400);ap.add_argument('--batch',type=int,default=8192)
 ap.add_argument('--seed',type=int,required=True);ap.add_argument('--output',type=Path,required=True);args=ap.parse_args()
 assert args.dimension>=6 and args.dimension%2==0;g=geometry(args.dimension);rng=np.random.default_rng(args.seed);values=[];start=time.monotonic()
 for i in range(args.blocks):
  values.append(limit_batch(rng,args.batch,g) if args.mode=='limit' else paired_batch(rng,args.batch,g,args.beta))
  if (i+1)%100==0 or i+1==args.blocks:
   result=dict(status='complete' if i+1==args.blocks else 'in_progress',dimension=args.dimension,moment_order=g[2],mode=args.mode,
       beta=args.beta if args.mode=='paired' else None,samples=len(values)*args.batch,seed=args.seed,seconds=time.monotonic()-start,
       unnormalized_parity_moment_correction=float(np.mean(values)),block_standard_error=float(np.std(values,ddof=1)/math.sqrt(len(values))),
       scope='Non-interval Monte Carlo for the unnormalized critical parity moment. Limit and paired integrands are distinct; no posterior sampling or finite-width claim.')
   args.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
 np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(values))
if __name__=='__main__':main()
