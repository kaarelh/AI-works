"""Tests for rareprob.nets_verify: soundness of the branch-and-bound interval
against exact rational counting, including every counterexample found by
adversarial review (overflow in the backward pass of deep nets, the
initialisation of the sampling stage for d > 53, a negative enumeration
threshold under python -O; and, from the referee of this version, a
negative first batch in the sampling stage and bounders or B&B results built
for another net), the affine minorant used by nets_analytic, and the budget
semantics.

p is the exact-real failure probability Pr[F(x) < t], F the net in exact
rational arithmetic on its float64 weights."""

import os
import subprocess
import sys
from fractions import Fraction

import numpy as np
import pytest

from rareprob.nets import MLP, all_inputs, init_mlp, train_constant
from rareprob import nets_verify as nv


# ------------------------------------------------------------ helpers

def exact_F(net, x):
    """The net in exact rational arithmetic on its float64 weights."""
    h = [Fraction(float(v)) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = [Fraction(float(b[j])) + sum(Fraction(float(W[j, i])) * h[i] for i in range(len(h)))
             for j in range(W.shape[0])]
        h = z if li == len(net.Ws) - 1 else [max(v, Fraction(0)) for v in z]
    return h[0]


def exact_count(net):
    X = all_inputs(net.d, 0, 1 << net.d)
    t = Fraction(float(net.threshold))
    return sum(exact_F(net, x) < t for x in X)


def contains(res, count):
    """The B&B interval [F, F + A + U] / 2^d contains the exact count."""
    return res.fail <= count <= res.fail + res.ambiguous + res.undecided


def overflow_net(L=3):
    """Red-team net: d = 3, widths [1, 2, 1]; the CROWN coefficients of layer 3
    (|W_3| |W_2| ~ 2e308) overflow although rho stays below 1e300. Every point
    fails (F = -7.8e292 < 0)."""
    d = 3
    W1 = np.full((1, d), 1e-200)
    b1 = np.array([1e-15])
    W2 = np.array([[1e154], [1e154]])
    W3 = np.array([[1e154, 1e154]])
    w4 = np.array([[-0.4]])
    return MLP([W1, W2, W3, w4], [b1, np.zeros(2), np.zeros(1), np.array([2e291])], threshold=0.0)


# ------------------------------------------------- red-team regressions

def test_overflow_in_backward_pass_is_not_a_certificate():
    """Before the fix a NaN interval was read as a dead unit and the root was
    certified safe: [0, 0] for p = 1."""
    net = overflow_net()
    bd = nv.Bounder(net)
    assert max(float(r.max()) for r in bd.rho) <= 1e300  # passes the weight guard
    lb, ub, score = bd.bound(np.zeros((1, 3)))
    assert np.isfinite(score[0]).all()
    count = exact_count(net)
    assert count == 8
    assert not (lb[0] >= bd.thr_safe)  # the root is not certified safe
    res = nv.bab(net, r_enum=0)
    assert contains(res, count)
    assert Fraction(res.lo) <= Fraction(count, 8) <= Fraction(res.hi)


@pytest.mark.parametrize("w3s,b3", [(0.4, 2e291), (-0.4, 2e291), (1e154, 0.0)])
@pytest.mark.parametrize("scale2", [1.0, 0.9, 0.8, 0.6])
def test_overflow_depth_two(w3s, b3, scale2):
    """The same construction with two hidden layers (the NaN reaches only the
    output bound): the interval contains p."""
    d = 3
    net = MLP([np.full((1, d), 1e-200), np.array([[1e154], [1e154]]) * scale2, np.array([[w3s, w3s]])],
              [np.array([1e-15]), np.zeros(2), np.array([b3])], threshold=0.0)
    try:
        nv.Bounder(net)
    except ValueError:
        return  # rejected by the guard: nothing is claimed
    res = nv.bab(net, r_enum=0)
    assert contains(res, exact_count(net))


def test_estimate_undecided_starts_from_rounded_down_count():
    """d = 57: F = 2^56 + 12 certified failing points and 4 undecided points
    that do not fail, so p = 1/2 + 12/2^57. lo used to start at the
    round-to-nearest float F / 2^d = 1/2 + 2^-53 > p."""
    d = 57
    m = 5
    W = np.zeros((m, d))
    b = np.zeros(m)
    a = np.zeros(m)
    W[0, 0] = -1; a[0] = -2                                    # x0 = -1 fails
    W[1, 0] = 1; W[1, 1:54] = -1; b[1] = -53; a[1] = -2        # a failing subcube of 8 points
    W[2, 0] = 1; W[2, 1:55] = 1; b[2] = -54; a[2] = -2         # and one of 4 points
    W[3, 55] = W[3, 56] = 1; a[3] = 0.3                        # identically 0 but loose
    W[4, 55] = W[4, 56] = 1; a[4] = -0.3
    net = MLP([W, a[None, :]], [b, np.array([1.0])], threshold=0.5)
    F_exact = 2 ** 56 + 12
    full = nv.bab(net, r_enum=0, min_rate=0.0)
    assert full.exact and full.fail == F_exact
    n_before = sum(lv["nodes"] for lv in full.levels[:-1])
    res = nv.bab(net, r_enum=0, min_rate=0.0, max_nodes=n_before)
    assert res.fail == F_exact and res.undecided > 0
    p = Fraction(F_exact, 2 ** d)
    for seed in range(3):
        tw = nv.estimate_undecided(net, res, eps=0.1, delta=0.05, rng=np.random.default_rng(seed),
                                   max_samples=10000)
        assert Fraction(tw.lo) <= p <= Fraction(tw.hi)
        assert Fraction(tw.det_lo) <= p <= Fraction(tw.det_hi)


def _renum_net():
    """d = 2: one clear failing point and one near tie (exact f = -2^-40)."""
    e = 2.0 ** -40
    W = np.array([[1., 1.], [-1., 1.]])
    b = np.array([-1., -1.])
    return MLP([W, np.array([[-2.0, -(1.0 + e)]])], [b, np.array([1.0])], threshold=0.0)


@pytest.mark.parametrize("r_enum", [-1, -5, 1.5, True])
def test_negative_or_invalid_r_enum_is_rejected(r_enum):
    with pytest.raises(ValueError):
        nv.bab(_renum_net(), r_enum=r_enum, stop_on_failure=True)


def test_r_enum_rejected_under_python_O():
    """Under python -O asserts vanish; the old code then returned an 'exact'
    [0.25, 0.25] for p = 1/2. The check must be an explicit exception."""
    here = os.path.dirname(os.path.abspath(__file__))
    code = ("import numpy as np, sys\n"
            "sys.path.insert(0, %r)\n"
            "from rareprob.nets import MLP\n"
            "from rareprob.nets_verify import bab\n"
            "e = 2.0 ** -40\n"
            "net = MLP([np.array([[1., 1.], [-1., 1.]]), np.array([[-2.0, -(1.0 + e)]])],"
            " [np.array([-1., -1.]), np.array([1.0])], threshold=0.0)\n"
            "try:\n"
            "    bab(net, r_enum=-1, stop_on_failure=True)\n"
            "except ValueError:\n"
            "    print('rejected')\n" % os.path.join(here, ".."))
    out = subprocess.run([sys.executable, "-O", "-c", code], capture_output=True, text=True, timeout=120)
    assert out.stdout.strip() == "rejected", out.stderr


def test_r_enum_zero_is_sound_on_the_near_tie_net():
    net = _renum_net()
    assert exact_count(net) == 2
    for stop in (False, True):
        res = nv.bab(net, r_enum=0, stop_on_failure=stop)
        assert contains(res, 2)


def _undecided_net():
    """d = 10: f = 2 relu(x_0 + 1) - relu(sum_{i>=1} x_i - 6) - 1, t = 0.5.
    Every x with x_0 = -1 fails, and so does x_0 = +1, x_i = +1 (i >= 1):
    p = 513/1024."""
    d = 10
    W1 = np.zeros((2, d))
    W1[0, 1:] = 1.0
    W1[1, 0] = 1.0
    return MLP([W1, np.array([[-1.0, 2.0]])], [np.array([-6.0, 1.0]), np.array([-1.0])], threshold=0.5)


@pytest.mark.parametrize("first", [-1, 0, 1.5, True, "8"])
def test_regression_estimate_undecided_rejects_bad_first_batch(first):
    """Referee counterexample: first = -1 drew no sample, the KL interval at
    N < 0 collapsed, and [0.5, 0.5 + 4e-16] was returned for p = 513/1024."""
    net = _undecided_net()
    assert exact_count(net) == 513
    res = nv.bab(net, r_enum=0, max_nodes=3)
    assert res.fail == 512 and res.undecided == 512
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, res, eps=0.5, delta=0.05, rng=np.random.default_rng(1), first=first)
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, res, eps=0.5, delta=0.05, rng=np.random.default_rng(1), max_samples=-1)
    tw = nv.estimate_undecided(net, res, eps=0.5, delta=0.05, rng=np.random.default_rng(1), first=1024)
    assert Fraction(tw.lo) <= Fraction(513, 1024) <= Fraction(tw.hi)


