"""Tests for the DFSB fixes: exact atoms (T'), atom-protected flattening,
forcing to a fixpoint, zero-mass envelopes, Phase-2 sample caps, cutset
conditioning with (S) and (E) disabled, the meta-procedure's handling of
underflow and empty intersections, certified variable elimination (log-scale
bounds, the 2^-1000 boundary, the evaluator's threshold arithmetic), canonical
CNF clauses, the local-threshold and affine modules of the meta-procedure,
truncated rejection fills, the compiler's rule budget and subnormal-safe
exponentials."""

import math
from fractions import Fraction

import numpy as np
import pytest

from rareprob.circuit import Circuit
from rareprob.dfsb import DFSB, AtomNNF, atom_nnf, dfsb_estimate, sample_cap, _leaves
from rareprob.dist import Product
from rareprob.compile import EnvelopeCompiler
from rareprob.envelope import Box, Envelope, _exp_down, _exp_up, estimate_boxes
from rareprob.janson import is_unate, janson_interval
from rareprob.meta import as_cnf, meta_estimate
from rareprob.nnf import to_nnf
from rareprob.ve import exact_ve, ve_bounds
from rareprob.stats import kl_interval, sequential_mean


def exact_fraction(C: Circuit, D: Product) -> Fraction:
    """p as an exact rational (q's are floats, hence dyadic rationals)."""
    n = C.n
    X = ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)
    y = C.eval_bits(X)
    q = [Fraction(float(v)) for v in D.q]
    tot = Fraction(0)
    for row in X[y]:
        w = Fraction(1)
        for i in range(n):
            w *= q[i] if row[i] else 1 - q[i]
        tot += w
    return tot


def random_circuit(n, g, rng):
    C = Circuit(n)
    pool = list(range(n))
    for _ in range(g):
        op = rng.choice(["AND", "OR", "NOT", "XOR", "AND", "OR"])
        if op == "NOT":
            h = C.NOT(int(rng.choice(pool)))
        else:
            h = C.add(op, [int(x) for x in rng.choice(pool, int(rng.integers(2, 4)))])
        pool.append(h)
    tops = [int(x) for x in rng.choice(pool[n:], int(rng.integers(1, 4)))]
    return C.set_output(C.AND(*tops) if len(tops) > 1 else tops[0])


def sampled(est) -> bool:
    return any(k in est.note for k in ("'mc'", "'env'", "'loose'"))


# ------------------------------------------------------------ read-once
def test_read_once_and_of_ors_exact():
    t = 30
    C = Circuit(2 * t)
    C.set_output(C.AND(*[C.OR(2 * i, 2 * i + 1) for i in range(t)]))
    p = 0.75 ** t
    for K in (1.0, 4.0, 64.0):
        e = dfsb_estimate(C, Product.uniform(2 * t), eps=0.1, delta=0.05, K=K,
                          rng=np.random.default_rng(0))
        assert not sampled(e) and e.samples == 0
        assert e.lo <= p <= e.hi and e.hi <= e.lo * (1 + 1e-12)


@pytest.mark.parametrize("biased", [False, True])
def test_read_once_and_of_two_level_blocks_exact(biased):
    t = 8
    C = Circuit(4 * t)
    C.set_output(C.AND(*[C.OR(C.AND(4 * j, 4 * j + 1), C.AND(4 * j + 2, 4 * j + 3)) for j in range(t)]))
    q = np.random.default_rng(1).uniform(0.05, 0.95, 4 * t) if biased else np.full(4 * t, 0.5)
    D = Product(q)
    P = Fraction(1)
    for j in range(t):
        a, b, c, d = [Fraction(float(q[4 * j + i])) for i in range(4)]
        P *= a * b + c * d - a * b * c * d
    e = dfsb_estimate(C, D, eps=0.1, delta=0.05, rng=np.random.default_rng(0))
    assert not sampled(e)
    assert Fraction(e.lo) <= P <= Fraction(e.hi) and e.hi <= e.lo * (1 + 1e-12)


