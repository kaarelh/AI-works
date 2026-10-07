# Referee (Track B) -- independent core: terms, anti-unification, matching, exact truth in N.
# Written from scratch; does NOT import terms.py, raw_common.py or raw_search.py.
# Term = tuple (head, *args). Constants: ('0',), ('x',), ('y',). Metavariable: ('$', name).
import itertools
import sympy

def mv(n): return ('$', n)
def ismv(t): return t[0] == '$'
ZERO = ('0',); X = ('x',); Y = ('y',)
VARS = {X, Y, ('u',), ('w',)}
def S(t): return ('S', t)
def ADD(a, b): return ('+', a, b)
def MUL(a, b): return ('*', a, b)
def EQ(a, b): return ('=', a, b)
def NEG(a): return ('~', a)
def AND(a, b): return ('&', a, b)
def OR(a, b): return ('|', a, b)
def IMP(a, b): return ('>', a, b)
def ALL(v, a): return ('A', v, a)
def EX(v, a): return ('E', v, a)
def numeral(n, base=ZERO):
    for _ in range(n): base = S(base)
    return base
def gn(n, t):
    for _ in range(n): t = ADD(ZERO, t)
    return t

def tsize(t): return 1 if ismv(t) else 1 + sum(tsize(a) for a in t[1:])
def mvars(t):
    if ismv(t): return {t[1]}
    s = set()
    for a in t[1:]: s |= mvars(a)
    return s

def fv(f, bound=frozenset()):
    if ismv(f): return set()
    if len(f) == 1: return {f} if f in VARS and f not in bound else set()
    if f[0] in 'AE': return fv(f[2], bound | {f[1]})
    s = set()
    for a in f[1:]: s |= fv(a, bound)
    return s

def sub_obj(f, v, t):
    """capture-free object substitution f[t/v] (callers only substitute 0, S(v), closed terms)"""
    if ismv(f): return f
    if f == v: return t
    if len(f) == 1: return f
    if f[0] in 'AE':
        if f[1] == v: return f
        assert not (f[1] in fv(t)), 'capture'
    return (f[0],) + tuple(sub_obj(a, v, t) for a in f[1:])

def IND(phi, v=X):
    return IMP(AND(sub_obj(phi, v, ZERO), ALL(v, IMP(phi, sub_obj(phi, v, S(v))))), ALL(v, phi))

def INDEQ(phi, v=X, w=Y):
    return IMP(AND(ALL(v, IMP(EQ(v, ZERO), phi)),
                   ALL(w, IMP(ALL(v, IMP(EQ(v, w), phi)), ALL(v, IMP(EQ(v, S(w)), phi))))),
               ALL(v, phi))

# ---------------- anti-unification (own implementation) ----------------
def antiunify(ts):
    memo = {}
    counter = itertools.count()
    def go(col):
        h = col[0]
        if (not ismv(h)) and all((not ismv(u)) and u[0] == h[0] and len(u) == len(h) for u in col):
            return (h[0],) + tuple(go(tuple(u[i] for u in col)) for i in range(1, len(h)))
        if col not in memo: memo[col] = mv('m%d' % next(counter))
        return memo[col]
    return go(tuple(ts))

def match(p, t, s=None):
    s = {} if s is None else s
    stack = [(p, t)]
    while stack:
        a, b = stack.pop()
        if ismv(a):
            if a[1] in s:
                if s[a[1]] != b: return None
            else: s[a[1]] = b
            continue
        if ismv(b) or a[0] != b[0] or len(a) != len(b): return None
        stack.extend(zip(a[1:], b[1:]))
    return s

def inst_of(t, p): return match(p, t) is not None
def apply(t, s):
    if ismv(t): return s.get(t[1], t)
    return (t[0],) + tuple(apply(a, s) for a in t[1:])
def normalize(t):
    ren = {}
    def r(u):
        if ismv(u):
            ren.setdefault(u[1], 'v%d' % len(ren)); return mv(ren[u[1]])
        return (u[0],) + tuple(r(a) for a in u[1:])
    return r(t)
def equiv(a, b): return normalize(a) == normalize(b)

# ---------------- exact truth in N ----------------
# Fragment: each quantifier body, after substituting the outer environment, is quantifier-free with only
# the bound variable free. Each atom s=t is p(v)=0; the set of natural roots of a nonzero p is computed
# exactly by sympy (integer roots of an integer polynomial); beyond the largest root every atom is
# constant, so the body is constant; evaluating v = 0..maxroot+1 decides the quantifier.
class Unsupported(Exception): pass
_xs = sympy.Symbol('v')
def to_sym(t, v, env):
    if t == ZERO: return sympy.Integer(0)
    if len(t) == 1:
        if t == v: return _xs
        if t in env: return sympy.Integer(env[t])
        raise Unsupported('free ' + str(t))
    if t[0] == 'S': return to_sym(t[1], v, env) + 1
    if t[0] == '+': return to_sym(t[1], v, env) + to_sym(t[2], v, env)
    if t[0] == '*': return to_sym(t[1], v, env) * to_sym(t[2], v, env)
    raise Unsupported(t[0])
