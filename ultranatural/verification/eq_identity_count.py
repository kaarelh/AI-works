"""Referee: independent recount of the short identities of plus and of the first projection
(the claim in Section 7 of equational.md that the projection satisfies far more short identities;
results/identities_L9.out gives 491 and 12960).

An identity is an unordered pair of distinct terms over {0, S, f} and x, y, z whose sizes add up
to at most 9 and whose values agree at every assignment with values 0..7.

Usage: python3 eq_identity_count.py
"""
import itertools
from collections import defaultdict

import numpy as np

grid = np.array(list(itertools.product(range(8), repeat=3)), dtype=np.int64)


def count(g, total=9):
    by = {1: [grid[:, 0], grid[:, 1], grid[:, 2], np.zeros(len(grid), dtype=np.int64)]}
    for n in range(2, total):
        cur = [v + 1 for v in by[n - 1]]
        for i in range(1, n - 1):
            cur += [g(a, b) for a in by[i] for b in by[n - 1 - i]]
        by[n] = cur
    groups = defaultdict(lambda: defaultdict(int))     # value vector -> size -> number of terms
    for n, vs in by.items():
        for v in vs:
            groups[v.tobytes()][n] += 1
    ids = 0
    for sizes in groups.values():
        items = sorted(sizes.items())
        for a, (n1, c1) in enumerate(items):
            if 2 * n1 <= total:
                ids += c1 * (c1 - 1) // 2
            for n2, c2 in items[a + 1:]:
                if n1 + n2 <= total:
                    ids += c1 * c2
    return ids


for name, g in (("plus", lambda a, b: a + b), ("first argument", lambda a, b: a + 0 * b), ("max", np.maximum),
                ("quus_5", lambda a, b: np.where((a < 5) & (b < 5), a + b, 5))):
    print(f"{name:16s} {count(g)}")
