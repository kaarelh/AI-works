"""Knuth estimates (current prover settings and cost model) of the 'lin'
certificate tree for the d = 64 suite nets: nodes, verifier fpe, and the
prover's CPU time extrapolated from the time per node measured on the
probes' own work (rough). The uncollapsed tree is estimated; for p = 0 nets
nothing collapses at d = 64 (enumeration costs ~6e17 fpe).

Usage: python3 knuth_d64.py [probes] -> results/knuth_d64.json
"""
import json
import os
import sys
import time

os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import CertNet, ProverConfig, knuth_estimate  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
NAMES = ["bce_d64_w64_s1000", "bce_d64_w64_s300", "bce_d64_w64_s100", "mse_d64_w64_s3000", "mse_d64_w64_s1000",
         "mse_d64_w64_s300"]


def main():
    probes = int(sys.argv[1]) if len(sys.argv) > 1 else 64
    out_path = os.path.join(HERE, "results", "knuth_d64.json")
    out = json.load(open(out_path)) if os.path.exists(out_path) else {}
    suite = {e["name"]: e for e in json.load(open(os.path.join(NETS, "suite.json")))}
    for name in NAMES:
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        t0 = time.time()
        k = knuth_estimate(cn, ProverConfig(kinds=("lin",), r_leaf=5, strong_k=2, alpha_iters=100), probes=probes,
                           seed=1)
        k["seconds"] = time.time() - t0
        k["enum_full_fpe"] = cn.flops_enum(cn.d) / cn.fpe_flops
        k["z"] = suite[name]["z"]
        out[name] = k
        json.dump(out, open(out_path, "w"), indent=1)
        print(f"{name}: nodes {k['nodes']:.3g} +- {k['nodes_se']:.2g}, verifier fpe {k['fpe']:.3g} +- "
              f"{k['fpe_se']:.2g}, depth {k['depth_mean']:.1f} [{k['depth_min']}, {k['depth_max']}] "
              f"({k['seconds']:.0f}s)", flush=True)


if __name__ == "__main__":
    main()
