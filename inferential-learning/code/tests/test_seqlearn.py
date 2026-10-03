import random

import pytest

from cil.domains.prop import (CLASSICAL_RULES, FALLACY_RULES, INTUITIONISTIC_RULES, TARGET_BY_NAME, TONK_E, TONK_I,
                              PropHumanConfig, Seq, generate_corpus, kripke_countermodel, parse_formula, parse_rule,
                              proof_steps, rule_sound, seq)
from cil.prop_eval import (adversarial_attack, completeness, fallacy_report, heldout_steps, recovery_report,
                           tonk_like, unsound_active, acceptance_rates)
from cil.seqlearn import (BoldLearner, CoherencePruner, LearnedRule, LearnedSeqCalculus, PruneConfig, SeqLearner,
                          bucket_key, coherence_search, min_weight_hitting_set, normalize_step, post_probes,
                          prepare_training)


@pytest.fixture(scope="module")
def clean_steps():
    return prepare_training(generate_corpus(60, PropHumanConfig(), seed=11))


@pytest.fixture(scope="module")
def fallacy_steps():
    return prepare_training(generate_corpus(100, PropHumanConfig(fallacy_rate=0.3), seed=0))


def test_normalize_step_abstracts_the_shared_context():
    base, core = normalize_step([seq("r, p |- q")], seq("r |- p -> q"))
    assert base == frozenset([parse_formula("r")])
    assert str(core) == "step(seq(ctx(p), q), seq(ctx, imp(p, q)))"


def test_tagged_learner_recovers_the_target_calculus(clean_steps):
    calc = SeqLearner(key_mode="tag").fit(steps=clean_steps)
    assert not unsound_active(calc)
    rep = recovery_report(calc)
    assert sum(v in ("exact", "guard_stronger") for v in rep.values()) == len(CLASSICAL_RULES), rep
    assert sum(v == "exact" for v in rep.values()) >= 9, rep
    # every active rule is an instance of a target rule (or of a derived rule)
    assert all(rule_sound(lr.rule) for lr in calc.active())


def test_conservative_verifier_acceptance(clean_steps):
    calc = SeqLearner(key_mode="tag").fit(steps=clean_steps)
    sets = heldout_steps(seed=0, n=80)
    rates = acceptance_rates(calc.accepts, sets)
    assert rates["valid_id"] > 0.9
    assert rates["invalid"] < 0.05


def test_fallacies_survive_positive_learning_and_coherence_removes_them(fallacy_steps):
    learner = SeqLearner(key_mode="tag")
    calc = learner.fit(steps=fallacy_steps)
    assert fallacy_report(calc)["AC"]["status"] == "survived"
    pr = CoherencePruner(calc, PruneConfig(seed=0), learner)
    pr.run()
    assert not unsound_active(calc)
    assert fallacy_report(calc)["AC"]["status"] == "removed"
    rep = recovery_report(calc)
    assert sum(v in ("exact", "guard_stronger") for v in rep.values()) == len(CLASSICAL_RULES), rep


def test_world_feedback_pruning(fallacy_steps):
    learner = SeqLearner(key_mode="tag")
    calc = learner.fit(steps=fallacy_steps)
    pr = CoherencePruner(calc, PruneConfig(seed=0, use_world=True, n_world=1), learner)
    pr.run()
    assert not unsound_active(calc)
    assert pr.queries > 0


def test_aggressive_anti_unification_produces_tonk_and_coherence_repairs_it(clean_steps):
    learner = SeqLearner(key_mode="coarse", cluster="lgg")
    calc = learner.fit(steps=clean_steps)
    assert any(tonk_like(lr.rule) for lr in calc.active())
    att = adversarial_attack(calc, seed=0, n_random=4, budget=500)
    assert att["derives_bottom"]
    CoherencePruner(calc, PruneConfig(seed=0), learner).run()
    assert not any(tonk_like(lr.rule) for lr in calc.active())


def test_post_probes_cover_both_truth_values():
    r = parse_rule("G, $D |- A / G |- A | B")
    ps = post_probes(r, random.Random(0), max_probes=16)
    assert len(ps) == 8
    assert {str(p["D"]) for p in ps} == {"ctx", "ctx(bot)"}


def test_bold_learner_post_completeness():
    bold = BoldLearner([(r.name, r) for r in CLASSICAL_RULES])
    bad = bold.offer([("pq", parse_rule("/ G |- A -> B"))])
    assert not bad["accepted"] and bad["proof"] is not None
    good = bold.offer([("peirce", parse_rule("/ G |- ((A -> B) -> A) -> A"))])
    assert good["accepted"]
    nonstructural = bold.offer([("p", parse_rule("/ G |- p"))])
    assert nonstructural["accepted"]          # coherent with the empty context: structurality matters


def test_bold_learner_tonk_is_order_dependent():
    base = [(r.name, r) for r in CLASSICAL_RULES]
    b1 = BoldLearner(base)
    assert b1.offer([("tonkI", TONK_I)])["accepted"]
    assert not b1.offer([("tonkE", TONK_E)])["accepted"]
    b2 = BoldLearner(base)
    assert b2.offer([("tonkE", TONK_E)])["accepted"]
    assert not b2.offer([("tonkI", TONK_I)])["accepted"]


def test_intuitionistic_base_accepts_excluded_middle():
    bold = BoldLearner([(r.name, r) for r in INTUITIONISTIC_RULES])
    lem = parse_rule("/ G |- A | ~A")
    assert kripke_countermodel(lem) is not None          # not intuitionistically derivable
    assert bold.offer([("lem", lem)])["accepted"]          # but coherent
    assert not bold.offer([("pq", parse_rule("/ G |- A -> B"))])["accepted"]


def test_min_weight_hitting_set_is_exact():
    bags = [{1, 2}, {2, 3}, {3, 4}, {1, 4}]
    assert sorted(min_weight_hitting_set(bags, {1: 1, 2: 10, 3: 1, 4: 10})) == [1, 3]
    assert sorted(min_weight_hitting_set(bags, {1: 10, 2: 1, 3: 10, 4: 1})) == [2, 4]
    assert min_weight_hitting_set([{5}], {}) == [5]


def test_untagged_bucket_key_separates_rule_shapes(clean_steps):
    from collections import Counter
    keys = {}
    for h in clean_steps:
        keys.setdefault(h.tag, Counter())[bucket_key(h, "abstract")] += 1
    top = {t: c.most_common(1)[0][0] for t, c in keys.items()}
    # the typical key of each rule is distinct (accidental collisions such as A | A aside)
    assert len(set(top.values())) == len(top)
