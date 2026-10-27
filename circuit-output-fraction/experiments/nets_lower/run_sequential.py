"""Cost of reaching a target ratio: anytime-valid sequential SMC lower bounds.

For each net, replicates (N = 1000, after a pilot) are added until the
betting bound is at least `target` times the running mean of the replicates
(at most R_MAX); the reported bound is the running maximum, valid by
Ville's inequality. The achieved ratio is measured against the exact p (or
against p_ref for the scaling nets), and the cost against the Monte Carlo
samples needed for the same ratio.

usage: python3 run_sequential.py [--quick] [name-substring ...]   (writes results/sequential.jsonl)
"""

import json
import os
import sys
import time

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_lower import lower_bound, mc_lower_samples  # noqa: E402

OUT = os.path.join(HERE, "results")
NETS = os.path.join(HERE, "..", "nets")
DELTA = 0.05
R_MAX = 512
TARGETS = (0.8, 0.9)
TRIALS = 3


def nets():
    for r in json.load(open(os.path.join(NETS, "suite.json"))):
        if r.get("p_exact", 0) > 0 and r["p_exact"] < 1e-3:
            yield r["name"], os.path.join(NETS, r["name"] + ".npz"), r["p_exact"], "exact"
    path = os.path.join(OUT, "scaling.jsonl")
    if os.path.exists(path):
        for line in open(path):
            r = json.loads(line)
            if r["kind"] == "ref" and r["p_ref"] > 0:
                f = (os.path.join(NETS, r["name"][len("suite_"):] + ".npz") if r["name"].startswith("suite_")
                     else os.path.join(OUT, "scaling_nets", r["name"] + ".npz"))
                yield r["name"], f, r["p_ref"], "ref"


def main():
    global TARGETS, TRIALS
    pats = sys.argv[1:]
    if "--quick" in pats:  # one target (0.9) and two trials
        pats.remove("--quick")
        TARGETS, TRIALS = (0.9,), 2
    path = os.path.join(OUT, "sequential.jsonl")
    done = set()
    if os.path.exists(path):
        for line in open(path):
            r = json.loads(line)
            done.add((r["name"], r["target"], r["trial"]))
    rng = np.random.default_rng(31)
    for name, f, p, kind in nets():
        if pats and not any(q in name for q in pats):
            continue
        net = load_net(f)
        for tg in TARGETS:
            for trial in range(TRIALS):
                if (name, tg, trial) in done:
                    continue
                t = time.time()
                res = lower_bound(net, delta=DELTA, N=1000, R=R_MAX, moves=10, rho=0.2, rng=rng, target_ratio=tg)
                evals = res.evals_pilot + res.evals_final
                ratio = res.smc_lower / p
                row = dict(name=name, p=p, p_kind=kind, d=net.d, target=tg, trial=trial, R=len(res.Z), evals=evals,
                           L=res.smc_lower, ratio=ratio, L_wit=res.witness_lower,
                           mc_samples_same_ratio=mc_lower_samples(p, min(ratio, 0.999), DELTA) if ratio > 0 else 0,
                           seconds=round(time.time() - t, 1))
                row["speedup_vs_mc"] = row["mc_samples_same_ratio"] / evals
                with open(path, "a") as fh:
                    fh.write(json.dumps(row) + "\n")
                print(f"{name:24s} p={p:.3g} target={tg} R={row['R']} ratio={ratio:.3f} evals={evals:.3g} "
                      f"x{row['speedup_vs_mc']:.3g} {row['seconds']}s", flush=True)


if __name__ == "__main__":
    main()
