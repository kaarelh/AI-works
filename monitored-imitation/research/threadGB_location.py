"""Thread GB (generic location): simulation for research/threadGB-generic-location.md.

numpy only.  Usage: python3 -B threadGB_location.py > threadGB_location.out   (about 2-3 minutes)

Exact Bayes over three small random-program classes.  In every class the human P is a deterministic
program on notebooks; a notebook is summarized by a 64-bit running hash of its entries (append-only,
hidden clock), h_{k+1} = mix(h_k xor mix(label_k)).  The toy verifier is chain equality: V accepts a
run iff its n labels equal the human's own chain (n = n0, no slack).  So a run is rejected iff it has
a mistake, and an accepted run certifies every one of its steps; all VSI variants add an accepted
run's labels as data ("verdict data"), which a calibrated learner must do.  Chained imitation (CI)
has no verifier and learns only from its one uniform task query per problem.

Classes (each with its own prior; "prior" humans are drawn from it, so the learner is calibrated):
* M1, modular code with known dispatch.  E = 48 table entries (12 subroutines x 4 inputs), values in
  [q], q = 4, uniform prior; K = 48 log2 4 = 96 bits.  At each notebook the (known) dispatch calls
  r = 2 entries, drawn from call frequencies f_e proportional to 2^-u_e, u_e uniform on [0, 14]
  (frequencies spread over four decades).  The step writes the values of the called entries.
* FV, decision list over notebook features.  d = 14 features; feature j (1..d) of a notebook is a
  j-bit field of its hash, so each of its values has frequency 2^-j.  L = 5 rules; rule i is
  (j_i, v_i, o_i): j_i uniform on 1..d (log-uniform branch frequencies), v_i uniform on the 2^j
  values, o_i uniform on [q], q = 3; component i of the step is o_i if feature j_i equals v_i,
  else "." (0).  K = sum_i (log2 d + j_i + log2 q).  The posterior is a product over rules and is
  computed exactly (excluded values per (rule, feature); candidate features after a firing).
* SIL, the silent class of the first note (hidden insights): problem p has, with probability eta = 1/2,
  an insight k_p in [q] (q = 4) at a uniform step t_p < n, written there and nowhere else; each
  problem is seen once, so nothing generalizes.

Protocols (each on its own learning trajectory; the same problems for every protocol):
* CI    : chained imitation: one task query at a uniform step of each run; the run is output.
* scan  : VSI, scan from step 0 to the first mistake.
* bayes : VSI, Bayesian search (Theorem GB1): query the run's steps in decreasing order of
          lambda(k) = P(first mistake at k | data, rejection), computed once per rejection.
* thr   : VSI, threshold Bayesian search (Theorem GB2): query the unqueried step of largest current
          doubt mu'(k) = P(P's label at k != run's label | current data) while some step has
          mu' >= gamma = log2(n)/n, recomputing after every miss; then scan the rest from step 0.
Per rejection we record, before the search: G(lambda) = sum_i i lambda_(i) (the guessing cost),
1/max lambda, 2^H(lambda), (sum sqrt lambda)^2 (Arikan), |supp lambda|, the number of suspect steps
(doubt > 0), and the true first mistake's scan position f+1 and rank in the lambda order.

Second experiment (FV1, deferral; Theorem GB5): one rule of fixed rarity j, learner prior uniform on
j.  'immediate' searches each rejection at once (Bayes order); 'defer' sets a rejected problem aside
while its location law is diffuse (1/max lambda > n/4, at most 5 waiting), conditions on the rejection
("the rule fires somewhere in that run"), and searches the next rejection, whose location law is then
concentrated on the steps sharing a value with the waiting runs.  Waiting problems are rerun after
every hit and searched at the end of the deployment.
"""
import math
import sys
import time

import numpy as np

M64 = (1 << 64) - 1


def mix(x):
    """splitmix64 finalizer: a fixed pseudo-random function of a 64-bit integer."""
    x = (x + 0x9E3779B97F4A7C15) & M64
    x = ((x ^ (x >> 30)) * 0xBF58476D1CE4E5B9) & M64
    x = ((x ^ (x >> 27)) * 0x94D049BB133111EB) & M64
    return x ^ (x >> 31)


