"""c6: depth-size trade-off for the implication chain (thread `shape`, target T7).

Seed 20261016.  Writes c6_spanners.out next to itself.

Law Ch_m: x_1 -> x_2 -> ... -> x_m (solutions: monotone 0^a 1^(m-a)).  Reasoner UP_k (k parallel rounds).

A  reduction (Thm 7.1): a 2-CNF of sound implications is UP_k-usable iff its implication graph is a k-hop
   TC-spanner of the directed path; checked on random edge sets (m <= 7) by running UP_k on every consistent
   partial assignment.  Wide sound clauses add nothing (their prime-implicate replacements derive as much).
B  exact minimum k-hop TC-spanners of the directed path P_m by integer programming (k = 2, 3, 4), cross-checked
   by exhaustive search for m <= 7; the optimal spanners are re-checked as UP_k-usable theories.
C  comparison with the recursive constructions and with the lower bound for UP_2 with auxiliary variables
   and clauses of any width (Thm 7.3): |F| >= ((m-2) log2((m-2)/2) - m)/2.
"""
import random, sys, time, math
from itertools import combinations, product
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
from scipy.sparse import lil_matrix
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import up, all_partial_assignments

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


def chain_sols(m):
    return [sum(1 << v for v in range(a, m)) for a in range(m + 1)]


def implied(sols, m, alpha):
    ext = [x for x in sols if all((x >> v & 1) == s for v, s in alpha.items())]
    if not ext:
        return None
    out = set()
    for v in range(m):
        if v in alpha:
            continue
        vals = {x >> v & 1 for x in ext}
        if len(vals) == 1:
            out.add((v, vals.pop()))
    return out


def usable_k(F, m, k):
    sols = chain_sols(m)
    for alpha in all_partial_assignments(m):
        imp = implied(sols, m, alpha)
        if imp is None or not imp:
            continue
        a = up(F, m, alpha, k)
        if a is None or any(a[v] != s for v, s in imp):
            return False
    return True


def is_spanner(E, m, k):
    adj = {i: [j for (a, j) in E if a == i] for i in range(m)}
    for i in range(m):
        dist = {i: 0}
        frontier = [i]
        for h in range(1, k + 1):
            nf = []
            for u in frontier:
                for w in adj[u]:
                    if w not in dist:
                        dist[w] = h
                        nf.append(w)
            frontier = nf
        if any(j not in dist for j in range(i + 1, m)):
            return False
    return True


def twocnf(E):
    return [((i, 0), (j, 1)) for (i, j) in E]  # clause (not x_i or x_j)


t0 = time.time()
P(f"# c6_spanners.py  seed={SEED}  python={sys.version.split()[0]}")

# ------------------------------------------------------------------ A
P("== A: UP_k-usable 2-CNF  <=>  k-hop TC-spanner (random sound edge sets)")
agree = tot = 0
for trial in range(300):
    m = rng.randint(3, 7)
    k = rng.randint(1, 4)
    pairs = [(i, j) for i in range(m) for j in range(i + 1, m)]
    E = [(i, i + 1) for i in range(m - 1)] + [p for p in pairs if p[1] > p[0] + 1 and rng.random() < 0.35]
    tot += 1
    agree += (usable_k(twocnf(E), m, k) == is_spanner(E, m, k))
P(f"  {tot} random (m, k, E): agreement {agree}/{tot}")
# wide sound clauses: a clause containing (not x_i or x_j), i<j, plus extra literals: replacing it by the 2-clause
# never loses a UP_k derivation (c1 G checks this for affine laws; here for the chain)
viol = runs = 0
sols_cache = {}
for trial in range(200):
    m = rng.randint(4, 7)
    F = []
    G = []
    for _ in range(rng.randint(2, 8)):
        i = rng.randrange(m - 1)
        j = rng.randrange(i + 1, m)
        C = [(i, 0), (j, 1)]
        for v in range(m):
            if v not in (i, j) and rng.random() < 0.25:
                C.append((v, rng.randint(0, 1)))
        F.append(tuple(C))
        G.append(((i, 0), (j, 1)))
    sols = chain_sols(m)
    for alpha in all_partial_assignments(m):
        if implied(sols, m, alpha) is None:
            continue
        for k in (1, 2, 3):
            a = up(F, m, alpha, k)
            b = up(G, m, alpha, k)
            runs += 1
            if a is None or b is None or any(a[v] != -1 and a[v] != b[v] for v in range(m)):
                viol += 1