def test_read_once_exact_without_atoms():
    """With (T') and canonicalisation off, (D) alone makes read-once formulas exact."""
    t = 8
    C = Circuit(4 * t)
    C.set_output(C.AND(*[C.OR(C.AND(4 * j, 4 * j + 1), C.AND(4 * j + 2, 4 * j + 3)) for j in range(t)]))
    e = dfsb_estimate(C, Product.uniform(4 * t), eps=0.1, delta=0.05, rng=np.random.default_rng(0),
                      exact_support=0, small_cone=0)
    p = (7 / 16) ** t
    assert not sampled(e) and e.lo <= p <= e.hi and e.hi <= e.lo * (1 + 1e-10)


# ------------------------------------------------------------ T' and atoms
@pytest.mark.parametrize("seed", range(6))
def test_exact_atom_rule_contains_rational_value(seed):
    rng = np.random.default_rng(700 + seed)
    n = 9
    C = random_circuit(n, 25, rng)
    q = rng.uniform(0, 1, n)
    q[rng.random(n) < 0.2] = rng.integers(0, 2, 1)[0]
    D = Product(q)
    alg = DFSB(C, D, exact_support=12)
    lo, hi = alg._exact(alg.N.root)
    P = exact_fraction(C, D)
    assert Fraction(lo) <= P <= Fraction(hi)
    assert hi <= math.nextafter(math.nextafter(lo, 2), 2) or lo == hi


def test_atoms_not_merged_into_larger_parents():
    n = 20
    C = Circuit(n)
    small = C.AND(0, 1)  # an atom
    big = C.AND(*[C.OR(i, i + 1) for i in range(2, 19)])
    C.set_output(C.AND(small, big))
    N = atom_nnf(C, atom=4, small_cone=0)
    assert isinstance(N, AtomNNF)
    kids = N.data[N.root]
    # the atom AND(x0, x1) stays one child; the big AND's children are merged
    assert any(N.kind[c] == "A" and N.sup[c] == 0b11 for c in kids)
    assert not any(N.kind[c] == "L" for c in kids)
    # restriction keeps the semantics
    X = np.random.default_rng(0).random((500, n)) < 0.5
    for rho in ({3: 1}, {0: 1, 5: 0}, {2: 0, 3: 0}):
        v = N.restrict(N.root, rho)
        Xr = X.copy()
        for i, b in rho.items():
            Xr[:, i] = bool(b)
        assert np.array_equal(N.eval_batch(X, v), C.eval_bits(Xr))


def test_force_runs_to_fixpoint():
    n = 16
    C = Circuit(n)
    body = C.OR(*[C.AND(i, i + 1) for i in range(8, 15)])
    C.set_output(C.AND(*[C.lit(i, 1) for i in range(8)], body))
    alg = DFSB(C, Product.uniform(n), exact_support=0, small_cone=0, probe_root=False)
    alg.pilot_delta = 0.05
    t = alg.build(alg.N.root, root=True)
    assert t.kind == "force"
    assert t.children[0].kind != "force"


# ------------------------------------------------------------ zero mass
def test_zero_mass_envelope_is_exact_zero():
    """A box-free envelope of mass 0 (a literal of probability 0) gives D(h) = 0
    instead of crashing the envelope sampler."""
    C = Circuit(3)
    C.set_output(C.OR(C.AND(0, 1), C.AND(0, 2)))
    D = Product([0.0, 0.306, 1.0])
    e = DFSB(C, D, K=4, exact_support=0, small_cone=0, use_dense=False, probe_root=False,
             rng=np.random.default_rng(0)).estimate(eps=0.2, delta=0.1)
    assert e.lo == 0.0 and e.hi == 0.0


