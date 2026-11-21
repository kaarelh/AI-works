"""Finite Gaussian calculation of the first logarithmic corner correction."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,time
import numpy as np
import full_label_independent as f
import softplus_corrected_proposal as s
rng=np.random.default_rng(2026112266);start=time.monotonic();values=[];samples=0
cov=4*f.RHO*np.linalg.inv(s.Q);chol=np.linalg.cholesky(cov)
exact=f.R*f.R*f.RHO/(4*s.P0)
for block in range(400):
 t=rng.normal(size=(16384,f.R))@chol.T
 fourth=np.sum((t@f.TRANSVERSE_ROWS.T)**4,axis=1)/(192*f.RHO*f.M)
 values.append([fourth.mean(),.5*np.mean(abs(fourth-exact))]);samples+=len(t)
arr=np.array(values);mean=arr.mean(0);se=arr.std(0,ddof=1)/math.sqrt(len(arr))
checks=json.loads((f.ROOT/'results/logarithmic_softplus_corner_checks.json').read_text())
comparison=[]
for row in checks['cases']:
 if row['logN']>=32:
  factor=row['a']*math.sqrt(row['eta'])
  comparison.append(dict(a=row['a'],eta=row['eta'],logN=row['logN'],
      scaled_radial_error=(row['radial_normalizer_ratio']-1)*row['logN']*factor,
      scaled_mark_discrepancy=row['conditional_mark_discrepancy']*row['logN']*factor))
out=dict(status='complete',samples=samples,seconds=time.monotonic()-start,
    exact_radial_coefficient=exact,estimated_radial_coefficient=float(mean[0]),radial_block_se=float(se[0]),
    estimated_mark_tv_coefficient=float(mean[1]),mark_tv_block_se=float(se[1]),comparisons=comparison,
    scope='Gaussian polynomial Monte Carlo and comparison with conditional corner integrations; coefficients scale as 1/(a sqrt(eta)). Not a full-posterior total-variation estimate.')
(f.ROOT/'results/logarithmic_mark_correction.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k!='comparisons'},indent=2))
