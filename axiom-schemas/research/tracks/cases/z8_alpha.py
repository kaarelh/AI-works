# Track "cases", revision (referee missing item 5): the named encoding when the community alpha-renames the
# frame's bound variables (data are arbitrary alpha-variants of schema instances; all binder names distinct).
# Prop B1-alpha (notes-final.md): a pattern template is then a guarded first-order pattern (name metavariables,
# guards fresh(v,A) and distinct(v,w)) iff P is applied to the SAME BINDERS at every occurrence.  Among the ZF
# schemas only Sep and SepJ (one occurrence) qualify; Coll, ReplU, ReplS, ReplJ, EInd do not.
# Checks:
#  (1) for every schema: the named lgg of two alpha-varied data with (R): which slots it ties (blocks);
#  (2) for Coll, ReplU, ReplS (first-order or truth-sound with textbook names, Table B1 / Prop C3): an instance of
#      the lgg, satisfying the most specific fresh/distinct guards learned from the data, that is a sentence
#      and not a schema instance (falsity: hand proof, same sentences as Sec. 2.4 items 4-6);
#  (3) Sep, SepJ: 4000 random instances of the guarded lgg (random distinct names, random slot formulas over
#      the frame names and parameters) are all genuine (alpha-variants of schema instances);
#  (4) Thm C2 under alpha-variation: path-subterm uniqueness for the deep-leaf family s_n (n <= 6) for Coll,
#      ReplU, ReplS with all binder names distinct (the hypothesis of Lemma C1).
import sys, random, itertools
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, match, show
from st_core import *
from st_pool import pool_for

rng = random.Random(3)
NAMEPOOL = ['n%d' % i for i in range(40)]

def body_named2(b, argnames, d=0):
    h = b[0]
    if h == 'h': return (argnames[b[1]],)
    if h == 'p': return (b[1],)
    if h == 'v': return ('w%d' % (d - 1 - b[1]),)
    if h in BINDERS: return (h, ('w%d' % d,), body_named2(b[1], argnames, d + 1))
    return (h,) + tuple(body_named2(k, argnames, d) for k in kids(b))

def alpha_instance(nm, body, rng, textbook=False):
    """named instance with every frame binder renamed to a fresh distinct name"""
    used = set()
    def fresh(old):
        if textbook: return old
        while True:
            c = rng.choice(NAMEPOOL)
            if c not in used: used.add(c); return c
    def go(f, env):
        if isinstance(f, str): return (env.get(f, f),)
        if f[0] == 'P': return body_named2(body, [env[v] for v in f[1:]])
        if f[0] in BINDERS:
            nn = fresh(f[1]); return (f[0], (nn,), go(f[2], {**env, f[1]: nn}))
        return (f[0],) + tuple(go(k, env) for k in f[1:])
    return go(NAMED_FRAMES[nm], {})

def named_to_db(t, scope=()):
    if len(t) == 1:
        nmv = t[0]
        if nmv in scope: return V(len(scope) - 1 - max(i for i, s in enumerate(scope) if s == nmv))
        return Par(nmv)
    if t[0] in BINDERS: return (t[0], named_to_db(t[2], scope + (t[1][0],)))
    return (t[0],) + tuple(named_to_db(k, scope) for k in t[1:])

def frame_paths(nm):
    """T1-positions of the P-occurrences and of the binder-name nodes of the named frame"""
    slots, binders = [], []
    def go(f, p):
        if isinstance(f, str): return
        if f[0] == 'P': slots.append(p); return
        if f[0] in BINDERS:
            binders.append(p + (0,)); go(f[2], p + (1,)); return
        for i, k in enumerate(f[1:]): go(k, p + (i,))
    go(NAMED_FRAMES[nm], ()); return slots, binders

def at(t, p):
    for i in p: t = t[1 + i]
    return t
def replace(t, p, v):
    if not p: return v
    return t[:1 + p[0]] + (replace(t[1 + p[0]], p[1:], v),) + t[2 + p[0]:]

def free_names(f, bound=()):
    if len(f) == 1: return set() if f in bound else {f[0]}
    if f[0] == '?': return set()
    if f[0] in BINDERS: return free_names(f[2], bound + (f[1],))
    return set().union(*[free_names(k, bound) for k in f[1:]])

def learned_guards(nm, data):
    """most specific guards true on all data: fresh(binder b, slot k) and distinct(binder b, binder b')"""
    slots, binders = frame_paths(nm)
    fresh = {(b, k) for b in binders for k in range(len(slots))
             if all(at(d, b)[0] not in free_names(at(d, slots[k])) for d in data)}
    dist = {(b, c) for b, c in itertools.combinations(binders, 2) if all(at(d, b) != at(d, c) for d in data)}
    return fresh, dist

