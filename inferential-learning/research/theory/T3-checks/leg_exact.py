"""T3 worked example: EuPhO 2025 T1(a) (chair leg), as reconstructed in L9 section 8.2.
Top model: vertical specular cylinder radius a, lit height L, point sun with elevation-from-vertical alpha,
rays travelling in +x (sun on the -x side), floor illuminance of direct light I0 = I cos(alpha).
Checks:
 (1) symbolic Jacobian of (theta, s) -> floor point, exact reflected illuminance E = I0 a c / (2 s + a c);
 (2) decomposition P = (s + a c) e(psi) + a cos(psi/2) e(psi + pi/2), c = sin(psi/2), psi = 2 theta - pi;
 (3) flux conservation; alpha-independence of E at a fixed floor point;
 (4) exact E vs the L9 Monte Carlo model;
 (5) rigorous thin-leg bridge bound  E/E0 in [1 - m/sig, (1 + m/sig)/(sqrt(1-eps^2) - eps/2)],
     eps = a/r, sig = sin(phi/2), m = arcsin(eps)/2, checked on a dense grid;
 (6) export domains for a 5% tolerance (rigorous bound vs exact error);
 (7) finite-sun-size bridge composed with the thin-leg bridge."""
import numpy as np, sympy as sp

# ---------- (1)-(3) symbolic ----------
a, s, th, al, I = sp.symbols('a s theta alpha I', positive=True)
P = sp.Matrix([a*sp.cos(th) + s*sp.cos(2*th - sp.pi), a*sp.sin(th) + s*sp.sin(2*th - sp.pi)])
J = sp.simplify(P.jacobian([th, s]).det())
print("det d(P)/d(theta,s) =", J)
assert sp.simplify(J - (a*sp.cos(th) - 2*s)) == 0
# power per dtheta ds: I sin(al) * a|cos th| dtheta dh with dh = ds / tan(al)  =>  I cos(al) a |cos th| dtheta ds
c = -sp.cos(th)                      # |cos th| on the lit side th in (pi/2, 3pi/2)
E = sp.simplify(I*sp.cos(al)*a*c/(2*s + a*c))   # |J| = 2s - a cos th = 2s + a c
print("exact E =", E, " ; d/d alpha at fixed (theta,s) after I0 = I cos(alpha) substitution:",
      sp.simplify(sp.diff(E.subs(I, sp.Symbol('I0')/sp.cos(al)), al)))
psi = sp.Symbol('psi')
thp = (psi + sp.pi)/2
Pp = P.subs(th, thp)
cc = sp.sin(psi/2)
dec = sp.Matrix([sp.cos(psi), sp.sin(psi)])*(s + a*cc) + sp.Matrix([-sp.sin(psi), sp.cos(psi)])*a*sp.cos(psi/2)
assert all(sp.simplify(sp.expand_trig(x)) == 0 for x in (Pp - dec)), "decomposition failed"
print("decomposition P = (s + a c) e(psi) + a cos(psi/2) e(psi+pi/2): OK")
# flux: integral over theta in (pi/2, 3pi/2), s in [0, R] of E*|J| = I cos(al) a c  -> 2 a R I cos(al)
R_, L_ = sp.symbols('R L', positive=True)
flux = sp.integrate(sp.integrate(I*sp.cos(al)*a*c, (s, 0, R_)), (th, sp.pi/2, 3*sp.pi/2))
print("total reflected flux =", sp.simplify(flux), "; with R = L tan(alpha):", sp.simplify(flux.subs(R_, L_*sp.tan(al))))

# ---------- numerics ----------
def floor_point(psi, s, a=1.0):
    c = np.sin(psi/2)
    u = s + a*c
    x = u*np.cos(psi) - a*np.cos(psi/2)*np.sin(psi)
    y = u*np.sin(psi) + a*np.cos(psi/2)*np.cos(psi)
    return x, y, c
def E_exact(psi, s, a=1.0, I0=1.0):
    c = np.sin(psi/2); return I0*a*c/(2*s + a*c)
def E_thin(r, phi, a=1.0, I0=1.0):
    return I0*a/2*np.abs(np.sin(phi/2))/r

# (4) against the L9 Monte Carlo model (same physics, sampled rays)
rng = np.random.default_rng(1)
def mc(alpha, a=1.0, L=60.0, N=6_000_000):
    b = rng.uniform(-a, a, N); h = rng.uniform(0, L, N)
    w = np.sin(alpha)*2*a*L/N
    x = -np.sqrt(a*a - b*b); y = b; nx, ny = x/a, y/a
    dx, dz = np.sin(alpha), -np.cos(alpha); dn = dx*nx
    rx, ry = dx - 2*dn*nx, -2*dn*ny
    t = h/np.cos(alpha); fx, fy = x + rx*t, y + ry*t
    return np.hypot(fx, fy), np.mod(np.arctan2(fy, fx), 2*np.pi), w
