"""Independent mini-implementation (reviewer) of de Bruijn terms, plugging, DT° matching, D-features,
witness events, for checking claims of sections setting/single.  Does not import any project code.

Terms:    ('0',) ('S',t) ('+',a,b) ('*',a,b) ('p',name) ('v',k) ('h',m)
Formulas: ('=',a,b) ('<',a,b) ('in',a,b) ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('all',f) ('ex',f)
Template occurrence: ('M', name, args)   (name lowercase: term-valued; uppercase: formula-valued)
"""
import itertools

BINDERS = {'all', 'ex'}
FORMULA_HEADS = {'=', '<', 'in', 'not', 'and', 'or', 'imp', 'iff', 'all', 'ex'}


class Fail(Exception):
    pass


def kids(t):
    if t[0] in ('0', 'p', 'v', 'h'):
        return []
    if t[0] == 'M':
        return []          # arguments are not positions of the template tree for our purposes
    return list(t[1:])


def rebuild(t, ks):
    return (t[0],) + tuple(ks)


def label(t):
    if t[0] in ('p', 'v', 'h'):
        return (t[0], t[1])
    if t[0] == 'M':
        return ('M', t[1])
    return (t[0], len(t) - 1)


def sort_of(t):
    if t[0] == 'M':
        return 'o' if t[1][0].isupper() else 'i'
    return 'o' if t[0] in FORMULA_HEADS else 'i'


def positions(t, pos=(), b=0):
    yield pos, t, b
    if t[0] == 'M':
        return
    for i, c in enumerate(kids(t)):
        yield from positions(c, pos + (i,), b + (1 if t[0] in BINDERS else 0))


def sub(t, pos):
    for i in pos:
        if t[0] == 'M':
            raise Fail('below occurrence')
        ks = kids(t)
        if i >= len(ks):
            raise Fail('no such position')
        t = ks[i]
    return t


def has_pos(t, pos):
    try:
        sub(t, pos)
        return True
    except Fail:
        return False


def bdepth(t, pos):
    b = 0
    for i in pos:
        if t[0] in BINDERS:
            b += 1
        t = kids(t)[i]
    return b


def shift(t, e, cut=0):
    if t[0] == 'v':
        return ('v', t[1] + e) if t[1] >= cut else t
    if t[0] == 'M':
        return ('M', t[1], tuple(shift(a, e, cut) for a in t[2]))
    if t[0] in ('0', 'p', 'h'):
        return t
    c2 = cut + (1 if t[0] in BINDERS else 0)
    return rebuild(t, [shift(k, e, c2) for k in kids(t)])


def lower(t, e, cut=0):
    """unshift free indices by e; fail if a free index refers to one of the e local binders"""
    if t[0] == 'v':
        k = t[1]
        if k < cut:
            return t
        if k < cut + e:
            raise Fail('mentions local binder')
        return ('v', k - e)
    if t[0] in ('0', 'p', 'h'):
        return t
    c2 = cut + (1 if t[0] in BINDERS else 0)
    return rebuild(t, [lower(k, e, c2) for k in kids(t)])


def FV(t, depth=0):
    if t[0] == 'v':
        return {t[1] - depth} if t[1] >= depth else set()
    if t[0] == 'M':
        s = set()
        for a in t[2]:
            s |= FV(a, depth)
        return s
    if t[0] in ('0', 'p', 'h'):
        return set()
    d2 = depth + (1 if t[0] in BINDERS else 0)
    s = set()
    for k in kids(t):
        s |= FV(k, d2)
    return s


def subst(t, u, depth=0):
    """replace free index y by u[y] (shifted under local binders)"""
    if t[0] == 'v':
        if t[1] >= depth:
            y = t[1] - depth
            if y not in u:
                raise Fail('subst undefined')
            return shift(u[y], depth)
        return t
    if t[0] in ('0', 'p', 'h'):
        return t
    if t[0] == 'M':
        return ('M', t[1], tuple(subst(a, u, depth) for a in t[2]))
    d2 = depth + (1 if t[0] in BINDERS else 0)
    return rebuild(t, [subst(k, u, d2) for k in kids(t)])


def plug(body, args, depth=0):
    if body[0] == 'h':
        return shift(args[body[1]], depth)
    if body[0] in ('0', 'p', 'v'):
        return body
    if body[0] == 'M':
        return ('M', body[1], tuple(plug(a, args, depth) for a in body[2]))
    d2 = depth + (1 if body[0] in BINDERS else 0)
    return rebuild(body, [plug(k, args, d2) for k in kids(body)])


def instantiate(T, theta):
    if T[0] == 'M':
        return plug(theta[T[1]], T[2])
    if T[0] in ('0', 'p', 'v', 'h'):
        return T
    return rebuild(T, [instantiate(k, theta) for k in kids(T)])


def size(t):
    if t[0] == 'M':
        return 1 + sum(size(a) for a in t[2])
    return 1 + sum(size(k) for k in kids(t))


def has_hole(t, m):
    if t == ('h', m):
        return True
    if t[0] in ('0', 'p', 'v', 'h'):
        return False
    if t[0] == 'M':
        return any(has_hole(a, m) for a in t[2])
    return any(has_hole(k, m) for k in kids(t))


