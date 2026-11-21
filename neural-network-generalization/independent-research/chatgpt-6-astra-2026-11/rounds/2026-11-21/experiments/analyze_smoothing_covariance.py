"""Normalize and center paired critical-moment differences.

Jackknife errors condition on the separately estimated ReLU reference moments.
They do not include uncertainty in that reference and are not certified bounds.
"""
import json,math
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
ref=json.loads((ROOT/'results/critical_moments_reference.json').read_text())
M0=ref['Mstar'];mc=ref['critical_mean'];second=np.array(ref['walsh_covariance_eigenvalues']);second[-1]+=64*mc*mc
rows=[]
for path in sorted((ROOT/'results').glob('paired_smoothing_covariance_beta*.json')):
 data=json.loads(path.read_text());beta=data['beta'];blocks=np.load(path.with_suffix('.npz'))['block_means'];n=len(blocks)
 def transform(arr):
  Mb=M0-arr[...,0]/beta;mb=(mc*M0-arr[...,1]/beta)/Mb
  cov=(arr[...,2:]-arr[...,0,None]*second)/Mb[...,None]
  cov[...,-1]-=64*beta*(mc*mc-mb*mb)
  return cov
 mean=blocks.mean(0);estimate=transform(mean);loo=transform((blocks.sum(0)-blocks)/(n-1))
 se=np.sqrt((n-1)*np.mean((loo-loo.mean(0))**2,axis=0))
 rows.append(dict(beta=beta,samples=data['samples'],scaled_covariance_difference=estimate.tolist(),
                  conditional_jackknife_se=se.tolist()))
rows.sort(key=lambda x:x['beta'])
out=dict(status='complete',reference_file='critical_moments_reference.json',rows=rows,
 scope='Normalized and centered paired Monte Carlo covariance differences. Errors condition on separately estimated ReLU moments; not interval-certified.')
(ROOT/'results/smoothing_covariance_analysis.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
