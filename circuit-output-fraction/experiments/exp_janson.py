"""E5: certified presumption of independence. Harris-Janson sandwich for
random unate k-CNFs: deterministic interval [M, M e^{Delta/(1-eps)}] (Delta over unordered dependent pairs) for
p = Pr[all clauses satisfied]. Small instances are checked against exact
enumeration; large ones report the interval and the Monte Carlo cost the same
ratio would need. Writes results/janson.json."""

import json
import math
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob import Product, exact_prob  # noqa
from rareprob.janson import cnf_circuit, janson_interval, random_unate_cnf  # noqa
from rareprob.stats import mc_samples_needed  # noqa

OUT = os.path.join(os.path.dirname(__file__), "results")


def main():
    rng = np.random.default_rng(7)
    rows = []
    for n, m, k in [(10**4, 2000, 10), (10**5, 2 * 10**4, 12), (2 * 10**5, 6 * 10**4, 12),
                    (10**6, 2 * 10**5, 14), (2 * 10**6, 2 * 10**5, 12)]:
        cl = random_unate_cnf(n, m, k, rng)
        D = Product.uniform(n)
        t = time.time()
        e = janson_interval(cl, D)
        secs = time.time() - t
        ratio = e.hi / e.lo
        eps_eq = ratio - 1
        mc = mc_samples_needed(e.lo, max(eps_eq, 1e-3), 0.05) if eps_eq < 1 else float("nan")
        rows.append(dict(n=n, m=m, k=k, lo=e.lo, hi=e.hi, ratio=ratio, seconds=secs, note=e.note,
                         mc_samples_same_ratio=mc, circuit_size=sum(len(c) for c in cl)))
        print(f"n={n:8d} m={m:8d} k={k:2d} p in [{e.lo:.3e},{e.hi:.3e}] ratio {ratio:.4f} "
              f"{secs:.1f}s ({e.note}); MC same ratio: {mc:.2e} evaluations", flush=True)
    # exact check on small instances
    miss = 0
    for t in range(200):
        n = 20
        cl = random_unate_cnf(n, int(rng.integers(3, 40)), int(rng.integers(2, 8)), rng)
        D = Product(rng.uniform(0.2, 0.8, n))
        p = exact_prob(cnf_circuit(n, cl), D)
        e = janson_interval(cl, D)
        miss += not (e.lo <= p * (1 + 1e-12) and p <= e.hi * (1 + 1e-12))
    print("exact-check violations:", miss, "/ 200")
    json.dump(dict(rows=rows, exact_check_violations=miss, exact_checks=200),
              open(os.path.join(OUT, "janson.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
