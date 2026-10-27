"""Tests for the DFSB fixes: exact atoms (T'), atom-protected flattening,
forcing to a fixpoint, zero-mass envelopes, Phase-2 sample caps, cutset
conditioning with (S) and (E) disabled, and the meta-procedure's handling of
underflow and empty intersections."""

import math
from fractions import Fraction

import numpy as np
import pytest

from rareprob.circuit import Circuit
from rareprob.dfsb import DFSB, AtomNNF, atom_nnf, dfsb_estimate, sample_cap, _leaves
from rareprob.dist import Product
from rareprob.meta import meta_estimate
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