def lam_stats(lam):
    """Guessing-cost statistics of a location law lam (array over steps, sums to 1)."""
    p = np.sort(lam[lam > 0])[::-1]
    if p.size == 0:
        return dict(G=0.0, inv_max=0.0, h2=0.0, ar=0.0, supp=0)
    G = float(np.sum(np.arange(1, p.size + 1) * p))
    H = float(-np.sum(p * np.log2(p)))
    return dict(G=G, inv_max=1.0 / p[0], h2=2.0 ** H, ar=float(np.sum(np.sqrt(p)) ** 2), supp=int(p.size))


def rank_order(lam):
    """Steps in decreasing lambda (ties: earlier step first), only steps with lambda > 0."""
    ks = np.nonzero(lam > 0)[0]
    return ks[np.lexsort((ks, -lam[ks]))]


# ----------------------------------------------------------------------------------------------
# M1: modular code, known dispatch
# ----------------------------------------------------------------------------------------------
class M1Model:
    name = 'M1'

    def __init__(self, rng, E=48, q=4, r=2, umax=14.0, adversarial=False):
        self.E, self.q, self.r = E, q, r
        u = np.random.default_rng(12345).uniform(0, umax, E)      # dispatch is fixed (known), not drawn per human
        f = 2.0 ** -u
        self.freq = f / f.sum()
        self.cdf = np.cumsum(self.freq)
        lo = 1 if adversarial else 0
        self.code = rng.integers(lo, q, E)                         # the human's code: uniform in [q] (adversarial: never the tie-break 0)
        self.K = E * math.log2(q)
        self._calls = {}

    def start(self, p):
        return mix(0xA5A5 + 7919 * p)

    def calls(self, h):
        c = self._calls.get(h)
        if c is None:
            c = tuple(int(np.searchsorted(self.cdf, (mix(h + 0x1000 * i) >> 11) / float(1 << 53), side='right'))
                      for i in range(self.r))
            c = tuple(min(e, self.E - 1) for e in c)
            self._calls[h] = c
        return c

    def human(self, h):
        return tuple(int(self.code[e]) for e in self.calls(h))

    def next(self, h, lab):
        return mix(h ^ mix(hash(lab) & M64))


class M1Learner:
    def __init__(self, model):
        self.m = model
        self.known = np.zeros(model.E, bool)
        self.val = np.zeros(model.E, int)

    def decode(self, h):
        return tuple(int(self.val[e]) if self.known[e] else 0 for e in self.m.calls(h))

    def observe(self, h, lab):
        for e, v in zip(self.m.calls(h), lab):
            self.known[e] = True
            self.val[e] = v

    def observe_run(self, hs, labs):
        for h, lab in zip(hs, labs):
            self.observe(h, lab)

    def doubts(self, hs, labs):
        q = self.m.q
        mu = np.zeros(len(hs))
        for k, (h, lab) in enumerate(zip(hs, labs)):
            unk = set()
            bad = False
            for e, v in zip(self.m.calls(h), lab):
                if self.known[e]:
                    bad |= (self.val[e] != v)
                else:
                    unk.add(e)
            mu[k] = 1.0 if bad else 1.0 - q ** (-len(unk))
        return mu

    def location(self, hs, labs):
        """lambda(k) = P(first mistake at k | data, rejection): first calls of unknown entries."""
        q = self.m.q
        lam = np.zeros(len(hs))
        S = 1.0
        seen = set()
        for k, h in enumerate(hs):
            new = {e for e in self.m.calls(h) if not self.known[e] and e not in seen}
            seen |= new
            if new:
                lam[k] = S * (1.0 - q ** (-len(new)))
                S *= q ** (-len(new))
        tot = 1.0 - S
        return lam / tot if tot > 0 else lam

    def describe_mistake(self, hs, labs, k):
        return 'code'


