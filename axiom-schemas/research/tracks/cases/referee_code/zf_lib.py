# Referee library (independent of the author's st_core.py): ZF schema frames in a named and a
# de Bruijn encoding, lambda-plugging of bodies, first-order anti-unification and matching, guards.
#
# Leaves are 1-tuples:  ('@x',) named variable x;  ('#3',) de Bruijn index 3;  ('$a',) parameter a;
#                       ('h0',) hole 0 of a body.  Metavariables of first-order schemas: ('?', name).
# Formulas: ('in',s,t) ('eq',s,t) ('neg',f) ('conj',f,g) ('impl',f,g) ('iff',f,g)
#           named binders ('fa',v,f) ('ex',v,f) ('ex1',v,f) with v a named-variable leaf;
#           de Bruijn binders ('fa',f) ('ex',f) ('ex1',f).
import itertools, random

BIND = ('fa', 'ex', 'ex1')

def nv(n): return ('@' + n,)
def ix(k): return ('#%d' % k,)
def par(n): return ('$' + n,)
def hole(i): return ('h%d' % i,)
def is_ix(t): return len(t) == 1 and t[0][0] == '#'
def ixv(t): return int(t[0][1:])
def is_hole(t): return len(t) == 1 and t[0][0] == 'h'
def holev(t): return int(t[0][1:])
def is_named(t): return len(t) == 1 and t[0][0] == '@'
def is_mv(t): return t[0] == '?'

TOPn = ('fa', nv('w9'), ('eq', nv('w9'), nv('w9')))     # named closed true formula
BOTn = ('neg', TOPn)

# ---------------- frames (named, textbook names) ----------------
def F_Sep(P):  return ('fa', nv('z'), ('ex', nv('y'), ('fa', nv('x'), ('iff', ('in', nv('x'), nv('y')),
                       ('conj', ('in', nv('x'), nv('z')), P(0, 'x', 'z'))))))
def F_SepJ(P): return ('fa', nv('X'), ('ex', nv('Y'), ('fa', nv('u'), ('iff', ('in', nv('u'), nv('Y')),
                       ('conj', ('in', nv('u'), nv('X')), P(0, 'u'))))))
def F_EInd(P): return ('impl', ('fa', nv('x'), ('impl', ('fa', nv('y'), ('impl', ('in', nv('y'), nv('x')), P(0, 'y'))),
                       P(1, 'x'))), ('fa', nv('x'), P(2, 'x')))
def _coll(P, q):
    return ('fa', nv('A'), ('impl', ('fa', nv('x'), ('impl', ('in', nv('x'), nv('A')), (q, nv('y'), P(0, 'x', 'y', 'A')))),
            ('ex', nv('Y'), ('fa', nv('x'), ('impl', ('in', nv('x'), nv('A')),
             ('ex', nv('y'), ('conj', ('in', nv('y'), nv('Y')), P(1, 'x', 'y', 'A'))))))))
def F_Coll(P): return _coll(P, 'ex')
def F_ReplU(P): return _coll(P, 'ex1')
def F_ReplS(P):
    return ('fa', nv('A'), ('impl', ('fa', nv('x'), ('impl', ('in', nv('x'), nv('A')),
            ('ex', nv('y'), ('conj', P(0, 'x', 'y', 'A'), ('fa', nv('u'), ('impl', P(1, 'x', 'u', 'A'), ('eq', nv('u'), nv('y')))))))),
            ('ex', nv('Y'), ('fa', nv('x'), ('impl', ('in', nv('x'), nv('A')),
             ('ex', nv('y'), ('conj', ('in', nv('y'), nv('Y')), P(2, 'x', 'y', 'A'))))))))
def F_ReplJ(P):
    return ('impl', ('fa', nv('x'), ('fa', nv('y'), ('fa', nv('u'), ('impl', ('conj', P(0, 'x', 'y'), P(1, 'x', 'u')),
            ('eq', nv('y'), nv('u')))))),
            ('fa', nv('X'), ('ex', nv('Y'), ('fa', nv('y'), ('iff', ('in', nv('y'), nv('Y')),
             ('ex', nv('x'), ('conj', ('in', nv('x'), nv('X')), P(2, 'x', 'y'))))))))

