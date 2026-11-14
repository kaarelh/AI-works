"""Referee, second pass: Proposition 4a of equational.md (a few missing pairs), checked and extended.

Own term machinery (eq_test_radius.py); nothing of code/ is used.

Data: plus on [0, n)^2 except a set U of missing pairs ("holes").  An identity is refuted by the
data if at some assignment both sides can be evaluated from the data alone and differ.

Part 1.  The statement of Proposition 4a(1) on the grid of its proof: for sides of at most m symbols,
         n = m^2 (h + 1) and assignments with values 0..K, K = (m - 1) h + 1, every identity false of
         plus that is not refuted there has a side containing a ground term f(r1, r2) whose
         arguments have values (a, b) in U, and that side has at least a + b + 3 symbols.
         The five cases of code/holes_check.py (the counts must agree) and further ones, among
         them m = 6 with two holes and m = 5 with three.
Part 2.  A simpler and stronger statement for holes that are not small ("Proposition 4b" of the
         report): if a + b >= m for every hole, every identity false of plus with sides of at most
         m <= n + 1 symbols is refuted already at an assignment of zeros and ones, whatever the
         number of holes.  Checked with ALL pairs with a + b >= m missing.
Part 3.  What happens between: one hole, n smaller than m^2 (h + 1).  For each n the number of
         false identities that are not refuted (all assignments that can be evaluated) and do not
         name the hole by a ground term.  Shows that 4a(1) needs some condition on n, and how
         far m^2 (h + 1) is from what is needed in these cases.

Part 4.  Low holes ("4c" of the report): if both coordinates of every hole are at most A and
         n > (A + 2)(m - 2), statement (1) holds whatever the number of holes, because the
         assignments with all values in {A + 1, A + 2} apply f at no hole outside ground terms.
         Checked with the whole square [0, A]^2 missing.
Part 5.  Some dependence of n on the number of holes is needed for (1): with the holes (1,1),
         (4,4), (6,6), ..., (2h, 2h) the identity f(x, f(x,x)) = f(S(x), S(x)) (sides of 5 symbols)
         names no hole by a ground term and is not refuted as long as n <= 4h + 2.

Usage: python3 eq2_holes.py            (about 5 minutes)
"""
import itertools
import sys

import numpy as np

sys.dont_write_bytecode = True
from eq_test_radius import all_terms, parse  # noqa: E402

plus = lambda a, b: a + b


def evaluate(tree, env, data):
    """(value under plus, value from the data or None)"""
    if isinstance(tree, str):
        v = 0 if tree == "0" else env[tree]
        return v, v
    if tree[0] == "S":
        p, d = evaluate(tree[1], env, data)
        return p + 1, (None if d is None else d + 1)
    (p1, d1), (p2, d2) = evaluate(tree[1], env, data), evaluate(tree[2], env, data)
    d = None
    if d1 is not None and d2 is not None:
        d = data(d1, d2)
    return p1 + p2, d


def size(tree):
    return 1 if isinstance(tree, str) else 1 + sum(size(u) for u in tree[1:])


def is_ground(tree):
    if isinstance(tree, str):
        return tree == "0"
    return all(is_ground(u) for u in tree[1:])


def ground_value(tree):
    return evaluate(tree, {}, lambda a, b: a + b)[0]


def named_holes(tree, U):
    """the holes (a, b) for which the term contains a ground f(r1, r2) with values (a, b)"""
    out = set()
    if isinstance(tree, str):
        return out
    if tree[0] == "f" and is_ground(tree[1]) and is_ground(tree[2]):
        p = (ground_value(tree[1]), ground_value(tree[2]))
        if p in U:
            out.add(p)
    for u in tree[1:]:
        out |= named_holes(u, U)
    return out


def tables(m, data, values, nvars=3):
    by = all_terms(2, nvars, m)
    terms = [t for s in range(1, m + 1) for t in by[s]]
    trees = [parse(t, 2)[0] for t in terms]
    var = "abc"[:nvars]
    grid = [dict(zip(var, u)) for u in itertools.product(values, repeat=nvars)]
    PV = np.empty((len(terms), len(grid)), dtype=np.int64)
    DV = np.empty((len(terms), len(grid)), dtype=np.int64)
    for i, tr in enumerate(trees):
        for j, env in enumerate(grid):
            p, d = evaluate(tr, env, data)
            PV[i, j] = p
            DV[i, j] = -1 if d is None else d
    return terms, trees, PV, DV


