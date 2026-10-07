# Referee checks for track "cases", Part 2, first-order side (Thm B1, Prop B2, Sec. 2.4, Prop C3, D1,
# Lemma C1 / Thm C2).  Own code only (zf_lib.py).  Falsity in V is NOT evaluated here; instead, for the
# deep-leaf case analysis of Thm C2 we check by brute force over ALL membership structures of size <= 3
# that each replaced sentence s_n[q <- v] logically implies the simple false sentence named in the proof
# (pure logic part of the argument).
import sys, itertools, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/cases/referee_code')
from zf_lib import *

print('(1) Thm B1 criterion: argument tuples per P-occurrence')
fo = {}
for sc in SCHEMAS:
    F, n, m = SCHEMAS[sc]
    names = []
    F(lambda k, *a: names.append(a) or ('?', 'x'))
    dba = db_args(sc)
    fo[sc] = (len(set(names)) == 1, len(set(dba)) == 1)
    print('   %-6s named %-40s FO-named %-5s | dB %-28s FO-dB %s' % (sc, names, fo[sc][0], dba, fo[sc][1]))

def blocks_of(L, slot_pos):
    mvs = [at(L, p) for p in slot_pos]
    out = []
    for k, z in enumerate(mvs):
        for b in out:
            if mvs[b[0]] == z: b.append(k); break
        else: out.append([k])
    return [tuple(b) for b in out], mvs

def slot_positions(sc, enc):
    m = SCHEMAS[sc][2]
    marks = [('?', 'P%d' % k) for k in range(m)]
    fr = build_named(sc, marks)
    if enc == 'db': fr = to_db(fr)
    return [[p for p, t in positions(fr) if t == marks[k]][0] for k in range(m)]

print('\n(2) Prop B2: blocks of the FO lgg on random body pairs with (R) vs prediction')
rng = random.Random(11)
for sc in SCHEMAS:
    F, n, m = SCHEMAS[sc]
    names = []
    F(lambda k, *a: names.append(a) or ('?', 'x'))
    dba = db_args(sc)
    ok = {'named': 0, 'db': 0}; tot = 0
    for _ in range(400):
        b1 = rand_body(rng, n); b2 = rand_body(rng, n)
        if root(b1) == root(b2): continue
        tot += 1
        data = [instance(sc, b1), instance(sc, b2)]
        for enc, args in (('named', names), ('db', dba)):
            D = data if enc == 'named' else [to_db(s) for s in data]
            L, cols = lgg(D)
            sp = slot_positions(sc, enc)
            bl, mvs = blocks_of(L, sp)
            ok_all = all(is_mv(z) for z in mvs)
            pred_tied = lambda k, l: all(not (uses(b1, i) or uses(b2, i)) for i in range(n) if args[k][i] != args[l][i])
            agree = ok_all and all((mvs[k] == mvs[l]) == pred_tied(k, l) for k in range(m) for l in range(m))
            ok[enc] += agree
    print('   %-6s pairs with (R): %3d  agree named %3d  dB %3d' % (sc, tot, ok['named'], ok['db']))

def most_specific_guards(L, cols, enc, frame_names):
    G = {}
    for z, col in cols.items():
        if enc == 'named':
            fv = set().union(*[free_names(c) for c in col])
            G[z] = {v for v in frame_names if v not in fv}           # fresh(v, z)
        else:
            G[z] = set().union(*[loose(c) for c in col])             # loose(z) <= G[z]
    return G

def satisfies(L, s, G, enc):
    sub = match(L, s, {})
    if sub is None: return None
    for z, val in sub.items():
        if enc == 'named':
            if free_names(val) & G[z]: return False
        else:
            if not loose(val) <= G[z]: return False
    return True

def check_case(title, sc, enc, data_bodies, inst_bodies):
    data = [instance(sc, b) for b in data_bodies]
    D = data if enc == 'named' else [to_db(s) for s in data]
    L, cols = lgg(D)
    G = most_specific_guards(L, cols, enc, FRAME_NAMES[sc])
    s = build_named(sc, inst_bodies)
    sdb = to_db(s)
    tgt = s if enc == 'named' else sdb
    bl, _ = blocks_of(L, slot_positions(sc, enc))
    m_plain = match(L, tgt, {}) is not None
    m_guard = satisfies(L, tgt, G, enc)
    print('   %-34s %-5s blocks %-22s inst-of-lgg %-5s guards-ok %-5s schema-instance %-5s closed %s' % (
        title, enc, bl, m_plain, m_guard, is_schema_instance(sc, s), not any(t[0].startswith('$free') for _, t in positions(sdb))))
    return L, G

