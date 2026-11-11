"""Checks for Sections 2-4 of A.md.

(1) |t - tanh t| <= |t|^3/3 on a grid; chain error |R y_{H-1} - g| <= (|g|^3/3) sum_{i=1}^{H-1} R^{-2i}
    for the scalar chain y_1 = tanh(g/R^{H-1}), y_j = tanh(R y_{j-1}); and <= a/2 when |g| <= 3/2, R^2 >= 9/(2a).
(2) beta(lambda) = E[1/K; K>=1], K ~ Poisson(lambda): closed form e^{-l}(Ei(l)-gamma-log l), values, argmax,
    Lipschitz property |beta'| <= 1; binomial version beta_n for K ~ Bin(n, 2^-d) and the Le Cam bound lambda/M.
(3) Monte Carlo of Q = sum_{seen x} ybar_x^2 at n = 2^d: mean vs M beta_n and fluctuations vs McDiarmid sqrt(2n log(1/delta)).
(4) Energy-Lipschitz and output bounds |z_w(x)| <= sqrt(kappa), Lip <= sqrt(prod kappa_l / d) <= (kappa/L)^{L/2}/sqrt d
    on random networks (empirical gradient norms are lower estimates of the Lipschitz constant).
(5) The normalized-tanh clip-mixture identity (13) of the noisy-interpolation note, by quadrature.
"""
import math, itertools
import numpy as np
from scipy import special, stats, optimize, integrate

rng = np.random.default_rng(0)

# (1)
t = np.linspace(-5, 5, 200001)
print("(1) max of (|t-tanh t| - |t|^3/3) on [-5,5]:", float(np.max(np.abs(t - np.tanh(t)) - np.abs(t) ** 3 / 3)))
worst_ratio = 0.0; worst_acc = -1.0
for H in [2, 3, 4, 6, 10]:
    for R2 in [2.0, 4.5, 9.0, 50.0, 1e3]:
        R = math.sqrt(R2)
        g = np.linspace(-1.5, 1.5, 3001)
        y = np.tanh(g / R ** (H - 1))
        for _ in range(H - 2):
            y = np.tanh(R * y)
        z = R * y
        bound = np.abs(g) ** 3 / 3 * sum(R ** (-2 * i) for i in range(1, H))
        mask = bound > 0
        worst_ratio = max(worst_ratio, float(np.max(np.abs(z - g)[mask] / bound[mask])))
    for a in [1.0, 0.5, 0.1, 0.01]:
        R = math.sqrt(9 / (2 * a)); g = np.linspace(-1.5, 1.5, 3001)
        y = np.tanh(g / R ** (H - 1))
        for _ in range(H - 2):
            y = np.tanh(R * y)
        worst_acc = max(worst_acc, float(np.max(np.abs(R * y - g)) / (a / 2)))
print(f"    chain: max |z-g| / predicted bound = {worst_ratio:.4f} (<=1 required); "
      f"max |z-g|/(a/2) at R^2=9/(2a), |g|<=3/2: {worst_acc:.4f} (<=1 required)")

# (2)
def beta_pois(lam, kmax=400):
    k = np.arange(1, kmax)
    logp = -lam + k * np.log(lam) - special.gammaln(k + 1)
    return float(np.sum(np.exp(logp) / k))

def beta_closed(lam):
    return math.exp(-lam) * (special.expi(lam) - np.euler_gamma - math.log(lam))

def beta_bin(n, M):
    k = np.arange(1, min(n, 400) + 1)
    return float(np.sum(stats.binom.pmf(k, n, 1.0 / M) / k))

for lam in [0.25, 0.5, 1.0, 1.5, 2.0, 4.0]:
    print(f"(2) lambda={lam}: beta_pois={beta_pois(lam):.6f}  closed form={beta_closed(lam):.6f}  (1-e^-l)/l={(1-math.exp(-lam))/lam:.6f}")
res = optimize.minimize_scalar(lambda l: -beta_pois(l), bounds=(0.2, 5), method="bounded", options={"xatol": 1e-10})
print(f"    argmax beta = {res.x:.5f}, max = {-res.fun:.6f}; first-order condition beta = (1-e^-l)/l: "
      f"{(1-math.exp(-res.x))/res.x:.6f}")
