"""Prover + verifier on the nets of experiments/nets/suite.json with exact p
(d <= 28): an exact certificate (no open leaf) and a hybrid argument (open
leaves sampled to ratio ~1 + eps), each checked by `verify`; compared with
the exact failure count, with Monte Carlo (3 ln(2/delta) / (eps^2 p)
samples of 1 fpe each) and with meet-in-the-middle enumeration of the whole
cube by the verifier.

Usage: python3 run_suite.py [kinds] [r_leaf] [node_budget] [names...]
   kinds = lin | lin+quad  -> results/suite_<kinds>.json (merged per net; with the
   environment variable SUITE_TAG=x the file is results/suite_<kinds>_x.json)
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

NETS = os.path.join(HERE, "..", "nets")
EPS, DELTA = 0.1, 0.05


def main():
    kinds = tuple(sys.argv[1].split("+")) if len(sys.argv) > 1 else ("lin",)
    r_leaf = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    budget = int(float(sys.argv[3])) if len(sys.argv) > 3 else 1_000_000
    names = sys.argv[4:]
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    tag = os.environ.get("SUITE_TAG")
    out_path = os.path.join(HERE, "results", f"suite_{'+'.join(kinds)}{'_' + tag if tag else ''}.json")
    out = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for e in suite:
        name = e["name"]
        if e.get("p_exact") is None or (names and name not in names) or (not names and name in out):
            continue
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        Fsuite = int(e["fail_count"])
        p = e["p_exact"]
        cfg = ProverConfig(kinds=kinds, r_leaf=r_leaf, node_budget=budget, open_policy="both", eps=EPS,
                           delta=DELTA, quad_rmin=6, quad_iters=200)
        t0 = time.time()
        arg, info = prove(cn, cfg)
        tp = time.time() - t0
        rng = np.random.default_rng(7)
        res = verify(cn, arg, delta=DELTA, rng=rng)
        rec = {"d": e["d"], "widths": e["widths"], "loss": e["loss"], "z": e["z"], "p_exact": p,
               "fail_count_suite": Fsuite, "prover_seconds": tp, "budget_hit": info.budget_hit,
               "precollapse": info.precollapse, "kinds": "+".join(kinds), "r_leaf": r_leaf, "node_budget": budget,
               "mc_fpe": 3 * math.log(2 / DELTA) / (EPS ** 2 * p) if p > 0 else math.inf,
               "enum_full_fpe": cn.flops_enum(cn.d) / cn.fpe_flops,
               "exact": {"F": res.F, "match_suite": res.F == Fsuite, "exact": res.exact, "lo": res.lo,
                         "hi": res.hi, "nodes": info.nodes, "leaves": res.leaves, "demoted": res.demoted,
                         "fpe": res.fpe, "flops_fpe": {k: v / cn.fpe_flops for k, v in res.flops.items()},
                         "bytes": res.arg_bytes, "verify_seconds": res.seconds, "r_hist": info.r_hist,
                         "predicted_fpe": info.predicted_fpe}}
        if "hybrid" in arg:
            h = arg["hybrid"]
            hres = verify(cn, h, delta=DELTA, rng=rng)
            rec["hybrid"] = {"lo": hres.lo, "hi": hres.hi, "ratio": hres.ratio, "contains_p": hres.contains(p),
                             "F_exact_part": hres.F, "Z_open": hres.Z, "samples": hres.n_samples,
                             "sample_fails": hres.sample_fails, "nodes": info.hybrid.nodes, "leaves": hres.leaves,
                             "fpe": hres.fpe, "flops_fpe": {k: v / cn.fpe_flops for k, v in hres.flops.items()},
                             "bytes": hres.arg_bytes, "open_fails_prover": info.hybrid.open_fails}
        out = json.load(open(out_path)) if os.path.exists(out_path) else {}  # merge with concurrent runs
        out[name] = rec
        json.dump(out, open(out_path, "w"), indent=1, default=float)
        hy = rec.get("hybrid")
        print(f"{name:24s} p={p:.3g} F={res.F} (suite {Fsuite}) exact-cert fpe {res.fpe:.3g} nodes {info.nodes} "
              f"bytes {res.arg_bytes:.3g} | hybrid fpe {hy['fpe'] if hy else float('nan'):.3g} ratio "
              f"{hy['ratio'] if hy else float('nan'):.3f} ok {hy['contains_p'] if hy else None} | MC {rec['mc_fpe']:.3g} "
              f"enum {rec['enum_full_fpe']:.3g} | prover {tp:.0f}s budget_hit {info.budget_hit}", flush=True)


if __name__ == "__main__":
    main()
