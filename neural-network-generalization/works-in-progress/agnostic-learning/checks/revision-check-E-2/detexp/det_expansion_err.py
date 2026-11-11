"""check-E-r2: expansion error of robust_memorizer_det.py's smoothed-feature expansion (not printed by that script)."""
import numpy as np
from robust_memorizer_det import expansion, pistar, xg, wg
from nets import cube, xbar
for (d, n, H, gamma, N, alpha, R) in [(6, 64, 2, 1.0, 2000, 5.0, 5.0), (6, 64, 2, 1.0, 8000, 5.0, 5.0), (6, 64, 2, 1.0, 8000, 5.0, 10.0),
             (6, 64, 2, 1.25, 8000, 5.0, 5.0), (6, 64, 2, 2.0, 4000, 5.0, 5.0),
             (6, 64, 3, 1.0, 3000, 5.0, 3.0), (6, 64, 3, 1.0, 6000, 5.0, 3.0)]:
    rng = np.random.default_rng(3); M = 2**d; X = cube(d)
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    r = np.zeros(M); cnt = np.zeros(M); np.add.at(r, idx, y); np.add.at(cnt, idx, 1)
    r[cnt > 0] /= cnt[cnt > 0]
    tau = N**((1-gamma)/2); taud = np.sqrt((d+1)/d)
    psi1 = lambda u: np.tanh(np.asarray(u, float)[..., None] + tau*taud*xg) @ wg
    Pi = pistar(H, tau)
    feats, coefs = expansion(d, r/Pi, alpha, psi1)
    Phi = psi1(xbar(X) @ feats.T)
    print(f"H={H} gamma={gamma} N={N} R={R}: A={np.abs(coefs).sum():.2f} expansion err={np.abs(Phi@coefs - r/Pi).max():.2e} max|r|={np.abs(r).max():.2f}")
