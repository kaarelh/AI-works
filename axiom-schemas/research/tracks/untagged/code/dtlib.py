# dtlib.py -- determinate second-order templates (class DT deg) over a first-order object language,
# closure-normal form (free variables = parameters ('p', name)), bound variables as de Bruijn indices.
#
# Object syntax (tuples):
#   terms     ('0',) ('S',t) ('+',a,b) ('*',a,b) ('v',k) [bound var, de Bruijn] ('p',name) [parameter]
#             ('#',n) [an evaluated numeral / HF-set constant used only inside refuters]
#   formulas  ('=',a,b) ('in',a,b) ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('iff',f,g) ('all',f) ('ex',f)
#             ('bot',) ('top',)
# Templates add metavariable occurrences ('M', name, arg1..argn); name[0]=='F' -> formula-valued,
#   name[0]=='t' -> term-valued.  Bodies of metavariables use holes ('h', j).
# Frozen metavariables (for subsumption) are rigid nodes ('C', name, args...).
#
# Instances: substitute closed-up lambda terms (bodies with holes; free variables = parameters only) and
# beta-reduce by one-step plugging (bodies are first order, so no redex cascade).
import itertools

TERM_HEADS = {'0', 'S', '+', '*', 'v', 'p', '#'}
FORM_HEADS = {'=', 'in', 'not', 'and', 'or', 'imp', 'iff', 'all', 'ex', 'bot', 'top'}
BINDERS = ('all', 'ex')

def kids(t):
    h = t[0]
    if h in ('v', 'h', 'p', '#', '0', 'bot', 'top'): return ()
    if h in ('M', 'C'): return t[2:]
    return t[1:]

def rebuild(t, ks):
    h = t[0]
    if h in ('v', 'h', 'p', '#', '0', 'bot', 'top'): return t
    if h in ('M', 'C'): return (h, t[1]) + tuple(ks)
    return (h,) + tuple(ks)

def child_sorts(t):
    h = t[0]
    if h in ('=', 'in', 'S', '+', '*'): return ['T'] * len(kids(t))
    if h in ('M', 'C'): return ['T'] * len(kids(t))
    return ['F'] * len(kids(t))

def sort_of(t):
    h = t[0]
    if h in ('M', 'C'): return 'F' if t[1][0] == 'F' else 'T'
    if h == 'h': return 'T'
    return 'T' if h in TERM_HEADS else 'F'

def size(t):
    return 1 + sum(size(k) for k in kids(t))

def shift(t, j, cut=0):
    if j == 0: return t
    h = t[0]
    if h == 'v': return ('v', t[1] + j) if t[1] >= cut else t
    if h in BINDERS: return (h, shift(t[1], j, cut + 1))
    ks = kids(t)
    if not ks: return t
    return rebuild(t, [shift(k, j, cut) for k in ks])

def fbv(t, cut=0, acc=None):
    """free de Bruijn indices of t (relative to t's own context)"""
    if acc is None: acc = set()
    h = t[0]
    if h == 'v':
        if t[1] >= cut: acc.add(t[1] - cut)
        return acc
    if h in BINDERS:
        fbv(t[1], cut + 1, acc); return acc
    for k in kids(t): fbv(k, cut, acc)
    return acc

def params(t, acc=None):
    if acc is None: acc = []
    if t[0] == 'p':
        if t[1] not in acc: acc.append(t[1])
        return acc
    for k in kids(t): params(k, acc)
    return acc

def rename_params(t, ren):
    if t[0] == 'p': return ('p', ren.get(t[1], t[1]))
    ks = kids(t)
    if not ks: return t
    return rebuild(t, [rename_params(k, ren) for k in ks])

def canon_params(t):
    """rename parameters a1, a2, ... in order of first occurrence (preorder)"""
    ps = params(t)
    ren = {p: 'a%d' % (i + 1) for i, p in enumerate(ps)}
    tmp = {p: '__%d' % i for i, p in enumerate(ps)}
    t = rename_params(t, tmp)
    return rename_params(t, {'__%d' % i: ren[p] for i, p in enumerate(ps)})

