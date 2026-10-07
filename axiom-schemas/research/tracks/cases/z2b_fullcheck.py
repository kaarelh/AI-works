# Track "cases", Part 2(e), cross-check of the reduced enumerator on the larger frames:
# full data-directed DT-degree enumeration (arity <= 3, stops at the first template not >= T*) on a few pairs of
# Coll and ReplJ, compared with the reduced enumerator and with (R)&(N).
import time
from multiprocessing import Pool
from st_core import *
from st_pool import pool_for
from st_enum import enumerate_dt_reduced, enumerate_covering

CASES = [('Coll', ('y=x', '¬x=A')), ('Coll', ('x∈A→y=A', 'Aw(w∈y↔w∈x)')), ('Coll', ('y=x', 'x∈y')), ('Coll', ('y=x', 'a∈b')),
         ('ReplJ', ('x∈z', '¬x=a')), ('ReplJ', ('Aw(w∈x→w∈z)', 'x=z')), ('ReplJ', ('¬x=a', 'x∈a')), ('ReplJ', ('z∈a', 'Ew(w∈x)'))]

def job(c):
    nm, keys = c
    P = pool_for(nm); T = SCHEMAS[nm]['T']; n = len(SCHEMAS[nm]['args'])
    bs = [P[k] for k in keys]; D = [instance(nm, b) for b in bs]
    t0 = time.time()
    full = enumerate_covering(D, 'DT', 3, T, stop_at_bad=True)
    t1 = time.time()
    red = enumerate_dt_reduced(D, T)
    return nm, keys, pred_R(bs), pred_N(bs, n), full[2] is None, full[0], red[2] is None, red[0], t1 - t0

if __name__ == '__main__':
    with Pool(4) as pool:
        for r in pool.imap_unordered(job, CASES):
            nm, keys, R, N, fa, fn, ra, rn, dt = r
            print('%-6s %-28s R=%-5s N=%-22s full-DT anchor=%-5s (%6d templates, %5.0fs)  reduced anchor=%-5s (%4d)  (R)&(N)=%s'
                  % (nm, keys, R, N, fa, fn, dt, ra, rn, R and all(N)), flush=True)
