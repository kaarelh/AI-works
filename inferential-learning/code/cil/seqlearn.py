"""Learning sequent-calculus (natural deduction) rules from positive examples,
plus coherence pruning, sparse world feedback, and the 'bold' learner.

Pipeline (propositional domain, :mod:`cil.domains.prop`)
--------------------------------------------------------
1. :func:`prepare_training` normalises every human step to a *core*: with
   Gamma := the intersection of all contexts of the step, each sequent becomes
   ``seq(ctx(extra assumptions), succedent)`` and the step the term
   ``step(seq_1, ..., seq_k, seq_conclusion)``.  Gamma itself is abstracted away
   (it is the shared context metavariable of every rule); whether a formula of
   the step is a member of Gamma is remembered for guard learning.

2. :class:`SeqLearner` anti-unifies cores (Plotkin LGG with one variable table)
   inside buckets.  Buckets: the human's rule tag (``key_mode='tag'``), a
   tag-free *shared-subterm abstraction* of the core (``'abstract'``), or only
   the premise count and extra-assumption arities (``'coarse'``).  Inside a
   bucket, ``cluster='mdl'`` uses the MDL agglomerative clustering of
   :func:`cil.learners.mdl_cluster` (optionally with stage-2 generalisation of
   well supported clusters, ``gen_support``), ``cluster='lgg'`` takes the plain
   LGG of the whole bucket (Plotkin's learner).  Different numbers of extra
   assumptions anti-unify to a *set metavariable*.  Guards
   (``guard_mode='most_specific'``): the conjunction of all ``mem t`` atoms
   (``t`` a formula pattern of the rule) that hold in at least ``1 - guard_tol``
   of the members (the S-boundary of the version space, made noise tolerant).

3. :class:`LearnedSeqCalculus` is the conservative verifier: a step is accepted
   iff it is an instance (premises in any order) of an ACTIVE learned rule with
   support >= m (members that satisfy the rule's guard).

4. :class:`CoherencePruner`: search for derivations of bottom from designated
   coherent contexts (the empty context, and contingent premise sets certified
   satisfiable by the environment).  Two search modes: *blind* backward search
   for ``Gamma_d |- bot``, and *Post probes*: instantiate a rule's metavariables
   with the closed basis {bot, ~bot}, prove its premises with the current
   calculus, and try to refute the instantiated conclusion (the constructive
   content of Post-completeness).  Each derivation is a *negative bag*.  Bags
   are diversified by re-searching with each bag member blocked.  Blame: minimum
   weight hitting set with weight = support (prefer removing rarely supported
   rules), or, with sparse world feedback, exact step-level blame (a step is
   refuted at an observed valuation).  Repair: minimal ``mem`` guard that blocks
   the incriminated instances and keeps >= m human members (monster-barring),
   else split the cluster by MDL (undo an inductive leap), else delete.

5. :class:`BoldLearner`: adds candidate schemas as long as the calculus stays
   coherent (Post-completeness experiment).
"""
from __future__ import annotations

import itertools
import math
import random
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

from .domains.prop import (BOT, EMPTY_CTX, TOP, TRUE_GUARD, MemGuard, PStep, ProofNode, Prover, PropWorld, Seq,
                           SeqRule, ctx_term, designated_contexts, fkey, licenses, match_step, neg)
from .learners import mdl_cluster
from .terms import App, Term, Var, lgg_tuples, match, match_tuple, subst, subterms, variables

__all__ = [
    "SeqTrainStep", "normalize_step", "prepare_training", "bucket_key", "LearnedRule", "LearnedSeqCalculus",
    "SeqLearner", "PruneConfig", "CoherencePruner", "BoldLearner", "coherence_search", "post_probes",
    "min_weight_hitting_set", "proof_instances",
]

OK = App("ok")


# ---------------------------------------------------------------------------
# Training data
# ---------------------------------------------------------------------------


@dataclass
class SeqTrainStep:
    idx: int
    prems: Tuple[Seq, ...]
    concl: Seq
    base: FrozenSet[Term]
    core: Term
    tag: str
    deriv: int
    kind: str = ""    # hidden generation label -- for evaluation only