lams = np.linspace(0.01, 20, 4000); b = np.array([beta_pois(l) for l in lams])
print(f"    max |beta'| on [0.01,20] (finite differences) = {np.max(np.abs(np.diff(b)/np.diff(lams))):.4f}  (<=1 claimed)")
for d in [6, 10, 16, 20, 30]:
    M = 2 ** d
    for lam in [1.0, 1.5]:
        n = int(round(lam * M))
        bn = beta_bin(n, M)
        print(f"    d={d} n={n}: beta_n(binomial)={bn:.6f}, |beta_n - beta(n/M)|={abs(bn-beta_pois(n/M)):.2e} <= Le Cam n/M^2={n/M**2:.2e}")

# (3)
print("(3) Monte Carlo of Q/M at n=2^d (fair labels):")
for d in [10, 14, 18]:
    M = 2 ** d; n = M
    vals = []
    for rep in range(200 if d < 18 else 50):
        x = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
        k = np.bincount(x, minlength=M); S = np.bincount(x, weights=y, minlength=M)
        seen = k > 0
        vals.append(np.sum((S[seen] / k[seen]) ** 2) / M)
    vals = np.array(vals); bn = beta_bin(n, M)
    dev01 = math.sqrt(2 * n * math.log(1 / 0.01)) / M
    print(f"    d={d}: mean Q/M={vals.mean():.5f} (beta_n={bn:.5f}), sd={vals.std():.5f}, "
          f"min={vals.min():.5f}; McDiarmid 1%-deviation={dev01:.5f}; min >= beta_n - dev: {vals.min() >= bn - dev01}")

# (4)
worst = 0.0; worst_out = 0.0
for trial in range(400):
    L = int(rng.integers(2, 6)); N = int(rng.integers(2, 30)); dd = int(rng.integers(1, 7))
    Ws = [rng.normal(size=(N, dd + 1)) * rng.uniform(0.1, 3)]
    Ws += [rng.normal(size=(N, N)) * rng.uniform(0.01, 1.5) for _ in range(L - 2)]
    v = rng.normal(size=N) * rng.uniform(0.01, 1.5)
    parts = [(dd / N) * np.sum(Ws[0] ** 2)] + [np.sum(A ** 2) for A in Ws[1:]] + [N * np.sum(v ** 2)]
    K = sum(parts)
    lip_prod = math.sqrt(np.prod(parts) / dd); lip_amgm = (K / L) ** (L / 2) / math.sqrt(dd)
    assert lip_prod <= lip_amgm * (1 + 1e-12)
    best = 0.0; outmax = 0.0
    for _ in range(100):
        xx = rng.uniform(-1, 1, size=dd); h = np.concatenate([[1.0], xx]); J = np.eye(dd + 1)[:, 1:]
        for A in Ws:
            h = np.tanh(A @ h); J = (1 - h ** 2)[:, None] * (A @ J)
        best = max(best, float(np.linalg.norm(v @ J))); outmax = max(outmax, abs(float(v @ h)))
    worst = max(worst, best / lip_prod); worst_out = max(worst_out, outmax / math.sqrt(K))
print(f"(4) random nets: max grad/sqrt(prod kappa_l/d) = {worst:.4f} (<=1), max |z|/sqrt(kappa) = {worst_out:.4f} (<=1)")

# (5)
worst = 0.0
for r in [0.1, 0.7, 1.0, 3.0, 10.0]:
    for u in np.linspace(-1, 1, 41):
        clip = lambda tt: max(-tt, min(tt, u))
        w = lambda tt: 2 * r * math.tanh(r * tt) / math.cosh(r * tt) ** 2
        val, _ = integrate.quad(lambda tt: clip(tt) * w(tt), 0, 1, limit=200, points=[abs(u)] if 0 < abs(u) < 1 else None)
        val += clip(1.0) / math.cosh(r) ** 2
        worst = max(worst, abs(val - math.tanh(r * u) / r))
print(f"(5) clip-mixture identity: max error {worst:.2e}")
