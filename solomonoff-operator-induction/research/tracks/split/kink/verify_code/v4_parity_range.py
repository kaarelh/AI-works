"""v4: independent check of kink/notes-final.md Proposition 4.2(ii) (the interval form of the lambda-range)
and item (g), with the numbers of section 4 (tables (a), (c), identification (b)) and of the synthesis's
Theorem D table.

Written for `../../verify-kink.md`; shares no code with checks/k4, k7 or referee_code/rB4.

Everything is computed in mpmath at 120 significant digits:
  * NH(p) - L_E from log-gamma (no Stirling series);
  * j in the sharp floor by an exact integer search (j - 2 log2(j+1) is increasing for j >= 2);
  * the sharp floor F#_t(I) exactly as the supremum over g >= 1: the maximum over g <= G, where G starts at
    G_MAX and is doubled until 1 - log2(1 + (1-2p)2^-t + 4p gamma_G(I)), an upper bound for every term with
    g > G, is below that maximum; the largest maximising g met is reported per row;
  * an UPPER bound U_t(I) = 1 - log2(1 + (1-2p)2^-t + 4p gamma_1(I)) >= F#_t(I) (gamma_g is nondecreasing in
    g because the threshold for j grows with g; 2^(1-g) >= 0), used to prove that C_t0(lambda) FAILS
    near lambda = 1: if max(G_t0, U_t0) <= H(p), the t = t0 inequality of C_t0 cannot hold.
Certification (Prop 4.2(ii)): a cell [a, b] passes if b * den_t < N (Gamma_t(a) - H(p)) for t0 <= t <= max(t0, T)
(with a relative safety margin of 1e-30).  Cells are laid in log(lambda - 1), each as long as passes.  An
initial segment (1, b0] is certified by the G floors alone when b0 * den_t < N (G_t - H(p)) for all those t
(Gamma_t >= G_t for every lambda).
Deterministic.  Python 3.11, mpmath 1.3.
"""
from fractions import Fraction as Fr

import mpmath as mp

mp.mp.dps = 120
G_MAX = 64
SAFE = mp.mpf(10) ** -30


def lg(x):
    return mp.log(x, 2)


def Hb(p):
    return -(p * lg(p) + (1 - p) * lg(1 - p))


def Kp(p):
    """K(p) bound used by the record: 2 log r for p = 2^-r; 2 log(h+1) + 2 log(e+1) for p = h/2^e."""
    h, den = p.numerator, p.denominator
    e = den.bit_length() - 1
    assert den == 2 ** e
    if h == 1:
        return 2 * lg(e)
    return 2 * lg(h + 1) + 2 * lg(e + 1)


def s_of(t):
    return 2 * t + 2 * lg(t + 1)


def least_j(T):
    """least integer j >= 0 with j - 2 log2(j+1) > T.  f(j) = j - 2 log2(j+1) is <= 0 for j <= 5 and
    increasing for j >= 2, so for T >= 0 the answer is >= 6 and is found by a local search from the
    fixed point j ~ T + 2 log2(T + 2)."""
    if T < 0:
        return 0
    f = lambda j: j - 2 * lg(j + 1)
    j = max(6, int(mp.floor(T + 2 * lg(T + 2))))
    while j > 6 and f(j - 1) > T:
        j -= 1
    while f(j) <= T:
        j += 1
    assert f(j) > T and (j == 6 or f(j - 1) <= T)
    return j


