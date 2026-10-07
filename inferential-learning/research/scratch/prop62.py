import numpy as np
from scipy.optimize import brentq
def exact_ratio(r, sig, a=1.0):
    """E/E0 at floor point (r, phi), phi = 2 arcsin(sig) in (0, pi]; L = infinity. Solve phi = psi + delta(psi)."""
    phi = 2*np.arcsin(sig)
    def F(psi):
        u = np.sqrt(r**2 - a**2*np.cos(psi/2)**2)
        return psi + np.arctan2(a*np.cos(psi/2), u) - phi
    psi = brentq(F, 1e-14, 2*np.pi - 1e-14, xtol=1e-15)
    c = np.sin(psi/2); u = np.sqrt(r**2 - a**2*np.cos(psi/2)**2)
    s = u - a*c
    E = a*c/(2*s + a*c)               # E/I0
    E0 = a/2*sig/r
    return E/E0, c, s
def bound(eps, sig):
    m = np.arcsin(eps)/2
    lo = 1 - m/sig; hi = (1 + m/sig)/(np.sqrt(1 - eps**2) - eps/2)
    return lo, hi
# check bound validity over a grid
viol = 0; n = 0
for r in np.concatenate([np.linspace(1.12, 5, 60), np.linspace(5, 300, 200)]):
    eps = 1/r
    if eps >= 2/np.sqrt(5): continue
    m = np.arcsin(eps)/2
    for sig in np.linspace(0.001, 1, 400):
        if sig <= m: continue
        R, c, s = exact_ratio(r, sig)
        lo, hi = bound(eps, sig); n += 1
        if not (lo - 1e-12 <= R <= hi + 1e-12): viol += 1; print('VIOL', r, sig, R, lo, hi)
print('bound checks', n, 'violations', viol)
tol = 0.05
def r_bound(sig, tol):
    f = lambda r: max(1 - bound(1/r, sig)[0], bound(1/r, sig)[1] - 1) - tol
    return brentq(f, 1.2 if sig > 0.5 else 2.0, 1e7)
def r_exact(sig, tol):
    # sup of r with |err| > tol: scan downward from large r
    rs = np.geomspace(1.13, 5000, 20000)
    errs = np.array([abs(exact_ratio(r, sig)[0] - 1) if np.arcsin(1/r)/2 < 2 else np.nan for r in rs])
    idx = np.where(errs > tol)[0]
    if len(idx) == 0: return None
    i = idx[-1]
    return brentq(lambda r: abs(exact_ratio(r, sig)[0] - 1) - tol, rs[i], rs[i+1], xtol=1e-10)
for sig in [1, 0.9, 0.8, 0.7, 1/np.sqrt(2), 0.5, 0.3, 0.1]:
    rb = r_bound(sig, tol); re = r_exact(sig, tol)
    print(f'sig={sig:.4f}: bound 5% at r>={rb:.2f}a; exact err>5% only for r<={re}; ratio {rb/re if re else None}')
for t in [0.05, 0.01, 0.002, 0.0004]:
    sig = 1/np.sqrt(2); rb = r_bound(sig, t); re = r_exact(sig, t)
    print(f'sig=1/sqrt2 tol={t}: rb={rb:.2f} re={re:.3f} ratio {rb/re:.1f}')
R, c, s = exact_ratio(20, 0.5)
print('r=20, sig=.5: sigma-c', 0.5 - c, 'first order', 0.05*0.75/2, 'E/E0-1', R-1, 'first order', 0.05*(2*.25-1)/(2*.5))
print('r=20, sig=1: E/E0', exact_ratio(20,1)[0], '40/39', 40/39, 'bound hi', bound(0.05,1)[1])
# counterexample: L=60a alpha=30, r=40, phi=pi
R,c,s = exact_ratio(40, 1.0); print('s at r=40 phi=pi', s, 'L tan30', 60*np.tan(np.radians(30)))
