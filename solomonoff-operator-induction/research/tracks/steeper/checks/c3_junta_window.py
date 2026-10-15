"""c3: the explicit window and identification bounds of notes Theorem 3 (parity simple model,
random junta error set), evaluated numerically; plus sanity checks of the elementary inequalities
used in its proof, the memoriser regime, the cheap-error (rate-blindness) example, the finite-sample
transfer (Lemma E) and a small exact illustration.

All machine-dependent additive constants are collected in one symbol kappa (default 0, 'for
illustration'), with a sensitivity run at kappa = 30.  Formulas are exactly those of the notes.
Seeded: numpy default_rng(3).
Revision 2026-10-11: log2binom uses exact integers (referee minor 2).
"""
from math import log2, log, sqrt, lgamma, ceil, inf, comb
import numpy as np
rng = np.random.default_rng(3)

def H(q): return 0.0 if q in (0, 1) else -(q*log2(q)+(1-q)*log2(1-q))
def log2binom(n, k):
    # Revision (referee minor 2): exact integer binomial, so that ceil(L_S) is exact when L_S is an
    # integer (e.g. |S| = 1 gives L_S = m).  The earlier lgamma version gave m + 1e-14 and ceil = m + 1.
    n, k = int(round(n)), int(round(k))
    approx = (lgamma(n+1)-lgamma(k+1)-lgamma(n-k+1))/log(2)
    if approx < 4e5: return log2(comb(n, k))   # exact when the integer is affordable
    return approx                              # huge values: never integers here, float is fine
def s_(t): return 2*t + 2*log2(t+1)

class Inst:
    def __init__(self, d, m, p, B=inf, kappa=0.0, deltaS=0.0):
        self.d, self.m, self.p, self.B, self.kappa, self.dS = d, m, p, B, kappa, deltaS
        self.s0 = int(round(p * 2**m)); assert abs(self.s0 - p*2**m) < 1e-9
        self.LS = log2binom(2**m, self.s0); self.BS = self.LS - deltaS
        tB = 0.0 if B == inf else 2.0**(1-B)
        self.tB = tB
        self.betaB = 0.0 if B == inf else 2**m * log2(1 + tB)
        self.Lam1 = 2*log2(d) + 2*log2(m) + (0 if B == inf else 2*log2(B)) + self.betaB + kappa
        r = log2(1/p)
        self.kg = 2*log2(d) + 2*log2(r) + kappa                      # good model overhead
        self.kb = 2*log2(d) + 2*log2(m) + 2*log2(self.s0) + kappa    # memoriser overhead
        self.k0 = kappa                                              # coin
        self.Hp = H(p)
        self.tstar = (d - self.Lam1)/4
    def G(self, j): return 1 - log2(1 + 2.0**(-j) + 2*self.p + self.tB)
    def M1(self, c): return c*(self.d - 4 - self.Lam1) + self.BS/2**self.m
    def M2(self, c):
        if self.tstar < 2: return self.G(1)
        return min(c*(self.d - 8 - self.Lam1) + self.G(1), self.G(self.tstar - 1))
    def Jg(self, c): return c*(self.d + self.kg) + self.Hp
    def Jb(self, c): return c*(self.d + ceil(self.LS) + self.kb)
    def chi(self):
        # largest c with J_g(c) <= M2(c)
        G1 = self.G(1)
        if self.tstar < 2: return (G1 - self.Hp)/(self.d + self.kg)
        return min((G1 - self.Hp)/(8 + self.Lam1 + self.kg), (self.G(self.tstar - 1) - self.Hp)/(self.d + self.kg))
    def Delta(self, c): return c*(4 + self.Lam1 + self.kg) + self.Hp - self.BS/2**self.m
    def ident(self, c, eta, g=7):
        m, s0 = self.m, self.s0
        Lam2 = 2**m*self.Hp - self.BS + 4 + self.Lam1 + self.kg
        u_lo = 2**-(self.Jg(c) + eta) - self.p - (0 if self.B == inf else 2.0**-self.B)
        R_lo = self.Hp - (c*Lam2 + eta)/(c*2**m - 1)
        Dl = self.kg + eta/c + (Lam2 + eta/c)/(c*2**m - 1)
        Lam3 = 4 + 2*log2(self.d) + self.kappa
        Gam = self.dS + Dl + Lam3 + 1 + 2*log2(m) + 2*log2(s0) + g + 2*log2(g) + self.kappa
        j0 = 0
        while not (j0 - 2*log2(j0+1) > Gam): j0 += 1
        gam = sqrt(j0*log(2)/(2*s0))
        e_hi = 1 - u_lo + gam + 2.0**-g
        margin = self.M2(c) - self.Jg(c)        # W4 requires eta < margin
        return dict(u_lo=u_lo, R_lo=R_lo, Dl=Dl, info=Dl+Lam3, gam=gam, e_hi=e_hi, margin=margin)

