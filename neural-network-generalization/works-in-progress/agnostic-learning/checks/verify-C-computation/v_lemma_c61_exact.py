"""Exact (quadrature) check of Lemma C.6.1 (i)-(iii), Gaussian and non-Gaussian coordinate laws.

Lemma C.6.1 holds for any product prior whose readout is s*xi, xi iid nu, independent of the hidden weights.
Its proof only uses (P1)-(P4) conditionally on the hidden weights, so it applies in particular when the hidden
features are FIXED (point-mass hidden prior). Then z_w(x) = s * sum_j h_j(x) xi_j, and everything is a low-dim integral.
 - N = 1: one-dimensional quadrature on a fine grid of xi.
 - N = 2: two-dimensional quadrature.
Coordinate laws: Gaussian (m=M=1) and the paper's example  q(t) ~ exp(-t^2/2 - b log cosh t), variance-standardized;
for it V'' = sd^2 (1 + b sech^2(sd u)) so m_nu = sd^2 (inf, |u|->inf), M_nu = sd^2 (1+b).
Bounds (sigma_out^2 = N s^2, k = eta t / m_nu):
 (i)   sup_x |fhat_t(x)| <= sigma_out^2 (4k + sqrt(2k))
 (ii)  KL(Pi_t || mu) <= eta t sigma_out^2 (1 + 8k + 2 sqrt(2k))
 (iii) sup_x int z^2 dPi_t <= 4 sigma_out^2/m_nu (KL + log(2)/2)
Adversarial configuration for (i): all features h(x_i) = 1, labels y_i = +1, test feature 1 (pushes the mean up).
"""
import numpy as np
rng = np.random.default_rng(5)

def logcosh(x):
    return np.logaddexp(x, -x) - np.log(2.0)

def make_law(kind, b=0.0):
    grid = np.linspace(-40, 40, 800001); du = grid[1] - grid[0]
    if kind == 'gauss':
        logd = -grid ** 2 / 2
        m_nu = M_nu = 1.0
    else:
        # unstandardized p(t) ~ exp(-t^2/2 - b log cosh t); compute its sd, then standardize
        lp = -grid ** 2 / 2 - b * logcosh(grid); p = np.exp(lp - lp.max()); p /= p.sum() * du
        sd = np.sqrt(np.sum(grid ** 2 * p) * du)
        logd = -(sd * grid) ** 2 / 2 - b * logcosh(sd * grid)
        m_nu, M_nu = sd ** 2, sd ** 2 * (1 + b)
    logd = logd - logd.max(); dens = np.exp(logd); Zc = dens.sum() * du
    logw = logd - np.log(Zc) + np.log(du)          # log of quadrature weights (sum to 1)
    var = np.sum(np.exp(logw) * grid ** 2)
    assert abs(var - 1) < 1e-6, var
    return grid, logw, du, m_nu, M_nu

def check_N1(law, s, eta, t, feats_tr, ys, feats_te):
    grid, logw, du, m_nu, M_nu = law
    ell = np.zeros_like(grid)
    for h, y in zip(feats_tr, ys):
        ell += eta * (np.clip(s * h * grid, -1, 1) - y) ** 2
    lp = logw - ell; c = lp.max(); post = np.exp(lp - c); Zp = post.sum(); post /= Zp
    logZ = c + np.log(Zp)                       # log int e^{-ell} dmu
    KL = -np.sum(post * ell) - logZ             # KL(Pi||mu) = -int ell dPi - log Z
    F = max(abs(np.sum(post * np.clip(s * h * grid, -1, 1))) for h in feats_te)
    Z2 = max(np.sum(post * (s * h * grid) ** 2) for h in feats_te)
    so2 = s ** 2; k = eta * t / m_nu
    bF = so2 * (4 * k + np.sqrt(2 * k)); bKL = eta * t * so2 * (1 + 8 * k + 2 * np.sqrt(2 * k)); bZ2 = 4 * so2 / m_nu * (KL + np.log(2) / 2)
    return F, bF, KL, bKL, Z2, bZ2

laws = {'gauss': make_law('gauss'), 'logcosh b=1': make_law('lc', 1.0), 'logcosh b=5': make_law('lc', 5.0)}
for name, law in laws.items():
    print(f"law {name}: m_nu={law[3]:.4f}  M_nu={law[4]:.4f}  (m_nu <= 1 <= M_nu: {law[3] <= 1 <= law[4]})")

