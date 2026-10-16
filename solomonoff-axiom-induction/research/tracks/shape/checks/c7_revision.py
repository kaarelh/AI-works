"""c7: checks for the revision of thread `shape` (after referee reports A and B).  Seed 20261016.
Writes c7_revision.out next to itself.  Uses the developer's shapelib.py (unit propagation, GF(2) algebra,
brute-force prime implicates); the referees' independent code (referee_code/) covers the same ground separately.

Item numbers refer to notes-final.md.

A  Lemma 1.5 for the chain law: false for m = 2 (counterexample), hypothesis holds for 3 <= m <= 8.
B  Theorem 7.1 (revised): the four counterexamples to the old "iff"; the 2-CNF "iff" on random 2-CNFs of prime
   implicates; the "only if" on random usable theories with wide clauses.
C  Proposition 3.1a (one round cannot use intermediate concepts): PI(S) plus a chain-encoded library with
   auxiliary variables loses UP_1-usability when any clause of PI(S) is deleted; simplex r=3,4 libraries are
   UP-usable but not UP_1-usable.
D  Proposition 3.8(a), (b) (depth): rounds needed by the chain encoding (exactly m-1) and by the balanced-tree
   encoding (<= 2 ceil(log2 m) - 1) of one parity law, exhaustive over all questions; the unbounded fan-in
   circuit of Lemma 3.5(b) built from these theories computes parity, with the stated gate and depth counts.
E  Remark 3.2a: simplex family with intermediate concepts: library sizes m(2m-4) (r >= 4), listing lengths (corrected
   integer code l_N(n) = |delta(n+1)|), rounds needed with chain and with balanced-tree encodings.
F  Proposition 4.2(b) (revised): non-trivial sound rules number m 2^(m-1); the unique minimal usable rule set.
G  Proposition 2.9a (d_* = 2): a single equivalence class of c variables needs exactly c clauses (directed cycle);
   separate classes add up; an anti-equivalence class.
H  Propositions 2.5 and 2.5a: for every d_*, the clauses contained in every UP-usable theory over X are
   exactly F_ind(S).
I  Proposition 3.2 (library size formula s(w)): construction vs formula, with weight-1 and weight-4 circuits.
J  Lemma 1.7 with l_N(n) = |delta(n+1)|: Kraft sum over all theories over 2 variables.
K  Section 3.2 computed fractions: the core answers a fraction of sampled questions, 5 systems per m.
L  Theorem 6.2(c): exact coupon-collector expectations n H_n and the corrected approximation.
M  Theorem 3.6 (revised hidden-state law, weight-1 and weight-3 functionals): dim = q+1; determined <=> XOR
   system unsatisfiable <=> g_* in span (all subsets, q = 3, 4); UP on PI(H_3) derives not-x_* iff unsat;
   every GKRS input (ordered triple, constant) maps to a coordinate of the law, and every coordinate is hit.
"""
import math
import random
import sys
import time
from itertools import combinations, product

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import *  # noqa: F401,F403

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


t0 = time.time()
P(f"# c7_revision.py  seed={SEED}  python={sys.version.split()[0]}")


# ------------------------------------------------------------------ helpers
def lit_str(L):
    v, s = L
    return f"x{v + 1}" if s == 1 else f"~x{v + 1}"


def cl_str(C):
    return "(" + " v ".join(lit_str(L) for L in C) + ")"


def chain_sols(m):
    """Ch_m = {x : x_1 <= ... <= x_m} as ints (bit i = x_{i+1})."""
    out = []
    for a in range(m + 1):  # x = 0^a 1^(m-a)
        x = 0
        for i in range(a, m):
            x |= 1 << i
        out.append(x)
    return out


def implied(sols, m, alpha):
    return law_implied(sols, m, alpha)


def usable_k(F, N, m, sols, k, alphas=None):
    return usable(F, N, m, sols, rounds=k, alphas=alphas)[0]


def proj(F, N, m):
    """Projection onto the base variables (brute force over all assignments; small N only)."""
    out = set()
    for z in range(1 << N):
        a = [(z >> v) & 1 for v in range(N)]
        if all(any(a[v] == s for v, s in C) for C in F):
            out.add(z & ((1 << m) - 1))
    return out


