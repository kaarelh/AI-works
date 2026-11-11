"""Check paper.tex eq. teacher-energy: the balanced clone of a depth-L, width-m teacher
with weights in [-B,B] computes the teacher exactly at width N>=m and has
kappa_N <= E_* = d(d+1)B^2 + 2(L-1)m^2B^2."""
import numpy as np
rng = np.random.default_rng(0)

def forward(Ws, v, X):
    h = np.hstack([np.ones((X.shape[0], 1)), X])
    for W in Ws:
        h = np.tanh(h @ W.T)
    return h @ v

def kappa(Ws, v, d):
    N = Ws[0].shape[0]
    k = (d / N) * np.sum(Ws[0] ** 2)
    for W in Ws[1:]:
        k += np.sum(W ** 2)
    return k + N * np.sum(v ** 2)

def clone(Ts, u, N):
    m = Ts[0].shape[0]
    sizes = np.array([N // m + (1 if j < N % m else 0) for j in range(m)])
    grp = np.repeat(np.arange(m), sizes)
    Ws = [Ts[0][grp, :].copy()]
    for T in Ts[1:]:
        W = T[grp][:, grp] / sizes[grp][None, :]
        Ws.append(W)
    v = u[grp] / sizes[grp]
    return Ws, v

worst = 0.0
for trial in range(400):
    d = int(rng.integers(1, 6)); L = int(rng.integers(2, 6)); m = int(rng.integers(1, 7))
    B = float(rng.uniform(0.3, 3.0))
    Ts = [rng.uniform(-B, B, (m, d + 1))] + [rng.uniform(-B, B, (m, m)) for _ in range(L - 2)]
    # adversarial-ish: put many weights at +-B
    if trial % 2 == 0:
        Ts = [np.sign(T) * B for T in Ts]
    u = rng.uniform(-B, B, m)
    Estar = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    X = rng.uniform(-1, 1, (50, d))
    g = forward(Ts, u, X)
    for N in [m, m + 1, 2 * m - 1 if m > 1 else 2, 3 * m + 2, 50]:
        if N < m:
            continue
        Ws, v = clone(Ts, u, N)
        err = np.max(np.abs(forward(Ws, v, X) - g))
        k = kappa(Ws, v, d)
        assert err < 1e-10, err
        worst = max(worst, k / Estar)
print("clone exact on all trials; max kappa_N/E_* =", round(worst, 4))