def normalize_step(prems: Sequence[Seq], concl: Seq) -> Tuple[FrozenSet[Term], Term]:
    """(Gamma, core) with Gamma = intersection of all contexts."""
    seqs = list(prems) + [concl]
    base = seqs[0].ctx
    for s in seqs[1:]:
        base = base & s.ctx
    core = App("step", tuple(App("seq", (ctx_term(s.ctx - base), s.succ)) for s in seqs))
    return base, core


def prepare_training(derivations) -> List[SeqTrainStep]:
    out: List[SeqTrainStep] = []
    for di, d in enumerate(derivations):
        for st in d.steps:
            base, core = normalize_step(st.prems, st.concl)
            out.append(SeqTrainStep(len(out), tuple(st.prems), st.concl, base, core, st.tag, di, st.kind))
    return out


# ---------------------------------------------------------------------------
# Untagged bucket keys
# ---------------------------------------------------------------------------


def _slots(core: Term) -> List[Term]:
    out = []
    for s in core.args:
        out.extend(s.args[0].args)
        out.append(s.args[1])
    return out


def _abstract_core(core: Term) -> Term:
    """Shared-subterm abstraction: every maximal subterm that occurs in two
    different formula slots of the step becomes a reference (numbered by first
    occurrence); unshared subterms that contain no shared subterm become '*'.
    Instances of one rule get the same key (up to accidental collisions)."""
    slots = _slots(core)
    occ: Dict[Term, set] = defaultdict(set)
    for i, f in enumerate(slots):
        for _, u in subterms(f):
            occ[u].add(i)
    shared = {u for u, ix in occ.items() if len(ix) >= 2 and u != BOT}
    refs: Dict[Term, App] = {}
    contains = {}

    def has_shared(u):
        r = contains.get(u)
        if r is None:
            r = u in shared or (type(u) is App and any(has_shared(a) for a in u.args))
            contains[u] = r
        return r

    def ab(u):
        if u in shared:
            if u not in refs:
                refs[u] = App(f"#{len(refs)}")
            return refs[u]
        if u == BOT:
            return u
        if not has_shared(u):
            return App("*")
        return App(u.head, tuple(ab(a) for a in u.args))

    seqs = []
    for s in core.args:
        seqs.append(App("seq", (App("ctx", tuple(ab(f) for f in s.args[0].args)), ab(s.args[1]))))
    return App("step", tuple(seqs))


def bucket_key(h: SeqTrainStep, mode: str):
    if mode == "tag":
        return ("tag", h.tag)
    if mode == "abstract":
        return ("abs", _abstract_core(h.core))
    if mode == "coarse":
        return ("coarse", len(h.prems), tuple(len(s.args[0].args) for s in h.core.args))
    raise ValueError(mode)


# ---------------------------------------------------------------------------
# Learned calculus / conservative verifier
# ---------------------------------------------------------------------------


@dataclass
class LearnedRule:
    sid: int
    rule: SeqRule
    members: List[int]
    tag: str = ""
    support: int = 0
    status: str = "active"          # 'active' | 'deleted' | 'split'
    log: List[str] = field(default_factory=list)
    parent: Optional[int] = None

    def __str__(self):
        return f"[{self.sid}|{self.tag}|n={self.support}|{self.status}] {self.rule}"


