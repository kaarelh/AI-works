"""rB7: referee B's independent computation of notes.md Section 5 (Lemma 5.1, Props 5.2-5.3).

(A) Closed form of psi_2(p, a) := inf_{x >= 0} [a p x - log2(3/4 - p/2 + 2p sqrt(x ln2 / 2))]: with y = sqrt(x)
    the function is convex in y and its minimiser solves a quadratic. From it: the crossings
    G_1 = H(p), psi_2(p, 1) = H(p) (p*), 1 - log2(3/2 - p) = H(p), and a*(p) (bisection in a), with a scan
    showing each crossing is unique on (0, 1/4).
(B) Exact Phi_2^sharp at d = 100, m = 20, B = inf: the information I(pi) = B_S - K(S | a, pi) is an integer,
    so Psi_t(c) = min over INTEGER I >= 0 of c I + Floor_t(I), computed exactly (no I-grid) through the
    lower convex hull of {(I, Floor_t(I)) : 0 <= I <= 2^21} (beyond 1/c the charge exceeds every Floor).
    Floor_t(I) = max(0, -log2(p + (1 - 2p) theta_{t-1} + p D(I))) with D(I) = min_{1<=g<=40} (2 gamma_g(I) + 2^(1-g)),
    independent of t. The window {c > 2^-m : J_g(c) < Phi_2^sharp(c)} is scanned on 3000 geometric points
    and its ends refined by bisection; kappa enters as in t4 (4 kappa in the second term).
(C) Convergence of Psi_2(a 2^-m) to psi_2(p, a) with exact integer I, d = m = 12, 16, 20, 22.
Deterministic.
"""
import math
import sys

import numpy as np
from scipy.spatial import ConvexHull

sys.dont_write_bytecode = True
LN2 = math.log(2)


def H(q):
    return -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def psi2(p, a, theta=0.75):
    A = p + (1 - 2 * p) * theta
    k = 2 * p * math.sqrt(LN2 / 2)
    # f(y) = a p y^2 - log2(A + k y); f'(y) = 0  <=>  2 a p ln2 * y (A + k y) = k
    qa, qb, qc = 2 * a * p * k * LN2, 2 * a * p * A * LN2, -k
    y = (-qb + math.sqrt(qb * qb - 4 * qa * qc)) / (2 * qa)
    return a * p * y * y - math.log2(A + k * y)


def bisect(f, lo, hi, it=200):
    flo = f(lo)
    for _ in range(it):
        mid = (lo + hi) / 2
        if (f(mid) > 0) == (flo > 0):
            lo, flo = mid, f(mid)
        else:
            hi = mid
    return (lo + hi) / 2


def part_A():
    print("=" * 100)
    print("(A) closed-form psi_2 and the constants of Prop 5.3")
    fG1 = lambda p: 1 - math.log2(1.5 + 2 * p) - H(p)
    fstar = lambda p: psi2(p, 1.0) - H(p)
    flim = lambda p: 1 - math.log2(1.5 - p) - H(p)
    grid = [i / 20000 for i in range(1, 5000)]
    for name, f in (("G_1 - H", fG1), ("psi_2(p,1) - H", fstar), ("1 - log(3/2 - p) - H", flim)):
        signs = [f(p) > 0 for p in grid]
        changes = sum(1 for i in range(1, len(signs)) if signs[i] != signs[i - 1])
        root = bisect(f, 0.001, 0.2499)
        print(f"  {name:22s}: sign changes on (0, 1/4): {changes}; root p = {root:.5f}")
    print(f"  {'p':>9} {'psi_2(p,1)':>11} {'H(p)':>8} {'a*(p)':>9}   (notes: 1.01 at 5/64, 2.13 at 3/32, 3.03 at 0.1, 6.0 at 7/64,"
          f" 15.6 at 15/128, 30 at 0.12)")
    for p in (1 / 16, 0.07, 5 / 64, 0.08, 3 / 32, 0.1, 7 / 64, 15 / 128, 0.12, 0.123):
        if psi2(p, 1.0) > H(p):
            a = 1.0
        elif flim(p) <= 0:
            a = math.inf
        else:
            a = bisect(lambda aa: psi2(p, aa) - H(p), 1.0, 1e9)
        print(f"  {p:9.6f} {psi2(p, 1.0):11.5f} {H(p):8.5f} {a:9.3f}")
    # monotonicity in a
    ok = all(psi2(p, a2) >= psi2(p, a1) for p in (0.05, 0.1, 0.12) for a1, a2 in zip(range(1, 200), range(2, 201)))
    print(f"  psi_2 nondecreasing in a on a = 1..200 for p in (0.05, 0.1, 0.12): {ok}")


