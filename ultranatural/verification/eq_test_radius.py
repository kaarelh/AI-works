"""Referee's independent computation of the test radius (equational.md, Sections 2, 3 and 6.1).

Shares no code with code/test_radius.py or code/eqlib.py.

Part 1 (from the definition, literally).  For a data set D_r = g restricted to [0, r)^k the
D_r-value of a term at an assignment is computed by an explicit partial evaluator that looks f up
in a dictionary and gives up when the datum is missing.  An identity is refuted by D_r if at some
assignment both sides have D_r-values and these differ.  Its reach is the least such r.  tau(m)
is the largest reach among the identities with both sides of at most m symbols that are false of
g.  Done for plus (3 variables, sides <= 5) and successor (2 variables, sides <= 6).

Part 2 (shortcut, for the whole of the tables in Section 6.1).  reach = the least, over the
refuting assignments, of 1 + the largest number f is applied to.  Values are exact Python
integers for unary f (so squaring does not overflow).  Run with two different search ranges for
the variables, to see which table entries depend on the range.

Usage: python3 eq_test_radius.py            (about two minutes)
"""
import itertools
import sys

import numpy as np

# ---------------------------------------------------------------- terms
# A term is a string in prefix (Polish) notation over the letters 0 S f and the variables a b c.


def all_terms(arity, nvars, maxsize):
    """dict size -> list of terms (strings)"""
    var = "abc"[:nvars]
    by = {1: list(var) + ["0"]}
    for n in range(2, maxsize + 1):
        out = ["S" + t for t in by[n - 1]]
        if arity == 1:
            out += ["f" + t for t in by[n - 1]]
        else:
            for i in range(1, n - 1):
                out += ["f" + s + t for s in by[i] for t in by[n - 1 - i]]
        by[n] = out
    return by


def parse(t, arity, pos=0):
    """prefix string -> nested list; returns (tree, next position)"""
    ch = t[pos]
    if ch in "abc0":
        return ch, pos + 1
    if ch == "S":
        sub, p = parse(t, arity, pos + 1)
        return ["S", sub], p
    args, p = [], pos + 1
    for _ in range(arity):
        sub, p = parse(t, arity, p)
        args.append(sub)
    return ["f"] + args, p


def pretty(t, arity):
    def go(tr):
        if isinstance(tr, str):
            return {"a": "x", "b": "y", "c": "z", "0": "0"}[tr]
        if tr[0] == "S":
            return "S(" + go(tr[1]) + ")"
        return "f(" + ",".join(go(u) for u in tr[1:]) + ")"
    return go(parse(t, arity)[0])


def partial_value(tree, env, data):
    """D-value of a term: None if a needed datum is missing"""
    if isinstance(tree, str):
        return 0 if tree == "0" else env[tree]
    if tree[0] == "S":
        v = partial_value(tree[1], env, data)
        return None if v is None else v + 1
    args = []
    for sub in tree[1:]:
        v = partial_value(sub, env, data)
        if v is None:
            return None
        args.append(v)
    return data.get(tuple(args))


def full_value(tree, env, g):
    """(value under the total function g, 1 + the largest number f is applied to, or 0)"""
    if isinstance(tree, str):
        return (0 if tree == "0" else env[tree]), 0
    if tree[0] == "S":
        v, need = full_value(tree[1], env, g)
        return v + 1, need
    vals, need = [], 0
    for sub in tree[1:]:
        v, nd = full_value(sub, env, g)
        vals.append(v)
        need = max(need, nd, v + 1)
    return g(*vals), need


