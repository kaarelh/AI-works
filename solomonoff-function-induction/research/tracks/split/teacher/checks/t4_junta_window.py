"""t4: a window for flip rates 0.056 <= p < 0.1233 in the junta case m < d (notes.md, Section 5).

Idea (notes.md Prop 5.2): a program of level t >= 2 that holds I bits about the error rule beyond the
parity has length l >= d - min(s(t) + 2 log d, d) - 2 log(2d) - 4 kappa + I^+  (the step of
thm:teacher:main(ii)(d) read backwards), so it pays c I^+ in J_c; the sharp floor
lem:teacher:sharpfloor gains it at most about 2p sqrt(I ln2 / (2 s0)) in risk. Hence, for level t,
    J^B_c(pi) >= LB_t(c) := max{ c (d - s(t) - Lambda_1)^+ + G_{t-1},
                                 c (d - min(s(t) + 2 log d, d) - 2 log(2d) - 4 kappa) + Psi_t(c) },
    Psi_t(c) := inf_{I >= 0} [ c I + Floor_t(I) ],
    Floor_t(I) := max_{g >= 1} -log2( p + (1-2p) theta_{t-1} + p (2 gamma_g(I) + 2^(1-g)) + 2^-B ),
with theta_{t-1} = 1/2 + 2^-t (level infinity: 1/2) and gamma_g(I) as in lem:teacher:sharpfloor.
Phi2sharp(c) := min over levels of LB_t(c) replaces Phi_2(c) in thm:teacher:main(i), (ii).

(A) Asymptotics (m -> infinity, d 2^-m -> 0, delta_S = o(2^m), B = infinity, c = a 2^-m):
    psi_2(p, a) := inf_{x >= 0} [ a p x - log2(3/4 - p/2 + 2 p sqrt(x ln2 / 2)) ];
    p* := sup{p : psi_2(p, 1) > H(p)};  a*(p) := inf{a >= 1 : psi_2(p, a) > H(p)}, finite iff
    1 - log2(3/2 - p) > H(p), i.e. p < 0.12331.
(B) Finite sizes, rigorous on a grid of cells: d = 100, m = 20, B = infinity, kappa in {0, 30},
    delta_S in {0, 20}, p in {2^-10, 1/16, 5/64, 3/32, 7/64, 15/128, 1/8}: the set of c > 2^-m with
    J_g(c) < Phi2sharp(c), certified cell by cell on a geometric grid (lower bounds of Phi2sharp
    on each cell from monotonicity; inf over I by an interval grid with Floor nonincreasing in I).
    Identification bounds of thm:teacher:main(ii)(a)-(e) at one c in the window.
(C) Convergence of the finite-size level-2 bound to psi_2(p, a) as m grows (d = m).
Deterministic.
"""
import math
import numpy as np

LN2 = math.log(2)


def H(q):
    return 0.0 if q in (0.0, 1.0) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def s_of(t):
    return 2 * t + 2 * math.log2(t + 1)


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / LN2


def least_j(rhs):
    """least integer j >= 0 with j - 2 log2(j+1) > rhs."""
    j = max(0, int(rhs) - 2)
    while j > 0 and (j - 1) - 2 * math.log2(j) > rhs:
        j -= 1
    while j - 2 * math.log2(j + 1) <= rhs:
        j += 1
    return j


# ---------------------------------------------------------------------------------------------
# (A) asymptotics
# ---------------------------------------------------------------------------------------------
def psi2(p, a, theta=0.75):
    """inf_{x >= 0} [a p x - log2(p + (1-2p) theta + 2 p sqrt(x ln2/2))] by golden section on the
    unimodal function (the log term is concave in sqrt(x), the linear term convex) plus x = 0."""
    A = p + (1 - 2 * p) * theta
    k = 2 * p * math.sqrt(LN2 / 2)
    f = lambda x: a * p * x - math.log2(A + k * math.sqrt(x))
    lo, hi = 0.0, 50.0
    for _ in range(200):
        m1, m2 = lo + (hi - lo) * 0.382, lo + (hi - lo) * 0.618
        if f(m1) < f(m2):
            hi = m2
        else:
            lo = m1
    return min(f(0.0), f((lo + hi) / 2))


