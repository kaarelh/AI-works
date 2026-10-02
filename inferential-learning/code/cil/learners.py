"""Learning inference rules from positive examples, plus coherence repair.

Pipeline
--------
1. :func:`prepare_training` turns human derivations into training steps,
   extracts each step's rewrite-core chain, and sets aside built-in arithmetic
   steps (checked by computation, never learned).

2. :class:`LGGLearner` (alias :data:`VersionSpaceLearner`) induces rewrite
   schemas by Plotkin anti-unification of rewrite cores:

   * cores are *bucketed* by the human's rule tag (``tagged=True``) or, when
     untagged, by the shape key ``(lhs head, lhs arity, abstracted rhs)``
     (the rhs with every maximal subterm that also occurs in the lhs replaced by
     a reference to its lhs position -- invariant across instances of one rule);
   * inside a bucket, cores are clustered by **MDL agglomeration**: merging two
     clusters replaces their schemas by their LGG, and is done iff it shortens
     the two-part code  ``|schema| + sum_members |sigma_member|``  and the LGG is
     range restricted.  A single noisy core cannot over-generalise a
     well-supported schema: generalising ``?a+0 -> ?a`` to ``?a+?b -> ?a`` costs
     one symbol per existing member;
   * guards: ``guard_mode='none'`` learns unguarded schemas (positive data never
     shows a guard); ``guard_mode='most_specific'`` takes the LGG in the guard
     lattice, i.e. the conjunction of all guard atoms entailed in *every*
     member's context (the S-boundary of the version space over
     schema x guard).

3. :class:`LearnedCalculus` holds the learned schemas and implements the
   **conservative verifier**.  Its exact acceptance criterion is:

       accept(before -> after | facts)  iff
         before == after                                  (reflexivity), or
         the step is a correct numeral evaluation          (built-in arith), or
         there is an ACTIVE learned schema S = (l -> r [G]) with support(S) >= m,
         a position p on the step's difference chain, and sigma with
         before|p = sigma(l), after|p = sigma(r), and facts |- G[sigma]
         (syntactic entailment).

   ``support(S)`` is the number of human training steps that are *members* of
   S's cluster (S is their preferred explanation) **and** satisfy S's guard in
   their own context.  Over-general schemas therefore do not inherit support
   from the steps of more specific schemas.

4. :class:`CoherenceRepairer` runs the Lakatos loop: search for **negative
   bags** (short derivations with the learned calculus that are refuted),
   assign blame, and **repair** (add the minimal guard from the guard language
   that blocks the counterexamples while keeping the most human instances --
   monster-barring / lemma-incorporation) or **delete** the schema.
   Feedback modes:

   * ``'numeral'``  pure coherence, no world: from a ground numeral probe, two
     derivations reach distinct numerals, or a derivation reaches a numeral
     different from the probe's value computed by arithmetic (``2 = 4``).
   * ``'bag'``      world feedback on derivation endpoints only (the learner
     learns that *some* step of the derivation is wrong); blame by spectrum-based
     fault localisation (Ochiai score, greedy hitting set).
   * ``'step'``     world feedback on every single step (exact credit assignment).
"""
from __future__ import annotations

import heapq
import itertools
import math
import random
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

from .rules import (Facts, Guard, RewriteRule, TRUE_GUARD, diff_chain, explanations, guard_candidates,
                    guard_satisfied, licenses)
from .terms import (App, Term, Var, is_numeral, lgg_tuples, lgg_tuples_subst, match, match_tuple, nonvar_size,
                    num, pretty, replace, subst, subterm, subterms, variables)

__all__ = [
    "TrainStep", "prepare_training", "shape_key", "mdl_cluster",
    "LearnedSchema", "LearnedCalculus", "LGGLearner", "VersionSpaceLearner",
    "CoherenceConfig", "CoherenceRepairer", "choose_guard", "ochiai_blame",
]


# ---------------------------------------------------------------------------
# Training data
# ---------------------------------------------------------------------------


@dataclass
class TrainStep:
    idx: int
    before: Term
    after: Term
    facts: Facts
    tag: str
    chain: list
    arith: bool
    deriv: int
    kind: str = ""   # hidden generation label -- for evaluation only, never read by learners

    @property
    def core(self) -> Optional[Tuple[Term, Term]]:
        if not self.chain:
            return None
        _, u, v = self.chain[0]
        return (u, v)


def prepare_training(derivations, domain) -> List[TrainStep]:
    """Flatten derivations into training steps (identity steps dropped)."""
    out: List[TrainStep] = []
    for di, d in enumerate(derivations):
        for s in d.steps:
            ch = diff_chain(s.before, s.after)
            if not ch:
                continue
            ar = s.tag == "arith" or domain.arith_step_ok(s.before, s.after)
            out.append(TrainStep(len(out), s.before, s.after, d.facts, s.tag, ch, ar, di, s.kind))
    return out


# ---------------------------------------------------------------------------
# Shape key for untagged clustering
# ---------------------------------------------------------------------------


