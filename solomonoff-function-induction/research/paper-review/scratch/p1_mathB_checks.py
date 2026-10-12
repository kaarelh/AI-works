"""Independent checks for review p1-math-B (Paper 1, sections hist/examples and their appendices).

Run: python3 p1_mathB_checks.py  (deterministic; seed 20261012 for the Monte Carlo parts).
Writes nothing; prints a report. Each block names the paper item it checks.
"""
import itertools, math, random
from fractions import Fraction as Fr

random.seed(20261012)
log2 = math.log2

def hdr(s):
    print("\n=== " + s)

# ---------------------------------------------------------------------------
hdr("1. lem:ex:chainsemi / eq:ex:depth with z NOT restricted to nonzero d-bit strings")
# Paper (app-examples.tex): D(x,z) := {(x,z1),(z1,z2),...,(zi,0^{|x|})} for 'strings z',
# Lemma: sum_z nu(D(x,z)) <= 1 over z with D(x,z) a data set; eq:ex:depth: sum_{x,|z|=k-1} nu(D(x,z)) = E|A_k(F)| <= N-k
d = 2; N = 2 ** d
strs = [format(i, "0%db" % d) for i in range(N)]
zero = "0" * d
nonzero = [s for s in strs if s != zero]

def D_of(x, z):
    pairs = [(x, z[0])] if z else [(x, zero)]
    if z:
        for i in range(len(z) - 1):
            pairs.append((z[i], z[i + 1]))
        pairs.append((z[-1], zero))
    dd = {}
    for a, b in pairs:
        if a in dd and dd[a] != b:
            return None          # not a data set
        dd[a] = b
    return dd

def extends(F, dd):
    return all(F.get(a) == b for a, b in dd.items())

F0 = {s: zero for s in strs}     # the constant-0 function (positive M_F weight)
x = nonzero[0]
cnt = 0
for L in range(0, 6):
    for z in itertools.product(strs, repeat=L):
        dd = D_of(x, z)
        if dd is not None and extends(F0, dd):
            cnt += 1
print("F == 0^d, x=%s: number of z of length <= 5 (any d-bit strings) with F ⊇ D(x,z): %d (Lemma claims <= 1)" % (x, cnt))

def depth_sum(F, k, restrict):
    alph = nonzero if restrict else strs
    tot = 0
    for xx in nonzero:
        for z in itertools.product(alph, repeat=k - 1):
            dd = D_of(xx, z)
            if dd is not None and extends(F, dd):
                tot += 1
    return tot

worst_unr = {}; worst_res = {}
vals = strs + [None]
for img in itertools.product(vals, repeat=N):      # all 5^4 = 625 partial functions
    F = {s: v for s, v in zip(strs, img) if v is not None}
    for k in range(1, N):
        worst_unr[k] = max(worst_unr.get(k, 0), depth_sum(F, k, False))
        worst_res[k] = max(worst_res.get(k, 0), depth_sum(F, k, True))
for k in range(1, N):
    print("k=%d: N-k=%d | max_F count, z restricted to nonzero d-bit: %d | z unrestricted: %d"
          % (k, N - k, worst_res[k], worst_unr[k]))

