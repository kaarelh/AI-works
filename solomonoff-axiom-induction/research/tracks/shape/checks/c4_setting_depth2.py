"""c4: checks for the setting (T1) and for the depth-2 bound with auxiliary variables (T7, Thm 7.2).

Seed 20261016.  Writes c4_setting_depth2.out next to itself.

A  Lemma 1.10: for random nonempty P in {0,1}^m (m <= 6), PI(P) answers every entailed literal in ONE round.
B  Theorem 1.11's compiler: for random explicit theories F' with auxiliary variables, kappa(F') = PI(proj F')
   is UP_1-compatible with every conditional datum F' is (semantically) compatible with.
C  Prop 1.8: the point theory x = x0 proves alpha -> l for every question of a random affine law.
D  Lemma 1.5: PI(P) is compatible with Q(S) only for P = S (random affine laws and the chain law; P ranging
   over S minus a point, S plus a point).
E  Theorem 7.2's ingredients on UP_2-usable theories WITH auxiliary variables and wide clauses for the chain law:
   generated theories (2-TC-spanner, auxiliary hubs, conjunctive clauses, padding) are checked for soundness and
   UP_2-usability by brute force; then the counting inequalities sum|N(v)| + sum c(j) <= m + 2|F|, the
   Hansel-type sums sum_a 2^-(|N(2a)|+c(2a-1)) <= 1 (both pairings), and the final bound are verified.
"""
import random, sys, time, math
from itertools import product, combinations
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import *

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


t0 = time.time()
P(f"# c4_setting_depth2.py  seed={SEED}  python={sys.version.split()[0]}")

# ------------------------------------------------------------------ A
P("== A: PI(P) is complete for one round of unit propagation (Lemma 1.10)")
fails = tot = 0
for trial in range(60):
    m = rng.randint(3, 6)
    Pset = sorted(rng.sample(range(1 << m), rng.randint(1, 1 << m)))
    pis = prime_implicates_bruteforce(Pset, m)
    for alpha in all_partial_assignments(m):
        imp = law_implied(Pset, m, alpha)
        if imp is None:
            continue
        a = up(pis, m, alpha, 1)
        tot += len(imp)
        if a is None or any(a[v] != s for v, s in imp):
            fails += 1
P(f"  60 random P (m=3..6): {tot} entailed literals; failures in one round = {fails}")

# ------------------------------------------------------------------ B
P("== B: the compiler kappa(F') = PI(proj F') preserves compatibility (Thm 1.11)")
bad = checked = 0
for trial in range(80):
    m = rng.randint(3, 5)
    na = rng.randint(0, 3)
    N = m + na
    F = []
    for _ in range(rng.randint(2, 7)):
        w = rng.randint(2, min(4, N))
        vs = rng.sample(range(N), w)
        F.append(tuple((v, rng.randint(0, 1)) for v in vs))
    proj = sorted({x & ((1 << m) - 1) for x in range(1 << N)
                   if all(any(((x >> v) & 1) == s for v, s in C) for C in F)})
    if not proj:
        continue
    kap = prime_implicates_bruteforce(proj, m)
    for alpha in all_partial_assignments(m):
        imp = law_implied(proj, m, alpha)  # semantic: F' u alpha satisfiable and entails these
        if imp is None:
            continue
        for lit in imp:
            checked += 1
            a = up(kap, m, alpha, 1)
            if a is None or a[lit[0]] != lit[1]:
                bad += 1
P(f"  {checked} (theory, datum) pairs that F' is compatible with: kappa(F') fails on {bad}")

# ------------------------------------------------------------------ C
P("== C: the two-valued encoding is degenerate (Prop 1.8)")
bad = tot = 0
for trial in range(30):
    m = rng.randint(4, 7)
    law = AffineLaw(m, random_system(rng, m, rng.randint(1, 3)))
    x0 = rng.choice(law.sols)
    for alpha in all_partial_assignments(m):
        imp = law.implied(alpha) if law.consistent(alpha) else None
        if not imp:
            continue
        for (v, s) in imp:
            tot += 1
            # T_x0 |- alpha -> l  iff  alpha disagrees with x0 or x0 satisfies l
            agrees = all(((x0 >> u) & 1) == b for u, b in alpha.items())
            if agrees and ((x0 >> v) & 1) != s:
                bad += 1
P(f"  {tot} questions of 30 random affine laws: the point theory fails to prove alpha->l in {bad}")

# ------------------------------------------------------------------ D
P("== D: compatibility with all of Q(S) forces proj = S (Lemma 1.5)")


def compatible_all(F, m, sols, N=None):
    N = N or m
    for alpha in all_partial_assignments(m):
        imp = law_implied(sols, m, alpha)
        if imp is None or not imp:
            continue
        a = up(F, N, alpha)
        if a is None or any(a[v] != s for v, s in imp):
            return False
    return True


wrong = tested = 0
for trial in range(40):
    if trial % 2 == 0:
        m = rng.randint(4, 6)
        sols = AffineLaw(m, random_system(rng, m, rng.randint(1, 3))).sols
    else:
        m = rng.randint(3, 6)
        sols = [sum(1 << v for v in range(a, m)) for a in range(m + 1)]
    sset = set(sols)
    cands = []
    for x in rng.sample(sols, min(3, len(sols))):
        cands.append(sorted(sset - {x}))
    outside = [x for x in range(1 << m) if x not in sset]
    for x in rng.sample(outside, min(3, len(outside))):
        cands.append(sorted(sset | {x}))
    for Pset in cands:
        if not Pset:
            continue
        tested += 1
        if compatible_all(prime_implicates_bruteforce(Pset, m), m, sols):
            wrong += 1
    assert compatible_all(prime_implicates_bruteforce(sols, m), m, sols)