def plug(body, args, j=0):
    """beta-reduce (lambda h0..h_{n-1}. body)(args); args are terms in the occurrence context"""
    h = body[0]
    if h == 'h': return shift(args[body[1]], j)
    if h in BINDERS: return (h, plug(body[1], args, j + 1))
    ks = kids(body)
    if not ks: return body
    return rebuild(body, [plug(k, args, j) for k in ks])

def instantiate(T, theta):
    h = T[0]
    if h == 'M':
        args = [instantiate(a, theta) for a in T[2:]]
        return plug(theta[T[1]], args)
    ks = kids(T)
    if not ks: return T
    return rebuild(T, [instantiate(k, theta) for k in ks])

def metas(T, acc=None):
    """name -> list of argument tuples"""
    if acc is None: acc = {}
    if T[0] == 'M':
        acc.setdefault(T[1], []).append(T[2:])
    for k in kids(T): metas(k, acc)
    return acc

def is_ground(t):
    if t[0] in ('M', 'h'): return False
    return all(is_ground(k) for k in kids(t))

def abstract(content, ys, j=0):
    """content lives under ys-binders (indices relative to occurrence); replace free ('v', ys[m]) by ('h', m).
    Returns None if content has a free bound variable not among ys."""
    h = content[0]
    if h == 'v':
        if content[1] < j: return content
        k = content[1] - j
        if k in ys: return ('h', ys.index(k))
        return None
    if h in BINDERS:
        b = abstract(content[1], ys, j + 1)
        return None if b is None else (h, b)
    ks = kids(content)
    if not ks: return content
    out = []
    for k in ks:
        b = abstract(k, ys, j)
        if b is None: return None
        out.append(b)
    return rebuild(content, out)

def shift_down(t, j, cut=0):
    h = t[0]
    if h == 'v': return ('v', t[1] - j) if t[1] >= cut else t
    if h in BINDERS: return (h, shift_down(t[1], j, cut + 1))
    ks = kids(t)
    if not ks: return t
    return rebuild(t, [shift_down(k, j, cut) for k in ks])

def unshift(t, j):
    if j == 0: return t
    fv = fbv(t)
    if any(k < j for k in fv): return None
    return shift_down(t, j)

def match_body(body, target, assign, j=0):
    """first-order match of a body (holes = pattern vars, terms) against target; under j internal binders.
    assign: dict hole -> term (relative to the outer context). Returns True/False (assign updated)."""
    h = body[0]
    if h == 'h':
        u = unshift(target, j)
        if u is None: return False
        m = body[1]
        if m in assign: return assign[m] == u
        assign[m] = u; return True
    if h != target[0]: return False
    if h in ('v', 'p', '#'): return body == target
    if h in ('M', 'C') and (body[1] != target[1] or len(body) != len(target)): return False
    if h in BINDERS: return match_body(body[1], target[1], assign, j + 1)
    kb, kt = kids(body), kids(target)
    if len(kb) != len(kt): return False
    return all(match_body(a, b, assign, j) for a, b in zip(kb, kt))

# ---------------------------------------------------------------------------- matching (membership)
def rigid_collect(T, s, occ, depth=0):
    if T[0] == 'M':
        occ.setdefault(T[1], []).append((s, T[2:], depth))
        return True
    if T[0] != s[0]: return False
    if T[0] in ('v', 'h', 'p', '#'): return T == s
    if T[0] == 'C' and (T[1] != s[1] or len(T) != len(s)): return False
    kT, ks = kids(T), kids(s)
    if len(kT) != len(ks): return False
    d2 = depth + 1 if T[0] in BINDERS else depth
    return all(rigid_collect(a, b, occ, d2) for a, b in zip(kT, ks))

def pattern_args(args):
    return all(a[0] == 'v' for a in args) and len(set(args)) == len(args)

