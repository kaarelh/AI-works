"""Remark after Prop. B2.2: how loose is kappa_path?  The class {phi_1 <= 1} contains +-x_j/2 and +-1/2
(x_j/2 = (relu(relu(x_j)) - relu(relu(-x_j)))/2 has path norm 1), so
  Rhat_S >= E max_j |sum_i eps_i xhat_ij| / (2n).
Monte Carlo of this lower bound for uniform samples on {-1,1}^30, against the upper bound 3.321/sqrt(n)."""
import numpy as np
rng = np.random.default_rng(0)
for n in [256, 2048, 16384]:
    vals = []
    for _ in range(200):
        X = np.concatenate([rng.choice([-1.0, 1.0], size=(n, 30)), np.ones((n, 1))], 1)
        eps = rng.choice([-1.0, 1.0], size=n)
        vals.append(np.abs(eps @ X).max() / (2 * n))
    lo = np.mean(vals) * np.sqrt(n)
    print(f"n={n:5d}: lower bound {lo:.3f}/sqrt(n), upper bound {np.sqrt(2*np.log(248)):.3f}/sqrt(n), ratio {np.sqrt(2*np.log(248))/lo:.2f}")
