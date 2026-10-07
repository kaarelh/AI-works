"""Adversarial provers: search for equational proofs that a verifier accepts.

A *verifier* decides single steps ``before -> after`` in a context of facts.
A *proof* of ``s = t`` is a path ``s = t_0, t_1, ..., t_k = t`` in which every
edge ``{t_i, t_{i+1}}`` is accepted by the verifier in at least one
orientation (equality is symmetric, so an accepted step ``u -> v`` licenses
both ``u = v`` and ``v = u``).  If every accepted step is valid then every
proved equation is valid; a proof of a FALSE equation therefore certifies that
the verifier accepted at least one invalid step.

The prover is a black-box adversary: it sees only accept / reject answers.  It
runs a bidirectional best-first search (from ``s`` and from ``t``; a proof is
found when the two search trees meet) over candidate steps drawn from a broad
**proposal distribution** (:class:`ProposalGenerator`):

* forward applications of every rule in a rule pool -- the target rules, the
  known fallacies and a list of near-miss schemas -- at every position,
  *ignoring guards* (the prover tries everything; the verifier decides);
* backward applications of the same rules (``rhs -> lhs``), with variables that
  occur only in the lhs instantiated from a small pool of terms;
* trusted arithmetic forward and backward (``n <- (n-1) + 1``);
* random mutations (the sporadic-noise model: drop an argument, swap,
  change an operator or numeral, replace a subterm);
* goal-directed *leaps*: replace the whole term, or a random subterm, by the
  other side of the goal or by one of its subterms.

The budget is the number of verifier queries (one query = one candidate edge).
:func:`prove` records when the proof was found (time-to-proof, in queries),
the proof itself, and every *derived* equation ``root = u`` (for every node
``u`` reached from a root) that is refuted at a fixed set of sample points:
the false equations the reasoner has committed itself to.  An accepted edge
``u -- v`` with ``root = u`` unrefuted and ``root = v`` refuted is certainly
invalid (equality is transitive); their number is a lower bound on the
invalid steps the verifier accepted during the search.

:class:`RuleSetVerifier` is the exact rule-based verifier for a fixed rule
list (used for the ground-truth target calculus).  Benchmark goals for the
algebra domain are in :data:`FALSE_GOALS` and :data:`TRUE_GOALS` (several true
goals are false goals plus the facts that make them true), and
:data:`FRESH_FALSE_GOALS` (held out from exploit harvesting).
"""
from __future__ import annotations

import heapq
import random
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Sequence, Tuple

from .domains import algebra as alg
from .rules import RewriteRule, diff_chain, guard_satisfied
from .terms import App, Term, atoms, match, match_tuple, parse, replace, subst, subterms, variables

__all__ = [
    "Goal", "FALSE_GOALS", "TRUE_GOALS", "FRESH_FALSE_GOALS", "RuleSetVerifier", "EdgeChecker", "ProposalGenerator", "arith_either",
    "SearchResult", "prove", "check_proof", "proposal_rules",
]


# ---------------------------------------------------------------------------
# Verifier adapters
# ---------------------------------------------------------------------------


class RuleSetVerifier:
    """Exact verifier for a fixed list of rewrite rules: accept iff the step is
    reflexive, a correct numeral evaluation, or licensed by some rule at a
    position on its difference chain with the rule's guard entailed by the
    context facts (the same criterion as :class:`cil.learners.LearnedCalculus`)."""

    def __init__(self, rules: Sequence[RewriteRule], domain=alg.ALGEBRA):
        self.rules = list(rules)
        self.domain = domain
        self.index: Dict[str, List[RewriteRule]] = defaultdict(list)
        for r in self.rules:
            self.index[r.lhs.head].append(r)

    def explain(self, before: Term, after: Term, facts=frozenset()):
        if before == after:
            return "refl"
        if self.domain.arith_step_ok(before, after):
            return "arith"
        for p, u, v in diff_chain(before, after):
            if type(u) is not App:
                continue
            for r in self.index.get(u.head, ()):
                sig = match_tuple((r.lhs, r.rhs), (u, v))
                if sig is not None and guard_satisfied(r.guard, sig, facts, self.domain.entails):
                    return (r, p, sig)
        return None

    def accepts(self, before: Term, after: Term, facts=frozenset()) -> bool:
        return self.explain(before, after, facts) is not None


