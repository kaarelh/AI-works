"""The adaptive cutoff at the bottom of the range, n = exp((log(d+1))^3).
r(n) = largest odd r with A_delta D_r log(2 D_r) <= n.  Reports r, r/(log d)^2, r H_r/(log(d+1))^3
and the factor sqrt(r H_r/d) of Theorem A, against (log d)^{3/2}/sqrt(d).
log binom(d,q) is accumulated as sum_{i<q} log((d-i)/(i+1)), which is exact to rounding for huge d.
"""
import numpy as np

for Adel in [1.0, 100.0]:
    for d in [1e5, 1e6, 1e8, 1e12, 1e20, 1e40]:
        logn = np.log(d + 1.0) ** 3
        q = np.arange(0, 20000, dtype=float)
        lb = np.concatenate([[0.0], np.cumsum(np.log((d - q[:-1]) / (q[:-1] + 1.0)))])
        logD = np.logaddexp.accumulate(lb)
        crit = np.log(Adel) + logD + np.log(np.log(2) + logD)
        r = int(np.max(np.nonzero(crit <= logn)[0]))
        if r % 2 == 0:
            r -= 1
        H = np.log(np.e * (d + 1) / r)
        L = np.log(d)
        print(f"A_delta={Adel:5.0f} d=1e{int(round(np.log10(d))):<3d} r(n)={r:5d}  r/(log d)^2={r / L ** 2:.3f}  "
              f"rH_r/(log(d+1))^3={r * H / np.log(d + 1.0) ** 3:.3f}  r<=d/64: {r <= d / 64}  "
              f"sqrt(rH_r/d)={np.sqrt(r * H / d):.3e}  (log d)^1.5/sqrt d={L ** 1.5 / np.sqrt(d):.3e}  "
              f"ratio={np.sqrt(r * H / d) / (L ** 1.5 / np.sqrt(d)):.3f}")
