import numpy as np
from scipy.optimize import brentq
a=1.0
def phi_of(psi, r):
    u=np.sqrt(r*r - (a*np.cos(psi/2))**2)
    return psi + np.arctan2(a*np.cos(psi/2), u)
def ratio(r, sig):
    # floor point with sin(phi/2)=sig, phi in (0,pi]; find psi
    phi = 2*np.arcsin(sig)
    if phi <= np.arcsin(a/r) + 1e-12: return np.inf   # not in the image of the lit side
    psi = brentq(lambda p: phi_of(p, r) - phi, 1e-14, 2*np.pi-1e-14, xtol=1e-15)
    c=np.sin(psi/2); u=np.sqrt(r*r-(a*np.cos(psi/2))**2)
    return (c/sig)*2*r/(2*u - a*c)
def bound(r, sig):
    eps=a/r; m=np.arcsin(eps)/2
    return max((1+m/sig)/(np.sqrt(1-eps**2)-eps/2)-1, m/sig)
tol=0.05
def r_bad(sig):   # largest r with exact error > tol (scan downward from large r)
    rs=np.exp(np.linspace(np.log(1.0001), np.log(400), 6000))
    errs=np.array([abs(ratio(r,sig)-1) for r in rs])
    idx=np.where(errs>tol)[0]
    if len(idx)==0: return None
    i=idx[-1]
    return brentq(lambda r: abs(ratio(r,sig)-1)-tol, rs[i], rs[i+1])
def r_rig(sig):
    return brentq(lambda r: bound(r,sig)-tol, 1.2, 1e5)
for sig in [1.0, 0.9, 0.85, 0.8, 0.75, 0.7071, 0.7, 0.65, 0.5, 0.3, 0.1]:
    rb=r_bad(sig); rr=r_rig(sig)
    print(f"sigma={sig}: rigorous 5% radius {rr:.2f}a, exact error >5% only for r<= {rb if rb is None else round(rb,2)}a, ratio {'inf' if rb is None else round(rr/rb,2)}")
# phi = pi exact ratio check
print("phi=pi r=20:", ratio(20,1.0), 2*20/(2*20-1))
# first-order formula check
for r,sig in [(20,0.5),(100,0.7071),(50,0.3)]:
    eps=a/r; phi=2*np.arcsin(sig)
    psi=brentq(lambda p: phi_of(p, r)-phi,1e-14,2*np.pi-1e-14,xtol=1e-15); c=np.sin(psi/2)
    print(f"r={r} sig={sig}: sig-c={sig-c:.4e}, eps(1-sig^2)/2={eps*(1-sig**2)/2:.4e}; ratio-1={ratio(r,sig)-1:.3e}, first order eps(2sig^2-1)/(2sig)={eps*(2*sig**2-1)/(2*sig):.3e}")
# tol -> 0 scaling near sigma=1/sqrt2
for t in [0.05, 0.01, 0.002]:
    sig=0.7
    rr=brentq(lambda r: bound(r,sig)-t, 1.2, 1e7)
    rs=np.exp(np.linspace(np.log(1.05), np.log(rr*2), 4000)); errs=np.array([abs(ratio(r,sig)-1) for r in rs]); idx=np.where(errs>t)[0]
    rb=brentq(lambda r: abs(ratio(r,sig)-1)-t, rs[idx[-1]], rs[idx[-1]+1])
    print(f"tol={t}: sigma=0.7 rigorous {rr:.1f}a exact {rb:.2f}a ratio {rr/rb:.1f}")