def unrefuted(PV, DV):
    """pairs (i, j), i < j, false of plus on the grid and not refuted by the data on the grid; and the number false"""
    out, nfalse = [], 0
    for i in range(len(PV) - 1):
        false = (PV[i][None, :] != PV[i + 1:]).any(axis=1)
        ref = ((DV[i][None, :] >= 0) & (DV[i + 1:] >= 0) & (DV[i][None, :] != DV[i + 1:])).any(axis=1)
        nfalse += int(false.sum())
        for j in np.nonzero(false & ~ref)[0]:
            out.append((i, i + 1 + int(j)))
    return out, nfalse


def pretty(tree):
    if isinstance(tree, str):
        return {"a": "x", "b": "y", "c": "z", "0": "0"}[tree]
    if tree[0] == "S":
        return "S(" + pretty(tree[1]) + ")"
    return "f(" + pretty(tree[1]) + "," + pretty(tree[2]) + ")"


def part1(m, U, n=None):
    U = set(U)
    h = len(U)
    n = m * m * (h + 1) if n is None else n
    K = (m - 1) * h + 1
    data = lambda a, b: a + b if a < n and b < n and (a, b) not in U else None
    terms, trees, PV, DV = tables(m, data, range(K + 1))
    pairs, nfalse = unrefuted(PV, DV)
    bad = short = 0
    for i, j in pairs:
        ok = False
        for tr in (trees[i], trees[j]):
            for (a, b) in named_holes(tr, U):
                ok = True
                if size(tr) < a + b + 3:
                    short += 1
        bad += not ok
    maxf = max(t.count("f") for t in terms)
    print(f"m={m} n={n} K={K} holes {sorted(U)}: {len(terms)} terms, {nfalse} false identities, {len(pairs)} not refuted on the grid, "
          f"{bad} of these name no hole, {short} naming sides shorter than a+b+3; most f in one side: {maxf} (2*{maxf} <= m-1: {2 * maxf <= m - 1})")
    sys.stdout.flush()
    return nfalse, len(pairs), bad


def part2(m):
    n = m - 1                                            # arguments of f have at most m - 2 symbols
    data = lambda a, b: a + b if a < n and b < n and a + b < m else None        # every pair with a + b >= m is missing
    terms, trees, PV, DV = tables(m, data, (0, 1))
    pairs, nfalse = unrefuted(PV, DV)
    kept = sum(1 for a in range(n) for b in range(n) if a + b < m)
    print(f"m={m}: data = plus on the {kept} pairs with a, b <= {m - 2} and a + b <= {m - 1}; assignments of zeros and ones only: "
          f"{nfalse} false identities, not refuted: {len(pairs)}")
    sys.stdout.flush()


def part3(m, hole, ns):
    U = {hole}
    for n in ns:
        data = lambda a, b: a + b if a < n and b < n and (a, b) not in U else None
        terms, trees, PV, DV = tables(m, data, range(n + 2))
        pairs, nfalse = unrefuted(PV, DV)
        bad = [(i, j) for i, j in pairs if not (named_holes(trees[i], U) or named_holes(trees[j], U))]
        ex = f"   e.g. {pretty(trees[bad[0][0]])} = {pretty(trees[bad[0][1]])}" if bad else ""
        print(f"   m={m} hole {hole} n={n:2d} (m^2(h+1) = {2 * m * m}): not refuted {len(pairs)}, of which name no hole by a ground term: {len(bad)}{ex}")
        sys.stdout.flush()


