# Referee check of B6: (a) IndEq(phi) <-> Ind(phi) is FOL-valid for FV(phi) within {x}: tested in random FINITE
# structures (arbitrary interpretations of 0, S, +, *), with motives containing quantifiers over y and x
# (inner rebinding of x, bound y that meets the IndEq binder y). (b) lgg of IndEq data = IndEq(lgg motives);
# root-diverse pairs give IndEq(P) exactly.
import random, itertools
from rb_core import *

rng = random.Random(11)
def rterm(d, vs):
    if d == 0 or rng.random() < 0.3: return rng.choice([ZERO] + vs)
    r = rng.random()
    if r < 0.4: return S(rterm(d - 1, vs))
    if r < 0.7: return ADD(rterm(d - 1, vs), rterm(d - 1, vs))
    return MUL(rterm(d - 1, vs), rterm(d - 1, vs))
def rform(d, vs):
    if d == 0 or rng.random() < 0.3: return EQ(rterm(2, vs), rterm(2, vs))
    r = rng.random()
    if r < 0.15: return NEG(rform(d - 1, vs))
    if r < 0.35:
        v = rng.choice([X, Y])
        return rng.choice([ALL, EX])(v, rform(d - 1, sorted(set(vs) | {v})))
    return rng.choice([AND, OR, IMP])(rform(d - 1, vs), rform(d - 1, vs))

def ev_t(t, M, env):
    if t == ZERO: return M['0']
    if len(t) == 1: return env[t]
    if t[0] == 'S': return M['S'][ev_t(t[1], M, env)]
    a, b = ev_t(t[1], M, env), ev_t(t[2], M, env)
    return M['+'][a][b] if t[0] == '+' else M['*'][a][b]
def ev(f, M, env):
    h = f[0]
    if h == '=': return ev_t(f[1], M, env) == ev_t(f[2], M, env)
    if h == '~': return not ev(f[1], M, env)
    if h == '&': return ev(f[1], M, env) and ev(f[2], M, env)
    if h == '|': return ev(f[1], M, env) or ev(f[2], M, env)
    if h == '>': return (not ev(f[1], M, env)) or ev(f[2], M, env)
    if h == 'A': return all(ev(f[2], M, {**env, f[1]: d}) for d in range(M['n']))
    if h == 'E': return any(ev(f[2], M, {**env, f[1]: d}) for d in range(M['n']))
    raise ValueError(h)
def rstruct():
    n = rng.randint(1, 4)
    return {'n': n, '0': rng.randrange(n), 'S': [rng.randrange(n) for _ in range(n)],
            '+': [[rng.randrange(n) for _ in range(n)] for _ in range(n)],
            '*': [[rng.randrange(n) for _ in range(n)] for _ in range(n)]}

tested = 0; disagree = []; with_y = 0; ind_false = 0
for _ in range(6000):
    phi = rform(3, [X])
    if not fv(phi) <= {X}: continue
    a, b = IND(phi), INDEQ(phi)
    if 'y' in str(phi): with_y += 1
    for _ in range(5):
        M = rstruct()
        va, vb = ev(a, M, {}), ev(b, M, {})
        tested += 1
        if not va: ind_false += 1
        if va != vb: disagree.append((show(phi), M))
print('B6(a): %d (motive, finite structure) pairs, %d motives mention y; Ind false in %d of them; '
      'disagreements Ind vs IndEq: %d' % (tested, with_y, ind_false, len(disagree)))
for d in disagree[:5]: print('   ', d)

# (b) lgg of IndEq data
P = mv('P')
T = INDEQ(P)
ok_inst = True; ok_exact = True; npairs = 0
for _ in range(2000):
    k = rng.randint(2, 4)
    phis = [rform(3, [X]) for _ in range(k)]
    phis = [p for p in phis if fv(p) <= {X}]
    if len(phis) < 2: continue
    L = antiunify([INDEQ(p) for p in phis])
    ok_inst &= inst_of(L, T)
    if len({p[0] for p in phis}) > 1:
        npairs += 1; ok_exact &= equiv(L, T)
    else:
        ok_exact &= not equiv(L, T)
print('B6(b): lgg of random IndEq data is an instance of IndEq(P): %s; equals IndEq(P) iff motive roots differ '
      '(%d root-diverse sets): %s' % (ok_inst, npairs, ok_exact))