def elias_delta_len(n):
    assert n >= 1
    L = n.bit_length() - 1  # floor(log2 n)
    LL = (L + 1).bit_length() - 1
    return L + 2 * LL + 1


def lN(n):
    """corrected integer code: l_N(n) := |delta(n+1)| (codes 0)."""
    return elias_delta_len(n + 1)


def l_lst_clauses(F, m, mtot):
    w = math.ceil(math.log2(mtot)) if mtot > 1 else 1
    return lN(mtot - m) + lN(len(F)) + sum(lN(len(C)) + len(C) * (w + 1) for C in F)


def l_lst_linear(eqs, m, mtot):
    w = math.ceil(math.log2(mtot)) if mtot > 1 else 1
    return lN(mtot - m) + lN(len(eqs)) + sum(lN(popcount(u)) + popcount(u) * w + 1 for u, c in eqs)


def tree_encoding(T_vars, c, aux_start):
    """Balanced binary XOR tree for XOR(T_vars) = c; internal non-root nodes get fresh auxiliary variables."""
    w = len(T_vars)
    if w <= 3:
        return xor_clauses(T_vars, c), 0
    nxt = [aux_start]
    cls = []

    def build(vs):  # returns the variable carrying XOR(vs)
        if len(vs) == 1:
            return vs[0]
        h = len(vs) // 2
        a = build(vs[:h])
        b = build(vs[h:])
        y = nxt[0]
        nxt[0] += 1
        cls.extend(xor_clauses([a, b, y], 0))
        return y

    h = w // 2
    a = build(T_vars[:h])
    b = build(T_vars[h:])
    cls.extend(xor_clauses([a, b], c))
    return cls, nxt[0] - aux_start


def library(law, enc='chain', direct_upto=4):
    """Each circuit written directly if its weight <= direct_upto, otherwise by the given encoding."""
    F = []
    nxt = law.m
    for u in law.circuits():
        vs = [v for v in range(law.m) if u >> v & 1]
        if len(vs) <= direct_upto:
            F += xor_clauses(vs, law.const[u])
        else:
            cls, na = (chain_encoding if enc == 'chain' else tree_encoding)(vs, law.const[u], nxt)
            nxt += na
            F += cls
    return F, nxt


def circuit_questions(law):
    qs = []
    for u in law.circuits():
        vs = [v for v in range(law.m) if u >> v & 1]
        for j in vs:
            rest = [v for v in vs if v != j]
            for bits in product((0, 1), repeat=len(rest)):
                alpha = dict(zip(rest, bits))
                val = (law.const[u] + sum(bits)) % 2
                qs.append((alpha, (j, val)))
    return qs


def answers_all(F, N, qs, rounds=None):
    for alpha, (j, val) in qs:
        a = up(F, N, alpha, rounds)
        if a is None or a[j] != val:
            return False
    return True


def min_rounds(F, N, qs, kmax=40):
    for k in range(1, kmax + 1):
        if answers_all(F, N, qs, k):
            return k
    return None


def pi_of_law(law):
    out = []
    for u in law.circuits():
        out += parity_clauses(u, law.const[u], law.m)
    return out


def decomposable(law, u):
    for u2 in law.codewords:
        out = u2 & ~u
        if popcount(out) == 1 and u2 != u:
            u3 = u ^ u2
            if u3 and (u2 & u3) == out:
                return True
    return False


def F_ind(law):
    out = []
    for u in law.circuits():
        if not decomposable(law, u):
            out += parity_clauses(u, law.const[u], law.m)
    return out


