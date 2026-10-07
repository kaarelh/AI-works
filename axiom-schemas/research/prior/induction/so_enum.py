# Track C: enumerators of second-order templates in the class SO°:
#   every metavariable occurrence is at a rigid position (not inside another occurrence's arguments) and
#   has metavariable-free arguments (ground terms over 0, S, +, bound variables), arity <= MAXAR.
# (a) data-directed enumeration: all SO° templates of size <= s covering a data set D.
#     Complete by the rigid-prefix lemma (C2): the rigid skeleton of any covering template is a prefix of
#     the common prefix of D, and its flex occurrences sit exactly at the cut points.
# (b) brute-force enumeration of all SO° templates up to a (small) size, for cross-validation of (a).
import itertools
from so_core import *

def term_pool(depth, amax):
    """ground terms over 0, S, add and ('v',k), k<depth, of size <= amax"""
    by = {1: [Z] + [V(k) for k in range(depth)]}
    for n in range(2, amax + 1):
        out = [S(t) for t in by[n - 1]]
        for a in range(1, n - 1):
            b = n - 1 - a
            if b in by:
                out += [add(t, u) for t in by[a] for u in by[b]]
        by[n] = out
    pool = []
    for n in range(1, amax + 1): pool += by.get(n, [])
    return pool

# ------------------------------------------------------------------ common prefix of the data
class Node:
    __slots__ = ('cols', 'sort', 'depth', 'sym', 'kids', 'idx')
    def __init__(self, cols, sort, depth):
        self.cols, self.sort, self.depth = cols, sort, depth
        self.sym, self.kids = None, []

def child_sort(h):
    return 'T' if (h in TERM_HEADS or h == 'eq') else 'F'

def build(cols, sort='F', depth=0):
    nd = Node(cols, sort, depth)
    c0 = cols[0]
    key0 = c0 if c0[0] in ('v', '0') else (c0[0], len(c0))
    same = all((c if c[0] in ('v', '0') else (c[0], len(c))) == key0 for c in cols)
    if same:
        nd.sym = c0[0] if c0[0] != 'v' else c0
        ks = [kids(c) for c in cols]
        cs = child_sort(c0[0])
        dd = depth + 1 if c0[0] in BINDERS else depth
        nd.kids = [build([k[i] for k in ks], cs, dd) for i in range(len(ks[0]))]
    return nd

def prefixes(nd, budget):
    """yield (fragment, slots, minsize): fragment has ('SLOT', i) placeholders indexing slots (preorder)"""
    yield (('SLOT', 0), [nd], 1)
    if nd.sym is None or budget < 1: return
    if isinstance(nd.sym, tuple):          # a common bound-variable leaf ('v',k)
        yield (nd.sym, [], 1); return
    if nd.sym == '0':
        yield (Z, [], 1); return
    def combine(i, budget_left):
        if i == len(nd.kids):
            yield ([], [], 0); return
        for frag, slots, ms in prefixes(nd.kids[i], budget_left):
            if ms > budget_left: continue
            for frags2, slots2, ms2 in combine(i + 1, budget_left - ms):
                yield ([(frag, slots)] + frags2, slots + slots2, ms + ms2)
    for parts, slots, ms in combine(0, budget - 1):
        # reindex placeholders
        out, off = [], 0
        for frag, sl in parts:
            out.append(reindex(frag, off)); off += len(sl)
        yield ((nd.sym,) + tuple(out), slots, ms + 1)

def reindex(frag, off):
    if frag[0] == 'SLOT': return ('SLOT', frag[1] + off)
    if frag[0] in ('v', 'h'): return frag
    return rebuild(frag, [reindex(k, off) for k in kids(frag)])

def fill(frag, fillers):
    if frag[0] == 'SLOT': return fillers[frag[1]]
    if frag[0] in ('v', 'h'): return frag
    return rebuild(frag, [fill(k, fillers) for k in kids(frag)])

