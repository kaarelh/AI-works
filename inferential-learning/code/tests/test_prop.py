import random

import pytest

from cil.domains.prop import (BOT, CLASSICAL_RULES, FALLACY_RULES, INTUITIONISTIC_RULES, TARGET_BY_NAME, TONK_E, TONK_I,
                              HumanProver, MemGuard, PropHumanConfig, PropWorld, Prover, Seq, SeqRule,
                              designated_contexts, fmt, format_proof, generate_corpus, kripke_countermodel,
                              kripke_valid_formula, licenses, local_sound_step, match_step, parse_formula, parse_rule,
                              proof_steps, random_formula, random_tautologies, rule_sound, satisfiable, seq,
                              tonk_interpretable, valid)


def test_formula_parse_print_roundtrip():
    rng = random.Random(0)
    for _ in range(300):
        f = random_formula(rng, rng.randint(0, 6), ("p", "q", "r"))
        assert parse_formula(fmt(f)) == f
    assert fmt(parse_formula("(A -> B) -> ~A | B & C")) == "(A -> B) -> ~A | B & C"
    assert fmt(parse_formula("A -> B -> C")) == "A -> B -> C"
    assert parse_formula("A -> B -> C") == parse_formula("A -> (B -> C)")


def test_rule_parse_print_roundtrip():
    for r in CLASSICAL_RULES + [f for f, _ in FALLACY_RULES.values()] + [TONK_I, TONK_E]:
        assert parse_rule(str(r)).key() == r.key()
    r = parse_rule("G, $D |- A / G |- B -> A [mem B, mem ~A]")
    assert r.set_vars() == ["D"] and set(r.formula_vars()) == {"A", "B"}
    assert parse_rule(str(r)).key() == r.key()


def test_classical_semantics_of_rules():
    assert all(rule_sound(r) for r in CLASSICAL_RULES)
    assert not any(rule_sound(f) for f, _ in FALLACY_RULES.values())
    assert not rule_sound(parse_rule("/ G |- A"))                    # unguarded assumption rule
    assert rule_sound(parse_rule("/ G |- ~A [mem ~A]"))
    assert not rule_sound(parse_rule("G, A |- B / G |- B"))          # dropping an assumption
    assert rule_sound(parse_rule("G |- B / G, A |- B"))              # weakening
    assert not rule_sound(parse_rule("G, $D |- B / G |- A -> B"))     # arbitrary extra assumptions
    assert not rule_sound(parse_rule("/ G |- p"))                    # non-structural axiom
    assert valid([], parse_formula("((p -> q) -> p) -> p"))
    assert not valid([parse_formula("p | q")], parse_formula("p"))
    assert satisfiable([parse_formula("p"), parse_formula("~q")])


def test_kripke_semantics_separates_ipc_from_cpc():
    for r in INTUITIONISTIC_RULES:
        assert kripke_countermodel(r) is None, str(r)
    assert kripke_countermodel(TARGET_BY_NAME["raa"]) is not None
    assert not kripke_valid_formula(parse_formula("~~p -> p"))
    assert not kripke_valid_formula(parse_formula("p | ~p"))
    assert not kripke_valid_formula(parse_formula("((p -> q) -> p) -> p"))
    assert kripke_valid_formula(parse_formula("p -> ~~p"))
    assert kripke_valid_formula(parse_formula("~~(p | ~p)"))


def test_tonk_has_no_truth_table():
    assert tonk_interpretable([TONK_I]) is not None
    assert tonk_interpretable([TONK_E]) is not None
    assert tonk_interpretable([TONK_I, TONK_E]) is None