def check_unimodal(p, a):
    """f(y^2) in y = sqrt(x) is a p y^2 - log2(A + k y): convex in y (sum of convex), so f is unimodal in x."""
    A = p + (1 - 2 * p) * 0.75
    k = 2 * p * math.sqrt(LN2 / 2)
    ys = [i / 100 for i in range(0, 1000)]
    v = [a * p * y * y - math.log2(A + k * y) for y in ys]
    return all(v[i - 1] + v[i + 1] >= 2 * v[i] - 1e-12 for i in range(1, len(v) - 1))


def bisect(fun, lo, hi, it=200):
    flo = fun(lo)
    for _ in range(it):
        mid = (lo + hi) / 2
        if (fun(mid) > 0) == (flo > 0):
            lo, flo = mid, fun(mid)
        else:
            hi = mid
    return (lo + hi) / 2


def part_A():
    print("=" * 100)
    print("(A) asymptotic level-2 floor with the information charge, psi_2(p, a), against H(p)")
    print("    convexity in y = sqrt(x) (so golden section finds the infimum) checked on a grid:",
          all(check_unimodal(p, a) for p in [0.02, 0.06, 0.1, 0.12] for a in [1, 2, 10, 100]))
    pstar = bisect(lambda p: psi2(p, 1.0) - H(p), 0.03, 0.12)
    plim = bisect(lambda p: (1 - math.log2(1.5 - p)) - H(p), 0.05, 0.2)
    pG1 = bisect(lambda p: (1 - math.log2(1.5 + 2 * p)) - H(p), 0.01, 0.1)
    print(f"    G_1 = H(p) at p = {pG1:.5f} (the paper's window condition)")
    print(f"    psi_2(p, 1) = H(p) at p* = {pstar:.5f} (window down to c = 2^-m, asymptotically)")
    print(f"    1 - log2(3/2 - p) = H(p) at p = {plim:.5f} (limit a -> infinity)")
    print(f"    {'p':>8} {'H(p)':>8} {'G_1':>8} {'psi_2(p,1)':>11} {'1-log(1.5-p)':>13} {'a*(p)':>9}")
    for p in [1 / 32, 0.05, 0.056, 1 / 16, 0.07, 5 / 64, 0.08, 0.09, 3 / 32, 0.1, 7 / 64, 0.115, 15 / 128, 0.12, 0.123, 1 / 8]:
        lim = 1 - math.log2(1.5 - p)
        if psi2(p, 1.0) > H(p):
            astar = 1.0
        elif lim <= H(p):
            astar = math.inf
        else:
            astar = bisect(lambda a: psi2(p, a) - H(p), 1.0, 1e9)
        print(f"    {p:8.5f} {H(p):8.4f} {1 - math.log2(1.5 + 2 * p):8.4f} {psi2(p, 1.0):11.4f} {lim:13.4f} {astar:9.3f}")
    return pstar


