"""Sound three-valued evaluator for set-theoretic sentences ({in, =}) in V (assumed to satisfy ZF).

Values bound to variables are either hereditarily finite sets (Python frozensets) or *generic* objects.
A generic G created by a quantifier stands for an arbitrary set outside a finite transitive set E_G (the
transitive closure of the concrete values in scope) and different from the generics already in scope.
Atoms involving generics are decided only when forced:
    G in G      False  (Foundation)            G = G        True
    G in c      False  if c in E_G or every element of c is in E_G   (else unknown)
    G = c       False  if c in E_G                                  (else unknown)
    c in G      unknown                        G in H, H in G  unknown;  G = H  False (H fresh w.r.t. G)
For an unbounded quantifier Ax.f the universe is split into finitely many cases: x in E (each element of
the transitive closure of the concrete values in scope), x = G for each generic in scope, or x a new
generic H (all remaining sets).  If every case is True the verdict is True; if some case is False it is
False (a generic case False means f fails for every set of that kind, and such sets exist).  In addition
a search over small HF sets outside E may find a concrete counterexample (for A) or witness (for E).
Bounded forms Ax(x in t -> f), Ex(x in t & f) with t an HF set are evaluated exactly.
Connectives: Kleene strong three-valued logic.  Every True/False verdict is therefore a theorem of ZF
about the sentence; for Delta_0 matrices with HF arguments this is Delta_0 absoluteness.
"""
from .syntax import BINDERS, LEAVES, close_params
from .oracle_base import ThreeValued, Budget, no_v0

EMPTY = frozenset()


def hf_upto(rank):
    """all HF sets of rank < rank (V_rank)"""
    level = [EMPTY]
    cur = {EMPTY}
    for _ in range(rank - 1):
        elems = sorted(cur, key=hf_key)
        new = set()
        n = len(elems)
        for mask in range(1 << n):
            new.add(frozenset(elems[i] for i in range(n) if mask >> i & 1))
        cur = new
    return sorted(cur, key=hf_key)


def hf_rank(s):
    return 0 if not s else 1 + max(hf_rank(x) for x in s)


def hf_size(s):
    return 1 + sum(hf_size(x) for x in s)


_KEY_CACHE = {}


def hf_key(s):
    k = _KEY_CACHE.get(s)
    if k is None:
        k = (hf_rank(s), hf_size(s), sorted(hf_key(x) for x in s))
        if len(_KEY_CACHE) < 100000:
            _KEY_CACHE[s] = k
    return k


_SORTED_CACHE = {}


def sorted_elems(s):
    r = _SORTED_CACHE.get(s)
    if r is None:
        r = sorted(s, key=hf_key)
        if len(_SORTED_CACHE) < 100000:
            _SORTED_CACHE[s] = r
    return r


def hf_str(s):
    if not s:
        return '0'
    return '{' + ','.join(hf_str(x) for x in sorted(s, key=hf_key)) + '}'


_TC_CACHE = {}


def tc_with(values):
    """transitive closure of a set of HF values, including the values themselves"""
    key = frozenset(values)
    r = _TC_CACHE.get(key)
    if r is not None:
        return r
    out, stack = set(), list(values)
    while stack:
        x = stack.pop()
        if x in out:
            continue
        out.add(x)
        stack.extend(x)
    r = frozenset(out)
    if len(_TC_CACHE) < 200000:
        _TC_CACHE[key] = r
    return r


class Gen:
    __slots__ = ('id', 'E', 'prior')

    def __init__(self, gid, E, prior):
        self.id, self.E, self.prior = gid, E, prior

    def __repr__(self):
        return 'G%d' % self.id


def _vkey(x):
    return ('G', x.id) if isinstance(x, Gen) else x


class ZFEval(ThreeValued):
    def __init__(self, search_rank=3, nested_search_rank=2, max_steps=60000):
        super().__init__(max_steps)
        self.pool = {r: hf_upto(r) for r in (1, 2, 3, 4)}
        self.search_rank, self.nested_search_rank = search_rank, nested_search_rank
        self.ngen = 0

    @staticmethod
    def _in(a, b):
        ga, gb = isinstance(a, Gen), isinstance(b, Gen)
        if not ga and not gb:
            return a in b
        if ga and gb:
            if a is b:
                return False
            return None
        if ga:      # generic a in concrete b
            if b in a.E or all(x in a.E for x in b):
                return False
            return None
        return None  # concrete a in generic b

    @staticmethod
    def _eq(a, b):
        ga, gb = isinstance(a, Gen), isinstance(b, Gen)
        if not ga and not gb:
            return a == b
        if ga and gb:
            return a is b
        g, c = (a, b) if ga else (b, a)
        if c in g.E:
            return False
        return None

    def vkey(self, x):
        return _vkey(x)

    @staticmethod
    def val(t, env):
        if t[0] == 'v':
            return env[t[1]]
        raise ValueError('set-theory terms are variables only: %r' % (t,))

    def atom(self, f, env):
        h = f[0]
        a, b = self.val(f[1], env), self.val(f[2], env)
        if h == 'in':
            return self._in(a, b), ('in', _vkey(a), _vkey(b))
        if h == '=':
            return self._eq(a, b), ('=', frozenset([_vkey(a), _vkey(b)]))
        raise ValueError('bad atom %r' % (h,))

    def quant(self, isall, body, env, level):
        conn = 'imp' if isall else 'and'
        if body[0] == conn and body[1][0] == 'in' and body[1][1] == ('v', 0) and no_v0(body[1][2]):
            tv = self.val(body[1][2], [None] + env)
            if not isinstance(tv, Gen):
                return self.combine(isall, (self.ev(body[2], [x] + env, level + 1)
                                            for x in sorted_elems(tv)))
        concretes = [x for x in env if not isinstance(x, Gen)]
        gens = [x for x in env if isinstance(x, Gen)]
        E = tc_with(concretes) if concretes else EMPTY
        unknown = False
        # exhaustive case analysis: a new generic (every set outside E and the generics in scope),
        # each generic in scope, each element of E
        self.ngen += 1
        newg = Gen(self.ngen, E, tuple(g.id for g in gens))
        for x in [newg] + gens + sorted_elems(E):
            r = self.ev(body, [x] + env, level + 1)
            if isall and r is False:
                return False
            if (not isall) and r is True:
                return True
            if r is None:
                unknown = True
        if not unknown:
            return True if isall else False
        # extra search over small HF sets outside E (counterexample for A, witness for E)
        R = self.search_rank if level == 0 else self.nested_search_rank
        for x in self.pool[min(R + 1, 4)]:
            if x in E:
                continue
            r = self.ev(body, [x] + env, level + 1)
            if isall and r is False:
                return False
            if (not isall) and r is True:
                return True
        return None


def refutes(sentence, ev=None):
    ev = ev or ZFEval()
    return ev.truth(sentence) is False
