import numpy as np
a=1.0; L=60.0
def exact_flux(rc, pc, dr, dp, I0, a=1.0, n=4001):
    # tight preimage box: psi = phi - delta, delta in [-asin(eps),asin(eps)]
    rmax = rc+dr/2; rmin = rc-dr/2
    dmax = np.arcsin(a/rmin)
    ps = np.linspace(pc-dp/2-dmax-0.01, pc+dp/2+dmax+0.01, n)
    ss = np.linspace(max(rmin-2*a,0), rmax+0.01, n)
    PS, SS = np.meshgrid(ps, ss); th=(PS+np.pi)/2
    X = a*np.cos(th) + SS*np.cos(PS); Y = a*np.sin(th)+SS*np.sin(PS)
    RR = np.hypot(X,Y); PH = np.mod(np.arctan2(Y,X),2*np.pi); C = np.sin(PS/2)
    inb = (np.abs(RR-rc)<dr/2)&(np.abs(PH-pc)<dp/2)
    return (I0*a*C*inb).sum()*(ps[1]-ps[0])/2*(ss[1]-ss[0])
# 2D-equivalent fast MC (sample directly the lit surface uniformly in projected area, which is exact for a parallel beam)
def run(alpha, N, rng):
    b = rng.uniform(-a, a, N); h = rng.uniform(0, L, N)
    x = -np.sqrt(a*a-b*b); y = b
    th = np.arctan2(y, x); psi = 2*th - np.pi
    s = h*np.tan(alpha)
    X = x + s*np.cos(psi); Y = y + s*np.sin(psi)
    return np.hypot(X,Y), np.mod(np.arctan2(Y,X),2*np.pi), np.sin(alpha)*2*a*L/N
bins = [(3,np.pi),(5,2*np.pi/3),(10,np.pi),(10,4*np.pi/3),(20,np.pi),(15,0.5)]
for alpha_deg in (35,55):
    al=np.radians(alpha_deg); I0=np.cos(al)
    cnt = np.zeros(len(bins)); W=0
    for seed in range(20):
        rng=np.random.default_rng(100+seed)
        r,ph,w = run(al, 5_000_000, rng); W=w
        for i,(rc,pc) in enumerate(bins):
            cnt[i] += ((np.abs(r-rc)<0.25)&(np.abs(ph-pc)<0.15)).sum()
    W = W/20
    for i,(rc,pc) in enumerate(bins):
        ex = exact_flux(rc,pc,0.5,0.3,I0)
        rat = cnt[i]*W/ex
        print(f"alpha={alpha_deg} ({rc},{pc:.3f}) counts={int(cnt[i])} MC/exact={rat:.4f}  z={(rat-1)*np.sqrt(cnt[i]):+.2f}")
