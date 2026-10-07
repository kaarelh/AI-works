# Track "cases", revision (referee F4 / missing item 2): the DT-degree half of Prop A2' computed, and SO-degree
# non-anchors for formulas with binders.  PA language, de Bruijn binders, closed-term data.
# Prediction (Prop A2'): in DT-degree, D is an anchor iff (R) (one variable), iff (R_1),(R_2),(D_12) (two).
# Method: dt_search.search (single-group templates; arguments: bound variables in scope and closed terms
# 0, S0; group size <= 3; arity <= 2 (<= 1 for groups of size 3)); a pair is classed "non-anchor" iff some
# covering template misses one of the probe instances.
import sys, itertools, time
from st_core import V, covers, kids, BINDERS

def pp(t, d=0):
    h = t[0]
    if h == 'v': return 'y%d' % (d - 1 - t[1]) if d - 1 - t[1] >= 0 else '#%d' % t[1]
    if h == 'M': return t[1] + '(' + ','.join(pp(a, d) for a in t[2:]) + ')'
    if h == '0': return '0'
    if h == 'S': return 'S' + pp(t[1], d)
    if h in ('add', 'mul'): return '(' + pp(t[1], d) + ('+' if h == 'add' else '*') + pp(t[2], d) + ')'
    if h == 'eq': return pp(t[1], d) + '=' + pp(t[2], d)
    if h in ('imp', 'and'): return '(' + pp(t[1], d) + (' -> ' if h == 'imp' else ' & ') + pp(t[2], d) + ')'
    if h in BINDERS: return {'all': 'A', 'ex': 'E', 'exu': 'E!'}[h] + 'y%d.' % d + pp(t[1], d + 1)
    return str(t)
from dt_search import search

Z = ('0',)
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def mul(a, b): return ('mul', a, b)
def eq(a, b): return ('eq', a, b)
def IMP(f, g): return ('imp', f, g)
def AND(f, g): return ('and', f, g)
def ALL(f): return ('all', f)
def EX(f): return ('ex', f)
XS = [('X0',), ('X1',)]   # placeholders for the free variables

def plug(phi, ts):
    if phi in XS: return ts[XS.index(phi)]      # closed terms: no shifting needed
    if phi[0] == 'v' or len(phi) == 1: return phi
    return (phi[0],) + tuple(plug(c, ts) for c in phi[1:])

x, y = XS
PHIS = [
    ('x+0=x', eq(add(x, Z), x), 1),
    ('Ay(x+y=y+x)', ALL(eq(add(x, V(0)), add(V(0), x))), 1),
    ('Ay(y=x -> x=y) & x=x', AND(ALL(IMP(eq(V(0), x), eq(x, V(0)))), eq(x, x)), 1),
    ('Ey(y=Sx)', EX(eq(V(0), S(x))), 1),
    ('x+y=y+x', eq(add(x, y), add(y, x)), 2),
]
POOL1 = [Z, S(Z), S(S(Z)), add(Z, Z), add(Z, S(Z)), mul(S(Z), Z), S(add(Z, Z))]
PROBES1 = [Z, S(Z), S(S(Z)), S(S(S(Z))), add(Z, Z), add(S(Z), Z), mul(Z, Z), mul(S(Z), S(Z)), S(mul(Z, Z))]
POOL2 = [(Z, S(Z)), (S(Z), Z), (Z, Z), (S(Z), S(Z)), (add(Z, Z), Z), (S(Z), add(Z, Z))]
PROBES2 = [(a, b) for a in (Z, S(Z), add(Z, Z), mul(Z, Z)) for b in (Z, S(Z), S(S(Z)), add(Z, S(Z)))]
CLOSED_ARGS = [Z, S(Z)]

def R(ts, i): return len({t[i][0] for t in ts}) >= 2
def Dd(ts, i, j): return any(t[i] != t[j] for t in ts)

t0 = time.time()
for name, phi, k in PHIS:
    pool = [(t,) for t in POOL1] if k == 1 else POOL2
    probes = [plug(phi, p) for p in ([(t,) for t in PROBES1] if k == 1 else PROBES2)]
    for degree in ('DT', 'SO'):
        agree = tot = anchors = 0
        ncov_tot = 0
        example = None
        for tA, tB in itertools.combinations(pool, 2):
            D = [plug(phi, tA), plug(phi, tB)]
            pred = all(R([tA, tB], i) for i in range(k)) and all(Dd([tA, tB], i, j) for i in range(k) for j in range(i + 1, k))
            ncov, wit = search(D, probes, CLOSED_ARGS, gmax=3, amax=2, degree=degree)
            ncov_tot += ncov
            got = not wit
            anchors += got
            tot += 1
            if degree == 'DT': agree += got == pred
            if degree == 'SO' and pred and not got and example is None:
                example = (tA, tB, wit[0])
        if degree == 'DT':
            print('%-24s DT: pairs %3d  anchors %3d  anchor <=> prediction on %3d/%3d  (covering templates seen %d)'
                  % (name, tot, anchors, agree, tot, ncov_tot))
        else:
            npred = sum(1 for tA, tB in itertools.combinations(pool, 2)
                        if all(R([tA, tB], i) for i in range(k)) and all(Dd([tA, tB], i, j) for i in range(k) for j in range(i + 1, k)))
            print('%-24s SO: pairs %3d  anchors %3d  (pairs satisfying the DT prediction: %d)' % (name, tot, anchors, npred))
            if example:
                tA, tB, (T, q) = example
                print('      SO non-anchor with the DT events: data terms %s, %s; template %s misses %s'
                      % ([pp(u) for u in tA], [pp(u) for u in tB], pp(T), pp(q)))
print('time %.1fs' % (time.time() - t0))