# ------------------------------------------------------------ cutsets
def test_cutset_conditioning_exact():
    t = 8
    C = Circuit(3 * t)
    C.set_output(C.AND(*[C.OR(C.AND(3 * i, 3 * i + 1), C.AND(C.NOT(3 * i), 3 * i + 2)) for i in range(t)]))
    D = Product(np.random.default_rng(2).uniform(0.1, 0.9, 3 * t))
    P = Fraction(1)
    for i in range(t):
        x, y, z = [Fraction(float(D.q[3 * i + j])) for j in range(3)]
        P *= x * y + (1 - x) * z
    alg = DFSB(C, D, K=1, exact_support=0, small_cone=0, use_dense=False, use_envelopes=False,
               rng=np.random.default_rng(0))
    e = alg.estimate(eps=0.1, delta=0.05)
    assert not sampled(e) and "'branch': 8" in e.note
    assert Fraction(e.lo) <= P <= Fraction(e.hi) and e.hi <= e.lo * (1 + 1e-12)
    s, r = 9 * t, t  # wires (upper bound), |Conf| = t
    assert alg.nodes <= 12 * s * 3 ** r


# ------------------------------------------------------------ caps
def test_kl_ratio_decreases_with_mean():
    for N in (1024, 1 << 16):
        for d in (0.3, 1e-6):
            prev = math.inf
            for m in np.geomspace(1e-5, 0.9, 120):
                lo, hi = kl_interval(float(m), N, d)
                r = hi / lo if lo > 0 else math.inf
                assert r <= prev * (1 + 1e-9)
                prev = r


@pytest.mark.parametrize("mu,eta", [(0.05, 0.3), (0.01, 0.5), (0.2, 0.15)])
def test_sample_cap_suffices(mu, eta):
    """The doubling rule stops by sample_cap(1/mu, eta, delta) in at least a
    1 - delta fraction of runs when the mean is mu."""
    delta = 0.2
    cap = sample_cap(1 / mu, eta, delta)
    rng = np.random.default_rng(3)
    runs, fails = 60, 0
    for _ in range(runs):
        e = sequential_mean(lambda k: (rng.random(k) < mu).astype(float), eta, delta, max_samples=cap)
        fails += not (e.lo > 0 and e.hi <= (1 + eta) * e.lo)
    assert fails <= delta * runs


def test_loose_leaves_and_user_cap_respected():
    rng = np.random.default_rng(5)
    n = 18
    C = Circuit(n)
    C.set_output(C.AND(*[C.XOR(i, i + 1, i + 2) for i in range(n - 2)]))
    D = Product.uniform(n)
    P = exact_fraction(C, D)
    e = dfsb_estimate(C, D, eps=0.1, delta=0.05, K=4, node_budget=3, rng=rng, exact_support=0,
                      small_cone=0, use_envelopes=False, loose_cap=5000)
    assert "'loose'" in e.note
    assert Fraction(e.lo) <= P <= Fraction(e.hi)
    nleaves = int(e.note.split("leaves ")[1].split(",")[0])
    assert e.samples <= 5000 * nleaves  # every leaf here is loose
    e2 = dfsb_estimate(C, D, eps=0.1, delta=0.05, K=4, node_budget=3, rng=rng, exact_support=0,
                       small_cone=0, use_envelopes=False, max_leaf_samples=2000)
    assert Fraction(e2.lo) <= P <= Fraction(e2.hi)


# ------------------------------------------------------------ soundness
def test_soundness_random_circuits_all_thresholds():
    rng = np.random.default_rng(42)
    runs, fails = 0, 0
    for _ in range(80):
        n = int(rng.integers(4, 11))
        C = random_circuit(n, int(rng.integers(3, 26)), rng)
        q = rng.uniform(0.02, 0.98, n)
        mask = rng.random(n) < 0.15
        q[mask] = rng.integers(0, 2, mask.sum())
        D = Product(q)
        P = exact_fraction(C, D)
        es = int(rng.choice([0, 2, 4, 12]))
        sc = int(rng.choice([0, 4, 10]))
        e = DFSB(C, D, K=8, node_budget=60, rng=rng, exact_support=es, small_cone=sc).estimate(
            eps=0.5, delta=0.1, max_leaf_samples=20000)
        ok = Fraction(e.lo) <= P <= Fraction(e.hi)
        if not sampled(e):
            assert ok, (e.lo, float(P), e.hi, e.note)
        runs += 1
        fails += not ok
    assert fails <= 0.1 * runs + 3


