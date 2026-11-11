"""Independent network-level checks for B.md.
(1) Lemma 2.1(a),(b): sup|z| <= sqrt(kappa); |z(x)-z(x')| <= d^{-1/2} (kappa/L)^{L/2} |x-x'| on random pairs.
(2) Lemma 2.2 cloning with UNEQUAL groups (N not a multiple of m): exactness and per-layer energy bounds.
(3) Lemma 7.2 memorizer with the lemma's own parameters (A_max, beta, R, m_t), groups of unequal size,
    energy accounting checked against explicit weight matrices on a reduced instance, and the full-size
    instance checked through the (exact) grouped forward pass."""
import itertools, math
import numpy as np
rng = np.random.default_rng(2026)

def forward(Ws, v, X):
    h = np.hstack([np.ones((X.shape[0], 1)), X])
    for W in Ws: h = np.tanh(h @ W.T)
    return h @ v

def energy(Ws, v, d):
    N = Ws[0].shape[0]
    parts = [d / N * np.sum(Ws[0] ** 2)] + [np.sum(W ** 2) for W in Ws[1:]] + [N * np.sum(v ** 2)]
    return np.array(parts)

# (1) Lemma 2.1
worst_a = worst_b = 0.0
for _ in range(3000):
    d = int(rng.integers(1, 7)); H = int(rng.integers(1, 5)); N = int(rng.integers(1, 12)); L = H + 1
    sc = 10 ** rng.uniform(-1, 1)
    Ws = [rng.standard_normal((N, d + 1)) * sc * math.sqrt(N / d)] + [rng.standard_normal((N, N)) * sc for _ in range(H - 1)]
    v = rng.standard_normal(N) * sc / math.sqrt(N)
    kap = energy(Ws, v, d).sum()
    X = rng.uniform(-1, 1, size=(200, d)); Xp = X + rng.standard_normal((200, d)) * 10 ** rng.uniform(-4, 0)
    z, zp = forward(Ws, v, X), forward(Ws, v, Xp)
    worst_a = max(worst_a, np.max(np.abs(z)) / math.sqrt(kap))
    lip = d ** -0.5 * (kap / L) ** (L / 2)
    worst_b = max(worst_b, np.max(np.abs(z - zp) / np.linalg.norm(X - Xp, axis=1)) / lip)
print(f"(1) Lemma 2.1: max sup|z|/sqrt(kappa) = {worst_a:.3f} (<=1);  max Lipschitz ratio = {worst_b:.3f} (<=1)")

# (2) Lemma 2.2 cloning with unequal groups
worst = 0.0; maxerr = 0.0
for _ in range(500):
    d = int(rng.integers(1, 6)); H = int(rng.integers(1, 5)); m = int(rng.integers(1, 6)); L = H + 1
    N = int(rng.integers(m, 5 * m + 4)); B = 10 ** rng.uniform(-1, 1)
    U1 = rng.uniform(-B, B, (m, d + 1)); Us = [rng.uniform(-B, B, (m, m)) for _ in range(H - 1)]; u = rng.uniform(-B, B, m)
    q, rr = divmod(N, m); k = np.array([q + 1] * rr + [q] * (m - rr)); grp = np.repeat(np.arange(m), k)
    W1 = U1[grp]; Wl = [Ul[np.ix_(grp, grp)] / k[grp][None, :] for Ul in Us]; vv = u[grp] / k[grp]
    X = rng.uniform(-1, 1, size=(100, d)) * 3
    maxerr = max(maxerr, np.max(np.abs(forward([W1] + Wl, vv, X) - forward([U1] + Us, u, X))))
    e = energy([W1] + Wl, vv, d)
    bounds = np.array([d * (d + 1) * B ** 2] + [2 * m ** 2 * B ** 2] * H)
    worst = max(worst, np.max(e / bounds))
print(f"(2) Lemma 2.2: max clone error = {maxerr:.2e}; max per-layer energy / bound = {worst:.3f} (<=1)")

