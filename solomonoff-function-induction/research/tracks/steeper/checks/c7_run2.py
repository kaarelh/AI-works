"""c7: checks for the second revision of the steeper track (referee.md of 2026-10-12).

Parts (each prints its own header):
  (A) Lemma 3.2' (fill-ins from stored stream prefixes, any computable sampler): the certification
      rule, its consistency, the bound Pr[certified label y within depth i] >= nu(y|x) - 3*2^-i under
      adversarial approximations, the end-to-end bound Pr_w[phi_w extends D] >= nu(D)/2 at
      i_D = ceil(log2(6N/beta_D)), the pairing/length facts, and the cost table.
  (B) Prop 2.17 (error envelopes): the all-hypothesis threshold c_env, the reproduction bound on the
      cheap error region, the three-hypothesis illustration, and exact small-instance checks of the
      complement coding identity (Lemma 2.3 on the complement) and of min_x[x + c(B - 2^m x)^+].
  (C) Lemma 2.2c (T5 Lemma 2.5c for semimeasures): exact identity and inequality on random
      semimeasure hypotheses; floors; the crossover of the level-2 floor; Prop 3.8(iv) instances
      (product sophistication ~ d for p < 1/4).
  (D) Theorem 2(iii) near 2^-m: where the memoriser-regime conclusion applies.
  (E) Prop 2.13 from the explicit teacher model.
  (F) Prop 2.8's consequence with eta' (explicit).
  (G) Prop 2.9(b') for schedules lambda_N (1, sqrt N, N^0.9, cN).

Seeded: numpy default_rng(7) and random.Random(7).  Exact rational arithmetic where stated.
"""
from fractions import Fraction as Fr
from math import log2, log, sqrt, ceil, floor, inf, lgamma, comb
import random
import numpy as np

rng = np.random.default_rng(7)
R7 = random.Random(7)

def H(q): return 0.0 if q <= 0 or q >= 1 else -(q*log2(q) + (1-q)*log2(1-q))
def log2binom(n, k):
    n, k = int(n), int(k)
    approx = (lgamma(n+1) - lgamma(k+1) - lgamma(n-k+1))/log(2)
    if approx < 4e5: return log2(comb(n, k))
    return approx
def s_(t): return 2*t + 2*log2(t+1)

# ---------------------------------------------------------------------------------------------
# Theorem 2 constants (same formulas as checks/c3, B = inf unless stated)
class Inst:
    def __init__(self, d, m, p, kappa=0.0, deltaS=0.0, B=inf):
        self.d, self.m, self.p, self.kappa, self.dS, self.B = d, m, p, kappa, deltaS, B
        self.s0 = int(round(p*2**m)); assert abs(self.s0 - p*2**m) < 1e-9
        self.LS = log2binom(2**m, self.s0); self.BS = self.LS - deltaS
        self.tB = 0.0 if B == inf else 2.0**(1-B)
        self.betaB = 0.0 if B == inf else 2**m*log2(1 + self.tB)
        self.Lam1 = 2*log2(d) + 2*log2(m) + (0 if B == inf else 2*log2(B)) + self.betaB + kappa
        r = log2(1/p)
        self.kg = 2*log2(d) + 2*log2(r) + kappa
        self.kb = 2*log2(d) + 2*log2(m) + 2*log2(self.s0) + kappa
        self.Hp = H(p); self.tstar = (d - self.Lam1)/4
    def G(self, j): return 1 - log2(1 + 2.0**(-j) + 2*self.p + self.tB)
    def M2(self, c):
        if self.tstar < 2: return self.G(1)
        return min(c*(self.d - 8 - self.Lam1) + self.G(1), self.G(self.tstar - 1))
    def Jg(self, c): return c*(self.d + self.kg) + self.Hp
    def Jb(self, c): return c*(self.d + ceil(self.LS) + self.kb)
    def chi(self):
        G1 = self.G(1)
        if self.tstar < 2: return (G1 - self.Hp)/(self.d + self.kg)
        return min((G1 - self.Hp)/(8 + self.Lam1 + self.kg), (self.G(self.tstar-1) - self.Hp)/(self.d + self.kg))

