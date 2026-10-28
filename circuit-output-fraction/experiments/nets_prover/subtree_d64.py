"""Real, verified certificates for random pieces of the d = 64 nets, and the
cost of a whole certificate estimated from them (Knuth / Purdom partial
backtracking: unbiased for the uncollapsed tree).

For a net and a depth k: follow the prover's own splitting rule from the
root along a uniformly random path for k steps (stopping early if a node is
certified), then build the complete argument for the subcube reached
(prove(root=...)) and check it with verify(root=...). The piece is exactly
certified when the verifier returns an exact result. The whole-cube cost is
estimated as 2^k times the verified cost of the piece (plus the splits on the
path), averaged over the paths; the number of failing points found in the
pieces is reported too (exact, no sampling).

Usage: python3 subtree_d64.py [paths] [names...] -> results/subtree_d64.json
       (SUBTREE_TAG=x writes results/subtree_d64_x.json)
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
from rareprob.nets_prover import CertNet, ProverConfig, prove, verify, _choose_split  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
# net -> depth k of the random path (chosen so that a piece has ~1e5 nodes
# according to the Knuth estimates in knuth_suite.json)
PLAN = {"bce_d64_w64_s1000": 8, "bce_d64_w64_s300": 17, "bce_d64_w64_s100": 29,
        "mse_d64_w64_s3000": 31, "mse_d64_w64_s1000": 40}


def main():
    paths = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    names = sys.argv[2:] or list(PLAN)
    tag = os.environ.get("SUBTREE_TAG")
    out_path = os.path.join(HERE, "results", f"subtree_d64{'_' + tag if tag else ''}.json")
    out = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for name in names:
        k = PLAN[name]
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        rng = np.random.default_rng(17)
        cfg = ProverConfig(kinds=("lin",), r_leaf=5, node_budget=600_000, budget_leaf="open")
        recs = []
        for path in range(paths):
            x0 = np.zeros(cn.d)
            path_cost = 0.0
            depth = 0
            ended = None
            for step in range(k):
                ivs, c, c_abs = cn.intervals(x0[None])
                if cn.check_lin(x0[None], None, 1, ivs)[0] >= cn.t:
                    ended = "certified on the path"
                    break
                v = int(_choose_split(cn, x0[None], ivs, cfg.strong_k)[0])
                path_cost += 2.0 ** depth * cn.flops_node()
                x0[v] = rng.choice([-1.0, 1.0])
                depth += 1
            t0 = time.time()
            arg, info = prove(cn, cfg, root=x0)
            tp = time.time() - t0
            res = verify(cn, arg, rng=np.random.default_rng(path), root=x0)
            est = (path_cost + 2.0 ** depth * res.fpe * cn.fpe_flops) / cn.fpe_flops
            recs.append({"depth": depth, "ended": ended, "r": int((x0 == 0).sum()), "nodes": info.nodes,
                         "exact": res.exact, "F": res.F, "Z_open": res.Z, "fpe": res.fpe, "leaves": res.leaves,
                         "demoted": res.demoted, "prover_seconds": tp, "verify_seconds": res.seconds,
                         "estimate_whole_fpe": est, "budget_hit": info.budget_hit})
            print(f"{name:20s} path {path}: depth {depth} piece r={recs[-1]['r']} nodes {info.nodes} "
                  f"exact {res.exact} F {res.F} open {res.Z} fpe {res.fpe:.3g} -> whole cube ~{est:.3g} fpe "
                  f"(prover {tp:.0f}s, verify {res.seconds:.0f}s)", flush=True)
        ests = [r["estimate_whole_fpe"] for r in recs]
        out[name] = {"k": k, "paths": recs, "estimate_mean_fpe": float(np.mean(ests)),
                     "estimate_geomean_fpe": float(np.exp(np.mean(np.log(ests)))),
                     "all_exact": all(r["exact"] for r in recs), "F_found": sum(r["F"] for r in recs)}
        json.dump(out, open(out_path, "w"), indent=1, default=float)
        print(f"{name}: whole-cube estimate mean {np.mean(ests):.3g} fpe (geomean "
              f"{out[name]['estimate_geomean_fpe']:.3g}), all pieces exact: {out[name]['all_exact']}", flush=True)


if __name__ == "__main__":
    main()
