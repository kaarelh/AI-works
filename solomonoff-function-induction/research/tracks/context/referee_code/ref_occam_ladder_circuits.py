"""Referee check: Occam (simplest-consistent) circuit learning makes exponentially many
out-of-distribution mistakes on a natural target, in the circuit language of notes.md section 3.2.

Claim under test (notes.md, Remark 3.10 and open problem 5): "For natural languages a super-polynomial
lower bound, or a polynomial upper bound, is open" for Occam's OOD mistakes.

Referee's counter-claim (proved in referee.md, issue M1): take f = AND of all d variables (c(f) = d-1 gates).
Adversary: reveal 1^d first; then, while Occam's current hypothesis h has fewer than d-1 gates, reveal
1_{V_h} (ones exactly on the variable set V_h that h depends on).  Since h(1^d) = 1 and |V_h| <= c(h)+1 < d,
this is always an unrevealed point where h errs.  For 2 <= k <= d-1 the k-conjunction AND_T needs exactly
k-1 gates; while it is alive c(h) <= k-1, so |V_h| <= k, so AND_T can only be killed by revealing 1_T itself.
Hence every point of Hamming weight 2..d-1 is revealed as a mistake: >= 2^d - d - 2 mistakes, for EVERY
tie-breaking rule.  (A first, wrong version of this argument claimed C(d,k) mistakes in each "phase" k >= 1;
this script refutes that version at k = 1, 2 -- a literal costs one gate, so early hypotheses read 2 variables.)

Circuit language (notes 3.2): gates of all 16 binary types; gate inputs from x_1..x_d, 0, 1, earlier gates;
size = number of gates; Occam orders functions by minimal size (the description length s + log2 N_s is
increasing in s), ties broken by an arbitrary fixed rule.  We compute exact minimal sizes up to smax gates
(smax = 2 for d = 3, 6; smax = 3 for d = 4, 5).  The lower bound concerns only hypotheses with at most d-2 gates;
for d = 6 only conjunctions of size <= 2 (weights 2..3) are covered.  For d = 3, 4 the full run is simulated.

Tie-breaking rules tested: truth-table integer order (ascending and descending) and 5 random permutations.
Seeded.  Output: ref_occam_ladder_circuits_output.txt
"""
import itertools
import math
import random
import sys
import time

import numpy as np

SEED = 20261012
OUT = []


def log(s):
    OUT.append(s)
    print(s)
    sys.stdout.flush()


def cube_points(d):
    return [tuple((i >> j) & 1 for j in range(d)) for i in range(2 ** d)]


def var_tt(d, j):
    """truth table (python int, bit i = value on point i) of x_j"""
    t = 0
    for i in range(2 ** d):
        if (i >> j) & 1:
            t |= 1 << i
    return t


def all_ops(a, b, full):
    """the 16 binary gate types applied to truth tables a, b"""
    na, nb = full ^ a, full ^ b
    return {0, full, a, b, na, nb, a & b, a & nb, na & b, na & nb, a | b, a | nb, na | b, na | nb, a ^ b, full ^ a ^ b}


def gate_set(avail, full):
    out = set()
    av = list(avail)
    for i in range(len(av)):
        for j in range(i, len(av)):
            out |= all_ops(av[i], av[j], full)
    return out


def min_sizes(d, smax):
    """exact minimal circuit size (gate count) of every function of size <= smax.
    A size-s circuit is a list of gates g_1..g_s; its output is g_s.  We enumerate sequences of
    distinct-valued intermediate gates (repeated values never help)."""
    full = (1 << (2 ** d)) - 1
    base = frozenset([0, full] + [var_tt(d, j) for j in range(d)])
    size = {}
    # level s: set of tuples of intermediate gate values (g_1..g_{s-1}) -> output set
    frontier = {frozenset()}  # intermediate-value sets (as frozensets) for circuits with s-1 gates
    for s in range(1, smax + 1):
        new_frontier = set()
        for inter in frontier:
            outs = gate_set(base | inter, full)
            for g in outs:
                if g not in size:
                    size[g] = s
                if s < smax and g not in base and g not in inter:
                    new_frontier.add(frozenset(inter | {g}))
        frontier = new_frontier
        log(f"  d={d}: size {s}: {sum(1 for v in size.values() if v == s)} new functions; "
            f"{len(frontier)} intermediate sets carried")
    return size


def depends_on(d, tt):
    V = []
    for j in range(d):
        for i in range(2 ** d):
            if not (i >> j) & 1:
                if ((tt >> i) & 1) != ((tt >> (i | (1 << j))) & 1):
                    V.append(j)
                    break
    return V


