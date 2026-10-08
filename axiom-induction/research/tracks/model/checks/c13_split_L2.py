"""c13: a schema against its root split under a derivation likelihood with latent citations (referee issue M3;
notes-final Prop 5.6).

Model (finite, exact).  Propositional fragment with atom a, connectives not and imp; bounded-depth derivation grammar
L2 (depth 2): a node at depth < 2 cites a theory axiom (alpha_ax), cites a logical axiom (alpha_lg; A1, A2, A3 chosen
uniformly, metavariables i.i.d. from Q_L = PCFG (a .5, not .25, imp .25) truncated to size <= 5) or applies MP (alpha_mp; two children: minor A and
major A -> B); at depth 2 a node cites (alpha_ax, alpha_lg renormalised).  P = mu / Z.
  Whole schema   tau   = F -> F,  F = a with probability u, F = not G with probability 1 - u, G ~ Q_G on {a, not a}.
  Root split     tau_a = a -> a,  tau_not = not G -> not G, with Dirichlet(1/2, 1/2) weights (w_a, w_not).
Prop 5.6(a): the split with weights (w_a, w_not) has exactly the law of the whole schema with root law u = w_a, so
  ln BF_n := ln P^Dir_split(D) - ln P_whole(D) = ln int prod_i P_u(x_i)/P_p(x_i) Beta(u; 1/2, 1/2) du,
where p is the whole schema's fixed root law.  a -> a and not a -> not a are also derivable from the logical axioms
(the depth-2 proof of F -> F), so citations are latent.  mu_u(x) is a polynomial in u of degree <= 4; we compute its
coefficients exactly, then integrate on the arcsine grid u = sin^2(pi y / 2) (y uniform <=> u ~ Beta(1/2, 1/2)).
Checks:
  A. the exact identity of Prop 5.6(a) (direct split computation with weights (u, 1-u) against the whole with root law u);
  B. well specified (data from P_p): mean ln BF_n against ln n (conjecture: slope -(K-1)/2 = -1/2);
  C. misspecified usage (data from P_r, r != p): ln BF_n / n against KL(P_r || P_p) (Prop 5.6(c), proved);
  D. Ville (Prop 5.6(b), proved): P(max_{n <= N} BF_n >= 1/eta) <= eta under P_p, every n checked.
"""
import itertools
import math
import numpy as np
from collections import defaultdict
from scipy.special import logsumexp

out = []
rng = np.random.default_rng(1313)

A = ('a',)
def neg(x): return ('~', x)
def imp(x, y): return ('>', x, y)

def fsize(f):
    return 1 + sum(fsize(c) for c in f[1:])

def formulas(maxsize):
    by = {1: [A]}
    for n in range(2, maxsize + 1):
        fs = [neg(x) for x in by[n - 1]]
        for k in range(1, n - 1):
            fs += [imp(x, y) for x in by[k] for y in by[n - 1 - k]]
        by[n] = fs
    return [f for n in by for f in by[n]]

QW = {'a': 0.5, '~': 0.25, '>': 0.25}
def qw(f):
    r = QW[f[0]]
    for c in f[1:]:
        r *= qw(c)
    return r
_fs = formulas(5)
_z = sum(qw(f) for f in _fs)
QL = {f: qw(f) / _z for f in _fs}          # logical-axiom instantiation law: PCFG truncated to size <= 5
QG = {A: 0.7, neg(A): 0.3}
AX, LG, MP = 0.5, 0.3, 0.2
DEG = 5        # polynomial coefficients in u, degree <= 4

def poly(c0=0.0, c1=0.0):
    p = np.zeros(DEG)
    p[0], p[1] = c0, c1
    return p

def pmul(p, q):
    r = np.convolve(p, q)
    assert np.all(np.abs(r[DEG:]) < 1e-300), 'degree overflow'
    return r[:DEG]

# logical axiom instance law
LOGI = defaultdict(float)
for f, g in itertools.product(QL, repeat=2):
    LOGI[imp(f, imp(g, f))] += QL[f] * QL[g] / 3
    LOGI[imp(imp(neg(g), neg(f)), imp(imp(neg(g), f), g))] += QL[f] * QL[g] / 3