def jmin(Gam):
    j = 0
    while not (j - 2*log2(j+1) > Gam): j += 1
    return j

# =============================================================================================
print("=" * 78)
print("(A) Lemma 3.2': fill-ins from stored private-stream prefixes, any computable sampler")

def certified_measure(F, q_by_depth, imax):
    """F: exact cumulative Fractions F_0=0..F_K=1.  q_by_depth[i][h]: approximation of F_h used at
    depth i (|q - F| <= 2^-i-2; q_0 = 0 and q_K = 1 exact).  Returns (per-label certified measure
    within depth imax, consistency flag).  Certification at depth i of the dyadic interval
    I = [k 2^-i, (k+1) 2^-i) for label h:  q_{h-1} + 2^-i-2 <= left(I) and right(I) <= q_h - 2^-i-2."""
    K = len(F) - 1
    lab = {}                     # depth-imax string index -> label certified along its path
    ok = True
    for i in range(1, imax+1):
        q = q_by_depth[i]; tol = Fr(1, 2**(i+2))
        for k in range(2**i):
            left, right = Fr(k, 2**i), Fr(k+1, 2**i)
            hs = [h for h in range(1, K+1) if q[h-1] + tol <= left and right <= q[h] - tol]
            if len(hs) > 1: ok = False
            if not hs: continue
            h = hs[0]
            # all depth-imax descendants of this interval
            span = 2**(imax - i)
            for kk in range(k*span, (k+1)*span):
                if kk in lab and lab[kk] != h: ok = False
                lab[kk] = h
    meas = [Fr(0)]*(K+1)
    for kk, h in lab.items(): meas[h] += Fr(1, 2**imax)
    return meas, ok

def rand_dist(K):
    den = R7.choice([3, 5, 7, 12, 1000, 1024, 999])
    cuts = sorted(R7.randint(0, den) for _ in range(K-1))
    vals = [Fr(b - a, den) for a, b in zip([0] + cuts, cuts + [den])]
    return vals

def approx(F, i, mode):
    K = len(F) - 1; tol = Fr(1, 2**(i+2)); q = [Fr(0)]*(K+1); q[K] = Fr(1)
    for h in range(1, K):
        if mode == "exact": q[h] = F[h]
        elif mode == "rand": q[h] = F[h] + tol*R7.choice([-1, 0, 1])
        elif mode == "down": q[h] = F[h] - tol
        else: q[h] = F[h] + tol
    return q

viol = cons_bad = tests = 0
worst = 1.0
for trial in range(600):
    K = R7.choice([2, 2, 3, 4])
    vals = rand_dist(K) if trial % 5 else [Fr(1, 3), Fr(2, 3)][:K] + ([] if K == 2 else [Fr(0)]*(K-2))
    if sum(vals) != 1: vals = [Fr(1, 3), Fr(2, 3)]; K = 2
    F = [Fr(0)]
    for v in vals: F.append(F[-1] + v)
    imax = R7.randint(1, 9)
    mode = R7.choice(["exact", "rand", "down", "up"])
    qd = {i: approx(F, i, mode) for i in range(1, imax+1)}
    meas, ok = certified_measure(F, qd, imax)
    cons_bad += (not ok)
    for h in range(1, K+1):
        tests += 1
        slack = meas[h] - (vals[h-1] - 3*Fr(1, 2**imax))
        if slack < 0: viol += 1
print(f"  certification: {tests} (label, depth) cases over 600 random samplers (|Y| in 2..4, adversarial"
      f" approximations): violations of measure >= nu - 3*2^-i: {viol}; inconsistent certificates: {cons_bad}")

