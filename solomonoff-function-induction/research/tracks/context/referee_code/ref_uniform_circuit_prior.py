"""Referee check of notes.md Prop 4.5 (uniform prior over circuits of size exactly S contains the circuit
simplicity prior): for every f with c(f) < S,
    P_unif,S(f) >= 1 / (N_{c(f)} * 16 (d+1+S)^2).
Brute force over ALL circuits of size S (gate list as in notes 3.2: 16 gate types, inputs from
x_1..x_d, 0, 1, earlier gates; output = last gate) for (d,S) = (1,2), (2,2), (3,2), (1,3), (2,3).
Deterministic.  Output: ref_uniform_circuit_prior_output.txt
"""
import itertools
import math

import numpy as np

OUT = []


def log(s):
    OUT.append(s)
    print(s)


def ops_table():
    # gate type t in 0..15: output bit for (a,b) = bit (2a+b) of t
    return [(lambda t: (lambda a, b: ((t >> (2 * a + b)) & 1)))(t) for t in range(16)]


def run(d, S):
    npts = 2 ** d
    pts = np.array([[(i >> j) & 1 for j in range(d)] for i in range(npts)], dtype=np.uint8)
    base = [pts[:, j] for j in range(d)] + [np.zeros(npts, np.uint8), np.ones(npts, np.uint8)]
    # enumerate circuits recursively, vectorised over the last gate
    counts = {}
    total = 0

    def tt_int(v):
        return int(sum(int(b) << i for i, b in enumerate(v)))

    def rec(avail, s):
        nonlocal total
        m = len(avail)
        A = np.stack(avail)  # m x npts
        if s == S:
            # last gate: all 16 types x m x m input pairs
            idx_a, idx_b = np.meshgrid(np.arange(m), np.arange(m), indexing="ij")
            a = A[idx_a.ravel()]
            b = A[idx_b.ravel()]
            code = 2 * a + b  # (m*m) x npts in 0..3
            for t in range(16):
                out = (t >> code) & 1
                keys = (out.astype(np.int64) << np.arange(npts)).sum(axis=1)
                u, c = np.unique(keys, return_counts=True)
                for k_, c_ in zip(u.tolist(), c.tolist()):
                    counts[k_] = counts.get(k_, 0) + c_
                total += m * m
            return
        for t in range(16):
            for ia in range(m):
                for ib in range(m):
                    g = (t >> (2 * A[ia].astype(np.int64) + A[ib])) & 1
                    rec(avail + [g.astype(np.uint8)], s + 1)

    rec(base, 1)
    N = lambda s: math.prod(16 * (d + 1 + j) ** 2 for j in range(1, s + 1))
    assert total == N(S), (total, N(S))
    # minimal sizes c(f) <= S-1 by enumeration of smaller sizes
    full = (1 << npts) - 1
    def all_ops(x, y):
        nx, ny = full ^ x, full ^ y
        return {0, full, x, y, nx, ny, x & y, x & ny, nx & y, nx & ny, x | y, x | ny, nx | y, nx | ny, x ^ y, full ^ x ^ y}
    bset = [tt_int(v) for v in base]
    size = {}
    frontier = {frozenset()}
    for s in range(1, S):
        nf = set()
        for inter in frontier:
            av = list(set(bset) | inter)
            outs = set()
            for i in range(len(av)):
                for j in range(i, len(av)):
                    outs |= all_ops(av[i], av[j])
            for g in outs:
                size.setdefault(g, s)
                nf.add(frozenset(inter | {g}))
        frontier = nf
    worst = math.inf
    nchk = 0
    for f, c in size.items():
        p = counts.get(f, 0) / total
        bound = 1.0 / (N(c) * 16 * (d + 1 + S) ** 2)
        worst = min(worst, p / bound)
        nchk += 1
    log(f"d={d} S={S}: {total} circuits of size S enumerated; {nchk} functions with c(f) < S; "
        f"min over f of P_unif,S(f) / bound = {worst:.3f} (>= 1 required): {worst >= 1}")


def main():
    for d, S in [(1, 2), (2, 2), (3, 2), (1, 3), (2, 3)]:
        run(d, S)
    with open(__file__.replace(".py", "_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
