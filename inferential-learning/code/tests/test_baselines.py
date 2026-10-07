import os

os.environ.setdefault("OMP_NUM_THREADS", "1")

import numpy as np
import pytest

from cil.baselines import (StatisticalVerifier, StepFeaturizer, _sym, _tokens, binary_metrics, build_step_dataset,
                           calibrate_threshold, roc_auc)
from cil.domains.algebra import ALGEBRA, HumanConfig, WorldOracle, generate_corpus
from cil.learners import prepare_training
from cil.terms import parse


def test_symbol_abstraction():
    assert _sym(parse("x")) == "atom"
    assert _sym(parse("2")) == "2"
    assert _sym(parse("17")) == "N"
    assert _sym(parse("x + 1")) == "+"


def test_tokens_count_every_node():
    t = parse("x*(y + 2)")
    c = _tokens(t)
    assert sum(v for k, v in c.items() if k.startswith("u:")) == t.size
    assert c["s:*(atom,+)"] == 1 and c["s:+(atom,2)"] == 1


def test_featurizer_shape_and_determinism():
    F = StepFeaturizer(256)
    steps = [(parse("x*(y + 2)"), parse("x*y + x*2"), frozenset()),
             (parse("sqrt(x^2)"), parse("x"), frozenset({("nonneg", parse("x"))}))]
    A = F.transform(steps).toarray()
    B = F.transform(steps).toarray()
    assert A.shape == (2, F.n_features)
    assert np.array_equal(A, B)
    # a reflexive step has an all-zero feature vector
    assert not F.transform([(parse("x"), parse("x"), frozenset())]).toarray().any()


def test_transform_both_matches_reversed_steps():
    F = StepFeaturizer(256)
    steps = [(parse("(a + b)/(c + d)"), parse("a/c + b/d"), frozenset()),
             (parse("1 + x*(y + 2)"), parse("1 + (x*y + x*2)"), frozenset({("nonzero", parse("x"))}))]
    both = F.transform_both(steps).toarray()
    sep = F.transform([s for b, a, f in steps for s in ((b, a, f), (a, b, f))]).toarray()
    assert np.array_equal(both, sep)


def test_binary_metrics_and_calibration():
    scores = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2]
    labels = [1, 1, 0, 1, 1, 0, 0, 0]
    m = binary_metrics(scores, labels, 0.65)
    assert m["tpr"] == 0.5 and m["fpr"] == 0.25 and m["tp"] == 2 and m["fp"] == 1
    tau = calibrate_threshold(scores, labels, 1.0)
    assert tau == 0.8                        # lowest threshold with no false accept
    assert binary_metrics(scores, labels, tau)["fpr"] == 0
    tau90 = calibrate_threshold(scores, labels, 0.75)
    assert binary_metrics(scores, labels, tau90)["balanced_precision"] >= 0.75
    assert tau90 <= tau
    assert roc_auc(scores, labels) == pytest.approx(0.875)


@pytest.fixture(scope="module")
def small_data():
    cfg = HumanConfig(noise_rate=0.05, fallacy_rate=0.3)
    tr = prepare_training(generate_corpus(60, cfg, seed=3), ALGEBRA)
    te = prepare_training(generate_corpus(40, cfg, seed=4), ALGEBRA)
    lab = WorldOracle(seed=1, n_points=20)
    return (build_step_dataset(tr, lab, seed=0, n_fallacy=20),
            build_step_dataset(te, lab, seed=1, n_fallacy=10))


def test_dataset_labels_are_oracle_consistent(small_data):
    train, _ = small_data
    lab = WorldOracle(seed=99, n_points=30)
    assert any(e.label == 1 for e in train) and any(e.label == 0 for e in train)
    for e in train[:80]:
        if e.source in ("perturb_any", "perturb_core", "fallacy_inst"):
            assert e.label == 0
        if e.label == 0:
            # a negative label is a certain refutation: some point separates the two sides
            assert lab.counterexample(e.before, e.after, e.facts, n=200) is not None or e.source.startswith("human")
    assert all(e.label == 1 for e in train if e.source == "human:valid")


@pytest.mark.parametrize("model", ["logreg", "gboost"])
def test_statistical_verifier_learns_in_distribution(small_data, model):
    train, test = small_data
    v = StatisticalVerifier(model, seed=0, n_hash=256).fit(train)
    s = v.score_batch([(e.before, e.after, e.facts) for e in test])
    assert roc_auc(s, [e.label for e in test]) > 0.75
    # edge scores are symmetric and cached; thresholds are views sharing the model
    u, w = test[0].before, test[0].after
    e1 = v.edge_scores(u, [w])[0]
    e2 = v.edge_scores(w, [u])[0]
    assert e1 == e2 == max(v.score(u, w), v.score(w, u))
    strict = v.with_threshold(1.01)
    assert strict.clf is v.clf and not strict.accepts(parse("x*y"), parse("x + y"))
    assert strict.accepts(parse("x + 2*3"), parse("x + 6"))      # trusted arithmetic is built in