def _first_positions(u: Term) -> Dict[Term, tuple]:
    """Map each subterm of ``u`` to its *shallowest* position (ties: leftmost)."""
    pos: Dict[Term, tuple] = {}
    for p, w in sorted(subterms(u), key=lambda pw: (len(pw[0]), pw[0])):
        if w not in pos:
            pos[w] = p
    return pos


def _abstract(v: Term, table: Dict[Term, tuple]) -> Term:
    p = table.get(v)
    if p is not None:
        return App("@" + ".".join(map(str, p)))
    if type(v) is App and v.args:
        return App(v.head, tuple(_abstract(a, table) for a in v.args))
    return v


def shape_key(u: Term, v: Term, mode: str = "abstract"):
    """Bucket key for untagged learning.

    ``mode='abstract'``: ``(head(u), arity(u), abstracted v)`` where the rhs has
    every maximal subterm that also occurs in the lhs replaced by a reference to
    its shallowest lhs position -- identical for instances of one rule except
    for accidental collisions between variable instantiations.
    ``mode='heads'``: ``(head(u), arity(u), head(v) or 'REF')`` -- coarser;
    MDL clustering then has to separate several rules inside one bucket."""
    hu = u.head if type(u) is App else "?"
    au = len(u.args) if type(u) is App else 0
    if mode == "heads":
        table = _first_positions(u)
        return (hu, au, "REF" if v in table else (v.head if type(v) is App else "?"))
    return (hu, au, _abstract(v, _first_positions(u)))


# ---------------------------------------------------------------------------
# MDL agglomerative anti-unification
# ---------------------------------------------------------------------------


def _occ(t: Term, acc: Dict[str, int]):
    if type(t) is Var:
        acc[t.name] = acc.get(t.name, 0) + 1
    elif not t.ground:
        for a in t.args:
            _occ(a, acc)


class _Cl:
    __slots__ = ("schema", "members", "M", "T", "cost", "alive", "cid")

    def __init__(self, schema, members, M, T, cost, cid):
        self.schema = schema      # (lhs, rhs)
        self.members = members    # list of core indices
        self.M = M                # total multiplicity
        self.T = T                # var -> total weighted substitution size
        self.cost = cost
        self.alive = True
        self.cid = cid


def _range_restricted(l: Term, r: Term) -> bool:
    if type(l) is Var:
        return False
    return set(variables(r)) <= set(variables(l))


def _merge(A: _Cl, B: _Cl, schema_weight: float):
    g, (thA, thB) = lgg_tuples_subst([A.schema, B.schema])
    l, r = g
    if not _range_restricted(l, r):
        return None
    T: Dict[str, float] = {}
    for X, th in ((A, thA), (B, thB)):
        for w, t in th.items():
            occ: Dict[str, int] = {}
            _occ(t, occ)
            T[w] = T.get(w, 0.0) + X.M * nonvar_size(t) + sum(c * X.T.get(v, 0.0) for v, c in occ.items())
    # vars of g not in any theta cannot happen (each var of g is keyed by a pair)
    cost = schema_weight * (l.size + r.size) + sum(T.values())
    return (l, r), T, cost


def mdl_cluster(cores: Sequence[Tuple[Term, Term]], mults: Sequence[int], schema_weight: float = 1.0,
                full_limit: int = 160, gen_support: int = 0) -> List[Tuple[Tuple[Term, Term], List[int]]]:
    """Cluster ground rewrite cores into schemas by MDL-driven agglomerative
    anti-unification.  Returns ``[(schema (l, r), member core indices)]``.

    Cost of a cluster = ``schema_weight * |l, r| + sum_members mult * |sigma|``.
    Merges are performed best-first while they decrease the total cost and the
    merged LGG is range restricted.  Buckets with more than ``full_limit``
    unique cores are first reduced by one sequential greedy pass.  If
    ``gen_support > 0`` a second stage generalises pairs of clusters that both
    have at least that many members (see :func:`_generalise_supported`)."""
    cl: List[_Cl] = []
    for i, (u, v) in enumerate(cores):
        cl.append(_Cl((u, v), [i], mults[i], {}, schema_weight * (u.size + v.size), i))

    def agglomerate(clusters: List[_Cl]) -> List[_Cl]:
        alive = {c.cid: c for c in clusters}
        nxt = max(alive) + 1 if alive else 0
        heap = []
        ids = sorted(alive)
        for a_i in range(len(ids)):
            A = alive[ids[a_i]]
            for b_i in range(a_i + 1, len(ids)):
                B = alive[ids[b_i]]
                res = _merge(A, B, schema_weight)
                if res is None:
                    continue
                d = res[2] - A.cost - B.cost
                if d < 0:
                    heapq.heappush(heap, (d, A.cid, B.cid, res))
        while heap:
            d, ia, ib, res = heapq.heappop(heap)
            if ia not in alive or ib not in alive:
                continue
            A, B = alive.pop(ia), alive.pop(ib)
            C = _Cl(res[0], A.members + B.members, A.M + B.M, res[1], res[2], nxt)
            nxt += 1
            for D in sorted(alive.values(), key=lambda c: c.cid):
                r2 = _merge(C, D, schema_weight)
                if r2 is None:
                    continue
                d2 = r2[2] - C.cost - D.cost
                if d2 < 0:
                    heapq.heappush(heap, (d2, D.cid, C.cid, r2) if D.cid < C.cid else (d2, C.cid, D.cid, r2))
            alive[C.cid] = C
        return [alive[k] for k in sorted(alive)]

    if len(cl) > full_limit:
        # one sequential greedy pass (largest multiplicity first)
        order = sorted(range(len(cl)), key=lambda i: (-cl[i].M, i))
        seq: List[_Cl] = []
        for i in order:
            c = cl[i]
            best, best_d = None, 0.0
            for j, D in enumerate(seq):
                res = _merge(D, c, schema_weight)
                if res is None:
                    continue
                d = res[2] - D.cost - c.cost
                if d < best_d:
                    best, best_d = (j, res), d
            if best is None:
                seq.append(c)
            else:
                j, res = best
                D = seq[j]
                seq[j] = _Cl(res[0], D.members + c.members, D.M + c.M, res[1], res[2], D.cid)
        cl = seq
    final = agglomerate(cl)
    if gen_support:
        final = _generalise_supported(final, gen_support, schema_weight)
    return [(c.schema, sorted(c.members)) for c in final]


