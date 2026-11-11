"""Spectral truncation (E-finite-prior-scale.md Lemma 2.4): internal W = low-rank + sigma*Z with sigma=N^{-gamma/2};
discard singular values <= b; check sup_cube |z_w - z_trunc| <= b (H-1) K^{(H-1)/2},
energy of truncated net <= L K, and the prior event {||W_{>b}||_F^2 <= K} when N^{(gamma-1)/2} >= 7/b."""
import numpy as np
from nets import cube, forward, layer_energies
rng = np.random.default_rng(5)
d = 5; X = cube(d)
for H in [2, 3]:
    for (N, gamma) in [(400, 1.5), (800, 1.5), (400, 2.0), (1500, 1.3)]:
        sig = N**(-gamma/2)
        # low-rank signal part (rank 2) with Frobenius norm ~2, first layer and readout modest
        W1 = rng.standard_normal((N, d+1))*np.sqrt(N**(1-gamma)/d) + np.outer(rng.standard_normal(N), rng.standard_normal(d+1))*0.5
        Ws = []
        for _ in range(H-1):
            Lr = sum(np.outer(rng.standard_normal(N), rng.standard_normal(N))/N for _ in range(2))
            Ws.append(Lr*1.0 + sig*rng.standard_normal((N, N)))
        v = rng.standard_normal(N)/N
        w = (W1, Ws, v)
        en = layer_energies(w, d)
        K = max(en[0], en[-1], 1.0)
        trunc = []
        for W in Ws:
            Uu, sv, Vt = np.linalg.svd(W)
            trunc.append((Uu, sv, Vt))
        # choose b = 7 N^{(1-gamma)/2} (smallest admissible threshold), K = max retained Frobenius^2 etc.
        b = 7*N**((1-gamma)/2)
        Wt = []
        for (Uu, sv, Vt) in trunc:
            keep = sv > b
            Wt.append((Uu[:, keep]*sv[keep]) @ Vt[keep])
            K = max(K, np.sum(sv[keep]**2))
        wt = (W1, Wt, v)
        dev = np.abs(forward(w, X)-forward(wt, X)).max()
        bound = b*(H-1)*K**((H-1)/2)
        ent = sum(layer_energies(wt, d))
        opn = [np.linalg.norm(W, 2) for W in Ws]
        print(f"H={H} N={N} gamma={gamma}: b={b:.3f}, bulk op-norm scale 2*sigma*sqrt(N)={2*sig*np.sqrt(N):.3f}, "
              f"K={K:.2f}, sup dev={dev:.4f} <= bound {bound:.3f}: {dev<=bound}; energy(trunc)={ent:.2f} <= L*K={(H+1)*K:.2f}: {ent<=(H+1)*K}")
