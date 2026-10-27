"""E1: cost of the structure-aware estimators versus Monte Carlo, as the
output probability p shrinks, on families with exactly known p.

Cost is measured in circuit (or sub-circuit) evaluations; Monte Carlo cost is
the number of samples its KL interval needs at the same (eps, delta) when the
empirical mean equals p (computed, not run, below p = 1e-4; run as a check
above). Writes results/speedup.json.
"""

import json
import math
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob import Product, auto_estimate, compile_envelope, envelope_estimate  # noqa: E402
from rareprob.circuit import Circuit  # noqa: E402
from rareprob.families import (dnf_circuit, dnf_exact, independent_blocks, obfuscated_dnf_circuit,  # noqa: E402
                               random_block_circuit, random_dnf_terms, trigger_circuit)
from rareprob.stats import mc_samples_needed  # noqa: E402
from rareprob.dfsb import dfsb_estimate  # noqa: E402
from rareprob.tilting import Block, poisson_binomial_tail, tilted_estimate  # noqa: E402

EPS, DELTA = 0.1, 0.05
OUT = os.path.join(os.path.dirname(__file__), "results")
os.makedirs(OUT, exist_ok=True)


def record(rows, family, param, p, est, secs, extra=None):
    r = dict(family=family, param=param, p=p, lo=est.lo, hi=est.hi, value=est.value,
             contains=bool(est.lo <= p * (1 + 1e-12) and p <= est.hi * (1 + 1e-12)),
             ratio=est.ratio, cost=est.evaluations, mc_cost=mc_samples_needed(p, EPS, DELTA),
             seconds=secs, note=est.note)
    if extra:
        r.update(extra)
    rows.append(r)
    print(f"{family:14s} {str(param):8s} p={p:.3e} [{est.lo:.3e},{est.hi:.3e}] ok={r['contains']} "
          f"cost={r['cost']:.3g} mc={r['mc_cost']:.3g} {secs:.1f}s", flush=True)


def main():
    rng = np.random.default_rng(2026)
    rows = []

    # 1. DNF, plain and obfuscated (auto compile), width w
    n, m = 64, 16
    for w in (8, 16, 24, 32, 40, 48, 56):
        terms = random_dnf_terms(n, m, w, rng)
        D = Product.uniform(n)
        p = dnf_exact(terms, D)
        C = obfuscated_dnf_circuit(n, terms, rng, noise=2)
        t = time.time()
        est = dfsb_estimate(C, D, eps=EPS, delta=DELTA, rng=rng)
        record(rows, "dnf-obfuscated", w, p, est, time.time() - t, {"size": C.size})

    # 2. trigger / backdoor circuits: R(x_rest) AND [x_S = t], k trigger bits
    for k in (10, 20, 30, 40, 60, 80):
        n = k + 16
        C, trig, rest, R = trigger_circuit(n, k, rng, body_gates=40)
        D = Product.uniform(n)
        # exact Pr[R] by enumerating the 16 body variables
        X = np.zeros((1 << 16, n), dtype=bool)
        X[:, rest] = ((np.arange(1 << 16)[:, None] >> np.arange(16)) & 1).astype(bool)
        for i, b in trig:
            X[:, i] = bool(b)
        p = float(C.eval_bits(X).mean()) * 2.0 ** (-k)
        t = time.time()
        est = dfsb_estimate(C, D, eps=EPS, delta=DELTA, rng=rng)
        record(rows, "trigger", k, p, est, time.time() - t, {"size": C.size})

    # 2b. triggers whose dense body has 20 variables (above the atom size, so
    # DFSB samples the body after forcing the trigger)
    for k in (20, 40, 80):
        n = k + 20
        C, trig, rest, R = trigger_circuit(n, k, rng, body_gates=60)
        D = Product.uniform(n)
        X = np.zeros((1 << 20, n), dtype=bool)
        X[:, rest] = ((np.arange(1 << 20)[:, None] >> np.arange(20)) & 1).astype(bool)
        for i, b in trig:
            X[:, i] = bool(b)
        p = float(C.eval_bits(X).mean()) * 2.0 ** (-k)
        del X
        t = time.time()
        est = dfsb_estimate(C, D, eps=EPS, delta=DELTA, rng=rng)
        record(rows, "trigger-body20", k, p, est, time.time() - t, {"size": C.size})

    # 3. AND of independent random blocks (6 variables each)
    for kb in (4, 8, 16, 24, 32):
        C, p, probs = independent_blocks(kb, 6, 12, rng)
        D = Product.uniform(kb * 6)
        t = time.time()
        est = dfsb_estimate(C, D, eps=EPS, delta=DELTA, rng=rng)
        record(rows, "blocks", kb, p, est, time.time() - t, {"size": C.size})

    # 3b. AND of independent random blocks of 16 variables (above the atom
    # size: dense leaves are sampled, with the eps/(3d) accuracy split)
    for kb in (2, 4, 8, 16):
        C, p, probs = independent_blocks(kb, 16, 40, rng)
        D = Product.uniform(kb * 16)
        t = time.time()
        est = dfsb_estimate(C, D, eps=EPS, delta=DELTA, rng=rng)
        record(rows, "blocks16", kb, p, est, time.time() - t, {"size": C.size})

    # 4. threshold of independent blocks: exponential tilting (Chernoff envelope)
    for kb, frac in ((50, 0.75), (100, 0.75), (200, 0.75), (400, 0.75), (800, 0.75)):
        b = 5
        n = kb * b
        D = Product.uniform(n)
        blocks = []
        for j in range(kb):
            vs = list(range(j * b, (j + 1) * b))
            Cb = Circuit(n)
            Cb.set_output(random_block_circuit(Cb, vs, 8, rng))
            blocks.append(Block(vs, Cb, 1.0))
        for bl in blocks:
            bl.tabulate(D)
        mean = sum(bl.p1 for bl in blocks)
        tt = math.ceil(mean + frac * (kb - mean) * 0.5)
        p = poisson_binomial_tail([bl.p1 for bl in blocks], [1] * kb, tt)
        t = time.time()
        est = tilted_estimate(blocks, tt, D, n, eps=EPS, delta=DELTA, rng=rng)
        record(rows, "threshold", kb, p, est, time.time() - t, {"t": tt})

    with open(os.path.join(OUT, "speedup.json"), "w") as f:
        json.dump(rows, f, indent=1)


if __name__ == "__main__":
    main()