# ------------------------------------------------------------ meta
def test_meta_underflow_not_zero():
    n = 1200
    C = Circuit(n)
    C.set_output(C.AND(*[C.lit(i, 1) for i in range(n)]))
    e = meta_estimate(C, Product.uniform(n), eps=0.1, delta=0.05, rng=np.random.default_rng(0))
    assert e.hi > 0 and e.lo >= 0


def test_meta_exact_ve_contains():
    rng = np.random.default_rng(9)
    C = random_circuit(10, 30, rng)
    D = Product(rng.uniform(0.1, 0.9, 10))
    P = exact_fraction(C, D)
    e = meta_estimate(C, D, eps=0.1, delta=0.05, rng=rng)
    assert Fraction(e.lo) <= P <= Fraction(e.hi)


# ------------------------------------------------------------ certified VE
def _ve_contains(res, P: Fraction) -> bool:
    """The certificate itself: p = mant 2^exp (1 + theta), |theta| <= rel."""
    if res.zero:
        return P == 0
    m = Fraction(res.mant) * Fraction(2) ** res.exp
    r = Fraction(res.rel)
    return m * (1 - r) <= P <= m * (1 + r)


@pytest.mark.parametrize("seed", range(4))
def test_ve_bounds_contain_exact_value(seed):
    rng = np.random.default_rng(900 + seed)
    for _ in range(60):
        n = int(rng.integers(3, 11))
        C = random_circuit(n, int(rng.integers(3, 30)), rng)
        q = rng.uniform(0, 1, n)
        m = rng.random(n) < 0.2
        q[m] = rng.integers(0, 2, m.sum())
        m2 = rng.random(n) < 0.15
        q[m2] = 10.0 ** rng.uniform(-300, -5, m2.sum())  # deep but normal marginals
        D = Product(q)
        P = exact_fraction(C, D)
        res = ve_bounds(C, D, max_width=18)
        if res is None:  # declined (width or a would-be underflow): always allowed
            continue
        assert _ve_contains(res, P)
        lo, hi = res.interval()
        assert Fraction(lo) <= P <= Fraction(hi)


def test_ve_boundary_two_to_minus_1000():
    """Regression: the old underflow branch certified p < 2^-1000 from a
    floating-point VE value just below 2^-1000 while p was just above it."""
    rng = np.random.default_rng(11)
    n = 1000
    C = Circuit(n)
    C.set_output(C.AND(*range(n)))
    cases = [np.full(n, 0.5)]
    q = np.full(n, 0.5)
    q[0] = math.nextafter(0.5, 1.0)  # p = 2^-1000 (1 + 2^-52), just above the old threshold
    cases.append(q)
    cases += [0.5 + rng.uniform(-1, 1, n) * 1e-13 for _ in range(12)]
    for q in cases:
        D = Product(q)
        P = Fraction(1)
        for x in q:
            P *= Fraction(float(x))
        res = ve_bounds(C, D, max_width=18)
        assert res is not None and _ve_contains(res, P)
        e = meta_estimate(C, D, eps=0.1, delta=0.05, rng=rng)
        assert Fraction(e.lo) <= P <= Fraction(e.hi)
        assert 0 < e.lo and e.hi <= e.lo * (1 + 1e-9)


