"""Independent characteristic-integral diagnostics for uniform/Laplace noise.

Adaptive floating-point quadrature is not interval arithmetic. Tail bounds
below are mathematical inequalities evaluated in floating point, so the
reported brackets likewise are not rigorous interval certificates.
"""
import json,math
from pathlib import Path
from scipy.integrate import quad
ROOT=Path(__file__).resolve().parents[1];CAM=ROOT/'results/universal_smoothing'
CACHE=ROOT/'results/universal_integral_reference.json'
cache=json.loads(CACHE.read_text()) if CACHE.exists() else {}

def phi(u,noise):
 if noise=='uniform':return math.sin(math.sqrt(3)*u)/(math.sqrt(3)*u) if u else 1.
 return 1/(1+u*u/2)
def derivative(u,noise):
 if noise=='uniform':
  v=math.sqrt(3)*u
  if abs(v)<1e-4:return -u+3*u**3/10-9*u**5/280
  return (v*math.cos(v)-math.sin(v))/(math.sqrt(3)*u*u)
 return -u/(1+u*u/2)**2

def references(r,k,A,noise):
 sigma=math.sqrt(A*math.log(r)/r);j=r-2*k
 # Every trigonometric peak is separately integrated. The reference is
 # independent of the meet-in-the-middle finite-cube implementation.
 cutoff=40*math.pi
 def integrand(t,kind):
  if not t:return 0.
  ph=phi(sigma*t,noise)
  if kind=='mean':return math.sin(t)**j*math.cos(t)**(2*k)*ph**r/(math.pi*t*t)
  if kind=='product':return math.sin(t)**r*ph**j*derivative(sigma*t,noise)**(2*k)/(math.pi*t*t)
  st=(1-math.cos(2*t)*phi(2*sigma*t,noise))/2
  return max(0,st)**(j/2)*max(0,1-st)**k/(math.pi*t*t)
 vals={};errors={}
 for kind in ('mean','product','upper'):
  value=err=0.
  for i in range(80):
   q,e=quad(lambda t:integrand(t,kind),i*math.pi/2,(i+1)*math.pi/2,epsabs=1e-19,epsrel=2e-10,limit=200)
   value+=q;err+=e
  vals[kind]=value;errors[kind]=err
 # Beyond cutoff, upper integrand differs from its 2^(-r/2) baseline
 # by at most C_r*|phi(2 sigma t)| / t^2. Use its maximum on [cutoff,infty]
 # to bound the entire tail, rather than treating the baseline as exact.
 if noise=='uniform':eta=min(1.,1/(2*math.sqrt(3)*sigma*cutoff))
 else:eta=1/(1+2*sigma*sigma*cutoff*cutoff)
 base=2**(-r/2)/(math.pi*cutoff)
 upper_tail_low=base*(1-eta)**(r/2);upper_tail_high=base*(1+eta)**(r/2)
 # These absolute tails bound the mean and product witnesses, using
 # |phi|<=1/(sqrt(3)*u) for uniform and <=2/u^2 for Laplace.
 if noise=='uniform':
  mean_tail=(math.sqrt(3)*sigma)**(-r)*cutoff**(-r-1)/(math.pi*(r+1))
  # |phi'| <= 1/|u| + 1/(sqrt(3)*u^2) <= 2/|u| here.
  product_tail=(math.sqrt(3)*sigma)**(-j)*(2/sigma)**(2*k)*cutoff**(-r-1)/(math.pi*(r+1))
 else:
  mean_tail=(2/sigma**2)**r*cutoff**(-2*r-1)/(math.pi*(2*r+1))
  # |phi'| <= 4/|u|^3.
  product_tail=(2/sigma**2)**j*(4/sigma**3)**(2*k)*cutoff**(-2*r-2*k-1)/(math.pi*(2*r+2*k+1))
 return dict(mean=vals['mean'],product=vals['product'],quadrature_error_estimates=errors,
  mean_absolute_tail_upper=mean_tail,product_absolute_tail_upper=product_tail,
  upper_root_low=vals['upper']+upper_tail_low,upper_root_high=vals['upper']+upper_tail_high,
  cutoff=cutoff)

rows=[]
for job in json.loads((CAM/'campaign.json').read_text())['jobs']:
 path=CAM/(job['name']+'.jsonl')
 if not path.exists():continue
 lines=path.read_text().splitlines()
 if not lines:continue
 try:last=json.loads(lines[-1])
 except json.JSONDecodeError:last=json.loads(lines[-2])
 for shell in last['shells']:
  k=shell['omitted']//2;key=f"{job['noise']}:{job['r']}:{job['A']:g}:{k}"
  if key not in cache:
   cache[key]=references(job['r'],k,job['A'],job['noise'])
   CACHE.write_text(json.dumps(cache,indent=2)+'\n')
  ref=cache[key];r=job['r'];A=job['A'];n=last['samples'];sgn=(-1)**((r-2*k-2)//2)
  mean_se=math.sqrt(max(0.,shell['kernel_estimate']-shell['mean_coefficient']**2)/n)
  prod_se=shell['product_alignment_standard_error']
  asym=32/math.pi**5*(math.pi/2)**(4*k)*(A*math.log(r))**(2*k)*r**(-2*k-1-A*math.pi**2/4)
  rows.append(dict(name=job['name'],noise=job['noise'],r=r,A=A,k=k,samples=n,
    kernel_estimate=shell['kernel_estimate'],kernel_empirical_standard_error=shell['kernel_standard_error'],
    mean_z_score=(shell['mean_coefficient']-sgn*ref['mean'])/mean_se if mean_se else None,
    product_z_score=(shell['hermite_alignment']-sgn*ref['product'])/prod_se if prod_se else None,
    analytic_lower_numerical=max(ref['mean'],ref['product'])**2,
    analytic_upper_numerical=ref['upper_root_high']**2,
    lower_to_asymptotic=max(ref['mean'],ref['product'])**2/asym,
    upper_to_asymptotic=ref['upper_root_high']**2/asym,
    kernel_to_asymptotic=shell['kernel_estimate']/asym,
    maximum_brute_difference=last['maximum_brute_difference']))
 print(json.dumps(dict(name=job['name'],samples=last['samples'],status='analyzed')),flush=True)
result=dict(rows=rows,qualification='Monte Carlo empirical standard errors and non-interval quadrature. The tail expressions are evaluated in ordinary floating point; no numerical certification is claimed.')
(ROOT/'results/universal_smoothing_analysis.json').write_text(json.dumps(result,indent=2)+'\n')
