#!/usr/bin/env python3
"""c4_coloring.py -- thread `fundamentals`: the colouring bound of Theorem 6.2(i) (scout F's F11(i)).

(1) For d = 2..200: l_d := ceil(log2(d / log2 3)) - 1 satisfies 3^(2^l_d) < 2^d (exact integer test) and
    l_d > log2 d - 2, and the pigeonhole count (fewer than 2^l_d programs of length < l_d, at most
    3^(2^l_d - 1) colours, 2^d atoms) leaves two atoms of equal colour.
(2) Toy universal list: for d = 10 and d = 16, the 2^l_d - 1 "short programs" are random theories over the
    literals R(t_x), x in {0,1}^d (each a consistent set of literals, or the inconsistent theory); colour the
    atoms, find a colliding pair (x1, x2), and check that no listed theory is consistent and proves
    not R(t_x1) and R(t_x2).
Seed 20261016.  Output: c4_coloring.out.
"""
import math
import os
import random

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


def ell(d):
    return math.ceil(math.log2(d / math.log2(3))) - 1


def part1():
    out("(1) arithmetic of the colouring bound")
    bad = []
    for d in range(2, 201):
        l = ell(d)
        ok = (3 ** (2 ** l) < 2 ** d) and (l > math.log2(d) - 2) and (3 ** (2 ** l - 1) < 2 ** d)
        if not ok:
            bad.append(d)
    out(f"    d = 2..200: 3^(2^l) < 2^d and l > log2 d - 2 hold for all d except {bad if bad else 'none'}")
    out("    d    l_d   log2 d - 2   colours bound 3^(2^l - 1)   atoms 2^d")
    for d in (2, 3, 4, 8, 16, 32, 64, 128, 200):
        l = ell(d)
        out(f"  {d:4d}  {l:4d}   {math.log2(d) - 2:9.3f}   {3 ** (2 ** l - 1):>24d}   2^{d}")


def part2():
    out("(2) toy universal lists of short theories")
    for d in (10, 16):
        l = ell(d)
        nprog = 2 ** l - 1
        progs = []
        for j in range(nprog):
            if rng.random() < 0.15:
                progs.append(None)                       # inconsistent theory: colour '*' everywhere
            else:
                # a consistent set of literals: each atom +, - or undecided
                p_dec = rng.random()
                progs.append([('+' if rng.random() < 0.5 else '-') if rng.random() < p_dec else '*'
                              for _ in range(2 ** d)])
        colour = {}
        pair = None
        for x in range(2 ** d):
            col = tuple('*' if pr is None else pr[x] for pr in progs)
            if col in colour:
                pair = (colour[col], x)
                break
            colour[col] = x
        x1, x2 = pair
        separated = [j for j, pr in enumerate(progs) if pr is not None and pr[x1] == '-' and pr[x2] == '+']
        out(f"    d = {d}: l = {l}, {nprog} short theories; colliding atoms x1 = {x1:0{d}b}, x2 = {x2:0{d}b}; "
            f"short consistent theories proving not R(x1) and R(x2): {separated if separated else 'none'}")


if __name__ == "__main__":
    out(f"seed {SEED}")
    part1()
    part2()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "c4_coloring.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
