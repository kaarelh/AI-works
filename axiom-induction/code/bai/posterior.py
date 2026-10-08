"""Exact posterior over a finite pool, posterior masses, bounded derivability and the threshold verifier."""
import math

from .grammar import NEG_INF, logsumexp, LN2, Grammar
from .lik import dirichlet_marginal, dirichlet_bounds, DPTooLarge, logcoefs0, Chain
from .pool import mem_theory
from .theory import Theory


def coef_fn(lik, Q=None):
    """per-datum coefficient function for a likelihood: 'L0' (needs Q), a Chain (L1) or a SelChain.
    Under L0 a theory of ground sentences (Mem) has a_i(d) = [d = T_i]: looked up directly."""
    if lik == 'L0':
        def f(th, d):
            if all(c.ground and not _hasp(c.T) for c in th.comps):
                idx = th.tags.get('_ground_index')
                if idx is None:
                    idx = {c.T: i for i, c in enumerate(th.comps)}
                    th.tags['_ground_index'] = idx
                i = idx.get(d)
                return {} if i is None else {i: 0.0}
            return logcoefs0(th, d, Q)
        return f
    return lambda th, d: lik.logcoefs(th, d)


def _hasp(t):
    from .theory import has_param
    return has_param(t)


def trimmed(th, used, tagger=None):
    """Trim(T, D_n): the sub-theory of the components of `th` with indices in `used` (the components that
    cover at least one datum of D_n as a first citation).  Returns None if nothing would be removed or
    nothing would be left."""
    if not used or len(used) == len(th.comps):
        return None
    comps = [c for i, c in enumerate(th.comps) if i in used]
    t = Theory(comps, 'trim:' + th.name, {'cls': 'trimmed', 'trimmed_from': th.name})
    if tagger is not None:
        tagger(t)
    return t


