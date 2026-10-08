"""Shared code for the 'universal' track checks (Bayesian induction of forall x phi from instances).

Reuses the syntax, parser and unique matcher of ../../../../axiom-schemas/code/dtrc (read-only; no bytecode
is written there).  Everything here is deterministic given an explicit random.Random(seed).

Objects
  term laws      NumLaw(q): Q(S^k 0) = (1-q) q^k.   GWLaw: Galton-Watson closed terms, Q(t) = prod of root probs.
                 OpenLaw(base, rho): a bare parameter w0 with prob rho, else a closed term from base.
  formula law    FormLaw(tlaw): quantifier-free closed formulas (for formula metavariables such as ?A).
  templates      dtrc tuples; '?z' term metavariable, '?A' formula metavariable.
  likelihoods    lp_template (citation of one template), lp_L0strict, lp_L0closure, lp_L1 (minimal calculus:
                 cite + forall-elimination, elim prob c), log_Z_L1 (normaliser), lp_L1sel (selection-aware).
  sampler        sample_derivation: an independent procedural implementation of the derivation grammar,
                 including Gen (prob g) over the parameter w0, used to validate the exact formulas.
"""
import sys
import math
import random

sys.dont_write_bytecode = True
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp, num, size, kids, rebuild, LEAVES, BINDERS, params_of  # noqa: E402
from dtrc.templates import match, instantiate, metas  # noqa: E402

NEG_INF = float('-inf')


def logsumexp(xs):
    xs = [x for x in xs if x > NEG_INF]
    if not xs:
        return NEG_INF
    m = max(xs)
    return m + math.log(sum(math.exp(x - m) for x in xs))


# ------------------------------------------------------------------------------------------- term laws
def numeral_value(t):
    k = 0
    while t[0] == 'S':
        t = t[1]
        k += 1
    return k if t == ('0',) else None


class NumLaw:
    """numerals only: Q(S^k 0) = (1-q) q^k"""
    def __init__(self, q):
        self.q = q

    def logp(self, t):
        k = numeral_value(t)
        if k is None:
            return NEG_INF
        return math.log(1 - self.q) + k * math.log(self.q)

    def sample(self, rng):
        k = 0
        while rng.random() < self.q:
            k += 1
        return num(k)

    def entropy(self):
        q = self.q
        return -math.log(1 - q) - q / (1 - q) * math.log(q)

    def root_probs(self):
        return {'0': 1 - self.q, 'S': self.q}


class GWLaw:
    """closed terms over 0, S, +, *; each node independently picks its root: Q(t) = prod_nodes p(root)"""
    def __init__(self, p=None, max_nodes=200):
        self.p = p or {'0': 0.4, 'S': 0.3, '+': 0.2, '*': 0.1}
        self.lp = {k: math.log(v) for k, v in self.p.items()}
        self.max_nodes = max_nodes

    def logp(self, t):
        h = t[0]
        if h not in self.p:
            return NEG_INF
        return self.lp[h] + sum(self.logp(k) for k in kids(t))

    def _sample(self, rng, budget):
        budget[0] -= 1
        if budget[0] < 0:
            raise OverflowError
        u, acc = rng.random(), 0.0
        for h, ph in self.p.items():
            acc += ph
            if u < acc:
                break
        if h == '0':
            return ('0',)
        if h == 'S':
            return ('S', self._sample(rng, budget))
        return (h, self._sample(rng, budget), self._sample(rng, budget))

    def sample(self, rng):
        # rejection of (rare) huge trees; the rejected mass is reported by tail_mass_estimate
        while True:
            try:
                return self._sample(rng, [self.max_nodes])
            except OverflowError:
                continue

    def root_probs(self):
        return dict(self.p)


class OpenLaw:
    """bare parameter w0 with probability rho, else a closed term from base"""
    def __init__(self, base, rho, pname='w0'):
        self.base, self.rho, self.pname = base, rho, pname

    def logp(self, t):
        if t[0] == 'p':
            return math.log(self.rho)
        b = self.base.logp(t)
        return NEG_INF if b == NEG_INF else math.log(1 - self.rho) + b

    def sample(self, rng):
        if rng.random() < self.rho:
            return ('p', self.pname)
        return self.base.sample(rng)


