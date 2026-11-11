"""Re-referee (scope lens, round 2) checks for depth-two.md: the fixed-d row of the 0.2 table and the
"Other c are not settled here" entry of its first row.

(1) Fixed d, c of order n, reading (R3).  Cube example D_d (x uniform on {-1,1}^d, y a fair sign), n samples.
    F_{c,S}(w) = kappa_N(w) + (R(z_w) + W)/c >= W/c, so min F >= W/c and every w with
    kappa_N(w) + R(z_w)/c <= 1 lies in N_1(S) (slack 1), at every width.
    Constant output a (sign chosen as sign(sum_i y_i)): every first-layer row (b,0,...,0), readout a/(N tanh b);
    kappa_N = d b^2 + a^2/tanh(b)^2 at every width N; R(a) = sum_x k_x (a - ybar_x)^2 exactly;
    test excess = a^2 (clipped too, since |a| < 1).
    For each (d, n, c) and 200 samples, the largest a on a fine grid with min_b kappa + R(a)/c <= 1 is found, and
    the smallest certified excess a^2 over the samples is printed, next to A Prop. 5.2(c)'s bound (8M/d' + 4c)/n
    at d' = 0.05 (t = 1).
(2) Explicit networks for one sample (d = 1, n = 10^4, c = n/4) at widths N = 1, 5, 64: F computed from the
    sample, compared with W/c + 1.
(3) B Prop. 9.1 at L = 2 with a fixed law for every c >= n/k (fixed k): K = n/c + 1 <= k + 1, d0 = 1/(k+1),
    eta0 = d0 K/2 <= 1/2, competitor row (0, sqrt(k+1)), readout 1/tanh(1/sqrt(k+1)).
(4) (5.7a) of depth-two.md Remark 5.7a with the zero competitor (E_* = d^2+d+2, U = 1) for c(n) = sqrt(n) ln n,
    an example of "other c" in the first row: the least n = 2^j with bound <= eps, and the implied degree in 1/eps.
(5) The argument of Corollary 5.2(a) for c_d = 2^{o(d)}, i.e. c(n) <= n^{o(1)}, beyond c <= poly(d): the worst case
    of Psi_cor on the event of Lemma 1.3 (the formula of depth-two.md section 4, lambda = 1, a = 1/d) divided by
    gamma(1) theta_c^2, and log2(1/eps_d)/d with eps_d = gamma theta_c^2/3, for c = 2^sqrt(d), d^ln(d), and the
    contrast c = 2^(d/3) = n^(1/3).

Run: python3 fixed_d_and_other_c.py > fixed_d_and_other_c.out   (about 30 seconds)
"""
import math
import numpy as np
from scipy.optimize import minimize_scalar

rng = np.random.default_rng(20261111)


def min_energy_const(a, d):
    """min over b>0 of d b^2 + a^2/tanh(b)^2: the energy of the constant output a at any width."""
    if a == 0:
        return 0.0
    f = lambda b: d * b * b + (a / math.tanh(b)) ** 2
    r = minimize_scalar(f, bounds=(1e-6, 10.0), method="bounded", options={"xatol": 1e-12})
    return r.fun, r.x


A_GRID = np.linspace(0.0, 0.6, 1201)[1:]
ENERGY = {}


def energy(a, d):
    key = (round(a, 10), d)
    if key not in ENERGY:
        ENERGY[key] = min_energy_const(a, d)
    return ENERGY[key]


def sample_stats(d, n):
    M = 2 ** d
    idx = rng.integers(0, M, size=n)
    y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float)
    S = np.bincount(idx, weights=y, minlength=M)
    seen = k > 0
    ybar = np.zeros(M)
    ybar[seen] = S[seen] / k[seen]
    G = float(np.sum(S[seen] ** 2 / k[seen]))
    W = n - G
    return M, k, ybar, seen, G, W, float(y.sum()), idx, y


print("(1) fixed d, c of order n: certified near-minimizer excess on the cube (reading (R3)), 200 samples each")
print("    d       n        c/n    min over samples of certified excess a^2   A Prop 5.2(c) bound (8M/0.05+4c)/n")
for d in (1, 2, 3):
    for n in (10 ** 3, 10 ** 4, 10 ** 5):
        for ratio in (0.1, 0.25, 1.0, 4.0):
            c = ratio * n
            worst = math.inf
            for _ in range(200):
                M, k, ybar, seen, G, W, ysum, _, _ = sample_stats(d, n)
                s = 1.0 if ysum >= 0 else -1.0
                best = 0.0
                for a in A_GRID:
                    R = float(np.sum(k[seen] * (s * a - ybar[seen]) ** 2))
                    if energy(a, d)[0] + R / c <= 1.0:
                        best = a
                    else:
                        if a > best + 0.05:
                            break
                worst = min(worst, best ** 2)
            boundA = (8 * M / 0.05 + 4 * c) / n
            print("   %2d  %7d   %5.2f            %.4f                                   %.2f" % (
                d, n, ratio, worst, boundA))

