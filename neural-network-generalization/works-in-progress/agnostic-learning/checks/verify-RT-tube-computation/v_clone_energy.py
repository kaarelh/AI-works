"""Check paper.tex eq. teacher-energy, used by Prop 4.1 through the denominator:
the balanced-group clone of a width-C teacher computes it exactly at every width
N >= C, with kappa_N <= E_* = d(d+1)B^2 + 2(L-1)C^2B^2 and per-layer bounds
d(d+1)B^2, 2C^2B^2 (internal), 2C^2B^2 (readout)."""
import numpy as np

rng = np.random.default_rng(7)


def forward(Ws, v, X):
    h = np.hstack([np.ones((X.shape[0], 1)), X])
    for W in Ws:
        h = np.tanh(h @ W.T)
    return h @ v


def energy_parts(Ws, v, d):
    N = v.shape[0]
    parts = [d / N * np.sum(Ws[0] ** 2)] + [np.sum(W ** 2) for W in Ws[1:]] + [N * np.sum(v ** 2)]
    return parts


def clone(Ts, u, N):
    C = u.shape[0]
    k = np.full(C, N // C)
    k[: N % C] += 1                       # sizes in {floor(N/C), ceil(N/C)}
    grp = np.repeat(np.arange(C), k)
    Ws = [Ts[0][grp, :]]
    for T in Ts[1:]:
        Ws.append(T[np.ix_(grp, grp)] / k[grp][None, :])
    v = u[grp] / k[grp]
    return Ws, v


worst_ratio, worst_err, worst_layer = 0.0, 0.0, [0.0, 0.0, 0.0]
cases = 0
for L in [2, 3, 4, 5]:
    for trial in range(150):
        d = int(rng.integers(1, 7)); C = int(rng.integers(1, 6)); B = float(rng.uniform(1, 3))
        extreme = trial % 3 == 0                    # all entries +-B: maximal teacher energy
        draw = (lambda s: B * rng.choice([-1, 1], size=s)) if extreme else (lambda s: rng.uniform(-B, B, s))
        Ts = [draw((C, d + 1))] + [draw((C, C)) for _ in range(L - 2)]
        u = draw(C)
        Estar = d * (d + 1) * B ** 2 + 2 * (L - 1) * C ** 2 * B ** 2
        X = rng.uniform(-1, 1, (64, d))
        f = forward(Ts, u, X)
        for N in sorted({C, C + 1, 2 * C - 1, 2 * C + 1, 3 * C + 2, 7 * C + 3, 50}):
            if N < C:
                continue
            Ws, v = clone(Ts, u, N)
            err = np.max(np.abs(forward(Ws, v, X) - f))
            parts = energy_parts(Ws, v, d)
            worst_err = max(worst_err, err)
            worst_ratio = max(worst_ratio, sum(parts) / Estar)
            worst_layer[0] = max(worst_layer[0], parts[0] / (d * (d + 1) * B ** 2))
            for p in parts[1:-1]:
                worst_layer[1] = max(worst_layer[1], p / (2 * C ** 2 * B ** 2))
            worst_layer[2] = max(worst_layer[2], parts[-1] / (2 * C ** 2 * B ** 2))
            cases += 1
print(f"clones checked: {cases}")
print(f"max |z_clone - g| on random inputs: {worst_err:.2e}")
print(f"max kappa_N / E_*: {worst_ratio:.4f}  (must be <= 1)")
print(f"max layer ratios: first/(d(d+1)B^2) = {worst_layer[0]:.4f}, internal/(2C^2B^2) = {worst_layer[1]:.4f},"
      f" readout/(2C^2B^2) = {worst_layer[2]:.4f}")
# a near-tight case for the internal/readout factor 2: N = 2C-1 gives sizes 1 and 2
C, B, d, L = 3, 1.0, 1, 3
Ts = [B * np.ones((C, d + 1)), B * np.ones((C, C))]; u = B * np.ones(C)
for N in [C, 2 * C - 1, 2 * C, 100 * C - 1]:
    Ws, v = clone(Ts, u, N)
    print(f"  all-ones teacher C=3, N={N}: layer energies {np.round(energy_parts(Ws, v, d), 4)},"
          f" E_*={d*(d+1)*B**2 + 2*(L-1)*C**2*B**2}")
