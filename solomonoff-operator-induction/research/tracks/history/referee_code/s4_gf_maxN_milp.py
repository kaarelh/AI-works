"""s4 (referee, second report): exact max_G N(G) for Lemma 5.5 / Thm 5.4 at m = 4 (and m = 2, 3
as a cross-check), by mixed-integer programming with HiGHS (scipy.optimize.milp).

N(G) = #{(a,b) : a != b, G(a) + G(b) = ab} over G : GF(2^m) -> GF(2^m) (ordered pairs; total G
suffices since extending a partial G never lowers N).  c5 found exact maxima 8 (m=2) and 22 (m=3)
and a local-search value 56 for m = 4 (bound 2^m + 2^{3m/2} = 80).

Model: z[a][v] in {0,1} with sum_v z[a][v] = 1 (G(a) = v); s[a,b] in {0,1} for a < b, with
s[a,b] <= 1 - z[a][v] + z[b][v + ab] for every v (if the pair counts and G(a) = v then
G(b) = v + ab).  Maximise 2 * sum s.  Symmetry: G -> G + const preserves N (characteristic 2),
so we fix G(0) = 0.  The same polynomial basis as c5 is used (lexicographically least
irreducible polynomial of degree m).  Deterministic; seed recorded as 0.
For m = 4 HiGHS does not close the gap within the time limit (600 s); the incumbent is then only a
LOWER bound on max N, and the Jensen bound is computed from the best proven upper bound.
Output: s4_gf_maxN_milp.out.  Also reports the implied constant-free bound
E[L_F] >= log2(#triples / max N) of Thm 5.4(c)'s Jensen step.
"""
import itertools, time
from math import log2
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
from scipy.sparse import lil_matrix

SEED = 0


def irreducible(m):
    for p in range(1 << m, 1 << (m + 1)):
        # p has degree m; test irreducibility by trial division by all polys of degree 1..m//2
        ok = True
        for q in range(2, 1 << (m // 2 + 1)):
            if q.bit_length() - 1 < 1:
                continue
            # polynomial mod
            r = p
            dq = q.bit_length() - 1
            while r.bit_length() - 1 >= dq:
                r ^= q << (r.bit_length() - 1 - dq)
            if r == 0:
                ok = False
                break
        if ok:
            return p
    raise ValueError


def gf_mul(a, b, m, poly):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> m:
            a ^= poly
    return r


def max_N(m, time_limit=600):
    q = 1 << m
    poly = irreducible(m)
    nz = q * q
    pairs = [(a, b) for a in range(q) for b in range(a + 1, q)]
    ns = len(pairs)
    nvar = nz + ns
    zi = lambda a, v: a * q + v
    rows = []
    lo, hi = [], []
    A = lil_matrix((q + ns * q, nvar))
    r = 0
    for a in range(q):
        for v in range(q):
            A[r, zi(a, v)] = 1
        lo.append(1); hi.append(1); r += 1
    for k, (a, b) in enumerate(pairs):
        p = gf_mul(a, b, m, poly)
        for v in range(q):
            # s + z[a][v] - z[b][v^p] <= 1
            A[r, nz + k] += 1
            A[r, zi(a, v)] += 1
            A[r, zi(b, v ^ p)] -= 1
            lo.append(-np.inf); hi.append(1); r += 1
    c = np.zeros(nvar)
    c[nz:] = -1.0
    lb = np.zeros(nvar); ub = np.ones(nvar)
    ub[zi(0, 0)] = 1; lb[zi(0, 0)] = 1  # G(0) = 0
    t0 = time.time()
    res = milp(c, constraints=LinearConstraint(A.tocsr(), lo, hi), integrality=np.ones(nvar),
               bounds=Bounds(lb, ub), options={"time_limit": time_limit, "disp": False})
    dt = time.time() - t0
    G = None
    if res.x is not None:
        z = np.round(res.x[:nz]).reshape(q, q)
        G = [int(np.argmax(z[a])) for a in range(q)]
        # recount independently
        N = sum(1 for a in range(q) for b in range(q) if a != b and (G[a] ^ G[b]) == gf_mul(a, b, m, poly))
    else:
        N = None
    bound = getattr(res, "mip_dual_bound", None)
    return res, N, G, dt, poly, bound


print("m  status                         max N (recounted)  dual bound on N   bound 2^m+2^(3m/2)  E[L_F] >= log2(#triples/maxN)  time")
for m in (2, 3, 4):
    res, N, G, dt, poly, bound = max_N(m)
    q = 1 << m
    triples = q * (q - 1) * q
    db = (2 * -bound) if bound is not None else float("nan")
    optimal = res.status == 0
    analytic = 2**m + 2**(1.5*m)
    # Jensen bound needs an UPPER bound on max N: the exact optimum if proved, else min(analytic, dual bound)
    upper = N if optimal else min(analytic, db)
    jl = log2(triples / upper)
    tag = "exact" if optimal else "from upper bound"
    print(f"{m}  {res.message[:30]:30s} {N!s:>8}{'' if optimal else ' (incumbent)'}  {db:10.2f}       {analytic:10.1f}        {jl:10.3f} ({tag})        {dt:6.1f}s")
    if m == 4 and G is not None:
        print(f"   m=4 optimiser G (poly {bin(poly)}): {G}")
