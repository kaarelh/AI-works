# Track "cases", Part 2(b,c,d): first-order (Plotkin) lgg of ZF-schema instances in two encodings.
#   named:     textbook variable names for the frame, phi substituted textually (T1 terms, names = constants)
#   de Bruijn: frame and phi as de Bruijn trees, indices are constants '#k' (T1 terms)
# For each schema: (1) the syntactic criterion (same argument names / same argument indices at every
# occurrence of P) and the guards; (2) on all pool pairs with (R): which P-occurrences the lgg ties together;
# (3) explicit instances of the computed lgg that are not instances of the schema, with the hand proofs of
# falsity in notes.md (Part 2(c),(d)).
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, match, show
from st_core import *
from st_pool import pool_for

def occ_args_named(nm):
    out = []
    def go(f, bound):
        if isinstance(f, str): return
        if f[0] == 'P': out.append((tuple(f[1:]), tuple(bound))); return
        if f[0] in BINDERS: go(f[2], bound + [f[1]]); return
        for k in f[1:]: go(k, bound)
    go(NAMED_FRAMES[nm], []); return out

def occ_args_db(nm):
    out = []
    def go(t, d):
        if t[0] == 'M': out.append((tuple(a[1] for a in t[2:]), d)); return
        if t[0] in BINDERS: go(t[1], d + 1); return
        for k in kids(t): go(k, d)
    go(SCHEMAS[nm]['T'], 0); return out

def named_to_db(t, scope=()):
    """named T1 sentence -> de Bruijn (free names -> parameters)"""
    if len(t) == 1:
        nmv = t[0]
        if nmv in scope: return V(len(scope) - 1 - max(i for i, s in enumerate(scope) if s == nmv))
        return Par(nmv)
    if t[0] in BINDERS: return (t[0], named_to_db(t[2], scope + (t[1][0],)))
    return (t[0],) + tuple(named_to_db(k, scope) for k in t[1:])

def slot_partition(L, frame_with_slots):
    m = match(frame_with_slots, L)
    if m is None: return None
    ns = len(m)
    vals = [m['s%d' % i] for i in range(ns)]
    blocks = []
    for i, v in enumerate(vals):
        for bl in blocks:
            if vals[bl[0]] == v: bl.append(i + 1); break
        else: blocks.append([i])
    return tuple(tuple(i + 1 if j == 0 else i for j, i in enumerate(bl)) for bl in blocks)

def partition(L, nm, enc):
    ns = n_slots(nm)
    sv = ['s%d' % i for i in range(ns)]
    F = named_frame_term(nm, sv) if enc == 'named' else db_frame_term(nm, sv)
    m = match(F, L)
    if m is None: return None
    vals = [m['s%d' % i] for i in range(ns)]
    groups = {}
    for i, v in enumerate(vals): groups.setdefault(v, []).append(i + 1)
    return tuple(sorted(tuple(g) for g in groups.values()))

print('(1) syntactic criterion: P-occurrences with argument tuples')
for nm in SCHEMAS:
    on = occ_args_named(nm); od = occ_args_db(nm)
    names_same = len({a for a, _ in on}) == 1
    idx_same = len({a for a, _ in od}) == 1
    # named guards: frame-bound names in scope at some occurrence but not an argument
    argset = set(on[0][0]) if names_same else set()
    fresh = sorted({v for _, bd in on for v in bd if v not in argset}) if names_same else None
    # de Bruijn: well-formedness at the shallowest occurrence forbids indices >= its depth
    dmin = min(d for _, d in od)
    auto = idx_same and set(od[0][0]) == set(range(dmin))
    print('  %-6s named args %-45s FO-named: %-5s guards: %s' % (nm, [a for a, _ in on], names_same,
          ('fresh(%s, A)' % ','.join(fresh)) if fresh else ('none' if names_same else '-')))
    print('  %-6s dB args    %-45s FO-dB:    %-5s guard: %s' % ('', [(a, d) for a, d in od], idx_same,
          '-' if not idx_same else ('implied by well-formedness' if auto else 'loose(A) <= %s' % (set(od[0][0]),))))

