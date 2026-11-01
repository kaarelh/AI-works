"""Tests for rareprob.nets_prover: soundness of the certified-partition
verifier on every net and every argument, checked against exact rational
evaluation of the net on all points.

Every counterexample of the red team on the earlier version is a regression
test here:
* underflow in the 'lin' check (a subnormal output weight times a huge
  first layer; exact ReLU rescalings of ordinary nets by powers of two);
* underflow of G kap in the 'quad' matrix (majorant terms dropped; a
  malicious theta at output scale 2^-53 whose subnormal products round up);
* the drop rule for units whose backward coefficient has uncertain sign,
  which did not charge the rounding of G (two hidden layers, normal scales);
* the absolute 2^-30 floor of the point tolerance, which sent every point to
  exact evaluation at small output scales;
* prover crashes (NaN in eigh) on nets with huge first-layer weights.

and so is every counterexample of the referee on this version:
* a float output that overflows to +inf at a point whose exact output is
  below t was read as surely safe (tau = inf makes the safe threshold +inf,
  and inf >= inf);
* a non-integer root was truncated to int8 before it was validated;
* CertNet crashed on thresholds within tau of the largest float.
"""

import math
from fractions import Fraction

import numpy as np
import pytest

from rareprob.nets import MLP, train_constant
from rareprob.nets_prover import (CertNet, ENUM, FAIL, OPEN, SAFE, SPLIT, ProverConfig, _imm_iv, _imm_pt, _midrad,
                                  _opt_alpha, _psd_box, _quad_coeffs, _sum_lo, knuth_estimate, prove, verify,
                                  witness_lower_bound)


# ---------------------------------------------------------------------------
# exact evaluation (Python integers): f = vals / 2^S on all points


def _int_scaled(A):
    A = np.asarray(A, dtype=np.float64)
    ratios = [float(v).as_integer_ratio() for v in A.ravel()]
    s = max(den.bit_length() - 1 for _, den in ratios) if ratios else 0
    ints = [n << (s - (den.bit_length() - 1)) for n, den in ratios]
    return np.array(ints, dtype=object).reshape(A.shape), s


def all_points(d, root=None):
    X = np.where((np.arange(1 << d)[:, None] >> np.arange(d)) & 1, 1, -1)
    if root is not None:
        root = np.asarray(root)
        m = root != 0
        X = X[np.all(X[:, m] == root[m], axis=1)]
    return X


def exact_values(net, X):
    """Exact f on the rows of X (+-1 ints) as a list of Fractions."""
    h = np.array(X, dtype=object)
    S = 0
    for k in range(len(net.Ws)):
        Wi, sw = _int_scaled(net.Ws[k])
        bi, sb = _int_scaled(np.asarray(net.bs[k]).ravel())
        S2 = max(sw + S, sb)
        z = (h @ Wi.T) * (1 << (S2 - sw - S)) + bi * (1 << (S2 - sb))
        S = S2
        if k < len(net.Ws) - 1:
            z = np.where(z > 0, z, 0)
        h = z
    return [Fraction(int(v), 1 << S) for v in h[:, 0]]


def exact_count(net, root=None):
    t = Fraction(float(net.threshold))
    return sum(v < t for v in exact_values(net, all_points(net.Ws[0].shape[1], root)))


def exact_minmax(net, x0):
    vals = exact_values(net, all_points(net.Ws[0].shape[1], x0))
    return min(vals), max(vals)


def bound_ok(lb, net, x0, sign):
    """lb <= min over the subcube of sign * f, exactly."""
    if not math.isfinite(lb):
        return True
    lo, hi = exact_minmax(net, x0)
    return Fraction(lb) <= (lo if sign == 1 else -hi)


def contains_exact(res, F, d):
    p = Fraction(F, 1 << d)
    return Fraction(res.lo) <= p <= Fraction(res.hi)


def max_shift(cn, x0, theta, mu, sign, lo=-1.0, hi=1.0, iters=200):
    """The largest shift that check_quad accepts (bisection), as a malicious
    prover would choose it."""
    if not math.isfinite(cn.check_quad(x0, None, theta, mu, lo, sign)):
        return None
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if math.isfinite(cn.check_quad(x0, None, theta, mu, mid, sign)):
            lo = mid
        else:
            hi = mid
    return lo


def craft_mu(cn, x0, theta, sign=1):
    """mu that makes M - diag(mu) diagonally dominant (from the centre of
    the verifier's enclosure of M)."""
    Mlo, Mhi = cn.quad_matrix(x0, None, theta, sign)
    M, _ = _midrad(Mlo, Mhi)
    return np.diag(M) - (np.abs(M).sum(1) - np.abs(np.diag(M)))


