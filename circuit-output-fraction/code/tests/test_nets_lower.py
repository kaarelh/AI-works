"""Tests for rareprob.nets_lower: the certified forward-error bound (including
the red-team counterexamples with gradual underflow, fused multiply-add and
overflow), completeness on exact ties at the threshold, exactness of the
witness bound and of Z, unbiasedness of fixed-level SMC against exact
enumeration, and coverage of the betting bound (fixed R and sequential) on
synthetic laws and on adversarial nets with exactly known p.

Referee counterexamples on this version, now regressions: exact counts
k / 2^d rounded to nearest (up) in the subnormal range (d >= 1075); the end
of the betting bisection in the subnormal range; bet sizes outside [0, 1];
caller-supplied witnesses that were never checked against the net, and
non-cube rows packed as cube points.

p is the exact-real failure probability Pr[F(x) < t*], F the net in exact
rational arithmetic on its float64 weights."""

import math
from fractions import Fraction

import numpy as np
import pytest

from rareprob.nets import MLP, all_inputs, exact_failure_count, init_mlp
from rareprob.nets_lower import (Evaluator, Plan, Witnesses, _float_down, betting_lower, forward_error_bound,
                                 lower_bound, pack, pilot_plan, random_cube, run_smc)


# ------------------------------------------------------------ helpers

