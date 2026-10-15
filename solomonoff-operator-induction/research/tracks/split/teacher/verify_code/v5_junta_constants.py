"""v5: independent checks of teacher/notes-final.md Remark 2.6 ((a1), (a2) and their numbers), of the window
membership of the c-values used there, of the structure of Phi_2^sharp (Prop 5.2) that Prop 3.6's last sentence
needs, and of Prop 5.3's computed constants p*, the 0.12331 crossing, the 0.05596 crossing and a*(p).

Written for research/tracks/split/verify-teacher.md; no code shared with teacher/checks/ or referee_code/.
Deterministic (no randomness). mpmath at 40 digits for the constants; numpy float64 for Psi and Phi_2^sharp.
kappa = 0 rows are illustrations (the machine constant set to 0), as everywhere in the record.

Method differences from the record's t4/t6 and referee B's rB7/rB8:
  * psi_2 is minimised by bisection on the derivative of the convex function y -> a p y^2 - log2(A + k y)
    (no closed-form quadratic); a*(p) by bisection in a.
  * the least j with j - 2 log2(j+1) > T comes from a fixed-point iteration y <- T + 2 log2(y+1), checked at j and j-1;
  * Psi_t(c) is a brute-force minimum over all integers 0 <= I <= 1/c (no convex hull);
  * L_S = log2 C(2^m, s0) from mpmath.loggamma.

(A) The crossings G_1 = H (B = inf), psi_2(p,1) = H and 1 - log2(3/2 - p) = H: certified brackets at 40 digits, and
    the analytic derivative bounds that make each crossing the only sign change on (0, 1/4].
(B) a*(p) at six rates; psi_2 at the record's (p, a) pairs; the a -> infinity limit.
(C) Psi_2(a 2^-m) with integer information at m = 12, 16, 20 (d = m, kappa = delta_S = 0, g <= 60).
(D) Remark 2.6: (a), (a1), (a2) and the e-bounds at the record's c-values, with the window membership of each c
    (J_g(c) < Phi_2(c) for p = 2^-10, J_g(c) < Phi_2^sharp(c) for the other rates), d = 100, m = 20, B = inf.
(E) Phi_2^sharp: beyond the level t_0 at which s(t) >= d - Lambda_1 and s(t) + 2 log d >= d, LB_t is
    nondecreasing in t and LB_inf >= LB_{t_0}; so Phi_2^sharp is a minimum of finitely many continuous functions.
(F) The upper ends of the exact windows at d = 100, m = 20 (kappa = 0, delta_S = 0), and the lower end at 15/128.
(G) (a1) against the paper's (a) when d - 4 - Lambda_1 < 0 (the full table d = m = 20 of cor:teacher:fulltable):
    R_max = c (kappa_g + 4 + Lambda_1) + H(p) + eps then exceeds J_g(c) + eps, and (a1) is weaker than (a);
    with c (d - 4 - Lambda_1)^+ subtracted instead it never is.
(H) Rounding direction of the quoted thresholds: a dyadic rate between each root and its rounded-up decimal
    (0.0560 in the paper; 0.07787 and 0.12331 in the record) at which the property fails.
"""
import math
import mpmath as mp
import numpy as np

mp.mp.dps = 40
LN2 = math.log(2)


# ----------------------------------------------------------------------------------------------- constants
def Hm(p):
    p = mp.mpf(p)
    return -(p * mp.log(p, 2) + (1 - p) * mp.log(1 - p, 2))


def psi2_m(p, a, theta=mp.mpf(3) / 4):
    """inf_{y>=0} a p y^2 - log2(A + k y), A = p + (1-2p) theta, k = 2 p sqrt(ln2/2); bisection on phi'(y)."""
    p, a = mp.mpf(p), mp.mpf(a)
    A = p + (1 - 2 * p) * theta
    k = 2 * p * mp.sqrt(mp.log(2) / 2)
    dphi = lambda y: 2 * a * p * y - k / ((A + k * y) * mp.log(2))
    lo, hi = mp.mpf(0), mp.mpf(1)
    assert dphi(lo) < 0
    while dphi(hi) <= 0:
        hi *= 2
    for _ in range(200):
        mid = (lo + hi) / 2
        if dphi(mid) <= 0:
            lo = mid
        else:
            hi = mid
    y = (lo + hi) / 2
    return a * p * y * y - mp.log(A + k * y, 2), y


