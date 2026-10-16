"""Referee B, thread `shape`, target T1 (setting): Lemma 1.5, Lemma 1.7, Prop 1.8, Thm 1.11.

Independent of checks/. Seed 20261016. Writes refB_t1_setting.out next to itself.

Checks
 A  Lemma 1.5: all theories over X compatible (UP, and PS_inf) with Q(S): is proj F = S? Exhaustive for m = 2
    (all 256 theories) and m = 3 (all theories of <= 5 clauses), for the chain law and affine laws; the lemma's
    hypothesis "every point of S has a coordinate determined by the others" for Ch_m, m = 2..8.
 B  Lemma 1.7: Kraft sum of the listing code over all theories over X for m = 2 (and m = 3 restricted);
    note on l_N(0).
 C  Prop 1.8: the point theory T_{x0} entails alpha -> l for every question (random affine laws, chain laws).
 D  Thm 1.11: the compiler kappa(F') = PI(proj F') is UP_1-compatible with every datum F' is compatible with
    (F' random theories with auxiliary variables, reasoners UP and PS_inf).
"""
import os, sys, random, time, math
from itertools import combinations, product
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from refB_lib import *

SEED = 20261016
rng = random.Random(SEED)
OUT = []
T0 = time.time()


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def chain_pts(m):
    return [sum(1 << (v - 1) for v in range(a + 1, m + 1)) for a in range(m + 1)]


def question_set(S, m):
    qs = []
    for alpha in partial_assignments(range(1, m + 1)):
        cons, ent = entailed(S, m, alpha)
        if cons:
            for L in ent:
                qs.append((alpha, L))
    return qs


def compatible(F, N, qs, reasoner):
    for alpha, L in qs:
        mods = [x for x in range(1 << N) if point_agrees(x, alpha) and theory_true_at(F, x)]
        if not mods:
            return False
        if reasoner == "UP":
            r = up(F, alpha)
            if r is None or L not in r:
                return False
        else:  # PS_inf: entailment
            if not all(lit_true_at(L, x) for x in mods):
                return False
    return True


P("# refB_t1_setting.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
P("== A: Lemma 1.5: theories over X compatible with all of Q(S): proj F = S ?")
laws = [("Ch_2", 2, chain_pts(2)), ("Ch_3", 3, chain_pts(3)),
        ("x1+x2=1", 2, affine_points([0b11], [1], 2)), ("x1+x2+x3=0", 3, affine_points([0b111], [0], 3)),
        ("x1+x2=0,x3 free", 3, affine_points([0b011], [0], 3))]
for name, m, S in laws:
    allc = all_clauses(range(1, m + 1))
    qs = question_set(S, m)
    maxs = len(allc) if m == 2 else 5
    for reasoner in ("UP", "PS"):
        ncomp = nproj_eq = nsub = 0
        example = None
        for s in range(0, maxs + 1):
            for G in combinations(allc, s):
                F = list(G)
                if not compatible(F, m, qs, reasoner):
                    continue
                ncomp += 1
                pr = set(x for x in range(1 << m) if theory_true_at(F, x))
                nsub += pr <= set(S)
                if pr == set(S):
                    nproj_eq += 1
                elif example is None:
                    example = (sorted(sorted(C) for C in F), sorted(pr))
        P(f"  {name} ({reasoner}, theories of <= {maxs} clauses): compatible {ncomp}; proj subset of S in {nsub}; "
          f"proj == S in {nproj_eq}" + (f"; e.g. F = {example[0]} has proj {example[1]} vs S = {sorted(S)}" if example else ""))
for m in range(2, 9):
    S = chain_pts(m)
    nodet = []
    for x in S:
        det = False
        for j in range(1, m + 1):
            others = [y for y in S if (y ^ x) & ~(1 << (j - 1)) == 0 and y != x]
            if not others:
                det = True
                break
        if not det:
            nodet.append(x)
    P(f"  Ch_{m}: points of S with no coordinate determined by the others: {[format(x, '0%db' % m)[::-1] for x in nodet]}")

P("== B: Lemma 1.7: Kraft sum of the listing code (theories over X, N = m)")
for m in (2, 3):
    allc = all_clauses(range(1, m + 1))
    tot = 0.0
    maxs = len(allc) if m == 2 else 6
    for s in range(0, maxs + 1):
        for G in combinations(allc, s):
            tot += 2.0 ** (-ell_lst(list(G), m, m))
    P(f"  m={m} (theories of <= {maxs} clauses): sum 2^(-l_lst) = {tot:.6f} (<= 1: {tot <= 1}); "
      f"note: Elias delta codes n >= 1, while l_lst needs l_N(N - m) = l_N(0) and l_N(|F|) = l_N(0); this script uses delta(n+1)")

P("== C: Prop 1.8: the point theory proves alpha -> l for every question in Q(S)")
bad = tot = 0
for trial in range(30):
    m = rng.choice([4, 5, 6])
    if trial % 3 == 0:
        S = chain_pts(m)
    else:
        k = rng.choice([1, 2, 3])
        while True:
            rows = [rng.randrange(1, 1 << m) for _ in range(k)]
            if rank(rows) == k:
                break
        S = affine_points(rows, [rng.randrange(2) for _ in range(k)], m)
    x0 = rng.choice(S)
    for alpha, L in question_set(S, m):
        tot += 1
        # T_{x0} |- alpha -> L  iff  x0 falsifies alpha or x0 satisfies L
        if point_agrees(x0, alpha) and not lit_true_at(L, x0):
            bad += 1
P(f"  {tot} questions of 30 laws: point theory fails in {bad}")

P("== D: Thm 1.11: kappa(F') = PI(proj F') is UP_1-compatible with every datum F' is compatible with")
bad = pairs = 0
for trial in range(150):
    m = rng.choice([3, 4, 5])
    N = m + rng.choice([0, 1, 2])
    F = []
    for _ in range(rng.randint(1, 8)):
        w = rng.randint(1, 3)
        vs = rng.sample(range(1, N + 1), min(w, N))
        F.append(frozenset(v if rng.random() < 0.5 else -v for v in vs))
    pr = projection(F, N, m)
    if not pr:
        continue
    kappa = prime_implicates(sorted(pr), m)
    for _ in range(20):
        alpha = frozenset(v if rng.random() < 0.5 else -v for v in range(1, m + 1) if rng.random() < 0.5)
        for v in range(1, m + 1):
            if v in alpha or -v in alpha:
                continue
            for L in (v, -v):
                for reasoner in ("UP", "PS"):
                    if not compatible(F, N, [(alpha, L)], reasoner):
                        continue
                    pairs += 1
                    r = up(kappa, alpha, 1)
                    sat = any(point_agrees(x, alpha) for x in pr)
                    if r is None or L not in r or not sat:
                        bad += 1
P(f"  {pairs} (theory, datum, reasoner) compatible triples: kappa fails in {bad}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_t1_setting.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
