"""Re-referee r2: independent check of the large-c paragraph of depth-two.md Remark 5.7a
(B-tempered-likelihood.md Proposition 9.1 at L = 2) and of prop91_l2.out.

(1) eta_0 = delta_0 K/2 <= 1/2 for delta_0 = min{1/2, 1/K}; (1 - eta)^2 lower bound from f(d0) - f(-d0) <= 2 eta
    (exact minimisation of the two-point loss under the constraint, by calculus and by brute force);
(2) the width-one competitor of Prop. 9.1(b) at L = 2, exact fit, weights, and the bound 1.5 max{sqrt2, sqrtK};
    the fixed competitor for c >= n/4 (delta_0 = 1/5);
(3) for c = n/ln n and n/ln^2 n: the exact least n (not only powers of ten) from which the competitor's largest weight
    is <= n^alpha, by bisection in log n with mpmath, and the least power of ten;
(4) B Lemma 2.1(b) at L = 2, d = 1: sup |z(x)-z(x')| / ((kappa/2)|x-x'|) <= 1, attacked by local maximisation;
(5) a direct experiment: minimise F_c for c = n/4 on a sample of D_{1/5} at several widths, and report the test MSE of
    the best network found (the theory says >= (1-K/10)^2 >= 1/4 for every near-minimiser).

Run: python3 rr2_prop91.py > rr2_prop91.out
"""
import math

import mpmath as mp
import numpy as np
from scipy.optimize import minimize

mp.mp.dps = 60
rng = np.random.default_rng(7)

print("(1) eta_0 and the (1-eta)^2 bound")
worst = 0.0
for K in np.concatenate([np.linspace(1.0, 3.0, 201), np.logspace(0.5, 12, 200)]):
    d0 = min(0.5, 1.0 / K)
    eta = d0 * K / 2
    worst = max(worst, eta)
print("   max eta_0 over the K grid = %.15f (must be <= 1/2)" % worst)
# min over (a,b) with a - b <= 2 eta of 0.5((a-1)^2 + (b+1)^2): brute force
for eta in (0.1, 0.25, 0.5, 0.9):
    best = 1e9
    for a in np.linspace(-2, 2, 801):
        # for fixed a the best b is max(a - 2 eta, -1)... do a grid anyway
        for b in np.linspace(-2, 2, 801)[::4]:
            if a - b <= 2 * eta + 1e-12:
                best = min(best, 0.5 * ((a - 1) ** 2 + (b + 1) ** 2))
    print("   eta=%.2f: grid min of L_D = %.5f, (1-eta)^2 = %.5f" % (eta, best, (1 - eta) ** 2))

print("\n(2) the width-one competitor (row (0, omega), readout v = 1/tanh(omega d0)), omega = d0^(-1/2)")
for K in (1, 2, 3, 5, 10, 1e3, 1e6, 1e12):
    d0 = mp.mpf(min(0.5, 1.0 / K))
    om = d0 ** mp.mpf(-0.5)
    v = 1 / mp.tanh(om * d0)
    fit = max(abs(v * mp.tanh(om * d0) - 1), abs(v * mp.tanh(-om * d0) + 1))
    ok = (om ** 2 >= 2) and (om <= v <= mp.mpf(1.5) * om) and (v <= mp.mpf(1.5) * max(mp.sqrt(2), mp.sqrt(K)))
    print("   K=%-8g d0=%-10s omega=%-12s v=%-12s v/omega=%-8s fit err=%s checks=%s" % (
        K, mp.nstr(d0, 6), mp.nstr(om, 8), mp.nstr(v, 8), mp.nstr(v / om, 6), mp.nstr(fit, 3), ok))
d0 = mp.mpf(1) / 5
om = mp.sqrt(5)
v = 1 / mp.tanh(om * d0)
print("   fixed law d0=1/5: omega=sqrt5=%s, v=1/tanh(1/sqrt5)=%s; g(+-d0)=%s,%s; eta=K/10<=1/2 iff K<=5; (1-1/2)^2=%.2f" % (
    mp.nstr(om, 6), mp.nstr(v, 6), mp.nstr(v * mp.tanh(om * d0), 15), mp.nstr(v * mp.tanh(-om * d0), 15), 0.25))
print("   c >= n/4 => K = n/c + 1 <= 5: K at c = n/4 exactly is %s" % (4 + 1))

print("\n(3) least n from which the competitor (largest weight v) lies in G_n^(alpha)")


def maxweight(K):
    d0 = min(mp.mpf(1) / 2, 1 / K)
    om = d0 ** mp.mpf(-0.5)
    return max(om, 1 / mp.tanh(om * d0))