# ------------------------------------------------------------------ A
P("== A: Lemma 1.5 for the chain law Ch_m")
m = 2
sols = chain_sols(2)
all_cl = [((0, 0), (1, 1)), ((0, 1), (1, 0)), ((0, 0),), ((0, 1),), ((1, 0),), ((1, 1),), ((0, 0), (1, 0)), ((0, 1), (1, 1))]
ncomp = nbad = 0
example = None
for mask in range(1 << len(all_cl)):
    F = [all_cl[i] for i in range(len(all_cl)) if mask >> i & 1]
    ok = True
    for alpha in all_partial_assignments(2):
        imp = implied(sols, 2, alpha)
        if imp is None or not imp:
            continue
        a = up(F, 2, alpha)
        if a is None or any(a[v] != s for v, s in imp):
            ok = False
            break
        # also: F u alpha satisfiable
        if not any(all(any((x >> v & 1) == s for v, s in C) for C in F) and all((x >> v & 1) == s for v, s in alpha.items()) for x in range(4)):
            ok = False
            break
    if ok:
        ncomp += 1
        p = proj(F, 2, 2)
        if p != set(sols):
            nbad += 1
            example = (F, sorted(p))
P(f"  m=2: theories over X (all {1 << len(all_cl)} subsets of the 8 non-tautological clauses) UP-compatible with Q(Ch_2): {ncomp}; with proj != Ch_2: {nbad}")
P(f"  counterexample: {[cl_str(C) for C in example[0]]}, proj = {['{:02b}'.format(x)[::-1] for x in example[1]]} (strings x1x2), Ch_2 = ['00','01','11']")
for m in range(2, 9):
    sols = chain_sols(m)
    solset = set(sols)
    nodet = []
    for x in sols:
        det = False
        for j in range(m):
            alpha = {v: (x >> v) & 1 for v in range(m) if v != j}
            imp = implied(sols, m, alpha)
            if imp and any(v == j for v, s in imp):
                det = True
                break
        if not det:
            nodet.append(''.join(str((x >> v) & 1) for v in range(m)))
    P(f"  m={m}: points of Ch_m with no coordinate determined by the others: {nodet}")

# ------------------------------------------------------------------ B
P("== B: Theorem 7.1 (revised)")


def spanner_ok(edges, m, k):
    """edges: set of (i,j) i<j. Is it a k-hop TC-spanner of the path on m vertices?"""
    INF = 10 ** 9
    for i in range(m):
        dist = {i: 0}
        frontier = [i]
        for step in range(1, k + 1):
            nf = []
            for a in frontier:
                for (p, q) in edges:
                    if p == a and q not in dist:
                        dist[q] = step
                        nf.append(q)
            frontier = nf
        for j in range(i + 1, m):
            if j not in dist:
                return False
    return True


def pi_inside(C):
    """prime implicates of Ch_m contained in clause C: pairs (i,j), i<j, with ~x_i and x_j in C."""
    neg = [v for v, s in C if s == 0]
    pos = [v for v, s in C if s == 1]
    return [(i, j) for i in neg for j in pos if i < j]


cexs = [
    (3, 1, [((0, 0), (1, 1)), ((1, 0), (2, 1)), ((0, 0), (1, 0), (2, 1))]),           # referee A, existential
    (4, 2, [((0, 0), (1, 1)), ((1, 0), (2, 1)), ((2, 0), (3, 1)), ((0, 1), (1, 0), (3, 1))]),  # referee A, forced
    (3, 1, [((0, 0), (1, 1)), ((0, 0), (2, 1)), ((1, 0), (0, 1), (2, 1))]),           # referee B, forced
    (4, 2, [((0, 0), (1, 1)), ((0, 0), (2, 1)), ((2, 0), (3, 1)), ((1, 0), (0, 1), (2, 1))]),  # referee B, forced
]
for m, k, F in cexs:
    sols = chain_sols(m)
    choices = [pi_inside(C) for C in F]
    reps_span = []
    for pick in product(*choices):
        reps_span.append(spanner_ok(set(pick), m, k))
    ok = usable_k(F, m, m, sols, k)
    P(f"  m={m} k={k} F={[cl_str(C) for C in F]}: UP_{k}-usable={ok}; replacements: {len(reps_span)}, of which k-hop spanners: {sum(reps_span)}")
# random 2-CNFs of prime implicates: usable <=> spanner
mism = tested = 0
for trial in range(600):
    m = rng.choice([4, 5, 6])
    k = rng.choice([1, 2, 3])
    pairs = [(i, j) for i in range(m) for j in range(i + 1, m)]
    E = set(rng.sample(pairs, rng.randint(m - 1, len(pairs))))
    F = [((i, 0), (j, 1)) for (i, j) in E]
    sols = chain_sols(m)
    u = usable_k(F, m, m, sols, k)
    s = spanner_ok(E, m, k)
    tested += 1
    mism += (u != s)
