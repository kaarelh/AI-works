#!/usr/bin/env python3
"""t5_monadic.py -- finite theories with free deduction: monadic finite models, a linear-size counter,
and the bipartite factoring of scout P (its Prop 5.1).

Record: notes.md, Lemma 6.1 (quantitative finite model property), Proposition 6.3 (literal size: the counter
Cnt'_k with carry predicates has O(k) symbols), Proposition 7.2 (factoring).

Part A (Lemma 6.1, independent of scout N1's c2): random sentences over {=, P1, P2, P3} of quantifier rank
  q = 1, 2, 3; random structures given by the 8 cell counts in {0, ..., q+2}; truncating every cell at
  q' = max(q, 1) never changes the truth value.  So every satisfiable such sentence has a model with at most
  2^3 q' elements (the truncated one).  Seed 20261016.
Part B (Prop 6.3): Cnt'_k over P_0..P_{k-1} and carry predicates Q_0..Q_k:
      forall x Q_0 x  &  AND_i forall x (Q_{i+1} x <-> (Q_i x & P_i x))  &  exists x AND_i ~P_i x
      &  forall x (~Q_k x -> exists y AND_i (P_i y <-> (P_i x xor Q_i x))).
  (1) For k = 1, 2, 3 and every structure in which the Q_i are the carries of the P-vector (all P-cell counts in
  {0,1,2}), Cnt'_k holds iff all 2^k P-cells are nonempty.  (2) For k = 1, 2 and 3000 random structures with
  arbitrary Q-labels, Cnt'_k true implies all 2^k P-cells nonempty.  (3) Symbol counts (scout N1's convention:
  iff and xor expanded, atoms P = 2, = = 3) for k = 1..10: linear, against scout N1's quadratic Cnt_k.
Part C (Prop 7.2, scout P's Prop 5.1): for (n, m) = (1,2), (2,2), (2,3), the least number of atom-to-atom implications
  forall x (U x -> V x) over {A_1..A_n, B_1..B_m} equivalent to T_dir is n*m, by exhaustive search over
  subsets (consequence = reachability, by the one-element-model argument); with the extra predicate X the
  theory T_X has n + m members and the same {A, B}-consequences among such implications (reachability).
Writes t5_monadic.out next to itself.
"""
import itertools
import os
import random

SEED = 20261016
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "t5_monadic.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


# ----------------------------------------------------------------------------------------------- formulas
# ('top',) ('bot',) ('eq', i, j) ('P', a, i) ('not', f) ('and', f, g) ('or', f, g) ('ex', i, f) ('all', i, f)

def gen(rng, rank, bound, k, depth=0):
    opts = []
    if bound:
        opts += ["atom"] * 3
    opts += ["not", "and", "or"]
    if rank > 0:
        opts += ["q"] * 3
    if depth > 6:
        opts = ["atom"] if bound else (["q"] if rank > 0 else ["const"])
    c = rng.choice(opts)
    if c == "const":
        return rng.choice([("top",), ("bot",)])
    if c == "atom":
        if rng.random() < 0.6:
            return ("P", rng.randrange(k), rng.choice(bound))
        return ("eq", rng.choice(bound), rng.choice(bound))
    if c == "not":
        return ("not", gen(rng, rank, bound, k, depth + 1))
    if c in ("and", "or"):
        return (c, gen(rng, rank, bound, k, depth + 1), gen(rng, rank, bound, k, depth + 1))
    v = len(bound)
    return (rng.choice(["ex", "all"]), v, gen(rng, rank - 1, bound + [v], k, depth + 1))


def rank_of(f):
    t = f[0]
    if t in ("eq", "P", "top", "bot"):
        return 0
    if t == "not":
        return rank_of(f[1])
    if t in ("and", "or"):
        return max(rank_of(f[1]), rank_of(f[2]))
    return 1 + rank_of(f[2])