# end-to-end: product over inputs of the per-input certified measure at depth i_D
bad = 0; worst_ratio = Fr(10)
for trial in range(300):
    N = R7.randint(1, 6); K = R7.choice([2, 3])
    D = []
    for _ in range(N):
        vals = rand_dist(K)
        while min(vals) == 0: vals = rand_dist(K)
        F = [Fr(0)]
        for v in vals: F.append(F[-1] + v)
        h = R7.randint(1, K)
        D.append((vals, F, h))
    beta = min(v[h-1] for v, F, h in D)
    iD = ceil(log2(6*N/float(beta)))
    if iD > 12: continue
    prod_cert = Fr(1); prod_nu = Fr(1)
    for vals, F, h in D:
        mode = R7.choice(["rand", "down", "up"])
        qd = {i: approx(F, i, mode) for i in range(1, iD+1)}
        meas, ok = certified_measure(F, qd, iD)
        prod_cert *= meas[h]; prod_nu *= vals[h-1]
    ratio = prod_cert/prod_nu
    worst_ratio = min(worst_ratio, ratio)
    if ratio < Fr(1, 2): bad += 1
print(f"  end-to-end: Pr_w[phi_w extends D] / nu(D) at depth i_D = ceil(log2(6N/beta_D)): violations of"
      f" >= 1/2: {bad}; smallest ratio seen {float(worst_ratio):.4f}")

def cantor(a, b): return (a + b)*(a + b + 1)//2 + b
okpair = True; seen = set()
for a in range(0, 300):
    for b in range(0, 300):
        v = cantor(a, b)
        if v in seen: okpair = False
        seen.add(v)
for n in range(0, 13):
    for i in range(1, 65):
        jmax = 2**(n+1) - 2
        if not (cantor(jmax, i-1) < (2**(n+1) + i)**2): okpair = False
        t = ceil(log2(2*n + 2 + 2*log2(i+1)))
        if not (2**t >= 2*log2(2**(n+1) + i)): okpair = False      # i.e. 2^(2^t) >= (2^(n+1)+i)^2
print(f"  Cantor pairing injective on [0,300)^2, <j(x), i-1> < (2^(n+1)+i)^2 and the choice of t (n<=12,"
      f" i<=64): {okpair}")
print("  cost of the fill-in family, 2 log2(t+1) bits, against Lemma 3.2's hashing cost "
      "2log(N+1)+2log(n+1)+2log(r+1):")
for (n, N, beta, r) in [(20, 10**3, 1/3, 2), (100, 10**6, 1/3, 2), (100, 10**6, 2.0**-10, 10),
                        (1000, 10**12, 1e-3, 10), (10**6, 10**15, 1/3, 2)]:
    iD = ceil(log2(6*N/beta)); t = ceil(log2(2*n + 2 + 2*log2(iD + 1)))
    print(f"    n={n:>7} N={N:.0e} beta={beta:.3g}: i_D={iD}, t={t}, 2log2(t+1)={2*log2(t+1):.1f} bits;"
          f" hashing (dyadic, r={r}) {2*log2(N+1)+2*log2(n+1)+2*log2(r+1):.1f} bits")