def satisfies(nm, s, guards):
    slots, binders = frame_paths(nm)
    fresh, dist = guards
    return all(at(s, b)[0] not in free_names(at(s, slots[k])) for b, k in fresh) and \
           all(at(s, b) != at(s, c) for b, c in dist)

def blocks_of(nm, L):
    slots, _ = frame_paths(nm)
    vals = [at(L, p) for p in slots]
    out = {}
    for i, v in enumerate(vals): out.setdefault(v, []).append(i + 1)
    return sorted(tuple(g) for g in out.values())

print('(1) blocks of the named lgg: textbook names vs alpha-varied data (all pool pairs with (R))')
for nm in SCHEMAS:
    P = pool_for(nm); n = len(SCHEMAS[nm]['args'])
    stats = {}
    for k1, k2 in itertools.combinations(P, 2):
        bs = [P[k1], P[k2]]
        if not pred_R(bs) or not all(pred_N(bs, n)): continue
        Lt = lgg_list([alpha_instance(nm, b, rng, textbook=True) for b in bs])
        La = lgg_list([alpha_instance(nm, b, rng) for b in bs])
        key = (tuple(blocks_of(nm, Lt)), tuple(blocks_of(nm, La)))
        stats[key] = stats.get(key, 0) + 1
    for (bt, ba), c in stats.items():
        print('   %-6s anchor pairs %3d: textbook-name blocks %-20s alpha-varied blocks %s' % (nm, c, bt, ba))

print('\n(2) false (non-)instances of the guarded named lgg under alpha-variation')
TOPn = ('all', ('w9',), ('eq', ('w9',), ('w9',))); BOTn = ('not', TOPn)
CASES = {'Coll': ('y=x', '¬x=A'), 'ReplU': ('y=x', '¬x=A'), 'ReplS': ('y=x', '¬x=A')}
for nm, (k1, k2) in CASES.items():
    P = pool_for(nm)
    data = [alpha_instance(nm, P[k1], rng), alpha_instance(nm, P[k2], rng)]
    L = lgg_list(data)
    G = learned_guards(nm, data)
    slots, binders = frame_paths(nm)
    # instantiate: names as in datum 1; slot 1 := (y = x) with datum 1's antecedent names, others := BOT
    d1 = data[0]
    th = {}
    for b in binders:
        u = at(L, b)
        if u[0] == '?': th[u[1]] = at(d1, b)
    # antecedent occurrence 1 argument names (x, y) in datum 1: the first two binders below the A-binder
    xname, yname = at(d1, binders[1]), at(d1, binders[2])
    for i, p in enumerate(slots):
        u = at(L, p)
        if u[0] != '?' or u[1] in th: continue
        th[u[1]] = ('eq', yname, xname) if i == 0 else BOTn
    def fs(t):
        if t[0] == '?': return th[t[1]]
        if len(t) == 1: return t
        return (t[0],) + tuple(fs(k) for k in t[1:])
    s = fs(L)
    sdb = named_to_db(s)
    print('   %-6s lgg blocks %-16s instance of lgg %s, guards ok %s, sentence %s, schema instance %s'
          % (nm, blocks_of(nm, L), match(L, s) is not None, satisfies(nm, s, G), is_sentence(sdb),
             covers(SCHEMAS[nm]['T'], sdb)))
    print('          %s' % pp(sdb))

print('\n(3) Sep, SepJ under alpha-variation: random instances of the guarded lgg are genuine')
def rand_named_formula(names, depth=0):
    r = rng.random()
    if depth > 2 or r < 0.4:
        return (rng.choice(['in', 'eq']), (rng.choice(names),), (rng.choice(names),))
    if r < 0.55: return ('not', rand_named_formula(names, depth + 1))
    if r < 0.8: return (rng.choice(['and', 'or', 'imp']), rand_named_formula(names, depth + 1), rand_named_formula(names, depth + 1))
    w = rng.choice(NAMEPOOL[:6] + ['w1', 'w2'])
    return (rng.choice(['all', 'ex']), (w,), rand_named_formula(names + [w], depth + 1))