for name, Kof in (("n/ln n", lambda L: L + 1), ("n/ln^2 n", lambda L: L ** 2 + 1)):
    for alpha in (0.1, 0.05, 0.01):
        # inside(n) <=> log(maxweight) <= alpha*ln n ; L = ln n
        f = lambda L: mp.log(maxweight(Kof(L))) - alpha * L
        # scan powers of ten
        first10 = None
        for j in range(1, 4001):
            L = j * mp.log(10)
            if f(L) <= 0:
                if first10 is None:
                    first10 = j
            elif first10 is not None:
                first10 = None  # left the class again: record the last entry point
        # exact crossing by bisection on L = ln n, between L=1 and the first power of ten found
        lo, hi = mp.mpf(1), first10 * mp.log(10)
        assert f(hi) <= 0
        for _ in range(200):
            mid = (lo + hi) / 2
            if f(mid) <= 0:
                hi = mid
            else:
                lo = mid
        print("   c=%-9s alpha=%.2f: inside from n=10^%d on (powers of ten up to 10^4000); exact entry n=10^%s; "
              "max weight at entry %s = n^alpha %s" % (name, alpha, first10, mp.nstr(hi / mp.log(10), 6),
                                                       mp.nstr(maxweight(Kof(hi)), 6), mp.nstr(mp.e ** (alpha * hi), 6)))
        # also: with the bound 1.5 max{sqrt2, sqrtK} instead of the actual weight
        g = lambda L: mp.log(mp.mpf(1.5) * max(mp.sqrt(2), mp.sqrt(Kof(L)))) - alpha * L
        j2 = next(j for j in range(1, 6001) if g(j * mp.log(10)) <= 0)
        print("        with the weight bound 1.5 max{sqrt2,sqrtK} in place of the actual weight: from n=10^%d" % j2)

print("\n(4) B Lemma 2.1(b) at L=2, d=1: ratio |z(x)-z(x')| / ((kappa/2)|x-x'|), adversarial local maximisation")


def neg_ratio(p, N):
    W = p[:2 * N].reshape(N, 2)
    vv = p[2 * N:3 * N]
    x, xp = np.tanh(p[3 * N]), np.tanh(p[3 * N + 1])
    kappa = np.sum(W ** 2) / N + N * np.sum(vv ** 2)
    zx = vv @ np.tanh(W @ np.array([1.0, x]))
    zxp = vv @ np.tanh(W @ np.array([1.0, xp]))
    return -abs(zx - zxp) / ((kappa / 2) * abs(x - xp) + 1e-12)


best = 0.0
for trial in range(300):
    N = int(rng.integers(1, 6))
    p0 = rng.normal(size=3 * N + 2) * rng.exponential(1.0)
    res = minimize(neg_ratio, p0, args=(N,), method="Nelder-Mead", options={"maxiter": 4000, "xatol": 1e-10, "fatol": 1e-12})
    best = max(best, -res.fun)
print("   largest ratio found over 300 local maximisations (N <= 5): %.6f (must be <= 1)" % best)

print("\n(5) direct minimisation of F_c, c = n/4, on a sample of D_{1/5} (d=1), several widths")
for n in (40, 200):
    c = n / 4.0
    d0 = 0.2
    xs = rng.choice([-d0, d0], size=n)
    ys = np.sign(xs)
    for N in (1, 4, 16):
        def F(p):
            W = p[:2 * N].reshape(N, 2)
            vv = p[2 * N:]
            H = np.tanh(np.outer(np.ones(n), W[:, 0]) + np.outer(xs, W[:, 1]))
            z = H @ vv
            kappa = (1.0 / N) * np.sum(W ** 2) + N * np.sum(vv ** 2)
            return kappa + np.sum((z - ys) ** 2) / c
        bestF, bestp = 1e18, None
        for r in range(60):
            p0 = rng.normal(size=3 * N) * rng.exponential(2.0)
            res = minimize(F, p0, method="L-BFGS-B")
            if res.fun < bestF:
                bestF, bestp = res.fun, res.x
        W = bestp[:2 * N].reshape(N, 2)
        vv = bestp[2 * N:]
        zt = lambda t: float(vv @ np.tanh(W[:, 0] + W[:, 1] * t))
        test = 0.5 * ((zt(d0) - 1) ** 2 + (zt(-d0) + 1) ** 2)
        print("   n=%3d c=%.0f K=%.0f N=%2d: min F found %.4f (zero network: %.4f); test MSE of best %.4f (>= %.4f required)" % (
            n, c, n / c + 1, N, bestF, n / c, test, (1 - (n / c + 1) * d0 / 2) ** 2))