h0, h1, h2 = hole(0), hole(1), hole(2)
TOPb = ('fa', nv('w0'), ('eq', nv('w0'), nv('w0')))
BOTb = ('neg', TOPb)
print('\n(3) Sec. 2.4 false instances: instance of the (guarded) FO lgg, not a schema instance')
check_case('EInd F1 [data x=x, ~x in a]', 'EInd', 'named', [('eq', h0, h0), ('neg', ('in', h0, par('a')))],
           [('neg', ('eq', h0, h0)), ('fa', nv('w0'), ('neg', ('in', nv('w0'), h0))), ('fa', nv('w0'), ('neg', ('in', nv('w0'), h0)))])
check_case('ReplJ [x in y, ~x=a] A:=y=y,B:=~u=u', 'ReplJ', 'named', [('in', h0, h1), ('neg', ('eq', h0, par('a')))],
           [('eq', h1, h1), ('neg', ('eq', h1, h1)), ('eq', h1, h1)])
check_case('ReplJ dB A1:=bot,A2:=bot,A3:=y=y', 'ReplJ', 'db', [('in', h0, h1), ('neg', ('eq', h0, par('a')))],
           [BOTb, BOTb, ('eq', h1, h1)])
check_case('Coll dB [y=x, ~x=A] A1:=y=y, A2:=bot', 'Coll', 'db', [('eq', h1, h0), ('neg', ('eq', h0, h2))],
           [('eq', h1, h1), BOTb])
check_case('ReplU dB A1:=y=x, A2:=bot', 'ReplU', 'db', [('eq', h1, h0), ('neg', ('eq', h0, h2))],
           [('eq', h1, h0), BOTb])
check_case('ReplS dB A1:=y=x, A2:=bot, A3:=bot', 'ReplS', 'db', [('eq', h1, h0), ('neg', ('eq', h0, h2))],
           [('eq', h1, h0), BOTb, BOTb])
print('   guard violations (instance of the unguarded lgg, rejected by the learned guards):')
check_case('Sep Russell [x in z, ~x=a]', 'Sep', 'named', [('in', h0, h1), ('neg', ('eq', h0, par('a')))],
           [('neg', ('in', h0, nv('y')))])
check_case('Sep Russell dB', 'Sep', 'db', [('in', h0, h1), ('neg', ('eq', h0, par('a')))],
           [('neg', ('in', h0, nv('y')))])
check_case('Coll named capture y=Y', 'Coll', 'named', [('eq', h1, h0), ('neg', ('eq', h0, h2))],
           [('eq', h1, nv('Y')), ('eq', h1, nv('Y'))])
# Coll dB with data not using A: slots tied; instance #0 = #2 reads y=A / y=Y
L, G = check_case('Coll dB tied [y=x, ~x in y]', 'Coll', 'db', [('eq', h1, h0), ('neg', ('in', h0, h1))],
                  [('eq', h1, h0), ('eq', h1, h0)])
db_cap = ('eq', ix(0), ix(2))
sub = match(L, to_db(instance('Coll', ('eq', h1, h0))), {})
zt = list(sub)[0]
capt = to_db(instance('Coll', ('eq', h1, h0)))
sp = slot_positions('Coll', 'db')
capt = replace(replace(capt, sp[0], db_cap), sp[1], db_cap)
print('   Coll dB index-capture  #0=#2 :  inst-of-lgg', match(L, capt, {}) is not None, ' guards-ok', satisfies(L, capt, G, 'db'),
      ' learned loose set', G[zt])

