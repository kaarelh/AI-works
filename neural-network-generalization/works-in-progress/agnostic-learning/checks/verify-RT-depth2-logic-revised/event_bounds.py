"""Independent evaluation of the explicit bounds of RT-depth2.fixed.md on the event of Lemma 1.3.

Written from the note's definitions (not from the author's script):
  M = 2^d, n = ceil(lambda M), lambda' = n/M, h = 2 n^{2/3}/M,
  beta_d = E[1/K; K>=1], p_d = P(K>=1), K ~ Bin(n, 1/M)   (exact, via log-pmf)
  theta = 1/(18 d c + 1), F_d = 1 + (d+1)(d+2)^2
  underline Psi_tri = ( sqrt(beta_d - h) - sqrt((1-theta)(p_d+h) + c(dF_d+1)/M + theta lambda' a) )_+^2
  underline Psi_cor = ( theta (p_d - h - lambda' a) - c(dF_d+1)/M )_+^2 / (4 (lambda' + h/2))
Also evaluates Theorem 5.1's Psi directly at the corner (Q^-, G^+ in R_max, G^- in Psi_cor, V^+)
to confirm that the two agree (monotonicity argument of section 4).

Prop. 5.3 worst case: Psi^H >= M^{-1}( sqrt(Q^-) - sqrt(c(2 sqrt(Q^+) + 1) + n/(9 Q^-)) )_+^2.
"""
import mpmath as mp

mp.mp.dps = 60


def FD(d):
    return 1 + (d + 1) * (d + 2) ** 2


def binstats(d, lam):
    M = mp.mpf(2) ** d
    n = mp.ceil(lam * M)
    p = 1 / M
    logq = mp.log1p(-p)
    b = mp.mpf(0)
    k = 1
    while True:
        lp = mp.loggamma(n + 1) - mp.loggamma(k + 1) - mp.loggamma(n - k + 1) + k * mp.log(p) + (n - k) * logq
        term = mp.e ** lp
        b += term / k
        if k > 5 and term < mp.mpf(10) ** (-50):
            break
        k += 1
        if k > n:
            break
    p_d = 1 - mp.e ** (n * logq)
    return M, n, b, p_d


def under_psi(d, c, a, lam=1.0):
    mp.mp.dps = int(0.31 * d) + 60
    M, n, b, p = binstats(d, lam)
    lp = n / M
    h = 2 * n ** (mp.mpf(2) / 3) / M
    c = mp.mpf(c); a = mp.mpf(a)
    th = 1 / (18 * d * c + 1)
    s1 = b - h
    s2 = (1 - th) * (p + h) + c * (d * FD(d) + 1) / M + th * lp * a
    tri = max((mp.sqrt(s1) if s1 > 0 else 0) - (mp.sqrt(s2) if s2 > 0 else 0), 0) ** 2
    cor = max(th * (p - h - lp * a) - c * (d * FD(d) + 1) / M, 0) ** 2 / (4 * (lp + h / 2))
    # direct corner evaluation of Theorem 5.1's Psi
    n23 = n ** (mp.mpf(2) / 3)
    Qm = M * b - 2 * n23; Gp = M * p + 2 * n23; Gm = M * p - 2 * n23; Vp = n + n23
    E0 = c * (d * FD(d) + 1) + th * n * a
    Rmax = (1 - th) * Gp + E0
    tri2 = max((mp.sqrt(Qm) if Qm > 0 else 0) - mp.sqrt(Rmax), 0) ** 2 / M
    cor2 = max(th * Gm - E0, 0) ** 2 / (4 * M * Vp)
    return dict(tri=tri, cor=cor, tri2=tri2, cor2=cor2, th=th, M=M, n=n, b=b, p=p)


gam1 = (1 - mp.e ** -1) ** 2 / 4

print("(A) c = 1, a = 1/n, lambda = 1: first positive d, first d with bound >= 2 eps_d, max")
first_pos = None; first2 = None; best = (0, 0); fails = []
for d in range(20, 1001):
    M = mp.mpf(2) ** d
    n = M
    r = under_psi(d, 1, 1 / n)
    val = max(r['tri'], r['cor'])
    assert abs(r['tri'] - r['tri2']) <= mp.mpf(10) ** -25 * (1 + r['tri']) and abs(r['cor'] - r['cor2']) <= mp.mpf(10) ** -25 * (abs(r['cor']) + mp.mpf(10) ** -40), (d, r['tri'], r['tri2'], r['cor'], r['cor2'])
    eps = gam1 * r['th'] ** 2 / 3
    if val > 0 and first_pos is None:
        first_pos = d
    if val >= 2 * eps and first2 is None:
        first2 = d
    if first2 is not None and val < 2 * eps:
        fails.append(d)
    if val > best[1]:
        best = (d, val)
    if d in (29, 30, 33, 35, 60):
        print("  d=%d  bound=%.4e  ratio to gamma theta^2 = %.4f" % (d, float(val), float(val / (3 * eps))))
