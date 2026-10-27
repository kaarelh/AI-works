"""E2: soundness. Empirical miss rates of the intervals, at delta = 0.1, on
random circuits and families with exactly known p, including adversarial
arguments (wrong envelopes, envelopes without proofs, bogus proofs).

Every reference value is an exact Fraction (enumeration in rational
arithmetic, exact block probabilities and their product, or an exact
Poisson-binomial tail), compared with the interval ends without slack.
Every procedure must have miss rate <= delta (up to sampling error of the
miss-rate estimate itself). Writes results/coverage.json.
"""

import json
import math
import os
import sys
from fractions import Fraction

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob import Product, auto_estimate, compile_envelope, dnf_envelope, envelope_estimate, exact_prob  # noqa
from rareprob.exact import exact_prob_rational, poisson_binomial_tail_rational  # noqa
from rareprob.argument import honest_proof, verify  # noqa
from rareprob.circuit import Circuit  # noqa
from rareprob.dfsb import dfsb_estimate  # noqa
from rareprob.envelope import Envelope  # noqa
from rareprob.families import (dnf_circuit, independent_blocks, obfuscated_dnf_circuit,  # noqa
                               random_block_circuit, random_dnf_terms, trigger_circuit)
from rareprob.janson import cnf_circuit, janson_interval, random_unate_cnf  # noqa
from rareprob.tilting import Block, tilted_estimate  # noqa

DELTA = 0.1
OUT = os.path.join(os.path.dirname(__file__), "results")
os.makedirs(OUT, exist_ok=True)


def random_circuit(n, gates, rng):
    C = Circuit(n)
    pool = list(range(n))
    for _ in range(gates):
        op = rng.choice(["AND", "OR", "XOR", "NOT", "AND", "AND"])
        if op == "NOT":
            g = C.NOT(int(rng.choice(pool)))
        else:
            k = int(rng.integers(2, 4))
            g = C.add(op, [int(t) for t in rng.choice(pool, size=k)])
        pool.append(g)
    return C.set_output(pool[-1])


def tally(name, results, rows):
    miss = sum(1 for ok in results if not ok)
    n = len(results)
    rows.append(dict(procedure=name, trials=n, misses=miss, miss_rate=miss / n, delta=DELTA))
    print(f"{name:40s} trials={n:4d} misses={miss:3d} rate={miss / n:.3f} (delta={DELTA})", flush=True)


def contains(e, p):
    # p is an exact Fraction and the comparison with the float ends is exact:
    # no slack, so floating-point misses of the procedures count as misses
    return e.lo <= p <= e.hi


