# Shared code for the induction-learning notes (Track A: motive-annotated data).
# Terms use the paper's T1-code format: ('f', args...) ; metavariables ('?', name).
import sys, itertools, random
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import is_var, size, vars_of, mu, match, is_instance, lgg_list, canon, show, ground_terms

def C(n): return (n,)
Z = C('0')
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def mul(a, b): return ('mul', a, b)
def eq(a, b): return ('eq', a, b)
def lt(a, b): return ('lt', a, b)
def NOT(a): return ('not', a)
def AND(a, b): return ('and', a, b)
def OR(a, b): return ('or', a, b)
def IMP(a, b): return ('imp', a, b)
def IFF(a, b): return ('iff', a, b)
def ALL(v, a): return ('all', v, a)
def EX(v, a): return ('ex', v, a)
def MV(n): return ('?', n)
x, y, n, k, u, w = C('x'), C('y'), C('n'), C('k'), C('u'), C('w')
OBJVARS = {'x', 'y', 'n', 'k', 'u', 'w', 'z', 'm', 'i', 'j'} | {'v%d' % i for i in range(200)}
TERM_F = {'0': 0, 'S': 1, 'add': 2, 'mul': 2}
ATOM_P = {'eq': 2, 'lt': 2}
CONN = {'not': 1, 'and': 2, 'or': 2, 'imp': 2, 'iff': 2}
QUANT = {'all', 'ex'}

def is_objvar(t): return len(t) == 1 and t[0] in OBJVARS
def is_term(t):
    if is_var(t): return False
    if is_objvar(t): return True
    if t[0] in TERM_F and len(t) == 1 + TERM_F[t[0]]: return all(is_term(a) for a in t[1:])
    return False
def is_formula(f):
    if is_var(f) or len(f) == 0: return False
    h = f[0]
    if h in ATOM_P and len(f) == 3: return is_term(f[1]) and is_term(f[2])
    if h in CONN and len(f) == 1 + CONN[h]: return all(is_formula(a) for a in f[1:])
    if h in QUANT and len(f) == 3: return is_objvar(f[1]) and is_formula(f[2])
    return False

def subst(f, v, t):
    """f[t/v] for an object variable v, respecting binders.  (Only used with t in {0, S(v), y, S(y)}
    where capture cannot occur for the motives we generate; capture is checked separately.)"""
    if f == v: return t
    if len(f) == 1: return f
    if f[0] in QUANT and f[1] == v: return f
    return (f[0],) + tuple(subst(a, v, t) for a in f[1:])

def free_vars(f, bound=frozenset()):
    if is_var(f): return set()
    if is_objvar(f): return set() if f[0] in bound else {f[0]}
    if f[0] in QUANT: return free_vars(f[2], bound | {f[1][0]})
    out = set()
    for a in f[1:]: out |= free_vars(a, bound)
    return out
def occurs(v, f):
    if is_var(f): return False
    if f == v: return True
    return any(occurs(v, a) for a in f[1:])
def capture_free(f, v, t, bound=frozenset()):
    """True iff substituting t for the free occurrences of v in f captures no variable of t."""
    tv = free_vars(t)
    def rec(g, bd):
        if is_objvar(g): return not (g == v and v[0] not in bd and (tv & bd))
        if len(g) == 1: return True
        if g[0] in QUANT:
            if g[1] == v: return True
            return rec(g[2], bd | {g[1][0]})
        return all(rec(a, bd) for a in g[1:])
    return rec(f, frozenset(bound))

# ---------------- the world W on Sub judgments ----------------
def W_sub(p, v, t, q):
    """W(Sub(p,v,t,q)) = 1 iff p is a formula, v an object variable, t a term, t free for v in p, q = p[t/v]."""
    return is_formula(p) and is_objvar(v) and is_term(t) and capture_free(p, v, t) and q == subst(p, v, t)

# ---------------- Sub-encoded induction (step = st(prem1, prem2, concl)) ----------------
def ind(phi, v=x):
    a = subst(phi, v, Z); b = subst(phi, v, S(v))
    return ('st', ('Sub', phi, v, Z, a), ('Sub', phi, v, S(v), b), IMP(AND(a, ALL(v, IMP(phi, b))), ALL(v, phi)))
def ind_raw(P, v, A, B):  # arbitrary instance of the pattern (possibly improper)
    return ('st', ('Sub', P, v, Z, A), ('Sub', P, v, S(v), B), IMP(AND(A, ALL(v, IMP(P, B))), ALL(v, P)))
SIGMA_X = ind_raw(MV('P'), x, MV('A'), MV('B'))            # x fixed: metavariables P, A, B
SIGMA_M = ind_raw(MV('P'), MV('X'), MV('A'), MV('B'))      # x a metavariable: P, X, A, B
def ind2(phi, v=x):  # the 'step by 2' fallacy, Sub-encoded
    a = subst(phi, v, Z); b = subst(phi, v, S(S(v)))
    return ('st', ('Sub', phi, v, Z, a), ('Sub', phi, v, S(S(v)), b), IMP(AND(a, ALL(v, IMP(phi, b))), ALL(v, phi)))
