"""Tests for rareprob.nets_analytic: every counterexample found by adversarial
review (McDiarmid's overflowing square, NaN cells and d > 53 in the narrow-net
DP interval, NaN rows in the exact indicator, the over-broad box-barrier
claim, the few-form ceiling claim, the heuristic CROWN rounding allowance, the
perturb-and-MAP threshold and overflow), plus exactness checks of the
envelopes' estimator identity and brute-force soundness on small nets.

p is the exact-real failure probability Pr[F(x) < t], F the net in exact
rational arithmetic on its float64 weights."""

import math
from fractions import Fraction
from math import comb

import numpy as np
import pytest

from rareprob.nets import MLP, all_inputs, train_constant
from rareprob import nets_analytic as na


# ------------------------------------------------------------ helpers

def mk(W, b, a, c, t):
    """One hidden layer: F = c + sum_j a_j relu(W_j . x + b_j), event F < t."""
    return MLP([np.asarray(W, float), np.asarray([a], float)], [np.asarray(b, float), np.asarray([c], float)],
               threshold=float(t))


def exact_p(net, t=None):
    """Pr[F < t] exactly (default t = the net's threshold), as a Fraction."""
    X = all_inputs(net.d, 0, 1 << net.d)
    t = Fraction(float(net.threshold)) if t is None else t
    return Fraction(sum(na.exact_output(net, x) < t for x in X), 1 << net.d)


def random_small_net(rng, L=1, d=None, scale=None):
    d = d or int(rng.integers(3, 8))
    sizes = [d] + [int(rng.integers(1, 4)) for _ in range(L)] + [1]
    sc = 1.0 if scale is None else scale
    Ws = [rng.normal(0, sc, (b, a)) for a, b in zip(sizes[:-1], sizes[1:])]
    bs = [rng.normal(0, sc, b) for b in sizes[1:]]
    net = MLP(Ws, bs, threshold=0.0)
    with np.errstate(all="ignore"):
        f = net.forward(all_inputs(d, 0, 1 << d))
    if np.isfinite(f).all():
        net.threshold = float(np.quantile(f, rng.uniform(0.05, 0.6)))
    return net


# ------------------------------------------------- McDiarmid (overflow)

def test_mcdiarmid_square_overflow():
    """s * s overflowed to inf while sum c_i^2 stayed finite: the certified
    value was U = 0 for p = 11/1024. Computed exactly, McDiarmid gives 0.087."""
    d = 10
    net = mk(np.full((1, d), 2e53), [11 * 2e53], [1e100], -8e153, 0.5)
    p = exact_p(net)
    assert p == Fraction(11, 1024)
    bd = na.mcdiarmid(net)
    assert math.isfinite(bd.log_value)
    assert Fraction(bd.value) >= p
    assert 0.08 < bd.value < 0.1


def test_mcdiarmid_constant_nets():
    """W = 0 raised ZeroDivisionError. F constant above t: p = 0, U = 0 is
    valid; below t: the trivial bound."""
    above = mk(np.zeros((2, 4)), [1.0, 2.0], [1.0, 1.0], 0.0, 0.5)
    assert exact_p(above) == 0
    assert na.mcdiarmid(above).value == 0.0
    below = mk(np.zeros((2, 4)), [1.0, 2.0], [1.0, 1.0], -5.0, 0.5)
    assert na.mcdiarmid(below).value == 1.0


def test_mcdiarmid_extreme_scales_never_nan():
    """The red team's 'scales' family (weights up to 1e+-100) gave U = NaN
    (inf / inf) on 12 of 517 nets."""
    rng = np.random.default_rng(5)
    for _ in range(40):
        d, m = int(rng.integers(3, 7)), int(rng.integers(1, 4))
        sw, sa = 10.0 ** rng.uniform(-100, 100), 10.0 ** rng.uniform(-100, 100)
        W = rng.normal(0, sw, (m, d))
        b = rng.normal(0, sw, m)
        a = rng.normal(0, sa, m)
        net = mk(W, b, a, float(rng.normal(0, sa * sw)), 0.0)
        bd = na.mcdiarmid(net)
        assert 0.0 <= bd.value <= 1.0 and not math.isnan(bd.log_value)
        assert Fraction(bd.value) >= exact_p(net)


# ------------------------------------------- narrow nets: DP interval

