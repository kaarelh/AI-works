# Track "cases", Part 2: second-order templates over the language of set theory {in, =}, de Bruijn.
#
# Terms:     ('v',k) bound variable (de Bruijn index k)   ('p',name) parameter (free name)
#            ('h',m) hole m of a lambda-body (metavariable values only)
# Formulas:  ('in',a,b) ('eq',a,b) ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('iff',f,g)
#            ('all',f) ('ex',f) ('exu',f)            [exu = 'there is exactly one', a primitive binder]
# Templates: may contain ('M',name,arg1..argn), args metavariable-free terms (here: bound variables).
#            Frozen metavariables ('C',name,args..) are rigid symbols (used for subsumption tests).
# Instances: substitute closed lambda-bodies (holes h0..h_{n-1}, parameters allowed, no loose index)
#            for metavariables and beta-reduce (one-step plugging; bodies are first-order).
import itertools, sys
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
import terms as T1

BINDERS = ('all', 'ex', 'exu')
FORM_HEADS = {'in', 'eq', 'not', 'and', 'or', 'imp', 'iff', 'all', 'ex', 'exu'}
TERM_HEADS = {'v', 'p', 'h'}

def V(k): return ('v', k)
def Par(n): return ('p', n)
def H(m): return ('h', m)
def IN(a, b): return ('in', a, b)
def EQ(a, b): return ('eq', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def OR(f, g): return ('or', f, g)
def IMP(f, g): return ('imp', f, g)
def IFF(f, g): return ('iff', f, g)
def ALL(f): return ('all', f)
def EX(f): return ('ex', f)
def EXU(f): return ('exu', f)
def M(name, *args): return ('M', name) + tuple(args)
TOP = ALL(EQ(V(0), V(0)))            # a closed true formula
BOT = NOT(TOP)                      # a closed false formula
v0, v1, v2, v3, v4 = V(0), V(1), V(2), V(3), V(4)

def kids(t):
    h = t[0]
    if h in ('v', 'h', 'p'): return ()
    if h in ('M', 'C'): return t[2:]
    return t[1:]

def rebuild(t, ks):
    h = t[0]
    if h in ('v', 'h', 'p'): return t
    if h in ('M', 'C'): return (h, t[1]) + tuple(ks)
    return (h,) + tuple(ks)

def size(t): return 1 + sum(size(k) for k in kids(t))

def shift(t, j, cut=0):
    if j == 0: return t
    h = t[0]
    if h == 'v': return ('v', t[1] + j) if t[1] >= cut else t
    if h in ('h', 'p'): return t
    if h in BINDERS: return (h, shift(t[1], j, cut + 1))
    return rebuild(t, [shift(k, j, cut) for k in kids(t)])

def plug(body, args, j=0):
    """beta-reduce (lambda h0..h_{n-1}. body)(args); args relative to the occurrence context"""
    h = body[0]
    if h == 'h': return shift(args[body[1]], j)
    if h in ('v', 'p'): return body
    if h in BINDERS: return (h, plug(body[1], args, j + 1))
    return rebuild(body, [plug(k, args, j) for k in kids(body)])

def instantiate(T, theta):
    h = T[0]
    if h == 'M':
        args = [instantiate(a, theta) for a in T[2:]]
        return plug(theta[T[1]], args)
    if h in ('v', 'h', 'p'): return T
    return rebuild(T, [instantiate(k, theta) for k in kids(T)])

def loose(t, j=0, acc=None):
    """set of loose de Bruijn indices (relative to the root of t)"""
    if acc is None: acc = set()
    h = t[0]
    if h == 'v':
        if t[1] >= j: acc.add(t[1] - j)
        return acc
    if h in BINDERS: return loose(t[1], j + 1, acc)
    for k in kids(t): loose(k, j, acc)
    return acc

def is_sentence(t): return not loose(t)

def holes(t, acc=None):
    if acc is None: acc = set()
    if t[0] == 'h': acc.add(t[1])
    for k in kids(t): holes(k, acc)
    return acc

def metas(T, acc=None):
    if acc is None: acc = {}
    if T[0] == 'M': acc.setdefault(T[1], []).append(T[2:])
    for k in kids(T): metas(k, acc)
    return acc

def subterms(t, acc=None):
    if acc is None: acc = []
    acc.append(t)
    for k in kids(t): subterms(k, acc)
    return acc

# ------------------------------------------------------------------ matching (class SO-degree)
def rigid_collect(T, s, occ):
    if T[0] == 'M':
        occ.setdefault(T[1], []).append((s, T[2:])); return True
    if T[0] != s[0]: return False
    if T[0] in ('v', 'h', 'p'): return T == s
    if T[0] == 'C' and (T[1] != s[1] or len(T) != len(s)): return False
    kT, ks = kids(T), kids(s)
    if len(kT) != len(ks): return False
    return all(rigid_collect(a, b, occ) for a, b in zip(kT, ks))

def exists_body(pairs, j=0):
    """closed body B with plug(B,args)==c for all (c,args)?  projection/imitation, polynomial."""
    n = len(pairs[0][1])
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs): return True
    c0 = pairs[0][0]; h = c0[0]
    for c, _ in pairs:
        if c[0] != h or len(c) != len(c0): return False
    if h == 'v': return c0[1] < j and all(c == c0 for c, _ in pairs)
    if h == 'p': return all(c == c0 for c, _ in pairs)
    if h == 'C' and any(c[1] != c0[1] for c, _ in pairs): return False
    if h in ('M', 'h'): raise ValueError('content must be ground')
    jj = j + 1 if h in BINDERS else j
    ks = [kids(c) for c, _ in pairs]
    return all(exists_body([(ks[i][a], pairs[i][1]) for i in range(len(pairs))], jj) for a in range(len(ks[0])))