for f, g, h in itertools.product(QL, repeat=3):
    LOGI[imp(imp(f, imp(g, h)), imp(imp(f, g), imp(f, h)))] += QL[f] * QL[g] * QL[h] / 3

def theory_cite_whole():
    """Law of a citation of the whole schema with root law u, as polynomials in u."""
    m = {imp(A, A): poly(0.0, 1.0)}                       # u
    for g, q in QG.items():
        m[imp(neg(g), neg(g))] = poly(q, -q)              # (1 - u) q
    return m

def theory_cite_split(wa):
    """Law of a citation of the split with fixed weights (wa, 1 - wa), as plain numbers."""
    m = {imp(A, A): wa}
    for g, q in QG.items():
        m[imp(neg(g), neg(g))] = (1 - wa) * q
    return m

def L2_poly(depth=2):
    th = theory_cite_whole()
    def cite(sa, sl):
        m = defaultdict(lambda: np.zeros(DEG))
        for s, p in th.items():
            m[s] = m[s] + sa * p
        for s, w in LOGI.items():
            m[s] = m[s] + poly(sl * w)
        return m
    mu = cite(AX / (AX + LG), LG / (AX + LG))
    for _ in range(depth):
        new = cite(AX, LG)
        for f, w in list(mu.items()):
            if f[0] == '>' and f[1] in mu:
                new[f[2]] = new[f[2]] + MP * pmul(mu[f[1]], w)
        mu = new
    return mu

def L2_split_numeric(wa, depth=2):
    th = theory_cite_split(wa)
    def cite(sa, sl):
        m = defaultdict(float)
        for s, p in th.items():
            m[s] += sa * p
        for s, w in LOGI.items():
            m[s] += sl * w
        return m
    mu = cite(AX / (AX + LG), LG / (AX + LG))
    for _ in range(depth):
        new = cite(AX, LG)
        for f, w in list(mu.items()):
            if f[0] == '>' and f[1] in mu:
                new[f[2]] += MP * mu[f[1]] * w
        mu = new
    return mu

mu = L2_poly()
X = sorted(mu, key=repr)
C = np.array([mu[x] for x in X])                          # (#X, DEG)
out.append(f"model: {len(X)} possible conclusions; logical axiom instances: {len(LOGI)}; alpha = ({AX}, {LG}, {MP})")

def probs(u):
    """P_u(x) for all x, u an array."""
    V = np.vander(np.atleast_1d(u), DEG, increasing=True)  # (#u, DEG)
    M = C @ V.T                                            # (#X, #u)
    return M / M.sum(axis=0, keepdims=True)

# A: exact identity
maxd = 0.0
for wa in (0.1, 0.37, 0.8):
    s = L2_split_numeric(wa)
    zs = sum(s.values())
    pw = probs(np.array([wa]))[:, 0]
    for i, x in enumerate(X):
        maxd = max(maxd, abs(s.get(x, 0.0) / zs - pw[i]))
out.append(f"A: split with weights (u, 1-u) vs whole with root law u, u in {{0.1, 0.37, 0.8}}: max |P difference| = {maxd:.2e}")
ia, inot = X.index(imp(A, A)), X.index(imp(neg(A), neg(A)))
Zc = C.sum(axis=0)                                         # coefficients of Z(u)
def Zof(u):
    return float(np.polyval(Zc[::-1], u))
for uu in (0.5,):
    P_u = probs(np.array([uu]))[:, 0]
    one_a = AX * uu / Zof(uu)
    one_n = AX * (1 - uu) * QG[A] / Zof(uu)
    out.append(f"A: latent citations at u = {uu}: P(a->a) = {P_u[ia]:.5f}, of which one-node citations {one_a:.5f}; "
               f"P(~a->~a) = {P_u[inot]:.5f}, of which one-node citations {one_n:.5f}")
dep = int(np.sum(np.any(np.abs(C[:, 1:]) > 1e-15, axis=1)))
out.append(f"A: conclusions whose probability depends on u: {dep} of {len(X)}; max polynomial degree used: "
           f"{max(int(np.max(np.nonzero(np.abs(c) > 1e-15)[0])) if np.any(np.abs(c) > 1e-15) else 0 for c in C)}")