# ----------------------------------------------------------------------------------------------
# FV: decision list over notebook features with log-uniform branch frequencies
# ----------------------------------------------------------------------------------------------
class FVModel:
    name = 'FV'

    def __init__(self, rng, d=14, L=5, q=3, jset=None):
        self.d, self.L, self.q = d, L, q
        self.sizes = 2 ** np.arange(1, d + 1)
        self.offsets = np.concatenate([[0], np.cumsum(self.sizes)[:-1]])
        self.tot = int(self.sizes.sum())
        self.j_of = np.repeat(np.arange(d), self.sizes)          # global value index -> feature index
        if jset is None:
            self.J = rng.integers(0, d, L)                        # feature index j-1, uniform on 1..d
        else:
            self.J = rng.choice(np.array(jset) - 1, L)
        self.V = np.array([rng.integers(0, self.sizes[j]) for j in self.J])
        self.O = rng.integers(1, q + 1, L)
        self.gidx = self.offsets[self.J] + self.V                 # rule i fires iff feat[J_i] == gidx_i
        self.K = float(sum(math.log2(d) + (j + 1) + math.log2(q) for j in self.J))
        self._feat = {}

    def start(self, p):
        return mix(0x5EED + 104729 * p)

    def feat(self, h):
        f = self._feat.get(h)
        if f is None:
            bits = (mix(h ^ 0x1111) << 128) | (mix(h ^ 0x2222) << 64) | mix(h ^ 0x3333)
            vals = []
            sh = 0
            for j in range(1, self.d + 1):
                vals.append((bits >> sh) & ((1 << j) - 1))
                sh += j
            f = self.offsets + np.array(vals, dtype=np.int64)
            self._feat[h] = f
        return f

    def human(self, h):
        f = self.feat(h)
        return tuple(int(self.O[i]) if f[self.J[i]] == self.gidx[i] else 0 for i in range(self.L))

    def next(self, h, lab):
        return mix(h ^ mix(hash(lab) & M64))

    def fires(self, h, i):
        return self.feat(h)[self.J[i]] == self.gidx[i]


class FVRule:
    """Exact posterior for one rule (j, v, o) with prior j uniform on 1..d, v uniform, o uniform."""

    def __init__(self, m):
        self.m = m
        self.disc = False
        self.excl = np.zeros(m.tot, bool)
        self.N = m.sizes.astype(float).copy()
        self.zstar = None
        self.cand = None
        self.o = 0
        self.cons = []            # deferred-rejection constraints (FV1 only): list of F matrices
        self.feas = None          # per feature: explicit feasible set of global indices (with constraints)
        self._post = None
        self._ub = None

    def post(self):
        if self._post is None:
            m = self.m
            if not self.disc:
                if self.feas is None:
                    w = self.N / m.sizes
                else:
                    w = np.array([len(s) for s in self.feas], float) / m.sizes
            else:
                w = self.cand / m.sizes
            s = w.sum()
            self._post = w / s
        return self._post

    def _invalidate(self):
        self._post = None
        self._ub = None

    def counts(self):
        if self.feas is None:
            return self.N
        return np.array([len(s) for s in self.feas], float)

    def pfire_rows(self, F):
        """P(rule fires) at each row of F (n x d global indices)."""
        pi = self.post()
        if not self.disc:
            N = self.counts()
            if self.feas is None:
                ok = ~self.excl[F]
            else:
                ok = np.zeros(F.shape, bool)
                for j in range(self.m.d):
                    s = self.feas[j]
                    if s:
                        ok[:, j] = [x in s for x in F[:, j]]
            with np.errstate(divide='ignore', invalid='ignore'):
                c = np.where(N > 0, pi / N, 0.0)
            return ok @ c
        return (F == self.zstar) @ pi

    def label_probs(self, F, lab):
        """P(component == lab[k]) at each row."""
        pf = self.pfire_rows(F)
        q = self.m.q
        if not self.disc:
            return np.where(lab == 0, 1.0 - pf, pf / q)
        return np.where(lab == self.o, pf, np.where(lab == 0, 1.0 - pf, 0.0))

    def decode_row(self, f):
        q = self.m.q
        if not self.disc and self.feas is None:
            if self._ub is None:
                pi = self.post()
                with np.errstate(divide='ignore', invalid='ignore'):
                    self._ub = float(np.sum(np.where(self.N > 0, pi / self.N, 0.0)))
            if self._ub <= q / (q + 1.0):
                return 0
        pf = float(self.pfire_rows(f[None, :])[0])
        if not self.disc:
            return 1 if pf / q > 1.0 - pf else 0
        return self.o if pf > 0.5 else 0

    def observe(self, f, c):
        m = self.m
        if not self.disc:
            if c == 0:
                new = f[~self.excl[f]]
                self.excl[new] = True
                self.N[m.j_of[new]] -= 1
                if self.feas is not None:
                    for j in range(m.d):
                        self.feas[j].discard(int(f[j]))
            else:
                self.disc = True
                self.o = c
                self.zstar = f.copy()
                if self.feas is None:
                    self.cand = (~self.excl[f]).astype(float)
                else:
                    self.cand = np.array([1.0 if int(f[j]) in self.feas[j] else 0.0 for j in range(m.d)])
                for F in self.cons:                      # each waiting run had a firing of the true rule
                    self.cand *= np.any(F == self.zstar, axis=0)
                self.cons = []
                self.feas = None
        else:
            if c == 0:
                self.cand *= (f != self.zstar)
            else:
                self.cand *= (f == self.zstar)
        self._invalidate()

    def observe_run(self, F, labs_i):
        m = self.m
        if not self.disc:
            assert np.all(labs_i == 0)
            vals = np.unique(F.ravel())
            new = vals[~self.excl[vals]]
            self.excl[new] = True
            self.N -= np.bincount(m.j_of[new], minlength=m.d)
            if self.feas is not None:
                for j in range(m.d):
                    self.feas[j].difference_update(F[:, j].tolist())
        else:
            fire = labs_i == self.o
            ok = np.ones(m.d, bool)
            if fire.any():
                ok &= np.all(F[fire] == self.zstar, axis=0)
            if (~fire).any():
                ok &= ~np.any(F[~fire] == self.zstar, axis=0)
            self.cand *= ok
        self._invalidate()

    def first_mistake_law(self, F, labs_i):
        """P(first step where component != run label = k), k < n; the rest is P(no mistake)."""
        n, d = F.shape
        P = np.zeros(n)
        pi = self.post()
        if not self.disc:
            assert np.all(labs_i == 0)
            N = self.counts()
            for j in range(d):
                if pi[j] <= 0:
                    continue
                vals, idx = np.unique(F[:, j], return_index=True)
                if self.feas is None:
                    keep = ~self.excl[vals]
                else:
                    keep = np.array([int(v) in self.feas[j] for v in vals], bool)
                np.add.at(P, idx[keep], pi[j] / N[j])
        else:
            fire_lab = labs_i == self.o
            mism = (F == self.zstar) != fire_lab[:, None]
            anym = mism.any(axis=0)
            first = mism.argmax(axis=0)
            for j in range(d):
                if pi[j] > 0 and anym[j]:
                    P[first[j]] += pi[j]
        return P

    def add_constraint(self, F):
        """Condition on 'the rule fires somewhere in this run' (run decoded '.' everywhere)."""
        assert not self.disc
        m = self.m
        if self.feas is None:
            self.feas = []
            for j in range(m.d):
                self.feas.append(None)
            for j in range(m.d):
                vals = set(int(x) for x in np.unique(F[:, j]) if not self.excl[x])
                self.feas[j] = vals
        else:
            for j in range(m.d):
                self.feas[j] &= set(int(x) for x in F[:, j])
        self.cons.append(F.copy())
        self._invalidate()