def one_body(pairs, j=0):
    n = len(pairs[0][1])
    for m in range(n):
        if all(c == shift(args[m], j) for c, args in pairs): return ('h', m)
    c0 = pairs[0][0]; h = c0[0]
    for c, _ in pairs:
        if c[0] != h or len(c) != len(c0): return None
    if h == 'v': return c0 if (c0[1] < j and all(c == c0 for c, _ in pairs)) else None
    if h == 'p': return c0 if all(c == c0 for c, _ in pairs) else None
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

def solve(T, s):
    occ = {}
    if not rigid_collect(T, s, occ): return None
    th = {}
    for nm, p in occ.items():
        b = one_body(p)
        if b is None: return None
        th[nm] = b
    return th

def freeze(T):
    if T[0] == 'M': return ('C', T[1]) + tuple(freeze(a) for a in T[2:])
    if T[0] in ('v', 'h', 'p'): return T
    return rebuild(T, [freeze(k) for k in kids(T)])

def subsumes(T1_, T2_):
    """T1_ at least as general as T2_"""
    return covers(T1_, freeze(T2_))

def equiv(a, b): return subsumes(a, b) and subsumes(b, a)

def pattern_args(args): return all(a[0] == 'v' for a in args) and len(set(args)) == len(args)

def rigid_occurrences(T, acc=None):
    if acc is None: acc = {}
    if T[0] == 'M':
        acc.setdefault(T[1], []).append(T[2:]); return acc
    for k in kids(T): rigid_occurrences(k, acc)
    return acc

def is_determinate(T):
    allm = metas(T); rig = rigid_occurrences(T)
    return all(nm in rig and any(pattern_args(a) for a in rig[nm]) for nm in allm)

def is_pattern_template(T):
    """Miller pattern: every occurrence applied to distinct bound variables"""
    return all(pattern_args(a) for occs in metas(T).values() for a in occs)

def canon(T):
    ren = {}
    def R(t):
        if t[0] == 'M':
            if t[1] not in ren: ren[t[1]] = ('P%d' if t[1][0].isupper() else 'f%d') % len(ren)
            return ('M', ren[t[1]]) + tuple(R(a) for a in t[2:])
        if t[0] in ('v', 'h', 'p'): return t
        return rebuild(t, [R(k) for k in kids(t)])
    return R(T)

