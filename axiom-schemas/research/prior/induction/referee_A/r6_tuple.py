# R6: P0 (tuple reduction) on random schemas with repeated metavariables; P7(b) value; P7(c) tightness
# construction for random starting motives (independent implementation of the one-symbol chain).
import random
from rcore import *
r = random.Random(31)
SIGF = {'f': 2, 'g': 1, 'h': 3, 'a': 0, 'b': 0, 'c': 0}
def rgt(d):
    if d == 0 or r.random() < .3: return K(r.choice('abc'))
    f = r.choice(['f', 'g', 'h'])
    return (f,) + tuple(rgt(d - 1) for _ in range(SIGF[f]))
def rschema(d, mvs):
    if d == 0 or r.random() < .35:
        return ('?', r.choice(mvs)) if r.random() < .6 else K(r.choice('abc'))
    f = r.choice(['f', 'g', 'h'])
    return (f,) + tuple(rschema(d - 1, mvs) for _ in range(SIGF[f]))
def apply(t, th):
    if isv(t): return th[t[1]]
    return (t[0],) + tuple(apply(a, th) for a in t[1:])
bad = 0; badord = 0; tot = 0
for _ in range(4000):
    mvs = ['A', 'B', 'C'][:r.randint(1, 3)]
    sig = rschema(4, mvs)
    vs = tvars(sig)
    if not vs: continue
    ths = [{v: rgt(r.randint(0, 3)) for v in vs} for _ in range(r.randint(1, 4))]
    L = au([apply(sig, th) for th in ths])
    T = au([('tup',) + tuple(th[v] for v in vs) for th in ths])
    eta = {v: T[i + 1] for i, v in enumerate(vs)}
    tot += 1
    if not variant(L, apply(sig, eta)): bad += 1
    # order: compare with a second data set
    ths2 = ths + [{v: rgt(r.randint(0, 3)) for v in vs}]
    L2 = au([apply(sig, th) for th in ths2]); T2 = au([('tup',) + tuple(th[v] for v in vs) for th in ths2])
    if variant(L, L2) != variant(T, T2) or more_general_eq(L2, L) != more_general_eq(T2, T): badord += 1
print(f'P0: {tot} random schemas: lgg(sigma theta_j) != sigma(lgg tuples): {bad}; order mismatches: {badord}')

# P7(c): independent one-symbol chain, forced escalations from ind(phi0) with fresh object-variable constants
fresh_ctr = [0]
def fresh(): fresh_ctr[0] += 1; return K('c%d' % fresh_ctr[0])
def positions(t, p=()):
    yield p, t
    if not isv(t):
        for i, a in enumerate(t[1:], 1): yield from positions(a, p + (i,))
def repl(t, p, new):
    if not p: return new
    return (t[0],) + tuple(repl(a, p[1:], new) if i == p[0] else a for i, a in enumerate(t[1:], 1))
def one_step(T, k):
    # leaves first (any non-variable leaf), then nodes whose children are all variables
    for p, s in positions(T):
        if p and not isv(s) and len(s) == 1: return repl(T, p, ('?', 'g%d' % k))
    for p, s in positions(T):
        if p and not isv(s) and all(isv(a) for a in s[1:]): return repl(T, p, ('?', 'g%d' % k))
    return None
def ground(g):
    th = {}
    def ap(t):
        if isv(t):
            if t[1] not in th: th[t[1]] = fresh()
            return th[t[1]]
        return (t[0],) + tuple(ap(a) for a in t[1:])
    return ap(g)
def nfree(f, v='x'):
    if is_ov(f): return int(f[0] == v)
    if len(f) == 1: return 0
    if f[0] in QN and f[1][0] == v: return 0
    return sum(nfree(a, v) for a in f[1:])
mism = 0
for trial in range(60):
    phi0 = rform(r, r.randint(0, 3), ['x', 'y'])
    m, k = tsize(phi0), nfree(phi0)
    T = ('tri', phi0, sb(phi0, 'x', ZERO), sb(phi0, 'x', S_(K('x'))))
    data = [ind(phi0)]; esc = 0; step = 0
    while True:
        step += 1
        g = one_step(T, step)
        if g is None: break
        q3 = ground(g); q = ind_raw(q3[1], K('x'), q3[2], q3[3])
        assert more_general_eq(SIG_X, q)
        if not more_general_eq(au(data), q): esc += 1
        data.append(q); T = g
    final = variant(au(data), SIG_X)
    if esc != 3 * m + k or not final: mism += 1
    # paper bound
    pb = rank(ind(phi0)) - rank(SIG_X)
    assert pb == 8 * m + 2 * k - 5
print(f'P7(c): 60 random phi0: escalations forced != 3m+k (or final lgg != sigma_x): {mism}')
