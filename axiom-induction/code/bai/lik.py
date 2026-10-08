"""Likelihoods.

Every likelihood here is a mixture over the components of a theory T = {T_1..T_m} with weights w:
    P(d | T, w) = sum_i w_i a_i(d),
and the weights are integrated against a symmetric Dirichlet(alpha) prior (dirichlet_marginal).

L0 (citation): a_i(d) = Q(theta_i(d)), the probability that citing T_i with bodies from Q gives d
(Component.logcoef0).

L1 (chain derivation grammar, class Chain).  A derivation is a chain s_0, s_1, ..., s_k, k <= K:
  * s_0 = T_i theta, a citation: component i with probability w_i, bodies theta from Q;
  * at step j < K, if some rule applies to s_j, the chain stops with probability c_stop; otherwise it
    picks an applicable rule r with probability c_r / sum of c over the applicable rules and applies it:
      elim  (s_j = forall x psi):  s_{j+1} = psi[t/x], t drawn from the term grammar Qe;
      gen   (s_j contains the parameter w0):  s_{j+1} = forall x s_j[x/w0]  (all occurrences);
      mp    (some 'MP component' A -> B has A matching s_j):  pick one such component uniformly,
            s_{j+1} = B theta, with theta read off s_j on A's metavariables and drawn from Q on the rest;
  * if no rule applies, or j = K, the chain stops.  The datum is the last sentence.
An MP component is a component of the form A -> B with A and B both DT° and every metavariable of A
occurring in B.  The major premise is cited (not derived); the minor premise is the current sentence.
The process never fails, so sum_d P(d | T, w) = 1 exactly, and a_i(d) is linear in nothing but the first
citation, so the Dirichlet integral is computed exactly as for L0.

a_i(d) is computed exactly by a backward recursion over the last rule (Chain.logcoefs): the state
probabilities G_k(s) = P(s_k = s) satisfy
    G_0(s)_i = a_i^{L0}(s),
    G_k(d) = sum over (pred, rule) with rule(pred) = d of G_{k-1}(pred) (1 - c_stop) P(rule | pred) P(d | pred, rule),
and P(d) = sum_k G_k(d) * stop_k(d).  The predecessors are finitely many: for elim, forall x psi with
psi[t/x] = d, i.e. a closed term t of d and a nonempty set of its occurrences (or the vacuous psi = d,
for which sum_t Qe(t) = 1); for gen, the unique s with gen(s) = d; for mp, B theta = d determines theta.
Predecessors that cannot occur at step k-1 are pruned by a sound abstraction (Abstract) that tracks the
leading-quantifier spine and whether the parameter can occur.
"""
import itertools
import math

import numpy as np

from dtrc.syntax import kids, LEAVES, replace_at, pp, canon_params
from dtrc.templates import match, metas, meta_sort, is_DT0, instantiate
from .grammar import Grammar, NEG_INF, logaddexp, logsumexp, PARAM
from .theory import Component, Theory, has_param


# ------------------------------------------------------------------------------------ syntax helpers
def has_bound_var(t):
    h = t[0]
    if h == 'v':
        return True
    if h in LEAVES:
        return False
    return any(has_bound_var(k) for k in kids(t))


def forall_elim(s, t):
    """psi[t/x] for s = forall x psi; t must have no bound variables"""
    assert s[0] == 'all'

    def go(u, j):
        h = u[0]
        if h == 'v':
            if u[1] == j:
                return t
            if u[1] > j:
                return ('v', u[1] - 1)
            return u
        if h in LEAVES:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], j + 1))
        return (h,) + tuple(go(k, j) for k in u[1:])
    return go(s[1], 0)


def gen(s):
    """forall x s[x/w0] (abstract every occurrence of the parameter)"""
    def go(u, j):
        h = u[0]
        if h == 'p':
            return ('v', j)
        if h in LEAVES:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], j + 1))
        return (h,) + tuple(go(k, j) for k in u[1:])
    return ('all', go(s, 0))


def outer_var_occurs(chi):
    """does the variable bound by an outer binder directly above chi occur in chi"""
    def go(u, j):
        h = u[0]
        if h == 'v':
            return u[1] == j
        if h in LEAVES:
            return False
        if h in ('all', 'ex'):
            return go(u[1], j + 1)
        return any(go(k, j) for k in u[1:])
    return go(chi, 0)


def ungen(s):
    """the unique s' with gen(s') = s, or None: s = forall x chi, chi uses x, s has no parameter"""
    if s[0] != 'all' or has_param(s) or not outer_var_occurs(s[1]):
        return None

    def go(u, j):
        h = u[0]
        if h == 'v':
            return PARAM if u[1] == j else u
        if h in LEAVES:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], j + 1))
        return (h,) + tuple(go(k, j) for k in u[1:])
    return go(s[1], 0)