class LearnedSeqCalculus:
    def __init__(self, rules: List[LearnedRule], steps: List[SeqTrainStep], m: int = 2):
        self.rules = rules
        self.steps = steps
        self.m = m
        self._version = 0
        self._idx_version = -1
        self.refresh_support()

    def member_ok(self, lr: LearnedRule, h: SeqTrainStep, rule: Optional[SeqRule] = None) -> bool:
        return match_step(rule or lr.rule, h.prems, h.concl) is not None

    def refresh_support(self):
        for lr in self.rules:
            lr.support = sum(1 for i in lr.members if self.member_ok(lr, self.steps[i]))
        self._version += 1

    def active(self) -> List[LearnedRule]:
        return [lr for lr in self.rules if lr.status == "active" and lr.support >= self.m]

    def by_id(self, sid: int) -> LearnedRule:
        return self.rules[sid]

    def _index(self):
        if self._idx_version != self._version:
            self._idx: Dict[Tuple[int, object], List[LearnedRule]] = defaultdict(list)
            for lr in self.active():
                c = lr.rule.concl[1]
                self._idx[(lr.rule.n_prems, c.head if type(c) is App else None)].append(lr)
            self._idx_version = self._version
        return self._idx

    def explain(self, prems: Sequence[Seq], concl: Seq):
        """(learned rule, sigma) licensing the step, or None."""
        idx = self._index()
        n = len(prems)
        for key in ((n, concl.succ.head), (n, None)):
            for lr in idx.get(key, ()):
                s = licenses(lr.rule, prems, concl)
                if s is not None:
                    return lr, s
        return None

    def accepts(self, prems: Sequence[Seq], concl: Seq) -> bool:
        return self.explain(prems, concl) is not None

    def rule_list(self, exclude: Iterable[int] = ()) -> List[Tuple[int, SeqRule]]:
        ex = set(exclude)
        return [(lr.sid, lr.rule) for lr in sorted(self.active(), key=lambda r: r.sid) if lr.sid not in ex]

    def prover(self, budget: int = 3000, max_depth: int = 12, exclude: Iterable[int] = ()) -> Prover:
        return Prover(self.rule_list(exclude), budget=budget, max_depth=max_depth)

    def signature(self):
        return frozenset(lr.rule.key() for lr in self.active())

    def copy(self) -> "LearnedSeqCalculus":
        rs = [LearnedRule(lr.sid, lr.rule, list(lr.members), lr.tag, lr.support, lr.status, list(lr.log), lr.parent)
              for lr in self.rules]
        c = LearnedSeqCalculus.__new__(LearnedSeqCalculus)
        c.rules, c.steps, c.m = rs, self.steps, self.m
        c._version, c._idx_version = 0, -1
        return c

    def summary(self) -> List[dict]:
        return [{"sid": lr.sid, "tag": lr.tag, "rule": str(lr.rule), "support": lr.support, "status": lr.status,
                 "active": lr.status == "active" and lr.support >= self.m, "log": lr.log} for lr in self.rules]


# ---------------------------------------------------------------------------
# The positive-example learner
# ---------------------------------------------------------------------------


def _sigma_cost(schema: Term, core: Term) -> Optional[int]:
    s = match(schema, core)
    if s is None:
        return None
    return sum(t.size for t in s.values())


