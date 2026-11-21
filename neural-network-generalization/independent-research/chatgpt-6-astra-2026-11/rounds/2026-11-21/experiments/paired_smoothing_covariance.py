"""Coupled critical ReLU/softplus moment differences in six input bits.

Conditional Gaussian readouts are integrated analytically. A beta-scaled
minimum-coordinate proposal targets the tail responsible for the covariance
correction. Output uncertainty is a block Monte Carlo estimate, not a bound.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp
import full_label_independent as f
from critical_moment_importance import walsh,DEGREES,BASE_HAT

def batch(rng,count,beta,scale,bias_scale=4.):
 t=scale*np.expm1(-np.log(rng.random(count)))
 excess=np.zeros((count,f.R));small=t<1
 if small.any():
  tt=t[small,None]
  excess[small,1:]=-ndtri_exp(log_ndtr(-tt)+np.log(rng.random((small.sum(),f.R-1))))-tt
 large=np.flatnonzero(~small)
 if len(large):
  rates=np.repeat(t[large],f.R-1);vals=np.empty(len(rates));pending=np.arange(len(rates))
  while len(pending):
   u=rng.exponential(size=len(pending))/rates[pending]
   ok=np.log(rng.random(len(pending)))<-u*u/2
   vals[pending[ok]]=u[ok];pending=pending[~ok]
  excess[large,1:]=vals.reshape(-1,f.R-1)
 bscale=bias_scale/(1+t);bias=rng.laplace(size=count)*bscale
 perturb=bias[:,None]+excess@f.X.T;layer=f.X.sum(axis=1)
 cone=np.max(abs(perturb),axis=1)<2*t
 hat=np.empty((count,f.M));gc=np.empty(count)
 if cone.any():
  psi=np.where(layer>0,perturb[cone],np.where(layer==0,np.maximum(perturb[cone],0),0))
  ph=walsh(psi);hat[cone]=t[cone,None]*BASE_HAT+ph;gc[cone]=ph[:,-1]
 if (~cone).any():hat[~cone]=walsh(np.maximum(t[~cone,None]*layer+perturb[~cone],0))
 G=hat[:,-1];lt=np.empty(count)
 lt[cone]=math.sqrt(f.R)*t[cone]*gc[cone]/f.RHO+.5*(gc[cone]/f.RHO)**2
 lt[~cone]=.5*((G[~cone]/f.RHO)**2-f.R*t[~cone]**2)
 pre=t[:,None]*layer+perturb
 dhat=walsh(np.logaddexp(0,-beta*abs(pre))/beta);dG=dhat[:,-1]
 dlt=(G*dG+.5*dG*dG)/f.RHO**2
 loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
 lqt=-math.log(scale)-2*np.log1p(t/scale);lqb=-np.log(2*bscale)-abs(bias)/bscale
 lw=math.log(f.R)+f.R*math.log(f.HALF)+(f.R-1)*loga+lt-bias*bias/2-.5*math.log(2*math.pi)-lqt-lqb
 wr=np.exp(lw);ew=np.exp(dlt);dw=-np.expm1(dlt)
 a2=1+(G/f.RHO)**2;da2=(2*G*dG+dG*dG)/f.RHO**2
 h2=np.column_stack([np.mean(hat[:,DEGREES==j]**2,axis=1) for j in range(f.R+1)])
 dh2=np.column_stack([np.mean((2*hat*dhat+dhat*dhat)[:,DEGREES==j],axis=1) for j in range(f.R+1)])
 spec=f.M*h2*a2[:,None]
 dspec=f.M*(dh2*a2[:,None]+(h2+dh2)*da2[:,None])
 diff=wr[:,None]*(dw[:,None]*spec-ew[:,None]*dspec)
 dmean=wr*(dw*G*G-ew*(2*G*dG+dG*dG))/f.RHO
 rows=np.column_stack([wr*dw,dmean,diff])
 return beta*rows.mean(axis=0)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--beta',type=float,required=True);ap.add_argument('--blocks',type=int,default=1200)
 ap.add_argument('--batch',type=int,default=16384);ap.add_argument('--seed',type=int,required=True)
 ap.add_argument('--scale-factor',type=float,default=1.);ap.add_argument('--output',type=Path,required=True)
 args=ap.parse_args();rng=np.random.default_rng(args.seed);vals=[];start=time.monotonic()
 ref=json.loads((f.ROOT/'results/critical_moments_reference.json').read_text());Mstar=ref['Mstar']
 for i in range(args.blocks):
  vals.append(batch(rng,args.batch,args.beta,args.scale_factor*args.beta))
  if (i+1)%50==0 or i+1==args.blocks:
   arr=np.array(vals);mu=arr.mean(0);se=arr.std(0,ddof=1)/math.sqrt(len(arr))
   result=dict(status='complete' if i+1==args.blocks else 'in_progress',beta=args.beta,
       samples=len(vals)*args.batch,blocks=len(vals),batch=args.batch,seed=args.seed,scale_factor=args.scale_factor,
       seconds=time.monotonic()-start,beta_normalizer_difference=float(mu[0]),beta_mean_numerator_difference=float(mu[1]),
       scaled_unnormalized_spectral_differences=mu[2:].tolist(),normalized_leading_differences=(mu[2:]/Mstar).tolist(),
       block_standard_errors=se.tolist(),Mstar_input=Mstar,
       scope='Paired floating-point critical moment differences. Normalized leading differences divide by an estimated ReLU normalizer but omit finite-beta normalization/centering corrections; those vanish in the proved beta-scaled limit. Not an interval certificate.')
   args.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
 np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(vals))
if __name__=='__main__':main()