P(f"  random 2-CNFs of prime implicates (m=4..6, k=1..3): {tested} tested; usable != spanner in {mism}")
# only-if on random usable theories with wide clauses
n_usable = viol = 0
tries = 0
while n_usable < 60 and tries < 20000:
    tries += 1
    m = rng.choice([4, 5])
    k = rng.choice([1, 2])
    sols = chain_sols(m)
    solset = set(sols)
    pairs = [(i, j) for i in range(m) for j in range(i + 1, m)]
    F = []
    for _ in range(rng.randint(m, 3 * m)):
        i, j = rng.choice(pairs)
        C = {i: 0, j: 1}
        for v in range(m):
            if v not in C and rng.random() < 0.3:
                C[v] = rng.randint(0, 1)
        F.append(tuple(sorted(C.items())))
    F = list(set(F))
    if not usable_k(F, m, m, sols, k):
        continue
    n_usable += 1
    choices = [pi_inside(C) for C in F]
    for _ in range(10):
        pick = [rng.choice(ch) for ch in choices]
        if not spanner_ok(set(pick), m, k):
            viol += 1
P(f"  'only if': {n_usable} random usable theories with wide clauses (m=4,5; k=1,2), 10 random replacements each: non-spanner replacements {viol}")

# ------------------------------------------------------------------ C
P("== C: Proposition 3.1a: one round of propagation cannot use intermediate concepts")
cnt = 0
for trial in range(12):
    m = rng.choice([6, 7, 8])
    k = rng.choice([2, 3])
    law = AffineLaw(m, random_system(rng, m, k))
    PI = pi_of_law(law)
    L, N = library(law, 'chain', direct_upto=3)
    qs = circuit_questions(law)
    full = list({tuple(sorted(C)) for C in PI + L})
    ok_full = answers_all(full, N, qs, 1)
    breaks = 0
    for C0 in PI:
        C0 = tuple(sorted(C0))
        Fm = [C for C in full if C != C0]  # removes every copy of C0 (the library repeats short circuits)
        if not answers_all(Fm, N, qs, 1):
            breaks += 1
    P(f"  m={m} r={law.k} d*={law.dmin()}: PI ({len(PI)} clauses) u chain library ({len(L)} clauses, {N - m} aux): UP_1-usable={ok_full}; deleting one PI clause (all copies) breaks UP_1-usability in {breaks}/{len(PI)}")
for r in (3, 4):
    m = 2 ** r - 1
    rows = []
    for i in range(r):
        rows.append(sum(1 << (c - 1) for c in range(1, m + 1) if (c >> i) & 1))
    law = AffineLaw(m, [(row, 0) for row in rows])
    L, N = library(law, 'chain', direct_upto=3)
    qs = circuit_questions(law)
    if r == 4:
        qs_s = rng.sample(qs, 3000)
    else:
        qs_s = qs
    P(f"  simplex r={r} m={m}: chain library {len(L)} clauses, {N - m} aux; UP-usable on {len(qs_s)} minimal questions: {answers_all(L, N, qs_s)}; UP_1-usable: {answers_all(L, N, qs_s, 1)}")

# ------------------------------------------------------------------ D
P("== D: Proposition 3.8(a),(b): rounds needed by intermediate concepts for one parity law (all m 2^(m-1) questions)")
P("   m | chain: clauses, aux, rounds (claimed m-1 for m >= 4; m = 3 is written directly) | balanced tree: clauses, aux, rounds (bound 2 ceil(log2 m) - 1)")
for m in range(3, 11):
    law = AffineLaw(m, [((1 << m) - 1, 0)])
    qs = circuit_questions(law)
    Fc, nc = chain_encoding(list(range(m)), 0, m)
    Ft, nt = tree_encoding(list(range(m)), 0, m)
    kc = min_rounds(Fc, m + nc, qs)
    kt = min_rounds(Ft, m + nt, qs)
    P(f"  {m:2d} | {len(Fc)}, {nc}, {kc} ({m - 1}) | {len(Ft)}, {nt}, {kt} (<= {2 * math.ceil(math.log2(m)) - 1})")


