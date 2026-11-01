"""Cost of reaching a target ratio: anytime-valid sequential SMC lower bounds.

For each net, replicates (N = 1000, after a pilot) are added until the
betting bound is at least `target` times the running mean of the replicates
(at most R_MAX); the reported bound is the running maximum, valid by Ville's
inequality. Nets: the exact suite with 0 < p < 1e-3 (targets 0.8 and 0.9) and
the d >= 32 nets with p_ref > 0 and reference relative variance <= 1 (target
0.9). The achieved ratio is measured against the exact p (exact suite,
and the d = 32 net enumerated in exact_d32.json) or against p_ref
(results/scaling.jsonl), and the cost against Monte Carlo for the same ratio.

usage: python3 run_sequential.py [--jobs J] [name-substring ...]   (appends to results/sequential.jsonl)
"""

import json
import os
import sys
import time

from common import (DELTA, MOVES, RES, RHO, exact_suite, get_net, jobs_arg, load_rows, mc_seconds_per_sample,
                    run_parallel, seed_of, yardsticks)
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets_lower import lower_bound

PATH = os.path.join(RES, "sequential.jsonl")
R_MAX = 512


def targets():
    """(name, p, kind of p, targets, trials)."""
    out = [(r["name"], r["p_exact"], "exact", (0.8, 0.9), 3) for r in exact_suite() if 0 < r["p_exact"] < 1e-3]
    exact = {}
    if os.path.exists(os.path.join(RES, "exact_d32.json")):
        e = json.load(open(os.path.join(RES, "exact_d32.json")))
        exact[e["name"]] = e["p_exact"]
    for r in load_rows(os.path.join(RES, "scaling.jsonl")):
        # far-tail nets (reference relvar > 1) would run to R_MAX without stopping: their
        # fixed-budget runs (run_scaling.py) already show the failure mode
        if r["kind"] == "ref" and r["p_ref"] > 0 and r["ref_relvar"] <= 1:
            p, kind = (exact[r["name"]], "exact") if r["name"] in exact else (r["p_ref"], "ref")
            out.append((r["name"], p, kind, (0.9,), 2))
    return out


def job(args):
    name, p, kind, target, trial = args
    net = get_net(name)
    mc_sec = mc_seconds_per_sample(net)
    seed = seed_of("sequential", name, target, trial)
    t = time.time()
    res = lower_bound(net, delta=DELTA, N=1000, R=R_MAX, moves=MOVES, rho=RHO, rng=np.random.default_rng(seed),
                      target_ratio=target)
    seconds = time.time() - t
    ratio = res.smc_lower / p
    return dict(name=name, p=p, p_kind=kind, d=net.d, target=target, trial=trial, seed=seed, R=len(res.Z),
                stopped=bool(len(res.Z) < R_MAX), evals=res.evals, seconds=round(seconds, 2), mc_sec_per_sample=mc_sec,
                L=res.smc_lower, ratio=ratio, L_wit=res.witness_lower, flagged=res.flagged,
                **yardsticks(p, ratio, res.evals, seconds, mc_sec))


def show(r):
    return (f"{r['name']:26s} p={r['p']:.3g} target={r['target']} R={r['R']} ratio={r['ratio']:.3f} "
            f"evals={r['evals']:.3g} {r['seconds']}s x{r['speedup_kl_fpe']:.3g} (fpe)")


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args)
    done = {(r["name"], r["target"], r["trial"]) for r in load_rows(PATH)}
    jobs = [(n, p, k, tg, tr) for n, p, k, tgs, trials in targets() for tg in tgs for tr in range(trials)
            if (not args or any(q in n for q in args)) and (n, tg, tr) not in done]
    jobs.sort(key=lambda j: -get_net(j[0]).d)
    run_parallel(job, jobs, PATH, n_jobs, show)


if __name__ == "__main__":
    main()
