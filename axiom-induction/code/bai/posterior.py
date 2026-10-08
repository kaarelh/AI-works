"""Exact posterior over a finite pool, posterior masses, bounded derivability and the threshold verifier."""
import math

from .grammar import NEG_INF, logsumexp, LN2, Grammar
from .lik import dirichlet_marginal, dirichlet_bounds, DPTooLarge, logcoefs0, Chain
from .pool import mem_theory


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


def evaluate(pool, data, ns, lik, Q=None, alpha=0.5, lam=1.0, tau=0.0, with_mem=True, code=None,
             max_states=20000):
    """posterior over `pool` (+ Mem(D_n) if with_mem) after each prefix data[:n], n in ns.

    Returns a list (one per n) of dicts name -> {'lp': log prior, 'lm': log marginal likelihood,
    'post': posterior probability}.  If the exact Dirichlet DP of a theory exceeds max_states states, its
    marginal is replaced by the lower bound of dirichlet_bounds ('lm_hi' holds the upper bound) and the
    entry '_bounded' gives the largest posterior mass the bounded theories could have.  log prior = -lam * bits * ln 2 - tau * log2(1 + size) * ln 2."""
    cf = coef_fn(lik, Q)
    N = max(ns)
    coefs = {}
    priors = {}
    for th in pool:
        priors[th.name] = th.tags['log_prior'] if 'log_prior' in th.tags else th.log_prior(lam, tau, code)
        cs = []
        for d in data[:N]:
            cs.append(cf(th, d))
        coefs[th.name] = cs
    out = []

    def marg(cs, m):
        try:
            return dirichlet_marginal(cs, m, alpha, max_states=max_states), None
        except DPTooLarge:
            lo, hi = dirichlet_bounds(cs, m, alpha)
            return lo, hi
    for n in ns:
        res = {}
        for th in pool:
            lm, hi = marg(coefs[th.name][:n], len(th.comps))
            res[th.name] = {'lp': priors[th.name], 'lm': lm}
            if hi is not None:
                res[th.name]['lm_hi'] = hi
        if with_mem:
            mem = mem_theory(data[:n], 'Mem')
            lm, hi = marg([cf(mem, d) for d in data[:n]], len(mem.comps))
            res['Mem'] = {'lp': mem.log_prior(lam, tau, code), 'lm': lm, 'theory': mem}
            if hi is not None:
                res['Mem']['lm_hi'] = hi
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
    """posterior mass of the theories in the pool (and Mem, if present in res) that derive s"""
    tot = 0.0
    ths = list(theories)
    if 'Mem' in res and 'theory' in res['Mem']:
        ths.append(res['Mem']['theory'])
    for th in ths:
        if th.name in res and res[th.name]['post'] > 0 and deriver.derives(th, s):
            tot += res[th.name]['post']
    return tot


def verifier_accepts(res, theories, deriver, s, delta):
    """the threshold verifier: accept s iff the posterior mass of {T : T |-_K s} is >= 1 - delta"""
    return support_mass(res, theories, deriver, s) >= 1 - delta
