# Referee's independent core library (does NOT import the author's code).
# Object language: de Bruijn indices ('#',k); holes ('z',m); metavariable occurrences ('?',name,args)
# name lowercase -> term-valued, uppercase -> formula-valued.  Frozen metavariables: ('F:'+name, *args).
# Symbols: terms 0 a b c S + ; formulas = in ~ & | -> <-> A E  (A,E bind one variable).
import sys
sys.setrecursionlimit(100000)

BINDERS = {'A', 'E'}
TERM_SYMS = {'0': 0, 'a': 0, 'b': 0, 'c': 0, 'S': 1, '+': 2}
FORM_SYMS = {'=': 2, 'in': 2, '~': 1, '&': 2, '|': 2, '->': 2, '<->': 2, 'A': 1, 'E': 1}


class Fail(Exception):
    pass


def sort_of(t):
    tag = t[0]
    if tag == '#':
        return 'i'
    if tag == 'z':
        return 'i'
    if tag == '?':
        return 'i' if t[1][0].islower() else 'o'
    if tag.startswith('F:'):
        return 'i' if tag[2].islower() else 'o'
    if tag in TERM_SYMS:
        return 'i'
    return 'o'


def children(t):
    """list of (child_index_in_tuple, child, binders_added)"""
    tag = t[0]
    if tag in ('#', 'z'):
        return []
    if tag == '?':
        return []          # occurrences are leaves of the skeleton
    if tag in BINDERS:
        return [(1, t[1], 1)]
    return [(i, t[i], 0) for i in range(1, len(t))]


def shift(t, d, c=0):
    tag = t[0]
    if tag == '#':
        return ('#', t[1] + d) if t[1] >= c else t
    if tag == 'z':
        return t
    if tag == '?':
        return ('?', t[1], tuple(shift(a, d, c) for a in t[2]))
    if tag in BINDERS:
        return (tag, shift(t[1], d, c + 1))
    return (tag,) + tuple(shift(a, d, c) for a in t[1:])


def fv(t, k=0):
    tag = t[0]
    if tag == '#':
        return {t[1] - k} if t[1] >= k else set()
    if tag == 'z':
        return set()
    if tag == '?':
        s = set()
        for a in t[2]:
            s |= fv(a, k)
        return s
    if tag in BINDERS:
        return fv(t[1], k + 1)
    s = set()
    for a in t[1:]:
        s |= fv(a, k)
    return s


def holes(t):
    tag = t[0]
    if tag == 'z':
        return {t[1]}
    if tag == '#':
        return set()
    if tag == '?':
        s = set()
        for a in t[2]:
            s |= holes(a)
        return s
    s = set()
    for a in t[1:]:
        s |= holes(a)
    return s


def plug(beta, args, k=0):
    tag = beta[0]
    if tag == 'z':
        return shift(args[beta[1]], k)
    if tag == '#':
        return beta
    if tag == '?':
        return ('?', beta[1], tuple(plug(a, args, k) for a in beta[2]))
    if tag in BINDERS:
        return (tag, plug(beta[1], args, k + 1))
    return (tag,) + tuple(plug(a, args, k) for a in beta[1:])


def inst(T, theta):
    tag = T[0]
    if tag == '?':
        return plug(theta[T[1]], T[2])
    if tag in ('#', 'z'):
        return T
    if tag in BINDERS:
        return (tag, inst(T[1], theta))
    return (tag,) + tuple(inst(a, theta) for a in T[1:])


def size(t):
    tag = t[0]
    if tag in ('#', 'z'):
        return 1
    if tag == '?':
        return 1 + sum(size(a) for a in t[2])
    return 1 + sum(size(a) for a in t[1:])


def sub_at(t, p):
    for i in p:
        t = t[i]
    return t


def depth_at(t, p):
    b = 0
    for i in p:
        if t[0] in BINDERS:
            b += 1
        t = t[i]
    return b


def replace_at(t, p, new):
    if not p:
        return new
    i = p[0]
    lst = list(t)
    lst[i] = replace_at(t[i], p[1:], new)
    return tuple(lst)


def all_positions(t, p=(), b=0):
    """skeleton positions (not descending into occurrence args): yields (p, subterm, b)"""
    yield (p, t, b)
    for i, c, add in children(t):
        yield from all_positions(c, p + (i,), b + add)