def bracket_root(f, lo, hi, it=160):
    flo, fhi = f(lo), f(hi)
    assert flo > 0 > fhi
    for _ in range(it):
        mid = (lo + hi) / 2
        if f(mid) > 0:
            lo = mid
        else:
            hi = mid
    return lo, hi


def partA():
    print("=" * 100)
    print("(A) crossings on (0, 1/4], B = infinity (40-digit arithmetic)")
    G1 = lambda p: 1 - mp.log(mp.mpf(3) / 2 + 2 * p, 2) - Hm(p)
    f1 = lambda p: 1 - mp.log(mp.mpf(3) / 2 - p, 2) - Hm(p)
    h1 = lambda p: psi2_m(p, 1)[0] - Hm(p)
    for name, f, lo, hi, quoted in (("G_1 = H", G1, mp.mpf("0.01"), mp.mpf("0.25"), "0.05596"),
                                    ("psi_2(p,1) = H", h1, mp.mpf("0.01"), mp.mpf("0.25"), "0.07787"),
                                    ("1 - log2(3/2 - p) = H", f1, mp.mpf("0.01"), mp.mpf("0.25"), "0.12331")):
        a, b = bracket_root(f, lo, hi)
        q = mp.mpf(quoted)
        side = "below" if q < a else ("above" if q > b else "inside")
        print(f"    {name:24s}: root in [{mp.nstr(a, 12)}, {mp.nstr(b, 12)}]; quoted {quoted} rounds it "
              f"({side}; |diff| = {mp.nstr(abs(q - a), 3)})")
        assert abs(q - a) < 5e-6
    # analytic monotonicity certificates (bounds valid for every p in (0, 1/4])
    l2 = mp.log(2)
    c0 = 1 / mp.sqrt(2 * l2)                 # y*(A + k y*) = c0 at a = 1
    kmax = 2 * mp.mpf("0.25") * mp.sqrt(l2 / 2)
    Amin, Amax = mp.mpf("0.625"), mp.mpf("0.75")
    ymax = c0 / Amin
    ymin = c0 / (Amax + kmax * ymax)
    second_min = (2 * mp.sqrt(l2 / 2) * ymin - mp.mpf("0.5")) / ((Amax + kmax * ymax) * l2)
    hprime_max = ymax ** 2 - second_min - mp.log(3, 2)
    f1prime_max = 1 / (mp.mpf("1.25") * l2) - mp.log(3, 2)
    print(f"    certificates on (0, 1/4]: (G_1 - H)' < -log2 3 < 0;  (1 - log2(3/2-p) - H)' <= {mp.nstr(f1prime_max, 5)} < 0;")
    print(f"      for h(p) = psi_2(p,1) - H(p): y* in [{mp.nstr(ymin, 5)}, {mp.nstr(ymax, 5)}], and by Danskin")
    print(f"      h'(p) = y*^2 - (2 sqrt(ln2/2) y* - 1/2)/((A + k y*) ln2) - log2((1-p)/p) <= {mp.nstr(hprime_max, 5)} < 0")
    assert hprime_max < 0 and f1prime_max < 0
    # numerical sanity of the derivative formula against finite differences
    for p in (mp.mpf("0.03"), mp.mpf("0.0779"), mp.mpf("0.2")):
        val, y = psi2_m(p, 1)
        A = mp.mpf(3) / 4 - p / 2
        k = 2 * p * mp.sqrt(l2 / 2)
        an = y ** 2 - (2 * mp.sqrt(l2 / 2) * y - mp.mpf("0.5")) / ((A + k * y) * l2) - mp.log((1 - p) / p, 2)
        hh = mp.mpf("1e-12")
        fd = (h1(p + hh) - h1(p - hh)) / (2 * hh)
        assert abs(an - fd) < 1e-8
    print("      (Danskin's formula agrees with central differences at p = 0.03, 0.0779, 0.2 to 1e-8)")