def random_net(rng, d, widths, threshold=None):
    sizes = [d] + list(widths) + [1]
    Ws = [rng.normal(0, 1, (b, a)) for a, b in zip(sizes[:-1], sizes[1:])]
    bs = [rng.normal(0, 0.5, b) for b in sizes[1:]]
    net = MLP(Ws, bs, threshold=0.0)
    if threshold is None:
        X = rng.choice([-1.0, 1.0], size=(400, d))
        net.threshold = float(np.quantile(net.forward(X), rng.uniform(0.05, 0.4)))
    else:
        net.threshold = threshold
    return net


def rescale(net, e_hidden, e_out=0):
    """Exact ReLU rescaling by powers of two: hidden units of layer k get
    incoming x 2^e, outgoing x 2^-e; the output and threshold x 2^-e_out.
    p is unchanged."""
    Ws = [W.copy() for W in net.Ws]
    bs = [np.asarray(b, dtype=float).copy() for b in net.bs]
    for k in range(len(Ws) - 1):
        e = np.broadcast_to(np.asarray(e_hidden[k]), (Ws[k].shape[0],))
        Ws[k] = np.ldexp(Ws[k], e[:, None])
        bs[k] = np.ldexp(bs[k], e)
        Ws[k + 1] = np.ldexp(Ws[k + 1], -e[None, :])
    Ws[-1] = np.ldexp(Ws[-1], -e_out)
    bs[-1] = np.ldexp(bs[-1], -e_out)
    return MLP(Ws, bs, threshold=math.ldexp(net.threshold, -e_out))


def adversarial_bounds(cn, net, rng, nsub=4, quad=True):
    """'lin' with random, subnormal, all-one, all-zero and optimised slopes
    and 'quad' with random / extreme theta at the largest accepted shift, on
    random subcubes, for f and -f: every certified bound must be <= the exact
    minimum. Returns the number of checks."""
    d = cn.d
    checks = 0
    for _ in range(nsub):
        x0 = np.zeros(d)
        r = int(rng.integers(1, d + 1))
        fixed = rng.choice(d, d - r, replace=False)
        x0[fixed] = rng.choice([-1.0, 1.0], d - r)
        for sign in (1, -1):
            for mode in ("rand", "tiny", "one", "zero", "opt"):
                if mode == "opt":
                    ivs, clo, chi = cn.intervals(x0[None])
                    a0, _ = _opt_alpha(cn, x0[None], sign, ivs, 0.5 * clo + 0.5 * chi, 20)
                    al = [a0] + [None] * (cn.L - 1)
                else:
                    al = []
                    for w in cn.widths:
                        if mode == "rand":
                            al.append(rng.uniform(0, 1, (1, w)))
                        elif mode == "tiny":
                            al.append(np.full((1, w), 5e-324) * rng.integers(1, 4, (1, w)))
                        else:
                            al.append(np.full((1, w), 1.0 if mode == "one" else 0.0))
                lb = float(cn.check_lin(x0[None], al, sign)[0])
                assert bound_ok(lb, net, x0, sign), ("lin", mode, sign, lb)
                checks += 1
            if not quad:
                continue
            m1 = cn.widths[0]
            for tmode in ("rand", "rho1", "tiny_s"):
                if tmode == "rand":
                    th = rng.uniform(0, 1, (m1, 2))
                elif tmode == "rho1":
                    th = np.ones((m1, 2))
                else:
                    th = np.column_stack([np.full(m1, 1e-310), np.ones(m1)])
                try:
                    mu = craft_mu(cn, x0, th, sign)
                except ValueError:
                    continue
                if not np.isfinite(mu).all():
                    continue
                scale = max(1e-300, float(np.abs(mu).max()))
                s = max_shift(cn, x0, th, mu, sign, -4 * scale - 1e-300, 4 * scale + 1e-300, iters=80)
                if s is None:
                    continue
                lb = cn.check_quad(x0, None, th, mu, s, sign)
                assert bound_ok(lb, net, x0, sign), ("quad", tmode, sign, lb)
                checks += 1
    return checks


# ---------------------------------------------------------------------------
# interval primitives


def test_imm_encloses_exact_products_with_underflow_and_huge_entries():
    rng = np.random.default_rng(0)
    for trial in range(30):
        ea = int(rng.integers(-1100, 600))
        eb = int(rng.integers(-600, 400))
        A = np.ldexp(rng.normal(0, 1, (3, 5)), ea)
        B = np.ldexp(rng.normal(0, 1, (5, 4)), eb)
        Ar = np.abs(np.ldexp(rng.normal(0, 1, (3, 5)), ea - 30))
        lo, hi = _imm_pt(A, Ar, B, np.abs(B))
        for _ in range(3):
            Ax = A + Ar * rng.uniform(-1, 1, A.shape)  # a float matrix inside the box
            Ax = np.clip(Ax, A - Ar, A + Ar)
            Ax = np.where((Ax >= A - Ar) & (Ax <= A + Ar), Ax, A)
            for i in range(3):
                for j in range(4):
                    ex = sum(Fraction(float(Ax[i, k])) * Fraction(float(B[k, j])) for k in range(5))
                    if math.isfinite(lo[i, j]) and math.isfinite(hi[i, j]):
                        assert Fraction(float(lo[i, j])) <= ex <= Fraction(float(hi[i, j]))
        Br = np.abs(np.ldexp(rng.normal(0, 1, B.shape), eb - 20))
        lo, hi = _imm_iv(A, Ar, B, Br)
        for i in range(3):
            for j in range(4):
                ex = sum(Fraction(float(A[i, k])) * Fraction(float(B[k, j])) for k in range(5))
                if math.isfinite(lo[i, j]):
                    assert Fraction(float(lo[i, j])) <= ex <= Fraction(float(hi[i, j]))