# ------------------------------------------------------------------ printing (named by binder depth)
BN = ['x0', 'x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7']
def pp(t, d=0, hn=None):
    h = t[0]
    if h == 'v':
        lvl = d - 1 - t[1]
        return BN[lvl] if 0 <= lvl < len(BN) else '#%d' % t[1]
    if h == 'p': return t[1]
    if h == 'h': return (hn[t[1]] if hn and t[1] < len(hn) else 'h%d' % t[1])
    if h == 'in': return pp(t[1], d, hn) + '∈' + pp(t[2], d, hn)
    if h == 'eq': return pp(t[1], d, hn) + '=' + pp(t[2], d, hn)
    if h == 'not': return '¬' + pp(t[1], d, hn)
    if h in ('and', 'or', 'imp', 'iff'):
        op = {'and': ' ∧ ', 'or': ' ∨ ', 'imp': ' → ', 'iff': ' ↔ '}[h]
        return '(' + pp(t[1], d, hn) + op + pp(t[2], d, hn) + ')'
    if h in BINDERS:
        q = {'all': '∀', 'ex': '∃', 'exu': '∃!'}[h]
        return q + BN[d] + '.' + pp(t[1], d + 1, hn)
    if h in ('M', 'C'):
        return t[1] + ('(' + ','.join(pp(a, d, hn) for a in t[2:]) + ')' if len(t) > 2 else '')
    return str(t)

# ------------------------------------------------------------------ the ZF schemas (closure-normal form)
# Each schema: template T* with one metavariable P; 'args' names P's arguments (for the (N_i) events).
SCHEMAS = {
    # Separation, Kunen-style: phi may mention the bounding set z.   Az Ey Ax (x in y <-> x in z & P(x,z))
    'Sep':    dict(T=ALL(EX(ALL(IFF(IN(v0, v1), AND(IN(v0, v2), M('P', v0, v2)))))), args=('x', 'z')),
    # Separation, Jech-style: phi(u,p) does not mention X.        AX EY Au (u in Y <-> u in X & P(u))
    'SepJ':   dict(T=ALL(EX(ALL(IFF(IN(v0, v1), AND(IN(v0, v2), M('P', v0)))))), args=('u',)),
    # epsilon-induction:  Ax(Ay(y in x -> P(y)) -> P(x)) -> Ax P(x)
    'EInd':   dict(T=IMP(ALL(IMP(ALL(IMP(IN(v0, v1), M('P', v0))), M('P', v0))), ALL(M('P', v0))), args=('x',)),
    # Collection, phi may mention A:  AA(Ax(x in A -> Ey P(x,y,A)) -> EY Ax(x in A -> Ey(y in Y & P(x,y,A))))
    'Coll':   dict(T=ALL(IMP(ALL(IMP(IN(v0, v1), EX(M('P', v1, v0, v2)))),
                             EX(ALL(IMP(IN(v0, v2), EX(AND(IN(v0, v2), M('P', v1, v0, v3)))))))), args=('x', 'y', 'A')),
    # Replacement with E! primitive (Kunen 1980 form)
    'ReplU':  dict(T=ALL(IMP(ALL(IMP(IN(v0, v1), EXU(M('P', v1, v0, v2)))),
                             EX(ALL(IMP(IN(v0, v2), EX(AND(IN(v0, v2), M('P', v1, v0, v3)))))))), args=('x', 'y', 'A')),
    # Replacement, E! spelled out:  Ey(P(x,y,A) & Au(P(x,u,A) -> u = y))
    'ReplS':  dict(T=ALL(IMP(ALL(IMP(IN(v0, v1), EX(AND(M('P', v1, v0, v2), ALL(IMP(M('P', v2, v0, v3), EQ(v0, v1))))))),
                             EX(ALL(IMP(IN(v0, v2), EX(AND(IN(v0, v2), M('P', v1, v0, v3)))))))), args=('x', 'y', 'A')),
    # Replacement, Jech 2003 form:  AxAyAu(P(x,y) & P(x,u) -> y = u) -> AX EY Ay(y in Y <-> Ex(x in X & P(x,y)))
    'ReplJ':  dict(T=IMP(ALL(ALL(ALL(IMP(AND(M('P', v2, v1), M('P', v2, v0)), EQ(v1, v0))))),
                         ALL(EX(ALL(IFF(IN(v0, v1), EX(AND(IN(v0, v3), M('P', v0, v1)))))))), args=('x', 'y')),
}
FOUNDATION = ALL(IMP(EX(IN(v0, v1)), EX(AND(IN(v0, v1), ALL(IMP(IN(v0, v1), NOT(IN(v0, v2))))))))