class Row:
    def __init__(self, d, p, kappa, delta, sharp=True):
        self.d, self.p, self.kappa, self.delta, self.sharp = d, p, mp.mpf(kappa), mp.mpf(delta), sharp
        self.pm = mp.mpf(p.numerator) / p.denominator
        self.N = mp.mpf(2) ** d
        self.s0 = p * 2 ** d
        assert self.s0.denominator == 1
        self.s0 = int(self.s0)
        self.H = Hb(self.pm)
        self.kg = 2 * lg(d) + Kp(p) + self.kappa
        self.L1 = 4 * lg(d) + self.kappa
        N_int = 2 ** d
        LE = (mp.loggamma(N_int + 1) - mp.loggamma(self.s0 + 1) - mp.loggamma(N_int - self.s0 + 1)) / mp.log(2)
        self.gap = self.N * self.H - LE
        self.b0 = self.kg + self.gap + self.delta + 2 * lg(d + 1) + self.kappa
        self.T = 1
        while s_of(self.T + 1) + self.L1 < d:
            self.T += 1
        self._gcache = {}

    def den(self, t):
        return self.kg + min(mp.mpf(self.d), s_of(t + 1) + self.L1)

    def G(self, t):
        return 1 - lg(1 + mp.mpf(2) ** (-t) + 2 * self.pm)

    def lbar(self, eta):
        return self.d + self.kg + (self.b0 + self.kappa) / eta

    def gammas(self, I, G=G_MAX):
        """[gamma_1(I), ..., gamma_G(I)], cached and extended on demand."""
        key = mp.nstr(I, 40)
        out = self._gcache.setdefault(key, [])
        while len(out) < G:
            g = len(out) + 1
            T = self.delta + I + 1 + 2 * lg(self.d) + 2 * lg(self.s0) + g + 2 * lg(g) + self.kappa
            out.append(mp.sqrt(least_j(T) * mp.log(2) / (2 * self.s0)))
        return out[:G]

    def Fsharp(self, t, I):
        """sup over g >= 1, exactly: the max over g <= G, with G doubled until the tail bound
        1 - log2(1 + (1-2p)2^-t + 4p gamma_G) (valid for every g > G, as gamma_g >= gamma_G) is below it."""
        G = G_MAX
        a = (1 - 2 * self.pm) * mp.mpf(2) ** (-t)
        while True:
            gl = self.gammas(I, G)
            best, arg = None, None
            for g, gm in enumerate(gl, start=1):
                v = 1 - lg(1 + a + 2 * self.pm * (2 * gm + mp.mpf(2) ** (1 - g)))
                if best is None or v > best:
                    best, arg = v, g
            tail = 1 - lg(1 + a + 4 * self.pm * gl[-1])
            if tail <= best:
                self.max_arg = max(getattr(self, "max_arg", 0), arg)
                return best, arg
            G *= 2

    def Upper(self, t, I):
        g1 = self.gammas(I, 1)[0]
        return 1 - lg(1 + (1 - 2 * self.pm) * mp.mpf(2) ** (-t) + 4 * self.pm * g1)

    def Gamma(self, t, eta):
        g = self.G(t)
        if not self.sharp:
            return g
        return max(g, self.Fsharp(t, self.lbar(eta) + self.kappa)[0])

    def ts(self, t0):
        return range(t0, max(t0, self.T) + 1)

    def C(self, t0, eta):
        lam = 1 + eta
        return all(lam * self.den(t) < self.N * (self.Gamma(t, eta) - self.H) for t in self.ts(t0))

    def cell(self, t0, ea, eb):
        return all((1 + eb) * self.den(t) * (1 + SAFE) < self.N * (self.Gamma(t, ea) - self.H) for t in self.ts(t0))

    def G_segment(self, t0, eb):
        """(1, 1+eb] certified by the G floors alone."""
        return all((1 + eb) * self.den(t) * (1 + SAFE) < self.N * (self.G(t) - self.H) for t in self.ts(t0))

    def certify(self, t0, ea, eb, wmin=mp.mpf(10) ** -12):
        """try to cover [1+ea, 1+eb] by passing cells (in log eta); return the eta reached (>= eb on success)."""
        x, w = ea, mp.mpf(1)
        while x < eb:
            y = min(x * mp.e ** w, eb)
            if self.cell(t0, x, y):
                x, w = y, min(2 * w, mp.mpf(8))
            else:
                w /= 2
                if w < wmin:
                    return x
        return x

    def lower_end(self, t0, eta_hi):
        """pointwise: inf{eta : C holds} by bisection in log eta between 1e-60 and eta_hi (C holds at eta_hi)."""
        a, b = mp.mpf(10) ** -60, eta_hi
        if self.C(t0, a):
            return None
        for _ in range(200):
            m = mp.sqrt(a * b)
            if self.C(t0, m):
                b = m
            else:
                a = m
            if b / a < 1 + mp.mpf(10) ** -9:
                break
        return b

    def fail_bound(self, t0):
        """largest eta (by bisection) with max(G_t0, U_t0(lbar+kappa)) <= H(p): C_t0 fails on (0, eta]."""
        if self.G(t0) > self.H:
            return None
        bad = lambda eta: max(self.G(t0), self.Upper(t0, self.lbar(eta) + self.kappa)) <= self.H
        a = mp.mpf(10) ** -60
        if not bad(a):
            return None
        b = mp.mpf(1)
        while bad(b):
            b *= 2
        for _ in range(300):
            m = mp.sqrt(a * b)
            if bad(m):
                a = m
            else:
                b = m
            if b / a < 1 + mp.mpf(10) ** -9:
                break
        return a

    def upper_end(self, t0, eta_lo):
        """pointwise sup of eta with C (bisection; C holds at eta_lo)."""
        a, b = eta_lo, mp.mpf(10) ** 40
        assert self.C(t0, a) and not self.C(t0, b)
        for _ in range(400):
            m = mp.sqrt(a * b)
            if self.C(t0, m):
                a = m
            else:
                b = m
            if b / a < 1 + mp.mpf(10) ** -12:
                break
        return a