def _generalise_supported(clusters: List[_Cl], k: int, schema_weight: float) -> List[_Cl]:
    """Stage 2: while two clusters that each have >= k members have a range
    restricted LGG, replace them by it (most similar pair first).  This is the
    inductive leap from two well-attested special cases to their common
    generalisation (e.g. (a*b)^2 -> a^2*b^2 and (a*b)^3 -> a^3*b^3 give
    (a*b)^n -> a^n*b^n), which plain MDL refuses once both are frequent.  The
    support requirement keeps sporadic noise from triggering it."""
    clusters = list(clusters)
    nxt = max((c.cid for c in clusters), default=0) + 1
    while True:
        best = None
        big = [c for c in clusters if c.M >= k]
        for i in range(len(big)):
            for j in range(i + 1, len(big)):
                res = _merge(big[i], big[j], schema_weight)
                if res is None:
                    continue
                d = res[2] - big[i].cost - big[j].cost
                if best is None or d < best[0]:
                    best = (d, big[i], big[j], res)
        if best is None:
            return clusters
        _, A, B, res = best
        clusters = [c for c in clusters if c is not A and c is not B]
        clusters.append(_Cl(res[0], A.members + B.members, A.M + B.M, res[1], res[2], nxt))
        nxt += 1


def _sigma_cost(schema: Tuple[Term, Term], core: Tuple[Term, Term]) -> Optional[int]:
    s = match_tuple(schema, core)
    if s is None:
        return None
    return sum(t.size for t in s.values())


# ---------------------------------------------------------------------------
# Learned calculus and the conservative verifier
# ---------------------------------------------------------------------------


@dataclass
class LearnedSchema:
    sid: int
    rule: RewriteRule
    members: List[int]
    tag: str = ""
    support: int = 0
    status: str = "active"         # 'active' | 'deleted' | 'split'
    log: List[str] = field(default_factory=list)
    parent: Optional[int] = None

    def __str__(self):
        return f"[{self.sid}|{self.tag}|n={self.support}|{self.status}] {self.rule}"


class LearnedCalculus:
    """A set of learned schemas + the conservative verifier (see module doc)."""

    def __init__(self, schemas: List[LearnedSchema], steps: List[TrainStep], domain, m: int = 2):
        self.schemas = schemas
        self.steps = steps
        self.domain = domain
        self.m = m
        self._index_version = -1
        self._version = 0
        self.refresh_support()

    # -- bookkeeping --------------------------------------------------------
    def touch(self):
        self._version += 1

    def member_ok(self, s: LearnedSchema, h: TrainStep, guard: Optional[Guard] = None) -> bool:
        g = s.rule.guard if guard is None else guard
        r = s.rule if guard is None else s.rule.with_guard(g)
        return licenses(r, h.before, h.after, h.facts, self.domain.entails, h.chain) is not None

    def refresh_support(self):
        for s in self.schemas:
            s.support = sum(1 for i in s.members if self.member_ok(s, self.steps[i]))
        self.touch()

    def active(self) -> List[LearnedSchema]:
        return [s for s in self.schemas if s.status == "active" and s.support >= self.m]

    def by_id(self, sid: int) -> LearnedSchema:
        return self.schemas[sid]

    def _ensure_index(self):
        if self._index_version == self._version:
            return
        self._active = self.active()
        self._index: Dict[str, List[LearnedSchema]] = defaultdict(list)
        for s in self._active:
            self._index[s.rule.lhs.head].append(s)
        self._index_version = self._version

    # -- verification -------------------------------------------------------
    def explain(self, before: Term, after: Term, facts: Facts = frozenset()):
        """Return the reason a step is accepted: 'refl', 'arith', or
        (schema, pos, sigma); None if rejected."""
        if before == after:
            return "refl"
        if self.domain.arith_step_ok(before, after):
            return "arith"
        self._ensure_index()
        chain = diff_chain(before, after)
        for p, u, v in chain:
            if type(u) is not App:
                continue
            for s in self._index.get(u.head, ()):
                sig = match_tuple((s.rule.lhs, s.rule.rhs), (u, v))
                if sig is not None and guard_satisfied(s.rule.guard, sig, facts, self.domain.entails):
                    return (s, p, sig)
        return None

    def accepts(self, before: Term, after: Term, facts: Facts = frozenset()) -> bool:
        return self.explain(before, after, facts) is not None

    # -- derivation ---------------------------------------------------------
    def rewrites(self, term: Term, facts: Facts = frozenset(), include_arith: bool = True):
        """All one-step rewrites licensed by active schemas (and arith):
        list of (sid or 'arith', pos, new_term, sigma)."""
        self._ensure_index()
        out = []
        for p, u in subterms(term):
            if type(u) is not App:
                continue
            for s in self._index.get(u.head, ()):
                sig = match(s.rule.lhs, u)
                if sig is None or not guard_satisfied(s.rule.guard, sig, facts, self.domain.entails):
                    continue
                out.append((s.sid, p, replace(term, p, subst(s.rule.rhs, sig)), sig))
        if include_arith:
            for p, new in self.domain.arith_rewrites(term):
                out.append(("arith", p, new, {}))
        return out

    def copy(self) -> "LearnedCalculus":
        sch = [LearnedSchema(s.sid, s.rule, list(s.members), s.tag, s.support, s.status, list(s.log), s.parent)
               for s in self.schemas]
        return LearnedCalculus(sch, self.steps, self.domain, self.m)

    def summary(self) -> List[dict]:
        return [{"sid": s.sid, "tag": s.tag, "rule": str(s.rule), "support": s.support,
                 "status": s.status, "active": s.status == "active" and s.support >= self.m,
                 "log": s.log} for s in self.schemas]