class FVLearner:
    def __init__(self, model):
        self.m = model
        self.rules = [FVRule(model) for _ in range(model.L)]

    def F(self, hs):
        return np.array([self.m.feat(h) for h in hs])

    def decode(self, h):
        f = self.m.feat(h)
        return tuple(r.decode_row(f) for r in self.rules)

    def observe(self, h, lab):
        f = self.m.feat(h)
        for r, c in zip(self.rules, lab):
            r.observe(f, c)

    def observe_run(self, hs, labs):
        F = self.F(hs)
        A = np.array(labs)
        for i, r in enumerate(self.rules):
            r.observe_run(F, A[:, i])

    def doubts(self, hs, labs):
        F = self.F(hs)
        A = np.array(labs)
        ok = np.ones(len(hs))
        for i, r in enumerate(self.rules):
            ok *= r.label_probs(F, A[:, i])
        return 1.0 - ok

    def location(self, hs, labs):
        F = self.F(hs)
        A = np.array(labs)
        n = len(hs)
        S = np.ones(n + 1)
        for i, r in enumerate(self.rules):
            P = r.first_mistake_law(F, A[:, i])
            Si = np.concatenate([[1.0], 1.0 - np.cumsum(P)])
            S *= np.clip(Si, 0.0, 1.0)
        lam = S[:-1] - S[1:]
        tot = 1.0 - S[-1]
        return lam / tot if tot > 0 else lam

    def describe_mistake(self, hs, labs, k):
        """Class of the true first mistake at step k: 'rare-new' if it is a first firing of an
        undiscovered rule with 2^j > n, 'new' for other undiscovered rules, else 'known'."""
        h = hs[k]
        tru = self.m.human(h)
        cls = 'known'
        for i, r in enumerate(self.rules):
            if tru[i] != labs[k][i] and not r.disc:
                if 2 ** (self.m.J[i] + 1) > len(hs):
                    return 'rare-new'
                cls = 'new'
        return cls


