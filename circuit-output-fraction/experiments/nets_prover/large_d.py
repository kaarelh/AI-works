"""The d = 64 and d = 128 nets of the suite (no exact p): budgeted prover
runs whose unresolved frontier becomes OPEN, verified with N uniform samples
of the open union. The certified (SAFE) part of the cube is excluded
deductively, so the upper end of the interval is (Z / 2^d) * u with Z the
open mass, against u_MC from plain Monte Carlo with the same number of
forward-pass equivalents. Also reports the certified fraction by subcube
dimension.

Usage: python3 large_d.py [node_budget] [samples] -> results/large_d.json
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
from rareprob.nets_prover import CertNet, ProverConfig, prove, verify  # noqa: E402
from rareprob.stats import kl_interval  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
DELTA = 0.05


def main():
    budget = int(float(sys.argv[1])) if len(sys.argv) > 1 else 200_000
    N = int(float(sys.argv[2])) if len(sys.argv) > 2 else 200_000
    names = sys.argv[3:]
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    out_path = os.path.join(HERE, "results", "large_d.json")
    out = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for e in suite:
        name = e["name"]
        if e["d"] < 64 or (names and name not in names) or (not names and name in out):
            continue
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        cfg = ProverConfig(kinds=("lin",), r_leaf=5, node_budget=budget, budget_leaf="open", alpha_iters=40,
                           chunk=2048 if max(cn.widths) <= 64 else 128)
        t0 = time.time()
        arg, info = prove(cn, cfg)
        tp = time.time() - t0
        arg["samples"] = N
        res = verify(cn, arg, delta=DELTA, rng=np.random.default_rng(3))
        frac_open = res.Z / 2 ** cn.d
        # plain Monte Carlo with the same cost (forward-pass equivalents)
        n_mc = int(res.fpe)
        lo_mc, hi_mc = kl_interval(0.0, n_mc, DELTA)
        rec = {"d": cn.d, "widths": cn.widths, "loss": e["loss"], "z": e["z"], "node_budget": budget,
               "nodes": info.nodes, "leaves": res.leaves, "r_hist_certified": info.r_hist,
               "open_fraction": frac_open, "certified_fraction": 1 - frac_open - res.F / 2 ** cn.d,
               "samples": res.n_samples, "sample_fails": res.sample_fails, "lo": res.lo, "hi": res.hi,
               "fpe": res.fpe, "mc_same_cost_hi_if_no_fail": hi_mc, "prover_seconds": tp,
               "verify_seconds": res.seconds, "bytes": res.arg_bytes}
        out[name] = rec
        json.dump(out, open(out_path, "w"), indent=1, default=float)
        print(f"{name:26s} nodes {info.nodes} certified {rec['certified_fraction']:.3g} open {frac_open:.3g} "
              f"samples {res.n_samples} fails {res.sample_fails} -> p in [{res.lo:.3g}, {res.hi:.3g}] "
              f"fpe {res.fpe:.3g}; MC same cost (0 fails): p <= {hi_mc:.3g} | prover {tp:.0f}s", flush=True)


if __name__ == "__main__":
    main()
