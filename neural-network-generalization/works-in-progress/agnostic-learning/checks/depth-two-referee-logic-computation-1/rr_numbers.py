"""Re-referee (logic and computation of the changed passages) of depth-two.md, round 3.

Independent of the author's scripts: binomial statistics through log-gamma (not the pmf recursion), the worst
case on the event written from the formulas of section 4 (not from Theorem 5.1 at the event corner), and the
Hadamard bound written from the proof of Proposition 5.3.

Checks, numbered as in the report:
  N1  Corollary 5.2 "Numbers", c = 1: a = 1/n and a = 1/d (first positive d, first d with bound >= 2 eps_d,
      the d = 33 values for a = 1/d, the ratio at d = 33 / 34, monotonicity of the ratio, maximum and location).
  N2  Table after Proposition 5.3: c = 0.1 sqrt M at M = 2^10 (0.01549 -> 0.015); the other entries.
  N3  Proposition 5.3, case c <= sqrt M, as now proved with Q <= M: the constant 2 sqrt 3 and the size of the
      O(M^{-1/3}) remainder, uniformly over c in [1/M, sqrt M].
  N4  Remark 5.2a: g*, Delta, Delta^2/6, and a brute-force search over width-one networks (clipped and not).
  N5  Remark 5.3a: |U|/n, 1/(2e) > 1/7, the d = ceil(n/b) variant (e^{-b}/2), the competitor accuracy,
      and the Gibbs-risk variant (averaging over a posterior that depends on the sample only).
  N6  Section 6 erratum, numerics bullet: phi and phi - c/G from the red-team run files.
  N7  Remark 5.7a algebra: E_* + 1 <= (d(d+1)+4) n^{4 alpha}, 4 + (U+1)^2 <= 8 n^{4 alpha}; the c-range of
      Corollary 8.1 at H = 1; the n_delta step; the rate at c = log^3 n.
  N8  Fixed-d row: (8 M/delta + 4 c t)/n at t = 1 and the probability 1 - delta - M e^{-n/(8M)}, by simulation.
"""
import math
import mpmath as mp
import numpy as np

mp.mp.dps = 120
rng = np.random.default_rng(20261111)


def bin_stats(d, lam=1):
    """beta_d = E[1/K; K>=1], p_d = P(K>=1), K ~ Bin(n, 1/M), M = 2^d, n = ceil(lam M), via log-gamma."""
    M = mp.mpf(2) ** d
    n = mp.ceil(mp.mpf(lam) * M)
    lp, lq = -mp.log(M), mp.log1p(-1 / M)
    p0 = mp.e ** (n * lq)
    s = mp.mpf(0)
    k = 1
    lfall = mp.mpf(0)  # log of n (n-1) ... (n-k+1), accumulated as k ln n + sum log1p(-j/n): no cancellation
    while True:
        lfall += mp.log(n) + mp.log1p(-(k - 1) / n)
        lpmf = lfall - mp.loggamma(k + 1) + k * lp + (n - k) * lq
        t = mp.e ** lpmf
        s += t / k
        if k > 5 and t < mp.mpf(10) ** (-100):
            break
        k += 1
        if k > n:
            break
    return M, n, s, 1 - p0


def F_d(d):
    return 1 + (d + 1) * (d + 2) ** 2


def gam(l):
    l = mp.mpf(l)
    return (1 - mp.e ** (-l)) ** 2 / (4 * l)


def beta_series(l):
    l = mp.mpf(l)
    return mp.e ** (-l) * mp.nsum(lambda k: l ** k / (k * mp.factorial(k)), [1, mp.inf])


def psi_lower(d, c, a, lam=1, st=None):
    """underline Psi_tri and underline Psi_cor of section 4, written from their displayed formulas."""
    M, n, b, p = st or bin_stats(d, lam)
    lamp = n / M
    h = 2 * n ** (mp.mpf(2) / 3) / M
    c = mp.mpf(c); a = mp.mpf(a)
    th = 1 / (18 * d * c + 1)
    e0m = c * (d * F_d(d) + 1) / M
    u1 = b - h
    u2 = (1 - th) * (p + h) + e0m + th * lamp * a
    sq = lambda u: mp.sqrt(u) if u > 0 else mp.mpf(0)
    tri = max(sq(u1) - sq(u2), 0) ** 2
    num = th * (p - h - lamp * a) - e0m
    cor = max(num, 0) ** 2 / (4 * (lamp + h / 2))
    return tri, cor, th


