# R1: independent test of P1/P2/P3-merge claims on a richer random motive law (mul, or, iff, ex, 6 variables,
# shadowing binders of the induction variable), sets of size 1..6.
import random, sys
from rcore import *
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, canon
r = random.Random(2026)
VS = ['x', 'y', 'z', 'n']
def cond_fixed(ph):
    return len({p[0] for p in ph}) > 1 and any('x' in fv(p) for p in ph)
def cond_meta(pv):
    return (len({p[0] for p, v in pv}) > 1 and any(v in fv(p) for p, v in pv) and len({v for p, v in pv}) > 1)
def motive(r):
    # bias toward few roots so that non-anchors are frequent; sometimes force vacuity / shadowing
    u = r.random()
    if u < 0.25:   # same-root family
        return ('eq', rterm(r, 2, VS), rterm(r, 2, VS))
    if u < 0.35:   # x only bound (vacuous in x, but x occurs)
        return (r.choice(['all', 'ex']), K('x'), rform(r, 2, VS))
    if u < 0.45:   # closed / x-free
        return rform(r, 2, ['y', 'z'])
    return rform(r, 3, VS)
mm = 0; tot = 0; anchors = 0; t1mm = 0
for trial in range(40000):
    k = r.randint(1, 6)
    ph = [motive(r) for _ in range(k)]
    D = [ind(p) for p in ph]
    L = au(D)
    assert more_general_eq(SIG_X, L)          # lgg is below sigma_x
    ok = variant(L, SIG_X)
    tot += 1; anchors += ok
    if ok != cond_fixed(ph): mm += 1; print('MISMATCH x-fixed', ph)
    # cross-check with the T1 implementation
    if canon(lgg_list(D)) != canon(L): t1mm += 1
print(f'x fixed: {tot} random sets (size 1..6): mismatches with (roots differ & some x free) = {mm}; anchors = {anchors}; T1-vs-referee lgg disagreements = {t1mm}')
mm = 0; tot = 0
for trial in range(40000):
    k = r.randint(1, 6)
    pv = []
    for _ in range(k):
        v = r.choice(VS if r.random() < 0.5 else ['x'])
        p = motive(r)
        pv.append((p, v))
    D = [ind(p, v) for p, v in pv]
    if not all(subs_true(s) for s in D):
        continue  # capture case (t free for v always holds for 0 and Sv, so this never triggers)
    L = au(D)
    assert more_general_eq(SIG_M, L)
    ok = variant(L, SIG_M); tot += 1
    if ok != cond_meta(pv): mm += 1; print('MISMATCH meta', pv)
print(f'X meta: {tot} random sets: mismatches with (roots differ & some own-variable free & variables differ) = {mm}')
# If all records share one variable v != x, lgg is the v-fixed rule
p1, p2 = ('eq', ('add', K('y'), ZERO), K('y')), ('not', ('eq', S_(K('y')), ZERO))
L = au([ind(p1, 'y'), ind(p2, 'y')])
print('two y-inductions, lgg == y-fixed rule:', variant(L, ind_raw(('?','P'), K('y'), ('?','A'), ('?','B'))))
# Merge claim (P3): top-level columns P,A,B merge iff all motives vacuous; deeper merges occur in non-anchors
L = au([ind(('eq', ('add', K('x'), ZERO), K('y'))), ind(('eq', ('add', ZERO, ZERO), K('x')))])
print('same-root pair lgg (shows deeper sharing between P and A sub-columns):', L[1])
