from fractions import Fraction as Q
import json
S=10**45

def dn(x):return Q((x.numerator*S)//x.denominator,S)
def up(x):return -dn(-x)
class I:
 def __init__(self,a,b=None):self.lo=dn(Q(a));self.hi=up(Q(a if b is None else b))
 def __add__(s,t):
  if not isinstance(t,I):t=I(t)
  return I(s.lo+t.lo,s.hi+t.hi)
 __radd__=__add__
 def __neg__(s):return I(-s.hi,-s.lo)
 def __sub__(s,t):return s+-t if isinstance(t,I) else s+I(-t)
 def __rsub__(s,t):return I(t)+-s
 def __mul__(s,t):
  if not isinstance(t,I):t=I(t)
  z=[s.lo*t.lo,s.lo*t.hi,s.hi*t.lo,s.hi*t.hi];return I(min(z),max(z))
 __rmul__=__mul__
 def inv(s):
  assert not(s.lo<=0<=s.hi)
  return I(1/s.hi,1/s.lo)
 def __truediv__(s,t):return s*(t.inv() if isinstance(t,I) else I(t).inv())
 def __rtruediv__(s,t):return I(t)*s.inv()
 def __pow__(s,n):
  assert n>=0
  o=I(1)
  for _ in range(n):o=o*s
  return o
 def show(s):return [float(s.lo),float(s.hi)]

def exp_pos(x):
 assert x>=0;M=256;assert x<M+2;term=Q(1);total=term
 for k in range(1,M+1):term=term*x/k;total+=term
 nxt=term*x/(M+1);tail=nxt/(1-x/(M+2))
 return I(total,total+tail)
def expneg(z):return I(exp_pos(z.hi).inv().lo,exp_pos(z.lo).inv().hi)

def sums(a):
 J=10;F0=I(1);F1=I(0);F2=I(0);Fp=I(0);Fpp=I(0);F1p=I(0)
 for j in range(J):
  jj=j*(j+1);b=2*(2*j+1);q=expneg(b*a);f=q/(1+q);fp=-b*q/(1+q)**2;fpp=b*b*q*(1-q)/(1+q)**3;sg=(-1)**j
  F0-=4*sg*f;Fp-=4*sg*fp;Fpp-=4*sg*fpp
  F1+=4*sg*(1+2*jj)*f;F1p+=4*sg*(1+2*jj)*fp
  F2-=4*sg*(1+4*jj+2*jj*jj)*f
 amin=a.lo;q0=expneg(I(2*amin*(2*J+1))).hi;r=expneg(I(4*amin)).hi
 assert r<Q(1,100)
 tail=192*(J+1)**6*q0;err=I(-tail,tail)
 return [v+err for v in [F0,F1,F2,Fp,Fpp,F1p]],tail

lo=Q(1237,1000);hi=Q(619,500)
(sl,tail)=sums(I(lo));(sh,_)=sums(I(hi));
Hl=I(lo)*sl[3]-sl[0];Hh=I(hi)*sh[3]-sh[0]
assert Hl.lo>0 and Hh.hi<0
(aF,tail)=sums(I(lo,hi));F0,F1,F2,Fp,Fpp,F1p=aF;a=I(lo,hi)
D1=F1+F0/4;D1p=F1p+Fp/4;D2=F2+F1/4+F0/32
Cnorm=a*D1**2/F0**3-a*D2/F0**2+(D1-a*D1p)**2/(2*a*Fpp*F0**2)
assert Fpp.hi<0 and Cnorm.lo>0
assert tail<Q(1,10**14)
assert Cnorm.lo>Q(4616,10000) and Cnorm.hi<Q(4842,10000)
print(json.dumps(dict(a_interval=[str(lo),str(hi)],H_lower=Hl.show(),H_upper=Hh.show(),F0=F0.show(),F0pp=Fpp.show(),normalized_C=Cnorm.show(),tail_bound=float(tail)),indent=2))
