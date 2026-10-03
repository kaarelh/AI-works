import random
from fractions import Fraction

import pytest

from cil.domains.algebra import (FALLACIES, TARGET_BY_NAME, TARGET_RULES, UNDEF, HumanConfig, WorldOracle,
                                 arith_rewrites, arith_step_ok, entails, evaluate, fact_holds, generate_corpus,
                                 random_term, schema_sound)
from cil.rules import TRUE_GUARD, licenses
from cil.terms import App, parse


def test_partial_semantics():
    assert evaluate(parse("1/0"), {}) is UNDEF
    assert evaluate(parse("0^0"), {}) == 1
    assert evaluate(parse("0^(-1)"), {}) is UNDEF
    assert evaluate(parse("sqrt(-1)"), {}) is UNDEF
    assert evaluate(parse("sqrt(4)"), {}) == 2
    assert evaluate(parse("2^(1/2)"), {}) is UNDEF
    assert evaluate(parse("(1/0)*0"), {}) is UNDEF
    assert evaluate(parse("x/y"), {"x": Fraction(1), "y": Fraction(2)}) == Fraction(1, 2)


def test_target_rules_sound_and_guards_necessary():
    for r in TARGET_RULES:
        assert schema_sound(r, seed=1, n=300), r
        if r.guard:
            assert not schema_sound(r.with_guard(TRUE_GUARD), seed=1, n=400), r


def test_fallacies_unsound():
    for f in FALLACIES:
        assert not schema_sound(f.rule, seed=2, n=400), f.name


def test_entailment_sound_random():
    rng = random.Random(0)
    orc = WorldOracle(seed=3, n_points=15)
    preds = ["defined", "nonzero", "nonneg", "pos"]
    checked = 0
    for _ in range(600):
        t = random_term(rng, rng.randint(1, 7))
        F = frozenset()
        r = rng.random()
        if r < 0.4:
            F = frozenset({(rng.choice(preds), App(rng.choice(["x", "y", "z"])))})
        elif r < 0.7:  # facts about compound terms exercise the decomposition closure
            F = frozenset({(rng.choice(preds), random_term(rng, rng.randint(2, 5)))})
        for p in preds:
            if entails(F, (p, t)):
                for env in orc.sample_points({"x", "y", "z", "a", "b"}, F, 8):
                    assert fact_holds((p, t), env), (p, str(t), F)
                    checked += 1
    assert checked > 500


def test_oracle_refutes_unguarded_cancellation():
    orc = WorldOracle(seed=0)
    assert not orc.equivalent(parse("x/x"), parse("1"))
    assert orc.equivalent(parse("x/x"), parse("1"), frozenset({("nonzero", parse("x"))}))
    assert not orc.equivalent(parse("(x + y)^2"), parse("x^2 + y^2"))
    assert orc.equivalent(parse("(x + y)^2"), parse("x^2 + 2*x*y + y^2"))
    assert not orc.equivalent(parse("sqrt(x^2)"), parse("x"))
    assert orc.equivalent(parse("sqrt(x^2)"), parse("x"), frozenset({("nonneg", parse("x"))}))


def test_arith():
    assert arith_step_ok(parse("x + 2*3"), parse("x + 6"))
    assert not arith_step_ok(parse("x + 2*3"), parse("x + 5"))
    assert arith_step_ok(parse("2/4"), parse("1/2"))
    assert not arith_step_ok(parse("1/0"), parse("0"))
    outs = [str(n) for _, n in arith_rewrites(parse("(1 + 2)*(3 - 5)"))]
    assert "3*(3 - 5)" in outs and "(1 + 2)*(-2)" in outs


def test_corpus_deterministic_and_valid_steps_are_valid():
    cfg = HumanConfig(noise_rate=0.05, fallacy_rate=0.3)
    c1 = generate_corpus(60, cfg, seed=4)
    c2 = generate_corpus(60, cfg, seed=4)
    assert [str(d) for d in c1] == [str(d) for d in c2]
    orc = WorldOracle(seed=9, n_points=25)
    n_valid = n_fallacy_refuted = n_fallacy = 0
    for d in c1:
        for s in d.steps:
            if s.kind == "valid":
                n_valid += 1
                assert licenses(TARGET_BY_NAME[s.tag], s.before, s.after, d.facts, entails) is not None
                assert orc.equivalent(s.before, s.after, d.facts)
            elif s.kind == "arith":
                assert orc.equivalent(s.before, s.after, d.facts)
            elif s.kind.startswith("fallacy"):
                n_fallacy += 1
                n_fallacy_refuted += not orc.equivalent(s.before, s.after, d.facts)
    assert n_valid > 100
    assert n_fallacy == 0 or n_fallacy_refuted >= 1


def test_fact_closure_sound_random():
    """Every fact in the decomposition closure holds wherever the original facts hold."""
    from cil.domains.algebra import fact_closure
    rng = random.Random(5)
    orc = WorldOracle(seed=8, n_points=10)
    n = 0
    for _ in range(300):
        F = frozenset({(rng.choice(["defined", "nonzero", "nonneg", "pos"]), random_term(rng, rng.randint(2, 6)))})
        pts = orc.sample_points({"x", "y", "z", "a", "b"}, F, 6)
        for f in fact_closure(F):
            for env in pts:
                assert fact_holds(f, env), (f, F)
                n += 1
    assert n > 300


def test_total_semantics_alternative_meaning():
    """The complex-meadow semantics (x/0 := 0, principal complex sqrt) is a
    coherent alternative meaning: every target rule is sound in it, every
    fallacy is unsound in it, and exactly the 'definedness' guards are
    unnecessary in it."""
    from cil.domains.algebra import evaluate_total, schema_sound_total
    assert evaluate_total(parse("1/0"), {}) == 0
    assert evaluate_total(parse("sqrt(-4)"), {}) == 2j
    assert evaluate_total(parse("0^(-2)"), {}) == 0
    for r in TARGET_RULES:
        assert schema_sound_total(r, seed=1, n=300), r
    for f in FALLACIES:
        assert not schema_sound_total(f.rule, seed=2, n=400), f.name
    sound_drops = {r.name for r in TARGET_RULES
                   if r.guard and schema_sound_total(r.with_guard(TRUE_GUARD), seed=1, n=400)}
    assert sound_drops == {"mul_zero", "zero_mul", "sub_self", "zero_div", "div_div", "pow_zero", "sq_sqrt"}
