"""Referee: which sets "slip through" a small proof bound?

Section 6.2 of equational.md says the sets counted as consistent at a small bound and found
inconsistent at a larger one are, as far as seen, of one kind (an identity such as
x = S(f(S(S(S(x))))) that makes S a bijection).  This script takes the dumps of
`eq_unary 12 L dump` for two bounds (they list the consistent sets that determine f at 0, 1, 2)
and classifies the sets that are in the first and not in the second, and the converse.

Usage: python3 eq_slip.py DUMP_small_L DUMP_large_L
"""
import sys
from collections import Counter


def load(path):
    d = {}
    for line in open(path):
        if line.startswith("D "):
            head, prof, ids = line[2:].split("|")
            d[ids.strip()] = tuple(int(v) for v in prof.split())
    return d


def kind(k):
    for e in k.split():
        l, r = e.split("=")
        for a, b in ((l, r), (r, l)):
            if a in ("x", "y") and b.endswith(a) and len(b) > 1:
                return "contains an identity x = W(x)"
    return "other"


a, b = load(sys.argv[1]), load(sys.argv[2])
gone = [k for k in a if k not in b]
new = [k for k in b if k not in a]
print(f"sets that determine f(0), f(1), f(2): {len(a)} at the small bound, {len(b)} at the large bound")
print(f"in the first list only (found inconsistent at the large bound): {len(gone)}: {dict(Counter(kind(k) for k in gone))}")
for k in gone:
    if kind(k) == "other":
        print(f"     other: {k}   proved at the small bound: {list(a[k])}")
print(f"in the second list only (they prove f(0), f(1), f(2) only by longer proofs): {len(new)}")
for k in new[:8]:
    print(f"     {k}   proves at the large bound: {list(b[k])}")
print(f"in both with a different profile: {sum(1 for k in a if k in b and a[k] != b[k])}")