# ---------------------------------------------------------------------------------------------
# (B) finite sizes
# ---------------------------------------------------------------------------------------------
class Instance:
    def __init__(self, d, m, p_num, p_den_log, kappa, deltaS, gmax=40):
        self.d, self.m, self.kappa, self.deltaS = d, m, kappa, deltaS
        self.p = p_num / 2 ** p_den_log
        self.s0 = int(round(self.p * 2 ** m))
        assert abs(self.s0 - self.p * 2 ** m) < 1e-9
        p = self.p
        self.LS = log2binom(2 ** m, self.s0)
        self.BS = self.LS - deltaS
        # K(p) for p = h / 2^e (h odd): 2 log(h+1) + 2 log(e+1); for h = 1 the paper's 2 log r
        h, e = p_num, p_den_log
        while h % 2 == 0:
            h //= 2
            e -= 1
        Kp = 2 * math.log2(e) if h == 1 else 2 * math.log2(h + 1) + 2 * math.log2(e + 1)
        self.kg = 2 * math.log2(d) + Kp + kappa
        self.L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa  # B = infinity
        self.Hp = H(p)
        self.gmax = gmax
        self._gam = {}

    def G(self, j):
        v = 0.0 if j == math.inf else 2.0 ** -j
        return 1 - math.log2(1 + v + 2 * self.p)

    def gamma(self, I, g):
        """gamma_g(I) of lem:teacher:sharpfloor, cached on (rounded-up I, g)."""
        key = (I, g)
        if key not in self._gam:
            rhs = (self.deltaS + I + 1 + 2 * math.log2(self.m) + 2 * math.log2(self.s0) + g
                   + 2 * math.log2(g) + self.kappa)
            j = least_j(rhs)
            self._gam[key] = math.sqrt(j * LN2 / (2 * self.s0))
        return self._gam[key]

    def floor(self, theta, I):
        p = self.p
        best = -math.inf
        for g in range(1, self.gmax + 1):
            arg = p + (1 - 2 * p) * theta + p * (2 * self.gamma(I, g) + 2.0 ** (1 - g))
            best = max(best, -math.log2(arg))
        return max(best, 0.0)  # R_B >= 0 anyway

    def Igrid(self):
        s0 = self.s0
        pts = [0.0]
        x = 1.0
        while x < 200.0 * s0 + 1e4:
            pts.append(x)
            x *= 1.02
        return pts

    def psi(self, theta, c, grid):
        """rigorous lower bound of inf_{I >= 0} [c I + Floor(I)]: on [I_k, I_{k+1}],
        c I + Floor(I) >= c I_k + Floor(I_{k+1}) (Floor nonincreasing); beyond the grid, >= c I_K."""
        best = c * grid[-1]
        fl = [self.floor(theta, I) for I in grid]
        for k in range(len(grid) - 1):
            best = min(best, c * grid[k] + fl[k + 1])
        return best

    def setup_levels(self):
        d = self.d
        self.levels = []
        t = 2
        while True:
            self.levels.append(t)
            if s_of(t) + 2 * math.log2(d) >= d and d - s_of(t) - self.L1 <= 0:
                break
            t += 1
        self.T = t
        grid = self.Igrid()
        self.grid = np.array(grid)
        # Floor values per level are independent of c: precompute
        self.fl = {}
        for t in self.levels:
            th = 0.5 + 2.0 ** -t
            self.fl[t] = np.array([self.floor(th, I) for I in grid])

    def psi_t(self, t, c):
        """rigorous lower bound of inf_{I >= 0}[c I + Floor_t(I)] (see psi)."""
        grid, fl = self.grid, self.fl[t]
        return float(min(c * grid[-1], np.min(c * grid[:-1] + fl[1:])))

    def Jg(self, c):
        return c * (self.d + self.kg) + self.Hp

    def Phi2(self, c):
        """the paper's Phi_2."""
        tstar = (self.d - self.L1) / 4
        if tstar >= 2:
            return min(c * (self.d - 8 - self.L1) + self.G(1), self.G(tstar - 1))
        return self.G(1)

    def LB_cell(self, c1, c2):
        """lower bound of Phi2sharp(c) over c in [c1, c2] (the level-T bound covers t >= T and infinity)."""
        d = self.d
        out = math.inf
        for t in self.levels:
            first = c1 * max(0.0, d - s_of(t) - self.L1) + self.G(t - 1)
            # l >= d - min(s(t) + 2 log d, d) + I - 2 kappa (F1, F3, F4, list decoding), and
            # I >= -(2 log(2d) + 2 kappa): every occurrence of kappa counted, 4 kappa in all
            k = d - min(s_of(t) + 2 * math.log2(d), d) - 2 * math.log2(2 * d) - 4 * self.kappa
            second = min(k * c1, k * c2) + self.psi_t(t, c1)
            out = min(out, max(first, second))
        return out

    def window(self, cmin, cmax, ncell=400, eps=0.0):
        """cells [c_i, c_{i+1}] of a geometric grid on which J_g(c_{i+1}) + eps < LB_cell: certified."""
        cs = [cmin * (cmax / cmin) ** (i / ncell) for i in range(ncell + 1)]
        ok = [self.Jg(cs[i + 1]) + eps < self.LB_cell(cs[i], cs[i + 1]) for i in range(ncell)]
        # merge into intervals
        ints, start = [], None
        for i, o in enumerate(ok):
            if o and start is None:
                start = cs[i]
            if not o and start is not None:
                ints.append((start, cs[i]))
                start = None
        if start is not None:
            ints.append((start, cs[-1]))
        return ints

    def chi_paper(self):
        Hp = self.Hp
        tstar = (self.d - self.L1) / 4
        if tstar >= 2:
            return min((self.G(1) - Hp) / (8 + self.L1 + self.kg), (self.G(tstar - 1) - Hp) / (self.d + self.kg))
        return (self.G(1) - Hp) / (self.d + self.kg)

    def identification(self, c, gmax=40):
        """thm:teacher:main(ii)(a)-(e) with eps = 0, B = infinity."""
        d, m, p = self.d, self.m, self.p
        Jg = self.Jg(c)
        u = max(0.75, 2 ** (-Jg) - p)
        L2 = 2 ** m * self.Hp - self.BS + 4 + self.L1 + self.kg
        Dl = self.kg + L2 / (c * 2 ** m - 1)
        L3 = 4 + 2 * math.log2(d) + self.kappa
        Ibound = Dl + L3
        best_e = math.inf
        for g in range(1, gmax + 1):
            rhs = (self.deltaS + Dl + L3 + 1 + 2 * math.log2(m) + 2 * math.log2(self.s0) + g
                   + 2 * math.log2(g) + self.kappa)
            j = least_j(rhs)
            gam = math.sqrt(j * LN2 / (2 * self.s0))
            best_e = min(best_e, 1 - u + gam + 2.0 ** -g)
        Rb = self.Hp - c * L2 / (c * 2 ** m - 1)
        return u, Dl, Ibound, best_e, Rb


