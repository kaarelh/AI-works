#!/usr/bin/env python3
"""Exact counts of small Boolean circuits by the function they compute.

Model (as in circuits-B.md, section 1): k input wires; gate i (i = 1..s) has a
type among the 16 two-input Boolean functions and an ordered pair of
predecessors among the k inputs and the gates 1..i-1; the output is the last
gate.  N_s = prod_{i=1..s} 16 (k+i-1)^2 circuits of size s.

The script counts, for every s up to a small bound, how many circuits of size
s compute each function, by dynamic programming over the multiset of wire
functions (exact integers).  It then prints, for a few tasks, the share of
the circuits fitting the data whose answer at a held-out input is off the
target's ("off-target"), the share computing the target on all inputs, and
the share computing a given payload variant (target XOR v, target OR v,
target AND NOT v).  It also checks the core-size law and the gate-price
bounds of circuits-B.md.  Inputs are written x1 x2 ... as bit strings.
Deterministic; no randomness; runs in well under a minute.
"""
import sys, time
from collections import defaultdict
from fractions import Fraction
from itertools import product

def input_tables(k):
    res = []
    for i in range(k):
        t = 0
        for u in range(1 << k):
            if (u >> i) & 1:
                t |= 1 << u
        res.append(t)
    return res

def gate(tt, a, b, mask):
    r = 0
    if tt & 1: r |= ~a & ~b
    if tt & 2: r |= ~a & b
    if tt & 4: r |= a & ~b
    if tt & 8: r |= a & b
    return r & mask

def counts_by_function(k, smax):
    """list over s = 1..smax of dict: truth table -> number of size-s circuits."""
    mask = (1 << (1 << k)) - 1
    states = {tuple(sorted(input_tables(k))): 1}
    out = []
    for s in range(1, smax + 1):
        pair = defaultdict(int)          # (fa, fb) -> number of (circuit prefix, ordered pin pair)
        nxt = defaultdict(int) if s < smax else None
        for S, cnt in states.items():
            d = {}
            for f in S:
                d[f] = d.get(f, 0) + 1
            items = list(d.items())
            for fa, ma in items:
                for fb, mb in items:
                    w = cnt * ma * mb
                    pair[(fa, fb)] += w
                    if nxt is not None:
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

def N(k, s, B=16):
    n = 1
    for i in range(1, s + 1):
        n *= B * (k + i - 1) ** 2
    return n

def bit(table, u):
    return (table >> u) & 1

def idx(bits):
    """input index from a tuple (x_1, ..., x_k)."""
    return sum(b << i for i, b in enumerate(bits))

def report(name, k, tables, target, data, queries, payloads=()):
    """Shares, among the circuits of size s that fit the data, of answers off the target's at each query."""
    print("TASK %s" % name)
    tgt = 0
    for u in product((0, 1), repeat=k):
        if target(u):
            tgt |= 1 << idx(u)
    dmask = sum(1 << idx(u) for u in data)
    qs = ["".join(map(str, q)) for q in queries]
    num = [Fraction(0)] * len(queries)
    den = Fraction(0)
    exact_l = Fraction(0)
    for s in range(1, len(tables) + 1):
        cons = {f: c for f, c in tables[s - 1].items() if (f ^ tgt) & dmask == 0}
        tot = sum(cons.values())
        if tot == 0:
            print("  s=%d fit=0" % s)
            continue
        devs = [sum(c for f, c in cons.items() if bit(f, idx(q)) != bit(tgt, idx(q))) for q in queries]
        line = "  s=%d fit=%d functions=%d target-everywhere=%s" % (s, tot, len(cons), Fraction(cons.get(tgt, 0), tot))
        line += " off-target: " + " ".join("%s:%s(%.4f)" % (qn, Fraction(d, tot), d / tot) for qn, d in zip(qs, devs))
        for pname, pf in payloads:
            pt = 0
            for u in product((0, 1), repeat=k):
                if pf(u):
                    pt |= 1 << idx(u)
            line += " %s=%s" % (pname, Fraction(cons.get(pt, 0), tot))
        print(line)
        w = Fraction(1, 2 ** s * N(k, s))
        den += w * tot
        exact_l += w * cons.get(tgt, 0)
        num = [x + w * d for x, d in zip(num, devs)]
    print("  length prior 2^-s/N_s cut at s<=%d: target-everywhere=%.4f off-target: %s" % (
        len(tables), float(exact_l / den), " ".join("%s:%.4f" % (qn, float(x / den)) for qn, x in zip(qs, num))))

# ---------- wiring-only check of the core-size law (section 1) ----------
def core_size_counts(k, s):
    """number of wirings (B = 1) of size s by the number of gates that are ancestors-or-self of the last gate."""
    res = defaultdict(int)
    ranges = [range(k + i - 1) for i in range(1, s + 1) for _ in (0, 1)]
    for w in product(*ranges):
        active = {s - 1}
        for g in range(s - 1, -1, -1):
            if g in active:
                for p in (w[2 * g], w[2 * g + 1]):
                    if p >= k:
                        active.add(p - k)
        res[len(active)] += 1
    return dict(res)

def elem_sym(vals, r):
    e = [Fraction(1)] + [Fraction(0)] * r
    for v in vals:
        for j in range(r, 0, -1):
            e[j] += e[j - 1] * v
    return e[r]

