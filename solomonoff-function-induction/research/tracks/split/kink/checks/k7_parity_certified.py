"""k7: Section 4 numbers of notes-final.md, revised after referee-A.md (issues 4, 6) and referee-B.md
(issues 8, 9, 11) and aligned with the teacher sub-track.

Changes against k4 (whose functions are copied below unchanged unless marked "CHANGED"):
  * b0 uses 2 log2(d+1) (fact (F5) literally, and the teacher sub-track's b0'), not 2 log2 d.  The old
    value is kept as Inst(..., b0_old=True) to show the effect.
  * (a), (c): every lambda-range is CERTIFIED as an interval.  Gamma_t(lambda) := max(G_t, F_t(budget(lambda)))
    is nondecreasing in lambda (the budget lbar_lambda + kappa decreases in lambda, and F_t is nonincreasing
    in the budget), and the left side lambda * den_t increases.  So if  b * den_t < N (Gamma_t(a) - H(p))
    for t0 <= t <= max(t0, T), condition C_t0 holds on the whole cell [a, b].  Cells are grown and halved
    adaptively in log(lambda - 1); the certified interval is a union of passing cells.
  * (b): identification at d = m = 20, with item (g) of Prop 4.2 written out:
        u >= max{ 3/4, 2^-Rmax - p, max_g [2^-Rmax - p - p (2 gamma_g + 2^(1-g))] / (1 - 2p) },
        Rmax := H(p) + lambda (kappa_g + s(t0) + Lambda_1) / N,  gamma_g at the information budget of (e);
        e <= min_g [1 - u + gamma_g + 2^-g].
  * (d): the constant of Cor 4.3, printed rounded DOWN.
Deterministic.  Python 3.11.
"""
import math

LN2 = math.log(2)


def H(q):
    return 0.0 if q in (0, 1) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / LN2


def NH_minus_LE(N, s0):
    p = s0 / N
    if N <= 2 ** 24:
        return N * H(p) - log2binom(N, s0)
    return 0.5 * math.log2(2 * math.pi * s0 * (N - s0) / N) + math.log2(math.e) * (
        1 / (12 * s0) + 1 / (12 * (N - s0)) - 1 / (12 * N))


def s_of(t):
    return 2 * t + 2 * math.log2(t + 1)


def G(t, p):
    return 1 - math.log2(1 + (2.0 ** -t if t != math.inf else 0.0) + 2 * p)


def least_j(rhs):
    if rhs > 2.0 ** 50:
        return math.ceil(rhs + 2 * math.log2(rhs + 2) + 1)
    j = max(0, int(rhs + 2 * math.log2(max(rhs, 1.0) + 1)) - 3)
    while j > 0 and (j - 1) - 2 * math.log2(j) > rhs:
        j -= 1
    while j - 2 * math.log2(j + 1) <= rhs:
        j += 1
    return j


_GCACHE = {}


def gammas(p, s0, d, budget, delta, kappa, gmax=40):
    key = (p, s0, d, round(budget, 9), delta, kappa)
    if key not in _GCACHE:
        out = []
        for g in range(1, gmax + 1):
            rhs = delta + budget + 1 + 2 * math.log2(d) + 2 * math.log2(s0) + g + 2 * math.log2(g) + kappa
            j = least_j(rhs)
            out.append((g, math.sqrt(j * LN2 / (2 * s0))))
        _GCACHE[key] = out
    return _GCACHE[key]


def F(t, p, s0, d, budget, delta, kappa):
    tt = 2.0 ** -t if t != math.inf else 0.0
    return max(1 - math.log2(1 + (1 - 2 * p) * tt + 2 * p * (2 * gm + 2.0 ** (1 - g)))
               for g, gm in gammas(p, s0, d, budget, delta, kappa))


def Kp(p):
    r = -math.log2(p)
    if abs(r - round(r)) < 1e-12:
        return 2 * math.log2(round(r))
    for e in range(1, 40):
        h = p * 2 ** e
        if abs(h - round(h)) < 1e-12:
            return 2 * math.log2(round(h) + 1) + 2 * math.log2(e + 1)
    raise ValueError


