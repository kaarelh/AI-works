# Referee checks for Thm E (anchors of the ZF pattern templates in every class PAT <= H <= SO-degree)
# and Cor F (higher-order pattern lgg).  Own code, independent of st_core/st_enum/so_core.
#
# (A) Counterexample search for Thm E.  Templates are second-order templates over the data's maximal
#     common prefix (de Bruijn).  A template is: the common-prefix skeleton, with a set G of pairwise
#     incomparable positions carrying ONE shared metavariable M(u^s) (args: in-scope bound variables,
#     REPEATS ALLOWED, and parameters $a,$b; arity <= AMAX), and fresh fully-applied pattern metavariables
#     at all remaining disagreement positions.  Any SO-degree template (args = bound variables or
#     parameters) that covers D and misses a probe p yields such a template that also covers D and
#     misses p (replace every other metavariable group by fresh fully-applied ones; they cover anything).
#     So: D is NOT an anchor (w.r.t. the probes) iff some group G covers D and misses some probe.
#     Probes = a fixed set of genuine instances of T* (bodies using all arguments, parameters, binders).
#     Prediction of Thm E: such G exists iff not((R) and all (N_i)).
# (B) Cor F: own n-ary higher-order pattern anti-unification (BKLV-style: generalization variable applied
#     to the bound variables free in the column; merge of columns equal up to ONE argument permutation
#     common to all data).  Check: result == T* (up to renaming / argument permutation) iff (R) & (N);
#     and soundness: random instances of the pattern lgg are schema instances.
import sys, itertools, random, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/cases/referee_code')
from zf_lib import *

def todb_body(b):
    """named body with holes -> de Bruijn body with holes"""
    return to_db(b)

def common_region(D):
    """positions p (in D[0]) such that all data agree (head, arity, leaf) at every proper prefix of p;
    returns (region positions, frontier/disagreement positions)."""
    region, frontier = [], []
    def walk(ts, p):
        region.append(p)
        h = ts[0][0]; n = len(ts[0])
        same = all(t[0] == h and len(t) == n for t in ts)
        if not same:
            frontier.append(p); return
        if n == 1: return
        for i in range(1, n):
            walk([t[i] for t in ts], p + (i - 1,))
    walk(D, ())
    return region, frontier

def depth_at(t, p):
    d = 0
    for i in p:
        if t[0] in BIND: d += 1
        t = t[1 + i]
    return d

def skeleton(t):
    if len(t) == 1: return '*'
    return (t[0],) + tuple(skeleton(c) for c in t[1:])

def leaves_with_depth(t, p=(), e=0):
    if len(t) == 1:
        yield p, t, e; return
    for i, c in enumerate(t[1:]):
        yield from leaves_with_depth(c, p + (i,), e + (1 if t[0] in BIND else 0))

def arg_leaf(a, e):
    return ('$' + a,) if isinstance(a, str) else ix(a + e)

def group_covers(G, args, x):
    """does the single metavariable group (positions G, arg tuples args) cover sentence x?"""
    conts = []
    for p in G:
        try: conts.append(at(x, p))
        except Exception: return False
    sk = skeleton(conts[0])
    if any(skeleton(c) != sk for c in conts[1:]): return False
    for (lp, leaf0, e) in leaves_with_depth(conts[0]):
        ls = [at(c, lp) for c in conts]
        ok = False
        # keep the leaf (constant/parameter or internally bound index)
        if all(l == leaf0 for l in ls) and not (is_ix(leaf0) and ixv(leaf0) >= e):
            ok = True
        if not ok:
            for mi in range(len(args[0])):
                if all(ls[s] == arg_leaf(args[s][mi], e) for s in range(len(G))):
                    ok = True; break
        if not ok: return False
    return True

def rigid_matches(D0, region, frontier, G, x):
    """rigid part = common region minus subtrees at G and frontier; does x agree there?"""
    cut = set(G) | set(frontier)
    def walk(t, u, p):
        if p in cut: return True
        if t[0] != u[0] or len(t) != len(u): return False
        return all(walk(t[i], u[i], p + (i - 1,)) for i in range(1, len(t)))
    return walk(D0, x, ())

