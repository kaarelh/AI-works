"""Object-language syntax: terms and formulas with de Bruijn bound variables and named parameters.

Representation (immutable nested tuples):

  bound variable   ('v', k)          de Bruijn index k (0 = innermost enclosing binder)
  parameter        ('p', name)       free variable, read under universal closure (closure-normal form)
  hole             ('h', m)          m-th lambda-bound argument inside a metavariable body
  metavariable     ('M', name, args) args: tuple of terms; name[0] upper -> formula sort, lower -> term sort
  frozen metavar   ('C', name, args) rigid constant, used for generality (subsumption) tests

  arithmetic       ('0',) ('S',t) ('+',a,b) ('*',a,b)        atoms ('=',a,b) ('<',a,b)
  set theory       atoms ('in',a,b) ('=',a,b)
  connectives      ('not',f) ('and',f,g) ('or',f,g) ('imp',f,g) ('iff',f,g) ('all',f) ('ex',f)

Bounded quantifiers are abbreviations: forall y<t. f == all(y<t -> f), exists y in t. f == ex(y in t & f).
"""
import re

BINDERS = ('all', 'ex')
TERM_HEADS = frozenset(['0', 'S', '+', '*', 'v', 'p', 'h'])
ATOM_HEADS = frozenset(['=', '<', 'in'])
CONN_HEADS = frozenset(['not', 'and', 'or', 'imp', 'iff', 'all', 'ex'])
FORM_HEADS = ATOM_HEADS | CONN_HEADS
LEAVES = frozenset(['v', 'p', 'h', '0'])

ZERO = ('0',)


