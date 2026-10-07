import numpy as np
from scipy.optimize import brentq
a=1.0
def phi_of_psi(psi,r):
    u=np.sqrt(r*r-(a*np.cos(psi/2))**2)
    return psi+np.arctan2(a*np.cos(psi/2),u)
def ratio_exact(r,phi):
    # E/E0 with E0 = a/2 * sigma / r (I0=1)
    g=lambda p: phi_of_psi(p,r)-phi
    if g(1e-12)*g(2*np.pi-1e-12)>0: return 0.0
    psi=brentq(g,1e-12,2*np.pi-1e-12)
    u=np.sqrt(r*r-(a*np.cos(psi/2))**2); c=np.sin(psi/2)
    E=a*c/(2*u-a*c)
    sig=abs(np.sin(phi/2))
    return E/(a/2*sig/r)
def bound(eps,sig):
    m=np.arcsin(eps)/2
    lo=1-m/sig; hi=(1+m/sig)/(np.sqrt(1-eps**2)-eps/2)
    return max(hi-1,1-lo)
# bound-certified 5% thresholds
for sig in [1,0.5,0.3,0.1]:
    rr=brentq(lambda r: bound(1/r,sig)-0.05, 1.2, 1e4)
    # exact threshold: largest r with |ratio-1|>0.05 at this sigma (phi=2 asin(sig))
    phi=2*np.arcsin(sig)
    f=lambda r: abs(ratio_exact(r,phi)-1)-0.05
    rs=np.linspace(1.2,300,6000); vals=[f(x) for x in rs]
    last=None
    for i in range(len(rs)-1):
        if vals[i]>0 and vals[i+1]<=0: last=brentq(f,rs[i],rs[i+1])
    print(f"sigma={sig}: bound certifies 5% from r={rr:.2f}a ; exact error >5% up to r={last}")
# max exact error on honest domain
worst=0;wl=None
for r in np.linspace(20,34,57):
    for sig in np.linspace(0.5,1,51):
        for phi in [2*np.arcsin(sig), 2*np.pi-2*np.arcsin(sig)]:
            q=ratio_exact(r,phi)
            if abs(q-1)>worst: worst=abs(q-1); wl=(r,sig,q)
print("honest domain max |exact/E0-1|",worst,wl)
# V7 true error
lo=[];
for r in np.linspace(20,34,29):
    for sig in np.linspace(0.5,1,26):
        q=ratio_exact(r,2*np.arcsin(sig))
        for al in np.radians(np.linspace(30,60,31)):
            ans=1.15*np.cos(al)**(1/50)
            lo.append(abs(q/ans-1))
print("V7 max |E/ans-1|",max(lo))
print("V9 at r=1.05, phi=pi:",ratio_exact(1.05,np.pi)-1)
print("ratio at r=20, phi=pi:",ratio_exact(20,np.pi), "sigma=0.5:",ratio_exact(20,2*np.arcsin(0.5)))
