"""Re-referee r2: the remaining changed numbers of depth-two.md, recomputed independently.

N1  Section 4 "Numbers" at c = 1, lambda = 1, for a = 1/n and a = 1/d (worst case on E_d, displayed formulas of
    Section 4; binomial statistics by an exact term recursion in mpmath at 80 digits).
N2  Table after Proposition 5.3: c = 0.1 sqrt(M), M = 2^10 (the corrected 0.015) and the c = 1 row.
N3  Remark 5.2a: Delta and Delta^2/6; isotonic fit by exhaustive search over monotone 3-vectors on a grid.
N4  Remark 5.3a constants: 1/(2e) > 1/7; the floor(n/b) variant e^{-b}/2; M >= n/(lambda+1).
N5  Remark 5.7a: Theorem 6.3 / Corollary 8.1 exponents at H = 1; the class constants with m = floor(n^alpha),
    B = n^alpha; the epsilon_n / n_delta construction checked on a grid; the c = log^3 n rate.
N6  Section 0.2 last row: A Proposition 5.2(c) at t = 1.

Run: python3 rr2_numbers.py > rr2_numbers.out
"""
import math

import mpmath as mp

mp.mp.dps = 80


def binom_stats(n, M):
    """beta_d = E[1/K; K>=1], p_d = P[K>=1] for K ~ Bin(n, 1/M), by the term recursion."""
    n = mp.mpf(n)
    p = 1 / mp.mpf(M)
    t = mp.e ** (n * mp.log1p(-p))  # P[K=0]
    p0 = t
    beta = mp.mpf(0)
    k = 0
    while True:
        k += 1
        t = t * (n - k + 1) / k * p / (1 - p)
        beta += t / k
        if k > 20 and t < mp.mpf(10) ** (-70):
            break
        if k >= n:
            break
    return beta, 1 - p0


def gamma_l(lam):
    return (1 - mp.e ** (-lam)) ** 2 / (4 * lam)


def beta_l(lam):
    return mp.e ** (-lam) * mp.nsum(lambda k: lam ** k / (k * mp.factorial(k)), [1, mp.inf])


def psi_lower(d, c, a, lam=1):
    M = mp.mpf(2) ** d
    n = mp.ceil(lam * M)
    lamp = n / M
    bd, pd = binom_stats(n, M)
    h = 2 * n ** (mp.mpf(2) / 3) / M
    th = 1 / (18 * d * c + 1)
    Fd = 1 + (d + 1) * (d + 2) ** 2
    r = c * (d * Fd + 1) / M
    A = bd - h
    B = (1 - th) * (pd + h) + r + th * lamp * a
    tri = (mp.sqrt(A) - mp.sqrt(B)) ** 2 if (A > 0 and A > B) else mp.mpf(0)
    num = th * (pd - h - lamp * a) - r
    cor = num ** 2 / (4 * (lamp + h / 2)) if num > 0 else mp.mpf(0)
    return max(tri, cor), tri, cor, th, n


print("N1: c = 1, lambda = 1")
g1 = gamma_l(1)
for label, afun in (("a=1/n", lambda d, n: 1 / n), ("a=1/d", lambda d, n: mp.mpf(1) / d)):
    first_pos, first_2eps, exceptions, best, ratios = None, None, [], (0, 0), {}
    for d in range(1, 1001):
        M = mp.mpf(2) ** d
        n = mp.ceil(M)
        val, tri, cor, th, _ = psi_lower(d, 1, afun(d, n))
        eps2 = 2 * g1 * th ** 2 / 3
        if val > 0 and first_pos is None:
            first_pos = d
        if val >= eps2 and first_2eps is None:
            first_2eps = d
        if first_2eps is not None and val < eps2:
            exceptions.append(d)
        if val > best[1]:
            best = (d, val)
        if d in (30, 33, 34, 35, 60):
            ratios[d] = (val, eps2, val / (g1 * th ** 2))
    print("  %s: first positive d=%s; first d with bound>=2eps_d: %s; exceptions after it up to 1000: %s; max %s at d=%d" % (
        label, first_pos, first_2eps, exceptions[:5], mp.nstr(best[1], 5), best[0]))
    for d, (v, e2, r) in ratios.items():
        print("     d=%d: bound %s, 2eps_d %s, ratio to gamma*theta^2 %s" % (d, mp.nstr(v, 4), mp.nstr(e2, 4), mp.nstr(r, 6)))
