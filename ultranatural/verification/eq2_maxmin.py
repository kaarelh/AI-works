"""Referee, second pass: part of the new open question 2 of equational.md (which targets are
pinned linearly?).  For max and min the test radius is linear for every m:

    tau(m) <= 2m - 2.

Reason.  Under max a term denotes max(C, c_j + x_j : x_j occurs), where c_j is the largest number
of S above an occurrence of x_j and C the largest number of S above any leaf.  Two terms denote
the same function iff they agree at the all-zero assignment and at the assignments with one
variable equal to B and the others 0, for any B larger than every C (B = m will do).  Under min a
term denotes min(c_0, c_j + x_j), with least numbers of S, and the assignments with values in
{0, B} decide equality in the same way (all B; or one variable 0 and the others B).  At these
assignments an argument of f, which has at most m - 2 symbols, has value at most (m - 3) + m.

This script checks the consequence by brute force: for sides of at most m symbols (3 variables),
every identity that is false somewhere on {0..m+2}^3 is refuted at an assignment with values in
{0, m} at which f is applied only at numbers up to 2m - 3.

Usage: python3 eq2_maxmin.py
"""
import itertools
import sys

import numpy as np

sys.dont_write_bytecode = True
from eq_test_radius import all_terms, parse  # noqa: E402


def tables(m, g, values):
    by = all_terms(2, 3, m)
    terms = [t for s in range(1, m + 1) for t in by[s]]
    grid = np.array(list(itertools.product(values, repeat=3)), dtype=np.int64)
    val, need = {}, {}
    zero = np.zeros(len(grid), dtype=np.int64)
    for i, v in enumerate("abc"):
        val[v], need[v] = grid[:, i], zero
    val["0"], need["0"] = zero, zero
    for t in terms:
        if len(t) == 1:
            continue
        if t[0] == "S":
            val[t], need[t] = val[t[1:]] + 1, need[t[1:]]
        else:
            _, p = parse(t, 2, 1)
            s1, s2 = t[1:p], t[p:]
            val[t] = g(val[s1], val[s2])
            need[t] = np.maximum(np.maximum(need[s1], need[s2]), np.maximum(val[s1], val[s2]) + 1)
    return terms, np.stack([val[t] for t in terms]), np.stack([need[t] for t in terms])


for name, g in (("max", np.maximum), ("min", np.minimum)):
    for m in (3, 4, 5, 6, 7):
        terms, Vbig, _ = tables(m, g, range(m + 3))
        _, V, N = tables(m, g, (0, m))
        BIG = 1 << 40
        worst = 0
        nfalse = missed = 0
        for i in range(len(terms) - 1):
            false = (Vbig[i][None, :] != Vbig[i + 1:]).any(axis=1)
            diff = V[i][None, :] != V[i + 1:]
            nd = np.where(diff, np.maximum(N[i][None, :], N[i + 1:]), BIG).min(axis=1)
            nfalse += int(false.sum())
            missed += int((false & (nd >= BIG)).sum())
            if (false & (nd < BIG)).any():
                worst = max(worst, int(nd[false & (nd < BIG)].max()))
        print(f"{name}, m={m}: {len(terms)} terms, {nfalse} identities false on {{0..{m + 2}}}^3; not refuted on {{0,{m}}}^3: {missed}; "
              f"largest need there: {worst} (bound 2m - 2 = {2 * m - 2}: {worst <= 2 * m - 2})")
        sys.stdout.flush()
