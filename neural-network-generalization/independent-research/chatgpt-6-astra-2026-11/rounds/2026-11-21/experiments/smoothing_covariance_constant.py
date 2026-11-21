"""Positive-integral Monte Carlo for the six-bit critical covariance correction.
This is not interval arithmetic or a certified numerical enclosure.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
import full_label_independent as f

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--blocks',type=int,default=1200);ap.add_argument('--batch',type=int,default=16384)
 ap.add_argument('--shape',type=float,default=.5);ap.add_argument('--seed',type=int,default=2026112264);ap.add_argument('--output',type=Path,required=True)
 args=ap.parse_args();rng=np.random.default_rng(args.seed);values=[];start=time.monotonic()
 base=json.loads((f.ROOT/'results/critical_moments_reference.json').read_text())
 Mstar=base['Mstar'];pref=24*math.pi**3/(2*math.pi)**3.5/Mstar
 for block in range(args.blocks):
  u=rng.normal(size=(args.batch,f.R));u/=np.linalg.norm(u,axis=1)[:,None]
  line=abs(u@f.TRANSVERSE_ROWS.T);H=line.sum(axis=1)/(2*f.RHO*f.M)
  radius=np.expm1(-np.log(rng.random(args.batch))/args.shape)
  delta=np.logaddexp(0,-radius[:,None]*line).sum(axis=1)/(f.RHO*f.M)
  val=H**-5*(-np.expm1(-5*np.log1p(delta/(radius*H))))
  logproposal=math.log(args.shape)-(1+args.shape)*np.log1p(radius)
  values.append(float(np.mean(val*np.exp(-logproposal)))*pref)
  if (block+1)%100==0 or block+1==args.blocks:
   mean=float(np.mean(values));se=float(np.std(values,ddof=1)/math.sqrt(len(values)))
   result=dict(status='complete' if block+1==args.blocks else 'in_progress',samples=len(values)*args.batch,
       blocks=len(values),batch=args.batch,shape=args.shape,seed=args.seed,seconds=time.monotonic()-start,
       correction_constant=mean,block_standard_error=se,Mstar_input=Mstar,
       walsh_covariance_correction_by_degree=(mean*np.array([600,512/3,24,0,8/3,0,24])).tolist(),
       scope='Non-interval positive-integral Monte Carlo for beta*(Sigma_ReLU-Sigma_softplus); critical normalizer input is estimated separately.')
   args.output.write_text(json.dumps(result,indent=2)+'\n')
   print(json.dumps(result),flush=True)
 np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(values))
if __name__=='__main__':main()
