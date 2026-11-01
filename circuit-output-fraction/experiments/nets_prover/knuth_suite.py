"""Knuth estimates of the prover's (uncollapsed) certificate tree for every
net of experiments/nets/suite.json: number of nodes, leaf mix, verifier
cost (fpe), for 'lin' and 'lin'+'quad' certificates. Fast (random probes).

Usage: python3 knuth_suite.py [probes] [lin|lin5|all]   -> results/knuth_suite.json
('lin' skips the slow 'quad' variants, e.g. for d >= 64)
"""
import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import CertNet, ProverConfig, knuth_estimate  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
probes = int(sys.argv[1]) if len(sys.argv) > 1 else 128
which = sys.argv[2] if len(sys.argv) > 2 else "all"
KINDS = [("lin",)] if which.startswith("lin") else [("lin",), ("lin", "quad")]
RLS = (5,) if which == "lin5" else (5, 8)
suite = json.load(open(os.path.join(NETS, "suite.json")))
out_path = os.path.join(HERE, "results", "knuth_suite.json")
out = json.load(open(out_path)) if os.path.exists(out_path) else {}
for e in suite:
    name = e["name"]
    if name in out and out[name].get("probes") == probes and all(
            f"{'+'.join(k)}_rl{rl}" in out[name] for k in KINDS for rl in RLS):
        continue
    cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
    rec = {"d": e["d"], "widths": e["widths"], "loss": e["loss"], "z": e["z"], "p_exact": e.get("p_exact"),
           "fail_count": e.get("fail_count"), "probes": probes,
           "enum_full_fpe": cn.flops_enum(cn.d) / cn.fpe_flops}
    for kinds in KINDS:
        for rl in RLS:
            t0 = time.time()
            k = knuth_estimate(cn, ProverConfig(kinds=kinds, r_leaf=rl, quad_rmin=6, quad_iters=200),
                               probes=probes, seed=1)
            k["seconds"] = time.time() - t0
            rec["+".join(kinds) + f"_rl{rl}"] = k
            print(f"{name:26s} {'+'.join(kinds):9s} r_leaf={rl} nodes {k['nodes']:.3g} fpe {k['fpe']:.3g} "
                  f"(full enum {rec['enum_full_fpe']:.3g}) depth {k['depth_mean']:.1f} "
                  f"leaves { {a: f'{b:.3g}' for a, b in k['leaf_kinds'].items()} } {k['seconds']:.0f}s", flush=True)
    out[name] = {**out.get(name, {}), **rec}
    json.dump(out, open(out_path, "w"), indent=1)