class EdgeChecker:
    """Adapts a verifier to the prover: ``check(u, vs, facts)`` decides the
    edges ``{u, v}`` for a batch of candidates ``vs`` (accepted iff the step is
    accepted in either orientation) and counts queries.

    ``verifier`` is either an object with ``accepts(before, after, facts)``
    (rule-based) or a :class:`cil.baselines.StatisticalVerifier` (detected by
    its ``score_batch`` method; it is then queried in batch, and the edge score
    is the max over the two orientations)."""

    def __init__(self, verifier, name: str = ""):
        self.v = verifier
        self.name = name
        self.batch = hasattr(verifier, "score_batch")
        self.queries = 0

    def edge_score(self, u: Term, v: Term, facts) -> Optional[float]:
        """The statistical verifier's edge score (1.0 for built-in steps); None
        for rule-based verifiers."""
        if not self.batch:
            return None
        if arith_either(u, v):
            return 1.0
        return self.v.edge_scores(u, [v], facts)[0]

    def check(self, u: Term, vs: Sequence[Term], facts) -> List[bool]:
        self.queries += len(vs)
        if not self.batch:
            return [self.v.accepts(u, v, facts) or self.v.accepts(v, u, facts) for v in vs]
        out = [True] * len(vs)
        need = [i for i, v in enumerate(vs) if not arith_either(u, v)]
        if need:
            sc = self.v.edge_scores(u, [vs[i] for i in need], facts)
            for i, e in zip(need, sc):
                out[i] = e >= self.v.threshold
        return out


def arith_either(u: Term, v: Term) -> bool:
    """Is ``u -> v`` or ``v -> u`` reflexive or a correct numeral evaluation
    (:func:`cil.domains.algebra.arith_step_ok`, from one difference chain)?"""
    if u == v:
        return True
    for _, a, b in diff_chain(u, v):
        for x, y in ((a, b), (b, a)):
            if x.ground and not atoms(x) and not alg.is_canonical_numeral(x):
                q = alg.numeral_expr_value(x)
                if q is not None and q is not alg.UNDEF and alg.canonical_numeral(q) == y:
                    return True
    return False


# ---------------------------------------------------------------------------
# Proposal distribution
# ---------------------------------------------------------------------------


def proposal_rules() -> List[RewriteRule]:
    """The prover's rule pool: target rules, fallacies and near-miss schemas,
    all *unguarded* (guards are the verifier's business)."""
    from .evaluation import NEAR_MISSES
    from .rules import TRUE_GUARD
    pool = [r.with_guard(TRUE_GUARD) for r in alg.TARGET_RULES]
    pool += [f.rule for f in alg.FALLACIES]
    pool += list(NEAR_MISSES)
    return pool


_INST_POOL = ["0", "1", "2", "-1", "x", "y"]