print("\n(2) explicit networks: d = 1, n = 10^4, c = n/4, one sample")
d, n = 1, 10 ** 4
c = n / 4
M, k, ybar, seen, G, W, ysum, idx, y = sample_stats(d, n)
cube = np.array([[-1.0], [1.0]])           # atom 0 -> x = -1, atom 1 -> x = +1 (any labelling works: z is constant)
xs = cube[idx]
s = 1.0 if ysum >= 0 else -1.0
a = 0.2
Emin, bstar = energy(a, d)
for N in (1, 5, 64):
    W1 = np.tile(np.array([bstar, 0.0]), (N, 1))
    v = np.full(N, s * a / (N * math.tanh(bstar)))
    z = lambda X: np.tanh(np.hstack([np.ones((X.shape[0], 1)), X]) @ W1.T) @ v
    kappa = (d / N) * np.sum(W1 ** 2) + N * np.sum(v ** 2)
    F = kappa + np.sum((z(xs) - y) ** 2) / c
    excess = float(np.mean(z(cube) ** 2))
    clip_excess = float(np.mean(np.clip(z(cube), -1, 1) ** 2))
    print("   N = %3d: kappa = %.6f, F - W/c = %.6f (<= 1: %s), test excess %.6f, clipped %.6f" % (
        N, kappa, F - W / c, F - W / c <= 1.0, excess, clip_excess))
    assert F - W / c <= 1.0 and abs(excess - a * a) < 1e-12

print("\n(3) B Prop. 9.1 at L = 2 on one fixed law for every c >= n/k")
for kk in (4, 10, 100, 1000):
    Kmax = kk + 1.0
    d0 = 1.0 / Kmax
    eta = d0 * Kmax / 2.0
    omega = math.sqrt(Kmax)
    v = 1.0 / math.tanh(omega * d0)
    fit = max(abs(v * math.tanh(omega * d0) - 1), abs(v * math.tanh(-omega * d0) + 1))
    assert eta <= 0.5 + 1e-15 and omega ** 2 >= 2 and fit < 1e-12
    print("   c >= n/%-5d: K <= %6.0f, d0 = 1/%d, eta0 <= %.2f, learner L_D >= %.2f; competitor row (0, %.4f), "
          "readout %.4f, fit error %.1e" % (kk, Kmax, kk + 1, eta, (1 - eta) ** 2, omega, v, fit))

print("\n(4) (5.7a) with the zero competitor (E_* = d^2+d+2, U = 1) at c(n) = sqrt(n) ln n, d = 5, delta = 0.05")
d, delta = 5, 0.05


def bound57a(n, c):
    Dn = math.sqrt(2 * (d + 1) * math.log(n + 1))
    return c * (d * d + d + 3) / n + 8 * Dn * math.sqrt(1 / c + 1 / n) + 8 * math.sqrt(math.log(2 / delta) / (2 * n))


prev = None
for eps in (0.2, 0.1, 0.05, 0.025, 0.0125):
    j = 1
    while True:
        n = 2.0 ** j
        if bound57a(n, math.sqrt(n) * math.log(n)) <= eps and all(
                bound57a(2.0 ** i, math.sqrt(2.0 ** i) * math.log(2.0 ** i)) <= eps for i in range(j, j + 40)):
            break
        j += 1
    slope = "" if prev is None else "  log2-ratio to previous eps: %.2f" % (j - prev)
    print("   eps = %.4f: bound <= eps from n = 2^%d on%s" % (eps, j, slope))
    prev = j
print("   (each halving of eps multiplies the least n by about 2^4: n_eps grows like eps^-4, a polynomial)")

print("\n(5) Corollary 5.2(a)'s argument for c = n^{o(1)} beyond poly(d): worst case of Psi_cor on the event of")
print("    Lemma 1.3 (lambda = 1, a = 1/d), ratio to gamma(1) theta_c^2, and log2(1/eps_d)/d with eps_d = gamma theta_c^2/3")
import mpmath as mp
mp.mp.dps = 60


def psi_cor_worst(d, c, lam=1):
    M = mp.mpf(2) ** d
    n = mp.ceil(lam * M)
    lamp = n / M
    p_d = 1 - mp.e ** (n * mp.log1p(-1 / M))
    h = 2 * n ** (mp.mpf(2) / 3) / M
    a = mp.mpf(1) / d
    Fd = 1 + (d + 1) * (d + 2) ** 2
    th = 1 / (18 * d * c + 1)
    num = th * (p_d - h - lamp * a) - c * (d * Fd + 1) / M
    return (max(num, 0) ** 2 / (4 * (lamp + h / 2))), th


g1 = (1 - mp.e ** -1) ** 2 / 4
for name, cf in (("2^sqrt(d)", lambda d: mp.mpf(2) ** mp.sqrt(d)),
                 ("d^ln(d)", lambda d: mp.mpf(d) ** mp.log(d)),
                 ("2^(d/3) = n^(1/3)", lambda d: mp.mpf(2) ** (mp.mpf(d) / 3))):
    for d in (64, 144, 256, 576, 1024, 4096):
        c = cf(d)
        psi, th = psi_cor_worst(d, c)
        eps = g1 * th ** 2 / 3
        print("   c = %-18s d = %5d: c = 2^%8.2f, Psi_cor/(gamma theta^2) = %.6f, log2(1/eps_d)/d = %.4f" % (
            name, d, float(mp.log(c, 2)), float(psi / (g1 * th ** 2)), float(mp.log(1 / eps, 2) / d)))
print("   (for c = n^{o(1)} the ratio tends to 1 and log2(1/eps_d)/d tends to 0, so 1/eps_d = 2^{o(d)} and every")
print("    polynomial p(d,1,1,1/eps_d,log(1/delta)) is eventually below n = 2^d; for c = n^(1/3) it does not)")
