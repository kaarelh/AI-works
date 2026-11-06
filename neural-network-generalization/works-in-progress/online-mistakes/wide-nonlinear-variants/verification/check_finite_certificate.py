"""Exact rational certificate for a wider tanh competitor.
No floating point arithmetic participates in any assertion.
The only analytic inequalities are tanh(u) >= u-u^3/3 (u>=0),
tanh(u)<=1, monotonicity, and weighted product/Frobenius AM-GM.
"""
from fractions import Fraction as F
alpha,b,r,s=F(55,100),F(17,100),F(147,1000),F(675,1000)
w=list(map(lambda n:F(n,1000),[1361,1365,1373,1389,1419]))
v=F(3,2)
def P(u):return u-u**3/3
m=min(r*P(alpha),s*P(2*b)-r)
h=P(m)
for a in w:
 assert 0<a*h<1
 h=P(a*h)
assert v*h>F(1,2)

def E(p):
 return 7*(p*alpha**2*43+(1-p)*2*b*b)+r*r/p+s*s/(1-p)+sum(a*a for a in w)+v*v
# E is convex in p. n=floor(N/64+1/2) gives these bounds at every N>=64.
for p in (F(1,95),F(1,48)):
 assert E(p)<F(157,10)
# Scalar wrong function after q_6 has Q=42+36+49=127.
# Product bound: kappa >= 8*(7*127/4)^(1/8) > 15.7.
assert (F(157,10)/8)**8<F(7*127,4)
# Human-readable floats below are presentation only.
print('PASS: full-target margin lower bound',float(v*h))
print('PASS: energy endpoint upper bounds',[float(E(p)) for p in (F(1,95),F(1,48))])
print('PASS: wider target energy < 15.7 < scalar wrong-function lower bound')