class FormLaw:
    """closed quantifier-free formulas: root '=' .5, '<' .2, 'not' .2, 'and' .1; terms from tlaw"""
    def __init__(self, tlaw, p=None):
        self.t = tlaw
        self.p = p or {'=': 0.5, '<': 0.2, 'not': 0.2, 'and': 0.1}

    def logp(self, f):
        h = f[0]
        if h not in self.p:
            return NEG_INF
        lp = math.log(self.p[h])
        if h in ('=', '<'):
            return lp + self.t.logp(f[1]) + self.t.logp(f[2])
        return lp + sum(self.logp(k) for k in kids(f))

    def sample(self, rng):
        u, acc = rng.random(), 0.0
        for h, ph in self.p.items():
            acc += ph
            if u < acc:
                break
        if h in ('=', '<'):
            return (h, self.t.sample(rng), self.t.sample(rng))
        if h == 'not':
            return ('not', self.sample(rng))
        return ('and', self.sample(rng), self.sample(rng))


# ------------------------------------------------------------------------------------------- templates
def subst_outer(body, rep, d=0):
    """replace the variable bound by a just-removed outermost binder (index d at binder depth d) by rep;
    rep must contain no de Bruijn index (a closed term, a parameter or a metavariable)"""
    h = body[0]
    if h == 'v':
        return rep if body[1] == d else body
    if h in LEAVES:
        return body
    if h in BINDERS:
        return (h, subst_outer(body[1], rep, d + 1))
    if h == 'M':
        return ('M', body[1], tuple(subst_outer(a, rep, d) for a in body[2]))
    return rebuild(body, [subst_outer(k, rep, d) for k in kids(body)])


def leading_all(A):
    m = 0
    while A[0] == 'all':
        A = A[1]
        m += 1
    return m


def strip(A, k):
    """the template whose instances are the results of k forall-eliminations applied to instances of A:
    the first k leading binders become fresh term metavariables e0, e1, ..."""
    for i in range(k):
        assert A[0] == 'all'
        A = subst_outer(A[1], ('M', 'elim%d' % i, ()))
    return A


def lp_template(A, d, tlaw, flaw=None):
    """log probability that citing A (metavariables i.i.d. from their sort's law) yields exactly d"""
    th = match(A, d)
    if th is None:
        return NEG_INF
    s = 0.0
    for name, val in th.items():
        if name[0].isupper():
            if flaw is None:
                return NEG_INF
            s += flaw.logp(val)
        else:
            s += tlaw.logp(val)
        if s == NEG_INF:
            return NEG_INF
    return s


def lp_L0strict(theory, d, tlaw, flaw=None):
    """pure citation: a sentence axiom yields only itself"""
    return logsumexp([math.log(w) + lp_template(A, d, tlaw, flaw) for A, w in theory])


def lp_L0closure(theory, d, tlaw, flaw=None):
    """citation with the closure reading: a universal sentence forall xbar chi cites chi(tbar)"""
    return logsumexp([math.log(w) + lp_template(strip(A, leading_all(A)), d, tlaw, flaw) for A, w in theory])


def lp_L1(theory, d, c, tlaw, flaw=None):
    """minimal calculus {cite, forall-elim}: root cites with prob 1-c (axiom by weight), or with prob c applies
    forall-elim (term from tlaw) to a recursively generated premise.  Sub-probability (failures lost)."""
    terms = []
    for A, w in theory:
        for k in range(leading_all(A) + 1):
            lp = lp_template(strip(A, k), d, tlaw, flaw)
            if lp > NEG_INF:
                terms.append(math.log(w) + math.log(1 - c) + k * math.log(c) + lp)
    return logsumexp(terms)


def log_Z_L1(theory, c):
    """total success probability of the minimal-calculus grammar (all leading-forall chains are well typed)"""
    return math.log(sum(w * (1 - c) * sum(c ** k for k in range(leading_all(A) + 1)) for A, w in theory))


