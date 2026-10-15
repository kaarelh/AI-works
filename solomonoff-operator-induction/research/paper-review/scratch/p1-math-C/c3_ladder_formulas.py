"""p1-math-C check 3: independent re-derivation of the formula half of thm:comp:ladder for d=3,4.
Formula size = number of leaves; leaves x_j, not x_j, 0, 1; binary AND, OR, XOR.  Computes the least formula size of
every Boolean function by dynamic programming over truth tables, checks that at the start of stage k the least-size
consistent functions are exactly the k-conjunctions, and simulates Occam on the ladder under two tie rules
(truth-table order ascending/descending).  Deterministic.  Usage: python3 -I c3_ladder_formulas.py"""
import itertools
from math import comb

def run(d):
    N = 2**d; full = (1 << N) - 1
    var = [sum(1 << x for x in range(N) if (x >> j) & 1) for j in range(d)]
    leaves = set(var) | {full ^ v for v in var} | {0, full}
    best = {f: 1 for f in leaves}
    by_size = {1: set(leaves)}
    s = 1
    while len(best) < 2**N and s < 2*d + 2:
        s += 1
        new = set()
        for a in range(1, s):
            for f in by_size[a]:
                for g in by_size[s - a]:
                    for h in (f & g, f | g, f ^ g):
                        if h not in best:
                            new.add(h)
        for h in new: best[h] = s
        by_size[s] = new | set()
        # keep only functions of exact least size s at level s (sufficient for least-size DP)
    ones = N - 1
    ok = True
    for k in range(1, d):
        cons = [f for f, sz in best.items() if (f >> ones) & 1 and all(((f >> x) & 1) == 0 for x in range(N) if bin(x).count("1") < k)]
        m = min(best[f] for f in cons)
        least = sorted(f for f in cons if best[f] == m)
        conj = sorted(sum(1 << x for x in range(N) if all((x >> j) & 1 for j in S)) for S in itertools.combinations(range(d), k))
        ok &= (m == k and least == conj)
    # Occam on the ladder
    res = []
    for rule in ("asc", "desc"):
        order_key = (lambda f: (best[f], f)) if rule == "asc" else (lambda f: (best[f], -f))
        target = 1 << ones
        data = {}
        mistakes = 0
        def hyp():
            return min((f for f in best if all(((f >> x) & 1) == y for x, y in data.items())), key=order_key)
        seq = [ones, 0]
        for x in seq:
            h = hyp(); mistakes += ((h >> x) & 1) != ((target >> x) & 1); data[x] = (target >> x) & 1
        for k in range(1, d):
            level = [x for x in range(N) if bin(x).count("1") == k]
            while any(x not in data for x in level):
                h = hyp()
                errs = [x for x in level if x not in data and ((h >> x) & 1) != 0]
                x = errs[0] if errs else next(x for x in level if x not in data)
                mistakes += ((h >> x) & 1) != 0; data[x] = 0
        res.append((rule, mistakes))
    return ok, res

for d in (3, 4):
    ok, res = run(d)
    print(f"d={d}: least-size consistent = k-conjunctions for k=1..d-1: {ok}; Occam ladder mistakes {res}; paper bound 2^d-2={2**d-2}")