# ---------------------------------------------------------------- part 1: literal definition
def tau_literal(g, arity, nvars, maxsize, R, rmax):
    by = all_terms(arity, nvars, maxsize)
    terms = [(n, t) for n in range(1, maxsize + 1) for t in by[n]]
    trees = [parse(t, arity)[0] for _, t in terms]
    var = "abc"[:nvars]
    envs = [dict(zip(var, u)) for u in itertools.product(range(R + 1), repeat=nvars)]
    # truth under the total function, on the search range
    total = np.array([[full_value(tr, e, g)[0] for e in envs] for tr in trees], dtype=object)
    # D_r-values for r = 0..rmax; -1 stands for "undefined"
    part = []
    for r in range(rmax + 1):
        data = {u: g(*u) for u in itertools.product(range(r), repeat=arity)}
        tab = np.array([[(-1 if (v := partial_value(tr, e, data)) is None else v) for e in envs] for tr in trees],
                       dtype=np.int64)
        part.append(tab)
    sizes = np.array([n for n, _ in terms])
    tau = [0] * (maxsize + 1)
    witness = [None] * (maxsize + 1)
    nfalse = 0
    unrefuted = 0
    for i in range(len(terms)):
        false = (total[i][None, :] != total[i:]).any(axis=1)          # false of g (on the search range)
        nfalse += int(false.sum())
        reach = np.full(len(terms) - i, -1)
        for r in range(rmax + 1):
            a, b = part[r][i], part[r][i:]
            ref = ((a[None, :] >= 0) & (b >= 0) & (a[None, :] != b)).any(axis=1)
            reach = np.where((reach < 0) & ref, r, reach)
        unrefuted += int((false & (reach < 0)).sum())
        side = np.maximum(sizes[i], sizes[i:])
        for m in range(1, maxsize + 1):
            sel = false & (side <= m)
            if sel.any():
                j = int(np.where(sel, reach, -1).argmax())
                if reach[j] > tau[m]:
                    tau[m], witness[m] = int(reach[j]), (terms[i][1], terms[i + j][1])
    return tau, witness, nfalse, unrefuted, len(terms)


# ---------------------------------------------------------------- part 2: shortcut, all targets
def tau_shortcut_binary(g, nvars, maxsize, R):
    by = all_terms(2, nvars, maxsize)
    grid = np.array(list(itertools.product(range(R + 1), repeat=nvars)), dtype=np.int64)
    val, need = {}, {}
    for i, v in enumerate("abc"[:nvars]):
        val[v], need[v] = grid[:, i], np.zeros(len(grid), dtype=np.int64)
    val["0"], need["0"] = np.zeros(len(grid), dtype=np.int64), np.zeros(len(grid), dtype=np.int64)
    order = []
    for n in range(1, maxsize + 1):
        for t in by[n]:
            if n > 1:
                if t[0] == "S":
                    val[t], need[t] = val[t[1:]] + 1, need[t[1:]]
                else:                                   # split "f s t" into its two arguments
                    _, p = parse(t, 2, 1)
                    s1, s2 = t[1:p], t[p:]
                    val[t] = np.asarray(g(val[s1], val[s2]), dtype=np.int64)
                    need[t] = np.maximum(np.maximum(need[s1], need[s2]), np.maximum(val[s1], val[s2]) + 1)
            order.append((n, t))
    V = np.stack([val[t] for _, t in order])
    N = np.stack([need[t] for _, t in order])
    sizes = np.array([n for n, _ in order])
    BIG = 1 << 60
    tau = [0] * (maxsize + 1)
    wit = [None] * (maxsize + 1)
    for i in range(len(order)):
        differ = V[i][None, :] != V[i:]
        nd = np.where(differ, np.maximum(N[i][None, :], N[i:]), BIG).min(axis=1)
        false = nd < BIG
        side = np.maximum(sizes[i], sizes[i:])
        for m in range(sizes[i], maxsize + 1):
            sel = false & (side <= m)
            if sel.any():
                j = int(np.where(sel, nd, -1).argmax())
                if nd[j] > tau[m]:
                    tau[m], wit[m] = int(nd[j]), (order[i][1], order[i + j][1])
    return tau, wit