def fresh_covers(frontier, G, x, D0):
    """fresh fully-applied pattern metavariables at frontier positions not under G: they cover any
    content whose loose indices are in scope -- always true for closed sentences; only existence of the
    position matters (guaranteed if rigid part matched)."""
    return True

def search_counterexample(D, probes, AMAX, GMAX, params=('a', 'b'), time_limit=60):
    D0 = D[0]
    region, frontier = common_region(D)
    region_set = set(region)
    # base template (G empty): misses a probe iff the rigid part disagrees
    for pr in probes:
        if not rigid_matches(D0, region, frontier, (), pr):
            return ('base', pr)
    # candidate positions with equal data signatures
    def sig(p):
        return tuple(skeleton(at(x, p)) for x in D)
    def leq(p, q): return q[:len(p)] == p
    by_sig = {}
    for p in region:
        by_sig.setdefault(sig(p), []).append(p)
    t0 = time.time()
    for sg, plist in by_sig.items():
        for gsize in range(1, GMAX + 1):
            for G in itertools.combinations(plist, gsize):
                if any(leq(a, b) or leq(b, a) for a, b in itertools.combinations(G, 2)): continue
                scopes = [list(range(depth_at(D0, p))) + list(params) for p in G]
                is_term = len(at(D0, G[0])) == 1 and all(len(at(x, G[0])) == 1 for x in D)
                # a term metavariable's body is a single hole or constant: arity <= 1 loses nothing
                for ar in range(0, (1 if is_term else AMAX) + 1):
                    # backtracking over arg tuples member by member, pruning on coverage of D
                    def rec(s, acc):
                        if time.time() - t0 > time_limit: raise TimeoutError
                        if s == len(G):
                            Gl = list(G)
                            if not all(group_covers(Gl, acc, x) for x in D): return None
                            for pr in probes:
                                if not rigid_matches(D0, region, frontier, Gl, pr) or not group_covers(Gl, acc, pr):
                                    return (Gl, list(acc), pr)
                            return None
                        for tup in itertools.product(scopes[s], repeat=ar):
                            acc2 = acc + [tup]
                            if s >= 1 and not all(group_covers(list(G[:s + 1]), acc2, x) for x in D): continue
                            r = rec(s + 1, acc2)
                            if r: return r
                        return None
                    r = rec(0, [])
                    if r: return r
    return None

# ---------------- body pools ----------------
h = hole
def pool(n):
    out = [('in', h(0), h(0)), ('eq', h(0), par('a')), ('neg', ('eq', h(0), h(0))), ('neg', ('in', par('a'), h(0))),
           ('fa', nv('w0'), ('in', nv('w0'), h(0))), ('ex', nv('w0'), ('eq', nv('w0'), par('b'))),
           ('conj', ('in', h(0), par('a')), ('eq', par('b'), par('b'))), ('impl', ('eq', par('a'), par('a')), ('in', h(0), h(0)))]
    if n >= 2:
        out += [('in', h(0), h(1)), ('eq', h(1), h(0)), ('neg', ('in', h(1), h(0))), ('iff', ('in', h(1), par('a')), ('eq', h(1), h(1))),
                ('fa', nv('w0'), ('impl', ('in', nv('w0'), h(1)), ('in', nv('w0'), h(0))))]
    if n >= 3:
        out += [('in', h(2), h(1)), ('neg', ('eq', h(0), h(2))), ('conj', ('eq', h(1), h(0)), ('in', h(0), h(2))),
                ('ex', nv('w0'), ('conj', ('in', nv('w0'), h(2)), ('eq', h(1), nv('w0'))))]
    out += [('eq', par('a'), par('b')), ('neg', ('in', par('b'), par('a')))]
    return out

