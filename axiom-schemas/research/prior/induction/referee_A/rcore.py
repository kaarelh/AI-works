# Referee's independent core (does NOT import the T1 code or the author's common.py).
# Terms: ('f', arg1, ...) ; constants ('c',) ; metavariables are ('?', name).
import itertools, random

def isv(t): return t[0] == '?'
def tsize(t): return 1 if isv(t) else 1 + sum(tsize(a) for a in t[1:])
def tvars(t, acc=None):
    if acc is None: acc = []
    if isv(t):
        if t[1] not in acc: acc.append(t[1])
    else:
        for a in t[1:]: tvars(a, acc)
    return acc
def rank(t): return tsize(t) - len(tvars(t))

def au(terms):
    """Plotkin/Reynolds anti-unification of a list of terms (metavariables in inputs are treated as
    opaque symbols); one table shared across the whole term."""
    table = {}
    def go(col):
        h = col[0]
        if (not isv(h)) and all((not isv(u)) and u[0] == h[0] and len(u) == len(h) for u in col):
            return (h[0],) + tuple(go(tuple(u[i] for u in col)) for i in range(1, len(h)))
        if col not in table: table[col] = ('?', 'G%d' % len(table))
        return table[col]
    return go(tuple(terms))

def mtch(p, t, s=None):
    """first-order matching: substitution s with p s == t, or None (t may contain metavariables; they are
    treated as constants)."""
    if s is None: s = {}
    stack = [(p, t)]
    while stack:
        a, b = stack.pop()
        if isv(a):
            if a[1] in s:
                if s[a[1]] != b: return None
            else: s[a[1]] = b
        else:
            if isv(b) or a[0] != b[0] or len(a) != len(b): return None
            stack.extend(zip(a[1:], b[1:]))
    return s
def more_general_eq(p, t): return mtch(p, t) is not None        # p >= t
def variant(a, b): return more_general_eq(a, b) and more_general_eq(b, a)

# ----- object language -----
def K(c): return (c,)
ZERO = K('0')
def S_(t): return ('S', t)
OV = ['x', 'y', 'z', 'n', 'k', 'u']
TF = {'0': 0, 'S': 1, 'add': 2, 'mul': 2}
PR = {'eq': 2, 'lt': 2}
CN = {'not': 1, 'and': 2, 'or': 2, 'imp': 2, 'iff': 2}
QN = {'all', 'ex'}
def is_ov(t): return len(t) == 1 and t[0] in OV
def is_tm(t):
    if isv(t): return False
    if is_ov(t): return True
    return t[0] in TF and len(t) == 1 + TF[t[0]] and all(is_tm(a) for a in t[1:])
def is_fm(f):
    if isv(f) or len(f) == 0: return False
    h = f[0]
    if h in PR: return len(f) == 3 and is_tm(f[1]) and is_tm(f[2])
    if h in CN: return len(f) == 1 + CN[h] and all(is_fm(a) for a in f[1:])
    if h in QN: return len(f) == 3 and is_ov(f[1]) and is_fm(f[2])
    return False
def fv(f):
    if is_ov(f): return {f[0]}
    if len(f) == 1: return set()
    if f[0] in QN: return fv(f[2]) - {f[1][0]}
    out = set()
    for a in f[1:]: out |= fv(a)
    return out
def free_for(f, v, t):
    """t is free for v in f (no free occurrence of v in f lies under a binder of a variable of t)"""
    tv = fv(t)
    def rec(g, bound):
        if is_ov(g): return not (g[0] == v and (tv & bound))
        if len(g) == 1: return True
        if g[0] in QN:
            if g[1][0] == v: return True
            return rec(g[2], bound | {g[1][0]})
        return all(rec(a, bound) for a in g[1:])
    return rec(f, frozenset())