# ---------------------------------------------------------------------------
# The positive-example learner
# ---------------------------------------------------------------------------


class LGGLearner:
    """Learn rewrite schemas from positive steps by MDL-clustered anti-unification.

    Parameters
    ----------
    tagged:      bucket by the human's rule tag (True) or by :func:`shape_key` (False)
    guard_mode:  'none' or 'most_specific' (see module doc)
    m:           support threshold of the conservative verifier
    gen_support: stage-2 generalisation threshold (default max(m, 4); 0 disables)
    key_mode:    untagged bucket key, 'abstract' or 'heads' (see :func:`shape_key`)
    """

    def __init__(self, domain, tagged: bool = True, guard_mode: str = "none", m: int = 2,
                 schema_weight: float = 1.0, full_limit: int = 160, gen_support: Optional[int] = None,
                 key_mode: str = "abstract"):
        self.domain = domain
        self.gen_support = max(m, 4) if gen_support is None else gen_support
        self.key_mode = key_mode
        self.tagged = tagged
        self.guard_mode = guard_mode
        self.m = m
        self.schema_weight = schema_weight
        self.full_limit = full_limit

    def fit(self, derivations=None, steps: Optional[List[TrainStep]] = None) -> LearnedCalculus:
        if steps is None:
            steps = prepare_training(derivations, self.domain)
        # unique cores per bucket
        buckets: Dict[object, Dict[Tuple[Term, Term], List[int]]] = defaultdict(dict)
        for h in steps:
            if h.arith:
                continue
            c = h.core
            key = h.tag if self.tagged else shape_key(c[0], c[1], self.key_mode)
            buckets[key].setdefault(c, []).append(h.idx)
        schemas: List[LearnedSchema] = []
        for key in sorted(buckets, key=lambda k: str(k)):
            core_map = buckets[key]
            cores = list(core_map)
            mults = [len(core_map[c]) for c in cores]
            clusters = mdl_cluster(cores, mults, self.schema_weight, self.full_limit, self.gen_support)
            # reassignment: every core goes to its cheapest-encoding cluster
            assign: Dict[int, List[int]] = defaultdict(list)
            sch = [s for s, _ in clusters]
            sizes = [sum(mults[i] for i in mem) for _, mem in clusters]
            for ci, c in enumerate(cores):
                best = None
                for k, S in enumerate(sch):
                    cost = _sigma_cost(S, c)
                    if cost is None:
                        continue
                    cand = (cost, -sizes[k], k)
                    if best is None or cand < best:
                        best = cand
                assign[best[2]].append(ci)
            for k in sorted(assign):
                mem_cores = [cores[ci] for ci in assign[k]]
                l, r = lgg_tuples(mem_cores) if len(mem_cores) > 1 else mem_cores[0]
                if not _range_restricted(l, r):
                    l, r = sch[k]
                members = sorted(i for ci in assign[k] for i in core_map[cores[ci]])
                tag = key if self.tagged else ""
                rule = RewriteRule(l, r, TRUE_GUARD, name=f"L{len(schemas)}")
                schemas.append(LearnedSchema(len(schemas), rule, members, tag=str(tag)))
        calc = LearnedCalculus(schemas, steps, self.domain, self.m)
        if self.guard_mode == "most_specific":
            for s in schemas:
                g = self.most_specific_guard(s, steps)
                if g:
                    s.rule = s.rule.with_guard(g)
                    s.log.append(f"most-specific guard from positives: {g}")
            calc.refresh_support()
        elif self.guard_mode != "none":
            raise ValueError(self.guard_mode)
        return calc

    def most_specific_guard(self, s: LearnedSchema, steps: List[TrainStep]) -> Guard:
        """Conjunction of all guard atoms entailed in every member's context
        (for each member, the explanation with the most entailed atoms)."""
        vs = variables(s.rule.lhs)
        cand = [(p, v) for v in vs for p in self.domain.guard_preds]
        common = None
        for i in s.members:
            h = steps[i]
            best = set()
            for _, sig in explanations(s.rule, h.before, h.after, h.chain):
                ent = {(p, v) for p, v in cand if self.domain.entails(h.facts, (p, sig[v]))}
                if len(ent) > len(best):
                    best = ent
            common = best if common is None else (common & best)
            if not common:
                return TRUE_GUARD
        return Guard(common or ())


