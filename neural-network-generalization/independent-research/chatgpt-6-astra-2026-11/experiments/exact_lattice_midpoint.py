"""Independent exact midpoint-bias kernels for bounded odd-lattice laws.

The three incoming laws are uniform on {+-p,+-q}, rescaled to variance
one; the bias is the lattice spacing. Integer alternating binomial tails
are checked against direct cube enumeration before population averaging.
Displayed asymptotic ratios use non-interval 70-digit arithmetic.
"""
import json,math,sys,time
from fractions import Fraction
from pathlib import Path
import mpmath as mp
from exact_lattice_kernel import binomrow
sys.set_int_max_str_digits(0)
ROOT=Path(__file__).resolve().parents[1];mp.mp.dps=70

def coefficient(r,nlarge,p,q,b=1):
 n=r-nlarge;choose=binomrow(nlarge);row1=binomrow(n-1);row2=binomrow(n-2);value=0
 for j in range(nlarge+1):
  D=q*(2*j-nlarge)-p*n+b
  if n<=1:h=sum((-1)**(n-i)*math.comb(n,i)*max(0,2*p*i+D) for i in range(n+1))
  else:
   m=max(0,(-D)//(2*p)+1)
   h=0 if m<1 or m>n else (-1)**(n-m)*(2*p*n*(row2[m-2] if m>=2 else 0)+D*row1[m-1])
  value+=(-1)**(nlarge-j)*choose[j]*h
 return value

def brute(r,nlarge,p,q):
 w=[q]*nlarge+[p]*(r-nlarge)
 return sum((-1)**(r-mask.bit_count())*max(0,1+sum(v*(1 if mask>>i&1 else -1) for i,v in enumerate(w))) for mask in range(1<<r))

if __name__=='__main__':
 start=time.monotonic();rows=[];cases=0
 for r in (2,4,6,8,10):
  for p,q in ((1,3),(1,5),(3,5)):
   for j in range(r+1):
    assert coefficient(r,j,p,q)==brute(r,j,p,q);cases+=1
 print(json.dumps(dict(brute_integer_checks=cases,status='PASS')),flush=True)
 for p,q in ((1,3),(1,5),(3,5)):
  v=Fraction(p*p+q*q,2);etap=(-1)**((p-1)//2);etaq=(-1)**((q-1)//2)
  for r in (6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024,1536,2048):
   before=time.monotonic();choose=binomrow(r);g=[coefficient(r,j,p,q) for j in range(r+1)]
   value=Fraction(sum(c*z*z for c,z in zip(choose,g)),1<<(3*r))/v
   # Mean of the bounded resonant comparator times the feature.
   mean_numerator=(-1)**(r//2+1)*sum(c*etap**(r-j)*etaq**j*z for j,(c,z) in enumerate(zip(choose,g)))
   mean_unscaled=Fraction(mean_numerator,1<<(2*r))
   mean=mp.mpf(mean_unscaled.numerator)/mean_unscaled.denominator/mp.sqrt(mp.mpf(v.numerator)/v.denominator)
   num=mp.mpf(value.numerator)/value.denominator;vv=mp.mpf(v.numerator)/v.denominator
   row=dict(r=r,p=p,q=q,exact_numerator=str(value.numerator),exact_denominator=str(value.denominator),
      exact_mean_before_normalization_numerator=str(mean_unscaled.numerator),exact_mean_before_normalization_denominator=str(mean_unscaled.denominator),
      kernel=str(num),ratio_to_midpoint_asymptotic=str(num*2*mp.pi*vv**4*r**3),
      mean_square_to_kernel=str(mean**2/num),seconds=time.monotonic()-before)
   rows.append(row)
   (ROOT/'results/exact_lattice_midpoint.json').write_text(json.dumps(dict(status='in_progress',rows=rows),indent=2)+'\n')
   print(json.dumps({k:val for k,val in row.items() if not k.startswith('exact_')}),flush=True)
 (ROOT/'results/exact_lattice_midpoint.json').write_text(json.dumps(dict(status='PASS',brute_integer_checks=cases,rows=rows,seconds=time.monotonic()-start,
   qualification='Exact integer/rational population calculation; displayed asymptotic ratios and square roots are non-interval 70-digit diagnostics.'),indent=2)+'\n')