def tau_shortcut_unary(g, maxsize, R):
    """exact integers; a term is (word, leaf); its value depends on one variable only"""
    words = [""]
    for n in range(1, maxsize):
        words += ["".join(w) for w in itertools.product("Sf", repeat=n)]

    def run(word, v):                       # apply the word (outermost letter first) to the number v
        need = 0
        for ch in reversed(word):
            if ch == "S":
                v += 1
            else:
                need = max(need, v + 1)
                v = g(v)
        return v, need

    table = {w: [run(w, v) for v in range(R + 1)] for w in words}
    terms = [(len(w) + 1, w, leaf) for w in words for leaf in "0ab"]
    tau = [0] * (maxsize + 1)
    wit = [None] * (maxsize + 1)
    for i, (n1, w1, l1) in enumerate(terms):
        t1 = table[w1]
        for n2, w2, l2 in terms[i + 1:]:
            t2 = table[w2]
            if l1 == "0":
                A = [t1[0]]
            else:
                A = t1
            if l2 == "0":
                B = [t2[0]]
            else:
                B = t2
            best = None
            if l1 == l2 and l1 != "0":      # the same variable: one number
                for (v1, d1), (v2, d2) in zip(A, B):
                    if v1 != v2:
                        d = max(d1, d2)
                        if best is None or d < best:
                            best = d
            else:                           # independent choices
                for v1, d1 in A:
                    for v2, d2 in B:
                        if v1 != v2:
                            d = max(d1, d2)
                            if best is None or d < best:
                                best = d
            if best is not None:
                m = max(n1, n2)
                if best > tau[m]:
                    tau[m], wit[m] = best, (w1 + l1, w2 + l2)
    for m in range(2, maxsize + 1):         # tau(m) is over sides of AT MOST m symbols
        if tau[m - 1] > tau[m]:
            tau[m], wit[m] = tau[m - 1], wit[m - 1]
    return tau, wit


if __name__ == "__main__":
    print("== Part 1: literal definition (explicit data sets D_r, partial evaluation) ==")
    for name, g, arity, nvars, M, R, rmax in (("plus", lambda a, b: a + b, 2, 3, 5, 6, 8),
                                              ("successor", lambda a: a + 1, 1, 2, 6, 12, 10)):
        tau, wit, nfalse, unref, nterms = tau_literal(g, arity, nvars, M, R, rmax)
        print(f"{name}: {nterms} terms of at most {M} symbols, {nvars} variables searched in 0..{R}, data sets D_0..D_{rmax}")
        print(f"   false identities: {nfalse}; false but not refuted by D_{rmax} at an assignment in range: {unref}")
        for m in range(2, M + 1):
            w = wit[m]
            print(f"   tau({m}) = {tau[m]}" + (f"   reached by {pretty(w[0], arity)} = {pretty(w[1], arity)}" if w else ""))
    sys.stdout.flush()

    print("\n== Part 2: shortcut, all targets of Section 6.1, two search ranges ==")
    QN = 5
    BIN = {
        "plus": lambda a, b: a + b,
        "x+y+1": lambda a, b: a + b + 1,
        "first argument": lambda a, b: a + 0 * b,
        "max": np.maximum,
        "min": np.minimum,
        "monus": lambda a, b: np.maximum(a - b, 0),
        "[x = y]": lambda a, b: (a == b).astype(np.int64),
        "times": lambda a, b: a * b,
        "quus_5": lambda a, b: np.where((a < QN) & (b < QN), a + b, 5),
        "plus, but 0 at (3,4)": lambda a, b: np.where((a == 3) & (b == 4), 0, a + b),
    }
    for R in (6, 8):
        print(f"binary f, 3 variables searched in 0..{R}: tau(m) for m = 2..6")
        for name, g in BIN.items():
            tau, wit = tau_shortcut_binary(g, 3, 6, R)
            w = wit[6]
            print(f"   {name:22s} " + " ".join(f"{tau[m]:4d}" for m in range(2, 7)) + f"    {pretty(w[0], 2)} = {pretty(w[1], 2)}")
        sys.stdout.flush()
    UN = {
        "successor": lambda a: a + 1,
        "identity": lambda a: a,
        "x+2": lambda a: a + 2,
        "predecessor": lambda a: max(a - 1, 0),
        "parity": lambda a: a % 2,
        "min(x+1, 3)": lambda a: min(a + 1, 3),
        "successor, but 0 at 4": lambda a: 0 if a == 4 else a + 1,
        "double": lambda a: 2 * a,
        "square": lambda a: a * a,
    }
    for R, M in ((12, 8), (16, 7)):
        print(f"unary f, 2 variables searched in 0..{R}: tau(m) for m = 2..{M} (exact integers)")
        for name, g in UN.items():
            tau, wit = tau_shortcut_unary(g, M, R)
            w = wit[M]
            cells = " ".join((f"{tau[m]:6d}" if tau[m] < 10 ** 9 else "  >1e9") for m in range(2, M + 1))
            print(f"   {name:22s} {cells}    {w[0]} = {w[1]}   (words read outermost letter first; a, b are x, y)")
        sys.stdout.flush()
