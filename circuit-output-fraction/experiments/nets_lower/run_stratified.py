"""Witness stratification at small d: the pilot's witnesses S are removed from
the last level and added back exactly (|S|/2^d + SMC bound for the rest),
versus plain SMC and versus the witness list alone (writes results/stratified.jsonl)."""

import json
import os
import sys

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_lower import lower_bound  # noqa: E402

NAMES = ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d28_w64_s600", "mse_d28_w64_s1000"]


def main():
    suite = {r["name"]: r for r in json.load(open(os.path.join(HERE, "..", "nets", "suite.json")))}
    rng = np.random.default_rng(17)
    with open(os.path.join(HERE, "results", "stratified.jsonl"), "w") as f:
        for name in NAMES:
            p = suite[name]["p_exact"]
            net = load_net(os.path.join(HERE, "..", "nets", name + ".npz"))
            for trial in range(3):
                for strat in (False, True):
                    res = lower_bound(net, N=1000, R=32, rng=rng, stratify=strat)
                    row = dict(name=name, p_exact=p, trial=trial, stratify=strat,
                               ratio_smc_part=(res.notes["stratum"] + res.smc_lower) / p,
                               ratio_witness=res.witness_lower / p, ratio_reported=res.lower / p,
                               stratum=res.notes["stratum"] / p, evals=res.evals_pilot + res.evals_final)
                    print(json.dumps(row), flush=True)
                    f.write(json.dumps(row) + "\n")


if __name__ == "__main__":
    main()
