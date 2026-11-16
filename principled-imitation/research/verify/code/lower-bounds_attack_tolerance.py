#!/usr/bin/env python3
"""Attack on Section 5 of research/prove/lower-bounds.md (N5): the gap
(2m+1)/(m+1) between the lower bound of Theorem 5.3 and the upper bound R3,
which the file lists as open ("closing (iii) from either side is open";
Section 9, item 3: "the adaptive case ... open").

Claim tested here (the adversary's, see the report): a scaffold whose inputs
depend on the answers closes the gap from below.

  Sequential-majority scaffold  Pi^seq(m, B, N0):
     z = (R_1, ..., R_B) independent and uniform on [N0], no internal randomness.
     Block b asks the inputs (R_b, 1), (R_b, 2), ... one after another and ends
     as soon as m+1 of its answers are equal to the same element of {0, 1};
     that element is the value of the block.  The outcome is the maximum of the
     block values.  Horizon L = B(m+1) + m; if the run would need a call beyond
     the horizon it stops with the outcome 'X' (an outcome that is wrong for
     every member).
  Region class: f_0 = 0 and f_i = 1 on region i, 0 elsewhere (as in Theorem 5.3).

Part A (brute force): for every member, every z and EVERY replacement rule that
  replaces at most m answers by elements of {0, 1, bot} (rules may depend on the
  whole history; all fault patterns are enumerated), the outcome equals the
  outcome of the human system, and the run has at most B(m+1) + m calls.  With
  m+1 replacements the outcome can be changed.
Part B: the human system makes exactly m+1 calls in each block, so on the run of
  f_0 every patch region R_b receives m+1 calls: the count that the packing
  argument for scaffolds with answer-dependent inputs allows (see the report).
Part C: numbers.  Lemma 1.10(2) gives, exactly as in Theorem 5.3(2), failure
  >= (N0 - n) p(B, N0)/(N0 + B); with N0 = B/(2 delta): n >= B/(4 delta) - B
  = (1 - 4 delta)(L - m)/(4 (m+1) delta).  Compared with the block-majority
  scaffold of Theorem 5.3 at the same horizon and with R3.
Part D: the non-adaptive block-majority scaffold of Definition 5.2' for
  comparison: tolerant against m replacements (the prover's check (c), redone
  with history-dependent rules), 2m+1 calls per block.
"""
import itertools
import math
import sys
from fractions import Fraction as F

BOT = 'bot'


def seq_run(m, B, z, f_region, faults_allowed, lmax):
    """Enumerate all runs of the sequential-majority scaffold on z with the
    human constant on regions (value f_region(R)), under every replacement rule
    with at most faults_allowed replacements.  Returns the set of
    (outcome, number_of_calls, faults_used)."""
    results = set()

    # depth-first search over the adversary's choices
    def rec(b, c0, c1, used, calls, vals):
        # b: current block index; c0, c1: counts of answers 0 and 1 in this block
        if b == len(z):
            results.add((max(vals) if vals else 0, calls, used))
            return
        if calls >= lmax:
            results.add(('X', calls, used))
            return
        truth = f_region(z[b])
        options = [(truth, 0)]
        if used < faults_allowed:
            for a in (0, 1, BOT):
                if a != truth:
                    options.append((a, 1))
        for a, cost in options:
            n0, n1 = c0 + (a == 0), c1 + (a == 1)
            if n0 == m + 1:
                rec(b + 1, 0, 0, used + cost, calls + 1, vals + [0])
            elif n1 == m + 1:
                rec(b + 1, 0, 0, used + cost, calls + 1, vals + [1])
            else:
                rec(b, n0, n1, used + cost, calls + 1, vals)

    rec(0, 0, 0, 0, 0, [])
    return results


def maj_run(m, B, z, f_region, faults_allowed):
    """Block-majority scaffold of Definition 5.2' (2m+1 calls per block, inputs
    do not depend on the answers), all replacement rules with at most
    faults_allowed replacements.  Returns the set of outcomes."""
    results = set()
    Ltot = B * (2 * m + 1)

    def rec(j, used, ones_in_block, vals):
        if j == Ltot:
            results.add(max(vals))
            return
        b = j // (2 * m + 1)
        truth = f_region(z[b])
        options = [(truth, 0)]
        if used < faults_allowed:
            for a in (0, 1, BOT):
                if a != truth:
                    options.append((a, 1))
        for a, cost in options:
            ones = ones_in_block + (a == 1)
            if (j + 1) % (2 * m + 1) == 0:
                rec(j + 1, used + cost, 0, vals + [1 if ones >= m + 1 else 0])
            else:
                rec(j + 1, used + cost, ones, vals)

    rec(0, 0, 0, [])
    return results