SCHEMAS = {'Sep': (F_Sep, 2, 1), 'SepJ': (F_SepJ, 1, 1), 'EInd': (F_EInd, 1, 3), 'Coll': (F_Coll, 3, 2),
           'ReplU': (F_ReplU, 3, 2), 'ReplS': (F_ReplS, 3, 3), 'ReplJ': (F_ReplJ, 2, 3)}
ARGNAMES = {'Sep': ('x', 'z'), 'SepJ': ('u',), 'EInd': ('x',), 'Coll': ('x', 'y', 'A'), 'ReplU': ('x', 'y', 'A'),
            'ReplS': ('x', 'y', 'A'), 'ReplJ': ('x', 'y')}
FRAME_NAMES = {'Sep': 'xyz', 'SepJ': 'XYu', 'EInd': 'xy', 'Coll': 'AxyY', 'ReplU': 'AxyY', 'ReplS': 'AxyYu', 'ReplJ': 'xyuXY'}

# ---------------- bodies (named, internal binders w0,w1,... by internal depth) ----------------
def plug_named(body, names, d=0):
    """lambda-body with holes -> named formula, hole i := variable names[i]"""
    if is_hole(body): return nv(names[holev(body)])
    if len(body) == 1: return body
    if body[0] in BIND:
        return (body[0], body[1], plug_named(body[2], names, d + 1))
    return (body[0],) + tuple(plug_named(c, names, d) for c in body[1:])

def build_named(schema, bodies):
    """bodies: list per occurrence (normally the same body at every occurrence)"""
    F = SCHEMAS[schema][0]
    return F(lambda k, *names: plug_named(bodies[k], names) if not is_mv(bodies[k]) else bodies[k])

def instance(schema, body):
    m = SCHEMAS[schema][2]
    return build_named(schema, [body] * m)

# ---------------- named -> de Bruijn ----------------
def to_db(f, env=()):
    if is_named(f):
        if f in env:
            return ix(len(env) - 1 - max(i for i, v in enumerate(env) if v == f))
        return ('$free_' + f[0][1:],)     # unbound name: a parameter
    if len(f) == 1 or is_mv(f): return f
    if f[0] in BIND:
        return (f[0], to_db(f[2], env + (f[1],)))
    return (f[0],) + tuple(to_db(c, env) for c in f[1:])

# ---------------- generic tree utilities ----------------
def positions(t, p=()):
    yield p, t
    if len(t) > 1 and not is_mv(t):
        for i, c in enumerate(t[1:]):
            yield from positions(c, p + (i,))

def at(t, p):
    for i in p: t = t[1 + i]
    return t

def replace(t, p, v):
    if not p: return v
    i = p[0]
    return t[:1 + i] + (replace(t[1 + i], p[1:], v),) + t[2 + i:]

def size(t): return sum(1 for _ in positions(t))

# ---------------- first-order anti-unification / matching ----------------
def au(ts, table):
    h0 = ts[0][0]; n0 = len(ts[0])
    if not any(is_mv(t) for t in ts) and all(t[0] == h0 and len(t) == n0 for t in ts):
        if n0 == 1: return ts[0]
        return (h0,) + tuple(au([t[i] for t in ts], table) for i in range(1, n0))
    key = tuple(ts)
    if key not in table: table[key] = ('?', 'A%d' % len(table))
    return table[key]

def lgg(ts):
    table = {}
    L = au(list(ts), table)
    return L, {v: k for k, v in table.items()}       # metavariable -> column

def match(pat, t, sub=None):
    if sub is None: sub = {}
    if is_mv(pat):
        if pat in sub: return sub if sub[pat] == t else None
        sub[pat] = t; return sub
    if pat[0] != t[0] or len(pat) != len(t): return None
    for a, b in zip(pat[1:], t[1:]):
        if match(a, b, sub) is None: return None
    return sub

def mv_positions(L):
    return [(p, s) for p, s in positions(L) if is_mv(s)]

# ---------------- free names / loose indices ----------------
def free_names(f, bound=()):
    if is_named(f): return set() if f in bound else {f[0][1:]}
    if len(f) == 1 or is_mv(f): return set()
    if f[0] in BIND and len(f) == 3:
        return free_names(f[2], bound + (f[1],))
    out = set()
    for c in f[1:]: out |= free_names(c, bound)
    return out

