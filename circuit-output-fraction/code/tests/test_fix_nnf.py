"""Threshold gates with integer weights of either sign expand into the NNF."""

import itertools

import numpy as np

from rareprob import Circuit
from rareprob.nnf import to_nnf


def test_negative_integer_threshold_weights_expand_exactly():
    rng = np.random.default_rng(3)
    for _ in range(60):
        n = int(rng.integers(2, 7))
        C = Circuit(n)
        k = int(rng.integers(1, n + 1))
        ins = [C.lit(int(i), int(rng.integers(0, 2))) for i in rng.choice(n, size=k, replace=False)]
        w = [float(rng.integers(-4, 5)) for _ in range(k)]
        t = float(rng.integers(-6, 7)) + float(rng.choice([0.0, 0.5, 5e-10, -5e-10]))
        C.set_output(C.THR(ins, w, t))
        N = to_nnf(C, small_cone=0)
        assert all(N.kind[g] != "X" for g in N.cone(N.root))  # expanded, not opaque
        X = np.array(list(itertools.product([0, 1], repeat=n)), dtype=bool)
        assert (N.eval_batch(X, N.root) == C.eval_bits(X)).all()
