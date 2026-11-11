"""Independent re-implementation (checker) of the certified excess e of Theorem 5.2 of
E-finite-prior-scale.md for c = n^{1-theta}, typed from the note's statements of
Proposition 4.4, Theorem 5.2 and Corollary 5.3 (not from either existing script).

beta_n is computed by a different method from the author's script: the integral
    E[1/K; K>=1] = int_0^1 ((1-p+pt)^n - (1-p)^n)/t dt,   K ~ Bin(n,p),
and beta(lambda) by the closed form e^{-lambda}(Ei(lambda) - gamma_E - log lambda).
"""
from mpmath import mp, mpf, sqrt, log, exp, log1p, ei, euler, quad, expm1

mp.dps = 60


def beta_lam(lam):
    lam = mpf(lam)
    return exp(-lam) * (ei(lam) - euler - log(lam))


def beta_n_int(n, M):
    n, M = mpf(n), mpf(M)
    p = 1 / M
    l0 = n * log1p(-p)
    f = lambda t: (exp(n * log1p(-p * (1 - t))) - exp(l0)) / t if t > 0 else n * p * exp((n - 1) * log1p(-p))
    return quad(f, [0, mpf(1) / 2, 1])


def consts(d, s, a, H):
    d, s, a = mpf(d), mpf(s), mpf(a)
    Sbar = mpf(3) ** (mpf(H - 1) / 2) + mpf(1) / 4
    Amax = 2 * sqrt(2 * d * s) * mpf(3) ** (mpf(H - 1) / 2)
    alpha_d = log(4 * sqrt(2 * d)) / 2
    alpha = 2 + max(alpha_d, log(256 * H * Sbar / a) / 2)
    R = max(Amax ** (mpf(1) / H), sqrt(128 * H * H * Sbar ** 3 / a), mpf(2))
    K = d * (d + 1) * alpha ** 2 + (H + 1) * R ** 2
    Klb = d * (d + 1) * (2 + alpha_d) ** 2 + (H + 1) * Amax ** (mpf(2) / H)
    return K, Klb


def e_thm52(d, n, H, c, a, t, lndelta_inv, beta_n):
    M = mpf(2) ** d
    lam = mpf(n) / M
    s0 = min(mpf(n), M)
    K, _ = consts(d, s0, a, H)
    eta = a ** 2 + c * (K + 2 * t) / n
    eps = lam * eta
    base = beta_n - sqrt(2 * lam * lndelta_inv / M)
    if base <= 0:
        return mpf(0)
    r = sqrt(base) - sqrt(eps)
    return r * r if r > 0 else mpf(0)


def e_schedule(d, H, theta, beta_mode='lower'):
    M = mpf(2) ** d
    n = M
    c = n ** (1 - mpf(theta))
    a = (max(c, 1) / M) ** (mpf(1) / 3)
    if beta_mode == 'lower':
        bn = beta_lam(1) - n / M ** 2
    else:
        bn = beta_n_int(n, M)
    return e_thm52(d, n, H, c, a, 1, mpf(2) ** (mpf(d) / 2), bn)


if __name__ == '__main__':
    print('beta(1) closed form =', float(beta_lam(1)))
    for d in (3, 6, 10, 20):
        M = 2 ** d
        print(f' d={d}: beta_n (integral) = {float(beta_n_int(M, M)):.8f}, |beta_n - beta(1)| = {float(abs(beta_n_int(M, M) - beta_lam(1))):.2e} <= n/M^2 = {1/M:.2e}')
    cases = [(2, '0.55', [100, 172, 173, 200, 400, 800, 1600]),
             (2, '0.6', [50, 80, 81, 100, 200, 400]),
             (3, '0.36', [200, 293, 294, 300, 400, 800, 1600])]
    print('\nPart A: schedule n=2^d, a=a_d, t=1, delta=delta_d, beta_n -> beta(1)-n/M^2')
    for H, th, show in cases:
        vals = [e_schedule(d, H, th) for d in range(1, 1601)]
        zeros = [d for d, e in zip(range(1, 1601), vals) if e == 0]
        lz = max(zeros)
        contiguous = zeros == list(range(1, lz + 1))
        nondec = all(vals[i + 1] >= vals[i] for i in range(lz - 1, 1599))
        print(f' H={H} theta={th}: zeros exactly d=1..{lz}: {contiguous}; nondecreasing on [{lz},1600]: {nondec}')
        print('   ' + ', '.join(f'd={d}: {float(vals[d-1]):.4f}' for d in show))
    print('\nPart A2: same schedule with exact beta_n (integral) at selected d')
    for H, th, show in cases:
        print(f' H={H} theta={th}: ' + ', '.join(f'd={d}: {float(e_schedule(d, H, th, "exact")):.4f}' for d in show))
