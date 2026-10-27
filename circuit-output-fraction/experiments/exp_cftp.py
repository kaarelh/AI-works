"""E6: certified telescoping with Las Vegas (CFTP) samplers on hard-core
ladders: x ~ Bernoulli(q)^n, C = [x is an independent set of the 2 x L
ladder graph], a unate 2-CNF. Janson's Delta is extensive here, so the
independence sandwich is useless. Exact p as a Fraction by a transfer matrix
along the rungs (cross-checked against variable elimination); every interval
is compared with it exactly. Writes results/cftp.json and results/cftp_log.txt."""

import json
import os
from fractions import Fraction
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob import Product  # noqa
from rareprob.cftp import telescoping_estimate  # noqa
from rareprob.janson import cnf_circuit, janson_interval  # noqa
from rareprob.stats import mc_samples_needed  # noqa
from rareprob.ve import exact_ve  # noqa

OUT = os.path.join(os.path.dirname(__file__), "results")
LOG = []


def log(s):
    print(s, flush=True)
    LOG.append(s)


def ladder(L):
    n, E = 2 * L, []
    for i in range(L):
        E.append((2 * i, 2 * i + 1))
        if i + 1 < L:
            E += [(2 * i, 2 * i + 2), (2 * i + 1, 2 * i + 3)]
    return n, [[(u, 0), (v, 0)] for u, v in E]


def ladder_prob(L, q):
    """Exact Pr[independent set of the 2 x L ladder], x_i ~ Bernoulli(q) (q at
    its exact binary value): transfer matrix over the rung states 00, 10, 01."""
    q = Fraction(q)
    w = {(0, 0): (1 - q) ** 2, (1, 0): q * (1 - q), (0, 1): q * (1 - q)}
    f = dict(w)
    for _ in range(L - 1):
        f = {s: w[s] * sum(v for t, v in f.items() if not (s[0] & t[0] or s[1] & t[1])) for s in w}
    return sum(f.values())


def main():
    rng = np.random.default_rng(4)
    rows = []
    for L in (20, 40, 60):
        n, cl = ladder(L)
        D = Product(np.full(n, 0.3))
        pe = ladder_prob(L, 0.3)
        p = float(pe)
        p_ve = exact_ve(cnf_circuit(n, cl), D)
        assert abs(p_ve / p - 1) < 1e-9, (p_ve, p)
        j = janson_interval(cl, D)
        t = time.time()
        e = telescoping_estimate(cl, D, N=2000, rng=rng)
        secs = time.time() - t
        rows.append(dict(L=L, n=n, clauses=len(cl), p=p, janson_lo=j.lo, janson_hi=j.hi, lo=e.lo, hi=e.hi,
                         value=e.value, contains=bool(e.lo <= pe <= e.hi),
                         janson_contains=bool(j.lo <= pe <= j.hi), cftp_runs=e.samples, seconds=secs,
                         mc_cost=mc_samples_needed(p, 0.2, 0.05), note=e.note))
        log(str(rows[-1]))
    json.dump(rows, open(os.path.join(OUT, "cftp.json"), "w"), indent=1)
    open(os.path.join(OUT, "cftp_log.txt"), "w").write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
