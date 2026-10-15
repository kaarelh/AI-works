"""rB4 (referee B): independent recomputation of the numbers of notes.md Section 4 (Props 4.1-4.2,
Cor 4.3, the comparison with cor:teacher:fulltable), from the formulas as written in the notes and in
paper-steeper/sections/teacher.tex, with mpmath (80 digits) for every log-binomial.

Not derived from checks/k4_parity_numbers.py.  Deterministic.

Conventions (notes Section 4): N = 2^d, s0 = pN, L_E = log2 C(N, s0), kappa_g = 2 log d + K(p) + kappa
with K(p) <= 2 log r for p = 2^-r and 2 log(h+1) + 2 log(e+1) for p = h/2^e (h odd > 1),
Lambda_1 = 4 log d + kappa, s(t) = 2t + 2 log(t+1), G_t = 1 - log(1 + 2^-t + 2p),
b0 = kappa_g + (N H(p) - L_E) + delta_E + 2 log d + kappa, lbar = d + kappa_g + (b0 + kappa)/(lambda - 1),
F_t(I) = sup_g [1 - log(1 + (1-2p)2^-t + 2p(2 gamma_g + 2^(1-g)))], gamma_g = sqrt(j ln2/(2 s0)),
j least with j - 2 log(j+1) > delta_E + I + 1 + 2 log d + 2 log s0 + g + 2 log g + kappa,
Psi_t = max(G_t, F_t(lbar + kappa)), T = least t >= 1 with s(t+1) + Lambda_1 >= d,
C_t0(lambda): lambda (kappa_g + min(d, s(t+1) + Lambda_1)) < N (Psi_t - H(p)) for t0 <= t <= max(t0, T).
"""
import math
from fractions import Fraction
import mpmath as mp

mp.mp.dps = 80
LN2 = math.log(2)


def lg(x):
    return math.log2(x)


def H(p):
    return -p * lg(p) - (1 - p) * lg(1 - p)


def log2binom(N, k):
    return float((mp.loggamma(N + 1) - mp.loggamma(k + 1) - mp.loggamma(N - k + 1)) / mp.log(2))


def NH_minus_LE(N, p):
    s0 = int(round(p * N))
    v = mp.mpf(N) * (-(mp.mpf(s0) / N) * mp.log(mp.mpf(s0) / N, 2) - (1 - mp.mpf(s0) / N) * mp.log(1 - mp.mpf(s0) / N, 2))
    return float(v - (mp.loggamma(N + 1) - mp.loggamma(s0 + 1) - mp.loggamma(N - s0 + 1)) / mp.log(2))


def Kp(p):
    fr = Fraction(p).limit_denominator(1 << 20)
    h_, den = fr.numerator, fr.denominator
    e = den.bit_length() - 1
    if h_ == 1:
        return 2 * lg(e)
    return 2 * lg(h_ + 1) + 2 * lg(e + 1)


def s(t):
    return 2 * t + 2 * lg(t + 1)


def G(t, p):
    return 1 - lg(1 + 2.0 ** -t + 2 * p)


_jcache = {}


