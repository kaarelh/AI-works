"""Certifying p = 0 (complete verification over the cube) as a function of d.

Nets: one hidden layer of width 32 trained to output 1 on uniform +-1
inputs, squared loss (event f < 1/2) at d = 12 ... 64 and logistic loss
(event logit < 0) at d = 16 ... 40, several training lengths and seeds;
plus short training (300, 600 steps, squared loss, d = 12 ... 28), where
p > 0 is typical, to see how the exact count's tree grows with d.
For each net, input branch and bound with CROWN bounds and enumeration of
subcubes with <= 6 free coordinates, run to completion or to a time limit:
it returns the exact failure count (p = 0 certified when it is 0) or a
valid interval. For d <= 24 the count is checked against the
meet-in-the-middle enumeration. When p > 0 is counted exactly, the size of
the tree a perfect engine would need (oracle_tree_static) and the Monte Carlo
cost are recorded too. Writes results/zero.json.
"""

import json
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import exact_failure_count, train_constant  # noqa: E402
from rareprob.nets_verify import Bounder, bab, mc_cost, oracle_tree_static  # noqa: E402

OUT = os.path.join(HERE, "results")
os.makedirs(OUT, exist_ok=True)


def jobs():
    for d in [12, 16, 20, 24, 28, 32]:
        for steps in [1000, 1500, 2000, 4000, 8000]:
            for seed in range(3 if d <= 24 else 2):
                yield ("mse", d, steps, seed)
    for d in [40, 48, 64]:
        for steps in [3000, 8000, 16000]:
            yield ("mse", d, steps, 0)
    for d in [16, 24, 32, 40]:
        for steps in [300, 1000, 3000]:
            for seed in range(2 if d <= 24 else 1):
                yield ("bce", d, steps, seed)
    # shorter training (p > 0 typical): how the exact count's tree grows with d
    for d in [12, 16, 20, 24, 28]:
        for steps in [300, 600]:
            for seed in range(2 if d <= 24 else 1):
                yield ("mse", d, steps, seed)


def main(limit_d=None):
    path = os.path.join(OUT, "zero.json")
    out = json.load(open(path)) if os.path.exists(path) else []
    done = {(o["loss"], o["d"], o["steps"], o["seed"]) for o in out}
    for loss, d, steps, seed in jobs():
        if (loss, d, steps, seed) in done or (limit_d and d > limit_d):
            continue
        rng = np.random.default_rng(7919 * d + seed + (0 if loss == "mse" else 100000))
        net, _ = train_constant(d, [32], steps, rng, loss=loss)
        X = rng.choice([-1.0, 1.0], size=(100000, d))
        f = net.forward(X)
        z = float((f.mean() - net.threshold) / f.std())
        bd = Bounder(net)
        tl = 600.0
        col = []
        res = bab(net, r_enum=6, min_rate=0.01, time_limit=tl, bounder=bd, collect=col)
        S = res.summary()
        # certified fraction of the bounded nodes per level (free coordinates r)
        S["cert_rate_by_free"] = {lv["free"]: round((lv.get("safe", 0) + lv.get("fail", 0)) / lv["bounded"], 4)
                                  for lv in res.levels if lv.get("bounded")}
        o = dict(loss=loss, d=d, steps=steps, seed=seed, z=z, t=bd.t, f0=float(bd.forward(np.zeros((1, d)))[0]),
                 mc_min=float(f.min()), bab=S, full_enum_fpe=bd.full_enum_flops() / bd.flops_forward,
                 p_zero_certified=bool(res.exact and res.fail == 0), p_positive_certified=bool(res.fail > 0))
        if res.exact and res.fail > 0 and not res.fail_cubes:
            X = np.concatenate(col)
            o["F"] = int(res.fail)
            o["oracle_tree_nodes"] = oracle_tree_static(X, d)["nodes"]
            o["mc_samples"] = mc_cost(res.fail / 2.0 ** d, 0.1, 0.05)
        if d <= 24:
            o["enum_count"] = exact_failure_count(net)
            assert res.fail <= o["enum_count"] <= res.fail + res.ambiguous + res.undecided
        print(json.dumps({k: v for k, v in o.items() if k != "bab"}),
              dict(fail=S["fail"], exact=S["exact"], fpe="%.3g" % S["fpe"], s=S["seconds"], hi=S["hi"]), flush=True)
        out.append(o)
        json.dump(out, open(path, "w"), indent=1)


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else None)