def p_hit(L, N):
    return 1 - (1 - F(1, N)) ** L


def part_ab():
    print("Part A/B: sequential-majority scaffold, brute force over all replacement rules")
    print("   m  B  N0   horizon B(m+1)+m   tolerant to m faults   max calls with <= m faults   calls of the human system per block   m+1 faults can change the outcome")
    for (m, B, N0) in [(1, 1, 2), (1, 2, 2), (1, 2, 3), (1, 3, 2), (2, 1, 2), (2, 2, 2), (2, 2, 3), (3, 1, 2), (3, 2, 2), (2, 3, 2)]:
        lmax = B * (m + 1) + m
        tolerant = True
        maxcalls = 0
        human_calls = set()
        breakable = False
        for i in range(0, N0 + 1):                       # member f_i, i = 0 is the zero function
            f_region = (lambda R, i=i: 1 if (i >= 1 and R == i) else 0)
            for z in itertools.product(range(1, N0 + 1), repeat=B):
                truth_out = max(f_region(R) for R in z)
                res = seq_run(m, B, z, f_region, m, lmax)
                for (out, calls, used) in res:
                    if out != truth_out:
                        tolerant = False
                    maxcalls = max(maxcalls, calls)
                    if used == 0:
                        human_calls.add(F(calls, B))
                res2 = seq_run(m, B, z, f_region, m + 1, lmax)
                if any(out != truth_out for (out, calls, used) in res2):
                    breakable = True
        print("  %2d %2d %3d   %8d           %-20s   %8d                     %-30s        %s"
              % (m, B, N0, lmax, tolerant, maxcalls, sorted(human_calls), breakable))
        assert tolerant and maxcalls <= lmax and human_calls == {F(m + 1)} and breakable


def part_d():
    print()
    print("Part D: block-majority scaffold of Definition 5.2' (inputs do not depend on the answers)")
    print("   m  B  N0   horizon B(2m+1)   tolerant to m faults (history-dependent rules, answers in {0,1,bot})   m+1 faults can change the outcome")
    for (m, B, N0) in [(1, 1, 2), (1, 2, 2), (1, 2, 3), (2, 1, 2), (2, 2, 2)]:
        tolerant = True
        breakable = False
        for i in range(0, N0 + 1):
            f_region = (lambda R, i=i: 1 if (i >= 1 and R == i) else 0)
            for z in itertools.product(range(1, N0 + 1), repeat=B):
                truth_out = max(f_region(R) for R in z)
                if any(o != truth_out for o in maj_run(m, B, z, f_region, m)):
                    tolerant = False
                if any(o != truth_out for o in maj_run(m, B, z, f_region, m + 1)):
                    breakable = True
        print("  %2d %2d %3d   %8d          %-20s                                                  %s" % (m, B, N0, B * (2 * m + 1), tolerant, breakable))
        assert tolerant and breakable


def part_c():
    print()
    print("Part C: questions needed for failure <= delta for every member of the region class (exact value of")
    print("   N0 - delta (N0 + B)/p(B, N0) with N0 = B/(2 delta)), at equal horizon L, against R3's sufficient number")
    print("   m   delta    L     | block-majority (Thm 5.3): B    bound   | sequential majority: B    bound   | ratio | R3: L K ln2/((m+1) delta), K = log2(N0+1) for the sequential scaffold")
    for (m, delta, B_seq) in [(1, F(1, 20), 30), (2, F(1, 20), 20), (5, F(1, 40), 22), (10, F(1, 100), 42), (50, F(1, 100), 102)]:
        L = B_seq * (m + 1) + m
        # block-majority needs L = B(2m+1): take the largest B that fits in the same horizon
        B_maj = L // (2 * m + 1)

        def need(B):
            N0 = F(B) / (2 * delta)
            if N0.denominator != 1:
                N0 = F(math.ceil(N0))
            N0 = int(N0)
            return float(N0 - delta * (N0 + B) / p_hit(B, N0)), N0
        b_maj, _ = need(B_maj)
        b_seq, N0s = need(B_seq)
        K = math.log2(N0s + 1)
        r3 = L * K * math.log(2) / ((m + 1) * float(delta))
        print("  %3d  %-6s %5d   |                     %5d  %8.1f   |              %5d  %8.1f   | %5.2f | %10.1f"
              % (m, delta, L, B_maj, b_maj, B_seq, b_seq, b_seq / b_maj, r3))
        # the closed forms claimed in the report
        assert b_seq >= float((1 - 4 * delta) * (L - m) / (4 * (m + 1) * delta)) - 1e-9
    print("   (ratio = sequential / block-majority; it tends to (2m+1)/(m+1) as L grows)")


if __name__ == "__main__":
    part_ab()
    part_d()
    part_c()
    print("all checks passed")
