# C5: the raw second-order learner and the Sub-encoded first-order learner have the same anchors.
# For every pair (and every triple) of pool motives: first-order lgg of the Sub-encoded instances
# (paper's T1-code, x a constant) recovers the Sub-induction schema  iff  (R) and (N).
import itertools, sys
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, canon as fo_canon
from so_core import *
from so_pool import *

NM = ['x', 'y', 'u', 'w']
def named(m, depth=1):
    h = m[0]
    if h == 'h': return ('x',)
    if h == 'v': return (NM[depth - 1 - m[1]],)
    if h == '0': return ('0',)
    if h in BINDERS: return (h, (NM[depth],), named(m[1], depth + 1))
    return (h,) + tuple(named(k, depth) for k in kids(m))
def fo_sub(t, v, r):
    if t == v: return r
    if len(t) == 1: return t
    if t[0] in BINDERS and t[1] == v: return t
    return (t[0],) + tuple(fo_sub(a, v, r) for a in t[1:])
x = ('x',); z = ('0',)
def sub_step(m):
    phi = named(m)
    a = fo_sub(phi, x, z); b = fo_sub(phi, x, ('S', x))
    return ('st', ('Sub', phi, x, z, a), ('Sub', phi, x, ('S', x), b),
            ('imp', ('and', a, ('all', x, ('imp', phi, b))), ('all', x, phi)))
P, A, B = ('?', 'P'), ('?', 'A'), ('?', 'B')
TARGET = ('st', ('Sub', P, x, z, A), ('Sub', P, x, ('S', x), B),
          ('imp', ('and', A, ('all', x, ('imp', P, B))), ('all', x, P)))
for k in (2, 3):
    agree = tot = rec = 0
    for combo in itertools.combinations(NAME_LIST := list(POOL), k):
        ms = [POOL[c] for c in combo]
        L = lgg_list([sub_step(m) for m in ms])
        recovered = fo_canon(L) == fo_canon(TARGET)
        pred = pred_R(ms) and pred_N(ms)
        agree += (recovered == pred); tot += 1; rec += recovered
    print('%d-subsets of the pool: %d; Sub-lgg recovers the schema: %d; agreement with (R)&(N): %d/%d'
          % (k, tot, rec, agree, tot))
