#!/usr/bin/env python3
"""s2_craig_blowup.py -- Craig's construction against a theory with a theoretical predicate
(scout S, notes.md section 3, Lemma 3.2 and Example 3.6).

Toy theory T (finite, Horn) over the observational vocabulary {e, s0, s1, R} and the theoretical
predicates {E, O} ("even / odd number of 1s"):
    E(e);  E(x)->E(s0 x);  E(x)->O(s1 x);  O(x)->O(s0 x);  O(x)->E(s1 x);  E(x)->R(x);  O(x)->~R(x).
Observational data: phi_w = R(t_w), t_w = s_{w1}(...s_{wk}(e)...), labelled by the parity of the 1s of w.

Toy proof system: a derivation is a sequence of ground literals (atoms over E, O, R with terms t_u,
|u| <= |w|, and the negated R-atoms), each justified by a rule of T whose premise occurs earlier.
Symbol size of a literal: 1 (predicate) + |u| + 1 (term) + [1 if negated].

For each word w the script computes
  * L*, the number of lines of a shortest derivation of the datum (|w| + 2), and its symbol size d_T;
  * the canonical proof search = test every sequence of candidate lines, by number of lines and then
    lexicographically, until the first valid derivation of R(t_w) or ~R(t_w): the exact number k of
    sequences tested (exact by a counting depth-first search; also by brute force for |w| <= 2);
  * the size of Craig's padded axiom (phi^b)^{&(k+1)} >= (k+1)|phi^b| (Lemma 3.2: every derivation of
    the datum from the Craig set of a literal labeller contains this line);
  * the size of the certificate axiom theta_c -> phi^b, with c a bit code of the shortest derivation
    (|theta_c| = |c| + 14 as in short-derivations Thm 3.1(iii)(b));
  * the size of the Craig axiom of a fast labeller (parity computed in |w| + 2 steps).
Seed 20261015 (random words).  Writes s2_craig_blowup.out next to itself.
"""
import itertools
import math
import os
import random

SEED = 20261015
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "s2_craig_blowup.out")


def atoms_for(maxlen):
    """candidate lines: (pred, u) with pred in E, O, R, nR and u a word of length <= maxlen;
    lexicographic order: by pred order, then by (len(u), u)."""
    words = [""]
    for L in range(1, maxlen + 1):
        words += ["".join(p) for p in itertools.product("01", repeat=L)]
    return [(p, u) for p in ("E", "O", "R", "nR") for u in words]


def justified(line, earlier):
    """is `line` justified by a rule of T from the set `earlier` of lines?"""
    p, u = line
    if p == "E":
        if u == "":
            return True
        a, rest = u[0], u[1:]
        return ("E", rest) in earlier if a == "0" else ("O", rest) in earlier
    if p == "O":
        if u == "":
            return False
        a, rest = u[0], u[1:]
        return ("O", rest) in earlier if a == "0" else ("E", rest) in earlier
    if p == "R":
        return ("E", u) in earlier
    if p == "nR":
        return ("O", u) in earlier
    return False


def lit_size(line):
    p, u = line
    return 1 + len(u) + 1 + (1 if p == "nR" else 0)


def shortest_derivation(w):
    """E(e), then the parity atoms of the suffixes of w from the inside out, then +-R(t_w)."""
    lines = [("E", "")]
    par = 0
    for i in range(len(w) - 1, -1, -1):
        par ^= int(w[i])
        lines.append(("O" if par else "E", w[i:]))
    lines.append(("nR" if par else "R", w))
    return lines, (0 if par else 1)


def canonical_rank(w, atoms, start_L=1):
    """number of candidate sequences tested by the canonical search before (and including) the first
    valid derivation whose last line is +-R(t_w).  Sequences of fewer lines come first; within a length,
    lexicographic in the atom order.  A depth-first search counts whole skipped subtrees at once.
    With start_L > 1 the lengths below start_L are assumed to contain no valid derivation (each rule
    adds one symbol to the term, so a derivation of +-R(t_w) has at least |w| + 2 lines) and are
    counted as N^L tested sequences each."""
    N = len(atoms)
    goal = {("R", w), ("nR", w)}
    tested_before = sum(N ** L for L in range(1, start_L))
    L = start_L
    while True:
        # does a valid derivation with exactly L lines exist?  find the lexicographically first one
        found = [None]
        count = [0]           # sequences of length L lexicographically before the first valid one

        def dfs(prefix, earlier_set):
            pos = len(prefix)
            remaining = L - pos - 1
            for a in atoms:
                ok = justified(a, earlier_set)
                if pos == L - 1:
                    if ok and a in goal:
                        found[0] = prefix + [a]
                        return True
                    count[0] += 1
                    continue
                if not ok:
                    count[0] += N ** remaining      # every completion of an invalid prefix is tested and fails
                    continue
                newset = earlier_set | {a}
                if dfs(prefix + [a], newset):
                    return True
            return False

        if dfs([], frozenset()):
            return tested_before + count[0] + 1, L, found[0]
        tested_before += N ** L
        L += 1