def evaluate(f, elems, asg):
    """elems: list of label tuples (one per element)."""
    t = f[0]
    if t == "top":
        return True
    if t == "bot":
        return False
    if t == "eq":
        return asg[f[1]] == asg[f[2]]
    if t == "P":
        return elems[asg[f[2]]][f[1]]
    if t == "not":
        return not evaluate(f[1], elems, asg)
    if t == "and":
        return evaluate(f[1], elems, asg) and evaluate(f[2], elems, asg)
    if t == "or":
        return evaluate(f[1], elems, asg) or evaluate(f[2], elems, asg)
    q = any if t == "ex" else all
    return q(evaluate(f[2], elems, {**asg, f[1]: d}) for d in range(len(elems)))


def struct(counts, k):
    elems = []
    for idx, c in enumerate(counts):
        elems += [tuple(bool((idx >> b) & 1) for b in range(k))] * c
    return elems


def size(f):
    t = f[0]
    if t in ("top", "bot"):
        return 1
    if t == "eq":
        return 3
    if t == "P":
        return 2
    if t == "not":
        return 1 + size(f[1])
    if t in ("and", "or"):
        return 1 + size(f[1]) + size(f[2])
    return 2 + size(f[2])


def part_a():
    log("== Part A: Lemma 6.1 with three predicates ==")
    rng = random.Random(SEED)
    k = 3
    ok = True
    for q in (1, 2, 3):
        pairs = changed = sat = 0
        while pairs < 400:
            f = gen(rng, q, [], k)
            if rank_of(f) != q:
                continue
            counts = [rng.randint(0, q + 2) for _ in range(2 ** k)]
            if sum(counts) == 0:
                counts[rng.randrange(2 ** k)] = 1
            qq = max(q, 1)
            trunc = [min(c, qq) for c in counts]
            v1 = evaluate(f, struct(counts, k), {})
            v2 = evaluate(f, struct(trunc, k), {})
            pairs += 1
            changed += v1 != v2
            sat += v1
        log(f"  rank q = {q}: {pairs} (sentence, structure) pairs ({sat} true), truth changed by truncating every "
            f"cell at q' = {max(q, 1)}: {changed}")
        ok &= changed == 0
    return ok


# --------------------------------------------------------------------------------------- the counter
def conj(fs):
    out = fs[0]
    for g in fs[1:]:
        out = ("and", out, g)
    return out


def iff(a, b):
    return ("or", ("and", a, b), ("and", ("not", a), ("not", b)))


def xor(a, b):
    return ("not", iff(a, b))


def counter_carry(k):
    """Predicates: P_i = index i (i < k), Q_i = index k + i (i <= k).  Variables 0 = x, 1 = y."""
    P = lambda i, v: ("P", i, v)  # noqa: E731
    Q = lambda i, v: ("P", k + i, v)  # noqa: E731
    parts = [("all", 0, Q(0, 0))]
    for i in range(k):
        parts.append(("all", 0, iff(Q(i + 1, 0), ("and", Q(i, 0), P(i, 0)))))
    parts.append(("ex", 0, conj([("not", P(i, 0)) for i in range(k)])))
    succ = conj([iff(P(i, 1), xor(P(i, 0), Q(i, 0))) for i in range(k)])
    parts.append(("all", 0, ("or", Q(k, 0), ("ex", 1, succ))))
    return conj(parts)


def counter_quadratic(k):
    """scout N1's Cnt_k (c2_finite_models.py), for the symbol-count comparison."""
    zero = conj([("not", ("P", i, 0)) for i in range(k)])
    full = conj([("P", i, 0) for i in range(k)])
    parts = []
    for i in range(k):
        carry = conj([("P", j, 0) for j in range(i)]) if i > 0 else ("top",)
        parts.append(iff(("P", i, 1), xor(("P", i, 0), carry)))
    return ("and", ("ex", 0, zero), ("all", 0, ("or", full, ("ex", 1, conj(parts)))))


def carries(vec):
    q = [True]
    for b in vec:
        q.append(q[-1] and b)
    return tuple(q)


