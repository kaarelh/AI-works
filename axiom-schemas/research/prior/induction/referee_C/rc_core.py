# Referee C: independent re-implementation (does NOT import so_core / so_enum).
# Representation: de Bruijn LEVELS (not indices).  A bound variable is ('v', k) where k is the
# depth (number of enclosing binders) of the binder that binds it; so alpha-equivalent formulas are
# structurally equal, and outer variables keep their name under further binders.
#   terms     ('0',) ('S',t) ('+',a,b) ('*',a,b) ('v',k)
#   formulas  ('=',a,b) ('~',f) ('&',f,g) ('|',f,g) ('>',f,g) ('A',f) ('E',f)
#   template  ('M', name, args)   name[0] upper -> formula sort, lower -> term sort; args a tuple
#   frozen    ('C', name, args)   rigid constant used for generality tests
# A metavariable body is a closed lambda-body: holes ('h',m) for parameters, internal binder
# variables as RELATIVE levels ('v', j) (j = depth inside the body).  plug(body,args,D) places it at
# absolute depth D.
import itertools

BIND = ('A', 'E')
TERMH = ('0', 'S', '+', '*')
FORMH = ('=', '~', '&', '|', '>', 'A', 'E')

def Z(): return ('0',)
def S(t): return ('S', t)
def ADD(a, b): return ('+', a, b)
def MUL(a, b): return ('*', a, b)
def EQ(a, b): return ('=', a, b)
def NOT(f): return ('~', f)
def AND(f, g): return ('&', f, g)
def OR(f, g): return ('|', f, g)
def IMP(f, g): return ('>', f, g)
def ALL(f): return ('A', f)
def EX(f): return ('E', f)
def V(k): return ('v', k)
def HOLE(m=0): return ('h', m)
def MV(name, *args): return ('M', name, tuple(args))
X = HOLE(0)

def children(t):
    h = t[0]
    if h in ('v', 'h', '0'): return ()
    if h in ('M', 'C'): return t[2]
    return t[1:]

def remake(t, ch):
    h = t[0]
    if h in ('v', 'h', '0'): return t
    if h in ('M', 'C'): return (h, t[1], tuple(ch))
    return (h,) + tuple(ch)

def size(t):
    return 1 + sum(size(c) for c in children(t))

def plug(body, args, D, r=0):
    """place body at absolute depth D (r = binders of the body passed so far)"""
    h = body[0]
    if h == 'h': return args[body[1]]
    if h == 'v': return ('v', D + body[1])
    return remake(body, [plug(c, args, D, r + (1 if h in BIND else 0)) for c in children(body)])

def Ind(m):
    """raw induction instance of the motive body m (hole 0 = x)"""
    return IMP(AND(plug(m, [Z()], 0), ALL(IMP(plug(m, [V(0)], 1), plug(m, [S(V(0))], 1)))),
               ALL(plug(m, [V(0)], 1)))

P0 = MV('P', Z()); Px = MV('P', V(0)); PSx = MV('P', S(V(0)))
T_IND = IMP(AND(P0, ALL(IMP(Px, PSx))), ALL(Px))

def instantiate(T, theta, D=0):
    h = T[0]
    if h == 'M':
        args = [instantiate(a, theta, D) for a in T[2]]
        return plug(theta[T[1]], args, D)
    if h in ('v', 'h', '0'): return T
    nd = D + 1 if h in BIND else D
    return remake(T, [instantiate(c, theta, nd) for c in children(T)])

def mvars(T, acc=None):
    if acc is None: acc = {}
    if T[0] == 'M':
        acc.setdefault(T[1], []).append(T[2])
    for c in children(T): mvars(c, acc)
    return acc

def has_meta(t):
    if t[0] == 'M': return True
    return any(has_meta(c) for c in children(t))

def rigid_occ(T, D=0, acc=None):
    """rigid metavariable occurrences: name -> list of (args, depth)"""
    if acc is None: acc = []
    if T[0] == 'M':
        acc.append((T[1], T[2], D)); return acc
    nd = D + 1 if T[0] in BIND else D
    for c in children(T): rigid_occ(c, nd, acc)
    return acc

