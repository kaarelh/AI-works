"""Projectile with quadratic drag: rigorous differential-inequality export certificate
vs simulation; the dimensionless side condition x = k v0^2/g; analytic vs simulation-certified
validity regions for a 5% range tolerance."""
import numpy as np
from scipy.integrate import solve_ivp
g = 9.81
def sim_range(kk, v0, th):
    def f(t, s):
        x, y, vx, vy = s; v = np.hypot(vx, vy)
        return [vx, vy, -kk*v*vx, -g - kk*v*vy]
    hit = lambda t, s: s[1]; hit.terminal = True; hit.direction = -1
    s0 = [0, 0, v0*np.cos(th), v0*np.sin(th)]
    sol = solve_ivp(f, [0, 100], s0, events=hit, rtol=1e-11, atol=1e-12, first_step=1e-6)
    return sol.y_events[0][0][0]
def certificate(x, th):
    """R/R0 interval from |a_drag| <= k v0^2 = x g, xdd<=0, valid iff x<1"""
    if x >= 1: return None
    return (1/(1+x) - x*np.tan(th)/(1-x)**2, 1/(1-x))
for name, m, r, Cd in [("steel", 7800*4/3*np.pi*0.01**3, 0.01, 0.47), ("ping-pong", 0.0027, 0.02, 0.5)]:
    kk = 0.5*1.2*Cd*np.pi*r**2/m; v0, th = 10.0, np.pi/4
    R0 = v0**2*np.sin(2*th)/g; x = kk*v0**2/g
    Rs = sim_range(kk, v0, th); c = certificate(x, th)
    print(f"{name}: m={m*1e3:.2f} g, k={kk:.4e}/m, x=a_d/g={x:.4f}, R0={R0:.3f}, sim R={Rs:.3f} ({Rs/R0-1:+.2%})",
          "cert:", None if c is None else f"[{c[0]*R0:.3f}, {c[1]*R0:.3f}]")
    if c: assert c[0]*R0 <= Rs <= c[1]*R0
# validity regions for tolerance 5% at 45 deg, as functions of x (dimensionless: R/R0 depends only on x, th)
th = np.pi/4; tol = 0.05
xs = np.linspace(0.0005, 0.3, 600)
cert_ok = [x for x in xs if certificate(x, th) and certificate(x, th)[0] >= 1-tol and certificate(x, th)[1] <= 1+tol]
print("analytic certificate region: x <= %.4f" % max(cert_ok))
# simulation: in dimensionless form R/R0 depends on x only (fix v0=10, vary k)
v0 = 10.0; R0 = v0**2/g
err = np.array([abs(sim_range(x*g/v0**2, v0, th)/R0 - 1) for x in xs])
print("true region (sim): x <= %.4f ; err slope near 0: %.3f" % (xs[np.argmax(err > tol)-1], err[5]/xs[5]))
# check dimensionless claim: R/R0 depends only on x (vary v0 with x fixed)
for v in [3.0, 10.0, 30.0]:
    x = 0.05; print("v0=%4.1f x=0.05 R/R0=%.6f" % (v, sim_range(x*g/v**2, v, th)/(v**2/g)))
# Lipschitz certification demo on x in [0,0.3]: L = max slope of err (estimated, flagged), grid queries
Lhat = np.max(np.abs(np.diff(err))/np.diff(xs))
print("estimated Lipschitz const of err(x): %.3f" % Lhat)
for h in [0.05, 0.02, 0.01, 0.005]:
    grid = np.arange(0, 0.3+1e-12, h); eg = np.array([0 if q == 0 else abs(sim_range(q*g/v0**2, v0, th)/R0-1) for q in grid])
    Lc = 1.2*Lhat
    reach = max([q + (tol-e)/Lc for q, e in zip(grid, eg) if e < tol and all(eg[grid <= q] < tol)])
    # certified region is a union of balls; report the connected component containing 0
    print(f"h={h}: queries={len(grid)}, certified [0, {min(reach, 0.3):.4f}]")
