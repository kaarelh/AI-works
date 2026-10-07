import sys, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/cases')
from st_core import *
from st_pool import *
from st_enum import enumerate_dt_reduced, enumerate_covering
for nm in SCHEMAS:
    T = SCHEMAS[nm]['T']
    P = pool_for(nm); ks = list(P)
    for i, j in [(0, 4), (0, 1), (13, 14)]:
        b1, b2 = P[ks[i]], P[ks[j]]
        D = [instance(nm, b1), instance(nm, b2)]
        t0 = time.time()
        r = enumerate_dt_reduced(D, T)
        print(nm, ks[i], ks[j], 'R', pred_R([b1,b2]), 'N', pred_N([b1,b2], len(SCHEMAS[nm]['args'])), 'reduced', r[:2], pp(r[2]) if r[2] else None, '%.2fs' % (time.time()-t0))
