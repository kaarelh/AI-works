#!/usr/bin/env python3
"""Measure source size of line ranges in paper sections; estimate pages at 4200 chars/page."""
import sys
base = "/home/user/AI-works/axiom-schemas/paper/sections/"
CPP = 4200.0
def size(f, a, b):
    lines = open(base + f).read().split("\n")[a-1:b]
    s = "\n".join(l for l in lines if not l.lstrip().startswith("%"))
    return len(s)
total = 0
for arg in sys.argv[1:]:
    f, rng = arg.split(":")
    a, b = map(int, rng.split("-"))
    n = size(f, a, b)
    total += n
    print(f"{f}:{a}-{b}  chars={n}  pages~{n/CPP:.2f}")
print(f"TOTAL chars={total} pages~{total/CPP:.2f}")