print("=" * 78)
print("[sanity] elementary inequalities used in the proofs")
print("  s(t) <= 4t for t=1..10^5:", all(s_(t) <= 4*t for t in range(1, 100001)))
ok = True
for m in range(4, 27):
    for r in range(2, min(m, 12)):
        p = 2.0**-r; n = 2**m; k = int(p*n)
        ok &= log2binom(n, k) >= n*H(p) - log2(n+1) - 1e-9
print("  L_S >= 2^m H(p) - log2(2^m+1) on a grid:", ok)
xs = np.linspace(1e-9, 10, 100001)
print("  log2(1+x) <= x/ln2 on [0,10]:", bool(np.all(np.log2(1+xs) <= xs/np.log(2) + 1e-15)))
# concavity of G and the reduction min_{t>=2} phi(t) >= min(phi(2), G_{t*-1}), with s(t) (not 4t)
viol = tests = 0
for _ in range(3000):
    d = int(rng.integers(30, 400)); m = int(rng.integers(6, min(d, 26)+1)); r = int(rng.integers(3, m))
    inst = Inst(d, m, 2.0**-r, B=[inf, float(m+10)][int(rng.integers(0, 2))], kappa=float(rng.uniform(0, 40)))
    if inst.tstar < 2: continue
    c = 10**rng.uniform(-7, -1); tests += 1
    lhs = min(max(0.0, c*(d - s_(t) - inst.Lam1)) + inst.G(t-1) for t in range(2, 4*d+8))
    lhs = min(lhs, inst.G(80))   # level infinity (G_infinity ~ G_80)
    if lhs < inst.M2(c) - 1e-12: viol += 1
print(f"  min over integer t>=2 of c(d-s(t)-Lam1)^+ + G_(t-1) >= M2(c): {viol} violations in {tests} random instances")
# Hoeffding without replacement, sanity: population values in [0,1], subsets of size s0
pop = rng.uniform(0, 1, 2**10)**3; s0 = 16; gam = 0.15; mu = pop.mean()
hits = sum((pop[rng.choice(len(pop), s0, replace=False)].mean() - mu) >= gam for _ in range(200000))
print(f"  Hoeffding w/o replacement: empirical P[avg - mean >= {gam}] = {hits/200000:.2e} <= exp(-2 s0 gam^2) = {np.exp(-2*s0*gam**2):.2e}")

lo_, hi_ = 1e-6, 0.25
for _ in range(200):
    mid = (lo_ + hi_)/2
    if 1 - log2(1.5 + 2*mid) > H(mid): lo_ = mid
    else: hi_ = mid
print(f"  G_1 = 1 - log2(3/2 + 2p) exceeds H(p) iff p < {lo_:.4f} (B = inf); the window method needs G_1 > H(p)")

print("=" * 78)
print("[window] c in (2^-m, c_hi]; lambda = cN.  (kappa = machine constant)")
cases = [(20, 20, 2.0**-10), (100, 20, 2.0**-10), (100, 24, 2.0**-10), (1000, 20, 2.0**-10)]
for kappa in [0.0, 30.0]:
    for (d, m, p) in cases:
        inst = Inst(d, m, p, B=inf, kappa=kappa)
        clo, chi_ = 2.0**-m, inst.chi()
        print(f"  kappa={kappa:4.0f} d={d:4d} m={m} p=2^-10: L_S={inst.LS:.0f}, Lam1={inst.Lam1:.1f}, "
              f"window c in ({clo:.3e}, {chi_:.3e}]  (ratio {chi_/clo:.0f}); G1={inst.G(1):.4f}, "
              f"G(t*-1)={inst.G(inst.tstar-1):.4f}")
        if m == d:
            print(f"      full table (N = 2^d): lambda in (1, {chi_*2**d:.4g}]")