VersionSpaceLearner = LGGLearner


# ---------------------------------------------------------------------------
# Coherence / world-feedback repair (the Lakatos loop)
# ---------------------------------------------------------------------------

_STRENGTH = {"defined": 0, "nonneg": 1, "nonzero": 1, "pos": 2}


def choose_guard(rule: RewriteRule, counterexamples: Sequence[Tuple[dict, Facts]],
                 positives: Sequence[Tuple[List[dict], Facts]], preds: Sequence[str], entails,
                 max_atoms: int = 2, bags: Optional[Sequence[Sequence[Tuple[dict, Facts]]]] = None,
                 required: Sequence[int] = (), min_bag_frac: float = 0.5):
    """Minimal guard (Lakatos monster-barring).

    Candidates are conjunctions of <= ``max_atoms`` guard atoms over the lhs
    variables, added to the rule's current guard.  An instance is *blocked* if
    the guard instance is not entailed in its context.

    * Step-level evidence (``counterexamples``): the guard must block every
      refuted instance.
    * Bag-level evidence (``bags``, one list of the schema's instances per
      attributed negative bag): a bag is blocked if one of its instances is;
      the guard must block every bag in ``required`` (bags in which this schema
      is the only suspect) and at least a ``min_bag_frac`` fraction of the bags
      (otherwise the blame is better explained by splitting/deleting, or by
      another schema).

    Among admissible guards choose the one keeping the most human positive
    instances (a positive is a list of alternative explanations; kept if one of
    them satisfies the guard), then (bag mode) blocking the most bags, then the
    fewest atoms, then the weakest predicates.  Returns ``(guard, kept)`` or
    ``(None, 0)``."""
    best = None
    req = set(required)
    for g in guard_candidates(rule, preds, max_atoms):
        full = rule.guard & g
        if bags is not None:
            blocked = [any(not guard_satisfied(full, sig, F, entails) for sig, F in bag) for bag in bags]
            nblocked = sum(blocked)
            if (nblocked == 0 or nblocked < min_bag_frac * len(bags)
                    or not all(blocked[i] for i in req)):
                continue
        else:
            if not all(not guard_satisfied(full, sig, F, entails) for sig, F in counterexamples):
                continue
            nblocked = len(counterexamples)
        kept = sum(1 for sigs, F in positives if any(guard_satisfied(full, sg, F, entails) for sg in sigs))
        strength = sum(_STRENGTH.get(p, 1) for p, _ in g.atoms)
        key = (-kept, -nblocked, len(g), strength, str(g))
        if best is None or key < best[0]:
            best = (key, g, kept)
    if best is None:
        return None, 0
    return best[1], best[2]


def ochiai_blame(neg_bags: Sequence[set], pos_bags: Sequence[set], max_blame: int = 10,
                 prior: Optional[Dict[int, float]] = None) -> List[Tuple[int, List[int]]]:
    """Spectrum-based fault localisation with a greedy hitting set.

    Repeatedly blame the schema with the highest Ochiai score
    ``n_f / sqrt(N_f * (n_f + n_p))`` over the still-unexplained negative bags
    and remove the bags containing it.  Returns ``[(sid, indices of the bags
    attributed to it)]``.  Ties are broken by lower ``prior`` (e.g. support)."""
    remaining = list(range(len(neg_bags)))
    pos_count: Dict[int, int] = defaultdict(int)
    for b in pos_bags:
        for s in b:
            pos_count[s] += 1
    out = []
    while remaining and len(out) < max_blame:
        nf: Dict[int, int] = defaultdict(int)
        for i in remaining:
            for s in neg_bags[i]:
                nf[s] += 1
        if not nf:
            break
        N = len(remaining)

        def score(s):
            return nf[s] / math.sqrt(N * (nf[s] + pos_count[s]))

        s_best = max(sorted(nf), key=lambda s: (score(s), -(prior or {}).get(s, 0.0)))
        attributed = [i for i in remaining if s_best in neg_bags[i]]
        out.append((s_best, attributed))
        remaining = [i for i in remaining if s_best not in neg_bags[i]]
    return out