def ac0_from_theory(F, N, k, inputs):
    """Unbounded fan-in AND/OR circuit of Lemma 3.5(b): rounds t = 1..k, per round one AND gate per (clause,
    literal) and one OR gate per literal.  inputs: set of literals that are circuit inputs.  Returns an
    evaluator (assignment of input literals -> set of literals derived) and the gate count and depth."""
    lits = [(v, s) for v in range(N) for s in (0, 1)]
    gates = k * (sum(len(C) for C in F) + len(lits))

    def evaluate(true_inputs):
        g = {L: (L in true_inputs) for L in lits}
        for t in range(k):
            g2 = dict(g)
            for C in F:
                for L in C:
                    if all(g[(v, 1 - s)] for (v, s) in C if (v, s) != L):
                        g2[L] = True
            g = g2
        return g
    return evaluate, gates, 2 * k


for m in range(4, 9):
    Ft, nt = tree_encoding(list(range(m)), 0, m)
    law = AffineLaw(m, [((1 << m) - 1, 0)])
    qs = circuit_questions(law)
    k = min_rounds(Ft, m + nt, qs)
    inputs = {(v, s) for v in range(1, m) for s in (0, 1)}
    ev, gates, depth = ac0_from_theory(Ft, m + nt, k, inputs)
    bad = 0
    for bits in product((0, 1), repeat=m - 1):
        g = ev({(v, bits[v - 1]) for v in range(1, m)})
        par = sum(bits) % 2
        if g[(0, 1)] != (par == 1) or g[(0, 0)] != (par == 0):
            bad += 1
    P(f"  circuit from the tree encoding, m={m}, k={k}: gates {gates} (= k(||F|| + 2N)), depth {depth}; computes x_1 = parity of x_2..x_m on all {2 ** (m - 1)} inputs: {bad == 0}")

# ------------------------------------------------------------------ E
P("== E: Remark 3.2a: simplex family with intermediate concepts")
P("   r  m | PI over X: clauses | chain library: clauses (m(2m-4)), aux, listing bits | GE core listing bits | ratio")
for r in range(3, 8):
    m = 2 ** r - 1
    w = (m + 1) // 2
    n_pi = m * 2 ** (w - 1)
    lib_cl = m * (4 * w - 6) if w >= 5 else m * 2 ** (w - 1)
    lib_aux = m * (w - 2) if w >= 5 else 0
    mtot = m + lib_aux
    lw = math.ceil(math.log2(mtot))
    # chain encoding: 4(w-2) clauses of width 3 and 2 clauses of width 2 per circuit
    if w >= 5:
        bits_lib = lN(lib_aux) + lN(lib_cl) + m * ((4 * (w - 2)) * (lN(3) + 3 * (lw + 1)) + 2 * (lN(2) + 2 * (lw + 1)))
    else:
        bits_lib = lN(0) + lN(lib_cl) + lib_cl * (lN(w) + w * (lw + 1))
    lwg = math.ceil(math.log2(m))
    bits_ge = lN(0) + lN(r) + r * (lN(w) + w * lwg + 1)
    P(f"  {r} {m:3d} | {n_pi} | {lib_cl} ({m * (2 * m - 4)}), {lib_aux}, {bits_lib} | {bits_ge} | {bits_lib / bits_ge:.1f}")
for r in (3, 4):
    m = 2 ** r - 1
    rows = [sum(1 << (c - 1) for c in range(1, m + 1) if (c >> i) & 1) for i in range(r)]
    law = AffineLaw(m, [(row, 0) for row in rows])
    qs = circuit_questions(law)
    qs_s = qs if r == 3 else rng.sample(qs, 2000)
    for enc in ('chain', 'tree'):
        L, N = library(law, enc, direct_upto=3)
        kk = min_rounds(L, N, qs_s)
        P(f"  simplex r={r} m={m}, {enc} library: {len(L)} clauses, {N - m} aux, rounds needed on {len(qs_s)} minimal questions: {kk}")

