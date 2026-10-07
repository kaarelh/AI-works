import numpy as np
from scipy.optimize import brentq
a=1.0
def ratio(r, phi):
    f = lambda p: p + np.arctan2(a*np.cos(p/2), np.sqrt(r*r - a*a*np.cos(p/2)**2)) - phi
    p = brentq(f, 1e-12, 2*np.pi-1e-12)
    u = np.sqrt(r*r - a*a*np.cos(p/2)**2); c=np.sin(p/2); s=u-a*c
    return (a*c/(2*s+a*c))/(a/2*abs(np.sin(phi/2))/r)
for sg in [1.0,0.8,0.5,0.3,0.2,0.1]:
    phi = 2*np.arcsin(sg)
    rs = np.geomspace(max(1.2, 1.0001/np.sin(min(phi,np.pi/2))), 400, 40000)
    err = np.array([abs(ratio(r,phi)-1) for r in rs])
    bad = rs[err>0.05]
    print(f"sigma={sg}: exact error >5% for r up to {bad.max() if bad.size else float('nan'):.2f} a; (also check 2pi-phi:) {abs(ratio(50,2*np.pi-phi)-ratio(50,phi)):.2e}")
