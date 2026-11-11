"""Check of the memorizer of B.md Lemma 7.2 on {-1,1}^d (small d), depth H+1 (H = 2, 3).
Pieces checked: (i) Fourier l1 bound; (ii) exact staircase expansion r = A E_pi sign(omega.xbar), A <= (d+1)||r||_2;
(iii) |r_beta - r| <= 2A e^{-2 beta}; (iv) sampled g (m features) error; (v) scalar-chain error
<= 2|g|^3/(3R^2); (vi) energy <= beta^2 d^3 + (H+1) R^2 (computed for the realized weights, k_j = 1, N = m)."""
import numpy as np, itertools, math
rng = np.random.default_rng(7)

def run(d, H, t, n_mult=1.0):
    M = 2 ** d
    X = np.array(list(itertools.product([-1, 1], repeat=d)), dtype=float)        # all cube points
    n = int(round(n_mult * M))
    idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M); S = np.bincount(idx, weights=y, minlength=M)
    ybar = np.where(k > 0, S / np.maximum(k, 1), 0.0)
    r = ybar.copy()                                                            # target: ybar on seen atoms, 0 elsewhere
    # (i) Fourier: rhat(S) = E_x r(x) chi_S(x)
    subsets = list(itertools.product([0, 1], repeat=d))
    chi = np.array([[np.prod(x[np.array(s, bool)]) for s in subsets] for x in X])   # M x M
    rhat = chi.T @ r / M
    l1 = np.sum(np.abs(rhat)); l2 = np.sqrt(np.sum(r ** 2))
    # (ii) staircase expansion
    rows, coefs = [], []
    for si, s in enumerate(subsets):
        if abs(rhat[si]) < 1e-15: continue
        Sset = np.array(s, bool); kk = Sset.sum()
        if kk == 0:
            rows.append(np.r_[1.0, np.zeros(d)]); coefs.append(rhat[si]); continue
        thetas = np.arange(-kk + 1, kk, 2); ts = np.arange(-kk, kk + 1, 2)
        phi = (-1.0) ** ((kk - ts) // 2); c0 = (phi[0] + phi[-1]) / 2; eps = np.diff(phi) / 2
        if c0 != 0: rows.append(np.r_[1.0, np.zeros(d)]); coefs.append(rhat[si] * c0)
        for th, e in zip(thetas, eps):
            rows.append(np.r_[-th, Sset.astype(float)]); coefs.append(rhat[si] * e)
    rows = np.array(rows); coefs = np.array(coefs)
    Xb = np.hstack([np.ones((M, 1)), X])
    pre = Xb @ rows.T
    exact = np.max(np.abs(np.sign(pre) @ coefs - r))
    A = np.sum(np.abs(coefs)); Amax = (d + 1) * math.sqrt(n)
    margin = np.min(np.abs(pre)); rownorm2 = np.max(np.sum(rows ** 2, 1))
    # (iii) tanh approximation
    beta = max(1.0, 0.5 * math.log(2 * Amax / t))
    rbeta = np.tanh(beta * pre) @ coefs
    e3 = np.max(np.abs(rbeta - r))
    # (iv) sampling m features from pi (signs absorbed into rows)
    # Lemma needs m > 2A^2 ln(2M)/t^2 (existence); we add ln 20 so a random draw succeeds w.p. >= 0.95
    m_needed = math.ceil(2 * A ** 2 * (math.log(2 * M) + math.log(20)) / t ** 2) + 1
    p = np.abs(coefs) / A; sgn = np.sign(coefs)
    J = rng.choice(len(coefs), size=m_needed, p=p)
    om = rows[J] * sgn[J][:, None]
    g = np.zeros(M)
    for c in range(0, m_needed, 200000):
        g += np.tanh(beta * (Xb @ om[c:c + 200000].T)).sum(1)
    g *= A / m_needed
    e4 = np.max(np.abs(g - rbeta))
    # (v) chain with R^2 = max{2, 9/(4t), A^{2/H}}
    R2 = max(2.0, 9 / (4 * t), A ** (2 / H)); R = math.sqrt(R2)
    u = np.tanh(g / R ** (H - 1))
    for _ in range(H - 2): u = np.tanh(R * u)
    z = R * u
    e5 = np.max(np.abs(z - g)); b5 = 2 * np.max(np.abs(g)) ** 3 / (3 * R2)
    # (vi) energy for the realized weights at width N = m (k_j = 1)
    N = m_needed
    E1 = (d / N) * np.sum((beta * om) ** 2)
    E2 = N * N * (A / (N * R ** (H - 1))) ** 2          # N rows, each with N entries A/(m R^{H-1})
    Eint = (H - 2) * R2; Eout = R2
    Etot = E1 + E2 + Eint + Eout; Ebound = beta ** 2 * d ** 3 + (H + 1) * R2
    tot = np.max(np.abs(z - r))
    print(f"d={d} H={H} n={n} t={t}: |T|={np.sum(k>0)}, ||r||_2={l2:.3f}, sum|rhat|={l1:.3f} (<= ||r||_2)")
    print(f"   exact expansion err={exact:.1e}, A={A:.2f} <= (d+1)||r||_2={(d+1)*l2:.2f}, margin={margin:.0f}, max|row|^2={rownorm2:.0f} <= d^2={d*d}")
    print(f"   beta={beta:.3f}: |r_beta-r|={e3:.2e} <= 2A e^(-2beta)={2*A*math.exp(-2*beta):.2e} <= t")
    print(f"   m={m_needed}: sampling err |g-r_beta|={e4:.4f} (Hoeffding target t={t}); max|g|={np.max(np.abs(g)):.3f}")
    print(f"   R^2={R2:.2f}: chain err={e5:.2e} <= 2|g|^3/(3R^2)={b5:.2e} <= t")
    print(f"   total sup|z-r|={tot:.4f} <= 3t={3*t:.2f};  energy={Etot:.2f} <= beta^2 d^3+(H+1)R^2={Ebound:.2f}"
          f"  [first layer {E1:.2f}, second {E2:.2f}]")

for (d, H, t) in [(4, 2, 0.15), (5, 2, 0.15), (5, 3, 0.15), (6, 2, 0.2)]:
    run(d, H, t)