@dataclass
class CoherenceConfig:
    """Parameters of the Lakatos loop.

    Probes for a schema S are instances sigma(lhs_S): a *boundary basis*
    (every variable ranges over a few boundary values, all combinations up to
    ``basis_probes``) plus ``probes_per_schema`` random instances.  With
    probability ``assume_guard_prob`` a world-mode probe *assumes S's current
    guard* (adds its instance as context facts): the learner red-teams its own
    guard exactly as a white-box adversary would."""

    mode: str = "step"               # 'numeral' | 'bag' | 'step'
    rounds: int = 6
    probes_per_schema: int = 8       # random probes per schema and round
    basis_probes: int = 40           # max boundary-basis probes per schema and round
    walks_per_probe: int = 2
    max_walk: int = 4                # world modes: random walk length <= max_walk
    bag_min_walk: int = 2            # bag mode: only derivations of length >= this are judged
    max_norm_walk: int = 12          # numeral mode: normalisation walk length
    max_atoms: int = 2               # guard repair: at most this many atoms
    max_term_size: int = 40
    max_blame: int = 12
    seed: int = 0
    oracle_points: int = 12
    p_fact: float = 0.2              # probability a random world probe carries a random fact
    assume_guard_prob: float = 0.5
    allow_split: bool = True         # repair by splitting into MDL sub-clusters
    bag_guard_min_frac: float = 0.5  # bag mode: a guard must block this fraction of attributed bags


_NUM_POOL = ["0", "1", "2", "3", "-1", "-2", "1/2", "1 + 1", "2*0", "1/0"]
_WORLD_POOL = _NUM_POOL + ["x", "y", "x + 1", "x - 1", "-x", "x*y", "x - x", "1/x", "x^2", "sqrt(x)", "x/y"]
_NUM_BASIS = ["0", "1", "-1", "2", "1/0", "1/2"]
_WORLD_BASIS = ["0", "1", "-1", "2", "1/0", "x", "-x", "1/x"]
_NUM_CTX = ["[]", "[]", "[]", "2*[]", "[] + 1", "1 + []", "[]*3", "[] - 1", "[]^2", "2/[]"]
_WORLD_CTX = _NUM_CTX + ["x*[]", "[] + y", "[] - x"]


def _parse_pool(strs):
    from .terms import parse
    return [parse(s) for s in strs]


def _parse_ctx(strs):
    from .terms import parse, HOLE
    out = []
    for s in strs:
        t = parse(s.replace("[]", "HOLE_"))
        out.append(subst_const(t, "HOLE_", HOLE))
    return out


def subst_const(t: Term, name: str, by: Term) -> Term:
    if type(t) is App:
        if not t.args and t.head == name:
            return by
        return App(t.head, tuple(subst_const(a, name, by) for a in t.args))
    return t


def _inherit_guard(parent: RewriteRule, l: Term, r: Term) -> Guard:
    """Transport the parent's guard to a child schema (l, r) that is an instance
    of it: an atom p(v) becomes p(w) when the instance maps v to a variable w;
    atoms mapped to compound terms are dropped (not expressible in the guard
    language) -- the child is re-tested anyway."""
    if not parent.guard:
        return TRUE_GUARD
    th = match_tuple((parent.lhs, parent.rhs), (l, r))
    if th is None:
        return TRUE_GUARD
    atoms = []
    for p, v in parent.guard.atoms:
        t = th.get(v)
        if type(t) is Var:
            atoms.append((p, t.name))
    return Guard(atoms)


