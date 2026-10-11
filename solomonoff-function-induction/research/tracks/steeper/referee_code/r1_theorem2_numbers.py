"""Referee check r1: independent re-implementation of the constants of notes Thm 2 / Cor 2.5 /
Cor 2.7 / Prop 2.11 / Prop 2.8, written from the notes' text (not from checks/c3).

Differences from c3 on purpose:
  * c_hi is found by bisection on J_g(c) <= M_2(c), not by the closed form, so the closed form
    and the claim "{c : J_g <= M_2} = (0, c_hi]" are tested;
  * L_S is computed by an exact sum of logs (no lgamma);
  * j_g is found by a scan and then checked against the defining inequality;
  * sensitivity to the machine constant kappa AND to the deficiency delta_S is reported
    (c3 fixes delta_S = 0 silently);
  * Prop 2.11(ii) examples are re-evaluated over a kappa grid and a d grid, to see which of the
    "defeats the trick for every lambda" instances survive nonzero machine constants;
  * the Prop 2.8 example is recomputed with the notes' own J_g formula (c5 hard-codes J values).
Deterministic (no randomness).
"""
from math import log2, log, sqrt, ceil, inf


def H(q):
    return 0.0 if q <= 0 or q >= 1 else -(q * log2(q) + (1 - q) * log2(1 - q))


def log2_binom_exact(n, k):
    k = min(k, n - k)
    return sum(log2(n - i) - log2(i + 1) for i in range(k))


class Thm2:
    def __init__(self, d, m, r, B=inf, kappa=0.0, deltaS=0.0):
        self.d, self.m, self.r, self.B, self.kap, self.dS = d, m, r, B, kappa, deltaS
        self.p = 2.0 ** -r
        self.s0 = 2 ** (m - r)
        self.LS = log2_binom_exact(2 ** m, self.s0)
        self.BS = self.LS - deltaS
        self.tauB = 0.0 if B == inf else 2.0 ** (1 - B)
        self.betaB = 0.0 if B == inf else 2 ** m * log2(1 + self.tauB)
        self.Lam1 = 2 * log2(d) + 2 * log2(m) + (2 * log2(B) if B < inf else 0.0) + self.betaB + kappa
        self.kg = 2 * log2(d) + 2 * log2(r) + kappa
        self.kb = 2 * log2(d) + 2 * log2(m) + 2 * log2(self.s0) + kappa if self.s0 > 1 else 2 * log2(d) + 2 * log2(m) + kappa
        self.Hp = H(self.p)
        self.tstar = (d - self.Lam1) / 4.0

    def G(self, j):
        return 1 - log2(1 + 2.0 ** (-j) + 2 * self.p + self.tauB)

    def M2(self, c):
        if self.tstar >= 2:
            return min(c * (self.d - 8 - self.Lam1) + self.G(1), self.G(self.tstar - 1))
        return self.G(1)

    def Jg(self, c):
        return c * (self.d + self.kg) + self.Hp

    def Jb(self, c):
        return c * (self.d + ceil(self.LS) + self.kb)

    def c_hi_closed(self):
        if self.tstar >= 2:
            return min((self.G(1) - self.Hp) / (8 + self.Lam1 + self.kg),
                       (self.G(self.tstar - 1) - self.Hp) / (self.d + self.kg))
        return (self.G(1) - self.Hp) / (self.d + self.kg)

    def c_hi_bisect(self):
        f = lambda c: self.Jg(c) - self.M2(c)
        if f(1e-15) > 0:
            return float('nan')
        lo, hi = 1e-15, 10.0
        for _ in range(300):
            mid = (lo + hi) / 2
            if f(mid) <= 0:
                lo = mid
            else:
                hi = mid
        return lo

    def ident(self, c, eta, g=7):
        m, s0 = self.m, self.s0
        Lam2 = 2 ** m * self.Hp - self.BS + 4 + self.Lam1 + self.kg
        Lam3 = 4 + 2 * log2(self.d) + self.kap
        Dl = self.kg + eta / c + (Lam2 + eta / c) / (c * 2 ** m - 1)
        u_lo = 2 ** (-(self.Jg(c) + eta)) - self.p - (0 if self.B == inf else 2.0 ** -self.B)
        Rgap = (c * Lam2 + eta) / (c * 2 ** m - 1)
        Gam = self.dS + Dl + Lam3 + 1 + 2 * log2(m) + 2 * log2(s0 if s0 > 1 else 1) + g + 2 * log2(g) + self.kap
        j = 0
        while not (j - 2 * log2(j + 1) > Gam):
            j += 1
        assert j - 2 * log2(j + 1) > Gam and all(not (jj - 2 * log2(jj + 1) > Gam) for jj in range(j))
        gam = sqrt(j * log(2) / (2 * s0))
        e_hi = 1 - u_lo + gam + 2.0 ** -g
        # "information" bound: B_S - K(S|a,pi) <= Dl + Lam3; relative to log C(2^m,s0) add delta_S
        return dict(u=u_lo, Rgap=Rgap, Dl=Dl, info_vs_BS=Dl + Lam3, info_vs_LS=Dl + Lam3 + self.dS,
                    e=e_hi, gam=gam, j=j, margin=self.M2(c) - self.Jg(c))


