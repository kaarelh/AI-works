"""theta_r sqrt(r) for the tanh L=2 unit-gain kernel, where
theta_r = C(D,r+2) lambda_{r+1}/tau_r = W_{r+2} / sum_{odd j>=r+2} W_j   (odd r, D=d+1).
Lemma T (exploration, unproved) asserts theta_r >= c/sqrt(r).  This scans every odd r
with r+2 <= D, at d in {200,400,800,1600,3200}, and reports the range of theta_r sqrt(r)
on three sets of r: r <= 0.065 d (the rows of compare_bounds.py), r <= 193 with r < d/2
(the range scanned by referee 2), and all odd r <= d-1.
"""
import numpy as np
from spec import spectrum

for d in [200, 400, 800, 1600, 3200]:
    sp = spectrum(d)
    W = sp['W']
    D = d + 1
    rs = np.arange(1, D - 1, 2)                      # r+2 <= D
    tails = np.array([W[r + 2::2].sum() for r in rs])
    ok = tails > 0                                   # level masses near j = D underflow for d >= 1600
    rs, tails = rs[ok], tails[ok]
    th = W[rs + 2] / tails * np.sqrt(rs)
    ok = np.isfinite(th) & (W[rs + 2] > 0)
    rs, th = rs[ok], th[ok]
    s1 = rs <= 0.065 * d
    s2 = (rs <= 193) & (rs < d / 2)
    first = rs[th > 3.03]
    print(f"d={d:5d}: r<=0.065d: [{th[s1].min():.3f}, {th[s1].max():.3f}]   "
          f"r<=193,r<d/2: [{th[s2].min():.3f}, {th[s2].max():.3f}] (max at r={rs[s2][np.argmax(th[s2])]})   "
          f"all odd r<=d-1: min {th.min():.3f} at r={rs[np.argmin(th)]}, max {th.max():.2f}   "
          f"first r with >3.03: {first[0] if len(first) else None}   (largest r with representable masses: {rs.max()})")
