# u12: spare slots for one-variable first-order instance schemas (referee U2, 'missing' 1).
# (a) After parameter canonicalization a term metavariable has finitely many head classes: for sigma = phi(z) over
#     0, S, +, * with p template parameters, the 5+p head-class specializations cover inst(sigma) (each is needed).
# (b) Proposition 3.5(c) [m = h]: for phi(z) = (z+0 = z), data with all h = 5 head classes, m = 5 slots for the
#     target: exact iff every non-constant class block has lgg f(x1..xr) with distinct variables.  Brute force over
#     all partitions into <= m blocks (Lemma 1.2 finite form; quantifier-free data, so Min(B) = {lgg(B)}), coverage
#     tested on all canonical instances phi(t), t of depth <= 2 (decisive here, see notes); also m = h-1 (always exact).
# (c) Proposition 3.6 [unary signature 0, S + names, closed form kappa = (h-1) r + |cl(T_r)|]: exhaustive check.
import sys, random, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from practice import rand_closed

def canon_t(t): return canon_params(t)

print('== (a) head-class failure templates ==')
rng = random.Random(0)
u, w = M('tu'), M('tw')
for name, phi, extra in (('z+0=z (p=0)', eq(add(M('t0'), Z), M('t0')), []),
                         ('a1+z=z+a1 (p=1)', eq(add(P('a1'), M('t0')), add(M('t0'), P('a1'))), [P('a2')])):
    heads = [('0', Z), ('S', S(u)), ('+', add(u, w)), ('*', mul(u, w)), ('a1', P('a1'))] + [('fresh', x) for x in extra]
    fails = [(h, instantiate(phi, {'t0': t})) for h, t in heads]
    miss = 0; used = {h: 0 for h, _ in heads}
    for _ in range(2000):
        r = rng.random()
        t = rand_closed(rng, 3) if r < .5 else (P('b%d' % rng.randint(1, 4)) if r < .7 else
             (P('a1') if r < .8 else add(P(rng.choice(['b1', 'b2', 'a1'])), rand_closed(rng, 1))))
        q = canon_params(instantiate(phi, {'t0': t}))
        cov = [h for h, F in fails if covers(F, q)]
        if not cov: miss += 1
        for h in cov: used[h] += 1
    # each failure template is needed: its generic instance is covered by no other one
    needed = []
    for h, t in heads:
        gen = canon_params(instantiate(phi, {'t0': {'0': Z, 'S': S(Z), '+': add(Z, Z), '*': mul(Z, Z)}.get(h, t)}))
        others = [h2 for h2, F in fails if h2 != h and covers(F, gen)]
        needed.append((h, not others))
    print('  %-18s %d failure templates; random canonical instances not covered: %d/2000; hits per class %s; each needed: %s'
          % (name, len(fails), miss, used, needed))

print()
print('== (b) m = h criterion for phi(z) = (z+0=z) ==')
phi = eq(add(M('t0'), Z), M('t0'))
d0 = [Z, P('a1')]
d1 = d0 + [S(x) for x in d0] + [add(x, y) for x in d0 for y in d0] + [mul(x, y) for x in d0 for y in d0]
names2 = [P('a1'), P('a2')]
d1n = [Z] + names2 + [S(x) for x in [Z] + names2] + [f(x, y) for f in (add, mul) for x in [Z] + names2 for y in [Z] + names2]
test_terms = set()
for t in d1n: test_terms.add(t)
for x in d1n: test_terms.add(S(x))
for f in (add, mul):
    for x in d1n:
        for y in d1n: test_terms.add(f(x, y))
tests = sorted(set(canon_params(instantiate(phi, {'t0': t})) for t in test_terms))
print('  test instances (canonical, z of depth <= 2):', len(tests))

def head(t): return t[0] if t[0] != 'p' else 'nu'
def criterion(T):
    cls = set(head(t) for t in T)
    if cls != {'0', 'S', '+', '*', 'nu'}: return False
    for f, r in (('S', 1), ('+', 2), ('*', 2)):
        blk = [t for t in T if t[0] == f]
        cols = [tuple(t[1 + j] for t in blk) for j in range(r)]
        for col in cols:
            if len(set(head(x) if x[0] != 'p' else x for x in col)) < 2: return False
        if r == 2 and cols[0] == cols[1]: return False
    return True

