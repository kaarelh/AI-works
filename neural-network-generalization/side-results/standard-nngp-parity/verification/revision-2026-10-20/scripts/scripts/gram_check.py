# Monte Carlo check of the intrinsic-dimension Chernoff bound for the tail Gram matrix
# E||Q_SS|| <= (e-1) n lam_{r+1} + tau_r log(2 tau_r/lam_{r+1})   (and the sharper log(tau_r/lam_{r+1}))
import numpy as np, math
from tanh_coef_fast import coefs
from walk import walk_levels
rng = np.random.default_rng(7)
ms, logc, v = coefs(1.0, 1201)
c = np.zeros(1202); c[ms] = np.exp(logc)
def kraw(q, k, d):
    return sum((-1)**i*math.comb(k, i)*math.comb(d-k, q-i) for i in range(0, q+1))
for d in [10, 12, 14]:
    D = d+1
    W = walk_levels(c, D, 1201)
    a = np.array([W[j]/math.comb(D, j) for j in range(D+1)])
    lam = np.array([a[q+1] if q % 2 == 0 else a[q] for q in range(d+1)])  # A=1
    Kq = np.array([[kraw(q, k, d) for k in range(d+1)] for q in range(d+1)])  # Kq[q,k]
    for r in [1, 3, 5]:
        if r >= d-1: continue
        tau = sum(math.comb(d, q)*lam[q] for q in range(r+1, d+1))
        l1 = lam[r+1]
        Qdist = (lam[r+1:, None]*Kq[r+1:, :]).sum(axis=0)   # Q as function of distance
        for n in [50, 200, 1000, 4000]:
            vals = []
            for t in range(40 if n <= 1000 else 10):
                S = rng.integers(0, 2, size=(n, d))
                # distances
                G = S @ S.T  # count of matching ones... compute Hamming distance
                dist = (S[:, None, :] != S[None, :, :]).sum(axis=2) if n <= 1000 else None
                if dist is None:
                    # memory-friendly distance: d - (agreements)
                    Sp = 2*S-1
                    dist = ((d - Sp @ Sp.T)//2).astype(int)
                Qss = Qdist[dist]
                vals.append(np.linalg.eigvalsh(Qss)[-1])
            E = np.mean(vals)
            b2 = (math.e-1)*n*l1 + tau*math.log(2*tau/l1)
            b1 = (math.e-1)*n*l1 + tau*math.log(tau/l1)
            print(f"d={d} r={r} n={n}: E||Q_SS||/tau={E/tau:.3f}  n*lam/tau={n*l1/tau:.3f}  bound(log 2d)/tau={b2/tau:.3f}  bound(log d)/tau={b1/tau:.3f}  {'OK' if E <= b1 else 'VIOLATES log-d form'}")
