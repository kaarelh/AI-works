"""Explicit lower bounds of the corrected Theorem 5.1 (depth two, cube example) on the event of Lemma 1.3.

Conventions (depth-two.md, sections 1.3, 3 and 4):
  M = 2^d, n = ceil(lambda M), K ~ Bin(n, 1/M), beta_d = E[1/K; K>=1], p_d = P(K>=1).
  Event of Lemma 1.3:  |Q - M beta_d| <= 2 n^{2/3}, |G - M p_d| <= 2 n^{2/3}, |V - n| <= n^{2/3}.
  theta = 1/(18 d c + 1),  E0 = c (d F_d + 1) + theta n a,  Rmax = (1-theta) G + E0.
  Psi_tri = (sqrt Q - sqrt Rmax)_+^2 / M          (Lemma 1.2(a))
  Psi_cor = (theta G - E0)_+^2 / (4 M V)          (Lemma 1.2(b))
  Worst case on the event: Q -> Q^- , G -> G^+ in Rmax, G -> G^- in Psi_cor, V -> V^+.
  Width: N0(a) = ceil(72 d n ln(2M) / a^2) + 1.
"""
import mpmath as mp

mp.mp.dps = 80


def FD(d):
    return 1 + (d + 1) * (d + 2) ** 2


def gam(l):
    l = mp.mpf(l)
    return (1 - mp.e ** (-l)) ** 2 / (4 * l)


def beta_lim(l):
    l = mp.mpf(l)
    return mp.e ** (-l) * (mp.ei(l) - mp.euler - mp.log(l))


def binom_stats(d, lam):
    """M, n, beta_d, p_d computed exactly from Bin(n, 1/M) (pmf recursion, stable for huge n)."""
    M = mp.mpf(2) ** d
    n = mp.ceil(lam * M)
    p = 1 / M
    pmf = mp.e ** (n * mp.log1p(-p))  # P(K=0)
    p_d = 1 - pmf
    s = mp.mpf(0)
    for k in range(1, 400):
        pmf = pmf * (n - k + 1) / k * p / (1 - p)
        s += pmf / k
        if pmf < mp.mpf(10) ** (-60):
            break
    return M, n, s, p_d


def event_box(d, lam):
    M, n, b, p = binom_stats(d, lam)
    n23 = n ** (mp.mpf(2) / 3)
    return dict(M=M, n=n, beta_d=b, p_d=p, Qm=M * b - 2 * n23, Qp=M * b + 2 * n23,
                Gm=M * p - 2 * n23, Gp=M * p + 2 * n23, Vp=n + n23,
                prob=1 - 4 * mp.e ** (-n ** (mp.mpf(1) / 3) / 2) - (4 + 2 * n / M) * n ** (-mp.mpf(1) / 3))


def t51(d, c, a, lam=1.0, box=None):
    B = box or event_box(d, lam)
    M, n = B['M'], B['n']
    c = mp.mpf(c); a = mp.mpf(a)
    th = 1 / (18 * d * c + 1)
    E0 = c * (d * FD(d) + 1) + th * n * a
    Rmax = (1 - th) * B['Gp'] + E0
    psi_tri = max(mp.sqrt(max(B['Qm'], 0)) - mp.sqrt(Rmax), 0) ** 2 / M
    psi_cor = max(th * B['Gm'] - E0, 0) ** 2 / (4 * M * B['Vp'])
    return psi_tri, psi_cor, th


def N0(d, a, lam=1.0):
    M = mp.mpf(2) ** d
    n = mp.ceil(lam * M)
    return mp.ceil(72 * d * n * mp.log(2 * M) / mp.mpf(a) ** 2) + 1


def Gamma(lam, nu):
    lam = mp.mpf(lam); nu = mp.mpf(nu)
    p1 = 1 - mp.e ** (-lam)
    b1 = gam(lam) / (18 * nu + 1) ** 2
    b2 = max(mp.sqrt(beta_lim(lam)) - mp.sqrt(p1 * 18 * nu / (18 * nu + 1)), 0) ** 2
    return b1, b2