# =============================================================================================
print("=" * 78)
print("(B) Prop 2.17: error envelopes (d=100, m=20, p=2^-10; S = S_1 u S_2, S_1 = {z: z_1..z_j = 0}, S_2 random)")
d, m, p = 100, 20, 2.0**-10
for (jj, s1) in [(11, 2**9), (13, 2**7)]:
    s2 = 1024 - s1
    p1 = s1/2**m; p2 = s2/(2**m - s1)
    Re = (1 - p1)*H(p2)
    L2 = log2binom(2**m - s1, s2)
    print(f"  instance j={jj}: s1={s1}, s2={s2}, p1=2^-{jj}, p2={p2:.4e}; R_env=(1-p1)H(p2)={Re:.5f}; H(p)={H(p):.5f};"
          f" gain H(p)-R_env={H(p)-Re:.5f}; L_2=log2 C(2^m-s1,s2)={L2:.1f} (so K(S) is about {L2:.0f} bits"
          f" when S_2 is random), L_S={log2binom(2**m, 1024):.1f}")
    for kappa in [0.0, 10.0, 30.0]:
        I = Inst(d, m, p, kappa=kappa)
        k1 = 2*log2(jj + 1) + kappa              # S_1 given m: the number j, doubling code, plus a fixed program
        ke = 2*log2(d) + 2*log2(m) + 2*log2(s2 + 1) + kappa
        KS1 = 2*log2(m) + k1 + kappa
        slackL = k1 + ke + 4 + I.Lam1
        cenv = (H(p) - Re)/slackL
        Je = lambda c: c*(d + k1 + ke) + Re
        lo = 2.0**-m
        print(f"    kappa={kappa:4.0f}: window (2^-m, c_hi] = ({lo:.3e}, {I.chi():.3e}];  c_env = (H(p)-R_env)/"
              f"(k1+k_e+4+Lam1) = {cenv:.3e}  (k1+k_e+4+Lam1 = {slackL:.1f});  J_env < M2 on (0, c_env]: "
              f"{all(Je(c) < I.M2(c) for c in np.geomspace(1e-9, cenv, 200))};  share of the window's log-width"
              f" below c_env: {(log2(min(cenv, I.chi())) - log2(lo))/(log2(I.chi()) - log2(lo)):.2f}")
        for dS2 in [0.0, 20.0]:
            row = []
            for c in [1.01*lo, 2e-6, 5e-6, 1e-5, 3e-5]:
                zeta = c*slackL
                Rbar = (zeta + (dS2 + log2(2**m + 1) + KS1)/2**m)/p1
                row.append(f"c={c:.2e}: e1>={2**-Rbar:.3f}")
            print(f"       delta_2={dS2:3.0f}: " + "; ".join(row))
s1, s2 = 2**9, 2**9; p1 = s1/2**m; p2 = s2/(2**m - s1); Re = (1 - p1)*H(p2); L2 = log2binom(2**m - s1, s2)
# three-hypothesis illustration with upper-bound lengths at kappa=0
I = Inst(d, m, p); k1 = 2*log2(12); ke = 2*log2(d) + 2*log2(m) + 2*log2(s2+1)
lg, le, lb = d + I.kg, d + k1 + ke, d + ceil(I.LS) + I.kb
lb_struct = d + k1 + 2*log2(m) + ceil(L2) + 2*log2(s2) + 2*log2(d)   # memoriser that names S_1 cheaply
print(f"  illustration (kappa=0, upper-bound lengths as if exact): l_good=d+{lg-d:.1f}, l_env=d+{le-d:.1f},"
      f" envelope beats good iff c < {(H(p)-Re)/(le-lg):.3e}; structured memoriser l=d+{lb_struct-d:.0f}"
      f" beats envelope iff c < {Re/(lb_struct-le):.3e}")
# minimisation identity
ok = True
for _ in range(2000):
    c = 10**rng.uniform(-8, -2); Bv = rng.uniform(0, 5e4); mm = int(rng.integers(5, 25))
    xs = np.concatenate([np.linspace(0, 2*Bv/2**mm, 4001), [Bv/2**mm]])
    val = np.min(xs + c*np.maximum(0, Bv - 2**mm*xs))
    if abs(val - min(c, 2.0**-mm)*Bv) > 1e-9*max(1, Bv): ok = False