print("=" * 78)
print("[identification] bounds for eta-near-optimal hypotheses (B = inf, kappa as stated)")
for kappa in [0.0, 30.0]:
    for (d, m, p, cs, etas) in [(20, 20, 2.0**-10, [2*2.0**-20, 1e-5, 1e-4, 1e-3], [0.0]),
                                (100, 20, 2.0**-10, [1e-5, 1e-4, 1e-3], [0.0, 1e-4*1e-1, 1e-3]),
                                (100, 24, 2.0**-10, [1e-6, 1e-5, 1e-4], [0.0, 1e-6])]:
        inst = Inst(d, m, p, kappa=kappa)
        for c in cs:
            if not (c*2**m > 1 and c <= inst.chi()): continue
            for eta in etas:
                r = inst.ident(c, eta)
                lam_full = f", lambda={c*2**d:.3g}" if m == d else ""
                print(f"  kappa={kappa:3.0f} d={d} m={m} c={c:.2e}{lam_full} eta={eta:.0e}: "
                      f"Delta(c)={inst.Delta(c):.2e}; u>={r['u_lo']:.4f}; R>=H(p)-{inst.Hp-r['R_lo']:.2e}; "
                      f"len<=d+{r['Dl']:.1f}; info(S)<={r['info']:.1f} of L_S={inst.LS:.0f}; "
                      f"e<={r['e_hi']:.3f} (gamma={r['gam']:.3f}); W4 margin {r['margin']:.3f}")

print("=" * 78)
print("[memoriser regime] c < 2^-m: eta-near-optimal (vs the memoriser) level-1 hypotheses")
for (d, m, p, c, eta) in [(100, 20, 2.0**-10, 2.0**-22, 0.0), (100, 20, 2.0**-10, 1e-7, 1e-8),
                          (100, 3, 1/8, 1e-3, 1e-4), (100, 3, 1/8, 4e-3, 1e-4)]:
    inst = Inst(d, m, p)
    num = c*(ceil(inst.LS) - inst.LS + inst.dS + 4 + inst.Lam1 + inst.kb) + eta
    RB_hi = num/(1 - c*2**m)
    cond_level = inst.M2(c) > inst.Jb(c) + eta
    cond_R = RB_hi < inst.BS/2**m
    e_lo = 2**(-RB_hi/p)
    print(f"  d={d} m={m} p={p:.4g} c={c:.2e}: level>=2 excluded: {cond_level}; R_B <= {RB_hi:.3e} "
          f"(valid: {cond_R}); error-label prob e >= {e_lo:.3f}")

print("=" * 78)
print("[rate blindness] cheap error juntas, d=100: three-hypothesis comparison (good vs memoriser vs coin)")
for (m, p) in [(3, 1/8), (6, 2.0**-6), (7, 2.0**-7), (8, 2.0**-8), (20, 2.0**-10)]:
    inst = Inst(100, m, p)
    rE = inst.Hp/(ceil(inst.LS) + inst.kb - inst.kg)          # memoriser beats good iff c < rE
    rM = (1 - inst.Hp)/(inst.d + inst.kg - inst.k0)          # coin beats-or-ties good iff c >= rM
    print(f"  m={m:2d} p={p:.4g}: memoriser beats good for c < {rE:.4e}; coin beats good for c >= {rM:.4e}; "
          f"good model never selected: {rE >= rM}")
print("  all-hypothesis version (Prop 2.11(ii)): a level-1 hypothesis with R >= H(p) is beaten at every c iff "
      "H(p)/(ceil(L_S)+kb+4+Lam1) >= (1-H(p))/(d-4-Lam1-k0):")
for kappa in [0.0, 30.0]:
    for (d, m, p) in [(100, 3, 1/8), (100, 6, 2.0**-6), (1000, 3, 1/8), (1000, 6, 2.0**-6), (10**4, 6, 2.0**-6)]:
        inst = Inst(d, m, p, kappa=kappa)
        lhs = inst.Hp/(ceil(inst.LS) + inst.kb + 4 + inst.Lam1); rhs = (1 - inst.Hp)/(d - 4 - inst.Lam1 - inst.k0)
        print(f"    kappa={kappa:3.0f} d={d:5d} m={m} p={p:.4g}: {lhs:.4e} vs {rhs:.4e} -> never selected: {lhs >= rhs}")
for (d, m, p) in [(100, 20, 2.0**-10), (100, 10, 2.0**-10), (100, 8, 2.0**-8), (100, 7, 2.0**-7),
                  (100, 6, 2.0**-6), (100, 5, 2.0**-5)]:
    inst = Inst(d, m, p)
    print(f"  d={d} m={m} p=2^{log2(p):.0f}: 2^-m={2.0**-m:.3e} vs c_hi={inst.chi():.3e} -> window "
          f"{'nonempty' if 2.0**-m < inst.chi() else 'EMPTY'}")