def instance(name, body):
    return instantiate(SCHEMAS[name]['T'], {'P': body})

def body_root(b): return b[0]

def pred_R(bodies): return len({body_root(b) for b in bodies}) >= 2
def pred_N(bodies, n): return [any(i in holes(b) for b in bodies) for i in range(n)]

# ------------------------------------------------------------------ named encoding (textbook names)
# Frame variables carry fixed names; phi's internal bound variables are named w0, w1, .. by internal depth;
# parameters keep their names.  Output: T1-style tuples, variables/parameters as constants ('x',).
def _A(v, f): return ('all', v, f)
def _E(v, f): return ('ex', v, f)
def _EU(v, f): return ('exu', v, f)
def _I(f, g): return ('imp', f, g)
def _N(f, g): return ('and', f, g)
def _IFF(f, g): return ('iff', f, g)
def _in(a, b): return ('in', a, b)
def _eq(a, b): return ('eq', a, b)
def _P(*a): return ('P',) + a
_COLL_CONS = _E('Y', _A('x', _I(_in('x', 'A'), _E('y', _N(_in('y', 'Y'), _P('x', 'y', 'A'))))))
NAMED_FRAMES = {
    'Sep':   _A('z', _E('y', _A('x', _IFF(_in('x', 'y'), _N(_in('x', 'z'), _P('x', 'z')))))),
    'SepJ':  _A('X', _E('Y', _A('u', _IFF(_in('u', 'Y'), _N(_in('u', 'X'), _P('u')))))),
    'EInd':  _I(_A('x', _I(_A('y', _I(_in('y', 'x'), _P('y'))), _P('x'))), _A('x', _P('x'))),
    'Coll':  _A('A', _I(_A('x', _I(_in('x', 'A'), _E('y', _P('x', 'y', 'A')))), _COLL_CONS)),
    'ReplU': _A('A', _I(_A('x', _I(_in('x', 'A'), _EU('y', _P('x', 'y', 'A')))), _COLL_CONS)),
    'ReplS': _A('A', _I(_A('x', _I(_in('x', 'A'), _E('y', _N(_P('x', 'y', 'A'),
                                                            _A('u', _I(_P('x', 'u', 'A'), _eq('u', 'y'))))))), _COLL_CONS)),
    'ReplJ': _I(_A('x', _A('y', _A('u', _I(_N(_P('x', 'y'), _P('x', 'u')), _eq('y', 'u'))))),
                _A('X', _E('Y', _A('y', _IFF(_in('y', 'Y'), _E('x', _N(_in('x', 'X'), _P('x', 'y')))))))),
}

def body_named(b, argnames, d=0):
    """phi's lambda-body -> named T1 term; holes -> argnames, internal binders -> w<depth>"""
    h = b[0]
    if h == 'h': return (argnames[b[1]],)
    if h == 'p': return (b[1],)
    if h == 'v':
        return ('w%d' % (d - 1 - b[1]),)
    if h in BINDERS: return (h, ('w%d' % d,), body_named(b[1], argnames, d + 1))
    return (h,) + tuple(body_named(k, argnames, d) for k in kids(b))

def named_instance(name, body, A=None):
    """A: optional dict metaname->T1 term to substitute instead (for building lgg instances)"""
    def go(f):
        if isinstance(f, str): return (f,)
        if f[0] == 'P': return body_named(body, f[1:])
        if f[0] in BINDERS: return (f[0], (f[1],), go(f[2]))
        return (f[0],) + tuple(go(k) for k in f[1:])
    return go(NAMED_FRAMES[name])

def named_frame_term(name, slotvars):
    """the named frame with the i-th P-occurrence replaced by T1 metavariable slotvars[i]"""
    cnt = [0]
    def go(f):
        if isinstance(f, str): return (f,)
        if f[0] == 'P':
            v = slotvars[cnt[0]]; cnt[0] += 1; return ('?', v)
        if f[0] in BINDERS: return (f[0], (f[1],), go(f[2]))
        return (f[0],) + tuple(go(k) for k in f[1:])
    return go(NAMED_FRAMES[name])