# (3) Lemma 7.2 memorizer
def staircase_rows(r, d):
    M = 2 ** d
    X = np.array(list(itertools.product([-1, 1], repeat=d)), dtype=float); Xb = np.hstack([np.ones((M, 1)), X])
    rows, coefs = [], []
    for s in itertools.product([0, 1], repeat=d):
        S = np.array(s, bool); kk = int(S.sum())
        rhat = np.mean(r * np.prod(np.where(S, X, 1.0), axis=1))
        if abs(rhat) < 1e-15: continue
        if kk == 0:
            rows.append(np.r_[1.0, np.zeros(d)]); coefs.append(rhat); continue
        ts = np.arange(-kk, kk + 1, 2); phi = (-1.0) ** ((kk - ts) // 2)
        c0 = (phi[0] + phi[-1]) / 2
        if c0 != 0: rows.append(np.r_[1.0, np.zeros(d)]); coefs.append(rhat * c0)
        for j in range(1, kk + 1):
            th = -kk + 2 * j - 1; Dj = phi[j] - phi[j - 1]
            rows.append(np.r_[-th, S.astype(float)]); coefs.append(rhat * Dj / 2)
    rows = np.array(rows); coefs = np.array(coefs)
    sgn = np.sign(coefs); rows = rows * sgn[:, None]; coefs = np.abs(coefs)   # absorb signs
    return X, Xb, rows, coefs

def memorizer(d, H, t, n_samples=None):
    M = 2 ** d; n = M if n_samples is None else n_samples
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    k = np.bincount(idx, minlength=M); ybar = np.where(k > 0, np.bincount(idx, weights=y, minlength=M) / np.maximum(k, 1), 0.0)
    r = ybar; s = n
    X, Xb, rows, coefs = staircase_rows(r, d)
    A = coefs.sum(); Amax = (d + 1) * math.sqrt(s)
    pre = Xb @ rows.T
    assert np.max(np.abs(np.sign(pre) @ coefs - r)) < 1e-12 and np.min(np.abs(pre)) >= 1 - 1e-12
    assert np.max(np.linalg.norm(rows, axis=1)) <= d + 1e-12 and A <= Amax + 1e-12
    beta = max(1.0, 0.5 * math.log(2 * Amax / t))
    R2 = max(2.0, 9 / (4 * t), Amax ** (2 / H)); R = math.sqrt(R2)
    mt = math.ceil(2 * (d + 1) * Amax ** 2 * math.log(2) / t ** 2) + 1
    # sample m_t features from pi = coefs/A
    J = rng.choice(len(coefs), size=mt, p=coefs / A); om = rows[J]
    feats = np.zeros(M)
    for c in range(0, mt, 100000): feats += np.tanh(beta * (Xb @ om[c:c + 100000].T)).sum(1)
    g = A * feats / mt
    rbeta = A * (np.tanh(beta * pre) @ (coefs / A))
    # width N not a multiple of m_t: groups of size 1 and 2
    N = mt + mt // 3
    q, rem = divmod(N, mt); kj = np.array([q + 1] * rem + [q] * (mt - rem))
    a1 = d / N * np.sum(kj * beta ** 2 * np.sum(om ** 2, axis=1))
    a2 = N * np.sum(kj * (A / (mt * kj * R ** (H - 1))) ** 2)
    total = a1 + a2 + (H - 2) * R2 + R2
    # forward pass of the grouped network (layer-2 preactivation = sum_j k_j * A/(mt k_j R^{H-1}) * tanh(...) = g/R^{H-1})
    s_ = g / R ** (H - 1); u = np.tanh(s_)
    for _ in range(H - 2): u = np.tanh(R * u)
    z = R * u
    return dict(d=d, H=H, t=t, n=n, A=A, Amax=Amax, beta=beta, R2=R2, mt=mt, N=N,
                samp=np.max(np.abs(g - rbeta)), tanh_err=np.max(np.abs(rbeta - r)), gmax=np.max(np.abs(g)),
                chain=np.max(np.abs(z - g)), err=np.max(np.abs(z - r)), a1=a1, a2=a2, a2b=2 * A ** 2 / R ** (2 * H - 2),
                total=total, Kmem=beta ** 2 * d ** 3 + (H + 1) * R2)

for (d, H, t) in [(3, 2, 0.25), (4, 2, 0.25), (4, 3, 0.2), (5, 2, 0.25), (5, 4, 0.25), (6, 3, 0.25)]:
    o = memorizer(d, H, t)
    print(f"(3) d={o['d']} H={o['H']} t={o['t']}: A={o['A']:.2f}<=Amax={o['Amax']:.2f}, beta={o['beta']:.2f}, R^2={o['R2']:.2f},"
          f" m_t={o['mt']}, N={o['N']}")
    print(f"      |r_beta-r|={o['tanh_err']:.3e}<=t, |g-r_beta|={o['samp']:.4f}<=t, max|g|={o['gmax']:.3f}<=1.5,"
          f" chain={o['chain']:.4f}<=t, total |z-r|={o['err']:.4f}<=3t={3*o['t']:.2f}")
    print(f"      energy: a1={o['a1']:.1f}<=beta^2 d^3={o['beta']**2*o['d']**3:.1f}, a2={o['a2']:.3f}<=2A^2/R^(2H-2)={o['a2b']:.3f}<=2R^2,"
          f" total={o['total']:.1f}<=K_mem={o['Kmem']:.1f}")

# explicit-matrix check of the energy accounting and the chain on a reduced instance (few features, unequal groups)
d, H, t = 4, 3, 0.25
X, Xb, rows, coefs = staircase_rows(rng.choice([-1.0, 0.0, 1.0], 2 ** d), d)
A = coefs.sum(); beta = 2.0; R = 3.0; m = 37; N = 53
J = rng.choice(len(coefs), size=m, p=coefs / A); om = rows[J]
q, rem = divmod(N, m); kj = np.array([q + 1] * rem + [q] * (m - rem)); grp = np.repeat(np.arange(m), kj)
W1 = beta * om[grp]
W2 = np.tile(A / (m * kj[grp] * R ** (H - 1)), (N, 1))
Ws = [W1, W2] + [np.full((N, N), R / N) for _ in range(H - 2)]; v = np.full(N, R / N)
z = forward(Ws, v, X)
g = A / m * np.tanh(beta * (Xb @ om.T)).sum(1); u = np.tanh(g / R ** (H - 1))
for _ in range(H - 2): u = np.tanh(R * u)
e = energy(Ws, v, d)
print(f"(3b) explicit matrices (d=4,H=3,m=37,N=53): |z - chain formula| = {np.max(np.abs(z - R*u)):.2e};"
      f" a2 = {e[1]:.4f} vs N*sum k_j (A/(m k_j R^(H-1)))^2 = {N*np.sum(kj*(A/(m*kj*R**(H-1)))**2):.4f};"
      f" a3 = {e[2]:.4f} (R^2={R*R}); aL = {e[3]:.4f} (R^2)")