# ------------------------------------------------------------------ F
P("== F: Proposition 4.2(b): directed rules for one parity law")


def fc(rules, N, alpha, rounds=None):
    a = [-1] * N
    for v, s in alpha.items():
        a[v] = s
    t = 0
    while rounds is None or t < rounds:
        new = {}
        for Pm, (v, s) in rules:
            if all(a[pv] == ps for pv, ps in Pm):
                if a[v] == 1 - s or (v in new and new[v] != s):
                    return None
                if a[v] == -1:
                    new[v] = s
        if not new:
            break
        for v, s in new.items():
            a[v] = s
        t += 1
    return a


for m in range(2, 7):
    law = AffineLaw(m, [((1 << m) - 1, 0)])
    sols = law.sols
    nontriv = 0
    alls = 0
    rules = []
    for alpha in all_partial_assignments(m):
        imp = implied(sols, m, alpha)
        if imp is None:
            continue
        for (v, s) in imp:
            alls += 1
            nontriv += 1
            rules.append((tuple(sorted(alpha.items())), (v, s)))
        # trivial rules: conclusion in the premise
        alls += len(alpha)
    P(f"  m={m}: sound rules {alls}; non-trivial (var(l) not in var(P)) {nontriv}; m 2^(m-1) = {m * 2 ** (m - 1)}; all non-trivial premises of size m-1: {all(len(p) == m - 1 for p, _ in rules)}")
    if m == 3:
        qs = circuit_questions(law)
        nus = 0
        for mask in range(1 << len(rules)):
            R = [rules[i] for i in range(len(rules)) if mask >> i & 1]
            if all((lambda a: a is not None and a[j] == val)(fc(R, m, alpha)) for alpha, (j, val) in qs):
                nus += 1
        P(f"   m=3: usable subsets of the 12 non-trivial sound rules: {nus} (the full set only)")

# ------------------------------------------------------------------ G
P("== G: Proposition 2.9a (d_* = 2): exact minima for equivalence classes (exhaustive over subsets of PI)")


def exact_min(law, maxsize=8):
    PI = pi_of_law(law)
    qs = circuit_questions(law)
    for s in range(0, min(maxsize, len(PI)) + 1):
        found = [S for S in combinations(range(len(PI)), s) if answers_all([PI[i] for i in S], law.m, qs)]
        if found:
            return s, len(found), [PI[i] for i in found[0]], len(PI)
    return None, 0, None, len(PI)


cases = []
for c in range(2, 6):
    cases.append((f"x1=...=x{c}", AffineLaw(c, [((1 << i) | (1 << (i + 1)), 0) for i in range(c - 1)]), c))
cases.append(("x1 = x2 + 1 = x3 (anti-equivalence)", AffineLaw(3, [(0b011, 1), (0b110, 1)]), 3))
cases.append(("two classes {x1,x2}, {x3,x4,x5}", AffineLaw(5, [(0b00011, 0), (0b01100, 0), (0b11000, 0)]), 5))
cases.append(("two classes {x1,x2,x3}, {x4,x5,x6}", AffineLaw(6, [(0b000011, 0), (0b000110, 0), (0b011000, 0), (0b110000, 0)]), 6))
for name, law, claim in cases:
    mn, nmin, ex, npi = exact_min(law)
    P(f"  {name}: |PI| = {npi}; exact minimum {mn} (claimed {claim}); minimum sets {nmin}; e.g. {[cl_str(C) for C in ex]}")

