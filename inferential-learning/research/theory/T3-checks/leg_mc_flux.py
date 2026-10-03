import numpy as np
exec(open('leg_exact.py').read().split('# (4)')[0].split('# ---------- numerics ----------')[1])
rng = np.random.default_rng(5)
a=1.0; L=60.0; alpha=np.radians(45); N=40_000_000
b = rng.uniform(-a, a, N); h = rng.uniform(0, L, N)
w = np.sin(alpha)*2*a*L/N
x = -np.sqrt(a*a - b*b); y = b; nx, ny = x/a, y/a
dx = np.sin(alpha); dn = dx*nx
rx, ry = dx - 2*dn*nx, -2*dn*ny
t = h/np.cos(alpha); fx, fy = x + rx*t, y + ry*t
r = np.hypot(fx, fy); ph = np.mod(np.arctan2(fy, fx), 2*np.pi); I0=np.cos(alpha)
# exact flux in an annular sector via the analytic preimage: sample psi,s finely and integrate I0*a*c (measure dpsi/2 ds)
for rc, pc in [(3,np.pi),(5,2*np.pi/3),(10,np.pi),(10,4*np.pi/3),(20,np.pi)]:
    dr, dp = 0.5, 0.3
    m = (np.abs(r-rc)<dr/2)&(np.abs(ph-pc)<dp/2)
    Fmc = m.sum()*w
    ps = np.linspace(pc-0.6, pc+0.6, 3001); ss = np.linspace(max(rc-2,0), rc+2, 3001)
    PS, SS = np.meshgrid(ps, ss); X, Y, C = floor_point(PS, SS)
    RR = np.hypot(X,Y); PH = np.mod(np.arctan2(Y,X),2*np.pi)
    inb = (np.abs(RR-rc)<dr/2)&(np.abs(PH-pc)<dp/2)
    Fex = (I0*a*C*inb).sum()*(ps[1]-ps[0])/2*(ss[1]-ss[0])   # dtheta = dpsi/2
    print(rc, round(pc,3), "counts", m.sum(), "MC/exact flux = %.4f" % (Fmc/Fex))