# ----------------------------------------------------------------------------------------------
# SIL: the silent (hidden-insight) class
# ----------------------------------------------------------------------------------------------
class SILModel:
    name = 'SIL'

    def __init__(self, rng, T, n, q=4, eta=0.5):
        self.q, self.eta, self.n = q, eta, n
        has = rng.random(T) < eta
        self.t = np.where(has, rng.integers(0, n, T), -1)
        self.k = rng.integers(1, q + 1, T)
        self.K = float(sum(-math.log2(1 - eta) if t < 0 else -math.log2(eta / (n * q)) for t in self.t))

    def start(self, p):
        return (p, 0, 0)

    def human(self, h):
        p, j, a = h
        if a == 0 and j == self.t[p]:
            return int(self.k[p])
        return a

    def next(self, h, lab):
        p, j, a = h
        return (p, j + 1, lab)


class SILLearner:
    def __init__(self, model):
        self.m = model
        self.probed = {}
        self.ins = {}

    def decode(self, h):
        p, j, a = h
        if a != 0:
            return a
        t = self.ins.get(p)
        if t is not None and t[0] == j:
            return t[1]
        return 0

    def observe(self, h, lab):
        p, j, a = h
        if a != 0:
            return
        if lab != 0:
            self.ins[p] = (j, lab)
        else:
            self.probed.setdefault(p, set()).add(j)

    def observe_run(self, hs, labs):
        for h, lab in zip(hs, labs):
            self.observe(h, lab)

    def _pt(self, p):
        S = len(self.probed.get(p, ()))
        eta, n = self.m.eta, self.m.n
        return (eta / n) / (1.0 - eta * S / n)

    def doubts(self, hs, labs):
        mu = np.zeros(len(hs))
        for k, (h, lab) in enumerate(zip(hs, labs)):
            p, j, a = h
            if a == 0 and p not in self.ins and j not in self.probed.get(p, ()):
                mu[k] = self._pt(p)
        return mu

    def location(self, hs, labs):
        mu = self.doubts(hs, labs)
        return mu / mu.sum() if mu.sum() > 0 else mu

    def describe_mistake(self, hs, labs, k):
        return 'insight'


# ----------------------------------------------------------------------------------------------
# Runs, searches, deployment
# ----------------------------------------------------------------------------------------------
def make_run(model, learner, x0, n):
    hs, labs = [], []
    h = x0
    for _ in range(n):
        lab = learner.decode(h)
        hs.append(h)
        labs.append(lab)
        h = model.next(h, lab)
    return hs, labs


def human_chain(model, x0, n):
    labs = []
    h = x0
    for _ in range(n):
        lab = model.human(h)
        labs.append(lab)
        h = model.next(h, lab)
    return labs


def query(model, learner, h):
    ans = model.human(h)
    learner.observe(h, ans)
    return ans


def search_scan(model, learner, hs, labs, n, lam):
    for k in range(n):
        if query(model, learner, hs[k]) != labs[k]:
            return k + 1
    raise RuntimeError('scan exhausted on a rejected run')


def search_bayes(model, learner, hs, labs, n, lam):
    cnt = 0
    done = set()
    for k in rank_order(lam):
        cnt += 1
        done.add(int(k))
        if query(model, learner, hs[k]) != labs[k]:
            return cnt
    for k in range(n):                       # never reached under (A1): lambda's support holds f_P
        if k in done:
            continue
        cnt += 1
        if query(model, learner, hs[k]) != labs[k]:
            return cnt
    raise RuntimeError('bayes search exhausted')


def search_thr(model, learner, hs, labs, n, lam):
    gamma = math.log2(n) / n
    cnt = 0
    done = np.zeros(n, bool)
    while True:
        mu = learner.doubts(hs, labs)
        mu[done] = -1.0
        k = int(np.argmax(mu))
        if mu[k] < gamma:
            break
        done[k] = True
        cnt += 1
        if query(model, learner, hs[k]) != labs[k]:
            return cnt, False
    # fallback: every unqueried step now has doubt < gamma; any order of them is allowed by Theorem
    # GB2's accounting, so use the lambda order recomputed now, then any step left.
    lam2 = learner.location(hs, labs)
    rest = [int(k) for k in rank_order(lam2) if not done[k]] + [k for k in range(n) if not done[k]]
    for k in rest:
        if done[k]:
            continue
        done[k] = True
        cnt += 1
        if query(model, learner, hs[k]) != labs[k]:
            return cnt, True
    raise RuntimeError('threshold search exhausted')