print("=" * 100)
print("N1  Corollary 5.2 'Numbers', c = 1, lambda = 1, worst case on the event")
g1 = gam(1)
rows = {'1/n': [], '1/d': []}
for d in range(1, 1001):
    st = bin_stats(d)
    for lab in ('1/n', '1/d'):
        a = 1 / st[1] if lab == '1/n' else mp.mpf(1) / d
        tri, cor, th = psi_lower(d, 1, a, st=st)
        rows[lab].append((d, tri, cor, th))
for lab in ('1/n', '1/d'):
    R = rows[lab]
    pos = [d for d, tri, cor, th in R if max(tri, cor) > 0]
    ok = [d for d, tri, cor, th in R if cor >= 2 * g1 * th ** 2 / 3]
    first_ok = ok[0]
    gaps = [d for d in range(first_ok, 1001) if d not in set(ok)]
    ratio = {d: cor / (g1 * th ** 2) for d, tri, cor, th in R}
    dec = [d for d in range(32, 1001) if ratio[d] < ratio[d - 1]]
    dm, bm = max(((d, max(tri, cor)) for d, tri, cor, th in R), key=lambda t: t[1])
    print(" a = %s: first positive d = %d; positive at every d in [%d,1000]: %s; max tri = %s" % (
        lab, pos[0], pos[0], pos == list(range(pos[0], 1001)), mp.nstr(max(t for _, t, _, _ in R), 3)))
    print("          first d with bound >= 2 eps_d = %d, gaps after it: %s; ratio at first: %s; decreases on [31,1000]: %d" % (
        first_ok, gaps, mp.nstr(ratio[first_ok], 6), len(dec)))
    print("          max bound %s at d = %d; bound at d=30: %s; at d=60: %s; gamma th^2 at d=60: %s" % (
        mp.nstr(bm, 5), dm, mp.nstr(max(R[29][1], R[29][2]), 4), mp.nstr(max(R[59][1], R[59][2]), 4),
        mp.nstr(g1 * R[59][3] ** 2, 4)))
    for dd in (31, 32, 33, 34):
        d_, tri, cor, th = R[dd - 1]
        print("          d=%d: bound %s, 2 eps_d %s, ratio %s" % (dd, mp.nstr(cor, 4), mp.nstr(2 * g1 * th ** 2 / 3, 4),
                                                                  mp.nstr(ratio[dd], 6)))

print("=" * 100)
print("N2  Table after Proposition 5.3 (worst case on the event, lambda = 1), and N3 (rate)")
b1 = beta_series(1)


def hadamard_lower(k, c, lam=1, use_QleM=False):
    M, n, b, p = bin_stats(k, lam)
    n23 = n ** (mp.mpf(2) / 3)
    Qm, Qp = M * b - 2 * n23, M * b + 2 * n23
    Qc = min(Qp, M) if use_QleM else Qp
    if Qm <= 0:
        return mp.mpf(0), M
    R = c * (2 * mp.sqrt(Qc) + 1) + n / (9 * Qm)
    return max(mp.sqrt(Qm) - mp.sqrt(R), 0) ** 2 / M, M


for k in (10, 14, 20, 30, 40, 60):
    v1, M = hadamard_lower(k, 1)
    v2, _ = hadamard_lower(k, mp.mpf('0.1') * mp.sqrt(mp.mpf(2) ** k))
    print("  M=2^%-3d c=1: %.5f   c=0.1 sqrt M: %.5f" % (k, float(v1), float(v2)))
