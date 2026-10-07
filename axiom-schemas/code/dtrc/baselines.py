"""Baselines.

* first-order lgg (Plotkin/Reynolds anti-unification) per tag or cluster, in two encodings:
    - 'named': bound variables named by binder level (x0 outermost); binders carry their variable name;
      first-order metavariables may be instantiated with formulas mentioning any name (capture);
    - 'debruijn': de Bruijn indices; first-order metavariables may be instantiated with any index.
* higher-order pattern anti-unification (all occurrences are Miller patterns; equal problems share a
  variable) -- the pattern-fragment lgg (Pfenning 1991; Baumgartner-Kutsia-Levy-Villaret 2017);
* cautious k-union learner over DT° templates without/with refutation negatives (small data only);
* skeleton clustering without refutation (DTRC.use_refutation=False with k_stop).
"""
import itertools
import random
from .syntax import BINDERS, LEAVES, kids, rebuild, canon_params, pp, ZERO, S, H, P
from .templates import match, canon
from .mincover import MinCover, build_tree


# ------------------------------------------------------------------------------------ encodings
def to_named(t, depth=0):
    h = t[0]
    if h == 'v':
        return ('n', 'x%d' % (depth - 1 - t[1]))
    if h in BINDERS:
        return (h, ('n', 'x%d' % depth), to_named(t[1], depth + 1))
    if h in LEAVES:
        return t
    return rebuild(t, [to_named(k, depth) for k in kids(t)])


def from_named(t, env=()):
    """named (level) -> de Bruijn; unbound names become parameters"""
    h = t[0]
    if h == 'n':
        name = t[1]
        for i in range(len(env) - 1, -1, -1):
            if env[i] == name:
                return ('v', len(env) - 1 - i)
        return ('p', name)
    if h in BINDERS:
        return (h, from_named(t[2], env + (t[1][1],)))
    if h in LEAVES:
        return t
    return rebuild(t, [from_named(k, env) for k in kids(t)])


def _fkids(t):
    h = t[0]
    if h in LEAVES or h in ('n', 'X'):
        return ()
    return t[1:]


def _fkey(t):
    h = t[0]
    if h in LEAVES or h == 'n':
        return t
    return (h, len(t) - 1)


def fo_lgg(ts):
    """Plotkin lgg of a list of trees; variables ('X', i, sort, depth)"""
    table = {}

    def A(col, sort, depth):
        c0 = col[0]
        k0 = _fkey(c0)
        if all(_fkey(c) == k0 for c in col):
            if not _fkids(c0):
                return c0
            ks = [_fkids(c) for c in col]
            h = c0[0]
            out = []
            for i in range(len(ks[0])):
                if h in BINDERS:
                    cs, nd = ('N', depth) if (i == 0 and len(ks[0]) == 2) else ('F', depth + 1)
                elif h in ('not', 'and', 'or', 'imp', 'iff'):
                    cs, nd = 'F', depth
                else:
                    cs, nd = 'T', depth
                out.append(A(tuple(k[i] for k in ks), cs, nd))
            return (h,) + tuple(out)
        if col not in table:
            table[col] = [len(table), sort, depth]
        else:
            table[col][2] = min(table[col][2], depth)
        return ('XREF', col)
    T = A(tuple(ts), 'F', 0)

    def fix(t):
        if t[0] == 'XREF':
            i, srt, d = table[t[1]]
            return ('X', i, srt, d)
        if not _fkids(t):
            return t
        return (t[0],) + tuple(fix(k) for k in _fkids(t))
    return fix(T)


def fo_match(p, t, sub=None):
    if sub is None:
        sub = {}
    if p[0] == 'X':
        v = p[1]
        if v in sub:
            return sub if sub[v] == t else None
        sub[v] = t
        return sub
    if _fkey(p) != _fkey(t):
        return None
    for a, b in zip(_fkids(p), _fkids(t)):
        if fo_match(a, b, sub) is None:
            return None
    return sub


def fo_vars(p, acc=None):
    if acc is None:
        acc = {}
    if p[0] == 'X':
        acc[p[1]] = (p[2], p[3])
        return acc
    for k in _fkids(p):
        fo_vars(k, acc)
    return acc


def fo_subst(p, sub):
    if p[0] == 'X':
        return sub[p[1]]
    if not _fkids(p):
        return p
    return (p[0],) + tuple(fo_subst(k, sub) for k in _fkids(p))


class FOLgg:
    def __init__(self, data, enc):
        self.enc = enc
        self.data = data
        enc_data = [self.encode(d) for d in data]
        self.T = fo_lgg(enc_data)

    def encode(self, s):
        return to_named(s) if self.enc == 'named' else s

    def decode(self, e):
        return canon_params(from_named(e)) if self.enc == 'named' else canon_params(e)

    def accepts(self, q):
        return fo_match(self.T, self.encode(q)) is not None

    def sample(self, rng, n, lang):
        """random instances (capture allowed: fillers may mention any bound variable in scope)"""
        vs = fo_vars(self.T)
        out = []
        for _ in range(n):
            sub = {}
            for v, (sort, depth) in vs.items():
                sub[v] = _fo_filler(rng, sort, depth, lang, self.enc)
            inst = fo_subst(self.T, sub)
            try:
                out.append(self.decode(inst))
            except Exception:
                pass
        return out

    def show(self):
        def sh(t):
            if t[0] == 'X':
                return '?X%d' % t[1]
            return t
        return str(self.T)[:200]


