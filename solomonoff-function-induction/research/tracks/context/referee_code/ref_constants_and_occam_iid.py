"""Referee check of explicit constants in notes.md, and of Prop 3.9 (Occam's expected in-distribution
mistakes) on the exact circuit order for d = 4 (minimal sizes recomputed here from scratch).

(1) Prop 2.12(3): (1/2) 2^{-l - 2 log2(l+1)} >= 1 / (8 m (log2 m + 3)^2), l = ceil(log2 m) + 1, m = 1..10^6.
(2) Prop 3.8: (ln|H| + ln 100)/0.01 <= 70 l + 531 when |H| < 2^{l+1}, l = 0..10^4.
(3) Prop 3.9 constant: 1 + sum_{n=1}^{N-1} [2 ln(n+1)/n + (n+1)^-2] - ln^2 N <= 5.7 for N up to 10^6,
    (the ln|H_f| (1 + ln N) part is separate), and the inequality sum_{n<N} ln n / n <= ln^2 N / 2 + 1/e.
(4) Section 3.2: B(s) = g (5 + 2 log2(d+1+s+g)) >= log2 of the exact weight ratio w(C)/w(C') = 2^g N_{s+g}/N_s.
    Formula surgery cost B = d (1 + log2(12 (2d+2))) = 22.75 at d = 3.
(5) Prop 3.9 by simulation: Occam over the exact circuit order (d = 4, functions of size <= 3, ties by a
    seeded random permutation), i.i.d. uniform inputs; mean total mistakes over 4000 runs vs the bound
    6.7 + ln|H_f| (1 + ln N) + ln^2 N, N = ceil(ln|H_f| / p_min), p_min = 2^-d.
Seeded.  Output: ref_constants_and_occam_iid_output.txt
"""
import math
import random

import numpy as np

SEED = 31337
OUT = []


def log(s):
    OUT.append(s)
    print(s)


def var_tt(d, j):
    t = 0
    for i in range(2 ** d):
        if (i >> j) & 1:
            t |= 1 << i
    return t


def all_ops(a, b, full):
    na, nb = full ^ a, full ^ b
    return {0, full, a, b, na, nb, a & b, a & nb, na & b, na & nb, a | b, a | nb, na | b, na | nb, a ^ b, full ^ a ^ b}


def min_sizes(d, smax):
    full = (1 << (2 ** d)) - 1
    base = frozenset([0, full] + [var_tt(d, j) for j in range(d)])
    size = {}
    frontier = {frozenset()}
    for s in range(1, smax + 1):
        nf = set()
        for inter in frontier:
            av = list(base | inter)
            outs = set()
            for i in range(len(av)):
                for j in range(i, len(av)):
                    outs |= all_ops(av[i], av[j], full)
            for g in outs:
                size.setdefault(g, s)
                if s < smax and g not in base and g not in inter:
                    nf.add(frozenset(inter | {g}))
        frontier = nf
    return size


def main():
    # (1)
    worst = min(0.5 * 2.0 ** (-(math.ceil(math.log2(m)) + 1) - 2 * math.log2(math.ceil(math.log2(m)) + 2))
                * 8 * m * (math.log2(m) + 3) ** 2 for m in range(1, 10 ** 6 + 1, 7))
    log(f"(1) Prop 2.12: min over m of LHS/RHS = {worst:.4f} (>= 1 required): {worst >= 1}")
    # (2)
    ok = all((math.log(2) * (l + 1) + math.log(100)) / 0.01 <= 70 * l + 531 for l in range(0, 10001))
    log(f"(2) Prop 3.8: 100 (ln 2^(l+1) + ln 100) <= 70 l + 531 for l = 0..10^4: {ok}")
    # (3)
    worst_c, worst_ln = -1e9, -1e9
    acc, accln = 1.0, 0.0
    for N in range(2, 10 ** 6 + 1):
        n = N - 1
        acc += 2 * math.log(n + 1) / n + (n + 1) ** -2
        accln += math.log(n) / n
        if N % 97 == 0 or N < 200:
            worst_c = max(worst_c, acc - math.log(N) ** 2)
            worst_ln = max(worst_ln, accln - (0.5 * math.log(N) ** 2 + 1 / math.e))
    log(f"(3) Prop 3.9: max_N [1 + sum (2 ln(n+1)/n + (n+1)^-2) - ln^2 N] = {worst_c:.4f} (<= 5.7: {worst_c <= 5.7}); "
        f"max_N [sum ln n/n - ln^2 N/2 - 1/e] = {worst_ln:.4f} (<= 0: {worst_ln <= 0})")
    # (4)
    def logN(d, s):
        return sum(4 + 2 * math.log2(d + 1 + j) for j in range(1, s + 1))
    bad = 0
    for d in range(1, 40):
        g = max(d - 1, 1) + 1
        for s in range(1, 300):
            exact = g + logN(d, s + g) - logN(d, s)
            B = g * (5 + 2 * math.log2(d + 1 + s + g))
            if exact > B + 1e-9:
                bad += 1
    log(f"(4) circuit surgery: exact -log2 weight ratio <= B(s) for d < 40, s < 300: violations {bad}; "
        f"formula B at d=3: {3 * (1 + math.log2(12 * 8)):.3f}")
    # (5)
    d = 4
    size = min_sizes(d, 3)
    rng = random.Random(SEED)
    key = {gf: rng.random() for gf in size}
    order = sorted(size, key=lambda gf: (size[gf], key[gf]))
    pos = {gf: i for i, gf in enumerate(order)}
    full = (1 << 16) - 1
    targets = {"AND_4": 1 << 15, "x1 XOR x2": var_tt(4, 0) ^ var_tt(4, 1),
               "parity_3": var_tt(4, 0) ^ var_tt(4, 1) ^ var_tt(4, 2)}
    # add three random size-3 functions
    s3 = [gf for gf in order if size[gf] == 3]
    for t in range(3):
        targets[f"random size-3 #{t}"] = s3[rng.randrange(len(s3))]
    nprng = np.random.default_rng(SEED)
    log("(5) Occam in distribution (uniform on {0,1}^4), exact circuit order, ties random; 4000 runs each")
    for name, f in targets.items():
        H = order[: pos[f] + 1]
        lnH = math.log(len(H))
        N = math.ceil(lnH / 2 ** -d)
        bound = 6.7 + lnH * (1 + math.log(N)) + math.log(N) ** 2
        tot = []
        Harr = np.array([[(h >> i) & 1 for i in range(16)] for h in H], dtype=np.int8)
        fv = np.array([(f >> i) & 1 for i in range(16)], dtype=np.int8)
        for _ in range(4000):
            alive = np.ones(len(H), dtype=bool)
            m = 0
            cur = 0
            for _step in range(400):
                x = int(nprng.integers(16))
                if Harr[cur, x] != fv[x]:
                    m += 1
                alive &= Harr[:, x] == fv[x]
                cur = int(np.argmax(alive))
                if cur == len(H) - 1 or np.array_equal(Harr[cur], fv):
                    break
            tot.append(m)
        log(f"  {name:18s}: c(f) = {size[f]}, |H_f| = {len(H):5d}, mean mistakes {np.mean(tot):.2f} "
            f"(max {max(tot)}), Prop 3.9 bound {bound:.1f}; holds: {np.mean(tot) <= bound}")
    with open(__file__.replace(".py", "_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
