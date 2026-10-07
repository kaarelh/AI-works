# Track "cases": data-directed enumeration of the SO-degree / DT-degree templates (language {in,=})
# that cover a finite set D of sentences (adapted from prior/induction/so_enum.py).
#
# Completeness (proved in notes.md, Part 2(e), Lemmas E1-E3):
#   * rigid-prefix lemma: the rigid skeleton of a covering template is a prefix of the common prefix C(D),
#     with metavariable occurrences exactly at its cut points (prior C2(a));
#   * term metavariables at positions where all data agree can be eliminated (their value is forced to a
#     projection/the common symbol); the result still covers D and is a specialisation;
#   * in DT-degree, arguments whose hole is unused by the (unique) bodies can be deleted; so arity <= the
#     largest number of free context variables of a slot content (<= 3 for every frame here).
# So for DT-degree with MAXAR = 3 the enumeration is complete up to these specialisations, which is all an
# anchor check needs.  For SO-degree (no determinacy) the arity bound 3 is a genuine restriction.
import itertools
from st_core import *

class Node:
    __slots__ = ('cols', 'sort', 'depth', 'sym', 'kids')
    def __init__(self, cols, sort, depth):
        self.cols, self.sort, self.depth, self.sym, self.kids = cols, sort, depth, None, []

def child_sort(h): return 'T' if h in ('in', 'eq') else 'F'

def build(cols, sort='F', depth=0):
    nd = Node(cols, sort, depth)
    c0 = cols[0]
    def key(c): return c if c[0] in ('v', 'p') else (c[0], len(c))
    if all(key(c) == key(c0) for c in cols):
        nd.sym = c0 if c0[0] in ('v', 'p') else c0[0]
        if c0[0] not in ('v', 'p'):
            ks = [kids(c) for c in cols]
            dd = depth + 1 if c0[0] in BINDERS else depth
            cs = child_sort(c0[0])
            nd.kids = [build([k[i] for k in ks], cs, dd) for i in range(len(ks[0]))]
    return nd

def prefixes(nd):
    """yield (fragment, slots); fragment has ('SLOT', i) placeholders"""
    if nd.sort == 'T':
        if nd.sym is not None:            # common term leaf: keep (term-metavariable elimination lemma)
            yield (nd.sym, []); return
        yield (('SLOT', 0), [nd]); return
    yield (('SLOT', 0), [nd])
    if nd.sym is None: return
    def combine(i):
        if i == len(nd.kids):
            yield [], []; return
        for frag, sl in prefixes(nd.kids[i]):
            for frags2, sl2 in combine(i + 1):
                yield [(frag, sl)] + frags2, sl + sl2
    for parts, sl in combine(0):
        out, off = [], 0
        for frag, s2 in parts:
            out.append(reindex(frag, off)); off += len(s2)
        yield ((nd.sym,) + tuple(out), sl)

def reindex(frag, off):
    if frag[0] == 'SLOT': return ('SLOT', frag[1] + off)
    if frag[0] in ('v', 'p', 'h'): return frag
    return rebuild(frag, [reindex(k, off) for k in kids(frag)])

def fill(frag, fillers):
    if frag[0] == 'SLOT': return fillers[frag[1]]
    if frag[0] in ('v', 'p', 'h'): return frag
    return rebuild(frag, [fill(k, fillers) for k in kids(frag)])

def arg_tuples(depth, maxar, distinct_only):
    out = []
    vs = [V(k) for k in range(depth)]
    for n in range(0, maxar + 1):
        it = itertools.permutations(vs, n) if distinct_only else itertools.product(vs, repeat=n)
        out += [tuple(t) for t in it]
    return out

def enumerate_covering(D, mode='DT', maxar=3, target=None, stop_at_bad=False):
    """yield all covering templates (canonical); mode 'DT' keeps determinate ones only.
    If target is given, returns (n_total, n_good, first_bad)."""
    root = build(list(D))
    found = set()
    n_tot = n_good = 0
    first_bad = None
    for frag, slots in prefixes(root):
        ns = len(slots)
        opts = [arg_tuples(nd.depth, maxar, False) for nd in slots]
        assign = [None] * ns
        names = []           # (name, sort, arity)
        occ = {}
        def check(nm):
            for i in range(len(D)):
                pairs = [(slots[k].cols[i], assign[k][2:]) for k in occ[nm]]
                if not exists_body(pairs): return False
            return True
        res = []
        def dfs(k):
            if k == ns:
                T = canon(fill(frag, assign))
                res.append(T); return
            nd = slots[k]
            for args in opts[k]:
                n = len(args)
                cands = [nm for (nm, s, ar) in names if s == nd.sort and ar == n]
                newname = ('P%d' if nd.sort == 'F' else 'f%d') % len(names)
                for nm in cands + [newname]:
                    assign[k] = ('M', nm) + args
                    isnew = nm == newname
                    if isnew: names.append((nm, nd.sort, n)); occ[nm] = []
                    occ[nm].append(k)
                    if check(nm): dfs(k + 1)
                    occ[nm].pop()
                    if isnew: names.pop(); del occ[nm]
                    assign[k] = None
        dfs(0)
        for T in res:
            if T in found: continue
            found.add(T)
            if mode == 'DT' and not is_determinate(T): continue
            n_tot += 1
            if target is not None:
                if subsumes(T, target): n_good += 1
                elif first_bad is None:
                    first_bad = T
                    if stop_at_bad: return n_tot, n_good, first_bad
    return n_tot, n_good, first_bad

