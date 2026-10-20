"""Referee's own spectrum code (independent of spec.py).
c_m for tanh at variance s2: c_m = s2^m I_m^2/(m! v), I_m = int_0^inf w^m e^{-s2 w^2/2}/sinh(pi w/2) dw.
Computed with scipy.quad on a rescaled integrand (log-space), cross-checked vs mpmath.
Composite F for L=3 via power-series composition.
Level masses W_j = sum_m c_m P(dist_m = j), dist = Ehrenfest walk on D-cube.
"""
import numpy as np
from scipy.integrate import quad
from scipy.special import gammaln
from numpy.polynomial.hermite_e import hermegauss

def v_tanh(s2):
    x, w = hermegauss(300)
    return float(np.sum(w*np.tanh(np.sqrt(s2)*x)**2)/np.sqrt(2*np.pi))

def logI(m, s2):
    # maximize g(w)= m log w - s2 w^2/2 - pi w/2
    ws = (-np.pi/2 + np.sqrt(np.pi**2/4 + 4*s2*m))/(2*s2)
    g = lambda w: m*np.log(w) - s2*w*w/2 - (np.pi*w/2 + np.log1p(-np.exp(-np.pi*w)) - np.log(2))
    g0 = g(ws)
    sd = 1/np.sqrt(s2 + m/ws**2)
    f = lambda w: np.exp(g(w)-g0) if w > 0 else 0.0
    lo = max(0.0, ws-60*sd); hi = ws+60*sd
    val, err = quad(f, lo, hi, points=[ws], limit=400, epsabs=0, epsrel=1e-12)
    if lo > 0:
        v2, _ = quad(f, 0, lo, limit=200); val += v2
    return g0 + np.log(val)

def coeffs_tanh(mmax, s2):
    v = v_tanh(s2)
    lc = np.full(mmax+1, -np.inf)
    for m in range(1, mmax+1, 2):
        lc[m] = m*np.log(s2) + 2*logI(m, s2) - gammaln(m+1) - np.log(v)
    return np.exp(lc), v

def compose(outer, inner, mmax):
    # F = outer(inner(t)), power series truncated at mmax
    res = np.zeros(mmax+1); powk = np.zeros(mmax+1); powk[0] = 1.0
    for k in range(len(outer)):
        if k > 0:
            powk = np.convolve(powk, inner)[:mmax+1]
        if outer[k] != 0:
            res += outer[k]*powk
        if not powk.any(): break
    return res

def level_masses(D, c):
    p = np.zeros(D+1); p[0] = 1.0
    W = c[0]*p.copy()
    j = np.arange(D+1); up = (D-j)/D; dn = j/D
    for m in range(1, len(c)):
        new = np.zeros(D+1)
        new[1:] += p[:-1]*up[:-1]
        new[:-1] += p[1:]*dn[1:]
        p = new
        if c[m] > 0: W += c[m]*p
    return W

def lam_from_W(d, W, A):
    D = d+1
    logC = gammaln(D+1)-gammaln(np.arange(D+1)+1)-gammaln(D-np.arange(D+1)+1)
    a = np.exp(np.log(np.maximum(W,1e-300)) - logC)
    lam = np.array([A*(a[q]+a[q+1]) if q < D else A*a[q] for q in range(d+1)])
    return lam