def _var(enc, depth, k):
    """the variable bound k binders above (k < depth), in the given encoding"""
    if enc == 'named':
        return ('n', 'x%d' % (depth - 1 - k))
    return ('v', k)


def _fo_filler(rng, sort, depth, lang, enc):
    vars_ = [_var(enc, depth, k) for k in range(depth)]
    if lang == 'PA':
        terms = [ZERO, S(ZERO)] + vars_ + [S(v) for v in vars_] + [P('w0')]
        if sort == 'T' or sort == 'N':
            return rng.choice(terms)
        a, b = rng.choice(terms), rng.choice(terms)
        k = rng.random()
        if k < 0.4:
            return ('=', a, b)
        if k < 0.6:
            return ('<', a, b)
        if k < 0.8:
            return ('not', ('=', a, b))
        return rng.choice([('=', ZERO, ZERO), ('=', S(ZERO), ZERO)])
    terms = vars_ + [P('w0')]
    if sort == 'T' or sort == 'N':
        return rng.choice(terms)
    a, b = rng.choice(terms), rng.choice(terms)
    k = rng.random()
    if k < 0.4:
        return ('in', a, b)
    if k < 0.6:
        return ('=', a, b)
    if k < 0.85:
        return ('not', ('in', a, b))
    top = ('all', ('n', 'x%d' % depth), ('=', ('n', 'x%d' % depth), ('n', 'x%d' % depth))) if enc == 'named' \
        else ('all', ('=', ('v', 0), ('v', 0)))
    return rng.choice([top, ('not', top)])


# ------------------------------------------------------------------------------------ pattern lgg
def pattern_lgg(D, term_level=True):
    """higher-order pattern generalization (anti-unification in the pattern fragment): rigid common prefix;
    at each maximal disagreement position (slot) a fresh variable applied to the bound variables occurring
    free in the column; slots whose problems coincide up to a permutation of those bound variables share the
    variable (BKLV's merge rule, my reading).
    v2 (referee F6): term_level=True is the genuine pattern lgg -- a term disagreement containing a bound
    variable is generalised at term level by a term variable f(x,..) of positive arity (full DT° tree);
    term_level=False is the v1 baseline, built on the DT°_F tree, which generalises the whole atom to a
    formula variable ?P(x,..) ('pattern lgg with formula-level atom generalisation')."""
    D = list(dict.fromkeys(D))
    mc = MinCover(D, term_arity0=not term_level)
    parent = {s.idx: s.idx for s in mc.slots}
    rep_args = {}
    order = [s.idx for s in mc.slots]
    assign = {}
    for s in mc.slots:
        # share with an earlier slot rho if s is derivable from rho with pattern-shaped arguments and
        # rho derivable from s likewise (identical problems up to bound-variable renaming)
        done = False
        for (rho, t) in mc.src[s.idx]:
            if rho not in assign or assign[rho][0] != 'own':
                continue
            if all(a[0] == 'v' for a in t) and len(set(t)) == len(t) and \
                    any(r2 == s.idx for (r2, _) in mc.src[rho]):
                assign[s.idx] = ('shared', rho, t)
                done = True
                break
        if not done:
            assign[s.idx] = ('own', s.idx, mc.own_args[s.idx])

    def build(nd):
        if nd.slot:
            kind, rho, args = assign[nd.idx]
            srt = 'P' if nd.sort == 'F' else 'f'
            return ('M', srt + 'own%d' % rho, tuple(args))
        if not nd.children:
            return nd.proto
        return rebuild(nd.proto, [build(c) for c in nd.children])
    return canon(build(mc.root))


def pattern_lgg_formula(D):
    """v1 baseline: pattern lgg with formula-level atom generalisation"""
    return pattern_lgg(D, term_level=False)


# ------------------------------------------------------------------------------------ k-union learner
def set_partitions(items, k):
    def rec(i, blocks):
        if i == len(items):
            yield [list(b) for b in blocks]
            return
        for b in blocks:
            b.append(items[i])
            yield from rec(i + 1, blocks)
            b.pop()
        if len(blocks) < k:
            blocks.append([items[i]])
            yield from rec(i + 1, blocks)
            blocks.pop()
    yield from rec(0, [])


class KUnion:
    """cautious verifier over unions of <= k DT° templates: accept q iff every union covering D (whose
    members are not refuted, if a refuter is given) contains q"""

    def __init__(self, D, k, refuter=None):
        self.D = list(dict.fromkeys(canon_params(d) for d in D))
        self.k = k
        self.R = refuter
        self._mins = {}

    def mins(self, block):
        key = frozenset(block)
        r = self._mins.get(key)
        if r is None:
            ms = MinCover(list(block)).minimal()
            if self.R is not None:
                ms = [T for T in ms if not self.R.refuted(T, list(block))]
            r = ms
            self._mins[key] = r
        return r

    def accepts(self, q, return_witness=False):
        q = canon_params(q)
        for part in set_partitions(self.D, self.k):
            feasible = True
            all_miss = True
            for b in part:
                ms = self.mins(b)
                if not ms:
                    feasible = False
                    break
                if all(match(T, q) is not None for T in ms):
                    all_miss = False
                    break
            if feasible and all_miss:
                if return_witness:
                    wit = [[T for T in self.mins(b) if match(T, q) is None][0] for b in part]
                    return False, wit
                return False
        return (True, None) if return_witness else True
