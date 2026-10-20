"""Large-n check of the derived intrinsic-dimension bound of Remark 8.5,
   E||Q_SS|| <= (e-1) n lam_{r+1} + tau_r log(tau_r/lam_{r+1}),
via Y = sum_i psi(X_i) psi(X_i)^T (same nonzero spectrum as Q_SS), which allows n up to 1e5.
tanh L=2 kernels with first-layer gain sigma_1 in {0.5,1,2}; spectrum from spec.py."""
import numpy as np
from math import comb, e, log
from scipy.linalg import hadamard
from scipy.sparse.linalg import eigsh
from spec import spectrum
rng = np.random.default_rng(5)
worst_mean, worst_max = 0.0, 0.0
for s1 in [0.5, 1.0, 2.0]:
    for d in [10, 12]:
        lam = spectrum(d, sigma1=s1)['lam']
        Hm = hadamard(2 ** d).astype(float)          # chi_U(x) = (-1)^{popcount(x & U)}
        deg = np.bitwise_count(np.arange(2 ** d))
        for r in [1, 3]:
            cols = np.where(deg > r)[0]
            Psi = Hm[:, cols] * np.sqrt(lam[deg[cols]])
            tau = sum(comb(d, q) * lam[q] for q in range(r + 1, d + 1))
            for n in [50, 500, 3000, 20000, 100000]:
                vals = []
                for t in range(6):
                    N = np.bincount(rng.integers(0, 2 ** d, size=n), minlength=2 ** d).astype(float)
                    Y = Psi.T @ (N[:, None] * Psi)
                    vals.append(eigsh(Y, k=1, which='LA', return_eigenvectors=False)[0])
                bnd = (e - 1) * n * lam[r + 1] + tau * log(tau / lam[r + 1])
                worst_mean = max(worst_mean, np.mean(vals) / bnd); worst_max = max(worst_max, np.max(vals) / bnd)
                print(f"s1={s1} d={d} r={r} n={n:6d}: mean lmax/bound={np.mean(vals)/bnd:.3f}  max={np.max(vals)/bnd:.3f}"
                      f"   lmax/(n lam)={np.mean(vals)/(n*lam[r+1]):.3f}")
print(f"worst mean ratio {worst_mean:.3f}, worst single-sample ratio {worst_max:.3f}")
