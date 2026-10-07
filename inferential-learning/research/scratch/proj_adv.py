import numpy as np
from scipy.integrate import solve_ivp
g=9.81
def rng_range(x, th, sfun, v0=10.0, lift=None):
    k = x*g/v0**2
    def f(t, s):
        X,Y,vx,vy = s; v = np.hypot(vx,vy)
        kap = k*v*sfun(t)
        ax, ay = -kap*vx, -g-kap*vy
        if lift is not None:
            # zero-work force of magnitude <= k v^2, perpendicular to v, direction chosen by lift(t, vx, vy) in {+1,-1}
            sgn = lift(t, vx, vy); ax += sgn*k*v*(-vy); ay += sgn*k*v*(vx)
        return [vx, vy, ax, ay]
    hit = lambda t,s: s[1]; hit.terminal=True; hit.direction=-1
    sol = solve_ivp(f,[0,200],[0,0,v0*np.cos(th),v0*np.sin(th)],events=hit,rtol=1e-10,atol=1e-12,first_step=1e-6, max_step=0.01)
    R0 = v0**2*np.sin(2*th)/g
    return sol.y_events[0][0][0]/R0
def cert(x, th): return 1/(1+x) - x*np.tan(th)/(1+x)**2, 1/(1-x)
rs = np.random.default_rng(1)
worst_lo = 1e9; worst_hi = -1e9; viol = 0
for trial in range(400):
    x = rs.uniform(0.01, 0.95); th = rs.uniform(0.05, 1.5)
    T0 = 2*10*np.sin(th)/g
    sw = np.sort(rs.uniform(0, T0*1.5, rs.integers(1,6)))
    start = rs.integers(0,2)
    sfun = lambda t, sw=sw, start=start: float((start + np.searchsorted(sw, t)) % 2)
    r = rng_range(x, th, sfun)
    lo, hi = cert(x, th)
    if not (lo - 1e-9 <= r <= hi + 1e-9): viol += 1; print("VIOL", x, th, r, lo, hi)
    worst_lo = min(worst_lo, r - lo); worst_hi = max(worst_hi, r - hi)
print("bang-bang drag: violations", viol, "min(R-lo)", worst_lo, "max(R-hi)", worst_hi)
# zero-work lift force (dissipative in the weak sense a.v<=0), |a|<=k v^2: does R exceed R0/(1-x)?
for x in [0.1, 0.3, 0.5]:
    for thd in [20, 45, 70]:
        th = np.radians(thd)
        best = -1
        for pol in ['up', 'forward', 'desc_up']:
            if pol=='up': lift = lambda t,vx,vy: 1.0          # rotate v by +90 deg: upward-ish
            elif pol=='forward': lift = lambda t,vx,vy: 1.0 if vy<0 else -1.0
            else: lift = lambda t,vx,vy: 1.0 if vy<0 else 0.0
            r = rng_range(x, th, lambda t: 0.0, lift=lift)
            best = max(best, r)
        lo, hi = cert(x, th)
        print(f"lift x={x} th={thd}: max R/R0={best:.4f}  cert hi={hi:.4f}  {'EXCEEDS' if best>hi else ''}")
