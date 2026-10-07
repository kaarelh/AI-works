"""Signed drag-induced period shift for the pendulum: two competing effects
(amplitude decay shortens the period through the nonlinearity, -beta*th0^3/6 to first order;
damping lengthens it at second order). Shows |e| is NOT monotone in beta: a Laymon-style
monotonicity assumption on the error would be false here."""
import numpy as np
from scipy.integrate import solve_ivp
def period(beta, th0):
    f = lambda t, y: [y[1], -np.sin(y[0]) - beta*y[1]*abs(y[1])]
    ev = lambda t, y: y[1]
    sol = solve_ivp(f, [0, 20*np.pi], [th0, 0.0], events=ev, rtol=1e-12, atol=1e-14, max_step=0.01)
    te = sol.t_events[0]; te = te[te > 1e-6]; return te[1]
th = np.deg2rad(6.75)
Tn = period(0, th)
for b in [0.0125, 0.025, 0.05, 0.1, 0.15, 0.2]:
    e = (period(b, th) - Tn)/Tn
    print(f"beta={b:.4f} signed e={e:+.3e}  first-order -beta*th^3/6={-b*th**3/6:+.3e}")
# real parameters and a Lipschitz-style local certificate on the box Cd in [0.3,0.6]
beta0 = 2.694e-3*np.array([0.3/0.47, 0.6/0.47]); th0s = np.deg2rad([9.0, 11.0])
bs = np.linspace(*beta0, 7); ts = np.linspace(*th0s, 7)
E = np.array([[ (period(b,t)-period(0,t))/period(0,t) for t in ts] for b in bs])
print("box values: min %.3e max %.3e" % (E.min(), E.max()))
gb = np.abs(np.diff(E, axis=0)).max()/(bs[1]-bs[0]); gt = np.abs(np.diff(E, axis=1)).max()/(ts[1]-ts[0])
print("finite-difference slopes: d/dbeta %.3e, d/dth %.3e" % (gb, gt))