# group conclusions by the shape of mu_x(u): ln mu_x(u) = ln scale_x + ln shape(u)
scale = np.abs(C).max(axis=1)
shapes = {}
sidx = np.zeros(len(X), dtype=int)
for i in range(len(X)):
    key = tuple(np.round(C[i] / scale[i], 12))
    sidx[i] = shapes.setdefault(key, len(shapes))
S = np.array(list(shapes.keys()))                          # (#shapes, DEG)
out.append(f"   {len(X)} conclusions fall into {len(S)} polynomial shapes")

def lnshape(u):
    V = np.vander(u, DEG, increasing=True)
    return np.log(S @ V.T)                                 # (#shapes, #u)

def lnZ(u):
    return np.log(np.vander(u, DEG, increasing=True) @ Zc)

NY = 20000
y = (np.arange(NY) + 0.5) / NY
ugrid = np.sin(np.pi * y / 2) ** 2                         # u ~ Beta(1/2, 1/2) when y ~ U(0, 1)
LS, LZ = lnshape(ugrid), lnZ(ugrid)

def ln_bf_counts(counts, lPtrue):
    """ln int prod_x (P_u(x)/P_true(x))^{n_x} dBeta(1/2,1/2)(u)."""
    n = counts.sum()
    ns = np.bincount(sidx, weights=counts, minlength=len(S))
    const = float(counts @ (np.log(scale) - lPtrue))
    L = ns @ LS - n * LZ + const
    return float(logsumexp(L) - math.log(NY))

p_true = 0.6
Pp = probs(np.array([p_true]))[:, 0]
lPp = np.log(Pp)
# B: well specified
ns_ = [10**2, 10**3, 10**4, 10**5, 10**6]
REPS = 400
means = []
for n in ns_:
    vals = [ln_bf_counts(rng.multinomial(n, Pp).astype(float), lPp) for _ in range(REPS)]
    means.append(np.mean(vals))
slope = np.polyfit(np.log(ns_), means, 1)[0]
out.append("B: well specified (p_a = 0.6): mean ln BF_n at n = 1e2..1e6: " + ", ".join(f"{m:.3f}" for m in means)
           + f";  fitted slope vs ln n = {slope:.3f}  (conjecture: -0.5)")
slope_hi = np.polyfit(np.log(ns_[2:]), means[2:], 1)[0]
out.append(f"B: slope on n = 1e4..1e6 only: {slope_hi:.3f}")

# C: misspecified usage
r = 0.3
Pr = probs(np.array([r]))[:, 0]
KL = float(np.sum(Pr * (np.log(Pr) - lPp)))
rows = []
for n in (10**3, 10**4, 10**5):
    vals = [ln_bf_counts(rng.multinomial(n, Pr).astype(float), lPp) / n for _ in range(100)]
    rows.append((n, np.mean(vals)))
out.append(f"C: misspecified usage (data root law r_a = {r}, whole has p_a = {p_true}): KL(P_r || P_p) = {KL:.5f} nats; "
           "mean ln BF_n / n: " + ", ".join(f"n = {n}: {v:.5f}" for n, v in rows))

# D: Ville, every n <= N
NY2 = 2000
y2 = (np.arange(NY2) + 0.5) / NY2
u2 = np.sin(np.pi * y2 / 2) ** 2
LS2, LZ2 = lnshape(u2), lnZ(u2)
row = LS2[sidx] + (np.log(scale) - lPp)[:, None] - LZ2[None, :]   # ln P_u(x)/P_p(x), (#X, NY2)
R, N = 1000, 3000
maxes = []
for _ in range(R):
    xs = rng.choice(len(X), size=N, p=Pp)
    L = np.cumsum(row[xs], axis=0)
    maxes.append(float((logsumexp(L, axis=1) - math.log(NY2)).max()))
maxes = np.array(maxes)
for eta in (0.5, 0.2, 0.05):
    k = int((maxes >= math.log(1 / eta)).sum())
    out.append(f"D: eta = {eta}: P(max_(n <= {N}) BF_n >= 1/eta) = {k / R:.3f} ({k}/{R}); Ville bound {eta}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
