"""t6: the junta window of notes-final.md Section 5 with EXACT integer information (no I-grid), and the
sharper identification bounds (a1), (a2) (notes-final Remark 2.6; referee B, B-m1, B-m2, B-m10).

I(pi) = B_S - K(S | a, pi) is an integer, so Psi_t(c) = min over integers I >= 0 of c I + Floor_t(I).
Floor_t(I) = max(0, -log2(p + (1 - 2p) theta_{t-1} + p Dmin(I))), Dmin(I) = min_{1<=g<=40} (2 gamma_g(I) + 2^(1-g)),
gamma_g(I) = sqrt(j ln2 / (2 s0)), j = least integer with j - 2 log2(j+1) > delta_S + I + 1 + 2 log m + 2 log s0
+ g + 2 log g + kappa (lem:teacher:sharpfloor). Dmin does not depend on the level t. j is found by a binary search
in the increasing sequence j - 2 log2(j+1), j >= 3 (independent of rB7, which uses scipy's ConvexHull).
For c >= c_min, only I <= 1/c_min matters (Floor <= 1). Psi_t(c) is evaluated exactly through the lower convex
hull of the integer points {(I, Floor_t(I))}, built by Andrew's monotone chain written here.

(A) Psi_2(a 2^-m) with integer I against psi_2(p, a) (d = m = 12, 16, 20, 22; kappa = delta_S = 0; g <= 60), and
    against t4(C) (I-grid) and rB7(C).
(B) The exact window {c > 2^-20 : J_g(c) < Phi2sharp(c)} at d = 100, m = 20, B = infinity, kappa in {0, 30},
    delta_S in {0, 20}; a 1200-point geometric scan of [2^-20, 0.05], ends refined by bisection. kappa enters as in
    t4 (4 kappa in the second term).
(C) Identification inside each window (thm:teacher:main(ii) with Phi_2 replaced by Phi2sharp, epsilon = 0):
    u by the paper's (a), by (a1) and by (a2), and e by (e) with each u; at the c that t4(B) used, and at the
    geometric midpoint of the exact window.
(D) The running example (p = 2^-10): (a), (a1), (a2) at c = 1e-4 and near the top of the window.
Deterministic.
"""
import math
import sys

sys.dont_write_bytecode = True
import numpy as np

LN2 = math.log(2)
JMAX = 1 << 23
_jj = np.arange(3, JMAX, dtype=np.float64)
_fj = _jj - 2 * np.log2(_jj + 1)          # increasing for j >= 3
assert np.all(np.diff(_fj) > 0)


def least_j(x):
    """least integer j >= 0 with j - 2 log2(j+1) > x, for x >= 0 (vectorised; exact in float64)."""
    x = np.asarray(x, dtype=np.float64)
    assert np.all(x >= 0)
    idx = np.searchsorted(_fj, x, side="right")
    assert np.all(idx < len(_fj))
    return idx + 3


def least_j_scalar(x):
    j = 0
    while j - 2 * math.log2(j + 1) <= x:
        j += 1
    return j


def H(q):
    return -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def s_of(t):
    return 2 * t + 2 * math.log2(t + 1)


def psi2(p, a, theta=0.75):
    """inf_{y >= 0} a p y^2 - log2(A + k y): convex in y = sqrt(x); minimiser from the first-order condition."""
    A = p + (1 - 2 * p) * theta
    k = 2 * p * math.sqrt(LN2 / 2)
    qa, qb, qc = 2 * a * p * k * LN2, 2 * a * p * A * LN2, -k
    y = (-qb + math.sqrt(qb * qb - 4 * qa * qc)) / (2 * qa)
    return a * p * y * y - math.log2(A + k * y)


def lower_hull(xs, ys):
    """Andrew's monotone chain, lower hull of points sorted by x (x strictly increasing)."""
    hx, hy = [], []
    for x, y in zip(xs.tolist(), ys.tolist()):
        while len(hx) >= 2:
            x1, y1, x2, y2 = hx[-2], hy[-2], hx[-1], hy[-1]
            if (y2 - y1) * (x - x1) >= (y - y1) * (x2 - x1):   # hx[-1] on or above the chord
                hx.pop()
                hy.pop()
            else:
                break
        hx.append(x)
        hy.append(y)
    return np.array(hx), np.array(hy)


