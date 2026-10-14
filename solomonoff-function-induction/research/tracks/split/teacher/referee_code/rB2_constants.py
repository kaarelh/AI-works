"""rB2: referee B's independent recomputation of the constants quoted in notes.md, written from the
definitions in paper-steeper/sections/teacher.tex (def:teacher:instance, the display before
thm:teacher:main, thm:teacher:main(ii)) without the prover's code. L_S is computed from the exact
integer binomial coefficient.

(A) The running example d = 100, m = 20, p = 2^-10, B = inf, eps = 0: c_hi, Lambda_2, and the
    identification bounds (u, l, I, e) at c = 1e-4 (paper's table) and c = 1.226e-4 (notes' t4 row).
(B) Prop 3.1's table: 2^(d-m), the sharp lower end 2^(d-m) theta_m, N c_hi, Lambda_2 at d = 20 and 100.
    L_S at d = 20, m = 12 (the notes say "L_S = 41 bits").
(C) Prop 2.4 at d = m = 20: b_0', Lambda_2 - b_0' against 4 + 4 log d - 2 log(d+1), and the length
    bounds at lambda = 2 from Lambda_2 (paper: d + 58.2) and from b_0' (notes/kink: d + 45.5).
(D) The ceiling of log2 binomials: the prover's tcommon.log2binom (lgamma) against exact integers.
    For every m in 3..16 and every j the two ceilings are compared.
(E) Prop 2.1(b): g = Lambda_2 / 2^m recomputed from (D2) at l = l0, and the length bound of Lemma 1.1
    against the paper's Delta_l for a grid of c (eps = 0.01).
Deterministic.
"""
import math

LN2 = math.log(2)


def log2_int(x):
    b = x.bit_length()
    if b <= 1000:
        return math.log2(x)
    s = b - 64
    return math.log2(x >> s) + s


def H(q):
    return -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


class Inst:
    def __init__(self, d, m, r, kappa=0.0, deltaS=0.0):
        self.d, self.m, self.r, self.kappa, self.deltaS = d, m, r, kappa, deltaS
        self.p = 2.0 ** -r
        self.s0 = 2 ** (m - r)
        M, s0 = 2 ** m, self.s0
        # 2^m H(p) without cancellation: 2^m H(p) = s0 r + (2^m - s0) log2(2^m / (2^m - s0))
        twoMH = s0 * r + (M - s0) * (math.log1p(s0 / (M - s0)) / LN2)
        self.twoMH = twoMH
        if m <= 26:
            C = math.comb(M, s0)
            self.LS = log2_int(C)
            self.ceilLS = (C - 1).bit_length()
            self.gap = twoMH - self.LS
        else:
            # Stirling's series for the gap 2^m H(p) - log2 C(M, s0) (error O(1/s0^3)); exact binomials are
            # out of reach here
            q = s0 / M
            self.gap = 0.5 * math.log2(2 * math.pi * M * q * (1 - q)) - (1 / (12 * M) - 1 / (12 * s0) - 1 / (12 * (M - s0))) / LN2
            self.LS = twoMH - self.gap
            self.ceilLS = math.ceil(self.LS)
        self.BS = self.LS - deltaS
        self.L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa
        self.kg = 2 * math.log2(d) + 2 * math.log2(r) + kappa
        self.kb = 2 * math.log2(d) + 2 * math.log2(m) + 2 * math.log2(s0) + kappa
        self.Hp = H(self.p)
        self.L2 = self.gap + deltaS + 4 + self.L1 + self.kg
        self.L3 = 4 + 2 * math.log2(d) + kappa

    def G(self, j):
        v = 0.0 if j == math.inf else 2.0 ** -j
        return 1 - math.log2(1 + v + 2 * self.p)

    def Jg(self, c):
        return c * (self.d + self.kg) + self.Hp

    def Phi2(self, c):
        ts = (self.d - self.L1) / 4
        if ts >= 2:
            return min(c * (self.d - 8 - self.L1) + self.G(1), self.G(ts - 1))
        return self.G(1)

    def chi(self):
        ts = (self.d - self.L1) / 4
        if ts >= 2:
            return min((self.G(1) - self.Hp) / (8 + self.L1 + self.kg), (self.G(ts - 1) - self.Hp) / (self.d + self.kg))
        return (self.G(1) - self.Hp) / (self.d + self.kg)

    def chi_bisect(self):
        lo, hi = 0.0, 1.0
        if self.Jg(1e-12) >= self.Phi2(1e-12):
            return None
        for _ in range(200):
            mid = (lo + hi) / 2
            if self.Jg(mid) <= self.Phi2(mid):
                lo = mid
            else:
                hi = mid
        return lo

    def ident(self, c, eps=0.0, gmax=40):
        M = 2 ** self.m
        Jg = self.Jg(c)
        u = max(0.75, 2 ** -(Jg + eps) - self.p)
        Dl = self.kg + eps / c + (self.L2 + eps / c) / (c * M - 1)
        I = Dl + self.L3
        Rb = self.Hp - (c * self.L2 + eps) / (c * M - 1)
        best = math.inf
        for g in range(1, gmax + 1):
            rhs = (self.deltaS + Dl + self.L3 + 1 + 2 * math.log2(self.m) + 2 * math.log2(self.s0) + g
                   + 2 * math.log2(g) + self.kappa)
            j = 0
            while j - 2 * math.log2(j + 1) <= rhs:
                j += 1
            best = min(best, 1 - u + math.sqrt(j * LN2 / (2 * self.s0)) + 2.0 ** -g)
        return dict(u=u, Dl=Dl, I=I, LSmK=self.deltaS + I, e=best, Rb=Rb)


