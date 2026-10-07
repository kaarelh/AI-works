# Independent check of prop:zf:indeq(a): FOL |- IndEq(phi) <-> Ind(phi) for motives phi (FV subset {x}),
# including motives that bind y; tested on random finite L_A-structures (arbitrary 0,S,+,*).
# Also checks the universal-closure counterexample P := (x=0 or not x=y) in N (bounded) for IndEq.
import random, itertools

# terms: ('0',) ('v',name) ('S',t) ('+',t,u) ('*',t,u)
# formulas: ('eq',t,u) ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('all',v,f) ('ex',v,f)

def ev_t(t, M, env):
    k = t[0]
    if k == '0': return M['0']
    if k == 'v': return env[t[1]]
    if k == 'S': return M['S'][ev_t(t[1], M, env)]
    if k == '+': return M['+'][ev_t(t[1], M, env)][ev_t(t[2], M, env)]
    if k == '*': return M['*'][ev_t(t[1], M, env)][ev_t(t[2], M, env)]

def ev(f, M, env):
    k = f[0]
    if k == 'eq': return ev_t(f[1], M, env) == ev_t(f[2], M, env)
    if k == 'not': return not ev(f[1], M, env)
    if k == 'and': return ev(f[1], M, env) and ev(f[2], M, env)
    if k == 'or': return ev(f[1], M, env) or ev(f[2], M, env)
    if k == 'imp': return (not ev(f[1], M, env)) or ev(f[2], M, env)
    if k == 'all': return all(ev(f[2], M, {**env, f[1]: a}) for a in M['dom'])
    if k == 'ex': return any(ev(f[2], M, {**env, f[1]: a}) for a in M['dom'])

def subst_t(t, x, s):
    k = t[0]
    if k == 'v': return s if t[1] == x else t
    if k == '0': return t
    return (k,) + tuple(subst_t(a, x, s) for a in t[1:])

def subst(f, x, s):
    # s contains only the variable x (0 or Sx), so no capture is possible except by rebinding x
    k = f[0]
    if k == 'eq': return ('eq', subst_t(f[1], x, s), subst_t(f[2], x, s))
    if k == 'not': return ('not', subst(f[1], x, s))
    if k in ('and', 'or', 'imp'): return (k, subst(f[1], x, s), subst(f[2], x, s))
    if k in ('all', 'ex'):
        if f[1] == x: return f
        return (k, f[1], subst(f[2], x, s))

X = ('v', 'x'); Y = ('v', 'y'); Z0 = ('0',)
def Ind(phi):
    return ('imp', ('and', subst(phi, 'x', Z0), ('all', 'x', ('imp', phi, subst(phi, 'x', ('S', X))))), ('all', 'x', phi))
def IndEq(phi):
    return ('imp', ('and', ('all', 'x', ('imp', ('eq', X, Z0), phi)),
                    ('all', 'y', ('imp', ('all', 'x', ('imp', ('eq', X, Y), phi)),
                                         ('all', 'x', ('imp', ('eq', X, ('S', Y)), phi))))),
            ('all', 'x', phi))

def rterm(d, vars_):
    if d == 0 or random.random() < 0.3:
        return random.choice([Z0] + [('v', v) for v in vars_])
    k = random.choice(['S', '+', '*'])
    if k == 'S': return ('S', rterm(d - 1, vars_))
    return (k, rterm(d - 1, vars_), rterm(d - 1, vars_))

def rform(d, vars_):
    if d == 0 or random.random() < 0.25:
        return ('eq', rterm(2, vars_), rterm(2, vars_))
    k = random.choice(['not', 'and', 'or', 'imp', 'all', 'ex'])
    if k == 'not': return ('not', rform(d - 1, vars_))
    if k in ('and', 'or', 'imp'): return (k, rform(d - 1, vars_), rform(d - 1, vars_))
    v = random.choice(['y', 'x', 'w'])     # may bind y (the IndEq binder) or rebind x
    return (k, v, rform(d - 1, sorted(set(vars_) | {v})))

def rstruct(n):
    dom = list(range(n))
    return {'dom': dom, '0': random.choice(dom), 'S': [random.choice(dom) for _ in dom],
            '+': [[random.choice(dom) for _ in dom] for _ in dom],
            '*': [[random.choice(dom) for _ in dom] for _ in dom]}

random.seed(7)
dis = 0; falseInd = 0; withy = 0
for it in range(6000):
    phi = rform(3, ['x'])
    s = repr(phi)
    if "'y'" in s: withy += 1
    M = rstruct(random.randint(1, 4))
    a = ev(Ind(phi), M, {}); b = ev(IndEq(phi), M, {})
    if not a: falseInd += 1
    if a != b:
        dis += 1
print('pairs 6000, motives mentioning y:', withy, 'Ind false:', falseInd, 'disagreements:', dis)

# universal-closure counterexample, N truncated: evaluate on {0..K} with S,+ truncated is unsound; do it by hand-logic instead:
# IndEq(x=0 or not x=y) at outer y=1 in N: base true; step: hypothesis forall x(x=y' -> x=0 or x!=y') holds iff y'=0,
# conclusion forall x(x=Sy' -> x=0 or x!=y') always holds; conclusion forall x(x=0 or x!=1) fails at x=1.
def stepN(yp):
    hyp = (yp == 0) or (yp != yp)
    concl = True  # x = S y' != y'
    return (not hyp) or concl
print('step clause holds for y\'=0..50:', all(stepN(v) for v in range(51)))
print('conclusion forall x (x=0 or x!=1) at x=1:', (1 == 0) or (1 != 1))