def test_sum_lo_is_a_lower_bound():
    rng = np.random.default_rng(1)
    for _ in range(50):
        T = np.ldexp(rng.normal(0, 1, (2, 40)), rng.integers(-1074, 900, (2, 40)))
        lb = _sum_lo(T)
        for i in range(2):
            assert Fraction(float(lb[i])) <= sum(Fraction(float(v)) for v in T[i])


def test_psd_box_rejects_boxes_that_contain_an_indefinite_matrix():
    rng = np.random.default_rng(2)
    for _ in range(40):
        n = int(rng.integers(2, 8))
        Q = np.linalg.qr(rng.normal(size=(n, n)))[0]
        lam = np.abs(rng.normal(size=n)) + 0.1
        lam[0] = 10.0 ** rng.uniform(-12, -6)
        scale = 2.0 ** int(rng.integers(-1000, 900))
        A = (Q * lam) @ Q.T * scale
        A = 0.5 * (A + A.T)
        # a box whose radius exceeds the smallest eigenvalue contains A - rad I, indefinite
        rad = np.full((n, n), 2.0 * lam[0] * scale)
        assert not _psd_box(A - rad, A + rad)
        # a clearly PSD box
        B = (Q * (lam + 1.0)) @ Q.T * scale
        B = 0.5 * (B + B.T)
        r2 = np.full((n, n), 1e-6 * scale)
        assert _psd_box(B - r2, B + r2)


def test_quad_coeffs_are_valid_minorants_and_majorants_exactly():
    rng = np.random.default_rng(3)
    for _ in range(40):
        m = 12
        e = int(rng.integers(-500, 500))
        L = -np.ldexp(rng.uniform(0.01, 3, m), e)
        U = np.ldexp(rng.uniform(0.01, 3, m), e)
        G = rng.choice([-1.0, 1.0], m) * np.ldexp(1.0, int(rng.integers(-1000, 0)))
        th = rng.uniform(0, 1, (m, 2))
        kap, bet, gam, charge = _quad_coeffs(G, G, L, U, th)
        for j in range(m):
            k, b, g = (Fraction(float(v)) for v in (kap[j], bet[j], gam[j]))
            Lj, Uj = Fraction(float(L[j])), Fraction(float(U[j]))
            q = lambda z: k * z * z + b * z + g  # noqa: E731
            assert k >= 0
            if G[j] > 0:  # minorant: convex q below relu iff at L, 0 and U
                assert q(Lj) <= 0 and q(Fraction(0)) <= 0 and q(Uj) <= Uj
            else:  # majorant: q >= 0 on [L, 0] and q >= z on [0, U] (convex: endpoints and vertex)
                pts = [Lj, Fraction(0), Uj]
                if k > 0:
                    pts += [z for z in (-b / (2 * k), (1 - b) / (2 * k)) if Lj <= z <= Uj]
                for z in pts:
                    assert q(z) >= max(z, 0)


# ---------------------------------------------------------------------------
# red-team regression tests


def test_regression_lin_underflow_subnormal_output_weight():
    """f(x) = c + a relu(w x1 + b) with a = -2^-1074, |w| ~ 4e289: fl(G lam)
    rounds to -0 and the old check certified f >= 2.7e-35 on the cube while
    f(+1) = -2.8e-35 < t = 0 (verify returned [0, 0], exact, at p = 1/2)."""
    a = -math.ldexp(1.0, -1074)
    net = MLP([np.array([[4e289]]), np.array([[a]])], [np.array([-1e289]), np.array([1.2e-34])], threshold=0.0)
    cn = CertNet(net)
    assert exact_count(net) == 1
    lb = float(cn.check_lin(np.zeros((1, 1)), None, 1)[0])
    assert bound_ok(lb, net, np.zeros(1), 1) and lb < 0.0
    res = verify(cn, {"tree": [(SAFE, {"kind": "lin", "alpha": None})], "samples": 0})
    assert contains_exact(res, 1, 1) and not res.exact and res.demoted == 1
    arg, _ = prove(cn, ProverConfig(kinds=("lin",), r_leaf=0))
    res = verify(cn, arg)
    assert res.exact and res.F == 1 and res.lo == res.hi == 0.5