SIGMA2_X = ('st', ('Sub', MV('P'), x, Z, MV('A')), ('Sub', MV('P'), x, S(S(x)), MV('B')),
            IMP(AND(MV('A'), ALL(x, IMP(MV('P'), MV('B')))), ALL(x, MV('P'))))

def equiv(a, b): return canon(a) == canon(b)
def sub_premises_true(step):
    return all(W_sub(*p[1:]) for p in step[1:-1] if p[0] == 'Sub')

# ---------------- bounded semantics (for exhibiting counterexamples only) ----------------
BOUND = 25
def ev_t(t, env):
    h = t[0]
    if h == '0': return 0
    if len(t) == 1: return env[h]
    if h == 'S': return ev_t(t[1], env) + 1
    if h == 'add': return ev_t(t[1], env) + ev_t(t[2], env)
    if h == 'mul': return ev_t(t[1], env) * ev_t(t[2], env)
    raise ValueError(t)
def ev(f, env, B=BOUND):
    h = f[0]
    if h == 'eq': return ev_t(f[1], env) == ev_t(f[2], env)
    if h == 'lt': return ev_t(f[1], env) < ev_t(f[2], env)
    if h == 'not': return not ev(f[1], env, B)
    if h == 'and': return ev(f[1], env, B) and ev(f[2], env, B)
    if h == 'or': return ev(f[1], env, B) or ev(f[2], env, B)
    if h == 'imp': return (not ev(f[1], env, B)) or ev(f[2], env, B)
    if h == 'iff': return ev(f[1], env, B) == ev(f[2], env, B)
    if h == 'all': return all(ev(f[2], {**env, f[1][0]: i}, B) for i in range(B))
    if h == 'ex': return any(ev(f[2], {**env, f[1][0]: i}, B) for i in range(B))
    raise ValueError(f)
def ev_closure(f, B=BOUND, Bfree=8):
    """bounded truth of the universal closure of f"""
    fv = sorted(free_vars(f))
    return all(ev(f, dict(zip(fv, vals)), B) for vals in itertools.product(range(Bfree), repeat=len(fv)))

# ---------------- motive universes and random motives ----------------
def terms_upto(maxsize, varnames=('x', 'y')):
    sig = {'0': 0, 'S': 1, 'add': 2}
    for v in varnames: sig[v] = 0
    by = ground_terms(sig, maxsize)
    return {s: by[s] for s in by}
def motives_upto(maxsize, varnames=('x', 'y'), conns=('not', 'and', 'imp'), quants=('all',)):
    """all formulas of size <= maxsize built from eq/lt over terms with the given variable names"""
    T = terms_upto(maxsize - 1, varnames)
    F = {}
    for sz in range(1, maxsize + 1):
        out = []
        for p in ('eq', 'lt'):
            for s1 in range(1, sz - 1):
                s2 = sz - 1 - s1
                if s2 < 1: continue
                for a in T.get(s1, []):
                    for b in T.get(s2, []): out.append((p, a, b))
        if 'not' in conns:
            for g in F.get(sz - 1, []): out.append(('not', g))
        for c in ('and', 'or', 'imp'):
            if c not in conns: continue
            for s1 in range(1, sz - 1):
                s2 = sz - 1 - s1
                for a in F.get(s1, []):
                    for b in F.get(s2, []): out.append((c, a, b))
        for q in quants:
            for g in F.get(sz - 2, []):
                for v in varnames: out.append((q, (v,), g))
        F[sz] = out
    return [f for sz in sorted(F) for f in F[sz]]

def rand_term(rng, d, vars_=('x', 'y')):
    r = rng.random()
    if d <= 0 or r < 0.35: return C(rng.choice(('0',) + tuple(vars_)))
    if r < 0.65: return S(rand_term(rng, d - 1, vars_))
    return add(rand_term(rng, d - 1, vars_), rand_term(rng, d - 1, vars_))
def rand_formula(rng, d, vars_=('x', 'y')):
    r = rng.random()
    if d <= 0 or r < 0.4:
        return (rng.choice(('eq', 'lt')), rand_term(rng, 2, vars_), rand_term(rng, 2, vars_))
    c = rng.choice(('not', 'and', 'or', 'imp', 'all', 'ex'))
    if c == 'not': return NOT(rand_formula(rng, d - 1, vars_))
    if c in ('all', 'ex'): return (c, C(rng.choice(vars_)), rand_formula(rng, d - 1, vars_))
    return (c, rand_formula(rng, d - 1, vars_), rand_formula(rng, d - 1, vars_))
def rand_motive_with_root(rng, root, v=x, nonvacuous=True, vars_=('x', 'y')):
    """random formula with the given main symbol and (if nonvacuous) v free; rejection sampling"""
    while True:
        if root in ('eq', 'lt'): f = (root, rand_term(rng, 2, vars_), rand_term(rng, 2, vars_))
        elif root == 'not': f = NOT(rand_formula(rng, 2, vars_))
        elif root in ('all', 'ex'):
            bv = C(rng.choice([q for q in vars_ if C(q) != v] or ['y']))
            f = (root, bv, rand_formula(rng, 2, vars_))
        else: f = (root, rand_formula(rng, 2, vars_), rand_formula(rng, 2, vars_))
        if (v[0] in free_vars(f)) == nonvacuous: return f
