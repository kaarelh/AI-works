"""Exact threshold semantics and CONST normalisation (final referee round).

A threshold gate computes [sum_j w_j y_j >= t] in exact rational arithmetic
(a float weight or threshold at its exact binary value), and a CONST gate is
0 or 1. Every module (evaluator, VE, NNF, tilting, local thresholds, affine
propagation, CNF encodings) must agree with that function. Also: the tilting
domination bug at t = m + 1e-13, the tilt search beyond theta = 50, capped
upper ends, TG's overflow and floating-point allowances, cyclic XPT arguments,
gate-by-gate NNFs, and the proposal lower bound against untrusted proposals.
"""

import itertools
import math
from fractions import Fraction

import numpy as np
import pytest

from rareprob import Circuit, Product
from rareprob.affine import Affine, Propagator, presolve_estimate, xpt_check, xpt_verify
from rareprob.circuit import as_rational, const_value, thr_canonical
from rareprob.cnf import affine_conjuncts, tseitin
from rareprob.ctxwidth import context_width
from rareprob.exact import eval_reference, exact_prob_rational
from rareprob.localthr import LTC, LocalModel, _thr_count_threshold, ltc_from_circuit, tg_estimate
from rareprob.meta import as_block_threshold, meta_estimate
from rareprob.nnf import to_nnf
from rareprob.tilting import Block, best_theta, proposal_lower_bound, tilted_estimate
from rareprob.ve import ve_bounds


def points(n):
    return ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)


def fires_exact(w, t, y):
    """[sum_j w_j y_j >= t] with every number at its exact rational value."""
    return int(sum(as_rational(wi) for wi, b in zip(w, y) if b) >= as_rational(t))


def thr_circuit(w, t):
    C = Circuit(len(w))
    return C.set_output(C.THR(list(range(len(w))), w, t))


def contains(e, P):
    return Fraction(e.lo) <= P <= Fraction(e.hi)


# ------------------------------------------------------------ the evaluator
@pytest.mark.parametrize("w,t,want", [
    ((10**20, 1, -10**20), 1, Fraction(1, 2)),           # sum of doubles loses the 1 (gave 3/8)
    ((1.0, 1.0, 1.0), 3 + 1e-13, Fraction(0)),           # inside the old 1e-12 tolerance (gave 1/8)
    ((0.1, 0.2), 0.30000000000000004, Fraction(0)),      # 0.1 + 0.2 < t exactly (gave 1/4)
    ((0.1, 0.2), 0.3, Fraction(1, 4)),                   # 0.1 + 0.2 > the double 0.3
    ((2**60, 1), 2**60 + 1, Fraction(1, 4)),             # t was coerced to the double 2^60
    ((1e16, 1.0, -1e16), 0.5, Fraction(1, 2)),           # left-to-right double sum gave 3/8
])
def test_referee_reproductions_exact(w, t, want):
    C = thr_circuit(w, t)
    X = points(len(w))
    assert [int(b) for b in C.eval_bits(X)] == [fires_exact(w, t, y) for y in X]
    assert exact_prob_rational(C) == want
    D = Product.uniform(C.n)
    r = ve_bounds(C, D)
    if want == 0:
        assert r.zero
    else:
        lo, hi = r.interval()
        assert Fraction(lo) <= want <= Fraction(hi)
    e = meta_estimate(C, D, eps=0.1, delta=0.05, rng=np.random.default_rng(0))
    assert contains(e, want)


def test_and_of_thresholds_just_above_one():
    """AND of 30 gates [x_i >= 1 + 1e-13]: p = 0 (the old tolerance gave 2^-30)."""
    C = Circuit(30)
    C.set_output(C.AND(*[C.THR([i], [1], 1 + 1e-13) for i in range(30)]))
    e = meta_estimate(C, Product.uniform(30), eps=0.1, delta=0.05, rng=np.random.default_rng(1))
    assert e.lo == e.hi == 0.0