def test_regression_bounder_and_result_must_belong_to_the_net():
    """Referee counterexample: bab(net, bounder=Bounder(other)) certified the
    bounder's net (t = -10) and returned the exact [0, 0] for p = 513/1024."""
    net = _undecided_net()
    other = MLP([W.copy() for W in net.Ws], [b.copy() for b in net.bs], threshold=-10.0)
    with pytest.raises(ValueError):
        nv.bab(net, r_enum=4, bounder=nv.Bounder(other))
    res_other = nv.bab(other, r_enum=0, max_nodes=3)
    res = nv.bab(net, r_enum=0, max_nodes=3, bounder=nv.Bounder(net))  # the same net: accepted
    assert contains(res, 513)
    kw = dict(eps=0.5, delta=0.05, rng=np.random.default_rng(1))
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, res, bounder=nv.Bounder(other), **kw)
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, res_other, **kw)
    # undecided subcubes of mixed sizes (a non-uniform sampler), or not summing to res.undecided
    bad = nv.BabResult(**{k: v for k, v in vars(res).items()})
    bad.undecided_cubes = res.undecided_cubes.copy()
    bad.undecided_cubes[0, np.nonzero(bad.undecided_cubes[0] == 0)[0][0]] = 1
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, bad, **kw)
    bad.undecided_cubes = res.undecided_cubes[:1].copy()
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, bad, **kw)
    bad.undecided_cubes = res.undecided_cubes.astype(float) * 0.5
    with pytest.raises(ValueError):
        nv.estimate_undecided(net, bad, **kw)


