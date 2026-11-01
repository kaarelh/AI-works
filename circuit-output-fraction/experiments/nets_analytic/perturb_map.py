"""Certified perturb-and-MAP upper bounds on p for the suite nets (d <= 28),
with an exact MAP oracle by enumeration (rareprob.nets_analytic.EnumMAPOracle).

For each net: a pilot run (independent random numbers) estimates
theta t + E R for theta in a grid and Gumbel block sizes (d = 24: theta in
{5, ..., 160}, blocks {1, 2, 4, 6}, 30 pilot samples each, 1000 final samples;
d = 28: theta in {10, ..., 160}, blocks {4, 7}, 8 pilot samples each, 300
final samples); the best configuration (by the pilot's estimate of the
certified value) is then run with fresh samples and certified by
perturb_map_bound (Maurer-Pontil empirical Bernstein, delta = 0.05). The
certified U holds with probability >= 1 - delta for every net, given a MAP
oracle that returns upper bounds of the perturbed maxima.

Cost accounting: each sample is one MAP call. Here the oracle is enumeration
(2^d forward-pass equivalents, so the whole procedure is far more expensive
than computing p exactly); the point is the quality of the bound a MAP-oracle
method can certify, and the number of oracle calls it needs. For d > 30 the
oracle would be a complete MILP / branch-and-bound solver (map_cost.py
measures what such calls cost).

Usage: python3 perturb_map.py [names...]   (default: the d = 24 nets).
Output: results/perturb_map.json"""

import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
DELTA = 0.05


def run(name, p, thetas=(5.0, 10.0, 20.0, 40.0, 80.0, 160.0), blocks=(1, 2, 4, 6), n_pilot=30, n_final=1000,
        seed=0):
    net = load_net(os.path.join(NETS, name + ".npz"))
    t0 = time.time()
    orc = na.EnumMAPOracle(net, np.float64 if net.d <= 24 else np.float32)
    t_table = time.time() - t0
    rng_pilot = np.random.default_rng(seed)
    pilot = []
    for th in thetas:
        for blk in blocks:
            R = na.perturb_map_samples(orc, th, blk, n_pilot, rng_pilot)
            # pilot score: estimate of the certified log bound at n_final
            B = th * (orc.Fmax - orc.Fmin)
            L = math.log(2 / DELTA)
            pen = math.sqrt(2 * R.var(ddof=1) * L / n_final) + 7 * L * B / (3 * (n_final - 1))
            pilot.append({"theta": th, "block": blk, "est": th * net.threshold + float(R.mean()),
                          "score": th * net.threshold + float(R.mean()) + pen})
    best = min(pilot, key=lambda q: q["score"])
    t1 = time.time()
    bd = na.perturb_map_bound(orc, best["theta"], best["block"], n_final, DELTA, np.random.default_rng(seed + 1))
    rec = {"name": name, "p": p, "d": net.d, "U": bd.value, "log_U": bd.log_value,
           "log_p": math.log(p) if p else None, "theta": best["theta"], "block": best["block"],
           "n_final": n_final, "map_calls": n_final + len(pilot) * n_pilot, "R_mean": bd.params["R_mean"],
           "R_sd": bd.params["R_sd"], "est_log_bound": best["theta"] * net.threshold + bd.params["R_mean"],
           "fmin": orc.Fmin, "fmax": orc.Fmax, "pilot": pilot, "seconds_table": t_table,
           "seconds_pilot": t1 - t0 - t_table, "seconds_final": time.time() - t1}
    rec["U_over_p"] = bd.value / p if p else None
    rec["bits_explained"] = (-bd.log_value / math.log(2), -math.log2(p) if p else float("inf"))
    return rec


if __name__ == "__main__":
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    names = sys.argv[1:] or [e["name"] for e in suite if e["d"] <= 24]
    out_path = os.path.join(HERE, "results", "perturb_map.json")
    res = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for nm in names:
        e = next(x for x in suite if x["name"] == nm)
        kw = {} if e["d"] <= 24 else {"thetas": (10.0, 20.0, 40.0, 80.0, 160.0), "blocks": (4, 7), "n_pilot": 8,
                                      "n_final": 300}
        r = run(nm, e.get("p_exact"), **kw)
        res[nm] = r
        print(json.dumps({k: v for k, v in r.items() if k != "pilot"}), flush=True)
        with open(out_path, "w") as f:
            json.dump(res, f, indent=1)
