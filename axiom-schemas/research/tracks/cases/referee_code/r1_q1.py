# Referee, track "cases", Part 1 (Q1).  Independent code: own anti-unification, own matching,
# own term generators.  Nothing is imported from the author's files or from the T1 code.
#
#  (1) Thm A2: lgg(D) == sigma_phi  <=>  (R_i) for all i and (D_ii') for all i<i', on RANDOM formulas
#      phi over {0,S,+,*,=,not,and,all,ex} (named encoding) with 1..3 free variables, some inside the
#      scope of binders, some of them occurring several times, with closed subterms of phi drawn from the
#      same pool as the data terms; random data sets of size 1..4.
#  (2) Capture: phi(x) = ex y not(y = x).  The unguarded lgg of two closed instances is ex y not(y = z);
#      in the named encoding its instance set contains the capture instance ex y not(y=y) (false in
#      every structure), which is not a closed instance of phi.  Same in a de Bruijn first-order encoding
#      (z := #0).  So inst(sigma_phi) != inst_c(phi) when x is in the scope of a binder, unless z ranges
#      over variable-free terms only (or a "free for" / closedness guard is present).
#  (3) Prop A2' SO-degree counterexample T = f(S0)+f(0) = f(S0): brute force over all bodies beta of size
#      <= 7 (one hole).
#  (4) Ex. A8: own implementation of the model of Q, axioms checked on {0..60} u {a,b}.
#  (5) Thm A3(b): the exact two-variable formula for a NON-i.i.d. joint law (t2 = t1 with prob. 0.3),
#      against Monte Carlo with the own lgg.
import itertools, random, math, sys
from functools import lru_cache

# ---------------- terms ----------------
# ground/schema terms are tuples (head, *children); metavariables ('?', name)
def is_mv(t): return t[0] == '?'

def au(ts, table):
    """Reynolds/Plotkin anti-unification of a list of terms (own implementation)."""
    h0 = ts[0][0]; n0 = len(ts[0])
    if not any(is_mv(t) for t in ts) and all(t[0] == h0 and len(t) == n0 for t in ts):
        if n0 == 1:
            return ts[0]
        return (h0,) + tuple(au([t[i] for t in ts], table) for i in range(1, n0))
    key = tuple(ts)
    if key not in table:
        table[key] = ('?', 'g%d' % len(table))
    return table[key]

def lgg(ts): return au(list(ts), {})

def match(pat, t, sub=None):
    if sub is None: sub = {}
    if is_mv(pat):
        if pat in sub: return sub if sub[pat] == t else None
        sub[pat] = t; return sub
    if pat[0] != t[0] or len(pat) != len(t): return None
    for a, b in zip(pat[1:], t[1:]):
        if match(a, b, sub) is None: return None
    return sub

def equiv(a, b):
    sa = match(a, b, {}); sb = match(b, a, {})
    if sa is None or sb is None: return False
    # renaming: values of sa must be distinct metavariables
    return all(is_mv(v) for v in sa.values()) and len(set(sa.values())) == len(sa)

# ---------------- PA-language formulas, named encoding ----------------
ZERO = ('0',)
def S(t): return ('S', t)
def PL(a, b): return ('+', a, b)
def TI(a, b): return ('*', a, b)
def EQ(a, b): return ('=', a, b)
def NOT(f): return ('~', f)
def AND(f, g): return ('&', f, g)
def ALL(v, f): return ('A', v, f)
def EX(v, f): return ('E', v, f)
VARN = [('v_x%d' % i,) for i in range(3)]   # free variables x0,x1,x2 (names)
BND = [('v_y',), ('v_w',)]                  # names used by binders inside phi

def closed_terms(maxsize):
    by = {1: [ZERO]}
    for s in range(2, maxsize + 1):
        out = [S(t) for t in by[s - 1]]
        for a in range(1, s - 1):
            b = s - 1 - a
            for x in by[a]:
                for y in by[b]:
                    out.append(PL(x, y)); out.append(TI(x, y))
        by[s] = out
    return [t for s in sorted(by) for t in by[s]]

POOL = closed_terms(4)

def rand_term(rng, k, bound, d):
    r = rng.random()
    if d <= 0 or r < 0.45:
        choices = [ZERO] + VARN[:k] + list(bound) + [rng.choice(POOL)]
        return rng.choice(choices)
    if r < 0.65: return S(rand_term(rng, k, bound, d - 1))
    f = PL if r < 0.85 else TI
    return f(rand_term(rng, k, bound, d - 1), rand_term(rng, k, bound, d - 1))