def test_ve_tiny_p_keeps_log_bounds():
    """p = 0.3^1100 ~ 10^-575 is far below the float range: the certificate
    still contains it, the float interval is [0, tiny] with hi > 0, and an
    exact zero is reported only for p = 0."""
    n = 1100
    C = Circuit(n)
    C.set_output(C.AND(*range(n)))
    D = Product(np.full(n, 0.3))
    res = ve_bounds(C, D, max_width=18)
    P = Fraction(0.3) ** n
    assert not res.zero and _ve_contains(res, P)
    l2lo, l2hi = res.log2_bounds()
    assert l2lo <= n * math.log2(0.3) <= l2hi and l2hi - l2lo < 1e-8
    e = meta_estimate(C, D, eps=0.1, delta=0.05, rng=np.random.default_rng(0))
    assert e.lo == 0.0 and 0 < e.hi < 1e-300
    Z = Circuit(2)
    Z.set_output(Z.AND(0, Z.NOT(0), 1))
    rz = ve_bounds(Z, Product.uniform(2))
    assert rz.zero and exact_ve(Z, Product.uniform(2)) == 0.0


def test_ve_threshold_uses_evaluator_sum():
    """Python's sum() is compensated; the evaluator adds left to right. With
    weights (1e16, 1, -1e16) the two differ, and VE must follow the evaluator."""
    C = Circuit(3)
    C.set_output(C.THR([0, 1, 2], [1e16, 1.0, -1e16], 0.5))
    D = Product.uniform(3)
    P = exact_fraction(C, D)
    assert P == Fraction(3, 8)
    res = ve_bounds(C, D)
    assert _ve_contains(res, P)
    e = meta_estimate(C, D, eps=0.1, delta=0.05, rng=np.random.default_rng(0))
    assert Fraction(e.lo) <= P <= Fraction(e.hi)


def test_ve_extreme_marginals_no_underflow():
    """Tables are mantissa/exponent pairs: products of tiny (even subnormal)
    marginals and tables spanning more than the double range stay exact up to
    the proved relative error."""
    rng = np.random.default_rng(5)
    for q0 in (1e-200, 1e-310, 0.3):
        n = 8
        C = Circuit(n)
        C.set_output(C.OR(C.AND(*range(n)), C.AND(0, C.NOT(1))))
        q = np.full(n, q0)
        q[2] = 0.7
        D = Product(q)
        res = ve_bounds(C, D)
        assert res is not None and _ve_contains(res, exact_fraction(C, D))
    C = random_circuit(9, 25, rng)
    q = 10.0 ** rng.uniform(-320, -1, 9)
    D = Product(q)
    res = ve_bounds(C, D)
    assert res is not None and _ve_contains(res, exact_fraction(C, D))


# ------------------------------------------------------------ canonical CNFs
def test_as_cnf_canonicalises_clauses():
    C = Circuit(3)
    n0a, n0b = C.NOT(0), C.NOT(0)
    c1 = C.OR(0, 0)                 # (x0 v x0)
    c2 = C.OR(1, 1, 2)              # (x1 v x1 v x2)
    c3 = C.OR(n0a, n0b, 2)          # (~x0 v ~x0 v x2): two distinct NOT gates
    taut = C.OR(1, C.NOT(1))        # tautology
    c2b = C.OR(2, 1)                # repeat of c2
    C.set_output(C.AND(c1, c2, c3, taut, c2b))
    cl = as_cnf(C)
    assert sorted(map(tuple, cl)) == sorted([((0, 1),), ((1, 1), (2, 1)), ((0, 0), (2, 1))])
    D = Product.uniform(3)
    P = exact_fraction(C, D)
    e = meta_estimate(C, D, eps=0.1, delta=0.05, rng=np.random.default_rng(0), ve_width=0)
    assert Fraction(e.lo) <= P <= Fraction(e.hi)


