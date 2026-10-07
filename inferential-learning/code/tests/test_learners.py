import pytest

from cil.domains.algebra import ALGEBRA, TARGET_BY_NAME, TARGET_RULES, HumanConfig, WorldOracle, generate_corpus
from cil.evaluation import fallacy_report, recovery_report, unsound_active
from cil.learners import (CoherenceConfig, CoherenceRepairer, LearnedCalculus, LearnedSchema, LGGLearner, TrainStep,
                          choose_guard, mdl_cluster, ochiai_blame, prepare_training, shape_key)
from cil.rules import Guard, RewriteRule, TRUE_GUARD, diff_chain, rule_from_strings
from cil.terms import parse, parse_pattern


@pytest.fixture(scope="module")
def clean_steps():
    return prepare_training(generate_corpus(150, HumanConfig(), seed=1), ALGEBRA)


def test_tagged_learner_recovers_target_shapes(clean_steps):
    calc = LGGLearner(ALGEBRA, tagged=True, m=2).fit(steps=clean_steps)
    act = calc.active()
    found = sum(any(s.rule.variant_of(r, check_guard=False) for s in act) for r in TARGET_RULES)
    assert found >= 37
    # on clean data every active schema is an instance of a target schema (up to guards)
    for s in act:
        assert any(t.subsumes(s.rule) for t in TARGET_RULES), str(s)


def test_most_specific_guard_learns_guards_from_clean_positives(clean_steps):
    calc = LGGLearner(ALGEBRA, tagged=True, m=2, guard_mode="most_specific").fit(steps=clean_steps)
    rep = recovery_report(calc)
    # without fallacies, positive data alone gives guards at least as strong as the target
    for name in ("div_self", "sqrt_sq"):
        if rep[name] != "missing":
            assert rep[name] in ("exact", "guard_stronger"), (name, rep[name])
    assert not unsound_active(calc)


def test_verifier_acceptance_criterion():
    steps = [TrainStep(i, parse(b), parse(a), frozenset(), "t", diff_chain(parse(b), parse(a)), False, 0)
             for i, (b, a) in enumerate([("x + 0", "x"), ("y*2 + 0", "y*2"), ("z + 0", "z")])]
    rule = rule_from_strings("a + 0", "a")
    calc = LearnedCalculus([LearnedSchema(0, rule, [0, 1, 2])], steps, ALGEBRA, m=3)
    assert calc.accepts(parse("(q*q + 1) + 0"), parse("q*q + 1"))          # large, unseen instance
    assert calc.accepts(parse("2 + 3"), parse("5"))                         # built-in arith
    assert not calc.accepts(parse("x + 1"), parse("x"))
    calc.m = 4
    calc.touch()
    assert not calc.accepts(parse("(q*q + 1) + 0"), parse("q*q + 1"))       # support 3 < m


def test_mdl_cluster_keeps_noise_out_of_big_cluster():
    cores = [(parse(f"{v} + 0"), parse(v)) for v in ["x", "y", "z", "x*y", "2*z", "y + 1", "x - y", "a"]]
    cores.append((parse("b + c"), parse("b")))   # sporadic noise
    parts = mdl_cluster(cores, [1] * len(cores))
    big = max(parts, key=lambda p: len(p[1]))
    assert len(big[1]) == 8
    assert RewriteRule(*big[0]).variant_of(TARGET_BY_NAME["add_zero"], check_guard=False)


def test_shape_key_invariant_across_instances():
    k1 = shape_key(parse("2*(x + y)"), parse("2*x + 2*y"))
    k2 = shape_key(parse("(a - 1)*(z + 3*b)"), parse("(a - 1)*z + (a - 1)*(3*b)"))
    assert k1 == k2


def test_choose_guard_monster_barring():
    entails = ALGEBRA.entails
    r = rule_from_strings("a/a", "1")
    cex = [({"a": parse("0")}, frozenset()), ({"a": parse("x - x")}, frozenset()), ({"a": parse("x")}, frozenset())]
    pos = [([{"a": parse("x")}], frozenset({("nonzero", parse("x"))})), ([{"a": parse("y + 1")}], frozenset({("pos", parse("y"))}))]
    g, kept = choose_guard(r, cex, pos, ALGEBRA.guard_preds, entails)
    assert str(g) == "nonzero(?a)" and kept == 2
    r = rule_from_strings("a*0", "0")
    cex = [({"a": parse("1/0")}, frozenset()), ({"a": parse("1/(x - x)")}, frozenset())]
    pos = [([{"a": parse("x")}], frozenset()), ([{"a": parse("y*y")}], frozenset())]
    g, kept = choose_guard(r, cex, pos, ALGEBRA.guard_preds, entails)
    assert str(g) == "defined(?a)" and kept == 2
    r = rule_from_strings("(a + b)^2", "a^2 + b^2")
    cex = [({"a": parse("1"), "b": parse("1")}, frozenset())]
    g, kept = choose_guard(r, cex, [], ALGEBRA.guard_preds, entails)
    assert g is None


