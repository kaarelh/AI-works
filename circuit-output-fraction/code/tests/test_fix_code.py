"""Regression tests for the code-soundness review (round 1)."""

import numpy as np
import pytest

from rareprob import Product, exact_prob
from rareprob.families import threshold_of_blocks
from rareprob.meta import as_block_threshold
from rareprob.rup import RUPChecker
from rareprob.stats import sequential_mean
from rareprob.tilting import tilted_estimate


class _ShapeShifter(list):
    """Shows [1, -1] to the first iteration and [] afterwards."""

    def __init__(self):
        super().__init__([1, -1])
        self.n = 0

    def __iter__(self):
        self.n += 1
        return iter([1, -1] if self.n == 1 else [])

    def __len__(self):
        return 0 if self.n > 1 else 2


def test_rup_snapshots_steps():
    ch = RUPChecker([[1, 2], [-1, 2]])  # satisfiable
    assert not ch.check_refutation([_ShapeShifter()])
    ch = RUPChecker([[1, 2], [-1, 2]])
    assert not ch.check_refutation([[1, "x"]])


def test_sequential_mean_rejects_out_of_range():
    with pytest.raises(ValueError):
        sequential_mean(lambda k: np.full(k, np.inf), 0.1, 0.05, max_samples=2048)


def test_tilting_boundary_threshold_contains_p():
    """t = number of blocks: W = 1 a.s., the interval's upper end is the
    Chernoff mass itself and must be rounded upwards."""
    rng = np.random.default_rng(5)
    for _ in range(30):
        k = int(rng.integers(3, 7))
        C, _ = threshold_of_blocks(k, 3, 4, float(k), rng)
        D = Product.uniform(C.n)
        p = exact_prob(C, D)
        if p == 0:
            continue
        blocks, t = as_block_threshold(C)
        e = tilted_estimate(blocks, t, D, C.n, eps=0.1, delta=0.05, rng=rng)
        assert e.lo <= p <= e.hi
