# Track C core: second-order templates over first-order arithmetic, de Bruijn representation.
#
# Formulas / terms (object language, modulo alpha via de Bruijn indices):
#   terms     ('0',)  ('S',t)  ('add',a,b)  ('mul',a,b)  ('v',k)   [bound variable, de Bruijn index k]
#   formulas  ('eq',a,b) ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('all',f) ('ex',f)
# lambda-bodies of metavariables use holes ('h',m) for the m-th lambda-bound argument; a body is
#   closed except for holes (no free de Bruijn index).
# Templates additionally contain metavariable occurrences ('M', name, arg1, ..., argn).
#   name[0] uppercase -> formula-valued (type iota^n -> o); lowercase -> term-valued (iota^n -> iota).
# Frozen metavariables (for subsumption tests) are rigid symbols ('C', name, args...).
#
# Instances: substitute closed lambda-terms for metavariables and beta-reduce.  Because bodies are
# first-order (only iota-variables are lambda-bound), beta-reduction is one-step "plug": no redex cascade.
import itertools, sys
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/induction')

ARITY = {'0': 0, 'S': 1, 'add': 2, 'mul': 2, 'eq': 2, 'not': 1, 'and': 2, 'or': 2, 'imp': 2,
         'all': 1, 'ex': 1}
BINDERS = ('all', 'ex')
TERM_HEADS = {'0', 'S', 'add', 'mul'}
FORM_HEADS = {'eq', 'not', 'and', 'or', 'imp', 'all', 'ex'}