def partB():
    print("=" * 100)
    print("(B) a*(p) = inf{a >= 1 : psi_2(p,a) > H(p)}, psi_2 values, and the a -> infinity limit")
    quoted = {"5/64": "1.011", "3/32": "2.128", "0.1": "3.034", "7/64": "5.999", "15/128": "15.585", "0.12": "30.20"}
    for s in ("5/64", "3/32", "0.1", "7/64", "15/128", "0.12"):
        p = mp.mpf(eval(s.replace("/", "*1.0/"))) if "/" in s else mp.mpf(s)
        if "/" in s:
            a_, b_ = s.split("/")
            p = mp.mpf(int(a_)) / int(b_)
        Hp = Hm(p)
        g = lambda a: psi2_m(p, a)[0] - Hp
        lo, hi = mp.mpf(1), mp.mpf(2)
        if g(lo) > 0:
            astar = mp.mpf(1)
        else:
            while g(hi) <= 0:
                hi *= 2
            for _ in range(80):
                mid = (lo + hi) / 2
                if g(mid) > 0:
                    hi = mid
                else:
                    lo = mid
            astar = (lo + hi) / 2
        q = mp.mpf(quoted[s])
        dig = len(quoted[s].split(".")[1])
        ok = abs(astar - q) <= mp.mpf(10) ** (-dig) * mp.mpf("0.5") + mp.mpf("1e-12")
        print(f"    p = {s:7s}: a* = {mp.nstr(astar, 8):>10s}   quoted {quoted[s]:>7s}   "
              f"{'agrees to the printed digits' if ok else 'DIFFERS'}")
    for (s, a, quoted_psi) in (("1/16", 1, "0.3980"), ("1/16", 4, "0.4552"), ("1/16", 16, "0.4710"),
                               ("3/32", 1, "0.3914"), ("7/64", 1, "0.3884")):
        a_, b_ = s.split("/")
        p = mp.mpf(int(a_)) / int(b_)
        v = psi2_m(p, a)[0]
        print(f"    psi_2({s}, {a:2d}) = {mp.nstr(v, 7)}   (record: {quoted_psi})")
        assert abs(v - mp.mpf(quoted_psi)) < 5e-5
    for s in ("1/16", "15/128"):
        a_, b_ = s.split("/")
        p = mp.mpf(int(a_)) / int(b_)
        lim = 1 - mp.log(mp.mpf(3) / 2 - p, 2)
        vals = [psi2_m(p, a)[0] for a in (1, 10, 100, 1e4, 1e6)]
        assert all(vals[i] < vals[i + 1] for i in range(len(vals) - 1)) and vals[-1] < lim
        print(f"    p = {s}: psi_2 at a = 1, 10, 100, 1e4, 1e6: " + ", ".join(mp.nstr(v, 6) for v in vals)
              + f"  -> 1 - log2(3/2 - p) = {mp.nstr(lim, 6)}")


# ----------------------------------------------------------------------------------------------- floors
def least_j(T):
    """least integer j >= 0 with j - 2 log2(j+1) > T (vectorised)."""
    T = np.asarray(T, dtype=np.float64)
    out = np.zeros(T.shape, dtype=np.int64)
    pos = T >= 0
    if np.any(pos):
        t = T[pos]
        y = t + 2 * np.log2(t + 2) + 2
        for _ in range(60):
            y = t + 2 * np.log2(y + 1)
        j = np.floor(y).astype(np.int64) + 1
        j = np.maximum(j, 3)
        f = lambda jj: jj - 2 * np.log2(jj + 1.0)
        for _ in range(3):                                 # local correction, should not trigger
            j = np.where(f(j) <= t, j + 1, j)
            j = np.where((j - 1 >= 3) & (f(j - 1) > t), j - 1, j)
        assert np.all(f(j) > t) and np.all((j - 1 < 3) | (f(j - 1) <= t))
        out[pos] = j
    return out


