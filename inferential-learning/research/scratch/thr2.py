import numpy as np
from scipy.optimize import brentq
a=1.0
def ratio(r, phi):
    f = lambda p: p + np.arctan2(a*np.cos(p/2), np.sqrt(r*r - a*a*np.cos(p/2)**2)) - phi
    p = brentq(f, 1e-13, 2*np.pi-1e-13, xtol=1e-14)
    u = np.sqrt(r*r - a*a*np.cos(p/2)**2); c=np.sin(p/2); s=u-a*c
    return (a*c/(2*s+a*c))/(a/2*abs(np.sin(phi/2))/r)
def bound(eps,sig):
    m=np.arcsin(eps)/2; return 1-m/sig, (1+m/sig)/(np.sqrt(1-eps**2)-eps/2)
def r_rig(sg, tol=0.05):
    epsg=np.geomspace(1e-5,0.85,40000); lo,hi=bound(epsg,sg)
    good=(hi-1<=tol)&(1-lo<=tol)&(sg>np.arcsin(epsg)/2)
    return 1/epsg[good].max()
def r_ex(sg, tol=0.05):
    phi=2*np.arcsin(sg)
    rmin=max(1.0001, 1.0001/np.sin(min(phi,np.pi/2)))
    rs=np.geomspace(rmin, 2000, 6000)
    err=np.array([abs(ratio(r,phi)-1) for r in rs])
    bad=rs[err>tol]
    return bad.max() if bad.size else rmin, err[0]
for sg in [1.0,0.95,0.9,0.85,0.8,0.75,0.7,0.65,0.6,0.5,0.4,0.3,0.2,0.1,0.05]:
    rr, e0 = r_ex(sg); rg=r_rig(sg)
    print(f"sigma={sg:.2f}: rigorous r>={rg:7.2f}a  exact r_bad<={rr:7.2f}a  ratio={rg/rr:5.2f}  err at r_min={e0:.3f}")