print('\n(2) which P-occurrences does the FO lgg tie together?  (all pool pairs with (R); keyed by (N_i))')
for nm in SCHEMAS:
    P = pool_for(nm); n = len(SCHEMAS[nm]['args'])
    stats = {}
    for k1, k2 in itertools.combinations(P, 2):
        bs = [P[k1], P[k2]]
        if not pred_R(bs): continue
        Ln = lgg_list([named_instance(nm, b) for b in bs])
        Ld = lgg_list([to_db(instance(nm, b)) for b in bs])
        key = tuple(pred_N(bs, n))
        stats.setdefault(key, {}).setdefault((partition(Ln, nm, 'named'), partition(Ld, nm, 'db')), 0)
        stats[key][(partition(Ln, nm, 'named'), partition(Ld, nm, 'db'))] += 1
    print('  %s  (args %s)' % (nm, SCHEMAS[nm]['args']))
    for key in sorted(stats):
        for (pn, pd), c in stats[key].items():
            print('     N=%-22s named blocks %-22s dB blocks %-22s pairs %d' % (key, pn, pd, c))

print('\n(3) explicit instances of the FO lgg that are NOT schema instances (falsity: hand proofs in notes.md)')
def N(*a): return tuple(a)
TOPn = ('all', ('w9',), ('eq', ('w9',), ('w9',)))
BOTn = ('not', TOPn)
TOPd = to_db(TOP); BOTd = to_db(BOT)
def show_db(t): return pp(from_db(t))
cases = [
    # (schema, encoding, two bodies, assignment to the slot blocks in order of first slot)
    ('EInd', 'named', ('x=x', '¬x∈a'), {1: ('not', ('eq', ('y',), ('y',))), 2: ('all', ('w0',), ('not', ('in', ('w0',), ('x',))))}),
    ('ReplJ', 'named', ('x∈z', '¬x=a'), {1: ('eq', ('y',), ('y',)), 2: ('not', ('eq', ('u',), ('u',)))}),
    ('ReplJ', 'db', ('x∈z', '¬x=a'), {1: BOTd, 2: BOTd, 3: ('eq', ('#1',), ('#1',))}),
    ('Coll', 'db', ('y=x', '¬x=A'), {1: ('eq', ('#0',), ('#0',)), 2: BOTd}),
    ('ReplU', 'db', ('y=x', '¬x=A'), {1: ('eq', ('#0',), ('#1',)), 2: BOTd}),
    ('ReplS', 'db', ('y=x', '¬x=A'), {1: ('eq', ('#0',), ('#1',)), 2: BOTd, 3: BOTd}),
    # guard violations (FO patterns whose guard is dropped)
    ('Sep', 'named', ('x∈z', '¬x=a'), {1: ('not', ('in', ('x',), ('y',)))}),
    ('Sep', 'db', ('x∈z', '¬x=a'), {1: ('not', ('in', ('#0',), ('#1',)))}),
    ('Coll', 'named', ('y=x', '¬x=A'), {1: ('eq', ('y',), ('Y',))}),
    ('ReplS', 'named', ('y=x', '¬x=A'), {1: ('eq', ('y',), ('Y',)), 2: ('not', ('eq', ('u',), ('u',)))}),
]
for nm, enc, (k1, k2), assign in cases:
    P = pool_for(nm)
    bs = [P[k1], P[k2]]
    if enc == 'named':
        L = lgg_list([named_instance(nm, b) for b in bs])
    else:
        L = lgg_list([to_db(instance(nm, b)) for b in bs])
    ns = n_slots(nm); sv = ['s%d' % i for i in range(ns)]
    F = named_frame_term(nm, sv) if enc == 'named' else db_frame_term(nm, sv)
    m = match(F, L)
    blocks = partition(L, nm, enc)
    th = {}
    for bi, bl in enumerate(blocks):
        th[m['s%d' % (bl[0] - 1)][1]] = assign[bi + 1]
    from st_core import fo_subst
    s = fo_subst(L, th)
    is_inst = match(L, s) is not None
    sdb = named_to_db(s) if enc == 'named' else from_db(s)
    genuine = covers(SCHEMAS[nm]['T'], sdb)
    print('  %-6s %-5s data bodies %s, %s; lgg blocks %s' % (nm, enc, k1, k2, blocks))
    print('       instance: %s' % pp(sdb))
    print('       instance of the lgg: %s; sentence: %s; instance of the schema: %s' % (is_inst, is_sentence(sdb), genuine))