@pytest.mark.parametrize("lam, G, c", [(1e150, -1e-174, 0.85e-24), (1e100, -1e-224, 0.85e-24),
                                       (2.0 ** 400, -2.0 ** -700, None)])
def test_regression_quad_majorant_underflow(lam, G, c):
    """f = c + G relu(lam x1) with G kap subnormal: the old verifier dropped
    the majorant term G kap z^2 when it rounded to 0 and returned [0, 0]
    (exact) at p = 1/2, for an honest-looking certificate and for the
    honest prover."""
    if c is None:
        c = 0.85 * abs(G) * lam
    net = MLP([np.array([[lam]]), np.array([[G]])], [np.zeros(1), np.array([c])], threshold=0.0)
    cn = CertNet(net)
    F = exact_count(net)
    x0 = np.zeros(1)
    theta = np.ones((1, 2))
    mu = craft_mu(cn, x0, theta)
    s = max_shift(cn, x0, theta, mu, 1, -1e-200 - abs(c) * 10, abs(c) * 10)
    if s is not None:
        lb = cn.check_quad(x0, None, theta, mu, s, 1)
        assert bound_ok(lb, net, x0, 1)
        res = verify(cn, {"tree": [(SAFE, {"kind": "quad", "alpha": None, "theta": theta, "mu": mu, "shift": s})],
                          "samples": 0})
        assert contains_exact(res, F, 1)
    arg, _ = prove(cn, ProverConfig(kinds=("lin", "quad"), r_leaf=0, quad_rmin=1, quad_iters=100))
    res = verify(cn, arg)
    assert res.exact and res.F == F


def test_regression_quad_malicious_theta_at_output_scale_2_pow_minus_53():
    """f = 0.3 S + S relu(lam x1) / lam (S = 2^-53, lam = 2^510), t = 0.5 S:
    a malicious theta made the subnormal G kap round up; the old verifier
    certified 0.5475 S > the true minimum 0.3 S and returned [0, 0]."""
    S, lam = 2.0 ** -53, 2.0 ** 510
    W1 = np.zeros((1, 2))
    W1[0, 0] = lam
    net = MLP([W1, np.array([[S / lam]])], [np.zeros(1), np.array([0.3 * S])], threshold=0.5 * S)
    cn = CertNet(net)
    F = exact_count(net)
    assert F == 2
    x0 = np.zeros(2)
    best = -math.inf
    for frac in np.linspace(0.5, 1.0, 26)[1:]:
        th = np.array([[frac, 1.0]])
        mu = craft_mu(cn, x0, th)
        if not np.isfinite(mu).all():
            continue
        s = max_shift(cn, x0, th, mu, 1, -4 * S, 4 * S)
        if s is None:
            continue
        lb = cn.check_quad(x0, None, th, mu, s, 1)
        assert bound_ok(lb, net, x0, 1)
        best = max(best, lb)
        res = verify(cn, {"tree": [(SAFE, {"kind": "quad", "alpha": None, "theta": th, "mu": mu, "shift": s})],
                          "samples": 0})
        assert contains_exact(res, F, 2)
    assert best <= 0.3 * S


def _dropcharge_net(p, a1, a2, q, t):
    b2 = np.array([2.0 ** -28 * a1, 2.0 ** -28 * a2])
    const = p * b2[0] - q * b2[1]
    return MLP([np.array([[1.0]]), np.array([[a1], [a2]]), np.array([[p, -q]])],
               [np.array([-0.5]), b2, np.array([-const])], threshold=t)


def test_regression_drop_rule_charges_rounding_of_G():
    """Two hidden layers, d = 1, O(1) weights: G on h_1 sits exactly at the
    old drop threshold 5 REL |G|_abs; the charge omitted G's own rounding, so
    with t at the certified bound the old verifier returned [0, 0], exact,
    while the exact minimum is 9e-18 below t (p = 1/2)."""
    p, a1, a2, q = (1.6978935706830813, 1.1286732123171694, 1.3762385014280942, 1.392467226032789)
    net = _dropcharge_net(p, a1, a2, q, -8.9237792777e-9)
    cn = CertNet(net)
    F = exact_count(net)
    assert F == 1
    lb = float(cn.check_lin(np.zeros((1, 1)), None, 1)[0])
    assert bound_ok(lb, net, np.zeros(1), 1)
    res = verify(cn, {"tree": [(SAFE, {"kind": "lin", "alpha": None})], "samples": 0})
    assert contains_exact(res, F, 1)
    # the same net with t at the new certified bound, and nearby output weights (ulp by ulp)
    for k in range(-20, 21):
        qk = q + k * math.ulp(q)
        net2 = _dropcharge_net(p, a1, a2, qk, 0.0)
        cn2 = CertNet(net2)
        lb2 = float(cn2.check_lin(np.zeros((1, 1)), None, 1)[0])
        assert bound_ok(lb2, net2, np.zeros(1), 1)
        net2.threshold = lb2
        res = verify(CertNet(net2), {"tree": [(SAFE, {"kind": "lin", "alpha": None})], "samples": 0})
        assert contains_exact(res, exact_count(net2), 1)


