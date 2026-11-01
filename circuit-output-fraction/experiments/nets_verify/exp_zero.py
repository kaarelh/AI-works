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
cost are recorded too. Costs: forward-pass equivalents (fpe) and wall-clock
seconds (shared 4-core machine). Writes results/zero.json (one record per
net) and results/zero_summary.json (frequency and cost by d).
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


def summarize():
    """results/zero_summary.json: per loss, d and training regime, how many
    nets have p = 0 certified, p > 0 counted exactly or stay open, and the
    cost of the runs that certify p = 0 (fpe and wall-clock seconds; medians
    and ranges). 'long' training is >= 1000 steps (squared loss) or >= 300
    (logistic loss), 'short' the 300 and 600 step squared-loss runs."""
    rows = json.load(open(os.path.join(OUT, "zero.json")))
    groups = {}
    for o in rows:
        regime = "short" if (o["loss"] == "mse" and o["steps"] < 1000) else "long"
        groups.setdefault((regime, o["loss"], o["d"]), []).append(o)
    table = []
    for (regime, loss, d), os_ in sorted(groups.items()):
        z = [o for o in os_ if o["p_zero_certified"]]
        pos = [o for o in os_ if o["bab"]["exact"] and o["bab"]["fail"] > 0]
        fpe = sorted(o["bab"]["fpe"] for o in z)
        sec = sorted(o["bab"]["seconds"] for o in z)
        table.append(dict(regime=regime, loss=loss, d=d, nets=len(os_), p_zero_certified=len(z),
                          p_positive_exact=len(pos), open=len(os_) - len(z) - len(pos),
                          root_certified=sum(o["bab"]["nodes_total"] == 1 for o in z),
                          fpe_median=float(np.median(fpe)) if fpe else None,
                          fpe_range=[fpe[0], fpe[-1]] if fpe else None,
                          seconds_median=float(np.median(sec)) if sec else None,
                          seconds_range=[sec[0], sec[-1]] if sec else None,
                          full_enum_fpe=os_[0]["full_enum_fpe"],
                          open_runs=[dict(steps=o["steps"], seed=o["seed"], hi=o["bab"]["hi"], fpe=o["bab"]["fpe"],
                                          seconds=o["bab"]["seconds"], stopped=o["bab"]["stopped"])
                                     for o in os_ if not o["bab"]["exact"]]))
    long_ = [o for o in rows if not (o["loss"] == "mse" and o["steps"] < 1000)]
    totals = dict(long_nets=len(long_), long_p_zero=sum(o["p_zero_certified"] for o in long_),
                  long_p_positive_exact=sum(o["bab"]["exact"] and o["bab"]["fail"] > 0 for o in long_),
                  long_open=sum(not o["bab"]["exact"] for o in long_))
    out = dict(note="one hidden layer of width 32; B&B with CROWN, r_enum = 6, time limit 600 s per net; "
                    "fpe = forward-pass equivalents; seconds = wall-clock on a shared 4-core machine",
               totals=totals, table=table)
    json.dump(out, open(os.path.join(OUT, "zero_summary.json"), "w"), indent=1)
    print(json.dumps(totals))
    return out


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
            if not res.fail <= o["enum_count"] <= res.fail + res.ambiguous + res.undecided:
                raise RuntimeError(f"interval does not contain the enumerated count: {loss} d={d} steps={steps}")
        print(json.dumps({k: v for k, v in o.items() if k != "bab"}),
              dict(fail=S["fail"], exact=S["exact"], fpe="%.3g" % S["fpe"], s=S["seconds"], hi=S["hi"]), flush=True)
        out.append(o)
        json.dump(out, open(path, "w"), indent=1)


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else None)
    summarize()