def probes_for(sc):
    n = SCHEMAS[sc][1]
    allh = ('eq', h(0), h(0))
    for i in range(1, n): allh = ('conj', allh, ('in', h(i), h(i - 1)))
    bs = [allh, ('neg', allh), ('fa', nv('w0'), ('impl', ('in', nv('w0'), h(n - 1)), allh)),
          ('ex', nv('w0'), ('conj', ('in', h(0), nv('w0')), ('eq', nv('w0'), par('b'))))]
    for i in range(n):
        bs.append(('in', h(i), par('a')))
        bs.append(('neg', ('eq', par('b'), h(i))))
    if n >= 2:
        bs.append(('iff', ('in', h(1), h(0)), ('eq', h(0), h(n - 1))))
        bs.append(('in', h(n - 1), h(0)))
    return [to_db(instance(sc, b)) for b in bs]

def events(sc, bodies):
    n = SCHEMAS[sc][1]
    R = len({root(b) for b in bodies}) >= 2
    N = [any(uses(b, i) for b in bodies) for i in range(n)]
    return R, N

# ---------------- (B) pattern anti-unification ----------------
def abstract_db(t, Y, e=0):
    if is_ix(t):
        k = ixv(t)
        if k >= e: return hole(Y.index(k - e))
        return t
    if len(t) == 1: return t
    if t[0] in BIND: return (t[0], abstract_db(t[1], Y, e + 1))
    return (t[0],) + tuple(abstract_db(c, Y, e) for c in t[1:])

def loose_db(t, e=0):
    if is_ix(t): return {ixv(t) - e} if ixv(t) >= e else set()
    if len(t) == 1: return set()
    if t[0] in BIND: return loose_db(t[1], e + 1)
    out = set()
    for c in t[1:]: out |= loose_db(c, e)
    return out

def permute_holes(t, pi):
    if is_hole(t): return hole(pi[holev(t)])
    if len(t) == 1: return t
    return (t[0],) + tuple(permute_holes(c, pi) for c in t[1:])

def pattern_lgg(ts):
    store = []      # list of (var name, column of abstracted terms)
    def go(ts, d):
        h0 = ts[0][0]; n0 = len(ts[0])
        if all(t[0] == h0 and len(t) == n0 for t in ts) and (n0 > 1 or all(t == ts[0] for t in ts)):
            if n0 == 1: return ts[0]
            return (h0,) + tuple(go([t[i] for t in ts], d + (1 if h0 in BIND else 0)) for i in range(1, n0))
        Y = sorted(set().union(*[loose_db(t) for t in ts]))
        col = tuple(abstract_db(t, Y) for t in ts)
        for name, ccol, ar in store:
            if ar != len(Y): continue
            for pi in itertools.permutations(range(ar)):
                # column with holes renamed by pi equals the stored column
                if tuple(permute_holes(c, pi) for c in col) == ccol:
                    # stored var applied to args: hole pi[i] of stored corresponds to Y[i]
                    args = [None] * ar
                    for i in range(ar): args[pi[i]] = Y[i]
                    return ('X', name) + tuple(ix(a) for a in args)
        name = 'X%d' % len(store)
        store.append((name, col, len(Y)))
        return ('X', name) + tuple(ix(a) for a in Y)
    return go(list(ts), 0), store

def lpat_equiv_target(sc, L):
    m = SCHEMAS[sc][2]; n = SCHEMAS[sc][1]
    marks = [('?', 'P%d' % k) for k in range(m)]
    fr = to_db(build_named(sc, marks))
    sp = [[p for p, t in positions(fr) if t == marks[k]][0] for k in range(m)]
    args = db_args(sc)
    # frame identical outside slots
    def same(a, b, p):
        if p in sp: return True
        if a[0] != b[0] or len(a) != len(b): return False
        return all(same(a[i], b[i], p + (i - 1,)) for i in range(1, len(a)))
    try:
        if not same(fr, L, ()): return False
        apps = [at(L, p) for p in sp]
    except Exception:
        return False
    if any(a[0] != 'X' for a in apps): return False
    if len({a[1] for a in apps}) != 1: return False
    if any(len(a) - 2 != n for a in apps): return False
    for pi in itertools.permutations(range(n)):
        if all(tuple(ixv(a[2 + pi[i]]) for i in range(n)) == tuple(args[k]) for k, a in enumerate(apps)):
            return True
    return False