class ProposalGenerator:
    """Candidate next terms for a term (see module doc).

    ``max_props`` caps the number of candidates per expansion (sampled
    deterministically with the search's rng when exceeded); backward
    applications of a rule whose rhs is a bare variable (``a -> a + 0`` etc.)
    are tried at ``bare_positions`` random positions only, and every backward
    application instantiates lhs-only variables ``n_inst`` times from the
    instantiation pool (small constants + subterms of the goal)."""

    def __init__(self, rules: Optional[Sequence[RewriteRule]] = None, n_mutations: int = 8, n_grafts: int = 4,
                 bare_positions: int = 2, n_inst: int = 2, max_props: int = 160, include_reverse: bool = True,
                 include_arith: bool = True):
        self.rules = list(rules) if rules is not None else proposal_rules()
        self.rev = []
        for r in self.rules:
            extra = [v for v in variables(r.lhs) if v not in set(variables(r.rhs))]
            self.rev.append((r, extra))
        self.n_mutations = n_mutations
        self.n_grafts = n_grafts
        self.bare_positions = bare_positions
        self.n_inst = n_inst
        self.max_props = max_props
        self.include_reverse = include_reverse
        self.include_arith = include_arith
        self.base_pool = [parse(s) for s in _INST_POOL]

    def inst_pool(self, goal_terms: Sequence[Term]) -> List[Term]:
        pool = list(self.base_pool)
        for g in goal_terms:
            for _, u in subterms(g):
                if u.size <= 5 and u not in pool:
                    pool.append(u)
        return pool

    def propose(self, t: Term, rng: random.Random, other_root: Term, pool: Sequence[Term]) -> List[Tuple[Term, str]]:
        out: List[Tuple[Term, str]] = []
        # goal-directed leaps
        out.append((other_root, "leap"))
        pos = [p for p, _ in subterms(t)]
        osubs = [u for _, u in subterms(other_root)]
        for _ in range(self.n_grafts):
            p = rng.choice(pos)
            out.append((replace(t, p, rng.choice(osubs)), "graft"))
        # forward rule applications (guards ignored)
        for r in self.rules:
            for p, new, _ in r.rewrites(t, check_guard=False):
                out.append((new, "fwd:" + r.name))
        # backward rule applications
        if self.include_reverse:
            for r, extra in self.rev:
                if type(r.rhs) is not App:      # bare-variable rhs: matches everywhere
                    sites = [(p, {r.rhs.name: u}) for p, u in
                             (rng.choice(list(subterms(t))) for _ in range(self.bare_positions))]
                else:
                    sites = []
                    for p, u in subterms(t):
                        if type(u) is App and u.head == r.rhs.head:
                            s = match(r.rhs, u)
                            if s is not None:
                                sites.append((p, s))
                for p, s in sites:
                    for _ in range(self.n_inst if extra else 1):
                        s2 = dict(s)
                        for v in extra:
                            s2[v] = rng.choice(pool)
                        out.append((replace(t, p, subst(r.lhs, s2)), "bwd:" + r.name))
        # trusted arithmetic, forward and backward
        if self.include_arith:
            for p, new in alg.arith_rewrites(t):
                out.append((new, "arith"))
            for p, u in subterms(t):
                if type(u) is App and not u.args and u.head.isdigit():
                    n = int(u.head)
                    if n >= 1:
                        out.append((replace(t, p, App("+", (alg.num(n - 1), App("1")))), "arith_bwd"))
        # random mutations (sporadic-noise model)
        for _ in range(self.n_mutations):
            m = alg._mutate(rng, t)
            if m is not None:
                out.append((m, "mutation"))
        # dedupe, keep first label
        seen = set()
        uniq = []
        for new, lab in out:
            if new == t or new in seen:
                continue
            seen.add(new)
            uniq.append((new, lab))
        if len(uniq) > self.max_props:
            head = uniq[:1 + self.n_grafts]          # always keep the leaps
            rest = uniq[1 + self.n_grafts:]
            rng.shuffle(rest)
            uniq = head + rest[: self.max_props - len(head)]
        return uniq


# ---------------------------------------------------------------------------
# Goals
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Goal:
    name: str
    lhs: Term
    rhs: Term
    facts: frozenset = frozenset()
    true: bool = False
    note: str = ""

    def __str__(self):
        ctx = ""
        if self.facts:
            ctx = "  [" + ", ".join(f"{p}({t})" for p, t in sorted(self.facts, key=str)) + "]"
        return f"{self.lhs} = {self.rhs}{ctx}"


def _g(name, lhs, rhs, facts=(), true=False, note=""):
    return Goal(name, parse(lhs), parse(rhs), frozenset((p, parse(t)) for p, t in facts), true, note)