def evaluate(pool, data, ns, lik, Q=None, alpha=0.5, lam=1.0, tau=0.0, with_mem=True, code=None,
             max_states=20000, trim=False, tagger=None):
    """posterior over a pool (+ Mem(D_n) if with_mem) after each prefix data[:n], n in ns.

    pool: a list of theories (the same at every n), or a function n -> list of theories (a pool that may
    depend on the data seen so far, e.g. theories built from D_b for build points b <= n).
    trim: if True, at each n add Trim(T, D_n) for every pool theory T with at least two components (the
    components of T that cover some datum of D_n; see `trimmed`), tagged by tagger(theory) if given.
    Theories are deduplicated at each n by their component keys; the first occurrence wins.

    Returns a list (one per n) of dicts name -> {'lp': log prior, 'lm': log marginal likelihood,
    'post': posterior probability, 'theory': the theory}.  If the exact Dirichlet DP of a theory exceeds
    max_states states, its marginal is replaced by the lower bound of dirichlet_bounds ('lm_hi' holds the
    upper bound) and the entry '_bounded' gives the largest posterior mass the bounded theories could have.
    log prior = -lam * bits * ln 2 - tau * log2(1 + size) * ln 2."""
    cf = coef_fn(lik, Q)
    N = max(ns)
    coefs = {}          # theory key -> list of coefficient dicts (extended lazily)
    priors = {}

    def get_coefs(th, n):
        cs = coefs.get(th.key)
        if cs is None:
            cs = []
            coefs[th.key] = cs
        while len(cs) < n:
            cs.append(cf(th, data[len(cs)]))
        return cs[:n]

    def get_prior(th):
        v = priors.get(th.key)
        if v is None:
            v = th.tags['log_prior'] if 'log_prior' in th.tags else th.log_prior(lam, tau, code)
            priors[th.key] = v
        return v
    out = []

    def marg(cs, m):
        try:
            return dirichlet_marginal(cs, m, alpha, max_states=max_states), None
        except DPTooLarge:
            lo, hi = dirichlet_bounds(cs, m, alpha)
            return lo, hi
    for n in ns:
        res = {}
        seen = set()
        cur = list(pool(n) if callable(pool) else pool)
        if trim:
            extra = []
            for th in cur:
                if len(th.comps) < 2:
                    continue
                cs = get_coefs(th, n)
                used = set()
                for cj in cs:
                    used.update(cj)
                t = trimmed(th, used, tagger)
                if t is not None:
                    extra.append(t)
            cur = cur + extra
        mem = mem_theory(data[:n], 'Mem') if with_mem else None
        if mem is not None:
            cur = cur + [mem]
        names_by_key = {}
        for th in cur:
            if th.key in seen:
                if th is mem:
                    # Mem(D_n) equals a pool theory: that theory keeps its name and its mass; 'Mem' is an
                    # alias with no mass of its own (no double counting)
                    res['Mem'] = {'lp': NEG_INF, 'lm': NEG_INF, 'theory': mem, 'alias_of': names_by_key[th.key]}
                continue
            seen.add(th.key)
            name = th.name
            if name in res:
                k = 2
                while '%s#%d' % (name, k) in res:
                    k += 1
                name = '%s#%d' % (name, k)
            names_by_key[th.key] = name
            lm, hi = marg(get_coefs(th, n), len(th.comps))
            res[name] = {'lp': get_prior(th), 'lm': lm, 'theory': th}
            if hi is not None:
                res[name]['lm_hi'] = hi
        z = logsumexp([v['lp'] + v['lm'] for v in res.values()])
        for v in res.values():
            x = v['lp'] + v['lm']
            v['post'] = math.exp(x - z) if x != NEG_INF else 0.0
            v['lpost'] = (x - z) if x != NEG_INF else NEG_INF
        # theories whose marginal is only bounded: the largest posterior mass they could have
        bnd = [k for k, v in res.items() if 'lm_hi' in v]
        if bnd:
            zx = logsumexp([v['lp'] + (v['lm_hi'] if k in bnd else v['lm']) for k, v in res.items()])
            res['_bounded'] = {'post': 0.0, 'lp': NEG_INF, 'lm': NEG_INF, 'names': bnd,
                               'max_post': sum(math.exp(res[k]['lp'] + res[k]['lm_hi'] - zx) for k in bnd)}
        out.append(res)
    return out


def mass(res, names):
    return sum(res[n]['post'] for n in names if n in res)


class Deriver:
    """bounded derivability T |-_K s: s is the output of some chain derivation of length <= K
    (citation, elim with any term, gen, MP with a cited conditional).  With all rule weights positive and
    a grammar of full support this is exactly 'P_T(s) > 0 under L1', so it is computed with Chain."""

    def __init__(self, K=2, Q=None):
        Q = Q or Grammar()
        self.chain = Chain(Q, Q, K=K, c_stop=0.5, qe_open=True)
        self.K = K
        self._memo = {}

    def derives(self, theory, s):
        key = (theory.key, s)
        r = self._memo.get(key)
        if r is None:
            r = any(c.logcoef0(s, self.chain.Q) != NEG_INF for c in theory.comps)
            if not r:
                r = bool(self.chain.logcoefs(theory, s))
            self._memo[key] = r
        return r


def support_mass(res, theories, deriver, s):
    """posterior mass of the theories in res (the pool at this n, including Mem and trimmed theories) that
    derive s.  `theories` is kept for backward compatibility and used only for entries of res that carry
    no theory."""
    byname = {th.name: th for th in theories}
    tot = 0.0
    for name, v in res.items():
        if name.startswith('_') or v['post'] <= 0:
            continue
        th = v.get('theory') or byname.get(name)
        if th is not None and deriver.derives(th, s):
            tot += v['post']
    return tot


def verifier_accepts(res, theories, deriver, s, delta):
    """the threshold verifier: accept s iff the posterior mass of {T : T |-_K s} is >= 1 - delta"""
    return support_mass(res, theories, deriver, s) >= 1 - delta
