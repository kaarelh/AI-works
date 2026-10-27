"""E6: certified telescoping with Las Vegas (CFTP) samplers on hard-core
ladders: x ~ Bernoulli(q)^n, C = [x is an independent set of the 2 x L
ladder graph], a unate 2-CNF. Janson's Delta is extensive here, so the
independence sandwich is useless; exact p by variable elimination (the
ladder has treewidth 2). Writes results/cftp.json."""

import json
import os
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


def ladder(L):
    n, E = 2 * L, []
    for i in range(L):
        E.append((2 * i, 2 * i + 1))
        if i + 1 < L:
            E += [(2 * i, 2 * i + 2), (2 * i + 1, 2 * i + 3)]
    return n, [[(u, 0), (v, 0)] for u, v in E]


def main():
    rng = np.random.default_rng(4)
    rows = []
    for L in (20, 40, 60):
        n, cl = ladder(L)
        D = Product(np.full(n, 0.3))
        p = exact_ve(cnf_circuit(n, cl), D)
        j = janson_interval(cl, D)
        t = time.time()
        e = telescoping_estimate(cl, D, N=2000, rng=rng)
        secs = time.time() - t
        rows.append(dict(L=L, n=n, clauses=len(cl), p=p, janson_lo=j.lo, janson_hi=j.hi, lo=e.lo, hi=e.hi,
                         value=e.value, contains=bool(e.lo <= p <= e.hi), cftp_runs=e.samples, seconds=secs,
                         mc_cost=mc_samples_needed(p, 0.2, 0.05), note=e.note))
        print(rows[-1], flush=True)
    json.dump(rows, open(os.path.join(OUT, "cftp.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