def rand_formula(rng, k, bound, d):
    r = rng.random()
    if d <= 0 or r < 0.35:
        return EQ(rand_term(rng, k, bound, 2), rand_term(rng, k, bound, 2))
    if r < 0.5: return NOT(rand_formula(rng, k, bound, d - 1))
    if r < 0.75: return AND(rand_formula(rng, k, bound, d - 1), rand_formula(rng, k, bound, d - 1))
    v = rng.choice(BND)
    Q = ALL if rng.random() < 0.5 else EX
    return Q(v, rand_formula(rng, k, bound + [v], d - 1))

def free_occ(f, v):
    if f == v: return True
    if len(f) == 1: return False
    if f[0] in ('A', 'E') and f[1] == v: return False
    return any(free_occ(a, v) for a in f[1:])

def subst(f, v, t):
    if f == v: return t
    if len(f) == 1 or is_mv(f): return f
    if f[0] in ('A', 'E') and f[1] == v: return f
    return (f[0],) + tuple(subst(a, v, t) for a in f[1:])

def inst(phi, ts):
    for i, t in enumerate(ts): phi = subst(phi, VARN[i], t)
    return phi

def sigma(phi, k): return inst(phi, [('?', 'z%d' % i) for i in range(k)])

def R_ok(D, i): return len({ts[i][0] for ts in D}) >= 2
def D_ok(D, i, j): return any(ts[i] != ts[j] for ts in D)

print('(1) Thm A2 on random formulas (own lgg)')
rng = random.Random(20261007)
tot = agree = rec = 0; nphi = 0; bad = []
scoped = 0
while nphi < 600:
    k = rng.choice([1, 1, 2, 2, 3])
    phi = rand_formula(rng, k, [], 4)
    if not all(free_occ(phi, VARN[i]) for i in range(k)): continue
    nphi += 1
    sig = sigma(phi, k)
    for _ in range(60):
        N = rng.choice([1, 2, 2, 3, 4])
        small = POOL[:12]
        D = [tuple(rng.choice(small) for _ in range(k)) for _ in range(N)]
        # bias towards collisions / shared roots
        if rng.random() < 0.3 and k >= 2:
            D = [(ts[0],) + ts[1:] if rng.random() < 0.5 else (ts[0],) * k for ts in D]
        L = lgg([inst(phi, ts) for ts in D])
        got = equiv(L, sig)
        pred = all(R_ok(D, i) for i in range(k)) and all(D_ok(D, i, j) for i in range(k) for j in range(i + 1, k))
        tot += 1; agree += (got == pred); rec += got
        if got != pred and len(bad) < 5: bad.append((phi, D, L))
print('   formulas %d, data sets %d, agreement %d, recovering %d, disagreements %s' % (nphi, tot, agree, rec, bad[:2]))

print('\n(2) capture in the named and de Bruijn first-order encodings')
X0 = VARN[0]; Yb = ('v_y',)
phi = EX(Yb, NOT(EQ(Yb, X0)))
L = lgg([inst(phi, [ZERO]), inst(phi, [S(ZERO)])])
print('   lgg of phi(0), phi(S0):', L)
cap = EX(Yb, NOT(EQ(Yb, Yb)))
print('   capture sentence ex y ~(y=y) matches the lgg:', match(L, cap, {}) is not None,
      '| it is a closed instance phi(t) for a variable-free t:', any(inst(phi, [t]) == cap for t in POOL))
# de Bruijn first-order: phi = E ~(#0 = z)
phidb = lambda t: ('E', ('~', ('=', ('#0',), t)))
Ldb = lgg([phidb(ZERO), phidb(S(ZERO))])
capdb = phidb(('#0',))
print('   de Bruijn lgg:', Ldb, ' capture E ~(#0=#0) matches:', match(Ldb, capdb, {}) is not None)

print('\n(3) SO-degree counterexample T = f(S0) + f(0) = f(S0) (f unary term metavariable, ground args)')
HOLE = ('h',)
def bodies(maxsize):
    by = {1: [ZERO, HOLE]}
    for s in range(2, maxsize + 1):
        out = [S(t) for t in by[s - 1]]
        for a in range(1, s - 1):
            for x in by[a]:
                for y in by[s - 1 - a]:
                    out.append(PL(x, y)); out.append(TI(x, y))
        by[s] = out
    return [t for s in by for t in by[s]]
def plugb(b, a):
    if b == HOLE: return a
    if len(b) == 1: return b
    return (b[0],) + tuple(plugb(c, a) for c in b[1:])
