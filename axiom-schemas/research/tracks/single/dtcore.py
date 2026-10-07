# Track "single": core library for determinate second-order templates (class DT°).
#
# Object language (first-order, de Bruijn INDICES for bound variables):
#   terms     ('0',) ('pa',) ('pb',) ('pc',)     constants; pa,pb,pc are free PARAMETERS (closure-normal
#                                                form: parameters behave as constants of the signature)
#             ('S',t) ('add',a,b) ('mul',a,b) ('v',k)   [k = de Bruijn index]
#   formulas  ('eq',a,b) ('mem',a,b) ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('iff',f,g)
#             ('all',f) ('ex',f)
# Metavariable bodies use holes ('h',m) for the m-th lambda-bound argument; a body is closed except
# for holes.  Templates contain metavariable occurrences ('M', name, arg1..argn); name[0] uppercase
# -> formula-valued (iota^n -> o), lowercase -> term-valued (iota^n -> iota).  DT° = arguments are
# metavariable-free and every metavariable has a pattern occurrence (args pairwise distinct bound
# variables).  Frozen metavariables ('C', name, args...) are rigid symbols (generality tests).
# Instances: substitute closed lambda-bodies, plug (one-step beta; no redex cascade, since bodies
# are first-order and arguments metavariable-free).
#
# Parts of this file are adapted from prior/induction/so_core.py (plug, shift, exists_body).
import sys
sys.setrecursionlimit(200000)

ARITY = {'0': 0, 'pa': 0, 'pb': 0, 'pc': 0, 'S': 1, 'add': 2, 'mul': 2,
         'eq': 2, 'mem': 2, 'not': 1, 'and': 2, 'or': 2, 'imp': 2, 'iff': 2, 'all': 1, 'ex': 1}
BINDERS = ('all', 'ex')
CONSTS = ('0', 'pa', 'pb', 'pc')
TERM_HEADS = {'0', 'pa', 'pb', 'pc', 'S', 'add', 'mul'}
FORM_HEADS = {'eq', 'mem', 'not', 'and', 'or', 'imp', 'iff', 'all', 'ex'}


class NoMatch(Exception):
    pass