def closed_term_occurrences(s):
    """dict term -> list of (path, binder depth) for the occurrences in s of terms without bound variables"""
    occ = {}

    def go(t, path, depth, sort):
        h = t[0]
        if sort == 'T':
            if not has_bound_var(t):
                occ.setdefault(t, []).append((path, depth))
            if h in ('S', '+', '*'):
                for i, k in enumerate(t[1:]):
                    go(k, path + (i,), depth, 'T')
            return
        if h in ('=', '<', 'in'):
            go(t[1], path + (0,), depth, 'T')
            go(t[2], path + (1,), depth, 'T')
        elif h in ('all', 'ex'):
            go(t[1], path + (0,), depth + 1, 'F')
        elif h in ('not', 'and', 'or', 'imp', 'iff'):
            for i, k in enumerate(t[1:]):
                go(k, path + (i,), depth, 'F')
    go(s, (), 0, 'F')
    return occ


class TooManyOccurrences(Exception):
    pass


def elim_predecessors(s, Qe, qe_open, max_occ=12):
    """all (pred, log Qe(t)) with forall_elim(pred, t) = s; pred = forall x psi.
    The vacuous predecessor forall x s carries log 1 = 0 (sum over t of Qe(t) = 1)."""
    out = [(('all', s), 0.0)]
    for t, occs in closed_term_occurrences(s).items():
        lt = Qe.logq_term(t, 0, 0, qe_open)
        if lt == NEG_INF:
            continue
        if len(occs) > max_occ:
            raise TooManyOccurrences('%d occurrences of %s' % (len(occs), pp(t)))
        n = len(occs)
        for mask in range(1, 1 << n):
            psi = s
            for b in range(n):
                if mask >> b & 1:
                    path, depth = occs[b]
                    psi = replace_at(psi, path, ('v', depth))
            out.append((('all', psi), lt))
    return out


def spine(T):
    heads = []
    node = T
    while True:
        h = node[0]
        if h == 'M':
            heads.append('*')
            break
        heads.append(h)
        if h == 'all':
            node = node[1]
        else:
            break
    return tuple(heads)


def compatible(s, level):
    """can sentence s be in the abstract set `level` (a set of (spine, param_possible))"""
    sp = spine(s)
    hp = has_param(s)
    for (a, p) in level:
        if hp and not p:
            continue
        ok = True
        for i, h in enumerate(a):
            if h == '*':
                break
            if i >= len(sp) or sp[i] != h:
                ok = False
                break
        else:
            ok = len(sp) == len(a)
        if ok:
            return True
    return False


# ------------------------------------------------------------------------------------ L1 chain grammar
class MPComp:
    def __init__(self, idx, comp):
        T = comp.T
        self.idx = idx
        self.comp = comp
        self.A, self.B = T[1], T[2]
        self.extra = {m: ar for m, ar in metas(self.B).items() if m not in metas(self.A)}


def mp_eligible(comp):
    T = comp.T
    if T[0] != 'imp':
        return False
    A, B = T[1], T[2]
    if not metas(A) and not metas(B):
        return True
    if not (is_DT0(A) and is_DT0(B)):
        return False
    return set(metas(A)) <= set(metas(B))


class Chain:
    """the L1 chain derivation grammar (module docstring)"""

    def __init__(self, Q, Qe=None, K=2, c_stop=0.5, c_elim=1.0, c_gen=1.0, c_mp=1.0, qe_open=True,
                 max_occ=10, guided=True):
        self.Q = Q
        self.guided = guided      # False: brute-force predecessor enumeration only (reference for tests)
        self.Qe = Qe if Qe is not None else Q
        self.K = K
        self.c_stop = c_stop
        self.c = {'elim': c_elim, 'gen': c_gen, 'mp': c_mp}
        self.qe_open = qe_open
        self.max_occ = max_occ
        self._single = {}       # component key -> _Ctx for single-component theories
        self.inexact = 0

    def describe(self):
        return {'K': self.K, 'c_stop': self.c_stop, 'c': self.c, 'qe_open': self.qe_open,
                'Q': self.Q.describe(), 'Qe': self.Qe.describe()}

    def ctx(self, comps):
        return _Ctx(self, comps)

    def logcoefs(self, theory, d):
        """dict component index -> log a_i(d) under L1 (finite entries only)"""
        if not any(mp_eligible(c) for c in theory.comps):
            out = {}
            for i, c in enumerate(theory.comps):
                cx = self._single.get(c.key)
                if cx is None:
                    cx = _Ctx(self, [c])
                    self._single[c.key] = cx
                v = cx.out(d).get(0)
                if v is not None:
                    out[i] = v
            return out
        cx = theory.tags.get('_l1ctx')
        if cx is None or cx.chain is not self:
            cx = _Ctx(self, theory.comps)
            theory.tags['_l1ctx'] = cx
        return cx.out(d)

    # -------------------------------------------------------------- forward sampler
    def sample(self, comps, w, rng, return_trace=False):
        i = _choose(rng, w)
        c = comps[i]
        theta = {m: self.Q.sample_body(rng, meta_sort(m), ar, c.guards[m] == 'open') for m, ar in c.metas.items()}
        s = canon_params(instantiate(c.T, theta))
        trace = [('cite', i)]
        mpc = [MPComp(j, cc) for j, cc in enumerate(comps) if mp_eligible(cc)]
        for k in range(self.K):
            rules = []
            if s[0] == 'all':
                rules.append('elim')
            if has_param(s):
                rules.append('gen')
            appl = [m for m in mpc if _mp_match(m, s) is not None]
            if appl:
                rules.append('mp')
            if not rules or rng.random() < self.c_stop:
                break
            r = _choose(rng, [self.c[x] for x in rules])
            r = rules[r]
            if r == 'elim':
                t = self.Qe.sample_term(rng, 0, 0, self.qe_open)
                s = forall_elim(s, t)
            elif r == 'gen':
                s = gen(s)
            else:
                m = appl[rng.randrange(len(appl))]
                th = dict(_mp_match(m, s))
                for mv, ar in m.extra.items():
                    th[mv] = self.Q.sample_body(rng, meta_sort(mv), ar, m.comp.guards[mv] == 'open')
                s = instantiate(m.B, th)
            s = canon_params(s)
            trace.append(r)
        return (s, trace) if return_trace else s


