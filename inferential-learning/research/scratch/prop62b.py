import numpy as np
from scipy.optimize import brentq
exec(open('prop62.py').read().split('# check bound validity')[0])
def exact_err(r, sig):
    try: return abs(exact_ratio(r, sig)[0] - 1)
    except ValueError: return np.inf   # not in image -> E = 0 there?? treat as large
def r_bound(sig, tol):
    f = lambda r: max(1 - bound(1/r, sig)[0], bound(1/r, sig)[1] - 1) - tol
    return brentq(f, 1.2 if sig > 0.5 else 2.0, 1e9)
def r_exact(sig, tol):
    rs = np.geomspace(1.000001, 1e5, 40000)
    errs = np.array([exact_err(r, sig) for r in rs])
    idx = np.where(errs > tol)[0]
    if len(idx) == 0: return None
    i = idx[-1]
    if i == len(rs)-1: return np.inf
    return brentq(lambda r: exact_err(r, sig) - tol, rs[i], rs[i+1], xtol=1e-12)
for sig in [1, 0.9, 0.8, 0.7, 1/np.sqrt(2), 0.5, 0.3, 0.1]:
    for tol in [0.05]:
        rb = r_bound(sig, tol); re = r_exact(sig, tol)
        print(f'sig={sig:.4f} tol={tol}: bound at r>={rb:.3f}a; exact err>tol only for r<={re:.4f}; ratio {rb/re:.2f}')
for t in [0.05, 0.01, 0.002, 0.0004]:
    sig = 1/np.sqrt(2); rb = r_bound(sig, t); re = r_exact(sig, t)
    print(f'sig=1/sqrt2 tol={t}: rb={rb:.2f} re={re:.4f} ratio {rb/re:.1f}')
R, c, s = exact_ratio(20, 0.5)
print('r=20, sig=.5: sigma-c', 0.5 - c, 'first order', 0.05*0.75/2, 'E/E0-1', R-1, 'first order', 0.05*(2*.25-1)/(2*.5))
print('r=20, sig=1: E/E0', exact_ratio(20,1)[0], '40/39', 40/39, 'bound hi', bound(0.05,1)[1])
R,c,s = exact_ratio(40, 1.0); print('s at r=40 phi=pi', s, 'L tan30', 60*np.tan(np.radians(30)))
# max exact error on honest domain r in [20,34], sig in [0.5,1]
mx = max(abs(exact_ratio(r, sg)[0]-1) for r in np.linspace(20,34,57) for sg in np.linspace(0.5,1,101))
print('max exact point-sun error on r in [20,34], sig>=0.5:', mx)