# ------------------------------------------------------------------ H
P("== H: Propositions 2.5, 2.5a: clauses common to all UP-usable theories over X = F_ind(S), every d_*")
stats = {}
nlaws = 0
tries = 0
while nlaws < 36 and tries < 5000:
    tries += 1
    m = rng.choice([5, 6, 7])
    k = rng.choice([1, 2, 3])
    if k >= m:
        continue
    law = AffineLaw(m, random_system(rng, m, k))
    d = law.dmin()
    key = min(d, 3)
    if stats.get(key, [0])[0] >= 12:
        continue
    nlaws += 1
    PI = pi_of_law(law)
    # all full-support clauses of all derived equations (implicates) plus PI
    big = list({tuple(sorted(C)) for u in law.codewords for C in parity_clauses(u, law.const[u], m)} | {tuple(sorted(C)) for C in PI})
    qs = circuit_questions(law)
    assert answers_all(big, m, qs)
    fi = {tuple(sorted(C)) for C in F_ind(law)}
    necessary = set()
    pis = {tuple(sorted(C)) for C in PI}
    nonprime = [C for C in big if C not in pis]
    cand = list(pis) + rng.sample(nonprime, min(10, len(nonprime)))
    for C in cand:
        Fm = [D for D in big if D != C]
        if not answers_all(Fm, m, qs):
            necessary.add(C)
    eq = (necessary == fi)
    st = stats.setdefault(key, [0, 0, 0])
    st[0] += 1
    st[1] += eq
    if d >= 3:
        st[2] += answers_all(list(fi), m, qs)
for key in sorted(stats):
    lab = {1: "d*=1", 2: "d*=2", 3: "d*>=3"}[key]
    extra = f"; F_ind usable in {stats[key][2]}" if key == 3 else ""
    P(f"  {lab}: {stats[key][0]} laws; necessary clauses (deleting it from the set of all derived-equation clauses breaks usability; tested: every prime implicate and 10 random non-prime ones) == F_ind in {stats[key][1]}{extra}")

# ------------------------------------------------------------------ I
P("== I: Proposition 3.2: library size sum_u s(|u|), s(w) = 2^(w-1) for w <= 4, 4w-6 for w >= 5")


def s_w(w):
    return 2 ** (w - 1) if w <= 4 else 4 * w - 6


for trial in range(8):
    m = rng.choice([6, 7, 8, 9])
    k = rng.choice([2, 3, 4])
    law = AffineLaw(m, random_system(rng, m, k))
    L, N = library(law, 'chain', direct_upto=4)
    ws = sorted(popcount(u) for u in law.circuits())
    formula = sum(s_w(w) for w in ws)
    old = sum(min(2 ** (w - 1), 4 * w - 6) for w in ws)
    qs = circuit_questions(law)
    ok = answers_all(L, N, qs)
    P(f"  m={m} r={law.k} circuit weights {ws}: construction {len(L)} clauses, formula {formula}, old formula min(2^(w-1),4w-6) {old}; usable {ok}")

# ------------------------------------------------------------------ J
P("== J: Lemma 1.7 with l_N(n) = |delta(n+1)|: Kraft sum over all theories over 2 base variables (no aux)")
lits2 = [(0, 0), (0, 1), (1, 0), (1, 1)]
clauses2 = [((0, 0),), ((0, 1),), ((1, 0),), ((1, 1),), ((0, 0), (1, 0)), ((0, 0), (1, 1)), ((0, 1), (1, 0)), ((0, 1), (1, 1))]
tot = 0.0
for mask in range(1 << 8):
    F = [clauses2[i] for i in range(8) if mask >> i & 1]
    tot += 2.0 ** (-l_lst_clauses(F, 2, 2))
P(f"  sum over all 256 theories of 2^(-l_lst) = {tot:.6f} (<= 1: {tot <= 1})")

# ------------------------------------------------------------------ K
P("== K: Section 3.2: fraction of sampled questions the core answers fully, 5 systems per m, 1000 questions each")


def sample_question(law, rng):
    m = law.m
    while True:
        x = rng.choice(law.sols)
        pr = rng.choice([0.3, 0.5, 0.7])
        S = [v for v in range(m) if rng.random() < pr]
        alpha = {v: (x >> v) & 1 for v in S}
        imp = law.implied(alpha)
        if imp:
            return alpha, imp


for m in (12, 16, 20):
    fr = []
    for sysno in range(5):
        k = m // 2
        law = None
        while law is None:
            try:
                law = AffineLaw(m, random_system(rng, m, k, row_weights=[3, 4]))
            except ValueError:
                law = None
        core = []
        for r_, c_ in law.eqs:
            core += xor_clauses([v for v in range(m) if r_ >> v & 1], c_)
        full = 0
        for _ in range(1000):
            alpha, imp = sample_question(law, rng)
            a = up(core, m, alpha)
            if a is not None and all(a[v] == s for v, s in imp):
                full += 1
        fr.append(full / 1000)
    P(f"  m={m} r={m // 2}: per-system fractions {fr}; range {min(fr):.3f}-{max(fr):.3f}; mean {sum(fr) / len(fr):.3f}")