def test_as_cnf_repeated_literal_janson_example():
    """(x0 v x0) & (x1 v x1 v x2): p = 3/8; the doubled literals must not be
    counted twice by Harris/Janson."""
    C = Circuit(3)
    C.set_output(C.AND(C.OR(0, 0), C.OR(1, 1, 2)))
    cl = as_cnf(C)
    assert is_unate(cl)
    e = janson_interval(cl, Product.uniform(3))
    assert e.lo <= 0.375 <= e.hi
    m = meta_estimate(C, Product.uniform(3), eps=0.1, delta=0.05, rng=np.random.default_rng(1), ve_width=0)
    assert m.lo <= 0.375 <= m.hi


# ------------------------------------------------------------ new meta modules
def test_meta_runs_presolve_on_parity_checks():
    rng = np.random.default_rng(3)
    n, r = 30, 8
    C = Circuit(n)
    checks = [C.XOR(*[int(x) for x in rng.choice(n, 4, replace=False)]) for _ in range(r)]
    R = C.OR(*[C.AND(int(a), int(b)) for a, b in rng.choice(n, (3, 2), replace=False)])
    C.set_output(C.AND(*checks, R))
    D = Product.uniform(n)
    e = meta_estimate(C, D, eps=0.2, delta=0.05, rng=rng, ve_width=0, node_budget=200)
    assert "presolve" in e.note
    # p by enumeration over the 2^n cube is too big; check against VE instead
    res = ve_bounds(C, D, max_width=25)
    assert res is not None
    lo, hi = res.interval()
    assert e.lo <= hi and lo <= e.hi
    assert e.lo > 0 and e.hi <= 1.2 * e.lo * (1 + 1e-9)


def test_meta_runs_tg_on_local_threshold():
    rng = np.random.default_rng(4)
    n = 12
    C = Circuit(n)
    gs = [C.AND(i, (i + 1) % n) for i in range(n)]  # overlapping scopes
    C.set_output(C.THR(gs, [1.0] * n, 6.0))
    D = Product.uniform(n)
    P = exact_fraction(C, D)
    e = meta_estimate(C, D, eps=0.3, delta=0.05, rng=rng, ve_width=0, ctx_max_cw=0,
                      ltc_L=4000, ltc_max_is=8000)
    assert "local threshold (TG)" in e.note
    assert Fraction(e.lo) <= P <= Fraction(e.hi)


def test_meta_module_soundness_random():
    rng = np.random.default_rng(77)
    runs, fails = 0, 0
    for _ in range(40):
        n = int(rng.integers(4, 10))
        C = Circuit(n)
        kind = _ % 3
        if kind == 0:
            parts = [C.XOR(*[int(x) for x in rng.choice(n, 3, replace=False)]) for _ in range(2)]
            C.set_output(C.AND(*parts, C.OR(*[int(x) for x in rng.choice(n, 2, replace=False)])))
        elif kind == 1:
            gs = [C.AND(*[int(x) for x in rng.choice(n, 2, replace=False)]) for _ in range(4)]
            C.set_output(C.THR(gs, [1.0] * 4, float(rng.integers(1, 5))))
        else:
            C = random_circuit(n, int(rng.integers(3, 20)), rng)
        q = np.full(n, 0.5) if rng.random() < 0.5 else rng.uniform(0.1, 0.9, n)
        D = Product(q)
        P = exact_fraction(C, D)
        e = meta_estimate(C, D, eps=0.3, delta=0.1, rng=rng, ve_width=0, node_budget=50,
                          max_leaf_samples=20000, ltc_L=2000, ltc_max_is=4000)
        runs += 1
        fails += not (Fraction(e.lo) <= P <= Fraction(e.hi))
    assert fails <= 0.1 * runs + 2


# ------------------------------------------------------------ truncated fills
class _Sparse:
    """A box whose estimate claims mass 1/2; its function is never true
    (mass 0) or is x_0 (mass 1/2)."""

    def __init__(self, n, mass):
        self.sup = (1 << n) - 1
        self.value = 0.5
        self.mass = mass

    def eval(self, X):
        return np.zeros(len(X), dtype=bool) if self.mass == 0 else X[:, 0]