def test_canonical_form_is_exact_and_idempotent():
    rng = np.random.default_rng(2)
    pool = [0, 1, -1, 3, 0.5, -0.25, 0.1, 0.2, 0.3, 1e-17, 1e16, -1e16, 2.0**53, 10**20, -10**20,
            Fraction(1, 3), Fraction(-2, 7), np.int64(5), np.float64(0.7), True]
    tpool = pool + [0.30000000000000004, 20 + 1e-13, -1e300, 1e300, Fraction(5, 3)]
    for _ in range(400):
        k = int(rng.integers(1, 6))
        w = [pool[int(rng.integers(len(pool)))] for _ in range(k)]
        t = tpool[int(rng.integers(len(tpool)))]
        W, T = thr_canonical(w, t)
        assert all(type(x) is int for x in W) and type(T) is int
        assert math.gcd(*W) in (0, 1)
        assert sum(x for x in W if x < 0) <= T <= sum(x for x in W if x > 0) + 1
        assert thr_canonical(W, T) == (W, T)
        for y in itertools.product((0, 1), repeat=k):
            assert int(sum(x for x, b in zip(W, y) if b) >= T) == fires_exact(w, t, y)


def test_infinite_and_invalid_parameters():
    assert thr_canonical([1, 2], math.inf) == ((0, 0), 1)
    assert thr_canonical([1, 2], -math.inf) == ((0, 0), 0)
    for w, t in (([1, math.nan], 0), ([math.inf, 1], 0), ([1], math.nan), (["1"], 0)):
        with pytest.raises((ValueError, TypeError)):
            thr_canonical(w, t)
    # a THR gate with t = inf is constant 0 and must not crash the NNF expansion
    for m in (12, 30):
        C = Circuit(m)
        C.set_output(C.THR(list(range(m)), [1] * m, math.inf))
        N = to_nnf(C, flatten=False)
        assert N.kind[N.root] == "F"
        e = meta_estimate(C, Product.uniform(m), ve_width=4, rng=np.random.default_rng(3))
        assert e.lo == 0.0


def test_evaluator_paths_agree_with_reference():
    """int64 sums, table lookup (fan-in <= 16, huge weights) and Python
    integers (fan-in > 16, huge weights) against the gate-by-gate reference."""
    rng = np.random.default_rng(4)
    for k, scale in ((5, 1), (5, 10**30), (20, 1), (20, 10**30)):
        for _ in range(4):
            n = k
            w = [int(x) * scale + int(rng.integers(-3, 4)) for x in rng.integers(-5, 6, size=k)]
            t = int(rng.integers(-3, 4)) * scale + int(rng.integers(-2, 3))
            C = thr_circuit(w, t)
            X = rng.integers(0, 2, size=(300, n)).astype(bool)
            got = C.eval_bits(X)
            assert [int(b) for b in got] == [eval_reference(C, x) for x in X]
            assert [int(b) for b in got] == [fires_exact(w, t, x) for x in X]


# ------------------------------------------------------------------- CONST
@pytest.mark.parametrize("b", [2, 0.5, -1, None, "1", 1.5, math.nan])
def test_const_rejects_other_values(b):
    with pytest.raises(ValueError):
        Circuit(1).add("CONST", (), b)
    with pytest.raises(ValueError):
        Circuit(1).const(b)
    with pytest.raises(ValueError):
        Circuit(1, ["IN", "CONST"], [(), ()], [None, b], 1)


def test_const_normalised_everywhere():
    for b, v in ((True, 1), (False, 0), (1.0, 1), (0.0, 0), (np.int64(1), 1), (Fraction(0), 0), (np.bool_(True), 1)):
        C = Circuit(1)
        g = C.add("CONST", (), b)
        assert C.params[g] == v and type(C.params[g]) is int and const_value(b) == v
        C2 = Circuit(1, ["IN", "CONST"], [(), ()], [None, b], 1)
        assert C2.params[1] == v
    # the affine reproductions: AND(CONST 1, MAJ(x0, x1, x2)) and AND(CONST 1, x0), p = 1/2
    C = Circuit(3)
    C.set_output(C.AND(C.add("CONST", (), 1.0), C.THR([0, 1, 2], [1, 1, 1], 2)))
    D = Product.uniform(3)
    e = presolve_estimate(C, D, eps=0.1, delta=0.05, rng=np.random.default_rng(5))
    assert e.lo <= 0.5 <= e.hi
    assert contains(meta_estimate(C, D, rng=np.random.default_rng(6)), Fraction(1, 2))
    C = Circuit(1)
    C.set_output(C.AND(C.const(True), 0))
    e = xpt_verify(C, None, {"leaf": "open"}, rng=np.random.default_rng(7))
    assert e.lo <= 0.5 <= e.hi
    assert [2] in tseitin(C)  # gate 1 (CONST) is variable 2, forced true
    C = Circuit(2)
    C.set_output(C.AND(C.XOR(0, C.const(1)), 1))
    assert (0b1, 0) in affine_conjuncts(C)