if __name__ == '__main__':
    lam = 1.0
    print("constants: gamma(1) = %s, beta(1) = %s, beta(1)/gamma(1) = %s" % (
        mp.nstr(gam(1), 8), mp.nstr(beta_lim(1), 9), mp.nstr(beta_lim(1) / gam(1), 6)))
    lstar = mp.findroot(lambda l: mp.e ** l - 1 - 2 * l, 1.25)
    print("argmax gamma = %s, max gamma = %s" % (mp.nstr(lstar, 8), mp.nstr(gam(lstar), 8)))
    bstar = mp.findroot(lambda l: mp.diff(beta_lim, l), 1.5)
    print("argmax beta  = %s, max beta  = %s" % (mp.nstr(bstar, 8), mp.nstr(beta_lim(bstar), 8)))
    # beta >= 4 gamma (Cauchy-Schwarz): check on a grid
    worst = min(beta_lim(l) / (4 * gam(l)) for l in [mp.mpf(i) / 20 for i in range(1, 201)])
    print("min over lambda in [0.05,10] of beta/(4 gamma) = %s (>= 1 expected)" % mp.nstr(worst, 8))

    print("\n(T1) c = 1, lambda = 1, worst case on the event; a = 1/n and a = 1/d")
    print("   d   Psi_cor(a=1/n)  Psi_tri  gamma*th^2    ratio   eps_d=gamma th^2/3  >=2eps_d?  Psi_cor(a=1/d)  event prob")
    first_pos = None; first_2eps = None; best = (None, mp.mpf(0))
    for d in list(range(26, 61)) + [80, 100, 200]:
        B = event_box(d, lam)
        tri, cor, th = t51(d, 1, 1 / B['n'], lam, B)
        tri2, cor2, _ = t51(d, 1, mp.mpf(1) / d, lam, B)
        asym = gam(lam) * th ** 2
        eps = asym / 3
        if cor > 0 and first_pos is None:
            first_pos = d
        if cor >= 2 * eps and first_2eps is None:
            first_2eps = d
        if cor > best[1]:
            best = (d, cor)
        if d in (29, 30, 31, 32, 33, 35, 40, 45, 50, 60, 80, 100, 200):
            print("  %3d  %.4e   %.1e   %.4e   %.4f   %.4e       %-5s     %.4e      %.4f" % (
                d, float(cor), float(tri), float(asym), float(cor / asym) if asym > 0 else 0, float(eps),
                str(bool(cor >= 2 * eps)), float(cor2), float(B['prob'])))
    print("first d with positive bound (a=1/n):", first_pos, "; first d with bound >= 2 eps_d:", first_2eps,
          "; max over d in table range: d=%d, %.4e" % (best[0], float(best[1])))

    print("\n(T2) small c, lambda = 1, worst case on the event (a = 1/n | a = 1/d)")
    print("   d   c          18dc      theta    Psi_cor(1/n)  Psi_tri(1/n)  max(1/n)   | Psi_cor(1/d) Psi_tri(1/d) max(1/d)")
    for d in [30, 40, 60, 100, 200]:
        B = event_box(d, lam)
        for label, c in [("1", 1), ("1/d", mp.mpf(1) / d), ("1/(18d)", mp.mpf(1) / (18 * d)),
                         ("0.05/d", mp.mpf(0.05) / d), ("1/d^2", mp.mpf(1) / d ** 2), ("1/d^3", mp.mpf(1) / d ** 3)]:
            tri, cor, th = t51(d, c, 1 / B['n'], lam, B)
            tri2, cor2, _ = t51(d, c, mp.mpf(1) / d, lam, B)
            print("  %3d  %-8s  %.3e  %.4f   %.4f        %.4f        %.4f     | %.4f       %.4f       %.4f" % (
                d, label, float(18 * d * c), float(th), float(cor), float(tri), float(max(cor, tri)),
                float(cor2), float(tri2), float(max(cor2, tri2))))

    print("\n(T3) limit function Gamma_lambda(nu) = max{gamma/(18nu+1)^2, (sqrt beta - sqrt((1-e^-l) 18nu/(18nu+1)))_+^2}")
    for l in [1.0, 1.5029]:
        print("  lambda = %.4f: beta = %.6f, gamma = %.6f" % (l, float(beta_lim(l)), float(gam(l))))
        for nu in [0, 0.001, 0.005, 0.01, 0.02, 0.05, 1 / 18, 0.1, 0.183, 0.5, 1.0]:
            b1, b2 = Gamma(l, nu)
            print("    nu = %-8.4f  cor-branch %.4f   tri-branch %.4f   Gamma = %.4f" % (nu, float(b1), float(b2), float(max(b1, b2))))
        # crossing point of the two branches
        f = lambda nu: Gamma(l, nu)[0] - Gamma(l, nu)[1]
        lo, hi = mp.mpf('0.001'), mp.mpf('0.18')  # f(lo) < 0 < f(hi)
        for _ in range(200):
            mid = (lo + hi) / 2
            if f(mid) < 0:
                lo = mid
            else:
                hi = mid
        nux = (lo + hi) / 2
        print("    branches cross at nu = %s (Gamma = %s); tri-branch vanishes at nu = %s" % (
            mp.nstr(nux, 5), mp.nstr(Gamma(l, nux)[0], 5),
            mp.nstr((beta_lim(l) / (1 - mp.e ** (-l))) / (18 * (1 - beta_lim(l) / (1 - mp.e ** (-l)))), 5)))

    print("\n(T4) explicit bound at c = nu/d versus its limit Gamma_1(nu), a = 1/n (worst case on the event)")
    for nu in [0.01, 0.05, 1 / 18, 0.5]:
        row = []
        for d in [30, 60, 100, 200, 400]:
            B = event_box(d, lam)
            tri, cor, th = t51(d, mp.mpf(nu) / d, 1 / B['n'], lam, B)
            row.append(float(max(tri, cor)))
        b1, b2 = Gamma(1, nu)
        print("  nu = %.4f: d=30,60,100,200,400 -> %s ; limit %.4f" % (nu, ", ".join("%.4f" % v for v in row), float(max(b1, b2))))

    print("\n(T5) width thresholds N0(a) = ceil(72 d n ln(2M)/a^2)+1, lambda = 1")
    for d in [30, 35, 60]:
        M = mp.mpf(2) ** d
        n = mp.ceil(M)
        print("  d=%d: n=%.3e  N0(1/n)=%.3e  N0(1/d)=%.3e  N0(1/d)/n=%.3e  72 d^3 ln(2M)=%.3e" % (
            d, float(n), float(N0(d, 1 / n)), float(N0(d, mp.mpf(1) / d)), float(N0(d, mp.mpf(1) / d) / n),
            float(72 * d ** 3 * mp.log(2 * M))))
