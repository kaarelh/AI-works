"""Witness stratification at small d: the pilot's witnesses S are removed from
the last level and added back exactly (|S|/2^d + SMC bound for the rest),
versus plain SMC and versus the witness list alone, at budget M.

usage: python3 run_stratified.py [--jobs J]   (writes results/stratified.jsonl)
"""

import os
import sys

from common import DELTA, RES, get_net, jobs_arg, run_parallel, seed_of, suite_rows
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets_lower import lower_bound  # noqa: E402

NAMES = ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d28_w64_s600", "mse_d28_w64_s1000"]
PATH = os.path.join(RES, "stratified.jsonl")


def job(name):
    p = {r["name"]: r for r in suite_rows()}[name]["p_exact"]
    net = get_net(name)
    rng = np.random.default_rng(seed_of("stratified", name))
    rows = []
    for trial in range(3):
        for strat in (False, True):
            res = lower_bound(net, delta=DELTA, N=1000, R=32, rng=rng, stratify=strat)
            rows.append(dict(name=name, p_exact=p, trial=trial, stratify=strat,
                             ratio_smc_part=(res.notes["stratum"] + res.smc_lower) / p,
                             ratio_witness=res.witness_lower / p, ratio_reported=res.lower / p,
                             stratum=res.notes["stratum"] / p, evals=res.evals, seconds=round(res.seconds, 2)))
    return rows


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args)
    open(PATH, "w").close()
    run_parallel(job, NAMES, PATH, n_jobs)


if __name__ == "__main__":
    main()