def test_ochiai_blame():
    neg = [{1, 2}, {1, 3}, {1}, {2, 4}]
    pos = [{2, 3}, {2, 4}, {3}, {4}]
    blame = ochiai_blame(neg, pos)
    assert blame[0][0] == 1
    assert sorted(i for _, att in blame for i in att) == [0, 1, 2, 3]


def _toy_calculus():
    """Hand-made human data: valid uses of a few rules + fallacies."""
    data = []

    def add(b, a, tag, facts=()):
        data.append((parse(b), parse(a), tag, frozenset(facts)))

    for v in ["x", "y", "z + 1", "2*x", "x*y"]:
        add(f"({v})*1", v, "mul_one")
        add(f"({v}) + 0", v, "add_zero")
        add(f"({v})*({v} + 2)", f"({v})*({v}) + ({v})*2", "distrib_l")
    for v in ["x", "y", "x + 1", "y*z"]:
        add(f"({v})/({v})", "1", "div_self", [("nonzero", parse(v))])
    add("z/z", "1", "div_self")                                   # unguarded cancellation
    add("(a + b)/(a + b)", "1", "div_self")
    for a, b in [("x", "y"), ("x", "1"), ("2", "z"), ("y*y", "x")]:
        add(f"({a} + {b})^2", f"({a})^2 + ({b})^2", "binom_sq")   # freshman's dream
    steps = [TrainStep(i, b, a, F, tag, diff_chain(b, a), False, i) for i, (b, a, tag, F) in enumerate(data)]
    return steps


@pytest.mark.parametrize("mode", ["step", "bag"])
def test_coherence_repairs_cancellation_and_deletes_freshman(mode):
    steps = _toy_calculus()
    calc = LGGLearner(ALGEBRA, tagged=True, m=2).fit(steps=steps)
    rep = CoherenceRepairer(calc, CoherenceConfig(mode=mode, seed=0, rounds=6), oracle=WorldOracle(seed=1))
    rep.run()
    act = calc.active()
    div = [s for s in act if s.rule.variant_of(TARGET_BY_NAME["div_self"], check_guard=False)]
    assert div and all(s.rule.guard.implies(Guard([("nonzero", v) for v in s.rule.vars()]), ALGEBRA.pred_implies)
                       for s in div)
    fresh = rule_from_strings("(a + b)^2", "a^2 + b^2")
    assert not any(s.rule.variant_of(fresh, check_guard=False) for s in act)
    assert not unsound_active(calc)


def test_pure_coherence_cannot_see_partiality():
    """Without world feedback, unguarded a*0 -> 0 is coherent with the rest."""
    data = []
    for v in ["x", "y", "2", "x + 1", "y*y", "x*y"]:
        data.append((parse(f"({v})*0"), parse("0")))
        data.append((parse(f"({v})*1"), parse(v)))
    steps = [TrainStep(i, b, a, frozenset(), "r", diff_chain(b, a), False, i) for i, (b, a) in enumerate(data)]
    calc = LGGLearner(ALGEBRA, tagged=False, m=2).fit(steps=steps)
    CoherenceRepairer(calc, CoherenceConfig(mode="numeral", seed=0)).run()
    mz = rule_from_strings("a*0", "0")
    assert any(s.rule.variant_of(mz, check_guard=True) for s in calc.active())
    calc2 = LGGLearner(ALGEBRA, tagged=False, m=2).fit(steps=steps)
    CoherenceRepairer(calc2, CoherenceConfig(mode="step", seed=0), oracle=WorldOracle(seed=2)).run()
    assert recovery_report(calc2, [TARGET_BY_NAME["mul_zero"]])["mul_zero"] == "exact"


def test_split_repair_separates_conflated_rules():
    """Untagged stage-2 generalisation conflates a*1 -> a and 0*a -> 0 into the
    unsound ?X*?Y -> ?X; coherence splits it back."""
    data = []
    for v in ["x", "y", "z + 1", "2*x", "x*y", "y - 1", "x^2"]:
        data.append((parse(f"({v})*1"), parse(v)))
        data.append((parse(f"0*({v})"), parse("0")))
    steps = [TrainStep(i, b, a, frozenset(), "", diff_chain(b, a), False, i) for i, (b, a) in enumerate(data)]
    calc = LGGLearner(ALGEBRA, tagged=False, m=2, gen_support=4).fit(steps=steps)
    bad = rule_from_strings("a*b", "a")
    assert any(s.rule.variant_of(bad, check_guard=False) for s in calc.active())
    CoherenceRepairer(calc, CoherenceConfig(mode="step", seed=0), oracle=WorldOracle(seed=3)).run()
    rep = recovery_report(calc, [TARGET_BY_NAME["mul_one"], TARGET_BY_NAME["zero_mul"]])
    assert rep == {"mul_one": "exact", "zero_mul": "exact"}
    assert not unsound_active(calc)