print(f"  min_(x>=0) [x + c max(0, B - 2^m x)] = min(c, 2^-m) B on 2000 random cases: {ok}")
# complement coding identity, small exact instance
okid = True; maxmass = 0.0
for trial in range(40):
    dd, mm = 6, 4; Z = 2**mm; Wn = 2**(dd - mm)
    a = rng.integers(0, 2, dd)
    S1 = set(rng.choice(Z, size=int(rng.integers(1, 4)), replace=False).tolist())
    Zc = [z for z in range(Z) if z not in S1]
    S2 = set(rng.choice(Zc, size=int(rng.integers(1, 4)), replace=False).tolist())
    h = rng.uniform(0, 1, (2**dd, 2)); h = h/np.maximum(1, h.sum(1, keepdims=True))*rng.uniform(0.5, 1, (2**dd, 1))
    def x_of(z, w): return z*Wn + w
    def bits(x): return [(x >> (dd-1-i)) & 1 for i in range(dd)]
    fa = [int(np.dot(a, bits(x)) % 2) for x in range(2**dd)]
    qz = {}
    for z in Zc:
        for b in (0, 1):
            qz[(z, b)] = 2**(-np.mean([-log2(h[x_of(z, w), fa[x_of(z, w)] ^ b]) for w in range(Wn)]))
    R2 = np.mean([-log2(h[x_of(z, w), fa[x_of(z, w)] ^ (1 if z in S2 else 0)]) for z in Zc for w in range(Wn)])
    lhs = -sum(log2(qz[(z, 1 if z in S2 else 0)]) for z in Zc)
    if abs(lhs - len(Zc)*R2) > 1e-9: okid = False
    tot = 0.0
    for mask in range(2**len(Zc)):
        pr = 1.0
        for i, z in enumerate(Zc): pr *= qz[(z, (mask >> i) & 1)]
        tot += pr
    maxmass = max(maxmass, tot)
print(f"  complement coding (Lemma 2.3 on z not in S_1): -log Q(S_2) = (2^m - s_1) R^(2) exactly: {okid};"
      f" max total mass of Q over all subsets = {maxmass:.4f} (<= 1)")