if __name__ == "__main__":
    print("== Part 1: Proposition 4a(1) on the grid of its proof ==")
    print("-- the five cases of code/holes_check.py (its counts: 3024/153, 46048/301, 46048/904, 46048/0, 600596/2205) --")
    part1(4, [(0, 0)])
    part1(5, [(1, 1)])
    part1(5, [(1, 0), (0, 2)])
    part1(5, [(2, 2)])
    part1(6, [(1, 1)])
    print("-- further cases --")
    for U in ([(0, 1)], [(1, 0)], [(1, 1)], [(0, 0), (0, 1)], [(0, 0), (1, 0), (0, 1)]):
        part1(4, U)
    for U in ([(0, 0)], [(0, 2)], [(2, 0)], [(0, 1)], [(0, 0), (1, 1)], [(0, 1), (1, 0)], [(0, 0), (1, 0), (0, 1)], [(1, 1), (0, 2), (2, 0)]):
        part1(5, U)
    for U in ([(0, 3)], [(2, 1)], [(0, 0)], [(1, 2)], [(1, 1), (0, 2)], [(0, 0), (2, 1)], [(3, 0), (0, 3)]):
        part1(6, U)
    for U in ([(1, 1)], [(2, 2)], [(0, 4)], [(2, 3)]):
        part1(7, U)

    print("\n== Part 2: holes with a + b >= m never matter (zero-one assignments suffice), whatever their number ==")
    for m in (3, 4, 5, 6, 7, 8):
        part2(m)

    print("\n== Part 3: one hole and small n ==")
    part3(5, (1, 1), range(4, 13))
    part3(5, (0, 2), range(4, 13))
    part3(6, (1, 1), range(5, 12))
    print("   the hole (n-1, 1) and the identity f(S^(n-2)(x), x) = S^(n-2)(x), sides of n + 1 and n - 1 symbols:")
    for n in (4, 5, 8):
        U = {(n - 1, 1)}
        data = lambda a, b: a + b if a < n and b < n and (a, b) not in U else None
        lhs = ["f", "a", "a"]
        t = "a"
        for _ in range(n - 2):
            t = ["S", t]
        lhs = ["f", t, "a"]
        ref = false = 0
        for x in range(0, 3 * n):
            (p1, d1), (p2, d2) = evaluate(lhs, {"a": x}, data), evaluate(t, {"a": x}, data)
            false += p1 != p2
            ref += d1 is not None and d2 is not None and d1 != d2
        print(f"      n={n}: false at {false} of the values x < {3 * n}; refuted by the data at {ref} of them; sides {size(lhs)} and {size(t)} symbols")

    print("\n== Part 4: all holes in [0, A]^2, n = (A + 2)(m - 2) + 1, any number of holes ==")
    for m, A in ((4, 1), (5, 1), (5, 2), (6, 1)):
        U = {(a, b) for a in range(A + 1) for b in range(A + 1)}
        n = (A + 2) * (m - 2) + 1
        data = lambda a, b: a + b if a < n and b < n and (a, b) not in U else None
        terms, trees, PV, DV = tables(m, data, range(n + 2))
        pairs, nfalse = unrefuted(PV, DV)
        bad = [(i, j) for i, j in pairs if not (named_holes(trees[i], U) or named_holes(trees[j], U))]
        # the same with only the assignments in {A+1, A+2}^3
        terms, trees, PV2, DV2 = tables(m, data, (A + 1, A + 2))
        pairs2, _ = unrefuted(PV2, DV2)
        bad2 = [(i, j) for i, j in pairs2 if not (named_holes(trees[i], U) or named_holes(trees[j], U))]
        print(f"   m={m} A={A}: {len(U)} holes, n={n} (Proposition 4a would need n >= {m * m * (len(U) + 1)}): {nfalse} false identities, "
              f"not refuted {len(pairs)}, of which name no hole: {len(bad)};  with the assignments in {{A+1, A+2}}^3 only: {len(bad2)}")
        sys.stdout.flush()

    print("\n== Part 5: the holes (1,1), (4,4), (6,6), ..., (2h,2h) and f(x, f(x,x)) = f(S(x), S(x)) ==")
    lhs, rhs = ["f", "a", ["f", "a", "a"]], ["f", ["S", "a"], ["S", "a"]]
    for h in (1, 2, 3, 5):
        U = {(1, 1)} | {(2 * i, 2 * i) for i in range(2, h + 1)}
        line = []
        for n in range(4, 4 * h + 8):
            data = lambda a, b: a + b if a < n and b < n and (a, b) not in U else None
            ref = False
            for xv in range(0, n + 2):
                (p1, d1), (p2, d2) = evaluate(lhs, {"a": xv}, data), evaluate(rhs, {"a": xv}, data)
                ref |= d1 is not None and d2 is not None and d1 != d2
            line.append((n, ref))
        last = max(n for n, r in line if not r)
        print(f"   h={h} holes {sorted(U)}: not refuted for every n up to {last} (4h + 2 = {4 * h + 2}); Proposition 4a assumes n >= {25 * (h + 1)}")