def fmt(x, k=6):
    return mp.nstr(x, k)


# ---------------------------------------------------------------------------------------------------------
print("=" * 110)
print("(0) monotonicity used in the proof of Prop 4.2(ii)")
okj = all(least_j(mp.mpf(T) / 7) <= least_j(mp.mpf(T + 1) / 7) for T in range(-50, 3000))
print(f"  j(T) nondecreasing in T on T in [-50/7, 3000/7] step 1/7: {okj}")
r = Row(30, Fr(1, 8), 30, 0)
etas = [mp.mpf(10) ** k for k in range(-12, 8)]
mono = all(r.Gamma(t, etas[i]) <= r.Gamma(t, etas[i + 1]) for t in (2, 3, 5) for i in range(len(etas) - 1))
print(f"  Gamma_t(lambda) nondecreasing in lambda on a log grid (p=1/8, d=30, kappa=30, t=2,3,5): {mono}")
print(f"  b0 + kappa >= 0 in every row below (needed for lbar_lambda to decrease in lambda): checked per row")
assert okj and mono

# ---------------------------------------------------------------------------------------------------------
print("=" * 110)
print("(1) certified lambda-ranges: the record's printed intervals, re-certified independently")
print("    columns: row; printed interval; certificate of the printed interval; pointwise ends of C_t0;")
print("    for rows printed as (1, x]: where C_t0 provably fails (the U-bound) and where certification starts")

ROWS = [
    # (source, d, p, kappa, delta, t0, sharp, printed_lo (None = '(1,'), printed_hi)
    ("kink 4(a), syn. D", 20, Fr(1, 1024), 0, 0, 1, False, None, "11944.9"),
    ("kink 4(a), syn. D", 20, Fr(1, 1024), 0, 0, 1, True, None, "12008.5"),
    ("kink 4(a)", 20, Fr(1, 1024), 30, 0, 1, False, None, "6456.2"),
    ("kink 4(a)", 20, Fr(1, 1024), 30, 0, 1, True, None, "6486.2"),
    ("kink 4(a), syn. D", 30, Fr(1, 1024), 0, 0, 1, False, None, "9.979e6"),
    ("kink 4(a), syn. D", 30, Fr(1, 1024), 0, 0, 1, True, None, "1.0048e7"),
    ("kink 4(a)", 100, Fr(1, 1024), 0, 0, 1, False, None, "9.493e27"),
    ("kink 4(a)", 100, Fr(1, 1024), 0, 0, 1, True, None, "9.560e27"),
    ("kink 4(a)", 100, Fr(1, 1024), 30, 0, 1, False, None, "4.483e27"),
    ("kink 4(a)", 100, Fr(1, 1024), 30, 0, 1, True, None, "4.514e27"),
    ("kink 4(c)", 20, Fr(1, 16), 0, 0, 1, True, "1.00048", "4276"),
    ("kink 4(c), syn. D", 100, Fr(1, 16), 30, 0, 1, True, None, "1.589e27"),
    ("kink 4(c), syn. D", 20, Fr(1, 8), 0, 0, 2, True, "1.00059", "6530"),
    ("kink 4(c)", 30, Fr(1, 8), 30, 0, 2, True, None, "3.06e6"),
    ("kink 4(c)", 20, Fr(15, 64), 0, 0, 2, True, "1.08655", "465.4"),
    ("kink 4(c), syn. D", 20, Fr(15, 64), 30, 0, 2, True, "1.3422", "199.8"),
    ("kink 4(c), syn. D", 100, Fr(15, 64), 0, 0, 2, True, None, "6.896e26"),
    ("k7(c) only", 30, Fr(1, 16), 0, 0, 1, True, None, "3.673e6"),
    ("k7(c) only", 60, Fr(15, 64), 30, 0, 2, True, None, "3.449e14"),
]
results = []