def occurrences(T):
    return [(p, s, b) for (p, s, b) in all_positions(T) if s[0] == '?']


def metas(T):
    out = {}
    for p, s, b in occurrences(T):
        out.setdefault(s[1], []).append((p, s[2], b))
    return out


def is_pattern_args(args):
    return all(a[0] == '#' for a in args) and len({a[1] for a in args}) == len(args)


def is_DT0(T):
    for name, occs in metas(T).items():
        if not any(is_pattern_args(a) for (_, a, _) in occs):
            return False
        ar = {len(a) for (_, a, _) in occs}
        if len(ar) != 1:
            return False
        for _, a, _ in occs:
            for x in a:
                if any(n[0] == '?' for (_, n, _) in all_positions(x)):
                    return False
    return True


def comparable(p, q):
    n = min(len(p), len(q))
    return p[:n] == q[:n]


def abstract(s, ys, k=0):
    """s closed except free indices among ys (relative to s's root); replace y_m by hole z_m"""
    tag = s[0]
    if tag == '#':
        if s[1] < k:
            return s
        y = s[1] - k
        if y in ys:
            return ('z', ys.index(y))
        raise Fail('free index outside pattern args')
    if tag in BINDERS:
        return (tag, abstract(s[1], ys, k + 1))
    if tag in ('z', '?'):
        raise Fail('unexpected')
    return (tag,) + tuple(abstract(a, ys, k) for a in s[1:])


def _walk(T, s, rec):
    if T[0] == '?':
        rec.append((T, s))
        return True
    if T[0] == '#':
        return s == T
    if s[0] != T[0] or len(s) != len(T):
        return False
    for i in range(1, len(T)):
        if not _walk(T[i], s[i], rec):
            return False
    return True


def match(T, s):
    """unique matcher of determinate template T against s, or None"""
    rec = []
    if not _walk(T, s, rec):
        return None
    theta = {}
    for occ, ss in rec:
        name, args = occ[1], occ[2]
        if name in theta:
            continue
        if is_pattern_args(args):
            try:
                theta[name] = abstract(ss, [a[1] for a in args])
            except Fail:
                return None
    names = {occ[1] for occ, _ in rec}
    if set(theta) != names:
        raise ValueError('not determinate')
    if inst(T, theta) != s:
        return None
    return theta


def freeze(T):
    tag = T[0]
    if tag == '?':
        return ('F:' + T[1],) + tuple(T[2])
    if tag in ('#', 'z'):
        return T
    if tag in BINDERS:
        return (tag, freeze(T[1]))
    return (tag,) + tuple(freeze(a) for a in T[1:])


def geq(T, T2):
    """T >= T2 (T more general)"""
    return match(T, freeze(T2)) is not None


def covers(T, D):
    return all(match(T, d) is not None for d in D)


# ----------------------------------------------------------------- first-order matching of free indices
def fo_match(pat, tgt, k, sub):
    """pat's free indices are variables (relative to pat root); extend sub so that pat[sub] == tgt"""
    tag = pat[0]
    if tag == '#':
        if pat[1] < k:
            return tgt == pat
        y = pat[1] - k
        f = fv(tgt)
        if any(i < k for i in f):
            return False
        u = shift(tgt, -k)
        if y in sub:
            return sub[y] == u
        sub[y] = u
        return True
    if tgt[0] != tag or len(tgt) != len(pat):
        return False
    if tag in BINDERS:
        return fo_match(pat[1], tgt[1], k + 1, sub)
    for i in range(1, len(pat)):
        if not fo_match(pat[i], tgt[i], k, sub):
            return False
    return True


def subst_free(t, u, k=0):
    tag = t[0]
    if tag == '#':
        if t[1] < k:
            return t
        y = t[1] - k
        if y not in u:
            raise Fail('index not in substitution domain')
        return shift(u[y], k)
    if tag in BINDERS:
        return (tag, subst_free(t[1], u, k + 1))
    if tag in ('z',):
        return t
    if tag == '?':
        return ('?', t[1], tuple(subst_free(a, u, k) for a in t[2]))
    return (tag,) + tuple(subst_free(a, u, k) for a in t[1:])