Z = ('0',)
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def mul(a, b): return ('mul', a, b)
def eq(a, b): return ('eq', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def OR(f, g): return ('or', f, g)
def IMP(f, g): return ('imp', f, g)
def ALL(f): return ('all', f)
def EX(f): return ('ex', f)
def V(k): return ('v', k)
def H(m=0): return ('h', m)
def M(name, *args): return ('M', name) + tuple(args)
X = H(0)          # in motive bodies, x is hole 0

def kids(t):
    h = t[0]
    if h in ('v', 'h'): return ()
    if h in ('M', 'C'): return t[2:]
    return t[1:]

def rebuild(t, ks):
    h = t[0]
    if h in ('v', 'h'): return t
    if h in ('M', 'C'): return (h, t[1]) + tuple(ks)
    return (h,) + tuple(ks)

def is_meta(t): return t[0] == 'M'

def size(t):
    """symbol count; a metavariable occurrence M(t1..tn) counts 1 + sum |ti|; a bound variable counts 1"""
    return 1 + sum(size(k) for k in kids(t))

def shift(t, j, cut=0):
    """add j to every free de Bruijn index (index >= cut) of t"""
    if j == 0: return t
    h = t[0]
    if h == 'v': return ('v', t[1] + j) if t[1] >= cut else t
    if h == 'h': return t
    if h in BINDERS: return (h, shift(t[1], j, cut + 1))
    return rebuild(t, [shift(k, j, cut) for k in kids(t)])

def plug(body, args, j=0):
    """beta-reduce (lambda h0..h_{n-1}. body)(args); args are terms relative to the occurrence context"""
    h = body[0]
    if h == 'h': return shift(args[body[1]], j)
    if h == 'v': return body
    if h in BINDERS: return (h, plug(body[1], args, j + 1))
    return rebuild(body, [plug(k, args, j) for k in kids(body)])

def instantiate(T, theta):
    h = T[0]
    if h == 'M':
        args = [instantiate(a, theta) for a in T[2:]]
        return plug(theta[T[1]], args)
    if h in ('v', 'h'): return T
    return rebuild(T, [instantiate(k, theta) for k in kids(T)])

def metas(T, acc=None):
    """name -> list of arg tuples (all occurrences, including nested)"""
    if acc is None: acc = {}
    if T[0] == 'M':
        acc.setdefault(T[1], []).append(T[2:])
    for k in kids(T): metas(k, acc)
    return acc

def closed(t, j=0):
    if t[0] == 'v': return t[1] < j
    if t[0] in BINDERS: return closed(t[1], j + 1)
    return all(closed(k, j) for k in kids(t))

def has_hole(t):
    if t[0] == 'h': return True
    return any(has_hole(k) for k in kids(t))

# ------------------------------------------------------------------ induction
def Ind(m):
    """raw induction instance for the motive body m (hole 0 = x):  m(0) & all x (m(x) -> m(Sx)) -> all x m(x)"""
    return IMP(AND(plug(m, [Z]), ALL(IMP(plug(m, [V(0)]), plug(m, [S(V(0))])))), ALL(plug(m, [V(0)])))

P0 = M('P', Z); Px = M('P', V(0)); PSx = M('P', S(V(0)))
T_IND = IMP(AND(P0, ALL(IMP(Px, PSx))), ALL(Px))

def frame(alpha, beta, gamma, delta):
    """imp(and(alpha, all(beta -> gamma)), all delta); beta,gamma,delta given as motive bodies (hole 0 = x)"""
    return IMP(AND(alpha, ALL(IMP(plug(beta, [V(0)]), plug(gamma, [V(0)])))), ALL(plug(delta, [V(0)])))

def root(m): return m[0]
def x_free(m): return has_hole(m)

# ------------------------------------------------------------------ matching
# Class SO°: every metavariable occurrence sits at a rigid position and has metavariable-free args.
def rigid_collect(T, s, occ):
    """walk the rigid part of T against s; collect flex occurrences; False on rigid clash"""
    if T[0] == 'M':
        occ.setdefault(T[1], []).append((s, T[2:]))
        return True
    if T[0] != s[0]: return False
    if T[0] in ('v', 'h'): return T == s
    if T[0] == 'C' and (T[1] != s[1] or len(T) != len(s)): return False
    kT, ks = kids(T), kids(s)
    if len(kT) != len(ks): return False
    return all(rigid_collect(a, b, occ) for a, b in zip(kT, ks))

def exists_body(pairs, j=0):
    """Is there a closed body B (holes h0..h_{n-1}) with plug(B, args) == c for every (c, args) in pairs?
    Simultaneous projection/imitation (Huet-Lang style) -- polynomial, because subtrees of B are independent."""
    n = len(pairs[0][1])
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs):
            return True
    c0 = pairs[0][0]
    h = c0[0]
    for c, _ in pairs:
        if c[0] != h or len(c) != len(c0): return False
    if h == 'v':
        return c0[1] < j and all(c == c0 for c, _ in pairs)
    if h == 'C' and any(c[1] != c0[1] for c, _ in pairs): return False
    if h in ('M', 'h'): raise ValueError('content must be ground')
    jj = j + 1 if h in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    return all(exists_body([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj)
               for a in range(len(ks[0])))

def count_bodies(pairs, j=0):
    """number of distinct bodies solving the simultaneous problem (exact)"""
    n = len(pairs[0][1])
    tot = 0
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs): tot += 1
    c0 = pairs[0][0]
    h = c0[0]
    for c, _ in pairs:
        if c[0] != h or len(c) != len(c0): return tot
    if h == 'v':
        return tot + (1 if (c0[1] < j and all(c == c0 for c, _ in pairs)) else 0)
    if h == 'C' and any(c[1] != c0[1] for c, _ in pairs): return tot
    jj = j + 1 if h in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    prod = 1
    for a in range(len(ks[0])):
        prod *= count_bodies([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj)
        if prod == 0: break
    return tot + prod

def one_body(pairs, j=0):
    """some solution body (projection preferred), or None"""
    n = len(pairs[0][1])
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs):
            return ('h', m)
    c0 = pairs[0][0]
    h = c0[0]
    for c, _ in pairs:
        if c[0] != h or len(c) != len(c0): return None
    if h == 'v':
        return c0 if (c0[1] < j and all(c == c0 for c, _ in pairs)) else None
    if h == 'C' and any(c[1] != c0[1] for c, _ in pairs): return None
    jj = j + 1 if h in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    out = []
    for a in range(len(ks[0])):
        b = one_body([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj)
        if b is None: return None
        out.append(b)
    return rebuild(c0, out)

def covers(T, s):
    occ = {}
    if not rigid_collect(T, s, occ): return False
    return all(exists_body(p) for p in occ.values())

def covers_all(T, D): return all(covers(T, s) for s in D)

def solve(T, s):
    """returns (theta, counts) with one solution theta and the exact number of solutions per metavariable,
    or None if T does not cover s"""
    occ = {}
    if not rigid_collect(T, s, occ): return None
    theta, counts = {}, {}
    for name, p in occ.items():
        b = one_body(p)
        if b is None: return None
        theta[name] = b
        counts[name] = count_bodies(p)
    return theta, counts

# ------------------------------------------------------------------ determinacy, canonical form
def pattern_args(args):
    return all(a[0] == 'v' for a in args) and len(set(args)) == len(args)

def rigid_occurrences(T, acc=None):
    if acc is None: acc = {}
    if T[0] == 'M':
        acc.setdefault(T[1], []).append(T[2:]); return acc
    for k in kids(T): rigid_occurrences(k, acc)
    return acc

def is_determinate(T):
    """every metavariable has a rigid occurrence whose arguments are distinct bound variables
    (0-ary: any rigid occurrence); nested occurrences are not rigid"""
    allm = metas(T)
    rig = rigid_occurrences(T)
    return all(name in rig and any(pattern_args(a) for a in rig[name]) for name in allm)

def canon(T):
    ren = {}
    cnt = {'F': 0, 'T': 0}
    def R(t):
        if t[0] == 'M':
            nm = t[1]
            if nm not in ren:
                srt = 'F' if nm[0].isupper() else 'T'
                ren[nm] = ('P%d' if srt == 'F' else 'f%d') % cnt[srt]; cnt[srt] += 1
            return ('M', ren[nm]) + tuple(R(a) for a in t[2:])
        if t[0] in ('v', 'h'): return t
        return rebuild(t, [R(k) for k in kids(t)])
    return R(T)

def freeze(T):
    """metavariables -> rigid constants (for subsumption: T1 >= T2 iff covers(T1, freeze(T2)))"""
    if T[0] == 'M': return ('C', T[1]) + tuple(freeze(a) for a in T[2:])
    if T[0] in ('v', 'h'): return T
    return rebuild(T, [freeze(k) for k in kids(T)])

def subsumes(T1, T2):
    """T1 is at least as general as T2 (T2 = T1 sigma, sigma may introduce T2's metavariables)"""
    return covers(T1, freeze(T2))

# ------------------------------------------------------------------ printing
NAMES = ['x', 'y', 'u', 'w', 'r', 's']
def pp(t, depth=0, holes=('X', 'Y')):
    h = t[0]
    if h == 'v':
        lvl = depth - 1 - t[1]
        return NAMES[lvl] if 0 <= lvl < len(NAMES) else '#%d' % t[1]
    if h == 'h': return holes[t[1]] if t[1] < len(holes) else 'h%d' % t[1]
    if h == '0': return '0'
    if h == 'S':
        k, u = 0, t
        while u[0] == 'S': k, u = k + 1, u[1]
        inner = pp(u, depth, holes)
        if u[0] in ('0', 'v', 'h', 'M', 'C') or (inner.startswith('(') and inner.endswith(')')):
            return 'S' * k + inner
        return 'S' * k + '(' + inner + ')'
    if h == 'add': return '(' + pp(t[1], depth, holes) + '+' + pp(t[2], depth, holes) + ')'
    if h == 'mul': return '(' + pp(t[1], depth, holes) + '*' + pp(t[2], depth, holes) + ')'
    if h == 'eq':
        a, b = pp(t[1], depth, holes), pp(t[2], depth, holes)
        if a.startswith('(') and a.endswith(')') and a.count('(') == 1: a = a[1:-1]
        if b.startswith('(') and b.endswith(')') and b.count('(') == 1: b = b[1:-1]
        return a + '=' + b
    if h == 'not': return '~' + pp(t[1], depth, holes)
    if h in ('and', 'or', 'imp'):
        op = {'and': ' & ', 'or': ' v ', 'imp': ' -> '}[h]
        return '(' + pp(t[1], depth, holes) + op + pp(t[2], depth, holes) + ')'
    if h in BINDERS:
        q = 'A' if h == 'all' else 'E'
        nm = NAMES[depth] if depth < len(NAMES) else 'z%d' % depth
        return q + nm + '.' + pp(t[1], depth + 1, holes)
    if h in ('M', 'C'):
        if len(t) == 2: return t[1]
        return t[1] + '(' + ','.join(pp(a, depth, holes) for a in t[2:]) + ')'
    return str(t)

def ppm(m):
    """print a motive body with x for the hole (internal binders named y, u, ...)"""
    return pp(m, 1, holes=('x',))

# ------------------------------------------------------------------ exact truth (via Track B evaluator)
def to_named(t, depth=0):
    """de Bruijn sentence -> raw_common named encoding (object variables x,y,u,v by binder level)"""
    h = t[0]
    nm = ['x', 'y', 'u', 'v']
    if h == 'v': return (nm[depth - 1 - t[1]],)
    if h == '0': return ('0',)
    if h in BINDERS: return (h, (nm[depth],), to_named(t[1], depth + 1))
    if h in ('h', 'M', 'C'): raise ValueError('not ground')
    return (h,) + tuple(to_named(k, depth) for k in kids(t))

def truth(s):
    from raw_common import truth as tr
    return tr(to_named(s))