class Exact:
    def __init__(self, d, m, p_num, p_exp, kappa, deltaS, gmax=40, Imax=None):
        self.d, self.m, self.kappa, self.deltaS = d, m, kappa, deltaS
        self.p = p_num / 2 ** p_exp
        self.s0 = int(round(self.p * 2 ** m))
        M = 2 ** m
        # 2^m H(p) - L_S via Stirling (m >= 12 here; error O(1/s0^3))
        q = self.p
        self.gap = 0.5 * math.log2(2 * math.pi * M * q * (1 - q)) - (1 / (12 * M) - 1 / (12 * self.s0) - 1 / (12 * (M - self.s0))) / LN2
        h, e = p_num, p_exp
        while h % 2 == 0:
            h //= 2
            e -= 1
        Kp = 2 * math.log2(e) if h == 1 else 2 * math.log2(h + 1) + 2 * math.log2(e + 1)
        self.kg = 2 * math.log2(d) + Kp + kappa
        self.L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa
        self.Hp = H(self.p)
        Imax = Imax if Imax is not None else 2 ** (m + 1)
        I = np.arange(0, Imax + 1, dtype=np.float64)
        D = np.full(I.shape, np.inf)
        for g in range(1, gmax + 1):
            rhs = deltaS + I + 1 + 2 * math.log2(m) + 2 * math.log2(self.s0) + g + 2 * math.log2(g) + kappa
            j = np.maximum(np.floor(rhs + 2 * np.log2(rhs + 2 * np.log2(rhs + 3) + 3)) - 3, 0)
            for _ in range(8):  # move down while the predecessor still qualifies, then up while j fails
                down = (j >= 1) & ((j - 1) - 2 * np.log2(j) > rhs)
                j = np.where(down, j - 1, j)
            for _ in range(8):
                up = (j - 2 * np.log2(j + 1)) <= rhs
                j = np.where(up, j + 1, j)
            assert np.all(j - 2 * np.log2(j + 1) > rhs) and np.all((j == 0) | ((j - 1) - 2 * np.log2(j) <= rhs))
            D = np.minimum(D, 2 * np.sqrt(j * LN2 / (2 * self.s0)) + 2.0 ** (1 - g))
        self.I, self.D = I, D
        self.levels = []
        t = 2
        while True:
            self.levels.append(t)
            if self.s(t) + 2 * math.log2(d) >= d and d - self.s(t) - self.L1 <= 0:
                break
            t += 1
        self.hulls = {}

    @staticmethod
    def s(t):
        return 2 * t + 2 * math.log2(t + 1)

    def G(self, j):
        return 1 - math.log2(1 + 2.0 ** -j + 2 * self.p)

    def hull(self, t):
        if t not in self.hulls:
            th = 0.5 + 2.0 ** -t
            F = np.maximum(0.0, -np.log2(self.p + (1 - 2 * self.p) * th + self.p * self.D))
            pts = np.stack([self.I, F], axis=1)
            # lower hull: qhull on the points plus a far point above, keep vertices; then filter lower chain
            hv = ConvexHull(pts).vertices
            V = pts[np.sort(hv)]
            low = []
            for P in V:  # monotone chain on the (few) hull vertices, sorted by I
                while len(low) >= 2 and (low[-1][1] - low[-2][1]) * (P[0] - low[-2][0]) >= (P[1] - low[-2][1]) * (low[-1][0] - low[-2][0]):
                    low.pop()
                low.append(P)
            self.hulls[t] = np.array(low)
        return self.hulls[t]

    def Psi(self, t, c):
        Hh = self.hull(t)
        return float(np.min(c * Hh[:, 0] + Hh[:, 1]))

    def Jg(self, c):
        return c * (self.d + self.kg) + self.Hp

    def Phi2sharp(self, c):
        d, best = self.d, math.inf
        for t in self.levels:
            first = c * max(0.0, d - self.s(t) - self.L1) + self.G(t - 1)
            if first >= best:
                continue
            k = d - min(self.s(t) + 2 * math.log2(d), d) - 2 * math.log2(2 * d) - 4 * self.kappa
            second = k * c + self.Psi(t, c)
            best = min(best, max(first, second))
        return best

    def Phi2(self, c):
        ts = (self.d - self.L1) / 4
        if ts >= 2:
            return min(c * (self.d - 8 - self.L1) + self.G(1), self.G(ts - 1))
        return self.G(1)

    def window(self, cmin, cmax, npts=3000):
        cs = np.geomspace(cmin, cmax, npts)
        ok = [self.Jg(c) < self.Phi2sharp(c) for c in cs]
        ints, start = [], None
        for i, o in enumerate(ok):
            if o and start is None:
                start = i
            if (not o) and start is not None:
                ints.append((start, i - 1))
                start = None
        if start is not None:
            ints.append((start, len(cs) - 1))
        out = []
        f = lambda c: self.Phi2sharp(c) - self.Jg(c)
        for (i0, i1) in ints:
            lo = cs[i0] if i0 == 0 else bisect(f, cs[i0 - 1], cs[i0], it=60)
            hi = cs[i1] if i1 == len(cs) - 1 else bisect(f, cs[i1], cs[i1 + 1], it=60)
            out.append((lo, hi))
        return out


