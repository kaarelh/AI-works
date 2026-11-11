"""Gaussian matrix facts used in E-finite-prior-scale.md ((G3), Lemmas 2.4 and 3.1): E||G||_op <= sqrt(p)+sqrt(q) (Gordon), concentration,
and the median bound ||Z||_op <= 2 sqrt(N) + sqrt(2 log 2) w.p. >= 1/2 for N x N Z."""
import numpy as np
rng = np.random.default_rng(0)
for (p, q) in [(10, 10), (50, 50), (200, 200), (400, 7), (300, 300)]:
    vals = np.array([np.linalg.norm(rng.standard_normal((p, q)), 2) for _ in range(200)])
    thr = np.sqrt(p)+np.sqrt(q)
    print(f"p={p},q={q}: mean||G||={vals.mean():.3f} <= sqrt p+sqrt q={thr:.3f}; "
          f"frac(||G|| <= thr+sqrt(2log2)) = {(vals <= thr+np.sqrt(2*np.log(2))).mean():.3f}; "
          f"frac(||G||>thr+t, t=sqrt(2 log 4)) = {(vals > thr+np.sqrt(2*np.log(4))).mean():.3f} (bound 0.25)")
