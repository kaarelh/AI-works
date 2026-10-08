"""Probabilistic grammars.

Grammar (the instantiation grammar Q).  A probabilistic context-free grammar over metavariable bodies:
closed terms, terms with holes, and formulas with holes and their own binders.  The context of a node is
(nh, nb, ap): nh holes h0..h_{nh-1} (the metavariable's arguments), nb bound variables of the body's own
binders in scope, and ap = whether the single parameter w0 is allowed (the metavariable's guard is 'open').

  term node:    0, S, +, *  with weights term_w;  a variable (hole or bound) with total weight var_w, split
                uniformly over the nh + nb variables in scope (absent if there are none);  the parameter w0
                with weight param_w (only if ap).  Weights are normalised over the options available.
  formula node: =, <, not, and, or, imp, iff, all, ex  with weights form_w (normalised).  A quantifier
                adds one bound variable to the context of its body.

Single-parameter convention: the only parameter is w0.  A body containing another parameter name has
probability 0.  (Data are in closure-normal form, so a sentence with one parameter has it named w0.)

The grammar is a proper distribution (the expected number of same-sort children is < 1 for the default
weights, so trees are finite with probability 1 and the probabilities of all finite trees sum to 1).

TemplateCode (the prior's code).  A prefix-free code for DT° templates, given as -log2 of a stochastic
grammar over templates (the same node alphabet plus metavariable occurrences).  See bits() for the exact
code.  theory_bits() codes a theory (a finite set of components).
"""
import math
import random

from dtrc.syntax import kids, LEAVES
from dtrc.templates import canon

LN2 = math.log(2.0)
NEG_INF = float('-inf')

DEFAULT_TERM_W = {'0': 0.45, 'S': 0.35, '+': 0.10, '*': 0.10}
DEFAULT_FORM_W = {'=': 0.35, '<': 0.20, 'not': 0.10, 'and': 0.10, 'or': 0.05, 'imp': 0.10, 'iff': 0.02,
                  'all': 0.05, 'ex': 0.03}
TERM_ARITY = {'0': 0, 'S': 1, '+': 2, '*': 2}
FORM_ARITY = {'=': 2, '<': 2, 'not': 1, 'and': 2, 'or': 2, 'imp': 2, 'iff': 2, 'all': 1, 'ex': 1}
PARAM = ('p', 'w0')