def is_pattern(args, D):
    return all(a[0] == 'v' and a[1] < D for a in args) and len(set(args)) == len(args)

def is_DT(T):
    names = set(mvars(T))
    pat = {n for (n, a, D) in rigid_occ(T) if is_pattern(a, D)}
    return names <= pat

def is_SO(T):
    """all occurrences rigid with metavariable-free args"""
    occ = rigid_occ(T)
    if any(has_meta(a) for (n, args, D) in occ for a in args): return False
    return sum(len(v) for v in mvars(T).values()) == len(occ)

# ------------------------------------------------------------------ walking the rigid part
def rigid_walk(T, s, D, out):
    """collect (name, args, subterm of s, depth) for maximal occurrences; False on clash"""
    if T[0] == 'M':
        out.append((T[1], T[2], s, D)); return True
    if T[0] != s[0]: return False
    if T[0] in ('v',): return T == s
    if T[0] == 'C':
        if T[1] != s[1] or len(T[2]) != len(s[2]): return False
    cT, cs = children(T), children(s)
    if len(cT) != len(cs): return False
    nd = D + 1 if T[0] in BIND else D
    return all(rigid_walk(a, b, nd, out) for a, b in zip(cT, cs))

def abstract(c, args, D):
    """body b with plug(b,args,D) == c for pattern args (distinct outer variables); None if impossible"""
    pos = {a[1]: i for i, a in enumerate(args)}
    def go(t):
        if t[0] == 'v':
            k = t[1]
            if k >= D: return ('v', k - D)
            if k in pos: return ('h', pos[k])
            raise ValueError
        return remake(t, [go(u) for u in children(t)])
    try:
        return go(c)
    except ValueError:
        return None

def det_match(T, s):
    """unique matcher of a determinate template (dict) or None"""
    occ = []
    if not rigid_walk(T, s, 0, occ): return None
    theta = {}
    for (n, args, c, D) in occ:
        if n in theta: continue
        if (len(args) == 0 and True) or is_pattern(args, D):
            b = abstract(c, args, D)
            if b is None: return None
            theta[n] = b
    if set(theta) != set(mvars(T)): raise ValueError('not determinate')
    return theta if instantiate(T, theta) == s else None

# ------------------------------------------------------------------ SO° matching (projection/imitation)
def bodies(occs, r=0, limit=None):
    """all bodies b with plug(b, args_j, D_j) == c_j for every occurrence (c_j, args_j, D_j); args
    metavariable-free.  r = body binders passed.  Returns a list (may be exponential)."""
    out = []
    n = len(occs[0][1])
    for m in range(n):
        if all(c == args[m] for (c, args, D) in occs):
            out.append(('h', m))
    c0 = occs[0][0]
    h = c0[0]
    if any(c[0] != h for (c, _, _) in occs): return out
    if h == 'v':
        rel = {c[1] - D for (c, _, D) in occs}
        if len(rel) == 1:
            j = rel.pop()
            if 0 <= j < r: out.append(('v', j))
        return out
    if h == 'C':
        if any(c[1] != c0[1] or len(c[2]) != len(c0[2]) for (c, _, _) in occs): return out
    ch = [children(c) for (c, _, _) in occs]
    if any(len(x) != len(ch[0]) for x in ch): return out
    nr = r + 1 if h in BIND else r
    sub = []
    for i in range(len(ch[0])):
        b = bodies([(ch[j][i], occs[j][1], occs[j][2]) for j in range(len(occs))], nr, limit)
        if not b: return out
        sub.append(b)
    for combo in itertools.product(*sub):
        out.append(remake(c0, combo))
        if limit and len(out) >= limit: break
    return out

def exists_body(occs, r=0):
    n = len(occs[0][1])
    for m in range(n):
        if all(c == args[m] for (c, args, D) in occs): return True
    c0 = occs[0][0]; h = c0[0]
    if any(c[0] != h for (c, _, _) in occs): return False
    if h == 'v':
        rel = {c[1] - D for (c, _, D) in occs}
        return len(rel) == 1 and 0 <= next(iter(rel)) < r
    if h == 'C' and any(c[1] != c0[1] or len(c[2]) != len(c0[2]) for (c, _, _) in occs): return False
    ch = [children(c) for (c, _, _) in occs]
    if any(len(x) != len(ch[0]) for x in ch): return False
    nr = r + 1 if h in BIND else r
    return all(exists_body([(ch[j][i], occs[j][1], occs[j][2]) for j in range(len(occs))], nr)
               for i in range(len(ch[0])))

