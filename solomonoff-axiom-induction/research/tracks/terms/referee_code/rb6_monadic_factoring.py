#!/usr/bin/env python3
"""rb6_monadic_factoring.py -- referee B: Prop 6.3 (carry counter), Thm 6.2(c) (iota_f), Prop 7.2 (factoring).

  A  Cnt'_k, written from the text of Prop 6.3(b), evaluated as a formula.  It has no equality, so its truth
     in a monadic structure depends only on the set of nonempty cells (cells over P_0..P_{k-1}, Q_0..Q_k);
     we evaluate it on one element per nonempty cell.  k = 1: all 255 nonempty cell sets; k = 2, 3: all subsets
     of the carry-consistent cells, each with 0, 1 or 2 extra cells, plus random cell sets (seeded).  The
     record's characterisation ("the Q_i are the carries and all 2^k P-cells are nonempty") is compared.
  B  Symbol counts of Cnt'_k in scout N1's convention (c2_finite_models.py: atom 2, = 3, not/and/or 1,
     quantifier 2; <-> and xor must be expanded) with two expansions of xor, and in a convention with <-> and
     xor primitive; the record's 64k + 13 and linearity are compared.
  C  Thm 6.2(c)/Prop 7.1: no injective, non-surjective self-map on sets of size <= 7 (exhaustive).
  D  Prop 7.2(b): least number of atom-to-atom implications over {A_i, B_j} equivalent to T_dir, by exhaustive
     search in increasing size, for (n, m) up to 5 atoms; and, beyond the record, the least number when the
     extra atom X may be used (same {A, B}-consequences), for (n, m) in {(1,2),(1,3),(2,2),(2,3)}.
Seed 20261016.  Writes rb6_monadic_factoring.out next to itself.
"""
import itertools
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb6_monadic_factoring.out")
LOG = []
SEED = 20261016


def log(x=""):
    print(x)
    LOG.append(x)


# ------------------------------------------------------------- formulas: ('P', name, var) etc.
def AND(*fs):
    out = fs[0]
    for g in fs[1:]:
        out = ("and", out, g)
    return out


def cnt_prime(k):
    """Cnt'_k with <->, xor and -> as primitives ('iff', 'xor', 'imp'); predicates ('P', i) and ('Q', i)."""
    P = lambda i, v: ("at", ("P", i), v)  # noqa: E731
    Q = lambda i, v: ("at", ("Q", i), v)  # noqa: E731
    parts = [("all", "x", Q(0, "x"))]
    for i in range(k):
        parts.append(("all", "x", ("iff", Q(i + 1, "x"), ("and", Q(i, "x"), P(i, "x")))))
    parts.append(("ex", "x", AND(*[("not", P(i, "x")) for i in range(k)])))
    succ = AND(*[("iff", P(i, "y"), ("xor", P(i, "x"), Q(i, "x"))) for i in range(k)])
    parts.append(("all", "x", ("imp", ("not", Q(k, "x")), ("ex", "y", succ))))
    return AND(*parts)


def ev(f, cells, asg):
    t = f[0]
    if t == "at":
        return f[1] in cells_of(asg[f[2]])
    if t == "not":
        return not ev(f[1], cells, asg)
    if t == "and":
        return ev(f[1], cells, asg) and ev(f[2], cells, asg)
    if t == "or":
        return ev(f[1], cells, asg) or ev(f[2], cells, asg)
    if t == "iff":
        return ev(f[1], cells, asg) == ev(f[2], cells, asg)
    if t == "xor":
        return ev(f[1], cells, asg) != ev(f[2], cells, asg)
    if t == "imp":
        return (not ev(f[1], cells, asg)) or ev(f[2], cells, asg)
    vals = (ev(f[2], cells, {**asg, f[1]: c}) for c in cells)
    return any(vals) if t == "ex" else all(vals)


def cells_of(c):
    return c   # an element is represented by its cell: the frozenset of predicates true of it


def all_cells(k):
    names = [("P", i) for i in range(k)] + [("Q", i) for i in range(k + 1)]
    return [frozenset(n for n, b in zip(names, bits) if b) for bits in itertools.product((0, 1), repeat=len(names))]


def consistent(c, k):
    if ("Q", 0) not in c:
        return False
    return all((("Q", i + 1) in c) == ((("Q", i) in c) and (("P", i) in c)) for i in range(k))


def record_says(cells, k):
    if not all(consistent(c, k) for c in cells):
        return False
    vecs = {tuple(("P", i) in c for i in range(k)) for c in cells}
    return len(vecs) == 2 ** k


def part_a(rng):
    ok = True
    for k in (1, 2, 3):
        f = cnt_prime(k)
        cs = all_cells(k)
        good = [c for c in cs if consistent(c, k)]
        badc = [c for c in cs if not consistent(c, k)]
        tests = []
        if k == 1:
            for r in range(1, len(cs) + 1):
                tests += [list(t) for t in itertools.combinations(cs, r)]
        else:
            for r in range(0, len(good) + 1):
                for sub in itertools.combinations(good, r):
                    for extra in range(0, 3):
                        t = list(sub) + rng.sample(badc, extra)
                        if t:
                            tests.append(t)
            for _ in range(3000):
                t = [c for c in cs if rng.random() < 0.3]
                if t:
                    tests.append(t)
        mism = sum(1 for t in tests if ev(f, t, {}) != record_says(t, k))
        models = [t for t in tests if ev(f, t, {})]
        least = min(len(t) for t in models) if models else None
        log(f"  k = {k}: {len(tests)} cell sets; formula vs record's characterisation: mismatches {mism}; models found "
            f"{len(models)}, least number of nonempty cells in a model {least} (2^k = {2 ** k})")
        ok &= mism == 0 and least == 2 ** k
    return ok