def part_B():
    print("=" * 100)
    print("(B) exact Phi_2^sharp (integer I) at d = 100, m = 20, B = inf: the window {c > 2^-20 : J_g(c) < Phi_2^sharp(c)}")
    print("    notes (t4(B), certified on a grid): 2^-10: (2^-20, 7.88e-3]; 1/16: (2^-20, 2.39e-3]; 5/64: [1.01e-6, 1.46e-3];")
    print("    3/32: [2.10e-6, 8.7e-4]; 7/64: [6.2e-6, 3.0e-4]; 15/128: [2.2e-5, 5.9e-5]; 1/8: none (kappa = 0, delta_S = 0)")
    d, m = 100, 20
    lo = 2.0 ** -m
    for (num, e, name) in ((1, 10, "2^-10"), (1, 4, "1/16"), (5, 6, "5/64"), (3, 5, "3/32"), (7, 6, "7/64"),
                           (15, 7, "15/128"), (1, 3, "1/8")):
        for (kappa, dS) in ((0, 0), (30, 0)):
            X = Exact(d, m, num, e, kappa, dS)
            w = X.window(lo * (1 + 1e-9), 0.05)
            s = "; ".join(f"[{a:.4e} (= {a / lo:.3f} 2^-20), {b:.4e}]" for a, b in w) if w else "none"
            extra = ""
            if name == "2^-10":
                chi = bisect(lambda c: X.Phi2(c) - X.Jg(c), 1e-7, 0.05)
                extra = f"; paper's c_hi = {chi:.4e}"
            print(f"  p={name:>7} kappa={kappa:2d}: {s}{extra}")


def part_C():
    print("=" * 100)
    print("(C) Psi_2(a 2^-m) with exact integer I (d = m), against psi_2(p, a); notes' t4(C) (I-grid of ratio 1.02):")
    print("    p = 1/16, a = 1: 0.3826 0.3954 0.3965 0.3966 0.3966 at m = 12, 16, 20, 28, 40, limit 0.3980")
    for (num, e) in ((1, 4), (3, 5), (7, 6)):
        p = num / 2 ** e
        for a in (1.0, 4.0, 16.0):
            row = []
            for m in (12, 16, 20, 22):
                X = Exact(m, m, num, e, 0, 0, gmax=60, Imax=int(2 ** m / a) + 2)
                row.append(X.Psi(2, a * 2.0 ** -m))
            print(f"    p={p:.5f} a={a:5.1f}: exact Psi_2 at m=12,16,20,22: " + "  ".join(f"{v:.4f}" for v in row)
                  + f"   limit psi_2 = {psi2(p, a):.4f}")


if __name__ == "__main__":
    part_A()
    part_C()
    part_B()