def covers(n):   # does T cover S^n 0 + 0 = S^n 0 ?
    t = ZERO
    for _ in range(n): t = S(t)
    return [b for b in BS if plugb(b, S(ZERO)) == t and plugb(b, ZERO) == ZERO]
BS = bodies(7)
print('   bodies enumerated (size<=7):', len(BS))
for n in range(4):
    w = covers(n)
    print('   n=%d: covering bodies %d  e.g. %s' % (n, len(w), w[:2]))

print('\n(4) Ex. A8: model of Q on N u {a,b} (own implementation)')
a, b = 'a', 'b'
def Sx(x): return x + 1 if isinstance(x, int) else x
def ad(x, y):
    if isinstance(x, int) and isinstance(y, int): return x + y
    if isinstance(y, int): return x
    if isinstance(x, int): return b
    return a if x == a else b
def mu_(x, y):
    if isinstance(x, int) and isinstance(y, int): return x * y
    if y == 0: return 0
    if isinstance(y, int): return b          # a*n = b*n = b, n >= 1
    if x == 0: return 0
    return a                                 # n*a=n*b=a (n>=1), a*a=a*b=b*a=b*b=a
Dom = list(range(61)) + [a, b]
fails = []
for x in Dom:
    if Sx(x) == 0: fails.append(('Q1', x))
    if x != 0 and not any(Sx(y) == x for y in Dom): fails.append(('Q3', x))
    if ad(x, 0) != x: fails.append(('Q4', x))
    if mu_(x, 0) != 0: fails.append(('Q6', x))
    for y in Dom:
        if x != y and Sx(x) == Sx(y): fails.append(('Q2', x, y))
        if ad(x, Sx(y)) != Sx(ad(x, y)): fails.append(('Q5', x, y))
        if mu_(x, Sx(y)) != ad(mu_(x, y), x): fails.append(('Q7', x, y))
print('   violations:', len(fails), fails[:3], ' 0+a =', ad(0, a), ' 0+b =', ad(0, b))
print('   note Q3 at x>60 needs predecessor x-1 (standard); a = S a, b = S b.')

print('\n(5) Thm A3(b) for a non-i.i.d. joint law (own lgg Monte Carlo)')
PR = {'0': 0.4, 'S': 0.3, '+': 0.2, '*': 0.1}
@lru_cache(None)
def law(d):
    if d >= 2: return {ZERO: 1.0}
    out = {ZERO: PR['0']}
    sub = law(d + 1)
    for t, p in sub.items(): out[S(t)] = out.get(S(t), 0) + PR['S'] * p
    for f, c in (('+', PL), ('*', TI)):
        for x, px in sub.items():
            for y, py in sub.items():
                out[c(x, y)] = out.get(c(x, y), 0) + PR[f] * px * py
    return out
mu = law(0)
items = list(mu.items())
TIE = 0.3
joint = {}
for t1, p1 in items:
    joint[(t1, t1)] = joint.get((t1, t1), 0) + TIE * p1
    for t2, p2 in items:
        joint[(t1, t2)] = joint.get((t1, t2), 0) + (1 - TIE) * p1 * p2
roots = list(PR)
A_ = {f: sum(p for (x, y), p in joint.items() if x[0] == f) for f in roots}
B_ = {g: sum(p for (x, y), p in joint.items() if y[0] == g) for g in roots}
c_ = sum(p for (x, y), p in joint.items() if x == y)
d_ = {(f, g): sum(p for (x, y), p in joint.items() if x[0] == f and y[0] == g) for f in roots for g in roots}
e_ = {f: sum(p for (x, y), p in joint.items() if x == y and x[0] == f) for f in roots}
def exact(N):
    return (sum(v ** N for v in A_.values()) + sum(v ** N for v in B_.values()) + c_ ** N
            - sum(v ** N for v in d_.values()) - sum(v ** N for v in e_.values()))
keys = list(joint); probs = [joint[k] for k in keys]; cum = list(itertools.accumulate(probs))
phi2 = EQ(PL(VARN[0], VARN[1]), PL(VARN[1], VARN[0]))
sig2 = sigma(phi2, 2)
rng = random.Random(7)
TR = 20000
for N in (2, 3, 4, 6, 8):
    f = 0
    for _ in range(TR):
        D = rng.choices(keys, cum_weights=cum, k=N)
        f += not equiv(lgg([inst(phi2, list(ts)) for ts in D]), sig2)
    print('   N=%2d exact %.5f  MC %.5f  (+-%.5f)' % (N, exact(N), f / TR, 2 * math.sqrt(max(exact(N) * (1 - exact(N)), 1e-9) / TR)))
