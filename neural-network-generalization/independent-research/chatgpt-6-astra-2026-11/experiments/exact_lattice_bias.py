"""Exact biased odd-lattice kernels, using integer ReLU coefficients.

All listed biases are z/sqrt(5), with rational z. Population kernel
values are rational because the squared normalization cancels sqrt(5).
"""
import json,math,time
from fractions import Fraction
from pathlib import Path
import mpmath as mp
from exact_lattice_kernel import binomrow
ROOT=Path(__file__).resolve().parents[1];mp.mp.dps=70

def coefficient(r,count_large,bias):
 n=r-count_large;choose=binomrow(count_large)
 row1=binomrow(n-1);row2=binomrow(n-2);total=0
 for j in range(count_large+1):
  D=3*(2*j-count_large)-n+bias
  if n<=1:h=sum((-1)**(n-i)*math.comb(n,i)*max(0,2*i+D) for i in range(n+1))
  else:
   m=max(0,(-D)//2+1)
   if m<1 or m>n:h=0
   else:h=(-1)**(n-m)*(2*n*(row2[m-2] if m>=2 else 0)+D*row1[m-1])
  total+=(-1)**(count_large-j)*choose[j]*h
 return total

rows=[];started=time.monotonic()
for r in (6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024,1536,2048):
 choose=binomrow(r);left=[coefficient(r,j,0) for j in range(r+1)];right=[coefficient(r,j,2) for j in range(r+1)]
 # Every weighted cube score is an even integer; ReLU is affine in bias
 # throughout [0,2]. The following interpolation is therefore exact.
 for b in (Fraction(0),Fraction(1,2),Fraction(1),Fraction(3,2),Fraction(2)):
  u=b.denominator;v=b.numerator
  nums=[(2*u-v)*a+v*c for a,c in zip(left,right)]
  value=Fraction(sum(c*g*g for c,g in zip(choose,nums)),(1<<(3*r))*5*(2*u)**2)
  numeric=mp.mpf(value.numerator)/value.denominator
  triangle=1-abs(mp.mpf(v)/u)
  row=dict(r=r,bias_in_lattice_units=str(b),exact_numerator=str(value.numerator),exact_denominator=str(value.denominator),
    kernel=str(numeric),r_times_kernel=str(r*numeric),r_cubed_times_kernel=str(r**3*numeric))
  if b!=1:row['ratio_to_leading_asymptotic']=str(numeric/(triangle**2/(50*mp.pi*r)))
  else:row['ratio_to_midpoint_asymptotic']=str(numeric/(1/(1250*mp.pi*r**3)))
  rows.append(row)
 (ROOT/'results/exact_lattice_bias.json').write_text(json.dumps(dict(status='in_progress',rows=rows),indent=2)+'\n')
 print(json.dumps(dict(r=r,midpoint_ratio=rows[-3]['ratio_to_midpoint_asymptotic'])),flush=True)
(ROOT/'results/exact_lattice_bias.json').write_text(json.dumps(dict(status='PASS',rows=rows,seconds=time.monotonic()-started,
 qualification='Exact rational kernel values; 70-digit non-interval asymptotic ratios. The midpoint constant is proved for the bounded odd-lattice law in the companion manuscript.'),indent=2)+'\n')
