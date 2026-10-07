import numpy as np
from scipy.integrate import solve_ivp
def period(beta, th0, lin=False, method='DOP853'):
    if lin: f = lambda t, y: [y[1], -y[0] - beta*y[1]*abs(y[1])]
    else:   f = lambda t, y: [y[1], -np.sin(y[0]) - beta*y[1]*abs(y[1])]
    ev = lambda t, y: y[1]
    sol = solve_ivp(f, [0, 3*np.pi], [th0, 0.0], events=ev, method=method, rtol=1e-13, atol=1e-16, max_step=0.005)
    te = sol.t_events[0]; te = te[te > 1e-6]; return te[1]
th = np.deg2rad(6.75)
for lin in [False, True]:
    Tn = period(0, th, lin)
    out = []
    for b in [0.0125, 0.025, 0.05, 0.075, 0.1, 0.11, 0.12, 0.13, 0.15, 0.2]:
        out.append((b, (period(b, th, lin) - Tn)/Tn))
    print("linear restoring" if lin else "pendulum", ["%.4f:%+.3e" % o for o in out])