def loose(f, d=0):
    if is_ix(f): return {ixv(f) - d} if ixv(f) >= d else set()
    if len(f) == 1 or is_mv(f): return set()
    if f[0] in BIND: return loose(f[1], d + 1)
    out = set()
    for c in f[1:]: out |= loose(c, d)
    return out

# ---------------- is a (named or dB) sentence an instance of the schema? ----------------
def slot_contents(schema, s, enc):
    """positions of the P-slots (from the frame) and the contents of s there; None if frame mismatch"""
    m = SCHEMAS[schema][2]
    marks = [('?', 'P%d' % k) for k in range(m)]
    frame = build_named(schema, marks)
    if enc == 'db': frame = to_db(frame)
    sub = match(frame, s, {})
    if sub is None: return None
    return [sub[marks[k]] for k in range(m)]

def is_schema_instance(schema, s, already_db=False):
    """s named sentence. Abstract the body from occurrence 0 (names of its arguments -> holes),
    then check every occurrence.  Uses the de Bruijn form to avoid name clashes."""
    sdb = s if already_db else to_db(s)
    marks = [('?', 'P%d' % k) for k in range(SCHEMAS[schema][2])]
    frame_db = to_db(build_named(schema, marks))
    sub = match(frame_db, sdb, {})
    if sub is None: return False
    # de Bruijn argument indices per occurrence: plug a marker predicate
    n = SCHEMAS[schema][1]
    marker = ('Pm',) + tuple(hole(i) for i in range(n))
    mdb = to_db(build_named(schema, [marker] * SCHEMAS[schema][2]))
    args = []
    for k in range(len(marks)):
        # find the k-th marker in mdb at the slot position of frame_db
        pos = [p for p, t in positions(frame_db) if t == marks[k]][0]
        args.append(tuple(ixv(a) for a in at(mdb, pos)[1:]))
    def abstract(c, a, d=0):
        if is_ix(c):
            j = ixv(c)
            if j < d: return c
            if (j - d) in a: return hole(a.index(j - d))
            return None
        if len(c) == 1: return c
        if c[0] in BIND:
            r = abstract(c[1], a, d + 1)
            return None if r is None else (c[0], r)
        kids = [abstract(x, a, d) for x in c[1:]]
        return None if any(x is None for x in kids) else (c[0],) + tuple(kids)
    def plugdb(b, a, d=0):
        if is_hole(b): return ix(a[holev(b)] + d)
        if len(b) == 1: return b
        if b[0] in BIND: return (b[0], plugdb(b[1], a, d + 1))
        return (b[0],) + tuple(plugdb(x, a, d) for x in b[1:])
    beta = abstract(sub[marks[0]], args[0])
    if beta is None: return False
    return all(plugdb(beta, args[k]) == sub[marks[k]] for k in range(len(marks)))

def db_args(schema):
    marks = [('?', 'P%d' % k) for k in range(SCHEMAS[schema][2])]
    frame_db = to_db(build_named(schema, marks))
    n = SCHEMAS[schema][1]
    marker = ('Pm',) + tuple(hole(i) for i in range(n))
    mdb = to_db(build_named(schema, [marker] * SCHEMAS[schema][2]))
    out = []
    for k in range(len(marks)):
        pos = [p for p, t in positions(frame_db) if t == marks[k]][0]
        out.append(tuple(ixv(a) for a in at(mdb, pos)[1:]))
    return out

# ---------------- random bodies ----------------
def rand_body(rng, n, d=0, depth=3):
    """named lambda-body: holes h0..h_{n-1}, parameters $a,$b, internal binders @w<d>"""
    def term():
        ch = [hole(i) for i in range(n)] + [par('a'), par('b')] + [nv('w%d' % j) for j in range(d)]
        return rng.choice(ch)
    r = rng.random()
    if depth <= 0 or r < 0.4:
        return (rng.choice(['in', 'eq']), term(), term())
    if r < 0.55: return ('neg', rand_body(rng, n, d, depth - 1))
    if r < 0.75: return (rng.choice(['conj', 'impl', 'iff']), rand_body(rng, n, d, depth - 1), rand_body(rng, n, d, depth - 1))
    return (rng.choice(['fa', 'ex']), nv('w%d' % d), rand_body(rng, n, d + 1, depth - 1))

def uses(body, i):
    return any(t == hole(i) for _, t in positions(body))

def root(body): return body[0]
