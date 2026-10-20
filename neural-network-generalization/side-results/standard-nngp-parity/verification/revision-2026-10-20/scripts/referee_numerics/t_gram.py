import numpy as np
from math import comb, log, e
from scipy.linalg import hadamard
from scipy.sparse.linalg import eigsh
from myspec import *
rng = np.random.default_rng(9)
c, v = coeffs_tanh(2001, 1.0)
for d in [10, 12, 14]:
    D = d+1; lam = lam_from_W(d, level_masses(D, c), v)
    M = 2**d; Hm = hadamard(M).astype(np.float32); deg = np.bitwise_count(np.arange(M))
    for r in [1, 3]:
        cols = np.where(deg > r)[0]
        if len(cols) > 9000: continue
        Psi = Hm[:, cols]*np.sqrt(lam[deg[cols]]).astype(np.float32)
        tau = sum(comb(d,q)*lam[q] for q in range(r+1, d+1)); Dr = sum(comb(d,q) for q in range(r+1))
        H = log(e*D/r); bnorm = 1+np.sqrt(d*r*H)+r*H
        for Adel in [1, 10, 100]:
            n = int(Adel*Dr*log(2*Dr))
            vals = []
            for t in range(5):
                N = np.bincount(rng.integers(0, M, size=n), minlength=M).astype(np.float32)
                Y = Psi.T @ (N[:, None]*Psi)
                vals.append(eigsh(Y.astype(np.float64), k=1, which='LA', return_eigenvectors=False)[0])
            q = np.array(vals)/tau
            print(f"d={d} r={r} A_delta={Adel:3d} n={n:7d}: ||Q_SS||/tau in [{q.min():.2f},{q.max():.2f}],  /(1+sqrt(d rH)+rH) max={q.max()/bnorm:.3f},  n lam/tau={n*lam[r+1]/tau:.2f}, Prop4 ratio min={(np.array(vals)/max(n*lam[r+1],tau)).min():.3f}")
