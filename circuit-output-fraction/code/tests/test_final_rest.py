"""Regression tests for the final review round: statistics, sampler, unate
CNF procedures, envelopes, the argument verifier and DFSB."""

import itertools
import math
import os
import subprocess
import sys
from decimal import Decimal, getcontext
from fractions import Fraction

import numpy as np
import pytest

from rareprob import Circuit, Product
from rareprob.argument import sanitize_envelope, verify
from rareprob.cftp import UnateSystem, _reps_for, cftp_samples, telescoping_estimate
from rareprob.dfsb import DFSB, TNode, _combine, affine_rows, dfsb_estimate
from rareprob.envelope import Envelope, dnf_envelope, envelope_estimate
from rareprob.families import dnf_exact
from rareprob.janson import janson_interval
from rareprob.stats import dklr_stopping_rule, kl_interval, sequential_mean

CODE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def all_points(n):
    return ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)


def exact_fraction(C, D):
    X = all_points(C.n)
    c = C.eval_bits(X)
    q = [Fraction(float(v)) for v in D.q]
    P = Fraction(0)
    for x, ci in zip(X, c):
        if ci:
            w = Fraction(1)
            for i, b in enumerate(x):
                w *= q[i] if b else 1 - q[i]
            P += w
    return P


def run_O(code):
    """Run code under python -O (asserts removed); returns the completed process."""
    return subprocess.run([sys.executable, "-O", "-c", code], cwd=CODE, capture_output=True, text=True,
                          env={**os.environ, "PYTHONPATH": CODE})


# ------------------------------------------------------------------ stats
@pytest.mark.parametrize("bad", [1 + 1e-12, 1 + 1e-9, -1e-15, np.nan, np.inf])
def test_sequential_mean_rejects_out_of_range_samples(bad):
    """No silent clipping: a weight above 1 means a non-dominating envelope."""
    def draw(k):
        z = np.full(k, 0.5)
        z[0] = bad
        return z

    with pytest.raises(ValueError):
        sequential_mean(draw, 0.1, 0.05, max_samples=4096)


def test_sequential_mean_rejects_wrong_batch_size():
    with pytest.raises(ValueError):
        sequential_mean(lambda k: np.zeros(k + 1), 0.1, 0.05, max_samples=4096)


def _kl_exact(a: float, b: float) -> Decimal:
    A, B = Decimal(a), Decimal(b)
    r = Decimal(0)
    if A > 0:
        r += A * (A / B).ln()
    if A < 1:
        r += (1 - A) * ((1 - A) / (1 - B)).ln()
    return r


def test_kl_interval_contains_exact_interval():
    """Each returned endpoint (unless 0 or 1) lies outside the exact KL
    interval {m : N KL(mean||m) <= ln(2/delta)}, checked in 60-digit
    arithmetic, including means near the endpoints of [0, 1] and huge N."""
    getcontext().prec = 60
    rng = np.random.default_rng(5)
    for _ in range(400):
        N = int(10 ** rng.uniform(1, 15))
        mean = float(rng.choice([rng.uniform(0, 1), 10 ** rng.uniform(-12, 0), 1 - 10 ** rng.uniform(-12, -1)]))
        delta = float(10 ** rng.uniform(-12, -0.5))
        lo, hi = kl_interval(mean, N, delta)
        c = (Decimal(2) / Decimal(delta)).ln() / N
        assert 0.0 <= lo <= mean <= hi <= 1.0
        if lo > 0:
            assert _kl_exact(mean, lo) > c
        if hi < 1:
            assert _kl_exact(mean, hi) > c


def test_kl_interval_rel_err_widens():
    for mean in (1e-6, 0.3, 0.999):
        lo, hi = kl_interval(mean, 10**6, 0.01)
        lo2, hi2 = kl_interval(mean, 10**6, 0.01, rel_err=1e-6)
        assert lo2 <= lo and hi2 >= hi
        assert lo2 <= kl_interval(mean * (1 - 1e-6), 10**6, 0.01)[0]