def beta(k, s, a, B=1):
    p = [Fraction(1, B * (k + i - 1) ** 2) for i in range(1, s + 1)]
    return p[s - 1] * elem_sym(p[:s - 1], a - 1)

def main():
    t0 = time.time()
    print("== 1. Core-size law: #{wirings of size s with core size a} = R_a * N_s * beta_s(a)  (B=1) ==")
    for k, smax in ((2, 5), (3, 4)):
        R = {}
        ok = True
        for s in range(1, smax + 1):
            cs = core_size_counts(k, s)
            R[s] = cs.get(s, 0)
            for a in range(1, s + 1):
                pred = R[a] * N(k, s, 1) * beta(k, s, a)
                if pred != cs.get(a, 0):
                    ok = False
            print("  k=%d s=%d: wirings by core size %s" % (k, s, [cs.get(a, 0) for a in range(1, s + 1)]))
        print("  k=%d: reduced wirings R_a = %s ; identity holds for all a<=s<=%d: %s" % (k, [R[a] for a in range(1, smax + 1)], smax, ok))
    print()
    print("== 2. Price of a gate: beta_s(a+1)/beta_s(a) against the bounds of CB3 (B=16) ==")
    for k, s in ((3, 5), (3, 12)):
        for a in (1, 4, 8):
            if a + 1 > s:
                continue
            r = beta(k, s, a + 1, 16) / beta(k, s, a, 16)
            lo = Fraction(1, 16 * a) * (Fraction(1, k + a - 1) - Fraction(1, k + s - 1))
            hi = Fraction(1, 16 * a * (k - 1))
            assert lo <= r <= hi
            print("  k=%d s=%d a=%d: lower %.3e <= ratio %.3e <= upper %.3e   (exact rationals)" % (k, s, a, lo, r, hi))
    for k, s in ((3, 5000), (20, 5000)):
        p = [1.0 / (16 * (k + i - 1) ** 2) for i in range(1, s)]
        e = [1.0] + [0.0] * 33
        for v in p:
            for j in range(33, 0, -1):
                e[j] += e[j - 1] * v
        for a in (1, 8, 32):
            r = e[a] / e[a - 1]
            lo = (1.0 / (16 * a)) * (1.0 / (k + a - 1) - 1.0 / (k + s - 1))
            hi = 1.0 / (16 * a * (k - 1))
            print("  k=%d s=%d a=%d: lower %.3e <= ratio %.3e <= upper %.3e   (floating point)" % (k, s, a, lo, r, hi))
    print()
    print("== 3. Posterior shares, k=3, full basis, sizes 1..5 ==")
    T3 = counts_by_function(3, 5)
    for s in range(1, 6):
        assert sum(T3[s - 1].values()) == N(3, s)
    lowv = [(a, b, 0) for a in (0, 1) for b in (0, 1)]
    highv = [(a, b, 1) for a in (0, 1) for b in (0, 1)]
    report("A: target x1 AND x2, third input v frozen at 0 on the data", 3, T3,
           lambda u: u[0] & u[1], lowv, highv,
           payloads=(("XORv", lambda u: (u[0] & u[1]) ^ u[2]),
                     ("ORv", lambda u: (u[0] & u[1]) | u[2]),
                     ("ANDNOTv", lambda u: (u[0] & u[1]) & (1 - u[2]))))
    report("B: target x1 XOR x2, v frozen at 0 on the data", 3, T3,
           lambda u: u[0] ^ u[1], lowv, highv,
           payloads=(("XORv", lambda u: u[0] ^ u[1] ^ u[2]),
                     ("ORv", lambda u: (u[0] ^ u[1]) | u[2])))
    report("C: target x1 (a literal), v frozen at 0 on the data", 3, T3,
           lambda u: u[0], lowv, highv)
    report("D: target (x1 AND x2) XOR v  (the target itself changes with v)", 3, T3,
           lambda u: (u[0] & u[1]) ^ u[2], lowv, highv)
    w2 = [u for u in product((0, 1), repeat=3) if sum(u) >= 2]
    rest = [u for u in product((0, 1), repeat=3) if sum(u) <= 1]
    report("E: target x1 AND x2 AND x3, data = inputs with at most one 0", 3, T3,
           lambda u: u[0] & u[1] & u[2], w2, rest)
    print("== 4. k=4, full basis, sizes 1..4 ==")
    T4 = counts_by_function(4, 4)
    for s in range(1, 5):
        assert sum(T4[s - 1].values()) == N(4, s)
    low = [u + (0,) for u in product((0, 1), repeat=3)]
    report("F: target (x1 AND x2) XOR x3, fourth input v frozen at 0", 4, T4,
           lambda u: (u[0] & u[1]) ^ u[2], low, [(0, 0, 0, 1), (1, 0, 0, 1), (1, 1, 0, 1), (1, 1, 1, 1)])
    w3 = [u for u in product((0, 1), repeat=4) if sum(u) >= 3]
    report("G: target AND of four inputs, data = inputs with at most one 0", 4, T4,
           lambda u: u[0] & u[1] & u[2] & u[3], w3, [(1, 1, 0, 0), (1, 0, 1, 0), (1, 0, 0, 0), (0, 0, 0, 0)])
    print("elapsed %.1f s" % (time.time() - t0), file=sys.stderr)

if __name__ == "__main__":
    main()