def test_matching_uses_set_semantics_for_contexts():
    impI = TARGET_BY_NAME["impI"]
    # discharged formula already in the context: still an instance of ->I
    assert match_step(impI, [seq("p, q |- q")], seq("p, q |- p -> q")) is not None
    assert match_step(impI, [seq("p, q |- q")], seq("q |- p -> q")) is not None
    assert match_step(impI, [seq("q |- q")], seq("|- p -> q")) is None
    ax = TARGET_BY_NAME["ax"]
    assert match_step(ax, [], seq("p, q |- q")) is not None
    assert match_step(ax, [], seq("p |- q")) is None
    andI = TARGET_BY_NAME["andI"]
    assert licenses(andI, [seq("r |- q"), seq("r |- p")], seq("r |- p & q")) is not None   # any premise order


def test_human_corpus_valid_steps_are_target_instances():
    ds = generate_corpus(40, PropHumanConfig(), seed=3)
    n = 0
    for d in ds:
        assert valid([], d.goal)
        for st in d.steps:
            assert match_step(TARGET_BY_NAME[st.tag], st.prems, st.concl) is not None, str(st)
            assert local_sound_step(st.prems, st.concl)
            n += 1
    assert n > 500


def test_human_corpus_fallacies_and_noise():
    ds = generate_corpus(150, PropHumanConfig(fallacy_rate=0.5, noise_rate=0.05), seed=4)
    kinds = {}
    for d in ds:
        for st in d.steps:
            kinds[st.kind] = kinds.get(st.kind, 0) + 1
            if st.kind.startswith("fallacy:"):
                name = st.kind.split(":")[1]
                assert match_step(FALLACY_RULES[name][0], st.prems, st.concl) is not None
    assert {"fallacy:AC", "fallacy:DA", "fallacy:ID", "noise"} <= set(kinds)


def test_tableau_construction_is_complete():
    hp = HumanProver(PropHumanConfig(), random.Random(0))
    for f in random_tautologies(40, seed=1, conn_range=(2, 8)):
        node = hp.tprove(frozenset(), f)
        assert node.seq == Seq((), f)
        for st in proof_steps(node):
            assert match_step(TARGET_BY_NAME[st.tag], st.prems, st.concl) is not None


def test_prover_derivations_are_rule_instances():
    pr = Prover([(r.name, r) for r in CLASSICAL_RULES], budget=3000, max_depth=12)
    proved = 0
    for f in random_tautologies(25, seed=2, conn_range=(2, 5)):
        node = pr.prove(Seq((), f))
        if node is None:
            continue
        proved += 1
        for st in proof_steps(node):
            assert match_step(TARGET_BY_NAME[st.tag], st.prems, st.concl) is not None
    assert proved >= 20
    assert pr.prove(seq("|- p")) is None
    assert pr.prove(seq("|- bot")) is None
    peirce = pr.prove(Seq((), parse_formula("((p -> q) -> p) -> p")))
    assert peirce is not None and "raa" in format_proof(peirce)


def test_prover_with_unsound_rule_derives_bottom():
    ac = FALLACY_RULES["AC"][0]
    pr = Prover([(r.name, r) for r in CLASSICAL_RULES] + [("AC", ac)], budget=3000, max_depth=10)
    # blind search from the empty context needs a suitable closed formula in its pool
    # (this is what the Post probes of the coherence search supply)
    node = pr.prove(seq("|- bot"), extra_pool=[parse_formula("bot -> ~bot")])
    assert node is not None
    assert any(st.tag == "AC" for st in proof_steps(node))


def test_world_oracle_is_one_sided():
    w = PropWorld(n_obs=2, seed=0)
    # a valid step is never refuted; a refutation is always genuine
    rng = random.Random(0)
    ds = generate_corpus(10, PropHumanConfig(), seed=5)
    for d in ds:
        for st in d.steps:
            assert w.step_refuted(st.prems, st.concl) is None
    for _ in range(200):
        s = Seq([random_formula(rng, 1)], random_formula(rng, 2))
        if w.sequent_refuted(s) is not None:
            assert not valid(s.ctx, s.succ)


def test_designated_contexts_are_satisfiable():
    ds = designated_contexts(6, seed=0)
    assert ds[0] == frozenset()
    assert all(satisfiable(G) for G in ds)
