"""c6: checks added in the revision after the referee report (notes-final.md).

[A] Prop 2.11(ii) made robust in the machine constant kappa (referee M1).  The all-hypothesis
    rate-blindness condition is equivalent to F(d) := d - a log2 d - b >= 0 with explicit a, b
    (Lemma 2.11a).  We compute d0(kappa) = least integer d with F(d) >= 0 and check, by direct
    evaluation of the original inequality, that it fails at d0 - 1 and holds on a grid of d >= d0.
[B] Theorem 2(ii) identification numbers with the randomness deficiency delta_S stated explicitly
    (referee minor 4): the information I = B_S - K(S | a, pi) and L_S - K(S | a, pi) = delta_S + I.
[C] Hanni's Version 1 realised in the junta family at d = 100, m = 10, p = 2^-6 (referee minor 13),
    and the referee's full-table instance d = 13, m = 10, p = 2^-6 for comparison.
[D] Prop 1.7 (price of private randomness under a steeper prior): the inequality
    xi_lambda(D_beta) <= R(beta)^min(lambda,2) on random finite product classes, and an illustrative
    class (coin, partial fill-ins, full fill-ins) against a shared class that also has sigma.
[E] Lemma 3.2 with the embedding of {0,1}^{<=n} into GF(2^q), q = max(n+1, r), counted per seed
    (per program): P_s[phi_s extends D] = nu(D) exactly, for random dyadic nu (referee minor 1).
[F] Lemma 1.2(iii) as reworded (referee minor 11): a point is the unique minimiser of c*l + R on a
    nonempty open interval of c iff it is a vertex of the lower boundary (end vertices included) and
    no other hypothesis sits at the same point.
[G] Small items: the exact guard-erosion crossing (Prop 2.13) and the explicit fraction in Prop 2.9(a).
[H] Example 2.7a at N = 1e4: Lemma 2.6's excess term against the largest margin M2 - J_g in the window.

Formulas are those of notes-final.md, re-implemented here (not imported from c3).
Seeded: numpy default_rng(6), random.seed(6).
"""
import itertools, random
from fractions import Fraction
from math import log2, log, sqrt, comb, ceil, inf
import numpy as np

rng = np.random.default_rng(6); random.seed(6)


def H(q):
    return 0.0 if q in (0, 1) else -(q*log2(q) + (1-q)*log2(1-q))


def LS_exact(m, s0):
    return log2(comb(2**m, s0))


class T2:
    """Theorem 2 constants, B = infinity."""
    def __init__(self, d, m, r, kappa=0.0, dS=0.0):
        self.d, self.m, self.r, self.kappa, self.dS = d, m, r, kappa, dS
        self.p = 2.0**-r; self.s0 = 2**(m - r)
        self.LS = LS_exact(m, self.s0); self.BS = self.LS - dS
        self.Hp = H(self.p)
        self.Lam1 = 2*log2(d) + 2*log2(m) + kappa
        self.kg = 2*log2(d) + 2*log2(r) + kappa
        self.kb = 2*log2(d) + 2*log2(m) + 2*log2(self.s0) + kappa
        self.tstar = (d - self.Lam1)/4

    def G(self, j):
        return 1 - log2(1 + 2.0**(-j) + 2*self.p)

    def M2(self, c):
        if self.tstar < 2:
            return self.G(1)
        return min(c*(self.d - 8 - self.Lam1) + self.G(1), self.G(self.tstar - 1))

    def Jg(self, c):
        return c*(self.d + self.kg) + self.Hp

    def chi(self):
        if self.tstar < 2:
            return (self.G(1) - self.Hp)/(self.d + self.kg)
        return min((self.G(1) - self.Hp)/(8 + self.Lam1 + self.kg),
                   (self.G(self.tstar - 1) - self.Hp)/(self.d + self.kg))

    def lower_end_sharp(self):   # Theorem 2(iv): memoriser beats every level-1 pi with R >= H(p) below this c
        return self.Hp/(ceil(self.LS) + self.kb + 4 + self.Lam1)

    def ident(self, c, eta=0.0):
        m, s0 = self.m, self.s0
        assert c*2**m > 1 and self.Jg(c) + eta < self.M2(c)
        Lam2 = 2**m*self.Hp - self.BS + 4 + self.Lam1 + self.kg
        Lam3 = 4 + 2*log2(self.d) + self.kappa
        u_lo = 2**-(self.Jg(c) + eta) - self.p
        Dl = self.kg + eta/c + (Lam2 + eta/c)/(c*2**m - 1)
        best = None
        for g in range(1, 41):
            Gam = self.dS + Dl + Lam3 + 1 + 2*log2(m) + 2*log2(s0) + g + 2*log2(g) + self.kappa
            j = 0
            while not (j - 2*log2(j + 1) > Gam):
                j += 1
            gam = sqrt(j*log(2)/(2*s0))
            e = 1 - u_lo + gam + 2.0**-g
            if best is None or e < best[0]:
                best = (e, g, j, gam)
        return dict(u=u_lo, len=Dl, I=Dl + Lam3, vsLS=self.dS + Dl + Lam3, e=best[0], g=best[1])


# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[A] Prop 2.11(ii), robust in kappa: condition  <=>  F(d) = d - a log2 d - b >= 0")


def cond_211ii(d, m, r, kappa):
    t = T2(d, m, r, kappa)
    den = d - 4 - t.Lam1 - kappa
    if den <= 0:
        return False
    return t.Hp/(ceil(t.LS) + t.kb + 4 + t.Lam1) >= (1 - t.Hp)/den


def ab(m, r, kappa):
    p = 2.0**-r; Hp = H(p); s0 = 2**(m - r); LSc = ceil(LS_exact(m, s0)); q = (1 - Hp)/Hp
    a = 2 + 4*q
    b = 4 + 2*log2(m) + 2*kappa + q*(LSc + 4*log2(m) + 2*log2(s0) + 2*kappa + 4)
    return a, b


print("  (m, r) rule | kappa | a/ln2 | b | d0 (least integer d with F(d) >= 0) | direct check at d0-1, d0 | grid d0..1e6 ok")
for (m, r) in [(3, 3), (4, 4), (6, 6), (7, 7), (6, 3)]:
    for kappa in [0, 10, 20, 30, 50, 100]:
        a, b = ab(m, r, kappa)
        F = lambda d: d - a*log2(d) - b
        lo, hi = max(1.0, a/log(2)), 1e7
        assert F(hi) > 0
        for _ in range(200):
            mid = (lo + hi)/2
            if F(mid) >= 0: hi = mid
            else: lo = mid
        d0 = ceil(hi)
        while d0 > 1 and F(d0 - 1) >= 0: d0 -= 1
        while F(d0) < 0: d0 += 1
        grid = sorted(set([d0, d0 + 1, d0 + 2] + [int(x) for x in np.unique(np.logspace(log2(d0)/log2(10), 6, 400).astype(int))]))
        grid_ok = all(cond_211ii(d, m, r, kappa) for d in grid if d >= d0)
        print(f"  m={m} p=2^-{r}  | {kappa:5d} | {a/log(2):6.1f} | {b:8.1f} | d0 = {d0:6d} | "
              f"{cond_211ii(d0 - 1, m, r, kappa)!s:5s} {cond_211ii(d0, m, r, kappa)!s:5s} | {grid_ok} ({len(grid)} values)")
        assert b >= a/log(2)   # needed for the up-set argument of Lemma 2.11a
print("  (b >= a/ln2 held in every row, so {d >= 1 : F(d) >= 0} = [d0, infinity) by Lemma 2.11a)")