def _choose(rng, w):
    tot = sum(w)
    r = rng.random() * tot
    acc = 0.0
    for i, x in enumerate(w):
        acc += x
        if r < acc:
            return i
    return len(w) - 1


def _mp_match(m, s):
    """theta on A's metavariables if the MP component's antecedent matches s (guards respected)"""
    if not metas(m.A):
        return {} if m.A == s else None
    th = match(m.A, s)
    if th is None:
        return None
    for mv, b in th.items():
        if m.comp.guards[mv] == 'closed' and has_param(b):
            return None
    return th


class _Ctx:
    """per-theory memo for the backward recursion"""

    def __init__(self, chain, comps):
        self.chain = chain
        self.comps = list(comps)
        self.mpc = [MPComp(j, c) for j, c in enumerate(self.comps) if mp_eligible(c)]
        self.G = {}
        self.appl = {}
        self.levels = self._levels()
        self.l_cont = math.log(1 - chain.c_stop) if chain.c_stop < 1 else NEG_INF
        self.l_stop = math.log(chain.c_stop) if chain.c_stop > 0 else NEG_INF
        self._sources = {}

    def _levels(self):
        lv0 = set()
        for c in self.comps:
            p = has_param(c.T) or any(g == 'open' for g in c.guards.values())
            lv0.add((spine(c.T), p))
        levels = [lv0]
        for k in range(1, self.chain.K + 1):
            nxt = set()
            for (a, p) in levels[-1]:
                if a[0] in ('all', '*'):
                    na = a[1:] if a[0] == 'all' else ('*',)
                    nxt.add((na, p or self.chain.qe_open))
                if p:
                    nxt.add((('all',) + a, False))
                for m in self.mpc:
                    pb = p or has_param(m.B) or any(m.comp.guards[x] == 'open' for x in m.extra)
                    nxt.add((spine(m.B), pb))
            levels.append(nxt)
        return levels

    def rules(self, s):
        r = self.appl.get(s)
        if r is None:
            rs = []
            if s[0] == 'all':
                rs.append('elim')
            if has_param(s):
                rs.append('gen')
            napp = sum(1 for m in self.mpc if _mp_match(m, s) is not None)
            if napp:
                rs.append('mp')
            tot = sum(self.chain.c[x] for x in rs)
            r = (tuple(rs), tot, napp)
            self.appl[s] = r
        return r

    # -------------------------------------------------------------- elim predecessor sources
    def sources(self, lvl):
        """(templates, star, gen_comps, brute): forall-rooted sentences at step lvl are instances of the
        templates (of their derived forms), or come from bare formula metavariables (star, level 0 only),
        or from gen applied to a level-0 sentence of a component in gen_comps (level 1 only); brute = True
        if some source is not covered and the brute-force enumeration is needed"""
        r = self._sources.get(lvl)
        if r is not None:
            return r
        temps, star, gcomps, brute = [], [], [], False
        if not self.chain.guided:
            r = ([], [], [], True)
            self._sources[lvl] = r
            return r
        if lvl == 0:
            for i, c in enumerate(self.comps):
                sp = spine(c.T)
                if star_form(c.T):
                    star.append(i)
                elif sp[0] == 'all':
                    temps.append(c.T)
                elif sp[0] == '*':
                    brute = True
        elif lvl == 1:
            for i, c in enumerate(self.comps):
                sp = spine(c.T)
                if sp[0] == '*' or (sp[0] == 'all' and sp[1] == '*'):
                    brute = True
                elif sp[:2] == ('all', 'all'):
                    U1 = derived_elim(c.T, 'u__1')
                    if U1 is None:
                        brute = True
                    else:
                        temps.append(U1)
                if has_param(c.T) or any(g == 'open' for g in c.guards.values()):
                    gcomps.append(i)
            for m in self.mpc:
                sb = spine(m.B)
                if sb[0] == 'all':
                    temps.append(m.B)
                elif sb[0] == '*':
                    brute = True
        else:
            brute = True
        r = (temps, star, gcomps, brute)
        self._sources[lvl] = r
        return r

    def _star_guard(self, i):
        T = self.comps[i].T
        mv = T[1] if T[0] == 'M' else T[1][1]
        return self.comps[i].guards[mv]

    def elim_candidates(self, s, lvl):
        """dict pred -> log Qe(t) of non-vacuous elim predecessors of s that can occur at step lvl"""
        ch = self.chain
        temps, star, gcomps, brute = self.sources(lvl)
        out = {}
        if brute:
            for pred, lt in elim_predecessors(s, ch.Qe, ch.qe_open, ch.max_occ)[1:]:
                out[pred] = lt
            return out, brute
        for U in temps:
            D = derived_elim(U, 'u__2')
            if D is None:
                for pred, lt in elim_predecessors(s, ch.Qe, ch.qe_open, ch.max_occ)[1:]:
                    out[pred] = lt
                return out, True
            th = match(D, s)
            if th is None or 'u__2' not in th:
                continue
            t = th.pop('u__2')
            lt = ch.Qe.logq_term(t, 0, 0, ch.qe_open)
            if lt == NEG_INF:
                continue
            pred = canon_params(instantiate(U, th)) if th else U
            out[pred] = lt
        for i in gcomps:
            for pred, lt in gen_elim_candidates(s, self.comps[i], ch.Qe, ch.qe_open, ch.max_occ).items():
                out[pred] = lt
        return out, False

    def g(self, s, k):
        key = (s, k)
        r = self.G.get(key)
        if r is not None:
            return r
        if k == 0:
            r = {}
            for i, c in enumerate(self.comps):
                v = c.logcoef0(s, self.chain.Q)
                if v != NEG_INF:
                    r[i] = v
            self.G[key] = r
            return r
        r = {}
        lev = self.levels[k - 1]
        ch = self.chain

        def add(pred, ltrans, rule, exclude=()):
            if not compatible(pred, lev):
                return
            gp = self.g(pred, k - 1)
            if not gp:
                return
            rs, tot, napp = self.rules(pred)
            if rule not in rs:
                return
            f = self.l_cont + math.log(ch.c[rule] / tot) + ltrans
            if rule == 'mp':
                f -= math.log(napp)
            for i, v in gp.items():
                if i in exclude:
                    continue
                r[i] = logaddexp(r.get(i, NEG_INF), v + f)
        if any(a[0] in ('all', '*') for (a, p) in lev):
            star = self.sources(k - 1)[1]
            # closed form for bare formula metavariables at step 0 (see star_elim_closed_form)
            star_cf = [i for i in star if k == 1 and not self.mpc and ch.guided and
                       (not has_param(s) or self._star_guard(i) == 'closed')]
            try:
                cands, brute = self.elim_candidates(s, k - 1)
                if not brute and len(star_cf) < len(star):
                    for pred, lt in elim_predecessors(s, ch.Qe, ch.qe_open, ch.max_occ)[1:]:
                        cands.setdefault(pred, lt)
            except TooManyOccurrences:
                ch.inexact += 1
                cands, brute = {}, True
            excl = set() if brute else set(star_cf)
            for pred, lt in cands.items():
                add(pred, lt, 'elim', excl)
            add(('all', s), 0.0, 'elim')            # vacuous: sum over t of Qe(t) = 1
            for i in excl:
                v = star_elim_closed_form(s, self.comps[i], ch.Q, ch.Qe, ch.qe_open)
                if v != NEG_INF:
                    # the predecessors of a closed-guard (or parameter-free) bare metavariable have no
                    # parameter and no MP component exists, so elim is the only applicable rule
                    r[i] = logaddexp(r.get(i, NEG_INF), v + self.l_cont)
        pg = ungen(s)
        if pg is not None:
            add(pg, 0.0, 'gen')
        for m in self.mpc:
            th = match(m.B, s) if metas(m.B) else ({} if m.B == s else None)
            if th is None:
                continue
            ok = True
            lq = 0.0
            for mv, b in th.items():
                if m.comp.guards[mv] == 'closed' and has_param(b):
                    ok = False
                    break
            if not ok:
                continue
            for mv, ar in m.extra.items():
                lq += ch.Q.logq_body(th[mv], meta_sort(mv), ar, m.comp.guards[mv] == 'open')
            if lq == NEG_INF:
                continue
            pred = canon_params(instantiate(m.A, {x: th[x] for x in metas(m.A)})) if metas(m.A) else m.A
            # the forward step from pred reproduces th on A's metavariables (unique DT° match)
            add(pred, lq, 'mp')
        self.G[key] = r
        return r

    def out(self, d):
        """dict component index -> log P(datum = d, first citation = i) / w_i"""
        res = {}
        for k in range(self.chain.K + 1):
            gk = self.g(d, k)
            if not gk:
                continue
            if k == self.chain.K:
                ls = 0.0
            else:
                rs, tot, napp = self.rules(d)
                ls = self.l_stop if rs else 0.0
            for i, v in gk.items():
                res[i] = logaddexp(res.get(i, NEG_INF), v + ls)
        return res