def exists_body(pairs, j=0):
    """general second-order matching with ground arguments (projection/imitation); pairs = [(content, args)]"""
    n = len(pairs[0][1])
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs):
            return True
    c0 = pairs[0][0]
    h = c0[0]
    for c, _ in pairs:
        if c[0] != h or len(c) != len(c0): return False
    if h in ('v',):
        return c0[1] < j and all(c == c0 for c, _ in pairs)
    if h in ('p', '#', '0', 'bot', 'top'):
        return all(c == c0 for c, _ in pairs)
    if h == 'C' and any(c[1] != c0[1] for c, _ in pairs): return False
    jj = j + 1 if h in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    return all(exists_body([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj)
               for a in range(len(ks[0])))

def match(T, s):
    """return theta with instantiate(T, theta) == s, or None. Determinate templates: unique theta via a pattern
    occurrence; otherwise fall back to existence check (returns {} as a witness flag)."""
    occ = {}
    if not rigid_collect(T, s, occ): return None
    theta = {}
    general = False
    for name, lst in occ.items():
        body = None
        for (c, args, d) in lst:
            if pattern_args(args):
                ys = [a[1] for a in args]
                body = abstract(c, ys)
                if body is None: return None
                break
        if body is None:
            general = True
            if not exists_body([(c, args) for (c, args, d) in lst]): return None
            continue
        for (c, args, d) in lst:
            if plug(body, list(args)) != c: return None
        theta[name] = body
    if general: return {}
    return theta

def covers(T, s): return match(T, s) is not None
def covers_all(T, D): return all(covers(T, s) for s in D)

def freeze(T):
    if T[0] == 'M': return ('C', T[1]) + tuple(freeze(a) for a in T[2:])
    ks = kids(T)
    if not ks: return T
    return rebuild(T, [freeze(k) for k in ks])

def subsumes(T1, T2):
    """T1 at least as general as T2 (syntactic: T2 = T1 sigma)"""
    return covers(T1, freeze(T2))

def is_determinate(T):
    occ = {}
    def walk(t, d):
        if t[0] == 'M':
            occ.setdefault(t[1], []).append(t[2:]); return
        dd = d + 1 if t[0] in BINDERS else d
        for k in kids(t): walk(k, dd)
    walk(T, 0)
    return all(any(pattern_args(a) for a in lst) for lst in occ.values())

def canon(T):
    """rename metavariables in order of first occurrence (preorder): F0,F1,.. / t0,t1,.."""
    ren = {}
    cnt = {'F': 0, 't': 0}
    def R(t):
        if t[0] == 'M':
            nm = t[1]
            if nm not in ren:
                s = 'F' if nm[0] == 'F' else 't'
                ren[nm] = '%s%d' % (s, cnt[s]); cnt[s] += 1
            return ('M', ren[nm]) + tuple(R(a) for a in t[2:])
        ks = kids(t)
        if not ks: return t
        return rebuild(t, [R(k) for k in ks])
    return R(T)

def equivalent(T1, T2): return subsumes(T1, T2) and subsumes(T2, T1)

def minimal_antichain(Ts):
    """keep templates not strictly more general than another (syntactic subsumption), dedupe equivalents"""
    Ts = list(dict.fromkeys(canon(T) for T in Ts))
    keep = []
    for i, T in enumerate(Ts):
        dominated = False
        for j, U in enumerate(Ts):
            if i == j: continue
            if subsumes(T, U):            # T >= U
                if not subsumes(U, T):     # strictly
                    dominated = True; break
                elif j < i:                # equivalent, keep first
                    dominated = True; break
        if not dominated: keep.append(T)
    return keep

# ---------------------------------------------------------------------------- common prefix and slots
class Node:
    __slots__ = ('cols', 'depth', 'common', 'kids', 'path', 'sort')
    def __init__(self, cols, depth, path, sort):
        self.cols, self.depth, self.path, self.sort = cols, depth, path, sort
        self.common, self.kids = False, []

def headkey(t):
    h = t[0]
    if h in ('v', 'p', '#'): return t
    if h in ('M', 'C'): return (h, t[1], len(t))
    return (h, len(t))

def build_prefix(cols, depth=0, path=(), sort='F'):
    nd = Node(cols, depth, path, sort)
    k0 = headkey(cols[0])
    if all(headkey(c) == k0 for c in cols):
        nd.common = True
        ks = [kids(c) for c in cols]
        dd = depth + 1 if cols[0][0] in BINDERS else depth
        srts = child_sorts(cols[0])
        nd.kids = [build_prefix([k[i] for k in ks], dd, path + (i,), srts[i]) for i in range(len(ks[0]))]
    return nd

def all_nodes(nd, acc=None):
    if acc is None: acc = []
    acc.append(nd)
    for k in nd.kids: all_nodes(k, acc)
    return acc

def slots_of(nd):
    return [x for x in all_nodes(nd) if not x.common]

def derive_args(src_bodies, cols_q, depth_q):
    """find u (terms in q's context) with plug(body_i, u) == cols_q[i] for all i; None if impossible"""
    assign = {}
    for b, c in zip(src_bodies, cols_q):
        if not match_body(b, c, assign): return None
    n = max([m for b in src_bodies for m in holes_of(b)] + [-1]) + 1
    if any(m not in assign for m in range(n)): return None
    u = [assign[m] for m in range(n)]
    for b, c in zip(src_bodies, cols_q):
        if plug(b, u) != c: return None
    return u

def holes_of(t, acc=None):
    if acc is None: acc = set()
    if t[0] == 'h': acc.add(t[1]); return acc
    for k in kids(t): holes_of(k, acc)
    return acc

def is_ancestor(p, q):
    return len(p) < len(q) and q[:len(p)] == p

def mincov(X, max_templates=50000, max_antichain=4096):
    """Minimal covering DT deg templates of the finite set X (list of formulas).
    Search space (argued complete in notes, cross-validated in u0): the rigid common prefix of X, in which
      (1) an antichain R of common nodes is replaced by derived occurrences M_pi(u) of sources pi outside R's subtrees;
      (2) among the remaining slots, one source (pattern occurrence with minimal arguments) per root class of the
          derivability preorder, every other remaining slot derived from some source (all choices);
    then the syntactically minimal covering templates are kept."""
    X = list(dict.fromkeys(X))
    if len(X) == 1: return [X[0]]
    root = build_prefix(X)
    nodes = all_nodes(root)
    slots = [x for x in nodes if not x.common]
    info = {}
    for s in slots:
        ys = sorted(set().union(*[fbv(c) for c in s.cols]))
        info[s.path] = (ys, [abstract(c, ys) for c in s.cols])
    der = {}
    for s in slots:
        for p in slots:
            if s is p or p.sort != s.sort: continue
            u = derive_args(info[p.path][1], s.cols, s.depth)
            if u is not None: der[(s.path, p.path)] = u
    # potential derived occurrences at common nodes (sources must have a bare-hole body)
    proj = [p for p in slots if any(b[0] == 'h' for b in info[p.path][1])]
    cder = {}
    for q in nodes:
        if not q.common or q is root and False: continue
        for p in proj:
            if p.sort != q.sort or is_ancestor(q.path, p.path): continue
            u = derive_args(info[p.path][1], q.cols, q.depth)
            if u is not None: cder.setdefault(q.path, []).append((p.path, u))
    cpaths = sorted(cder)
    # antichains of common nodes
    antichains = [()]
    def ext(i, cur):
        for j in range(i, len(cpaths)):
            q = cpaths[j]
            if any(is_ancestor(r, q) or is_ancestor(q, r) for r in cur): continue
            nc = cur + (q,)
            antichains.append(nc)
            if len(antichains) >= max_antichain: return
            ext(j + 1, nc)
    ext(0, ())
    out = []
    for R in antichains:
        rem = [s for s in slots if not any(is_ancestor(r, s.path) for r in R)]
        rp = [s.path for s in rem]
        def can(s, p): return (s, p) in der
        roots = [p for p in rp if all(can(q, p) for q in rp if q != p and can(p, q))]
        reps = []
        for p in roots:
            if not any(can(p, r) and can(r, p) for r in reps): reps.append(p)
        rset = set(reps)
        names = {p: ('F' if info_sort(slots, p) == 'F' else 't') + 'm%d' % i for i, p in enumerate(reps)}
        opts = {}
        ok = True
        for s in rem:
            if s.path in rset:
                opts[s.path] = [('M', names[s.path]) + tuple(('v', y) for y in info[s.path][0])]
            else:
                o = [('M', names[p]) + tuple(der[(s.path, p)]) for p in reps if can(s.path, p)]
                if not o: ok = False; break
                opts[s.path] = o
        if not ok: continue
        for r in R:
            o = [('M', names[p]) + tuple(u) for (p, u) in cder[r] if p in rset]
            if not o: ok = False; break
            opts[r] = o
        if not ok: continue
        def build(nd):
            if nd.path in opts:
                for o in opts[nd.path]: yield o
                return
            c0 = nd.cols[0]
            if not nd.kids:
                yield c0; return
            for combo in itertools.product(*[list(build(k)) for k in nd.kids]):
                yield rebuild(c0, list(combo))
        for T in build(root):
            out.append(T)
            if len(out) >= max_templates: break
        if len(out) >= max_templates: break
    out = [T for T in out if covers_all(T, X)]
    return minimal_antichain(out)

def info_sort(slots, p):
    for s in slots:
        if s.path == p: return s.sort
    raise KeyError(p)

def sort_of_slot(nd): return nd.sort
def sort_of_slot_path(slots, p):
    for s in slots:
        if s.path == p: return s.sort
    raise KeyError(p)

# ---------------------------------------------------------------------------- printing
VN = ['x', 'y', 'z', 'u', 'w', 'r', 's', 'q', 'b2', 'c2', 'd2']
def pp(t, depth=0, holes=None):
    h = t[0]
    if h == 'v':
        lvl = depth - 1 - t[1]
        return VN[lvl] if 0 <= lvl < len(VN) else '#%d' % t[1]
    if h == 'h': return (holes[t[1]] if holes else 'z%d' % t[1])
    if h == 'p': return t[1]
    if h == '#': return str(t[1])
    if h == '0': return '0'
    if h == 'bot': return 'F'
    if h == 'top': return 'T'
    if h == 'S':
        k, u = 0, t
        while u[0] == 'S': k, u = k + 1, u[1]
        inner = pp(u, depth, holes)
        if u[0] == '0': return 'S' * k + '0'
        if u[0] in ('v', 'p', 'M', 'C', 'h', '#'): return 'S' * k + inner
        return 'S' * k + '(' + inner + ')'
    if h in ('+', '*'): return '(' + pp(t[1], depth, holes) + h + pp(t[2], depth, holes) + ')'
    if h == '=': return pp(t[1], depth, holes) + '=' + pp(t[2], depth, holes)
    if h == 'in': return pp(t[1], depth, holes) + '∈' + pp(t[2], depth, holes)
    if h == 'not': return '¬' + pp(t[1], depth, holes)
    if h in ('and', 'or', 'imp', 'iff'):
        op = {'and': ' ∧ ', 'or': ' ∨ ', 'imp': ' → ', 'iff': ' ↔ '}[h]
        return '(' + pp(t[1], depth, holes) + op + pp(t[2], depth, holes) + ')'
    if h in BINDERS:
        q = '∀' if h == 'all' else '∃'
        nm = VN[depth] if depth < len(VN) else 'v%d' % depth
        return q + nm + '.' + pp(t[1], depth + 1, holes)
    if h in ('M', 'C'):
        if len(t) == 2: return t[1]
        return t[1] + '(' + ','.join(pp(a, depth, holes) for a in t[2:]) + ')'
    return str(t)

# ---------------------------------------------------------------------------- constructors
Z = ('0',)
def S(t): return ('S', t)
def num(n):
    t = Z
    for _ in range(n): t = S(t)
    return t
def add(a, b): return ('+', a, b)
def mul(a, b): return ('*', a, b)
def eq(a, b): return ('=', a, b)
def mem(a, b): return ('in', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def OR(f, g): return ('or', f, g)
def IMP(f, g): return ('imp', f, g)
def IFF(f, g): return ('iff', f, g)
def ALL(f): return ('all', f)
def EX(f): return ('ex', f)
def V(k): return ('v', k)
def P(n): return ('p', n)
def H(m=0): return ('h', m)
def M(name, *args): return ('M', name) + tuple(args)

def Ind(m):
    """raw induction instance for a motive body m (hole 0 = induction variable)"""
    return IMP(AND(plug(m, [Z]), ALL(IMP(plug(m, [V(0)]), plug(m, [S(V(0))])))), ALL(plug(m, [V(0)])))

T_IND = IMP(AND(M('FP', Z), ALL(IMP(M('FP', V(0)), M('FP', S(V(0)))))), ALL(M('FP', V(0))))
