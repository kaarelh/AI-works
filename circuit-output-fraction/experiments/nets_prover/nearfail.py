"""The near-failure count that a gap-limited certificate must pay for.

A subcube S of dimension r can be certified SAFE only if min_S f >= t + G,
where G >= 0 is the gap of the relaxation on S; so no point with
f(x) < t + G(r) lies in a SAFE leaf of dimension r. With G(r) the median
gap measured in gap_scan.py, a partition certificate whose SAFE leaves have
dimension about r needs at least about N(t + G(r)) / 2^r non-SAFE leaves of
dimension <= r, where N(s) = #{x : f(x) < s} = 2^d Pr[f < s]. This script
estimates Pr[f < t + g] by sampling (4 * 10^6 points) and evaluates
    leaves(r) = 2^d Pr[f < t + G(r)] / 2^r
for the nets of gap_scan.py, next to Monte Carlo's 1/p.

Usage: python3 nearfail.py  (needs results/gap_scan.json) -> results/nearfail.json
"""
import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import CertNet  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")


def main():
    gaps = json.load(open(os.path.join(HERE, "results", "gap_scan.json")))
    suite = {e["name"]: e for e in json.load(open(os.path.join(NETS, "suite.json")))}
    out = {}
    for name, rec in gaps.items():
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        rng = np.random.default_rng(5)
        vals = np.concatenate([cn.forward(rng.choice([-1.0, 1.0], size=(200000, cn.d))) for _ in range(20)])
        vals.sort()
        n = len(vals)
        res = {"d": cn.d, "p_exact": suite[name].get("p_exact"), "rows": []}
        for r, g in sorted(((int(k), v) for k, v in rec.items())):
            row = {"r": r}
            for kind in ("lin", "quad"):
                G = max(0.0, g[f"median_gap_{kind}"])
                q = np.searchsorted(vals, cn.t + G) / n
                row[f"G_{kind}"] = G
                row[f"pr_below_t_plus_G_{kind}"] = q
                row[f"log2_leaves_{kind}"] = math.log2(q) + cn.d - r if q > 0 else None
            res["rows"].append(row)
            print(f"{name:22s} r={r:2d} G_lin={row['G_lin']:.3f} Pr[f<t+G]={row['pr_below_t_plus_G_lin']:.3g} "
                  f"log2 leaves {row['log2_leaves_lin']} | G_quad={row['G_quad']:.3f} "
                  f"Pr={row['pr_below_t_plus_G_quad']:.3g} log2 leaves {row['log2_leaves_quad']}", flush=True)
        p = res["p_exact"]
        res["log2_mc"] = math.log2(3 * math.log(40) / (0.01 * p)) if p else None
        out[name] = res
    json.dump(out, open(os.path.join(HERE, "results", "nearfail.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
