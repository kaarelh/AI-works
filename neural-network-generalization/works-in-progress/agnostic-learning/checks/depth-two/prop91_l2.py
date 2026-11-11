"""B-tempered-likelihood.md Proposition 9.1 at depth two (L = 2), as used in depth-two.md Remark 5.7a.

Law D_{d0}: d = 1, x uniform on {-d0, +d0}, y = sign(x); noiseless, Bayes risk 0.  K = n/c + 1.
(a) B Prop. 9.1(a) at L = 2.  Every near-minimizer, at every width, has kappa_N <= K (B Lemma 2.3(a)).  B Lemma 2.1(b)
    with d = 1 and L = 2 gives |z(x) - z(x')| <= (kappa_N/2)|x - x'|, so |z(d0) - z(-d0)| <= K d0 = 2 eta with
    eta = d0 K / 2.  If eta <= 1, then L_D(clip z) >= (1 - eta)^2.
(b) B Prop. 9.1(b) at L = 2.  omega = d0^{-1/2}, which needs omega^2 >= 2, i.e. d0 <= 1/2.  The width-one network
    g(x) = v tanh(omega x) (first-layer row (0, omega), readout v = 1/tanh(omega d0)) has g(+-d0) = +-1, so L_D(g) = 0,
    and omega <= v <= 1.5 omega.
With d0 = min{1/2, 1/K}: eta <= 1/2, so every reading of SP_c has L_D >= 1/4, while g has zero loss and weights at most
1.5 max{sqrt 2, sqrt K}.

Parts:
(1) a grid of K: eta, (1 - eta)^2, omega, v, the fit of g, and the weight bound.
(2) c >= n/4, i.e. K <= 5: one fixed law (d0 = 1/5) and one fixed competitor for every n.
(3) c = n/ln n and c = n/ln^2 n (so n/c = n^{o(1)}): the least n = 10^j from which the competitor lies in
    G_n^(alpha) (width 1 <= n^alpha, weights <= n^alpha), and that it stays there up to n = 10^4000.
(4) the Lipschitz step of (a) on random width-N networks with d = 1, kappa = their own energy.

Run: python3 prop91_l2.py > prop91_l2.out   (under a second)
"""
import math
import numpy as np

rng = np.random.default_rng(20261111)


def law_and_competitor(K):
    d0 = min(0.5, 1.0 / K)
    eta = d0 * K / 2.0
    omega = d0 ** -0.5
    v = 1.0 / math.tanh(omega * d0)
    fit = max(abs(v * math.tanh(omega * d0) - 1.0), abs(v * math.tanh(-omega * d0) + 1.0))
    return d0, eta, omega, v, fit


print("(1) d0 = min{1/2, 1/K}")
print("      K        d0        eta    (1-eta)^2   omega      v     max|g(+-d0) -+ 1|   max weight  1.5 max{sqrt2, sqrtK}")
for K in (1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 1e2, 1e4, 1e8):
    d0, eta, omega, v, fit = law_and_competitor(K)
    bound = 1.5 * max(math.sqrt(2.0), math.sqrt(K))
    assert eta <= 0.5 + 1e-15 and omega ** 2 >= 2 - 1e-12 and omega <= v <= 1.5 * omega and max(omega, v) <= bound
    print("  %9.3g  %9.3g  %7.4f  %8.4f  %9.4f  %9.4f  %12.1e        %9.4f   %9.4f" % (
        K, d0, eta, (1 - eta) ** 2, omega, v, fit, max(omega, v), bound))
print("   assertions passed: eta <= 1/2, omega^2 >= 2, omega <= v <= 1.5 omega, weights <= 1.5 max{sqrt2, sqrtK}")

print("\n(2) c >= n/4: K = n/c + 1 <= 5; fixed d0 = 1/5")
d0 = 0.2
omega = d0 ** -0.5
v = 1.0 / math.tanh(omega * d0)
for K in (1.0, 2.0, 3.0, 4.0, 5.0):
    eta = d0 * K / 2
    print("   K = %.0f: eta = %.2f, every reading has L_D >= (1-eta)^2 = %.4f" % (K, eta, (1 - eta) ** 2))
print("   fixed competitor: omega = %.4f, v = %.4f, g(d0) = %.12f, g(-d0) = %.12f, largest weight %.4f" % (
    omega, v, v * math.tanh(omega * d0), v * math.tanh(-omega * d0), max(omega, v)))

print("\n(3) n/c = n^{o(1)}: least n = 10^j (j <= 4000) from which the competitor lies in G_n^(alpha)")
for name, ratio in (("n/ln n", lambda l10: l10 * math.log(10)),
                    ("n/ln^2 n", lambda l10: (l10 * math.log(10)) ** 2)):
    for alpha in (0.1, 0.05, 0.01):
        inside = []
        for l10 in range(1, 4001):
            K = ratio(l10) + 1.0            # n/c + 1
            d0, eta, om, vv, fit = law_and_competitor(K)
            # compare log10(largest weight) with log10(n^alpha) = alpha * j, to avoid overflow
            inside.append(math.log10(max(om, vv)) <= alpha * l10 and eta <= 0.5 + 1e-12 and fit < 1e-9)
        first = next(j for j, ok in enumerate(inside, start=1) if ok)
        stays = all(inside[first - 1:])
        print("   c = %-9s alpha = %.2f: from n = 10^%d on (stays inside up to 10^4000: %s)" % (
            name, alpha, first, stays))

print("\n(4) |z(x) - z(x')| <= (kappa/2)|x - x'| at L = 2, d = 1, on 20000 random width-N networks")
worst = 0.0
for trial in range(20000):
    N = int(rng.integers(1, 30))
    W = rng.normal(size=(N, 2)) * rng.exponential(3.0)
    vv = rng.normal(size=N) * rng.exponential(3.0)
    kappa = (1.0 / N) * np.sum(W ** 2) + N * np.sum(vv ** 2)
    x, xp = rng.uniform(-1, 1, size=2)
    z = lambda t: float(vv @ np.tanh(W @ np.array([1.0, t])))
    worst = max(worst, abs(z(x) - z(xp)) / ((kappa / 2) * abs(x - xp) + 1e-300))
assert worst <= 1.0
print("   largest ratio %.4f (must be <= 1)" % worst)
