# Referee check of Thm G (exact failure probability for the ZF pattern learners) with own pool, own
# inclusion-exclusion code and Monte Carlo with the own pattern lgg (r3_anchor.pattern_lgg).
import sys, itertools, random, math
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/cases/referee_code')
from zf_lib import *
from r3_anchor import pattern_lgg, lpat_equiv_target, pool

def exact(P, w, n, N):
    roots = sorted({root(b) for b in P})
    tot = 0.0
    for F in [None] + roots:
        for r in range(0, n + 1):
            for I in itertools.combinations(range(n), r):
                if F is None and not I: continue
                mu = sum(wi for b, wi in zip(P, w) if (F is None or root(b) == F) and not any(uses(b, i) for i in I))
                sign = (-1) ** ((F is not None) + len(I) + 1)
                tot += sign * mu ** N
    return tot

rng = random.Random(99)
for sc in SCHEMAS:
    n = SCHEMAS[sc][1]
    P = pool(n)
    for law in ('uniform', 'skewed'):
        w = [1.0] * len(P) if law == 'uniform' else [3.0 if b[0] in ('in', 'eq') else 1.0 for b in P]
        s = sum(w); w = [x / s for x in w]
        line = []
        for N in (2, 4, 6, 8):
            TR = 1500
            fail = 0
            for _ in range(TR):
                bodies = rng.choices(P, w, k=N)
                L, _ = pattern_lgg([to_db(instance(sc, b)) for b in bodies])
                fail += not lpat_equiv_target(sc, L)
            e = exact(P, w, n, N)
            line.append('N=%d ex %.4f mc %.4f' % (N, e, fail / TR))
        print('%-6s %-8s %s' % (sc, law, ' | '.join(line)))
