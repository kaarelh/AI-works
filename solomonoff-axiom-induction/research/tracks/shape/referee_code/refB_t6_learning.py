"""Referee B, thread `shape`, target T6 (Lemma 6.1, Theorem 6.2: learning pattern by pattern).

Independent of checks/. Seed 20261016. Writes refB_t6_learning.out next to itself.

Setting as in the record: Par_m = even parity; Q_{m-1} = questions q = (j, gamma), gamma in Par_m, antecedent
gamma minus x_j, answer x_j = gamma_j; pattern pi(q) = gamma xor e_j.

Checks
 A  Lemma 6.1 (i) <=> (ii) <=> (iii): m = 3 all theories of <= 3 clauses, m = 3, 4 random larger theories.
 B  Thm 6.2(a): m = 3, every theory of <= 5 clauses (of all 26): fully correct iff it is PI(Par_3).
 C  Thm 6.2(b): all inclusion-minimal UP-compatible theories (found by enumeration of clause subsets, with
    compatibility tested directly by UP and satisfiability), m = 3 (|D| <= 5) and m = 4 (|D| <= 3);
    failures on Q_{m-1} >= unseen patterns. Larger D (m = 4, 5) via minimal hitting sets (Lemma 6.1, checked in A).
 D  Thm 6.2(c): coupon-collector numbers, exact and simulated.
 E  Thm 6.2(d): exact mixture weight W_lst over all theories over X (m = 3, block-complete data) against r b_m.
 F  Thm 6.2(e): listing lengths of one equation and of the chain encoding.
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


def par(m):
    return [x for x in range(1 << m) if popcount(x) % 2 == 0]


def questions(m):
    qs = []
    for g in par(m):
        for j in range(1, m + 1):
            alpha = frozenset((v if bit(g, v) else -v) for v in range(1, m + 1) if v != j)
            L = j if bit(g, j) else -j
            qs.append((j, g, alpha, L))
    return qs


def pattern(q):
    j, g, _, _ = q
    return g ^ (1 << (j - 1))


def compatible_q(F, q, m):
    """(i): F u alpha satisfiable and UP derives the answer."""
    j, g, alpha, L = q
    sat = any(theory_true_at(F, x) for x in range(1 << m) if point_agrees(x, alpha))
    if not sat:
        return False
    r = up(F, alpha)
    return r is not None and L in r


def correct_q(F, q):
    """(ii): UP derives exactly x_j = gamma_j without conflict."""
    j, g, alpha, L = q
    r = up(F, alpha)
    return r is not None and L in r and -L not in r


def cond_iii(F, q, m):
    j, g, alpha, L = q
    pi = pattern(q)
    return theory_true_at(F, g) and any((j in {abs(x) for x in C}) and not clause_true_at(C, pi) for C in F)


P("# refB_t6_learning.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
# ------------------------------------------------------------------ A
P("== A: Lemma 6.1: (i) compatible <=> (ii) answered correctly <=> (iii) gamma |= F and a clause on x_j is falsified by pi(q)")
for m, mode in [(3, "all <= 3"), (3, "random"), (4, "random")]:
    allc = all_clauses(range(1, m + 1))
    qs = questions(m)
    if mode == "all <= 3":
        theories = [list(G) for s in range(0, 4) for G in combinations(allc, s)]
    else:
        theories = []
        for _ in range(3000):
            s = rng.randint(1, 10)
            theories.append(rng.sample(allc, s))
    bad = 0
    n = 0
    for F in theories:
        for q in qs:
            a, b, c = compatible_q(F, q, m), correct_q(F, q), cond_iii(F, q, m)
            n += 1
            bad += not (a == b == c)
    P(f"  m={m} ({mode} theories: {len(theories)}): {n} (theory, question) pairs; mismatches = {bad}")

# ------------------------------------------------------------------ B
P("== B: Thm 6.2(a): fully correct theories among all theories of <= 5 clauses (m = 3)")
m = 3
allc = all_clauses(range(1, m + 1))
qs = questions(m)
PI = set(prime_implicates(par(m), m))
full = []
cnt = 0
for s in range(0, 6):
    for G in combinations(allc, s):
        cnt += 1
        if all(correct_q(list(G), q) for q in qs):
            full.append(set(G))
P(f"  {cnt} theories; fully correct: {len(full)}; equal to PI(Par_3): {[F == PI for F in full]}")
# poisoning: any theory containing a clause falsified by some point of Par_m fails some question
pois_bad = 0
for C in allc:
    if is_implicate(C, par(m)):
        continue
    for _ in range(20):
        F = [C] + rng.sample(allc, rng.randint(0, 8))
        if all(correct_q(F, q) for q in qs):
            pois_bad += 1
P(f"  theories containing a non-implicate that were fully correct (random supersets): {pois_bad}")

# ------------------------------------------------------------------ C
P("== C: Thm 6.2(b): every inclusion-minimal UP-compatible theory fails on >= (number of unseen patterns) questions")


def minimal_compatible_enum(D, m, allc, maxsize):
    """All inclusion-minimal compatible theories with <= maxsize clauses (direct test)."""
    comp = []
    for s in range(0, maxsize + 1):
        for G in combinations(allc, s):
            Gs = set(G)
            if any(H <= Gs for H in comp):
                continue
            if all(compatible_q(list(G), q, m) for q in D):
                comp.append(Gs)
    return comp


def failures(F, qs):
    return sum(1 for q in qs if not correct_q(F, q))


for m, sizes, trials in [(3, [1, 2, 3, 4, 5], 4), (4, [1, 2, 3], 3)]:
    allc = all_clauses(range(1, m + 1))
    qs = questions(m)
    tot = viol = 0
    worst = None
    for t in sizes:
        for _ in range(trials):
            D = rng.sample(qs, t)
            unseen = (1 << (m - 1)) - len({pattern(q) for q in D})
            mins = minimal_compatible_enum(D, m, allc, t)
            for F in mins:
                f = failures(list(F), qs)
                tot += 1
                viol += (f < unseen)
                gap = f - unseen
                if worst is None or gap < worst:
                    worst = gap
            # shortest by listing length
            best = min(mins, key=lambda F: ell_lst(list(F), m, m))
            assert failures(list(best), qs) >= unseen
    P(f"  m={m}: |D| in {sizes}, {trials} random D each: {tot} minimal compatible theories; failures < unseen in {viol}; "
      f"min (failures - unseen) = {worst}")


def random_minimal_hitting_set(fam, rng):
    """A random inclusion-minimal hitting set of the family fam (list of frozensets)."""
    H = set()
    order = list(range(len(fam)))
    rng.shuffle(order)
    for i in order:
        if not (fam[i] & H):
            H.add(rng.choice(sorted(fam[i], key=lambda C: sorted(C))))
    for c in rng.sample(sorted(H, key=lambda C: sorted(C)), len(H)):
        if all(f & (H - {c}) for f in fam):
            H.discard(c)
    return frozenset(H)


for m, sizes, ndraw in [(4, [4, 6, 8, 12, 16], 300), (5, [4, 8, 16, 32], 200), (6, [8, 32, 64], 100)]:
    allc = all_clauses(range(1, m + 1))
    qs = questions(m)
    tot = viol = nonmin = 0
    worst = None
    ratios = []
    for t in sizes:
        for _ in range(3):
            D = rng.sample(qs, t)
            unseen = (1 << (m - 1)) - len({pattern(q) for q in D})
            pos = {q[1] for q in D}
            adm = [C for C in allc if all(clause_true_at(C, g) for g in pos)]
            fam = []
            for q in D:
                j = q[0]
                pi = pattern(q)
                fam.append(frozenset(C for C in adm if j in {abs(x) for x in C} and not clause_true_at(C, pi)))
            seenH = set()
            for _ in range(ndraw):
                H = random_minimal_hitting_set(fam, rng)
                if H in seenH:
                    continue
                seenH.add(H)
                F = list(H)
                assert all(compatible_q(F, q, m) for q in D)
                # inclusion-minimality checked directly with UP
                if any(all(compatible_q([C for C in F if C != c], q, m) for q in D) for c in F):
                    nonmin += 1
                f = failures(F, qs)
                tot += 1
                viol += (f < unseen)
                if unseen:
                    ratios.append(f / unseen)
                gap = f - unseen
                if worst is None or gap < worst:
                    worst = gap
    mr = sum(ratios) / len(ratios) if ratios else float('nan')
    P(f"  m={m} (random minimal hitting sets, Lemma 6.1): |D| in {sizes}: {tot} distinct minimal compatible theories "
      f"(non-minimal by direct test: {nonmin}); failures < unseen in {viol}; min (failures - unseen) = {worst}; "
      f"mean failures/unseen = {mr:.2f}")

# ------------------------------------------------------------------ D
P("== D: Thm 6.2(c): coupon collector over the 2^(m-1) patterns")
for m in (4, 5, 6):
    n = 1 << (m - 1)
    H = sum(1 / i for i in range(1, n + 1))
    approx = n * ((m - 1) * math.log(2) + 0.5772)
    qs = questions(m)
    sims = []
    for _ in range(4000):
        seen = set()
        T = 0
        while len(seen) < n:
            T += 1
            seen.add(pattern(qs[rng.randrange(len(qs))]))
        sims.append(T)
    unseen16 = n * (1 - 1 / n) ** 16
    P(f"  m={m}: exact E[T_all] = n H_n = {n * H:.2f}; record's approximation n((m-1)ln2+0.577) = {approx:.2f}; "
      f"simulated (4000 runs) {sum(sims) / len(sims):.2f}; E[unseen at T=16] = {unseen16:.3f}")

# ------------------------------------------------------------------ E
P("== E: Thm 6.2(d): exact W_lst over all theories over X (m = 3), block-complete data, against r * b_m")
m = 3
allc = all_clauses(range(1, m + 1))
qs = questions(m)
b_m = ell_N(m) + m * (math.ceil(math.log2(m)) + 1)
for r in (1, 2, 3, 4):
    pats = sorted({pattern(q) for q in qs})[:r]
    D = [q for q in qs if pattern(q) in pats]
    pos = {q[1] for q in D}
    adm = [C for C in allc if all(clause_true_at(C, g) for g in pos)]
    W = 0.0
    nth = 0
    for mask in range(1 << len(adm)):
        F = [adm[i] for i in range(len(adm)) if mask >> i & 1]
        if all(compatible_q(F, q, m) for q in D):
            W += 2.0 ** (-ell_lst(F, m, m))
            nth += 1
    P(f"  r={r} seen patterns (|D|={len(D)}): admissible clauses {len(adm)}, compatible theories {nth}, "
      f"-log2 W = {-math.log2(W):.3f}; r*b_m = {r * b_m} (b_3 = {b_m})")

# ------------------------------------------------------------------ F
P("== F: Thm 6.2(e): listing lengths (record's l_lst, Elias delta for l_N)")
for m in range(3, 9):
    lw = math.ceil(math.log2(m)) + 1
    one_eq = ell_N(0) + ell_N(1) + ell_N(m) + m * math.ceil(math.log2(m)) + 1
    F, nxt = chain_encoding(list(range(1, m + 1)), 0, m + 1)
    chain = ell_lst(F, m, nxt - 1)
    PIlen = ell_lst(prime_implicates(par(m), m), m, m) if m <= 6 else None
    P(f"  m={m}: one equation {one_eq} bits (m ceil(log2 m) = {m * math.ceil(math.log2(m))}); chain encoding {chain} bits; "
      f"PI(Par_m) {PIlen} bits; 2^(m-1) b_m = {2 ** (m - 1) * (ell_N(m) + m * lw)}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_t6_learning.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