class SeqLearner:
    """Learn sequent rules from positive steps (see module docstring).

    MDL clustering is over distinct cores (types) unless ``weigh_tokens``: with
    token weights, a core that humans repeat often (e.g. the assumption step
    for the atom q) is never merged with others, leaving ground rules that the
    guard language cannot restrict.  Support (the activation threshold m)
    always counts tokens."""

    def __init__(self, key_mode: str = "tag", cluster: str = "mdl", gen_support: int = 0,
                 guard_mode: str = "most_specific", guard_tol: float = 0.1, m: int = 2,
                 schema_weight: float = 1.0, full_limit: int = 160, weigh_tokens: bool = False):
        self.weigh_tokens = weigh_tokens
        self.key_mode = key_mode
        self.cluster = cluster
        self.gen_support = gen_support
        self.guard_mode = guard_mode
        self.guard_tol = guard_tol
        self.m = m
        self.schema_weight = schema_weight
        self.full_limit = full_limit

    def _clusters(self, cores: List[Term], mults: List[int]) -> List[Tuple[Term, List[int]]]:
        if self.cluster == "lgg":
            by_ar: Dict[int, List[int]] = defaultdict(list)
            for i, c in enumerate(cores):
                by_ar[len(c.args)].append(i)
            out = []
            for ar in sorted(by_ar):
                ix = by_ar[ar]
                g = lgg_tuples([(cores[i],) for i in ix])[0] if len(ix) > 1 else cores[ix[0]]
                out.append((g, ix))
            return out
        res = mdl_cluster([(c, OK) for c in cores], mults, self.schema_weight, self.full_limit, self.gen_support)
        sch = [l for (l, _), _ in res]
        sizes = [sum(mults[i] for i in mem) for _, mem in res]
        assign: Dict[int, List[int]] = defaultdict(list)
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
        out = []
        for k in sorted(assign):
            mem = assign[k]
            g = lgg_tuples([(cores[i],) for i in mem])[0] if len(mem) > 1 else cores[mem[0]]
            out.append((g, mem))
        return out

    def fit(self, derivations=None, steps: Optional[List[SeqTrainStep]] = None) -> LearnedSeqCalculus:
        if steps is None:
            steps = prepare_training(derivations)
        buckets: Dict[object, Dict[Term, List[int]]] = defaultdict(dict)
        for h in steps:
            buckets[bucket_key(h, self.key_mode)].setdefault(h.core, []).append(h.idx)
        rules: List[LearnedRule] = []
        for key in sorted(buckets, key=lambda k: str(k)):
            core_map = buckets[key]
            cores = list(core_map)
            mults = [len(core_map[c]) if self.weigh_tokens else 1 for c in cores]
            for schema, mem in self._clusters(cores, mults):
                members = sorted(i for ci in mem for i in core_map[cores[ci]])
                rule = SeqRule.from_term(schema, TRUE_GUARD, name=f"L{len(rules)}")
                tag = key[1] if key[0] == "tag" else ""
                lr = LearnedRule(len(rules), rule, members, tag=str(tag))
                if self.guard_mode == "most_specific":
                    g = self.most_specific_guard(rule, members, steps)
                    if g:
                        lr.rule = rule.with_guard(g)
                        lr.log.append(f"most-specific guard from positives: {g}")
                elif self.guard_mode != "none":
                    raise ValueError(self.guard_mode)
                rules.append(lr)
        return LearnedSeqCalculus(rules, steps, self.m)

    def most_specific_guard(self, rule: SeqRule, members: Sequence[int], steps: List[SeqTrainStep]) -> MemGuard:
        cands = rule.guard_candidates()
        if not cands or not members:
            return TRUE_GUARD
        cnt: Counter = Counter()
        n = 0
        for i in members:
            h = steps[i]
            s = match_step(rule, h.prems, h.concl, check_guard=False)
            if s is None:
                continue
            n += 1
            for p in cands:
                t = subst(p, s)
                if t.ground and t in h.base:
                    cnt[p] += 1
        if n == 0:
            return TRUE_GUARD
        keep = [p for p in cands if cnt[p] >= (1.0 - self.guard_tol) * n]
        # drop atoms implied by others: mem t is redundant if t is also required?  (no
        # implication between distinct memberships) -- keep all
        return MemGuard(keep)


# ---------------------------------------------------------------------------
# Coherence search (shared by the pruner and the bold learner)
# ---------------------------------------------------------------------------


def post_probes(rule: SeqRule, rng: random.Random, max_probes: int = 8, basis=(BOT, TOP)) -> List[dict]:
    """Instantiations of the rule's formula metavariables by the closed basis
    {bot, ~bot} (all combinations if few, else a random sample that always
    contains all-bot and all-top); set metavariables become empty."""
    fv = rule.formula_vars()
    combos = list(itertools.product(range(len(basis)), repeat=len(fv)))
    if len(combos) > max_probes:
        keep = {combos[0], combos[-1]}
        rest = [c for c in combos if c not in keep]
        rng.shuffle(rest)
        combos = sorted(keep) + rest[:max_probes - 2]
    out = []
    for c in combos:
        s = {v: basis[i] for v, i in zip(fv, c)}
        for v in rule.set_vars():
            s[v] = EMPTY_CTX
        out.append(s)
    return out


def _inst_seq(e, a, sigma, G) -> Seq:
    E = sigma[e.name].args if type(e) is Var else tuple(subst(f, sigma) for f in e.args)
    return Seq(G | set(E), subst(a, sigma))