@pytest.mark.parametrize("seed", range(6))
def test_regression_subnormal_rescalings_lin(seed):
    """Hidden units x 2^e1 (e1 in 900..960), output x 2^-(e1 + e2): output
    weights subnormal, f ~ 2^-e2. The old verifier gave a wrong exact count
    on 1 of 40 such nets and lin bound violations on 5."""
    rng = np.random.default_rng(10_000 + 2 * seed)
    d = int(rng.integers(5, 9))
    net = random_net(rng, d, [int(rng.integers(2, 9))])
    e1, e2 = int(rng.integers(900, 960)), int(rng.integers(60, 130))
    net = rescale(net, [e1], e2)
    cn = CertNet(net)
    F = exact_count(net)
    arg, _ = prove(cn, ProverConfig(kinds=("lin",), r_leaf=1, alpha_iters=10, collapse=False))
    res = verify(cn, arg, rng=np.random.default_rng(seed))
    assert contains_exact(res, F, d)
    if res.exact:
        assert res.F == F
    adversarial_bounds(cn, net, rng, nsub=3, quad=False)


@pytest.mark.parametrize("seed", range(6))
def test_regression_subnormal_rescalings_quad(seed):
    """G kap ~ 2^-(2 e1 + e2) near the subnormal floor (e1 in 150..500): the
    old quad lower bounds exceeded the exact minimum on 29 of 40 such nets
    (up to 54%)."""
    rng = np.random.default_rng(10_001 + 2 * seed)
    d = int(rng.integers(5, 8))
    net = random_net(rng, d, [int(rng.integers(2, 7))])
    e1 = int(rng.integers(150, 500))
    e2 = max(0, 1074 - 2 * e1 + int(rng.integers(-30, 10)))
    net = rescale(net, [e1], e2)
    cn = CertNet(net)
    F = exact_count(net)
    arg, _ = prove(cn, ProverConfig(kinds=("lin", "quad"), r_leaf=1, quad_rmin=2, quad_iters=40, alpha_iters=10))
    res = verify(cn, arg, rng=np.random.default_rng(seed))
    assert contains_exact(res, F, d)
    adversarial_bounds(cn, net, rng, nsub=3, quad=True)


def test_regression_point_tolerance_scales_with_the_net():
    """Scaling the output layer and the threshold of a net by 2^-40 leaves p
    unchanged; with the old absolute floor 2^-30 in tau every point went to
    exact rational evaluation (0 s -> 7.6 s at d = 14)."""
    rng = np.random.default_rng(5)
    net = random_net(rng, 10, [6])
    small = rescale(net, [0], 40)
    for nn in (net, small):
        cn = CertNet(nn)
        res = verify(cn, {"tree": [(ENUM,)], "samples": 0})
        assert res.exact and res.F == exact_count(nn)
        assert res.exact_evals <= 2
    assert CertNet(small).tau_pt == pytest.approx(math.ldexp(CertNet(net).tau_pt, -40), rel=1e-6)


def test_prover_does_not_crash_on_huge_first_layer_weights():
    """The old prover crashed (eigh on NaN) on 20 of 24 nets with huge
    first-layer weights; the old verifier refused nets with bounds > 1e290."""
    rng = np.random.default_rng(6)
    for e in (450, 700, 1000):
        net = random_net(rng, 6, [5])
        net = rescale(net, [e], 0)
        cn = CertNet(net)
        F = exact_count(net)
        arg, _ = prove(cn, ProverConfig(kinds=("lin", "quad"), r_leaf=1, quad_rmin=2, quad_iters=20))
        res = verify(cn, arg)
        assert contains_exact(res, F, 6)


def test_overflowing_bounds_are_undecided_and_points_exact():
    """Weights near the top of the float range: bounds overflow (rejected
    as undecided), float evaluation overflows at some points (re-evaluated
    exactly); the counts stay exact."""
    W1 = np.array([[1e308, 1e308, -1e308], [1e308, -1e308, 1e308]])
    net = MLP([W1, np.array([[1e10, -1e10]])], [np.zeros(2), np.array([0.5])], threshold=0.0)
    cn = CertNet(net)
    F = exact_count(net)
    assert not math.isfinite(cn.tau_pt)
    lb = cn.check_lin(np.zeros((1, 3)), None, 1)
    assert not np.isfinite(lb).any()
    res = verify(cn, {"tree": [(SAFE, {"kind": "lin", "alpha": None})], "samples": 0})
    assert contains_exact(res, F, 3)
    res = verify(cn, {"tree": [(ENUM,)], "samples": 0})
    assert res.exact and res.F == F
    arg, _ = prove(cn, ProverConfig(r_leaf=1, quad_rmin=1))
    res = verify(cn, arg)
    assert contains_exact(res, F, 3)