def test_dklr_stopping_rule_cap_gives_no_estimate():
    est, N = dklr_stopping_rule(lambda: 0.0, 0.1, 0.05, max_samples=5000)
    assert est is None and N == 5000
    rng = np.random.default_rng(1)
    est, N = dklr_stopping_rule(lambda: float(rng.random() < 0.2), 0.1, 0.05)
    assert est is not None and abs(est / 0.2 - 1) < 0.1
    with pytest.raises(ValueError):
        dklr_stopping_rule(lambda: 1.5, 0.1, 0.05)


# ------------------------------------------------------------- dist
@pytest.mark.parametrize("q", [[0.5, np.nan], [1.2], [-0.1], [[0.5, 0.5]]])
def test_product_rejects_bad_marginals(q):
    with pytest.raises(ValueError):
        Product(q)


def test_product_check_survives_python_O():
    r = run_O("from rareprob import Product\n"
              "try:\n    Product([float('nan')])\nexcept ValueError:\n    print('rejected')\n")
    assert r.returncode == 0 and "rejected" in r.stdout, r.stderr


class _FakeRng:
    """Returns prescribed uniforms (on the grid 2^-53 Z), one per draw."""

    def __init__(self, seq):
        self.seq = list(seq)

    def random(self, size):
        size = (size,) if np.isscalar(size) else tuple(size)
        k = int(np.prod(size))
        out = np.array(self.seq[:k], dtype=float).reshape(size)
        del self.seq[:k]
        return out


def test_product_sample_is_exact_beyond_the_53_bit_grid():
    """x = [V < q] with V's digits drawn lazily: q = 2^-70 is not rounded up
    to 2^-53, and a tie on the first 53 bits is decided by the next ones."""
    D = Product([2.0 ** -70])
    assert not D.sample(1, _FakeRng([2.0 ** -53]))[0, 0]  # the old sampler set this to 1
    assert D.sample(1, _FakeRng([0.0, 2.0 ** -17 - 2.0 ** -53]))[0, 0]
    assert not D.sample(1, _FakeRng([0.0, 2.0 ** -17]))[0, 0]
    # q = 0.3 is not on the 2^-53 grid: q 2^53 = m + 1/2
    s = 0.3 * 2.0 ** 53
    m = math.floor(s)
    assert s - m == 0.5
    D = Product([0.3])
    assert not D.sample(1, _FakeRng([(m + 1) * 2.0 ** -53]))[0, 0]
    assert D.sample(1, _FakeRng([(m - 1) * 2.0 ** -53]))[0, 0]
    assert D.sample(1, _FakeRng([m * 2.0 ** -53, 0.25]))[0, 0]
    assert not D.sample(1, _FakeRng([m * 2.0 ** -53, 0.5]))[0, 0]


def test_product_sample_marginals():
    rng = np.random.default_rng(3)
    q = np.array([0.0, 1.0, 0.3, 1e-3, 0.5, 1 - 1e-3, 5e-324])
    X = Product(q).sample(200_000, rng)
    assert X.shape == (200_000, len(q)) and X.dtype == bool
    assert not X[:, 0].any() and X[:, 1].all() and not X[:, 6].any()
    m = X.mean(axis=0)
    for i in (2, 3, 4, 5):
        sd = math.sqrt(q[i] * (1 - q[i]) / len(X))
        assert abs(m[i] - q[i]) < 5 * sd
    assert Product(q).sample(0, rng).shape == (0, len(q))


# ------------------------------------------------------- unate CNFs
NON_UNATE = [[(0, 1)], [(0, 0), (1, 1)]]


def test_non_unate_rejected():
    D = Product.uniform(2)
    with pytest.raises(ValueError):
        janson_interval(NON_UNATE, D)
    with pytest.raises(ValueError):
        UnateSystem(NON_UNATE, D)
    with pytest.raises(ValueError):
        telescoping_estimate(NON_UNATE, D, N=50, rng=np.random.default_rng(0))
    with pytest.raises(ValueError):
        janson_interval([[(2, 1)]], D)  # variable out of range
    with pytest.raises(ValueError):
        janson_interval([[(0, 2)]], D)  # not a 0/1 value


