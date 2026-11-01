"""Nets of the architecture built to break the lower bound (not trained):
planted failure sets that SMC cannot see, nets that defeat the floating-point
argument (gradual underflow, fused multiply-add, overflow), exact ties at the
threshold, and the adversarial shapes of the design round's red-team review.
code/tests/test_nets_lower.py has its own copies of the float64 attacks.

exact_p(net) is the exact-real failure probability: float64 enumeration,
with every output within E*/2 of the threshold re-evaluated in rationals."""

import math
from fractions import Fraction
from itertools import combinations

import common  # noqa: F401  (sets OMP_NUM_THREADS=1 before numpy is imported)
import numpy as np  # noqa: E402
from rareprob.nets import MLP, all_inputs, init_mlp  # noqa: E402
from rareprob.nets_lower import forward_error_bound  # noqa: E402


def exact_F(net, x):
    h = [Fraction(float(v)) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = [Fraction(float(b[j])) + sum(Fraction(float(W[j, i])) * h[i] for i in range(len(h)))
             for j in range(W.shape[0])]
        h = z if li == len(net.Ws) - 1 else [max(v, Fraction(0)) for v in z]
    return h[0]


def _fma(a, b, c):
    if hasattr(math, "fma"):
        return math.fma(a, b, c)
    return float(Fraction(a) * Fraction(b) + Fraction(c))  # correctly rounded


def _forward_by(net, x, step):
    h = [float(v) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = []
        for j in range(W.shape[0]):
            acc = float(b[j])
            for i in range(len(h)):
                acc = step(float(W[j, i]), h[i], acc)
            z.append(acc)
        h = z if li == len(net.Ws) - 1 else [max(v, 0.0) for v in z]
    return h[0]


def fma_forward(net, x):
    """An admissible float64 evaluation other than numpy's: acc = b; acc = fma(w_i, h_i, acc)."""
    return _forward_by(net, x, _fma)


def sequential_forward(net, x):
    """Another admissible evaluation: acc = b; acc = acc + w_i h_i, left to right."""
    return _forward_by(net, x, lambda w, h, acc: acc + w * h)


def exact_count(net, block=1 << 16):
    """Number of x with F(x) < t* (exact real F), d <= 24."""
    E = forward_error_bound(net)
    t = float(net.threshold)
    assert math.isfinite(E) and net.d <= 24
    total = 0
    for s in range(0, 1 << net.d, block):
        X = all_inputs(net.d, s, min(s + block, 1 << net.d))
        f = net.forward(X)
        total += int((f < t - E / 2).sum())  # F <= f + E/2 < t
        unsure = np.flatnonzero(np.abs(f - t) <= E / 2)
        total += sum(exact_F(net, X[i]) < Fraction(t) for i in unsure)
    return total


def exact_p(net):
    return exact_count(net) / 2.0 ** net.d


# ------------------------------------------------- planted failure sets

def planted(d, m, k, rng, ball=True, noise=0.002, width=16):
    """f = 1 - (0.75/2m) relu(<x,u> - (d - 2m)) - relu(<x_S, b> - (k - 1)) + small
    random units: a visible Hamming ball around u (f decreases towards it)
    and a hidden subcube {x_S = b} (f flat outside it)."""
    u = rng.choice([-1.0, 1.0], d)
    S = rng.choice(d, k, replace=False)
    b = rng.choice([-1.0, 1.0], k)
    W = [rng.normal(0, 1 / math.sqrt(d), (width, d))]
    a = list(rng.normal(0, noise, width))
    bias = list(np.zeros(width))
    if ball:
        W.append(u[None, :])
        a.append(-0.75 / (2 * m))
        bias.append(-(d - 2 * m))
    w = np.zeros(d)
    w[S] = b
    W.append(w[None, :])
    a.append(-1.0)
    bias.append(-(k - 1.0))
    return MLP([np.concatenate(W, axis=0), np.array(a)[None, :]], [np.array(bias), np.array([1.0])],
               threshold=0.5, loss="mse")


def hidden_d40(rng):
    """d = 40: a visible ball (Hamming radius 2 around u, 821 points) and a
    hidden subcube of codimension 26 (2^14 points), f flat (noise < 0.03)
    elsewhere. Returns (net, p, p_visible); p is exact because outside the
    two candidate sets f >= 0.6 - 0.03, and on them |f - 1/2| > 0.02."""
    d, m, k, width = 40, 6, 26, 16
    u = rng.choice([-1.0, 1.0], d)
    S = rng.choice(d, k, replace=False)
    b = rng.choice([-1.0, 1.0], k)
    Wn = rng.normal(0, 1 / math.sqrt(d), (width, d))
    an = rng.normal(0, 3e-5, width)
    assert float(np.sum(np.abs(an) * np.abs(Wn).sum(axis=1))) < 0.03
    w = np.zeros(d)
    w[S] = b
    W1 = np.concatenate([Wn, u[None, :], w[None, :]], axis=0)
    a = np.concatenate([an, [-0.8 / (2 * m), -1.0]])
    bias = np.concatenate([np.zeros(width), [-(d - 2 * m), -(k - 1.0)]])
    net = MLP([W1, a[None, :]], [bias, np.array([1.0])], threshold=0.5, loss="mse")
    ball = [u.copy()]
    for i in range(d):
        x = u.copy()
        x[i] *= -1
        ball.append(x)
    for i, j in combinations(range(d), 2):
        x = u.copy()
        x[i] *= -1
        x[j] *= -1
        ball.append(x)
    free = np.setdiff1d(np.arange(d), S)
    idx = np.arange(1 << len(free))
    cube = np.empty((len(idx), d))
    cube[:, S] = b
    cube[:, free] = np.where((idx[:, None] >> np.arange(len(free))) & 1, 1.0, -1.0)
    cand = np.unique(np.concatenate([np.array(ball), cube]), axis=0)
    f = net.forward(cand)
    assert np.all(np.abs(f - 0.5) > 0.02)
    p = int((f < 0.5).sum()) / 2.0 ** d
    p_vis = int((net.forward(np.array(ball)) < 0.5).sum()) / 2.0 ** d
    return net, p, p_vis


# ------------------------------------------------- float64 attacks (exact p = 0)

def underflow_mse(d, k=8):
    """h2 = 2^-1075 exactly, 0 in float; amplified by 2^1024 - 2^971 over k units."""
    W3 = np.full((1, k), float.fromhex("0x1.fffffffffffffp+1023"))
    return MLP([np.zeros((1, d)), np.full((k, 1), 2.0 ** -538), W3],
               [np.array([2.0 ** -537]), np.zeros(k), np.array([0.5 - 3 * 2.0 ** -50])], threshold=0.5)


def underflow_ball_bce(d, m=4, seed=0):
    rng = np.random.default_rng(seed)
    u = rng.choice([-1.0, 1.0], d)
    W1 = np.zeros((2, d))
    W1[0] = u
    a = 2.0 ** -85
    return MLP([W1, np.array([[1.0, 0.0], [0.0, 2.0 ** -540]]), np.array([[-a, 2.0 ** 1000]])],
               [np.array([-(d - 2.0 * m), 2.0 ** -540]), np.zeros(2), np.array([a])], threshold=0.0, loss="bce")


def visible_ball(d, r=4, seed=0):
    rng = np.random.default_rng(seed)
    u = rng.choice([-1.0, 1.0], d)
    W1 = np.zeros((2, d))
    W1[0] = u
    a = 2.0 ** -83
    return MLP([W1, np.array([[1.0, 0.0], [0.0, 2.0 ** -540]]), np.array([[-a, 2.0 ** 1000]])],
               [np.array([float(d), 2.0 ** -540]), np.zeros(2), np.array([a * (2 * d - 2 * r + 1)])],
               threshold=0.0, loss="bce")


def fma_tie(d, k=16):
    return MLP([np.zeros((1, d)), np.full((k, 1), 2.0 ** -538), np.full((1, k), 2.0 ** 1023)],
               [np.array([2.0 ** -537]), np.full(k, 2.0 ** -1074), np.array([0.5 - 1.5 * k * 2.0 ** -51])],
               threshold=0.5)


def overflow(d=5):
    """Partial sums overflow to -inf (ReLU 0, a finite output) where the exact
    pre-activation 1.7e308 (x3 + x4 + x5 - x1 - x2) is positive. Exact F =
    1e-300 relu(.) fails iff x3 + x4 + x5 - x1 - x2 < 0: p = 1/2."""
    big = 1.7e308
    w = np.array([-big, -big, big, big, big] + [0.0] * (d - 5))
    return MLP([w[None, :], np.array([[1e-300]])], [np.zeros(1), np.array([0.0])], threshold=0.5)


FLOAT_ATTACKS = {  # name: (constructor, exact p)
    "underflow_mse_d10": (lambda: underflow_mse(10), 0.0),
    "underflow_mse_d40": (lambda: underflow_mse(40), 0.0),
    "underflow_ball_bce_d12": (lambda: underflow_ball_bce(12), 0.0),
    "underflow_ball_bce_d40": (lambda: underflow_ball_bce(40), 0.0),
    "visible_ball_d14": (lambda: visible_ball(14), 0.0),
    "visible_ball_d40": (lambda: visible_ball(40), 0.0),
    "visible_ball_d64": (lambda: visible_ball(64), 0.0),
    "fma_tie_d10": (lambda: fma_tie(10), 0.0),
    "overflow_d5": (lambda: overflow(5), 0.5),
}


# ------------------------------------------------- red-team adversarial shapes (d <= 16, exact p)

def shift_to_quantile(net, k):
    f = np.sort(net.forward(all_inputs(net.d, 0, 1 << net.d)))
    net.bs[-1] = net.bs[-1] + (net.threshold - (f[k - 1] + f[k]) / 2)
    return net


def decoy(d=16, seed=0):
    """A strong funnel to a non-failing basin (floor 0.52) and a weakly pulled ball of failures."""
    rng = np.random.default_rng(seed)
    u = rng.choice([-1.0, 1.0], d)
    v = -u.copy()
    v[: d // 4] *= -1
    W1 = np.stack([u, v, v, np.zeros(d)])
    a = np.array([-0.48 / d, -0.3, -0.01 / d, 0.0])
    return MLP([W1, a[None, :]], [np.array([0.0, -(d - 4.0), float(d), 1.0]), np.array([1.02])], threshold=0.5)


def needle(d=16, seed=1):
    v = np.random.default_rng(seed).choice([-1.0, 1.0], d)
    return MLP([v[None, :], np.array([[-1.0]])], [np.array([-(d - 1.0)]), np.array([1.0])], threshold=0.5)


def wide_scale(d=16, seed=2, k=40):
    rng = np.random.default_rng(seed)
    net = init_mlp(d, [12, 8], rng)
    net.Ws[0] = net.Ws[0] * np.exp(rng.uniform(-12, 12, net.Ws[0].shape))
    net.Ws[1] = net.Ws[1] * np.exp(rng.uniform(-6, 6, net.Ws[1].shape))
    return shift_to_quantile(net, k)


def random_depth2(d=16, seed=3, k=30):
    return shift_to_quantile(init_mlp(d, [24, 24], np.random.default_rng(seed)), k)


def dead_units(d=16, seed=4, k=20):
    net = init_mlp(d, [32], np.random.default_rng(seed))
    net.bs[0][:24] = -50.0
    return shift_to_quantile(net, k)


def integer_ties(d=14, seed=5):
    rng = np.random.default_rng(seed)
    net = MLP([rng.integers(-1, 2, (10, d)).astype(float), rng.integers(-1, 2, (1, 10)).astype(float)],
              [rng.integers(-2, 3, 10).astype(float), np.array([0.0])], threshold=0.5)
    f = np.sort(net.forward(all_inputs(d, 0, 1 << d)))
    net.bs[-1] = net.bs[-1] - f[int(1e-3 * len(f))]
    return net


def p_one(d=12):
    return MLP([np.zeros((2, d)), np.array([[1.0, 1.0]])], [np.zeros(2), np.array([0.0])], threshold=0.5)


def p_zero_close(d=14, seed=6):
    net = init_mlp(d, [16], np.random.default_rng(seed))
    f = net.forward(all_inputs(d, 0, 1 << d))
    net.bs[-1] = net.bs[-1] + (0.5 + 1e-12 - f.min())
    return net


def threshold_ties_bce(d=14):
    W1 = np.zeros((2, d))
    W1[0, 0] = W1[1, 1] = 1
    return MLP([W1, np.array([[1.0, 1.0]])], [np.zeros(2), np.array([-1.0])], threshold=0.0, loss="bce")


ADVERSARIAL = dict(decoy=decoy, needle=needle, wide_scale=wide_scale, random_depth2=random_depth2,
                   dead_units=dead_units, integer_ties=integer_ties, p_one=p_one, p_zero_close=p_zero_close,
                   threshold_ties_bce=threshold_ties_bce)
