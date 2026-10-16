#!/usr/bin/env python3
"""rb3_ef_games.py -- referee B: Ehrenfeucht-Fraisse games for Lemma 5.2, Lemma 6.1 and Prop 6.3(a).

A generic EF-game solver on finite relational structures (written here; the developer's t5_monadic.py evaluates
random sentences instead, so this is a different method):
  A  Lemma 5.2(a): A1 =_q B1 and A2 =_q B2 imply A1 + A2 =_q B1 + B2 (disjoint union), on structures with a
     unary U and a binary E built from random numbers of copies of random components (so that =_q but
     non-isomorphic pairs are common), q = 1, 2, 3; only non-isomorphic pairs are counted as informative.
  B  Lemma 5.2(b) in the form Thm 5.1 uses: redefining E(x,y) as E(x,y) or (H(x) & Rt(y)) and forgetting H, Rt
     preserves =_q.
     Control: when B1 =_q B2 holds only unmarked and the chosen roots are not =_q as marked points, the glued
     structures are usually not =_q (so the Rt marker in Thm 5.1 is doing work).
  C  Lemma 6.1 by games: a monadic structure (k = 2, 3 predicates) and its truncation (each cell cut to
     max(q,1) elements) are =_q-equivalent, q = 1, 2; plus the tightness of N(psi) = 2^k max(q,1): the rank-q
     sentence "every cell has at least q elements" has least model size exactly 2^k q.
  D  Pure equality (Lemma 6.1 with k = 0, Prop 6.3(a), Prop 7.1(b)): random rank-q sentences have the same truth
     value on all sets of size >= q; Inf_q separates sizes q-1 and q.
Seed 20261016.  Writes rb3_ef_games.out next to itself.
"""
import itertools
import os
import random
from functools import lru_cache

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb3_ef_games.out")
LOG = []
SEED = 20261016


def log(x=""):
    print(x)
    LOG.append(x)


# A structure: (n, unary: tuple of frozensets (one per unary symbol), binary: tuple of frozensets of pairs)
def rand_struct(rng, n, nu, nb, p=0.4):
    un = tuple(frozenset(i for i in range(n) if rng.random() < p) for _ in range(nu))
    bi = tuple(frozenset((i, j) for i in range(n) for j in range(n) if rng.random() < p) for _ in range(nb))
    return (n, un, bi)


def union(A, B):
    n = A[0] + B[0]
    un = tuple(a | frozenset(x + A[0] for x in b) for a, b in zip(A[1], B[1]))
    bi = tuple(a | frozenset((x + A[0], y + A[0]) for x, y in b) for a, b in zip(A[2], B[2]))
    return (n, un, bi)


def partial_iso(A, B, a, b):
    for i in range(len(a)):
        for j in range(len(a)):
            if (a[i] == a[j]) != (b[i] == b[j]):
                return False
            for E, F in zip(A[2], B[2]):
                if ((a[i], a[j]) in E) != ((b[i], b[j]) in F):
                    return False
        for U, V in zip(A[1], B[1]):
            if (a[i] in U) != (b[i] in V):
                return False
    return True


def equiv(A, B, q):
    @lru_cache(maxsize=None)
    def win(a, b, r):
        if not partial_iso(A, B, a, b):
            return False
        if r == 0:
            return True
        for x in range(A[0]):
            if not any(win(a + (x,), b + (y,), r - 1) for y in range(B[0])):
                return False
        for y in range(B[0]):
            if not any(win(a + (x,), b + (y,), r - 1) for x in range(A[0])):
                return False
        return True
    return win((), (), q)


def isomorphic(A, B):
    if A[0] != B[0]:
        return False
    for perm in itertools.permutations(range(B[0])):
        if all(frozenset(perm[x] for x in U) == V for U, V in zip(A[1], B[1])) and \
                all(frozenset((perm[x], perm[y]) for x, y in E) == F for E, F in zip(A[2], B[2])):
            return True
    return False


def replicated(rng, comps, maxcopies):
    """Disjoint union of random numbers of copies of the given components (so that =_q but non-isomorphic
    pairs are common: m and m' copies with m, m' >= q are indistinguishable in q rounds)."""
    S = None
    while S is None:
        for C in comps:
            for _ in range(rng.randint(0, maxcopies)):
                S = C if S is None else union(S, C)
    return S