# ------------------------------------------------------------------ reduced DT-degree enumeration (SOCL-style)
# Every covering DT-degree template T is a specialisation-wise *above* one produced here (Lemmas E1-E4 in
# notes.md): common-position term metavariables eliminated; each metavariable has an 'own' pattern
# occurrence whose arguments are exactly the context variables free in some datum's content there (sorted);
# every other occurrence is 'derived', with arguments forced by the data.  Hence: D is an anchor in
# DT-degree iff every template produced here is >= T*, and a bad template exists iff a bad one is produced.
def _solve_derived(bodies_pi, cols_sigma, nh):
    """find u (tuple of bound variables at sigma) with plug(body_j, u) == col_j for all j, or None"""
    u = [None] * nh
    def walk(b, c, d):
        h = b[0]
        if h == 'h':
            if c[0] != 'v' or c[1] < d: return False
            val = ('v', c[1] - d)
            if u[b[1]] is None: u[b[1]] = val
            return u[b[1]] == val
        if h != c[0] or len(b) != len(c): return False
        if h in ('v', 'p'): return b == c
        dd = d + 1 if h in BINDERS else d
        return all(walk(x, y, dd) for x, y in zip(kids(b), kids(c)))
    for b, c in zip(bodies_pi, cols_sigma):
        if not walk(b, c, 0): return None
    if any(x is None for x in u): return None
    if not all(plug(b, u) == c for b, c in zip(bodies_pi, cols_sigma)): return None
    return tuple(u)

def enumerate_dt_reduced(D, target=None):
    root = build(list(D))
    n_tot = n_good = 0
    first_bad = None
    seen = set()
    for frag, slots in prefixes(root):
        ns = len(slots)
        ys, bodies = [], []
        for nd in slots:
            fv = set()
            for c in nd.cols: fv |= loose(c)
            y = sorted(fv)
            ys.append(y)
            bodies.append([abstract(c, y) for c in nd.cols])
        # term slots need a body for every datum (projection or common parameter): abstract always works
        opts = []
        for s in range(ns):
            o = ['own']
            for p in range(ns):
                if p == s or slots[p].sort != slots[s].sort: continue
                u = _solve_derived(bodies[p], slots[s].cols, len(ys[p]))
                if u is not None: o.append((p, u))
            opts.append(o)
        for choice in itertools.product(*opts):
            if any(ch != 'own' and choice[ch[0]] != 'own' for ch in choice): continue
            fillers = []
            for s, ch in enumerate(choice):
                if ch == 'own':
                    nm = ('P%d' if slots[s].sort == 'F' else 'f%d') % s
                    fillers.append(('M', nm) + tuple(V(k) for k in ys[s]))
                else:
                    p, u = ch
                    nm = ('P%d' if slots[p].sort == 'F' else 'f%d') % p
                    fillers.append(('M', nm) + u)
            T = canon(fill(frag, fillers))
            if T in seen: continue
            seen.add(T)
            n_tot += 1
            if target is not None:
                if subsumes(T, target): n_good += 1
                elif first_bad is None: first_bad = T
    return n_tot, n_good, first_bad

def most_specific_own(D):
    """the template on the maximal common prefix C(D) with an own pattern filler at every disagreement slot
    (a covering DT-degree template; used to certify non-anchors when (R) fails)"""
    root = build(list(D))
    def go(nd):
        if nd.sym is None:
            fv = set()
            for c in nd.cols: fv |= loose(c)
            ys = sorted(fv)
            nm = ('P%d' if nd.sort == 'F' else 'f%d') % go.k; go.k += 1
            return ('M', nm) + tuple(V(k) for k in ys)
        if isinstance(nd.sym, tuple): return nd.sym
        return (nd.sym,) + tuple(go(k) for k in nd.kids)
    go.k = 0
    return canon(go(root))
