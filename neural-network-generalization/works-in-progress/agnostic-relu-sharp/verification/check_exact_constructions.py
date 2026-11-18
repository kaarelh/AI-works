"""Exact rational checks of Fourier/ReLU features and the bounded tent teacher."""
from fractions import Fraction as F
from itertools import product
import json,random

def relu(x):return max(F(0),x)
def parity_features(S,D):
 j=len(S); row=[0]*(D+1)
 for i in S:row[i+1]=1
 if j==0:return [(F(1),tuple([1]+[0]*D))]
 y0=(-1)**j; slope=-y0
 result=[(F(y0),tuple([1]+[0]*D))]
 result.append((F(slope),tuple([j]+row[1:])))
 old=slope
 for ell in range(1,j):
  new=-old;t=-j+2*ell
  result.append((F(new-old),tuple([-t]+row[1:])))
  old=new
 return result

rng=random.Random(1701); cases=0; maxratio=F(0)
for D in range(1,6):
 cube=list(product([-1,1],repeat=D));subsets=[tuple(i for i in range(D) if bits[i]) for bits in product([0,1],repeat=D)]
 for trial in range(8):
  target={x:F(rng.randrange(-2,3),2) for x in cube}; allfeatures=[]; fouriersq=F(0)
  for S in subsets:
   coeff=sum(target[x]*F(__import__('math').prod(x[i] for i in S)) for x in cube)/len(cube)
   fouriersq+=coeff*coeff
   feats=parity_features(S,D)
   assert len(feats)<=D+1
   assert sum(c*c for c,row in feats)<=4*D
   for c,row in feats:assert sum(v*v for v in row)<=4*D*D
   allfeatures.extend((coeff*c,row) for c,row in feats)
  assert len(allfeatures)<=(D+1)*2**D
  csq=sum(c*c for c,row in allfeatures)
  assert csq<=4*D*fouriersq
  if fouriersq:maxratio=max(maxratio,csq/(4*D*fouriersq))
  for x in cube:
   value=sum(c*relu(F(row[0]+sum(a*b for a,b in zip(row[1:],x)))) for c,row in allfeatures)
   assert value==target[x],(D,trial,x,value,target[x])
  cases+=1

tents=0
for H in range(1,7):
 for r in [1,2,4,8]:
  for B in [1,2,4]:
   delta=F(2,r**H*B**(H+1))
   if delta>F(1,2):continue
   scale=1/delta
   def g(t):return scale*(-relu(t+2*delta)+2*relu(t+delta)-2*relu(t-delta)+relu(t-2*delta))
   assert g(delta)==1 and g(-delta)==-1 and g(F(0))==0 and g(F(1))==0 and g(F(-1))==0
   for j in range(-12,13):assert abs(g(F(j,4)*delta))<=1
   assert 2*B*delta<=B
   tents+=1
print(json.dumps({'fourier_instances':cases,'all_cube_values_exact':True,'maximum_coefficient_budget_ratio':str(maxratio),'tent_instances':tents,'all_tent_checks_exact':True,'status':'passed'},indent=2))
