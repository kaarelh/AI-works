# Double-precision (log-scale) computation of tanh dual coefficients, m odd up to Mmax.
import numpy as np
from scipy import integrate, special, optimize
def log_sinh(y):
    # log sinh y for y>0, stable
    return y + np.log1p(-np.exp(-2*y)) - np.log(2)
def logI(m, s):
    a = np.pi/2
    g = lambda w: m*np.log(w) - s*s*w*w/2 - log_sinh(a*w)
    pk = (-a + np.sqrt(a*a + 4*s*s*m))/(2*s*s)
    pk = max(pk, 1e-3)
    gmax = g(pk)
    f = lambda w: np.exp(g(w) - gmax) if w > 0 else 0.0
    wid = 1/s
    lo = max(1e-12, pk - 40*wid); hi = pk + 40*wid
    pts = sorted(set([lo] + [pk + k*wid for k in range(-30, 31, 3) if lo < pk + k*wid < hi] + [hi]))
    tot = 0.0
    if lo > 1e-12:
        r0, _ = integrate.quad(f, 1e-12, lo, limit=200); tot += r0
    for x0, x1 in zip(pts[:-1], pts[1:]):
        r, _ = integrate.quad(f, x0, x1, limit=200); tot += r
    return gmax + np.log(tot)
def v_of(s):
    r, _ = integrate.quad(lambda t: np.tanh(s*t)**2*np.exp(-t*t/2)/np.sqrt(2*np.pi), -40, 40, limit=400)
    return r
def coefs(s, Mmax):
    v = v_of(s)
    ms = np.arange(1, Mmax+1, 2)
    logc = np.array([2*m*np.log(s) + 2*logI(m, s) - special.gammaln(m+1) - np.log(v) for m in ms])
    return ms, logc, v
if __name__ == "__main__":
    for s in [0.3, 0.5, 1.0, 2.0, 3.0]:
        ms, logc, v = coefs(s, 4001)
        c = np.exp(logc)
        a = np.pi/(2*s)
        gam = 1/(6*(1+a)**4)
        rat = c[1:]/c[:-1]
        X = (np.sqrt(a*a + 4*ms[:-1]) - a)/2
        gsharp = X**4/((ms[:-1]+1)*(ms[:-1]+2))
        print(f"sigma={s}: v={v:.6f} sum c_m (m<=4001) = {c.sum():.12f}; c1={c[0]:.6f}; min ratio={rat.min():.5f} at m={ms[np.argmin(rat)]}; "
              f"gamma={gam:.3e}; #viol(gamma)={(rat<gam).sum()}; #viol(sharp)={(rat<gsharp*(1-1e-9)).sum()}; min(rat/gsharp)={np.min(rat/gsharp):.4f}; rat[-1]={rat[-1]:.5f}")
        np.save(f"logc_sigma{s}.npy", np.vstack([ms, logc]))
