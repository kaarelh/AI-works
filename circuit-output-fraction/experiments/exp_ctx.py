"""E7: context-width compilation. C = OR of t CNFs with sliding-window
clauses of width w, each along its own random variable order (context width
O(w); exact counting is #P-hard for such ORs in general). The circuit is
compiled into an equivalent DNNF (rareprob.ctxwidth) and estimated with the
envelope estimator (K <= t, the ambiguity of the top OR). Small n are
checked against enumeration. Writes results/ctx.json."""

import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob import Product, envelope_estimate, exact_prob  # noqa
from rareprob.ctxwidth import compile_ctx, context_width  # noqa
from rareprob.families import or_of_chain_cnfs  # noqa
from rareprob.nnf import to_nnf  # noqa
from rareprob.stats import mc_samples_needed  # noqa

OUT = os.path.join(os.path.dirname(__file__), "results")


def main():
    rng = np.random.default_rng(8)
    rows = []
    for n, t, w in [(20, 4, 3), (24, 4, 3), (100, 4, 3), (200, 4, 3), (400, 4, 3), (800, 8, 3), (400, 4, 5)]:
        C = or_of_chain_cnfs(n, t, w, rng)
        D = Product.uniform(n)
        t0 = time.time()
        N = to_nnf(C, flatten=False)
        cw = context_width(N)
        E = compile_ctx(N)
        tc = time.time() - t0
        t0 = time.time()
        e = envelope_estimate(C, D, E, eps=0.1, delta=0.05, rng=rng)
        te = time.time() - t0
        p = exact_prob(C, D) if n <= 24 else None  # count / 2^n under uniform D: exact
        row = dict(n=n, t=t, w=w, size=C.size, cw=cw, dnnf_size=E.size(), compile_seconds=tc, lo=e.lo, hi=e.hi,
                   ratio=e.ratio, samples=e.samples, estimate_seconds=te, exact_p=p,
                   contains=(None if p is None else bool(e.lo <= p <= e.hi)),
                   mc_cost=mc_samples_needed(e.lo, 0.1, 0.05))
        rows.append(row)
        print(row, flush=True)
    json.dump(rows, open(os.path.join(OUT, "ctx.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