def run_probe(prover: Prover, rid, rule: SeqRule, sigma: dict, budget: int) -> Optional[ProofNode]:
    """Prove the instantiated premises, then try to derive |- bot using the
    instantiated conclusion (added as a lemma).  The rule's guard is *assumed*:
    its instance is put into the context of the probe."""
    G = frozenset(subst(p, sigma) for p in rule.guard.pats)
    proofs = []
    for e, a in rule.prems:
        p = _inst_seq(e, a, sigma, G)
        r = prover.prove(p, budget=budget)
        if r is None:
            return None
        proofs.append(r)
    concl = _inst_seq(rule.concl[0], rule.concl[1], sigma, G)
    if concl not in prover.success:
        prover.add_lemma(ProofNode(concl, rid, proofs, sigma))
    return prover.prove(Seq((), BOT), extra_pool=list(concl.ctx) + [concl.succ], budget=budget)


def coherence_search(rules: List[Tuple[object, SeqRule]], focus: Sequence[object], designated: Sequence[FrozenSet],
                     rng: random.Random, probe_budget: int = 300, blind_budget: int = 1500, max_depth: int = 10,
                     max_probes: int = 8, stop_first: bool = False, prover: Optional[Prover] = None):
    """Search for derivations of bottom.  Returns ``(bags, prover)`` where bags is a
    list of ``(ProofNode, source)``; source is ``('probe', rid, sigma)`` or
    ``('blind', Gamma)``."""
    pr = prover or Prover(rules, budget=blind_budget, max_depth=max_depth)
    rmap = dict(rules)
    bags = []
    for rid in focus:
        rule = rmap[rid]
        for sigma in post_probes(rule, rng, max_probes):
            node = run_probe(pr, rid, rule, sigma, probe_budget)
            if node is not None:
                bags.append((node, ("probe", rid, sigma)))
                break
        if stop_first and bags:
            return bags, pr
    for G in designated:
        node = pr.prove(Seq(G, BOT), budget=blind_budget)
        if node is not None:
            bags.append((node, ("blind", G)))
            if stop_first:
                return bags, pr
    return bags, pr


def rerun_source(rules: List[Tuple[object, SeqRule]], source, probe_budget: int, blind_budget: int,
                 max_depth: int) -> Optional[ProofNode]:
    pr = Prover(rules, budget=blind_budget, max_depth=max_depth)
    if source[0] == "probe":
        rmap = dict(rules)
        if source[1] not in rmap:
            return None
        return run_probe(pr, source[1], rmap[source[1]], source[2], probe_budget)
    return pr.prove(Seq(source[1], BOT), budget=blind_budget)


def proof_instances(node: ProofNode) -> List[Tuple[object, dict, FrozenSet[Term], Tuple[Seq, ...], Seq]]:
    """Distinct rule instances of a derivation: (rid, sigma, Gamma, premises, conclusion)."""
    out, seen = [], set()
    stack = [node]
    while stack:
        n = stack.pop()
        prems = tuple(c.seq for c in n.children)
        key = (n.rid, prems, n.seq)
        if key not in seen:
            seen.add(key)
            base = n.seq.ctx
            for p in prems:
                base = base & p.ctx
            out.append((n.rid, n.sigma or {}, base, prems, n.seq))
        stack.extend(n.children)
    return out


def min_weight_hitting_set(bags: Sequence[set], weight: Dict[object, float], max_size: int = 3) -> List:
    """Exact minimum-weight hitting set among sets of size <= max_size (ties:
    fewer elements, then smaller ids), greedy beyond."""
    elems = sorted({e for b in bags for e in b}, key=str)
    best = None
    for k in range(1, max_size + 1):
        for combo in itertools.combinations(elems, k):
            cs = set(combo)
            if all(b & cs for b in bags):
                key = (sum(weight.get(e, 1.0) for e in combo), k, [str(e) for e in combo])
                if best is None or key < best[0]:
                    best = (key, list(combo))
    if best is not None:
        return best[1]
    remaining = [set(b) for b in bags]
    chosen = []
    while remaining:
        cnt = Counter(e for b in remaining for e in b)
        e = min(cnt, key=lambda x: (weight.get(x, 1.0) / cnt[x], str(x)))
        chosen.append(e)
        remaining = [b for b in remaining if e not in b]
    return chosen