class Grammar:
    """the instantiation grammar Q (see module docstring)"""

    def __init__(self, term_w=None, form_w=None, var_w=0.3, param_w=0.15):
        self.term_w = dict(DEFAULT_TERM_W if term_w is None else term_w)
        self.form_w = dict(DEFAULT_FORM_W if form_w is None else form_w)
        self.var_w = var_w
        self.param_w = param_w
        zf = sum(self.form_w.values())
        self._lf = {h: math.log(w / zf) for h, w in self.form_w.items() if w > 0}
        self._ctx = {}
        self._hp = {}

    def describe(self):
        return {'term_w': self.term_w, 'form_w': self.form_w, 'var_w': self.var_w, 'param_w': self.param_w}

    # ------------------------------------------------------------------ term-node log-probabilities
    def _tctx(self, hasvar, ap):
        key = (hasvar, ap)
        c = self._ctx.get(key)
        if c is None:
            z = sum(self.term_w.values()) + (self.var_w if hasvar else 0.0) + (self.param_w if ap else 0.0)
            c = {h: math.log(w / z) for h, w in self.term_w.items() if w > 0}
            if hasvar and self.var_w > 0:
                c['var'] = math.log(self.var_w / z)
            if ap and self.param_w > 0:
                c['p'] = math.log(self.param_w / z)
            self._ctx[key] = c
        return c

    def logq_term(self, t, nh=0, nb=0, ap=False):
        """natural log of Q(t) for a term node in context (nh, nb, ap); -inf if t is not generated"""
        nv = nh + nb
        c = self._tctx(nv > 0, ap)
        h = t[0]
        if h == 'v':
            if t[1] >= nb or 'var' not in c:
                return NEG_INF
            return c['var'] - math.log(nv)
        if h == 'h':
            if t[1] >= nh or 'var' not in c:
                return NEG_INF
            return c['var'] - math.log(nv)
        if h == 'p':
            if t[1] != 'w0' or 'p' not in c:
                return NEG_INF
            return c['p']
        lp = c.get(h)
        if lp is None:
            return NEG_INF
        for k in t[1:]:
            lk = self.logq_term(k, nh, nb, ap)
            if lk == NEG_INF:
                return NEG_INF
            lp += lk
        return lp

    def logq_form(self, f, nh=0, nb=0, ap=False):
        """natural log of Q(f) for a formula node in context (nh, nb, ap)"""
        h = f[0]
        lp = self._lf.get(h)
        if lp is None:
            return NEG_INF
        if h in ('=', '<'):
            for k in f[1:]:
                lk = self.logq_term(k, nh, nb, ap)
                if lk == NEG_INF:
                    return NEG_INF
                lp += lk
            return lp
        if h in ('all', 'ex'):
            lk = self.logq_form(f[1], nh, nb + 1, ap)
            return NEG_INF if lk == NEG_INF else lp + lk
        for k in f[1:]:
            lk = self.logq_form(k, nh, nb, ap)
            if lk == NEG_INF:
                return NEG_INF
            lp += lk
        return lp

    def logq_body(self, body, sort, arity, ap):
        """log-probability of a metavariable body (sort 'T' or 'F', `arity` holes)"""
        if sort == 'T':
            return self.logq_term(body, arity, 0, ap)
        return self.logq_form(body, arity, 0, ap)

    # ------------------------------------------------------------------ sampling
    def _choose(self, rng, items):
        r = rng.random()
        acc = 0.0
        for k, p in items:
            acc += p
            if r < acc:
                return k
        return items[-1][0]

    def sample_term(self, rng, nh=0, nb=0, ap=False):
        nv = nh + nb
        c = self._tctx(nv > 0, ap)
        items = [(k, math.exp(v)) for k, v in sorted(c.items())]
        h = self._choose(rng, items)
        if h == 'var':
            i = rng.randrange(nv)
            return ('v', i) if i < nb else ('h', i - nb)
        if h == 'p':
            return PARAM
        return (h,) + tuple(self.sample_term(rng, nh, nb, ap) for _ in range(TERM_ARITY[h]))

    def sample_form(self, rng, nh=0, nb=0, ap=False):
        items = [(k, math.exp(v)) for k, v in sorted(self._lf.items())]
        h = self._choose(rng, items)
        if h in ('=', '<'):
            return (h, self.sample_term(rng, nh, nb, ap), self.sample_term(rng, nh, nb, ap))
        if h in ('all', 'ex'):
            return (h, self.sample_form(rng, nh, nb + 1, ap))
        return (h,) + tuple(self.sample_form(rng, nh, nb, ap) for _ in range(FORM_ARITY[h]))

    def sample_body(self, rng, sort, arity, ap):
        if sort == 'T':
            return self.sample_term(rng, arity, 0, ap)
        return self.sample_form(rng, arity, 0, ap)

    # ------------------------------------------------------------------ derived quantities
    def p_term_has_param(self, nh=0):
        """probability that a term in context (nh, 0, ap=True) contains w0 (fixed point of the PCFG)"""
        key = nh
        if key in self._hp:
            return self._hp[key]
        c = self._tctx(nh > 0, True)
        pp_ = math.exp(c['p']) if 'p' in c else 0.0
        pS = math.exp(c.get('S', NEG_INF)) if 'S' in c else 0.0
        p2 = sum(math.exp(c[h]) for h in ('+', '*') if h in c)
        h = 0.0
        for _ in range(10000):
            h2 = pp_ + pS * h + p2 * (1 - (1 - h) ** 2)
            if abs(h2 - h) < 1e-15:
                h = h2
                break
            h = h2
        self._hp[key] = h
        return h


# ------------------------------------------------------------------------------------------ prior code
PRIOR_FORM_W = {'=': 0.20, '<': 0.10, 'not': 0.10, 'and': 0.10, 'or': 0.05, 'imp': 0.10, 'iff': 0.05,
                'all': 0.10, 'ex': 0.05, 'M': 0.15}
PRIOR_TERM_W = {'0': 0.30, 'S': 0.20, '+': 0.10, '*': 0.10, 'var': 0.15, 'param': 0.05, 'M': 0.10}


def elias_gamma_bits(m):
    """length of the Elias gamma code of a positive integer m"""
    return 2 * int(math.floor(math.log2(m))) + 1


