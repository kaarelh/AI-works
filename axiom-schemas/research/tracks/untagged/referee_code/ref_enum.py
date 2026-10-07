# Referee: independent data-directed enumerator of DT° templates covering a finite data set.
# Written independently of dtlib.mincov.  Uses dtlib only for the term representation (tuples), kids/rebuild and
# printing.  Covering is checked with an own implementation: body from a pattern occurrence (abstraction of the
# free bound variables), then verification of every occurrence by own plugging.
import itertools, sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code'); sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code')
from dtlib import kids, rebuild, BINDERS, pp, canon

TERMH = {'0', 'S', '+', '*', 'v', 'p', '#'}

def srt(t):
    return 'T' if t[0] in TERMH else 'F'

def hk(t):
    if t[0] in ('v', 'p', '#'): return t
    return (t[0], len(t))

def child_srt(h):
    return 'T' if h in ('=', 'in', 'S', '+', '*') else 'F'

# --- own de Bruijn utilities
def my_shift(t, j, cut=0):
    if t[0] == 'v': return ('v', t[1] + j) if t[1] >= cut else t
    if t[0] in BINDERS: return (t[0], my_shift(t[1], j, cut + 1))
    ks = kids(t)
    return t if not ks else rebuild(t, [my_shift(k, j, cut) for k in ks])

def my_plug(body, args, j=0):
    if body[0] == 'h': return my_shift(args[body[1]], j)
    if body[0] in BINDERS: return (body[0], my_plug(body[1], args, j + 1))
    ks = kids(body)
    return body if not ks else rebuild(body, [my_plug(k, args, j) for k in ks])

def my_abstract(c, ys, j=0):
    """replace free bound variable ('v', ys[m]) (relative to occurrence context) by hole m; None if other free bv"""
    if c[0] == 'v':
        if c[1] < j: return c
        k = c[1] - j
        return ('h', ys.index(k)) if k in ys else None
    if c[0] in BINDERS:
        b = my_abstract(c[1], ys, j + 1)
        return None if b is None else (c[0], b)
    ks = kids(c)
    if not ks: return c
    out = []
    for k in ks:
        b = my_abstract(k, ys, j)
        if b is None: return None
        out.append(b)
    return rebuild(c, out)

def is_pattern(args):
    return all(a[0] == 'v' for a in args) and len(set(args)) == len(args)

# --- common prefix
class Nd:
    def __init__(self, cols, depth, sort):
        self.cols, self.depth, self.sort = cols, depth, sort
        self.common = all(hk(c) == hk(cols[0]) for c in cols)
        self.kids = []
        if self.common:
            c0 = cols[0]
            d2 = depth + 1 if c0[0] in BINDERS else depth
            ks = [kids(c) for c in cols]
            cs = child_srt(c0[0])
            self.kids = [Nd([k[i] for k in ks], d2, cs) for i in range(len(ks[0]))]

def prefixes(nd, budget):
    """yield (frag, slots, rigid_size); frag has ('SLOT', i)"""
    yield (('SLOT', 0), [nd], 0)
    if not nd.common or budget < 1: return
    c0 = nd.cols[0]
    if not nd.kids:
        yield (c0, [], 1); return
    def comb(i, b):
        if i == len(nd.kids):
            yield ([], [], 0); return
        for f, sl, rs in prefixes(nd.kids[i], b):
            if rs + len(sl) > b: continue
            for f2, sl2, rs2 in comb(i + 1, b - rs - len(sl)):
                yield ([(f, sl)] + f2, sl + sl2, rs + rs2)
    for parts, sl, rs in comb(0, budget - 1):
        out, off = [], 0
        for f, s in parts:
            out.append(reidx(f, off)); off += len(s)
        yield (rebuild(c0, out), sl, rs + 1)

def reidx(f, off):
    if f[0] == 'SLOT': return ('SLOT', f[1] + off)
    ks = kids(f)
    return f if not ks else rebuild(f, [reidx(k, off) for k in ks])

def fill(f, fillers):
    if f[0] == 'SLOT': return fillers[f[1]]
    ks = kids(f)
    return f if not ks else rebuild(f, [fill(k, fillers) for k in ks])

def arg_pool(depth, params, lang, amax):
    base = [('v', k) for k in range(depth)] + [('p', p) for p in params]
    if lang == 'arith':
        base = base + [('0',)]
        pool = list(base)
        if amax >= 2: pool += [('S', t) for t in base]
        return pool
    return base

def body_ok(occs, i):
    """occs: list of (slot_node, args); does a body exist for datum i?  determinate: use a pattern occurrence"""
    pat = [(nd, a) for nd, a in occs if is_pattern(a)]
    if not pat: return None   # not determinate (yet)
    nd, a = pat[0]
    ys = [x[1] for x in a]
    b = my_abstract(nd.cols[i], ys)
    if b is None: return False
    return all(my_plug(b, list(a2)) == nd2.cols[i] for nd2, a2 in occs)

def enum_cover(D, smax, lang, maxar=2, amax=1):
    params = sorted(set(p for d in D for p in _params(d)))
    root = Nd(list(D), 0, 'F')
    found = set()
    for frag, slots, rs in prefixes(root, smax):
        if rs + len(slots) > smax: continue
        opts = []
        for nd in slots:
            pool = arg_pool(nd.depth, params, lang, amax)
            o = []
            for n in range(maxar + 1):
                for args in itertools.product(pool, repeat=n):
                    sz = 1 + sum(_size(x) for x in args)
                    o.append((n, args, sz))
            opts.append(o)
        names, occ, assign = [], {}, [None] * len(slots)
        def ok_name(nm):
            lst = [(slots[k], assign[k][2:]) for k in occ[nm]]
            for i in range(len(D)):
                r = body_ok(lst, i)
                if r is False: return False
            return True
        def dfs(k, used):
            if k == len(slots):
                # determinacy and covering
                for nm in occ:
                    lst = [(slots[kk], assign[kk][2:]) for kk in occ[nm]]
                    if not any(is_pattern(a) for _, a in lst): return
                    for i in range(len(D)):
                        if not body_ok(lst, i): return
                T = fill(frag, assign)
                found.add(canon(T)); return
            nd = slots[k]
            for (n, args, sz) in opts[k]:
                if used + sz + (len(slots) - k - 1) > smax: continue
                cands = [nm for nm, s, a in names if s == nd.sort and a == n]
                new = ('F' if nd.sort == 'F' else 't') + 'z%d' % len(names)
                for nm in cands + [new]:
                    isnew = nm == new
                    assign[k] = ('M', nm) + tuple(args)
                    if isnew: names.append((nm, nd.sort, n)); occ[nm] = []
                    occ[nm].append(k)
                    if ok_name(nm): dfs(k + 1, used + sz)
                    occ[nm].pop()
                    if isnew: names.pop(); del occ[nm]
                    assign[k] = None
        dfs(0, rs)
    return found

def _params(t, acc=None):
    if acc is None: acc = []
    if t[0] == 'p':
        if t[1] not in acc: acc.append(t[1])
        return acc
    for k in kids(t): _params(k, acc)
    return acc

def _size(t): return 1 + sum(_size(k) for k in kids(t))