def derived_elim(U, uname):
    """for U = forall x B (a template): B with x replaced by the fresh 0-ary term metavariable ?uname.
    Returns None unless the result is DT° (x must not be an argument of a metavariable occurrence).
    For a DT° result D, the pairs (instance of U, term t) with forall_elim = s correspond one-to-one to
    the matchers of D against s, so they are found by one unique match."""
    if U[0] != 'all':
        return None

    def go(t, j):
        h = t[0]
        if h == 'v':
            if t[1] == j:
                return ('M', uname, ())
            if t[1] > j:
                return ('v', t[1] - 1)
            return t
        if h == 'M':
            return ('M', t[1], tuple(go(a, j) for a in t[2]))
        if h in LEAVES:
            return t
        if h in ('all', 'ex'):
            return (h, go(t[1], j + 1))
        return (h,) + tuple(go(k, j) for k in t[1:])
    D = go(U[1], 0)
    try:
        return D if is_DT0(D) else None
    except Exception:
        return None


def _replace_param_by_meta(T, uname):
    h = T[0]
    if h == 'p':
        return ('M', uname, ())
    if h == 'M':
        return T
    if h in LEAVES:
        return T
    if h in ('all', 'ex'):
        return (h, _replace_param_by_meta(T[1], uname))
    return (h,) + tuple(_replace_param_by_meta(k, uname) for k in T[1:])