def exact_F(net, x):
    """The net in exact rational arithmetic on its float64 weights."""
    h = [Fraction(float(v)) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = [Fraction(float(b[j])) + sum(Fraction(float(W[j, i])) * h[i] for i in range(len(h)))
             for j in range(W.shape[0])]
        h = z if li == len(net.Ws) - 1 else [max(v, Fraction(0)) for v in z]
    return h[0]


def exact_p(net):
    X = all_inputs(net.d, 0, 1 << net.d)
    t = Fraction(float(net.threshold))
    return sum(exact_F(net, x) < t for x in X) / 2 ** net.d


def _fma(a, b, c):
    if hasattr(math, "fma"):
        return math.fma(a, b, c)
    return float(Fraction(a) * Fraction(b) + Fraction(c))  # correctly rounded


def fma_forward(net, x):
    """A different admissible float64 evaluation: acc = b; acc = fma(w_i, h_i, acc)."""
    h = [float(v) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = []
        for j in range(W.shape[0]):
            acc = float(b[j])
            for i in range(len(h)):
                acc = _fma(float(W[j, i]), h[i], acc)
            z.append(acc)
        h = z if li == len(net.Ws) - 1 else [max(v, 0.0) for v in z]
    return h[0]


def sequential_forward(net, x):
    """Yet another admissible evaluation: plain left-to-right sums."""
    h = [float(v) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = []
        for j in range(W.shape[0]):
            acc = float(b[j])
            for i in range(len(h)):
                acc = acc + float(W[j, i]) * h[i]
            z.append(acc)
        h = z if li == len(net.Ws) - 1 else [max(v, 0.0) for v in z]
    return h[0]


def max_error(net, X):
    with np.errstate(all="ignore"):
        f = net.forward(X)
    return max(abs(Fraction(float(f[i])) - exact_F(net, X[i])) for i in range(len(X)))


# ------------------------------------- red-team nets (float64 attacks)

def net_underflow_mse(d, k=8):
    """attack_underflow, net A. h1 = 2^-537; h2_j = relu(2^-538 h1), exactly
    2^-1075, which rounds to 0 (ties to even); output weights about 2^1024.
    Float: f = 0.5 - 3 2^-50 < t*. Exact: F = 0.5 + 2^-50 - 2^-103 > t*, so p = 0."""
    W1 = np.zeros((1, d))
    b1 = np.array([2.0 ** -537])
    W2 = np.full((k, 1), 2.0 ** -538)
    W3 = np.full((1, k), float.fromhex("0x1.fffffffffffffp+1023"))
    return MLP([W1, W2, W3], [b1, np.zeros(k), np.array([0.5 - 3 * 2.0 ** -50])], threshold=0.5, loss="mse")


def net_underflow_ball_bce(d, m=4, seed=0):
    """attack_underflow, net B. The term 2^1000 (2^-540 2^-540) is dropped in
    float; float failures are a Hamming ball of radius m - 1 around u, while
    F >= 2^-80 - a (2m - 1) > 0 everywhere (p = 0)."""
    rng = np.random.default_rng(seed)
    u = rng.choice([-1.0, 1.0], d)
    W1 = np.zeros((2, d))
    W1[0] = u
    b1 = np.array([-(d - 2.0 * m), 2.0 ** -540])
    W2 = np.array([[1.0, 0.0], [0.0, 2.0 ** -540]])
    a = 2.0 ** -85
    W3 = np.array([[-a, 2.0 ** 1000]])
    return MLP([W1, W2, W3], [b1, np.zeros(2), np.array([a])], threshold=0.0, loss="bce"), u


def net_visible_ball(d, r=4, seed=0):
    """attack_underflow2: float f = a (2H - 2r + 1) (fails iff H <= r - 1, a
    visible funnel for SMC), exact F = f + 2^-80 > 0 everywhere (p = 0)."""
    rng = np.random.default_rng(seed)
    u = rng.choice([-1.0, 1.0], d)
    W1 = np.zeros((2, d))
    W1[0] = u
    b1 = np.array([float(d), 2.0 ** -540])
    W2 = np.array([[1.0, 0.0], [0.0, 2.0 ** -540]])
    a = 2.0 ** -83
    W3 = np.array([[-a, 2.0 ** 1000]])
    return MLP([W1, W2, W3], [b1, np.zeros(2), np.array([a * (2 * d - 2 * r + 1)])],
               threshold=0.0, loss="bce"), u


def net_fma(d, k=16):
    """attack_fma: w.h = 2^-1075 (a tie) plus bias 2^-1074. numpy (product
    rounded, then + bias) gives 2^-1074, FMA gives 2^-1073, the exact value is
    1.5 2^-1074; amplified by 2^1023 over k units. numpy: f < t*; FMA and
    exact: f >= t* (p = 0)."""
    W1 = np.zeros((1, d))
    b1 = np.array([2.0 ** -537])
    W2 = np.full((k, 1), 2.0 ** -538)
    b2 = np.full(k, 2.0 ** -1074)
    W3 = np.full((1, k), 2.0 ** 1023)
    b3 = np.array([0.5 - 1.5 * k * 2.0 ** -51])
    return MLP([W1, W2, W3], [b1, b2, b3], threshold=0.5, loss="mse")


def net_overflow():
    """Partial sums overflow: at x = (1, ..., 1) the exact pre-activation is
    1.7e308 > 0, but every left-to-right (and numpy's) evaluation gives -inf,
    whose ReLU is a finite 0. Float: f = 0 < t* = 0.5; exact F = 1.7e8."""
    big = 1.7e308
    W1 = np.array([[-big, -big, big, big, big]])
    return MLP([W1, np.array([[1e-300]])], [np.zeros(1), np.array([0.0])], threshold=0.5)


# ------------------------------------- red-team nets (exact ties, adversarial shapes)

def threshold_ties_bce(d=14):
    """f = relu(x1) + relu(x2) - 1: f = 0 = t* exactly on half the cube (not a
    failure), f = -1 on a quarter (p = 1/4)."""
    W1 = np.zeros((2, d))
    W1[0, 0] = 1
    W1[1, 1] = 1
    return MLP([W1, np.array([[1.0, 1.0]])], [np.zeros(2), np.array([-1.0])], threshold=0.0, loss="bce")


def shift_to_quantile(net, k):
    """Threshold between the k-th and (k+1)-th smallest outputs."""
    f = np.sort(net.forward(all_inputs(net.d, 0, 1 << net.d)))
    net.bs[-1] = net.bs[-1] + (net.threshold - (f[k - 1] + f[k]) / 2)
    return net


def decoy(d=16, seed=0):
    """A strong funnel to a non-failing basin (floor 0.52) and a weakly pulled
    Hamming ball of failures elsewhere."""
    rng = np.random.default_rng(seed)
    u = rng.choice([-1.0, 1.0], d)
    v = -u.copy()
    v[: d // 4] *= -1
    W1 = np.stack([u, v, v, np.zeros(d)])
    b1 = np.array([0.0, -(d - 4.0), float(d), 1.0])
    a = np.array([-0.48 / d, -0.3, -0.01 / d, 0.0])
    return MLP([W1, a[None, :]], [b1, np.array([1.02])], threshold=0.5, loss="mse")


def needle(d=12, seed=1):
    v = np.random.default_rng(seed).choice([-1.0, 1.0], d)
    return MLP([v[None, :], np.array([[-1.0]])], [np.array([-(d - 1.0)]), np.array([1.0])], threshold=0.5)


def integer_ties(d=12, seed=5):
    """Integer weights: many exact ties of f at intermediate levels."""
    rng = np.random.default_rng(seed)
    W1 = rng.integers(-1, 2, (10, d)).astype(float)
    b1 = rng.integers(-2, 3, 10).astype(float)
    a = rng.integers(-1, 2, (1, 10)).astype(float)
    net = MLP([W1, a], [b1, np.array([0.0])], threshold=0.5, loss="mse")
    f = np.sort(net.forward(all_inputs(d, 0, 1 << d)))
    net.bs[-1] = net.bs[-1] - f[int(5e-3 * len(f))]
    return net


def p_one(d=10):
    return MLP([np.zeros((2, d)), np.array([[1.0, 1.0]])], [np.zeros(2), np.array([0.0])], threshold=0.5)


def p_zero_close(d=12, seed=6):
    """p = 0 with the minimum output 1e-12 above the threshold."""
    net = init_mlp(d, [16], np.random.default_rng(seed))
    f = net.forward(all_inputs(d, 0, 1 << d))
    net.bs[-1] = net.bs[-1] + (0.5 + 1e-12 - f.min())
    return net


def wide_scale(d=12, seed=2, k=30):
    """Weights with magnitudes e^-12 .. e^12 (first layer) and e^-6 .. e^6."""
    rng = np.random.default_rng(seed)
    net = init_mlp(d, [12, 8], rng)
    net.Ws[0] = net.Ws[0] * np.exp(rng.uniform(-12, 12, net.Ws[0].shape))
    net.Ws[1] = net.Ws[1] * np.exp(rng.uniform(-6, 6, net.Ws[1].shape))
    return shift_to_quantile(net, k)


# ------------------------------------------------- forward-error bound

@pytest.mark.parametrize("seed", range(3))
def test_error_bound_random_and_mixed_magnitude_nets(seed):
    rng = np.random.default_rng(seed)
    nets = [init_mlp(8, [6], rng), init_mlp(8, [5, 4], rng)]
    m = init_mlp(8, [6, 3], rng)
    m.Ws[0] = m.Ws[0] * np.exp(rng.uniform(-40, 40, m.Ws[0].shape))  # 1e-17 .. 1e17
    m.Ws[1] = m.Ws[1] * np.exp(rng.uniform(-300, 300, m.Ws[1].shape))  # down to the subnormal range
    nets.append(m)
    X = all_inputs(8, 0, 256)
    for net in nets:
        E = forward_error_bound(net)
        assert math.isfinite(E)
        assert max_error(net, X) <= Fraction(E) / 2


def test_underflow_attack_bound_holds_and_nothing_certified():
    """Red-team attack_underflow: the old bound (no underflow term) was
    3.55e-15 vs E*/2 = 5e-16, and lower_bound certified 0.97 at p = 0."""
    net = net_underflow_mse(10)
    ev = Evaluator(net)
    X = random_cube(np.random.default_rng(1), 16, 10)
    assert max_error(net, X) <= Fraction(ev.E) / 2
    x = -np.ones(10)
    f = float(net.forward(x[None])[0])
    assert f < 0.5 and exact_F(net, x) > Fraction(1, 2)  # the float evaluation does fail
    assert not ev.certified(np.array([f]))[0]
    assert exact_failure_count(net) == 1 << 10  # numpy-order p = 1, exact p = 0
    for d, seed in ((10, 5), (40, 6)):
        res = lower_bound(net_underflow_mse(d), N=200, R=16, rng=np.random.default_rng(seed))
        assert res.lower == 0.0 and res.witness_lower == 0.0


def test_underflow_ball_attack():
    """Red-team net B: |f_fl - F| = 8.3e-25 against the old E*/2 = 8.8e-40."""
    net, u = net_underflow_ball_bce(12)
    X = random_cube(np.random.default_rng(2), 12, 12)
    X[:4] = u
    for i in range(1, 4):
        X[i, :i] *= -1
    ev = Evaluator(net)
    assert max_error(net, X) <= Fraction(ev.E) / 2
    assert exact_failure_count(net) > 0  # float failures exist ...
    assert not ev.certified(net.forward(all_inputs(12, 0, 1 << 12))).any()  # ... none is certified
    assert lower_bound(net, N=200, R=16, rng=np.random.default_rng(3)).lower == 0.0


@pytest.mark.parametrize("d", [14, 40, 64])
def test_visible_ball_attack(d):
    """Red-team attack_underflow2: the old code certified 9.35e-9 (d = 40) and
    1.5e-15 (d = 64) at exact p = 0."""
    net, u = net_visible_ball(d)
    ev = Evaluator(net)
    X = np.tile(u, (5, 1))
    for i in range(5):
        X[i, :i] *= -1
    assert max_error(net, X) <= Fraction(ev.E) / 2
    assert net.forward(X[:1])[0] < 0 < exact_F(net, X[0])
    res = lower_bound(net, N=1000 if d > 14 else 500, R=32, rng=np.random.default_rng(100))
    assert res.lower == 0.0


def test_fma_attack():
    """Red-team attack_fma: numpy and FMA evaluations differed by 7.1e-15
    against the old E* = 1.9e-15; a numpy-certified witness was not a
    failure under FMA evaluation."""
    net = net_fma(10)
    ev = Evaluator(net)
    x = -np.ones(10)
    f_np = float(net.forward(x[None])[0])
    f_fma = fma_forward(net, x)
    F = exact_F(net, x)
    assert f_np < 0.5 <= f_fma and F >= Fraction(1, 2)
    assert abs(Fraction(f_np) - F) <= Fraction(ev.E) / 2 and abs(Fraction(f_fma) - F) <= Fraction(ev.E) / 2
    # certified (numpy order) implies a failure in every admissible order
    X = all_inputs(10, 0, 1 << 10)
    s = net.forward(X)
    for i in np.flatnonzero(ev.certified(s)):
        assert fma_forward(net, X[i]) < 0.5 and sequential_forward(net, X[i]) < 0.5
    assert lower_bound(net, N=200, R=16, rng=np.random.default_rng(1)).lower == 0.0


def test_fma_and_sequential_orders_within_bound_on_trained_scale_net():
    rng = np.random.default_rng(7)
    net = init_mlp(10, [12, 6], rng)
    E = forward_error_bound(net)
    for x in random_cube(rng, 40, 10):
        F = exact_F(net, x)
        for f in (float(net.forward(x[None])[0]), fma_forward(net, x), sequential_forward(net, x)):
            assert abs(Fraction(f) - F) <= Fraction(E) / 2


def test_overflow_gives_no_bound():
    """A finite but wrong float output (0 against an exact 1.7e8) from an
    overflowing partial sum: the bound must be refused, not just computed."""
    net = net_overflow()
    x = np.ones(5)
    with np.errstate(all="ignore"):
        f = float(net.forward(x[None])[0])
    assert math.isfinite(sequential_forward(net, x)) and sequential_forward(net, x) < 0.5
    assert exact_F(net, x) > Fraction(1, 2)
    assert math.isfinite(f)  # numpy too returns a finite value here
    assert forward_error_bound(net) == math.inf
    ev = Evaluator(net)
    assert not ev.decided and not ev.certified(np.array([f, -1.0])).any()
    res = lower_bound(net, N=50, R=4, rng=np.random.default_rng(0))
    assert res.lower == 0.0 and res.notes.get("undecided")


@pytest.mark.parametrize("where", ["weight", "bias", "threshold_nan", "threshold_inf"])
def test_nonfinite_parameters_decide_nothing(where):
    net = init_mlp(6, [4], np.random.default_rng(0))
    if where == "weight":
        net.Ws[0][1, 2] = math.nan
    elif where == "bias":
        net.bs[1][0] = math.inf
    elif where == "threshold_nan":
        net.threshold = math.nan
    else:
        net.threshold = math.inf
    ev = Evaluator(net)
    assert not ev.decided
    assert lower_bound(net, N=50, R=4, rng=np.random.default_rng(1)).lower == 0.0


def test_nonfinite_scores_are_undecided():
    ev = Evaluator(init_mlp(6, [4], np.random.default_rng(0)))
    for bad in (math.nan, math.inf, -math.inf):
        s = np.array([0.0, bad])
        assert ev.ambiguous(s, -10.0)
        assert not ev.certified(s)[1]


def test_certified_level_is_exactly_E_below_threshold():
    for net in (init_mlp(8, [6], np.random.default_rng(3)), net_fma(6), threshold_ties_bce(6)):
        ev = Evaluator(net)
        assert Fraction(ev.thr) - Fraction(ev.t_cert) >= Fraction(ev.E) > 0


# ------------------------------------------------- completeness on ties

def test_exact_threshold_ties_are_not_flagged():
    """Red-team threshold_ties_bce: f = t* exactly on half the cube flagged
    every replicate (L = 0 at p = 0.25)."""
    net = threshold_ties_bce()
    p = exact_failure_count(net) / 2 ** net.d
    assert p == 0.25 and exact_p(threshold_ties_bce(6)) == Fraction(1, 4)
    ev = Evaluator(net)
    assert not ev.ambiguous(np.array([0.0, 1.0, -1.0]), ev.t_cert)
    for seed in range(3):
        res = lower_bound(net, N=200, R=16, rng=np.random.default_rng(seed))
        assert res.flagged == 0
        assert 0.1 < res.lower <= p


# ------------------------------------------------- exactness

def test_witnesses_are_failures_and_exact_on_a_needle():
    net = needle(12)
    res = lower_bound(net, N=300, R=8, rng=np.random.default_rng(4))
    assert res.lower <= 2.0 ** -12
    W = Witnesses(Evaluator(net))
    X = all_inputs(12, 0, 1 << 12)
    W.add(X, net.forward(X))
    assert W.count == 1 and W.lower() == 2.0 ** -12


def three_point_net(d):
    """Fails (f < 0) iff x_1..x_{d-2} are all +1 and not x_{d-1} = x_d = +1:
    exactly 3 failing points, p = 3 / 2^d."""
    k = d - 2
    W1 = np.zeros((2, d))
    W1[0, :k] = 1.0
    W1[1, k:] = 1.0
    return MLP([W1, np.array([[-1.0, 2.0]])], [np.array([-(k - 2.0), -1.0]), np.array([1.0])], threshold=0.0)


@pytest.mark.parametrize("d", [1075, 1076])
def test_regression_subnormal_counts_are_rounded_down(d):
    """Referee counterexample: math.ldexp(3, -1075) = 4 * 2^-1075 > p. Every
    witness and stratum bound must be at most p exactly."""
    net = three_point_net(d)
    pts = np.ones((3, d))
    pts[0, -2:] = (-1, -1)
    pts[1, -2:] = (-1, 1)
    pts[2, -2:] = (1, -1)
    p = Fraction(3, 1 << d)
    ev = Evaluator(net)
    W = Witnesses(ev)
    W.add(pts, ev.score(pts))
    assert W.count == 3
    assert Fraction(W.lower()) <= p and W.lower() == _float_down(p)
    for strat in (False, True):
        r = lower_bound(net, N=20, R=2, moves=1, rng=np.random.default_rng(0), witnesses=W, stratify=strat,
                        max_levels=3)
        assert Fraction(r.lower) <= p and Fraction(r.witness_lower) <= p
        assert Fraction(r.notes["stratum"]) <= p


def test_regression_betting_lower_subnormal_end():
    """Referee counterexample: 64 replicates Z = 3 * 2^-1074 gave p0 = Z,
    outside its own confidence set (E(p0) = 1 < 1/delta)."""
    z = 3 * 2.0 ** -1074
    L = betting_lower(np.full(64, z), 0.05)
    assert 0 < L < z
    assert betting_lower(np.full(64, 2.0 ** -1074), 0.05) == 0.0


@pytest.mark.parametrize("lams", [(3.0,), (-0.5,), (0.5, 1.5), (), (math.nan,), [[0.5]]])
def test_regression_bet_sizes_must_lie_in_unit_interval(lams):
    """Referee counterexample: lams = (3,) gave Pr[L > p] = 0.13 > delta = 0.05."""
    with pytest.raises(ValueError):
        betting_lower(np.array([1e-6, 0.0, 2e-6]), 0.05, lams=lams)
    with pytest.raises(ValueError):
        betting_lower(np.zeros(3), 0.05, lams=lams)


def test_regression_supplied_witnesses_are_recertified():
    """Referee counterexamples (d = 8, p = 0): witnesses collected on a net that
    fails everywhere gave lower = 0.52; a non-cube point (x_0 = 0, where
    f = |x_0| = 0 < t) was packed as the cube point x_0 = -1 and gave 2^-8."""
    d = 8
    W1 = np.eye(d)[:1]
    safe = MLP([W1, np.array([[1.0]])], [np.zeros(1), np.array([1.0])], threshold=0.5)
    always = MLP([W1, np.array([[1.0]])], [np.zeros(1), np.array([-1.0])], threshold=0.5)
    assert exact_failure_count(safe) == 0 and exact_failure_count(always) == 2 ** d
    ev_other = Evaluator(always)
    Wo = Witnesses(ev_other)
    X = random_cube(np.random.default_rng(0), 200, d)
    Wo.add(X, ev_other.score(X))
    assert Wo.count > 100
    r = lower_bound(safe, N=50, R=4, rng=np.random.default_rng(1), witnesses=Wo)
    assert r.lower == 0.0 and r.witness_lower == 0.0
    absnet = MLP([np.vstack([W1, -W1]), np.array([[1.0, 1.0]])], [np.zeros(2), np.zeros(1)], threshold=0.5)
    assert exact_failure_count(absnet) == 0
    ev = Evaluator(absnet)
    Wn = Witnesses(ev)
    Y = np.full((1, d), -1.0)
    Y[0, 0] = 0.0
    with pytest.raises(ValueError):
        Wn.add(Y, ev.score(Y))
    Wn.codes.update(pack(np.full((1, d), -1.0)))  # a forged code: a cube point that does not fail
    Wn.codes.add(b"\x00\x00")  # and one of the wrong length
    r = lower_bound(absnet, N=50, R=4, rng=np.random.default_rng(1), witnesses=Wn)
    assert r.lower == 0.0 and r.witness_lower == 0.0
    # genuine witnesses survive re-certification
    net = needle(10)
    ev = Evaluator(net)
    Wg = Witnesses(ev)
    X = all_inputs(10, 0, 1 << 10)
    Wg.add(X, ev.score(X))
    assert Wg.count == 1
    r = lower_bound(net, N=50, R=4, rng=np.random.default_rng(2), witnesses=Wg)
    assert r.witness_lower == 2.0 ** -10 and r.lower >= 2.0 ** -10


def test_smc_Z_is_rounded_down_exact_product():
    rng = np.random.default_rng(5)
    net = shift_to_quantile(init_mlp(10, [16], rng), 20)
    ev = Evaluator(net)
    plan = pilot_plan(ev, 100, 0.3, 2, rng).plan
    plan.N = 7
    for _ in range(50):
        r = run_smc(ev, plan, rng)
        if r.flagged or r.Z == 0:
            continue
        exact = Fraction(math.prod(r.counts), plan.N ** len(r.counts))
        assert Fraction(r.Z) <= exact and float(exact) - r.Z <= 2 * math.ulp(r.Z)


def test_pilot_levels_strictly_decreasing_and_end_at_certified_level():
    for net in (decoy(), integer_ties(), wide_scale(), threshold_ties_bce(), p_zero_close()):
        ev = Evaluator(net)
        plan = pilot_plan(ev, 200, 0.3, 2, np.random.default_rng(0)).plan
        assert plan.levels[-1] == ev.t_cert
        assert all(a > b for a, b in zip(plan.levels, plan.levels[1:]))
        assert len(plan.moves) == len(plan.flips) == len(plan.levels) - 1


# ------------------------------------------------- unbiasedness

@pytest.mark.parametrize("moves", [0, 2])
def test_smc_unbiased_against_enumeration(moves):
    """E Z = D(A_K) for any invariant kernel, including no moves at all."""
    rng = np.random.default_rng(11)
    net = shift_to_quantile(init_mlp(10, [16], rng), 12)
    ev = Evaluator(net)
    f = net.forward(all_inputs(10, 0, 1 << 10))
    assert not ev.ambiguous(f, ev.t_cert)
    target = float(np.mean(f < ev.t_cert))
    base = pilot_plan(ev, 100, 0.3, 2, rng).plan
    plan = Plan(base.levels, 10, [moves] * len(base.moves), list(base.flips))
    Z = []
    for _ in range(3000):
        r = run_smc(ev, plan, rng)
        assert not r.flagged
        Z.append(r.Z)
    Z = np.array(Z)
    se = Z.std(ddof=1) / math.sqrt(len(Z))
    assert abs(Z.mean() - target) < 4.5 * se


# ------------------------------------------------- betting bound

def test_betting_lower_edge_cases():
    assert betting_lower([0.0, 0.0], 0.05) == 0.0
    assert betting_lower([], 0.05) == 0.0
    with pytest.raises(ValueError):
        betting_lower([1.0, -1.0], 0.05)
    with pytest.raises(ValueError):
        betting_lower([1.0, math.nan], 0.05)
    L = betting_lower(np.full(64, 3.0), 0.05)
    assert 0 < L < 3.0
    assert betting_lower(np.full(64, 3.0), 0.01) < L  # smaller delta, smaller bound


@pytest.mark.parametrize("law", ["two-point", "lognormal"])
def test_betting_lower_coverage(law):
    rng = np.random.default_rng(12)
    delta, trials, R = 0.1, 600, 8
    draw = {"two-point": lambda: (rng.random(R) < 0.05) / 0.05,
            "lognormal": lambda: np.exp(rng.normal(-2.0, 2.0, R))}[law]  # mean 1 in both
    miss = seq_miss = 0
    for i in range(trials):
        Z = draw()
        miss += betting_lower(Z, delta) > 1.0
        if i < 200:  # running maximum over the replicates: anytime-valid
            seq_miss += max(betting_lower(Z[:k], delta) for k in range(1, R + 1)) > 1.0
    assert miss / trials <= delta + 3 * math.sqrt(delta * (1 - delta) / trials)
    assert seq_miss / 200 <= delta + 3 * math.sqrt(delta * (1 - delta) / 200)


# ------------------------------------------------- coverage on adversarial nets

ADVERSARIAL = dict(decoy=decoy, needle=needle, integer_ties=integer_ties, p_one=p_one, p_zero_close=p_zero_close,
                   wide_scale=wide_scale, threshold_ties=threshold_ties_bce)


@pytest.mark.parametrize("name", sorted(ADVERSARIAL))
def test_coverage_on_adversarial_nets(name):
    """Tiny budgets (to make misses visible); a sound bound exceeds p in at
    most a delta fraction of runs (here with a 3-sigma allowance)."""
    net = ADVERSARIAL[name]()
    p = exact_failure_count(net) / 2 ** net.d
    rng = np.random.default_rng(13)
    delta, runs = 0.2, 60
    miss = seq_miss = 0
    for _ in range(runs):
        r = lower_bound(net, delta=delta, N=40, R=4, moves=2, rho=0.3, rng=rng)
        assert r.witness_lower <= p
        miss += r.lower > p
    for _ in range(runs // 2):
        r = lower_bound(net, delta=delta, N=40, R=24, moves=2, rho=0.3, rng=rng, target_ratio=0.9, min_R=2)
        seq_miss += r.lower > p
    if p == 0:
        assert miss == seq_miss == 0
    assert miss / runs <= delta + 3 * math.sqrt(delta * (1 - delta) / runs)
    assert seq_miss / (runs // 2) <= delta + 3 * math.sqrt(delta * (1 - delta) / (runs // 2))


def test_stratified_bound_on_small_net():
    """The stratum (pilot witnesses, removed from the last level) is added back
    exactly; the reported bound is max(stratum + SMC bound, witness bound)."""
    rng = np.random.default_rng(14)
    net = shift_to_quantile(init_mlp(12, [16], rng), 40)
    p = exact_failure_count(net) / 2 ** 12
    misses = 0
    for _ in range(10):
        r = lower_bound(net, N=100, R=8, rng=rng, stratify=True)
        assert 0 < r.notes["stratum"] <= r.witness_lower <= p
        assert r.lower == max(_float_down(Fraction(r.notes["stratum"]) + Fraction(r.smc_lower)), r.witness_lower)
        misses += r.lower > p
    assert misses <= 3  # Pr[Binomial(10, 0.05) >= 4] < 1e-3
