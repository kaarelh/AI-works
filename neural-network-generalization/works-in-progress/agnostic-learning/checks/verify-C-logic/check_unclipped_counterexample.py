"""Does Theorem C.1 (arbitrary prior) survive if the predictor is the UNclipped posterior mean int z_w dPi_t
(the brief's 'posterior mean of z_w (BMA)') instead of the mean of clipped outputs?
Two-point prior: Theta={w1,w2}, mu=(1/2,1/2), z_{w1} == M (constant), z_{w2} == -1; D: y == -1 (x irrelevant).
FIX_eta likelihood uses clip: loss of w1 is (1-(-1))^2 = 4, loss of w2 is 0.
Bound (C.2.5) with Q = delta_{w2}: E L_D(fbar_n) <= 0 + KL/(eta(n+1)) = log 2/(eta(n+1)).
"""
import numpy as np
eta = 1/8
for M in [1, 10, 1e3, 1e6]:
    for n in [10, 100, 1000]:
        t = np.arange(n + 1)
        a = np.exp(-4 * eta * t)                 # unnormalized posterior weight of w1 (w2 has weight 1)
        p1 = a / (1 + a)
        mean_clip = p1 * 1 + (1 - p1) * (-1)     # mean of clipped outputs
        mean_unc = p1 * M + (1 - p1) * (-1)      # unclipped posterior mean
        fbar_clip, fbar_unc = mean_clip.mean(), mean_unc.mean()
        bound = np.log(2) / (eta * (n + 1))
        L_clip, L_unc = (fbar_clip + 1) ** 2, (fbar_unc + 1) ** 2
        L_unc_clipped = (np.clip(fbar_unc, -1, 1) + 1) ** 2
        print(f"M={M:8.0e} n={n:5d}: bound={bound:.3e}  L(clipped-mean PM)={L_clip:.3e} ok={L_clip <= bound}"
              f"  L(unclipped PM)={L_unc:.3e} ok={L_unc <= bound}  L(clip of unclipped PM)={L_unc_clipped:.3e} ok={L_unc_clipped <= bound}")
# one-step inequality of Theorem C.1(a) for the unclipped mean at t=0 (posterior = prior)
for M in [10]:
    lhs = (0.5 * M - 0.5 + 1) ** 2
    rhs = -np.log(0.5 * np.exp(-4 * eta) + 0.5) / eta
    print(f"one step, M={M}: (unclipped mean - y)^2 = {lhs:.3f}  vs  -(1/eta) log(Z1/Z0) = {rhs:.3f}")
