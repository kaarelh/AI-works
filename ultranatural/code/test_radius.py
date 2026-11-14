"""Test radius of a target function g.

For an identity s = t that is false for g, its reach is the least r such that some assignment
refutes it while every application of f in evaluating both sides (under g) has all arguments
below r. So data g on [0, r)^k refutes the identity. tau_g(m) is the largest reach among the
false identities whose sides have at most m symbols.

Identities use at most 3 variables (2 for unary f) with values searched in 0..R0; an identity
with no refuting assignment in that range is counted as true. Arithmetic is in 64-bit integers,
except for squaring, where exact integers are used.

Usage: python3 test_radius.py
"""
import itertools

import numpy as np

from eqlib import show_id

BIG = 10 ** 9


def build(arity, nvars, maxsize, g, R0, exact=False):
    """Terms by increasing size, with value and radius arrays over the assignment grid.
    With exact=True the arrays hold Python integers (needed where values exceed 64 bits)."""
    dt = object if exact else np.int64
    grid = np.array(list(itertools.product(range(R0 + 1), repeat=nvars)), dtype=dt)
    zero = np.zeros(len(grid), dtype=dt)
    by = {1: [(("v", i), grid[:, i], zero) for i in range(nvars)] + [(("0",), zero, zero)]}
    for s in range(2, maxsize + 1):
        cur = [(("S", t), v + 1, r) for t, v, r in by[s - 1]]
        if arity == 1:
            for t, v, r in by[s - 1]:
                cur.append((("f", t), g(v), np.maximum(r, v + 1)))
        else:
            for a in range(1, s - 1):
                for t1, v1, r1 in by[a]:
                    for t2, v2, r2 in by[s - 1 - a]:
                        rad = np.maximum(np.maximum(r1, r2), np.maximum(v1, v2) + 1)
                        cur.append((("f", t1, t2), g(v1, v2), rad))
        by[s] = cur
    return by


def tau(arity, nvars, maxsize, g, R0, exact=False):
    by = build(arity, nvars, maxsize, g, R0, exact)
    BIG = 10 ** 400 if exact else 10 ** 9
    terms, sizes, vals, rads = [], [], [], []
    for s in range(1, maxsize + 1):
        for t, v, r in by[s]:
            terms.append(t)
            sizes.append(s)
            vals.append(v)
            rads.append(r)
    sizes = np.array(sizes)
    Vm = np.stack(vals)
    Rm = np.stack(rads) if exact else np.minimum(np.stack(rads), BIG - 1)
    best = [0] * (maxsize + 1)                         # tau by max side size
    nfalse = np.zeros(maxsize + 1, dtype=np.int64)
    example = {}
    for i in range(len(terms)):
        diff = Vm[i][None, :] != Vm[i:]
        rad = np.where(diff, np.maximum(Rm[i][None, :], Rm[i:]), BIG)
        mn = rad.min(axis=1)
        false = mn < BIG
        side = np.maximum(sizes[i], sizes[i:])
        for m in range(sizes[i], maxsize + 1):
            sel = false & (side == m)
            if sel.any():
                nfalse[m] += sel.sum()
                j = np.where(sel, mn, -1).argmax()
                if mn[j] > best[m]:
                    best[m] = int(mn[j])
                    example[m] = (terms[i], terms[i + j])
    out = []
    run, ex = 0, None
    for m in range(1, maxsize + 1):
        if best[m] > run:
            run, ex = int(best[m]), example[m]
        out.append((m, int(nfalse[: m + 1].sum()), run, ex))
    return out


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
    "quus (x+y if x,y<5, else 5)": lambda a, b: np.where((a < QN) & (b < QN), a + b, 5),
    "plus, but 0 at (3,4)": lambda a, b: np.where((a == 3) & (b == 4), 0, a + b),
}
UN = {
    "successor": lambda a: a + 1,
    "identity": lambda a: a,
    "x+2": lambda a: a + 2,
    "predecessor": lambda a: np.maximum(a - 1, 0),
    "parity": lambda a: a % 2,
    "min(x+1, 3)": lambda a: np.minimum(a + 1, 3),
    "successor, but 0 at 4": lambda a: np.where(a == 4, 0, a + 1),
    "double": lambda a: 2 * a,
    "square": lambda a: a * a,
}

if __name__ == "__main__":
    for title, funcs, arity, nvars, M, R0 in (("binary f", BIN, 2, 3, 6, 6), ("unary f", UN, 1, 2, 8, 12)):
        print(f"== {title}: tau_g(m) for sides of at most m symbols, variables searched in 0..{R0} ==")
        print(f"{'target':30s} " + " ".join(f"m={m:<3d}" for m in range(2, M + 1)) + "  false identities, example of largest reach")
        for name, g in funcs.items():
            res = tau(arity, nvars, M, g, R0, exact=(name == "square"))   # squaring overflows 64 bits
            cells = " ".join(f"{r[2]:5d}" for r in res[1:])
            ex = res[-1][3]
            print(f"{name:30s} {cells}  {res[-1][1]:9d}  {show_id(ex) if ex else '-'}")
        print()