def _inf_output_net(mirror=False):
    """d = 1, t = 0. At x = +1 the first hidden unit is exactly 2^1024 (float:
    inf) and the second exactly FMAX, so f_float = +inf while the exact
    f = 2^1024 - FMAX - 2^972 = -2^971 < 0; at x = -1 both fail. p = 1. The
    mirror (output layer negated, t = -FMAX) has f_float = -inf at x = +1 and
    p = 0."""
    E = 2.0 ** 1023
    W1 = np.array([[E], [E - 2.0 ** 971]])
    b1 = np.array([E, E])
    s = -1.0 if mirror else 1.0
    return MLP([W1, s * np.array([[1.0, -1.0]])], [b1, s * np.array([-2.0 ** 972])],
               threshold=-np.finfo(float).max if mirror else 0.0)


def test_regression_overflow_to_inf_is_not_surely_safe():
    """Referee counterexample: verify returned the exact interval [1/2, 1/2]
    for p = 1 (the +inf point was counted safe without exact evaluation)."""
    net = _inf_output_net()
    with np.errstate(all="ignore"):
        assert net.forward(np.array([[1.0]]))[0] == math.inf
    cn = CertNet(net)
    assert not math.isfinite(cn.tau_pt)
    assert exact_count(net) == 2
    res = verify(cn, {"tree": [(ENUM,)], "samples": 0})
    assert res.exact and res.F == 2 and res.lo == res.hi == 1.0
    res = verify(cn, {"tree": [(OPEN,)], "samples": 4000}, delta=1e-6, rng=np.random.default_rng(0))
    assert contains_exact(res, 2, 1) and res.sample_fails == 4000
    assert witness_lower_bound(net, np.array([[1.0], [-1.0]])) == (1.0, 2)
    mirror = _inf_output_net(mirror=True)
    assert exact_count(mirror) == 0
    res = verify(CertNet(mirror), {"tree": [(ENUM,)], "samples": 0})
    assert res.exact and res.F == 0 and res.lo == res.hi == 0.0


@pytest.mark.parametrize("sign", [1.0, -1.0])
def test_threshold_at_the_largest_float(sign):
    """CertNet used to raise OverflowError when t + tau rounds past FMAX."""
    net = MLP([np.ones((1, 3)), np.ones((1, 1))], [np.zeros(1), np.zeros(1)],
              threshold=sign * np.finfo(float).max)
    cn = CertNet(net)
    F = exact_count(net)
    assert F == (8 if sign > 0 else 0)
    res = verify(cn, {"tree": [(ENUM,)], "samples": 0})
    assert res.exact and res.F == F
    arg, _ = prove(cn, ProverConfig(r_leaf=1))
    assert contains_exact(verify(cn, arg), F, 3)


def test_exact_ties_and_tiny_gaps():
    """Integer weights with many points exactly at t; and a point where
    float64 evaluates a failing point to exactly t (f = 1/2 - 2^-60)."""
    rng = np.random.default_rng(7)
    for _ in range(4):
        d = 7
        Ws = [rng.integers(-2, 3, (5, d)).astype(float), rng.integers(-2, 3, (1, 5)).astype(float)]
        bs = [rng.integers(-2, 3, 5).astype(float), rng.integers(-2, 3, 1).astype(float)]
        net = MLP(Ws, bs, threshold=0.0)
        net.threshold = float(np.median(net.forward(all_points(d))))
        cn = CertNet(net)
        F = exact_count(net)
        for kinds in (("lin",), ("lin", "quad")):
            arg, _ = prove(cn, ProverConfig(kinds=kinds, r_leaf=1, quad_rmin=2, quad_iters=30))
            res = verify(cn, arg)
            assert res.exact and res.F == F
    W1 = np.zeros((2, 8))
    W1[0, 0] = W1[1, 1] = 1.0
    net = MLP([W1, np.array([[-2.0 ** -60, 1e-3]])], [np.zeros(2), np.array([0.5])], threshold=0.5)
    cn = CertNet(net)
    assert exact_count(net) == 64
    for kinds in (("lin",), ("lin", "quad")):
        arg, _ = prove(cn, ProverConfig(kinds=kinds, r_leaf=1, quad_rmin=2))
        res = verify(cn, arg)
        assert res.exact and res.F == 64 and res.lo == res.hi == 0.25


# ---------------------------------------------------------------------------
# soundness campaign (small) and dishonest arguments