def _subterm_paths(body, t):
    from dtrc.syntax import positions
    return [p for p, u in positions(body) if u == t]


def gen_elim_candidates(s, comp, Qe, qe_open, max_occ=12):
    """all pred1 = gen(s0) with s0 an instance of comp containing w0 and forall_elim(pred1, t) = s, i.e.
    s = s0[t/w0]; returned as dict pred1 -> log Qe(t)"""
    out = {}
    rigid = has_param(comp.T)
    open_ms = [m for m in comp.metas if comp.guards[m] == 'open']
    if not rigid and not open_ms:
        return out
    D = _replace_param_by_meta(comp.T, 'u__p') if rigid else comp.T
    th = match(D, s)
    if th is None:
        return out
    if rigid:
        if 'u__p' not in th:
            return out
        tcands = [th.pop('u__p')]
    else:
        tc = set()
        for m in open_ms:
            for t in closed_term_occurrences_any(th[m]):
                tc.add(t)
        tcands = sorted(tc)
    for t in tcands:
        if has_bound_var(t) or _has_hole(t):
            continue
        lt = Qe.logq_term(t, 0, 0, qe_open)
        if lt == NEG_INF:
            continue
        occ = [(m, p) for m in open_ms for p in _subterm_paths(th[m], t)]
        if len(occ) > max_occ:
            raise TooManyOccurrences('%d occurrences of %s' % (len(occ), pp(t)))
        for mask in range(0 if rigid else 1, 1 << len(occ)):
            th0 = dict(th)
            for b in range(len(occ)):
                if mask >> b & 1:
                    m, p = occ[b]
                    th0[m] = replace_at(th0[m], p, PARAM)
            s0 = instantiate(comp.T, th0) if th0 else comp.T
            if not has_param(s0):
                continue
            pred1 = gen(s0)
            if forall_elim(pred1, t) != s:
                continue
            out[canon_params(pred1)] = lt
    return out


def _has_hole(t):
    h = t[0]
    if h == 'h':
        return True
    if h in LEAVES:
        return False
    return any(_has_hole(k) for k in kids(t))


def closed_term_occurrences_any(body):
    """closed terms (no bound variable, no hole) occurring in a metavariable body"""
    from dtrc.syntax import positions, TERM_HEADS
    out = []
    for p, u in positions(body):
        if u[0] in ('0', 'S', '+', '*', 'p') and not has_bound_var(u) and not _has_hole(u):
            out.append(u)
    return out


def star_form(T):
    """'bare' for ?P (0-ary formula metavariable), 'allP' for forall x ?P(x), else None"""
    if T[0] == 'M' and not T[2]:
        return 'bare'
    if T[0] == 'all' and T[1][0] == 'M' and T[1][2] == (('v', 0),):
        return 'allP'
    return None


def star_elim_closed_form(s, comp, Q, Qe, qe_open):
    """for a bare 0-ary formula metavariable component ?P: log of
         sum over non-vacuous (psi, t) with psi[t/x] = s of  Q_F(forall x psi) * Qe(t)
    Under the PCFG, Q_F(forall x psi_S) = Q_F(forall x s) * prod_{o in S} r_o with
    r_o = (p_var / nv_o) / Q_hv(t), where nv_o = 1 + binder depth at o and Q_hv(t) is the probability of t
    in a context with variables; so the sum over nonempty S is Q_F(forall x s) * (prod_o (1 + r_o) - 1)."""
    form = star_form(comp.T)
    mv = comp.T[1] if form == 'bare' else comp.T[1][1]
    ap = comp.guards[mv] == 'open'
    # Q_F(forall x psi) for ?P equals q(all) * Q_F(psi with x as a variable); for forall x ?P(x) the body
    # is psi with x as hole 0, whose probability is Q_F(psi; nh=0, nb=1) (variables are counted alike)
    offset = 0.0 if form == 'bare' else -Q._lf['all']
    if has_param(s):
        # closed guard: the predecessor forall x psi has no parameter, so t contains w0 and every occurrence
        # of t is replaced (and every w0 of s lies inside one): one predecessor per such t
        assert not ap
        tot = NEG_INF
        for t, occs in closed_term_occurrences(s).items():
            if not has_param(t):
                continue
            lt = Qe.logq_term(t, 0, 0, qe_open)
            if lt == NEG_INF:
                continue
            psi = s
            for (path, depth) in occs:
                psi = replace_at(psi, path, ('v', depth))
            pred = ('all', psi)
            if has_param(pred):
                continue
            lq = Q.logq_form(pred, 0, 0, False)
            if lq != NEG_INF:
                tot = logaddexp(tot, lq + offset + lt)
        return tot
    lvac = Q.logq_form(('all', s), 0, 0, ap)
    if lvac != NEG_INF:
        lvac += offset
    if lvac == NEG_INF:
        return NEG_INF
    c = Q._tctx(True, ap)
    if 'var' not in c:
        return NEG_INF
    lpv = c['var']
    tot = NEG_INF
    for t, occs in closed_term_occurrences(s).items():
        lt = Qe.logq_term(t, 0, 0, qe_open)
        if lt == NEG_INF:
            continue
        lqt = Q.logq_term(t, 0, 1, ap)
        prod = 0.0
        for (path, depth) in occs:
            x = lpv - math.log(depth + 1) - lqt          # log r_o
            prod += x + math.log1p(math.exp(-x)) if x > 0 else math.log1p(math.exp(x))
        # log(prod (1 + r_o) - 1)
        val = prod + math.log(-math.expm1(-prod))
        tot = logaddexp(tot, lvac + val + lt)
    return tot