def round_up(x, k):
    """x rounded up to k significant digits (as an mpf)."""
    e = int(mp.floor(mp.log10(x))) - k + 1
    return mp.ceil(x / mp.mpf(10) ** e) * mp.mpf(10) ** e


def round_down(x, k):
    e = int(mp.floor(mp.log10(x))) - k + 1
    return mp.floor(x / mp.mpf(10) ** e) * mp.mpf(10) ** e


for src, d, p, kap, dl, t0, sharp, plo, phi in ROWS:
    r = Row(d, p, kap, dl, sharp)
    assert r.b0 + r.kappa >= 0
    hi_eta = mp.mpf(phi) - 1
    printed = f"{'(1' if plo is None else '[' + plo}, {phi}]"
    tag = f"p={p}, d={d}, kappa={kap}, t0={t0}, {'sharp' if sharp else 'G only'}"
    mid = next(mp.mpf(10) ** k for k in range(-12, 30) if r.C(t0, mp.mpf(10) ** k))
    up = r.upper_end(t0, mid)
    lo = r.lower_end(t0, mid)                 # None: C holds pointwise down to eta = 1e-60
    gseg = r.G_segment(t0, mp.mpf(10) ** -40)
    # (A) the printed interval
    if plo is None:
        if gseg:
            a, b = mp.mpf(10) ** -40, hi_eta
            if r.G_segment(t0, b):
                a = b
            else:
                for _ in range(300):
                    m = mp.sqrt(a * b)
                    if r.G_segment(t0, m):
                        a = m
                    else:
                        b = m
                    if b / a < 1 + mp.mpf(10) ** -12:
                        break
            reached = a if a >= hi_eta else r.certify(t0, a, hi_eta)
            verdict = "CERTIFIED (every lambda in (1, x])" if reached >= hi_eta else \
                f"NOT certified: the certificate stops at {fmt(1 + reached, 9)}"
        else:
            verdict = "NOT certified as '(1, x]': the G floors do not cover lambda -> 1"
            if r.C(t0, mp.mpf(10) ** -12):
                reached = r.certify(t0, mp.mpf(10) ** -12, hi_eta)
                verdict += (f"; [1 + 1e-12, x] is {'certified' if reached >= hi_eta else 'NOT certified (stops at ' + fmt(1 + reached, 9) + ')'}")
            else:
                verdict += "; C fails already at lambda = 1 + 1e-12"
    else:
        ea = mp.mpf(plo) - 1
        if r.C(t0, ea):
            reached = r.certify(t0, ea, hi_eta)
            verdict = "CERTIFIED" if reached >= hi_eta else f"NOT certified: the certificate stops at {fmt(1 + reached, 9)}"
        else:
            verdict = "NOT certified: C fails at the printed lower end"
    # (B) the corrected interval: lower end rounded up, upper end rounded down, re-certified
    if gseg:
        lo_txt, ea2 = "(1", mp.mpf(10) ** -40
        if not r.G_segment(t0, ea2):
            raise SystemExit("unexpected")
    else:
        ea2 = round_up(lo * (1 + mp.mpf(10) ** -7), 3)
        lo_txt = "[1 + " + mp.nstr(ea2, 3) + "" if ea2 < mp.mpf(10) ** -3 else "[" + mp.nstr(1 + ea2, 8)
        if ea2 >= mp.mpf(10) ** -3:
            ea2 = round_up(1 + lo * (1 + mp.mpf(10) ** -7), 6) - 1
            lo_txt = "[" + mp.nstr(1 + ea2, 7)
    reach2 = r.certify(t0, ea2, up) if not gseg else None
    if gseg:
        # G segment then cells
        a, b = mp.mpf(10) ** -40, up
        for _ in range(300):
            m = mp.sqrt(a * b)
            if r.G_segment(t0, m):
                a = m
            else:
                b = m
            if b / a < 1 + mp.mpf(10) ** -12:
                break
        reach2 = r.certify(t0, a, up)
    hi2 = round_down(1 + reach2, 6)
    assert r.certify(t0, ea2, hi2 - 1) >= hi2 - 1 if not gseg else True
    fb = r.fail_bound(t0) if not gseg else None
    print(f"  [{src}] {tag}")
    print(f"      printed {printed}: {verdict}")
    print(f"      pointwise ends of C_t0: lower lambda = 1 + {fmt(lo, 6) if lo is not None else '0 (holds down to 1 + 1e-60)'};"
          f" upper lambda = {fmt(1 + up, 10)}; certified up to {fmt(1 + reach2, 10)}")
    print(f"      corrected range (lower end rounded up, upper end rounded down to 6 digits, re-certified): {lo_txt}, {mp.nstr(hi2, 6)}]")
    if fb is not None:
        print(f"      C_t0 provably fails for every lambda in (1, 1 + {fmt(fb, 4)}] (G_t0 = {fmt(r.G(t0), 5)} <= H(p) = {fmt(r.H, 5)},"
              f" and the upper bound U_t0 on the sharp floor is <= H(p) there)")
    print(f"      (largest maximising g in the sharp floor for this row: {getattr(r, 'max_arg', '-')})")
    results.append((src, tag, printed, verdict))

