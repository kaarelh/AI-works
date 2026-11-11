"""Independent implementation of the Lemma 2.1 memorizer (A.md Section 2) at the lemma's OWN width
N >= N_0(d,s,a) = floor(64 log2 d(d+1)s/a^2)+1 with m = N_0 sampled features (no override), s = min(n,M).

For d=3 the network is built with dense weight matrices and a plain forward pass; for larger d a compressed
representation is used (all neurons of layers >= 2 are identical), but the energy is computed exactly from
the group sizes, i.e. it equals the Frobenius-norm energy of the dense matrices.
Checks: exact Fourier/affine-tanh expansion, A^2 <= 8ds, Hoeffding success, max|z-r| < a, kappa_N <= K_mem.
"""
import itertools, math, sys
import numpy as np

def run(d, H, a, Nmult, seed, dense):
    rng = np.random.default_rng(seed)
    M = 2 ** d; n = M
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    Xb = np.hstack([np.ones((M, 1)), X])
    idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M); S = np.bincount(idx, weights=y, minlength=M)
    r = np.zeros(M); seen = k > 0; r[seen] = S[seen] / k[seen]
    s = min(n, M)
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    # Fourier
    subsets = [c for kk in range(d + 1) for c in itertools.combinations(range(d), kk)]
    chi = np.array([[np.prod(x[list(T)]) if T else 1.0 for T in subsets] for x in X])
    rhat = chi.T @ r / M
    # c_{k,alpha} by direct definition (sum over v in {-1,1}^k)
    def ck(kk):
        b = 0 if kk % 2 else 1
        return np.mean([np.prod(v) * math.tanh(alpha * (sum(v) - b)) for v in itertools.product([-1, 1], repeat=kk)])
    cks = {kk: ck(kk) for kk in range(1, d + 1)}
    rows, gam = [], []
    for j, T in enumerate(subsets):
        if rhat[j] == 0.0:
            continue
        if not T:
            w = np.zeros(d + 1); w[0] = 1.0; rows.append(w); gam.append(rhat[j] / math.tanh(1.0)); continue
        kk = len(T); b = 0 if kk % 2 else 1
        for u in itertools.product([-1, 1], repeat=kk):
            w = np.zeros(d + 1); w[0] = -alpha * b
            for jj, coord in enumerate(T):
                w[1 + coord] = alpha * u[jj]
            rows.append(w); gam.append(rhat[j] * np.prod(u) / (cks[kk] * 2 ** kk))
    rows = np.array(rows); gam = np.array(gam)
    recon_err = float(np.max(np.abs(np.tanh(Xb @ rows.T) @ gam - r)))
    A = float(np.abs(gam).sum())
    rn2max = float(np.max(np.sum(rows ** 2, 1)))
    m = math.floor(64 * math.log(2) * d * (d + 1) * s / a ** 2) + 1
    # sample until max|g-r| < a/2 (the lemma only needs existence; record attempts)
    p = np.abs(gam) / A
    for attempt in range(1, 51):
        pick = rng.choice(len(gam), size=m, p=p)
        srows = rows[pick] * np.sign(gam[pick])[:, None]
        xi = np.tanh(Xb @ srows.T)                    # M x m
        g = (A / m) * xi.sum(1)
        if np.max(np.abs(g - r)) < a / 2:
            break
    gerr = float(np.max(np.abs(g - r)))
    N = Nmult * m + (7 if Nmult > 1 else 0)
    kt = np.full(m, N // m); kt[: N - m * (N // m)] += 1
    assert kt.sum() == N and kt.min() >= N / (2 * m)
    R = max(A ** (1 / H), math.sqrt(9 / (2 * a)))
    w2 = A / (m * kt * R ** (H - 1))                  # weight from each neuron of group t into every layer-2 neuron
    if dense:
        grp = np.repeat(np.arange(m), kt)
        W1 = srows[grp]                                # N x (d+1)
        W2 = np.tile(w2[grp][None, :], (N, 1))         # N x N
        mids = [W2] + [np.full((N, N), R / N) for _ in range(H - 2)]
        v = np.full(N, R / N)
        h = np.tanh(Xb @ W1.T)
        for Wl in mids:
            h = np.tanh(h @ Wl.T)
        z = h @ v
        kap = [(d / N) * np.sum(W1 ** 2)] + [np.sum(Wl ** 2) for Wl in mids] + [N * np.sum(v ** 2)]
    else:
        pre2 = xi @ (kt * w2)                          # sum over all N layer-1 neurons
        yv = np.tanh(pre2)
        for _ in range(H - 2):
            yv = np.tanh(N * (R / N) * yv)
        z = N * (R / N) * yv
        kap = [(d / N) * float(np.sum(kt * np.sum(srows ** 2, 1))), N * float(np.sum(kt * w2 ** 2))]
        kap += [N * N * (R / N) ** 2 for _ in range(H - 2)] + [N * N * (R / N) ** 2]
    K = float(sum(kap))
    Kmem = d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1 / H), 9 / (2 * a))
    zerr = float(np.max(np.abs(z - r)))
    print(f"d={d} H={H} a={a} seed={seed} {'dense' if dense else 'compressed'}: s={s} Q={np.sum(r**2):.2f} "
          f"recon={recon_err:.1e} A^2={A**2:.1f}<=8ds={8*d*s}:{A**2<=8*d*s} rownorm2={rn2max:.3f}<=(d+1)al^2={(d+1)*alpha**2:.3f} "
          f"| m=N0={m} N={N} attempts={attempt} max|g-r|={gerr:.3f}<a/2:{gerr<a/2} | max|z-r|={zerr:.4f}<a:{zerr<a} "
          f"| kappa={K:.3f} (layers {', '.join(f'{x:.2f}' for x in kap)}) <= K_mem={Kmem:.3f}:{K<=Kmem}")
    return zerr < a and K <= Kmem

allok = True
allok &= run(3, 2, 1.0, 1, 1, True)
allok &= run(3, 3, 1.0, 1, 2, True)
allok &= run(3, 2, 0.5, 1, 3, False)
allok &= run(4, 2, 1.0, 1, 4, False)
allok &= run(4, 3, 0.5, 3, 5, False)
allok &= run(5, 2, 0.5, 1, 6, False)
allok &= run(5, 4, 0.25, 2, 7, False)
allok &= run(6, 3, 0.5, 1, 8, False)
print("ALL OK:", allok)