def brute_rank(w, atoms):
    """brute force: enumerate sequences in the same order and test each one (small cases only)."""
    goal = {("R", w), ("nR", w)}
    tested = 0
    for L in itertools.count(1):
        for seq in itertools.product(atoms, repeat=L):
            tested += 1
            earlier = set()
            ok = True
            for a in seq:
                if not justified(a, earlier):
                    ok = False
                    break
                earlier.add(a)
            if ok and seq[-1] in goal:
                return tested, L


def main():
    rng = random.Random(SEED)
    lines_out = []

    def log(s):
        print(s)
        lines_out.append(s)

    log("s2_craig_blowup.py  seed=%d" % SEED)
    log("Canonical search order: by number of lines, then lexicographic in the candidate-line order.")
    log("")
    # brute-force cross-check of the counting search
    for w in ["", "0", "1", "01", "10", "11", "00"]:
        atoms = atoms_for(len(w))
        k1, L1, _ = canonical_rank(w, atoms)
        k2, L2 = brute_rank(w, atoms)
        log(f"cross-check w={w!r:5}: counting search k={k1}, lines={L1}; brute force k={k2}, lines={L2}; "
            f"{'agree' if (k1, L1) == (k2, L2) else 'DISAGREE'}")
    log("")
    hdr = ("|w|  w(sample)              N_cand  L*  d_T   log10(k)   log10 Craig axiom  "
           "certificate axiom  fast-labeller Craig axiom")
    log(hdr)
    for n in list(range(1, 13)) + [16, 20, 24]:
        w = "".join(rng.choice("01") for _ in range(n))
        atoms = atoms_for(n)
        N = len(atoms)
        der, b = shortest_derivation(w)
        Lstar = len(der)
        dT = sum(lit_size(x) for x in der)
        phi = 1 + n + 1 + (0 if b == 1 else 1)          # |phi^b|
        if n <= 4:
            k, L, first = canonical_rank(w, atoms, start_L=(1 if n <= 2 else Lstar))
            assert L == Lstar, (w, L, Lstar)
            exact = True
        else:
            # lower bound: all sequences with fewer lines are tested first
            k = sum(N ** L for L in range(1, Lstar))
            exact = False
        log10k = math.log10(k)
        craig = math.log10(k + 1) + math.log10(phi)       # log10 of (k+1)|phi^b|
        # certificate: per line a 2-bit tag and the index of the candidate line in ceil(log2 N) bits
        cbits = Lstar * (2 + math.ceil(math.log2(N)))
        cert = cbits + 14 + 1 + phi                        # |theta_c -> phi^b| = |c| + 15 + |phi^b|
        fast = (n + 3) * phi                               # (time + 1)|phi^b| with time <= n + 2
        log(f"{n:3d}  {w[:20]:20s} {N:8d} {Lstar:3d} {dT:4d}   {log10k:8.2f}{'' if exact else '+'}   "
            f"{craig:12.2f}       {cert:10d}          {fast:10d}")
    log("")
    log("'+' marks a lower bound (sequences with fewer lines only); other rows are exact.")
    log("log10 Craig axiom = log10((k+1)|phi^b|), symbols.  Certificate and fast-labeller columns are symbols.")
    log("Reading: the Craig axiom of canonical proof search grows like N^(L*-1) = 2^Theta(|w|^2) here,")
    log("the theory's own derivations like |w|^2, the certificate axiom like |w|^2, and the Craig axiom")
    log("of the fast parity labeller like |w|^2.  The blow-up belongs to the construction (padding by the")
    log("run time of an exhaustive search), not to the observational regularity.")
    with open(OUT, "w") as fh:
        fh.write("\n".join(lines_out) + "\n")


if __name__ == "__main__":
    main()