lim = b1 * (1 - mp.sqrt(2 * mp.mpf('0.1') / mp.sqrt(b1))) ** 2
print("  limit at nu = 0.1: %s; beta(1) = %s" % (mp.nstr(lim, 6), mp.nstr(b1, 7)))
worst_C, worst_at = mp.mpf(-1), None
worst_C4 = mp.mpf(-1)
for k in list(range(8, 61, 4)) + [80, 100, 120]:
    M = mp.mpf(2) ** k
    for e in [mp.mpf(i) / 8 for i in range(-8 * k // 2 - 8, 8 * k // 4 + 1)]:  # c = M^{e/ k}... grid in log2 c
        c = mp.mpf(2) ** e
        if c < 1 / M or c > mp.sqrt(M):
            continue
        v, _ = hadamard_lower(k, c, use_QleM=True)
        C = (b1 - 2 * mp.sqrt(3) * mp.sqrt(c) * M ** (-mp.mpf(1) / 4) - v) * M ** (mp.mpf(1) / 3)
        C4 = (b1 - 4 * mp.sqrt(c) * M ** (-mp.mpf(1) / 4) - v) * M ** (mp.mpf(1) / 3)
        if C > worst_C:
            worst_C, worst_at = C, (k, float(e))
        worst_C4 = max(worst_C4, C4)
print("  N3: sup over the grid (M = 2^8..2^120, c in [1/M, sqrt M]) of (beta - 2 sqrt3 sqrt c M^-1/4 - bound) M^{1/3}"
      " = %s at (log2 M, log2 c) = %s; with 4 in place of 2 sqrt 3: %s" % (mp.nstr(worst_C, 5), worst_at, mp.nstr(worst_C4, 5)))

print("=" * 100)
print("N4  Remark 5.2a")
gstar = lambda x: 0.5 * (np.tanh(1 + 2 * x) + np.tanh(1 - 2 * x))
xs = np.array([-1.0, 0.0, 1.0])
gv = gstar(xs)
Delta = gv[1] - gv[0]
print("  g* = %s, Delta = %.5f, Delta^2/6 = %.5f" % (np.round(gv, 5), Delta, Delta ** 2 / 6))
from scipy.optimize import minimize


def loss(p, clip):
    v, w0, w1 = p
    z = v * np.tanh(w0 + w1 * xs)
    if clip:
        z = np.clip(z, -1, 1)
    return np.mean((z - gv) ** 2)


best = {False: 9.0, True: 9.0}
for clip in (False, True):
    for _ in range(600):
        p0 = rng.normal(0, 3, 3)
        r = minimize(loss, p0, args=(clip,), method='Nelder-Mead', options=dict(xatol=1e-10, fatol=1e-12, maxiter=4000))
        best[clip] = min(best[clip], r.fun)
print("  min over width-one networks found (600 restarts): unclipped %.5f, clipped %.5f (>= Delta^2/6 expected)" % (
    best[False], best[True]))
print("  g* weights: rows (1, 2), (1, -2); readout 1/2, 1/2; max |weight| = 2; sup|g*| = %.4f" % np.max(np.abs(gv)))

print("=" * 100)
print("N5  Remark 5.3a")
print("  1/(2e) = %.5f > 1/7 = %.5f: %s" % (1 / (2 * math.e), 1 / 7, 1 / (2 * math.e) > 1 / 7))
for n in (10 ** 4, 10 ** 5, 10 ** 6):
    J = rng.integers(0, n, size=n)
    seen = np.zeros(n, bool); seen[J] = True
    print("  n = d = %7d: |U|/n = %.4f (e^-1 = %.4f)" % (n, (~seen).mean(), math.exp(-1)))
for b in (2.0, 3.0):
    n = 200000
    d = math.ceil(n / b)
    J = rng.integers(0, d, size=n)
    seen = np.zeros(d, bool); seen[J] = True
    U = ~seen
    theta = rng.choice([-1, 1], size=d)
    # worst learner-independent bound: half the unseen atoms are wrong in sign for ANY output; Bayes learner loss |U|/d
    s = rng.choice([-1, 1], size=d)  # arbitrary output signs, independent of theta on U
    wrong = np.mean(U & (theta == -s))
    print("  b = %.0f: d = ceil(n/b), |U|/d = %.4f (e^-b = %.4f), fraction of atoms forced wrong = %.4f (e^-b/2 = %.4f)" % (
        b, U.mean(), math.exp(-b), wrong, math.exp(-b) / 2))
for n, al in ((10 ** 3, 0.1), (10 ** 6, 0.1), (10 ** 6, 0.25)):
    err = abs(n ** al * math.tanh(n ** -al) - 1)
    print("  competitor accuracy n=%g alpha=%.2f: |g(e_j)-theta_j| = %.3e <= n^{-2a}/3 = %.3e" % (n, al, err, n ** (-2 * al) / 3))
# Gibbs-risk variant: posterior Pi over outputs depends on the sample only; risk >= mean over U of Pi(s_j = -theta_j)
n = 20000
J = rng.integers(0, n, size=n); seen = np.zeros(n, bool); seen[J] = True; U = ~seen
q = rng.uniform(0, 1, size=n)  # Pi(s_j = +1) for each j, a function of the sample only
vals = []
for _ in range(200):
    theta = rng.choice([-1, 1], size=n)
    pw = np.where(theta == 1, 1 - q, q)  # Pi(s_j = -theta_j)
    vals.append(np.sum(pw[U]) / n)
print("  Gibbs-risk variant (n=%d): min over 200 theta of n^-1 sum_U Pi(s_j=-theta_j) = %.4f (> 1/7)" % (n, min(vals)))

print("=" * 100)
print("N6  Section 6 erratum, numerics bullet (red-team run files, lambda = 1, c = 1)")
for d, G, Fw in ((8, 154.8, 93.51), (10, 634.1, 267.75)):
    phi = 1 - Fw / G
    print("  d=%d: phi = 1 - %.2f/%.1f = %.5f; (1-0.%s)G = %.3f vs cF-W = %.2f; near-min absorbs >= phi - 1/G = %.5f" % (
        d, Fw, G, phi, '396' if d == 8 else '578', (1 - (0.396 if d == 8 else 0.578)) * G, Fw, phi - 1 / G))

print("=" * 100)
print("N7  Remark 5.7a algebra")
worst1, worst2 = 0.0, 0.0
for n in [1, 2, 3, 10, 100, 10 ** 4, 10 ** 8, 10 ** 12]:
    for al in [0.01, 0.05, 0.1, 0.124, 0.2, 0.249]:
        m = math.floor(n ** al); B = n ** al
        for d in range(1, 60):
            Es = d * (d + 1) * B ** 2 + 2 * (2 - 1) * m ** 2 * B ** 2
            worst1 = max(worst1, (Es + 1) / ((d * (d + 1) + 4) * n ** (4 * al)))
            worst1b = (Es + 1) / ((d * (d + 1) + 3) * n ** (4 * al))
        U_ = m * B
        worst2 = max(worst2, (4 + (U_ + 1) ** 2) / (8 * n ** (4 * al)))
print("  max (E_*+1)/((d(d+1)+4) n^{4a}) = %.4f (<= 1); max (4+(U+1)^2)/(8 n^{4a}) = %.4f (<= 1)" % (worst1, worst2))
for al in (1e-6, 0.05, 0.1, 0.125 - 1e-9):
    th = (1 + 8 * al) / 3
    beta = min((1 - 4 * al) / 3, 0.5 - 4 * al)
    print("  Cor 8.1 at H=1, alpha=%.4f: theta=%.4f, c = n^%.4f, beta=%.4f" % (al, th, 1 - th, beta))
# c = log^3 n: middle term 8 D_n sqrt(1/c+1/n), D_n = sqrt(2(d+1) ln(n+1)), d = floor(log2 n + 1)
for e in (20, 40, 80, 160, 320):
    n = mp.mpf(2) ** e
    d = e + 1
    Dn = mp.sqrt(2 * (d + 1) * mp.log(n + 1))
    c = mp.log(n) ** 3
    mid = 8 * Dn * mp.sqrt(1 / c + 1 / n)
    print("  c = ln^3 n, n = 2^%d: middle term %.4f, times sqrt(ln n) = %.4f" % (e, float(mid), float(mid * mp.sqrt(mp.log(n)))))

print("=" * 100)
print("N8  Fixed-d row (A Prop. 5.2(c) at t = 1): simulate U_S and the bound (8M/delta + 4c)/n")
for d, mult, c, delta in ((4, 64, 1.0, 0.1), (6, 64, 1.0, 0.1), (6, 256, 4.0, 0.05)):
    M = 2 ** d; n = mult * M
    good = 0; T = 3000
    for _ in range(T):
        x = rng.integers(0, M, size=n); y = rng.choice([-1, 1], size=n)
        k = np.bincount(x, minlength=M); S = np.bincount(x, weights=y, minlength=M)
        if k.min() < 1:
            continue
        D0 = np.sum(S ** 2 / k)
        US = ((math.sqrt((D0 + c) / k.min()) + math.sqrt(D0 / k.min())) ** 2) / M
        good += US <= (8 * M / delta + 4 * c) / n
    print("  d=%d n=%d c=%g delta=%g: freq{U_S <= bound} = %.4f >= 1 - delta - M e^{-n/(8M)} = %.4f" % (
        d, n, c, delta, good / T, 1 - delta - M * math.exp(-n / (8 * M))))
