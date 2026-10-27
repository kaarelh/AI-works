"""Exact failure count of the d = 32 scaling net (meet-in-the-middle
enumeration of 2^32 inputs, nets.exact_failure_count), to check the SMC
reference estimate p_ref (writes results/exact_d32.json)."""

import json
import os
import sys
import time

os.environ.setdefault("OMP_NUM_THREADS", "1")
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import exact_failure_count, load_net  # noqa: E402

name = "mse_d32_w64_s600"
net = load_net(os.path.join(HERE, "results", "scaling_nets", name + ".npz"))
t = time.time()
cnt = exact_failure_count(net)
ref = [json.loads(l) for l in open(os.path.join(HERE, "results", "scaling.jsonl"))]
ref = [r for r in ref if r["kind"] == "ref" and r["name"] == name][0]
out = dict(name=name, fail_count=cnt, p_exact=cnt / 2.0 ** 32, p_ref=ref["p_ref"], p_ref_se=ref["p_ref_se"],
           seconds=round(time.time() - t, 1))
print(json.dumps(out))
json.dump(out, open(os.path.join(HERE, "results", "exact_d32.json"), "w"), indent=1)
