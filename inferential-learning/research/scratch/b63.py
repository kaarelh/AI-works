import numpy as np
from scipy.optimize import brentq
def G(rr, ph):  # exact E/I0, a=1, point sun, lit
    ph = np.mod(ph, 2*np.pi)
    if ph <= np.arcsin(1/rr) or ph >= 2*np.pi-np.arcsin(1/rr): return 0.0
    f=lambda p: p+np.arctan2(np.cos(p/2), np.sqrt(rr*rr-np.cos(p/2)**2))-ph
    p=brentq(f,1e-13,2*np.pi-1e-13); u=np.sqrt(rr*rr-np.cos(p/2)**2); c=np.sin(p/2); s=u-c
    return c/(2*s+c)
def bound(eps,sig):
    m=np.arcsin(eps)/2; return 1-m/sig, (1+m/sig)/(np.sqrt(1-eps**2)-eps/2)
rng=np.random.default_rng(4)
worst_viol=0; cnt=0
for ds in [4.65e-3, 0.05, 0.15]:
    for trial in range(300):
        alpha=np.radians(rng.uniform(30,60)); amin=np.radians(30)
        rr=rng.uniform(3,200); sg=rng.uniform(0.05,1); ph=2*np.arcsin(sg)*(1 if rng.random()<.5 else -1)
        D=np.arcsin(np.sin(ds)/np.sin(amin))
        m=np.arcsin(1/rr)/2
        if not (sg-D/2>m): continue
        # sample sun disc directions: uniform disc of angular radius ds around (alpha, azimuth 0), radiance with limb darkening
        K=400; rho=ds*np.sqrt(rng.random(K)); ang=rng.uniform(0,2*np.pi,K)
        sun=np.array([np.sin(alpha),0,np.cos(alpha)])  # direction TO sun is (-sin,0,cos); use travel dir
        # build orthonormal basis around the sun-centre direction (pointing toward sun from ground)
        c0=np.array([-np.sin(alpha),0,np.cos(alpha)]); e1=np.array([0,1.0,0]); e2=np.cross(c0,e1)
        dirs=np.cos(rho)[:,None]*c0+np.sin(rho)[:,None]*(np.cos(ang)[:,None]*e1+np.sin(ang)[:,None]*e2)
        wts=1-0.6*(1-np.sqrt(np.maximum(0,1-(rho/ds)**2)))  # limb darkening
        zen=np.arccos(dirs[:,2]); beta=np.arctan2(-dirs[:,1],-dirs[:,0])  # azimuth of travel direction
        cosz=np.cos(zen)
        Esum=sum(G(rr, ph-b)*cz*w for b,cz,w in zip(beta,cosz,wts)); I0=np.sum(cosz*wts)
        E0=abs(np.sin(ph/2))/(2*rr)
        R=(Esum/I0)/E0
        lo2,hi2=bound(1/rr, sg-D/2)
        L_=(1-D/(2*sg))*lo2; H_=(1+D/(2*sg))*hi2
        cnt+=1
        if R<L_-1e-12 or R>H_+1e-12: worst_viol+=1; print("VIOL", ds, rr, sg, R, L_, H_)
        # also check lit condition used (need r <= L tan(alpha_min - ds)) -- here L infinite
print("checked", cnt, "violations", worst_viol)