def exact_bruteforce(T, m):
    data = [canon_params(instantiate(phi, {'t0': t})) for t in T]
    n = len(data)
    mask = {}
    full = (1 << len(tests)) - 1
    def block_mask(idx):
        key = frozenset(idx)
        if key not in mask:
            Ts = mincov([data[i] for i in idx])
            assert len(Ts) == 1                      # quantifier-free data: Min = {Plotkin lgg}
            mk = 0
            for k, q in enumerate(tests):
                if covers(Ts[0], q): mk |= 1 << k
            mask[key] = mk
        return mask[key]
    def parts(xs, k):
        if not xs: yield []; return
        for p in parts(xs[1:], k):
            for i in range(len(p)): yield p[:i] + [[xs[0]] + p[i]] + p[i + 1:]
            if len(p) < k: yield [[xs[0]]] + p
    for p in parts(list(range(n)), m):
        mk = 0
        for B in p: mk |= block_mask(B)
        if mk != full: return False
    return True

pool_S = [S(Z), S(S(Z)), S(P('a1')), S(add(Z, Z))]
pool_add = [add(Z, Z), add(S(Z), Z), add(Z, S(Z)), add(P('a1'), Z), add(P('a1'), P('a1')), add(S(Z), S(Z)), add(mul(Z, Z), Z)]   # (H2): <= 1 parameter per z-value
pool_mul = [mul(Z, Z), mul(S(Z), Z), mul(Z, S(Z)), mul(P('a1'), Z), mul(S(Z), S(Z)), mul(Z, P('a1'))]
rng = random.Random(3)
agree = tot = 0; ex_cnt = 0; m4_exact = 0
for trial in range(60):
    T = [Z, P('a1')] + rng.sample(pool_S, 2) + rng.sample(pool_add, rng.randint(2, 3)) + rng.sample(pool_mul, rng.randint(2, 3))
    T = list(dict.fromkeys(canon_params(t) for t in T))
    if rng.random() < 0.2: T = [t for t in T if t[0] != '*'] or T      # sometimes drop a class
    bf = exact_bruteforce(T, 5)
    cr = criterion(T)
    tot += 1; agree += (bf == cr); ex_cnt += bf
    m4_exact += exact_bruteforce(T, len(set(head(t) for t in T)) - 1) if len(set(head(t) for t in T)) > 1 else 1
print('  m = 5: brute force vs criterion agree on %d/%d random data sets (%d exact)' % (agree, tot, ex_cnt))
print('  m = h(T) - 1: exact in %d/%d (Prop 3.5(a): always)' % (m4_exact, tot))

print()
print('== (c) unary signature {0, S} + names: kappa = (h-1) r + |cl(T_r)| ==')
def kappa_bf(T, bases):
    # terms (j, b): S^j b; lgg(block) = itself if singleton-equal else ('var', min j)
    T = list(T)
    def lgg(B):
        if len(set(B)) == 1: return ('g',) + B[0]
        return ('v', min(j for j, _ in B))
    def covers_all(pats):
        J = min([p[1] for p in pats if p[0] == 'v'] + [10 ** 9])
        if J == 10 ** 9: return False
        ground = set((p[1], p[2]) for p in pats if p[0] == 'g')
        return all((j, b) in ground for j in range(J) for b in bases)
    best = None
    def parts(xs):
        if not xs: yield []; return
        for p in parts(xs[1:]):
            for i in range(len(p)): yield p[:i] + [[xs[0]] + p[i]] + p[i + 1:]
            yield [[xs[0]]] + p
    for p in parts(T):
        if not covers_all([lgg(B) for B in p]):
            if best is None or len(p) < best: best = len(p)
    return best
def kappa_formula(T, bases):
    h = len(bases) + 1
    r, Tj = 0, set(T)
    while True:
        cl = set(b for j, b in Tj if j == 0) | ({'S'} if any(j >= 1 for j, _ in Tj) else set())
        if len(cl) < h: return (h - 1) * r + len(cl)
        Tj = set((j - 1, b) for j, b in Tj if j >= 1); r += 1
for p in (0, 1):
    bases = ['0', 'nu'] + ['c%d' % i for i in range(1, p + 1)]
    U = [(j, b) for j in range(4) for b in bases]
    agree = tot = 0
    for size in range(1, 8 if p == 0 else 7):
        for T in itertools.combinations(U, size):
            tot += 1; agree += kappa_bf(T, bases) == kappa_formula(T, bases)
    print('  p = %d (h = %d): formula = brute force on %d/%d term sets' % (p, len(bases) + 1, agree, tot))
print('  example (p=0): numerals {0,S0,SS0,SSS0}: kappa =', kappa_formula([(j, '0') for j in range(4)], ['0', 'nu']),
      '; with name instances {0,a,S0,Sa,SS0}: kappa =', kappa_formula([(0, '0'), (0, 'nu'), (1, '0'), (1, 'nu'), (2, '0')], ['0', 'nu']))
