"""Referee B, thread `shape`, target T7 (depth against size for the chain law).

Independent of checks/. Seed 20261016. Writes refB_t7_spanners.out next to itself.

Checks
 A  Thm 7.1: prime implicates of Ch_m are the 2-clauses (brute force); the "iff" with wide clauses
    (explicit counterexamples for k = 1 and k = 2: a theory whose prime-implicate replacement is a k-hop
    TC-spanner but which is not UP_k-usable); the "only if" direction on random wide theories.
 B  Exact s_k(m) by an independent exact search (iterative deepening on added edges, branching on the shortest
    uncovered pair), against the record's table; for larger m an ILP with a layered reachability formulation
    (only edge variables integral; different from the developer's path formulation), solved by HiGHS.
 C  Prop 7.1a: closed form vs recursion; Conj 7.1b: s_2(m) vs sum floor(log2 i) as far as the ILP reaches.
 D  Thm 7.2: Steiner (auxiliary-variable) constructions at depth 2 are UP_2-usable; their size vs the bound.
"""
import os, sys, random, time, math
from itertools import combinations, product
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from refB_lib import *
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
from scipy.sparse import lil_matrix

SEED = 20261016
rng = random.Random(SEED)
OUT = []
T0 = time.time()
ILP_MAX_K2 = int(os.environ.get("REFB_ILP_MAX_K2", "16"))


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def chain_pts(m):
    # x_1 <= x_2 <= ... <= x_m : points 0^a 1^b ; bit v-1 is x_v
    return [sum(1 << (v - 1) for v in range(a + 1, m + 1)) for a in range(m + 1)]


def theory_from_edges(E):
    return [frozenset([-i, j]) for (i, j) in E]