def ev_term(t, env):
    if t == ZERO: return 0
    if len(t) == 1:
        if t in env: return env[t]
        raise Unsupported('free ' + str(t))
    if t[0] == 'S': return ev_term(t[1], env) + 1
    if t[0] == '+': return ev_term(t[1], env) + ev_term(t[2], env)
    if t[0] == '*': return ev_term(t[1], env) * ev_term(t[2], env)
    raise Unsupported(t[0])
def qf_atoms(f):
    if f[0] == '=': return [f]
    if f[0] in 'AE': raise Unsupported('nested quantifier')
    if ismv(f): raise Unsupported('mv')
    r = []
    for a in f[1:]: r += qf_atoms(a)
    return r
def natural_roots(expr):
    p = sympy.Poly(sympy.expand(expr), _xs)
    if p.is_zero: return None          # identically zero: atom constant True
    rts = p.ground_roots()             # integer roots (domain ZZ)
    return [int(r) for r in rts if r >= 0]
def holds(f, env=None):
    env = env or {}
    if ismv(f): raise Unsupported('mv')
    h = f[0]
    if h == '=': return ev_term(f[1], env) == ev_term(f[2], env)
    if h == '~': return not holds(f[1], env)
    if h == '&': return holds(f[1], env) and holds(f[2], env)
    if h == '|': return holds(f[1], env) or holds(f[2], env)
    if h == '>': return (not holds(f[1], env)) or holds(f[2], env)
    if h in 'AE':
        v, body = f[1], f[2]
        env2 = {k: n for k, n in env.items() if k != v}
        top = 0
        for a in qf_atoms(body):
            r = natural_roots(to_sym(a[1], v, env2) - to_sym(a[2], v, env2))
            if r: top = max(top, max(r))
        vals = (holds(body, {**env2, v: n}) for n in range(top + 2))
        return all(vals) if h == 'A' else any(vals)
    raise Unsupported(h)

def is_sentence(f): return not mvars(f) and not fv(f)

def show(f):
    if ismv(f): return f[1]
    h = f[0]
    if len(f) == 1: return h
    if h == 'S': return 'S' + (show(f[1]) if len(f[1]) == 1 or f[1][0] == 'S' or ismv(f[1]) else '(' + show(f[1]) + ')')
    if h in '+*': return '(' + show(f[1]) + h + show(f[2]) + ')'
    if h == '=': return show(f[1]) + '=' + show(f[2])
    if h == '~': return '~' + show(f[1])
    if h in '&|': return '(' + show(f[1]) + ' ' + h + ' ' + show(f[2]) + ')'
    if h == '>': return '(' + show(f[1]) + ' -> ' + show(f[2]) + ')'
    if h in 'AE': return h + show(f[1]) + '.' + show(f[2])
    return str(f)

# ---------------- sorts of metavariables (for well-sorted instance search) ----------------
def sorts(t, s='F', acc=None):
    acc = {} if acc is None else acc
    if ismv(t): acc.setdefault(t[1], set()).add(s); return acc
    h = t[0]
    if h in ('=', '+', '*', 'S'): ks = ['T'] * (len(t) - 1)
    elif h in ('~', '&', '|', '>'): ks = ['F'] * (len(t) - 1)
    elif h in ('A', 'E'): ks = ['V', 'F']
    else: ks = []
    for a, k in zip(t[1:], ks): sorts(a, k, acc)
    return acc

POOL = {'T': [ZERO, S(ZERO), S(S(ZERO)), X, S(X), MUL(ZERO, X), ADD(S(ZERO), MUL(ZERO, X))],
        'F': [EQ(ZERO, ZERO), EQ(ZERO, S(ZERO)), EQ(X, ZERO), EQ(X, X), NEG(EQ(X, ZERO))],
        'V': [X]}
def false_instance(L, pool=POOL, cap=50000):
    srt = sorts(L)
    names = sorted(srt)
    if any(len(srt[n]) != 1 for n in names): raise ValueError('mixed sorts')
    choices = [pool[next(iter(srt[n]))] for n in names]
    for k, combo in enumerate(itertools.product(*choices)):
        if k >= cap: break
        s = apply(L, dict(zip(names, combo)))
        if not is_sentence(s): continue
        try:
            if not holds(s): return s
        except Unsupported:
            continue
    return None
