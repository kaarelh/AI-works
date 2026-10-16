"""Referee B, thread `shape`: Lemma 2.4 (subsumption keeps UP_k derivations), Prop 2.3 (CNF lower bound) against
exact minimum CNF sizes, and Prop 5.1(c) (the polynomial decider of PI(S)).

Independent of checks/. Seed 20261016. Writes refB_misc2.out next to itself.
"""
import os, sys, random, time, math
from itertools import combinations, product
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from refB_lib import *

SEED = 20261016
rng = random.Random(SEED)
OUT = []
T0 = time.time()


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def random_affine(m, k):
    while True:
        rows = [rng.randrange(1, 1 << m) for _ in range(k)]
        if rank(rows) == k:
            break
    return rows, [rng.randrange(2) for _ in range(k)]


def chain_pts(m):
    return [sum(1 << (v - 1) for v in range(a + 1, m + 1)) for a in range(m + 1)]


P("# refB_misc2.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
P("== A: Lemma 2.4: replacing implicates by contained prime implicates keeps every UP_k derivation, round by round")
runs = viol = conf = 0
for trial in range(120):
    m = rng.choice([4, 5, 6])
    if trial % 3 == 0:
        S = chain_pts(m)
    else:
        rows, consts = random_affine(m, rng.choice([1, 2, 3]))
        S = affine_points(rows, consts, m)
    pis = prime_implicates(S, m)
    F = []
    Fp = []
    for _ in range(rng.randint(2, 10)):
        C = set(rng.choice(pis))
        for _ in range(rng.choice([0, 1, 1, 2])):
            v = rng.randint(1, m)
            if v not in C and -v not in C:
                C.add(v if rng.random() < 0.5 else -v)
        C = frozenset(C)
        F.append(C)
        Fp.append(rng.choice([D for D in pis if D <= C]))
    for _ in range(15):
        x = rng.choice(S)
        alpha = frozenset((v if bit(x, v) else -v) for v in range(1, m + 1) if rng.random() < 0.4)
        for k in (1, 2, 3, None):
            a = up(F, alpha, k)
            b = up(Fp, alpha, k)
            runs += 1
            if a is None or b is None:
                conf += 1
                continue
            viol += not (a <= b)
P(f"  {runs} (theory, consistent alpha, k) runs: violations {viol}; conflicts {conf}")

P("== B: Prop 2.3: exact minimum CNF size over X (set cover of the non-solutions by prime implicates) vs (1-2^-k)2^d*")
rowsout = []
for trial in range(14):
    m = rng.choice([4, 5])
    k = rng.choice([1, 2, 3])
    rows, consts = random_affine(m, k)
    S = set(affine_points(rows, consts, m))
    pis = prime_implicates(sorted(S), m)
    nons = [x for x in range(1 << m) if x not in S]
    cover = [frozenset(x for x in nons if not clause_true_at(C, x)) for C in pis]
    best = None
    for s in range(1, len(pis) + 1):
        for G in combinations(range(len(pis)), s):
            U = set()
            for i in G:
                U |= cover[i]
            if len(U) == len(nons):
                best = s
                break
        if best:
            break
    deq = derived_equations(sorted(S), m)
    d = min(popcount(u) for u in deq if u)
    lb = (1 - 2 ** -k) * 2 ** d
    rowsout.append((m, k, d, best, lb, best >= lb - 1e-9))
P("  (m, k, d*, exact min CNF, bound, ok): " + "; ".join(f"({a},{b},{c},{e},{f:.2f},{g})" for a, b, c, e, f, g in rowsout))

P("== C: Prop 5.1(c): C_{T,beta} in PI(S) iff derived equations supported in T are exactly {0, 1_T} and beta violates 1_T")
tot = bad = 0
for trial in range(25):
    m = rng.choice([4, 5, 6])
    rows, consts = random_affine(m, rng.choice([1, 2, 3]))
    S = affine_points(rows, consts, m)
    pis = set(prime_implicates(S, m))
    sp = span(rows)
    # constants of derived equations from the system (Gaussian-elimination-free: by span with constants)
    cst = {0: 0}
    for r, c in zip(rows, consts):
        for u, cu in list(cst.items()):
            cst[u ^ r] = cu ^ c
    for C in all_clauses(range(1, m + 1)):
        T = sum(1 << (abs(L) - 1) for L in C)
        beta = sum(1 << (abs(L) - 1) for L in C if L < 0)  # falsifying assignment: x_v = 1 where literal is -v
        inside = [u for u in sp if (u & ~T) == 0]
        dec = sorted(inside) == sorted({0, T}) and (popcount(T & beta) % 2) != cst[T]
        tot += 1
        bad += dec != (C in pis)
P(f"  {tot} clauses over 25 random laws: decider disagrees with brute force in {bad}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_misc2.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