# ---------------------------------------------------------------------------
hdr("2. Eisenstat constants (prop:ex:asymp, prop:ex:burnin, prop:ex:rulestats)")
L3 = log2(3)
a = 1.5 * L3 - 1
sigma2 = 2 / 9 * a * a + 0.25 * L3 * L3
H13 = -(1 / 3) * log2(1 / 3) - (2 / 3) * log2(2 / 3)
print("H(1/3)/2 = %.7f ; sigma^2 = %.7f ; sigma = %.4f ; iid(1/3) rate log3-1/3 = %.4f" % (H13 / 2, sigma2, math.sqrt(sigma2), L3 - 1 / 3))
theta = sum(2 / 9 * ((2 / 3) ** k * log2(1 + 2.0 ** -k) + (1 / 3) ** k * log2(1 + 2.0 ** k)) for k in range(0, 400))
print("vartheta = %.10f ; 3*vartheta = %.8f" % (theta, 3 * theta))
ret = 2 / 9 + 2 / 9 + sum(2 / 9 * (2 / 3) ** k * 2.0 ** -k for k in range(1, 400)) + sum(2 / 9 * (1 / 3) ** k for k in range(1, 400))
print("return probability from touching = %.12f (paper 2/3)" % ret)
p = Fr(1, 3) / (1 - Fr(1, 3))   # p = p/3 + 1/3
print("no-error probability p solves p = p/3 + 1/3 -> %s" % p)
Bsteps = sum(Fr(2, 9) * Fr(1, 3) ** k * 2 * k for k in range(1, 200))
print("E B-steps after a touching step ~ %.12f (paper 1/3); errors per cycle = 2/9+1/9+1/3 = %s" % (float(Bsteps), Fr(2, 9) + Fr(1, 9) + Fr(1, 3)))
print("Lemma behind constant 1+1/(1-e^{-1/18}) = %.4f (paper <= 19.6)" % (1 + 1 / (1 - math.exp(-1 / 18))))
# UB_n - tau_n H(1/3) = (2/3)(G - T/2)
for T, G in [(1, 0), (3, 5), (10, 2)]:
    tau = T + G
    ub = tau * L3 - T
    print("T=%d G=%d: UB - tau*H = %.6f ; (2/3)(G-T/2) = %.6f" % (T, G, ub - tau * H13, 2 / 3 * (G - T / 2)))

# ---------------------------------------------------------------------------
hdr("3. Eisenstat Monte Carlo with an independent P* (lem:ex:pstar): N_touch, L_P*, rule errors")

class Proc:
    def __init__(self, rng):
        self.rng = rng; self.b = []; self.rev = set()
        self.heads = []; self.tails = []   # revealed in order
    def bit(self, i):
        while len(self.b) <= i:
            self.b.append(1 if self.rng.random() < 1 / 3 else 0)
        return self.b[i]
    def frontiers(self):
        tau = (self.tails[-1] + 1) if self.tails else 0
        eta = (self.heads[-1] + 1) if self.heads else 0
        return tau, eta
    def g(self):
        i = 0
        while i in self.rev:
            i += 1
        return i
    def step(self):
        tau, eta = self.frontiers()
        if self.rng.random() < 2 / 3:      # head
            i = eta
            while True:
                if i not in self.rev and self.bit(i) == 1:
                    break
                i += 1
            lab = 1; self.heads.append(i)
        else:
            i = tau
            while True:
                if i not in self.rev and self.bit(i) == 0:
                    break
                i += 1
            lab = 0; self.tails.append(i)
        self.rev.add(i)
        return i, lab

def pstar_one(tau, eta, g, x):
    F = max(tau, eta)
    if x < F:
        return 0.0 if x < eta else 1.0
    if g < F:
        return 1.0 if tau <= eta else 0.0
    k = x - F
    return 2.0 ** k / (2.0 ** k + 1)

R = 20000; T = 120
tot_touch = 0; tot_loss = 0.0; tot_err = 0; noerr = 0; bad = 0
for r in range(R):
    pr = Proc(random.Random(random.getrandbits(64)))
    errs = 0
    for t in range(T):
        tau, eta = pr.frontiers(); g = pr.g(); F = max(tau, eta)
        touching = (g == F)
        x, lab = pr.step()
        q = pstar_one(tau, eta, g, x)
        pl = q if lab == 1 else 1 - q
        if pl <= 0:
            bad += 1
        else:
            tot_loss += -log2(pl)
        tot_touch += touching
        rule = 0 if x == g else 1
        if rule != lab:
            errs += 1
    tot_err += errs; noerr += (errs == 0)
print("runs=%d, T=%d: E N_touch = %.3f (limit 3), E L_P* = %.4f (limit 2.3986), E rule errors = %.3f (limit 2), P(no error) = %.4f (limit 1/2), zero-probability labels: %d"
      % (R, T, tot_touch / R, tot_loss / R, tot_err / R, noerr / R, bad))