print("  Prop 2.11(i) three-hypothesis examples, with lengths set equal to their upper bounds (kappa = 0):")
for (m, r) in [(6, 6), (7, 7), (8, 8)]:
    t = T2(100, m, r, 0.0)
    rE = t.Hp/(ceil(t.LS) + t.kb - t.kg)
    rM = (1 - t.Hp)/(t.d + t.kg - 0.0)
    # margin: how many bits l_b - l_g may grow before the verdict flips
    flip = t.Hp/rM - (ceil(t.LS) + t.kb - t.kg)
    print(f"    m={m}, single prefix: memoriser beats good for c < {rE:.4e}; coin beats/ties good for c >= {rM:.4e}; "
          f"never selected: {rE >= rM}; verdict flips if l_b - l_g grows by {flip:+.2f} bits")

# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[B] Theorem 2(ii) identification with delta_S explicit (B = inf, eta = 0, g optimised over 1..40)")
print("    I := B_S - K(S|a,pi) <= Delta_l + Lambda_3;  L_S - K(S|a,pi) = delta_S + I")
for (d, m, r) in [(100, 20, 10), (100, 24, 10)]:
    for kappa in [0.0, 30.0]:
        for dS in [0.0, 10.0, 20.0]:
            t = T2(d, m, r, kappa, dS)
            for c in [1e-5, 1e-4, 1e-3]:
                if not (c*2**m > 1 and c <= t.chi()):
                    continue
                z = t.ident(c)
                print(f"  d={d} m={m} kappa={kappa:4.0f} delta_S={dS:4.0f} c={c:.0e}: u>={z['u']:.4f}  len<=d+{z['len']:.1f}  "
                      f"I<={z['I']:.1f}  L_S-K(S|a,pi)<={z['vsLS']:.1f} (of L_S={t.LS:.0f})  e<={z['e']:.3f} (g={z['g']})")

# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[C] Hanni's Version 1 (100-bit model with rate ~100 bits/bit; ~100-bit error model with rate ~10 bits/bit, N fixed)")
t0 = T2(100, 10, 6, 0.0)
N = 10**4
print(f"  instance d=100, m=10, p=2^-6: s0={t0.s0}, L_S={t0.LS:.2f} bits, H(p)={t0.Hp:.4f}")
print(f"  at N={N}: model saving N(1-H(p)) = {N*(1-t0.Hp):.0f} bits for d=100 bits (rate {N*(1-t0.Hp)/100:.1f}/bit); "
      f"error saving N H(p) = {N*t0.Hp:.0f} bits for L_S = {t0.LS:.1f} bits (rate {N*t0.Hp/t0.LS:.1f}/bit)")
for kappa in [0.0, 5.0, 10.0, 20.0, 30.0]:
    t = T2(100, 10, 6, kappa)
    lo, hi = 2.0**-10, t.chi()
    ok = lo < hi
    print(f"  kappa={kappa:4.0f}: window c in (2^-10, c_hi] = ({lo:.3e}, {hi:.3e}] nonempty={ok}; "
          f"at N=1e4: lambda in ({N*lo:.2f}, {N*hi:.2f}];  Thm 2(iv) memoriser-regime threshold {t.lower_end_sharp():.3e}")
    if ok:
        for c in [1.5e-3, 2.5e-3, 4e-3, 5.5e-3]:
            if c <= hi and c*2**10 > 1:
                z = t.ident(c)
                print(f"      c={c:.1e} (lambda={c*N:.0f} at N=1e4): u>={z['u']:.3f}  len<=d+{z['len']:.1f}  "
                      f"I<={z['I']:.1f} of L_S={t.LS:.0f}  e<={z['e']:.2f}")
print("  referee's full-table instance d=13, m=10, p=2^-6 (N = 2^13): lambda-window (N 2^-m, N c_hi]")
for kappa in [0.0, 10.0, 30.0]:
    t = T2(13, 10, 6, kappa)
    print(f"    kappa={kappa:4.0f}: ({2**13*2.0**-10:.2f}, {2**13*t.chi():.2f}]")

# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[D] Prop 1.7: xi_lambda(D_beta) <= R(beta)^min(lambda,2) on random finite product classes")
viol = tests = 0; worst = -inf
for trial in range(300):
    k = int(rng.integers(1, 6)); P = int(rng.integers(2, 12))
    # hypothesis p: per block j, sub-probabilities nu(.|a_j), nu(.|b_j) on {0,1}
    nus = []
    for _ in range(P):
        kind = rng.integers(0, 3)
        if kind == 0:     # random sub-probabilities
            A = rng.dirichlet(np.ones(3), size=(k, 2))[:, :, :2]
        elif kind == 1:   # deterministic fill-in of a random beta (consistent on both inputs)
            bb = rng.integers(0, 2, k); A = np.zeros((k, 2, 2)); A[np.arange(k), :, bb] = 1.0
        else:             # sharp but different on the two inputs of a block
            A = np.zeros((k, 2, 2)); A[np.arange(k), 0, rng.integers(0, 2, k)] = 1.0; A[np.arange(k), 1, rng.integers(0, 2, k)] = 1.0
        nus.append(A)
    ell = rng.integers(1, 8, P).astype(float)
    while np.sum(2.0**-ell) > 1: ell += 1
    w = 2.0**-ell
    for beta in itertools.product([0, 1], repeat=k):
        nuD = np.array([np.prod([A[j, 0, beta[j]]*A[j, 1, beta[j]] for j in range(k)]) for A in nus])
        Qb = np.array([np.prod([(A[j, 0, beta[j]] + A[j, 1, beta[j]])/2 for j in range(k)]) for A in nus])
        R = float(np.sum(w*Qb))
        for lam in [1.0, 1.3, 1.7, 2.0, 2.5, 4.0]:
            xi = float(np.sum(w**lam*nuD)); tests += 1
            if xi > R**min(lam, 2.0)*(1 + 1e-12) + 1e-300: viol += 1
            if xi > 0 and R > 0: worst = max(worst, log2(xi) - min(lam, 2.0)*log2(R))
print(f"  violations {viol} of {tests} (beta, lambda) checks; max log2(xi / R^min(lam,2)) = {worst:.3f} (<= 0 required)")

print("  illustration: k blocks {0^j, 1^j}, labels beta_j on both inputs of block j; beta uniform random")
k = 40
beta = rng.integers(0, 2, k)
# product class: coin (l=2); partial fill-ins knowing the first t bits of beta (t=1..k), coin elsewhere:
#   l_t = t + 2 log2(t+1) + 2 log2(k+1) + 2  (only the correct one matters for D_beta; incorrect ones have nu(D_beta) = 0)
# shared class adds sigma (one coin per block, l = 2).
def code_lengths(lam):
    terms = [2.0**(-lam*2)*2.0**(-2*k)]                           # coin: 2 bits per block
    for t in range(1, k + 1):
        lt = t + 2*log2(t + 1) + 2*log2(k + 1) + 2
        terms.append(2.0**(-lam*lt)*2.0**(-2*(k - t)))              # knows t bits, coin on the rest
    prod_ = -log2(sum(terms))
    shared = -log2(sum(terms) + 2.0**(-lam*2)*2.0**(-k))           # + sigma
    return prod_, shared
for lam in [1.0, 1.5, 2.0, 3.0, 5.0]:
    pc, sc = code_lengths(lam)
    print(f"    lambda={lam:3.1f}: product-class steeper code length {pc:7.1f} bits; shared class (with sigma) {sc:6.1f} bits; "
          f"min(lambda,2) k = {min(lam, 2)*k:5.1f}, k = {k}")

# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[E] Lemma 3.2: per-seed (per-program) hashing over GF(2^q), q = max(n+1, r), inputs of length <= n")
MOD = {3: 0b1011, 4: 0b10011, 5: 0b100101}


