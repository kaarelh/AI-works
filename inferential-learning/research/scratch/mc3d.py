import numpy as np
rng = np.random.default_rng(11)
a=1.0; L=60.0
def run(alpha, N):
    d = np.array([np.sin(alpha), 0, -np.cos(alpha)])
    # launch rays on a plane perpendicular to d, covering the cylinder silhouette
    e1 = np.array([0,1.0,0]); e2 = np.cross(d, e1)  # perpendicular basis
    # silhouette in (e1,e2) coordinates: y in [-a,a], along e2 the cylinder spans height projection
    # sample generously
    u = rng.uniform(-a, a, N)
    # e2 coordinate range: project points (x,z) with x in[-a,a], z in[0,L]
    corners = np.array([[x,0,z] for x in (-a,a) for z in (0,L)])
    pr = corners@e2
    v = rng.uniform(pr.min()-1, pr.max()+1, N)
    area = 2*a*(pr.max()-pr.min()+2)
    O = -50*d[None,:] + u[:,None]*e1[None,:] + v[:,None]*e2[None,:]
    # intersect with infinite cylinder x^2+y^2=a^2
    A = d[0]**2 + d[1]**2
    B = 2*(O[:,0]*d[0] + O[:,1]*d[1]); C = O[:,0]**2 + O[:,1]**2 - a*a
    disc = B*B - 4*A*C
    hit = disc >= 0
    t = (-B - np.sqrt(np.where(hit, disc, 0)))/(2*A)
    X = O + t[:,None]*d[None,:]
    hit &= (X[:,2] >= 0) & (X[:,2] <= L)
    X = X[hit]
    n = np.stack([X[:,0]/a, X[:,1]/a, 0*X[:,0]], 1)
    dn = n@d
    R = d[None,:] - 2*dn[:,None]*n
    tt = -X[:,2]/R[:,2]
    F = X + tt[:,None]*R
    w = area/N  # irradiance I=1 normal to beam
    return np.hypot(F[:,0],F[:,1]), np.mod(np.arctan2(F[:,1],F[:,0]),2*np.pi), w, np.cos(alpha), hit.sum()*w
def exact_flux(rc, pc, dr, dp, I0, a=1.0):
    ps = np.linspace(pc-0.8, pc+0.8, 2001); ss = np.linspace(max(rc-3,0), rc+3, 2001)
    PS, SS = np.meshgrid(ps, ss); th=(PS+np.pi)/2
    X = a*np.cos(th) + SS*np.cos(PS); Y = a*np.sin(th)+SS*np.sin(PS)
    RR = np.hypot(X,Y); PH = np.mod(np.arctan2(Y,X),2*np.pi); C = np.sin(PS/2)
    inb = (np.abs(RR-rc)<dr/2)&(np.abs(PH-pc)<dp/2)
    return (I0*a*C*inb).sum()*(ps[1]-ps[0])/2*(ss[1]-ss[0])
for alpha_deg in (35, 55):
    al = np.radians(alpha_deg)
    tot_r=[];tot_p=[];W=None
    for k in range(4):
        r, ph, w, I0, intercepted = run(al, 4_000_000); tot_r.append(r); tot_p.append(ph)
    r = np.concatenate(tot_r); ph = np.concatenate(tot_p); w = w/4
    print(f"alpha={alpha_deg}: intercepted flux (MC) vs 2aL sin(alpha) = {len(r)*w:.3f} vs {2*a*L*np.sin(al):.3f}")
    for rc, pc in [(3,np.pi),(5,2*np.pi/3),(10,np.pi),(10,4*np.pi/3),(20,np.pi),(15,0.5)]:
        dr, dp = 0.5, 0.3
        m = (np.abs(r-rc)<dr/2)&(np.abs(ph-pc)<dp/2)
        print(f"  (r,phi)=({rc},{pc:.3f}) counts={m.sum():6d} MC/exact={m.sum()*w/exact_flux(rc,pc,dr,dp,I0):.4f}  (1-sigma ~ {1/np.sqrt(max(m.sum(),1)):.4f})")