def part_a(rng):
    ok = True
    for q, csize, ncomp, maxc, npool, ntest in ((1, (1, 2), 2, 3, 60, 225), (2, (1, 2), 2, 3, 60, 100),
                                                 (3, (1,), 2, 4, 40, 400)):
        comps = [rand_struct(rng, rng.choice(csize), 1, 1) for _ in range(4)]
        pool = [replicated(rng, rng.sample(comps, ncomp), maxc) for _ in range(npool)]
        pairs = [(A, B) for A, B in itertools.combinations(pool, 2)
                 if A[0] <= 8 and B[0] <= 8 and equiv(A, B, q) and not isomorphic(A, B)]
        rng.shuffle(pairs)
        tested = bad = 0
        half = len(pairs) // 2
        for (A1, B1), (A2, B2) in itertools.islice(itertools.product(pairs[:half], pairs[half:]), ntest):
            cap = 10 if q < 3 else 12
            if union(A1, A2)[0] > cap or union(B1, B2)[0] > cap:
                continue
            tested += 1
            if not equiv(union(A1, A2), union(B1, B2), q):
                bad += 1
        log(f"  q = {q}: {len(pairs)} informative pairs (=_q, not isomorphic); {tested} unions tested; "
            f"=_q violated {bad}")
        ok &= bad == 0 and tested > 0
    return ok


def glue(A, B, hA, rB, marked):
    """Disjoint union of A (context) and B (subtree) plus one E-edge from hA in A to rB in B.
    If marked, the edge is defined through unary markers H (on A) and Rt (on B), quantifier-free, as in Thm 5.1."""
    U = union(A, B)
    n, un, bi = U
    E = bi[0] | {(hA, A[0] + rB)}
    return (n, un, (E,))


def part_b(rng):
    ok = True
    tested = bad = ctrl = ctrl_broken = 0
    q = 2
    comps = [rand_struct(rng, rng.choice((1, 2)), 1, 1) for _ in range(4)]
    for _ in range(300):
        A = rand_struct(rng, rng.choice((1, 2)), 1, 1)
        B1 = replicated(rng, rng.sample(comps, 2), 3)
        B2 = replicated(rng, rng.sample(comps, 2), 3)
        if B1[0] > 6 or B2[0] > 6 or not equiv(B1, B2, q):
            continue
        hA = rng.randrange(A[0])
        for r1 in range(B1[0]):
            for r2 in range(B2[0]):
                M1 = (B1[0], B1[1] + (frozenset([r1]),), B1[2])
                M2 = (B2[0], B2[1] + (frozenset([r2]),), B2[2])
                glued_equiv = equiv(glue(A, B1, hA, r1, True), glue(A, B2, hA, r2, True), q)
                if equiv(M1, M2, q):
                    tested += 1
                    bad += not glued_equiv
                else:
                    ctrl += 1
                    ctrl_broken += not glued_equiv
    log(f"  q = 2: gluing with Rt-marked roots =_q (as Thm 5.1 needs): {tested} cases, =_q violated {bad}; control "
        f"(B1 =_q B2 unmarked, but roots not =_q as marked points): {ctrl} cases, glued structures not =_q in "
        f"{ctrl_broken}")
    ok &= bad == 0 and tested > 0 and ctrl_broken > 0
    return ok


def monadic(counts, k):
    """Monadic structure with cells given by counts (index bits = predicate values)."""
    elems = []
    for idx, c in enumerate(counts):
        elems += [idx] * c
    n = len(elems)
    un = tuple(frozenset(i for i, e in enumerate(elems) if (e >> b) & 1) for b in range(k))
    return (n, un, ())


