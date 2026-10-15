"""c2_finite_models.py -- finite checks for the theoretical-terms results (notes.md, section 5).

Seed 20261015. Output: c2_finite_models.out.

Part A (pure equality). For random first-order sentences over {=} of quantifier rank <= q (q = 1..4),
  the truth value is the same in all sets of size >= q (sizes q..q+3 checked), as the
  Ehrenfeucht-Fraisse argument in Lemma B1.1 says.
Part B (monadic). For random sentences over {=, P1, P2} of rank <= q (q = 1..3) and random structures
  (given by the four cell counts), truncating every cell count at q preserves the truth value
  (Lemma B1.1). Hence a satisfiable sentence has a model with at most 2^k q elements.
Part C (a unary function). The sentence iota = "f is injective and not surjective" has no model of
  size 1..6 (all functions enumerated).
Part D (the binary counter). For k = 1..3 the monadic sentence Cnt_k (size O(k^2)) holds in a
  monadic structure exactly when all 2^k cells are nonempty (all cell-count vectors with counts in
  {0,1,2} checked), so every model has >= 2^k elements. Symbol counts of Cnt_k and of
  lambda_n ("there are at least n elements") are printed.
"""
import itertools
import random

SEED = 20261015
random.seed(SEED)

# Formulas: ("eq", i, j) | ("P", a, i) | ("not", f) | ("and", f, g) | ("or", f, g) |
#           ("ex", i, f) | ("all", i, f) | ("top",) | ("bot",)


def gen(rank, bound, k, depth=0):
    """Random formula with free variables among `bound` and quantifier rank <= rank."""
    choices = []
    if bound:
        choices += ["atom"] * 3
    choices += ["not", "and", "or"]
    if rank > 0:
        choices += ["q"] * 3
    if depth > 6:
        choices = ["atom"] if bound else (["q"] if rank > 0 else ["const"])
    if not choices:
        choices = ["const"]
    c = random.choice(choices)
    if c == "const":
        return random.choice([("top",), ("bot",)])
    if c == "atom":
        if k > 0 and random.random() < 0.5:
            return ("P", random.randrange(k), random.choice(bound))
        return ("eq", random.choice(bound), random.choice(bound))
    if c == "not":
        return ("not", gen(rank, bound, k, depth + 1))
    if c in ("and", "or"):
        return (c, gen(rank, bound, k, depth + 1), gen(rank, bound, k, depth + 1))
    v = len(bound)  # fresh variable index (no shadowing)
    return (random.choice(["ex", "all"]), v, gen(rank - 1, bound + [v], k, depth + 1))


def rank_of(f):
    t = f[0]
    if t in ("eq", "P", "top", "bot"):
        return 0
    if t == "not":
        return rank_of(f[1])
    if t in ("and", "or"):
        return max(rank_of(f[1]), rank_of(f[2]))
    return 1 + rank_of(f[2])


def ev(f, cells, asg):
    """cells: list of tuples of booleans (the predicate values of each element)."""
    t = f[0]
    if t == "top":
        return True
    if t == "bot":
        return False
    if t == "eq":
        return asg[f[1]] == asg[f[2]]
    if t == "P":
        return cells[asg[f[2]]][f[1]]
    if t == "not":
        return not ev(f[1], cells, asg)
    if t == "and":
        return ev(f[1], cells, asg) and ev(f[2], cells, asg)
    if t == "or":
        return ev(f[1], cells, asg) or ev(f[2], cells, asg)
    v, body = f[1], f[2]
    res = (any if t == "ex" else all)(ev(body, cells, {**asg, v: d}) for d in range(len(cells)))
    return res


def structure_from_counts(counts, k):
    cells = []
    for idx, c in enumerate(counts):
        label = tuple(bool((idx >> b) & 1) for b in range(k))
        cells += [label] * c
    return cells


def part_a():
    print("== Part A: pure equality ==")
    for q in range(1, 5):
        n_sent = 0
        bad = 0
        for _ in range(250):
            f = gen(q, [], 0)
            if rank_of(f) > q:
                continue
            n_sent += 1
            vals = [ev(f, [()] * n, {}) for n in range(q, q + 4)]
            if len(set(vals)) > 1:
                bad += 1
        print(f"  q={q}: {n_sent} sentences, truth not constant on sizes q..q+3: {bad}")
        assert bad == 0


