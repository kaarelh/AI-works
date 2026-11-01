"""Fixed-level SMC lower bounds on the exact-p suite (experiments/nets, d <= 28).

For every net with p_exact and every budget (S, M, L), TRIALS independent
runs of nets_lower.lower_bound (pilot + R fixed-plan replicates, delta =
0.05); records the betting bound, the witness bound, the reported bound
(their maximum), the cost in fpe and seconds (pilot included), the
replicates Z_i, and the Monte Carlo yardsticks for the same ratio.

usage: python3 run_suite.py [--jobs J] [name-substring ...]   (appends to results/suite.jsonl)
"""

import os
import sys
import time

from common import (BUDGETS, DELTA, MOVES, RES, RHO, exact_suite, get_net, jobs_arg, load_rows,
                    mc_seconds_per_sample, run_parallel, seed_of, yardsticks)
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets_lower import lower_bound

TRIALS = 5
PATH = os.path.join(RES, "suite.jsonl")


def job(args):
    row, budget, trial = args
    N, R = BUDGETS[budget]
    net = get_net(row["name"])
    mc_sec = mc_seconds_per_sample(net)
    seed = seed_of("suite", row["name"], budget, trial)
    t = time.time()
    res = lower_bound(net, delta=DELTA, N=N, R=R, moves=MOVES, rho=RHO, rng=np.random.default_rng(seed))
    seconds = time.time() - t
    p = row["p_exact"]
    out = dict(name=row["name"], d=row["d"], widths=row["widths"], loss=row["loss"], step=row["step"], z=row["z"],
               p_exact=p, fail_count=row["fail_count"], budget=budget, N=N, R=R, moves=MOVES, rho=RHO, trial=trial,
               seed=seed, K=len(res.plan.levels), flips=res.plan.flips, evals_pilot=res.evals_pilot,
               evals_final=res.evals_final, evals=res.evals, seconds=round(seconds, 2),
               seconds_pilot=round(res.seconds_pilot, 2), mc_sec_per_sample=mc_sec, pilot_log10Z=res.pilot_log10Z,
               flagged=res.flagged, L=res.lower, L_bet=res.smc_lower, L_wit=res.witness_lower,
               n_wit=round(res.witness_lower * 2.0 ** row["d"]), Z=res.Z, miss=bool(res.lower > p))
    if p > 0:
        out.update(r_bet=res.smc_lower / p, r_wit=res.witness_lower / p, r=res.lower / p)
        out.update(yardsticks(p, res.smc_lower / p, res.evals, seconds, mc_sec))
    return out


def show(r):
    if r["p_exact"] == 0:
        return f"{r['name']:22s} {r['budget']} t{r['trial']} p=0 L={r['L']:.3g} evals={r['evals']:.3g} {r['seconds']}s"
    return (f"{r['name']:22s} {r['budget']} t{r['trial']} p={r['p_exact']:.3g} r_bet={r['r_bet']:.3f} "
            f"r_wit={r['r_wit']:.3f} evals={r['evals']:.3g} x{r['speedup_kl_fpe']:.3g} (fpe) "
            f"x{r['speedup_kl_sec']:.3g} (s) {r['seconds']}s")


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args)
    done = {(r["name"], r["budget"], r["trial"]) for r in load_rows(PATH)}
    jobs = [(row, b, t) for b in ("L", "M", "S") for row in exact_suite() for t in range(TRIALS)
            if (not args or any(q in row["name"] for q in args)) and (row["name"], b, t) not in done]
    run_parallel(job, jobs, PATH, n_jobs, show)


if __name__ == "__main__":
    main()