# ---------- forcing (Lemma 1.3) ----------
def match_free(s1, s2, e=0, acc=None):
    """partial map e_d on FV(s1) with s2 = s1[e_d]; None if impossible"""
    if acc is None:
        acc = {}
    if s1[0] == 'v' and s1[1] >= e:
        y = s1[1] - e
        try:
            val = lower(s2, e)
        except Fail:
            return None
        if y in acc and acc[y] != val:
            return None
        acc[y] = val
        return acc
    if label(s1) != label(s2):
        return None
    e2 = e + (1 if s1[0] in BINDERS else 0)
    for a, b in zip(kids(s1), kids(s2)):
        if match_free(a, b, e2, acc) is None:
            return None
    return acc


def common_map(pairs):
    u = {}
    for s1, s2 in pairs:
        m = match_free(s1, s2)
        if m is None:
            return None
        for y, v in m.items():
            if y in u and u[y] != v:
                return None
            u[y] = v
    return u


# ---------- data notions and features ----------
class Features:
    def __init__(self, D):
        D = list(dict.fromkeys(D))
        assert D
        self.D = D
        d0 = D[0]
        self.C = {}        # pos -> label
        self.slots = []
        self.sort = {}
        stack = [()]
        while stack:
            p = stack.pop()
            nodes = [sub(d, p) for d in D]
            labs = {label(n) for n in nodes}
            self.sort[p] = sort_of(nodes[0])
            if len(labs) == 1:
                self.C[p] = labs.pop()
                for i in range(len(kids(nodes[0]))):
                    stack.append(p + (i,))
            else:
                self.slots.append(p)
        self.A = list(self.C) + self.slots
        self.Y = {s: set().union(*[FV(sub(d, s)) for d in D]) for s in self.slots}
        self.eq = []
        for s in self.slots:
            for r in self.A:
                if r == s or r[:len(s)] == s or s[:len(r)] == r:
                    continue
                if self.sort[r] != self.sort[s]:
                    continue
                u = common_map([(sub(d, s), sub(d, r)) for d in D])
                if u is not None:
                    self.eq.append((s, r, u))

    def accepts(self, q, why=False):
        for p, lab in self.C.items():
            if not has_pos(q, p) or label(sub(q, p)) != lab:
                return (False, ('Sym', p)) if why else False
        for s in self.slots:
            if not FV(sub(q, s)) <= self.Y[s]:
                return (False, ('Scope', s)) if why else False
        for s, r, u in self.eq:
            qs = sub(q, s)
            try:
                ok = subst(qs, u) == sub(q, r)
            except Fail:
                ok = False
            if not ok:
                return (False, ('Eq', s, r, u)) if why else False
        return (True, None) if why else True


# ---------- templates, occurrences, events ----------
def occurrences(T, pos=(), b=0):
    for p, t, bb in positions(T):
        if t[0] == 'M':
            yield p, t, bb


def skel(T):
    return [p for p, t, b in positions(T) if t[0] != 'M']


def is_pattern(args):
    return all(a[0] == 'v' for a in args) and len({a[1] for a in args}) == len(args)


def metas(T):
    out = {}
    for p, t, b in occurrences(T):
        out[t[1]] = len(t[2])
    return out


def is_DT(T):
    ms = metas(T)
    pat = {t[1] for p, t, b in occurrences(T) if is_pattern(t[2])}
    return set(ms) == pat


def match_DT(T, s):
    """reviewer's own DT° matcher: returns theta or None"""
    theta = {}
    occs = list(occurrences(T))
    for p, t, b in positions(T):
        if t[0] == 'M':
            continue
        if not has_pos(s, p) or label(sub(s, p)) != label(t):
            return None
    for p, t, b in occs:
        if t[1] in theta or not is_pattern(t[2]):
            continue
        sp = sub(s, p)
        ys = [a[1] for a in t[2]]
        if not FV(sp) <= set(ys):
            return None
        theta[t[1]] = subst(sp, {y: ('h', m) for m, y in enumerate(ys)})
    for p, t, b in occs:
        if plug(theta[t[1]], t[2]) != sub(s, p):
            return None
    if instantiate(T, theta) != s:
        return None
    return theta


def events(Tstar, thetas):
    data = [instantiate(Tstar, th) for th in thetas]
    occs = list(occurrences(Tstar))
    occpos = {p: t for p, t, b in occs}
    Rstar = all(len({label(sub(d, p)) for d in data}) > 1 for p in occpos)
    ms = metas(Tstar)
    Nev = all(any(has_hole(th[M], m) for th in thetas) for M, n in ms.items() for m in range(n))
    sorts = {p: sort_of(t) for p, t, b in positions(Tstar)}
    nonvalid = []
    U = True
    for s, ts in occpos.items():
        Ystar = set().union(*[FV(a) for a in ts[2]]) if ts[2] else set()
        for r in sorts:
            if r == s or r[:len(s)] == s or s[:len(r)] == r or sorts[r] != sorts[s]:
                continue
            valid = False
            if r in occpos and occpos[r][1] == ts[1]:
                u0 = common_map(list(zip(ts[2], occpos[r][2])))
                valid = u0 is not None
            if valid:
                continue
            nonvalid.append((s, r))
            u = common_map([(sub(d, s), sub(d, r)) for d in data])
            if u is not None:
                U = False
    return Rstar, Nev, U, data, nonvalid