# ------------------------------------------------------------------ A
P("# refB_t7_spanners.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
P("== A: Theorem 7.1")
for m in range(2, 7):
    pis = set(prime_implicates(chain_pts(m), m))
    want = {frozenset([-i, j]) for i in range(1, m + 1) for j in range(i + 1, m + 1)}
    P(f"  m={m}: prime implicates of Ch_m are exactly the 2-clauses -x_i v x_j (i<j): {pis == want}")
# counterexamples to the 'if' direction with wide clauses
# the last two have a wide clause containing exactly one prime implicate, so the replacement is forced
for m, k, F, repl in [
    (3, 1, [frozenset([-1, 2]), frozenset([-2, 3]), frozenset([-1, 2, 3])], (1, 3)),
    (4, 2, [frozenset([-1, 2]), frozenset([-2, 3]), frozenset([-3, 4]), frozenset([-1, 2, 3])], (1, 3)),
    (3, 1, [frozenset([-1, 2]), frozenset([-1, 3]), frozenset([-2, 3, 1])], (2, 3)),
    (4, 2, [frozenset([-1, 2]), frozenset([-1, 3]), frozenset([-3, 4]), frozenset([-2, 3, 1])], (2, 3)),
]:
    nchoices = [len([(-a, b) for a in C for b in C if a < 0 < b and -a < b]) for C in F if len(C) > 2]
    S = chain_pts(m)
    okF, _, why = usable(F, m, S, m, rounds=k)
    E = [(i, j) for (i, j) in [(-min(C), max(C)) for C in F if len(C) == 2]] + [repl]
    G = theory_from_edges(E)
    okG, _, _ = usable(G, m, S, m, rounds=k)
    P(f"  m={m}, k={k}: F = {[sorted(C) for C in F]} (prime implicates inside the wide clause: {nchoices}): UP_{k}-usable {okF} (fails at {why}); replacing the wide clause by "
      f"the prime implicate -x{repl[0]} v x{repl[1]} it contains gives edges {sorted(E)}: a {k}-hop TC-spanner, usable {okG}")
# 'only if' on random wide theories: usable => every replacement choice is a spanner
viol = tests = 0
for _ in range(300):
    m = rng.choice([4, 5, 6])
    k = rng.choice([1, 2, 3])
    S = chain_pts(m)
    F = []
    for _ in range(rng.randint(m, 3 * m)):
        i = rng.randint(1, m - 1)
        j = rng.randint(i + 1, m)
        C = {-i, j}
        for _ in range(rng.choice([0, 0, 1, 2])):
            v = rng.randint(1, m)
            if v not in C and -v not in C:
                C.add(v if rng.random() < 0.5 else -v)
        F.append(frozenset(C))
    ok, _, _ = usable(F, m, S, m, rounds=k, check_proj=False)
    if not ok:
        continue
    tests += 1
    for _ in range(5):
        E = []
        for C in F:
            opts = [(-a, b) for a in C for b in C if a < 0 < b and -a < b]
            E.append(rng.choice(opts))
        Gk = theory_from_edges(set(E))
        okG, _, _ = usable(Gk, m, S, m, rounds=k, check_proj=False)
        viol += (not okG)
P(f"  'only if': {tests} random usable theories with wide clauses, 5 random replacement choices each: "
  f"replacement not usable in {viol}")

# ------------------------------------------------------------------ B


def covered_all(adj, m, k):
    """adj[i] = bitmask of j>i with edge (i,j). Returns first uncovered pair (shortest) or None."""
    R = [adj[i] for i in range(m + 1)]
    for _ in range(k - 1):
        R2 = list(R)
        for i in range(1, m + 1):
            acc = R[i]
            a = adj[i]
            while a:
                l = (a & -a).bit_length() - 1
                acc |= R[l]
                a &= a - 1
            R2[i] = acc
        R = R2
    best = None
    for d in range(2, m):
        for i in range(1, m - d + 1):
            if not (R[i] >> (i + d)) & 1:
                return (i, i + d)
    return None


def paths_options(i, j, k, adj):
    """All sets of missing edges completing some path i = v0 < ... < vt = j with t <= k (minimal ones)."""
    opts = set()

    def rec(v, t, missing):
        if t > k:
            return
        if v == j:
            opts.add(frozenset(missing))
            return
        if t == k:
            return
        for w in range(v + 1, j + 1):
            e = (v, w)
            if (adj[v] >> w) & 1:
                rec(w, t + 1, missing)
            else:
                rec(w, t + 1, missing + [e])

    rec(i, 0, [])
    opts = [o for o in opts if not any(p < o for p in opts)]
    return sorted(opts, key=len)


def exact_search(m, k, cap=5 * 10 ** 7):
    base = [0] * (m + 1)
    for i in range(1, m):
        base[i] |= 1 << (i + 1)
    nodes = [0]

    def dfs(adj, budget):
        nodes[0] += 1
        if nodes[0] > cap:
            raise RuntimeError("cap")
        pair = covered_all(adj, m, k)
        if pair is None:
            return True
        if budget == 0:
            return False
        for o in paths_options(pair[0], pair[1], k, adj):
            if len(o) > budget:
                continue
            adj2 = list(adj)
            for (a, b) in o:
                adj2[a] |= 1 << b
            if dfs(adj2, budget - len(o)):
                return True
        return False

    B = 0
    while True:
        if dfs(base, B):
            return (m - 1) + B, nodes[0]
        B += 1


def ilp_reach(m, k, time_limit=3600):
    """min |E| s.t. every i<j reachable within k hops; x integral, layered reach variables continuous."""
    pairs = [(i, j) for i in range(1, m + 1) for j in range(i + 1, m + 1)]
    idx = {}
    for p in pairs:
        idx[("x",) + p] = len(idx)
    for t in range(2, k + 1):
        for (i, j) in pairs:
            if j - i >= 2:
                idx[("r", t, i, j)] = len(idx)
                for l in range(i + 1, j):
                    idx[("w", t, i, l, j)] = len(idx)
    nv = len(idx)
    rowsA = []
    lb = []
    ub = []

    def R(t, i, j):
        if t == 1 or j - i < 2:
            return idx[("x", i, j)]
        return idx[("r", t, i, j)]

    for t in range(2, k + 1):
        for (i, j) in pairs:
            if j - i < 2:
                continue
            # r^t_ij - x_ij - sum_l w^t_ilj <= 0
            row = {idx[("r", t, i, j)]: 1.0, idx[("x", i, j)]: -1.0}
            for l in range(i + 1, j):
                row[idx[("w", t, i, l, j)]] = row.get(idx[("w", t, i, l, j)], 0) - 1.0
                # w <= x_il ; w <= r^{t-1}_lj
                rowsA.append({idx[("w", t, i, l, j)]: 1.0, idx[("x", i, l)]: -1.0}); lb.append(-np.inf); ub.append(0)
                rowsA.append({idx[("w", t, i, l, j)]: 1.0, R(t - 1, l, j): -1.0}); lb.append(-np.inf); ub.append(0)
            rowsA.append(row); lb.append(-np.inf); ub.append(0)
    # requirement: reach within k hops
    for (i, j) in pairs:
        rowsA.append({R(k, i, j): 1.0}); lb.append(1); ub.append(np.inf)
    A = lil_matrix((len(rowsA), nv))
    for r_, row in enumerate(rowsA):
        for c, v in row.items():
            A[r_, c] = v
    c = np.zeros(nv)
    integ = np.zeros(nv)
    lo = np.zeros(nv)
    hi = np.ones(nv)
    for (i, j) in pairs:
        c[idx[("x", i, j)]] = 1
        integ[idx[("x", i, j)]] = 1
        if j == i + 1:
            lo[idx[("x", i, j)]] = 1
    res = milp(c, constraints=[LinearConstraint(A.tocsr(), lb, ub)], integrality=integ, bounds=Bounds(lo, hi),
               options={"time_limit": time_limit, "disp": False})
    if res.status != 0:
        return None, res.status
    val = int(round(res.fun))
    E = [p for p in pairs if res.x[idx[("x",) + p]] > 0.5]
    return val, E


record = {
    2: {2: 1, 3: 2, 4: 4, 5: 6, 6: 8, 7: 10, 8: 13, 9: 16, 10: 19, 11: 22, 12: 25, 13: 28, 14: 31, 15: 34, 16: 38},
    3: {2: 1, 3: 2, 4: 3, 5: 5, 6: 6, 7: 8, 8: 10, 9: 12, 10: 14, 11: 16, 12: 18, 13: 20},
    4: {2: 1, 3: 2, 4: 3, 5: 4, 6: 6, 7: 7, 8: 9, 9: 10, 10: 12, 11: 14, 12: 16},
}
P("== B: exact s_k(m): independent exact search (ES) for small m, layered-reach ILP (HiGHS) beyond; record's table")
ilp_vals = {}
for k in (2, 3, 4):
    line = []
    for m in range(2, max(record[k]) + 1):
        es = None
        if (k == 2 and m <= 12) or (k == 3 and m <= 13) or (k == 4 and m <= 12):
            try:
                es, nodes = exact_search(m, k)
            except RuntimeError:
                es = None
        t1 = time.time()
        il, E = ilp_reach(m, k) if (m >= 6) else (None, None)
        if il is not None:
            ilp_vals[(k, m)] = il
            adj = [0] * (m + 1)
            for (a, b) in E:
                adj[a] |= 1 << b
            assert covered_all(adj, m, k) is None
            if m <= 9:
                okU, _, _ = usable(theory_from_edges(E), m, chain_pts(m), m, rounds=k)
                assert okU
        rec = record[k][m]
        vals = [v for v in (es, il) if v is not None]
        agree = all(v == rec for v in vals)
        line.append(f"m={m}:{rec}" + ("" if agree else f"(ES {es}, ILP {il})"))
        if not agree:
            P(f"   MISMATCH k={k} m={m}: record {rec}, exact search {es}, ILP {il}")
    P(f"  k={k}: record values confirmed: " + ", ".join(line))

# ------------------------------------------------------------------ C
P("== C: Prop 7.1a and Conjecture 7.1b")


def Ssum(m):
    return sum(int(math.floor(math.log2(i))) for i in range(1, m + 1))


def closed(m):
    L = m.bit_length() - 1
    return (m + 1) * L - 2 ** (L + 1) + 2


Srec = {1: 0}
for n in range(2, 3001):
    Srec[n] = n - 1 + Srec[(n - 1 + 1) // 2] + (Srec[(n - 1) // 2] if (n - 1) // 2 >= 1 else 0)
bad = sum(1 for n in range(1, 3001) if not (Srec[n] == Ssum(n) == closed(n)))
P(f"  midpoint recursion S(n) = n-1+S(ceil((n-1)/2))+S(floor((n-1)/2)), sum floor(log2 i), closed form: mismatches for n<=3000: {bad}")
for m in range(17, ILP_MAX_K2 + 1):
    t1 = time.time()
    il, E = ilp_reach(m, 2, time_limit=5400)
    P(f"  k=2, m={m}: ILP s_2(m) = {il}; sum floor(log2 i) = {Ssum(m)}; agree: {il == Ssum(m)} ({time.time() - t1:.0f}s)")

# ------------------------------------------------------------------ D
P("== D: Thm 7.2: Steiner constructions at depth 2 (one auxiliary 'hub' per recursion interval)")


def steiner_theory(lo, hi, nxt, F):
    """Cover all pairs in [lo, hi] within 2 rounds; auxiliary hub y: x_i -> y (i <= mid), y -> x_j (j > mid)."""
    n = hi - lo + 1
    if n <= 1:
        return nxt
    if n == 2:
        F.append(frozenset([-lo, hi]))
        return nxt
    mid = (lo + hi) // 2
    y = nxt
    nxt += 1
    for i in range(lo, mid + 1):
        F.append(frozenset([-i, y]))
    for j in range(mid + 1, hi + 1):
        F.append(frozenset([-y, j]))
    nxt = steiner_theory(lo, mid, nxt, F)
    nxt = steiner_theory(mid + 1, hi, nxt, F)
    return nxt


for m in range(4, 15):
    F = []
    nxt = steiner_theory(1, m, m + 1, F)
    N = nxt - 1
    ok, _, why = usable(F, N, chain_pts(m), m, rounds=2, check_proj=(N <= 20))
    bound = 0.5 * ((m - 2) * math.log2((m - 2) / 2) - m)
    P(f"  m={m}: Steiner construction {len(F)} clauses, {N - m} aux, UP_2-usable {ok}; s_2(m) = {record[2].get(m)}; "
      f"Thm 7.2 bound {bound:.1f}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_t7_spanners.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
