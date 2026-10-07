# Track "cases", Part 2(g): sample complexity of the DT-degree / pattern-lgg learner on ZF schemas.
# Exact failure probability after N i.i.d. bodies (Theorem G):
#   P[no anchor] = sum over (F, I) != (*, {}) of (-1)^{[F != *] + |I| + 1} mu(C_{F,I})^N,
#   C_{F,I} = { phi : (F = * or root(phi) = F) and no argument in I is free in phi }.
# Compared with Monte Carlo using the pattern lgg (anchor <=> pattern lgg == T*), and with the union bound
#   sum_f p_f^N + sum_i (1 - q_i)^N.
import sys, itertools, random
from st_core import *
from st_pool import pool_for

def exact_fail(bodies, weights, n, N):
    roots = sorted({b[0] for b in bodies})
    tot = 0.0
    for F in ['*'] + roots:
        for r in range(0, n + 1):
            for I in itertools.combinations(range(n), r):
                if F == '*' and not I: continue
                mass = sum(w for b, w in zip(bodies, weights)
                           if (F == '*' or b[0] == F) and not (holes(b) & set(I)))
                sign = (-1) ** ((F != '*') + len(I) + 1)
                tot += sign * mass ** N
    return tot

def union_bound(bodies, weights, n, N):
    roots = {b[0] for b in bodies}
    s = sum(sum(w for b, w in zip(bodies, weights) if b[0] == f) ** N for f in roots)
    s += sum((1 - sum(w for b, w in zip(bodies, weights) if i in holes(b))) ** N for i in range(n))
    return s

rng = random.Random(3)
TR = 3000
for nm in ('Sep', 'EInd', 'Coll', 'ReplS', 'ReplJ'):
    P = pool_for(nm); T = SCHEMAS[nm]['T']; n = len(SCHEMAS[nm]['args'])
    bodies = list(P.values())
    for lawname, weights in (('uniform', [1 / len(bodies)] * len(bodies)),
                             ('skewed', None)):
        if weights is None:
            # atoms in, eq four times as likely as the rest
            raw = [4.0 if b[0] in ('in', 'eq') else 1.0 for b in bodies]
            weights = [x / sum(raw) for x in raw]
        print('%-6s law %-8s' % (nm, lawname), end='')
        rows = []
        for N in (2, 3, 4, 6, 8, 12):
            ex = exact_fail(bodies, weights, n, N)
            fails = 0
            for _ in range(TR):
                D = rng.choices(bodies, weights, k=N)
                L = pattern_lgg([instance(nm, b) for b in D])
                fails += not equiv(L, T)
            rows.append('N=%d exact %.4f MC %.4f ub %.4f' % (N, ex, fails / TR, union_bound(bodies, weights, n, N)))
        Nst = next(N for N in range(1, 400) if exact_fail(bodies, weights, n, N) <= 0.01)
        print(' smallest N with P[fail]<=0.01: %d' % Nst)
        for r in rows: print('        ' + r)
