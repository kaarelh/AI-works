"""T3 section 4 checks: learning bridge validity regions.
(a) small-angle pendulum bridge: rigorous enclosure oracle + monotone (binary-search) certification;
(b) projectile drag bridge: rigorous analytic certificate (tight form) vs simulated true region;
(c) Lipschitz-grid certification (Lipschitz constant ESTIMATED -> flagged, not a proof);
(d) split-conformal tolerance vs an adversarial instance choice;
(e) coherence-only tolerance repair: drift and common-mode blindness."""
import numpy as np
from scipy.special import ellipk
from scipy.integrate import solve_ivp

# (a) small-angle bridge  T = T0 (1 + e(theta0)),  e = (2/pi) K(k^2) - 1, k = sin(theta0/2)
def e_exact(th): k = np.sin(th/2); return (2/np.pi)*ellipk(k**2) - 1
def e_enclosure(th):          # rigorous: c_n = ((2n-1)!!/(2n)!!)^2 decreasing, c1 = 1/4, c2 = 9/64
    k2 = np.sin(th/2)**2; return k2/4, k2/4 + (9/64)*k2**2/(1 - k2)
def monotone_certify(tau, lo=0.0, hi=np.pi*0.9, queries=20):
    """binary search on theta0; accept [0, t] iff upper enclosure at t <= tau. Sound because e is increasing
    (power series in k^2 with positive coefficients, k increasing on [0, pi))."""
    best = 0.0; q = 0
    for _ in range(queries):
        mid = (lo + hi)/2; q += 1
        if e_enclosure(mid)[1] <= tau: best, lo = mid, mid
        else: hi = mid
    return best, q
import math, mpmath as mpm
def e_up_iv(deg):
    """interval-arithmetic upper enclosure at theta0 = deg (degrees, given as a decimal string): rigorous"""
    mpm.iv.dps = 40
    th = mpm.iv.mpf(deg)*mpm.iv.pi/180; k2 = mpm.iv.sin(th/2)**2
    return k2/4 + mpm.iv.mpf(9)/64*k2**2/(1 - k2)
print("(a) small-angle bridge, monotone certification with rigorous enclosure oracle")
print("    (revised after verification: reported thresholds are truncated DOWNWARD to 0.001 deg and the")
print("     enclosure at the reported value is re-verified in mpmath interval arithmetic)")
for tau in [1e-3, 5e-3, 1e-2, 5e-2]:
    t, q = monotone_certify(tau)
    t_rep = math.floor(np.degrees(t)*1000)/1000          # round down: certifying less is always sound
    up = e_up_iv(f"{t_rep:.3f}")
    assert up.b <= mpm.mpf(tau), (tau, t_rep, up)         # rigorous: e <= e_up <= tau at the reported angle
    mpm.mp.dps = 30
    tex = mpm.findroot(lambda x: 2/mpm.pi*mpm.ellipk(mpm.sin(x/2)**2) - 1 - tau, mpm.radians(30))
    print(f"   tau={tau:.0e}: certified theta0 <= {t_rep:.3f} deg ({q} lazy-bisection queries; interval check e_up <= tau passed);"
          f" exact threshold {float(mpm.degrees(tex)):.4f} deg")

# (b) projectile with quadratic drag; x = k v0^2 / g
g = 9.81
def sim_range(kk, v0, th):
    def f(t, s):
        x, y, vx, vy = s; v = np.hypot(vx, vy)
        return [vx, vy, -kk*v*vx, -g - kk*v*vy]
    hit = lambda t, s: s[1]; hit.terminal = True; hit.direction = -1
    sol = solve_ivp(f, [0, 100], [0, 0, v0*np.cos(th), v0*np.sin(th)], events=hit, rtol=1e-11, atol=1e-12, first_step=1e-6)
    return sol.y_events[0][0][0]
def cert(x, th):
    """R/R0 in [1/(1+x) - x tan(th)/(1+x)^2, 1/(1-x)] for x < 1 (T3 Thm 3.6)."""
    if x >= 1: return None
    return 1/(1 + x) - x*np.tan(th)/(1 + x)**2, 1/(1 - x)
print("\n(b) projectile certificate")
for name, m, r, Cd in [("steel r=1cm", 7800*4/3*np.pi*0.01**3, 0.01, 0.47), ("ping-pong", 0.0027, 0.02, 0.5)]:
    kk = 0.5*1.2*Cd*np.pi*r**2/m; v0, th = 10.0, np.pi/4; R0 = v0**2*np.sin(2*th)/g; x = kk*v0**2/g
    Rs = sim_range(kk, v0, th); c = cert(x, th)
    print(f"   {name}: x={x:.4f} R0={R0:.3f} sim R={Rs:.3f} ({Rs/R0-1:+.2%}) cert:",
          None if c is None else f"[{c[0]*R0:.3f}, {c[1]*R0:.3f}]")
    if c: assert c[0]*R0 <= Rs <= c[1]*R0
