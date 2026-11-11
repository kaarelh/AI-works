"""Remark 3 after Theorem C.1 ("If the likelihood used unclipped outputs, it would need concavity of psi_y on all of R").

Claim tested: with the UNCLIPPED likelihood Pi_t ~ exp(-eta sum (z_w(x_i)-y_i)^2) mu and the predictor
fhat_t = posterior mean of CLIPPED outputs, the per-step inequality still holds for eta <= 1/8:
   int e^{-eta (z-y)^2} dPi_t <= int e^{-eta (clip z - y)^2} dPi_t <= e^{-eta (fhat_t - y)^2},
because |clip z - y| <= |z - y| for y in [-1,1], and Jensen is then applied on [-1,1] only.
So sum_t (fhat_t(x_{t+1}) - y_{t+1})^2 <= -(1/eta) log Z_T^{unclipped} <= sum_i int (z_w(x_i)-y_i)^2 dQ + KL/eta.
Contrast: with the posterior mean of UNCLIPPED outputs as predictor the per-step inequality fails (Remark's concern).
"""
import numpy as np
rng = np.random.default_rng(21)
M = 25; xs = np.linspace(-1, 1, M); K = 150; eta = 0.125
viol_clipmean = 0; viol_rawmean = 0; worst_raw = 0.0; total = 0
for rep in range(400):
    H = rng.uniform(-3, 3, K)[:, None] * np.tanh(rng.uniform(-4, 4, K)[:, None] * xs[None, :] + rng.uniform(-2, 2, K)[:, None])  # outputs in [-3,3]
    mu = rng.dirichlet(np.ones(K) * 0.5)
    T = 30; idx = rng.integers(0, M, T); y = rng.uniform(-1, 1, T); y[: T // 3] = np.sign(y[: T // 3])
    logw = np.log(mu).copy(); lhs_clip = 0.0; lhs_raw = 0.0
    for t in range(T):
        w = np.exp(logw - logw.max()); w /= w.sum()
        f_clip = w @ np.clip(H[:, idx[t]], -1, 1)
        f_raw = w @ H[:, idx[t]]
        # per-step: log(Z_{t+1}/Z_t) = log sum_j w_j exp(-eta (H_j - y)^2)   (unclipped likelihood)
        step = np.log(np.sum(w * np.exp(-eta * (H[:, idx[t]] - y[t]) ** 2)))
        if (f_clip - y[t]) ** 2 > -step / eta + 1e-10: viol_clipmean += 1
        if (f_raw - y[t]) ** 2 > -step / eta + 1e-10:
            viol_rawmean += 1; worst_raw = max(worst_raw, (f_raw - y[t]) ** 2 + step / eta)
        total += 1
        logw -= eta * (H[:, idx[t]] - y[t]) ** 2
print(f"per-step checks: {total}")
print(f"  unclipped likelihood, predictor = mean of clipped outputs : violations = {viol_clipmean}")
print(f"  unclipped likelihood, predictor = mean of unclipped outputs: violations = {viol_rawmean} (max excess {worst_raw:.3f})")
# explicit two-point example for the raw-mean predictor: y = 1, outputs {3, 7} with weights 1/2
p = np.array([3.0, 7.0]); wt = np.array([0.5, 0.5]); yv = 1.0
print(f"  two-point example y=1, outputs (3,7): (mean-y)^2 = {(wt@p-yv)**2:.3f}  vs  -(1/eta) log E e^(-eta(p-y)^2) = {-np.log(wt@np.exp(-eta*(p-yv)**2))/eta:.3f}")