class Inst:
    def __init__(self, d, m, num, e, kappa, dS, gmax=40, Imax=None):
        self.d, self.m, self.kappa, self.dS = d, m, kappa, dS
        self.p = num / 2 ** e
        self.s0 = num * 2 ** (m - e)
        h, ee = num, e
        while h % 2 == 0:
            h //= 2
            ee -= 1
        Kp = 2 * math.log2(ee) if h == 1 else 2 * math.log2(h + 1) + 2 * math.log2(ee + 1)
        self.kg = 2 * math.log2(d) + Kp + kappa
        self.L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa
        self.Hp = H(self.p)
        # L_S by the exact integer binomial
        c = math.comb(2 ** m, self.s0)
        b = c.bit_length()
        self.LS = math.log2(c) if b < 1000 else math.log2(c >> (b - 64)) + (b - 64)
        self.BS = self.LS - dS
        self.gmax = gmax
        self.Imax = Imax if Imax is not None else 2 ** m + 2
        I = np.arange(self.Imax + 1, dtype=np.float64)
        D = np.full(I.shape, np.inf)
        for g in range(1, gmax + 1):
            rg = dS + 1 + 2 * math.log2(m) + 2 * math.log2(self.s0) + g + 2 * math.log2(g) + kappa
            gam = np.sqrt(least_j(I + rg) * LN2 / (2 * self.s0))
            D = np.minimum(D, 2 * gam + 2.0 ** (1 - g))
        self.I, self.D = I, D
        self._hull = {}

    def G(self, j):
        v = 0.0 if j == math.inf else 2.0 ** -j
        return 1 - math.log2(1 + v + 2 * self.p)

    def floor(self, theta):
        return np.maximum(0.0, -np.log2(self.p + (1 - 2 * self.p) * theta + self.p * self.D))

    def hull(self, t):
        if t not in self._hull:
            theta = 0.5 if t == math.inf else 0.5 + 2.0 ** -t
            hx, hy = lower_hull(self.I, self.floor(theta))
            sl = np.diff(hy) / np.diff(hx)        # increasing (from negative towards 0)
            self._hull[t] = (hx, hy, sl)
        return self._hull[t]

    def Psi(self, t, c):
        hx, hy, sl = self.hull(t)
        i = int(np.searchsorted(sl, -c, side="left"))   # first edge with slope >= -c: vertex i is optimal
        return c * hx[i] + hy[i]

    def levels(self):
        d, out, t = self.d, [], 2
        while True:
            out.append(t)
            if s_of(t) + 2 * math.log2(d) >= d and d - s_of(t) - self.L1 <= 0:
                return out
            t += 1

    def Jg(self, c):
        return c * (self.d + self.kg) + self.Hp

    def Phi2sharp(self, c):
        d, best = self.d, math.inf
        for t in self.levels():
            first = c * max(0.0, d - s_of(t) - self.L1) + self.G(t - 1)
            k = d - min(s_of(t) + 2 * math.log2(d), d) - 2 * math.log2(2 * d) - 4 * self.kappa
            best = min(best, max(first, c * k + self.Psi(t, c)))
        return best

    def window(self, cmin, cmax, npts=1200):
        f = lambda c: self.Phi2sharp(c) - self.Jg(c)
        cs = [cmin * (cmax / cmin) ** (i / npts) for i in range(npts + 1)]
        v = [f(c) > 0 for c in cs]
        ints, i = [], 0
        while i <= npts:
            if v[i]:
                j = i
                while j + 1 <= npts and v[j + 1]:
                    j += 1
                lo = cs[i] if i == 0 else bis(f, cs[i - 1], cs[i])
                hi = cs[j] if j == npts else bis(f, cs[j], cs[j + 1])
                ints.append((lo, hi))
                i = j + 1
            else:
                i += 1
        return ints

    def ident(self, c, gmax=40):
        """thm:teacher:main(ii), eps = 0, B = infinity: (a), (a1), (a2), l, I, e for each u."""
        d, m, p, s0 = self.d, self.m, self.p, self.s0
        L2 = 2 ** m * self.Hp - self.BS + 4 + self.L1 + self.kg
        Dl = self.kg + L2 / (c * 2 ** m - 1)
        L3 = 4 + 2 * math.log2(d) + self.kappa
        Rmax = c * (self.kg + 4 + self.L1) + self.Hp
        gams = []
        for g in range(1, gmax + 1):
            rhs = self.dS + Dl + L3 + 1 + 2 * math.log2(m) + 2 * math.log2(s0) + g + 2 * math.log2(g) + self.kappa
            gams.append((g, math.sqrt(least_j_scalar(rhs) * LN2 / (2 * s0))))
        ua = max(0.75, 2 ** -self.Jg(c) - p)
        u1 = max(0.75, 2 ** -Rmax - p)
        u2 = max(0.75, max((2 ** -Rmax - p * (1 + 2 * gm + 2.0 ** (1 - g))) / (1 - 2 * p) for g, gm in gams))
        e = lambda u: min(1 - u + gm + 2.0 ** -g for g, gm in gams)
        return dict(ua=ua, u1=u1, u2=u2, ea=e(ua), e1=e(u1), e2=e(u2), Dl=Dl, I=Dl + L3)