def part_A():
    print("=" * 100)
    print("(A) running example d = 100, m = 20, p = 2^-10, B = inf, eps = 0")
    for kappa in (0, 30):
        for dS in (0, 20):
            T = Inst(100, 20, 10, kappa, dS)
            print(f"  kappa={kappa:2d} delta_S={dS:2d}: L_S={T.LS:.3f}, 2^m H(p) - L_S = {T.gap:.4f}, Lambda_2 = {T.L2:.3f}, "
                  f"c_hi (closed form) = {T.chi():.4e}, (bisection) = {T.chi_bisect():.4e}, 2^-m = {2.0 ** -20:.4e}")
            for c in (1e-4, 1.226e-4):
                r = T.ident(c)
                print(f"      c = {c:.4e}: u >= {r['u']:.4f}, l <= d + {r['Dl']:.2f}, I <= {r['I']:.2f}, "
                      f"L_S - K(S|a,pi) <= {r['LSmK']:.2f}, e <= {r['e']:.4f}, R_B >= {r['Rb']:.5f}")
    print("  paper's table at c = 1e-4: (kappa, delta_S) = (0,0): 0.983, d+20.4, 37.7, 37.7, 0.199; (0,20): 0.983, d+20.6,")
    print("  37.9, 57.9, 0.218; (30,0): 0.981, d+51.0, 98.3, 98.3, 0.274; (30,20): 0.981, d+51.2, 98.5, 118.5, 0.287.")
    print("  notes' t4 row at c = 1.226e-4 (kappa = 0, delta_S = 0): 0.981, d+20.3, 37.6, e <= 0.201.")


def part_B():
    print("=" * 100)
    print("(B) Prop 3.1: the full-table window (2^(d-m), N c_hi), sharp lower end 2^(d-m) theta_m")
    print(f"  {'d':>4} {'m':>4} {'kap':>4} | {'L_S':>10} {'theta_m':>8} {'2^(d-m)':>10} {'sharp':>10} {'N c_hi':>11} {'Lambda_2':>9}")
    for (d, ms) in ((20, (20, 18, 16, 12)), (100, (100, 98, 20, 16, 12))):
        for m in ms:
            for kappa in (0, 30):
                T = Inst(d, m, 10, kappa, 0)
                theta = T.twoMH / (T.ceilLS + T.kb + 4 + T.L1)
                print(f"  {d:4d} {m:4d} {kappa:4d} | {T.LS:10.2f} {theta:8.4f} {2.0 ** (d - m):10.4g} "
                      f"{2.0 ** (d - m) * theta:10.4g} {2.0 ** d * T.chi():11.4g} {T.L2:9.2f}")
    T = Inst(20, 12, 10)
    print(f"  d = 20, m = 12, p = 2^-10: s0 = {T.s0}, L_S = log2 C(4096, 4) = {T.LS:.3f} bits (the notes say 41)")


