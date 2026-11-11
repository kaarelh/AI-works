# Adversarial random test of Proposition 7.2a's budget: Delta(zeta) <= C + n a^2 + 7.
import numpy as np
rng = np.random.default_rng(12345)
worst = -np.inf; count = 0
for trial in range(20000):
    n = int(rng.integers(100, 3000)); M = int(rng.integers(max(2, n // 8), 4 * n))
    p = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(p, minlength=M); S = np.bincount(p, weights=y, minlength=M)
    seen = k > 0; ybar = np.zeros(M); ybar[seen] = S[seen] / k[seen]
    W = np.sum((y - ybar[p]) ** 2)
    a = float(rng.uniform(0, 1)) ** rng.choice([1, 3])
    C = float(rng.uniform(0, 1)) * n                      # C = c(K_mem + t) <= n
    # comparator: vertex values within a of ybar, plus within-cluster deviations u0 of size <= 1/n, adversarial sign
    z0p = ybar + a * rng.uniform(-1, 1, size=M) * 0.999999
    v0 = z0p[p] - y
    u0 = np.sign(v0) / n
    R0 = np.sum((u0 + v0) ** 2)
    # near-minimizer: vertex values zeta = ybar + s*dir (on seen vertices); u_i = -sign(v_i)/n (helps the fit)
    dirv = rng.normal(size=M); dirv[~seen] = 0
    dirv /= np.sqrt(np.sum(k * dirv ** 2)) + 1e-300
    budget = C + R0                                       # sum (z_w - y)^2 may be at most this
    # find the largest s with residual(s) <= budget by bisection (residual increases with s for s >= 0)
    def resid(s):
        zeta = ybar + s * dirv; v = zeta[p] - y; u = -np.sign(v) / n
        u[np.abs(v) < 1.0 / n] = -v[np.abs(v) < 1.0 / n]   # cannot overshoot below zero residual
        return np.sum((u + v) ** 2), zeta
    lo, hi = 0.0, 1.0
    while resid(hi)[0] <= budget: hi *= 2
    for _ in range(80):
        mid = (lo + hi) / 2
        if resid(mid)[0] <= budget: lo = mid
        else: hi = mid
    _, zeta = resid(lo)
    Delta = np.sum(k[seen] * (zeta[seen] - ybar[seen]) ** 2)
    slack = (C + n * a * a + 7) - Delta
    worst = max(worst, -slack); count += 1
print(f"instances: {count}; max of Delta - (C + n a^2 + 7) = {worst:.4f} (must be <= 0)")