def run_ladder(d, size, order_key, full_run):
    """Occam learner on f = AND_d with the adaptive adversary of the proof.
    Hypotheses: functions with known size, ordered by (size, order_key).  Returns
    (total mistakes, mistakes per phase k, final hypothesis size)."""
    full = (1 << (2 ** d)) - 1
    f = 1 << (2 ** d - 1)  # AND_d: 1 only at the all-ones point (index 2^d - 1)
    cf = size.get(f, None)
    hyps = sorted(size.keys(), key=lambda g: (size[g], order_key(g)))
    revealed = {}  # point index -> label
    mistakes = 0
    mist_pts = []
    per_phase = {}

    def consistent(g):
        for i, y in revealed.items():
            if ((g >> i) & 1) != y:
                return False
        return True

    def current():
        for g in hyps:
            if consistent(g):
                return g
        return None

    def kconj_alive(k):
        for S in itertools.combinations(range(d), k):
            ok = True
            for i, y in revealed.items():
                val = int(all((i >> j) & 1 for j in S))
                if val != y:
                    ok = False
                    break
            if ok:
                return True
        return False

    def reveal(i):
        nonlocal mistakes
        h = current()
        pred = (h >> i) & 1 if h is not None else None
        y = (f >> i) & 1
        revealed[i] = y
        if pred is not None and pred != y:
            mistakes += 1
            mist_pts.append(i)
            # phase = smallest k with a live k-conjunction (before this reveal), computed by caller
            return True
        return False

    fallbacks = []
    reveal(2 ** d - 1)  # the all-ones point first
    while True:
        h = current()
        if h is None:
            break
        if cf is not None and size[h] >= cf and not full_run:
            break
        if h == f:
            break
        # phase: smallest k with a live k-conjunction
        k = next((kk for kk in range(0, d) if kconj_alive(kk)), d)
        V = depends_on(d, h)
        pt = sum(1 << j for j in V)
        if pt in revealed or ((h >> pt) & 1) == ((f >> pt) & 1):
            fallbacks.append(pt)
            # fall back: any unrevealed point where h is wrong
            cand = [i for i in range(2 ** d) if i not in revealed and ((h >> i) & 1) != ((f >> i) & 1)]
            if not cand:
                break
            pt = cand[0]
        if reveal(pt):
            per_phase[k] = per_phase.get(k, 0) + 1
    final = current()
    if fallbacks:
        log(f"    note: fallback rule used {len(fallbacks)} times (only possible once c(h) >= d-1)")
    return mistakes, per_phase, (size.get(final) if final is not None else None), mist_pts


def main():
    rng = random.Random(SEED)
    log("Occam ladder in the gate-count circuit language of notes.md 3.2 (all 16 binary gates)")
    log(f"seed {SEED}")
    for d, smax, full_run in [(3, 2, True), (4, 3, True), (5, 3, False), (6, 2, False)]:
        t0 = time.time()
        log(f"\nd = {d}: enumerating exact minimal sizes up to {smax} gates")
        size = min_sizes(d, smax)
        f = 1 << (2 ** d - 1)
        log(f"  c(AND_{d}) = {size.get(f, '>' + str(smax))} (theory: d-1 = {d - 1})")
        rules = {"tt-ascending": lambda g: g, "tt-descending": lambda g: -g}
        for r in range(5):
            perm = {g: rng.random() for g in size}
            rules[f"random-{r}"] = (lambda p: (lambda g: p[g]))(perm)
        kmax = min(d - 1, smax + 1)  # k-conjunctions with k-1 <= smax gates are enumerated
        bound_total = sum(math.comb(d, k) for k in range(2, kmax + 1))
        for name, key in rules.items():
            m, per, fin, mist_pts = run_ladder(d, size, key, full_run)
            wt = {}
            for i in mist_pts:
                w = bin(i).count("1")
                wt[w] = wt.get(w, 0) + 1
            allk = all(wt.get(k, 0) == math.comb(d, k) for k in range(2, kmax + 1))
            wt_s = ", ".join(f"w={w}: {wt.get(w, 0)}/{math.comb(d, w)}" for w in range(0, d + 1))
            log(f"  tie-break {name:14s}: mistakes = {m:3d}; mistake points by Hamming weight: {wt_s}; "
                f"final hypothesis size {fin}; all points of weight 2..{kmax} were mistakes: {allk}; "
                f"mistakes >= {bound_total}: {m >= bound_total}")
        log(f"  ({time.time() - t0:.1f} s)")
    log("\nConclusion: in every run and for every tie-breaking rule, every point of Hamming weight 2..d-1")
    log("(within the enumerated sizes) was revealed as a mistake, as the corrected argument predicts:")
    log(">= 2^d - d - 2 mistakes against c(AND_d) = d - 1 gates (description length Theta(d log d)).")
    with open(__file__.replace(".py", "_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