def test_nan_values_are_ambiguous_not_safe():
    """A point whose float value is not a number is never counted as safe
    (enumeration and sampling stage)."""
    bd = nv.Bounder(_renum_net())
    f = np.array([np.nan, -1.0, 1.0, 0.0])
    amb = bd._ambiguous(f)
    assert amb.tolist() == [True, False, False, True]


def test_guards_are_explicit_exceptions():
    # network too large for the fixed rounding margin
    net = MLP([np.zeros((1, 33000)), np.ones((1, 1))], [np.zeros(1), np.zeros(1)], threshold=0.5)
    with pytest.raises(ValueError):
        nv.Bounder(net)
    # non-finite and too large weights
    with pytest.raises(ValueError):
        nv.Bounder(MLP([np.array([[np.inf]]), np.ones((1, 1))], [np.zeros(1), np.zeros(1)]))
    with pytest.raises(ValueError):
        nv.Bounder(MLP([np.array([[1e301]]), np.ones((1, 1))], [np.zeros(1), np.zeros(1)]))
    # phase splitting needs one hidden layer
    bd = nv.Bounder(overflow_net())
    with pytest.raises(ValueError):
        bd.phase_bound(np.zeros((1, 3)), 1)


# ------------------------------------------------------- soundness fuzz

def _random_net(rng):
    """Small nets with independent per-layer scales (1e-150 ... 1e150),
    zero weights, integer weights with exact ties."""
    L = int(rng.integers(1, 4))
    d = int(rng.integers(2, 6))
    widths = [int(rng.integers(1, 4)) for _ in range(L)]
    sizes = [d] + widths + [1]
    Ws, bs = [], []
    integer = rng.random() < 0.3
    for a, b in zip(sizes[:-1], sizes[1:]):
        if integer:
            W = rng.integers(-2, 3, size=(b, a)).astype(float)
            bb = rng.integers(-2, 3, size=b).astype(float)
        else:
            sc = 10.0 ** rng.uniform(-150, 150) if rng.random() < 0.5 else 1.0
            W = rng.normal(0, 1, (b, a)) * sc * (rng.random((b, a)) > 0.2)
            bb = rng.normal(0, 1, b) * sc
        Ws.append(W)
        bs.append(bb)
    net = MLP(Ws, bs, threshold=0.0)
    with np.errstate(all="ignore"):
        f = net.forward(all_inputs(d, 0, 1 << d))
    if np.isfinite(f).all():
        net.threshold = float(rng.choice(f)) if rng.random() < 0.5 else float(np.median(f))
    return net


