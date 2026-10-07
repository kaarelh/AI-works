# Track B (raw induction instances, first-order patterns): common encodings, exact evaluator.
# Terms use the paper's T1-code library: ('f',args...), constants are 1-tuples ('0',), ('x',);
# metavariables are ('?',name).  lgg_list = Plotkin/Reynolds anti-unification (column-indexed).
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, match, is_instance, size, vars_of, canon, show, is_var  # noqa: F401

def C(s): return (s,)
Z = C('0'); X = C('x'); Y = C('y')
OBJVARS = {('x',), ('y',), ('u',), ('v',)}
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def mul(a, b): return ('mul', a, b)
def eq(a, b): return ('eq', a, b)
def NOT(a): return ('not', a)
def AND(a, b): return ('and', a, b)
def OR(a, b): return ('or', a, b)
def IMP(a, b): return ('imp', a, b)
def ALL(v, a): return ('all', v, a)
def MV(n): return ('?', n)
def num(n, base=Z):
    t = base
    for _ in range(n): t = S(t)
    return t
def g(n, t):
    """g_n(t) = 0+(0+(...(0+t))) with n additions."""
    for _ in range(n): t = add(Z, t)
    return t

TERM_SYMS = {'0', 'S', 'add', 'mul', 'x', 'y', 'u', 'v'}
FORM_SYMS = {'eq', 'not', 'and', 'or', 'imp', 'all', 'ex'}

def subst(f, v, t):
    """object-level phi[t/v] (v an object variable constant), stopping at binders of v.
    (t is closed or is S(v) in all uses below, so no capture question arises.)"""
    if is_var(f): return f
    if f == v: return t
    if len(f) == 1: return f
    if f[0] in ('all', 'ex') and f[1] == v: return f
    return (f[0],) + tuple(subst(a, v, t) for a in f[1:])

def Ind(phi, v=X):
    """raw induction instance  phi(0) & all v (phi -> phi(Sv)) -> all v phi"""
    return IMP(AND(subst(phi, v, Z), ALL(v, IMP(phi, subst(phi, v, S(v))))), ALL(v, phi))

def IndEq(phi, v=X, w=Y):
    """Tarski-style substitution-free form:
       all v (v=0 -> phi) & all w (all v (v=w -> phi) -> all v (v=Sw -> phi)) -> all v phi"""
    return IMP(AND(ALL(v, IMP(eq(v, Z), phi)),
                   ALL(w, IMP(ALL(v, IMP(eq(v, w), phi)), ALL(v, IMP(eq(v, S(w)), phi))))),
               ALL(v, phi))

def free_vars(f, bound=frozenset()):
    if is_var(f): return set()
    if len(f) == 1: return {f} if (f in OBJVARS and f not in bound) else set()
    if f[0] in ('all', 'ex'): return free_vars(f[2], bound | {f[1]})
    out = set()
    for a in f[1:]: out |= free_vars(a, bound)
    return out

def subst_meta(t, th):
    if is_var(t): return th.get(t[1], t)
    if len(t) == 1: return t
    return (t[0],) + tuple(subst_meta(a, th) for a in t[1:])

def has_meta(t): return len(vars_of(t)) > 0

# ---------- sorts of metavariable positions ----------
def meta_sorts(t, sort='F', acc=None):
    """sort of each metavariable: 'T' term, 'F' formula, 'V' object variable."""
    if acc is None: acc = {}
    if is_var(t):
        acc.setdefault(t[1], set()).add(sort); return acc
    h = t[0]
    if len(t) == 1: return acc
    if h in ('eq', 'add', 'mul', 'S'): kids = ['T'] * (len(t) - 1)
    elif h in ('not', 'and', 'or', 'imp'): kids = ['F'] * (len(t) - 1)
    elif h in ('all', 'ex'): kids = ['V', 'F']
    else: kids = ['?'] * (len(t) - 1)
    for a, s in zip(t[1:], kids): meta_sorts(a, s, acc)
    return acc

# ---------- exact truth in N for the fragment used here ----------
# A quantifier  all v B  is decided exactly when B (after the environment is plugged in) is
# quantifier-free with only v free: each atom s=t is p(v)=0 for an integer polynomial p; a nonzero p
# has all its natural roots <= Cauchy bound, so beyond the largest bound every atom is constant and
# B is constant; checking v = 0..bound+1 decides  all v B.  Anything else raises NotExact.
class NotExact(Exception): pass

def padd(p, q):
    r = dict(p)
    for k, c in q.items(): r[k] = r.get(k, 0) + c
    return {k: c for k, c in r.items() if c}
def pmul(p, q):
    r = {}
    for a, c in p.items():
        for b, d in q.items(): r[a + b] = r.get(a + b, 0) + c * d
    return {k: c for k, c in r.items() if c}
def poly(t, v, env):
    if t == Z: return {}
    if len(t) == 1:
        if t == v: return {1: 1}
        if t in env: return {0: env[t]} if env[t] else {}
        raise NotExact('free variable %s' % (t,))
    if t[0] == 'S': return padd(poly(t[1], v, env), {0: 1})
    if t[0] == 'add': return padd(poly(t[1], v, env), poly(t[2], v, env))
    if t[0] == 'mul': return pmul(poly(t[1], v, env), poly(t[2], v, env))
    raise NotExact('term %s' % (t[0],))
def cauchy(p):
    if not p: return 0
    n = max(p); an = abs(p[n])
    if n == 0: return 0
    return 1 + max((abs(c) for k, c in p.items() if k < n), default=0) // an + 1
def atoms(f):
    if f[0] == 'eq': return [f]
    if f[0] in ('all', 'ex'): raise NotExact('nested quantifier')
    out = []
    for a in f[1:]: out += atoms(a)
    return out
def tval(t, env):
    if t == Z: return 0
    if len(t) == 1:
        if t in env: return env[t]
        raise NotExact('free %s' % (t,))
    if t[0] == 'S': return tval(t[1], env) + 1
    if t[0] == 'add': return tval(t[1], env) + tval(t[2], env)
    if t[0] == 'mul': return tval(t[1], env) * tval(t[2], env)
    raise NotExact(t[0])
def truth(f, env=None):
    env = env or {}
    h = f[0]
    if is_var(f): raise NotExact('metavariable')
    if h == 'eq': return tval(f[1], env) == tval(f[2], env)
    if h == 'not': return not truth(f[1], env)
    if h == 'and': return truth(f[1], env) and truth(f[2], env)
    if h == 'or': return truth(f[1], env) or truth(f[2], env)
    if h == 'imp': return (not truth(f[1], env)) or truth(f[2], env)
    if h in ('all', 'ex'):
        v, body = f[1], f[2]
        env2 = {k: n for k, n in env.items() if k != v}
        B = 0
        for a in atoms(body):
            p = padd(poly(a[1], v, env2), {k: -c for k, c in poly(a[2], v, env2).items()})
            B = max(B, cauchy(p))
        vals = [truth(body, {**env2, v: n}) for n in range(B + 2)]
        return all(vals) if h == 'all' else any(vals)
    raise NotExact(h)

def is_sentence(f): return not has_meta(f) and not free_vars(f)
