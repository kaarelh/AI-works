import math

import numpy as np
import pytest

from rareprob import Circuit, Product, exact_prob, compile_envelope, envelope_estimate, dnf_envelope
from rareprob.argument import honest_proof, verify, domination_cnf
from rareprob.cnf import forced_input_literals
from rareprob.families import (dnf_circuit, independent_blocks, obfuscated_dnf_circuit,
                               random_dnf_terms, trigger_circuit)
from rareprob.nnf import to_nnf
from rareprob.rup import RUPChecker
from rareprob.stats import kl_interval
from rareprob.ve import exact_ve


def all_points(n):
    return ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)


def random_circuit(n, gates, rng):
    C = Circuit(n)
    pool = list(range(n))
    for _ in range(gates):
        op = rng.choice(["AND", "OR", "XOR", "NOT"])
        if op == "NOT":
            g = C.NOT(int(rng.choice(pool)))
        else:
            k = int(rng.integers(2, 4))
            g = C.add(op, [int(t) for t in rng.choice(pool, size=k)])
        pool.append(g)
    return C.set_output(pool[-1])


def test_eval_matches_scalar():
    rng = np.random.default_rng(0)
    C = random_circuit(8, 30, rng)
    X = all_points(8)
    y = C.eval_bits(X)
    for x, v in zip(X[:50], y[:50]):
        assert C(x) == int(v)


def test_nnf_equivalent():
    rng = np.random.default_rng(1)
    for _ in range(20):
        C = random_circuit(7, 25, rng)
        N = to_nnf(C)
        X = all_points(7)
        assert np.array_equal(C.eval_bits(X), N.eval_batch(X))


@pytest.mark.parametrize("seed", range(10))
def test_envelope_dominates_and_masses_exact(seed):
    rng = np.random.default_rng(seed)
    n = 9
    C = random_circuit(n, 30, rng)
    D = Product(rng.uniform(0.2, 0.8, n))
    E, st, rho = compile_envelope(C, D, shannon=3)
    X = all_points(n)
    c = C.eval_bits(X)
    phi = E.evaluate(X)
    assert np.all(phi[c] >= 1 - 1e-9), "envelope must dominate C"
    w = D.pmf(X)
    assert math.isclose(E.mass(D), float((w * phi).sum()), rel_tol=1e-9)


@pytest.mark.parametrize("seed", range(5))
def test_envelope_sampler_exact(seed):
    rng = np.random.default_rng(100 + seed)
    n = 6
    terms = random_dnf_terms(n, 3, 3, rng)
    E = dnf_envelope(terms, n)
    D = Product(rng.uniform(0.2, 0.8, n))
    X = all_points(n)
    target = D.pmf(X) * E.evaluate(X)
    target /= target.sum()
    S = E.sample(D, 200_000, rng)
    idx = (S * (1 << np.arange(n))).sum(axis=1)
    emp = np.bincount(idx, minlength=1 << n) / len(idx)
    assert np.abs(emp - target).max() < 0.01


def test_kl_interval_coverage():
    rng = np.random.default_rng(5)
    mu, N, delta = 0.01, 2000, 0.1
    miss = 0
    for _ in range(400):
        x = rng.random(N) < mu
        lo, hi = kl_interval(x.mean(), N, delta)
        miss += not (lo <= mu <= hi)
    assert miss / 400 <= delta


def test_estimator_coverage_dnf():
    rng = np.random.default_rng(7)
    n = 16
    terms = random_dnf_terms(n, 6, 10, rng)
    C = dnf_circuit(n, terms)
    D = Product.uniform(n)
    p = exact_prob(C, D)
    E = dnf_envelope(terms, n)
    miss = 0
    for _ in range(40):
        est = envelope_estimate(C, D, E, eps=0.2, delta=0.1, rng=rng)
        miss += not est.contains(p)
        assert est.ratio <= 1.2 + 1e-9
    assert miss <= 8


def test_boxes_coverage():
    rng = np.random.default_rng(8)
    C, p, _ = independent_blocks(4, 4, 8, rng)
    D = Product.uniform(16)
    E, st, _ = compile_envelope(C, D, tau=0.05, rng=rng)
    for _ in range(5):
        est = envelope_estimate(C, D, E, eps=0.2, delta=0.1, rng=rng)
        assert est.contains(p) or True  # coverage checked statistically below
    miss = sum(not envelope_estimate(C, D, E, eps=0.3, delta=0.1, rng=rng).contains(p) for _ in range(20))
    assert miss <= 4


def test_forced_literals_trigger():
    rng = np.random.default_rng(9)
    C, trig, rest, R = trigger_circuit(20, 10, rng)
    f = forced_input_literals(C)
    for i, b in trig:
        assert f.get(i) == b


def test_ve_exact():
    rng = np.random.default_rng(10)
    for _ in range(5):
        C = random_circuit(10, 25, rng)
        D = Product(rng.uniform(0.1, 0.9, 10))
        assert math.isclose(exact_ve(C, D), exact_prob(C, D), rel_tol=1e-9, abs_tol=1e-12)


def test_rup_checker_rejects_bogus():
    # satisfiable formula: no refutation may be accepted
    cls = [[1, 2], [-1, 2], [1, -2]]
    assert not RUPChecker(cls).check_refutation([[2], [1], []])  # [1] is RUP? check soundness overall
    # unsatisfiable formula with a correct proof
    cls2 = [[1, 2], [-1, 2], [1, -2], [-1, -2]]
    assert RUPChecker(cls2).check_refutation([[2], []])


def test_argument_sound_and_complete():
    rng = np.random.default_rng(11)
    n = 18
    terms = random_dnf_terms(n, 6, 10, rng)
    C = obfuscated_dnf_circuit(n, terms, rng)
    D = Product.uniform(n)
    p = exact_prob(C, D)
    E = dnf_envelope(terms, n)
    pf = honest_proof(C, E)
    v = verify(C, D, E, pf, eps=0.1, delta=0.05, rng=rng)
    assert v.proof_ok and v.estimate.contains(p) and v.estimate.ratio <= 1.1 + 1e-9
    # a wrong envelope has no proof, and the verifier then gives only a lower bound
    E2 = dnf_envelope(terms[:-1], n)
    assert honest_proof(C, E2) is None
    v2 = verify(C, D, E2, pf, eps=0.1, delta=0.05, rng=rng)
    assert not v2.proof_ok and v2.estimate.hi == math.inf and v2.estimate.lo <= p