def least_j(thr):
    """least integer j with j - 2 log2(j+1) > thr."""
    key = round(thr, 9)
    if key in _jcache:
        return _jcache[key]
    j = max(1, int(thr))
    while j - 2 * lg(j + 1) > thr and j > 1:
        j = max(1, j // 2)
    while not (j - 2 * lg(j + 1) > thr):
        j += 1
    while j > 1 and (j - 1) - 2 * lg(j) > thr:
        j -= 1
    _jcache[key] = j
    return j


def gamma_g(I, p, d, dE, kap, g):
    N = 2 ** d
    s0 = p * N
    thr = dE + I + 1 + 2 * lg(d) + 2 * lg(s0) + g + 2 * lg(g) + kap
    j = least_j(thr)
    return math.sqrt(j * LN2 / (2 * s0))


def F(t, I, p, d, dE, kap, gmax=60):
    best = -math.inf
    for g in range(1, gmax + 1):
        gg = gamma_g(I, p, d, dE, kap, g)
        arg = 1 + (1 - 2 * p) * 2.0 ** -t + 2 * p * (2 * gg + 2.0 ** (1 - g))
        best = max(best, 1 - lg(arg))
    return best


class Inst:
    def __init__(self, d, p, kap, dE):
        self.d, self.p, self.kap, self.dE = d, p, kap, dE
        self.N = 2 ** d
        self.kg = 2 * lg(d) + Kp(p) + kap
        self.L1 = 4 * lg(d) + kap
        self.b0 = self.kg + NH_minus_LE(self.N, p) + dE + 2 * lg(d) + kap
        self.T = next(t for t in range(1, 10 ** 6) if s(t + 1) + self.L1 >= d)

    def lbar(self, lam):
        return self.d + self.kg + (self.b0 + self.kap) / (lam - 1)

    def Psi(self, t, lam, sharp=True):
        g_ = G(t, self.p)
        if not sharp:
            return g_
        return max(g_, F(t, self.lbar(lam) + self.kap, self.p, self.d, self.dE, self.kap))

    def C(self, t0, lam, sharp=True):
        for t in range(t0, max(t0, self.T) + 1):
            lhs = lam * (self.kg + min(self.d, s(t + 1) + self.L1))
            rhs = self.N * (self.Psi(t, lam, sharp) - H(self.p))
            if not lhs < rhs:
                return False
        return True

    def lam_range(self, t0, sharp=True):
        """set of lambda > 1 with C_t0: scanned on a log grid, ends refined by bisection; reports
        whether the set is an interval on the grid."""
        grid = sorted(set([1 + 10 ** x for x in [i / 20 for i in range(-200, 0)]] + [10 ** (i / 20) for i in range(1, 20 * 40)]))
        ok = [self.C(t0, lam, sharp) for lam in grid]
        if not any(ok):
            return None, True
        idx = [i for i, o in enumerate(ok) if o]
        interval = all(ok[i] for i in range(idx[0], idx[-1] + 1))
        lo_i, hi_i = idx[0], idx[-1]
        if lo_i == 0:
            lo = 1.0
        else:
            a, b = grid[lo_i - 1], grid[lo_i]
            for _ in range(80):
                m = (a + b) / 2
                if self.C(t0, m, sharp):
                    b = m
                else:
                    a = m
            lo = b
        if hi_i == len(grid) - 1:
            hi = math.inf
        else:
            a, b = grid[hi_i], grid[hi_i + 1]
            for _ in range(200):
                m = (a + b) / 2
                if self.C(t0, m, sharp):
                    a = m
                else:
                    b = m
            hi = a
        return (lo, hi), interval

    def ident(self, lam, t0):
        d, N, p, kap = self.d, self.N, self.p, self.kap
        lb = self.lbar(lam)
        Kai = s(t0) + 2 * lg(d) + kap
        lmin = d - s(t0) - self.L1
        fit_up = lam * (self.kg + s(t0) + self.L1)
        fit_lo = lam * (self.b0 + kap) / (lam - 1)
        suff = self.b0 + (lam - 1) * (self.kg + s(t0) + self.L1)
        I = self.kg + (self.b0 + kap) / (lam - 1) + s(t0) + 2 * lg(d) + kap
        Rmax = H(p) + fit_up / N
        u_G = 2 ** -Rmax - p
        u_sharp = -math.inf
        e_best = math.inf
        for g in range(1, 61):
            gg = gamma_g(I, p, d, self.dE, kap, g)
            u_sharp = max(u_sharp, (2 ** -Rmax - p - p * (2 * gg + 2.0 ** (1 - g))) / (1 - 2 * p))
        u = max(u_G, u_sharp, 0.5 + 2.0 ** (-t0 - 1))
        for g in range(1, 61):
            gg = gamma_g(I, p, d, self.dE, kap, g)
            e_best = min(e_best, 1 - u + gg + 2.0 ** -g)
        return dict(Kai=Kai, lmin=lmin - d, lmax=lb - d, fit_up=fit_up, fit_lo=fit_lo, suff=suff, I=I,
                    u_G=u_G, u_sharp=u_sharp, u=u, e=e_best)


def paper_Nchi(d, p, kap):
    """N c_hi of thm:teacher:main / cor:teacher:fulltable with m = d, B = inf, p = 2^-r."""
    r = round(-lg(p))
    kg = 2 * lg(d) + 2 * lg(r) + kap
    L1 = 4 * lg(d) + kap
    ts = (d - L1) / 4
    Hp = H(p)
    if ts >= 2:
        c = min((G(1, p) - Hp) / (8 + L1 + kg), (G(ts - 1, p) - Hp) / (d + kg))
    else:
        c = (G(1, p) - Hp) / (d + kg)
    return 2 ** d * c


def bisect_root(f, a, b, it=200):
    fa = f(a)
    for _ in range(it):
        m = (a + b) / 2
        if (f(m) > 0) == (fa > 0):
            a, fa = m, f(m)
        else:
            b = m
    return (a + b) / 2


def main():
    print("rB4: Section 4 numbers, recomputed independently (referee B)")
    print("=" * 100)
    print("(a) p = 2^-10: level-1 range (t0 = 1) against N c_hi of cor:teacher:fulltable")
    for d in (20, 30, 60, 100):
        for kap in (0, 30):
            for dE in (0, 20):
                ins = Inst(d, 2.0 ** -10, kap, dE)
                Nc = paper_Nchi(d, 2.0 ** -10, kap)
                rG, iG = ins.lam_range(1, sharp=False)
                rS, iS = ins.lam_range(1, sharp=True)
                print(f"  d={d:3d} kappa={kap:2d} dE={dE:2d}: N c_hi = {Nc:.6g}; G-floor range ({rG[0]:.6g}, {rG[1]:.6g})"
                      f"{'' if iG else ' [not an interval]'}; sharp-floor range ({rS[0]:.6g}, {rS[1]:.6g}){'' if iS else ' [not an interval]'}; T = {ins.T}")
    print("=" * 100)
    print("(b) identification at d = 20, p = 2^-10, t0 = 1")
    for kap in (0, 30):
        for dE in (0, 20):
            ins = Inst(20, 2.0 ** -10, kap, dE)
            for lam in (2, 105):
                r = ins.ident(lam, 1)
                print(f"  kappa={kap:2d} dE={dE:2d} lambda={lam:3d}: K(a|pi)<={r['Kai']:.2f}, l in [d{r['lmin']:+.2f}, d+{r['lmax']:.2f}], "
                      f"fit in [NH-{r['fit_lo']:.1f}, NH+{r['fit_up']:.1f}], suff. def <= {r['suff']:.1f}, I <= {r['I']:.2f}, "
                      f"u >= {r['u']:.4f} (G floor {r['u_G']:.4f}, sharp {r['u_sharp']:.4f}), e <= {r['e']:.4f}")
    print("=" * 100)
    print("(c) every flip rate below 1/4: least t0 with a nonempty range, the range, and lambda = 2 numbers")
    rows = []
    for p in (1 / 16, 1 / 8, 3 / 16, 7 / 32, 15 / 64):
        for d in (20, 30, 60, 100):
            for kap in (0, 30):
                ins = Inst(d, p, kap, 0)
                res = None
                for t0 in (1, 2, 3):
                    rr, inter = ins.lam_range(t0)
                    if rr is not None:
                        res = (t0, rr, inter)
                        break
                if res is None:
                    print(f"  p={p:.4f} d={d:3d} kappa={kap:2d}: no t0 <= 3 with a nonempty range")
                    continue
                t0, rr, inter = res
                if rr[0] <= 2 <= rr[1]:
                    idn = ins.ident(2, t0)
                    extra = f"at lambda=2: K(a|pi)<={idn['Kai']:.1f}, l in [d{idn['lmin']:+.1f}, d+{idn['lmax']:.1f}], I<={idn['I']:.1f}"
                else:
                    extra = "lambda = 2 outside the range"
                print(f"  p={p:.4f} d={d:3d} kappa={kap:2d}: t0={t0}, lambda in ({rr[0]:.6g}, {rr[1]:.4g})"
                      f"{'' if inter else ' [NOT an interval on the grid]'}; {extra}; K(p) used = {Kp(p):.2f}")
                rows.append((p, d, kap, t0, rr))
    print("=" * 100)
    print("(d) crossovers and the interval check of Cor 4.3")
    f1 = lambda p: 1 - lg(1.5 - p) - H(p)
    G1 = lambda p: G(1, p) - H(p)
    print(f"  G_1(p) = H(p) at p = {bisect_root(G1, 0.01, 0.2):.6f}")
    print(f"  1 - log(3/2 - p) = H(p) at p = {bisect_root(f1, 0.01, 0.24):.6f}")
    # rigorous: f2(p) - H(p) >= f2(a) - H(b) on [a, b]; f2 increasing, H increasing on (0, 1/2)
    mp.mp.dps = 30
    f2 = lambda x: 1 - mp.log(1 + (1 - 2 * x) / 4, 2)
    Hm = lambda x: -x * mp.log(x, 2) - (1 - x) * mp.log(1 - x, 2) if x > 0 else mp.mpf(0)
    K = 200000
    lo = mp.mpf(10) ** 9
    worst = None
    pts = [mp.mpf(0)] + [mp.mpf(i) / (4 * K) for i in range(1, K + 1)]
    for a, b in zip(pts, pts[1:]):
        v = f2(a) - Hm(b)
        if worst is None or v < worst:
            worst, wa = v, b
    print(f"  interval check, {K} cells of (0, 1/4]: min over cells of f2(a) - H(b) = {float(worst):.6f} (at b = {float(wa):.6f}); "
          f"f2(1/4) - H(1/4) = {float(f2(mp.mpf(1) / 4) - Hm(mp.mpf(1) / 4)):.6f}")
    # monotonicity claim for f1 - H on (0, 1/4]
    der = max(math.log2(math.e) / (1.5 - p) - lg((1 - p) / p) for p in [i / 10000 for i in range(1, 2501)])
    print(f"  max over a grid of (0, 1/4] of d/dp (f1 - H) = {der:.4f} (< 0 claimed)")
    print("=" * 100)
    print("(e) Prop 4.1 steepness sigma^(t0) at the example sizes (kappa = 0, dE = 0), t0 = 1 and 2, and the")
    print("    window w <= kappa_g + s(t0) + Lambda_1")
    for p in (2.0 ** -10, 1 / 16, 1 / 8, 15 / 64):
        for d in (20, 30, 100):
            ins = Inst(d, p, 0, 0)
            for t0 in (1, 2):
                vals = []
                for t in range(t0, max(t0, ins.T) + 3):
                    Psi0 = max(G(t, p), F(t, d + 0, p, d, 0, 0))
                    vals.append(2 ** d * (Psi0 - H(p)) / (ins.kg + min(d, s(t + 1) + ins.L1)))
                Psi_inf = max(G(60, p), F(60, d, p, d, 0, 0))
                vals.append(2 ** d * (Psi_inf - H(p)) / (ins.kg + d))
                sig = min(vals)
                print(f"  p={p:.6f} d={d:3d} t0={t0}: sigma^(t0) = {sig:.4g}, window <= {ins.kg + s(t0) + ins.L1:.1f}, "
                      f"N(1-H(p))/d = {2 ** d * (1 - H(p)) / d:.4g}")


if __name__ == "__main__":
    main()