def enumerate_covering(D, smax, amax=3, maxar=2, arities_T=(0, 1), arities_F=(0, 1, 2)):
    """all SO° templates of size <= smax covering every sentence of D (canonical, deduplicated)"""
    root = build(list(D))
    pools = {}
    found = set()
    for frag, slots, ms in prefixes(root, smax):
        if ms > smax: continue
        rigid = ms - len(slots)
        # filler options per slot
        nslots = len(slots)
        def opts(nd):
            key = (nd.depth, amax)
            if key not in pools: pools[key] = term_pool(nd.depth, amax)
            pool = pools[key]
            ars = arities_T if nd.sort == 'T' else arities_F
            res = []
            for n in ars:
                if n > maxar: continue
                for args in itertools.product(pool, repeat=n):
                    res.append((n, args, 1 + sum(size(a) for a in args)))
            return res
        slot_opts = [opts(nd) for nd in slots]
        # DFS
        assign = [None] * nslots
        names = []          # list of (name, sort, arity)
        occ = {}            # name -> list of slot indices
        def check(name):
            for i in range(len(D)):
                pairs = [(slots[k].cols[i], assign[k][2:]) for k in occ[name]]
                if not exists_body(pairs): return False
            return True
        def dfs(k, used):
            if k == nslots:
                T = fill(frag, assign)
                found.add(canon(T)); return
            nd = slots[k]
            remaining_min = nslots - k - 1
            for (n, args, sz) in slot_opts[k]:
                if used + sz + remaining_min > smax: continue
                cands = [nm for (nm, srt, ar) in names if srt == nd.sort and ar == n]
                newname = ('P%d' if nd.sort == 'F' else 'f%d') % len(names)
                for nm in cands + [newname]:
                    assign[k] = ('M', nm) + tuple(args)
                    isnew = nm == newname
                    if isnew: names.append((nm, nd.sort, n)); occ[nm] = []
                    occ[nm].append(k)
                    if check(nm):
                        dfs(k + 1, used + sz)
                    occ[nm].pop()
                    if isnew: names.pop(); del occ[nm]
                    assign[k] = None
        dfs(0, rigid)
    return found

# ------------------------------------------------------------------ brute force
def gen_all(smax, amax=2, maxar=2, depth_max=2, heads_F=('eq', 'not', 'and', 'imp', 'all'),
            heads_T=('0', 'S', 'add'), arities_T=(0, 1), arities_F=(0, 1, 2)):
    """all SO° templates (canonical) of size <= smax; metavariables as placeholders, then all sharings"""
    from functools import lru_cache
    pools = {d: term_pool(d, amax) for d in range(depth_max + 1)}
    @lru_cache(maxsize=None)
    def G(sort, n, depth):
        out = []
        # metavariable placeholder
        ars = arities_T if sort == 'T' else arities_F
        for a in ars:
            if a > maxar: continue
            for args in itertools.product(pools[depth], repeat=a):
                if 1 + sum(size(x) for x in args) == n:
                    out.append(('?', sort) + tuple(args))
        if sort == 'T':
            if n == 1:
                out.append(Z); out += [V(k) for k in range(depth)]
            if 'S' in heads_T and n >= 2:
                out += [S(t) for t in G('T', n - 1, depth)]
            if 'add' in heads_T and n >= 3:
                for a in range(1, n - 1):
                    out += [add(t, u) for t in G('T', a, depth) for u in G('T', n - 1 - a, depth)]
        else:
            if 'eq' in heads_F and n >= 3:
                for a in range(1, n - 1):
                    out += [eq(t, u) for t in G('T', a, depth) for u in G('T', n - 1 - a, depth)]
            if 'not' in heads_F and n >= 2:
                out += [NOT(f) for f in G('F', n - 1, depth)]
            for hb in ('and', 'imp'):
                if hb in heads_F and n >= 3:
                    for a in range(1, n - 1):
                        out += [(hb, f, g) for f in G('F', a, depth) for g in G('F', n - 1 - a, depth)]
            if 'all' in heads_F and n >= 2 and depth < depth_max:
                out += [ALL(f) for f in G('F', n - 1, depth + 1)]
        return tuple(out)
    for n in range(1, smax + 1):
        for t in G('F', n, 0):
            for T in name_all(t):
                yield T

def placeholders(t, acc):
    if t[0] == '?': acc.append(t); return
    for k in kids(t) if t[0] not in ('?',) else (): placeholders(k, acc)

def name_all(t):
    """all ways to name the placeholders (sharing only between equal sort & arity), canonical order"""
    ph = []
    def walk(u):
        if u[0] == '?': ph.append(u); return
        if u[0] in ('v', 'h'): return
        for k in kids(u): walk(k)
    walk(t)
    res = []
    def rec(i, labels, names):
        if i == len(ph):
            res.append(list(labels)); return
        srt, ar = ph[i][1], len(ph[i]) - 2
        for j, (s2, a2) in enumerate(names):
            if s2 == srt and a2 == ar:
                labels.append(j); rec(i + 1, labels, names); labels.pop()
        names.append((srt, ar)); labels.append(len(names) - 1)
        rec(i + 1, labels, names)
        labels.pop(); names.pop()
    rec(0, [], [])
    for lab in res:
        it = iter(lab)
        def R(u):
            if u[0] == '?':
                j = next(it)
                nm = ('P%d' if u[1] == 'F' else 'f%d') % j
                return ('M', nm) + u[2:]
            if u[0] in ('v', 'h'): return u
            return rebuild(u, [R(k) for k in kids(u)])
        yield canon(R(t))