print("=" * 78)
print("[A] window: closed-form c_hi vs bisection on J_g <= M_2 (should agree)")
for (d, m, r) in [(20, 20, 10), (100, 20, 10), (100, 24, 10), (1000, 20, 10), (100, 10, 10), (100, 8, 8)]:
    for kap in [0.0, 30.0]:
        T = Thm2(d, m, r, kappa=kap)
        a, b = T.c_hi_closed(), T.c_hi_bisect()
        full = f"; full table lambda <= {a * 2 ** d:.4g}" if m == d else ""
        print(f"  d={d:4d} m={m:2d} r={r:2d} kappa={kap:4.0f}: L_S={T.LS:9.1f} c_hi closed={a:.4e} "
              f"bisect={b:.4e} rel.diff={abs(a - b) / a:.1e}; 2^-m={2.0 ** -m:.3e}; nonempty={2.0 ** -m < a}{full}")

print("=" * 78)
print("[B] G_1 = H(p) crossover (B = inf), by bisection")
lo, hi = 1e-6, 0.3
for _ in range(200):
    mid = (lo + hi) / 2
    if 1 - log2(1.5 + 2 * mid) > H(mid):
        lo = mid
    else:
        hi = mid
print(f"  crossover p = {lo:.5f}")

print("=" * 78)
print("[C] identification bounds (Thm 2(ii)); kappa and delta_S sensitivity; B = inf")
for (d, m, r, c) in [(20, 20, 10, 2 * 2.0 ** -20), (20, 20, 10, 1e-4), (100, 20, 10, 1e-5), (100, 20, 10, 1e-4),
                     (100, 20, 10, 1e-3), (100, 24, 10, 1e-5)]:
    for kap in [0.0, 30.0]:
        for dS in [0.0, 20.0]:
            T = Thm2(d, m, r, kappa=kap, deltaS=dS)
            if not (c * 2 ** m > 1 and c <= T.c_hi_closed()):
                print(f"  d={d} m={m} c={c:.2e} kappa={kap} dS={dS}: outside window")
                continue
            o = T.ident(c, 0.0)
            print(f"  d={d:3d} m={m} c={c:.2e} kappa={kap:3.0f} dS={dS:3.0f}: u>={o['u']:.4f} len<=d+{o['Dl']:.1f} "
                  f"info(vs B_S)<={o['info_vs_BS']:.1f} info(vs L_S)<={o['info_vs_LS']:.1f} e<={o['e']:.3f} "
                  f"(j={o['j']}, gamma={o['gam']:.3f}) R>=H-{o['Rgap']:.2e}")

print("=" * 78)
print("[D] Prop 2.11(ii) instances ('defeats the trick for every lambda, over all hypotheses'):")
print("    condition H/(ceil L_S + kb + 4 + Lam1) >= (1-H)/(d - 4 - Lam1 - kappa)")
for (m, r) in [(3, 3), (6, 6)]:
    for d in [100, 300, 1000, 3000, 10000]:
        row = []
        for kap in [0, 10, 20, 30, 50]:
            T = Thm2(d, m, r, kappa=float(kap))
            denom = d - 4 - T.Lam1 - kap
            ok = denom > 0 and T.Hp / (ceil(T.LS) + T.kb + 4 + T.Lam1) >= (1 - T.Hp) / denom
            row.append(f"k={kap}:{'Y' if ok else 'n'}")
        print(f"  m={m} p=2^-{r} d={d:5d}: " + " ".join(row))