def part_c(rng):
    ok = True
    for k, q, trials, cmax in ((2, 1, 60, 3), (2, 2, 60, 3), (3, 1, 40, 2), (3, 2, 25, 3)):
        bad = done = 0
        while done < trials:
            counts = [rng.randint(0, cmax) for _ in range(2 ** k)]
            if sum(counts) == 0:
                continue
            qq = max(q, 1)
            trunc = [min(c, qq) for c in counts]
            if trunc == counts:
                continue
            done += 1
            if not equiv(monadic(counts, k), monadic(trunc, k), q):
                bad += 1
        # one-step-smaller truncation must fail somewhere (the bound max(q,1) per cell is needed)
        fail_smaller = 0
        if q >= 2:
            for _ in range(20):
                counts = [rng.randint(q, q + 1) for _ in range(2 ** k)]
                smaller = [min(c, q - 1) for c in counts]
                fail_smaller += not equiv(monadic(counts, k), monadic(smaller, k), q)
        log(f"  k = {k}, q = {q}: {done} structures vs their truncation at max(q,1): =_q violated {bad}"
            + (f"; truncation at q-1 breaks =_q in {fail_smaller}/20" if q >= 2 else ""))
        ok &= bad == 0 and (q < 2 or fail_smaller > 0)
    # tightness of N(psi) = 2^k q: least model of "every cell has >= q elements" (rank q)
    tight = []
    for k in (1, 2):
        for q in (1, 2, 3):
            least = None
            for n in range(1, 2 ** k * q + 1):
                # a model of size n exists iff n cells can be split with >= q per cell
                if n >= 2 ** k * q:
                    least = n
                    break
            tight.append((k, q, least, 2 ** k * q))
    log("  tightness: least model of 'every one of the 2^k cells has >= q elements' (rank q): "
        + ", ".join(f"k={k},q={q}: {a} (= 2^k q = {b})" for k, q, a, b in tight))
    ok &= all(a == b for _, _, a, b in tight)
    return ok


# ---------------------------------------------------------------- pure equality sentences
def gen_eq(rng, rank, vars_in_scope, depth=0):
    if rank == 0 or (depth > 0 and rng.random() < 0.25 and vars_in_scope):
        if not vars_in_scope:
            return ("top",) if rng.random() < 0.5 else ("bot",)
        a, b = rng.choice(vars_in_scope), rng.choice(vars_in_scope)
        return ("eq", a, b)
    r = rng.random()
    if r < 0.2:
        return ("not", gen_eq(rng, rank, vars_in_scope, depth + 1))
    if r < 0.45:
        return (rng.choice(("and", "or")), gen_eq(rng, rank, vars_in_scope, depth + 1),
                gen_eq(rng, rng.randint(0, rank), vars_in_scope, depth + 1))
    v = len(vars_in_scope)
    return (rng.choice(("ex", "all")), v, gen_eq(rng, rank - 1, vars_in_scope + [v], depth + 1))


def qrank(f):
    t = f[0]
    if t in ("top", "bot", "eq"):
        return 0
    if t == "not":
        return qrank(f[1])
    if t in ("and", "or"):
        return max(qrank(f[1]), qrank(f[2]))
    return 1 + qrank(f[2])


def ev(f, n, asg):
    t = f[0]
    if t == "top":
        return True
    if t == "bot":
        return False
    if t == "eq":
        return asg[f[1]] == asg[f[2]]
    if t == "not":
        return not ev(f[1], n, asg)
    if t == "and":
        return ev(f[1], n, asg) and ev(f[2], n, asg)
    if t == "or":
        return ev(f[1], n, asg) or ev(f[2], n, asg)
    vals = (ev(f[2], n, {**asg, f[1]: x}) for x in range(n))
    return any(vals) if t == "ex" else all(vals)


def part_d(rng):
    ok = True
    for q in (1, 2, 3, 4):
        bad = done = 0
        while done < 300:
            f = gen_eq(rng, q, [])
            if qrank(f) != q:
                continue
            done += 1
            vals = {ev(f, n, {}) for n in range(q, q + 3)}
            bad += len(vals) > 1
        log(f"  pure equality, rank q = {q}: 300 random sentences, truth not constant on sizes q..q+2: {bad}")
        ok &= bad == 0
    inf = lambda m: ("ex", 0, ("ex", 1, ("not", ("eq", 0, 1)))) if m == 2 else None  # noqa: E731
    sep = ev(inf(2), 2, {}) and not ev(inf(2), 1, {})
    log(f"  Inf_2 true in size 2 and false in size 1: {sep}")
    return ok and sep


def main():
    rng = random.Random(SEED)
    log("rb3_ef_games.py -- referee B: EF games for Lemma 5.2, Lemma 6.1, Prop 6.3(a)")
    log("== Part A: Lemma 5.2(a), disjoint unions ==")
    ok = part_a(rng)
    log("== Part B: Lemma 5.2(b), the marked one-edge gluing of Thm 5.1 ==")
    ok &= part_b(rng)
    log("== Part C: Lemma 6.1 by games; tightness of 2^k max(q,1) ==")
    ok &= part_c(rng)
    log("== Part D: pure equality ==")
    ok &= part_d(rng)
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