class TemplateCode:
    """Prefix-free code for DT° templates (with one guard bit per metavariable).

    A template is written in preorder (after canonical renaming of metavariables, dtrc.templates.canon).
      formula node: one of =, <, not, and, or, imp, iff, all, ex, M  (probabilities PRIOR_FORM_W);
      term node:    one of 0, S, +, *, var, param, M  (PRIOR_TERM_W; 'var' only if a bound variable is in
                    scope; probabilities renormalised over the available options);
      var:          which bound variable, uniformly among the nb in scope (log2 nb bits);
      M:            which metavariable of this sort: one of the k already introduced or a new one,
                    uniformly (log2(k+1) bits); a new one then codes its arity r with r+1 bits
                    (P(r) = 2^-(r+1)) and its guard (closed/open) with 1 bit;
      M's args:     r metavariable-free terms (DT°), coded as term nodes without the M option.
    The code length of a template is the sum of -log2 of these choices.  The stochastic grammar behind it
    is subcritical, so the code is prefix-free (Kraft sum <= 1)."""

    def __init__(self, form_w=None, term_w=None):
        self.form_w = dict(PRIOR_FORM_W if form_w is None else form_w)
        self.term_w = dict(PRIOR_TERM_W if term_w is None else term_w)
        zf = sum(self.form_w.values())
        self._lf = {h: -math.log2(w / zf) for h, w in self.form_w.items()}
        self._lt = {}

    def _tcost(self, hasvar, allow_meta):
        key = (hasvar, allow_meta)
        c = self._lt.get(key)
        if c is None:
            opts = {h: w for h, w in self.term_w.items()
                    if (h != 'var' or hasvar) and (h != 'M' or allow_meta)}
            z = sum(opts.values())
            c = {h: -math.log2(w / z) for h, w in opts.items()}
            self._lt[key] = c
        return c

    def bits(self, T):
        T = canon(T)
        seen = {'F': [], 'T': []}
        total = [0.0]

        def meta(node, sort, nb):
            name, args = node[1], node[2]
            lst = seen[sort]
            total[0] += math.log2(len(lst) + 1)
            if name not in lst:
                lst.append(name)
                total[0] += len(args) + 1          # arity
                total[0] += 1.0                    # guard bit
            for a in args:
                term(a, nb, False)

        def term(t, nb, allow_meta=True):
            c = self._tcost(nb > 0, allow_meta)
            h = t[0]
            if h == 'M':
                total[0] += c['M']
                meta(t, 'T', nb)
            elif h == 'v':
                total[0] += c['var'] + math.log2(nb)
            elif h == 'p':
                total[0] += c['param']
            elif h in TERM_ARITY:
                total[0] += c[h]
                for k in t[1:]:
                    term(k, nb, allow_meta)
            else:
                raise ValueError('cannot code term node %r' % (t,))

        def form(f, nb):
            h = f[0]
            if h == 'M':
                total[0] += self._lf['M']
                meta(f, 'F', nb)
            elif h in ('=', '<'):
                total[0] += self._lf[h]
                term(f[1], nb)
                term(f[2], nb)
            elif h in ('all', 'ex'):
                total[0] += self._lf[h]
                form(f[1], nb + 1)
            elif h in FORM_ARITY:
                total[0] += self._lf[h]
                for k in f[1:]:
                    form(k, nb)
            else:
                raise ValueError('cannot code formula node %r' % (f,))
        form(T, 0)
        return total[0]


def theory_bits(templates, code=None, as_set=True):
    """code length of a theory given as a list of templates: Elias gamma code of the number m of
    components, then each template; for a set of distinct components the order carries log2(m!) bits that
    a set code saves"""
    code = code or TemplateCode()
    m = len(templates)
    b = elias_gamma_bits(m) + sum(code.bits(T) for T in templates)
    if as_set:
        b -= math.lgamma(m + 1) / LN2
    return b


def logaddexp(a, b):
    if a == NEG_INF:
        return b
    if b == NEG_INF:
        return a
    if a < b:
        a, b = b, a
    return a + math.log1p(math.exp(b - a))


def logsumexp(xs):
    xs = [x for x in xs if x != NEG_INF]
    if not xs:
        return NEG_INF
    m = max(xs)
    return m + math.log(sum(math.exp(x - m) for x in xs))