def n_slots(name):
    c = [0]
    def go(f):
        if isinstance(f, str): return
        if f[0] == 'P': c[0] += 1; return
        for k in f[1:]: go(k)
    go(NAMED_FRAMES[name]); return c[0]

# ------------------------------------------------------------------ de Bruijn first-order encoding
def to_db(t):
    """de Bruijn formula -> T1 term; indices become constants '#k'; metavariables -> T1 metavariables"""
    h = t[0]
    if h == 'v': return ('#%d' % t[1],)
    if h == 'p': return (t[1],)
    if h == 'M': return ('?', t[1])
    return (h,) + tuple(to_db(k) for k in kids(t))

def from_db(t):
    if T1.is_var(t): return ('M', t[1])
    if len(t) == 1:
        if t[0].startswith('#'): return ('v', int(t[0][1:]))
        return ('p', t[0])
    return (t[0],) + tuple(from_db(k) for k in t[1:])

def db_frame_term(name, slotvars):
    cnt = [0]
    def go(t):
        if t[0] == 'M':
            v = slotvars[cnt[0]]; cnt[0] += 1; return ('?', v)
        if t[0] == 'v': return ('#%d' % t[1],)
        return (t[0],) + tuple(go(k) for k in kids(t))
    return go(SCHEMAS[name]['T'])

def fo_subst(t, th):
    if T1.is_var(t): return th[t[1]]
    if len(t) == 1: return t
    return (t[0],) + tuple(fo_subst(a, th) for a in t[1:])

# ------------------------------------------------------------------ higher-order pattern lgg (n-ary)
def abstract(c, ys, j=0):
    """replace the context variables ys (indices relative to the slot) by holes, under j internal binders"""
    h = c[0]
    if h == 'v':
        if c[1] >= j:
            k = c[1] - j
            return ('h', ys.index(k)) if k in ys else None
        return c
    if h in ('p',): return c
    if h in BINDERS:
        r = abstract(c[1], ys, j + 1)
        return None if r is None else (h, r)
    out = []
    for k in kids(c):
        r = abstract(k, ys, j)
        if r is None: return None
        out.append(r)
    return rebuild(c, out)

def pattern_lgg(data):
    """least general higher-order pattern generalization (BKLV-style, n-ary):
    common prefix; at a disagreement slot a generalization variable applied to the bound variables
    (innermost first) occurring free in some column entry; slots whose abstracted columns agree up to a
    permutation of the arguments share one variable (the merge rule)."""
    slots = []   # (key=tuple of abstracted bodies, name, ys)
    def go(cols, D):
        c0 = cols[0]
        if all(c == c0 for c in cols): return c0
        if c0[0] not in ('v', 'p', 'h') and all(c[0] == c0[0] and len(c) == len(c0) for c in cols):
            nD = D + 1 if c0[0] in BINDERS else D
            ks = [kids(c) for c in cols]
            return rebuild(c0, [go([k[i] for k in ks], nD) for i in range(len(ks[0]))])
        free = set()
        for c in cols: free |= loose(c)
        ys = sorted(free)
        bodies = tuple(abstract(c, ys) for c in cols)
        for key, nm, ys2 in slots:
            if len(ys2) != len(ys): continue
            for perm in itertools.permutations(range(len(ys))):
                # does key (bodies with holes 0..n-1) with holes renamed by perm equal bodies?
                ren = tuple(rename_holes(b, perm) for b in key)
                if ren == bodies:
                    # bodies = key[perm]: hole m of key is our hole perm[m] -> args (ys[perm[m]])_m
                    return ('M', nm) + tuple(V(ys[perm[m]]) for m in range(len(ys)))
        nm = 'X%d' % len(slots) if c0[0] in FORM_HEADS else 'g%d' % len(slots)
        slots.append((bodies, nm, ys))
        return ('M', nm) + tuple(V(k) for k in ys)
    return go(list(data), 0)

def rename_holes(b, perm):
    if b[0] == 'h': return ('h', perm[b[1]])
    if b[0] in ('v', 'p'): return b
    return rebuild(b, [rename_holes(k, perm) for k in kids(b)])