def _campaign_net(kind, rng):
    d = int(rng.integers(5, 8))
    L = int(rng.integers(1, 3))
    net = random_net(rng, d, [int(rng.integers(2, 7)) for _ in range(L)])
    if kind == "gauss":
        sc = [10.0 ** rng.uniform(-6, 6) for _ in net.Ws]
        Ws = [W * s for W, s in zip(net.Ws, sc)]
        bs = [b * np.prod(sc[:i + 1]) for i, b in enumerate(net.bs)]
        return random_net_like(Ws, bs, rng)
    if kind == "rescaled":
        return rescale(net, [rng.integers(-450, 451, w) for w in net.widths], 0)
    if kind == "outscale":
        return rescale(net, [0] * L, int(rng.integers(-900, 1000)))
    if kind == "dead":
        for k in range(L):
            m = net.Ws[k].shape[0]
            net.bs[k] = np.where(rng.random(m) < 0.4, -100.0, net.bs[k])
            if m >= 2:
                net.Ws[k][1] = net.Ws[k][0]
                net.bs[k][1] = net.bs[k][0]
        return net
    if kind == "p0":
        net.threshold = -1e3 * (1 + sum(np.abs(W).sum() for W in net.Ws))
        return net
    if kind == "p1":
        net.threshold = 1e3 * (1 + sum(np.abs(W).sum() for W in net.Ws))
        return net
    raise ValueError(kind)


def random_net_like(Ws, bs, rng):
    net = MLP(Ws, bs, threshold=0.0)
    X = rng.choice([-1.0, 1.0], size=(400, Ws[0].shape[1]))
    net.threshold = float(np.quantile(net.forward(X), rng.uniform(0.05, 0.4)))
    return net


@pytest.mark.parametrize("seed", range(12))
def test_soundness_campaign(seed):
    """Random nets (one or two hidden layers; scales 1e-6..1e6 per layer,
    exact rescalings by 2^+-450, output scales 2^-900..2^1000, dead and
    duplicated units, p = 0, p = 1): honest arguments give the exact count,
    and adversarial slopes / quadratic parameters never certify a bound
    above the exact minimum."""
    kinds = ["gauss", "rescaled", "outscale", "dead", "p0", "p1"]
    rng = np.random.default_rng(100 + seed)
    net = _campaign_net(kinds[seed % len(kinds)], rng)
    cn = CertNet(net)
    F = exact_count(net)
    for kinds_ in (("lin",), ("lin", "quad")):
        arg, _ = prove(cn, ProverConfig(kinds=kinds_, r_leaf=1, quad_rmin=2, quad_iters=30, alpha_iters=10,
                                        collapse=bool(seed % 2)))
        res = verify(cn, arg, rng=np.random.default_rng(seed))
        assert contains_exact(res, F, cn.d)
        assert res.exact and res.F == F
    assert adversarial_bounds(cn, net, rng, nsub=2, quad=True) > 0


def test_prover_certificates_are_accepted_as_checked():
    """Regression (soundness campaign): the prover checked a quad certificate
    on enclosures computed for a batch of subcubes, the verifier on one
    subcube; the enclosures differ in the last bits (another summation path)
    and a certificate at the edge was demoted, so the result was not exact.
    The prover now checks quad certificates exactly as the verifier does and
    certifies with a margin 2^-30 |f|_abs."""
    rng = np.random.default_rng(2026)
    for i in range(5):  # the campaign's fifth random net: d = 9, widths [11, 10]
        d = int(rng.integers(6, 11))
        L = int(rng.integers(1, 3))
        widths = [int(rng.integers(3, 12)) for _ in range(L)]
        scale = 10.0 ** rng.uniform(-6, 6)
        sizes = [d] + widths + [1]
        Ws = [rng.normal(0, 1, (b, a)) * scale for a, b in zip(sizes[:-1], sizes[1:])]
        bs = [rng.normal(0, 1, b) * scale for b in sizes[1:]]
        net = MLP(Ws, bs, threshold=0.0)
        X = rng.choice([-1.0, 1.0], size=(512, d))
        net.threshold = float(np.quantile(net.forward(X), rng.uniform(0.0, 0.3)))
    cn = CertNet(net)
    F = exact_count(net)
    arg, _ = prove(cn, ProverConfig(kinds=("lin", "quad"), r_leaf=2, quad_rmin=2, quad_iters=60, alpha_iters=20,
                                    collapse=False))
    res = verify(cn, arg)
    assert res.exact and res.F == F and res.demoted == 0 and res.leaves["quad"] > 0


def test_subcube_certificates_and_roots():
    rng = np.random.default_rng(8)
    net = random_net(rng, 8, [6])
    cn = CertNet(net)
    for _ in range(4):
        root = np.zeros(8, dtype=np.int8)
        fixed = rng.choice(8, 3, replace=False)
        root[fixed] = rng.choice([-1, 1], 3)
        arg, _ = prove(cn, ProverConfig(kinds=("lin",), r_leaf=1), root=root)
        res = verify(cn, arg, root=root)
        F = exact_count(net, root)
        assert res.exact and res.F == F