print('\n(4) Thm B1 only-if witness s3 (top at one block, bot elsewhere) for every non-FO case')
for sc in SCHEMAS:
    F, n, m = SCHEMAS[sc]
    for enc, isfo in (('named', fo[sc][0]), ('db', fo[sc][1])):
        if isfo: continue
        phi1 = ('eq', h0, h0)
        for i in range(1, n): phi1 = ('conj', phi1, ('eq', hole(i), hole(i)))
        phi2 = ('neg', phi1)
        data = [instance(sc, phi1), instance(sc, phi2)]
        D = data if enc == 'named' else [to_db(s) for s in data]
        L, cols = lgg(D)
        sp = slot_positions(sc, enc)
        bl, mvs = blocks_of(L, sp)
        s3 = D[0]
        first = mvs[0]
        for k, p in enumerate(sp):
            v = TOPb if mvs[k] == first else BOTb
            vv = v if enc == 'named' else to_db(v)
            s3 = replace(s3, p, vv)
        G = most_specific_guards(L, cols, enc, FRAME_NAMES[sc])
        s3n = s3 if enc == 'named' else None
        # schema-instance test on the dB form (names irrelevant: bodies closed)
        sch = None
        if enc == 'named': sch = is_schema_instance(sc, s3)
        else:
            # rebuild named version for the test: same per-slot closed formulas
            bodies = [TOPb if mvs[k] == first else BOTb for k in range(m)]
            sch = is_schema_instance(sc, build_named(sc, bodies))
        print('   %-6s %-5s blocks %-20s s3 inst-of-lgg %s guards-ok %s schema-instance %s' % (
            sc, enc, bl, match(L, s3, {}) is not None, satisfies(L, s3, G, enc), sch))

print('\n(5) Prop C3: named ReplS, data with (R) and N_y')
L, G = check_case('ReplS named [y=x, ~x=A] B2:=bot', 'ReplS', 'named', [('eq', h1, h0), ('neg', ('eq', h0, h2))],
                  [('eq', h1, h0), BOTb, ('eq', h1, h0)])
print('   learned fresh-guards per metavariable:', {z: sorted(g) for z, g in G.items()})

print('\n(6) Prop D1(b): learned guards == target guards  <=>  (N_x and N_z) for Sep; (N_x,N_y,N_A) for Coll/ReplU')
rng = random.Random(5)
for sc, target in (('Sep', {'y'}), ('Coll', {'Y'}), ('ReplU', {'Y'})):
    n = SCHEMAS[sc][1]
    agree = tot = 0
    for _ in range(600):
        b1 = rand_body(rng, n); b2 = rand_body(rng, n)
        if root(b1) == root(b2): continue
        tot += 1
        L, cols = lgg([instance(sc, b1), instance(sc, b2)])
        G = most_specific_guards(L, cols, 'named', FRAME_NAMES[sc])
        exact = all(g == target for g in G.values())
        pred = all(uses(b1, i) or uses(b2, i) for i in range(n))
        agree += (exact == pred)
    print('   %-6s pairs %d agree %d' % (sc, tot, agree))

# ---------------- (7) deep leaf: uniqueness and pure-logic part of the case analysis ----------------
def neg_chain(f, k):
    for _ in range(k): f = ('neg', f)
    return f

def evaluate(f, R, dom, env=()):
    h = f[0]
    if h == 'in': return (val(f[1], env), val(f[2], env)) in R
    if h == 'eq': return val(f[1], env) == val(f[2], env)
    if h == 'neg': return not evaluate(f[1], R, dom, env)
    if h == 'conj': return evaluate(f[1], R, dom, env) and evaluate(f[2], R, dom, env)
    if h == 'impl': return (not evaluate(f[1], R, dom, env)) or evaluate(f[2], R, dom, env)
    if h == 'iff': return evaluate(f[1], R, dom, env) == evaluate(f[2], R, dom, env)
    if h == 'fa': return all(evaluate(f[1], R, dom, env + (e,)) for e in dom)
    if h == 'ex': return any(evaluate(f[1], R, dom, env + (e,)) for e in dom)
    if h == 'ex1': return sum(1 for e in dom if evaluate(f[1], R, dom, env + (e,))) == 1
    raise ValueError(h)
def val(t, env): return env[len(env) - 1 - ixv(t)]