# ------------------------------------------------------------- symbol counts
def size_n1(f, xor_style):
    """Scout N1's convention: atom 2, not/and/or 1, quantifier 2; iff := (a&b)|(~a&~b); imp := ~a | b;
    xor := ~iff (xor_style 'notiff') or (a&~b)|(~a&b) (xor_style 'dnf')."""
    t = f[0]
    if t == "at":
        return 2
    if t == "not":
        return 1 + size_n1(f[1], xor_style)
    if t in ("and", "or"):
        return 1 + size_n1(f[1], xor_style) + size_n1(f[2], xor_style)
    if t == "iff":
        a, b = size_n1(f[1], xor_style), size_n1(f[2], xor_style)
        return 1 + (1 + a + b) + (1 + (1 + a) + (1 + b))
    if t == "xor":
        a, b = size_n1(f[1], xor_style), size_n1(f[2], xor_style)
        iff = 1 + (1 + a + b) + (1 + (1 + a) + (1 + b))
        return 1 + iff if xor_style == "notiff" else 1 + (1 + a + 1 + b) + (1 + 1 + a + b)
    if t == "imp":
        if f[1][0] == "not":     # ~a -> b written a | b (as the developer's t5_monadic.py does)
            return 1 + size_n1(f[1][1], xor_style) + size_n1(f[2], xor_style)
        return 1 + (1 + size_n1(f[1], xor_style)) + size_n1(f[2], xor_style)
    return 2 + size_n1(f[2], xor_style)


def size_prim(f):
    t = f[0]
    if t == "at":
        return 2
    if t == "not":
        return 1 + size_prim(f[1])
    if t in ("and", "or", "iff", "xor", "imp"):
        return 1 + size_prim(f[1]) + size_prim(f[2])
    return 2 + size_prim(f[2])


def part_b():
    rows = []
    for k in range(1, 11):
        f = cnt_prime(k)
        rows.append((k, size_n1(f, "notiff"), size_n1(f, "dnf"), size_prim(f)))
    log("  k, |Cnt'_k| N1 convention (xor = ~iff, ~a -> b = a | b), same with xor in DNF, with <->/xor/-> primitive:")
    for r in rows:
        log("   " + " ".join(str(x) for x in r))
    d1 = {rows[i + 1][1] - rows[i][1] for i in range(len(rows) - 1)}
    d2 = {rows[i + 1][2] - rows[i][2] for i in range(len(rows) - 1)}
    d3 = {rows[i + 1][3] - rows[i][3] for i in range(len(rows) - 1)}
    rec = all(r[1] == 64 * r[0] + 13 for r in rows)
    log(f"  first differences: {sorted(d1)}, {sorted(d2)}, {sorted(d3)}; record's 64k + 13 reproduced in the first "
        f"convention: {rec}")
    return len(d1) == 1 and len(d2) == 1 and len(d3) == 1


def part_c():
    found = 0
    for n in range(1, 8):
        for f in itertools.product(range(n), repeat=n):
            injective = len(set(f)) == n
            surjective = set(f) == set(range(n))
            if injective and not surjective:
                found += 1
    log(f"  injective non-surjective self-maps on sets of size 1..7: {found}")
    return found == 0


# ------------------------------------------------------------- Prop 7.2
def allowed(edges, atoms):
    out = set()
    for bits in itertools.product((0, 1), repeat=len(atoms)):
        val = dict(zip(atoms, bits))
        if all((not val[u]) or val[v] for u, v in edges):
            out.add(bits)
    return out


def project(vals, atoms, keep):
    idx = [atoms.index(a) for a in keep]
    return {tuple(b[i] for i in idx) for b in vals}


def least_theory(n, m, with_X, cap):
    A = [f"A{i}" for i in range(n)]
    Bs = [f"B{j}" for j in range(m)]
    base = A + Bs
    atoms = base + (["X"] if with_X else [])
    target = allowed([(a, b) for a in A for b in Bs], base)
    edges = [(u, v) for u in atoms for v in atoms if u != v]
    for r in range(0, cap + 1):
        for S in itertools.combinations(edges, r):
            if project(allowed(S, atoms), atoms, base) == target:
                return r, S
    return None, None


def part_d():
    ok = True
    for n, m in ((1, 1), (1, 2), (2, 1), (2, 2), (1, 3), (3, 1), (2, 3), (3, 2), (1, 4)):
        r, S = least_theory(n, m, False, n * m)
        log(f"  (n, m) = ({n}, {m}): least atom-to-atom theory over {{A, B}} equivalent to T_dir has {r} members "
            f"(n*m = {n * m})")
        ok &= r == n * m
    for n, m in ((1, 2), (1, 3), (2, 2), (2, 3)):
        r, S = least_theory(n, m, True, min(n * m, n + m))
        log(f"  with X allowed, (n, m) = ({n}, {m}): least size {r} (n*m = {n * m}, n+m = {n + m})")
        ok &= r == min(n * m, n + m)
    return ok


def main():
    rng = random.Random(SEED)
    log("rb6_monadic_factoring.py -- referee B: carry counter, iota_f, factoring")
    log("== Part A: Cnt'_k evaluated as written ==")
    ok = part_a(rng)
    log("== Part B: symbol counts ==")
    ok &= part_b()
    log("== Part C: iota_f has no finite model ==")
    ok &= part_c()
    log("== Part D: Prop 7.2 by exhaustive search ==")
    ok &= part_d()
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