def solve_eq(pairs):
    """pairs: list of (pat, tgt). common u with tgt == pat[u] for all, or None"""
    sub = {}
    for pat, tgt in pairs:
        if not fo_match(pat, tgt, 0, sub):
            return None
    return sub


# ----------------------------------------------------------------- data analysis (features)
def root_sym(t):
    if t[0] in ('#', 'z'):
        return t
    return (t[0], len(t))


class DataInfo:
    def __init__(self, D):
        self.D = list(D)
        self.C = {}          # path -> root symbol
        self.slots = []
        self.depth = {}
        self.sort = {}
        self._build((), self.D, 0)
        self.A = list(self.C) + self.slots
        self.Y = {s: set().union(*[fv(sub_at(d, s)) for d in self.D]) for s in self.slots}
        self.feats = []      # (sigma, r, u)
        for s in self.slots:
            for r in self.A:
                if comparable(s, r) or self.sort[s] != self.sort[r]:
                    continue
                pairs = [(sub_at(d, s), sub_at(d, r)) for d in self.D]
                u = solve_eq(pairs)
                if u is not None:
                    self.feats.append((s, r, u))

    def _build(self, p, ds, b):
        self.depth[p] = b
        self.sort[p] = sort_of(ds[0])
        roots = {root_sym(d) for d in ds}
        if len(roots) == 1:
            self.C[p] = roots.pop()
            for i, c, add in children(ds[0]):
                self._build(p + (i,), [d[i] for d in ds], b + add)
        else:
            self.slots.append(p)

    def has_features(self, q, why=False):
        # Sym
        for p, r in self.C.items():
            try:
                t = sub_at(q, p)
            except (IndexError, TypeError):
                return (False, ('sym', p)) if why else False
            if not isinstance(t, tuple) or root_sym(t) != r:
                return (False, ('sym', p)) if why else False
        for s in self.slots:
            if not fv(sub_at(q, s)) <= self.Y[s]:
                return (False, ('scope', s)) if why else False
        for s, r, u in self.feats:
            try:
                lhs = subst_free(sub_at(q, s), u)
            except Fail:
                return (False, ('eq', s, r)) if why else False
            if lhs != sub_at(q, r):
                return (False, ('eq', s, r)) if why else False
        return (True, None) if why else True


# ----------------------------------------------------------------- pretty printing
def pp(t, names=None, k=0):
    names = names or []
    tag = t[0]
    if tag == '#':
        i = t[1]
        if i < len(names):
            return names[len(names) - 1 - i]
        return '#%d' % i
    if tag == 'z':
        return 'z%d' % t[1]
    if tag == '?':
        return t[1] + ('(' + ','.join(pp(a, names) for a in t[2]) + ')' if t[2] else '')
    if tag.startswith('F:'):
        return tag + '(' + ','.join(pp(a, names) for a in t[1:]) + ')'
    if tag in BINDERS:
        v = 'xyuvwpqrst'[len(names) % 10] + ('' if len(names) < 10 else str(len(names)))
        return tag + v + '.' + pp(t[1], names + [v])
    if tag in ('0', 'a', 'b', 'c'):
        return tag
    if tag == 'S':
        return 'S' + pp(t[1], names)
    if tag == '~':
        return '~' + pp(t[1], names)
    if len(t) == 3:
        return '(' + pp(t[1], names) + tag + pp(t[2], names) + ')'
    return tag + '(' + ','.join(pp(a, names) for a in t[1:]) + ')'


# constructors
Z = ('0',)
def S(t): return ('S', t)
def EQ(a, b): return ('=', a, b)
def IN(a, b): return ('in', a, b)
def NOT(f): return ('~', f)
def AND(f, g): return ('&', f, g)
def IMP(f, g): return ('->', f, g)
def IFF(f, g): return ('<->', f, g)
def ALL(f): return ('A', f)
def EX(f): return ('E', f)
def V(k): return ('#', k)
def M(name, *args): return ('?', name, tuple(args))
def ADD(a, b): return ('+', a, b)


def Ind_T():
    P = 'P'
    return IMP(AND(M(P, Z), ALL(IMP(M(P, V(0)), M(P, S(V(0)))))), ALL(M(P, V(0))))


def Ind(phi_body):
    """phi_body: formula with hole z0 for x"""
    return inst(Ind_T(), {'P': phi_body})
