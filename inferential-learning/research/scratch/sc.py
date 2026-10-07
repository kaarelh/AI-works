import numpy as np
from scipy.optimize import brentq
a=1.0
for r in [20, 100]:
  for sg in [0.2, 0.5, 0.7071, 0.9]:
    phi=2*np.arcsin(sg)
    f=lambda p: p+np.arctan2(a*np.cos(p/2), np.sqrt(r*r-a*a*np.cos(p/2)**2))-phi
    p=brentq(f,1e-13,2*np.pi-1e-13); c=np.sin(p/2); eps=a/r
    u=np.sqrt(r*r-a*a*np.cos(p/2)**2); s=u-a*c
    rat=(a*c/(2*s+a*c))/(a/2*sg/r)
    print(f"r={r} sigma={sg}: sigma-c={sg-c:.3e}  eps(1-s^2)/2={eps*(1-sg**2)/2:.3e}  eps(1-s^2)/(2s)={eps*(1-sg**2)/(2*sg):.3e}  ratio-1={rat-1:+.3e}  first-order eps(2s^2-1)/(2s)={eps*(2*sg**2-1)/(2*sg):+.3e}")