th = np.pi/4; tol = 0.05
xs = np.linspace(1e-4, 0.3, 3000)
okc = [x for x in xs if cert(x, th) and cert(x, th)[0] >= 1 - tol and cert(x, th)[1] <= 1 + tol]
print("   analytic certified region (5%%, 45 deg): x <= %.4f" % max(okc))
v0 = 10.0; R0 = v0**2/g
xg = np.linspace(1e-4, 0.3, 300); err = np.array([abs(sim_range(x*g/v0**2, v0, th)/R0 - 1) for x in xg])
from scipy.optimize import brentq
x_true = brentq(lambda x: abs(sim_range(x*g/v0**2, v0, th)/R0 - 1) - tol, 0.03, 0.12, xtol=1e-7)
x_cert = (1/(1 - tol))**0.5 - 1      # closed form: at 45 deg the lower bound 1/(1+x) - x/(1+x)^2 = 1/(1+x)^2 is binding
print("   simulated true region: x <= %.4f (grid), %.5f (root-finding)" % (xg[np.argmax(err > tol) - 1], x_true))
print("   closed-form certificate threshold x = (1/0.95)^(1/2) - 1 = %.6f; ratio true/certified = %.2f" % (x_cert, x_true/x_cert))
# random check of the certificate over angles and x
rng = np.random.default_rng(0); bad = 0
for _ in range(300):
    x = rng.uniform(0, 0.9); a = rng.uniform(0.05, 1.5); Rr = sim_range(x*g/v0**2, v0, a)/(v0**2*np.sin(2*a)/g); c = cert(x, a)
    bad += not (c[0] - 1e-9 <= Rr <= c[1] + 1e-9)
print("   certificate violations on 300 random (x, angle):", bad)

# (c) Lipschitz-grid certification on x in [0, 0.3]; L estimated from data (NOT a proof)
Lhat = 1.2*np.max(np.abs(np.diff(err))/np.diff(xg))
print("\n(c) Lipschitz grid learner (L estimated = %.3f, x1.2 safety; flagged as an assumption)" % Lhat)
for h in [0.05, 0.02, 0.01]:
    grid = np.arange(0, 0.3 + 1e-12, h)
    eg = np.array([0 if q == 0 else abs(sim_range(q*g/v0**2, v0, th)/R0 - 1) for q in grid])
    reach = 0.0
    for q, e in zip(grid, eg):
        if e >= tol or q > reach + 1e-12: break
        reach = max(reach, q + (tol - e)/Lhat)
    print(f"   h={h}: {len(grid)} oracle calls, certified [0, {min(reach, 0.3):.4f}]")

# (d) split conformal on the small-angle bridge: calibration theta0 ~ U[0, 30 deg]; adversary picks 60 deg
n = 200; alpha = 0.1
cal = e_exact(np.radians(rng.uniform(0, 30, n)))
q = np.sort(cal)[int(np.ceil((n + 1)*(1 - alpha))) - 1]
test = e_exact(np.radians(rng.uniform(0, 30, 100000)))
print("\n(d) conformal tolerance %.2e; coverage on exchangeable test %.3f; adversarial instance (60 deg) error %.2e -> covered: %s"
      % (q, np.mean(test <= q), e_exact(np.radians(60)), e_exact(np.radians(60)) <= q))

# (e) coherence-only repair. Two schemas export the period ratio T/T0 for amplitude th:
#   S1 small-angle (value 1, tol eps1), S2 exact elliptic (value 1+e, tol eps2 ~ 0).  Incoherent iff |e| > eps1 + eps2.
#   Minimal repair widens eps1 to |e|. Adversary feeds amplitudes increasing toward 179 deg.
eps1 = 1e-3
for thd in [20, 60, 120, 170, 179, 179.9]:
    e = e_exact(np.radians(thd))
    if e > eps1: eps1 = e
    print(f"   after th={thd:6.1f} deg: eps1 = {eps1:.3g}")
print("   -> eps1 diverges (K(k^2) ~ log 1/(1-k^2)); S1 is never restricted, only made uninformative")
# common mode: two small-angle-based schemas (period formula; energy method) both export 1 -> always coherent
print("   common mode: S1 and S1' (both small-angle) always agree; at 120 deg the true ratio is %.3f, both exports (tol 1e-3) false" % (1 + e_exact(np.radians(120))))
