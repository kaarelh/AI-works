import pytest

from cil.domains.algebra import TARGET_RULES, WorldOracle
from cil.provers import (FALSE_GOALS, TRUE_GOALS, EdgeChecker, Goal, ProposalGenerator, RuleSetVerifier,
                         arith_either, check_proof, prove)
from cil.rules import rule_from_strings
from cil.terms import parse


def test_goal_labels_agree_with_the_world():
    oracle = WorldOracle(seed=11, n_points=80)
    for g in FALSE_GOALS:
        assert oracle.counterexample(g.lhs, g.rhs, g.facts) is not None, str(g)
    for g in TRUE_GOALS:
        assert oracle.counterexample(g.lhs, g.rhs, g.facts) is None, str(g)
    assert len({g.name for g in FALSE_GOALS + TRUE_GOALS}) == len(FALSE_GOALS) + len(TRUE_GOALS)


def test_target_verifier_respects_guards():
    V = RuleSetVerifier(TARGET_RULES)
    x = parse("x")
    assert not V.accepts(parse("x/x"), parse("1"))
    assert V.accepts(parse("x/x"), parse("1"), frozenset({("nonzero", x)}))
    assert V.accepts(parse("y + x*(1 + 2)"), parse("y + x*3"))          # arithmetic
    assert V.accepts(parse("2*(x + y)"), parse("2*x + 2*y"))
    assert not V.accepts(parse("(x + y)^2"), parse("x^2 + y^2"))


def test_arith_either():
    assert arith_either(parse("1 + 1"), parse("2")) and arith_either(parse("2"), parse("1 + 1"))
    assert arith_either(parse("x + 2/4"), parse("x + 1/2"))
    assert not arith_either(parse("1"), parse("2"))
    assert not arith_either(parse("1/0"), parse("0"))


def _goal(name):
    return next(g for g in FALSE_GOALS + TRUE_GOALS if g.name == name)


def test_target_calculus_proves_true_goals_and_no_false_ones():
    V = RuleSetVerifier(TARGET_RULES)
    P = ProposalGenerator()
    for name in ("cancel", "collect", "neg_sub", "recip"):
        r = prove(_goal(name), EdgeChecker(V), P, 1500, seed=0)
        assert r.proved, name
        assert r.proof[0] == _goal(name).lhs and r.proof[-1] == _goal(name).rhs
        assert len(r.proof_labels) == len(r.proof) - 1
        assert not r.derived_false
    for name in ("cancel_noguard", "one_eq_two"):
        ch = EdgeChecker(V)
        r = prove(_goal(name), ch, P, 600, seed=0)
        assert not r.proved and r.queries == 600 == ch.queries
        assert not r.derived_false and r.invalid_edges == 0


def test_one_tonk_rule_collapses_arithmetic():
    """Unguarded x/x -> 1 and 0/x -> 0 together prove 0 = 1 via 0/0 (Prior's tonk in miniature)."""
    bad = [r for r in TARGET_RULES if r.name not in ("div_self", "zero_div")]
    bad += [rule_from_strings("a/a", "1", name="div_self_noguard"), rule_from_strings("0/a", "0", name="zero_div_noguard")]
    V = RuleSetVerifier(bad)
    g = _goal("zero_eq_one")
    r = prove(g, EdgeChecker(V), ProposalGenerator(), 3000, seed=0)
    assert r.proved
    for a, b in zip(r.proof, r.proof[1:]):
        assert V.accepts(a, b, g.facts) or V.accepts(b, a, g.facts)
    valid = check_proof(r.proof, g.facts, WorldOracle(seed=2, n_points=40))
    assert not all(valid)                        # a proof of a falsehood contains an invalid step
    assert r.derived_false and r.first_false is not None and r.invalid_edges >= 1


def test_search_is_deterministic():
    V = RuleSetVerifier(TARGET_RULES)
    P = ProposalGenerator()
    g = _goal("x_eq_2x")
    r1 = prove(g, EdgeChecker(V), P, 400, seed=5)
    r2 = prove(g, EdgeChecker(V), P, 400, seed=5)
    assert r1.to_dict() == r2.to_dict()


class _FakeStat:
    """Minimal statistical verifier: accepts an edge iff the two terms have equal size."""
    threshold = 0.5

    def __init__(self):
        self.calls = 0

    def score_batch(self, steps):
        return [1.0 if b.size == a.size else 0.0 for b, a, _ in steps]

    def edge_scores(self, u, vs, facts=frozenset()):
        self.calls += 1
        return [1.0 if u.size == v.size else 0.0 for v in vs]


def test_edge_checker_batch_path():
    fake = _FakeStat()
    ch = EdgeChecker(fake)
    u = parse("x + y")
    out = ch.check(u, [parse("y + x"), parse("x"), parse("2 + 1"), parse("x*y")], frozenset())
    # 2 + 1 vs x + y: equal size; x: smaller; x*y: same size
    assert out == [True, False, True, True]
    assert ch.queries == 4 and fake.calls == 1
    # built-in arithmetic bypasses the classifier
    assert ch.check(parse("3"), [parse("1 + 2")], frozenset()) == [True]


def test_proposals_include_every_kind():
    P = ProposalGenerator(max_props=10_000)
    import random
    props = P.propose(parse("x/x + 0"), random.Random(0), parse("1"), P.inst_pool([parse("x/x + 0"), parse("1")]))
    kinds = {lab.split(":")[0] for _, lab in props}
    assert {"leap", "graft", "fwd", "bwd", "mutation"} <= kinds
    assert (parse("1 + 0"), "fwd:div_self") in props or any(t == parse("1 + 0") for t, _ in props)