# ---------------------------------------------------------------------------------------------------------
print("=" * 110)
print("(2) item (g) and the identification numbers at d = m = 20, p = 2^-10, t0 = 1 (kink section 4(b))")
for kap in (0, 30):
    for dl in (0, 20):
        r = Row(20, Fr(1, 1024), kap, dl)
        for lam in (2, 105):
            eta = mp.mpf(lam) - 1
            assert r.C(1, eta)
            lb = r.lbar(eta)
            Ie = lb - r.d + s_of(1) + 2 * lg(r.d) + r.kappa
            Rmax = r.H + lam * (r.kg + s_of(1) + r.L1) / r.N
            uG = mp.mpf(2) ** (-Rmax) - r.pm
            gl = r.gammas(Ie)
            us = max((mp.mpf(2) ** (-Rmax) - r.pm - r.pm * (2 * gm + mp.mpf(2) ** (1 - g))) / (1 - 2 * r.pm)
                     for g, gm in enumerate(gl, start=1))
            theta = mp.mpf(1) / 2 + mp.mpf(2) ** (-2)
            u = max(theta, uG, us)
            e = min(1 - u + gm + mp.mpf(2) ** (-g) for g, gm in enumerate(gl, start=1))
            print(f"  kappa={kap:2d} delta_E={dl:2d} lambda={lam:3d}: C_1 holds; b0={fmt(r.b0, 6)}; l <= d + {fmt(lb - r.d, 6)};"
                  f" I <= {fmt(Ie, 6)}; R_max = {fmt(Rmax, 6)}; u >= max(3/4, {fmt(uG, 6)}, {fmt(us, 6)}) = {fmt(u, 6)};"
                  f" e <= {fmt(e, 6)}")

print("=" * 110)
print("(3) the lambda = 2 columns of kink section 4, table (c): exact values (bounds of Prop 4.2(i)(a), (b), (e))")
for p, d, kap, t0 in [(Fr(1, 16), 20, 0, 1), (Fr(1, 16), 100, 30, 1), (Fr(1, 8), 20, 0, 2), (Fr(1, 8), 30, 30, 2),
                      (Fr(15, 64), 20, 0, 2), (Fr(15, 64), 20, 30, 2), (Fr(15, 64), 100, 0, 2)]:
    r = Row(d, p, kap, 0)
    assert r.C(t0, mp.mpf(1))
    Kab = s_of(t0) + 2 * lg(d) + r.kappa
    llo = s_of(t0) + r.L1
    lhi = r.lbar(mp.mpf(1)) - d
    Ie = lhi + s_of(t0) + 2 * lg(d) + r.kappa
    print(f"  p={p}, d={d}, kappa={kap}, t0={t0}: C holds at lambda=2; K(a|pi) <= {fmt(Kab, 6)}; l in [d - {fmt(llo, 6)}, d + {fmt(lhi, 6)}];"
          f" I <= {fmt(Ie, 6)}")

print("=" * 110)
print("done")