# =============================================================================================
print("=" * 78)
print("(C) Lemma 2.2c: E_x nu(y*|x) = u - p avg_S A + p avg_S V  and the sharper floor")
viol = 0; maxerr = 0.0; ntest = 0
for trial in range(400):
    dd = 8; mm = int(rng.choice([6, 8])); Wn = 2**(dd - mm); Z = 2**mm
    s0 = int(rng.choice([Z//16, Z//8, Z//4 - 1]))
    pp = s0/Z
    a = rng.integers(0, 2, dd)
    fa = np.array([int(np.dot(a, [(x >> (dd-1-i)) & 1 for i in range(dd)]) % 2) for x in range(2**dd)])
    hA = rng.uniform(0, 1, 2**dd)**rng.uniform(0.2, 3); hV = (1 - hA)*rng.uniform(0, 1, 2**dd)
    if trial % 3 == 0:                      # S-aware hypothesis: correlate with the error set
        pass
    S = rng.choice(Z, size=s0, replace=False)
    inS = np.zeros(Z, bool); inS[S] = True
    if trial % 3 == 0:
        for z in S:
            for w in range(Wn): hA[z*Wn + w], hV[z*Wn + w] = hV[z*Wn + w], hA[z*Wn + w]
    zof = np.arange(2**dd)//Wn
    ystar_prob = np.where(inS[zof], hV, hA)
    lhs = ystar_prob.mean()
    Az = hA.reshape(Z, Wn).mean(1); Vz = hV.reshape(Z, Wn).mean(1)
    u = Az.mean()
    rhs = u - pp*Az[inS].mean() + pp*Vz[inS].mean()
    maxerr = max(maxerr, abs(lhs - rhs))
    devA = max(0.0, u - Az[inS].mean()); devV = max(0.0, Vz[inS].mean() - (1 - u))
    ntest += 1
    if lhs > pp + (1 - 2*pp)*u + pp*(devA + devV) + 1e-12: viol += 1
print(f"  {ntest} random semimeasure hypotheses (a third of them S-aware), d=8, m in {{6,8}}: identity max error"
      f" {maxerr:.1e}; violations of E nu(y*) <= p + (1-2p)u + p(devA + devV): {viol}")
lo_, hi_ = 1e-6, 0.4
for _ in range(200):
    mid = (lo_ + hi_)/2
    if 1 - log2(1.5 - mid) > H(mid): lo_ = mid
    else: hi_ = mid
print(f"  level-2 floor with Lemma 2.2c and no deviation term, 1 - log2(3/2 - p), exceeds H(p) iff p < {lo_:.4f}"
      f" (Lemma 2.2's G_1 needs p < 0.0560)")
lo2, hi2 = 1e-6, 0.4
for _ in range(200):
    mid = (lo2 + hi2)/2
    if 1 - log2(1 + 2*mid) > H(mid): lo2 = mid
    else: hi2 = mid
print(f"  Lemma 2.2's floor at large level, 1 - log2(1 + 2p), exceeds H(p) iff p < {lo2:.4f};"
      f" Lemma 2.2c's, 1 - log2(1 + (1-2p)2^-t), tends to 1 for every p < 1/2")
print("  Prop 3.8(iv): full table (m = d), B = inf, delta_E = 0, simple dyadic p = a/2^b (K(p) <= 2log(a+1)+2log(b+1));")
print("  best (t, g); then soph^x_c(D) lies in [d - s(t) - Lam1, d + kappa_g] for c in [c_lo, c_up)")
for kappa in [0.0, 30.0]:
    for d in [20, 30, 60, 100]:
        n = 2**d
        for (aa, bb) in [(1, 3), (3, 4), (7, 5), (15, 6)]:
            pp = aa/2**bb; s0 = aa*2**(d - bb)
            LE = log2binom(n, s0)
            Lam1 = 2*log2(d) + 2*log2(d) + kappa
            kg = 2*log2(d) + 2*log2(aa + 1) + 2*log2(bb + 1) + kappa
            kb = 2*log2(d) + 2*log2(d) + 2*log2(s0) + kappa
            clo = 0.0 + 2*log2(d) + kg + log2(n + 1) + kappa
            best = None
            for g in range(1, 40):
                Gam = 0.0 + d + g + 2*log2(g) + 2*log2(d) + 2*log2(s0) + 1 + 2*kappa   # I <= l + kappa, plus the coding constant
                gam = sqrt(jmin(Gam)*log(2)/(2*s0))
                for t in range(1, 30):
                    Ft = 1 - log2(1 + (1 - 2*pp)*2.0**-t + 2*pp*(2*gam + 2.0**(1 - g)))
                    cup = n*Ft - d - ceil(LE) - kb - 2*kappa
                    if cup > clo:
                        lb = d - s_(t) - Lam1
                        if best is None or lb > best[0]: best = (lb, t, g, gam, Ft, cup)
                        break
            oldok = any(n*(1 - log2(1 + 2.0**(1-t) + 2*pp)) - d - ceil(LE) - kb - 2*kappa > clo for t in range(1, 60))
            if best is None:
                print(f"    kappa={kappa:3.0f} d={d:3d} p={aa}/2^{bb}: no admissible (t, g); Lemma 2.2's floor admissible: {oldok}")
            else:
                lb, t, g, gam, Ft, cup = best
                print(f"    kappa={kappa:3.0f} d={d:3d} p={aa}/2^{bb}={pp:.4f}: t={t}, g={g}, gamma={gam:.1e}, F_t={Ft:.4f} > H(p)={H(pp):.4f};"
                      f" soph in [d-{d-lb:.1f}, d+{kg:.1f}] = [{lb:.1f}, {d+kg:.1f}] for c in [{clo:.0f}, {cup:.3g});"
                      f" Lemma 2.2's floor admissible: {oldok}")

# =============================================================================================
print("=" * 78)
print("(D) Theorem 2(iii) near 2^-m (d=100, m=20, p=2^-10, B=inf, eta=0)")
for kappa in [0.0, 30.0]:
    for dS in [0.0, 20.0]:
        I = Inst(100, 20, 2.0**-10, kappa=kappa, deltaS=dS)
        def rho(c): return c*(ceil(I.LS) - I.LS + I.dS + 4 + I.Lam1 + I.kb)
        def cond(c): return rho(c) < (1 - c*2**I.m)*I.BS/2**I.m and I.Jb(c) < I.M2(c)
        def ebound(c): return 2**(-rho(c)/((1 - c*2**I.m)*I.p))
        lo, hi = 0.5*2.0**-20, 2.0**-20
        for _ in range(100):
            mid = (lo + hi)/2
            if cond(mid): lo = mid
            else: hi = mid
        ccond = lo
        def first_c(target):
            lo, hi = 1e-3*2.0**-20, ccond
            for _ in range(100):
                mid = (lo + hi)/2
                if ebound(mid) >= target: lo = mid
                else: hi = mid
            return lo
        cells = "; ".join(f"eps={eps}: e>={ebound((1-eps)*2.0**-20):.3f}" for eps in [0.5, 0.2, 0.1, 0.06, 0.03, 0.01])
        print(f"  kappa={kappa:3.0f} delta_S={dS:3.0f}: condition holds iff c < {ccond*2**20:.5f}*2^-m;"
              f" e>=1/2 iff c <= {first_c(0.5)*2**20:.4f}*2^-m; e>=0.9 iff c <= {first_c(0.9)*2**20:.4f}*2^-m;"
              f" threshold of (iv) = {I.Hp/(ceil(I.LS)+I.kb+4+I.Lam1)*2**20:.5f}*2^-m")
        print(f"      at c = (1-eps) 2^-m: {cells}")

# =============================================================================================
print("=" * 78)
print("(E) Prop 2.13 (guard erosion) from the explicit teacher model")
M, eta, ks, kG = 64, 0.05, 22, 12
phit = 1 - eta + eta/M
HG = -(phit*log2(phit) + (M - 1)*(eta/M)*log2(eta/M))
gain = log2(M) - HG
DG = log2(M/eta) - log2(M - 1)
print(f"  G-contexts: teacher and sigma-model put {phit:.5f} on sigma, eta/M on each other step; H_G={HG:.4f},"
      f" g=log2 M - H_G={gain:.4f}")
print(f"  not-G contexts: teacher plays one fixed non-sigma step; losses none=log2 M={log2(M):.3f},"
      f" unguarded=log2(M/eta)={log2(M/eta):.3f}, guarded=log2(M-1)={log2(M-1):.3f}; Delta_G={DG:.4f}")
for (piG, pinG) in [(0.05, 5e-4), (0.002, 0.002)]:
    pts = {"none": (0.0, piG*log2(M) + pinG*log2(M)),
           "unguarded": (ks, piG*HG + pinG*log2(M/eta)),
           "guarded": (ks + kG, piG*HG + pinG*log2(M - 1))}
    rs = (pts["none"][1] - pts["unguarded"][1])/ks; rG = (pts["unguarded"][1] - pts["guarded"][1])/kG
    rgn = (pts["none"][1] - pts["guarded"][1])/(ks + kG)
    path = []
    for c in np.geomspace(1e-7, 1, 4001):
        best = min(pts, key=lambda k: c*pts[k][0] + pts[k][1])
        if not path or path[-1] != best: path.append(best)
    print(f"  piG={piG}, pinG={pinG}: rho_sigma={rs:.4e}, rho_G={rG:.4e}, guarded->none average rate {rgn:.4e};"
          f" selection path as c increases: {' -> '.join(path)}")

# =============================================================================================
print("=" * 78)
print("(F) Prop 2.8 consequence: eta' = eta + eps_1 + B sqrt((L' ln2 + ln(2/delta))/(2N)), L' = (J_g+eps_1+eta)/c")
I = Inst(100, 20, 2.0**-10)
for (c, eta, N) in [(1e-4, 1e-3, 1e13), (1e-4, 1e-4, 1e13), (1e-3, 1e-3, 1e11)]:
    B, delta, A = 30.0, 0.01, 10.0
    eps1 = A*sqrt(log(2/delta)/(2*N))
    Lp = (I.Jg(c) + eps1 + eta)/c
    etap = eta + eps1 + B*sqrt((Lp*log(2) + log(2/delta))/(2*N))
    Lold = (I.Jg(c) + eps1)/c
    etaold = eta + eps1 + B*sqrt((Lold*log(2) + log(2/delta))/(2*N))
    print(f"  c={c:.0e} eta={eta:.0e} N={N:.0e}: L'={Lp:.1f} bits (notes.md's L-hat {Lold:.1f}); eta'={etap:.4e}"
          f" (with L-hat: {etaold:.4e}); J_g+eta' < M2: {I.Jg(c)+etap < I.M2(c)}; log2 mass ratio <= "
          f"{-N*eta + (I.Jg(c)+eta)/c:.3g}")

# =============================================================================================
print("=" * 78)
print("(G) Prop 2.9(b'): the lambda-MAP under a schedule lambda_N (d=100, m=20, B=30, delta=0.01, kappa=0)")
I = Inst(100, 20, 2.0**-10)
Lhat = I.d + ceil(I.LS) + I.kb
B, delta = 30.0, 0.01
for name, lam in [("lambda=1", lambda N: 1.0), ("lambda=sqrt(N)", lambda N: sqrt(N)),
                  ("lambda=N^0.9", lambda N: N**0.9), ("lambda=1e-4 N", lambda N: 1e-4*N)]:
    cells = []
    for N in [1e12, 1e13, 1e15, 1e17]:
        RB = lam(N)*Lhat/N + B*sqrt((Lhat*log(2) + log(2/delta))/(2*N))
        e = 2**(-RB/I.p) - 2**-B
        cells.append(f"N={N:.0e}: c=lam/N={lam(N)/N:.1e}, e>={max(e, 0):.3f}")
    print(f"  {name:15s} " + "; ".join(cells))
print(f"  (the window of Theorem 2 is c in (2^-20, {I.chi():.3e}] = ({2.0**-20:.3e}, {I.chi():.3e}];"
      f" a schedule with lambda_N/N -> 0 leaves it once lambda_N/N < 2^-20)")

# =============================================================================================
print("=" * 78)
print("(H) Cor 2.5 (full table d = m = 20, p = 2^-10, B = inf) with delta_E explicit; g optimised over 1..40")
for kappa in [0.0, 30.0]:
    for dS in [0.0, 20.0]:
        I = Inst(20, 20, 2.0**-10, kappa=kappa, deltaS=dS)
        cells = []
        for lam in [2.0, 105.0]:
            c = lam/2**20
            Lam2 = 2**I.m*I.Hp - I.BS + 4 + I.Lam1 + I.kg
            u_lo = max(0.75, 2**-(I.Jg(c)) - I.p)
            Dl = I.kg + Lam2/(c*2**I.m - 1)
            Lam3 = 4 + 2*log2(I.d) + I.kappa
            best = None
            for g in range(1, 41):
                Gam = I.dS + Dl + Lam3 + 1 + 2*log2(I.m) + 2*log2(I.s0) + g + 2*log2(g) + I.kappa
                gam = sqrt(jmin(Gam)*log(2)/(2*I.s0))
                e = 1 - u_lo + gam + 2.0**-g
                if best is None or e < best[0]: best = (e, g)
            cells.append(f"lambda={lam:g}: u>={u_lo:.4f} len<=d+{Dl:.1f} I<={Dl+Lam3:.1f} e<={best[0]:.3f} (g={best[1]})")
        print(f"  kappa={kappa:3.0f} delta_E={dS:3.0f}: " + "; ".join(cells))