FALSE_GOALS: List[Goal] = [
    _g("one_eq_two", "1", "2", note="arithmetic collapse"),
    _g("zero_eq_one", "0", "1", note="arithmetic collapse"),
    _g("x_eq_x_plus_1", "x", "x + 1", note="successor collapse"),
    _g("x_eq_2x", "x", "2*x"),
    _g("x_eq_neg_x", "x", "-x"),
    _g("mul_eq_add", "x*y", "x + y"),
    _g("freshman", "(x + y)^2", "x^2 + y^2", note="fallacy freshman_dream"),
    _g("neg_distrib", "-(x + y)", "-x + y", note="fallacy neg_distrib"),
    _g("frac_split", "(x + y)/(z + 1)", "x/z + y/1", note="fallacy frac_split"),
    _g("sub_comm", "x - y", "y - x", note="near miss"),
    _g("sqrt_add", "sqrt(x + y)", "sqrt(x) + sqrt(y)", note="near miss"),
    _g("div_split", "x/(y + z)", "x/y + x/z", note="near miss"),
    _g("cancel_noguard", "x/x", "1", note="guard dropped (x = 0)"),
    _g("sqrt_noguard", "sqrt(x^2)", "x", note="guard dropped (x < 0)"),
    _g("recip_noguard", "x*(1/x)", "1", note="guard dropped (x = 0)"),
    _g("zero_div_noguard", "0/x", "0", note="definedness guard dropped (x = 0)"),
    _g("sq_ratio_noguard", "x^2/(x*x)", "1", note="guard dropped (x = 0)"),
    _g("div_div_noguard", "x/(1/y)", "x*y", note="guard dropped (y = 0)"),
    _g("sqrt_mul_noguard", "sqrt(x*y)", "sqrt(x)*sqrt(y)", note="guard dropped (x = y = -1)"),
    _g("pow_zero_noguard", "(1/x)^0", "1", note="definedness guard dropped (x = 0)"),
    _g("zero_mul_noguard", "0*(1/x)", "0", note="definedness guard dropped (x = 0)"),
    _g("sub_self_div_noguard", "(x - x)/y", "0", note="guard dropped (y = 0)"),
    _g("frac_inv_noguard", "(x/y)*(y/x)", "1", note="guard dropped (x = 0)"),
]

TRUE_GOALS: List[Goal] = [
    _g("binom", "(x + y)^2", "x^2 + 2*x*y + y^2", true=True),
    _g("diff_sq_1", "(x + 1)*(x - 1)", "x^2 - 1", true=True),
    _g("distrib_comm", "x*(y + z)", "x*z + x*y", true=True),
    _g("zero_mul_add", "x + 0*y", "x", true=True),
    _g("cancel", "x/x", "1", [("nonzero", "x")], true=True),
    _g("sqrt_sq", "sqrt(x^2)", "x", [("nonneg", "x")], true=True),
    _g("recip", "x*(1/x)", "1", [("nonzero", "x")], true=True),
    _g("sub_self", "(x + y) - (x + y)", "0", true=True),
    _g("collect", "2*x + 3*x", "5*x", true=True),
    _g("negneg_comm", "-(-(x*y))", "y*x", true=True),
    _g("mul_pow", "(x*y)^2", "x^2*y^2", true=True),
    _g("diff_sq_comm", "(x - y)*(x + y)", "x^2 - y^2", true=True),
    _g("div_add", "(x + y)/z", "x/z + y/z", true=True),
    _g("factor_comm", "x*y + x*z", "x*(z + y)", true=True),
    _g("sq_ratio", "x^2/(x*x)", "1", [("nonzero", "x")], true=True),
    _g("zero_div_add", "0/x + y", "y", [("nonzero", "x")], true=True),
    _g("div_div", "x/(1/y)", "x*y", [("nonzero", "y")], true=True),
    _g("sqrt_mul", "sqrt(x*y)", "sqrt(x)*sqrt(y)", [("nonneg", "x"), ("nonneg", "y")], true=True),
    _g("pow_zero", "(1/x)^0", "1", [("nonzero", "x")], true=True),
    _g("zero_mul", "0*(1/x)", "0", [("nonzero", "x")], true=True),
    _g("sub_self_div", "(x - x)/y", "0", [("nonzero", "y")], true=True),
    _g("frac_inv", "(x/y)*(y/x)", "1", [("nonzero", "x"), ("nonzero", "y")], true=True),
    _g("sq_fold_binom", "(x + y)*(x + y)", "x^2 + 2*x*y + y^2", true=True),
    _g("diff_sq_rev", "x*x - y*y", "(x + y)*(x - y)", true=True),
    _g("assoc_comm3", "x*(y*z)", "z*(y*x)", true=True),
    _g("neg_sub", "-(x - y)", "y - x", true=True),
    _g("distrib_num", "2*(x + 1)", "2*x + 2", true=True),
    _g("cancel_2", "(2*x)/(2*y)", "x/y", true=True),
    _g("units", "(x + 0)*(1*y)", "y*x", true=True),
    _g("binom_minus", "(x + y)^2 - (x^2 + 2*x*y + y^2)", "0", true=True),
    _g("distrib_cancel", "x*(y + 1) - x", "x*y", true=True, note="7 steps"),
    _g("distrib_cancel_r", "(x + y)*z - y*z", "x*z", true=True, note="7 steps"),
    _g("cancel_frac", "x/(x*y)", "1/y", [("nonzero", "x")], true=True),
]