class Inst:
    def __init__(self, d, m, h, e, kappa=0.0, dS=0.0, gmax=60):
        self.d, self.m, self.kappa, self.dS, self.gmax = d, m, kappa, dS, gmax
        self.p = h / 2 ** e
        self.s0 = h * 2 ** (m - e)
        assert self.s0 == int(self.s0)
        while h % 2 == 0:
            h //= 2
            e -= 1
        Kp = 2 * math.log2(e) if h == 1 else 2 * math.log2(h + 1) + 2 * math.log2(e + 1)
        self.kg = 2 * math.log2(d) + Kp + kappa
        self.L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa
        N, k = mp.mpf(2) ** m, mp.mpf(self.s0)
        self.LS = float((mp.loggamma(N + 1) - mp.loggamma(k + 1) - mp.loggamma(N - k + 1)) / mp.log(2))
        self.BS = self.LS - dS
        self.Hp = float(Hm(mp.mpf(self.p)))
        self._D = {}

    def Dmin(self, Imax):
        if Imax not in self._D:
            I = np.arange(Imax + 1, dtype=np.float64)
            D = np.full(I.shape, np.inf)
            for g in range(1, self.gmax + 1):
                rg = self.dS + 1 + 2 * math.log2(self.m) + 2 * math.log2(self.s0) + g + 2 * math.log2(g) + self.kappa
                D = np.minimum(D, 2 * np.sqrt(least_j(I + rg) * LN2 / (2 * self.s0)) + 2.0 ** (1 - g))
            self._D = {Imax: D}
        return self._D[Imax]

    def Psi(self, t, c):
        Imax = int(math.floor(1 / c)) + 1
        D = self.Dmin(max(Imax, max(self._D) if self._D else 0))[: Imax + 1]
        th = 0.5 if t == math.inf else 0.5 + 2.0 ** -t
        fl = np.maximum(0.0, -np.log2(self.p + (1 - 2 * self.p) * th + self.p * D))
        return float(np.min(c * np.arange(Imax + 1) + fl))

    def G(self, j):
        return 1 - math.log2(1 + (0.0 if j == math.inf else 2.0 ** -j) + 2 * self.p)

    @staticmethod
    def s(t):
        return 2 * t + 2 * math.log2(t + 1)

    def LB(self, t, c):
        d = self.d
        if t == math.inf:
            first = self.G(math.inf)
            coef = d - d - 2 * math.log2(2 * d) - self.kappa
        else:
            first = c * max(0.0, d - self.s(t) - self.L1) + self.G(t - 1)
            coef = d - min(self.s(t) + 2 * math.log2(d), d) - 2 * math.log2(2 * d) - self.kappa
        return max(first, c * coef + self.Psi(t, c))

    def t0(self):
        t = 2
        while not (self.s(t) >= self.d - self.L1 and self.s(t) + 2 * math.log2(self.d) >= self.d):
            t += 1
        return t

    def Phi2sharp(self, c):
        return min([self.LB(t, c) for t in range(2, self.t0() + 1)] + [self.LB(math.inf, c)])

    def Phi2(self, c):
        d, L1 = self.d, self.L1
        ts = (d - L1) / 4
        return min(c * (d - 8 - L1) + self.G(1), self.G(ts - 1)) if ts >= 2 else self.G(1)

    def Jg(self, c):
        return c * (self.d + self.kg) + self.Hp

    def ident(self, c, gmax=60):
        d, m, p, s0 = self.d, self.m, self.p, self.s0
        L2 = 2 ** m * self.Hp - self.BS + 4 + self.L1 + self.kg
        Dl = self.kg + L2 / (c * 2 ** m - 1)
        L3 = 4 + 2 * math.log2(d) + self.kappa
        Rmax = c * (self.kg + 4 + self.L1) + self.Hp
        gs = np.arange(1, gmax + 1, dtype=np.float64)
        T = self.dS + Dl + L3 + 1 + 2 * math.log2(m) + 2 * math.log2(s0) + gs + 2 * np.log2(gs) + self.kappa
        gam = np.sqrt(least_j(T) * LN2 / (2 * s0))
        ua = max(0.75, 2 ** -self.Jg(c) - p)
        u1 = max(0.75, 2 ** -Rmax - p)
        u2 = max(0.75, float(np.max((2 ** -Rmax - p * (1 + 2 * gam + 2.0 ** (1 - gs))) / (1 - 2 * p))))
        e = lambda u: float(np.min(1 - u + gam + 2.0 ** -gs))
        return dict(ua=ua, u1=u1, u2=u2, ea=e(ua), e1=e(u1), e2=e(u2), Dl=Dl, I=Dl + L3, LS=self.LS)