def bis(f, lo, hi, it=80):
    flo = f(lo) > 0
    for _ in range(it):
        mid = math.sqrt(lo * hi)
        if (f(mid) > 0) == flo:
            lo = mid
        else:
            hi = mid
    return math.sqrt(lo * hi)


def part_A():
    print("=" * 100)
    print("(A) Psi_2(a 2^-m) with integer I against psi_2(p, a): d = m, kappa = delta_S = 0, g <= 60")
    for (num, e) in [(1, 4), (3, 5), (7, 6)]:
        p = num / 2 ** e
        for a in (1.0, 4.0, 16.0):
            row = []
            for m in (12, 16, 20, 22):
                X = Inst(m, m, num, e, 0, 0, gmax=60, Imax=int(2 ** m / a) + 2)
                c = a * 2.0 ** -m
                row.append(float(np.min(c * X.I + X.floor(0.75))))
            print(f"    p={p:.5f} a={a:5.1f}: Psi_2 at m=12,16,20,22: " + "  ".join(f"{v:.4f}" for v in row)
                  + f"   psi_2 = {psi2(p, a):.4f}   H(p) = {H(p):.4f}")


ROWS = [(1, 10, "2^-10"), (1, 4, "1/16"), (5, 6, "5/64"), (3, 5, "3/32"), (7, 6, "7/64"), (15, 7, "15/128"), (1, 3, "1/8")]
T4C = {("1/16", 0, 0): 6.745e-05, ("5/64", 0, 0): 5.282e-05, ("3/32", 0, 0): 4.278e-05, ("7/64", 0, 0): 4.337e-05,
       ("15/128", 0, 0): 3.586e-05, ("2^-10", 0, 0): 1.226e-04}


def part_BC():
    print("=" * 100)
    print("(B) exact window {c > 2^-20 : J_g(c) < Phi2sharp(c)} at d = 100, m = 20, B = infinity (integer I)")
    print("(C) identification inside it: u by (a) / (a1) / (a2), and e with each; l <= d + Delta_l; I <= Delta_l + Lambda_3")
    d, m = 100, 20
    lo = 2.0 ** -m
    for (num, e, name) in ROWS:
        for (kappa, dS) in ((0, 0), (0, 20), (30, 0)):
            X = Inst(d, m, num, e, kappa, dS)
            ints = X.window(lo, 0.05)
            s = "; ".join(f"[{a:.4e} (= {a / lo:.3f} 2^-20), {b:.4e}]" for a, b in ints) if ints else "none"
            print(f"  p={name:>7} kappa={kappa:2d} delta_S={dS:2d}: {s}")
            if ints:
                a_, b_ = ints[0]
                cs = [("midpoint", math.sqrt(max(a_, 2 * lo) * b_))]
                if (name, kappa, dS) in T4C:
                    cs.append(("t4's c", T4C[(name, kappa, dS)]))
                for lab, c in cs:
                    r = X.ident(c)
                    print(f"      at c = {c:.4e} ({lab}): u >= {r['ua']:.4f} (a) / {r['u1']:.4f} (a1) / {r['u2']:.4f} (a2);"
                          f" e <= {r['ea']:.4f} / {r['e1']:.4f} / {r['e2']:.4f}; l <= d + {r['Dl']:.1f}; I <= {r['I']:.1f}")


def part_D():
    print("=" * 100)
    print("(D) the running example d = 100, m = 20, p = 2^-10, B = infinity: (a), (a1), (a2)")
    for (kappa, dS) in ((0, 0), (0, 20), (30, 0), (30, 20)):
        X = Inst(100, 20, 1, 10, kappa, dS, Imax=8)  # the floor arrays are not needed here
        for c in (1e-4, 2e-3, 4e-3, 6e-3, 8e-3):
            if kappa == 30 and c > 3.6e-3:
                continue
            r = X.ident(c)
            print(f"  kappa={kappa:2d} delta_S={dS:2d} c={c:.0e}: u >= {r['ua']:.4f} / {r['u1']:.4f} / {r['u2']:.4f};"
                  f" e <= {r['ea']:.4f} / {r['e1']:.4f} / {r['e2']:.4f}; l <= d + {r['Dl']:.2f}; I <= {r['I']:.2f}")


if __name__ == "__main__":
    part_A()
    part_BC()
    part_D()
