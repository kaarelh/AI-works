"""Re-referee r2: adversarial check of B-tempered-likelihood.md Lemma 2.1(b) at L = 2, d = 1,
|z(x) - z(x')| <= (kappa_N / 2) |x - x'|, the step used by Proposition 9.1(a) in depth-two.md Remark 5.7a.

300 Nelder-Mead maximisations of the ratio over width-N networks (N <= 5) and pairs x, x' in (-1, 1), with no
regularisation of the denominator.  Floating-point ratios above 1 can appear only when |x - x'| is near machine
precision, where z(x) - z(x') is lost to cancellation; every maximiser is therefore re-evaluated in 60-digit
arithmetic with the same (float) parameters.

Run: python3 rr2_lipschitz.py > rr2_lipschitz.out
"""
import mpmath as mp
import numpy as np
from scipy.optimize import minimize

mp.mp.dps = 60
rng = np.random.default_rng(7)


def parts(p, N):
    W = p[:2 * N].reshape(N, 2)
    vv = p[2 * N:3 * N]
    return W, vv, np.tanh(p[3 * N]), np.tanh(p[3 * N + 1])


def neg_ratio(p, N):
    W, vv, x, xp = parts(p, N)
    kappa = np.sum(W ** 2) / N + N * np.sum(vv ** 2)
    zx = vv @ np.tanh(W @ np.array([1.0, x]))
    zxp = vv @ np.tanh(W @ np.array([1.0, xp]))
    return -abs(zx - zxp) / ((kappa / 2) * abs(x - xp) + 1e-300)


def exact_ratio(W, vv, x, xp):
    W = [[mp.mpf(float(a)) for a in row] for row in W]
    vv = [mp.mpf(float(a)) for a in vv]
    x, xp = mp.mpf(float(x)), mp.mpf(float(xp))
    if x == xp:
        return None
    N = len(vv)
    kappa = sum(a * a for row in W for a in row) / N + N * sum(a * a for a in vv)
    z = lambda t: sum(vv[j] * mp.tanh(W[j][0] + W[j][1] * t) for j in range(N))
    return abs(z(x) - z(xp)) / ((kappa / 2) * abs(x - xp))


rows = []
for trial in range(300):
    N = int(rng.integers(1, 6))
    p0 = rng.normal(size=3 * N + 2) * rng.exponential(1.0)
    r = minimize(neg_ratio, p0, args=(N,), method="Nelder-Mead", options={"maxiter": 4000, "xatol": 1e-10, "fatol": 1e-12})
    W, vv, x, xp = parts(r.x, N)
    rows.append((-r.fun, N, abs(x - xp), exact_ratio(W, vv, x, xp)))
rows.sort(key=lambda a: -a[0])
print("largest float ratios, with |x - x'| and the 60-digit ratio at the same parameters:")
for f, N, gap, ex in rows[:6]:
    print("  float %.6f  N=%d  |x-x'|=%.3e  60-digit %s" % (f, N, gap, mp.nstr(ex, 12) if ex is not None else "x = x'"))
mx = max(ex for _, _, _, ex in rows if ex is not None)
print("largest 60-digit ratio over all 300 maximisers: 1 - (%s) (must be <= 1)" % mp.nstr(1 - mx, 5))
big = [f for f, _, g, _ in rows if g >= 1e-12]
print("largest float ratio among maximisers with |x - x'| >= 1e-12: 1 + %.1e (floating-point error)" % (
    max(big) - 1))
print("float ratios above 1 + 1e-12 occur only at |x - x'| <= %.1e (cancellation)" % max(
    g for f, _, g, _ in rows if f > 1 + 1e-12))