def deploy(model, learner, proto, n, T, rng, max_reruns=400):
    out = dict(queries=0, rejections=0, wrong=0, fallbacks=0, rec=[])
    for p in range(T):
        x0 = model.start(p)
        chain = human_chain(model, x0, n)
        reruns = 0
        while True:
            hs, labs = make_run(model, learner, x0, n)
            if proto == 'CI':
                k = int(rng.integers(n))
                out['hits'] = out.get('hits', 0) + int(query(model, learner, hs[k]) != labs[k])
                out['queries'] += 1
                if labs != chain:
                    out['wrong'] += 1
                break
            if labs == chain:
                learner.observe_run(hs, labs)
                break
            reruns += 1
            if reruns > max_reruns:
                raise RuntimeError('too many reruns')
            out['rejections'] += 1
            lam = learner.location(hs, labs)
            mu = learner.doubts(hs, labs)
            st = lam_stats(lam)
            tru = [model.human(h) for h in hs]
            f = next(k for k in range(n) if tru[k] != labs[k])       # true first mistake (not a query)
            order = rank_order(lam)
            pos = np.nonzero(order == f)[0]
            st['rank_f'] = int(pos[0]) + 1 if pos.size else n + 1
            st['scan_f'] = f + 1
            st['suspect'] = int(np.sum(mu > 0))
            st['mistakes'] = int(sum(tru[k] != labs[k] for k in range(n)))
            st['cls'] = learner.describe_mistake(hs, labs, f)
            if proto == 'scan':
                c = search_scan(model, learner, hs, labs, n, lam)
            elif proto == 'bayes':
                c = search_bayes(model, learner, hs, labs, n, lam)
            elif proto == 'thr':
                c, fb = search_thr(model, learner, hs, labs, n, lam)
                out['fallbacks'] += int(fb)
            st['cost'] = c
            out['queries'] += c
            out['rec'].append(st)
    return out


def deploy_defer(model, learner, n, T, defer, tau_frac=0.25, qmax=5):
    """FV1 (one rule): immediate Bayesian search, or deferral of diffuse rejections."""
    out = dict(queries=0, rejections=0, deferrals=0, first_cost=None, first_deferred=0)
    queue = []
    rule = learner.rules[0]

    def process(p, forced):
        x0 = model.start(p)
        chain = human_chain(model, x0, n)
        while True:
            hs, labs = make_run(model, learner, x0, n)
            if labs == chain:
                learner.observe_run(hs, labs)
                return
            out['rejections'] += 1
            lam = learner.location(hs, labs)
            if (defer and not forced and not rule.disc and lam.max() < 1.0 / (tau_frac * n)
                    and len(queue) < qmax and all(l == (0,) for l in labs)):
                rule.add_constraint(learner.F(hs))
                queue.append(p)
                out['deferrals'] += 1
                return
            was = rule.disc
            c = search_bayes(model, learner, hs, labs, n, lam)
            out['queries'] += c
            if not was and rule.disc:
                out['first_cost'] = c
                out['first_deferred'] = len(queue)
            if queue:
                pending = list(queue)
                queue.clear()
                for p2 in pending:
                    process(p2, False)

    for p in range(T):
        process(p, False)
    while queue:
        process(queue.pop(0), True)
    return out


# ----------------------------------------------------------------------------------------------
# Experiments
# ----------------------------------------------------------------------------------------------
def summarize(name, recs):
    if not recs:
        return None
    a = {k: np.mean([r[k] for r in recs]) for k in ('cost', 'G', 'inv_max', 'h2', 'ar', 'supp', 'suspect', 'scan_f', 'rank_f', 'mistakes')}
    a['max'] = max(r['cost'] for r in recs)
    a['N'] = len(recs)
    return a


