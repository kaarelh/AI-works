"""Independent spectrum code for the tanh NNGP kernel at depth L=2.

c_m(sigma^2) = sigma^{2m} I_m(sigma)^2 / (m! v),  m odd   (paper Lemma 4.1)
I_m(sigma)   = int_0^inf w^m exp(-sigma^2 w^2/2) / sinh(pi w/2) dw
v            = E tanh^2(sigma G)

Level masses on the D-cube, D=d+1:  W_j = C(D,j) a_j = sum_m c_m P(X_m = j),
X_m = Hamming distance after m uniform single flips (Ehrenfest walk).
For odd F and q in [0,d]: lambda_q = A a_{j(q)}, j(q) = q (q odd), q+1 (q even).
For odd r: tau_r = A sum_{odd j>=r+2} W_j,  lambda_{r+1} = A W_{r+2}/C(D,r+2).
"""
import numpy as np
from scipy.special import gammaln, logsumexp


def log_Im(m, sigma=1.0, npts=None):
    if npts is None:
        npts = 200001 if m < 50 else 6001
    # peak of m log w - sigma^2 w^2/2 - pi w/2
    ws = (-np.pi / 2 + np.sqrt(np.pi ** 2 / 4 + 4 * sigma ** 2 * m)) / (2 * sigma ** 2)
    lo = max(1e-12, ws - 40.0 / sigma)
    hi = ws + 40.0 / sigma
    w = np.linspace(lo, hi, npts)
    x = np.pi * w / 2
    logsinh = x + np.log1p(-np.exp(-2 * x)) - np.log(2.0)
    lf = m * np.log(w) - sigma ** 2 * w ** 2 / 2 - logsinh
    dw = w[1] - w[0]
    # trapezoid in log space
    wts = np.full(npts, np.log(dw))
    wts[0] += np.log(0.5)
    wts[-1] += np.log(0.5)
    val = logsumexp(lf + wts)
    if lo > 1e-12:
        return val
    return val


def v_tanh(sigma=1.0):
    x, wt = np.polynomial.hermite_e.hermegauss(200)
    return float(np.sum(wt * np.tanh(sigma * x) ** 2) / np.sqrt(2 * np.pi))


def log_coeffs(mmax, sigma=1.0):
    """log c_m for odd m <= mmax (array indexed by m; -inf at even m)."""
    v = v_tanh(sigma)
    lc = np.full(mmax + 1, -np.inf)
    for m in range(1, mmax + 1, 2):
        lc[m] = 2 * m * np.log(sigma) + 2 * log_Im(m, sigma) - gammaln(m + 1) - np.log(v)
    return lc, v


def level_masses(D, lc):
    """W_j = sum_m c_m P(X_m=j), j=0..D, via the exact Ehrenfest recursion."""
    mmax = len(lc) - 1
    p = np.zeros(D + 1)
    p[0] = 1.0
    W = np.zeros(D + 1)
    j = np.arange(D + 1)
    up = (D - j) / D       # prob distance j -> j+1
    dn = j / D             # prob distance j -> j-1
    c = np.exp(lc)
    for m in range(1, mmax + 1):
        new = np.zeros(D + 1)
        new[1:] += p[:-1] * up[:-1]
        new[:-1] += p[1:] * dn[1:]
        p = new
        if c[m] > 0:
            W += c[m] * p
    tail = 1.0 - c[:mmax + 1].sum()
    return W, tail


def spectrum(d, sigma1=1.0, sigma2=1.0, mmax=None):
    D = d + 1
    if mmax is None:
        mmax = 3 * D + 400
    if mmax % 2 == 0:
        mmax += 1
    lc, v = log_coeffs(mmax, sigma1)
    A = sigma2 ** 2 * v
    W, tail = level_masses(D, lc)
    from scipy.special import comb
    logCD = gammaln(D + 1) - gammaln(np.arange(D + 1) + 1) - gammaln(D - np.arange(D + 1) + 1)
    with np.errstate(divide='ignore'):
        loga = np.log(W) - logCD
    lam = np.zeros(d + 1)
    for q in range(d + 1):
        jq = q if q % 2 == 1 else q + 1
        lam[q] = A * np.exp(loga[jq])
    return dict(d=d, D=D, A=A, W=W, lam=lam, lc=lc, tail=tail, logCD=logCD)


if __name__ == "__main__":
    lc, v = log_coeffs(4001)
    c = np.exp(lc)
    print("v =", v, " sum_{m<=4001} c_m =", c.sum(), " c_1 =", c[1], " c_3 =", c[3])
    # cross-check c_m with mpmath at a few m
    import mpmath as mp
    mp.mp.dps = 40
    for m in [1, 3, 11, 101, 1001]:
        f = lambda w: w ** m * mp.e ** (-w ** 2 / 2) / mp.sinh(mp.pi * w / 2)
        I = mp.quad(f, [0, mp.mpf(m) ** 0.5 / 2, mp.mpf(m) ** 0.5, 2 * mp.mpf(m) ** 0.5 + 10, mp.inf])
        lcm = 2 * mp.log(I) - mp.loggamma(m + 1) - mp.log(v)
        print(m, float(lcm), lc[m], float(lcm) - lc[m])