for nm in ('Sep', 'SepJ'):
    P = pool_for(nm); n = len(SCHEMAS[nm]['args'])
    tested = genuine = 0
    for k1, k2 in itertools.combinations(P, 2):
        bs = [P[k1], P[k2]]
        if not pred_R(bs) or not all(pred_N(bs, n)): continue
        data = [alpha_instance(nm, b, rng) for b in bs]
        L = lgg_list(data); G = learned_guards(nm, data)
        slots, binders = frame_paths(nm)
        for _ in range(40):
            th = {}
            for b in binders:
                u = at(L, b)
                if u[0] == '?': th[u[1]] = (rng.choice(NAMEPOOL[:6]),)
            names = [th[at(L, b)[1]][0] if at(L, b)[0] == '?' else at(L, b)[0] for b in binders] + ['a', 'b']
            u = at(L, slots[0]); th[u[1]] = rand_named_formula(names)
            def fs(t):
                if t[0] == '?': return th[t[1]]
                if len(t) == 1: return t
                return (t[0],) + tuple(fs(k) for k in t[1:])
            s = fs(L)
            if not satisfies(nm, s, G): continue
            sdb = named_to_db(s)
            tested += 1; genuine += covers(SCHEMAS[nm]['T'], sdb)
    print('   %-5s guarded-lgg instances tested %d, genuine %d' % (nm, tested, genuine))

print('\n(4) Thm C2(iii) under alpha-variation.  Family s_n = alpha-variant of Coll/ReplU/ReplS(phi_n),')
print('    phi_n = ~^{2n}(y = x & x in A), all binder names distinct; designated leaf: the y of the atom y = x in the')
print('    consequent occurrence (the A-leaf used for de Bruijn is NOT unique here: x in A is also a frame atom).')
print('    (a) Lemma C1 hypothesis: every proper-prefix subterm on the path occurs once;  (b) for every prefix q one')
print('    of TOP/BOT makes s_n[q<-v] imply "every set is empty" in all membership structures of size <= 3.')
def negs(k, f):
    for _ in range(k): f = NOT(f)
    return f
def count_sub(t, u):
    c = 1 if t == u else 0
    if len(t) > 1: c += sum(count_sub(k, u) for k in t[1:])
    return c
def ev(f, dom, R, env):
    h = f[0]
    if h == 'in': return (env[f[1][0]], env[f[2][0]]) in R
    if h == 'eq': return env[f[1][0]] == env[f[2][0]]
    if h == 'not': return not ev(f[1], dom, R, env)
    if h == 'and': return ev(f[1], dom, R, env) and ev(f[2], dom, R, env)
    if h == 'or': return ev(f[1], dom, R, env) or ev(f[2], dom, R, env)
    if h == 'imp': return (not ev(f[1], dom, R, env)) or ev(f[2], dom, R, env)
    if h == 'iff': return ev(f[1], dom, R, env) == ev(f[2], dom, R, env)
    if h == 'all': return all(ev(f[2], dom, R, {**env, f[1][0]: d}) for d in dom)
    if h == 'ex': return any(ev(f[2], dom, R, {**env, f[1][0]: d}) for d in dom)
    if h == 'exu': return sum(1 for d in dom if ev(f[2], dom, R, {**env, f[1][0]: d})) == 1
    raise ValueError(h)
STRUCTS = []
for n_ in (1, 2, 3):
    dom = list(range(n_)); pairs = [(i, j) for i in dom for j in dom]
    for mask in range(1 << len(pairs)):
        STRUCTS.append((dom, {pairs[k] for k in range(len(pairs)) if mask >> k & 1}))
def empty_all(dom, R): return not R
for nm, occ in (('Coll', 2), ('ReplU', 2), ('ReplS', 3)):
    ok_unique = True; ok_logic = True; nq = 0
    for n in range(0, 7):
        body = negs(2 * n, AND(EQ(H(1), H(0)), IN(H(0), H(2))))
        s = alpha_instance(nm, body, random.Random(n))
        slots, _ = frame_paths(nm)
        p = slots[occ - 1] + (0,) * (2 * n) + (0, 0)
        assert at(s, p) == at(s, slots[occ - 1] + (0,) * (2 * n) + (0,))[1]
        prefixes = [p[:i] for i in range(len(p))]
        ok_unique &= all(count_sub(s, at(s, q)) == 1 for q in prefixes)
        if n <= 1:
            for q in prefixes:
                nq += 1
                good = False
                for v in (TOPn, BOTn):
                    sv = replace(s, q, v)
                    if all(empty_all(dom, R) for dom, R in STRUCTS if ev(sv, dom, R, {})):
                        good = True; break
                ok_logic &= good
    print('   %-6s (a) n = 0..6 unique: %s   (b) n = 0,1: %d prefixes, each with a v making s[q<-v] |= "all sets empty": %s'
          % (nm, ok_unique, nq, ok_logic))