# ---------------------------------------------------------------------------
hdr("4. prop:ex:law(a) by Monte Carlo (n=3): Pr[D_3=D] vs C(n,H)(2/9)^n r^(M-n)")
from collections import Counter
cnt = Counter(); RR = 400000
for r in range(RR):
    pr = Proc(random.Random(random.getrandbits(64)))
    D = []
    for t in range(3):
        D.append(pr.step())
    cnt[tuple(sorted(D))] += 1
worst = 0
rows = []
for D, c in cnt.most_common(12):
    H = sum(l for _, l in D); M = max(i for i, _ in D) + 1
    top = max(D)[1]; r_ = 2 / 3 if top == 1 else 1 / 3
    pf = math.comb(3, H) * (2 / 9) ** 3 * r_ ** (M - 3)
    se = math.sqrt(pf * (1 - pf) / RR)
    z = (c / RR - pf) / se
    worst = max(worst, abs(z)); rows.append((D, c / RR, pf, z))
for D, e, pf, z in rows[:6]:
    print("D=%s empirical %.5f formula %.5f z=%.2f" % (D, e, pf, z))
print("max |z| over the 12 most frequent data sets: %.2f" % worst)
# the counterexample of the paper: S={0,1,3}: labellings (0,1,1) and (1,1,0)
Z = ((2 / 3) + (1 / 3)) * math.comb(5, 2)
print("S={0,1,3}: Z(S)=%g; Pr[(0,1,1)|S]=%g, Pr[(1,1,0)|S]=%g" % (Z, 3 * (2 / 3) / Z, 3 * (1 / 3) / Z))

# ---------------------------------------------------------------------------
hdr("5. GF(2^q) (lem:hist:charsum, thm:hist:gf)")
def gf_mul(a, b, q, poly):
    r = 0
    for i in range(q):
        if (b >> i) & 1:
            r ^= a << i
    for i in range(2 * q - 2, q - 1, -1):
        if (r >> i) & 1:
            r ^= poly << (i - q)
    return r
q = 2; poly = 0b111   # x^2+x+1, the lexicographically least irreducible of degree 2
F_ = list(range(4))
best = 0
for img in itertools.product(list(range(4)) + [None], repeat=4):
    n_ = 0
    for a_, b_ in itertools.permutations(F_, 2):
        if img[a_] is not None and img[b_] is not None and (img[a_] ^ img[b_]) == gf_mul(a_, b_, q, poly):
            n_ += 1
    best = max(best, n_)
print("q=2: max_G N(G) over all 625 partial G = %d ; bound 2^q+2^{3q/2} = %g" % (best, 2 ** q + 2 ** (1.5 * q)))
ok = all(log2(2 ** (2 * qq) * (2 ** qq - 1)) - 1.5 * qq - 1 >= 1.5 * qq - 2 - 1e-12 for qq in range(1, 60))
print("Jensen step log(2^{2q}(2^q-1)) - 3q/2 - 1 >= 3q/2 - 2 for q=1..59: %s" % ok)
# exact directed information of the GF process (random order), marker value 0 off {a,b}
def gf_directed_info(q, poly, marker=0):
    Fq = list(range(2 ** q))
    joint = Counter()   # (f, x1, y1, x2) -> prob
    w = Fr(1, len(Fq) * (len(Fq) - 1) * len(Fq) * 2)
    for a_, b_ in itertools.permutations(Fq, 2):
        for r_ in Fq:
            f = [marker] * len(Fq); f[a_] = r_; f[b_] = r_ ^ gf_mul(a_, b_, q, poly); f = tuple(f)
            for (u, v) in [(a_, b_), (b_, a_)]:
                joint[(f, u, f[u], v)] += w
    def H(marg):
        return -sum(float(p) * log2(float(p)) for p in marg.values() if p > 0)
    def marg(keys):
        m = Counter()
        for k_, p_ in joint.items():
            m[tuple(k_[i] for i in keys)] += p_
        return m
    # I(f;x1) + I(f;x2 | x1,y1) = [H(x1)-H(x1|f)] + [H(x2|x1,y1) - H(x2|f,x1,y1)]
    Hx1 = H(marg([1])); Hfx1 = H(marg([0, 1])); Hf = H(marg([0]))
    Hx1y1x2 = H(marg([1, 2, 3])); Hx1y1 = H(marg([1, 2]))
    Hfx1y1x2 = H(marg([0, 1, 2, 3])); Hfx1y1 = H(marg([0, 1, 2]))
    I1 = Hx1 - (Hfx1 - Hf)
    I2 = (Hx1y1x2 - Hx1y1) - (Hfx1y1x2 - Hfx1y1)
    return I1, I2