def log_PS_L1(theory, c):
    """probability of producing a sentence without a leading forall (the selection set S used by L1-sel)"""
    return math.log(sum(w * (1 - c) * c ** leading_all(A) for A, w in theory))


def lp_L1sel(theory, d, c, tlaw, flaw=None):
    return lp_L1(theory, d, c, tlaw, flaw) - log_PS_L1(theory, c)


# ------------------------------------------------------------------------------------------- sampler
def _abstract_param(t, name, d=0):
    h = t[0]
    if h == 'p':
        return ('v', d) if t[1] == name else t
    if h in LEAVES:
        return t
    if h in BINDERS:
        return (h, _abstract_param(t[1], name, d + 1))
    return rebuild(t, [_abstract_param(k, name, d) for k in kids(t)])


def sample_derivation(theory, c, g, tlaw, flaw, rng):
    """procedural derivation grammar: cite (1-c-g), forall-elim (c), Gen over the parameter w0 (g).
    theory: list of (axiom, weight) or (axiom, weight, citation_law).  forall-elim draws its term from tlaw.
    Returns the conclusion, or None on failure (ill-typed rule application)."""
    u = rng.random()
    if u < 1 - c - g:
        r, acc = rng.random(), 0.0
        for ax in theory:
            acc += ax[1]
            if r < acc:
                break
        A = ax[0]
        claw = ax[2] if len(ax) > 2 else tlaw  # optional per-axiom citation law (e.g. a closedness guard)
        theta = {}
        for name in metas(A):
            theta[name] = flaw.sample(rng) if name[0].isupper() else claw.sample(rng)
        return instantiate(A, theta)
    prem = sample_derivation(theory, c, g, tlaw, flaw, rng)
    if prem is None:
        return None
    if u < 1 - g:  # forall-elim
        if prem[0] != 'all':
            return None
        return subst_outer(prem[1], tlaw.sample(rng))
    ps = params_of(prem)  # Gen
    if not ps:
        return None
    return ('all', _abstract_param(prem, ps[0]))


# ------------------------------------------------------------------------------------------- examples
PHIS = {
    # name: (instance schema sigma_phi, universal sentence forall x phi)
    '0+x=x': ('0+?z=?z', 'forall x. 0+x=x'),
    'x+0=x': ('?z+0=?z', 'forall x. x+0=x'),
    'x*0=0': ('?z*0=0', 'forall x. x*0=0'),
    'Sx!=0': ('~(S?z=0)', 'forall x. ~(Sx=0)'),
    'x<Sx': ('?z<S?z', 'forall x. x<Sx'),
}


def P(s):
    return parse(s)


def prior_logw(theory_axioms, lam=1.0, per_axiom=1):
    """log prior weight (natural log) of a theory: 2^{-lam (sum of dtrc symbol counts + per_axiom per axiom)}"""
    return -lam * math.log(2) * sum(size(A) + per_axiom for A in theory_axioms)


def open_calculus_forms(c, g, rho, w_all, w_open, w_sch, Qc_logp):
    """exact output law of the calculus {cite, forall-elim, Gen} for a qf one-variable phi, term law
    Q_open = rho*[w0] + (1-rho)*Q_c, and a theory citing forall x phi (weight w_all), the unguarded template
    phi(z) with z ~ Q_open (w_open) and the guarded template phi(z), z ~ Q_c (w_sch).
    Returns (a, b_p, b_closed(t), Z): probabilities of forall x phi, phi(w0), phi(t) for closed t, and the
    success probability."""
    K = 1 - c - g
    a = K * (w_all + g * rho * w_open) / (1 - g * c * rho)
    b_p = rho * (K * w_open + c * a)

    def b_closed(t):
        return math.exp(Qc_logp(t)) * ((1 - rho) * (K * w_open + c * a) + K * w_sch)
    Z = a * (1 + c) + K * (w_open + w_sch)
    return a, b_p, b_closed, Z
