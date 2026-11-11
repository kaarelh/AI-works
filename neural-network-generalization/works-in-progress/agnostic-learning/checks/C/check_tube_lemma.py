"""Claim C, Lemma C.3.1 (teacher-tube mass at an arbitrary prior scale sigma), Appendix C.A Step 3, and the cloning
facts of Section C.3.1 (Section C.8 item 3): deterministic part.

For a random teacher g (depth L, width m, weights in [-B,B]) and its balanced clone w_* at width N,
draw perturbations zeta in the symmetric event E of the proof (cylinder half-width h/tbar, op-norm <= b0 sqrt N),
form w = w_* + scaled(zeta) at scale sigma (t = sigma sqrt N, tbar = max(1,t)), and check on many inputs of
[-1,1]^d (random points and cube corners) that
   e_1 <= h(d+1),   e_l <= (sqrt2 m B + tbar b0) e_{l-1} + sqrt(m) h,   |z_w - g| <= sqrt2 m B e_{L-1} + h <= h P0(tbar).
Also checks the clone identities (exact computation of g, energy <= E_*, ||W_*||op <= sqrt2 mB, sqrt N ||v_*|| <= sqrt2 mB).
Gaussian coordinates (m_nu = M_nu = 1).
"""
import numpy as np
rng = np.random.default_rng(2)

def forward(Ws, v, X):
    h = np.tanh(Ws[0] @ np.vstack([np.ones(X.shape[1]), X]))
    hs = [h]
    for W in Ws[1:]:
        h = np.tanh(W @ h); hs.append(h)
    return hs, v @ h

def clone(T, u, N):
    m = u.shape[0]
    sizes = np.full(m, N // m); sizes[: N % m] += 1
    grp = np.repeat(np.arange(m), sizes)
    W1 = T[0][grp, :]
    Ws = [W1]
    for Tl in T[1:]:
        Ws.append(Tl[np.ix_(grp, grp)] / sizes[grp][None, :])
    v = u[grp] / sizes[grp]
    return Ws, v, grp, sizes

def check(d, m, B, L, N, t, h, trials=20, npts=400):
    b0 = 2 * np.sqrt(2 * (2 * np.log(9) + np.log(4 * L)))
    tbar = max(1.0, t)
    A0 = 2 + 3 * m * B + tbar * b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    sigma = t / np.sqrt(N)
    T = [rng.uniform(-B, B, (m, d + 1))] + [rng.uniform(-B, B, (m, m)) for _ in range(L - 2)]
    u = rng.uniform(-B, B, m)
    Ws, v, grp, sizes = clone(T, u, N)
    X = rng.uniform(-1, 1, (d, npts)); X[:, :min(npts, 2 ** d)] = np.sign(X[:, :min(npts, 2 ** d)])
    _, g = forward(T, u, X)
    hs_star, z_star = forward(Ws, v, X)
    assert np.max(np.abs(z_star - g)) < 1e-10, "clone does not compute g"
    E_star = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    kappa = d / N * np.sum(Ws[0] ** 2) + sum(np.sum(W ** 2) for W in Ws[1:]) + N * np.sum(v ** 2)
    opn = max([np.linalg.norm(W, 2) for W in Ws[1:]] + [0])
    assert kappa <= E_star + 1e-9 and opn <= np.sqrt(2) * m * B + 1e-9 and np.sqrt(N) * np.linalg.norm(v) <= np.sqrt(2) * m * B + 1e-9
    # group-constant projection basis
    U = np.zeros((N, m)); U[np.arange(N), grp] = 1 / np.sqrt(sizes[grp])
    worst = {"e1": 0, "rec": 0, "out": 0, "outP0": 0}
    for _ in range(trials):
        z1 = rng.choice([-1, 1], (N, d + 1)) * h / tbar
        zL = rng.choice([-1, 1], N) * h / tbar
        Zs = []
        for _l in range(L - 2):
            Z = rng.standard_normal((N, N))
            ZP = Z @ U                      # group sums <Z_i*, u_j>
            target = rng.choice([-1, 1], ZP.shape) * h / tbar
            Z = Z + (target - ZP) @ U.T     # now <Z_i*, u_j> = +-h/tbar exactly
            assert np.allclose(Z @ U, target)
            assert np.linalg.norm(Z, 2) <= b0 * np.sqrt(N)
            Zs.append(Z)
        W1 = Ws[0] + sigma * np.sqrt(N / d) * z1
        Wl = [W + sigma * Z for W, Z in zip(Ws[1:], Zs)]
        vv = v + sigma / np.sqrt(N) * zL
        hs, z = forward([W1] + Wl, vv, X)
        e = [np.linalg.norm(a - b, axis=0) / np.sqrt(N) for a, b in zip(hs, hs_star)]
        worst["e1"] = max(worst["e1"], np.max(e[0]) / (h * (d + 1)))
        for l in range(1, L - 1):
            bound = (np.sqrt(2) * m * B + tbar * b0) * e[l - 1] + np.sqrt(m) * h
            worst["rec"] = max(worst["rec"], np.max(e[l] / bound))
        outb = np.sqrt(2) * m * B * e[L - 2] + h
        worst["out"] = max(worst["out"], np.max(np.abs(z - g) / outb))
        worst["outP0"] = max(worst["outP0"], np.max(np.abs(z - g)) / (h * P0))
    return worst, P0

print("ratios actual/bound (all must be <= 1):")
for (d, m, B, L, N) in [(3, 2, 1.5, 2, 7), (3, 2, 1.5, 3, 7), (4, 3, 2.0, 4, 10), (2, 1, 1.0, 5, 6), (5, 4, 1.0, 3, 41)]:
    for t in [0.2, 1.0, 4.0]:
        for h in [0.5, 0.05]:
            w, P0 = check(d, m, B, L, N, t, h)
            print(f"d={d} m={m} B={B} L={L} N={N} t={t:3.1f} h={h:4.2f}: e1 {w['e1']:.3f}  recursion {w['rec']:.3f}  output {w['out']:.3f}  output/(hP0) {w['outP0']:.2e}")