def so_covers(T, s):
    occ = []
    if not rigid_walk(T, s, 0, occ): return False
    by = {}
    for (n, args, c, D) in occ:
        if any(has_meta(a) for a in args): raise ValueError('not SO')
        by.setdefault(n, []).append((c, args, D))
    return all(exists_body(v) for v in by.values())

def covers(T, s):
    if is_DT(T): return det_match(T, s) is not None
    return so_covers(T, s)

def freeze(T):
    if T[0] == 'M': return ('C', T[1], tuple(freeze(a) for a in T[2]))
    return remake(T, [freeze(c) for c in children(T)])

def geq(T1, T2):
    """T1 at least as general as T2"""
    return covers(T1, freeze(T2))

# ------------------------------------------------------------------ motive utilities
def x_free(m):
    if m[0] == 'h': return True
    return any(x_free(c) for c in children(m))

def root(m): return m[0]

def unshielded(m):
    """some free x not inside a proper term t != x with FV(t) <= {x} (internal variables: ('v',j))"""
    def term_closed_over_x(t):
        if t[0] == 'v': return False
        return all(term_closed_over_x(c) for c in children(t))
    found = [False]
    def walk(t, parent_term):
        if t[0] == 'h':
            if parent_term is None or not term_closed_over_x(parent_term): found[0] = True
            return
        if t[0] in FORMH:
            for c in children(t): walk(c, None)
            return
        for c in children(t): walk(c, t)
    walk(m, None)
    return found[0]

NM = 'xyzuvw'
def pp(t, D=0, hole='x'):
    h = t[0]
    if h == 'v': return NM[t[1]] if t[1] < len(NM) else 'v%d' % t[1]
    if h == 'h': return hole if t[1] == 0 else 'h%d' % t[1]
    if h == '0': return '0'
    if h == 'S': return 'S' + pp(t[1], D, hole) if t[1][0] in ('0', 'v', 'h', 'S', 'M', 'C') else 'S(' + pp(t[1], D, hole) + ')'
    if h in ('+', '*'): return '(' + pp(t[1], D, hole) + h + pp(t[2], D, hole) + ')'
    if h == '=': return pp(t[1], D, hole) + '=' + pp(t[2], D, hole)
    if h == '~': return '~' + pp(t[1], D, hole)
    if h in ('&', '|', '>'):
        return '(' + pp(t[1], D, hole) + {'&': ' & ', '|': ' v ', '>': ' -> '}[h] + pp(t[2], D, hole) + ')'
    if h in BIND: return h + (NM[D] if D < len(NM) else 'v%d' % D) + '.' + pp(t[1], D + 1, hole)
    if h in ('M', 'C'):
        return t[1] + ('(' + ','.join(pp(a, D, hole) for a in t[2]) + ')' if t[2] else '')
    return str(t)

def ppm(m):
    """print a motive body: hole = x, internal binders y, z, ..."""
    def go(t, r):
        h = t[0]
        if h == 'h': return 'x'
        if h == 'v': return 'yzuvw'[t[1]]
        if h == '0': return '0'
        if h == 'S': return 'S' + go(t[1], r) if t[1][0] in ('0', 'v', 'h', 'S') else 'S(' + go(t[1], r) + ')'
        if h in ('+', '*'): return '(' + go(t[1], r) + h + go(t[2], r) + ')'
        if h == '=': return go(t[1], r) + '=' + go(t[2], r)
        if h == '~': return '~' + go(t[1], r)
        if h in ('&', '|', '>'): return '(' + go(t[1], r) + {'&': '&', '|': 'v', '>': '->'}[h] + go(t[2], r) + ')'
        if h in BIND: return h + 'yzuvw'[r] + '.' + go(t[1], r + 1)
    return go(m, 0)