# ---------------------------------------------------------------- modules
def test_nnf_counter_uses_scaled_integer_weights():
    """[0.5 x0 + 0.25 x1 + 0.25 x2 >= 0.6] is [2 x0 + x1 + x2 >= 3]: expanded
    exactly (not opaque), and t = m + 1e-13 is ceil(t) = m + 1."""
    for w, t in (([0.5, 0.25, 0.25], 0.6), ([1, 1, 1, 1], 2 + 1e-13), ([3, -2, 1, 1], Fraction(1, 2)),
                 ([10**20, 1, -10**20], 1)):
        C = Circuit(len(w))
        # a NOT on top keeps the gate out of the small-cone tabulation
        C.set_output(C.THR(list(range(len(w))), w, t))
        N = to_nnf(C, small_cone=0)
        X = points(len(w))
        assert np.array_equal(N.eval_batch(X), C.eval_bits(X)), (w, t)
        assert np.array_equal(C.eval_bits(X), [bool(fires_exact(w, t, y)) for y in X])


def test_ve_tables_use_exact_thresholds():
    rng = np.random.default_rng(8)
    for _ in range(30):
        n = 5
        w = [rng.choice([0.1, 0.2, -0.3, 1e16, -1e16, 1.0]) for _ in range(n)]
        t = float(rng.choice([0.3, 0.30000000000000004, 1e16 + 1, 0.0, -0.1]))
        C = thr_circuit([float(x) for x in w], t)
        D = Product(rng.uniform(0.1, 0.9, n))
        P = exact_prob_rational(C, D)
        r = ve_bounds(C, D)
        if r.zero:
            assert P == 0
        else:
            lo, hi = r.interval()
            assert Fraction(lo) <= P <= Fraction(hi)


def test_localthr_threshold_from_integer_form():
    assert _thr_count_threshold(((2, 2, 2), 3), 3) == 2       # (2,2,2; 3) = (1,1,1; 2)
    assert _thr_count_threshold(((1.0,) * 4, 2 + 1e-13), 4) == 3
    assert _thr_count_threshold(((1, 2), 1), 2) is None
    assert _thr_count_threshold(((1, 1), -5), 2) == 0
    assert _thr_count_threshold(((1, 1), 7.5), 2) == 3
    n = 6
    C = Circuit(n)
    C.set_output(C.THR([C.AND(i, (i + 1) % n) for i in range(n)], [2] * n, 3 + 1e-13))
    ltc = ltc_from_circuit(C)
    assert ltc is not None and ltc.t == 2
    X = points(n)
    assert np.array_equal(ltc.C(X), C.eval_bits(X))
    assert LTC(n, ltc.scopes, ltc.tables, Fraction(5, 2)).t == 3
    back = ltc.to_circuit()
    assert np.array_equal(back.eval_bits(X), C.eval_bits(X))


def test_propagator_repeated_child_is_exact():
    """THR(x0, x0, x1; 1, 1, -1; 2) is [2 x0 - x1 >= 2]: firing forces x0 = 1
    and x1 = 0; not firing with x0 = 1 forces x1 = 1."""
    C = Circuit(2)
    g = C.THR([0, 0, 1], [1, 1, -1], 2)
    C.set_output(g)
    P = Propagator(C)
    _, sigma = P.run(Affine(), {g: 1})
    assert sigma[0] == 1 and sigma[1] == 0
    _, sigma = P.run(Affine(), {g: 0, 0: 1})
    assert sigma[1] == 1


# ----------------------------------------------------------------- tilting
def _or_blocks(k, t, q=None):
    C = Circuit(2 * k)
    C.set_output(C.THR([C.OR(2 * j, 2 * j + 1) for j in range(k)], [1] * k, t))
    D = Product.uniform(2 * k) if q is None else Product(q)
    return C, D


