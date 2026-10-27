"""Larger Monte Carlo check of a scaling net's reference estimate.
usage: python3 mc_check.py <name> <samples>   (appends to results/mc_checks.jsonl)"""

import json
import os
import sys
import time

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_lower import random_cube  # noqa: E402

name, n = sys.argv[1], int(float(sys.argv[2]))
net = load_net(os.path.join(HERE, "results", "scaling_nets", name + ".npz"))
ref = [json.loads(l) for l in open(os.path.join(HERE, "results", "scaling.jsonl"))]
ref = [r for r in ref if r["kind"] == "ref" and r["name"] == name][0]
rng = np.random.default_rng(int(time.time()))
t = time.time()
hits = done = 0
while done < n:
    k = min(1 << 18, n - done)
    hits += int((net.forward(random_cube(rng, k, net.d)) < net.threshold).sum())
    done += k
out = dict(name=name, mc_n=n, mc_hits=hits, p_mc=hits / n, p_mc_se=hits ** 0.5 / n, p_ref=ref["p_ref"],
           p_ref_se=ref["p_ref_se"], seconds=round(time.time() - t, 1))
print(json.dumps(out))
with open(os.path.join(HERE, "results", "mc_checks.jsonl"), "a") as f:
    f.write(json.dumps(out) + "\n")