def exp_main(T, seeds, ns):
    print('== E1: location under three random-program classes (exact Bayes; chain-equality verifier, n = n0) ==')
    print('   T = %d problems per human; %d humans per row (drawn from the class prior unless marked)' % (T, len(seeds)))
    print('   Columns: rej = rejections per human; Q = task queries per human; Q/rej = mean search cost per rejection (max);')
    print('   at the same rejections, before the search: G = guessing cost of lambda, 1/maxL, 2^H, Ar = (sum sqrt lambda)^2,')
    print('   supp = |supp lambda|, susp = suspect steps (doubt > 0), f+1 = scan position of the true first mistake,')
    print('   rank = its rank in the lambda order; for CI: wrong = wrong outputs per human (CI makes T queries).')
    print('   thr bound = Theorem GB2: K (1 + 1/c + n/log2(1/gamma)), gamma = log2(n)/n, c = log2(1/(1-gamma)).')
    classes = [
        ('M1 prior', lambda r: M1Model(r), M1Learner),
        ('M1 adversarial (code never the tie-break)', lambda r: M1Model(r, adversarial=True), M1Learner),
        ('FV prior', lambda r: FVModel(r), FVLearner),
        ('FV rare-only (2^j in [4n, nT/2])', None, FVLearner),
        ('SIL (silent humans)', None, SILLearner),
    ]
    allres = {}
    for n in ns:
        for cname, mk, Lrn in classes:
            if cname.startswith('FV rare'):
                lo = int(math.log2(n)) + 2
                hi = int(math.floor(math.log2(n * T))) - 1
                mk = (lambda lo, hi: (lambda r: FVModel(r, jset=list(range(lo, hi + 1)))))(lo, hi)
            if cname.startswith('SIL'):
                mk = (lambda n: (lambda r: SILModel(r, T, n)))(n)
            print()
            print('-- %s, n = %d --' % (cname, n))
            print('   | protocol | rej | Q | Q/rej (max) | G | 1/maxL | 2^H | Ar | supp | susp | f+1 | rank | wrong (CI) | K | thr bound |')
            print('   |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|')
            for proto in ('CI', 'scan', 'bayes', 'thr'):
                Q, R, W, Ks, recs, fbs, Hs = [], [], [], [], [], [], []
                for s in seeds:
                    m = mk(np.random.default_rng(1000 * s + 17))
                    lrn = Lrn(m)
                    o = deploy(m, lrn, proto, n, T, np.random.default_rng(7 + s))
                    Q.append(o['queries']); R.append(o['rejections']); W.append(o['wrong']); Ks.append(m.K)
                    recs += o['rec']; fbs.append(o['fallbacks']); Hs.append(o.get('hits', 0))
                K = float(np.mean(Ks))
                g = math.log2(n) / n
                bound = K * (1 + 1 / math.log2(1 / (1 - g)) + n / math.log2(1 / g))
                a = summarize(proto, recs)
                allres[(cname, n, proto)] = dict(Q=np.mean(Q), R=np.mean(R), W=np.mean(W), K=K, a=a, fb=np.mean(fbs))
                if proto == 'CI':
                    print('   | CI | - | %.0f | (%.1f queries per hit) | - | - | - | - | - | - | - | - | %.1f | %.0f | - |' % (
                        np.mean(Q), np.sum(Q) / max(1, np.sum(Hs)), np.mean(W), K))
                elif a is None:
                    print('   | %s | 0 | 0 | - | - | - | - | - | - | - | - | - | 0 | %.0f | %.0f |' % (proto, K, bound))
                else:
                    print('   | %s | %.1f | %.1f | %.2f (%d) | %.2f | %.1f | %.1f | %.1f | %.1f | %.1f | %.1f | %.1f | 0 | %.0f | %s |' % (
                        proto, np.mean(R), np.mean(Q), a['cost'], a['max'], a['G'], a['inv_max'], a['h2'], a['ar'],
                        a['supp'], a['suspect'], a['scan_f'], a['rank_f'], K, ('%.0f (max Q %d; fallbacks %.1f)' % (bound, max(Q), np.mean(fbs))) if proto == 'thr' else '-'))
            sys.stdout.flush()
    return allres


def exp_classes(T, seeds, n):
    print()
    print('== E2: FV prior, n = %d: search cost per rejection by the kind of the true first mistake ==' % n)
    print('   rare-new = first firing of an undiscovered rule with 2^j > n; new = first firing of a frequent rule; known = a discovered rule')
    print('   | protocol | kind | rejections | Q/rej | G | 1/maxL | f+1 | rank |')
    print('   |---|---|---|---|---|---|---|---|')
    for proto in ('scan', 'bayes', 'thr'):
        by = {}
        for s in seeds:
            m = FVModel(np.random.default_rng(1000 * s + 17))
            o = deploy(m, FVLearner(m), proto, n, T, np.random.default_rng(7 + s))
            for r in o['rec']:
                by.setdefault(r['cls'], []).append(r)
        for cls in ('rare-new', 'new', 'known'):
            v = by.get(cls, [])
            if v:
                print('   | %s | %s | %d | %.2f | %.2f | %.1f | %.1f | %.1f |' % (proto, cls, len(v), np.mean([r['cost'] for r in v]),
                      np.mean([r['G'] for r in v]), np.mean([r['inv_max'] for r in v]), np.mean([r['scan_f'] for r in v]), np.mean([r['rank_f'] for r in v])))
    sys.stdout.flush()


