"""Outward-rounded interval upper certificate: standard softplus m_c < 1/2.

The analytic reduction is documented in the companion proof. Bias is set
to zero to upper-bound |G|. On each radial/angular rectangle, G is bounded
by its upper-right corner and the Gaussian radial measure is integrated
exactly. The tail is bounded by an elementary exponential integral.
This is a numerical interval certificate, not a Lean formalization.
"""
import json,time
from pathlib import Path
from mpmath import iv
ROOT=Path(__file__).resolve().parents[1];iv.dps=35;start=time.time()
K=32;radial=1000;step=iv.mpf(1)/50;sqrt2=iv.sqrt(2)
angles=[iv.pi*(j+1)/(4*K) for j in range(K)]
AA=[(iv.cos(p)+iv.sin(p))/2 for p in angles]
BB=[(iv.cos(p)-iv.sin(p))/2 for p in angles]
def logcosh(t):return iv.log((iv.exp(t)+iv.exp(-t))/2)
upper=iv.mpf(0)
for i in range(radial):
 lo=iv.mpf(i)/50;hi=iv.mpf(i+1)/50;mass=iv.exp(-lo*lo/2)-iv.exp(-hi*hi/2);angular=iv.mpf(0)
 for a,b in zip(AA,BB):
  g=(logcosh(hi*a)-logcosh(hi*b))/2
  angular+=g*g*iv.exp(4*g*g)
 upper+=2*sqrt2*mass*angular/K
 if i%100==0:print(json.dumps(dict(row=i,partial=str(upper),seconds=time.time()-start)),flush=True)
R=iv.mpf(20);a=2*sqrt2/3
tail=sqrt2/4*iv.exp(iv.mpf(4)/9-a*R)*(R**3/a+3*R**2/a**2+6*R/a**3+6/a**4)
total=upper+tail
# log cosh(R/sqrt2) <= R/sqrt2 - 2/3 for R >= 3.
check=iv.log(2)-iv.log(1+iv.exp(-3*sqrt2))-iv.mpf(2)/3
assert check.a>0
assert total.b<iv.mpf(488)/1000
row=dict(status='PASS',precision_decimal_digits=35,radial_cells=radial,radial_step='1/50',angular_cells=K,radial_cutoff=20,compact_integral_interval=str(upper),tail_interval=str(tail),total_upper_interval=str(total),certified_rational_upper='61/125 = 0.488 < 1/2',tail_inequality_margin_interval=str(check),seconds=time.time()-start)
(ROOT/'results'/'standard_softplus_critical_mean_certificate.json').write_text(json.dumps(row,indent=2)+'\n');print(json.dumps(row),flush=True)