print("=" * 78)
print("[E] Prop 2.11(i) three-hypothesis examples use the upper bounds as exact lengths; margin size")
for (m, r) in [(6, 6), (7, 7), (8, 8)]:
    T = Thm2(100, m, r)
    lb = T.d + ceil(T.LS) + T.kb
    lg = T.d + T.kg
    rE = T.Hp / (lb - lg)
    rM = (1 - T.Hp) / lg
    # how much may the true length difference l_b - l_g shrink (or l_g grow) before the verdict flips?
    slack_bits = T.Hp / rM - (lb - lg)   # verdict 'never selected' iff l_b - l_g <= H/rM
    print(f"  m={m} d=100: rE={rE:.4e} rM={rM:.4e} verdict={'never selected' if rE >= rM else 'window exists'}; "
          f"verdict flips if l_b - l_g changes by {slack_bits:+.2f} bits")

print("=" * 78)
print("[F] Prop 2.8 example: exponent -N*eta + (J_g + eta)/c with the notes' J_g formula")
for (d, m, r, c, eta, N) in [(100, 20, 10, 1e-4, 1e-3, 10 ** 6), (100, 20, 10, 1e-3, 1e-3, 10 ** 6),
                             (100, 20, 10, 1e-5, 1e-4, 10 ** 7)]:
    for kap in [0.0, 30.0]:
        T = Thm2(d, m, r, kappa=kap)
        Jg = T.Jg(c)
        print(f"  c={c:.0e} eta={eta:.0e} N={N:.0e} kappa={kap:3.0f}: J_g={Jg:.4f}; log2 bound = {-N * eta + (Jg + eta) / c:.0f}")

print("=" * 78)
print("[G] Hanni's version-2 numbers (c1) recomputed: rates, window, lambda=1 switch")
p = 2.0 ** -10
for kf in [0, 10]:
    rm = (1 - H(p)) / (100 + kf)
    re = H(p) / (10000 - kf)
    print(f"  flip cost {kf}: window ({re:.4e}, {rm:.4e}), ratio {rm / re:.0f}, switch N = {(10000 - kf) / H(p):.4e}")
print(f"  H(2^-10)={H(p):.5f}, p log(1/p)={p * 10:.5f}, relative shortfall {(H(p) - 10 * p) / H(p):.3f}")
print(f"  L_S(m=20, s0=1024) exact = {log2_binom_exact(2 ** 20, 1024):.2f}")

print("=" * 78)
print("[H] Is Hanni's VERSION 1 (100-bit model, 100-bit error model, rates 100 vs 10 in total bits)")
print("    realisable in the junta family? Full table m < d: error rate ~ 2^(d-m) per bit, model rate ~ 2^d/d.")
for (d, m, r) in [(13, 10, 6), (14, 10, 6), (13, 9, 5)]:
    for kap in [0.0, 10.0, 30.0]:
        T = Thm2(d, m, r, kappa=kap)
        ch = T.c_hi_closed()
        n = 2 ** d
        print(f"  d={d} m={m} p=2^-{r}: L_S={T.LS:.1f} bits, total model saving n(1-H)={n * (1 - T.Hp):.0f}, "
              f"error saving nH={n * T.Hp:.0f}; kappa={kap:3.0f}: lambda-window (n 2^-m, n c_hi] = "
              f"({n * 2.0 ** -m:.2f}, {n * ch:.2f}] -> {'nonempty' if 2.0 ** -m < ch else 'EMPTY'}")
print("  identification bounds for the version-1 instance d=13, m=10, p=2^-6 (full table, eta = 0):")
for lam in [12.0, 20.0, 40.0, 80.0]:
    for kap in [0.0, 30.0]:
        T = Thm2(13, 10, 6, kappa=kap)
        c = lam / 2 ** 13
        if not (c * 2 ** 10 > 1 and c <= T.c_hi_closed()):
            print(f"    lambda={lam} kappa={kap}: outside window"); continue
        o = T.ident(c, 0.0)
        print(f"    lambda={lam:5.1f} kappa={kap:3.0f}: u>={o['u']:.3f} len<=d+{o['Dl']:.1f} info<={o['info_vs_BS']:.1f} "
              f"of L_S={T.LS:.0f}; e<={o['e']:.3f}; Delta(c)*n={(c*(4+T.Lam1+T.kg)+T.Hp-T.BS/2**10)*2**13:.0f} bits")