print("  first positive d:", first_pos, "; first d with >= 2eps_d:", first2,
      "; d in [first2,1000] with < 2 eps_d:", fails[:5], "; max at d=%d: %.4e" % (best[0], float(best[1])))

print("(B) small-c table (note: 1/d: 3e-4; 0.05/d: .0275 .0277 .0277; 1/d^2: .0430 .0988 .2189;"
      " 1/d^3: .3403 .4099 .4616; 1/d^3 with a=1/d: .2328 .3090 .3889)")
for label, cf, af in [("1/d", lambda d: mp.mpf(1) / d, None), ("0.05/d", lambda d: mp.mpf('0.05') / d, None),
                      ("1/d^2", lambda d: mp.mpf(1) / d ** 2, None), ("1/d^3", lambda d: mp.mpf(1) / d ** 3, None),
                      ("1/d^3,a=1/d", lambda d: mp.mpf(1) / d ** 3, lambda d: mp.mpf(1) / d)]:
    row = []
    for d in (30, 60, 200):
        n = mp.mpf(2) ** d
        a = af(d) if af else 1 / n
        r = under_psi(d, cf(d), a)
        row.append(float(max(r['tri'], r['cor'])))
    print("  c=%-12s %s" % (label, "  ".join("%.4f" % v for v in row)))

print("(C) Prop 5.3 worst case on the event, lambda = 1 (note: c=1: .093 .279 .416 .474 .483 .4848;"
      " c=0.1 sqrt M: .016 .062 .093 .103 .104 .104)")
for label, cf in [("1", lambda M: mp.mpf(1)), ("0.1 sqrt M", lambda M: mp.mpf('0.1') * mp.sqrt(M))]:
    row = []
    for k in (10, 14, 20, 30, 40, 60):
        mp.mp.dps = int(0.31 * k) + 60
        M, n, b, p = binstats(k, 1.0)
        n23 = n ** (mp.mpf(2) / 3)
        Qm = M * b - 2 * n23; Qp = M * b + 2 * n23
        c = cf(M)
        R = c * (2 * mp.sqrt(Qp) + 1) + n / (9 * Qm)
        row.append(float(max(mp.sqrt(Qm) - mp.sqrt(R), 0) ** 2 / M))
    print("  c=%-12s %s" % (label, "  ".join("%.4f" % v for v in row)))

print("(D) Prop 5.3 rate claim: worst-case bound >= beta - 4 sqrt(c) M^{-1/4} - C M^{-1/3}; print the implied C")
beta1 = mp.e ** -1 * (mp.ei(1) - mp.euler)
for k in (10, 14, 20, 30, 40, 60):
    mp.mp.dps = int(0.31 * k) + 60
    M, n, b, p = binstats(k, 1.0)
    n23 = n ** (mp.mpf(2) / 3)
    Qm = M * b - 2 * n23; Qp = M * b + 2 * n23
    for c in (mp.mpf(1), mp.sqrt(M) / 100, mp.sqrt(M) ** mp.mpf(0.5)):
        R = c * (2 * mp.sqrt(Qp) + 1) + n / (9 * Qm)
        val = max(mp.sqrt(Qm) - mp.sqrt(R), 0) ** 2 / M
        Cimp = (beta1 - 4 * mp.sqrt(c) * M ** (-mp.mpf(1) / 4) - val) / M ** (-mp.mpf(1) / 3)
        print("  M=2^%d c=%.3g  bound=%.4f  implied C=%.3f" % (k, float(c), float(val), float(Cimp)))

print("(E) widths: N0(1/n) and N0(1/d) at d=30 (note 5.7e31 and 4.5e16 = 4.2e7 n)")
d = 30; n = mp.mpf(2) ** d; M = n
for a, lab in [(1 / n, "1/n"), (mp.mpf(1) / d, "1/d")]:
    N0 = mp.ceil(72 * d * n * mp.log(2 * M) / a ** 2) + 1
    print("  a=%s  N0=%.3e  N0/n=%.3e" % (lab, float(N0), float(N0 / n)))