d = 30
M = 2 ** d
n = M
print("  widths at d=30: N0(1/n)=%s, N0(1/d)=%s = %s n" % (
    mp.nstr(mp.ceil(72 * d * n * mp.log(2 * M) * n ** 2) + 1, 4),
    mp.nstr(mp.ceil(72 * d ** 3 * n * mp.log(2 * M)) + 1, 4),
    mp.nstr((mp.ceil(72 * d ** 3 * n * mp.log(2 * M)) + 1) / n, 4)))

print("\nN2: Proposition 5.3 table (worst case on E_M, lambda = 1)")
for logM in (10, 14, 20, 30, 40, 60):
    M = mp.mpf(2) ** logM
    n = mp.ceil(M)
    bd, pd = binom_stats(n, M)
    Qm = M * bd - 2 * n ** (mp.mpf(2) / 3)
    Qp = M * bd + 2 * n ** (mp.mpf(2) / 3)
    row = []
    for c in (mp.mpf(1), mp.mpf(0.1) * mp.sqrt(M)):
        R = c * (2 * mp.sqrt(Qp) + 1) + n / (9 * Qm)
        v = (mp.sqrt(Qm) - mp.sqrt(R)) ** 2 / M if Qm > R else 0
        row.append(mp.nstr(v, 5))
    print("  log2 M=%d: c=1 -> %s ; c=0.1 sqrtM -> %s" % (logM, row[0], row[1]))
b1 = beta_l(1)
print("  limit at nu=0.1: beta(1)(1-sqrt(0.2/sqrt(beta)))^2 = %s ; sqrt(beta(1))/2 = %s" % (
    mp.nstr(b1 * (1 - mp.sqrt(mp.mpf(0.2) / mp.sqrt(b1))) ** 2, 6), mp.nstr(mp.sqrt(b1) / 2, 5)))

print("\nN3: Remark 5.2a")
gm = (mp.tanh(3) - mp.tanh(1)) / 2
g0 = mp.tanh(1)
Delta = g0 - gm
print("  g*(+-1)=%s g*(0)=%s Delta=%s Delta^2/6=%s" % (mp.nstr(gm, 6), mp.nstr(g0, 6), mp.nstr(Delta, 6), mp.nstr(Delta ** 2 / 6, 6)))
# exhaustive search over monotone (nondecreasing or nonincreasing) triples on a fine grid
vals = [float(gm), float(g0), float(gm)]
best = 9.0
grid = [i / 2000 for i in range(-200, 2001)]
for u in grid[::5]:
    for w in grid[::5]:
        # nondecreasing u <= m <= w: optimal middle = clip(g0, u, w)
        if u <= w:
            m = min(max(vals[1], u), w)
            best = min(best, ((u - vals[0]) ** 2 + (m - vals[1]) ** 2 + (w - vals[2]) ** 2) / 3)
print("  grid minimum of the MSE over monotone fits: %.5f" % best)

print("\nN4: Remark 5.3a")
print("  1/(2e) = %.5f > 1/7 = %.5f : %s" % (1 / (2 * math.e), 1 / 7, 1 / (2 * math.e) > 1 / 7))
for b in (1, 2, 3, 5):
    print("  b=%d: e^{-b}/2 = %.5f" % (b, math.exp(-b) / 2))
for lam in (0.3, 1, 1.5, 3):
    ok = all(2 ** k > math.ceil(lam * 2 ** k) / (lam + 1) for k in range(0, 40))
    print("  lambda=%.1f: M > n/(lambda+1) for M = 2^k, k < 40: %s" % (lam, ok))

print("\nN5: Remark 5.7a")
for alpha in (0.01, 1 / 16, 0.1, 0.124):
    theta = (1 + 8 * alpha) / 3
    beta = min((1 - 4 * alpha) / 3, 0.5 - 4 * alpha)
    print("  alpha=%.4f: theta=%.4f, c exponent 1-theta=(2-8alpha)/3=%.4f, beta=%.4f, 4alpha-theta=%.4f <= -beta: %s" % (
        alpha, theta, 1 - theta, beta, 4 * alpha - theta, 4 * alpha - theta <= -beta + 1e-15))
