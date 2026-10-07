# Track "cases", Part 1 (Q1): learning the instance schema phi(z1..zk) of a fixed formula phi from
# instances phi(t1..tk) at closed terms, with the paper's T1 lgg code (Plotkin/Reynolds anti-unification).
#
# Checks:
#  (1) anchor <=> (R) & (D) on all pairs / triples from a pool of closed terms, for several phi
#      (x occurring several times; two variables; phi containing closed subterms that also occur as
#      data terms; a bound occurrence of the same variable name; a vacuous phi);
#  (2) instance-set injectivity used in the anchor proof (two generic instances have lgg = sigma);
#  (3) open-term data with a "closed" guard (most specific guard, lem:setting:guard);
#  (4) coupon-collector rates: exact failure probability vs Monte Carlo (with lgg) vs the bound of
#      thm:imitation:coupon.
import sys, itertools, random, math
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, match, canon, show, ground_terms, vars_of

Z = ('0',)
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def mul(a, b): return ('mul', a, b)
def eq(a, b): return ('eq', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def ALL(v, f): return ('all', v, f)
def MV(n): return ('?', n)
X, Y = ('x',), ('y',)

def subst_free(f, v, t):
    """phi[t/v] for an object variable constant v, stopping at binders of v (named encoding)."""
    if f == v: return t
    if len(f) == 1 or f[0] == '?': return f
    if f[0] in ('all', 'ex') and f[1] == v: return f
    return (f[0],) + tuple(subst_free(a, v, t) for a in f[1:])

def inst(phi, vs, ts):
    out = phi
    for v, t in zip(vs, ts): out = subst_free(out, v, t)
    return out

def schema(phi, vs):
    return inst(phi, vs, [MV('z%d' % i) for i in range(len(vs))])

def occurs_free(f, v):
    if f == v: return True
    if len(f) == 1 or f[0] == '?': return False
    if f[0] in ('all', 'ex') and f[1] == v: return False
    return any(occurs_free(a, v) for a in f[1:])

def equiv(a, b):
    return match(a, b) is not None and match(b, a) is not None

def pred_R(tuples, i): return len({t[i][0] for t in tuples}) >= 2
def pred_D(tuples, i, j): return any(t[i] != t[j] for t in tuples)

# closed terms of PA language, size <= 4
GT = ground_terms({'0': 0, 'S': 1, 'add': 2, 'mul': 2}, 4)
POOL = [t for n in range(1, 5) for t in GT[n]]
print('closed-term pool: %d terms (size <= 4); roots:' % len(POOL),
      {r: sum(1 for t in POOL if t[0] == r) for r in ('0', 'S', 'add', 'mul')})

PHIS = {
    'x+0=x  (x twice)': (eq(add(X, Z), X), [X]),
    'x+x=x*x (x four times)': (eq(add(X, X), mul(X, X)), [X]),
    'x+S0=Sx (closed S0 in phi)': (eq(add(X, S(Z)), S(X)), [X]),
    'x=0 & Ax(x=x)  (bound x)': (AND(eq(X, Z), ALL(X, eq(X, X))), [X]),
    'x+y=y+x (two vars)': (eq(add(X, Y), add(Y, X)), [X, Y]),
    'x*0=0 & y=y (two vars)': (AND(eq(mul(X, Z), Z), eq(Y, Y)), [X, Y]),
}

print('\n(1) anchor <=> (R)&(D):  lgg(data) == phi(z..) up to renaming')
for name, (phi, vs) in PHIS.items():
    sig = schema(phi, vs)
    k = len(vs)
    if k == 1:
        tuples_all = [(t,) for t in POOL]
    else:
        sub = [t for t in POOL if len(str(t)) < 40][:18]
        tuples_all = list(itertools.product(sub, repeat=k))
    agree = tot = rec = 0
    for r in (2, 3):
        combos = itertools.combinations(tuples_all, r)
        for D in itertools.islice(combos, 0, 60000):
            data = [inst(phi, vs, ts) for ts in D]
            L = lgg_list(data)
            got = equiv(L, sig)
            pred = all(pred_R(D, i) for i in range(k)) and all(pred_D(D, i, j) for i in range(k) for j in range(i + 1, k))
            agree += (got == pred); tot += 1; rec += got
    print('  %-28s schema %-28s data sets %6d  agree %6d  recovering %6d' % (name, show(sig), tot, agree, rec))

print('\n    examples of non-anchors (sound specialisations):')
phi, vs = PHIS['x+0=x  (x twice)']
for D in [[(S(Z),), (S(S(Z)),)], [(add(Z, Z),), (add(S(Z), Z),)]]:
    print('     data terms', [show(t[0]) for t in D], '-> lgg', show(lgg_list([inst(phi, vs, t) for t in D])))
phi, vs = PHIS['x+y=y+x (two vars)']
D = [(Z, Z), (S(Z), S(Z)), (add(Z, Z), add(Z, Z))]
print('     x+y=y+x on diagonal data', [show(a) for a, b in D], '-> lgg', show(lgg_list([inst(phi, vs, t) for t in D])))
phi, vs = PHIS['x+S0=Sx (closed S0 in phi)']
D = [(S(Z),), (Z,)]
print('     x+S0=Sx with data terms S0 and 0 (S0 also a closed subterm of phi) -> lgg',
      show(lgg_list([inst(phi, vs, t) for t in D])))
D = [(S(Z),), (S(S(Z)),)]
print('     x+S0=Sx with data terms S0 and SS0 (root S only) -> lgg',
      show(lgg_list([inst(phi, vs, t) for t in D])))

print('\n(2) instance-set injectivity: two instances with distinct roots per variable and distinct values')
ok = True
for name, (phi, vs) in PHIS.items():
    sig = schema(phi, vs)
    th0 = [Z, S(Z), add(Z, Z)][:len(vs)]
    th1 = [S(S(Z)), mul(Z, Z), Z][:len(vs)]
    L = lgg_list([inst(phi, vs, th0), inst(phi, vs, th1)])
    ok &= equiv(L, sig)
print('  lgg of the two generic instances == schema for all phi:', ok)

print('\n(3) open-term data, named encoding, guards {closed(z), free-for(z)} learned as the strongest guards true on all data')
P1, P2 = ('p1',), ('p2',)       # parameters (free names) = constants of the step language
PARAMS = {P1, P2}
def is_closed(t):
    if t in PARAMS or t in (X, Y): return False
    if len(t) == 1: return True
    return all(is_closed(a) for a in t[1:])
phi, vs = (eq(add(Z, X), X), [X])     # 0+x=x
sig = schema(phi, vs)
def learn(data_terms):
    L = lgg_list([inst(phi, vs, (t,)) for t in data_terms])
    guards = {'closed(z0)': all(is_closed(t) for t in data_terms)}
    return L, guards
def accepts(L, guards, t):
    s = inst(phi, vs, (t,))
    m = match(L, s)
    if m is None: return False
    if guards['closed(z0)'] and not is_closed(t): return False
    return True
for D in ([Z, S(Z)], [Z, S(Z), add(P1, S(Z))]):
    L, G = learn(D)
    print('  data terms', [show(t) for t in D], ' lgg', show(L), ' learned guards', G)
    for q in (S(S(Z)), P2, mul(P1, P2)):
        print('     accept 0+t=t for t = %-12s : %s' % (show(q), accepts(L, G, q)))
print('  (accepting t = p2, a parameter, means accepting the universal closure  Ap2 (0+p2=p2),  i.e.  Ax(0+x=x).)')

print('\n(4) rates.  Law on closed terms: Galton-Watson tree, root 0:0.4, S:0.3, add:0.2, mul:0.1, depth cap 4')
PR = {'0': 0.4, 'S': 0.3, 'add': 0.2, 'mul': 0.1}
def gen(rng, d=0):
    r = rng.random()
    if d >= 4: return Z
    acc = 0
    for f, p in PR.items():
        acc += p
        if r < acc: break
    if f == '0': return Z
    if f == 'S': return S(gen(rng, d + 1))
    return (f, gen(rng, d + 1), gen(rng, d + 1))
# exact term law (finite support because of the depth cap) for collision probabilities
from functools import lru_cache
@lru_cache(None)
def law(d):
    if d >= 4: return {Z: 1.0}
    out = {Z: PR['0']}
    sub = law(d + 1)
    for t, p in sub.items(): out[S(t)] = out.get(S(t), 0) + PR['S'] * p
    for f in ('add', 'mul'):
        for a, pa in sub.items():
            for b, pb in sub.items():
                out[(f, a, b)] = out.get((f, a, b), 0) + PR[f] * pa * pb
    return out
mu = law(0)
p = {f: sum(q for t, q in mu.items() if t[0] == f) for f in PR}
c = sum(q * q for q in mu.values())
cf = {f: sum(q * q for t, q in mu.items() if t[0] == f) for f in PR}
print('  root law', {f: round(v, 4) for f, v in p.items()}, ' collision prob c = P[t=t\'] = %.4f' % c)
def fail1(N): return sum(v ** N for v in p.values())
def fail2(N):
    Sn = sum(v ** N for v in p.values()); Cn = sum(v ** N for v in cf.values())
    return 2 * Sn - Sn * Sn + c ** N - Cn
rho_root = max(min(sum(p[f] for f in G), 1 - sum(p[f] for f in G))
               for r in range(1, 4) for G in itertools.combinations(PR, r))
rng = random.Random(1)
TR = 20000
print('  one variable (phi = x+0=x): exact P[no anchor] = sum_f p_f^N;  two variables (x+y=y+x, independent terms):')
print('  exact = 2S - S^2 + c^N - sum_f c_f^N  (S = sum_f p_f^N, c_f = P[t=t\', root f])')
print('   N   exact1     MC1(lgg)   exact2     MC2(lgg)   bound1=2e^{-N rho}  bound2=5e^{-N rho2}')
phi1, vs1 = PHIS['x+0=x  (x twice)']; sig1 = schema(phi1, vs1)
phi2, vs2 = PHIS['x+y=y+x (two vars)']; sig2 = schema(phi2, vs2)
rho2 = min(rho_root, 1 - c)
for N in (2, 3, 4, 6, 8, 10, 12):
    f1 = f2 = 0
    for _ in range(TR):
        D1 = [inst(phi1, vs1, (gen(rng),)) for _ in range(N)]
        f1 += not equiv(lgg_list(D1), sig1)
        D2 = [inst(phi2, vs2, (gen(rng), gen(rng))) for _ in range(N)]
        f2 += not equiv(lgg_list(D2), sig2)
    print('  %2d  %.5f    %.5f    %.5f    %.5f    %.5f            %.5f' % (
        N, fail1(N), f1 / TR, fail2(N), f2 / TR, min(1, 2 * math.exp(-N * rho_root)), min(1, 5 * math.exp(-N * rho2))))
for delta in (0.01,):
    n1 = next(N for N in range(1, 500) if fail1(N) <= delta)
    n2 = next(N for N in range(1, 500) if fail2(N) <= delta)
    t1 = math.ceil(math.log(2 / delta) / rho_root); t2 = math.ceil(math.log(5 / delta) / rho2)
    print('  delta=%.2f: smallest N with exact failure <= delta: one var %d, two vars %d;  theorem bound N: %d, %d'
          % (delta, n1, n2, t1, t2))
print('  rho (root split) = %.3f, rho2 = min(rho, 1-c) = %.3f' % (rho_root, rho2))

print('\n(5) second-order classes: Prop A2\' holds in DT-degree but fails in SO-degree for the PA language')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/prior/induction')
import so_core as so
# phi(x) = x+0=x;  T = f(S0) + f(0) = f(S0), f a unary term metavariable with ground arguments (no pattern occurrence)
T = so.eq(so.add(so.M('f', so.S(so.Z)), so.M('f', so.Z)), so.M('f', so.S(so.Z)))
def inst_pa(t): return so.eq(so.add(t, so.Z), t)
for n in range(4):
    t = so.Z
    for _ in range(n): t = so.S(t)
    print('   T covers %-12s : %s' % (so.pp(inst_pa(t)), so.covers(T, inst_pa(t))))
print('   T is determinate (DT):', so.is_determinate(T), ';  {0+0=0, S0+0=S0} satisfies (R) but T misses SS0+0=SS0')