def main():
    rng = np.random.default_rng(12345)
    rows = []

    # 1. auto envelope estimator and DFSB on random circuits (any structure)
    res_auto, res_dfsb = [], []
    for t in range(300):
        n = int(rng.integers(8, 15))
        C = random_circuit(n, int(rng.integers(15, 50)), rng)
        D = Product(rng.uniform(0.15, 0.85, n))
        p = exact_prob_rational(C, D)
        e = auto_estimate(C, D, eps=0.2, delta=DELTA, rng=rng, max_samples=20000)
        res_auto.append(contains(e, p))
        if t < 150:
            e2 = dfsb_estimate(C, D, eps=0.2, delta=DELTA, K=16, rng=rng, node_budget=100)
            res_dfsb.append(contains(e2, p))
    tally("envelope (auto) on random circuits", res_auto, rows)
    tally("DFSB on random circuits", res_dfsb, rows)

    # 2. KLM envelope on random DNFs, rare
    res = []
    for t in range(300):
        n = 18
        terms = random_dnf_terms(n, int(rng.integers(3, 12)), int(rng.integers(6, 14)), rng)
        C = dnf_circuit(n, terms)
        D = Product(rng.uniform(0.2, 0.8, n))
        p = exact_prob_rational(C, D)
        e = envelope_estimate(C, D, dnf_envelope(terms, n), eps=0.2, delta=DELTA, rng=rng)
        res.append(contains(e, p))
    tally("KLM envelope on DNFs", res, rows)

    # 3. boxes: products of dense blocks
    res = []
    for t in range(100):
        C, _, probs = independent_blocks(int(rng.integers(2, 5)), 4, 8, rng)
        p = math.prod(Fraction(q) for q in probs)  # block probabilities are exact (counts / 2^4)
        D = Product.uniform(C.n)
        E, _, _ = compile_envelope(C, D, tau=0.05, rng=rng)
        e = envelope_estimate(C, D, E, eps=0.3, delta=DELTA, rng=rng)
        res.append(contains(e, p))
    tally("envelope with boxes on block products", res, rows)

    # 4. tilting on thresholds of blocks
    res = []
    for t in range(200):
        kb, b = int(rng.integers(10, 60)), 4
        n = kb * b
        D = Product.uniform(n)
        blocks = []
        for j in range(kb):
            vs = list(range(j * b, (j + 1) * b))
            Cb = Circuit(n)
            Cb.set_output(random_block_circuit(Cb, vs, 6, rng))
            blocks.append(Block(vs, Cb, 1.0))
        for bl in blocks:
            bl.tabulate(D)
        mean = sum(bl.p1 for bl in blocks)
        tt = int(math.ceil(mean + rng.uniform(0.1, 0.5) * (kb - mean)))
        # exact block probabilities under uniform D: counts / 2^b
        p = poisson_binomial_tail_rational([Fraction(len(bl.pts1), 1 << b) for bl in blocks], [1] * kb, tt)
        if p == 0:
            continue
        e = tilted_estimate(blocks, tt, D, n, eps=0.2, delta=DELTA, rng=rng)
        res.append(contains(e, p))
    tally("exponential tilting on thresholds", res, rows)

    # 5. Harris-Janson sandwich (deterministic): must always contain p
    res = []
    for t in range(300):
        n = 18
        cl = random_unate_cnf(n, int(rng.integers(3, 50)), int(rng.integers(2, 7)), rng)
        D = Product(rng.uniform(0.2, 0.8, n))
        p = exact_prob_rational(cnf_circuit(n, cl), D)
        res.append(contains(janson_interval(cl, D), p))
    tally("Harris-Janson sandwich (deterministic)", res, rows)

    # 6. adversarial arguments: wrong envelopes / bogus proofs / no proofs
    res_honest, res_wrong_env, res_bogus, res_noproof, res_lied = [], [], [], [], []
    for t in range(150):
        n = 16
        terms = random_dnf_terms(n, int(rng.integers(3, 8)), int(rng.integers(6, 11)), rng)
        C = obfuscated_dnf_circuit(n, terms, rng)
        D = Product.uniform(n)
        p = exact_prob_rational(C, D)
        E = dnf_envelope(terms, n)
        pf = honest_proof(C, E)
        res_honest.append(contains(verify(C, D, E, pf, eps=0.2, delta=DELTA, rng=rng).estimate, p))
        # wrong envelope: drop a term, reuse the honest proof (must not verify)
        E2 = dnf_envelope(terms[:-1], n)
        v2 = verify(C, D, E2, pf, eps=0.2, delta=DELTA, rng=rng)
        res_wrong_env.append(contains(v2.estimate, p))
        # bogus proof: a list of random clauses ending with the empty clause
        bogus = [[int(rng.integers(1, n + 1)) * int(rng.choice([-1, 1]))] for _ in range(10)] + [[]]
        v3 = verify(C, D, E2, bogus, eps=0.2, delta=DELTA, rng=rng)
        res_bogus.append(contains(v3.estimate, p))
        # envelope that misses most mass, no proof: lower bound only
        E4 = Envelope()
        i, b = terms[0][0]
        E4.root = E4.PROD([E4.lit(i, 1 - b)] + [E4.lit(j, c) for j, c in terms[0][1:]])
        v4 = verify(C, D, E4, None, eps=0.2, delta=DELTA, rng=rng)
        res_noproof.append(contains(v4.estimate, p))
        # malformed envelope: the honest DNF envelope plus a non-decomposable
        # PROD(x_i, not x_i) whose second literal declares an empty support (a lie
        # the verifier must not trust), with the honest proof and with none
        E5 = dnf_envelope(terms, n)
        i0 = int(rng.integers(0, n))
        a5 = E5.lit(i0, 1)
        E5.kind.append("LIT"); E5.data.append((i0, 0)); E5.sup.append(0)
        b5 = len(E5.kind) - 1
        E5.kind.append("PROD"); E5.data.append((a5, b5)); E5.sup.append(1 << i0)
        c5 = len(E5.kind) - 1
        E5.kind.append("SUM"); E5.data.append((E5.root, c5)); E5.sup.append(E5.sup[E5.root] | (1 << i0))
        E5.root = len(E5.kind) - 1
        for proof in (pf, None):
            v5 = verify(C, D, E5, proof, eps=0.2, delta=DELTA, rng=rng)
            res_lied.append(contains(v5.estimate, p))
    tally("argument: honest envelope + DRUP proof", res_honest, rows)
    tally("argument: wrong envelope + stale proof", res_wrong_env, rows)
    tally("argument: wrong envelope + bogus proof", res_bogus, rows)
    tally("argument: disjoint envelope, no proof", res_noproof, rows)
    tally("argument: malformed envelope (lied supports)", res_lied, rows)

    with open(os.path.join(OUT, "coverage.json"), "w") as f:
        json.dump(rows, f, indent=1)


if __name__ == "__main__":
    main()