def sb(f, v, t):
    """f[t/v], replacing free occurrences only (caller checks free_for)"""
    if is_ov(f): return t if f[0] == v else f
    if len(f) == 1: return f
    if f[0] in QN and f[1][0] == v: return f
    return (f[0],) + tuple(sb(a, v, t) for a in f[1:])
def Wsub(p, v, t, q):
    return is_fm(p) and is_ov(v) and is_tm(t) and free_for(p, v[0], t) and q == sb(p, v[0], t)

# ----- encodings -----
def ind_raw(P, v, A, B):
    return ('st', ('Sub', P, v, ZERO, A), ('Sub', P, v, S_(v), B),
            ('imp', ('and', A, ('all', v, ('imp', P, B))), ('all', v, P)))
def ind(phi, v='x'):
    V = K(v)
    return ind_raw(phi, V, sb(phi, v, ZERO), sb(phi, v, S_(V)))
SIG_X = ind_raw(('?', 'P'), K('x'), ('?', 'A'), ('?', 'B'))
SIG_M = ind_raw(('?', 'P'), ('?', 'X'), ('?', 'A'), ('?', 'B'))
def subs_true(step): return all(Wsub(*p[1:]) for p in step[1:-1] if p[0] == 'Sub')

# ----- random formulas (richer than the author's universe) -----
def rterm(r, d, vs):
    u = r.random()
    if d <= 0 or u < 0.3: return K(r.choice(['0'] + list(vs)))
    if u < 0.55: return S_(rterm(r, d - 1, vs))
    return (r.choice(['add', 'mul']), rterm(r, d - 1, vs), rterm(r, d - 1, vs))
def rform(r, d, vs):
    u = r.random()
    if d <= 0 or u < 0.35: return (r.choice(['eq', 'lt']), rterm(r, 2, vs), rterm(r, 2, vs))
    c = r.choice(['not', 'and', 'or', 'imp', 'iff', 'all', 'ex'])
    if c == 'not': return ('not', rform(r, d - 1, vs))
    if c in QN: return (c, K(r.choice(vs)), rform(r, d - 1, vs))
    return (c, rform(r, d - 1, vs), rform(r, d - 1, vs))

# ----- bounded semantics (evidence only) -----
def ev_t(t, env, mod=None):
    h = t[0]
    if h == '0': r = 0
    elif len(t) == 1: r = env[h]
    elif h == 'S': r = ev_t(t[1], env, mod) + 1
    elif h == 'add': r = ev_t(t[1], env, mod) + ev_t(t[2], env, mod)
    elif h == 'mul': r = ev_t(t[1], env, mod) * ev_t(t[2], env, mod)
    else: raise ValueError(t)
    return r if mod is None else mod(r)
def ev(f, env, dom, mod=None):
    h = f[0]
    if h == 'eq': return ev_t(f[1], env, mod) == ev_t(f[2], env, mod)
    if h == 'lt': return ev_t(f[1], env, mod) < ev_t(f[2], env, mod)
    if h == 'not': return not ev(f[1], env, dom, mod)
    if h == 'and': return ev(f[1], env, dom, mod) and ev(f[2], env, dom, mod)
    if h == 'or': return ev(f[1], env, dom, mod) or ev(f[2], env, dom, mod)
    if h == 'imp': return (not ev(f[1], env, dom, mod)) or ev(f[2], env, dom, mod)
    if h == 'iff': return ev(f[1], env, dom, mod) == ev(f[2], env, dom, mod)
    if h == 'all': return all(ev(f[2], {**env, f[1][0]: i}, dom, mod) for i in dom)
    if h == 'ex': return any(ev(f[2], {**env, f[1][0]: i}, dom, mod) for i in dom)
    raise ValueError(f)
def closure_true(f, dom, freedom=None, mod=None):
    vs = sorted(fv(f)); freedom = dom if freedom is None else freedom
    return all(ev(f, dict(zip(vs, vals)), dom, mod) for vals in itertools.product(freedom, repeat=len(vs)))