def part_C():
    print("=" * 100)
    print("(C) Prop 2.4 at d = m = 20, p = 2^-10, B = inf, delta_E = 0")
    for kappa in (0, 30):
        T = Inst(20, 20, 10, kappa, 0)
        d = 20
        b0 = T.gap + 0 + T.kg + 2 * math.log2(d + 1) + kappa
        print(f"  kappa={kappa}: N H(p) - L_E = {T.gap:.3f}, b_0' = {b0:.3f}, Lambda_2 = {T.L2:.3f}, Lambda_2 - b_0' = "
              f"{T.L2 - b0:.4f}, 4 + 4 log d - 2 log(d+1) = {4 + 4 * math.log2(d) - 2 * math.log2(d + 1):.4f}")
        print(f"     lambda = 2: l <= d + kappa_g + Lambda_2 = d + {T.kg + T.L2:.2f};   l <= d + kappa_g + b_0' = d + {T.kg + b0:.2f}")


def part_D():
    print("=" * 100)
    print("(D) ceil(log2 C(2^m, j)): tcommon's lgamma version against the exact integer ceiling")

    def lg_version(n, k):
        return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / LN2

    bad = []
    total = 0
    for m in range(3, 17):
        M = 2 ** m
        for j in range(0, min(M, 2 ** 11) + 1):
            total += 1
            ex = (math.comb(M, j) - 1).bit_length()
            fl = math.ceil(lg_version(M, j))
            if ex != fl:
                bad.append((m, j, fl, ex))
    print(f"  {total} pairs (m, j) with 3 <= m <= 16, j <= min(2^m, 2048); mismatches: {len(bad)}")
    for row in bad[:40]:
        print(f"    m={row[0]:2d} j={row[1]:5d}: lgamma ceiling {row[2]}, exact {row[3]}")
    js = sorted(set(b[1] for b in bad))
    print(f"  the mismatched j values (all m): {js[:30]}{' ...' if len(js) > 30 else ''}")
    # also for C(2^d, j) with d = 10, 14 (named inputs) and the case used in t2/t3
    for (n, ks) in ((2 ** 10, range(0, 1025)), (2 ** 14, range(0, 1025)), (2 ** 12, range(0, 1025))):
        mm = [k for k in ks if (math.comb(n, k) - 1).bit_length() != math.ceil(lg_version(n, k))]
        print(f"  C({n}, j), j <= 1024: mismatches at j = {mm[:20]}{' ...' if len(mm) > 20 else ''}")


def part_E():
    print("=" * 100)
    print("(E) Prop 2.1(b): g from (D2) at l0, and Lemma 1.1's length bound against the paper's Delta_l (eps = 0.01)")
    worst = 0.0
    for (d, m, r) in ((100, 20, 10), (100, 10, 6), (60, 20, 5), (20, 20, 10)):
        for kappa in (0, 30):
            for dS in (0, 20):
                T = Inst(d, m, r, kappa, dS)
                M = 2 ** m
                l0, lM = d + T.kg, d - 4 - T.L1
                # (D2): R_B >= (d + B_S - 4 - Lambda_1 - l)/2^m; its value at l0 is H(p) - g
                g = T.Hp - (d + T.BS - 4 - T.L1 - l0) / M
                worst = max(worst, abs(g * M - T.L2) / T.L2)
                for k in range(1, 40):
                    c = 2.0 ** -m * (1 + 1.3 ** k / 10)
                    eps = 0.01
                    lem = l0 + (g + eps) / (c - 2.0 ** -m) - d
                    pap = T.kg + eps / c + (T.L2 + eps / c) / (c * M - 1)
                    worst = max(worst, abs(lem - pap) / pap)
    print(f"  largest relative difference (g * 2^m vs Lambda_2; Lemma length bound vs Delta_l): {worst:.2e}")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    part_D()
    part_E()
