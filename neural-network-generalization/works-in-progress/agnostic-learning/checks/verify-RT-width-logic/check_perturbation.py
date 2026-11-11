"""Check the perturbation bound in the proof of redteam.md Proposition 6.1.

Claim: if kappa_N(w) <= K and ||w - w'||_inf <= delta', then for every x in [-1,1]^d
    |z_w(x) - z_w'(x)| <= delta' * [(d+1) K^{H/2} + N * sum_{j<H} K^{j/2}]      (fine form)
                       <= delta' * H (d+N+1) (K+1)^{H/2}                           (stated form)

Networks: h^0 = (1,x), h^l = tanh(W^l h^{l-1}) (l=1..H), z = v^T h^H.
Energy: (d/N)||W^1||_F^2 + sum_{l=2}^H ||W^l||_F^2 + N||v||^2.
We draw random networks at energy exactly K, with several energy splits, and perturb them
(a) by random signs, (b) by the sign of the gradient at a chosen input (first-order worst case),
(c) by sign patterns aligned with the activations (rank-one, saturating the delta' N^{3/2} term).
"""
import numpy as np

rng = np.random.default_rng(20261111)


def forward(Ws, v, X):
    hs = [np.hstack([np.ones((X.shape[0], 1)), X])]
    for W in Ws:
        hs.append(np.tanh(hs[-1] @ W.T))
    return hs, hs[-1] @ v


def energy(Ws, v, d, N):
    e = (d / N) * np.sum(Ws[0] ** 2)
    for W in Ws[1:]:
        e += np.sum(W ** 2)
    return e + N * np.sum(v ** 2)


def grad_sign(Ws, v, x):
    """sign of dz/dw at a single input x (manual backprop)."""
    hs, _ = forward(Ws, v, x[None, :])
    hs = [h[0] for h in hs]
    gv = hs[-1].copy()
    delta = v * (1 - hs[-1] ** 2)  # dz/d(preact of layer H)
    gWs = [None] * len(Ws)
    for l in range(len(Ws) - 1, -1, -1):
        gWs[l] = np.outer(delta, hs[l])
        if l > 0:
            delta = (Ws[l].T @ delta) * (1 - hs[l] ** 2)
    return [np.sign(g) for g in gWs], np.sign(gv)


def random_net(d, N, H, K, split):
    Ws = [rng.standard_normal((N, d + 1))] + [rng.standard_normal((N, N)) for _ in range(H - 1)]
    v = rng.standard_normal(N)
    L = H + 1
    if split == "dirichlet":
        a = rng.dirichlet(np.ones(L)) * K
    elif split == "equal":
        a = np.ones(L) * K / L
    elif split == "first":
        a = np.full(L, 1e-3); a[0] = K - 1e-3 * (L - 1)
    elif split == "readout":
        a = np.full(L, 1e-3); a[-1] = K - 1e-3 * (L - 1)
    # rescale blocks so that block energies equal a
    Ws[0] *= np.sqrt(a[0] / ((d / N) * np.sum(Ws[0] ** 2)))
    for l in range(1, H):
        Ws[l] *= np.sqrt(a[l] / np.sum(Ws[l] ** 2))
    v *= np.sqrt(a[-1] / (N * np.sum(v ** 2)))
    return Ws, v


def bounds(d, N, H, K, dp):
    fine = dp * ((d + 1) * K ** (H / 2) + N * sum(K ** (j / 2) for j in range(H)))
    stated = dp * H * (d + N + 1) * (K + 1) ** (H / 2)
    return fine, stated


worst_fine = 0.0
worst_stated = 0.0
rows = []
for (d, N, H, K) in [(1, 3, 1, 4.0), (2, 5, 2, 10.0), (3, 8, 2, 50.0), (4, 6, 3, 30.0),
                     (2, 12, 3, 200.0), (5, 10, 4, 100.0), (8, 16, 2, 1000.0), (3, 4, 5, 20.0)]:
    for split in ["dirichlet", "equal", "first", "readout"]:
        for trial in range(25):
            Ws, v = random_net(d, N, H, K, split)
            assert abs(energy(Ws, v, d, N) - K) < 1e-8 * K
            X = rng.uniform(-1, 1, size=(400, d))
            X = np.vstack([X, np.sign(rng.uniform(-1, 1, size=(100, d)))])
            dp = 10.0 ** rng.uniform(-6, -2)
            fine, stated = bounds(d, N, H, K, dp)
            _, z0 = forward(Ws, v, X)
            perts = []
            # (a) random signs
            perts.append(([dp * np.sign(rng.standard_normal(W.shape)) for W in Ws],
                          dp * np.sign(rng.standard_normal(N))))
            # (b) gradient sign at the input with the largest output
            xs = X[np.argmax(np.abs(z0))]
            gW, gv = grad_sign(Ws, v, xs)
            perts.append(([dp * g for g in gW], dp * gv))
            # (c) activation-aligned rank-one signs at xs
            hs, _ = forward(Ws, v, xs[None, :])
            hs = [h[0] for h in hs]
            aligned = []
            for l, W in enumerate(Ws):
                rowsign = np.sign(Ws[l + 1].T @ np.ones(Ws[l + 1].shape[0])) if l + 1 < len(Ws) else np.sign(v)
                rowsign[rowsign == 0] = 1
                aligned.append(dp * np.outer(rowsign, np.sign(hs[l]) + (hs[l] == 0)))
            perts.append((aligned, dp * (np.sign(hs[-1]) + (hs[-1] == 0))))
            for (dW, dv) in perts:
                for s in (+1, -1):
                    Ws2 = [W + s * D for W, D in zip(Ws, dW)]
                    v2 = v + s * dv
                    _, z1 = forward(Ws2, v2, X)
                    diff = np.max(np.abs(z1 - z0))
                    worst_fine = max(worst_fine, diff / fine)
                    worst_stated = max(worst_stated, diff / stated)
                    if diff > fine * (1 + 1e-12):
                        rows.append(("VIOLATION", d, N, H, K, split, dp, diff, fine))
    print(f"d={d:2d} N={N:3d} H={H} K={K:7.1f}: running max ratio actual/fine = {worst_fine:.4f}, "
          f"actual/stated = {worst_stated:.2e}")

print("violations:", rows if rows else "none")
print(f"overall max ratio actual/fine-bound = {worst_fine:.4f}")
print(f"overall max ratio actual/stated-bound = {worst_stated:.3e}")

# algebraic check: fine <= stated for a grid of parameters
ok = True
for d in [1, 2, 5, 20, 100]:
    for N in [1, 2, 10, 100, 1000]:
        for H in [1, 2, 3, 5, 8]:
            for K in [0.0, 0.5, 1.0, 3.0, 100.0, 1e6]:
                f, s = bounds(d, N, H, K, 1.0)
                if f > s * (1 + 1e-12):
                    ok = False
                    print("fine > stated at", d, N, H, K, f, s)
print("fine <= stated on the parameter grid:", ok)