print('\n(3b) de Bruijn capture by index shift: Coll with phi(x,y) not mentioning A; the dB lgg ties both occurrences,')
print('     but without the guard loose(A) <= {#0,#1} the index #2 means A at occurrence 1 and Y at occurrence 2')
P = pool_for('Coll'); bs = [P['y=x'], P['x∈y']]
L = lgg_list([to_db(instance('Coll', b)) for b in bs])
blocks = partition(L, 'Coll', 'db')
sv = ['s0', 's1']; m = match(db_frame_term('Coll', sv), L)
s = fo_subst(L, {m['s0'][1]: ('eq', ('#0',), ('#2',))})
sdb = from_db(s)
print('  lgg blocks %s; instance %s; sentence %s; schema instance %s' % (blocks, pp(sdb), is_sentence(sdb), covers(SCHEMAS['Coll']['T'], sdb)))

print('\n(4) EInd in de Bruijn: instances of the FO pattern with well-formed results are exactly the EInd instances')
import random
rng = random.Random(11)
def rand_form(d, depth=0):
    """random de Bruijn formula; d = number of binders in scope (indices < d allowed)"""
    r = rng.random()
    def term():
        opts = [V(k) for k in range(d)] + [Par('a')]
        return rng.choice(opts)
    if depth > 3 or r < 0.35:
        return rng.choice([IN, EQ])(term(), term())
    if r < 0.5: return NOT(rand_form(d, depth + 1))
    if r < 0.75: return rng.choice([AND, OR, IMP, IFF])(rand_form(d, depth + 1), rand_form(d, depth + 1))
    return rng.choice([ALL, EX, EXU])(rand_form(d + 1, depth + 1))
Lg = lgg_list([to_db(instance('EInd', P1)) for P1 in (pool_for('EInd')['x∈x'], pool_for('EInd')['¬x=x'])])
mvar = match(db_frame_term('EInd', ['s0', 's1', 's2']), Lg)['s0'][1]
wf = gen = ill = 0
for _ in range(3000):
    A = rand_form(2)                     # may mention #0 and #1
    s = from_db(fo_subst(Lg, {mvar: to_db(A)}))
    if is_sentence(s):
        wf += 1; gen += covers(SCHEMAS['EInd']['T'], s)
    else:
        ill += 1
print('  3000 random A with loose indices in {#0,#1}: well-formed instances %d, of which EInd instances %d; ill-formed %d' % (wf, gen, ill))

print('\n(5) general only-if (Theorem B1): generic data phi1 = /\\_i z_i=z_i, phi2 = ~phi1; set the lgg slots of one block')
print('    to TOP and all others to BOT: the result is an instance of the lgg but not of the schema')
for nm in SCHEMAS:
    n = len(SCHEMAS[nm]['args'])
    f = EQ(H(0), H(0))
    for i in range(1, n): f = AND(f, EQ(H(i), H(i)))
    bs = [f, NOT(f)]
    for enc in ('named', 'db'):
        if enc == 'named': L = lgg_list([named_instance(nm, b) for b in bs])
        else: L = lgg_list([to_db(instance(nm, b)) for b in bs])
        blocks = partition(L, nm, enc)
        if len(blocks) == 1:
            print('  %-6s %-5s single block (FO pattern)' % (nm, enc)); continue
        ns = n_slots(nm); sv = ['s%d' % i for i in range(ns)]
        F = named_frame_term(nm, sv) if enc == 'named' else db_frame_term(nm, sv)
        m = match(F, L)
        TOPx = ('all', ('w9',), ('eq', ('w9',), ('w9',))) if enc == 'named' else to_db(TOP)
        th = {}
        for bi, bl in enumerate(blocks):
            th[m['s%d' % (bl[0] - 1)][1]] = TOPx if bi == 0 else ('not', TOPx)
        s = fo_subst(L, th)
        sdb = named_to_db(s) if enc == 'named' else from_db(s)
        print('  %-6s %-5s blocks %-22s instance of lgg %s, schema instance %s' % (nm, enc, blocks, match(L, s) is not None,
              covers(SCHEMAS[nm]['T'], sdb)))