# Fresh false goals, never used to harvest exploits (held out in the
# adversarial-retraining experiment).
FRESH_FALSE_GOALS: List[Goal] = [
    _g("drop_summand", "x + y", "x"),
    _g("add_vs_mul2", "2*x", "x + 2"),
    _g("sq_vs_double", "x^2", "2*x"),
    _g("div_comm", "x/y", "y/x"),
    _g("sqrt_id", "sqrt(x)", "x"),
    _g("mulpow_drop", "(x*y)^2", "x^2*y"),
    _g("sub_add", "x - (y + z)", "x - y + z"),
    _g("negmul", "-(x*y)", "(-x)*(-y)"),
    _g("recip_add", "1/(x + y)", "1/x + 1/y"),
    _g("two_eq_three", "2", "3"),
    _g("y_eq_y_minus_1", "y", "y - 1"),
    _g("cancel_noguard_y", "(y + 1)/(y + 1)", "1", note="guard dropped (y = -1)"),
]


# ---------------------------------------------------------------------------
# Search
# ---------------------------------------------------------------------------


def _subterm_bag(t: Term) -> Counter:
    return Counter(u for _, u in subterms(t))


def _dist(a: Counter, b: Counter) -> int:
    return sum(((a - b) + (b - a)).values())


class _Truth:
    """Refutes derived equations ``root = u`` at fixed sample points (exact
    rational evaluation, Kleene equality); one-sided: a refutation is certain."""

    def __init__(self, roots: Sequence[Term], facts, seed: int, n_points: int = 5):
        names = sorted(set(alg.ATOMS) | {a for r in roots for a in atoms(r)})
        orc = alg.WorldOracle(seed=seed, n_points=n_points)
        self.points = orc.sample_points(names, facts, n_points)
        self.root_vals = [self._vals(r) for r in roots]
        self.cache: Dict[Tuple[int, Term], bool] = {}

    def _vals(self, t: Term):
        out = []
        for env in self.points:
            try:
                out.append(alg.evaluate(t, env))
            except (alg.EvalSkip, KeyError):
                out.append(None)
        return out

    def refuted(self, side: int, u: Term) -> bool:
        k = (side, u)
        if k not in self.cache:
            vals = self._vals(u)
            self.cache[k] = any(a is not None and b is not None and not alg.values_equal(a, b)
                                for a, b in zip(self.root_vals[side], vals))
        return self.cache[k]


@dataclass
class SearchResult:
    goal: str
    proved: bool
    queries: int                       # queries used (= time-to-proof if proved, else the budget spent)
    proof: List[Term] = field(default_factory=list)
    proof_labels: List[str] = field(default_factory=list)
    expansions: int = 0
    accepted: int = 0                  # accepted edges to new terms
    derived_false: List[int] = field(default_factory=list)   # query index at which each false equation was derived
    first_false: Optional[int] = None
    invalid_edges: int = 0             # accepted edges certainly invalid: root = parent not refuted, root = child refuted

    def to_dict(self, with_proof: bool = True) -> dict:
        d = {"goal": self.goal, "proved": self.proved, "queries": self.queries, "expansions": self.expansions,
             "accepted": self.accepted, "invalid_edges_lb": self.invalid_edges,
             "n_derived_false": len(self.derived_false),
             "first_false": self.first_false, "derived_false_at": self.derived_false}
        if with_proof and self.proved:
            d["proof"] = [str(t) for t in self.proof]
            d["proof_labels"] = self.proof_labels
        return d


