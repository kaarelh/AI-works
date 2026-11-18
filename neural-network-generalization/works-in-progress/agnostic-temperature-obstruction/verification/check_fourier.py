import math
import numpy as np
from scipy.integrate import quad
from numpy.polynomial.hermite import hermgauss
rng=np.random.default_rng(83171)
# Midpoint-grid Fourier coefficients, real interpolation and signal-zero mask.
checks=0
for D in (1,2,3):
 for J in (2,4):
  r=1/math.sqrt(2*D)
  idx=np.array(list(np.ndindex(*([J]*D))))
  z=r*(2*idx+1-J)/J
  vals=rng.uniform(-1,1,len(z))
  freq=idx.copy()
  phases=np.pi/r*(z@freq.T)
  c=np.exp(-1j*phases).T@vals/len(z)
  recon=(np.exp(1j*phases)@c).real
  assert np.max(np.abs(recon-vals))<1e-11
  assert np.sum(np.abs(c))<=math.sqrt(len(z))+1e-10
  mask=1-np.prod(np.cos(np.pi*J*z/(2*r))**2,axis=1)
  assert np.max(np.abs(mask-1))<1e-12
  assert 1-np.prod(np.cos(np.zeros(D))**2)==0
  checks+=1
# The exact convolution multiplier and numerical convolution check.
c0=quad(lambda x: math.cos(x)/math.cosh(x)**2,-30,30,epsabs=1e-11)[0]
assert 1<=c0<=2
nodes,weights=hermgauss(96)
weights=weights/math.sqrt(math.pi)
for v in (0,.25,1):
 def phi(x): return np.dot(weights,np.tanh(x+math.sqrt(2*v)*nodes))
 kappa=2*math.exp(-v/2)*c0
 assert 2*math.exp(-.5)<=kappa<=4
 for t in (0,.7,3,10):
  U=abs(t)+14
  integ=quad(lambda u: math.cos(u)*(phi(t-u+math.pi/2)-phi(t-u-math.pi/2)),-U,U,epsabs=1e-9,limit=200)[0]/kappa
  assert abs(integ-math.cos(t))<3e-7,(v,t,integ)
  checks+=1
for H in range(2,9):
 f1,f2=.25,.75
 for _ in range(H):f1,f2=math.tanh(f1),math.tanh(f2)
 resid=(.75*f1-.25*f2)**2/(2*(.25**2+.75**2))
 assert resid>0
 print('H',H,'fixed width-one nonlinear residual against affine functions',resid)
print('Passed',checks,'Fourier/mask/convolution checks. c0=',c0)
