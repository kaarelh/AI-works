import sys; sys.path.insert(0, '.')
import numpy as np
from robust_memorizer import build
from nets import cube
d, n = 6, 64
for (H, gamma, N, m, alpha, R) in [(2, 1.0, 1000, 500, 4.0, 5.0), (2, 1.0, 4000, 1000, 4.0, 5.0),
                                     (2, 1.0, 8000, 2000, 4.0, 5.0), (2, 1.5, 4000, 1000, 4.0, 5.0),
                                     (3, 1.0, 2000, 1000, 4.0, 3.0), (3, 1.0, 5000, 2000, 4.0, 3.0)]:
    rng = np.random.default_rng(3); M = 2**d
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    r = np.zeros(M); cnt = np.zeros(M); np.add.at(r, idx, y); np.add.at(cnt, idx, 1)
    seen = cnt > 0; r[seen] /= cnt[seen]
    tau = N**((1-gamma)/2)
    w0, info = build(d, r, H, tau, N, m, alpha, R, rng)
    print(H, gamma, N, f"sampling err = {info['samp_err']:.6f}")