al0 = np.radians(45); r_mc, ph_mc, w = mc(al0); I0 = np.cos(al0)
print("\n(4) exact-cylinder formula vs Monte Carlo (alpha=45 deg, L=60a):")
for rc in [3, 5, 10, 20]:
    row = []
    for pc in [2*np.pi/3, np.pi, 4*np.pi/3]:
        dr, dp = 0.2, 0.1
        msk = (np.abs(r_mc - rc) < dr/2) & (np.abs(ph_mc - pc) < dp/2)
        Emc = msk.sum()*w/(rc*dr*dp)
        # exact E at the bin centre: solve for (psi, s) by Newton from thin guess
        ps, ss = pc, rc
        for _ in range(50):
            x, y, _c = floor_point(ps, ss); F = np.array([np.hypot(x, y) - rc, np.angle(np.exp(1j*(np.arctan2(y, x) - pc)))])
            d = 1e-7; x1, y1, _ = floor_point(ps + d, ss); x2, y2, _ = floor_point(ps, ss + d)
            Jm = np.array([[(np.hypot(x1, y1) - np.hypot(x, y))/d, (np.hypot(x2, y2) - np.hypot(x, y))/d],
                           [np.angle(np.exp(1j*(np.arctan2(y1, x1) - np.arctan2(y, x))))/d, np.angle(np.exp(1j*(np.arctan2(y2, x2) - np.arctan2(y, x))))/d]])
            ps, ss = np.array([ps, ss]) - np.linalg.solve(Jm, F)
        Eex = E_exact(ps, ss, I0=I0)
        row.append((Emc/Eex, Eex/E_thin(rc, pc, I0=I0)))
    print(f"  r={rc:>2}a  MC/exact = {', '.join(f'{p[0]:.3f}' for p in row)}   exact/thin = {', '.join(f'{p[1]:.4f}' for p in row)}")

# (5) rigorous bound vs exact ratio on a dense (psi, s) grid
def bound(eps, sig):
    m = np.arcsin(eps)/2
    return 1 - m/sig, (1 + m/sig)/(np.sqrt(1 - eps**2) - eps/2)
psis = np.linspace(1e-3, 2*np.pi - 1e-3, 2001); ss = np.concatenate([np.linspace(0, 5, 501), np.geomspace(5, 1e4, 800)])
PS, SS = np.meshgrid(psis, ss)
X, Y, C = floor_point(PS, SS); Rr = np.hypot(X, Y); Phi = np.mod(np.arctan2(Y, X), 2*np.pi)
ratio = E_exact(PS, SS)/E_thin(Rr, Phi)
eps = 1/Rr; sig = np.abs(np.sin(Phi/2)); lo, hi = bound(eps, sig)
ok = (eps < 0.8) & (sig > np.arcsin(np.minimum(eps, 1))/2 + 1e-9)
viol = ok & ((ratio < lo - 1e-12) | (ratio > hi + 1e-12))
print(f"\n(5) grid points checked: {ok.sum()}, bound violations: {viol.sum()}")
assert viol.sum() == 0
# tightness at phi = pi: exact ratio is 2r/(2r - a)
print("    at phi=pi, r=20a: exact ratio", 40/39, " bound", bound(0.05, 1.0))

# (6) export domains for tolerance 5%
tol = 0.05
print("\n(6) minimal r/a for |E/E0 - 1| <= 5%, by sigma = sin(phi/2):")
for sg in [1.0, 0.8, 0.5, 0.3, 0.2, 0.1]:
    epsg = np.geomspace(1e-5, 0.7, 20000); lo_, hi_ = bound(epsg, sg)
    good = (hi_ - 1 <= tol) & (1 - lo_ <= tol)
    r_rig = 1/epsg[good].max()
    # exact: worst ratio over points with sigma >= sg ... evaluate along level set using the grid
    sel = ok & (np.abs(sig - sg) < 0.01)
    bad = sel & (np.abs(ratio - 1) > tol)
    r_ex = Rr[bad].max() if bad.any() else float('nan')
    print(f"   sigma={sg:.1f}: rigorous r >= {r_rig:7.1f} a ;  exact error exceeds 5% only for r <= {r_ex:6.1f} a")

# (7) finite sun (angular radius ds) composed with thin-leg bridge.
# Sun directions within ds of the centre have azimuth within Delta = arcsin(sin ds / sin alpha) (alpha >= ds).
# E_fs(r,phi)/I0 lies between min and max of exact E(r,phi')/I0 over |phi'-phi| <= Delta (rotational symmetry;
# the geometric factor does not depend on elevation), provided r <= L tan(alpha_min - ds).
ds = 4.65e-3
def composite(eps, sig, alpha_min):
    D = np.arcsin(np.sin(ds)/np.sin(alpha_min)); sig2 = sig - D/2
    lo2, hi2 = bound(eps, sig2)
    up = (1 + D/(2*sig))*hi2 - 1; dn = 1 - (1 - D/(2*sig))*lo2
    return max(up, dn), D
for amin in [np.radians(20), np.radians(40)]:
    for (e_, s_) in [(1/40, 1.0), (1/40, 0.5), (1/100, 0.3), (1/100, 0.1)]:
        b, D = composite(e_, s_, amin)
        print(f"   alpha_min={np.degrees(amin):.0f} deg (Delta={D*1e3:.2f} mrad): r=a/{e_:.3f}... r/a={1/e_:.0f}, sigma={s_}: total rel. error <= {b:.4f}")

# (8) exact (not bounded) thin-leg error on the checker's domain r in [20a, 34a], sin(phi/2) >= 0.5 (point sun)
psis = np.linspace(1e-4, 2*np.pi - 1e-4, 4001); ss = np.linspace(15, 40, 1201)
PS, SS = np.meshgrid(psis, ss); X, Y, C = floor_point(PS, SS); Rr = np.hypot(X, Y); Phi = np.mod(np.arctan2(Y, X), 2*np.pi)
dom = (Rr >= 20) & (Rr <= 34) & (np.abs(np.sin(Phi/2)) >= 0.5)
rat = E_exact(PS, SS)/E_thin(Rr, Phi)
print(f"\n(8) exact thin-leg error on domain: max |E/E0-1| = {np.max(np.abs(rat[dom]-1)):.4f} (rigorous bound there: {max(b-1 if i else 1-b for i,b in enumerate(bound(1/20, 0.5))):.4f})")
