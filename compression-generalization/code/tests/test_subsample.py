"""Tests for unit subsampling (cgb/subsample.py): the Maurey identity
E_I ||g - f||^2 = (A^2 - ||f - c||^2) / k on an empirical distribution, the top-k
refit guarantee, and the update version."""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from cgb import subsample as ss  # noqa: E402
from cgb.models import np_forward  # noqa: E402


def _net(rng, n=20, N=300, C=1):
    W = rng.standard_normal((N, n)) / np.sqrt(n)
    b = rng.standard_normal(N) * 0.1
    V = rng.standard_normal((C, N)) * 3 / N
    c = np.full(C, 0.2)
    return [(W, b), (V, c)]


def test_maurey_identity():
    rng = np.random.default_rng(0)
    w = _net(rng)
    X = rng.choice([-1.0, 1.0], size=(3000, 20))
    f = np_forward(w, X)
    A = ss.path_norm(w[1][0], ss.relu_features(*w[0], X))
    pred = (A ** 2 - np.mean(np.sum((f - w[1][1]) ** 2, 1)))
    for k in (5, 40):
        errs = [np.mean(np.sum((np_forward(ss.subsample_one_layer(w, k, X, np.random.default_rng(r), "maurey",
                                                                  refit=False)[0], X) - f) ** 2, 1))
                for r in range(2000)]
        se = np.std(errs) / np.sqrt(len(errs))
        assert abs(np.mean(errs) - pred / k) < 4 * se + 1e-3 * pred / k, (k, np.mean(errs), pred / k)


def test_maurey_identity_multiclass():
    rng = np.random.default_rng(1)
    w = _net(rng, C=4)
    X = rng.choice([-1.0, 1.0], size=(2000, 20))
    f = np_forward(w, X)
    A = ss.path_norm(w[1][0], ss.relu_features(*w[0], X))
    pred = (A ** 2 - np.mean(np.sum((f - w[1][1]) ** 2, 1))) / 10
    errs = [np.mean(np.sum((np_forward(ss.subsample_one_layer(w, 10, X, np.random.default_rng(r), "maurey",
                                                              refit=False)[0], X) - f) ** 2, 1)) for r in range(2000)]
    se = np.std(errs) / np.sqrt(len(errs))
    assert abs(np.mean(errs) - pred) < 4 * se + 1e-3 * pred


def test_topk_refit_tail_guarantee():
    rng = np.random.default_rng(2)
    w = _net(rng)
    X = rng.choice([-1.0, 1.0], size=(3000, 20))
    f = np_forward(w, X)
    s = ss.unit_importance(w[1][0], ss.relu_features(*w[0], X))
    for k in (5, 30, 100):
        g, idx, _ = ss.subsample_one_layer(w, k, X, rng, "topk", refit=True)
        tail = np.sort(s)[::-1][k:].sum()
        assert np.mean((np_forward(g, X) - f) ** 2) <= tail ** 2 * (1 + 1e-6) + 1e-12


def test_update_identity_and_exact_at_full_width():
    rng = np.random.default_rng(3)
    w0 = _net(rng)
    (W, b), (V, c) = w0
    w = [(W + 0.3 * rng.standard_normal(W.shape) / np.sqrt(W.shape[1]), b), (V + rng.standard_normal(V.shape) / 300, c + 0.1)]
    X = rng.choice([-1.0, 1.0], size=(2000, 20))
    f = np_forward(w, X)
    lg, idx, info = ss.subsample_update(w, w0, 300, X, rng, "topk", refit=True)
    assert np.max(np.abs(lg(X) - f)) < 1e-6        # keeping every unit and refitting reproduces f


if __name__ == "__main__":
    for t in [test_maurey_identity, test_maurey_identity_multiclass, test_topk_refit_tail_guarantee,
              test_update_identity_and_exact_at_full_width]:
        t()
        print(t.__name__, "ok")