def partC():
    print("=" * 100)
    print("(C) Psi_2(a 2^-m) with integer I (d = m, kappa = delta_S = 0, g <= 60) against psi_2(p, a)")
    rec = {(1, 16, 1): (0.3837, 0.3968, 0.3979), (1, 16, 4): (0.4117, 0.4510, 0.4549),
           (1, 16, 16): (0.4117, 0.4581, 0.4698), (3, 32, 1): (0.3764, 0.3901, 0.3913),
           (7, 64, 1): (0.3732, 0.3871, 0.3883)}
    for (h, q, a), vals in rec.items():
        e = int(math.log2(q))
        row = []
        for m, v in zip((12, 16, 20), vals):
            X = Inst(m, m, h, e)
            P = X.Psi(2, a * 2.0 ** -m)
            row.append(f"{P:.4f}")
            assert abs(P - v) < 6e-5, (h, q, a, m, P, v)
        ps = float(psi2_m(mp.mpf(h) / q, a)[0])
        print(f"    p = {h}/{q}, a = {a:2d}: m = 12, 16, 20: {', '.join(row)}  (record {vals}); psi_2 = {ps:.4f}")


def partD():
    print("=" * 100)
    print("(D) Remark 2.6 at d = 100, m = 20, B = inf, kappa = 0 (illustration), delta_S = 0, epsilon = 0")
    rows = [((1, 10), 1e-4, "0.9831/0.9882/0.9897", "0.1991/0.1940/0.1925"),
            ((1, 10), 4e-3, "0.750/0.873/0.874", "0.432/0.309/0.308"),
            ((1, 10), 1.2260e-4, "(a2) 0.989", "(a2) 0.193"),
            ((1, 4), 6.7450e-5, "0.750/0.750/0.828", "0.274/0.274/0.1965"),
            ((5, 6), 5.2820e-5, "0.750/0.750/0.803", "0.273/0.273/0.220"),
            ((3, 5), 4.2780e-5, "0.750/0.750/0.780", "0.271/0.271/0.240"),
            ((7, 6), 4.3370e-5, "0.750/0.750/0.760", "0.269/0.269/0.260"),
            ((15, 7), 3.5860e-5, "0.750/0.750/0.750", "0.269/0.269/0.269")]
    for (h, e), c, uq, eq in rows:
        X = Inst(100, 20, h, e)
        r = X.ident(c)
        if (h, e) == (1, 10):
            ok = X.Jg(c) < X.Phi2(c)
            memb = f"J_g < Phi_2: {ok} (margin {X.Phi2(c) - X.Jg(c):.4f})"
        else:
            ps = X.Phi2sharp(c)
            ok = X.Jg(c) < ps
            memb = f"J_g < Phi2#: {ok} (margin {ps - X.Jg(c):.4f}; Phi_2 - J_g = {X.Phi2(c) - X.Jg(c):+.4f})"
        assert ok
        print(f"    p = {h}/2^{e:<2d} c = {c:.4e}: u >= {r['ua']:.4f}/{r['u1']:.4f}/{r['u2']:.4f} [{uq}]; "
              f"e <= {r['ea']:.4f}/{r['e1']:.4f}/{r['e2']:.4f} [{eq}]")
        print(f"        l <= d + {r['Dl']:.2f}; I <= {r['I']:.2f} of L_S = {r['LS']:.1f}; {memb}")


def partE():
    print("=" * 100)
    print("(E) Phi_2^sharp: LB_t nondecreasing in t from t_0 on, and LB_inf >= LB_{t_0} (d = 100, m = 20)")
    for (h, e) in ((1, 10), (1, 4), (15, 7)):
        X = Inst(100, 20, h, e)
        t0 = X.t0()
        for c in (2.0 ** -20 * 1.5, 1e-5, 1e-4, 1e-3, 5e-3):
            vals = [X.LB(t, c) for t in range(t0, t0 + 40)]
            assert all(vals[i] <= vals[i + 1] + 1e-12 for i in range(len(vals) - 1))
            assert X.LB(math.inf, c) >= vals[0] - 1e-12
        print(f"    p = {h}/2^{e}: t_0 = {t0}; checked at 5 values of c over t_0 .. t_0 + 39 and t = inf")


