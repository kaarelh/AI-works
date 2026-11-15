"""Count the identities (universally quantified equations) that a binary function on the natural
numbers satisfies, in the signature {f, S, 0} with variables x, y, z and no other symbols.

An identity is an unordered pair of distinct terms s, t with size(s) + size(t) <= L that take the
same value under every assignment of x, y, z in 0..M-1. (So "satisfies" means: on that range.
For plus, max, min and times the identities found are true on all of N.)

Usage: python3 identities.py [L] [M]
"""
import itertools
import sys
from collections import defaultdict

import numpy as np

L = int(sys.argv[1]) if len(sys.argv) > 1 else 11
M = int(sys.argv[2]) if len(sys.argv) > 2 else 8
QN = 5                      # quus threshold
PATCH = (3, 4)              # the point patch


def rnd(seed):
    def h(a, b):
        v = (a * 2654435761 + b * 40503 + seed * 97) % 1000003
        return (v * v + 12345) % 100003
    return h


FUNCS = {
    "plus": lambda a, b: a + b,
    "quus (x+y if x,y<5, else 5)": lambda a, b: np.where((a < QN) & (b < QN), a + b, 5),
    "plus, but 0 at (3,4)": lambda a, b: np.where((a == PATCH[0]) & (b == PATCH[1]), 0, a + b),
    "plus, but 0 at (3,4) and (4,3)": lambda a, b: np.where(((a == 3) & (b == 4)) | ((a == 4) & (b == 3)), 0, a + b),
    "plus, but 1 at (0,0)": lambda a, b: np.where((a == 0) & (b == 0), 1, a + b),
    "x+y+1": lambda a, b: a + b + 1,
    "max": np.maximum,
    "min": np.minimum,
    "times": lambda a, b: a * b,
    "monus": lambda a, b: np.maximum(a - b, 0),
    "first argument": lambda a, b: a + 0 * b,
    "x+2y": lambda a, b: a + 2 * b,
    "random 1": rnd(1),
    "random 2": rnd(2),
}

grid = np.array(list(itertools.product(range(M), repeat=3)), dtype=np.int64)
ATOMS = [("x", grid[:, 0]), ("y", grid[:, 1]), ("z", grid[:, 2]), ("0", np.zeros(len(grid), dtype=np.int64))]


def terms(f, maxsize):
    """All terms by size, as (string, value vector)."""
    by = {1: list(ATOMS)}
    for s in range(2, maxsize + 1):
        cur = [("S(" + t + ")", v + 1) for t, v in by[s - 1]]
        for a in range(1, s - 1):
            b = s - 1 - a
            for t1, v1 in by[a]:
                for t2, v2 in by[b]:
                    cur.append(("f(" + t1 + "," + t2 + ")", np.asarray(f(v1, v2), dtype=np.int64)))
        by[s] = cur
    return by


def identities(f):
    by = terms(f, L - 1)
    classes = defaultdict(list)
    for s, lst in by.items():
        for t, v in lst:
            classes[v.tobytes()].append((s, t))
    ids = set()
    for members in classes.values():
        if len(members) < 2:
            continue
        for (s1, t1), (s2, t2) in itertools.combinations(members, 2):
            if s1 + s2 <= L:
                ids.add((t1, t2) if t1 < t2 else (t2, t1))
    return ids


print(f"identities s = t with size(s) + size(t) <= {L}, checked for x, y, z < {M}")
E = {name: identities(f) for name, f in FUNCS.items()}
base = E["plus"]
print(f"{'function':34s} {'identities':>10s} {'shared with plus':>17s} {'of plus kept':>13s}")
for name, ids in E.items():
    print(f"{name:34s} {len(ids):10d} {len(ids & base):17d} {len(ids & base) / len(base):13.3f}")
print("\nby total size, number of identities:")
names = ["plus", "quus (x+y if x,y<5, else 5)", "plus, but 0 at (3,4)", "max", "times", "monus", "random 1"]
size = lambda t: t.count("S") + t.count("f") + t.count("x") + t.count("y") + t.count("z") + t.count("0")
print(f"{'size':>4s} " + " ".join(f"{n[:16]:>16s}" for n in names))
for l in range(2, L + 1):
    print(f"{l:4d} " + " ".join(f"{sum(1 for a, b in E[n] if size(a) + size(b) == l):16d}" for n in names))
print("\nshortest identities of quus:", sorted(E["quus (x+y if x,y<5, else 5)"], key=lambda p: (len(p[0]) + len(p[1]), p))[:8])
print("shortest identities of 'plus, but 0 at (3,4)':", sorted(E["plus, but 0 at (3,4)"], key=lambda p: (len(p[0]) + len(p[1]), p))[:8])
