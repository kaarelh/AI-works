"""Strong-prior step of Theorem strong as used by Prop 4.1.

In standardized coordinates xi = Lambda w / sigma ~ N(0, I_P), kappa_N = sigma^2 |xi|^2.
Numerator: mu_sigma{kappa_N > K} = P(chi2_P > K/sigma^2)  (exact, mpmath).
Denominator: mu_sigma(U_{rho-rho0}(g)) >= P(|xi - xi_*| <= r/sigma) with |xi_*|^2 = E/sigma^2,
lower-bounded rigorously by vol(ball) * min density on the ball.
Here r is the radius of a Lambda-ball around the clone inside the tube; it shrinks with
rho - rho0 and with N.  We show: (i) the ratio -> 0 as sigma -> 0 when K = E + 2,
(ii) the threshold sigma_0 at which the ratio reaches eps/6 decreases with the parameter
count P (so the uniformity in learner width is only in the sample size, not in sigma_0).
"""
import mpmath as mp

mp.mp.dps = 50


def log_num(P, K, s):
    return mp.log(mp.gammainc(mp.mpf(P) / 2, K / (2 * s ** 2), mp.inf, regularized=True))


def log_den_lb(P, E, r, s):
    R = r / s
    lam_sqrt = mp.sqrt(E) / s
    return ((mp.mpf(P) / 2) * mp.log(mp.pi) + P * mp.log(R) - mp.loggamma(mp.mpf(P) / 2 + 1)
            - (mp.mpf(P) / 2) * mp.log(2 * mp.pi) - (lam_sqrt + R) ** 2 / 2)


def log_ratio(P, E, K, r, s):
    return log_num(P, K, s) - log_den_lb(P, E, r, s)


E, eps = mp.mpf(10), mp.mpf('0.1')
K = E + 2
print("sigma^2 * log(ratio) as sigma -> 0 should tend to -(K - (sqrt(E)+r)^2)/2 for this crude bound;")
for r in [mp.mpf('0.1'), mp.mpf('0.01')]:
    lim = -(K - (mp.sqrt(E) + r) ** 2) / 2
    vals = [(s, mp.nstr(s ** 2 * log_ratio(20, E, K, r, s), 6)) for s in [mp.mpf('0.1'), mp.mpf('0.03'), mp.mpf('0.01'), mp.mpf('0.003')]]
    print(f"  P=20, r={r}: limit {mp.nstr(lim, 6)}; values {vals}")


def sigma0(P, r):
    target = mp.log(eps / 6)
    lo, hi = mp.mpf('1e-6'), mp.mpf(1)
    if log_ratio(P, E, K, r, hi) <= target:
        return hi
    for _ in range(80):
        mid = mp.sqrt(lo * hi)
        if log_ratio(P, E, K, r, mid) <= target:
            lo = mid
        else:
            hi = mid
    return lo


print("\nsigma_0 (ratio <= eps/6 = 1/60) against the parameter count P, at E = 10, K = 12:")
for r in [mp.mpf('0.1')]:
    for P in [10, 100, 1000, 10000, 100000]:
        print(f"  r={r}, P={P:>6}: sigma_0 = {mp.nstr(sigma0(P, r), 5)}")
print("(P = N(d+1) + (L-2)N^2 + N grows with width N, and r also shrinks with N, so sigma_0(N) -> 0:")
print(" the result is uniform in N only through the sample size and the common sample event.)")
