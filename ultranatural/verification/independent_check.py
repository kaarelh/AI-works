#!/usr/bin/env python3
"""Independent check of the Section 6 enumeration (referee's own code; shares nothing with code/).

Language, as stated in note.md Section 6:
    t ::= x | y | a | 0 | S(t) | P(t) | It(t, t, t) | ifz(t, t, t)
  values 0..31, S and P saturating; It(n, body, init) = body applied n times to init, where n and
  init are evaluated in the enclosing environment and body sees the running value as a;
  ifz(c, u, v) = u if c == 0 else v; a closed term is run with a = 0.

Method: enumerate ALL terms of each size syntactically (no semantic pruning, no deduplication of
subterms), evaluate each by direct recursion on its syntax tree at the 36 inputs x, y < 6, and
record for each resulting function the least size of a term that computes it.

Usage: python3 independent_check.py [MAXSIZE=8]
"""
import sys
import time

VMAX = 31
N = int(sys.argv[1]) if len(sys.argv) > 1 else 8
INPUTS = [(x, y) for x in range(6) for y in range(6)]


def ev(t, x, y, a):
    op = t[0]
    if op == "x":
        return x
    if op == "y":
        return y
    if op == "a":
        return a
    if op == "0":
        return 0
    if op == "S":
        v = ev(t[1], x, y, a)
        return v + 1 if v < VMAX else VMAX
    if op == "P":
        v = ev(t[1], x, y, a)
        return v - 1 if v > 0 else 0
    if op == "It":
        n = ev(t[1], x, y, a)
        acc = ev(t[3], x, y, a)
        body = t[2]
        for _ in range(n):
            acc = ev(body, x, y, acc)
        return acc
    if op == "ifz":
        if ev(t[1], x, y, a) == 0:
            return ev(t[2], x, y, a)
        return ev(t[3], x, y, a)
    raise ValueError(op)


def show(t):
    if len(t) == 1:
        return t[0]
    return t[0] + "(" + ",".join(show(c) for c in t[1:]) + ")"


def main():
    t0 = time.time()
    terms = {1: [("x",), ("y",), ("a",), ("0",)]}
    for s in range(2, N + 1):
        cur = []
        for c in terms[s - 1]:
            cur.append(("S", c))
            cur.append(("P", c))
        for s1 in range(1, s - 2):
            for s2 in range(1, s - 1 - s1):
                s3 = s - 1 - s1 - s2
                for c1 in terms[s1]:
                    for c2 in terms[s2]:
                        for c3 in terms[s3]:
                            cur.append(("It", c1, c2, c3))
                            cur.append(("ifz", c1, c2, c3))
        terms[s] = cur
    print("syntactic terms by size:", {s: len(terms[s]) for s in terms})

    K = {}      # function table (tuple of 36 values) -> least size
    wit = {}    # function table -> all terms of least size (capped at 5)
    for s in range(1, N + 1):
        for t in terms[s]:
            tab = tuple(ev(t, x, y, 0) for (x, y) in INPUTS)
            if tab not in K:
                K[tab] = s
                wit[tab] = [t]
            elif K[tab] == s and len(wit[tab]) < 5:
                wit[tab].append(t)
        print(f"size {s}: evaluated, {len(K)} distinct functions so far, {time.time() - t0:.0f}s",
              flush=True)
    by = {}
    for tab, k in K.items():
        by[k] = by.get(k, 0) + 1
    print("distinct functions by least size:", dict(sorted(by.items())))
    print("total:", len(K))

    funcs = list(K.items())

    def dist(f, g):
        return sum(1 for u, v in zip(f, g) if u != v)

    def profile(f):
        """least size of a function g != f at each exact Hamming distance (within sizes <= N)."""
        prof = {}
        for g, k in funcs:
            if g == f:
                continue
            d = dist(f, g)
            if d not in prof or k < prof[d]:
                prof[d] = k
        return prof

    def R_of(f):
        kf = K[f]
        best = None
        for g, k in funcs:
            if g != f and k <= kf:
                d = dist(f, g)
                if best is None or d < best:
                    best = d
        return best

    targets = {
        "successor x+1": tuple(min(x + 1, VMAX) for x, y in INPUTS),
        "addition x+y": tuple(x + y for x, y in INPUTS),
        "x+y+1": tuple(x + y + 1 for x, y in INPUTS),
        "monus x-y": tuple(max(x - y, 0) for x, y in INPUTS),
        "product x*y": tuple(x * y for x, y in INPUTS),
        "double 2x": tuple(2 * x for x, y in INPUTS),
        "max(x,y)": tuple(max(x, y) for x, y in INPUTS),
        "min(x,y)": tuple(min(x, y) for x, y in INPUTS),
        "[x<=y]": tuple(int(x <= y) for x, y in INPUTS),
        "add, but 1 at (0,0)": tuple(1 if (x, y) == (0, 0) else x + y for x, y in INPUTS),
        "add, but y+1 where x=0": tuple(y + 1 if x == 0 else x + y for x, y in INPUTS),
        "add, but x where y<=1": tuple(x if y <= 1 else x + y for x, y in INPUTS),
        "add, but 0 where x=0": tuple(0 if x == 0 else x + y for x, y in INPUTS),
    }
    radii = [1, 2, 3, 5, 6, 8, 11, 17]
    print(f"\nnamed functions (everything restricted to terms of size <= {N}; K and R are exact when "
          f"K <= {N}; 'within r' entries are exact when they are <= {N}, '-' means none of size <= {N})")
    print(f"{'function':26s} {'K':>3s} {'R':>4s}  " + " ".join(f"r<={r:<3d}" for r in radii) + "  a least term")
    for name, f in targets.items():
        if f not in K:
            print(f"{name:26s}  not expressible with size <= {N}")
            continue
        prof = profile(f)
        cells = []
        for r in radii:
            ks = [k for d, k in prof.items() if d <= r]
            cells.append(str(min(ks)) if ks else "-")
        print(f"{name:26s} {K[f]:3d} {R_of(f):4d}  " + " ".join(f"{c:>6s}" for c in cells)
              + "  " + show(wit[f][0]))

    add = targets["addition x+y"]
    near = sorted((k, g) for g, k in funcs if dist(add, g) == 1)
    print("\nfunctions at Hamming distance exactly 1 from addition, by least size:")
    if not near:
        print("  none of size <=", N)
    for k, g in near:
        pos = [(INPUTS[i], add[i], g[i]) for i in range(36) if add[i] != g[i]][0]
        print(f"  size {k}: differs at (x,y)={pos[0]}: {pos[1]} -> {pos[2]};  least terms: "
              + "; ".join(show(t) for t in wit[g]))

    rs = [1, 2, 3, 6, 9, 12, 18]
    print("\nisolation counts (R >= r) by K, as in Part 2 of analyze_pr11.out "
          "(exact, since R only involves functions of size <= K):")
    print(f"{'K':>3s} {'count':>7s}  " + " ".join(f"r={r:<6d}" for r in rs))
    Rall = {f: R_of(f) for f, k in funcs}
    for k in range(1, N + 1):
        fs = [f for f, kk in funcs if kk == k]
        print(f"{k:3d} {len(fs):7d}  " + " ".join(
            f"{sum(1 for f in fs if Rall[f] is None or Rall[f] >= r):8d}" for r in rs))
    print(f"\ndone in {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main()
