"""T3 sanity checks: pendulum worked example.
Checks: small-angle export certificate, physical-pendulum corrections, air effects
(buoyancy, added mass, quadratic drag) on the period, and monotonicity of the
drag-induced period shift used for validity-region certification."""
import numpy as np
from scipy.special import ellipk
from scipy.integrate import solve_ivp

g, L = 9.81, 1.000
th0 = np.deg2rad(10.0)
T0 = 2*np.pi*np.sqrt(L/g)
k = np.sin(th0/2)
ratio_exact = (2/np.pi)*ellipk(k**2)          # scipy uses parameter m=k^2
lo = 1 + k**2/4
hi_series = 1 + k**2/4 + (9/64)*k**4/(1-k**2)
hi_crude = 1/np.cos(th0/2)
print(f"T0 = {T0:.6f} s")
print(f"T/T0 exact = {ratio_exact:.8f}; series cert [{lo:.8f}, {hi_series:.8f}]; crude upper {hi_crude:.6f}")
assert lo <= ratio_exact <= hi_series <= hi_crude
print(f"T exact = {T0*ratio_exact:.6f}; crude export interval [{T0:.4f}, {T0*hi_crude:.4f}]")

# check the series coefficient monotonicity claim c_n = ((2n-1)!!/(2n)!!)^2 decreasing
c = [1.0]
for n in range(1, 30):
    c.append(c[-1]*((2*n-1)/(2*n))**2)
assert all(c[i+1] <= c[i] for i in range(len(c)-1)); print("c_n decreasing; c1,c2 =", c[1], c[2])
# check upper bounds over a range of amplitudes
for deg in [1, 5, 10, 20, 40, 60, 80, 100, 120, 150, 170]:
    kk = np.sin(np.deg2rad(deg)/2); r = (2/np.pi)*ellipk(kk**2)
    assert 1+kk**2/4 <= r <= min(1+kk**2/4+(9/64)*kk**4/(1-kk**2), 1/np.sqrt(1-kk**2)), deg
print("series certificate valid on 1..170 deg")

# steel ball bob
rho_s, rho_a, r, Cd = 7850.0, 1.2, 0.01, 0.47
V = 4/3*np.pi*r**3; m = rho_s*V; A = np.pi*r**2
print(f"m = {m*1e3:.2f} g")
phys = np.sqrt(1 + 2*r**2/(5*L**2)) - 1
buoy = 1/np.sqrt(1 - rho_a/rho_s) - 1
added = np.sqrt(1 + 0.5*rho_a/rho_s) - 1     # added mass 1/2 rho_a V for a sphere (potential flow)
print(f"rel. corrections: physical pendulum {phys:.2e}, buoyancy {buoy:.2e}, added mass {added:.2e}")
beta = 0.5*rho_a*Cd*A/m*L
print(f"drag parameter beta = {beta:.3e}")

def period(beta, th0, w=1.0, nper=1):
    """time between successive turning points on the same side (first full period)
    for th'' = -w^2 sin th - beta th'|th'|, th(0)=th0, th'(0)=0; returns period in units 1/w."""
    f = lambda t, y: [y[1], -w**2*np.sin(y[0]) - beta*y[1]*abs(y[1])]
    ev = lambda t, y: y[1]
    ev.direction = 0
    sol = solve_ivp(f, [0, 20*np.pi], [th0, 0.0], events=ev, rtol=1e-12, atol=1e-14, max_step=0.01)
    te = sol.t_events[0]; te = te[te > 1e-6]
    return te[1]   # second turning point after start = one full period

Tnd = period(0.0, th0); Td = period(beta, th0)
print(f"no-drag period/(1/w) = {Tnd:.10f}; 2pi*ratio = {2*np.pi*ratio_exact:.10f}")
print(f"drag shift rel = {(Td-Tnd)/Tnd:.3e}  (beta*th0)^2 = {(beta*th0)**2:.3e}")

# monotonicity scan of e(beta, th0) = |T_drag - T_nodrag|/T_nodrag on a grid
betas = np.linspace(0, 0.2, 9); ths = np.deg2rad(np.linspace(2, 40, 9))
E = np.zeros((len(betas), len(ths)))
Tn = {th: period(0.0, th) for th in ths}
for i, b in enumerate(betas):
    for j, th in enumerate(ths):
        E[i, j] = abs(period(b, th) - Tn[th])/Tn[th]
mono = np.all(np.diff(E, axis=0) >= -1e-12) and np.all(np.diff(E, axis=1) >= -1e-12)
print("monotone on grid:", mono)
print("E at max corner:", E[-1, -1], " E(beta=0.05, 40deg):", E[2, -1])
np.set_printoptions(precision=2)
print(E)
