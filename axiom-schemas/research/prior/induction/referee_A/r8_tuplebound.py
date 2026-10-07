# R8: brute-force check of the tuple-gap bound P7(b) on small schemas with repeated metavariables:
# longest strict lgg chain from one example (queries = all instances with theta(X) of size <= 4) vs
# tuple bound sum|theta0 x| - |vars| and the paper bound mu(s0)-mu(sigma).
import itertools, random
from rcore import *
def canon(t):
    ren = {}
    def R(u):
        if isv(u):
            if u[1] not in ren: ren[u[1]] = ('?', 'v%d' % len(ren))
            return ren[u[1]]
        return (u[0],) + tuple(R(a) for a in u[1:])
    return R(t)
def ground(maxs):
    by = {1: [K('a'), K('b'), K('c')]}
    for s in range(2, maxs + 1):
        out = [('h', t) for t in by[s - 1]]
        for s1 in range(1, s - 1):
            out += [('k', p, q) for p in by[s1] for q in by[s - 1 - s1]]
        by[s] = out
    return [t for s in by for t in by[s]]
G = ground(4)
def apply(t, th):
    if isv(t): return th[t[1]]
    return (t[0],) + tuple(apply(a, th) for a in t[1:])
schemas = [('f', ('?', 'X'), ('g', ('?', 'X'))), ('f', ('?', 'X'), ('?', 'X'), ('?', 'Y')), ('f', ('g', ('?', 'X')), ('?', 'Y'), ('?', 'X'))]
r = random.Random(4)
for sig in schemas:
    vs = tvars(sig)
    insts = [apply(sig, dict(zip(vs, combo))) for combo in itertools.product(G, repeat=len(vs))] if len(vs) == 1 else \
            [apply(sig, dict(zip(vs, combo))) for combo in itertools.product(G[:40], repeat=len(vs))]
    for trial in range(3):
        th0 = {v: r.choice(G) for v in vs}
        s0 = apply(sig, th0)
        memo = {}
        def rec(g):
            key = canon(g)
            if key in memo: return memo[key]
            best = 0
            for q in insts:
                if not more_general_eq(g, q): best = max(best, 1 + rec(au([g, q])))
            memo[key] = best
            return best
        L = rec(s0)
        tb = sum(tsize(th0[v]) for v in vs)
        pb = rank(s0) - rank(sig)
        print(f'sigma={sig}  theta0={th0}: longest chain={L}  tuple bound={tb}  paper bound={pb}  ok={L <= tb <= pb}')