# ------------------------------------------------------------------ constructors
Z = ('0',)
PA, PB, PC = ('pa',), ('pb',), ('pc',)
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def mul(a, b): return ('mul', a, b)
def eq(a, b): return ('eq', a, b)
def mem(a, b): return ('mem', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def OR(f, g): return ('or', f, g)
def IMP(f, g): return ('imp', f, g)
def IFF(f, g): return ('iff', f, g)
def ALL(f): return ('all', f)
def EX(f): return ('ex', f)
def V(k): return ('v', k)
def H(m=0): return ('h', m)
def M(name, *args): return ('M', name) + tuple(args)


def msort(name):
    return 'F' if name[0].isupper() else 'T'


def kids(t):
    h = t[0]
    if h in ('v', 'h'):
        return ()
    if h in ('M', 'C'):
        return t[2:]
    return t[1:]


def rebuild(t, ks):
    h = t[0]
    if h in ('v', 'h'):
        return t
    if h in ('M', 'C'):
        return (h, t[1]) + tuple(ks)
    return (h,) + tuple(ks)


def child_sort(h):
    """sort of the children of a rigid node with head h (for M/C: arguments are terms)"""
    if h in ('S', 'add', 'mul', 'eq', 'mem', 'M', 'C'):
        return 'T'
    return 'F'


def node_key(t):
    """identity of the symbol at the root of t (bound variables: their index)"""
    h = t[0]
    if h in ('v', 'h'):
        return t
    if h in ('M', 'C'):
        return (h, t[1], len(t))
    return (h, len(t))


def size(t):
    return 1 + sum(size(k) for k in kids(t))


def shift(t, j, cut=0):
    if j == 0:
        return t
    h = t[0]
    if h == 'v':
        return ('v', t[1] + j) if t[1] >= cut else t
    if h == 'h':
        return t
    if h in BINDERS:
        return (h, shift(t[1], j, cut + 1))
    return rebuild(t, [shift(k, j, cut) for k in kids(t)])


def lower(t, j, cut=0):
    """inverse of shift by j: subtract j from free indices; None if t refers to one of the j binders"""
    if j == 0:
        return t
    h = t[0]
    if h == 'v':
        if t[1] < cut:
            return t
        if t[1] - cut < j:
            return None
        return ('v', t[1] - j)
    if h == 'h':
        return t
    if h in BINDERS:
        b = lower(t[1], j, cut + 1)
        return None if b is None else (h, b)
    ks = []
    for k in kids(t):
        b = lower(k, j, cut)
        if b is None:
            return None
        ks.append(b)
    return rebuild(t, ks)


def plug(body, args, j=0):
    """beta-reduce (lambda h0..h_{n-1}. body)(args); args are relative to the occurrence context"""
    h = body[0]
    if h == 'h':
        return shift(args[body[1]], j)
    if h == 'v':
        return body
    if h in BINDERS:
        return (h, plug(body[1], args, j + 1))
    return rebuild(body, [plug(k, args, j) for k in kids(body)])


def instantiate(T, theta):
    h = T[0]
    if h == 'M':
        args = [instantiate(a, theta) for a in T[2:]]
        return plug(theta[T[1]], args)
    if h in ('v', 'h'):
        return T
    return rebuild(T, [instantiate(k, theta) for k in kids(T)])


def fv(t, j=0, acc=None):
    """free de Bruijn indices of t, relative to the root of t"""
    if acc is None:
        acc = set()
    h = t[0]
    if h == 'v':
        if t[1] >= j:
            acc.add(t[1] - j)
        return acc
    jj = j + 1 if h in BINDERS else j
    for k in kids(t):
        fv(k, jj, acc)
    return acc


def holes(t, acc=None):
    if acc is None:
        acc = set()
    if t[0] == 'h':
        acc.add(t[1])
    for k in kids(t):
        holes(k, acc)
    return acc


def has_meta(t):
    if t[0] == 'M':
        return True
    return any(has_meta(k) for k in kids(t))


def subst_free(t, umap, j=0):
    """replace each free index y (relative to the root of t) by shift(umap[y], j)"""
    h = t[0]
    if h == 'v':
        if t[1] >= j:
            return shift(umap[t[1] - j], j)
        return t
    if h == 'h':
        return t
    jj = j + 1 if h in BINDERS else j
    return rebuild(t, [subst_free(k, umap, jj) for k in kids(t)])


# ------------------------------------------------------------------ positions
def sub(t, p):
    for i in p:
        t = kids(t)[i]
    return t


def bdepth(t, p):
    """number of binders strictly above position p"""
    d = 0
    for i in p:
        if t[0] in BINDERS:
            d += 1
        t = kids(t)[i]
    return d


def positions(t, p=(), d=0, srt='F'):
    """yield (pos, node, binder depth, sort) in preorder; does not descend into metavariable args"""
    yield p, t, d, srt
    if t[0] in ('M', 'C', 'v', 'h'):
        return
    dd = d + 1 if t[0] in BINDERS else d
    cs = child_sort(t[0])
    for i, k in enumerate(kids(t)):
        yield from positions(k, p + (i,), dd, cs)


def comparable(p, q):
    n = min(len(p), len(q))
    return p[:n] == q[:n]


# ------------------------------------------------------------------ templates
def occurrences(T, p=(), d=0, acc=None):
    """list of (pos, name, args, binder depth) of metavariable occurrences (rigid ones only)"""
    if acc is None:
        acc = []
    if T[0] == 'M':
        acc.append((p, T[1], T[2:], d))
        return acc
    if T[0] in ('v', 'h', 'C'):
        return acc
    dd = d + 1 if T[0] in BINDERS else d
    for i, k in enumerate(kids(T)):
        occurrences(k, p + (i,), dd, acc)
    return acc


def is_pattern_args(args):
    return all(a[0] == 'v' for a in args) and len(set(args)) == len(args)


def metas(T):
    return sorted({o[1] for o in occurrences(T)})


def is_DT0(T):
    """arguments metavariable-free, every metavariable has a pattern occurrence"""
    occ = occurrences(T)
    for (_, nm, args, _) in occ:
        if any(has_meta(a) for a in args):
            return False
    names = {o[1] for o in occ}
    for nm in names:
        if not any(o[1] == nm and is_pattern_args(o[2]) for o in occ):
            return False
    # arity consistency
    ar = {}
    for (_, nm, args, _) in occ:
        if ar.setdefault(nm, len(args)) != len(args):
            return False
    return True


# ------------------------------------------------------------------ matching
def rigid_collect(T, s, occ, d=0, p=()):
    if T[0] == 'M':
        occ.setdefault(T[1], []).append((s, T[2:], d, p))
        return True
    if node_key(T) != node_key(s):
        return False
    if T[0] in ('v', 'h'):
        return True
    dd = d + 1 if T[0] in BINDERS else d
    return all(rigid_collect(a, b, occ, dd, p + (i,)) for i, (a, b) in enumerate(zip(kids(T), kids(s))))


def abstract(c, idxs, j=0):
    """body with c = body[ys]; idxs = de Bruijn indices (relative to the occurrence) of the pattern args"""
    h = c[0]
    if h == 'v':
        k = c[1]
        if k < j:
            return c
        if k - j in idxs:
            return ('h', idxs.index(k - j))
        raise NoMatch
    jj = j + 1 if h in BINDERS else j
    return rebuild(c, [abstract(x, idxs, jj) for x in kids(c)])


def det_match(T, s):
    """unique matcher of a DT° template T against a ground formula s, or None (Theorem A)"""
    occ = {}
    if not rigid_collect(T, s, occ):
        return None
    theta = {}
    for nm, lst in occ.items():
        pat = next((o for o in lst if is_pattern_args(o[1])), None)
        if pat is None:
            raise ValueError('not determinate: ' + nm)
        c, args, _, _ = pat
        try:
            body = abstract(c, [a[1] for a in args])
        except NoMatch:
            return None
        for (c2, args2, _, _) in lst:
            if plug(body, list(args2)) != c2:
                return None
        theta[nm] = body
    return theta


def exists_body(pairs, j=0):
    """Is there a closed body B with plug(B, args) == c for every (c, args)?  (projection/imitation;
    polynomial because subproblems are independent; adapted from prior so_core)"""
    n = len(pairs[0][1])
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs):
            return True
    c0 = pairs[0][0]
    k0 = node_key(c0)
    for c, _ in pairs:
        if node_key(c) != k0:
            return False
    if c0[0] == 'v':
        return c0[1] < j
    jj = j + 1 if c0[0] in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    return all(exists_body([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj)
               for a in range(len(ks[0])))


def count_bodies(pairs, j=0):
    n = len(pairs[0][1])
    tot = 0
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs):
            tot += 1
    c0 = pairs[0][0]
    k0 = node_key(c0)
    for c, _ in pairs:
        if node_key(c) != k0:
            return tot
    if c0[0] == 'v':
        return tot + (1 if c0[1] < j else 0)
    jj = j + 1 if c0[0] in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    prod = 1
    for a in range(len(ks[0])):
        prod *= count_bodies([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj)
        if prod == 0:
            break
    return tot + prod


def covers(T, s):
    """s in inst(T) for T in SO° (any matcher), via simultaneous projection/imitation"""
    occ = {}
    if not rigid_collect(T, s, occ):
        return False
    return all(exists_body([(c, a) for (c, a, _, _) in lst]) for lst in occ.values())


def covers_all(T, D):
    return all(covers(T, s) for s in D)


def n_matchers(T, s):
    occ = {}
    if not rigid_collect(T, s, occ):
        return 0
    r = 1
    for lst in occ.values():
        r *= count_bodies([(c, a) for (c, a, _, _) in lst])
    return r


def freeze(T):
    if T[0] == 'M':
        return ('C', T[1]) + tuple(freeze(a) for a in T[2:])
    if T[0] in ('v', 'h'):
        return T
    return rebuild(T, [freeze(k) for k in kids(T)])


def subsumes(T1, T2):
    """T1 >= T2 (T2 = T1 sigma); for T1, T2 in DT° this is freeze-and-match (Prop. A.3)"""
    return covers(T1, freeze(T2))


def equivalent(T1, T2):
    return subsumes(T1, T2) and subsumes(T2, T1)


def canon(T):
    ren, cnt = {}, {'F': 0, 'T': 0}
    def R(t):
        if t[0] == 'M':
            nm = t[1]
            if nm not in ren:
                srt = msort(nm)
                ren[nm] = ('P%d' if srt == 'F' else 'f%d') % cnt[srt]
                cnt[srt] += 1
            return ('M', ren[nm]) + tuple(R(a) for a in t[2:])
        if t[0] in ('v', 'h'):
            return t
        return rebuild(t, [R(k) for k in kids(t)])
    return R(T)


# ------------------------------------------------------------------ printing
NAMES = ['x', 'y', 'u', 'w', 'r', 's', 't']
def pp(t, depth=0, hn=('X', 'Y', 'Z', 'W')):
    h = t[0]
    if h == 'v':
        lvl = depth - 1 - t[1]
        return NAMES[lvl] if 0 <= lvl < len(NAMES) else '#%d' % t[1]
    if h == 'h':
        return hn[t[1]] if t[1] < len(hn) else 'h%d' % t[1]
    if h in CONSTS:
        return {'0': '0', 'pa': 'a', 'pb': 'b', 'pc': 'c'}[h]
    if h == 'S':
        k, u = 0, t
        while u[0] == 'S':
            k, u = k + 1, u[1]
        inner = pp(u, depth, hn)
        if u[0] in CONSTS or u[0] in ('v', 'h', 'M', 'C') or inner.startswith('('):
            return 'S' * k + inner
        return 'S' * k + '(' + inner + ')'
    if h in ('add', 'mul'):
        return '(' + pp(t[1], depth, hn) + ('+' if h == 'add' else '*') + pp(t[2], depth, hn) + ')'
    if h in ('eq', 'mem'):
        return pp(t[1], depth, hn) + ('=' if h == 'eq' else ' in ') + pp(t[2], depth, hn)
    if h == 'not':
        return '~' + pp(t[1], depth, hn)
    if h in ('and', 'or', 'imp', 'iff'):
        op = {'and': ' & ', 'or': ' v ', 'imp': ' -> ', 'iff': ' <-> '}[h]
        return '(' + pp(t[1], depth, hn) + op + pp(t[2], depth, hn) + ')'
    if h in BINDERS:
        q = 'A' if h == 'all' else 'E'
        nm = NAMES[depth] if depth < len(NAMES) else 'z%d' % depth
        return q + nm + '.' + pp(t[1], depth + 1, hn)
    if h in ('M', 'C'):
        if len(t) == 2:
            return t[1]
        return t[1] + '(' + ','.join(pp(a, depth, hn) for a in t[2:]) + ')'
    return str(t)


def ppb(body, nh=None):
    """print a body with holes X, Y, ..."""
    return pp(body)


# ------------------------------------------------------------------ standard templates
P0, Px, PSx = M('P', Z), M('P', V(0)), M('P', S(V(0)))
T_IND = IMP(AND(P0, ALL(IMP(Px, PSx))), ALL(Px))

def Ind(m):
    """induction instance for the motive body m (hole 0 = x)"""
    return instantiate(T_IND, {'P': m})

# ZF (closure-normal form; parameters pa,pb are free names).  de Bruijn: innermost binder = index 0.
# Separation:  Aa Eb Ax (x in b <-> (x in a & P(x,a)))
T_SEP = ALL(EX(ALL(IFF(mem(V(0), V(1)), AND(mem(V(0), V(2)), M('P', V(0), V(2)))))))
# Replacement (exists-unique spelled out):
#  Aa ( Ax (x in a -> Ey (P(x,y,a) & Az (P(x,z,a) -> z = y)))  ->  Eb Ax (x in a -> Ey (y in b & P(x,y,a))) )
T_REP = ALL(IMP(
    ALL(IMP(mem(V(0), V(1)), EX(AND(M('P', V(1), V(0), V(2)),
                                    ALL(IMP(M('P', V(2), V(0), V(3)), eq(V(0), V(1)))))))),
    EX(ALL(IMP(mem(V(0), V(2)), EX(AND(mem(V(0), V(2)), M('P', V(1), V(0), V(3)))))))))
# epsilon-induction:  Ax (Ay (y in x -> P(y)) -> P(x)) -> Ax P(x)
T_EIND = IMP(ALL(IMP(ALL(IMP(mem(V(0), V(1)), M('P', V(0)))), M('P', V(0)))), ALL(M('P', V(0))))