class Inst:
    def __init__(self, d, p, kappa, delta, use_sharp=True, b0_old=False):
        self.d, self.p, self.kappa, self.delta = d, p, kappa, delta
        self.N = 2 ** d
        self.s0 = round(p * self.N)
        assert abs(self.s0 - p * self.N) < 1e-9
        self.kg = 2 * math.log2(d) + Kp(p) + kappa
        self.L1 = 4 * math.log2(d) + kappa
        self.NH = self.N * H(p)
        self.gapE = NH_minus_LE(self.N, self.s0)
        self.LE = self.NH - self.gapE
        # CHANGED: 2 log2(d+1) (F5), as the teacher sub-track's b0'; b0_old=True gives k4's 2 log2 d
        self.b0 = self.kg + self.gapE + delta + (2 * math.log2(d) if b0_old else 2 * math.log2(d + 1)) + kappa
        self.use_sharp = use_sharp
        self.T = 1
        while s_of(self.T + 1) + self.L1 < d:
            self.T += 1

    def Llam(self, lam):
        return self.d + self.kg + (self.b0 + self.kappa) / (lam - 1)

    def Gam(self, t, lam):
        g = G(t, self.p)
        if not self.use_sharp:
            return g
        return max(g, F(t, self.p, self.s0, self.d, self.Llam(lam) + self.kappa, self.delta, self.kappa))

    def den(self, t):
        return self.kg + min(self.d, s_of(t + 1) + self.L1)

    def ok(self, t0, lam):
        return all(lam * self.den(t) < self.N * (self.Gam(t, lam) - H(self.p))
                   for t in range(t0, max(t0, self.T) + 1))

    def cell_ok(self, t0, a, b):
        """C_t0 holds on all of [a, b] (a <= b), by the monotonicity argument."""
        return all(b * self.den(t) < self.N * (self.Gam(t, a) - H(self.p))
                   for t in range(t0, max(t0, self.T) + 1))

    def lam_range_grid(self, t0):
        """k4's scan: log grid and bisection (not certified)."""
        top = int(4 * (math.log10(self.N) + 1))
        grid = [1 + 10.0 ** e for e in [x / 4 for x in range(-48, top + 1)]]
        oks = [self.ok(t0, l) for l in grid]
        if not any(oks):
            return None
        i0 = oks.index(True)
        i1 = len(oks) - 1 - oks[::-1].index(True)

        def bis(a, b, want):
            for _ in range(50):
                m = 1 + math.sqrt((a - 1) * (b - 1))
                if self.ok(t0, m) == want:
                    b = m
                else:
                    a = m
            return b
        lo = 1.0 if i0 == 0 else bis(grid[i0 - 1], grid[i0], True)
        hi = grid[i1] if i1 == len(grid) - 1 else bis(grid[i1 + 1], grid[i1], True)
        return lo, hi, all(oks[i0:i1 + 1])

    def certify(self, t0, lo, hi, wmin=1e-5, floor=1e-12):
        """grow a certified interval from the geometric middle of (lo, hi) in log(lambda - 1)."""
        m = 1 + math.sqrt(max(lo - 1, floor) * (hi - 1))
        if not self.ok(t0, m):
            return None
        x, w = m, 1.0
        while w >= wmin:                                   # upwards
            y = 1 + (x - 1) * math.exp(w)
            if self.cell_ok(t0, x, y):
                x, w = y, min(2 * w, 8.0)
            else:
                w /= 2
        up = x
        x, w = m, 1.0
        while w >= wmin:                                   # downwards
            y = 1 + (x - 1) * math.exp(-w)
            if y - 1 < floor:
                if self.cell_ok(t0, 1 + floor, x):
                    x = 1 + floor
                break
            if self.cell_ok(t0, y, x):
                x, w = y, min(2 * w, 8.0)
            else:
                w /= 2
        return x, up

    def c_hi_window(self):
        p, d = self.p, self.d
        tstar = (d - self.L1) / 4
        g1 = G(1, p)
        if tstar >= 2:
            c = min((g1 - H(p)) / (8 + self.L1 + self.kg), (G(tstar - 1, p) - H(p)) / (d + self.kg))
        else:
            c = (g1 - H(p)) / (d + self.kg)
        return self.N * c

    def ident(self, lam, t0):
        d, k = self.d, self.kappa
        w = self.kg + s_of(t0) + self.L1
        Ll = self.Llam(lam)
        I_bound = (Ll - d) + s_of(t0) + 2 * math.log2(d) + k
        R_max = (self.NH + lam * w) / self.N
        u_G = 2.0 ** -R_max - self.p                                   # Lemma teacher:floor
        gl = gammas(self.p, self.s0, d, I_bound, self.delta, k)
        u_sharp = max((2.0 ** -R_max - self.p - self.p * (2 * gm + 2.0 ** (1 - g))) / (1 - 2 * self.p)
                      for g, gm in gl)                                  # Lemma teacher:sharpfloor
        u = max(0.5 + 2.0 ** (-t0 - 1), u_G, u_sharp)
        e = min(1.0, min(1 - u + gm + 2.0 ** -g for g, gm in gl))
        return dict(Kag=s_of(t0) + 2 * math.log2(d) + k, len_lo=d - s_of(t0) - self.L1, len_hi=Ll - d,
                    fit_excess=lam * w, fit_deficit=lam * (self.b0 + k) / (lam - 1),
                    suff=self.b0 + (lam - 1) * w, I=I_bound, u=u, uG=u_G, usharp=u_sharp, e=e, Rmax=R_max)


def fmt(x):
    return f"{x:.6g}"


