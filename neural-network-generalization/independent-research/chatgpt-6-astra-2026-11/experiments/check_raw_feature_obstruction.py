"""Exact finite-cube checks of the optimal-energy raw-feature obstruction.

Integer sums verify all displayed source/annihilator/attainment identities.
Polynomial-width margin examples are numerical diagnostics of the separately
proved Bernstein construction. No optimization solver is used.
"""
import json,math
from fractions import Fraction as F
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
rng=np.random.default_rng(2026111823);rows=[];sampled=[]
for r in (6,8,10,12):
 M=2**r;X=(2*((np.arange(M)[:,None]>>np.arange(r))&1)-1).astype(np.int64)
 source=np.prod(X,axis=1);br=F(math.comb(r-2,(r-2)//2),2**(r-1))*(-1)**((r-2)//2)
 for j in range(2,r,2):
  target=np.prod(X[:,:j],axis=1);chosen=np.prod(X[:,1:j],axis=1)==1;Z=X[chosen];K=len(Z)
  H=np.maximum(Z@X.T,0);bt=F(math.comb(r-2,(r-2)//2),2**(r-1))*F((-1)**((j-2)//2)*math.comb((r-2)//2,(j-2)//2),math.comb(r-2,j-2))
  d=bt.denominator;n=bt.numerator
  assert np.all(d*(H@target)==M*n*Z[:,0])
  assert np.all(2*(H@X[:,0])==M*Z[:,0])
  annihilator=d*target-2*n*X[:,0]
  assert np.all(H@annihilator==0)
  assert np.all(br.denominator*(source[chosen]@H)==K*br.numerator*source)
  assert np.all(2*d*(target[chosen]@H)==K*(2*n*target+d*X[:,0]))
  # Exact invariance of the (target,x_1) kernel block. H is unnormalized.
  k_target=H.T@(H@target);k_linear=H.T@(H@X[:,0])
  assert np.all(2*d*d*k_target==K*M*(2*n*n*target+n*d*X[:,0]))
  assert np.all(4*d*k_linear==K*M*(2*n*target+d*X[:,0]))
  error=1/(1+4*bt*bt)
  rows.append(dict(r=r,j=j,width=K,beta_j=str(bt),optimal_raw_mse=str(error),optimal_raw_mse_decimal=float(error)))
  if j==r-2:
   for eps in (.5,.1,.03):
    confidence=.01;rho2=float(br*br)/r
    N=math.ceil(4*(1+eps)**2/(rho2*eps**2)*math.log(M/confidence))
    counts=rng.multinomial(N,np.full(K,1/K))
    F_over_s=(1+eps)/float(br)*(counts*source[chosen])@H/N
    margin=float(np.min(source*F_over_s));assert margin>=1
    sampled.append(dict(r=r,j=j,relative_energy_excess=eps,width=N,minimum_margin_over_s=margin))
 print(json.dumps(dict(r=r,status='PASS',cases=r//2-1)),flush=True)
result=dict(status='PASS',exact_cases=rows,random_margin_checks=sampled,scope='Exact integer finite-cube identities; conventional general proof; sampled margin examples are numerical diagnostics.')
(ROOT/'results/raw_feature_obstruction_checks.json').write_text(json.dumps(result,indent=2)+'\n')