# ------------------------------------------------------------------------------------ L0 helper
def logcoefs0(theory, d, Q):
    out = {}
    for i, c in enumerate(theory.comps):
        v = c.logcoef0(d, Q)
        if v != NEG_INF:
            out[i] = v
    return out


# ------------------------------------------------------------------------------------ Dirichlet marginal
class DPTooLarge(Exception):
    pass


def dirichlet_bounds(coefs, m, alpha=0.5, iters=500):
    """(lower, upper) bounds on dirichlet_marginal, for when the exact DP is too large.

    Upper: the Dirichlet average of L(w) = prod_j sum_i w_i a_ij is at most max_w L(w).  f = log L is
    concave on the simplex, so for any w, max f <= f(w) + max_i g_i - n with g_i = sum_j a_ij / p_j(w)
    (first-order bound; p_j(w) = sum_i w_i a_ij).  w is found by EM.
    Lower: one term of the assignment expansion (each datum to its largest coefficient)."""
    n = len(coefs)
    if any(not c for c in coefs):
        return NEG_INF, NEG_INF
    lg = math.lgamma
    cnt = [0] * m
    lo = 0.0
    for cj in coefs:
        i = max(cj, key=cj.get)
        cnt[i] += 1
        lo += cj[i]
    lo += lg(m * alpha) - lg(m * alpha + n) + sum(lg(alpha + c) - lg(alpha) for c in cnt)
    # EM on the scaled coefficients (scale each datum by its max coefficient)
    rows = []
    shift = 0.0
    for cj in coefs:
        mx = max(cj.values())
        shift += mx
        rows.append([(i, math.exp(v - mx)) for i, v in cj.items()])
    w = [1.0 / m] * m
    for _ in range(iters):
        acc = [0.0] * m
        for r in rows:
            p = sum(w[i] * a for i, a in r)
            for i, a in r:
                acc[i] += w[i] * a / p
        w = [x / n for x in acc]
    f = shift
    g = [0.0] * m
    for r in rows:
        p = sum(w[i] * a for i, a in r)
        f += math.log(p)
        for i, a in r:
            g[i] += a / p
    hi = f + max(g) - n
    return lo, hi


def dirichlet_marginal(coefs, m, alpha=0.5, max_states=None):
    """log of  E_{w ~ Dir(alpha,...,alpha)} prod_j sum_i w_i a_i(d_j)  computed exactly.

    coefs: list over data of dicts {component: log a_i(d_j)} (finite entries only); m: number of components.
    Expanding the product gives sum over assignments z of prod_j a_{z_j}(d_j) E[prod_i w_i^{n_i(z)}] with
    E[...] = Gamma(m alpha)/Gamma(m alpha + n) prod_i Gamma(alpha + n_i)/Gamma(alpha).  Data covered by one
    component are counted directly; data covered by several are summed out by dynamic programming over the
    count vectors of the components they share, eliminating each component after its last group."""
    n = len(coefs)
    if n == 0:
        return 0.0
    lg = math.lgamma
    fixed = [0] * m
    base = 0.0
    groups = {}
    for cj in coefs:
        if not cj:
            return NEG_INF
        if len(cj) == 1:
            (i, v), = cj.items()
            fixed[i] += 1
            base += v
        else:
            groups.setdefault(tuple(sorted(cj)), []).append(cj)
    total = base + lg(m * alpha) - lg(m * alpha + n) - m * lg(alpha)
    U = sorted(set(i for S in groups for i in S))
    if 2 <= len(U) <= 3:
        for i in range(m):
            if i not in U:
                total += lg(alpha + fixed[i])
        return total + _dense_dp(U, [cj for S in groups for cj in groups[S]], fixed, alpha)
    order = sorted(groups, key=lambda S: (len(S), S))
    last = {}
    for gi, S in enumerate(order):
        for i in S:
            last[i] = gi
    for i in range(m):
        if i not in last:
            total += lg(alpha + fixed[i])
    act = []
    state = {(): 0.0}
    for gi, S in enumerate(order):
        poly = _group_poly(S, groups[S])
        new_act = act + [i for i in S if i not in act]
        pos = [new_act.index(i) for i in S]
        ext = len(new_act) - len(act)
        nstate = {}
        for st, lw in state.items():
            st0 = list(st) + [0] * ext
            for gv, lgp in poly.items():
                v = list(st0)
                for p, c in zip(pos, gv):
                    v[p] += c
                key = tuple(v)
                nstate[key] = logaddexp(nstate.get(key, NEG_INF), lw + lgp)
        act = new_act
        state = nstate
        if max_states is not None and len(state) > max_states:
            raise DPTooLarge(len(state))
        drop = [i for i in act if last[i] == gi]
        if drop:
            keep_idx = [j for j, i in enumerate(act) if last[i] != gi]
            drop_idx = [(j, i) for j, i in enumerate(act) if last[i] == gi]
            nstate = {}
            for st, lw in state.items():
                add = sum(lg(alpha + fixed[i] + st[j]) for j, i in drop_idx)
                key = tuple(st[j] for j in keep_idx)
                nstate[key] = logaddexp(nstate.get(key, NEG_INF), lw + add)
            state = nstate
            act = [i for i in act if last[i] != gi]
    assert not act
    return total + logsumexp(list(state.values()))