def gf_mul(a, b, q):
    res = 0
    while b:
        if b & 1: res ^= a
        b >>= 1; a <<= 1
        if a >> q: a ^= MOD[q]
    return res


def embed(x):          # x a binary string of length <= n -> integer with binary digits '1x'
    return int('1' + x, 2)


n = 2
inputs = [''] + [''.join(t) for L in range(1, n + 1) for t in itertools.product('01', repeat=L)]
maxerr = Fraction(0); cases = 0
for r in [2, 3, 4]:
    q = max(n + 1, r)
    Yn = 3
    for trial in range(3):
        # random dyadic nu with denominator 2^r, |Y| = 3, per input
        nu = {}
        for x in inputs:
            cuts = sorted(rng.integers(0, 2**r + 1, Yn - 1)); parts = np.diff([0] + list(cuts) + [2**r])
            nu[x] = [Fraction(int(c), 2**r) for c in parts]
        def sigma(x, b):   # canonical sampler: b in [0, 2^r)
            acc = 0
            for y in range(Yn):
                acc += nu[x][y]*2**r
                if b < acc: return y
        for Nn in [1, 2, 3]:
            subsets = list(itertools.combinations(inputs, Nn))
            random.shuffle(subsets)
            for S in subsets[:6]:
                pts = [embed(x) for x in S]
                powers = [[1] for _ in pts]
                for i, z in enumerate(pts):
                    for _ in range(1, Nn): powers[i].append(gf_mul(powers[i][-1], z, q))
                counts = {}
                for s in itertools.product(range(2**q), repeat=Nn):
                    lab = []
                    for i in range(Nn):
                        v = 0
                        for j in range(Nn): v ^= gf_mul(s[j], powers[i][j], q)
                        lab.append(sigma(S[i], v & (2**r - 1)))
                    counts[tuple(lab)] = counts.get(tuple(lab), 0) + 1
                for lab in itertools.product(range(Yn), repeat=Nn):
                    pr = Fraction(counts.get(lab, 0), 2**(q*Nn))
                    nuD = Fraction(1)
                    for x, y in zip(S, lab): nuD *= nu[x][y]
                    maxerr = max(maxerr, abs(pr - nuD)); cases += 1
print(f"  n={n} (7 inputs), r in {{2,3,4}}, q = max(n+1,r), |Y|=3, N<=3: {cases} (domain, labelling) cases; "
      f"max |P_s[phi_s extends D] - nu(D)| = {float(maxerr):.1e}")
print("  (each seed s is a distinct program rho pi_nu <N><n><r> s of length L0 + qN, so the per-program sum is "
      "2^-L0 * P_s[...] exactly; no per-function collision issue)")

# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[F] Lemma 1.2(iii): unique minimiser on an open c-interval  <=>  vertex of the lower boundary, unshared point")


def lower_vertices(A):
    """Vertices of the lower-left boundary of conv(A + R^2_{>=0}) (strict; collinear points excluded)."""
    P = sorted(set(A))
    best = {}
    for l_, R_ in P:
        if l_ not in best or R_ < best[l_]: best[l_] = R_
    pts = sorted(best.items())
    stair = []                       # keep points with R strictly below every point to the left
    for l_, R_ in pts:
        if not stair or R_ < stair[-1][1]: stair.append((l_, R_))
    hull = []
    for q_ in stair:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            if (x2 - x1)*(q_[1] - y1) - (y2 - y1)*(q_[0] - x1) <= 0: hull.pop()   # remove non-strict turns
            else: break
        hull.append(q_)
    return hull


mism = 0; tot = 0
examples = [[(0, 1.0), (10, 0.5), (20, 0.0)]]
for _ in range(400):
    A = [(int(rng.integers(0, 30)), float(rng.integers(0, 12))/4) for _ in range(int(rng.integers(2, 25)))]
    examples.append(A)