STRUCTS = []
for size_ in (1, 2, 3):
    dom = list(range(size_))
    pairs = [(a, b) for a in dom for b in dom]
    for bits in range(2 ** len(pairs)):
        STRUCTS.append((dom, {pairs[i] for i in range(len(pairs)) if bits >> i & 1}))

def implies_everywhere(f, g):
    return all((not evaluate(f, R, dom)) or evaluate(g, R, dom) for dom, R in STRUCTS)

EMPTYALL = to_db(('fa', nv('x'), ('fa', nv('w'), ('neg', ('in', nv('w'), nv('x'))))))   # every set is empty
C_ReplJ = to_db(('fa', nv('X'), ('ex', nv('Y'), ('fa', nv('y'), ('iff', ('in', nv('y'), nv('Y')),
                ('ex', nv('x'), ('conj', ('in', nv('x'), nv('X')), ('in', nv('x'), nv('y')))))))))

def deep_case(sc, enc, body, leaf_occ, leaf_pred, target, nn):
    s = instance(sc, body)
    sdb = to_db(s)
    t = s if enc == 'named' else sdb
    sp = slot_positions(sc, enc)[leaf_occ]
    # designated leaf: deepest leaf inside the slot satisfying leaf_pred
    cands = [p for p, x in positions(t) if p[:len(sp)] == sp and len(x) == 1 and leaf_pred(t, x, p)]
    leaf = max(cands, key=len)
    prefixes = [leaf[:i] for i in range(len(leaf))]
    allsub = [x for _, x in positions(t)]
    uniq = all(allsub.count(at(t, q)) == 1 for q in prefixes)
    # pure-logic check: for every proper prefix q (formula positions), one of top/bot makes s[q<-v]
    # imply the target (checked in all membership structures of size <= 3), using the dB form.
    sdbp = sdb
    # translate prefix positions named->dB: named binders have an extra child (the variable)
    def to_db_pos(p, tree):
        out = []; cur = tree
        for i in p:
            if enc == 'named' and cur[0] in BIND:
                assert i == 1; out.append(0); cur = cur[2]
            else:
                out.append(i); cur = cur[1 + i]
        return tuple(out)
    okq = 0; badq = []
    TOPd, BOTd = to_db(TOPb), to_db(BOTb)
    qs = [q for q in prefixes if not (enc == 'named' and len(at(t, q)) == 1)]
    for q in qs:
        qd = to_db_pos(q, t) if enc == 'named' else q
        good = False
        for v in (TOPd, BOTd):
            r = replace(sdb, qd, v)
            if implies_everywhere(r, target):
                good = True; break
        okq += good
        if not good: badq.append(q)
    print('   %-6s %-5s n=%d leaf depth %2d  path subterms unique: %s  prefixes %2d, with a top/bot making s[q<-v] |= target: %2d %s' % (
        sc, enc, nn, len(leaf), uniq, len(qs), okq, badq[:2]))

print('\n(7) Thm C2 deep-leaf: uniqueness along the path; pure-logic check of the case analysis on all')
print('    membership structures of size <= 3 (necessary condition for the hand proof)')
for nn in (1, 2):
    phiE = neg_chain(('fa', nv('w0'), ('neg', ('in', nv('w0'), h0))), 2 * nn)
    deep_case('EInd', 'named', phiE, 0, lambda t, x, p: x == nv('y'), EMPTYALL, nn)
    phiJ = neg_chain(('in', h0, h1), 2 * nn)
    deep_case('ReplJ', 'named', phiJ, 1, lambda t, x, p: x == nv('u'), C_ReplJ, nn)
    deep_case('ReplJ', 'db', phiJ, 1, lambda t, x, p: p[-1] == 1 and at(t, p[:-1])[0] == 'in', C_ReplJ, nn)
    phiC = neg_chain(('conj', ('eq', h1, h0), ('in', h0, h2)), 2 * nn)
    occ = {'Coll': 1, 'ReplU': 1, 'ReplS': 2}
    for sc in ('Coll', 'ReplU', 'ReplS'):
        # leaf = the A inside the consequent occurrence: the right child of the 'in' atom
        deep_case(sc, 'db', phiC, occ[sc], lambda t, x, p: p[-1] == 1 and at(t, p[:-1])[0] == 'in', EMPTYALL, nn)