def _dense_dp(U, data, fixed, alpha):
    """exact sum over assignments of the ambiguous data to the components U (|U| = 2 or 3) of
    prod a * prod_{i in U} Gamma(alpha + fixed_i + count_i), in log space, with a dense array over the
    counts of the first |U| - 1 components (the last count is implied)"""
    from scipy.special import gammaln
    r = len(data)
    u = len(U)
    if u == 2:
        A = np.full(r + 1, -np.inf)
        A[0] = 0.0
        for j, cj in enumerate(data):
            new = np.full(r + 1, -np.inf)
            if U[1] in cj:
                new[:j + 1] = A[:j + 1] + cj[U[1]]
            if U[0] in cj:
                new[1:j + 2] = np.logaddexp(new[1:j + 2], A[:j + 1] + cj[U[0]])
            A = new
        c0 = np.arange(r + 1)
        F = A + gammaln(alpha + fixed[U[0]] + c0) + gammaln(alpha + fixed[U[1]] + r - c0)
    else:
        A = np.full((r + 1, r + 1), -np.inf)
        A[0, 0] = 0.0
        for j, cj in enumerate(data):
            new = np.full((r + 1, r + 1), -np.inf)
            if U[2] in cj:
                new[:j + 1, :j + 1] = A[:j + 1, :j + 1] + cj[U[2]]
            if U[0] in cj:
                new[1:j + 2, :j + 1] = np.logaddexp(new[1:j + 2, :j + 1], A[:j + 1, :j + 1] + cj[U[0]])
            if U[1] in cj:
                new[:j + 1, 1:j + 2] = np.logaddexp(new[:j + 1, 1:j + 2], A[:j + 1, :j + 1] + cj[U[1]])
            A = new
        c0 = np.arange(r + 1)[:, None]
        c1 = np.arange(r + 1)[None, :]
        c2 = r - c0 - c1
        valid = c2 >= 0
        F = np.where(valid, A + gammaln(alpha + fixed[U[0]] + c0) + gammaln(alpha + fixed[U[1]] + c1)
                     + gammaln(alpha + fixed[U[2]] + np.maximum(c2, 0)), -np.inf)
    mx = np.max(F)
    if mx == -np.inf:
        return NEG_INF
    return float(mx + np.log(np.sum(np.exp(F - mx))))


def _group_poly(S, data):
    """dict count-vector over S -> log sum over assignments of the group's data to S with those counts"""
    r = len(data)
    if len(S) == 2:
        a, b = S
        arr = np.full(r + 1, -np.inf)
        arr[0] = 0.0
        for j, cj in enumerate(data):
            ca, cb = cj[a], cj[b]
            new = np.full(r + 1, -np.inf)
            new[:j + 2] = arr[:j + 2] + cb
            new[1:j + 2] = np.logaddexp(new[1:j + 2], arr[:j + 1] + ca)
            arr = new
        return {(k, r - k): float(arr[k]) for k in range(r + 1) if arr[k] > -np.inf}
    poly = {tuple([0] * len(S)): 0.0}
    for cj in data:
        new = {}
        for v, lw in poly.items():
            for p, i in enumerate(S):
                v2 = list(v)
                v2[p] += 1
                v2 = tuple(v2)
                new[v2] = logaddexp(new.get(v2, NEG_INF), lw + cj[i])
        poly = new
    return poly


def log_marginal(theory, data, lik, alpha=0.5, Q=None):
    """log P(data | theory) with Dirichlet-integrated weights; lik = 'L0' (needs Q) or a Chain"""
    if lik == 'L0':
        coefs = [logcoefs0(theory, d, Q) for d in data]
    else:
        coefs = [lik.logcoefs(theory, d) for d in data]
    return dirichlet_marginal(coefs, len(theory.comps), alpha)