def test_regression_non_integer_roots_are_rejected():
    """Referee counterexample: the root was cast to int8 before it was
    validated, so (0.6, 0, 0, 0) was read as the whole cube and (1.9, 0, 0, 0)
    as (1, 0, 0, 0)."""
    W1 = np.zeros((1, 4))
    W1[0, 0] = 1.0
    net = MLP([W1, np.array([[1.0]])], [np.zeros(1), np.zeros(1)], threshold=0.5)  # fails iff x_0 = -1
    arg = {"tree": [(ENUM,)], "samples": 0}
    for root in ([0.6, 0, 0, 0], [1.9, 0, 0, 0], [-0.9, 0, 0, 0], [np.nan, 0, 0, 0], [1, 0, 0], [2, 0, 0, 0]):
        with pytest.raises(ValueError):
            verify(net, arg, root=np.array(root, dtype=float))
        with pytest.raises(ValueError):
            prove(net, ProverConfig(r_leaf=1), root=np.array(root, dtype=float))
    res = verify(net, arg, root=np.array([1.0, 0, 0, 0]))
    assert res.exact and res.F == 0
    res = verify(net, arg, root=[-1, 0, 0, 0])
    assert res.exact and res.F == 8 and res.lo == 1.0


def test_dishonest_and_malformed_arguments_never_miss_p():
    rng = np.random.default_rng(9)
    net = random_net(rng, 6, [5])
    cn = CertNet(net)
    F = exact_count(net)
    good, _ = prove(cn, ProverConfig(kinds=("lin",), r_leaf=1))
    bad_certs = [{"kind": "lin", "alpha": [np.full(5, np.nan)]}, {"kind": "lin", "alpha": [np.ones(3)]},
                 {"kind": "quad", "alpha": None, "theta": np.ones((5, 2)), "mu": np.full(7, 1e300), "shift": 1e300},
                 {"kind": "quad", "alpha": None, "theta": np.ones((5, 2)), "mu": np.zeros(7), "shift": np.nan},
                 {"kind": "nope"}, None, {"kind": "lin", "alpha": [np.full(5, np.inf)]}]
    args = [{"tree": [(SAFE, c)], "samples": 100} for c in bad_certs]
    args += [{"tree": [(FAIL, c)], "samples": 0} for c in bad_certs]
    args += [{"tree": [(SPLIT, 0), (SAFE, {"kind": "lin", "alpha": None})], "samples": 10},  # ends early
             {"tree": [(SPLIT, 0), (SPLIT, 0), (ENUM,), (ENUM,), (ENUM,)], "samples": 0},  # fixed coordinate
             {"tree": [(SPLIT, 6), (ENUM,), (ENUM,)]}, {"tree": [(SPLIT, True), (ENUM,), (ENUM,)]},
             {"tree": [(SPLIT, 1.0), (ENUM,), (ENUM,)]}, {"tree": [(ENUM,), (ENUM,)]}, {"tree": []},
             {"tree": [("magic",)]}, {"tree": [(OPEN,)], "samples": -5}, {"tree": [(OPEN,)], "samples": "x"},
             {"tree": good["tree"] + [(ENUM,)]}]
    for arg in args:
        res = verify(cn, arg, rng=np.random.default_rng(0), delta=1e-9)
        assert contains_exact(res, F, 6)
    res = verify(cn, good)
    assert res.exact and res.F == F


def test_hybrid_arguments_cover_p():
    rng = np.random.default_rng(10)
    net, _ = train_constant(10, [8], 150, rng)
    F = exact_count(net)
    cn = CertNet(net)
    arg, info = prove(cn, ProverConfig(kinds=("lin",), r_leaf=3, open_policy="both", eps=0.3))
    res = verify(cn, arg)
    assert res.exact and res.F == F
    h = arg["hybrid"]
    misses = 0
    for s in range(20):
        hres = verify(cn, h, delta=0.05, rng=np.random.default_rng(s))
        misses += not contains_exact(hres, F, 10)
    assert misses <= 4


def test_witness_lists():
    rng = np.random.default_rng(11)
    net = random_net(rng, 7, [5])
    X = all_points(7)
    vals = exact_values(net, X)
    t = Fraction(float(net.threshold))
    fails = [x for x, v in zip(X, vals) if v < t]
    pts = np.array(fails + fails[:2] + [X[0], X[1]] + [[0.5] * 7], dtype=float)
    lb, k = witness_lower_bound(net, pts)
    assert k == len(fails) and lb == len(fails) / 2 ** 7


def test_trained_net_exact_and_knuth():
    rng = np.random.default_rng(12)
    net, _ = train_constant(12, [16], 300, rng, loss="logistic")
    F = exact_count(net)
    cn = CertNet(net)
    for kinds in (("lin",), ("lin", "quad")):
        arg, info = prove(cn, ProverConfig(kinds=kinds, r_leaf=4, quad_rmin=6, quad_iters=60))
        res = verify(cn, arg)
        assert res.exact and res.F == F and res.demoted == 0
        assert res.fpe > 0 and res.seconds >= 0
    est = knuth_estimate(cn, ProverConfig(kinds=("lin",), r_leaf=4), probes=8)
    assert est["nodes"] >= 1
