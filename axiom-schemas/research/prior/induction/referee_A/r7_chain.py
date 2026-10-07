# R7: P7(d)/(e): longest chain of strictly increasing lggs built from GENUINE queries, starting from ind(phi0).
# Independent search; universes with a third variable z and with mul (absent from the author's universes).
import sys, time, itertools
from rcore import *
sys.setrecursionlimit(100000)
def canon(t):
    ren = {}
    def R(u):
        if isv(u):
            if u[1] not in ren: ren[u[1]] = ('?', 'v%d' % len(ren))
            return ren[u[1]]
        return (u[0],) + tuple(R(a) for a in u[1:])
    return R(t)
def terms_by_size(maxs, vs, funs):
    by = {1: [K(c) for c in ['0'] + vs]}
    for s in range(2, maxs + 1):
        out = []
        if 'S' in funs: out += [S_(t) for t in by[s - 1]]
        for f in [f for f in funs if f in ('add', 'mul')]:
            for s1 in range(1, s - 1):
                for a in by[s1]:
                    for b in by[s - 1 - s1]: out.append((f, a, b))
        by[s] = out
    return by
def eq_universe(maxm, vs, funs, preds=('eq',)):
    by = terms_by_size(maxm - 2, vs, funs); out = []
    for p in preds:
        for s1 in by:
            for s2 in by:
                if 1 + s1 + s2 <= maxm:
                    out += [(p, a, b) for a in by[s1] for b in by[s2]]
    return out
def tri(phi): return ('tri', phi, sb(phi, 'x', ZERO), sb(phi, 'x', S_(K('x'))))
def longest(phi0, U):
    tus = [tri(p) for p in U]
    memo = {}
    def rec(g):
        key = canon(g)
        if key in memo: return memo[key][0]
        best = (0, None)
        for t, p in zip(tus, U):
            if more_general_eq(g, t): continue
            g2 = au([g, t])
            l = rec(g2) + 1
            if l > best[0]: best = (l, p)
        memo[key] = best
        return best[0]
    L = rec(tri(phi0))
    g = tri(phi0); seq = []
    while memo[canon(g)][1] is not None:
        p = memo[canon(g)][1]; seq.append(p); g = au([g, tri(p)])
    return L, seq, len(memo)
def show(t):
    if isv(t): return t[1]
    if len(t) == 1: return t[0]
    return t[0] + '(' + ','.join(show(a) for a in t[1:]) + ')'
phi0 = ('eq', ('add', K('x'), ZERO), K('x'))
configs = [(int(a), b.split(','), c.split(','), d.split(',')) for a, b, c, d in (s.split(':') for s in sys.argv[1:])]
for maxm, vs, funs, preds in configs:
    t = time.time()
    U = eq_universe(maxm, vs, funs, preds) + [('lt', ZERO, ZERO)]
    U = [p for p in U if p != phi0]
    L, seq, ns = longest(phi0, U)
    print(f'motive size <= {maxm}, vars {vs}, funs {funs}, preds {preds}: |U| = {len(U)}; longest genuine chain from x+0=x = {L} '
          f'({ns} states, {time.time()-t:.0f}s)\n   witness: {[show(p) for p in seq]}', flush=True)