# ------------------------------------------------------------------ L
P("== L: Theorem 6.2(c): coupon collector over n = 2^(m-1) patterns")
for m in (4, 5, 6, 8, 10):
    n = 2 ** (m - 1)
    H = sum(1.0 / i for i in range(1, n + 1))
    approx_old = n * ((m - 1) * math.log(2) + 0.5772156649)
    approx_new = approx_old + 0.5
    P(f"  m={m}: exact n H_n = {n * H:.3f}; n((m-1)ln2 + gamma) = {approx_old:.3f}; with +1/2: {approx_new:.3f}")

# ------------------------------------------------------------------ M
P("== M: Theorem 3.6: the hidden-state law with weight-1 and weight-3 functionals")


def hidden_law(q):
    rows = []
    for w in (1, 3):
        for tri in combinations(range(q), w):
            u = sum(1 << i for i in tri)
            for c in (0, 1):
                rows.append(u | (c << q))
    gstar = 1 << q
    return rows, gstar


def rank(vecs):
    return len(rref_rows(list(vecs)))


for q in (3, 4):
    rows, gstar = hidden_law(q)
    E = len(rows)
    cols = rows + [gstar]
    pts = set()
    for z in range(1 << (q + 1)):
        x = 0
        for idx, g in enumerate(cols):
            if popcount(z & g) % 2:
                x |= 1 << idx
        pts.add(x)
    dim = int(round(math.log2(len(pts))))
    mism = 0
    nunsat = 0
    for S in range(1 << E):
        sel = [rows[i] for i in range(E) if S >> i & 1]
        in_span = rank(sel + [gstar]) == rank(sel)
        # XOR system u.y = c over y in GF(2)^q unsatisfiable?
        unsat = not any(all(popcount(y & (g & ((1 << q) - 1))) % 2 == (g >> q) for g in sel) for y in range(1 << q))
        # determined: all points with x_S = 0 agree on x_*
        vals = {(x >> E) & 1 for x in pts if (x & S) == 0}
        det = (len(vals) == 1)
        mism += not (in_span == unsat == det)
        nunsat += unsat
    P(f"  q={q}: |E_q| = {E} = 2(C(q,3)+q); m = {E + 1}; dim H_q = {dim} (q+1 = {q + 1}); subsets {1 << E}, unsatisfiable {nunsat}; mismatches among (g_* in span, unsat, determined): {mism}")
    if q == 3:
        m = E + 1
        sols = sorted(pts)
        PI = prime_implicates_bruteforce(sols, m)
        bad = 0
        for S in range(1 << E):
            alpha = {i: 0 for i in range(E) if S >> i & 1}
            a = up(PI, m, alpha)
            sel = [rows[i] for i in range(E) if S >> i & 1]
            unsat = rank(sel + [gstar]) == rank(sel)
            derived = (a is not None and a[E] == 0)
            bad += (derived != unsat)
        P(f"   q=3: PI(H_3) has {len(PI)} clauses; UP derives not-x_* from alpha_S iff the system is unsatisfiable: mismatches {bad}/{1 << E}")
for q in range(3, 7):
    rows, gstar = hidden_law(q)
    rowset = set(rows)
    hit = set()
    ok = True
    for v1, v2, v3 in product(range(q), repeat=3):
        u = (1 << v1) ^ (1 << v2) ^ (1 << v3)
        if popcount(u) not in (1, 3):
            ok = False
        for b in (0, 1):
            g = u | (b << q)
            if g not in rowset:
                ok = False
            hit.add(g)
    P(f"  q={q}: all {2 * q ** 3} GKRS inputs map to coordinates of the law: {ok}; coordinates hit: {len(hit)}/{len(rows)}")

P(f"# done in {time.time() - t0:.1f}s")
with open(__file__.rsplit('.', 1)[0] + '.out', 'w') as f:
    f.write("\n".join(out_lines) + "\n")
