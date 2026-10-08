"""r6 (referee): Remark 1.10 and Prop 2.5 of notes.md, propositional fragment (A1-A3, MP), independent implementation.

Remark 1.10: "A stronger theory has more short theorems, hence a larger Z_T, hence a smaller P_T(s) on each datum."
Test with T = {a, a->b} and T' = T + {b} (inst(T) is a subset of inst(T'), same theorems):
  (i)  the normalised graded score P_T(s) = 2^(-kappa l_T(s)) / Z_T over a finite universe U of formulas (size <= 7),
       l_T(s) = least tree size of an MP-derivation inside U (sum of formula sizes over the tree);
  (ii) the bounded-depth derivation grammar L2 (depth 2), as in the notes.
Prop 2.5: P_{T1}(b) >= a_ax/2 and P_{T2}(b) <= a_r/(1-a_r) for T1 = {a, b}, T2 = {a, a->b}; checked under (ii).
"""
import itertools
from collections import defaultdict

out = []
A, B = ('a',), ('b',)
def imp(x, y): return ('>', x, y)
def neg(x): return ('~', x)
def size(f): return 1 + sum(size(c) for c in f[1:])

# universe of formulas of size <= NMAX over atoms a, b with ~ and ->
NMAX = 7
by = {1: [A, B]}
for n in range(2, NMAX + 1):
    fs = [neg(x) for x in by[n - 1]]
    for k in range(1, n - 1):
        fs += [imp(x, y) for x in by[k] for y in by[n - 1 - k]]
    by[n] = fs
U = [f for n in by for f in by[n]]
Uset = set(U)
out.append(f"universe: {len(U)} formulas of size <= {NMAX}")

# logical axiom instances inside U
def is_A1(f):
    return f[0] == '>' and f[2][0] == '>' and f[2][2] == f[1]
def is_A2(f):
    if f[0] != '>' or f[1][0] != '>' or f[2][0] != '>':
        return False
    l, r = f[1], f[2]
    if l[2][0] != '>' or r[1][0] != '>' or r[2][0] != '>':
        return False
    Bf, C, D = l[1], l[2][1], l[2][2]
    return r[1] == imp(Bf, C) and r[2] == imp(Bf, D)
def is_A3(f):
    if f[0] != '>' or f[1][0] != '>' or f[2][0] != '>':
        return False
    l, r = f[1], f[2]
    if l[1][0] != '~' or l[2][0] != '~' or r[1][0] != '>':
        return False
    C, Bf = l[1][1], l[2][1]
    return r[1] == imp(neg(C), Bf) and r[2] == C
LOG = {f for f in U if is_A1(f) or is_A2(f) or is_A3(f)}
out.append(f"logical axiom instances in the universe: {len(LOG)}")

# MP pairs inside U: for each s, the A with A and A->s in U
pairs = defaultdict(list)
for f in U:
    if f[0] == '>' and f[1] in Uset:
        pairs[f[2]].append((f[1], f))

def least_sizes(T):
    INF = float('inf')
    l = {f: (size(f) if (f in LOG or f in T) else INF) for f in U}
    changed = True
    while changed:
        changed = False
        for s in U:
            best = l[s]
            for Af, Imp in pairs.get(s, ()):
                c = l[Af] + l[Imp] + size(s)
                if c < best:
                    best = c
            if best < l[s]:
                l[s] = best
                changed = True
    return l

def graded(T, kappa=1.0):
    l = least_sizes(T)
    mu = {s: 2.0 ** (-kappa * l[s]) for s in U if l[s] < float('inf')}
    Z = sum(mu.values())
    return {s: v / Z for s, v in mu.items()}, l

T = [A, imp(A, B)]
T2 = [A, imp(A, B), B]
for kappa in (0.5, 1.0):
    PT, lT = graded(set(T), kappa)
    PT2, lT2 = graded(set(T2), kappa)
    higher = [s for s in PT if PT2.get(s, 0) > PT[s] * (1 + 1e-12)]
    lower = [s for s in PT if PT2.get(s, 0) < PT[s] * (1 - 1e-12)]
    out.append(f"(i) kappa = {kappa}: l_T(b) = {lT[B]}, l_T'(b) = {lT2[B]}; P_T(b) = {PT[B]:.4e}, P_T'(b) = {PT2[B]:.4e}; "
               f"sentences with P_T' > P_T: {len(higher)}, with P_T' < P_T: {len(lower)}")

# (ii) L2 (bounded depth), Q over formulas truncated to the universe of size <= 3, as a PCFG
pq = {'a': 0.3, 'b': 0.3, '~': 0.2, '>': 0.2}
def qp(f):
    r = pq[f[0]]
    for c in f[1:]:
        r *= qp(c)
    return r
small = [f for f in U if size(f) <= 3]
zq = sum(qp(f) for f in small)
Q = {f: qp(f) / zq for f in small}
QL = defaultdict(float)
for x, y in itertools.product(small, repeat=2):
    QL[imp(x, imp(y, x))] += Q[x] * Q[y] / 3
    QL[imp(imp(neg(y), neg(x)), imp(imp(neg(y), x), y))] += Q[x] * Q[y] / 3
for x, y, z in itertools.product(small, repeat=3):
    QL[imp(imp(x, imp(y, z)), imp(imp(x, y), imp(x, z)))] += Q[x] * Q[y] * Q[z] / 3

def L2(theory, a_ax, a_lg, a_mp, depth):
    def cite(sa, sl):
        m = defaultdict(float)
        for s in theory:
            m[s] += sa / len(theory)
        for s, w in QL.items():
            m[s] += sl * w
        return m
    mu = cite(a_ax / (a_ax + a_lg), a_lg / (a_ax + a_lg))
    for _ in range(depth):
        new = cite(a_ax, a_lg)
        for f, w in list(mu.items()):
            if f[0] == '>' and f[1] in mu:
                new[f[2]] += a_mp * mu[f[1]] * w
        mu = new
    Z = sum(mu.values())
    return {s: w / Z for s, w in mu.items()}

for a_ax, a_lg, a_mp in ((0.7, 0.2, 0.1), (0.6, 0.25, 0.15), (0.4, 0.3, 0.3)):
    P1 = L2([A, B], a_ax, a_lg, a_mp, 2)
    P2 = L2([A, imp(A, B)], a_ax, a_lg, a_mp, 2)
    P3 = L2([A, imp(A, B), B], a_ax, a_lg, a_mp, 2)
    region = a_ax / 2 > a_mp / (1 - a_mp)
    out.append(f"(ii) a = ({a_ax},{a_lg},{a_mp}) depth 2: P_T1(b) = {P1.get(B, 0):.4f} >= a_ax/2 = {a_ax/2:.3f}: "
               f"{P1.get(B, 0) >= a_ax / 2}; P_T2(b) = {P2.get(B, 0):.4f} <= a_r/(1-a_r) = {a_mp/(1-a_mp):.3f}: "
               f"{P2.get(B, 0) <= a_mp / (1 - a_mp)}; in proved region: {region};  "
               f"T = T2, T' = T2+{{b}}: P_T(b) = {P2.get(B, 0):.4f} < P_T'(b) = {P3.get(B, 0):.4f}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
