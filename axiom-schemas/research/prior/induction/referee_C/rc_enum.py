# Referee C: independent data-directed enumerator of covering templates (SO°-style fillers, i.e.
# metavariable-free arguments), written from scratch.  Optional 'nested' fillers F(G(..)) are
# handled separately in r3/r6.
import itertools
from rc_core import *

def term_pool(D, amax, mul=False):
    """terms over 0, S, +, (*), outer variables v_0..v_{D-1}, of size <= amax"""
    by = {1: [Z()] + [V(k) for k in range(D)]}
    for n in range(2, amax + 1):
        out = [S(t) for t in by[n - 1]]
        for a in range(1, n - 1):
            b = n - 1 - a
            out += [ADD(t, u) for t in by[a] for u in by[b]]
            if mul: out += [MUL(t, u) for t in by[a] for u in by[b]]
        by[n] = out
    return [t for n in range(1, amax + 1) for t in by[n]]

class Node:
    def __init__(self, cols, sort, D):
        self.cols, self.sort, self.D = cols, sort, D
        self.sym, self.kids = None, []

def common(cols, sort='F', D=0):
    nd = Node(cols, sort, D)
    c0 = cols[0]
    def key(c):
        if c[0] in ('v', '0'): return c
        if c[0] == 'C': return ('C', c[1], len(c[2]))
        return (c[0], len(children(c)))
    if all(key(c) == key(c0) for c in cols):
        nd.sym = c0
        ch = [children(c) for c in cols]
        if c0[0] in ('=', '+', '*', 'S'): cs = 'T'
        elif c0[0] in FORMH: cs = 'F'
        else: cs = 'T'
        nD = D + 1 if c0[0] in BIND else D
        nd.kids = [common([x[i] for x in ch], cs, nD) for i in range(len(ch[0]))]
    return nd

def prefixes(nd):
    """yield (fragment, cutnodes): fragment contains ('SLOT', i)"""
    yield (('SLOT', 0), [nd])
    if nd.sym is None: return
    if not nd.kids:
        yield (nd.sym, []); return
    lists = [list(prefixes(k)) for k in nd.kids]
    for combo in itertools.product(*lists):
        frags, cuts, off = [], [], 0
        for frag, cs in combo:
            frags.append(shift_slots(frag, off)); off += len(cs); cuts += cs
        yield (remake(nd.sym, frags), cuts)

def shift_slots(f, off):
    if f[0] == 'SLOT': return ('SLOT', f[1] + off)
    if f[0] in ('v', 'h', '0'): return f
    return remake(f, [shift_slots(c, off) for c in children(f)])

def fill(f, fillers):
    if f[0] == 'SLOT': return fillers[f[1]]
    if f[0] in ('v', 'h', '0'): return f
    return remake(f, [fill(c, fillers) for c in children(f)])

def frag_size(f):
    if f[0] == 'SLOT': return 0
    return 1 + sum(frag_size(c) for c in children(f))

def enum_covering(D, smax, amax=3, ar_F=(0, 1, 2), ar_T=(0, 1), mul=False, require=None):
    """all templates (metavariable-free args, any sharing) of size <= smax covering every datum in D.
    Covering is decided exactly by projection/imitation per metavariable (pruned incrementally).
    require: optional predicate on finished templates (e.g. is_DT)."""
    root_ = common(list(D))
    pools = {}
    out = set()
    for frag, cuts in prefixes(root_):
        base = frag_size(frag)
        if base + len(cuts) > smax: continue
        opts = []
        for nd in cuts:
            if nd.D not in pools: pools[nd.D] = term_pool(nd.D, amax, mul)
            ars = ar_F if nd.sort == 'F' else ar_T
            o = []
            for n in ars:
                for args in itertools.product(pools[nd.D], repeat=n):
                    o.append((tuple(args), 1 + sum(size(a) for a in args)))
            o.sort(key=lambda x: x[1])
            opts.append(o)
        k = len(cuts)
        assign = [None] * k
        names = []           # (name, sort, arity)
        occ = {}
        def ok(name):
            for i in range(len(D)):
                if not exists_body([(cuts[j].cols[i], assign[j][2], cuts[j].D) for j in occ[name]]):
                    return False
            return True
        def dfs(i, used):
            if i == k:
                T = fill(frag, assign)
                if require is None or require(T): out.add(canon(T))
                return
            nd = cuts[i]
            for (args, sz) in opts[i]:
                if used + sz + (k - i - 1) > smax: break
                n = len(args)
                cands = [nm for (nm, s_, a_) in names if s_ == nd.sort and a_ == n]
                new = ('P%d' if nd.sort == 'F' else 'f%d') % len(names)
                for nm in cands + [new]:
                    if nm == new:
                        names.append((nm, nd.sort, n)); occ[nm] = []
                    occ[nm].append(i)
                    assign[i] = ('M', nm, args)
                    if ok(nm): dfs(i + 1, used + sz)
                    occ[nm].pop()
                    if nm == new:
                        names.pop(); del occ[nm]
                    assign[i] = None
        dfs(0, base)
    return out

def canon(T):
    ren = {}
    cnt = [0, 0]
    def go(t):
        if t[0] == 'M':
            if t[1] not in ren:
                if t[1][0].isupper(): ren[t[1]] = 'P%d' % cnt[0]; cnt[0] += 1
                else: ren[t[1]] = 'f%d' % cnt[1]; cnt[1] += 1
            return ('M', ren[t[1]], tuple(go(a) for a in t[2]))
        if t[0] in ('v', 'h', '0'): return t
        return remake(t, [go(c) for c in children(t)])
    return go(T)
