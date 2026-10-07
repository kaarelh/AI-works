import numpy as np
rng = np.random.default_rng(0)
def simulate(alpha, a=1.0, L=400.0, N=4_000_000, I=1.0):
    # sunlight travels in direction d=(sin a, 0, -cos a); irradiance I on a plane normal to beam.
    # Sample rays uniformly over the cylinder's projected cross-section: horizontal impact parameter b in [-a,a],
    # height of hit point h in [0,L] (vertical cylinder x^2+y^2=a^2, light from -x side).
    b = rng.uniform(-a, a, N); h = rng.uniform(0, L, N)
    # flux per ray: total flux intercepted = I*sin(alpha)*(2a)*L (horizontal component through vertical cross-section)
    w = I*np.sin(alpha)*2*a*L/N
    # hit point on lit side: x=-sqrt(a^2-b^2), y=b ; outward normal n=(x,y)/a
    x = -np.sqrt(a*a-b*b); y = b
    nx, ny = x/a, y/a
    dx, dy, dz = np.sin(alpha), 0.0, -np.cos(alpha)
    dn = dx*nx + dy*ny
    rx, ry, rz = dx-2*dn*nx, dy-2*dn*ny, dz
    t = h/np.cos(alpha)           # time to floor (|rz|=cos alpha)
    fx, fy = x + rx*t, y + ry*t
    # remove rays that would hit the cylinder again: none for convex cylinder (reflected rays leave)
    r = np.hypot(fx, fy); phi = np.mod(np.arctan2(fy, fx), 2*np.pi)  # phi=0 is the anti-sun (+x) direction
    return r, phi, w
for alpha_deg in [30, 50, 70]:
    al = np.radians(alpha_deg)
    r, phi, w = simulate(al)
    I0 = np.cos(al)  # direct floor illuminance for I=1
    R = 400*np.tan(al)
    rb = np.array([0.15, 0.3, 0.5])*R; dr = 0.04*R
    out=[]
    for rc in rb:
        for pc in [np.pi/3, np.pi/2, np.pi, 4*np.pi/3]:
            dp = 0.1
            m = (np.abs(r-rc)<dr/2) & (np.abs(phi-pc)<dp/2)
            E_mc = m.sum()*w/(rc*dr*dp)
            E_th = 1.0*I0/2*np.abs(np.sin(pc/2))/rc
            out.append(E_mc/E_th)
    print(alpha_deg, "ratio MC/theory: mean %.4f min %.4f max %.4f" % (np.mean(out), np.min(out), np.max(out)), " R/a=%.0f"%R)