def part_B():
    print("=" * 100)
    print("(B) finite sizes d = 100, m = 20, B = infinity: certified window {c > 2^-m : J_g(c) < Phi2sharp(c)}")
    d, m = 100, 20
    rows = [(1, 10, "2^-10"), (1, 4, "1/16"), (5, 6, "5/64"), (3, 5, "3/32"), (7, 6, "7/64"), (15, 7, "15/128"), (1, 3, "1/8")]
    for (num, e, name) in rows:
        for kappa in [0, 30]:
            for dS in ([0, 20] if kappa == 0 else [0]):
                inst = Instance(d, m, num, e, kappa, dS)
                inst.setup_levels()
                ints = inst.window(2.0 ** -m, 0.05)
                chi = inst.chi_paper()
                lo = 2.0 ** -m
                s = "; ".join(f"[{a:.3e}, {b:.3e}]" for a, b in ints) if ints else "none"
                print(f"  p={name:>7} (H={inst.Hp:.4f}, G_1-H={inst.G(1) - inst.Hp:+.4f}) kappa={kappa:2d} delta_S={dS:2d}: "
                      f"paper c_hi = {chi:.3e}{' (no window)' if chi <= lo else ''}; certified cells: {s}")
                if ints:
                    a, b = ints[0]
                    c = math.sqrt(max(a, 2 * lo) * b)  # a point well inside the first interval
                    u, Dl, Ib, e_, Rb = inst.identification(c)
                    print(f"      at c = {c:.3e} (c 2^m = {c * 2 ** m:.1f}): u >= {u:.3f}, l <= d + {Dl:.1f}, "
                          f"I <= {Ib:.1f} of L_S = {inst.LS:.0f}, e <= {e_:.3f}, R_B >= {Rb:.4f} (H(p) = {inst.Hp:.4f})")


def part_C():
    print("=" * 100)
    print("(C) convergence: the finite-size level-2 bound Psi_2(a 2^-m) (lower bound by the I-grid) against psi_2(p, a)")
    print("    (kappa = 0, delta_S = 0, B = infinity, d = m; psi_2 from (A); Floor maximised over g <= 60)")
    for (num, e) in [(1, 4), (3, 5), (7, 6)]:
        p = num / 2 ** e
        for a in [1.0, 4.0, 16.0]:
            row = []
            for m in [12, 16, 20, 28, 40]:
                inst = Instance(m, m, num, e, 0, 0, gmax=60)
                grid = inst.Igrid()
                c = a * 2.0 ** -m
                row.append(inst.psi(0.75, c, grid))
            print(f"    p={p:.5f} a={a:5.1f}: Psi_2 at m=12,16,20,28,40: " + "  ".join(f"{v:.4f}" for v in row)
                  + f"   limit psi_2 = {psi2(p, a):.4f}   H(p) = {H(p):.4f}")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