def part_b():
    print("== Part B: monadic, k = 2 predicates, truncation of cell counts at q ==")
    k = 2
    for q in range(1, 4):
        n_checks = 0
        bad = 0
        for _ in range(150):
            f = gen(q, [], k)
            if rank_of(f) > q:
                continue
            for _s in range(4):
                counts = [random.randint(0, q + 2) for _ in range(2 ** k)]
                if sum(counts) == 0:
                    counts[0] = 1
                trunc = [min(c, q) for c in counts]
                v1 = ev(f, structure_from_counts(counts, k), {})
                v2 = ev(f, structure_from_counts(trunc, k), {})
                n_checks += 1
                if v1 != v2:
                    bad += 1
        print(f"  q={q}: {n_checks} (sentence, structure) pairs, truth changed by truncation: {bad}")
        assert bad == 0


def part_c():
    print("== Part C: iota = f injective and not surjective ==")
    for n in range(1, 7):
        sat = 0
        for f in itertools.product(range(n), repeat=n):
            inj = len(set(f)) == n
            nonsurj = len(set(f)) < n
            if inj and nonsurj:
                sat += 1
        print(f"  size {n}: {n**n} functions, models of iota: {sat}")
        assert sat == 0


def counter(k):
    """Cnt_k as a formula over P_0..P_{k-1} (variables 0 = x, 1 = y)."""
    def conj(fs):
        out = fs[0]
        for g in fs[1:]:
            out = ("and", out, g)
        return out

    def iff(a, b):
        return ("or", ("and", a, b), ("and", ("not", a), ("not", b)))

    def xor(a, b):
        return ("not", iff(a, b))
    zero = conj([("not", ("P", i, 0)) for i in range(k)])
    full = conj([("P", i, 0) for i in range(k)])
    succ_parts = []
    for i in range(k):
        carry = conj([("P", j, 0) for j in range(i)]) if i > 0 else ("top",)
        succ_parts.append(iff(("P", i, 1), xor(("P", i, 0), carry)))
    succ = conj(succ_parts)
    return ("and", ("ex", 0, zero), ("all", 0, ("or", full, ("ex", 1, succ))))


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


def lam(n):
    """lambda_n: there exist x_0..x_{n-1} pairwise distinct."""
    body = ("top",)
    for i in range(n):
        for j in range(i + 1, n):
            body = ("and", body, ("not", ("eq", i, j)))
    for i in reversed(range(n)):
        body = ("ex", i, body)
    return body


def part_d():
    print("== Part D: binary counter Cnt_k ==")
    for k in range(1, 4):
        f = counter(k)
        bad = 0
        tot = 0
        for counts in itertools.product(range(3), repeat=2 ** k):
            if sum(counts) == 0:
                continue
            tot += 1
            v = ev(f, structure_from_counts(list(counts), k), {})
            if v != all(c > 0 for c in counts):
                bad += 1
        print(f"  k={k}: {tot} structures, Cnt_k true iff all 2^k cells nonempty; mismatches {bad}")
        assert bad == 0
    def lam_size(n):  # closed form of size(lam(n)): top, C(n,2) conjuncts "and not eq", n quantifiers
        return 1 + 5 * (n * (n - 1) // 2) + 2 * n
    for n in range(1, 17):
        assert lam_size(n) == size(lam(n))
    print("  closed form |lambda_n| = 1 + 5 C(n,2) + 2n agrees with the recursive count for n <= 16")
    print("  symbol counts: k, |Cnt_k|, 2^k, |lambda_(2^k)|")
    for k in range(1, 11):
        print(f"   {k} {size(counter(k))} {2**k} {lam_size(2**k)}")
    for n in (2, 3, 4):
        assert ev(lam(n), [()] * n, {}) and not ev(lam(n), [()] * (n - 1), {})
    print("  lambda_n true in size n and false in size n-1 for n = 2, 3, 4: OK")


if __name__ == "__main__":
    print(f"seed {SEED}")
    part_a()
    part_b()
    part_c()
    part_d()
    print("all assertions passed")