for qq, pp in [(2, 0b111), (3, 0b1011)]:
    I1, I2 = gf_directed_info(qq, pp)
    print("q=%d: I(f;x1)=%.4f, I(f;x2|h1)=%.4f, I(f->x)=%.4f ; notes' closed form (q-1)+log(2^q-1)=%.4f ; 2q=%d"
          % (qq, I1, I2, I1 + I2, qq - 1 + log2(2 ** qq - 1), 2 * qq))

# ---------------------------------------------------------------------------
hdr("6. Small arithmetic facts used in hist")
ok = all(log2(math.comb(n, n // 2)) >= n - log2(n + 1) - 1e-12 for n in range(2, 3000))
print("log C(n,floor(n/2)) >= n - log(n+1) for 2<=n<3000: %s" % ok)
print("sum_{t=2}^{n}(t-1) = n(n-1)/2 for n=50: %d vs %d" % (sum(t - 1 for t in range(2, 51)), 50 * 49 // 2))
# Lipschitz step of the minimax proof: |log G - log G'| <= |Y|^n ||G0-G0'||_1 / ln2 when both >= 1/2 |Y|^-n
Y_, n_ = 2, 3
G = 0.5 * Y_ ** -n_; Gp = G + 0.5 * 0.01
print("Lipschitz example: |log G-log G'| = %.5f <= %.5f" % (abs(log2(Gp) - log2(G)), Y_ ** n_ * 0.01 / math.log(2)))
# sum_{t<N}(d-K(t))^+ <= 2N via counting: sum_{i>=1} 2^{d-i+1} = 2N
dd_ = 10
print("sum_{i>=1} 2^{d-i+1} for d=10: %d = 2N = %d" % (sum(2 ** (dd_ - i + 1) for i in range(1, dd_ + 1)), 2 * 2 ** dd_))

# ---------------------------------------------------------------------------
hdr("7. prop:hist:lhg (LHG-odd construction): is the sequence consistent?")
omega = [random.randint(0, 1) for _ in range(40)]
xs = [0] + omega[:-1]       # x_1 = 0, x_{i+1} = y_i
ys = omega                  # y_i = omega_i
lab = {}
incons = None
for i, (xx, yy) in enumerate(zip(xs, ys)):
    if xx in lab and lab[xx] != yy:
        incons = i + 1; break
    lab[xx] = yy
print("X=Y={0,1}, x_1=0, x_{i+1}=y_i, y_i=omega_i: first inconsistency at step %s (input %d gets two labels)" % (incons, xs[incons - 1] if incons else -1))
print("(even construction x_i=omega_i, y_i=x_i is consistent: identity function)")

# ---------------------------------------------------------------------------
hdr("8. prop:hist:sketchfails: P vs private-randomness simulator (exact)")
P_loss = -log2(Fr(1, 2)) - log2(1)
sim_prob = Fr(1, 2) * Fr(1, 2)     # g(a), g(b) independent uniform
print("P's loss = %.1f bit ; private simulator's loss = %.1f bits ; mixture of constants = %.1f bit" % (P_loss, -log2(sim_prob), -log2(Fr(1, 2))))