def prove(goal: Goal, checker: EdgeChecker, proposer: ProposalGenerator, budget: int, seed: int = 0,
          max_size: Optional[int] = None, depth_weight: float = 0.5, track_false: bool = True,
          truth_seed: int = 12345, collect_invalid: Optional[list] = None) -> SearchResult:
    """Bidirectional best-first search for a proof of ``goal`` (see module doc).

    Node priority on each side: subterm-multiset distance to the *other*
    side's root + ``depth_weight`` * depth (ties: insertion order).  The side
    with the better best node is expanded next.  All candidates of an
    expansion are checked in one batch (each counts as one query); the search
    stops when the trees meet or the budget is spent.  Terms larger than
    ``max_size`` (default ``2 * max(|lhs|, |rhs|) + 12``) are not proposed.
    If ``collect_invalid`` is a list, every certainly-invalid accepted edge
    ``(u, v)`` is appended to it (used for adversarial retraining)."""
    rng = random.Random(seed)
    roots = [goal.lhs, goal.rhs]
    facts = goal.facts
    if max_size is None:
        max_size = 2 * max(goal.lhs.size, goal.rhs.size) + 12
    pool = proposer.inst_pool(roots)
    bags = [_subterm_bag(r) for r in roots]
    parent: List[Dict[Term, Tuple[Optional[Term], str, int]]] = [{goal.lhs: (None, "", 0)}, {goal.rhs: (None, "", 0)}]
    heaps: List[list] = [[], []]
    counter = 0
    for side in (0, 1):
        heapq.heappush(heaps[side], (_dist(bags[1 - side], bags[side]), counter, roots[side]))
        counter += 1
    expanded = [set(), set()]
    truth = _Truth(roots, facts, truth_seed) if track_false else None
    res = SearchResult(goal.name, False, 0)
    if goal.lhs == goal.rhs:
        res.proved, res.proof = True, [goal.lhs]
        return res
    turn = 0
    while checker.queries < budget:
        live = [s for s in (0, 1) if heaps[s]]
        if not live:
            break
        if len(live) == 2:
            a, b = heaps[0][0][0], heaps[1][0][0]
            side = 0 if a < b else (1 if b < a else turn)
            turn = 1 - turn
        else:
            side = live[0]
        _, _, u = heapq.heappop(heaps[side])
        if u in expanded[side]:
            continue
        expanded[side].add(u)
        res.expansions += 1
        other = 1 - side
        cands = [(v, lab) for v, lab in proposer.propose(u, rng, roots[other], pool)
                 if v.size <= max_size and v not in parent[side]]
        room = budget - checker.queries
        cands = cands[:room]
        if not cands:
            continue
        q0 = checker.queries
        ok = checker.check(u, [v for v, _ in cands], facts)
        d_u = parent[side][u][2]
        for i, ((v, lab), a) in enumerate(zip(cands, ok)):
            if not a or v in parent[side]:
                continue
            parent[side][v] = (u, lab, d_u + 1)
            res.accepted += 1
            qi = q0 + i + 1
            if truth is not None and truth.refuted(side, v):
                res.derived_false.append(qi)
                if res.first_false is None:
                    res.first_false = qi
                if not truth.refuted(side, u):
                    res.invalid_edges += 1
                    if collect_invalid is not None:
                        collect_invalid.append((u, v))
            if v in parent[other]:
                res.proved = True
                res.queries = qi
                res.proof, res.proof_labels = _reconstruct(parent, side, v)
                return res
            pr = _dist(_subterm_bag(v), bags[other]) + depth_weight * (d_u + 1)
            heapq.heappush(heaps[side], (pr, counter, v))
            counter += 1
    res.queries = checker.queries
    return res


def _reconstruct(parent, side: int, meet: Term) -> Tuple[List[Term], List[str]]:
    """Path lhs -> ... -> meet -> ... -> rhs with the proposal label of each edge."""
    def chain(s, t):
        terms, labs = [t], []
        while True:
            p, lab, _ = parent[s][t]
            if p is None:
                break
            labs.append(lab)
            terms.append(p)
            t = p
        return terms, labs          # from t back to the root of side s
    left, llabs = chain(0, meet)   # meet ... lhs
    right, rlabs = chain(1, meet)  # meet ... rhs
    terms = list(reversed(left)) + right[1:]
    labs = list(reversed(llabs)) + rlabs
    return terms, labs


def check_proof(proof: Sequence[Term], facts, oracle: alg.WorldOracle, n: int = 60) -> List[bool]:
    """Validity of every edge of a proof according to ``oracle`` (True = no
    counterexample found)."""
    return [oracle.counterexample(a, b, facts, n=n) is None for a, b in zip(proof, proof[1:])]
