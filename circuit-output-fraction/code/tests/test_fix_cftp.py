"""Regression tests for certified telescoping (cftp.py) and the clause
probabilities of janson.py: stage guarantees below 1/2, repeated literals,
p = 0, an empty CNF, unordered Delta, and floating-point rounding of the
Harris bound and of the interval ends, including below the normal range."""

import math
import os
import sys
from decimal import Decimal, localcontext
from fractions import Fraction

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from rareprob import Product, exact_prob  # noqa: E402
from rareprob.cftp import UnateSystem, _stat_interval, telescoping_estimate  # noqa: E402
from rareprob.janson import cnf_circuit, exp_down, exp_up, janson_interval  # noqa: E402


def exact_contains(e, p: Fraction) -> bool:
    return Fraction(e.lo) <= p <= Fraction(e.hi)


def test_unit_clauses_low_ratio_coverage():
    """10 unit clauses with q = 0.02: every stage ratio is 0.02 < 1/2. The old
    code assumed r_k >= 1/2 and returned hi < p in most runs; its Harris clamp
    also exceeded p by rounding."""
    n = 10
    cl = [[(i, 1)] for i in range(n)]
    D = Product(np.full(n, 0.02))
    p = Fraction(0.02) ** n
    S = UnateSystem(cl, D)
    assert len(S.stages()) == n
    assert Fraction(S.harris_lower(range(n))) <= p
    rng = np.random.default_rng(5)
    for _ in range(4):
        e = telescoping_estimate(cl, D, delta=0.05, N=200, rng=rng)
        assert exact_contains(e, p), (e.lo, e.hi, float(p))


def test_low_ratio_nontrivial_intervals():
    """Stage guarantees 0.05: the intervals are non-trivial and cover p."""
    n = 4
    cl = [[(i, 1)] for i in range(n)]
    D = Product(np.full(n, 0.05))
    p = Fraction(0.05) ** n
    rng = np.random.default_rng(6)
    for _ in range(6):
        e = telescoping_estimate(cl, D, delta=0.05, N=2000, rng=rng)
        assert exact_contains(e, p), (e.lo, e.hi, float(p))
        assert e.hi < 1.0 and e.lo > 0


def test_stage_guarantees_below_half():
    """A clause with D(B_c) > 1/2 is a stage of its own, and every stage
    guarantee is a lower bound on the true ratio."""
    n = 6
    cl = [[(i, 0), (i + 1, 0)] for i in range(n - 1)]
    D = Product(np.full(n, 0.8))  # D(B_c) = 0.64
    S = UnateSystem(cl, D)
    st = S.stages()
    assert all(len(s) == 1 for s in st)
    for k, s in enumerate(st):
        prev = [c for t in st[:k] for c in t]
        num = exact_prob(cnf_circuit(n, [cl[c] for c in prev + s]), D)
        den = exact_prob(cnf_circuit(n, [cl[c] for c in prev]), D) if prev else 1.0
        assert S.harris_lower(s) <= num / den
        assert S.harris_lower(s) <= 0.36


def test_repeated_literals():
    """(x0 v x0) & (x1 v x1 v x2) has p = 3/8; counting the repeated literal
    twice made both procedures return intervals excluding p."""
    cl = [[(0, 0), (0, 0)], [(1, 0), (1, 0), (2, 0)]]
    D = Product(np.array([0.5, 0.5, 0.5]))
    p = exact_prob(cnf_circuit(3, cl), D)
    assert abs(p - 0.375) < 1e-12
    S = UnateSystem(cl, D)
    assert np.allclose(S.pb, [0.5, 0.25])
    j = janson_interval(cl, D)
    assert j.lo <= p <= j.hi
    e = telescoping_estimate(cl, D, N=400, rng=np.random.default_rng(0))
    assert e.lo <= p <= e.hi


def test_p_zero_and_tiny_marginals():
    """A clause false with probability 1 gives the exact [0, 0]; a literal whose
    probability is positive but rounds 1 - q to 1 must not give lo > p."""
    D = Product(np.array([0.0, 0.3]))
    e = telescoping_estimate([[(0, 1)], [(1, 0)]], D, N=100, rng=np.random.default_rng(1))
    assert e.lo == 0.0 and e.hi == 0.0
    D = Product(np.array([1e-20, 0.3]))
    p = 1e-20 * 0.7
    e = telescoping_estimate([[(0, 1)], [(1, 0)]], D, N=100, rng=np.random.default_rng(1))
    assert e.lo <= p <= e.hi