def test_tilting_threshold_just_above_integer():
    """t = m + 1e-13: the gate fires iff S >= m + 1, so p = 0 when m is the
    number of blocks; at t = m the interval contains p (the old code missed
    it deterministically)."""
    rng = np.random.default_rng(9)
    for k in (2, 5):
        C = Circuit(k)
        C.set_output(C.THR(list(range(k)), [1] * k, k + 1e-13))
        blocks, t = as_block_threshold(C)
        assert t == k + 1
        e = tilted_estimate(blocks, t, Product.uniform(k), k, rng=rng)
        assert e.lo == e.hi == 0.0
    C = Circuit(20)
    C.set_output(C.THR(list(range(20)), [1] * 20, 20 + 1e-13))
    assert meta_estimate(C, Product.uniform(20), rng=rng).hi == 0.0
    C.set_output(C.THR(list(range(20)), [1] * 20, 20))
    for _ in range(10):
        blocks, t = as_block_threshold(C)
        assert contains(tilted_estimate(blocks, t, Product.uniform(20), 20, rng=rng), Fraction(1, 2**20))
    # 30 two-input OR blocks: p = 0.75^30 at t = 30, 0 at t = 30 + 1e-13
    C, D = _or_blocks(30, 30)
    for _ in range(5):
        assert contains(meta_estimate(C, D, rng=rng), Fraction(3, 4) ** 30)
    C, D = _or_blocks(30, 30 + 1e-13)
    assert meta_estimate(C, D, rng=rng).hi == 0.0
    # biased OR blocks
    q = rng.uniform(0.6, 0.95, 40)
    C, D = _or_blocks(20, 20, q)
    Q = [Fraction(float(v)) for v in q]
    P = math.prod(1 - (1 - Q[2 * j]) * (1 - Q[2 * j + 1]) for j in range(20))
    for _ in range(5):
        assert contains(meta_estimate(C, D, rng=rng), P)


def test_tilt_beyond_fifty():
    """k = 10 single-variable blocks, q = 1e-30, t = 1: the mean-matching tilt
    is about 66.9, and the interval is tight (theta was capped at 50)."""
    n = 10
    C = Circuit(n)
    C.set_output(C.THR(list(range(n)), [1] * n, 1))
    D = Product(np.full(n, 1e-30))
    blocks, t = as_block_threshold(C)
    for b in blocks:
        b.tabulate(D)
    assert 60 < best_theta(blocks, t) < 75
    p = 1 - (1 - Fraction(1e-30)) ** 10
    e = tilted_estimate(blocks, t, D, n, rng=np.random.default_rng(10))
    assert contains(e, p) and e.hi <= 1.25 * e.lo


def test_tilting_and_meta_upper_end_at_most_one():
    rng = np.random.default_rng(11)
    C, D = _or_blocks(6, 0)
    blocks, t = as_block_threshold(C)
    e = tilted_estimate(blocks, t, D, C.n, rng=rng)
    assert e.lo == e.hi == 1.0
    C, D = _or_blocks(6, 1)
    blocks, t = as_block_threshold(C)
    for th in (0.0, 3.0):
        e = tilted_estimate(blocks, t, D, C.n, theta=th, rng=rng)
        assert e.hi <= 1.0 and contains(e, 1 - Fraction(1, 4) ** 6)
    e = tilted_estimate(blocks, t, D, C.n, theta=1e6, rng=rng)
    assert (e.lo, e.hi) == (0.0, 1.0)
    assert meta_estimate(C, D, rng=rng).hi <= 1.0
    with pytest.raises(ValueError):
        Block([0], C, 0.5)


def test_proposal_lower_bound_untrusted_proposal():
    class Evil(Product):
        def sample(self, N, rng):
            return np.ones((N, self.n), dtype=bool)

        def logpmf(self, X):
            return np.full(len(X), math.log(1e-3))

    C = Circuit(3)
    C.set_output(C.AND(0, 1, 2))
    D = Product.uniform(3)
    rng = np.random.default_rng(12)
    e = proposal_lower_bound(C, D, Evil(np.full(3, 0.5)), 1.0, rng=rng)
    assert e.lo <= 1 / 8 and e.hi == 1.0
    for M in (0.0, -1.0, math.nan, math.inf):
        e = proposal_lower_bound(C, D, Product(np.full(3, 0.5)), M, rng=rng)
        assert (e.lo, e.hi) == (0.0, 1.0)
    bad = Product(np.full(3, 0.5))
    bad.q = np.array([0.5, math.nan, 0.5])
    assert proposal_lower_bound(C, D, bad, 1.0, rng=rng).lo == 0.0
    # brute force over random small circuits, proposals and M
    misses = 0
    for _ in range(150):
        n = 4
        C = Circuit(n)
        lits = [C.lit(i, int(rng.integers(0, 2))) for i in range(n)]
        C.set_output(C.OR(C.AND(lits[0], lits[1]), C.AND(lits[2], lits[3], lits[0])))
        D = Product(rng.uniform(0.05, 0.95, n))
        Q = Product(rng.choice([0.0, 0.01, 0.5, 0.99, 1.0, 1e-300], n))
        P = exact_prob_rational(C, D)
        e = proposal_lower_bound(C, D, Q, float(rng.choice([1e-3, 0.1, 1.0, 10.0])), delta=0.01, N=2000, rng=rng)
        misses += Fraction(e.lo) > P
        assert e.hi == 1.0
    assert misses <= 6