print("  single-prefix error rules (|S| = 1, p = 2^-m): memoriser regime holds below 2^-m; e.g.")
for (d, m) in [(100, 6), (100, 7)]:
    inst = Inst(d, m, 2.0**-m)
    for c in [1e-4, 1e-3, 4e-3]:
        num = c*(ceil(inst.LS) - inst.LS + 4 + inst.Lam1 + inst.kb)
        RB_hi = num/(1 - c*2**m)
        print(f"    d={d} m={m} c={c:.0e}: level>=2 excluded: {inst.M2(c) > inst.Jb(c)}; "
              f"R_B<= {RB_hi:.2e} (valid {RB_hi < inst.BS/2**m}); e >= {2**(-RB_hi/inst.p):.3f}")

print("=" * 78)
print("[finite sample, Lemma E] d=100, m=20, p=2^-10, B=30, delta=0.01: eta = eps_N")
inst = Inst(100, 20, 2.0**-10, B=30.0)
dl = 0.01
for c in [1e-5, 1e-4, 1e-3]:
    for N in [1e9, 1e11, 1e13, 1e15]:
        e1 = log2(1/inst.p)*sqrt(log(2/dl)/(2*N))
        Lhat = (inst.Jg(c) + e1)/c
        eps = e1 + inst.B*sqrt((Lhat*log(2) + log(2/dl))/(2*N))
        r = inst.ident(c, eps)
        print(f"  c={c:.0e} N={N:.0e}: eps_N={eps:.2e} (eps/c={eps/c:.1f} bits); u>={r['u_lo']:.4f}; "
              f"len<=d+{r['Dl']:.1f}; e<={r['e_hi']:.3f}; W4 margin ok: {eps < r['margin']}")
print("  lambda = 1 (c = 1/N), comparator = memoriser, eps_1 = 0: error-label prob of the MAP")
for N in [1e9, 1e11, 1e13, 1e15]:
    c = 1/N; Jb = inst.Jb(c)
    RB = Jb + inst.B*sqrt(((inst.d + ceil(inst.LS) + inst.kb)*log(2) + log(2/dl))/(2*N))
    print(f"  N={N:.0e}: R_B(MAP) <= {RB:.2e}; e(MAP) >= {max(0.0, 2**(-RB/inst.p) - 2.0**-inst.B):.3f}")

print("=" * 78)
print("[illustration] exact small instance d=m=8, |E|=8 (p=1/32): structured product families")
d = 8; n = 2**d; p = 1/32; mE = int(p*n)
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)], dtype=np.int64)
a = rng.integers(0, 2, d); fa = (X @ a) % 2
E = rng.choice(n, mE, replace=False); e = np.zeros(n, int); e[E] = 1; ystar = (fa + e) % 2
pts = [(0.0, 1.0, "coin")]
for u_ in range(d + 1):            # product list mixtures (know d-u bits of a), noise p
    free = list(range(d - u_, d)); L = []
    for t in range(2**u_):
        b = a.copy()
        for k, i in enumerate(free): b[i] = (t >> k) & 1
        L.append((X @ b) % 2)
    q = (np.array(L) == ystar).mean(axis=0); hp = (1-p)*q + p*(1-q)
    pts.append((float(d - u_ + 2*log2(d)), float(-np.mean(np.log2(hp))), f"list u={u_}"))
for j in range(1, mE + 1):         # good model + memorise j of the error points (rest: noise rate)
    rest = (mE - j)/(n - j)
    ll = (n - j)*H(rest) if rest > 0 else 0.0
    pts.append((d + 2*log2(d) + log2binom(n, j) + 2*log2(j+1), ll/n, f"good+{j} errs"))
good = [P for P in pts if P[2] == "list u=0"][0]; bad = [P for P in pts if P[2] == f"good+{mE} errs"][0]
print(f"  good: {good[0]:.1f} bits + n R = {n*good[1]:.1f}; full memoriser: {bad[0]:.1f} bits; "
      f"good-vs-memoriser switch at lambda = {n*good[1]/(bad[0]-good[0]):.3f}")
for lam in [0.5, 0.9, 1.0, 1.02, 1.5, 4.0, 20.0, 40.0]:
    c = lam/n; best = min(pts, key=lambda P: c*P[0] + P[1])
    print(f"  lambda={lam:5}: selected {best[2]:12s} (bits={best[0]:.1f}, risk={best[1]:.4f})")
