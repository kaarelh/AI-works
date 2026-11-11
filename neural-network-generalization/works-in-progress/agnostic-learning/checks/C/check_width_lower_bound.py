"""Claim C, Lemma C.6.1 / Theorem C.5 (necessity of width dependence; Section C.8 item 4), Monte Carlo.

Finite-scale Gaussian prior mu_{N,gamma}, depth L (2 or 3), d=2, constant target y = 1, eta = 1/8, n = 20.
Given the hidden weights, the outputs on the finite point set P (train + test) are exactly Gaussian with
covariance N^{-gamma-1} H^T H, so we sample them by a P x P Cholesky factor (exact), many readouts per hidden draw.
Posterior quantities are computed by self-normalised importance sampling from the prior (weights Lambda in [e^{-4 eta n},1]).
Bounds checked (m_nu = 1, s2 := N^{-gamma}, k := eta n):
  sup_x |fhat_n(x)| <= s2 (4k + sqrt(2k));  KL(pi_n||mu) <= k s2 (1 + 8k + 2 sqrt(2k));  TV <= sqrt(KL_bound/2).
"""
import numpy as np, sys
rng = np.random.default_rng(3)
d, n, eta, gamma = 2, 20, 0.125, 1.0
Xtr = rng.uniform(-1, 1, (d, n)); Xte = rng.uniform(-1, 1, (d, 10))
Xall = np.hstack([Xtr, Xte]); P = Xall.shape[1]
Xbar = np.vstack([np.ones(P), Xall])
ytr = np.ones(n)

def outputs(N, L, Rh, Rv):
    Z = []
    for _ in range(Rh):
        W1 = rng.standard_normal((N, d + 1)) * np.sqrt(N ** (1 - gamma) / d)
        H = np.tanh(W1 @ Xbar)
        for _l in range(L - 2):
            W = rng.standard_normal((N, N)) * np.sqrt(N ** (-gamma))
            H = np.tanh(W @ H)
        G = H.T @ H * N ** (-gamma - 1)           # covariance of outputs given hidden weights
        C = np.linalg.cholesky(G + 1e-14 * np.eye(P))
        Z.append((C @ rng.standard_normal((P, Rv))).T)
    return np.vstack(Z)                            # (Rh*Rv) x P samples of z on the point set

print(f"d={d}, n={n}, eta={eta}, gamma={gamma}, target y=1; columns: sup|fhat| (bound), KL (bound), TV (bound), test MSE of fhat_n")
for L, Ns, Rh in [(2, [1, 4, 16, 64, 256, 1024, 4096, 16384], 400), (3, [1, 4, 16, 64, 256, 1024], 100)]:
    for N in Ns:
        Zs = outputs(N, L, Rh, 100000 // Rh)
        zc = np.clip(Zs, -1, 1)
        ell = eta * ((zc[:, :n] - ytr) ** 2).sum(1)
        lam = np.exp(-ell)
        Zn = lam.mean()
        w = lam / lam.sum()
        fhat = w @ zc                               # posterior mean of clipped outputs, all points
        F = np.max(np.abs(fhat))
        KL = np.sum(w * (-ell)) - np.log(Zn)
        TV = 0.5 * np.mean(np.abs(lam / Zn - 1))
        k = eta * n; s2 = N ** (-gamma)
        Fb = s2 * (4 * k + np.sqrt(2 * k)); KLb = k * s2 * (1 + 8 * k + 2 * np.sqrt(2 * k)); TVb = np.sqrt(KLb / 2)
        mse = np.mean((1 - fhat[n:]) ** 2)
        print(f"L={L} N={N:6d}: sup|fhat|={F:.2e} ({min(Fb,1):.2e})  KL={KL:.2e} ({KLb:.2e})  TV={TV:.2e} ({min(TVb,1):.2e})  test MSE={mse:.4f}"
              f"  ok={F <= Fb and KL <= KLb and TV <= TVb}")
        sys.stdout.flush()
