# Independent kernel check: F via 2D Gauss-Hermite quadrature, lambda_q via Krawtchouk transform,
# versus Hermite-coefficient + Ehrenfest route.
import numpy as np
from math import comb
from numpy.polynomial.hermite_e import hermegauss
from myspec import *
x, w = hermegauss(250); w = w/np.sqrt(2*np.pi)
v = np.sum(w*np.tanh(x)**2)
def F(rho):
    s = np.sqrt(max(0.0, 1-rho*rho))
    X = x[:,None]; Wv = x[None,:]
    return np.sum(w[:,None]*w[None,:]*np.tanh(X)*np.tanh(rho*X+s*Wv))/v
def kraw(d):
    K = np.zeros((d+1, d+1))
    for q in range(d+1):
        for k in range(d+1):
            K[q,k] = sum((-1)**j*comb(k,j)*comb(d-k,q-j) for j in range(0, min(k,q)+1) if q-j <= d-k)
    return K
c, _ = coeffs_tanh(2001, 1.0)
for d in [10, 12, 14]:
    D = d+1
    Kd = np.array([v*F((1+d-2*k)/D) for k in range(d+1)])   # K as function of distance k
    Kr = kraw(d)
    lam_direct = np.array([sum(comb(d,k)*Kd[k]*Kr[q,k] for k in range(d+1))/2**d/comb(d,q) for q in range(d+1)])
    W = level_masses(D, c); lam = lam_from_W(d, W, v)
    print("d=",d, "max rel diff lambda:", np.max(np.abs(lam_direct/lam-1)))
    print("  lambda:", " ".join(f"{t:.3e}" for t in lam))
    print("  monotone:", np.all(np.diff(lam) <= 1e-18), " pairing lam_2k=lam_2k+1:", np.max(np.abs(lam[2::2][:len(lam[3::2])]-lam[3::2])/lam[3::2]))
    np.save(f"lam_d{d}.npy", lam)