# ------------------------------------------------------------------------------------ selection model
def quantifier_free(f):
    h = f[0]
    if h in ('all', 'ex'):
        return False
    if h == 'M':
        return False
    if h in LEAVES:
        return True
    return all(quantifier_free(k) for k in kids(f)) if h not in ('=', '<', 'in') else True


def class_prob_qf(comp, chain):
    """probability that a chain started by citing `comp` outputs a closed quantifier-free sentence.

    Exact for components forall^a matrix with a quantifier-free matrix that uses every leading bound
    variable, term metavariables only (0-ary), and theories without MP components: the chain's rule
    applicability depends only on (number of leading quantifiers, whether w0 occurs), which evolves as a
    finite Markov chain.  Raises ValueError otherwise."""
    T = comp.T
    a = 0
    node = T
    while node[0] == 'all':
        a += 1
        node = node[1]
    if not quantifier_free(node):
        raise ValueError('matrix not quantifier-free: %s' % pp(T))
    for m, ar in comp.metas.items():
        if meta_sort(m) != 'T' or ar != 0:
            raise ValueError('only 0-ary term metavariables supported')
    # every leading bound variable must occur in the matrix
    body = T
    for j in range(a):
        body = body[1]
    for j in range(a):
        if not _occurs_index(node, j):
            raise ValueError('vacuous leading quantifier')
    p_open = [m for m in comp.metas if comp.guards[m] == 'open']
    h = chain.Q.p_term_has_param() if p_open else 0.0
    p_param0 = 1.0 if has_param(T) else 1.0 - (1.0 - h) ** len(p_open)
    he = chain.Qe.p_term_has_param() if chain.qe_open else 0.0
    ce, cg = chain.c['elim'], chain.c['gen']
    dist = {}
    if p_param0 > 0:
        dist[(a, True)] = p_param0
    if p_param0 < 1:
        dist[(a, False)] = dist.get((a, False), 0.0) + 1.0 - p_param0
    final = {}
    for k in range(chain.K + 1):
        nd = {}
        for (aa, p), pr in dist.items():
            rules = []
            if aa >= 1:
                rules.append('elim')
            if p:
                rules.append('gen')
            if not rules or k == chain.K:
                final[(aa, p)] = final.get((aa, p), 0.0) + pr
                continue
            final[(aa, p)] = final.get((aa, p), 0.0) + pr * chain.c_stop
            go = pr * (1 - chain.c_stop)
            tot = sum(chain.c[r] for r in rules)
            if 'elim' in rules:
                pe = go * ce / tot
                if he > 0:
                    nd[(aa - 1, True)] = nd.get((aa - 1, True), 0.0) + pe * he
                if he < 1:
                    nd[(aa - 1, p)] = nd.get((aa - 1, p), 0.0) + pe * (1 - he)
            if 'gen' in rules:
                pg = go * cg / tot
                nd[(aa + 1, False)] = nd.get((aa + 1, False), 0.0) + pg
        dist = nd
    return final.get((0, False), 0.0)


def _occurs_index(f, j):
    """does the variable bound j binders above f occur in f"""
    h = f[0]
    if h == 'v':
        return f[1] == j
    if h in LEAVES:
        return False
    if h in ('all', 'ex'):
        return _occurs_index(f[1], j + 1)
    if h == 'M':
        return any(_occurs_index(a, j) for a in f[2])
    return any(_occurs_index(k, j) for k in f[1:])


class SelChain:
    """L1sel: the L1 chain grammar observed only through closed quantifier-free outputs, with per-citation
    selection: a_i^sel(d) = a_i(d) / c_i, c_i = class_prob_qf(T_i).  (Each citation of component i is
    repeated until its chain outputs a closed quantifier-free sentence.)"""

    def __init__(self, chain):
        self.chain = chain
        self._c = {}

    def logcoefs(self, theory, d):
        out = {}
        for i, v in self.chain.logcoefs(theory, d).items():
            c = theory.comps[i]
            lc = self._c.get(c.key)
            if lc is None:
                p = class_prob_qf(c, self.chain)
                lc = math.log(p) if p > 0 else NEG_INF
                self._c[c.key] = lc
            if lc != NEG_INF:
                out[i] = v - lc
        return out


def l1_exact_supported(theory, K):
    """True if the guided backward recursion computes this theory's L1 coefficients without the
    brute-force fallback: at K = 1 every component whose spine starts with a formula metavariable is ?P or
    forall x ?P(x), and every forall-rooted component has a DT° derived template (derived_elim); at K = 2
    there are no metavariable spines and the twice-derived templates of forall-forall components are DT°"""
    for c in theory.comps:
        sp = spine(c.T)
        starish = sp[0] == '*' or (sp[0] == 'all' and '*' in sp)
        if starish:
            if K >= 2 or not star_form(c.T):
                return False
            continue
        if sp[0] == 'all':
            D = derived_elim(c.T, 'u__1')
            if D is None:
                return False
            if K >= 2 and sp[:2] == ('all', 'all') and derived_elim(D, 'u__2') is None:
                return False
    return True
