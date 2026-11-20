"""High-precision evaluation of the exact prior parity kernel eigenvalue.
Posterior values are the proved fixed-dimension large-width prediction,
not finite-width sampler estimates.
"""
import json,math
from pathlib import Path
import mpmath as mp
ROOT=Path(__file__).resolve().parents[1];mp.mp.dps=140
rows=[]
for r in range(6,130,2):
 def kernel(c):return (r+1)/(2*mp.pi)*(mp.sqrt(1-c*c)+(mp.pi-mp.acos(c))*c)
 eigen=mp.fsum([(-1)**j*mp.binomial(r,j)*kernel(mp.mpf(1+r-2*j)/(r+1)) for j in range(r+1)])/2**r
 rho=mp.binomial(r-2,(r-2)//2)/(mp.mpf(2)**(r-1)*mp.sqrt(r))
 target=rho/2
 assert eigen>0 and eigen<3*mp.mpf(2)**(-r)
 rows.append(dict(r=r,prior_eigenvalue=float(eigen),posterior_eigenvalue_limit=float(target),amplification=float(target/eigen),log2_amplification=float(mp.log(target/eigen,2)),rho=float(rho),exact_exceptional_count_lower=2**(r-1)))
(ROOT/'results/parity_kernel_amplification.json').write_text(json.dumps(rows,indent=2)+'\n')
for row in rows:
 if row['r'] in [6,8,16,32,64,128]:print(json.dumps(row))