print("\nN=1, adversarial (all features 1, labels +1): ratio actual/bound for (i), (ii), (iii)")
for name, law in laws.items():
    worst = {'i': 0, 'ii': 0, 'iii': 0}
    for eta in [0.125, 1.0, 10.0]:
        for t in [1, 5, 50, 500]:
            for s in [1e-3, 1e-2, 0.05, 0.1, 0.3]:
                F, bF, KL, bKL, Z2, bZ2 = check_N1(law, s, eta, t, np.ones(t), np.ones(t), [1.0, 0.5, -1.0])
                if bF > 1: continue        # bound (i) vacuous (F <= 1 always); skip from the tightness statistics
                worst['i'] = max(worst['i'], F / bF); worst['ii'] = max(worst['ii'], KL / bKL); worst['iii'] = max(worst['iii'], Z2 / bZ2)
    print(f"  {name:12s}: max ratio (i)={worst['i']:.3f}  (ii)={worst['ii']:.3f}  (iii)={worst['iii']:.3f}")

print("\nN=1, large eta*t and tiny s: (i) ratio; Gaussian prediction 2k/((1+2ks^2)(4k+sqrt(2k))) -> 1/2")
for name in laws:
    for (eta, t) in [(0.125, 8), (0.125, 80), (1.0, 100), (10.0, 1000)]:
        s = 1e-3
        F, bF, *_ = check_N1(laws[name], s, eta, t, np.ones(t), np.ones(t), [1.0])
        k = eta * t
        pred = 2*k/((1+2*k*s*s)*(4*k+np.sqrt(2*k))) if name == 'gauss' else float('nan')
        print(f"  {name:12s} eta*t={k:7.1f}: F/bound = {F/bF:.4f}   Gaussian prediction = {pred:.4f}")

print("\nN=1, random features/labels (200 random samples per law): any violation?")
for name, law in laws.items():
    viol = 0; mx = 0
    for _ in range(200):
        t = int(rng.integers(1, 60)); eta = float(np.exp(rng.uniform(np.log(0.01), np.log(20)))); s = float(np.exp(rng.uniform(np.log(1e-3), np.log(1.0))))
        feats = rng.uniform(-1, 1, t); ys = rng.uniform(-1, 1, t)
        F, bF, KL, bKL, Z2, bZ2 = check_N1(law, s, eta, t, feats, ys, list(rng.uniform(-1, 1, 5)) + [1.0])
        viol += (F > bF * (1 + 1e-9)) + (KL > bKL * (1 + 1e-9)) + (Z2 > bZ2 * (1 + 1e-9))
        if bF < 1: mx = max(mx, F / bF)
    print(f"  {name:12s}: violations={viol}, max (i) ratio when non-vacuous={mx:.3f}")

print("\nN=2 (2-D quadrature), Gaussian and logcosh b=5, fixed features in [-1,1]^2, sigma_out^2 = 2 s^2")
g1 = np.linspace(-9, 9, 1201)
for name in ['gauss', 'logcosh b=5']:
    grid, logw, du, m_nu, M_nu = laws[name]
    d1 = np.exp(np.interp(g1, grid, logw)); d1 /= d1.sum()
    X1, X2 = np.meshgrid(g1, g1, indexing='ij'); W = np.outer(d1, d1)
    viol = 0; mx = 0
    for _ in range(60):
        t = int(rng.integers(1, 30)); eta = float(np.exp(rng.uniform(np.log(0.05), np.log(10)))); s = float(np.exp(rng.uniform(np.log(3e-3), np.log(0.5))))
        H = rng.uniform(-1, 1, (t, 2)); H[: t // 2] = np.sign(H[: t // 2]); ys = np.sign(rng.uniform(-1, 1, t))
        ell = np.zeros_like(X1)
        for (h1, h2), y in zip(H, ys):
            ell += eta * (np.clip(s * (h1 * X1 + h2 * X2), -1, 1) - y) ** 2
        lp = np.log(np.maximum(W, 1e-300)) - ell; c = lp.max(); post = np.exp(lp - c); Zp = post.sum(); post /= Zp
        KL = -np.sum(post * ell) - (c + np.log(Zp))
        Hte = np.vstack([H, rng.uniform(-1, 1, (10, 2)), [[1, 1], [1, -1]]])
        F = max(abs(np.sum(post * np.clip(s * (a * X1 + b * X2), -1, 1))) for a, b in Hte)
        Z2 = max(np.sum(post * (s * (a * X1 + b * X2)) ** 2) for a, b in Hte)
        so2 = 2 * s ** 2; k = eta * t / m_nu
        bF = so2 * (4 * k + np.sqrt(2 * k)); bKL = eta * t * so2 * (1 + 8 * k + 2 * np.sqrt(2 * k)); bZ2 = 4 * so2 / m_nu * (KL + np.log(2) / 2)
        viol += (F > bF * (1 + 1e-9)) + (KL > bKL * (1 + 1e-9)) + (Z2 > bZ2 * (1 + 1e-9))
        if bF < 1: mx = max(mx, F / bF)
    print(f"  {name:12s}: violations={viol}, max (i) ratio when non-vacuous={mx:.3f}")
