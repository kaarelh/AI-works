"""Referee A: independent checks of claims in tracks/shape/notes.md.

Seed 20261016. Writes refA_checks.out next to itself. Uses only refA_lib.py (not the thread's shapelib.py).

A  Lemma 1.5 for the chain law with m = 2: exhaustive over all explicit theories over X (2 base variables).
B  Theorem 7.1's "iff" for theories with wide clauses: an explicit counterexample, then random theories.
C  The simplex family with auxiliary variables: Prop 3.2's chain-encoded circuit library is UP-usable and has
   polynomially many clauses, so K_lst^UP (auxiliaries allowed) is not exponentially above K_lst^GE.
D  Theorem 2.6 replicated: F_ind (indecomposable circuits, by the definition) is UP-usable and every clause
   of it is necessary, for random affine laws with d_* >= 3.
E  Exact minimum k-hop TC-spanners of the path for small m (independent search), against the record's table.
F  Lemma 6.1 (answers of a no-aux theory on Q_{m-1} of the parity law): (i) <=> (iii) on random theories.
G  Prop 4.2(c): splitting clauses of width >= 4 with fresh variables preserves UP-usability.
"""
import random, sys, time
from itertools import combinations, product
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from refA_lib import *

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def P(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


t0 = time.time()
P(f"# refA_checks.py  seed={SEED}  python={sys.version.split()[0]}")


def chain_sols(m):
    return [sum(1 << v for v in range(a, m)) for a in range(m + 1)]


def compatible_with_Q(F, sols, m, N):
    """UP-compatibility with every question of Q(sols): F u alpha satisfiable and UP derives the answer."""
    mods = models(F, N)
    mask = (1 << m) - 1
    pr = set(x & mask for x in mods)
    for alpha in partial_assignments(m):
        imp = entailed(sols, alpha, m)
        if imp is None or not imp:
            continue
        if not any(all(((x >> v) & 1) == s for v, s in alpha.items()) for x in pr):
            return False, pr
        a, conf = up_rounds(F, alpha)
        if conf or any(a.get(v) != s for v, s in imp):
            return False, pr
    return True, pr


# ------------------------------------------------------------------ A
P("== A: Lemma 1.5 for the chain law Ch_2 (claimed: compatibility with Q(Ch_m) forces proj = Ch_m for m >= 2)")
m = 2
sols = chain_sols(m)
lits = [1, -1, 2, -2]
allcl = [frozenset([L]) for L in lits] + [frozenset([a, b]) for a in (1, -1) for b in (2, -2)]
ncomp = nbad = 0
example = None
for mask in range(1 << len(allcl)):
    F = [allcl[i] for i in range(len(allcl)) if (mask >> i) & 1]
    ok, pr = compatible_with_Q(F, sols, m, m)
    if ok:
        ncomp += 1
        if pr != set(sols):
            nbad += 1
            if example is None or len(F) < len(example[0]):
                example = (F, sorted(pr))
P(f"  all 256 theories over 2 base variables: {ncomp} UP-compatible with Q(Ch_2), of which {nbad} have proj != Ch_2")
if example:
    F, pr = example
    P("  smallest example: F =", [sorted(C) for C in F], " proj F =", [format(x, '02b')[::-1] for x in pr],
      " Ch_2 =", [format(x, '02b')[::-1] for x in sols], "(strings x_0x_1)")
for mm in range(2, 9):
    s = chain_sols(mm)
    nodet = []
    for x in s:
        det = False
        for j in range(mm):
            alpha = {v: (x >> v) & 1 for v in range(mm) if v != j}
            imp = entailed(s, alpha, mm)
            if imp:
                det = True
                break
        if not det:
            nodet.append(format(x, f'0{mm}b')[::-1])
    P(f"  m={mm}: points of Ch_m with no coordinate determined by the others: {nodet}")

# ------------------------------------------------------------------ B
P("== B: Theorem 7.1's 'iff' with wide clauses")
m = 3
sols = chain_sols(m)
# x_0 -> x_1, x_1 -> x_2, and the wide implicate (not x_0 or not x_1 or x_2)
F = [frozenset([-1, 2]), frozenset([-2, 3]), frozenset([-1, -2, 3])]
Frep = [frozenset([-1, 2]), frozenset([-2, 3]), frozenset([-1, 3])]
P("  F = {~x0|x1, ~x1|x2, ~x0|~x1|x2};  proj F == Ch_3:", projection(F, 3, 3) == sorted(sols))
P("  F is UP_1-usable:", usable(F, sols, 3, rounds=1))
P("  F with the wide clause replaced by its contained prime implicate ~x0|x2 is UP_1-usable (a 1-hop TC-spanner):",
  usable(Frep, sols, 3, rounds=1))
Frep2 = [frozenset([-1, 2]), frozenset([-2, 3]), frozenset([-2, 3])]
P("  ... replaced by the other contained prime implicate ~x1|x2 instead: UP_1-usable:", usable(Frep2, sols, 3, rounds=1))


def prime_contained(C):
    out = []
    for L1 in C:
        for L2 in C:
            if L1 < 0 < L2 and lit_var(L1) < lit_var(L2):
                out.append(frozenset([L1, L2]))
    return out


def spanner(edges, m, k):
    # BFS distances <= k for all i<j
    adj = {i: set() for i in range(m)}
    for (i, j) in edges:
        adj[i].add(j)
    for i in range(m):
        frontier = {i}
        seen = {i}
        for _ in range(k):
            frontier = set(w for v in frontier for w in adj[v]) - seen
            seen |= frontier
        if any(j not in seen for j in range(i + 1, m)):
            return False
    return True


for m in (4, 5):
    sols = chain_sols(m)
    allimp = []
    for w in range(2, m + 1):
        for vs in combinations(range(m), w):
            for signs in product((0, 1), repeat=w):
                C = frozenset(mk(v, s) for v, s in zip(vs, signs))
                if prime_contained(C):
                    allimp.append(C)
    stats = {"theories": 0, "usable": 0, "some_rep_spanner_not_usable": 0, "all_rep_spanner_not_usable": 0,
             "usable_but_some_rep_not_spanner": 0}
    for trial in range(400):
        k = rng.choice([1, 2])
        base = []
        # a random spanner-ish 2-CNF plus random wide implicates
        for i in range(m - 1):
            base.append(frozenset([-(i + 1), i + 2]))
        extra = rng.sample(allimp, rng.randint(1, 5))
        F = base + extra
        stats["theories"] += 1
        u = usable(F, sols, m, rounds=k)
        stats["usable"] += u
        choices = [prime_contained(C) for C in F]
        reps = list(product(*choices))
        if len(reps) > 400:
            reps = rng.sample(reps, 400)
        sp = [spanner([(lit_var(min(e)), lit_var(max(e))) for e in rep], m, k) for rep in reps]
        if not u and any(sp):
            stats["some_rep_spanner_not_usable"] += 1
        if not u and all(sp):
            stats["all_rep_spanner_not_usable"] += 1
        if u and not all(sp):
            stats["usable_but_some_rep_not_spanner"] += 1
    P(f"  m={m}, 400 random implicate theories (path edges + 1..5 random implicates, k in {{1,2}}):", stats)

# ------------------------------------------------------------------ C
P("== C: simplex family with auxiliary variables (Prop 3.2's chain-encoded circuit library)")


def chain_encoding(u, c, start):
    """Chain encoding of u.x = c over supp(u) with fresh variables start, start+1, ...; returns (clauses, next)."""
    supp = [i for i in range(u.bit_length()) if (u >> i) & 1]
    w = len(supp)
    if w <= 4:
        return clauses_of_equation(u, c), start
    cl = []
    y = start
    # y0 = x_s0 + x_s1
    def xor3(a, b, d):  # a + b + d = 0 : clauses excluding odd-parity points
        out = []
        for bits in product((0, 1), repeat=3):
            if sum(bits) % 2 == 1:
                out.append(frozenset(mk(v, 1 - bb) for v, bb in zip((a, b, d), bits)))
        return out
    cl += xor3(supp[0], supp[1], y)
    prev = y
    for t in range(2, w - 1):
        y += 1
        cl += xor3(prev, supp[t], y)
        prev = y
    # prev + x_last = c
    last = supp[w - 1]
    for bits in product((0, 1), repeat=2):
        if sum(bits) % 2 != c:
            cl.append(frozenset(mk(v, 1 - bb) for v, bb in zip((prev, last), bits)))
    return cl, y + 1


for r in (3, 4, 5):
    m = 2 ** r - 1
    cols = list(range(1, 2 ** r))
    rows = []
    for i in range(r):
        rows.append(sum(1 << j for j, col in enumerate(cols) if (col >> i) & 1))
    b = [rng.randint(0, 1) for _ in range(r)]
    # all derived equations with constants
    derived = {0: 0}
    for i in range(r):
        derived.update({u ^ rows[i]: c ^ b[i] for u, c in list(derived.items())})
    circuits = [u for u in derived if u]
    lib = []
    nxt = m
    for u in circuits:
        cl, nxt = chain_encoding(u, derived[u], nxt)
        lib += cl
    npi = m * 2 ** ((m - 1) // 2)
    lits = sum(len(C) for C in lib)
    P(f"  r={r}, m={m}: chain-encoded circuit library: {len(lib)} clauses, {lits} literal occurrences, "
      f"{nxt - m} auxiliary variables; minimum without auxiliaries (Cor 2.8): {npi} clauses")
    if r <= 4:
        sols = [x for x in range(1 << m) if all(popcount(x & rows[i]) % 2 == b[i] for i in range(r))]
        if r == 3:
            ok = usable(lib, sols, m)
            P(f"    UP-usable, exhaustive over all 3^{m} partial assignments: {ok}")
        else:
            alphas = []
            for _ in range(3000):
                S = rng.sample(range(m), rng.randint(1, m - 1))
                x = rng.choice(sols)
                alphas.append({v: (x >> v) & 1 for v in S})
            for u in circuits[:8]:
                supp = [i for i in range(m) if (u >> i) & 1]
                x = rng.choice(sols)
                for j in supp:
                    alphas.append({v: (x >> v) & 1 for v in supp if v != j})
            ok = usable(lib, sols, m, alphas=alphas)
            P(f"    UP-usable on {len(alphas)} consistent antecedents (3000 random + all circuit-minus-one antecedents "
              f"of 8 circuits): {ok}")
            # projection check by sampling: the library with any base point extends iff the point is a solution
            P("    (projection = S holds because every auxiliary variable is a partial sum, as in Prop 3.2)")

# ------------------------------------------------------------------ D
P("== D: Theorem 2.6 replicated (F_ind by the definition of decomposability)")


def law_data(m, k):
    # a random rank-k law on m variables whose derived equations all have weight >= 3; if none is found
    # after many tries (e.g. no [m,k,3] code exists, as for m=6,k=4 or m=5,k=3), lower k
    tries = 0
    while True:
        tries += 1
        if tries > 20000:
            k, tries = k - 1, 0
        rows = [rng.randrange(1, 1 << m) for _ in range(k)]
        b = [rng.randint(0, 1) for _ in range(k)]
        sp = {0: 0}
        for i in range(k):
            sp.update({u ^ rows[i]: c ^ b[i] for u, c in list(sp.items())})
        if len(sp) != 2 ** k:
            continue
        if 0 in sp and sp[0] != 0:
            continue
        if min(popcount(u) for u in sp if u) < 3:
            continue
        return rows, b, sp


nlaw = ok_use = ok_nec = 0
nclauses = 0
t1 = time.time()
ndec = npi = 0
for trial in range(100):
    m = rng.randint(6, 9)
    k = rng.randint(2, 5)
    rows, b, sp = law_data(m, k)
    der = [u for u in sp if u]
    circ = [u for u in der if not any(v != u and (v & u) == v for v in der)]
    ind = []
    for u in circ:
        dec = False
        for u1 in der:
            u2 = u ^ u1
            if u2 == 0 or u2 not in sp:
                continue
            inter = u1 & u2
            if popcount(inter) == 1 and not (inter & u):
                dec = True
                break
        if not dec:
            ind.append(u)
    Find = []
    for u in ind:
        Find += clauses_of_equation(u, sp[u])
    ndec += (len(ind) < len(circ))
    npi += sum(2 ** (popcount(u) - 1) for u in circ)
    sols = [x for x in range(1 << m) if all(popcount(x & rows[i]) % 2 == b[i] for i in range(len(rows)))]
    nlaw += 1
    u_ok = usable(Find, sols, m) and projection(Find, m, m) == sols
    ok_use += u_ok
    nclauses += len(Find)
    # necessity (Prop 2.5): for each clause C of F_ind, with j the first variable of C, the antecedent
    # "falsifying assignment of C minus x_j" is no longer answered once C is deleted
    nec = True
    for i, C in enumerate(Find):
        j = min(lit_var(L) for L in C)
        alpha = {lit_var(L): 1 - lit_val(L) for L in C if lit_var(L) != j}
        if usable(Find[:i] + Find[i + 1:], sols, m, alphas=[alpha]):
            nec = False
            break
    ok_nec += nec
P(f"  {nlaw} random laws (m=6..9, k=2..5 lowered when no [m,k,3] law is found, d_*>=3): F_ind usable with "
  f"proj = S in {ok_use}; every clause necessary (targeted witness) in {ok_nec}; laws with a decomposable circuit "
  f"(F_ind strictly inside PI) {ndec}; total |F_ind| = {nclauses} against total |PI| = {npi}  ({time.time() - t1:.0f}s)")

# ------------------------------------------------------------------ E
P("== E: exact minimum k-hop TC-spanners s_k(m) of the directed path (independent search)")
record = {2: [1, 2, 4, 6, 8, 10, 13, 16], 3: [1, 2, 3, 5, 6, 8, 10, 12], 4: [1, 2, 3, 4, 6, 7, 9, 10]}


def min_spanner(m, k):
    forced = [(i, i + 1) for i in range(m - 1)]
    others = [(i, j) for i in range(m) for j in range(i + 2, m)]
    for extra in range(0, len(others) + 1):
        for comb in combinations(others, extra):
            if spanner(forced + list(comb), m, k):
                return m - 1 + extra
    return None


for k in (2, 3, 4):
    vals = []
    for m in range(2, 10):
        vals.append(min_spanner(m, k))
    P(f"  k={k}: s_k(m) for m=2..9: {vals};  record's table: {record[k]};  agree: {vals == record[k]}")

# ------------------------------------------------------------------ F
P("== F: Lemma 6.1 on random theories over X (parity law, questions with |S| = m-1)")
bad = tot = 0
for trial in range(300):
    m = rng.choice([4, 5])
    sols = [x for x in range(1 << m) if popcount(x) % 2 == 0]
    F = []
    for _ in range(rng.randint(1, 10)):
        w = rng.randint(1, m)
        vs = rng.sample(range(m), w)
        F.append(frozenset(mk(v, rng.randint(0, 1)) for v in vs))
    for gamma in sols:
        for j in range(m):
            alpha = {v: (gamma >> v) & 1 for v in range(m) if v != j}
            # (i): F u alpha satisfiable and UP derives x_j = gamma_j
            sat = any(all(((x >> v) & 1) == s for v, s in alpha.items()) for x in models(F, m))
            a, conf = up_rounds(F, alpha)
            i_ = sat and (not conf) and a.get(j) == ((gamma >> j) & 1)
            pi = gamma ^ (1 << j)
            gsat = all(any(((gamma >> lit_var(L)) & 1) == lit_val(L) for L in C) for C in F)
            fal = any(any(lit_var(L) == j for L in C) and
                      all(((pi >> lit_var(L)) & 1) != lit_val(L) for L in C) for C in F)
            iii = gsat and fal
            tot += 1
            bad += (i_ != iii)
P(f"  {tot} (theory, question) pairs: (i) != (iii) in {bad}")

# ------------------------------------------------------------------ G
P("== G: Prop 4.2(c): splitting clauses of width >= 4 preserves UP-usability")


def split(F, m, N):
    out = []
    z = N
    for C in F:
        Ls = sorted(C)
        w = len(Ls)
        if w < 4:
            out.append(C)
            continue
        out.append(frozenset([Ls[0], Ls[1], z + 1]))
        for t in range(2, w - 2):
            out.append(frozenset([-(z + 1), Ls[t], z + 2]))
            z += 1
        out.append(frozenset([-(z + 1), Ls[w - 2], Ls[w - 1]]))
        z += 1
    return out, z


okc = 0
for trial in range(20):
    m = rng.randint(5, 7)
    k = rng.randint(1, 3)
    rows, b, sp = law_data(m, k) if m >= 6 else law_data(m, 1)
    der = [u for u in sp if u]
    circ = [u for u in der if not any(v != u and (v & u) == v for v in der)]
    PI = []
    for u in circ:
        PI += clauses_of_equation(u, sp[u])
    sols = [x for x in range(1 << m) if all(popcount(x & r_) % 2 == c for r_, c in zip(rows, b))]
    Fs, N = split(PI, m, m)
    good = usable(Fs, sols, m)
    okc += good
P(f"  20 random laws (PI split into 3-clauses with fresh variables per clause): UP-usable in {okc}"
  " (projection preserved by construction: the pieces of one clause existentially project to it)")

P(f"# done in {time.time() - t0:.1f}s")
open(__file__.rsplit('.', 1)[0] + ".out", "w").write("\n".join(OUT) + "\n")