print("=" * 104)
print("(a) p = 2^-10: level-1 ranges.  Grid range (k4's method) and the CERTIFIED interval [lo_c, hi_c]")
for d in [20, 30, 60, 100]:
    for kappa in [0, 30]:
        for delta in [0, 20]:
            I = Inst(d, 2.0 ** -10, kappa, delta)
            IG = Inst(d, 2.0 ** -10, kappa, delta, use_sharp=False)
            rG = IG.lam_range_grid(1)
            rS = I.lam_range_grid(1)
            cG = IG.certify(1, rG[0], rG[1])
            cS = I.certify(1, rS[0], rS[1])
            print(f"  d={d:3d} kappa={kappa:2d} delta_E={delta:2d}: N c_hi = {I.c_hi_window():.6g}; G floors: grid ({fmt(rG[0])}, {fmt(rG[1])}),"
                  f" certified [{fmt(cG[0])}, {fmt(cG[1])}]; with sharp floor: grid ({fmt(rS[0])}, {fmt(rS[1])}), certified [{fmt(cS[0])}, {fmt(cS[1])}]")

print("=" * 104)
print("(b) identification at d = m = 20, p = 2^-10, every lambda-MAP (level 1); item (g) written out")
print("    (app:teacher:fulltable at lambda=2: u>=0.991, l<=d+58.2, I<=70.8, e<=0.220; at lambda=105: d+15.7, 28.3, 0.185)")
for kappa in [0, 30]:
    for delta in [0, 20]:
        for old in [False, True]:
            I = Inst(20, 2.0 ** -10, kappa, delta, b0_old=old)
            for lam in [2, 105]:
                b = I.ident(lam, 1)
                tag = "b0 with 2log(d)  [k4]" if old else "b0 with 2log(d+1) [new]"
                print(f"  kappa={kappa:2d} delta_E={delta:2d} {tag} lambda={lam:3d}: b0={I.b0:.2f}; K(a|pi)<={b['Kag']:.1f}; "
                      f"l in [d{b['len_lo'] - 20:+.1f}, d+{b['len_hi']:.2f}]; fit in [NH-{b['fit_deficit']:.1f}, NH+{b['fit_excess']:.1f}]; "
                      f"suff. def. <= {b['suff']:.1f}; I<={b['I']:.2f}; (g): Rmax={b['Rmax']:.5f}, u>=max(0.75, G: {b['uG']:.4f}, "
                      f"sharp: {b['usharp']:.4f}) = {b['u']:.4f}; e<={b['e']:.4f}")

print("=" * 104)
print("(c) every flip rate below 1/4: least level t0 with a nonempty certified range; bounds at lambda = 2 (new b0)")
for p in [1 / 16, 1 / 8, 3 / 16, 7 / 32, 15 / 64]:
    for d in [20, 30, 60, 100]:
        for kappa in [0, 30]:
            I = Inst(d, p, kappa, 0)
            out = None
            for t0 in range(1, max(I.T, 12) + 1):
                r = I.lam_range_grid(t0)
                if r is not None:
                    c = I.certify(t0, r[0], r[1])
                    out = (t0, r, c)
                    break
            if out is None:
                print(f"  p={p:.4f} d={d:3d} kappa={kappa:2d}: no level with a nonempty range")
                continue
            t0, r, c = out
            line = (f"  p={p:.4f} d={d:3d} kappa={kappa:2d}: t0={t0}; grid ({fmt(r[0])}, {r[1]:.4g}) "
                    f"{'(one interval on the grid)' if r[2] else '(NOT one interval on the grid)'}; certified "
                    + (f"[{fmt(c[0])}, {c[1]:.4g}]" if c else "none"))
            if c and c[0] <= 2 <= c[1]:
                b = I.ident(2.0, t0)
                line += (f"; at lambda=2: K(a|pi)<={b['Kag']:.1f}, l in [d{b['len_lo'] - d:+.1f}, d+{b['len_hi']:.1f}], "
                         f"I<={b['I']:.1f} of L_E={I.LE:.4g}")
            print(line)

print("=" * 104)
print("(d) Cor 4.3: the limit f_2(p) = 1 - log(1 + (1-2p)/4) exceeds H(p) on (0, 1/4]; cell bound, rounded DOWN")
cells = 100000
worst = min(1 - math.log2(1 + (1 - 2 * (k * 0.25 / cells)) / 4) - H((k + 1) * 0.25 / cells) for k in range(cells))
val_quarter = 1 - math.log2(1 + 0.5 / 4) - H(0.25)
print(f"  interval check over {cells} cells: f_2 - H >= {math.floor(worst * 1e5) / 1e5:.5f} (rounded down; raw {worst:.8f})")
print(f"  value at p = 1/4: {math.floor(val_quarter * 1e6) / 1e6:.6f} (rounded down); so 'f_2 - H >= 0.0187 on (0, 1/4]'")