# ---------------------------------------------------------------------------
# Coherence pruning (+ sparse world feedback)
# ---------------------------------------------------------------------------


@dataclass
class PruneConfig:
    """Parameters of coherence pruning.

    designated   coherent contexts certified by the environment (default: the empty
                 context plus ``n_designated`` satisfiable contingent sets)
    use_world    sparse world feedback on ``n_world`` observed valuations"""

    use_world: bool = False
    n_world: int = 2
    n_designated: int = 4
    designated: Optional[List[FrozenSet[Term]]] = None
    rounds: int = 8
    blind_budget: int = 1500
    probe_budget: int = 300
    max_depth: int = 10
    max_probes: int = 8
    diversify: int = 4
    max_bags: int = 6
    max_atoms: int = 2
    allow_split: bool = True
    world_probes: int = 8
    seed: int = 0


class CoherencePruner:
    """Coherence (and optional sparse world feedback) driven repair of a
    :class:`LearnedSeqCalculus` (modified in place)."""

    def __init__(self, calc: LearnedSeqCalculus, cfg: PruneConfig, learner: Optional[SeqLearner] = None):
        self.calc = calc
        self.cfg = cfg
        self.learner = learner
        self.rng = random.Random(cfg.seed)
        self.designated = cfg.designated if cfg.designated is not None else designated_contexts(
            cfg.n_designated, seed=10007 + cfg.seed)
        self.world = PropWorld(cfg.n_world, seed=20011 + cfg.seed) if cfg.use_world else None
        self.history: List[dict] = []
        self.probed_ok: set = set()
        self.world_ok: set = set()
        self.search_nodes = 0
        self.examples: List[dict] = []

    @property
    def queries(self) -> int:
        return self.world.queries if self.world else 0

    # -- world probes -----------------------------------------------------------
    def _world_probes(self, lr: LearnedRule) -> List[Tuple[dict, FrozenSet, Tuple[Seq, ...], Seq]]:
        """Instantiate metavariables with literals over one atom (not mentioned by
        the rule) and ask the world whether the instance step is refuted at an
        observed valuation.  Returns the refuted instances."""
        rule = lr.rule
        a = next(x for x in self.world.atoms[::-1] if x not in rule.constants())
        lits = [App(a), neg(App(a))]
        fv = rule.formula_vars()
        combos = list(itertools.product(range(2), repeat=len(fv)))
        if len(combos) > self.cfg.world_probes:
            keep = {combos[0], combos[-1]}
            rest = [c for c in combos if c not in keep]
            self.rng.shuffle(rest)
            combos = sorted(keep) + rest[:self.cfg.world_probes - 2]
        out = []
        for c in combos:
            s = {v: lits[i] for v, i in zip(fv, c)}
            for v in rule.set_vars():
                s[v] = EMPTY_CTX
            G = frozenset(subst(p, s) for p in rule.guard.pats)
            prems = tuple(_inst_seq(e, x, s, G) for e, x in rule.prems)
            concl = _inst_seq(rule.concl[0], rule.concl[1], s, G)
            if self.world.step_refuted(prems, concl) is not None:
                out.append((s, G, prems, concl))
        return out

    # -- one round ---------------------------------------------------------------
    def _search(self):
        cfg = self.cfg
        rules = self.calc.rule_list()
        focus = [sid for sid, r in rules if r.key() not in self.probed_ok]
        bags, pr = coherence_search(rules, focus, self.designated, self.rng, cfg.probe_budget, cfg.blind_budget,
                                    cfg.max_depth, cfg.max_probes)
        self.search_nodes += pr.total_nodes
        found_rules = {src[1] for _, src in bags if src[0] == "probe"}
        for sid, r in rules:
            if sid in focus and sid not in found_rules:
                self.probed_ok.add(r.key())
        # diversification: re-search each source with one bag member blocked
        out = list(bags[:cfg.max_bags])
        for node, src in bags[:cfg.max_bags]:
            used = sorted({rid for rid, *_ in proof_instances(node)},
                          key=lambda s: (self.calc.by_id(s).support, s))
            for rid in used[:cfg.diversify]:
                if src[0] == "probe" and rid == src[1]:
                    continue
                n2 = rerun_source([x for x in rules if x[0] != rid], src, cfg.probe_budget, cfg.blind_budget,
                                  cfg.max_depth)
                if n2 is not None:
                    out.append((n2, src))
        return out

    def _choose_guard(self, lr: LearnedRule, bad: Sequence[Tuple[dict, FrozenSet]]) -> Tuple[Optional[MemGuard], int]:
        """Minimal mem-guard blocking every incriminated instance, keeping the most
        human members (ties: fewer atoms)."""
        atoms = [p for p in lr.rule.guard_candidates() if p not in lr.rule.guard.pats]
        best = None
        for k in range(1, self.cfg.max_atoms + 1):
            for combo in itertools.combinations(atoms, k):
                g = lr.rule.guard & MemGuard(combo)
                if not all(not g.holds(s, G) for s, G in bad):
                    continue
                r2 = lr.rule.with_guard(g)
                kept = sum(1 for i in lr.members if self.calc.member_ok(lr, self.calc.steps[i], r2))
                key = (-kept, k, str(g))
                if best is None or key < best[0]:
                    best = (key, g, kept)
        if best is None:
            return None, 0
        return best[1], best[2]

    def _split(self, lr: LearnedRule) -> Optional[List[LearnedRule]]:
        core_map: Dict[Term, List[int]] = {}
        for i in lr.members:
            core_map.setdefault(self.calc.steps[i].core, []).append(i)
        cores = list(core_map)
        if len(cores) < 2:
            return None
        parts = mdl_cluster([(c, OK) for c in cores], [1] * len(cores), gen_support=0)
        if len(parts) < 2:
            return None
        children = []
        for (l, _), mem in parts:
            sid = len(self.calc.rules)
            members = sorted(i for ci in mem for i in core_map[cores[ci]])
            rule = SeqRule.from_term(l, TRUE_GUARD, name=f"L{sid}")
            if self.learner is not None and self.learner.guard_mode == "most_specific":
                rule = rule.with_guard(self.learner.most_specific_guard(rule, members, self.calc.steps))
            ch = LearnedRule(sid, rule, members, tag=lr.tag, parent=lr.sid, log=[f"split from L{lr.sid}"])
            self.calc.rules.append(ch)
            children.append(ch)
        return children

    def _repair(self, lr: LearnedRule, bad, rnd: int, evidence: str) -> dict:
        g, kept = self._choose_guard(lr, bad)
        if g is not None and kept >= self.calc.m:
            old = lr.rule.guard
            lr.rule = lr.rule.with_guard(g)
            lr.log.append(f"round {rnd}: GUARDED [{g}] ({evidence}; keeps {kept}/{len(lr.members)})")
            return {"sid": lr.sid, "action": "guard", "guard": str(g)}
        if self.cfg.allow_split:
            ch = self._split(lr)
            if ch:
                lr.status = "split"
                lr.log.append(f"round {rnd}: SPLIT into {[c.sid for c in ch]} ({evidence})")
                return {"sid": lr.sid, "action": "split", "children": [c.sid for c in ch]}
        lr.status = "deleted"
        lr.log.append(f"round {rnd}: DELETED ({evidence})")
        return {"sid": lr.sid, "action": "delete"}

    def run(self) -> List[dict]:
        cfg = self.cfg
        for rnd in range(cfg.rounds):
            incriminated: Dict[int, list] = defaultdict(list)
            evidence: Dict[int, str] = {}
            n_world_cex = 0
            # 1. world probes (step-level feedback on rule instances)
            if self.world is not None:
                for lr in sorted(self.calc.active(), key=lambda r: r.sid):
                    k = lr.rule.key()
                    if k in self.world_ok:
                        continue
                    ref = self._world_probes(lr)
                    if ref:
                        incriminated[lr.sid].extend((s, G) for s, G, _, _ in ref)
                        evidence[lr.sid] = f"{len(ref)} instances refuted by the world"
                        n_world_cex += len(ref)
                    else:
                        self.world_ok.add(k)
            # 2. coherence: derivations of bottom from designated contexts
            bags = self._search()
            bag_sets = []
            for node, src in bags:
                insts = proof_instances(node)
                if len(self.examples) < 3:
                    from .domains.prop import format_proof
                    self.examples.append({"round": rnd, "source": str(src[0]),
                                          "proof": format_proof(node, names={lr.sid: f"L{lr.sid}" for lr in self.calc.rules})})
                blamed = set()
                if self.world is not None:
                    for rid, s, G, prems, concl in insts:
                        if self.world.step_refuted(prems, concl) is not None:
                            blamed.add(rid)
                            incriminated[rid].append((s, G))
                            evidence.setdefault(rid, "step refuted by the world inside a derivation of bottom")
                if not blamed:
                    bag_sets.append(({rid for rid, *_ in insts}, insts))
            # 3. coherence-only blame: minimum weight hitting set (weight = support)
            hs = []
            if bag_sets:
                weight = {lr.sid: float(max(lr.support, 1)) for lr in self.calc.rules}
                hs = min_weight_hitting_set([b for b, _ in bag_sets], weight)
                for rid in hs:
                    for b, insts in bag_sets:
                        if rid in b:
                            incriminated[rid].extend((s, G) for r2, s, G, _, _ in insts if r2 == rid)
                    evidence.setdefault(rid, f"hitting set of {len(bag_sets)} negative bags")
            actions = []
            for sid in sorted(incriminated):
                lr = self.calc.by_id(sid)
                if lr.status != "active":
                    continue
                actions.append(self._repair(lr, incriminated[sid], rnd, evidence.get(sid, "")))
            self.calc.refresh_support()
            self.history.append({"round": rnd, "bags": len(bags), "bags_hitting_set": len(bag_sets),
                                 "world_cex": n_world_cex, "hitting_set": hs, "actions": actions,
                                 "queries": self.queries})
            if not bags and not incriminated:
                break
        return self.history