def test_rejection_fill_truncated_per_fill():
    n = 6
    D = Product.uniform(n)
    rng = np.random.default_rng(0)
    X = D.sample(50, rng)
    with pytest.raises(RuntimeError):
        Envelope._rejection_fill(_Sparse(n, 0), D, X, np.arange(50), rng, [0], fill_cap=200)
    cnt = [0]
    X = D.sample(5000, rng)
    Envelope._rejection_fill(_Sparse(n, 0.5), D, X, np.arange(5000), rng, cnt, fill_cap=200)
    assert X[:, 0].all() and cnt[0] < 40 * 5000


def test_dfsb_truncated_box_leaf_outputs_trivial_interval(monkeypatch):
    """Phase 2 with a fill cap of one draw: box (E)-leaves are truncated and
    output [0, 1], and the root interval stays valid."""
    import rareprob.dfsb as dfsb_mod
    orig = dfsb_mod.envelope_estimate
    truncated = [0]

    def tiny_cap(*a, **k):
        k["fill_cap"] = 1
        try:
            return orig(*a, **k)
        except RuntimeError:
            truncated[0] += 1
            raise

    monkeypatch.setattr(dfsb_mod, "envelope_estimate", tiny_cap)
    rng = np.random.default_rng(0)
    fails = 0
    for s in range(8):
        n = 14
        C = Circuit(n)
        th = [C.THR([int(a) for a in rng.choice(n, 4, replace=False)], [0.7, 1.3, 0.9, 1.1], 1.0)
              for _ in range(3)]  # opaque (real weights) and dense: boxes
        ors = [C.OR(int(a), int(b)) for a, b in rng.choice(n, (6, 2))]
        C.set_output(C.AND(*th, *ors))
        D = Product.uniform(n)
        P = exact_fraction(C, D)
        e = DFSB(C, D, K=8, node_budget=60, rng=np.random.default_rng(s), exact_support=0, small_cone=0,
                 use_dense=False).estimate(eps=0.5, delta=0.1, max_leaf_samples=20000)
        fails += not (Fraction(e.lo) <= P <= Fraction(e.hi))
    assert truncated[0] > 0 and fails <= 1


# ------------------------------------------------------------ compiler budget, chunked boxes
def test_compiler_rule_budget_keeps_domination():
    rng = np.random.default_rng(12)
    for budget in (1, 3, 10):
        n = 10
        C = random_circuit(n, 25, rng)
        N = to_nnf(C)
        D = Product.uniform(n)
        comp = EnvelopeCompiler(N, D, shannon=3, call_budget=budget)
        r = comp.env(N.root, {}, 0)
        comp.E.root = r
        assert comp.calls <= budget
        X = rng.random((4000, n)) < 0.5
        phi = comp.E.evaluate(X)
        assert np.all(phi[C.eval_bits(X)] >= 1)


def test_estimate_boxes_draws_in_batches():
    n = 4
    C = Circuit(n)
    C.set_output(C.OR(0, 1))
    N = to_nnf(C)
    E = Envelope()
    E.root = E.box(N, N.root, {}, (1 << n) - 1)
    D = Product.uniform(n)
    used = estimate_boxes(E, D, 0.002, 0.05, np.random.default_rng(0), max_samples=1 << 17)
    b = E.boxes[0]
    assert used > 1 << 15 and b.lo <= 0.75 <= b.hi


# ------------------------------------------------------------ exponentials
def test_exp_bounds_below_normal_range():
    for x in (-700.0, -708.5, -720.0, -740.0, -745.2, -800.0):
        up, dn = _exp_up(x), _exp_down(x)
        assert up > 0 and up >= math.exp(x) + math.ulp(0.0) * (math.exp(x) < 2.3e-308)
        assert dn <= math.exp(x)
        if math.exp(x) < 4.5e-308:
            assert dn == 0.0
    assert _exp_up(-math.inf) == 0.0 and _exp_down(-math.inf) == 0.0
