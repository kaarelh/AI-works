# Track "single": INDEPENDENT bounded brute-force enumerator of SO° / DT° templates covering a data
# set D (does not use the feature theory).  Adapted from prior/induction/so_enum.py, generalized to
# term- and formula-valued metavariables of arity <= maxar, constants/parameters, any connectives.
#   Complete for SO° within the bounds (rigid-prefix lemma, prior C2): the rigid skeleton of a
#   covering template is a prefix of C(D) and its metavariable occurrences sit at the cut points.
import itertools
from dtcore import *


def term_pool(depth, amax, consts=('0',), funcs=(('S', 1), ('add', 2))):
    by = {1: [(c,) for c in consts] + [V(k) for k in range(depth)]}
    for n in range(2, amax + 1):
        out = []
        for f, ar in funcs:
            if ar == 1:
                out += [(f, t) for t in by[n - 1]]
            elif ar == 2:
                for a in range(1, n - 1):
                    b = n - 1 - a
                    out += [(f, t, u) for t in by[a] for u in by[b]]
        by[n] = out
    return [t for n in range(1, amax + 1) for t in by[n]]


class Node:
    __slots__ = ('cols', 'sort', 'depth', 'key', 'kids', 'leaf')
    def __init__(self, cols, sort, depth):
        self.cols, self.sort, self.depth = cols, sort, depth
        self.key, self.kids, self.leaf = None, [], None


def build(cols, sort='F', depth=0):
    nd = Node(cols, sort, depth)
    k0 = node_key(cols[0])
    if all(node_key(c) == k0 for c in cols):
        nd.key = k0
        c0 = cols[0]
        if not kids(c0):
            nd.leaf = c0
        else:
            ks = [kids(c) for c in cols]
            cs = child_sort(c0[0])
            dd = depth + 1 if c0[0] in BINDERS else depth
            nd.leaf = c0[0]
            nd.kids = [build([k[i] for k in ks], cs, dd) for i in range(len(ks[0]))]
    return nd


def prefixes(nd, budget):
    """yield (fragment, slots, size): fragment has ('SLOT', i) placeholders"""
    yield (('SLOT', 0), [nd], 1)
    if nd.key is None or budget < 1:
        return
    if not nd.kids:
        yield (nd.leaf, [], 1)
        return
    def combine(i, left):
        if i == len(nd.kids):
            yield ([], [], 0)
            return
        for frag, slots, ms in prefixes(nd.kids[i], left):
            if ms > left:
                continue
            for frags2, slots2, ms2 in combine(i + 1, left - ms):
                yield ([(frag, slots)] + frags2, slots + slots2, ms + ms2)
    for parts, slots, ms in combine(0, budget - 1):
        out, off = [], 0
        for frag, sl in parts:
            out.append(reindex(frag, off))
            off += len(sl)
        yield ((nd.leaf,) + tuple(out), slots, ms + 1)


def reindex(frag, off):
    if frag[0] == 'SLOT':
        return ('SLOT', frag[1] + off)
    if frag[0] in ('v', 'h'):
        return frag
    return rebuild(frag, [reindex(k, off) for k in kids(frag)])


def fill(frag, fillers):
    if frag[0] == 'SLOT':
        return fillers[frag[1]]
    if frag[0] in ('v', 'h'):
        return frag
    return rebuild(frag, [fill(k, fillers) for k in kids(frag)])


def enumerate_covering(D, smax, amax=2, arities_T=(0, 1), arities_F=(0, 1, 2), consts=('0',),
                       funcs=(('S', 1), ('add', 2)), determinate_only=True):
    """all SO° (or DT°) templates of size <= smax covering every sentence of D, canonical"""
    D = list(D)
    root = build(D)
    pools = {}
    found = set()
    for frag, slots, ms in prefixes(root, smax):
        if ms > smax:
            continue
        rigid = ms - len(slots)
        nslots = len(slots)
        def opts(nd):
            key = (nd.depth, amax)
            if key not in pools:
                pools[key] = term_pool(nd.depth, amax, consts, funcs)
            pool = pools[key]
            ars = arities_T if nd.sort == 'T' else arities_F
            res = []
            for n in ars:
                for args in itertools.product(pool, repeat=n):
                    res.append((n, args, 1 + sum(size(a) for a in args)))
            return res
        slot_opts = [opts(nd) for nd in slots]
        assign = [None] * nslots
        names = []
        occ = {}
        def check(name):
            for i in range(len(D)):
                pairs = [(slots[k].cols[i], assign[k][2:]) for k in occ[name]]
                if not exists_body(pairs):
                    return False
            return True
        def dfs(k, used):
            if k == nslots:
                T = fill(frag, assign)
                if (not determinate_only) or is_DT0(T):
                    found.add(canon(T))
                return
            nd = slots[k]
            remaining_min = nslots - k - 1
            for (n, args, sz) in slot_opts[k]:
                if used + sz + remaining_min > smax:
                    continue
                cands = [nm for (nm, srt, ar) in names if srt == nd.sort and ar == n]
                newname = ('P%d' if nd.sort == 'F' else 'f%d') % len(names)
                for nm in cands + [newname]:
                    assign[k] = ('M', nm) + tuple(args)
                    isnew = nm == newname
                    if isnew:
                        names.append((nm, nd.sort, n))
                        occ[nm] = []
                    occ[nm].append(k)
                    if check(nm):
                        dfs(k + 1, used + sz)
                    occ[nm].pop()
                    if isnew:
                        names.pop()
                        del occ[nm]
                    assign[k] = None
        dfs(0, rigid)
    return found


def minimal_elements(Ts):
    reps = []
    for T in Ts:
        if any(subsumes(T, R) and subsumes(R, T) for R in reps):
            continue
        reps.append(T)
    mins = [T for T in reps if not any(subsumes(T, U) and not subsumes(U, T) for U in reps)]
    return mins, reps
