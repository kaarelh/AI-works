"""Exact counts of small Boolean circuits by the function they compute.

Model (research/circuits-final.md, Section 1.1): k input wires; a circuit of size
s is an ordered list of gates g_1..g_s, gate i having one of the 16 two-input
truth tables and an ordered pair of pointers to wires among the k inputs and the
gates 1..i-1; the output is the last gate.  There are
    N_s = prod_{i=1..s} 16 (k+i-1)^2
circuits of size s.  The fixed-size prior mu_s is uniform on them.

A function of the k inputs is stored as its truth table, an integer of 2^k bits:
bit u is the value at the input with x_{i+1} = (u >> i) & 1 (i = 0..k-1).  In the
index reading (Section 1.3) input wire i+1 carries the binary digit b_i of t-1 for
the position t = u+1, so the truth table read from bit 0 upwards is
tt(C) = f_C(1) f_C(2) ... f_C(2^k), and a context of length n is the set of bits
0..n-1.

`counts_by_function(k, smax)` counts, for each s <= smax, the number of size-s
circuits computing each function, by dynamic programming over the multiset of
wire functions of a circuit prefix (the method of research/circuit_count.py):
the function of the next gate depends only on the functions of the two wires it
points to, so prefixes with the same multiset of wire functions can be merged,
and the number of ordered pointer pairs onto wires with functions (fa, fb) is
m(fa) * m(fb).  `counts_direct(k, s)` enumerates every circuit of size s one by
one and serves as a check.  Exact integers throughout; no randomness.

Command line:  python3 circuit_count.py K SMAX [--direct]
prints, for each s <= SMAX, N_s, the number of distinct functions computed and
the check that the counts sum to N_s (and agree with direct enumeration if
--direct is given; keep K and SMAX small then).
"""
import sys
from collections import defaultdict
from fractions import Fraction
from itertools import product


def input_tables(k):
    """Truth tables of the k input wires x_1..x_k (equivalently b_0..b_{k-1})."""
    res = []
    for i in range(k):
        t = 0
        for u in range(1 << k):
            if (u >> i) & 1:
                t |= 1 << u
        res.append(t)
    return res


def full_mask(k):
    return (1 << (1 << k)) - 1


def gate(tt, a, b, mask):
    """Truth table of a gate with table tt (bit 2*va+vb is the output on (va, vb))
    applied to wires with truth tables a and b."""
    r = 0
    if tt & 1:
        r |= ~a & ~b
    if tt & 2:
        r |= ~a & b
    if tt & 4:
        r |= a & ~b
    if tt & 8:
        r |= a & b
    return r & mask


def N(k, s):
    """Number of circuits of size s on k inputs."""
    n = 1
    for i in range(1, s + 1):
        n *= 16 * (k + i - 1) ** 2
    return n


def counts_by_function(k, smax):
    """List over s = 1..smax of dict {truth table: number of size-s circuits computing it}."""
    mask = full_mask(k)
    states = {tuple(sorted(input_tables(k))): 1}
    out = []
    for s in range(1, smax + 1):
        last = s == smax
        pair = defaultdict(int)          # (fa, fb) -> number of (prefix, ordered pointer pair)
        nxt = None if last else defaultdict(int)
        for S, cnt in states.items():
            mult = defaultdict(int)
            for f in S:
                mult[f] += 1
            items = list(mult.items())
            for fa, ma in items:
                for fb, mb in items:
                    w = cnt * ma * mb
                    pair[(fa, fb)] += w
                    if not last:
                        for tt in range(16):
                            h = gate(tt, fa, fb, mask)
                            nxt[tuple(sorted(S + (h,)))] += w
        fc = defaultdict(int)
        for (fa, fb), w in pair.items():
            for tt in range(16):
                fc[gate(tt, fa, fb, mask)] += w
        out.append(dict(fc))
        states = nxt
    return out


def counts_direct(k, s):
    """dict {truth table: number of size-s circuits computing it}, by visiting every circuit."""
    mask = full_mask(k)
    res = defaultdict(int)
    wires = input_tables(k)

    def rec(i):                       # wires holds the k inputs and gates 1..i-1
        n = len(wires)
        for a in range(n):
            for b in range(n):
                fa, fb = wires[a], wires[b]
                for tt in range(16):
                    h = gate(tt, fa, fb, mask)
                    if i == s:
                        res[h] += 1
                    else:
                        wires.append(h)
                        rec(i + 1)
                        wires.pop()

    rec(1)
    return dict(res)


# ---------- inputs, data and queries ----------

def idx(bits):
    """Input index u from a tuple (x_1, ..., x_k)."""
    return sum(b << i for i, b in enumerate(bits))


def table_of(k, func):
    """Truth table of func, a function of the tuple (x_1, ..., x_k)."""
    t = 0
    for u in range(1 << k):
        if func(tuple((u >> i) & 1 for i in range(k))):
            t |= 1 << u
    return t


def mask_of(inputs):
    """Bit mask of a collection of inputs given as tuples (x_1, ..., x_k)."""
    m = 0
    for u in inputs:
        m |= 1 << idx(u)
    return m


def prefix_mask(n):
    """Index reading: the context of length n is positions 1..n, i.e. inputs u = 0..n-1."""
    return (1 << n) - 1


def bit(table, u):
    return (table >> u) & 1


def fitting(counts, target, dmask):
    """The part of a size-s count dict that agrees with target on the inputs in dmask."""
    return {f: c for f, c in counts.items() if (f ^ target) & dmask == 0}


def answer_share(counts, target, dmask, query, answer):
    """Under mu_s: (share, number answering `answer` at input index `query`, number fitting)
    among the circuits of size s that agree with target on dmask.  share is None if none fit."""
    cons = fitting(counts, target, dmask)
    tot = sum(cons.values())
    num = sum(c for f, c in cons.items() if bit(f, query) == answer)
    return (Fraction(num, tot) if tot else None), num, tot


def deviation_mass(counts, target, dmask, query, own):
    """1 - pi(own | query, D) under mu_s, with D = (dmask, target on dmask)."""
    return answer_share(counts, target, dmask, query, 1 - own)


def function_share(counts, target, dmask, g):
    """Share, among the size-s circuits fitting D, of those computing the function g everywhere."""
    cons = fitting(counts, target, dmask)
    tot = sum(cons.values())
    return (Fraction(cons.get(g, 0), tot) if tot else None), cons.get(g, 0), tot


def least_fitting_size(tables, target, dmask):
    """Least s (1-based) with a fitting circuit among tables[0..], or None."""
    for s, counts in enumerate(tables, start=1):
        if any((f ^ target) & dmask == 0 for f in counts):
            return s
    return None


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    k, smax = int(argv[0]), int(argv[1])
    direct = "--direct" in argv[2:]
    tables = counts_by_function(k, smax)
    for s, c in enumerate(tables, start=1):
        line = "k=%d s=%d N_s=%d functions=%d sum==N_s:%s" % (k, s, N(k, s), len(c), sum(c.values()) == N(k, s))
        if direct:
            line += " direct==dp:%s" % (counts_direct(k, s) == c)
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