def test_small_width_interval_overflow_cells():
    """a relu(z) overflowed, _down_vec(inf) = inf - inf = NaN, and the NaN
    cells were silently left out of hi: [0, 0] for p = 1 and for p = 1/2."""
    d = 6
    net = mk(np.zeros((2, d)), [1e150, 1e150], [1e160, -1e160], 0.0, 0.5)  # F == 0 < t
    assert exact_p(net) == 1
    lo, hi = na.small_width_interval(net, budget=60)
    assert lo <= 1 <= hi
    v = np.ones(d)
    net = mk(np.vstack([1e150 * v, 1e150 * v, np.eye(d)[0]]), [1e151, 1e151, 0.0], [1e160, -1e160, 1.0], 0.0, 0.5)
    p = exact_p(net)  # F = relu(x_1) exactly
    assert p == Fraction(1, 2)
    lo, hi = na.small_width_interval(net, budget=60)
    assert Fraction(lo) <= p <= Fraction(hi)


@pytest.mark.parametrize("d", [54, 68, 82, 120])
def test_small_width_interval_beyond_53_inputs(d):
    """For d > 53 the DP entries are rounded; the interval used to miss p by
    about one ulp (92 of 161 cases). F = relu(sum x) - relu(-sum x) = sum x."""
    w = np.ones(d)
    for tk in (-d, -2, 0, 2, d // 3, d - 1, d):
        net = mk(np.vstack([w, -w]), [0.0, 0.0], [1.0, -1.0], 0.0, tk + 0.5)
        p = Fraction(sum(comb(d, j) for j in range(d + 1) if 2 * j - d < tk + 0.5), 2 ** d)
        lo, hi = na.small_width_interval(net, budget=d)
        assert Fraction(lo) <= p <= Fraction(hi), (d, tk, lo, hi, float(p))
        assert hi - lo < 1e-11


def test_small_width_interval_exact_up_to_53_inputs():
    d = 40
    w = np.ones(d)
    for tk in (-3, 0, 7):
        net = mk(np.vstack([w, -w]), [0.0, 0.0], [1.0, -1.0], 0.0, tk + 0.5)
        p = Fraction(sum(comb(d, j) for j in range(d + 1) if 2 * j - d < tk + 0.5), 2 ** d)
        lo, hi = na.small_width_interval(net, budget=d)
        assert Fraction(lo) == p == Fraction(hi)


def test_small_width_interval_random_nets():
    rng = np.random.default_rng(8)
    for _ in range(15):
        d, m = int(rng.integers(3, 8)), int(rng.integers(1, 4))
        net = mk(rng.normal(0, 1, (m, d)), rng.normal(0, 1, m), rng.normal(0, 1, m), 0.3, 0.3)
        lo, hi = na.small_width_interval(net, budget=40)
        assert Fraction(lo) <= exact_p(net) <= Fraction(hi)


def test_form_dp_limits():
    assert na.dp_rel(53) == 0.0 and na.dp_rel(54) > 0.0
    with pytest.raises(ValueError):
        na.form_dp(np.ones((1, 1001), dtype=np.int64))
    law = na.form_dp(np.array([[1, 2, -1, 0, 3]]))
    X = all_inputs(5, 0, 32)
    s = X @ np.array([1, 2, -1, 0, 3])
    for v in range(-7, 8):
        assert law.P[v + 7] == np.mean(s == v)


# -------------------------------------------------- exact indicator

def test_fails_exact_nan_rows():
    """The pre-activation overflows to inf at x_1 = x_2 = 1, f_fl = inf - inf
    = NaN, and NaN rows were neither rechecked nor counted: p = 0.75 reported
    for p = 1."""
    net = mk(np.array([[1e308, 1e308, 0, 0], [1e308, 1e308, 0, 0]]), [0.0, 0.0], [1.0, -1.0], 0.0, 0.5)
    X = all_inputs(4, 0, 16)
    assert exact_p(net) == 1
    assert na.forward_error_bound(net) == math.inf
    assert na.fails_exact(net, X).all()


def test_fails_exact_matches_rational_arithmetic():
    rng = np.random.default_rng(9)
    for _ in range(20):
        net = random_small_net(rng, L=int(rng.integers(1, 3)))
        if rng.random() < 0.4:  # integer weights: exact ties f = t
            net.Ws = [np.round(W * 2) for W in net.Ws]
            net.bs = [np.round(b * 2) for b in net.bs]
            net.threshold = float(np.round(net.threshold * 2))
        X = all_inputs(net.d, 0, 1 << net.d)
        t = Fraction(float(net.threshold))
        ref = np.array([na.exact_output(net, x) < t for x in X])
        assert (na.fails_exact(net, X) == ref).all()


# ------------------------------------------------------ box barrier

def small_ball_net(d=16):
    """F = relu(sum x) + relu(-sum x) = |sum x|, t = 1: failure iff sum x = 0;
    F(0) - t = -1."""
    w = np.ones(d)
    return mk(np.vstack([w, -w]), [0.0, 0.0], [1.0, 1.0], 0.0, 1.0)


def test_box_barrier_holds_for_tilt_mixtures():
    net = small_ball_net()
    assert float(na.exact_output(net, np.zeros(16))) - net.threshold == -1.0
    assert na.tilt_envelope(net).logZ >= 0.0
    assert na.sign_pattern_envelope(net).logZ >= 0.0
    # a net with negative units and F(0) < t: Z >= exp(theta (t' - F(0))) >= 1
    rng = np.random.default_rng(1)
    d, m = 10, 6
    W = rng.normal(0, 1, (m, d))
    b = rng.normal(0, 0.3, m)
    a = np.array([1.0, 1.0, 1.0, -0.5, -0.5, -0.5])
    net = mk(W, b, a, 0.0, 0.0)
    F0 = float(na.exact_output(net, np.zeros(d)))
    net.threshold = F0 + 0.5
    for k in (0, 2, 3):
        env = na.sign_pattern_envelope(net, n_split=k)
        assert env.logZ >= env.theta * (env.tp - F0) - 1e-9
        assert env.logZ >= 0.0


def test_box_barrier_does_not_cover_cell_envelopes():
    """The red team's counterexample to the over-broad claim: an envelope
    that keeps the hidden form s = sum x exactly (a group-DP / cell envelope)
    has mass Z < 1 on the small-ball net although F(0) < t. The module's
    box-barrier statement is now restricted to positive mixtures of
    full-support tilts."""
    d = 16
    net = small_ball_net(d)
    law = na.form_dp(np.ones((1, d), dtype=np.int64))
    s = law.values(0).ravel()
    P = law.P.ravel()
    best = min((float(np.dot(P, np.exp(th * (1.0 - np.abs(s))))), th) for th in np.linspace(0.05, 2.0, 40))
    Z, th = best
    assert Z < 0.7
    # domination: phi(x) = exp(th (1 - |sum x|)) >= 1 on every failure
    X = all_inputs(d, 0, 1 << d)
    fails = na.fails_exact(net, X)
    phi = np.exp(th * (1.0 - np.abs(X.sum(1))))
    assert (phi[fails] >= 1.0).all()
    assert abs(Z - float(phi.mean())) < 1e-12
    assert "not log-linear" in na.__doc__ and "full-support exponential tilts" in na.__doc__


def test_few_form_ceiling_claim_dropped():
    """The hindsight 'K* >= 843 for envelopes in 1-3 forms' was an artifact of
    coarse grids (K* = 10 ... 44 at a 2^20 grid); the claim is gone."""
    assert "843" not in na.__doc__
    assert "few-form" not in na.__doc__.lower()


# ---------------------------------------------- envelopes: exactness

def test_tilt_identity_and_interval():
    """E_Q W = p / Z by enumeration, and the interval contains p."""
    rng = np.random.default_rng(2)
    d = 10
    w = np.ones(d)
    net = mk(np.vstack([w, -w]), [0.0, 0.0], [0.25, -0.25], 2.0, 0.5)  # F = 2 + s/4, p = Pr[s <= -8]
    p = exact_p(net)
    env = na.tilt_envelope(net, rng=rng)
    X = all_inputs(d, 0, 1 << d)
    Q = np.prod(np.where(X > 0, env.pi, 1 - env.pi), axis=1)
    W = env.weight(X, na.fails_exact(net, X))
    assert W.max() <= 1.0
    Z = math.exp(env.logZ)
    assert abs(float(np.dot(Q, W)) - float(p) / Z) <= 1e-9 * float(p) / Z
    if env.logZ < 0:
        est = na.envelope_interval(env, eps=0.2, delta=0.05, max_samples=200000, rng=np.random.default_rng(3))
        assert Fraction(est.lo) <= p <= Fraction(est.hi)
    assert env.log_weight_err > 0


def test_sign_pattern_identity_and_domination():
    rng = np.random.default_rng(4)
    d, m = 9, 5
    W = rng.normal(0, 1, (m, d))
    b = rng.normal(0, 0.5, m)
    a = np.array([1.5, 1.0, -0.7, -0.6, -0.4])
    net = mk(W, b, a, 1.0, 0.0)
    X = all_inputs(d, 0, 1 << d)
    f = net.forward(X)
    net.threshold = float(np.quantile(f, 0.03))
    p = exact_p(net)
    env = na.sign_pattern_envelope(net, n_split=3)
    assert env.coin_tv >= d * 2.0 ** -52
    # domination at cube points and at real points of the box
    fails = na.fails_exact(net, X)
    assert (env.log_phi(X)[fails] >= 0).all()
    Y = rng.uniform(-1, 1, (5000, d))
    FY = net.forward(Y)
    assert (env.log_phi(Y)[FY < net.threshold - 1e-9] >= 0).all()
    # exact identity sum_x Q(x) W(x) = p / Z (Q the mixture over sign patterns)
    Z = math.exp(env.logZ)
    lhs = float(np.dot(sign_pattern_Q(env, X), env.weight(X, fails)))
    assert abs(lhs - float(p) / Z) <= 1e-8 * max(float(p) / Z, 1e-300)
    assert env.logZ >= 0  # this net is barred: F(0) - t < 0


def sign_pattern_Q(env, X):
    """The sampler's law (mixture over sign patterns) at the points X."""
    lt = env.log_terms
    wT = np.exp(lt - lt.max())
    wT /= wT.sum()
    Q = np.zeros(len(X))
    for T in range(lt.size):
        beta = env._beta(np.array([T]))[0]
        q = 1 / (1 + np.exp(-2 * beta))
        Q += wT[T] * np.prod(np.where(X > 0, q, 1 - q), axis=1)
    return Q


def test_sign_pattern_interval_large_margin():
    """F = 2 + (sum x) / 4 (one negative unit): F(0) - t = 1.5, Z < 1."""
    d = 10
    w = np.ones(d)
    net = mk(np.vstack([w, -w]), [0.0, 0.0], [0.25, -0.25], 2.0, 0.5)
    p = exact_p(net)
    env = na.sign_pattern_envelope(net)
    assert env.logZ < -1.0
    X = all_inputs(d, 0, 1 << d)
    W = env.weight(X, na.fails_exact(net, X))
    Z = math.exp(env.logZ)
    assert abs(float(np.dot(sign_pattern_Q(env, X), W)) - float(p) / Z) <= 1e-8 * float(p) / Z
    for seed in range(3):
        est = na.envelope_interval(env, eps=0.2, delta=0.05, max_samples=100000, rng=np.random.default_rng(seed))
        assert Fraction(est.lo) <= p <= Fraction(est.hi)


def test_cube_tilt_envelope():
    """The cube-certified tilt: exists only when min_x (F(x) + F(-x))/2 > t
    (cube barrier), dominates the failures exactly, and its estimator is
    unbiased (enumeration) and covers p."""
    d = 10
    w = np.ones(d)
    net = mk(np.vstack([w, -w]), [0.0, 0.0], [0.25, -0.25], 2.0, 0.5)  # F = 2 + s/4: F(x) + F(-x) = 4
    orc = na.EnumMAPOracle(net)
    assert na.symmetric_gap(orc.F, net.threshold) > 0
    env = na.cube_tilt_envelope(net, orc, iters=60)
    p = exact_p(net)
    X = all_inputs(d, 0, 1 << d)
    fails = na.fails_exact(net, X)
    assert (env.A0 + X @ env.alpha - env.logZ)[fails].max() <= 1e-12
    Q = np.prod(np.where(X > 0, env.pi, 1 - env.pi), axis=1)
    EW = float(np.dot(Q, env.weight(X, fails)))
    assert abs(math.log(EW) + env.logZ - math.log(float(p))) < 1e-9
    assert env.logZ < 0
    est = na.envelope_interval(env, eps=0.2, delta=0.05, max_samples=100000, rng=np.random.default_rng(1))
    assert Fraction(est.lo) <= p <= Fraction(est.hi)
    barred = small_ball_net(10)
    with pytest.raises(ValueError):
        na.cube_tilt_envelope(barred, na.EnumMAPOracle(barred), iters=20)


def test_deep_tilt_minorant_is_certified():
    """affine_minorant_deep used a heuristic 1e-10 allowance; it now uses the
    CROWN pass of nets_verify with its proved margin. Checked exactly on deep
    nets with large and cancelling weights."""
    rng = np.random.default_rng(6)
    for _ in range(20):
        net = random_small_net(rng, L=int(rng.integers(2, 4)), d=int(rng.integers(2, 6)),
                               scale=10.0 ** rng.uniform(-2, 12))
        g0, gam, err = na.affine_minorant_deep(net)
        for x in all_inputs(net.d, 0, 1 << net.d):
            lhs = Fraction(g0) + sum(Fraction(float(g)) * int(v) for g, v in zip(gam, x)) - Fraction(err)
            assert na.exact_output(net, x) >= lhs
    rng = np.random.default_rng(0)
    net, _ = train_constant(10, [8, 8], 200, rng)
    env = na.tilt_envelope_deep(net)
    assert math.isfinite(env.logZ)


# --------------------------------------------------- perturb-and-MAP

def test_perturb_map_threshold_and_overflow():
    """The bound is on Pr[F < t + tau] (so float evaluations are covered),
    and returns the trivial bound instead of NaN when theta F overflows."""
    d = 8
    # integer net with exact ties F = t at many points
    W = np.array([[1.0] * d, [-1.0] * d])
    net = mk(W, [0.0, 0.0], [1.0, 1.0], 0.0, 2.0)  # F = |sum x|; F = 2 = t on 2 * C(8, 3) points
    orc = na.EnumMAPOracle(net)
    tp = Fraction(float(net.threshold)) + Fraction(orc.tau)
    p_tp = exact_p(net, tp)
    bd = na.perturb_map_bound(orc, 2.0, 2, 200, 0.05, np.random.default_rng(1))
    assert Fraction(bd.value) >= p_tp
    huge = na.perturb_map_bound(orc, 1e306, 2, 20, 0.05, np.random.default_rng(1))
    assert huge.value == 1.0 and not math.isnan(huge.log_value)


def test_map_oracle_refuses_overflowing_tables():
    net = mk(np.array([[1e308, 1e308, 0, 0], [1e308, 1e308, 0, 0]]), [0.0, 0.0], [1.0, -1.0], 0.0, 0.5)
    with pytest.raises(ValueError):
        na.EnumMAPOracle(net)


# ----------------------------------------- brute-force soundness smoke

def test_chernoff_holder_and_floor_on_small_nets():
    rng = np.random.default_rng(10)
    for trial in range(8):
        d, m = int(rng.integers(4, 8)), int(rng.integers(2, 5))
        sc = 10.0 ** rng.uniform(-3, 3) if trial % 2 else 1.0
        net = mk(rng.normal(0, sc, (m, d)), rng.normal(0, sc, m), rng.normal(0, 1, m), 0.5, 0.0)
        X = all_inputs(d, 0, 1 << d)
        net.threshold = float(np.quantile(net.forward(X), 0.2))
        p = exact_p(net)
        for form in ("relu", "even"):
            bd = na.chernoff_holder(net, form=form, restarts=1)
            assert Fraction(bd.value) >= p
        assert Fraction(na.mcdiarmid(net).value) >= p


def test_chernoff_holder_overflow_is_trivial():
    net = mk(np.zeros((2, 6)), [1e150, 1e150], [1e160, -1e160], 0.0, 0.5)
    bd = na.chernoff_holder(net, form="relu", restarts=1)
    assert bd.value == 1.0 and not math.isnan(bd.log_value)
    # forms whose l1 norm overflows cannot be quantised: refused inside, trivial bound outside
    net = mk(np.full((2, 6), 1e308), [0.0, 0.0], [1.0, -1.0], 0.0, 0.5)
    with pytest.raises(ValueError):
        na.grid_for(net.Ws[0], 100)
    for form in ("relu", "even"):
        assert na.chernoff_holder(net, form=form, restarts=1).value == 1.0
    assert na.mcdiarmid(net).value == 1.0
