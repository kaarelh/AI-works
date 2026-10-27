"""Regression tests for the PCIS verifier (argument.py): the envelope is untrusted
data, so its stored supports, kinds, literal indices and DAG structure must all be
checked by the verifier, and a malformed argument must yield a valid interval."""

import math

import numpy as np
import pytest

from rareprob import Circuit, Product, exact_prob
from rareprob.argument import (domination_cnf, honest_proof, sanitize_envelope,
                               support_circuit, verify)
from rareprob.envelope import Envelope, dnf_envelope
from rareprob.families import obfuscated_dnf_circuit, random_dnf_terms
from rareprob.rup import RUPChecker


def _x0_circuit():
    C = Circuit(2)
    return C.set_output(C.OR(C.lit(0, 1), C.AND(C.lit(0, 1), C.lit(1, 1))))  # = x0


def _raw(kinds, datas, sups, root):
    E = Envelope()
    E.kind, E.data, E.sup, E.root = list(kinds), list(datas), list(sups), root
    return E


def test_lying_support_is_not_trusted():
    # PROD([x0], [x0]) with the second leaf's support falsely declared empty:
    # mass q0^2 = 1/4, phi = [x0], and C = x0 provably implies supp phi = x0.
    # Trusting the declared supports gave a tight interval around 1/4, but p = 1/2.
    C, D = _x0_circuit(), Product.uniform(2)
    E = _raw(["LIT", "LIT", "PROD"], [(0, 1), (0, 1), (0, 1)], [1, 0, 1], 2)
    v = verify(C, D, E, honest_proof(C, E), eps=0.1, delta=0.05, rng=np.random.default_rng(0))
    assert v.estimate.contains(0.5)
    assert not v.proof_ok


MALFORMED = [
    _raw(["LIT", "SUM"], [(0, 1), (1,)], [1, 1], 1),           # SUM is its own child (cycle)
    _raw(["SUM", "LIT"], [(1,), (0, 1)], [1, 1], 0),           # forward reference
    _raw(["LIT"], [(-1, 1)], [1], 0),                          # negative index
    _raw(["LIT"], [(2, 1)], [4], 0),                           # index out of range
    _raw(["LIT"], [(0, 2)], [1], 0),                           # literal value not 0/1
    _raw(["LIT"], [(0.0, 1)], [1], 0),                         # float index
    _raw(["LIT"], [(0,)], [1], 0),                             # wrong arity
    _raw(["CONST"], [3], [0], 0),                              # unknown kind
    _raw(["BOX"], [0], [1], 0),                                # boxes not allowed
    _raw(["LIT", "SUM"], [(0, 1), ()], [1, 0], 1),             # empty SUM
    _raw(["LIT"], [(0, 1)], [1], 5),                           # root out of range
    _raw(["LIT"], [(0, 1)], [1], "0"),                         # root not an int
    _raw(["LIT", "LIT"], [(0, 1)], [1, 1], 0),                 # inconsistent lengths
]


@pytest.mark.parametrize("E", MALFORMED)
def test_malformed_envelope_gives_trivial_interval(E):
    C, D = _x0_circuit(), Product.uniform(2)
    assert sanitize_envelope(E, 2) is None
    v = verify(C, D, E, [[]], eps=0.1, delta=0.05, rng=np.random.default_rng(1))
    assert (v.estimate.lo, v.estimate.hi) == (0.0, 1.0) and not v.proof_ok


def _needs_proof():
    """C = x0 OR F with F the four clauses on (x1, x2): C implies x0, but unit
    propagation alone does not refute the domination CNF for E = [x0]."""
    C = Circuit(3)
    F = C.AND(*[C.OR(C.lit(1, a), C.lit(2, b)) for a in (0, 1) for b in (0, 1)])
    C.set_output(C.OR(C.lit(0, 1), F))
    E = Envelope()
    E.root = E.lit(0, 1)
    return C, E


@pytest.mark.parametrize("proof", [42, [["a", 1], 3.5], [[1.5, 2]], [[0]], [None], "1 0", [[]]])
def test_garbage_proof_gives_lower_bound_only(proof):
    C, E = _needs_proof()
    D = Product.uniform(3)
    assert not RUPChecker(domination_cnf(C, E)).refuted
    v = verify(C, D, E, proof, eps=0.1, delta=0.05, rng=np.random.default_rng(2))
    assert not v.proof_ok and v.estimate.hi == math.inf and v.estimate.lo <= 0.5
    w = verify(C, D, E, honest_proof(C, E), eps=0.1, delta=0.05, rng=np.random.default_rng(3))
    assert w.proof_ok and w.estimate.contains(0.5)


def test_honest_argument_unchanged():
    rng = np.random.default_rng(11)
    n = 16
    terms = random_dnf_terms(n, 6, 8, rng)
    C = obfuscated_dnf_circuit(n, terms, rng)
    D = Product.uniform(n)
    p = exact_prob(C, D)
    E = dnf_envelope(terms, n)
    S = sanitize_envelope(E, n)
    assert S is not None and domination_cnf(C, S) == domination_cnf(C, E)
    v = verify(C, D, E, honest_proof(C, E), eps=0.1, delta=0.05, rng=rng)
    assert v.proof_ok and v.estimate.contains(p) and v.estimate.ratio <= 1.1 + 1e-9


def _random_envelope(n, rng):
    E = Envelope()

    def build(vs, depth):
        if depth == 0 or len(vs) == 1:
            return E.lit(int(rng.choice(vs)), int(rng.integers(2)))
        if rng.random() < 0.5:  # SUM: children over overlapping subsets
            return E.SUM([build(list(rng.choice(vs, size=max(1, len(vs) // 2), replace=False)), depth - 1)
                          for _ in range(int(rng.integers(2, 4)))])
        perm = list(rng.permutation(vs))  # PROD: children over disjoint parts
        k = int(rng.integers(2, min(3, len(perm)) + 1))
        return E.PROD([build([int(t) for t in perm[j::k]], depth - 1) for j in range(k)])

    E.root = build(list(range(n)), 3)
    return E


@pytest.mark.parametrize("seed", range(12))
def test_random_arguments_sound(seed):
    """Random well-formed envelopes; C is (a random circuit) AND (supp phi) half of
    the time, so that domination holds and the proof exists, and a random circuit
    otherwise. Every returned interval must contain p (delta = 0.01, fixed seeds)."""
    rng = np.random.default_rng(500 + seed)
    n = 8
    E = _random_envelope(n, rng)
    C = support_circuit(E, n)
    pool = list(range(n))
    for _ in range(12):
        op = str(rng.choice(["AND", "OR", "XOR"]))
        g = C.add(op, [int(t) for t in rng.choice(pool, size=2)])
        pool.append(g)
    if seed % 2 == 0:
        C.set_output(C.AND(pool[-1], C.output))
    else:
        C.set_output(pool[-1])
    D = Product(rng.uniform(0.2, 0.8, n))
    p = exact_prob(C, D)
    pf = honest_proof(C, E)
    v = verify(C, D, E, pf, eps=0.2, delta=0.01, rng=rng)
    assert v.estimate.lo <= p * (1 + 1e-9)
    assert p <= v.estimate.hi * (1 + 1e-9) + 1e-15
    if seed % 2 == 0:
        assert v.proof_ok
