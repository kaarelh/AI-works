"""Wall-clock comparison of exact counting by branch and bound with Monte
Carlo, measured in the same session (shared 4-core machine, so the numbers
are indicative): forward-pass equivalents hide that one fpe of branch and
bound costs more wall-clock time than one Monte Carlo sample.

For every one-hidden-layer suite net with an exact p:
  * Monte Carlo: seconds per sample (fresh uniform inputs, numpy forward pass
    and comparison, in chunks of 2^18), and the seconds Monte Carlo needs for
    ratio 1 + eps at eps = 0.1, delta = 0.05 (3 ln(2/delta) / (eps^2 p)
    samples);
  * branch and bound (CROWN, r_enum = 4, as exp_suite.py): the exact count is
    re-run here for the nets whose recorded cost is below 2e7 fpe, giving its
    seconds and seconds per fpe; for the others the recorded fpe is converted
    with the median seconds per fpe of the re-run nets of the same width.
Writes results/wallclock.json.
"""

import json
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_verify import Bounder, bab, mc_cost  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")


def mc_seconds_per_sample(net, n=1 << 22, chunk=1 << 18, seed=0):
    rng = np.random.default_rng(seed)
    t0 = time.time()
    hits = 0
    for s in range(0, n, chunk):
        X = rng.choice([-1.0, 1.0], size=(chunk, net.d))
        hits += int((net.forward(X) < net.threshold).sum())
    return (time.time() - t0) / n


def main():
    suite = [e for e in json.load(open(os.path.join(NETS, "suite.json")))
             if e.get("p_exact") is not None and len(e["widths"]) == 1]
    recorded = {o["name"]: o for o in json.load(open(os.path.join(OUT, "suite.json")))}
    rows = []
    for e in suite:
        net = load_net(os.path.join(NETS, e["name"] + ".npz"))
        bd = Bounder(net)
        rec = recorded[e["name"]]["exact_run"]
        r = dict(name=e["name"], d=e["d"], width=e["widths"][0], p=e["p_exact"], fail_count=e["fail_count"],
                 bab_fpe=rec["fpe"], bab_seconds_recorded=rec["seconds"])
        r["mc_s_per_sample"] = mc_seconds_per_sample(net)
        p = e["p_exact"]
        r["mc_samples"] = mc_cost(p, 0.1, 0.05) if p > 0 else None
        r["mc_seconds"] = r["mc_samples"] * r["mc_s_per_sample"] if p > 0 else None
        if rec["fpe"] < 2e7:
            t0 = time.time()
            res = bab(net, r_enum=4, min_rate=0.01, bounder=bd)
            r["bab_seconds"] = time.time() - t0
            r["bab_rerun_fpe"] = res.fpe
            r["bab_rerun_ambiguous"] = res.ambiguous
            r["bab_rerun_contains_count"] = bool(res.fail <= e["fail_count"] <= res.fail + res.ambiguous + res.undecided)
            r["bab_s_per_fpe"] = r["bab_seconds"] / res.fpe
        rows.append(r)
        print(json.dumps(r), flush=True)
    for r in rows:
        if "bab_s_per_fpe" not in r:
            same = [q["bab_s_per_fpe"] for q in rows if "bab_s_per_fpe" in q and q["width"] == r["width"]]
            ref = same or [q["bab_s_per_fpe"] for q in rows if "bab_s_per_fpe" in q]
            r["bab_s_per_fpe_estimated"] = float(np.median(ref))
            r["bab_seconds"] = r["bab_fpe"] * r["bab_s_per_fpe_estimated"]
        if r["mc_seconds"] is not None:
            r["mc_over_bab_fpe"] = r["mc_samples"] / r["bab_fpe"]
            r["mc_over_bab_seconds"] = r["mc_seconds"] / r["bab_seconds"]
            r["wallclock_factor"] = r["mc_over_bab_fpe"] / r["mc_over_bab_seconds"]
    json.dump(dict(note="seconds are wall-clock on a shared 4-core machine; eps = 0.1, delta = 0.05", rows=rows),
              open(os.path.join(OUT, "wallclock.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