# ------------------------------------------------------- local thresholds
def test_tg_huge_tilt_gives_no_nan():
    ltc = LTC(6, [(j,) for j in range(6)], [np.array([0, 1])] * 6, 6)
    q = np.full(6, 0.3)
    for sampler in ("glauber", "cftp"):
        for th in (1e308, math.inf, math.nan):
            e = tg_estimate(ltc, q, theta=th, theta_cap=1e308, sampler=sampler, L=200, max_is=2000,
                            rng=np.random.default_rng(13), pilot_chains=16)
            assert not math.isnan(e.log_lo) and not math.isnan(e.log_hi)
            assert e.contains_log(6 * math.log(0.3))


def test_float_allowance_covers_extreme_logits():
    """At q = 1e-300, Delta = 3, theta = 230 the update probability is off by
    up to 3.7 * 2^-48 in floating point; the allowance must exceed that."""
    ltc = LTC(2, [(0, 1)], [np.array([0, 0, 0, 1]) * 1], 1)
    ltc3 = LTC(4, [(0, 1), (0, 2), (0, 3)], [np.array([0, 0, 0, 1])] * 3, 1)
    m = LocalModel(ltc3, np.array([1e-300, 0.5, 0.5, 0.5]))
    assert m.dmax == 3
    assert m.float_tv(230.0) >= 3.7 * 2.0 ** -48
    assert m.certificate(230.0).tv_update == m.float_tv(230.0)
    m0 = LocalModel(ltc, np.array([0.3, 0.6]))
    assert m0.float_tv(4.0) == 2.0 ** -48  # typical inputs: the old floor


# --------------------------------------------------------- XPT and NNFs
def test_cyclic_argument_terminates():
    C = Circuit(6)
    C.set_output(C.OR(C.AND(0, 1), C.XOR(4, 5)))
    node = {"split": ("form", [4], 0), "children": [None, None]}
    node["children"] = [node, node]
    leaves, st = xpt_check(C, node)
    assert st["nodes"] <= 3
    X = points(6)
    y = C.eval_bits(X)
    for x in X[y]:
        assert any(S.contains(sum(1 << i for i in range(6) if x[i])) for S, _ in leaves)
    # an exponential DAG (each level's two children are the same object)
    deep = {"leaf": "open"}
    for i in range(60):
        deep = {"split": ("form", [i % 6], 0), "children": [deep, deep]}
    leaves, st = xpt_check(C, deep)
    assert st["nodes"] <= 2 * 61 + 1 and st["truncated"] > 0
    e = xpt_verify(C, None, deep, rng=np.random.default_rng(14))
    P = exact_prob_rational(C)
    assert contains(e, P)


def test_gate_by_gate_nnf_keeps_equal_gates_apart():
    """Two chains with structurally equal but distinct AND-gates: hash-consing
    merged them and raised the context width above both chains' (3 > 2)."""
    def chain(C, clauses):
        acc = None
        for c in clauses:
            g = C.OR(*[C.lit(v, b) for v, b in c])
            acc = g if acc is None else C.AND(acc, g)
        return acc

    shared = [[(0, 1), (1, 1)], [(1, 1), (2, 1)]]
    ra = [[(1, 0), (0, 0)], [(7, 0), (5, 1)], [(6, 1), (7, 0)]]
    rb = [[(2, 0), (1, 1)], [(3, 0), (2, 0)], [(4, 0)]]
    C = Circuit(8)
    a, b = chain(C, shared + ra), chain(C, shared + rb)
    C.set_output(C.OR(a, b))
    cw = context_width(to_nnf(C, flatten=False, small_cone=0))
    ca = context_width(to_nnf(C.with_output(a), flatten=False, small_cone=0))
    cb = context_width(to_nnf(C.with_output(b), flatten=False, small_cone=0))
    assert cw <= max(ca, cb) == 2
    N = to_nnf(C, flatten=False, small_cone=0)
    X = points(8)
    assert np.array_equal(N.eval_batch(X), C.eval_bits(X))
