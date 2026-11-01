"""Plain Monte Carlo check of a net's failure probability.
usage: python3 mc_check.py <name> <samples>   (appends to results/mc_checks.jsonl)"""

import os
import sys
import time

from common import RES, append_row, get_net
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets_lower import random_cube  # noqa: E402

if __name__ == "__main__":
    name, n = sys.argv[1], int(float(sys.argv[2]))
    net = get_net(name)
    rng = np.random.default_rng(int(time.time()))
    t = time.time()
    hits = done = 0
    while done < n:
        k = min(1 << 18, n - done)
        hits += int((net.forward(random_cube(rng, k, net.d)) < net.threshold).sum())
        done += k
    out = dict(name=name, mc_n=n, mc_hits=hits, p_mc=hits / n, p_mc_se=hits ** 0.5 / n,
               seconds=round(time.time() - t, 1))
    print(out)
    append_row(os.path.join(RES, "mc_checks.jsonl"), out)