# ---------------------------------------------------------------------------
# The bold learner (Post-completeness experiment)
# ---------------------------------------------------------------------------


class BoldLearner:
    """Start from a base calculus and add candidate schemas one at a time,
    keeping a candidate iff the extended calculus remains *coherent*: no
    derivation of bottom from the designated contexts is found (blind search
    plus Post probes of the candidate) within the budget."""

    def __init__(self, base: Sequence[Tuple[object, SeqRule]], designated: Sequence[FrozenSet] = (frozenset(),),
                 probe_budget: int = 400, blind_budget: int = 3000, max_depth: int = 12, max_probes: int = 8,
                 seed: int = 0):
        self.rules = list(base)
        self.designated = list(designated)
        self.probe_budget = probe_budget
        self.blind_budget = blind_budget
        self.max_depth = max_depth
        self.max_probes = max_probes
        self.rng = random.Random(seed)

    def test(self, extra: Sequence[Tuple[object, SeqRule]], blind: bool = True):
        rules = self.rules + list(extra)
        bags, pr = coherence_search(rules, [rid for rid, _ in extra], self.designated if blind else [],
                                    self.rng, self.probe_budget, self.blind_budget, self.max_depth,
                                    self.max_probes, stop_first=True)
        return (bags[0] if bags else None), pr.total_nodes

    def offer(self, extra: Sequence[Tuple[object, SeqRule]], blind: bool = True) -> dict:
        found, nodes = self.test(extra, blind)
        accepted = found is None
        if accepted:
            self.rules.extend(extra)
        return {"accepted": accepted, "proof": found[0] if found else None,
                "source": found[1][0] if found else None, "nodes": nodes}
