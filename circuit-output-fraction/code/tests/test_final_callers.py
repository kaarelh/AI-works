"""Every KL interval on a measured floating-point mean is told the rounding
error of that mean (stats.sum_rel_err), and the callers fixed for this stay
sound."""

import ast
import os
from fractions import Fraction
from types import SimpleNamespace

import numpy as np

from rareprob import Circuit, Product
from rareprob import localthr, stats, tilting
from rareprob.exact import exact_prob_rational

PKG = os.path.join(os.path.dirname(__file__), "..", "rareprob")


def test_every_kl_interval_call_passes_rel_err():
    """Outside stats.py (whose mc_samples_needed evaluates a hypothetical,
    not a measured, mean) every call kl_interval(...) passes rel_err."""
    missing = []
    for fn in sorted(os.listdir(PKG)):
        if not fn.endswith(".py") or fn == "stats.py":
            continue
        tree = ast.parse(open(os.path.join(PKG, fn)).read())
        for node in ast.walk(tree):
            if isinstance(node, ast.Call) and getattr(node.func, "id", getattr(node.func, "attr", None)) == "kl_interval":
                if not any(k.arg == "rel_err" for k in node.keywords):
                    missing.append(f"{fn}:{node.lineno}")
    assert not missing, missing


def test_ti_interval_window_passes_rel_err(monkeypatch):
    seen = []
    real = localthr.kl_interval

    def spy(mean, N, delta, rel_err=0.0):
        seen.append((N, rel_err))
        return real(mean, N, delta, rel_err=rel_err)

    monkeypatch.setattr(localthr, "kl_interval", spy)
    rng = np.random.default_rng(0)
    L = 64
    Y = rng.integers(0, 21, L).astype(float)
    lo, hi, info = localthr.ti_interval(Y, 0.5, 5.0, 0, 20, 0.01, 0.01, 0.01, centres=np.full(L, 10.0), w=4.0)
    assert seen and seen[0][0] == L and seen[0][1] >= stats.sum_rel_err(L) > 0
    assert lo <= hi and info["e_out"] > 0


def test_kl_interval_rel_err_widens():
    for mean, N in ((0.3, 1000), (1e-6, 10**7), (0.999, 50)):
        a = stats.kl_interval(mean, N, 0.05)
        b = stats.kl_interval(mean, N, 0.05, rel_err=stats.sum_rel_err(N))
        assert b[0] <= a[0] and a[1] <= b[1]


def test_proposal_lower_bound_sound_against_exact_p():
    """Brute force: the lower end never exceeds the exact rational p, for a
    good proposal, a bad one and an M far too small."""
    rng = np.random.default_rng(3)
    n = 8
    C = Circuit(n)
    C.set_output(C.AND(C.OR(0, 1), 2, 3, C.NOT(4), C.XOR(5, 6)))
    D = Product(np.array([0.3, 0.6, 0.2, 0.25, 0.7, 0.5, 0.4, 0.5]))
    p = exact_prob_rational(C, D)
    good = SimpleNamespace(q=np.array([0.6, 0.7, 1.0, 1.0, 0.0, 0.5, 0.5, 0.5]))
    bad = SimpleNamespace(q=np.full(n, 0.5))
    for Q, M in ((good, float(p) * 4), (bad, float(p) * 4), (good, float(p) / 100), (good, 1.0)):
        e = tilting.proposal_lower_bound(C, D, Q, M, delta=0.05, N=20000, rng=rng)
        assert e.hi == 1.0
        assert Fraction(e.lo) <= p, (Q.q, M, e.lo, float(p))
    # untrusted objects give the trivial interval
    for Q, M in ((SimpleNamespace(q=np.full(n, np.nan)), 1.0), (good, -1.0), (object(), 1.0),
                 (SimpleNamespace(q=np.full(n + 1, 0.5)), 1.0)):
        e = tilting.proposal_lower_bound(C, D, Q, M, N=100, rng=rng)
        assert (e.lo, e.hi) == (0.0, 1.0)


def test_rational_references_match_enumeration():
    """The exact reference values used by the experiments (DNFs by
    inclusion-exclusion, Poisson-binomial tails) against brute force."""
    from itertools import product as iprod

    from rareprob.exact import dnf_prob_rational, poisson_binomial_tail_rational
    from rareprob.families import dnf_circuit, random_dnf_terms

    rng = np.random.default_rng(5)
    for _ in range(20):
        n = 10
        terms = random_dnf_terms(n, int(rng.integers(1, 7)), int(rng.integers(1, 5)), rng)
        D = Product(rng.uniform(0.05, 0.95, n))
        assert dnf_prob_rational(terms, D) == exact_prob_rational(dnf_circuit(n, terms), D)
        assert dnf_prob_rational(terms) == exact_prob_rational(dnf_circuit(n, terms))
    for _ in range(20):
        k = int(rng.integers(1, 8))
        ps = list(rng.uniform(0, 1, k)) + [Fraction(1, 3)]
        ws = [int(w) for w in rng.integers(0, 4, k)] + [2]
        for t in (-1, 0, 0.5, 1, 2.25, 3, 7, sum(ws), sum(ws) + 0.5, float("inf"), float("-inf")):
            brute = Fraction(0)
            for bits in iprod((0, 1), repeat=k + 1):
                pr = Fraction(1)
                for b, p in zip(bits, ps):
                    pr *= Fraction(p) if b else 1 - Fraction(p)
                brute += pr if sum(b * w for b, w in zip(bits, ws)) >= t else 0
            assert poisson_binomial_tail_rational(ps, ws, t) == brute