for A in examples:
    V = set(lower_vertices(A))
    slopes = set()
    for (l1, R1), (l2, R2) in itertools.combinations(A, 2):
        if l1 != l2:
            s = (R1 - R2)/(l2 - l1)
            if s > 0: slopes.add(s)
    sl = sorted(slopes)
    probes = ([sl[0]/2] if sl else [1.0]) + [(a + b)/2 for a, b in zip(sl, sl[1:])] + ([2*sl[-1]] if sl else [])
    for idx, a in enumerate(A):
        unique_somewhere = False
        for c in probes:
            vals = [c*l_ + R_ for l_, R_ in A]; v = min(vals)
            mins = [i for i, val in enumerate(vals) if abs(val - v) < 1e-12]
            if mins == [idx]: unique_somewhere = True
        predicted = (a in V) and (A.count(a) == 1)
        tot += 1; mism += (unique_somewhere != predicted)
print(f"  referee example {{(0,1),(10,0.5),(20,0)}}: vertices = {sorted(lower_vertices(examples[0]))}")
print(f"  {tot} (point set, point) pairs over {len(examples)} sets: mismatches between 'unique on an open interval' and "
      f"'vertex and unshared' = {mism}")

# ---------------------------------------------------------------------------------------------
print("=" * 94)
print("[G] small items: exact guard-erosion crossing (Prop 2.13); Prop 2.9(a) explicit fraction")
M_, eta_ = 64, 0.05
p_hit = 1 - eta_ + eta_/M_
gain = log2(M_) + (p_hit*log2(p_hit) + (M_ - 1)*(eta_/M_)*log2(eta_/M_))
DG = log2(M_/eta_) - log2(M_ - 1)
for (piG, pinG, ks, kG) in [(0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)]:
    rho_s = (piG*gain - pinG*log2(1/eta_))/ks; rho_G = pinG*DG/kG
    # guarded vs none: c (ks + kG) = piG gain - pinG log(1/eta) + pinG DG
    c_gn = (piG*gain - pinG*log2(1/eta_) + pinG*DG)/(ks + kG)
    print(f"  piG={piG}, pinG={pinG}: rho_sigma={rho_s:.4e}, rho_G={rho_G:.4e}; "
          f"{'unguarded selected on (%.4e, %.4e)' % (rho_G, rho_s) if rho_G < rho_s else 'guarded -> none at c = %.4e' % c_gn}")
t = T2(100, 20, 10, 0.0)
errs = t.p*2**100
print(f"  Prop 2.9(a), d=100, m=20, p=2^-10, all 2^100 inputs: #error inputs = {errs:.3e}; "
      f"inputs with SFI prob < 1/2 for the teacher's label <= d + ceil(L_S) + kappa_b = {100 + ceil(t.LS) + t.kb:.0f} (kappa=0); "
      f"fraction of error inputs reproduced >= 1 - {(100 + ceil(t.LS) + t.kb)/errs:.2e}")

print("=" * 94)
print("[H] Example 2.7a at N = 1e4: Lemma 2.6's excess vs the margin M2 - J_g (B = inf gives the largest margin)")
t = T2(100, 10, 6, 0.0)
cs = np.linspace(2.0**-10*1.0001, t.chi(), 2000)
marg = max(t.M2(c) - t.Jg(c) for c in cs)
Lmin = t.d - 4 - t.Lam1              # (D1): every level-1 program, pi_g included, has l >= d - 4 - Lambda_1
exc = log2(64)*sqrt(Lmin*log(2)/(2*1e4))
print(f"  max over the window of M2 - J_g (B = inf, kappa = 0): {marg:.3f};  Lemma 2.6 excess at N = 1e4 with B >= log2(1/p) = 6: "
      f">= 6 sqrt((d-4-Lambda_1) ln2 / 2N) = {exc:.3f}  -> no finite-sample guarantee at N = 1e4: {exc > marg}")
