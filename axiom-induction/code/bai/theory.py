"""Theories: finite sets of DT° template components with guards; the prior; L0 citation coefficients.

A component is a DT° template T with a guard per metavariable: 'closed' (the body may not contain the
parameter w0) or 'open' (it may).  A sentence is a component without metavariables.

L0 coefficient: because DT° matching is unique, a citation of component T_i with a body assignment theta
drawn from Q yields the datum d exactly when theta is the unique matcher of T_i against d, so
    a_i(d) = P(T_i theta = d) = prod_M Q(theta(M))      (0 if T_i does not match d or a guard is violated).
For a sentence component, a_i(d) = [d = T_i].
"""
import math

from dtrc.syntax import canon_params, pp, size, params_of, kids, LEAVES
from dtrc.templates import match, metas, meta_sort, is_DT0, canon
from .grammar import TemplateCode, theory_bits, NEG_INF, LN2


def has_param(t):
    h = t[0]
    if h == 'p':
        return True
    if h in LEAVES:
        return False
    return any(has_param(k) for k in kids(t))


def canon_renaming(T):
    """the metavariable renaming used by dtrc.templates.canon (preorder of first occurrence; formula
    metavariables P0, P1, ..., term metavariables f0, f1, ...)"""
    ren, cnt = {}, [0, 0]

    def go(t):
        h = t[0]
        if h == 'M':
            if t[1] not in ren:
                if meta_sort(t[1]) == 'F':
                    ren[t[1]] = 'P%d' % cnt[0]
                    cnt[0] += 1
                else:
                    ren[t[1]] = 'f%d' % cnt[1]
                    cnt[1] += 1
            for a in t[2]:
                go(a)
            return
        if h in LEAVES:
            return
        for k in kids(t):
            go(k)
    go(T)
    return ren


def _rename(t, ren):
    h = t[0]
    if h == 'M':
        return ('M', ren.get(t[1], t[1]), tuple(_rename(a, ren) for a in t[2]))
    if h in LEAVES:
        return t
    return (h,) + tuple(_rename(k, ren) for k in t[1:])


class Component:
    """a DT° template in canonical form (dtrc canon) with a guard per metavariable"""

    def __init__(self, T, guards=None, default_guard='closed'):
        if not is_DT0(T):
            raise ValueError('not a DT° template: %s' % pp(T))
        ren = canon_renaming(T)
        g0 = dict(guards or {})
        Tc = canon_params(_rename(T, ren))
        assert Tc == canon(T), (pp(Tc), pp(canon(T)))
        self.T = Tc
        self.metas = metas(Tc)                     # name -> arity
        self.guards = {ren[m]: g0.get(m, default_guard) for m in ren}
        self.ground = not self.metas
        self.key = (Tc, tuple(sorted(self.guards.items())))
        self._cache = {}

    def __repr__(self):
        gs = ''.join('' if g == 'closed' else '[%s open]' % m for m, g in sorted(self.guards.items()))
        return pp(self.T) + gs

    def logcoef0(self, d, Q):
        """natural log of a_i(d) under L0 with grammar Q (memoised per grammar)"""
        key = (id(Q), d)
        r = self._cache.get(key)
        if r is not None:
            return r
        theta = match(self.T, d)
        if theta is None:
            r = NEG_INF
        else:
            r = 0.0
            for m, ar in self.metas.items():
                b = theta[m]
                ap = self.guards[m] == 'open'
                if not ap and has_param(b):
                    r = NEG_INF
                    break
                lq = Q.logq_body(b, meta_sort(m), ar, ap)
                if lq == NEG_INF:
                    r = NEG_INF
                    break
                r += lq
        self._cache[key] = r
        return r

    def matcher(self, d):
        """the unique matcher theta, or None (also None if a guard is violated)"""
        theta = match(self.T, d)
        if theta is None:
            return None
        for m in self.metas:
            if self.guards[m] == 'closed' and has_param(theta[m]):
                return None
        return theta


class Theory:
    """a finite set of components with a name and free-form tags"""

    def __init__(self, comps, name, tags=None):
        seen, out = set(), []
        for c in comps:
            if not isinstance(c, Component):
                c = Component(c)
            if c.key in seen:
                continue
            seen.add(c.key)
            out.append(c)
        self.comps = out
        self.name = name
        self.tags = dict(tags or {})
        self.key = frozenset(c.key for c in out)

    def __len__(self):
        return len(self.comps)

    def __repr__(self):
        return '%s{%s}' % (self.name, '; '.join(repr(c) for c in self.comps))

    def bits(self, code=None):
        """description length in bits: theory_bits plus one guard bit per metavariable is already in the
        template code"""
        return theory_bits([c.T for c in self.comps], code)

    def size(self):
        return sum(size(c.T) for c in self.comps)

    def log_prior(self, lam=1.0, tau=0.0, code=None):
        """natural log of the unnormalised prior 2^(-lam * bits) * (1 + total template size)^(-tau)

        The time factor charges tau * log2(1 + sum |T_i|) bits: deciding axiomhood in DT° is a linear
        match against each template, so this is the log of the membership-test time."""
        b = lam * self.bits(code) + tau * math.log2(1 + self.size())
        return -b * LN2