P(f"  {tested} perturbed projections (S minus or plus a point): compatible with Q(S) in {wrong} (expected 0)")

# ------------------------------------------------------------------ E
P("== E: Theorem 7.2's ingredients on UP_2-usable chain theories with auxiliary variables and wide clauses")


def chain_ok(F, N, m, k):
    sols = [sum(1 << v for v in range(a, m)) for a in range(m + 1)]
    # soundness: projection of F equals the chain law
    proj = set()
    for x in range(1 << N):
        if all(any(((x >> v) & 1) == s for v, s in C) for C in F):
            proj.add(x & ((1 << m) - 1))
    if proj != set(sols):
        return False
    for alpha in all_partial_assignments(m):
        imp = law_implied(sols, m, alpha)
        if imp is None or not imp:
            continue
        a = up(F, N, alpha, k)
        if a is None or any(a[v] != s for v, s in imp):
            return False
    return True


def gen_theory(m):
    """A UP_2-usable theory for Ch_m with auxiliary hubs and conjunctive clauses (0-indexed variables)."""
    F = []
    N = m
    pairs_needed = {(i, j) for i in range(m) for j in range(i + 1, m)}
    covered = set()
    # random auxiliary hubs y: x_i -> y for i in I, y -> x_j for j in J, max(I) < min(J)
    for _ in range(rng.randint(1, 3)):
        s = rng.randrange(0, m - 1)
        I = [i for i in range(0, s + 1) if rng.random() < 0.8] or [s]
        J = [j for j in range(s + 1, m) if rng.random() < 0.8] or [s + 1]
        y = N
        N += 1
        F += [((i, 0), (y, 1)) for i in I]
        F += [((y, 0), (j, 1)) for j in J]
        covered |= {(i, j) for i in I for j in J}
    # conjunctive clauses: two hubs y1 (from I1) and y2 (from I2) -> x_j, sound when max(I1 & I2) <= j
    for _ in range(rng.randint(0, 2)):
        a = rng.randrange(0, m - 1)
        I1 = list(range(0, a + 1)) + [a + 1] if a + 1 < m else list(range(0, a + 1))
        I2 = list(range(0, a + 1))
        y1, y2 = N, N + 1
        N += 2
        F += [((i, 0), (y1, 1)) for i in I1]
        F += [((i, 0), (y2, 1)) for i in I2]
        j = rng.randrange(a + 1, m)
        F.append(((y1, 0), (y2, 0), (j, 1)))
        covered |= {(i, j) for i in set(I1) & set(I2) if i < j}
    # complete with direct edges (a midpoint 2-spanner restricted to uncovered pairs)
    def hubs(lo, hi):
        if hi - lo < 1:
            return
        h = (lo + hi) // 2
        for i in range(lo, h):
            if (i, h) not in covered:
                F.append(((i, 0), (h, 1)))
                covered.add((i, h))
        for j in range(h + 1, hi + 1):
            if (h, j) not in covered:
                F.append(((h, 0), (j, 1)))
                covered.add((h, j))
        hubs(lo, h - 1)
        hubs(h + 1, hi)
    hubs(0, m - 1)
    # padding: a few wide sound clauses
    for _ in range(rng.randint(0, 2)):
        i = rng.randrange(0, m - 1)
        j = rng.randrange(i + 1, m)
        C = [(i, 0), (j, 1)] + [(v, rng.randint(0, 1)) for v in rng.sample(range(N), 2) if v not in (i, j)]
        F.append(tuple(C))
    return F, N


ok_theories = 0
viol_count = viol_hansel = viol_bound = 0
for trial in range(400):
    m = rng.randint(4, 8)
    F, N = gen_theory(m)
    if N > 14:
        continue
    if not chain_ok(F, N, m, 2):
        continue
    ok_theories += 1
    # N(v), c(j) with 1-indexed elements v = 1..m (variable v-1)
    Nset = {}
    for v in range(m):
        Nset[v] = {(v, 1)} | {L for C in F if len(C) == 2 for L in C if ((v, 0) in C and L != (v, 0))}
    cnt = {}
    for j in range(m):
        c = 0
        for C in F:
            if (j, 1) not in C:
                continue
            prem = {(u, 1 - s) for (u, s) in C if (u, s) != (j, 1)}
            if any(prem <= Nset[u] for u in range(j)):
                c += 1
        cnt[j] = c
    lhs = sum(len(Nset[v]) for v in range(m)) + sum(cnt.values())
    if lhs > m + 2 * len(F):
        viol_count += 1
    # pairing sums (1-indexed: source 2a, target 2a-1  ->  0-indexed: source 2a-1, target 2a-2)
    s1 = sum(2.0 ** -(len(Nset[2 * a - 1]) + cnt[2 * a - 2]) for a in range(1, m // 2 + 1))
    s2 = sum(2.0 ** -(len(Nset[2 * a]) + cnt[2 * a - 1]) for a in range(1, (m - 1) // 2 + 1))
    if s1 > 1 + 1e-12 or s2 > 1 + 1e-12:
        viol_hansel += 1
    bound = 0.5 * ((m - 2) * math.log2((m - 2) / 2) - m)
    if len(F) < bound:
        viol_bound += 1
P(f"  {ok_theories} generated theories (m=4..8, up to 14 variables) verified sound and UP_2-usable by brute force; "
  f"violations: counting inequality {viol_count}, Hansel sums {viol_hansel}, final bound {viol_bound}")
P(f"# done in {time.time() - t0:.1f}s")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out_lines) + "\n")
