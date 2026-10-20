"""Independent check of tanh dual coefficients and Lemma 3.1 bounds.
(1) Direct Hermite projection with mpmath Gauss-Hermite quadrature vs I_m formula (small m).
(2) log I_m via scipy quad on a log-shifted integrand for m up to 4001 and many sigma,
    check sum c_m -> 1, and ratio bounds  upsilon^4/((m+1)(m+2)) <= c_{m+2}/c_m <= m^2/((m+1)(m+2)),
    and >= gamma(sigma)=1/(6(1+pi/(2 sigma))^4).
"""
import numpy as np, mpmath as mp
from scipy import integrate, special
mp.mp.dps = 40

def v_of(sig):
    f = lambda g: mp.tanh(sig*g)**2*mp.exp(-g*g/2)
    return mp.quad(f, [-mp.inf, -3, 0, 3, mp.inf])/mp.sqrt(2*mp.pi)

def hermite_direct(sig, mmax):
    # beta_m = E[tanh(sig G) He_m(G)]/sqrt(m!)
    out = []
    for m in range(1, mmax+1, 2):
        f = lambda g: mp.tanh(sig*g)*mp.hermite(m, g/mp.sqrt(2))*2**(-mp.mpf(m)/2)*mp.exp(-g*g/2)
        # He_m(x) = 2^{-m/2} H_m(x/sqrt2)
        val = mp.quad(f, mp.linspace(-30, 30, 61))/mp.sqrt(2*mp.pi)
        out.append(val**2/mp.factorial(m))
    return out

def logI(m, sig):
    # log int_0^inf w^m e^{-sig^2 w^2/2}/sinh(pi w/2) dw
    def lg(w):
        return m*np.log(w) - sig**2*w*w/2 - (np.pi*w/2 + np.log1p(-np.exp(-np.pi*w)) - np.log(2))
    if m <= 9:
        f0 = lambda w: w**m*mp.exp(-sig**2*w*w/2)/mp.sinh(mp.pi*w/2)
        return float(mp.log(mp.quad(f0, [0, 0.5, 2, 8, 30, 120, mp.inf])))
    # locate max
    from scipy.optimize import minimize_scalar
    a = np.pi/(2*sig)
    w0 = (np.sqrt(a*a+4*m)-a)/(2*sig) if m > 0 else 1.0
    res = minimize_scalar(lambda w: -lg(w), bounds=(1e-6, 10*w0+10), method='bounded')
    wst = res.x; lmax = -res.fun
    width = 1/np.sqrt(max(sig**2 + m/wst**2, 1e-12))
    lo = max(1e-12, wst-40*width); hi = wst+40*width
    f = lambda w: np.exp(lg(w)-lmax)
    pts = np.linspace(lo, hi, 9)
    val = 0.0
    for i in range(8):
        val += integrate.quad(f, pts[i], pts[i+1], epsabs=0, epsrel=1e-13, limit=200)[0]
    if lo > 1e-12:
        val += integrate.quad(f, 1e-14, lo, epsabs=0, epsrel=1e-10, limit=200)[0]
    return lmax + np.log(val)

def logc_formula(sig, mmax):
    v = float(v_of(sig))
    ms = np.arange(1, mmax+1, 2)
    lc = np.array([2*m*np.log(sig) + 2*logI(m, sig) - special.gammaln(m+1) - np.log(v) for m in ms])
    return ms, lc

if __name__ == '__main__':
    # (1) direct vs formula
    for sig in [0.3, 1.0, 2.5]:
        d = hermite_direct(mp.mpf(sig), 15)
        ms, lc = logc_formula(sig, 15)
        v = float(v_of(sig))
        print('sig', sig, 'max rel diff direct vs formula (m<=15):',
              max(abs(float(d[i])/np.exp(lc[i])-1) for i in range(len(ms))))
    # (2) ratios
    worst = []
    for sig in [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0, 1.5, 2.0, 3.0, 5.0, 8.0, 12.0, 20.0, 40.0]:
        mmax = 4001 if sig <= 5 else 1201
        ms, lc = logc_formula(sig, mmax)
        tot = np.exp(lc).sum()
        r = np.exp(lc[1:]-lc[:-1])
        m = ms[:-1].astype(float)
        a = np.pi/(2*sig)
        ups = 0.5*(np.sqrt(a*a+4*m)-a)
        lowb = ups**4/((m+1)*(m+2)); upb = m*m/((m+1)*(m+2))
        gam = 1/(6*(1+a)**4)
        vl = (r/lowb).min(); vu = (r/upb).max()
        print(f'sig={sig:6.2f} mmax={mmax} sum c={tot:.14f}  min ratio={r.min():.4e} at m={int(m[r.argmin()])}  '
              f'gamma={gam:.3e}  min r/lowbound={vl:.6f}  max r/upbound={vu:.6f}  min lowb/gamma={(lowb/gam).min():.4f}')