def test_bab_matches_exact_counts_on_adversarial_nets():
    rng = np.random.default_rng(2026)
    checked = 0
    for _ in range(120):
        net = _random_net(rng)
        try:
            nv.Bounder(net)
        except ValueError:
            continue
        count = exact_count(net)
        for kw in (dict(r_enum=0), dict(r_enum=1, branch="static"), dict(r_enum=0, max_nodes=3),
                   dict(r_enum=2, stop_on_failure=True), dict(r_enum=0, alpha_iters=5),
                   dict(r_enum=0, phase_depth=1, phase_iters=5)):
            res = nv.bab(net, **kw)
            assert contains(res, count), (kw, res.summary(), count)
        checked += 1
    assert checked >= 60


def test_affine_lower_is_a_minorant_on_the_cube():
    """f(x) >= h + g.x - err at every cube point, checked exactly, for random
    deep nets with large and cancelling weights."""
    rng = np.random.default_rng(7)
    for trial in range(25):
        L = int(rng.integers(1, 4))
        d = int(rng.integers(2, 6))
        sizes = [d] + [int(rng.integers(1, 4)) for _ in range(L)] + [1]
        sc = 10.0 ** rng.uniform(-3, 12)
        Ws = [rng.normal(0, sc, (b, a)) for a, b in zip(sizes[:-1], sizes[1:])]
        bs = [rng.normal(0, sc, b) for b in sizes[1:]]
        net = MLP(Ws, bs, threshold=0.0)
        h, g, err = nv.Bounder(net).affine_lower()
        Hf, gf, ef = Fraction(h), [Fraction(float(v)) for v in g], Fraction(err)
        for x in all_inputs(d, 0, 1 << d):
            assert exact_F(net, x) >= Hf + sum(gi * int(xi) for gi, xi in zip(gf, x)) - ef


def test_affine_lower_on_the_overflow_net():
    """On the red-team net the output pass stays finite (|w_4| |W_3| |W_2| ~
    8e307): the minorant must be valid there."""
    net = overflow_net()
    h, g, err = nv.Bounder(net).affine_lower()
    for x in all_inputs(3, 0, 8):
        assert exact_F(net, x) >= Fraction(h) + sum(Fraction(float(gi)) * int(xi) for gi, xi in zip(g, x)) \
            - Fraction(err)


def test_backward_pass_overflow_gives_no_information():
    """The mechanism behind the fix: a backward pass whose coefficients
    overflow returns -inf (the guard on rho makes this rare at the output, so
    it is exercised directly)."""
    bd = nv.Bounder(overflow_net())
    X0 = np.zeros((1, 3))
    R = np.ones((1, 3))
    bounds, relax, alphas = bd.layer_bounds(X0, R)
    for lo, hi in bounds:
        assert np.isfinite(lo).all() and np.isfinite(hi).all()
    A = np.full((1, 1, 2), 1e308)
    val = bd._lower_linear(A, np.zeros((1, 1)), 2, X0, R, relax, alphas)
    assert val[0, 0] == -np.inf
    val = bd._lower_linear(-A, np.zeros((1, 1)), 2, X0, R, relax, alphas)
    assert val[0, 0] == -np.inf


# ---------------------------------------------------- behaviour checks

def test_exact_count_on_a_trained_net():
    rng = np.random.default_rng(3)
    net, _ = train_constant(12, [16], 300, rng)
    X = all_inputs(12, 0, 1 << 12)
    count = int((net.forward(X) < net.threshold).sum())
    res = nv.bab(net, r_enum=4)
    assert res.exact and res.fail == count


def test_budget_is_a_conservative_projection():
    """max_fpe is checked against the cost of bounding every node of the next
    level: the run never exceeds it, and with the probe it can stop far
    below it (the docstring and the experiment READMEs say so)."""
    rng = np.random.default_rng(4)
    net = init_mlp(40, [32], rng)
    res = nv.bab(net, r_enum=4, max_fpe=1e5)
    assert res.stopped == "budget"
    assert res.fpe <= 1e5
    assert 0.0 <= res.lo <= res.hi <= 1.0


def test_estimate_undecided_coverage_small():
    """Two-sided intervals from the sampling stage contain the exact p."""
    rng = np.random.default_rng(11)
    net, _ = train_constant(10, [8], 150, rng)
    count = exact_count(net)
    p = Fraction(count, 1 << 10)
    res = nv.bab(net, r_enum=0, max_nodes=40)
    for seed in range(5):
        tw = nv.estimate_undecided(net, res, eps=0.2, delta=0.05, rng=np.random.default_rng(seed),
                                   max_samples=4000)
        assert Fraction(tw.lo) <= p <= Fraction(tw.hi)
