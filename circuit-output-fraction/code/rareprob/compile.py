"""Poly-time construction of dominating envelopes from a circuit (no prover).

Every rule below is sound (it produces phi >= 1_C pointwise), so the
envelope estimator is correct on every circuit; the rules only affect how
tight phi is, i.e. the efficiency parameter K = E_D[phi] / p.

Rules, applied to the NNF of C under a partial assignment rho:
  literal                 -> literal (or 1 / 0 if its variable is in rho)
  OR(c_1..c_k)            -> SUM_j env(c_j)                     (union bound)
  AND, forced literals F  -> PROD(F, env(AND | rho+F))           (C implies F)
  AND, disjoint supports  -> PROD_j env(c_j)                     (independence)
  AND, shared variable u  -> SUM_b PROD([u=b], env(AND | rho+{u:b}))
                             (Shannon expansion; at most `shannon` per path)
  AND, otherwise          -> PROD over a greedy variable-disjoint subset of
                             the conjuncts (dropping conjuncts)
  opaque gate             -> 1
  any gate that a pilot sample finds dense (Pr >= tau)
                          -> BOX: the exact sub-function as a leaf, with
                             Monte-Carlo mass and rejection sampling
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from .circuit import Circuit
from .cnf import forced_input_literals
from .dist import Product
from .envelope import Envelope, envelope_estimate
from .nnf import NNF, to_nnf
from .stats import Estimate

FALSE = "FALSE"


@dataclass
class CompileStats:
    shannon_splits: int = 0
    dropped_conjuncts: int = 0
    forced_literals: int = 0
    budget_exhausted: bool = False


class EnvelopeCompiler:
    def __init__(self, N: NNF, D: Product, shannon: int = 4, node_budget: int = 200_000,
                 tau: float | None = None, pilot: int = 512, rng=None):
        self.tau = tau
        self.slack = 2.0
        self.pilot = pilot
        self.rng = np.random.default_rng() if rng is None else rng
        self.pilot_evals = 0
        self.N = N
        self.D = D
        self.shannon = shannon
        self.budget = node_budget
        self.E = Envelope()
        self.memo: dict = {}
        self.fmemo: dict = {}
        self.stats = CompileStats()
        self._mass: dict[int, float] = {}

    # --------------------------------------------------------------- helpers
    def _key(self, v: int, rho: dict) -> tuple:
        s = self.N.sup[v]
        return (v, tuple(sorted((i, b) for i, b in rho.items() if (s >> i) & 1)))

    def mass(self, e: int) -> float:
        m = self._mass.get(e)
        if m is not None:
            return m
        k = self.E.kind[e]
        if k == "ONE":
            m = 1.0
        elif k == "ZERO":
            m = 0.0
        elif k == "LIT":
            i, b = self.E.data[e]
            m = self.D.lit_prob(i, b)
        elif k == "BOX":
            m = self.E.boxes[self.E.data[e]].value
        elif k == "SUM":
            m = sum(self.mass(c) for c in self.E.data[e])
        else:
            m = 1.0
            for c in self.E.data[e]:
                m *= self.mass(c)
        self._mass[e] = m
        return m

    def forced(self, v: int, rho: dict):
        """Literals implied by node v under rho (syntactic), or FALSE."""
        key = self._key(v, rho)
        r = self.fmemo.get(key)
        if r is not None:
            return r
        N = self.N
        k = N.kind[v]
        if k == "T" or k == "X":
            r = frozenset()
        elif k == "F":
            r = FALSE
        elif k == "L":
            i, b = N.data[v]
            if i in rho:
                r = frozenset() if rho[i] == b else FALSE
            else:
                r = frozenset([(i, b)])
        elif k == "A":
            acc: set = set()
            r = None
            for c in N.data[v]:
                f = self.forced(c, rho)
                if f == FALSE:
                    r = FALSE
                    break
                acc |= f
            if r is None:
                vs = {}
                for i, b in acc:
                    if vs.get(i, b) != b:
                        r = FALSE
                        break
                    vs[i] = b
                if r is None:
                    r = frozenset(acc)
        else:  # OR
            r = None
            for c in N.data[v]:
                f = self.forced(c, rho)
                if f == FALSE:
                    continue
                r = f if r is None else (r & f)
            if r is None:
                r = FALSE
        self.fmemo[key] = r
        return r

    # ---------------------------------------------------------------- rules
    def env(self, v: int, rho: dict, depth: int) -> int:
        key = self._key(v, rho) + (depth if self.N.kind[v] == "A" else 0,)
        r = self.memo.get(key)
        if r is not None:
            return r
        r = self._env(v, rho, depth)
        self.memo[key] = r
        if len(self.E.kind) > self.budget:
            self.stats.budget_exhausted = True
        return r

    def _dense(self, v: int, rho: dict) -> bool:
        if self.tau is None:
            return False
        X = self.D.sample(self.pilot, self.rng)
        self.pilot_evals += self.pilot
        r = {i: b for i, b in rho.items() if (self.N.sup[v] >> i) & 1}
        self._last_pilot = float(self.N.eval_batch(X, v, r).mean())
        return self._last_pilot >= self.tau

    def _box(self, v: int, rho: dict) -> int:
        r = {i: b for i, b in rho.items() if (self.N.sup[v] >> i) & 1}
        free = self.N.sup[v] & ~sum(1 << i for i in r)
        e = self.E.box(self.N, v, r, free)
        b = self.E.boxes[self.E.data[e]]
        if b.value != b.value:  # nan: first creation, record pilot density
            b.value = self._last_pilot
        return e

    def _env(self, v: int, rho: dict, depth: int) -> int:
        k = self.N.kind[v]
        if k == "X":
            return self._box(v, rho) if self._dense(v, rho) else self.E.one()
        r = self._env_rules(v, rho, depth)
        # replace a loose rule-based envelope by an exact dense leaf
        if self.tau is not None and k in ("A", "O"):
            m = self.mass(r)
            if m >= self.slack * self.tau and self._dense(v, rho) and m > self.slack * self._last_pilot:
                return self._box(v, rho)
        return r

    def _env_rules(self, v: int, rho: dict, depth: int) -> int:
        N, E = self.N, self.E
        k = N.kind[v]
        if k == "T":
            return E.one()
        if k == "F":
            return E.zero()
        if k == "L":
            i, b = N.data[v]
            if i in rho:
                return E.one() if rho[i] == b else E.zero()
            return E.lit(i, b)
        if k == "O":
            return E.SUM([self.env(c, rho, depth) for c in N.data[v]])
        # AND
        f = self.forced(v, rho)
        if f == FALSE:
            return E.zero()
        f = [(i, b) for (i, b) in f if i not in rho]
        if f:
            self.stats.forced_literals += len(f)
            rho2 = dict(rho)
            rho2.update(f)
            return E.PROD([E.lit(i, b) for i, b in f] + [self.env(v, rho2, depth)])
        ch = [c for c in N.data[v]]
        free = ~sum(1 << i for i in rho) if rho else -1
        sups = [N.sup[c] & free for c in ch]
        # shared variables (w.r.t. NNF supports, so restriction cannot create new overlaps)
        seen = 0
        shared = 0
        for s in sups:
            shared |= seen & s
            seen |= s
        if shared == 0:
            return E.PROD([self.env(c, rho, depth) for c in ch])
        if depth < self.shannon and not self.stats.budget_exhausted:
            # branch on the shared variable occurring in the most conjuncts
            best, bestc = -1, -1
            s = shared
            while s:
                low = s & -s
                i = low.bit_length() - 1
                cnt = sum(1 for t in sups if (t >> i) & 1)
                if cnt > bestc:
                    best, bestc = i, cnt
                s ^= low
            self.stats.shannon_splits += 1
            parts = []
            for b in (0, 1):
                rho2 = dict(rho)
                rho2[best] = b
                parts.append(E.PROD([E.lit(best, b), self.env(v, rho2, depth + 1)]))
            return E.SUM(parts)
        # drop conjuncts: greedy variable-disjoint subset, most informative first
        envs = [(self.env(c, rho, depth), c) for c in ch]
        envs.sort(key=lambda t: self.mass(t[0]))
        used = 0
        keep = []
        for e, c in envs:
            se = E.sup[e]
            if se & used:
                self.stats.dropped_conjuncts += 1
                continue
            used |= se
            keep.append(e)
        return E.PROD(keep)


def compile_envelope(C: Circuit, D: Product, shannon: int = 4, use_up: bool = True,
                     node_budget: int = 200_000, tau: float | None = None, rng=None):
    """Envelope for C plus compile statistics. Returns (env, stats, rho0)
    where rho0 are the input literals forced by unit propagation/probing.
    If C is refuted (p = 0), env has root ZERO."""
    rho0: dict[int, int] = {}
    if use_up:
        r = forced_input_literals(C)
        if r is None:
            E = Envelope()
            E.root = E.zero()
            return E, CompileStats(), None
        rho0 = r
    Cr = C.restrict(rho0) if rho0 else C
    N = to_nnf(Cr)
    comp = EnvelopeCompiler(N, D, shannon=shannon, node_budget=node_budget, tau=tau, rng=rng)
    root = comp.env(N.root, dict(rho0), 0)
    E = comp.E
    E.root = E.PROD([E.lit(i, b) for i, b in rho0.items()] + [root])
    comp.stats.forced_literals += len(rho0)
    return E, comp.stats, rho0


def auto_estimate(C: Circuit, D: Product, eps: float = 0.1, delta: float = 0.05,
                  max_samples: int = 10**6, shannon: int = 4, tau: float | None = 0.05,
                  rng=None) -> Estimate:
    """Part-1 procedure: compile an envelope by sound syntactic rules, then
    run the envelope estimator. The returned interval is always valid with
    probability >= 1 - delta; it is tight when K = E[phi]/p is small."""
    E, st, rho0 = compile_envelope(C, D, shannon=shannon, tau=tau, rng=rng)
    est = envelope_estimate(C, D, E, eps=eps, delta=delta, max_samples=max_samples, rng=rng)
    est.note += f"; forced {st.forced_literals}, splits {st.shannon_splits}, dropped {st.dropped_conjuncts}"
    return est
