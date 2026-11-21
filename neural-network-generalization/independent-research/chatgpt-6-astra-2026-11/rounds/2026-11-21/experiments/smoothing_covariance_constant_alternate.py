"""Independent positive-integral representation of the covariance coefficient."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,time
import numpy as np
import full_label_independent as f
rng=np.random.default_rng(2026112267);values=[];start=time.monotonic();batch=16384;blocks=2400;shape=.5
Mstar=json.loads((f.ROOT/'results/critical_moments_reference.json').read_text())['Mstar']
pref=120*math.pi**3/(2*math.pi)**3.5/Mstar
for block in range(blocks):
 u=rng.normal(size=(batch,f.R));u/=np.linalg.norm(u,axis=1)[:,None]
 line=abs(u@f.TRANSVERSE_ROWS.T);H=line.sum(axis=1)/(2*f.RHO*f.M)
 radius=rng.gamma(f.R,size=batch)/H
 zeta=np.expm1(-np.log(rng.random(batch))/shape)
 delta=np.logaddexp(0,-zeta[:,None]*radius[:,None]*line).sum(axis=1)/(zeta*f.RHO*f.M)
 lp=math.log(shape)-(1+shape)*np.log1p(zeta)
 val=H**-6*(-np.expm1(-delta))*np.exp(-lp)
 values.append(float(val.mean())*pref)
 if (block+1)%100==0 or block+1==blocks:
  out=dict(status='complete' if block+1==blocks else 'in_progress',samples=(block+1)*batch,
      seconds=time.monotonic()-start,correction_constant=float(np.mean(values)),
      block_standard_error=float(np.std(values,ddof=1)/math.sqrt(len(values))),
      scope='Independent positive integral: ReLU radial Gamma marks and Lomax crossover scale. Non-interval Monte Carlo; uses estimated critical normalizer.')
  (f.ROOT/'results/smoothing_covariance_constant_alternate.json').write_text(json.dumps(out,indent=2)+'\n')
  print(json.dumps(out),flush=True)