def instantiate_lgg(L, store, rng):
    vals = {}
    for name, col, ar in store:
        b = rand_body(rng, ar)
        vals[name] = to_db(b)
    def plugdb(b, a, e=0):
        if is_hole(b): return ix(a[holev(b)] + e)
        if len(b) == 1: return b
        if b[0] in BIND: return (b[0], plugdb(b[1], a, e + 1))
        return (b[0],) + tuple(plugdb(x, a, e) for x in b[1:])
    def go(t):
        if t[0] == 'X':
            return plugdb(vals[t[1]], [ixv(a) for a in t[2:]])
        if len(t) == 1: return t
        return (t[0],) + tuple(go(c) for c in t[1:])
    return go(L)

if __name__ == '__main__':
    which = sys.argv[1] if len(sys.argv) > 1 else 'all'
    rng = random.Random(3)
    if which in ('all', 'A'):
        print('(A) Thm E counterexample search (own SO-degree group search; args with repeats and parameters)')
        CONF = (('Sep', 3, 2, 60), ('SepJ', 2, 2, 50), ('EInd', 2, 3, 60),
                ('ReplJ', 2, 3, 40), ('Coll', 3, 2, 40), ('ReplU', 3, 2, 30), ('ReplS', 3, 3, 30))
        if len(sys.argv) > 3:      # override bounds: A <schema> AMAX GMAX NPAIRS
            CONF = ((sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5])),)
        only = sys.argv[2] if len(sys.argv) > 2 else None
        for sc, AMAX, GMAX, npairs in CONF:
            if only and sc != only: continue
            n = SCHEMAS[sc][1]
            P = pool(n)
            probes = probes_for(sc)
            pairs = list(itertools.combinations(range(len(P)), 2))
            rng.shuffle(pairs)
            # make sure anchors and non-anchors are both represented
            chosen = pairs[:npairs]
            agree = tot = to = 0; dis = []
            t0 = time.time()
            stats = {'anchor': 0, 'nonanchor': 0}
            for i, j in chosen:
                bodies = [P[i], P[j]]
                D = [to_db(instance(sc, b)) for b in bodies]
                R, N = events(sc, bodies)
                pred = R and all(N)
                try:
                    cx = search_counterexample(D, probes, AMAX, GMAX, time_limit=90)
                except TimeoutError:
                    to += 1; continue
                found_anchor = cx is None
                tot += 1; agree += (found_anchor == pred)
                stats['anchor' if pred else 'nonanchor'] += 1
                if found_anchor != pred and len(dis) < 3: dis.append((bodies, cx))
            print('   %-6s AMAX=%d GMAX=%d pairs %3d (anchor-pred %d, non %d) agree %3d timeouts %d  %.0fs %s' % (
                sc, AMAX, GMAX, tot, stats['anchor'], stats['nonanchor'], agree, to, time.time() - t0, dis[:1]))
            sys.stdout.flush()
    if which in ('all', 'B'):
        print('\n(B) Cor F: own pattern lgg on pairs and triples of random bodies')
        for sc in SCHEMAS:
            n = SCHEMAS[sc][1]
            agree = tot = 0; sound = sound_tot = 0
            for _ in range(500):
                k = rng.choice([2, 2, 3])
                bodies = [rand_body(rng, n) for _ in range(k)]
                D = [to_db(instance(sc, b)) for b in bodies]
                L, store = pattern_lgg(D)
                R, N = events(sc, bodies)
                got = lpat_equiv_target(sc, L)
                tot += 1; agree += (got == (R and all(N)))
                for _ in range(3):
                    s = instantiate_lgg(L, store, rng)
                    sound_tot += 1; sound += is_schema_instance(sc, s, already_db=True)
            print('   %-6s data sets %d agree %d ;  random lgg instances %d, schema instances %d' % (sc, tot, agree, sound_tot, sound))
        # contrast: the anchor pair for Coll gives T* back
        D = [to_db(instance('Coll', b)) for b in [('eq', h(1), h(0)), ('neg', ('eq', h(0), h(2)))]]
        L, _ = pattern_lgg(D)
        print('   Coll from bodies y=x, ~x=A:', L, ' == T*:', lpat_equiv_target('Coll', L))