def exp_defer(T, n, js, nh):
    print()
    print('== E3: one rule of fixed rarity 2^-j (FV1; learner prior uniform on j = 1..14), n = %d, T = %d, %d humans per j ==' % (n, T, nh))
    print('   fires = problems whose human chain fires the rule; first = cost of the search that discovers the rule;')
    print('   defer: a rejection with 1/max lambda > n/4 waits (<= 5 waiting), conditioned on as "the rule fires in that run".')
    print('   | j | humans | fires (mean) | protocol | Q per human | first discovery cost (mean) | when fires = 1 | when fires >= 2 | deferrals |')
    print('   |---|---|---|---|---|---|---|---|---|')
    for j in js:
        for proto in ('immediate', 'defer'):
            rows = []
            for s in range(nh):
                m = FVModel(np.random.default_rng(5000 + 31 * s + j), L=1, jset=[j])
                fires = sum(any(c != (0,) for c in human_chain(m, m.start(p), n)) for p in range(T))
                o = deploy_defer(m, FVLearner(m), n, T, proto == 'defer')
                rows.append((fires, o['queries'], o['first_cost'], o['deferrals']))
            fires = np.array([r[0] for r in rows])
            fc = [(r[0], r[2]) for r in rows if r[2] is not None]
            one = [c for f, c in fc if f == 1]
            two = [c for f, c in fc if f >= 2]
            fmt = lambda v: ('%.1f (%d)' % (np.mean(v), len(v))) if v else '-'
            print('   | %d | %d | %.1f | %s | %.1f | %s | %s | %s | %.1f |' % (
                j, nh, fires.mean(), proto, np.mean([r[1] for r in rows]), fmt([c for _, c in fc]), fmt(one), fmt(two),
                np.mean([r[3] for r in rows])))
        sys.stdout.flush()


def exp_prior_counts():
    print()
    print('== E4: how often a random decision list has rare and single-shot rules (exact binomial counts, no simulation) ==')
    print('   A rule of rarity j fires in a run of n fresh steps w.p. pi_j = 1-(1-2^-j)^n; over T problems it fires in Bin(T, pi_j) of them.')
    print('   Per rule: P(fires in exactly one problem) = single; P(fires, and 2^j > n) = rare-exercised; P(fires at all) = exercised.')
    print('   Priors on j: log-uniform = uniform on 1..d (d = 40); universal-type = P(j) proportional to 1/j^2 on 1..200.')
    print('   | prior | n | T | exercised | rare-exercised | single | single/exercised | 1/ln(nT) |')
    print('   |---|---|---|---|---|---|---|---|')
    for name, js, wts in (('log-uniform', np.arange(1, 41), np.ones(40)), ('universal-type', np.arange(1, 201), 1.0 / np.arange(1, 201) ** 2)):
        wts = wts / wts.sum()
        for n in (16, 64, 256):
            for T in (300, 3000):
                pj = 1.0 - (1.0 - 2.0 ** -js.astype(float)) ** n
                ex = 1.0 - (1.0 - pj) ** T
                single = T * pj * (1.0 - pj) ** (T - 1)
                rare = ex * (2.0 ** js > n)
                E, R, S = float(wts @ ex), float(wts @ rare), float(wts @ single)
                print('   | %s | %d | %d | %.3f | %.3f | %.4f | %.3f | %.3f |' % (name, n, T, E, R, S, S / E, 1.0 / math.log(n * T)))
    sys.stdout.flush()


if __name__ == '__main__':
    t0 = time.time()
    print('Thread GB: does genericity make mistakes cheap to locate?  (python3 -B threadGB_location.py)')
    print()
    exp_main(T=300, seeds=list(range(1, 13)), ns=(16, 64))
    exp_classes(T=300, seeds=list(range(1, 13)), n=64)
    exp_defer(T=300, n=64, js=(4, 8, 10, 12, 14), nh=24)
    exp_prior_counts()
    print()
    print('runtime %.0f s' % (time.time() - t0))