P(f"  wide sound clauses vs their 2-clause replacements: {runs} runs, violations={viol}")


# ------------------------------------------------------------------ B
def ilp_spanner(m, k):
    pairs = [(i, j) for i in range(m) for j in range(i + 1, m)]
    eidx = {p: t for t, p in enumerate(pairs)}
    paths = []  # list of (pair index, list of edge indices) for paths with 2..k hops
    for (i, j) in pairs:
        inner = list(range(i + 1, j))
        for h in range(2, k + 1):
            for mids in combinations(inner, h - 1):
                seq = [i] + list(mids) + [j]
                paths.append(((i, j), [eidx[(seq[t], seq[t + 1])] for t in range(h)]))
    ne, npth = len(pairs), len(paths)
    nv = ne + npth
    c = np.concatenate([np.ones(ne), np.zeros(npth)])
    nrows = len(pairs) + sum(len(es) for _, es in paths)
    A = lil_matrix((nrows, nv))
    lb = np.zeros(nrows)
    ub = np.full(nrows, np.inf)
    r = 0
    paths_of = {p: [] for p in pairs}
    for t, (p, es) in enumerate(paths):
        paths_of[p].append(t)
    for p in pairs:
        A[r, eidx[p]] = 1
        for t in paths_of[p]:
            A[r, ne + t] = 1
        lb[r] = 1
        r += 1
    for t, (p, es) in enumerate(paths):
        for e in es:
            A[r, ne + t] = 1
            A[r, e] = -1
            ub[r] = 0
            lb[r] = -np.inf
            r += 1
    res = milp(c, constraints=[LinearConstraint(A.tocsr(), lb, ub)], integrality=np.ones(nv),
               bounds=Bounds(0, 1), options={"time_limit": 600})
    E = [pairs[t] for t in range(ne) if res.x[t] > 0.5]
    return int(round(res.fun)), E, res.status


def brute_spanner(m, k):
    pairs = [(i, j) for i in range(m) for j in range(i + 2, m)]
    base = [(i, i + 1) for i in range(m - 1)]
    best = None
    for s in range(0, len(pairs) + 1):
        for extra in combinations(pairs, s):
            if is_spanner(base + list(extra), m, k):
                return m - 1 + s
    return best


def construct(m, k):
    """Recursive constructions: k=2 midpoint hubs; k>=3: blocks of size b with hub vertices (upper bounds)."""
    from functools import lru_cache

    @lru_cache(None)
    def s2(n):
        if n <= 1:
            return 0
        if n == 2:
            return 1
        h = (n - 1) // 2  # hub index in 0..n-1
        return (n - 1) + s2(h) + s2(n - 1 - h)
    if k == 2:
        return s2(m)
    return None


P("== B: exact minimum k-hop TC-spanners of the directed path (ILP), brute-force cross-check for m <= 7")
res_table = {}
for k in (2, 3, 4):
    mmax = {2: 22, 3: 16, 4: 12}[k]
    row = []
    for m in range(2, mmax + 1):
        val, E, st = ilp_spanner(m, k)
        if m <= 7:
            bf = brute_spanner(m, k)
            assert bf == val, (m, k, bf, val)
        if m <= 8:
            assert usable_k(twocnf(E), m, k)
        row.append((m, val, st))
        res_table[(k, m)] = val
    P(f"  k={k}: " + ", ".join(f"m={m}:{v}" + ("" if st == 0 else "?") for m, v, st in row))
P("  (brute force agreed for m <= 7; the ILP optima for m <= 8 were re-checked as UP_k-usable 2-CNFs)")

P("== C: k=2 against the midpoint construction and the lower bound with auxiliary variables (Thm 7.3)")
for m in (4, 6, 8, 10, 12, 14, 16, 18, 20, 22):
    lbv = ((m - 2) * math.log2((m - 2) / 2) - m) / 2 if m > 3 else 0
    P(f"  m={m}: ILP optimum (no aux) = {res_table[(2, m)]}; midpoint construction = {construct(m, 2)}; "
      f"m log2 m = {m * math.log2(m):.1f}; lower bound with aux and any width = {lbv:.1f}")
P(f"# done in {time.time() - t0:.1f}s")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out_lines) + "\n")