def test_janson_still_matches_on_distinct_literals():
    """Deduplication leaves clauses without repeats unchanged."""
    rng = np.random.default_rng(7)
    n = 10
    cl = [[(int(i), 0) for i in rng.choice(n, 3, replace=False)] for _ in range(6)]
    D = Product(rng.uniform(0.2, 0.6, n))
    p = exact_prob(cnf_circuit(n, cl), D)
    j = janson_interval(cl, D)
    assert j.lo <= p <= j.hi
    M = math.prod(1 - math.prod(D.q[i] for i, _ in c) for c in cl)
    assert abs(j.lo - M) <= 1e-9 * M


def test_empty_cnf():
    """No clauses: p = 1 (K = 0 used to crash on h.min())."""
    D = Product.uniform(3)
    e = telescoping_estimate([], D, N=10, rng=np.random.default_rng(2))
    assert e.lo == e.hi == 1.0
    j = janson_interval([], D)
    assert 0 < j.lo <= 1.0 <= j.hi


def test_janson_delta_unordered():
    """(x0 v x1) & (x1 v x2), uniform: one dependent pair, D(B_1 & B_2) = 1/8."""
    j = janson_interval([[(0, 1), (1, 1)], [(1, 1), (2, 1)]], Product.uniform(3))
    assert "Delta=0.125," in j.note
    assert j.lo <= 0.625 <= j.hi


def _subnormal_unit_clauses(units: float):
    """1061 disjoint unit clauses (x_i) with q = [0.5]*1060 + [q_last] and
    p = prod q = units * 2^-1074, below the normal range; Harris is tight."""
    q_last = float(Fraction(units) * Fraction(2) ** -14)
    q = np.array([0.5] * 1060 + [q_last])
    p = math.prod(Fraction(float(x)) for x in q)
    return [[(i, 1)] for i in range(1061)], Product(q), p


def test_subnormal_harris_and_janson():
    """exp(s)(1 -+ slack) rounded to the subnormal grid crossed p: at
    p = 12.8 * 2^-1074 the Harris bound and Janson's lower end were 13 * 2^-1074,
    at 13.4 * 2^-1074 Janson's upper end was 13 * 2^-1074."""
    for units in (12.8, 13.4, 13.6, 2.6, 0.6, 1000.4):
        cl, D, p = _subnormal_unit_clauses(units)
        assert Fraction(UnateSystem(cl, D).harris_lower(range(len(cl)))) <= p
        j = janson_interval(cl, D)
        assert Fraction(j.lo) <= p <= Fraction(j.hi), (units, j.lo, j.hi)


def test_exp_bounds_and_statistical_ends():
    """exp_down/exp_up and the statistical interval of telescoping_estimate
    against 60-digit decimal arithmetic, across the subnormal range."""
    rng = np.random.default_rng(3)
    meds = [math.log(12.8) - 1074 * math.log(2)]
    meds += list(-rng.uniform(690, 760, 400)) + list(-rng.uniform(0, 50, 100))
    with localcontext() as ctx:
        ctx.prec = 60
        for med in meds:
            med = float(med)
            x = Decimal(med).exp()
            assert Decimal(exp_down(med)) <= x <= Decimal(exp_up(med)) and exp_up(med) > 0
            for b, eps0, kap in ((0.0, 0.0, 0.0), (0.01, 0.3, 2.0 ** -40), (0.0, 1 - 2.0 ** -40, 0.0)):
                lo, hi = _stat_interval(med, b, eps0, kap)
                tlo = (Decimal(med) - Decimal(b) - Decimal(kap)).exp() / (1 + Decimal(eps0))
                thi = min(Decimal(1), (Decimal(med) + Decimal(b) + Decimal(kap)).exp() / (1 - Decimal(eps0)))
                assert Decimal(lo) <= tlo and Decimal(hi) >= thi > 0, (med, b, eps0, lo, hi)
