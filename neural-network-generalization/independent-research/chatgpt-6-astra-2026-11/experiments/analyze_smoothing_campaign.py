"""Compare independent finite-cube Monte Carlo with the proved integral bounds.

The integrals are evaluated numerically at high precision, not by intervals.
Monte Carlo error bars are empirical standard errors, not certified bounds.
"""
import json,math
from pathlib import Path
import mpmath as mp
from check_codimension_smoothing import identities
ROOT=Path(__file__).resolve().parents[1];CAM=ROOT/'results/mitm_campaign'
CACHE=ROOT/'results/mitm_integral_reference.json'
cache=json.loads(CACHE.read_text()) if CACHE.exists() else {}
rows=[]
for job in json.loads((CAM/'campaign.json').read_text())['jobs']:
 p=CAM/(job['name']+'.jsonl')
 if not p.exists():continue
 lines=p.read_text().splitlines()
 if not lines:continue
 try:record=json.loads(lines[-1])
 except json.JSONDecodeError:record=json.loads(lines[-2])
 r=job['r'];A=job['A'];n=record['samples'];L=A*math.log(r)
 for shell in record['shells']:
  k=shell['omitted']//2;key=f'{r}:{A:g}:{k}'
  if key not in cache:
   cache[key]=identities(r,k,A)
   CACHE.write_text(json.dumps(cache,indent=2)+'\n')
  ref=cache[key];mu=float(ref['mu']);nu=float(ref['nu']);upper=float(ref['upper_root'])
  mean=shell['mean_coefficient'];lam=shell['kernel_estimate'];se=shell['kernel_standard_error']
  mean_se=math.sqrt(max(0.,lam-mean*mean)/n)
  expected_mean=(-1)**((r-2*k-2)//2)*mu
  expected_hermite=(-1)**((r+2*k-2)//2)*nu
  asym=32/math.pi**5*(math.pi/2)**(4*k)*L**(2*k)*r**(-2*k-1-A*math.pi**2/4)
  rows.append(dict(name=job['name'],r=r,A=A,k=k,samples=n,requested_samples=job['samples'],
      kernel_estimate=lam,kernel_empirical_standard_error=se,
      analytic_lower_numerical=max(mu,nu)**2,analytic_upper_numerical=upper**2,
      lower_to_asymptotic=max(mu,nu)**2/asym,upper_to_asymptotic=upper**2/asym,
      kernel_to_asymptotic=lam/asym,
      mean_coefficient=mean,expected_mean_coefficient_numerical=expected_mean,
      mean_empirical_standard_error=mean_se,
      mean_z_score=(mean-expected_mean)/mean_se if mean_se else None,
      hermite_alignment=shell['hermite_alignment'],expected_hermite_alignment_numerical=expected_hermite,
      maximum_brute_difference=record['maximum_brute_difference']))
 print(json.dumps(dict(job=job['name'],samples=n,reference='available')),flush=True)
result=dict(rows=rows,precision_decimal_digits=mp.mp.dps,
 qualification='Finite-cube floating-point Monte Carlo with empirical standard errors; positive integral bounds evaluated by non-interval high-precision quadrature. Neither is independent proof review.')
(ROOT/'results/smoothing_campaign_analysis.json').write_text(json.dumps(result,indent=2)+'\n')