def test_non_unate_rejected_under_python_O():
    r = run_O("from rareprob import Product\n"
              "from rareprob.janson import janson_interval\n"
              "from rareprob.cftp import telescoping_estimate\n"
              f"cl = {NON_UNATE!r}\n"
              "for f in (lambda: janson_interval(cl, Product.uniform(2)),\n"
              "          lambda: telescoping_estimate(cl, Product.uniform(2), N=20)):\n"
              "    try:\n        f()\n    except ValueError:\n        print('rejected')\n")
    assert r.returncode == 0 and r.stdout.count("rejected") == 2, r.stderr


def _tail(R, fail=Fraction(1, 4)):
    return sum(math.comb(R, j) * fail ** j * (1 - fail) ** (R - j) for j in range((R + 1) // 2, R + 1))


@pytest.mark.parametrize("delta", [0.3, 0.2, 0.05, 0.025, 1e-3, 1e-7, 1e-20])
def test_reps_for_is_the_smallest_valid_count(delta):
    R = _reps_for(delta)
    assert R % 2 == 1 and _tail(R) <= Fraction(delta)
    assert R == 1 or _tail(R - 2) > Fraction(delta)


def test_reps_for_tiny_delta_does_not_overflow():
    for d in (1e-80, 1e-300, 5e-324):
        R = _reps_for(d)
        assert R % 2 == 1 and R <= math.ceil(8 * -math.log(d)) + 2
    with pytest.raises(ValueError):
        _reps_for(0.0)


def test_cftp_many_variables_few_relevant():
    """9000 variables, one clause: the chain runs on the clause's variables
    only, so there is a verdict (before, 4n > T_max meant no horizon at all)."""
    D = Product(np.full(9000, 0.5))
    e = telescoping_estimate([[(0, 1), (1, 1)]], D, N=20, rng=np.random.default_rng(0))
    assert e.lo <= 0.75 <= e.hi and e.lo > 0.5


def test_cftp_small_horizon_cap_still_tries_one_horizon():
    cl = [[(i, 0), (i + 1, 0)] for i in range(10)]
    S = UnateSystem(cl, Product(np.full(11, 0.3)))
    Y, f = cftp_samples(S, list(range(len(cl))), 200, np.random.default_rng(1), T_max=8)
    assert Y.shape[0] + f == 200  # 4 * 11 > 8, yet the horizon T_max was tried


def test_cftp_samples_exact_law_with_inactive_variables():
    """Active clauses on some variables, an inactive clause and a variable in
    no clause: the output law is D(.|active clauses hold) on all of them."""
    rng = np.random.default_rng(7)
    n = 6
    cl = [[(0, 0), (1, 0)], [(1, 0), (2, 0)], [(2, 0), (3, 0)], [(4, 1)]]
    D = Product(np.array([0.6, 0.5, 0.7, 0.4, 0.35, 0.8]))
    S = UnateSystem(cl, D)
    active = [0, 1, 2]
    Y, f = cftp_samples(S, active, 60000, rng, chunk=7)
    assert f == 0 and Y.shape == (60000, n)
    # y = [x takes the falsifying value]; x_5 is in no clause: y_5 = 0
    assert not Y[:, 5].any()
    idx = (Y[:, :5] * (1 << np.arange(5))).sum(1)
    emp = np.bincount(idx, minlength=32) / len(idx)
    r = S.r[:5]
    P = np.zeros(32)
    for a in range(32):
        y = [(a >> i) & 1 for i in range(5)]
        if any(all(y[v] for v in S.vars[c]) for c in active):
            continue
        P[a] = np.prod([r[i] if y[i] else 1 - r[i] for i in range(5)])
    P /= P.sum()
    assert 0.5 * np.abs(emp - P).sum() < 0.02


# ------------------------------------------------------ envelopes
def test_envelope_interval_is_clipped_to_unit_interval():
    # mass 6 >= 1: Monte Carlo fallback; p = 1
    n = 6
    terms = [[(i, 1)] for i in range(n)] + [[(i, 0)] for i in range(n)]
    C = Circuit(n)
    C.set_output(C.OR(*[C.lit(i, b) for t in terms for (i, b) in t]))
    e = envelope_estimate(C, Product.uniform(n), dnf_envelope(terms, n), rng=np.random.default_rng(0))
    assert e.lo <= 1.0 <= e.hi <= 1.0
    # mass just below 1 with W = 1: Z e^eta would exceed 1
    C = Circuit(1)
    C.set_output(0)
    D = Product([1 - 2.0 ** -40])
    e = envelope_estimate(C, D, dnf_envelope([[(0, 1)]], 1), rng=np.random.default_rng(0))
    assert e.lo <= D.q[0] <= e.hi <= 1.0


def _raw(E, kind, data):
    E.kind.append(kind)
    E.data.append(data)
    E.sup.append(0)
    return len(E.kind) - 1


def _big(E, levels):
    """A node counting 2^levels derivations of the constant 1 (no flattening)."""
    c = _raw(E, "SUM", (E.one(), E.one()))
    for _ in range(levels - 1):
        c = _raw(E, "SUM", (c, c))
    return c


def test_envelope_overflowing_count_off_the_sampled_derivation():
    """phi = 2^1024 [x0 = 1] + [x0 = 0][x1 = 1] with q0 = 5e-324: the mass is
    about 1/2, but phi's first term is inf * 0 at x0 = 0, which used to give
    NaN weights."""
    C = Circuit(2)
    C.set_output(C.AND(C.NOT(0), 1))
    D = Product([5e-324, 0.5])
    E = Envelope()
    big = _big(E, 1024)
    t1 = _raw(E, "PROD", (big, E.lit(0, 1)))
    t2 = _raw(E, "PROD", (E.lit(0, 0), E.lit(1, 1)))
    E.root = _raw(E, "SUM", (t1, t2))
    p = 0.5 * (1 - 5e-324)
    e = envelope_estimate(C, D, E, eps=0.1, delta=0.05, max_samples=20000, rng=np.random.default_rng(0))
    assert e.lo <= p <= e.hi <= 1.0
    v = verify(C, D, E, None, eps=0.1, delta=0.05, max_samples=20000, rng=np.random.default_rng(0))
    assert not v.proof_ok and v.estimate.lo <= p and v.estimate.hi == 1.0


@pytest.mark.parametrize("levels", [500, 1100])
def test_verify_huge_mass_falls_back_to_monte_carlo(levels):
    C = Circuit(3)
    C.set_output(C.AND(0, 1))
    E = Envelope()
    E.root = _big(E, levels)
    v = verify(C, Product.uniform(3), E, [[]], eps=0.1, delta=0.05, max_samples=20000,
               rng=np.random.default_rng(0))
    assert v.proof_ok and v.estimate.lo <= 0.25 <= v.estimate.hi <= 1.0


def test_verify_turns_estimator_failure_into_trivial_interval(monkeypatch):
    import rareprob.argument as arg

    def boom(*a, **k):
        raise OverflowError("math range error")

    monkeypatch.setattr(arg, "envelope_estimate", boom)
    C = Circuit(2)
    C.set_output(C.AND(0, 1))
    v = arg.verify(C, Product.uniform(2), dnf_envelope([[(0, 1), (1, 1)]], 2), None)
    assert (v.estimate.lo, v.estimate.hi) == (0.0, 1.0)


def test_sanitize_rejects_unbounded_iterables():
    class Env:
        pass

    e = Env()
    e.kind, e.data, e.root = itertools.repeat("ONE"), [None], 0
    assert sanitize_envelope(e, 2) is None
    e.kind, e.data, e.root = ["ONE", "SUM"], [None, itertools.count()], 1
    assert sanitize_envelope(e, 2) is None
    e.kind, e.data, e.root = ["LIT"], [iter((0, 1))], 0
    assert sanitize_envelope(e, 2) is None
    e.kind, e.data, e.root = ["ONE", "LIT", "SUM"], [None, (0, 1), (0, 1)], 2
    assert sanitize_envelope(e, 2) is not None


def test_dnf_exact_rejects_too_many_terms():
    with pytest.raises(ValueError):
        dnf_exact([[(0, 1)]] * 23, Product.uniform(1))


# ------------------------------------------------------------ DFSB
def _r8_circuit(rewrite, t=3, M=5):
    """The (R8) instance: XOR(g, x3..x15), NOT XOR(x2..x15) and t rare groups
    sharing x1; g = x1 XOR x2 written as an XOR or as an AND/OR circuit."""
    n = 16 + t * (2 + M)
    C = Circuit(n)
    g = C.OR(C.AND(1, C.NOT(2)), C.AND(C.NOT(1), 2)) if rewrite else C.XOR(1, 2)
    cl = [C.XOR(g, *range(3, 16)), C.NOT(C.XOR(*range(2, 16)))]
    nxt = 16
    for _ in range(t):
        v, b = nxt, nxt + 1
        nxt += 2
        cl.append(C.OR(1, v, b))
        for _ in range(M):
            cl.append(C.OR(v, nxt))
            nxt += 1
    return C.set_output(C.AND(*cl))


def test_dfsb_tree_invariant_under_atom_rewrite():
    """Rewriting the atom-sized gate g changes neither the root's forced
    literals (Gaussian elimination now reads atoms by their truth tables)
    nor the tree."""
    out = []
    for rw in (False, True):
        C = _r8_circuit(rw)
        assert affine_rows(C, 12) == affine_rows(_r8_circuit(not rw), 12)
        alg = DFSB(C, Product.uniform(C.n), K=4, rng=np.random.default_rng(3))
        lits, _ = alg._root_force()
        assert lits.get(1) == 1  # x1 = 1 follows from the two parities
        e = alg.estimate(0.2, 0.05, max_leaf_samples=20000)
        out.append((sorted(lits.items()), e.note, alg.nodes))
    assert out[0] == out[1]


def _rows_hold(C, rows):
    X = all_points(C.n)
    sat = X[C.eval_bits(X)]
    for mask, c in rows:
        cols = [i for i in range(C.n) if (mask >> i) & 1]
        par = np.bitwise_xor.reduce(sat[:, cols], axis=1) if cols else np.zeros(len(sat), dtype=bool)
        if not np.all(par == bool(c)):
            return False
    return True


def test_affine_rows_atom_hull_and_soundness():
    C = Circuit(6)
    atom = C.AND(C.XOR(0, 1), C.NOT(C.XOR(2, 3)))  # x0+x1 = 1, x2+x3 = 0
    C.set_output(C.AND(atom, C.XOR(C.XOR(0, 1), 4, 5)))  # x0+x1+x4+x5 = 1, so x4+x5 = 0
    rows = affine_rows(C, 4)
    assert _rows_hold(C, rows)
    from rareprob.cnf import gauss_forced
    assert gauss_forced(rows, {0: 1, 2: 0, 4: 1}) == {1: 0, 3: 0, 5: 1}
    C0 = Circuit(2)
    C0.set_output(C0.AND(C0.const(0), 1))
    assert affine_rows(C0, 4) is None
    rng = np.random.default_rng(11)
    for _ in range(60):
        n = 8
        C = Circuit(n)
        gates = list(range(n))
        for _ in range(12):
            op = rng.choice(["AND", "OR", "XOR", "NOT"])
            a = [int(x) for x in rng.choice(gates, 1 if op == "NOT" else 2, replace=False)]
            gates.append(C.add(op, a))
        C.set_output(C.AND(*[int(g) for g in rng.choice(gates[n:], 3, replace=False)]))
        for a in (0, 3, 8):
            rows = affine_rows(C, a)
            if rows is None:
                assert not C.eval_bits(all_points(n)).any()
            else:
                assert _rows_hold(C, rows)


def test_dfsb_log_bounds_below_float_range():
    """AND of 60 (x OR y) with q = 1e-10: p ~ 10^-581.9. The float interval is
    [0, tiny], and the note gives tight log10 bounds."""
    t = 60
    C = Circuit(2 * t)
    C.set_output(C.AND(*[C.OR(2 * i, 2 * i + 1) for i in range(t)]))
    D = Product(np.full(2 * t, 1e-10))
    e = dfsb_estimate(C, D, rng=np.random.default_rng(0))
    q = Fraction(1e-10)
    P = (1 - (1 - q) ** 2) ** t
    l10 = (math.log(P.numerator) - math.log(P.denominator)) / math.log(10)
    assert e.lo == 0.0 and 0.0 < e.hi <= 1e-300
    s = e.note.split("log10 p in [")[1].rstrip("]")
    a, b = (float(x) for x in s.split(","))
    assert a <= l10 * (1 - 1e-15) and l10 * (1 + 1e-15) <= b and b - a < 1e-8


def test_dfsb_combine_clips_and_matches_linear_domain():
    D = Product(np.full(4, 0.5))
    leaf = TNode("mc", 0, lo=0.95, hi=1.2)
    lo, hi, L, H = _combine(leaf, D)
    assert lo == 0.95 and hi == 1.0 and H == 0.0
    t = TNode("or", 0, children=[TNode("mc", 0, lo=1e-200, hi=2e-200), TNode("mc", 0, lo=0.3, hi=0.31)])
    lo, hi, L, H = _combine(t, D)
    assert lo <= 0.3 + 1e-200 and 0.31 + 2e-200 <= hi * (1 + 1e-15) and hi <= 0.32
    t = TNode("or", 0, children=[TNode("mc", 0, lo=1e-320, hi=2e-320), TNode("mc", 0, lo=1e-321, hi=1e-320)])
    lo, hi, L, H = _combine(t, D)
    assert L <= math.log(1.1e-320) and math.log(3e-320) <= H


@pytest.mark.parametrize("seed", range(4))
def test_dfsb_contains_exact_p_on_random_circuits(seed):
    rng = np.random.default_rng(900 + seed)
    for _ in range(5):
        n = 10
        C = Circuit(n)
        gates = list(range(n))
        for _ in range(16):
            op = rng.choice(["AND", "OR", "XOR", "NOT", "THR"])
            k = 1 if op == "NOT" else int(rng.integers(2, 4))
            a = [int(x) for x in rng.choice(gates, k, replace=False)]
            if op == "THR":
                gates.append(C.THR(a, [float(w) for w in rng.integers(-2, 3, k)], float(rng.integers(0, 3)) + 0.5))
            else:
                gates.append(C.add(op, a))
        C.set_output(C.AND(*[int(g) for g in rng.choice(gates[n:], 2, replace=False)]))
        q = rng.uniform(0.05, 0.95, n)
        q[rng.random(n) < 0.2] = 1e-6
        D = Product(q)
        P = exact_fraction(C, D)
        for kw in ({}, dict(exact_support=0, small_cone=0), dict(exact_support=4)):
            e = dfsb_estimate(C, D, eps=0.2, delta=0.05, K=8, node_budget=60, rng=rng, **kw)
            assert 0.0 <= e.lo <= e.hi <= 1.0
            assert Fraction(e.lo) <= P <= Fraction(e.hi), (kw, e)


def test_dfsb_exact_threshold_semantics():
    """THR(x1, x2, x3; 10^20, 1, -10^20; t = 1) under the uniform law has
    p = 1/2 in exact arithmetic (a rounded sum would give 3/8)."""
    C = Circuit(3)
    C.set_output(C.THR([0, 1, 2], [10**20, 1, -10**20], 1))
    D = Product.uniform(3)
    assert exact_fraction(C, D) == Fraction(1, 2)
    for kw in ({}, dict(exact_support=0, small_cone=0)):
        e = dfsb_estimate(C, D, rng=np.random.default_rng(0), **kw)
        assert e.lo <= 0.5 <= e.hi
