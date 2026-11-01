"""Rough Knuth estimates (8 probes, default slopes only) for the d = 128
two-hidden-layer suite nets, where the full knuth_suite.py run is too slow
on a shared machine. -> results/knuth_d128.json"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import CertNet, ProverConfig, knuth_estimate  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
out = {}
for name in ["bce_d128_w128x128_s1000", "bce_d128_w128x128_s300", "bce_d128_w128x128_s100"]:
    cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
    t0 = time.time()
    k = knuth_estimate(cn, ProverConfig(kinds=("lin",), r_leaf=5, alpha_iters=0, strong_k=2), probes=8, seed=1)
    k["seconds"] = time.time() - t0
    k["enum_full_fpe"] = cn.flops_enum(cn.d) / cn.fpe_flops
    out[name] = k
    json.dump(out, open(os.path.join(HERE, "results", "knuth_d128.json"), "w"), indent=1)
    print(f"{name}: nodes {k['nodes']:.3g} fpe {k['fpe']:.3g} depth {k['depth_mean']:.1f} "
          f"[{k['depth_min']}, {k['depth_max']}] ({k['seconds']:.0f}s)", flush=True)
