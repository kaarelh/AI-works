"""Exact full-parity kernels for two bounded four-point initializations.

Permutation symmetry reduces the population expectation to a binomial
count of large magnitudes. Alternating binomial tails evaluate the actual
ReLU coefficient with integers, without a numerical quadrature or solver.
"""
import json,math,time,sys
sys.set_int_max_str_digits(0)
from fractions import Fraction
from pathlib import Path
import mpmath as mp
ROOT=Path(__file__).resolve().parents[1];mp.mp.dps=70

def binomrow(n):
 if n<0:return []
 a=[1]
 for i in range(n):a.append(a[-1]*(n-i)//(i+1))
 return a

def coefficient_numerator(r,count_large,large):
 n=r-count_large;choose=binomrow(count_large)
 row1=binomrow(n-1);row2=binomrow(n-2)
 total=0
 for j in range(count_large+1):
  D=large*(2*j-count_large)-n
  if n<=1:
   h=sum((-1)**(n-i)*math.comb(n,i)*max(0,2*i+D) for i in range(n+1))
  else:
   m=max(0,(-D)//2+1)
   if m<1 or m>n:h=0
   else:
    weighted=row2[m-2] if 2<=m<=n else 0
    h=(-1)**(n-m)*(2*n*weighted+D*row1[m-1])
  total+=(-1)**(count_large-j)*choose[j]*h
 return total

def brute_numerator(r,nlarge,large):
 weights=[large]*nlarge+[1]*(r-nlarge);value=0
 for mask in range(2**r):
  z=sum(w*(1 if mask>>i&1 else -1) for i,w in enumerate(weights))
  value+=(-1)**(r-mask.bit_count())*max(0,z)
 return value

if __name__=='__main__':
 cases=0
 for r in (2,4,6,8,10,12):
  for large in (2,3):
   for nlarge in range(r+1):
    assert coefficient_numerator(r,nlarge,large)==brute_numerator(r,nlarge,large)
    cases+=1
 print(json.dumps(dict(brute_integer_checks=cases,status='PASS')),flush=True)
 saved=ROOT/'results/exact_lattice_kernels.json'
 rows=json.loads(saved.read_text())['rows'] if saved.exists() else []
 completed={(row['r'],row['law']) for row in rows};start=time.monotonic()
 for r in (6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024,1536,2048,3072,4096,6144,8192):
  choose=binomrow(r)
  for large in (2,3):
   if (r,'odd' if large==3 else 'mixed') in completed:continue
   before=time.monotonic();nums=[coefficient_numerator(r,j,large) for j in range(r+1)]
   numerator=sum(c*n*n for c,n in zip(choose,nums))*2
   denominator=(1<<(3*r))*(1+large*large)
   common=math.gcd(numerator,denominator);numerator//=common;denominator//=common
   value=mp.mpf(numerator)/denominator
   row=dict(r=r,law='odd' if large==3 else 'mixed',exact_numerator=str(numerator),exact_denominator=str(denominator),
     log_kernel=str(mp.log(value)),r_times_kernel=str(r*value),seconds=time.monotonic()-before)
   if large==3:
    asym=1/(50*mp.pi*r);lower=4/(25*mp.pi**6*r)
    assert value>=lower
    row['ratio_to_asymptotic']=str(value/asym)
   else:
    upper=(mp.mpf(r)/(r-1))**2/mp.pi**2*(mp.mpf(25)/32)**(r-1)
    assert value<=upper
    row['ratio_to_exponential_upper']=str(value/upper)
    row['ratio_to_asymptotic']=str(value/(22/(25*mp.pi*mp.sqrt(3)*r)*(mp.mpf(25)/32)**r))
   rows.append(row)
   (ROOT/'results/exact_lattice_kernels.json').write_text(json.dumps(dict(status='in_progress',brute_integer_checks=cases,rows=rows),indent=2)+'\n')
   print(json.dumps({k:v for k,v in row.items() if not k.startswith('exact_')}),flush=True)
 result=dict(status='PASS',brute_integer_checks=cases,rows=rows,wall_seconds_last_run=time.monotonic()-start,summed_kernel_compute_seconds=sum(row['seconds'] for row in rows),
 qualification='Kernel values are exact rational numbers. Displayed logarithms, pi comparisons, and asymptotic ratios use non-interval 70-digit arithmetic.')
 (ROOT/'results/exact_lattice_kernels.json').write_text(json.dumps(result,indent=2)+'\n')