def S(t): return ('S', t)
def ADD(a, b): return ('+', a, b)
def MUL(a, b): return ('*', a, b)
def EQ(a, b): return ('=', a, b)
def LT(a, b): return ('<', a, b)
def IN(a, b): return ('in', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def OR(f, g): return ('or', f, g)
def IMP(f, g): return ('imp', f, g)
def IFF(f, g): return ('iff', f, g)
def ALL(f): return ('all', f)
def EX(f): return ('ex', f)
def V(k): return ('v', k)
def P(name): return ('p', name)
def H(m=0): return ('h', m)
def MV(name, *args): return ('M', name, tuple(args))


def num(n):
    t = ZERO
    for _ in range(n):
        t = ('S', t)
    return t


def kids(t):
    h = t[0]
    if h in LEAVES:
        return ()
    if h == 'M' or h == 'C':
        return t[2]
    return t[1:]


def rebuild(t, ks):
    h = t[0]
    if h in LEAVES:
        return t
    if h == 'M' or h == 'C':
        return (h, t[1], tuple(ks))
    return (h,) + tuple(ks)


def is_formula_head(h):
    return h in FORM_HEADS


def meta_sort(name):
    return 'F' if name[0].isupper() else 'T'


def sort_of(t):
    h = t[0]
    if h in ('M', 'C'):
        return meta_sort(t[1])
    return 'F' if h in FORM_HEADS else 'T'


def child_sort(h):
    """sort of the children of a node with head h"""
    if h in CONN_HEADS:
        return 'F'
    return 'T'


def size(t):
    """symbol count; a metavariable occurrence M(t1..tn) counts 1 + sum |ti|"""
    if t[0] in LEAVES:
        return 1
    return 1 + sum(size(k) for k in kids(t))


def depth_binders(t):
    if t[0] in LEAVES:
        return 0
    d = max((depth_binders(k) for k in kids(t)), default=0)
    return d + (1 if t[0] in BINDERS else 0)


def shift(t, j, cut=0):
    """add j to every free de Bruijn index (index >= cut) of t"""
    if j == 0:
        return t
    h = t[0]
    if h == 'v':
        return ('v', t[1] + j) if t[1] >= cut else t
    if h in LEAVES:
        return t
    if h in BINDERS:
        return (h, shift(t[1], j, cut + 1))
    return rebuild(t, [shift(k, j, cut) for k in kids(t)])


def unshift(t, j, cut=0):
    """subtract j from free indices >= cut + j; returns None if some free index in [cut, cut+j) occurs"""
    if j == 0:
        return t
    h = t[0]
    if h == 'v':
        k = t[1]
        if k < cut:
            return t
        if k < cut + j:
            return None
        return ('v', k - j)
    if h in LEAVES:
        return t
    if h in BINDERS:
        b = unshift(t[1], j, cut + 1)
        return None if b is None else (h, b)
    out = []
    for k in kids(t):
        u = unshift(k, j, cut)
        if u is None:
            return None
        out.append(u)
    return rebuild(t, out)


def free_indices(t, cut=0, acc=None):
    """set of free de Bruijn indices of t, relative to t's own position"""
    if acc is None:
        acc = set()
    h = t[0]
    if h == 'v':
        if t[1] >= cut:
            acc.add(t[1] - cut)
        return acc
    if h in LEAVES:
        return acc
    if h in BINDERS:
        free_indices(t[1], cut + 1, acc)
        return acc
    for k in kids(t):
        free_indices(k, cut, acc)
    return acc


def is_closed(t):
    return not free_indices(t)


def params_of(t, acc=None):
    if acc is None:
        acc = []
    h = t[0]
    if h == 'p':
        if t[1] not in acc:
            acc.append(t[1])
        return acc
    if h in LEAVES:
        return acc
    for k in kids(t):
        params_of(k, acc)
    return acc


def has_hole(t):
    if t[0] == 'h':
        return True
    if t[0] in LEAVES:
        return False
    return any(has_hole(k) for k in kids(t))


def has_meta(t):
    if t[0] == 'M':
        return True
    if t[0] in LEAVES:
        return False
    return any(has_meta(k) for k in kids(t))


def rename_params(t, ren):
    h = t[0]
    if h == 'p':
        return ('p', ren.get(t[1], t[1]))
    if h in LEAVES:
        return t
    return rebuild(t, [rename_params(k, ren) for k in kids(t)])


def canon_params(t):
    """rename parameters to w0, w1, ... in order of first occurrence (closure-normal form is invariant
    under renaming of parameters)"""
    ps = params_of(t)
    ren = {p: 'w%d' % i for i, p in enumerate(ps)}
    if all(k == v for k, v in ren.items()):
        return t
    # two-step rename to avoid collisions
    tmp = rename_params(t, {p: '__tmp%d' % i for i, p in enumerate(ps)})
    return rename_params(tmp, {'__tmp%d' % i: 'w%d' % i for i in range(len(ps))})


def close_params(t):
    """universal closure: parameters -> outer de Bruijn binders (w0 outermost).  Returns a closed formula."""
    ps = params_of(t)
    n = len(ps)
    if n == 0:
        return t
    pos = {p: i for i, p in enumerate(ps)}

    def go(u, d):
        h = u[0]
        if h == 'p':
            # w_i is bound by the i-th outer binder; at depth d inside the body its index is d + (n-1-i)
            return ('v', d + (n - 1 - pos[u[1]]))
        if h in LEAVES:
            return u
        if h in BINDERS:
            return (h, go(u[1], d + 1))
        return rebuild(u, [go(k, d) for k in kids(u)])
    body = go(t, 0)
    for _ in range(n):
        body = ('all', body)
    return body


def subterm(t, path):
    for i in path:
        t = kids(t)[i]
    return t


def positions(t, path=()):
    yield path, t
    if t[0] in LEAVES:
        return
    for i, k in enumerate(kids(t)):
        yield from positions(k, path + (i,))


def replace_at(t, path, new):
    if not path:
        return new
    ks = list(kids(t))
    ks[path[0]] = replace_at(ks[path[0]], path[1:], new)
    return rebuild(t, ks)


def plug(body, args, j=0):
    """beta-reduce (lambda h0..h_{n-1}. body)(args); args are terms relative to the occurrence context,
    j = number of body binders passed so far (args are shifted under them)"""
    h = body[0]
    if h == 'h':
        return shift(args[body[1]], j)
    if h in LEAVES:
        return body
    if h in BINDERS:
        return (h, plug(body[1], args, j + 1))
    return rebuild(body, [plug(k, args, j) for k in kids(body)])


def language_of(t):
    """'PA' if arithmetic symbols occur, 'ZF' if 'in' occurs, else None"""
    h = t[0]
    if h in ('0', 'S', '+', '*', '<'):
        return 'PA'
    if h == 'in':
        return 'ZF'
    if h in LEAVES:
        return None
    for k in kids(t):
        r = language_of(k)
        if r:
            return r
    return None


# ----------------------------------------------------------------------------------- printing
BNAMES = ['x', 'y', 'z', 'u', 'v', 's', 'r', 'q', 'n', 'm', 'k', 'j']


def bname(level):
    return BNAMES[level] if level < len(BNAMES) else 'x%d' % level


def pp(t, depth=0, holes=None, prec=0):
    """pretty-print; bound variables named by binder level (outermost binder = x, then y, z, ...)"""
    h = t[0]
    if h == 'v':
        lvl = depth - 1 - t[1]
        return bname(lvl) if lvl >= 0 else '#%d' % t[1]
    if h == 'p':
        return t[1]
    if h == 'h':
        if holes and t[1] < len(holes):
            return holes[t[1]]
        return '_%d' % t[1]
    if h == '0':
        return '0'
    if h == 'S':
        k, u = 0, t
        while u[0] == 'S':
            k, u = k + 1, u[1]
        if u[0] == '0':
            return str(k) if k <= 3 else 'S' * k + '0'
        inner = pp(u, depth, holes, 3)
        return 'S' * k + inner
    if h in ('+', '*'):
        p = 1 if h == '+' else 2
        s = pp(t[1], depth, holes, p) + h + pp(t[2], depth, holes, p + 1)
        return '(' + s + ')' if prec > p else s
    if h in ATOM_HEADS:
        op = {'=': '=', '<': '<', 'in': ' in '}[h]
        return pp(t[1], depth, holes) + op + pp(t[2], depth, holes)
    if h == 'not':
        return '~' + pp(t[1], depth, holes, 9)
    if h in ('and', 'or', 'imp', 'iff'):
        op = {'and': ' & ', 'or': ' | ', 'imp': ' -> ', 'iff': ' <-> '}[h]
        s = pp(t[1], depth, holes, 5) + op + pp(t[2], depth, holes, 5)
        return '(' + s + ')' if prec >= 5 else s
    if h in BINDERS:
        q = 'A' if h == 'all' else 'E'
        s = q + bname(depth) + '.' + pp(t[1], depth + 1, holes, 4)
        return '(' + s + ')' if prec >= 5 else s
    if h in ('M', 'C'):
        pre = '?' if h == 'M' else '!'
        if not t[2]:
            return pre + t[1]
        return pre + t[1] + '(' + ','.join(pp(a, depth, holes) for a in t[2]) + ')'
    return str(t)


# ----------------------------------------------------------------------------------- parsing
_TOK = re.compile(r'\s*(<->|->|<|=|~|&|\||\(|\)|,|\.|\+|\*|\?[A-Za-z_][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_\']*|\d+)')


def tokenize(s):
    toks, i = [], 0
    s = s.strip()
    while i < len(s):
        m = _TOK.match(s, i)
        if not m:
            raise SyntaxError('bad input at %r' % s[i:])
        toks.append(m.group(1))
        i = m.end()
        while i < len(s) and s[i].isspace():
            i += 1
    return toks


class _Parser:
    QUANT = {'forall': 'all', 'all': 'all', 'A': 'all', 'exists': 'ex', 'ex': 'ex', 'E': 'ex'}

    def __init__(self, toks):
        self.t, self.i = toks, 0

    def peek(self, k=0):
        j = self.i + k
        return self.t[j] if j < len(self.t) else None

    def eat(self, tok=None):
        x = self.peek()
        if tok is not None and x != tok:
            raise SyntaxError('expected %r got %r at %d' % (tok, x, self.i))
        self.i += 1
        return x

    # formulas
    def formula(self, env):
        return self.iff(env)

    def iff(self, env):
        f = self.imp(env)
        if self.peek() == '<->':
            self.eat()
            g = self.imp(env)
            return ('iff', f, g)
        return f

    def imp(self, env):
        f = self.disj(env)
        if self.peek() == '->':
            self.eat()
            g = self.imp(env)
            return ('imp', f, g)
        return f

    def disj(self, env):
        f = self.conj(env)
        while self.peek() == '|':
            self.eat()
            f = ('or', f, self.conj(env))
        return f

    def conj(self, env):
        f = self.unary(env)
        while self.peek() == '&':
            self.eat()
            f = ('and', f, self.unary(env))
        return f

    def unary(self, env):
        x = self.peek()
        if x == '~':
            self.eat()
            return ('not', self.unary(env))
        qv = None
        if x in self.QUANT and self.peek(1) is not None and re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', self.peek(1)) \
                and self.peek(2) in ('.', '<', 'in'):
            q = self.QUANT[self.eat()]
            qv = self.eat()
        elif x is not None and re.match(r'^[AE][a-z][A-Za-z0-9_]*$', x) and self.peek(1) in ('.', '<', 'in'):
            self.eat()
            q = 'all' if x[0] == 'A' else 'ex'
            qv = x[1:]
        if qv is not None:
            var = qv
            bound = None
            if self.peek() in ('<', 'in'):
                rel = self.eat()
                bt = self.term(env)
                bound = (rel, bt)
            self.eat('.')
            env2 = [var] + env
            body = self.formula(env2)
            if bound is not None:
                rel, bt = bound
                guard = (rel, ('v', 0), shift(bt, 1))
                body = ('imp', guard, body) if q == 'all' else ('and', guard, body)
            return (q, body)
        if x is not None and x.startswith('?') and x[1].isupper():
            return self.meta(env)
        if x == '(':
            save = self.i
            try:
                return self.atom(env)
            except SyntaxError:
                self.i = save
            self.eat('(')
            f = self.formula(env)
            self.eat(')')
            return f
        return self.atom(env)

    def atom(self, env):
        a = self.term(env)
        r = self.peek()
        if r not in ('=', '<', 'in'):
            raise SyntaxError('expected relation, got %r' % r)
        self.eat()
        b = self.term(env)
        return (r, a, b)

    def meta(self, env):
        name = self.eat()[1:]
        args = []
        if self.peek() == '(':
            self.eat('(')
            if self.peek() != ')':
                args.append(self.term(env))
                while self.peek() == ',':
                    self.eat()
                    args.append(self.term(env))
            self.eat(')')
        return ('M', name, tuple(args))

    # terms
    def term(self, env):
        a = self.mul(env)
        while self.peek() == '+':
            self.eat()
            a = ('+', a, self.mul(env))
        return a

    def mul(self, env):
        a = self.succ(env)
        while self.peek() == '*':
            self.eat()
            a = ('*', a, self.succ(env))
        return a

    def succ(self, env):
        x = self.peek()
        if x == 'S' and self.peek(1) not in (None, ')', ',', '=', '<', '+', '*', '.', '&', '|', '->', '<->', 'in'):
            self.eat()
            return ('S', self.succ(env))
        if x is not None and x not in env and re.match(r'^S+([0-9]+|[a-z][A-Za-z0-9_]*)$', x):
            rest = x.lstrip('S')
            k = len(x) - len(rest)
            self.eat()
            if rest.isdigit():
                t = num(int(rest))
            elif rest in env:
                t = ('v', env.index(rest))
            else:
                t = ('p', rest)
            for _ in range(k):
                t = ('S', t)
            return t
        return self.prim(env)

    def prim(self, env):
        x = self.eat()
        if x == '(':
            a = self.term(env)
            self.eat(')')
            return a
        if x.isdigit():
            return num(int(x))
        if x.startswith('?'):
            self.i -= 1
            return self.meta(env)
        if x in env:
            return ('v', env.index(x))
        if re.match(r'[A-Za-z_]', x):
            return ('p', x)
        raise SyntaxError('bad term token %r' % x)


def parse(s, canon=True):
    """parse a formula; free identifiers become parameters (renamed canonically unless canon=False)"""
    p = _Parser(tokenize(s))
    f = p.formula([])
    if p.i != len(p.t):
        raise SyntaxError('trailing input: %r' % p.t[p.i:])
    return canon_params(f) if canon else f


def parse_term(s):
    p = _Parser(tokenize(s))
    t = p.term([])
    if p.i != len(p.t):
        raise SyntaxError('trailing input: %r' % p.t[p.i:])
    return t