worst1 = worst2 = 0.0
for alpha in (0.01, 0.05, 0.1, 0.124):
    for n in (2, 10, 100, 10 ** 4, 10 ** 8, 10 ** 16):
        for d in (1, 2, 5, 20, 60):
            m = math.floor(n ** alpha)
            if m < 1:
                continue
            B = n ** alpha
            Estar = d * (d + 1) * B ** 2 + 2 * (2 - 1) * m ** 2 * B ** 2
            U = m * B
            worst1 = max(worst1, (Estar + 1) / ((d * (d + 1) + 4) * n ** (4 * alpha)))
            worst2 = max(worst2, (4 + (U + 1) ** 2) / (8 * n ** (4 * alpha)))
print("  max (E*+1)/((d(d+1)+4) n^{4alpha}) = %.4f ; max (4+(U+1)^2)/(8 n^{4alpha}) = %.4f (both must be <= 1)" % (worst1, worst2))


# epsilon_n / n_delta construction for the clipped class version: check total <= eps_n for n >= n_delta
def total_bound(n, d, c, alpha, delta, eta):
    Dn = math.sqrt(2 * (d + 1) * math.log(n + 1))
    t1 = c * (d * (d + 1) + 4) * n ** (4 * alpha - 1)
    t2 = 8 * Dn * math.sqrt(1 / c + 1 / n)
    t3 = 8 * n ** (4 * alpha) * math.sqrt(math.log(4 / delta) / (2 * n))  # B at confidence delta/2
    return t1 + t2 + t3 + 4 * eta


def eps_n(n, C0, c, alpha):
    d = math.floor(math.log2(n) + C0)
    Dn = math.sqrt(2 * (d + 1) * math.log(n + 1))
    return c * (d * (d + 1) + 4) * n ** (4 * alpha - 1) + 8 * Dn * math.sqrt(1 / c + 1 / n) + 2 * n ** (2 * alpha - 0.25)


ok = True
for alpha, eps, C0 in ((0.05, 0.5, 2), (0.1, 0.9, 0), (0.02, 0.2, 3)):
    for delta in (0.5, 1e-3, 1e-9):
        # n_delta: third term (at delta/2) below n^{2alpha-1/4}
        nd = next(10 ** j for j in range(1, 400) if 8 * math.sqrt(math.log(4 / delta) / 2) * (10 ** j) ** (4 * alpha - 0.5)
                  <= (10 ** j) ** (2 * alpha - 0.25))
        for j in range(int(math.log10(nd)), int(math.log10(nd)) + 30, 3):
            n = 10 ** j
            c = min(n ** (1 - eps), max(math.log(n) ** 3, 1.0))  # a c with c/log^2 n -> infinity and c <= n^{1-eps}
            for d in range(1, math.floor(math.log2(n) + C0) + 1, max(1, math.floor(math.log2(n) + C0) // 7)):
                eta = n ** (2 * alpha - 0.25) / 4
                if total_bound(n, d, c, alpha, delta, eta) > eps_n(n, C0, c, alpha) * (1 + 1e-12):
                    ok = False
print("  clipped class version: total bound <= eps_n for all tested n >= n_delta, d <= log2 n + C0: %s" % ok)
for j in (6, 12, 24, 48, 96):
    n = 10.0 ** j
    c = math.log(n) ** 3
    Dn = math.sqrt(2 * (math.log2(n) + 1) * math.log(n + 1))
    print("  c=ln^3 n, n=1e%d: middle term 8 D_n sqrt(1/c+1/n) * sqrt(ln n) = %.3f" % (j, 8 * Dn * math.sqrt(1 / c + 1 / n) * math.sqrt(math.log(n))))

print("\nN6: A Proposition 5.2(c) at t = 1")
for d in (1, 3, 8):
    M = 2 ** d
    print("  d=%d: 8M = 2^(d+3) = %d ; M e^{-n/(8M)} at n=1000M: %.3e" % (d, 8 * M, M * math.exp(-1000 * M / (8 * M))))
