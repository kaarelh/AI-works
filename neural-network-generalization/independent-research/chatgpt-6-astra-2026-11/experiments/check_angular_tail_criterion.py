"""Independent one-dimensional numerical check of the angular-tail constant.

The artificial homogeneous G has angular gap tan(theta)^beta around two
poles. Its near-maximum volume is explicit. Bessel integration is compared
with the separate angular-volume asymptotic. Normalization cancels.
This is floating-point quadrature, not an interval proof or a neural model.
"""
import json,math
from pathlib import Path
from scipy.integrate import quad
from scipy.special import gamma,kve
ROOT=Path(__file__).resolve().parents[1];rows=[]
for d,beta in ((4,1.),(6,1.),(6,1.25),(8,1.5)):
 kappa=d/beta;alpha=kappa-(d+1)/2;area=2*math.pi**(d/2)/gamma(d/2);L=2*area/d
 constant=math.sqrt(math.pi/2)*L*gamma(kappa+1)
 for z in (16.,64.,256.,1024.,4096.):
  # Gap t=tan(theta)^beta, then v=z*t. Both tails are exponentially damped.
  def integrand(v):
   if v==0:return 0.
   t=v/z;q=1/(1+t);a=t**(1/beta)
   angular=(a/math.sqrt(1+a*a))**(d-1)/(1+a*a)/beta*t**(1/beta-1)/z
   return 2*area*angular/q*(z/q)**(d/2)*kve(d/2,z/q)*math.exp(-v)
  value,error=quad(integrand,0,160,epsabs=1e-25,epsrel=2e-10,limit=300)
  rows.append(dict(d=d,beta=beta,alpha=alpha,z=z,density_ratio=value*z**(alpha+1)/constant,quadrature_error_estimate=error))
result=dict(status='completed',rows=rows,qualification='Non-interval floating-point quadrature of an artificial homogeneous statistic. Checks the proposed constant and exponent numerically; the general theorem is proved in the manuscript.')
(ROOT/'results/angular_tail_criterion_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps([r for r in rows if r['z']==4096]))
