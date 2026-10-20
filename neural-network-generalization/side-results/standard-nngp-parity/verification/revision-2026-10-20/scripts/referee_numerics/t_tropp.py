# Remark 8.5: E||Q_SS|| <= (e-1) n lam_{r+1} + tau_r log(2 tau_r/lam_{r+1}); test incl. large n and other gains.
import numpy as np
from math import comb, e, log
from scipy.linalg import hadamard
from scipy.sparse.linalg import eigsh
from myspec import *
rng = np.random.default_rng(5)
for s1 in [1.0, 0.5, 2.0]:
    c, v = coeffs_tanh(2001, s1)
    for d in [10, 12]:
        D = d+1; lam = lam_from_W(d, level_masses(D, c), v)
        Hm = hadamard(2**d).astype(float)  # rows x, cols U (Sylvester ordering: chi_U(x)=(-1)^{popcount(x&U)})
        deg = np.bitwise_count(np.arange(2**d))
        for r in [1, 3]:
            cols = np.where(deg > r)[0]; Psi = Hm[:, cols]*np.sqrt(lam[deg[cols]])
            tau = sum(comb(d,q)*lam[q] for q in range(r+1, d+1))
            for n in [50, 500, 3000, 20000, 100000]:
                vals = []
                for t in range(6):
                    N = np.bincount(rng.integers(0, 2**d, size=n), minlength=2**d).astype(float)
                    Y = Psi.T @ (N[:, None]*Psi)
                    vals.append(eigsh(Y, k=1, which='LA', return_eigenvectors=False)[0])
                bnd = (e-1)*n*lam[r+1] + tau*log(2*tau/lam[r+1])
                print(f"s1={s1} d={d} r={r} n={n:6d}: mean lmax/bound={np.mean(vals)/bnd:.3f}  max={np.max(vals)/bnd:.3f}   lmax/(n lam)={np.mean(vals)/(n*lam[r+1]):.3f}")