def partF():
    print("=" * 100)
    print("(F) exact windows at d = 100, m = 20, kappa = 0, delta_S = 0 (upper ends; lower end at 15/128)")
    rec_hi = {(1, 10): "8.198e-3", (1, 4): "2.529e-3", (5, 6): "1.521e-3", (3, 5): "9.10e-4", (7, 6): "3.18e-4",
              (15, 7): "6.23e-5"}
    for (h, e), qs in rec_hi.items():
        q = float(qs)
        sig = len(qs.split("e")[0].replace(".", ""))
        X = Inst(100, 20, h, e)
        f = lambda c: X.Phi2sharp(c) - X.Jg(c)
        lo, hi = q * 0.9, q * 1.1
        assert f(lo) > 0 > f(hi)
        for _ in range(40):
            mid = math.sqrt(lo * hi)
            if f(mid) > 0:
                lo = mid
            else:
                hi = mid
        print(f"    p = {h}/2^{e:<2d}: upper end {lo:.4e}   (record {qs}; rounds to it: {float(f'{lo:.{sig - 1}e}') == q})")
        assert float(f"{lo:.{sig - 1}e}") == q
    X = Inst(100, 20, 15, 7)
    f = lambda c: X.Phi2sharp(c) - X.Jg(c)
    lo, hi = 2.0 ** -20 * 20, 2.0 ** -20 * 23
    assert f(lo) < 0 < f(hi)
    for _ in range(30):
        mid = math.sqrt(lo * hi)
        if f(mid) > 0:
            hi = mid
        else:
            lo = mid
    print(f"    p = 15/2^7 : lower end {hi / 2.0 ** -20:.3f} * 2^-20   (record 21.432 * 2^-20)")
    assert abs(hi / 2.0 ** -20 - 21.432) < 0.01


def partG():
    print("=" * 100)
    print("(G) (a1) versus (a) at d = m = 20, p = 2^-10, B = inf, delta_S = 0 (full table, c = lambda/N)")
    for kappa in (0.0, 30.0):
        X = Inst(20, 20, 1, 10, kappa=kappa)
        for lam in (2.0, 105.0, 1000.0):
            c = lam / 2 ** 20
            Rmax = c * (X.kg + 4 + X.L1) + X.Hp
            ua = 2 ** -X.Jg(c) - X.p
            u1 = 2 ** -Rmax - X.p
            u1p = 2 ** -(X.Jg(c) - c * max(0.0, X.d - 4 - X.L1)) - X.p
            print(f"    kappa = {kappa:4.0f}, lambda = {lam:6.0f}: d - 4 - Lambda_1 = {X.d - 4 - X.L1:7.2f}; "
                  f"(a): {ua:.6f}  (a1) as stated: {u1:.6f}  (a1) with (.)^+: {u1p:.6f}")
            assert u1 < ua and u1p >= ua


def partH():
    print("=" * 100)
    print("(H) dyadic rates between a root and its rounded-up decimal (B = infinity)")
    G1 = lambda p: 1 - mp.log(mp.mpf(3) / 2 + 2 * p, 2) - Hm(p)
    f1 = lambda p: 1 - mp.log(mp.mpf(3) / 2 - p, 2) - Hm(p)
    h1 = lambda p: psi2_m(p, 1)[0] - Hm(p)
    for name, f, h, e, dec in (("G_1 - H(p)", G1, 3669, 16, "0.0560"),
                               ("psi_2(p,1) - H(p)", h1, 81650, 20, "0.07787"),
                               ("1 - log2(3/2-p) - H(p)", f1, 129298, 20, "0.12331")):
        p = mp.mpf(h) / 2 ** e
        v = f(p)
        assert p < mp.mpf(dec) and v < 0
        print(f"    p = {h}/2^{e} = {mp.nstr(p, 9)} < {dec}: {name} = {mp.nstr(v, 4)} < 0")


if __name__ == "__main__":
    partA()
    partB()
    partC()
    partD()
    partE()
    partF()
    partG()
    partH()