class CoherenceRepairer:
    """The Lakatos loop over a :class:`LearnedCalculus` (modified in place)."""

    def __init__(self, calc: LearnedCalculus, config: CoherenceConfig, oracle=None):
        self.calc = calc
        self.cfg = config
        self.oracle = oracle
        if config.mode in ("bag", "step") and oracle is None:
            raise ValueError("world-feedback modes need an oracle")
        self.rng = random.Random(config.seed)
        self.num_pool = _parse_pool(_NUM_POOL)
        self.world_pool = _parse_pool(_WORLD_POOL)
        self.num_basis = _parse_pool(_NUM_BASIS)
        self.world_basis = _parse_pool(_WORLD_BASIS)
        self.num_ctx = _parse_ctx(_NUM_CTX)
        self.world_ctx = _parse_ctx(_WORLD_CTX)
        self.history: List[dict] = []
        self.queries = 0
        self.suspicion: Dict[int, int] = {}

    # -- probes ---------------------------------------------------------------
    def _probes(self, s: LearnedSchema):
        """Probe list for schema ``s``: (t0, position of the redex, facts)."""
        from .terms import HOLE, plug
        numeral = self.cfg.mode == "numeral"
        vs = variables(s.rule.lhs)
        basis = self.num_basis if numeral else self.world_basis
        sigmas = []
        total = len(basis) ** len(vs)
        if total <= self.cfg.basis_probes:
            for combo in itertools.product(range(len(basis)), repeat=len(vs)):
                sigmas.append({v: basis[i] for v, i in zip(vs, combo)})
        else:
            for _ in range(self.cfg.basis_probes):
                sigmas.append({v: self.rng.choice(basis) for v in vs})
        pool = self.num_pool if numeral else self.world_pool
        for _ in range(self.cfg.probes_per_schema):
            sigmas.append({v: self.rng.choice(pool) for v in vs})
        ctxs = self.num_ctx if numeral else self.world_ctx
        out = []
        for k, sigma in enumerate(sigmas):
            redex = subst(s.rule.lhs, sigma)
            ctx = HOLE if (k < len(sigmas) - self.cfg.probes_per_schema and not numeral) else self.rng.choice(ctxs)
            t0 = plug(ctx, redex)
            pos = next(p for p, u in subterms(ctx) if u == HOLE)
            facts = frozenset()
            if not numeral:
                if s.rule.guard and self.rng.random() < self.cfg.assume_guard_prob:
                    facts = frozenset((p, sigma[v]) for p, v in s.rule.guard.atoms)
                    if self.oracle is not None and not self.oracle.satisfiable(facts):
                        continue
                elif self.rng.random() < self.cfg.p_fact:
                    facts = frozenset({(self.rng.choice(["nonneg", "nonzero", "pos"]),
                                        App(self.rng.choice(["x", "y"])))})
            out.append((t0, pos, facts))
        return out

    def _walk(self, t0: Term, facts: Facts, first: Optional[Tuple[LearnedSchema, tuple]], length: int,
              normalise: bool):
        """A derivation from t0: list of (sid|'arith', before, after, sigma)."""
        steps = []
        t = t0
        if first is not None:
            s, pos = first
            sig = match(s.rule.lhs, subterm(t, pos))
            if sig is None or not guard_satisfied(s.rule.guard, sig, facts, self.calc.domain.entails):
                return steps
            new = replace(t, pos, subst(s.rule.rhs, sig))
            steps.append((s.sid, t, new, sig))
            t = new
        while len(steps) < length:
            if normalise and self.calc.domain.is_numeral_value(t):
                break
            cands = [c for c in self.calc.rewrites(t, facts) if c[2].size <= self.cfg.max_term_size]
            if not cands:
                break
            if normalise:
                ar = [c for c in cands if c[0] == "arith"]
                if ar and self.rng.random() < 0.6:
                    c = self.rng.choice(ar)
                else:
                    ws = [4.0 if c[2].size < t.size else (1.0 if c[2].size == t.size else 0.2) for c in cands]
                    c = cands[self.rng.choices(range(len(cands)), weights=ws)[0]]
            else:
                c = self.rng.choice(cands)
            steps.append((c[0], t, c[2], c[3]))
            t = c[2]
        return steps

    # -- one round of search --------------------------------------------------
    def search(self):
        """Returns (neg_bags, pos_bags, step_counterexamples).

        A bag is a list of (sid, sigma, facts) schema instances (arith steps are
        trusted and omitted).  ``step_counterexamples`` maps sid -> list of
        (sigma, facts) individually refuted instances (step mode only)."""
        cfg = self.cfg
        neg, pos, cex = [], [], defaultdict(list)
        active = sorted(self.calc.active(), key=lambda s: s.sid)
        dom = self.calc.domain
        for s in active:
            for t0, p0, facts in self._probes(s):
                if cfg.mode == "numeral":
                    walks = [self._walk(t0, facts, (s, p0), cfg.max_norm_walk, True)]
                    for _ in range(cfg.walks_per_probe - 1):
                        walks.append(self._walk(t0, facts, None, cfg.max_norm_walk, True))
                    q0 = dom.numeral_value(t0)
                    ends = []
                    for w in walks:
                        if w and dom.is_numeral_value(w[-1][2]):
                            ends.append((w[-1][2], w))
                    inst = lambda w: [(sid, sig, facts) for sid, _, _, sig in w if sid != "arith"]
                    from fractions import Fraction
                    if isinstance(q0, Fraction):
                        q0t = dom.numeral_value(t0)
                        for end, w in ends:
                            b = inst(w)
                            if not b:
                                continue
                            if dom.numeral_value(end) != q0t:
                                neg.append(b)
                            else:
                                pos.append(b)
                    else:
                        vals = {}
                        for end, w in ends:
                            vals.setdefault(end, []).append(w)
                        if len(vals) >= 2:
                            b = [x for _, w in ends for x in inst(w)]
                            if b:
                                neg.append(b)
                        else:
                            for end, w in ends:
                                if inst(w):
                                    pos.append(inst(w))
                else:
                    for k in range(cfg.walks_per_probe):
                        lo = cfg.bag_min_walk if cfg.mode == "bag" else 1
                        L = self.rng.randint(lo, max(lo, cfg.max_walk))
                        w = self._walk(t0, facts, (s, p0) if k == 0 else None, L, False)
                        if len(w) < lo:
                            continue
                        b = [(sid, sig, facts) for sid, _, _, sig in w if sid != "arith"]
                        if not b:
                            continue
                        if cfg.mode == "bag":
                            self.queries += 1
                            bad = self.oracle.counterexample(t0, w[-1][2], facts, cfg.oracle_points) is not None
                            (neg if bad else pos).append(b)
                        else:  # step-level feedback
                            any_bad = False
                            for sid, bef, aft, sig in w:
                                if sid == "arith":
                                    continue
                                self.queries += 1
                                if self.oracle.counterexample(bef, aft, facts, cfg.oracle_points) is not None:
                                    cex[sid].append((sig, facts))
                                    any_bad = True
                            (neg if any_bad else pos).append(b)
        return neg, pos, cex

    # -- repair ---------------------------------------------------------------
    def _positives(self, s: LearnedSchema):
        out = []
        for i in s.members:
            h = self.calc.steps[i]
            sigs = [sig for _, sig in explanations(s.rule.with_guard(TRUE_GUARD), h.before, h.after, h.chain)]
            out.append((sigs, h.facts))
        return out

    def _repair(self, s: LearnedSchema, counterexamples=None, bags=None, round_no=0, evidence="",
                destructive_ok: bool = True, required: Sequence[int] = ()):
        """Repair hierarchy for a refuted schema:

        1. GUARD (monster-barring): the minimal guard blocking every
           counterexample (or one instance per attributed bag), accepted if it
           still keeps >= m human instances;
        2. SPLIT (undo an inductive leap): if MDL clustering of the schema's
           member cores (without stage-2 generalisation) yields >= 2 clusters,
           replace the schema by them -- each child is tested again next round;
        3. DELETE otherwise."""
        dom = self.calc.domain
        g, kept = choose_guard(s.rule, counterexamples or [], self._positives(s), dom.guard_preds, dom.entails,
                               self.cfg.max_atoms, bags=bags, required=required,
                               min_bag_frac=self.cfg.bag_guard_min_frac)
        if g is not None and kept >= self.calc.m:
            old = s.rule.guard
            s.rule = s.rule.with_guard(old & g)
            s.log.append(f"round {round_no}: REPAIRED with guard {g} ({evidence}; keeps {kept}/{len(s.members)} human instances)")
            return "repaired", str(g)
        if not destructive_ok:
            s.log.append(f"round {round_no}: SUSPECTED ({evidence}; no acceptable guard; action deferred)")
            return "deferred", None
        children = self._split(s) if self.cfg.allow_split else None
        if children:
            s.status = "split"
            s.log.append(f"round {round_no}: SPLIT into {[c.sid for c in children]} ({evidence})")
            return "split", None
        s.status = "deleted"
        why = "no guard blocks the counterexamples" if g is None else f"best guard {g} keeps only {kept}"
        s.log.append(f"round {round_no}: DELETED ({evidence}; {why})")
        return "deleted", None

    def _split(self, s: LearnedSchema) -> Optional[List[LearnedSchema]]:
        core_map: Dict[Tuple[Term, Term], List[int]] = {}
        for i in s.members:
            core_map.setdefault(self.calc.steps[i].core, []).append(i)
        cores = list(core_map)
        if len(cores) < 2:
            return None
        parts = mdl_cluster(cores, [len(core_map[c]) for c in cores], gen_support=0)
        if len(parts) < 2:
            return None
        children = []
        for (l, r), mem in parts:
            sid = len(self.calc.schemas)
            members = sorted(i for ci in mem for i in core_map[cores[ci]])
            rule = RewriteRule(l, r, _inherit_guard(s.rule, l, r), name=f"L{sid}")
            ch = LearnedSchema(sid, rule, members, tag=s.tag, parent=s.sid,
                               log=[f"split from L{s.sid}"])
            self.calc.schemas.append(ch)
            children.append(ch)
        return children

    def run(self) -> List[dict]:
        cfg = self.cfg
        for rnd in range(cfg.rounds):
            q_before = self.queries
            neg, pos, cex = self.search()
            actions = []
            if cfg.mode == "step":
                for sid in sorted(cex):
                    s = self.calc.by_id(sid)
                    if s.status != "active":
                        continue
                    a, g = self._repair(s, counterexamples=cex[sid], round_no=rnd,
                                        evidence=f"{len(cex[sid])} refuted instances")
                    actions.append({"sid": sid, "action": a, "guard": g, "n_cex": len(cex[sid])})
            else:
                neg_sets = [set(sid for sid, _, _ in b) for b in neg]
                pos_sets = [set(sid for sid, _, _ in b) for b in pos]
                prior = {s.sid: float(s.support) for s in self.calc.schemas}
                certain = {next(iter(b)) for b in neg_sets if len(b) == 1}
                for sid, attributed in ochiai_blame(neg_sets, pos_sets, cfg.max_blame, prior):
                    s = self.calc.by_id(sid)
                    if s.status != "active":
                        continue
                    self.suspicion[sid] = self.suspicion.get(sid, 0) + 1
                    # destructive repairs (split / delete) need certain guilt (the schema
                    # alone explains a negative bag) or blame in two different rounds
                    ok = sid in certain or self.suspicion[sid] >= 2
                    bags = [[(sig, F) for sd, sig, F in neg[i] if sd == sid] for i in attributed]
                    req = [k for k, i in enumerate(attributed) if len(neg_sets[i]) == 1]
                    a, g = self._repair(s, bags=bags, round_no=rnd, destructive_ok=ok, required=req,
                                        evidence=f"blamed for {len(attributed)} negative bags"
                                                 + (", certain" if sid in certain else ""))
                    actions.append({"sid": sid, "action": a, "guard": g, "n_bags": len(attributed)})
            self.calc.refresh_support()
            self.history.append({"round": rnd, "neg_bags": len(neg), "pos_bags": len(pos),
                                 "queries": self.queries - q_before, "actions": actions})
            if not neg:
                break
        return self.history