def part_b():
    log("== Part B: the counter with carry predicates ==")
    ok = True
    for k in (1, 2, 3):
        f = counter_carry(k)
        bad = n = 0
        for counts in itertools.product(range(3), repeat=2 ** k):
            if sum(counts) == 0:
                continue
            elems = []
            for idx, c in enumerate(counts):
                vec = tuple(bool((idx >> b) & 1) for b in range(k))
                elems += [vec + carries(vec)] * c
            v = evaluate(f, elems, {})
            n += 1
            bad += v != all(c > 0 for c in counts)
        log(f"  k = {k}: {n} structures with carry labels, Cnt'_k true iff all 2^k P-cells nonempty: mismatches {bad}")
        ok &= bad == 0
    rng = random.Random(SEED + 1)
    for k in (1, 2):
        f = counter_carry(k)
        unsound = trues = 0
        for _ in range(3000):
            size_ = rng.randint(1, 2 ** k + 2)
            elems = [tuple(rng.random() < 0.5 for _ in range(2 * k + 1)) for _ in range(size_)]
            if rng.random() < 0.7:  # bias towards correct carries
                elems = [e[:k] + carries(e[:k]) for e in elems]
            if evaluate(f, elems, {}):
                trues += 1
                if len({e[:k] for e in elems}) < 2 ** k:
                    unsound += 1
        log(f"  k = {k}: 3000 random structures with arbitrary Q-labels, {trues} satisfy Cnt'_k; of these, with a "
            f"missing P-cell: {unsound}")
        ok &= unsound == 0
    log("  symbol counts (N1's convention): k, |Cnt'_k| (carries), |Cnt_k| (N1), 2^k")
    prev = None
    diffs = []
    for k in range(1, 11):
        a, b = size(counter_carry(k)), size(counter_quadratic(k))
        log(f"   {k} {a} {b} {2 ** k}")
        if prev is not None:
            diffs.append(a - prev)
        prev = a
    log(f"  first differences of |Cnt'_k|: {diffs} (constant: linear in k)")
    ok &= len(set(diffs)) == 1
    return ok


# --------------------------------------------------------------------------------------- factoring
def closure(edges, atoms):
    reach = {a: {a} for a in atoms}
    changed = True
    while changed:
        changed = False
        for u, v in edges:
            for a in atoms:
                if u in reach[a] and v not in reach[a]:
                    reach[a].add(v)
                    changed = True
    return reach


def part_c():
    log("== Part C: factoring a complete bipartite implication graph (scout P's Prop 5.1) ==")
    ok = True
    for n, m in ((1, 2), (2, 2), (2, 3)):
        A = [f"A{i}" for i in range(n)]
        B = [f"B{j}" for j in range(m)]
        atoms = A + B
        cand = [(u, v) for u in atoms for v in atoms if u != v]
        target = closure([(a, b) for a in A for b in B], atoms)
        best = None
        for r in range(0, n * m + 1):
            for S in itertools.combinations(cand, r):
                if closure(S, atoms) == target:
                    best = r
                    break
            if best is not None:
                break
        # T_X: n + m implications through X; its {A,B}-consequences among implications = reachability restricted
        TX = [(a, "X") for a in A] + [("X", b) for b in B]
        rx = closure(TX, atoms + ["X"])
        same = all((rx[a] - {"X"}) == target[a] for a in atoms)
        log(f"  n = {n}, m = {m}: least equivalent atom-to-atom theory over {{A, B}} has {best} members (n*m = {n * m}); "
            f"T_X has {len(TX)} members and the same consequences on {{A, B}}: {same}")
        ok &= best == n * m and same
    return ok


def main():
    log("t5_monadic.py -- monadic finite models, the carry counter, bipartite factoring")
    ok = part_a()
    ok &= part_b()
    ok &= part_c()
    log("")
    log("all checks passed" if ok else "SOME CHECK FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
