"""Experiment E4: fragile and robust properties of the same runs.

The human of E2 (property_rules.py): rules triggered by conjunctions of literals on a
12-bit content, two rules of each size 1..9. The decoder's run is the human's process
with corrupted steps: at a step where a rule it does not know fires, it writes the
wrong notes; everywhere else it does what the human would do from the current state.

We train the decoder by chained imitation (one task query at a uniformly random step of
each run) and measure, exactly over all 4096 problems, the failure probability under
three notions of success for the same runs:

  rho = 0     every step right (the property "the run is the human's run");
  rho = 0.05  at most 5% of the run's steps wrong;
  rho = 0.2   at most 20% of the run's steps wrong.

The second and third are properties that survive a small fraction of corrupted steps.
The note's Theorem 1 bounds chained imitation's failures under rho > 0 by K/rho, with
no factor n.

Usage: python3 robust_runs.py OUTDIR
"""

import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from property_rules import NC, World  # noqa: E402


def run_ci(world, seed, rhos, max_runs, eps):
    rng = np.random.default_rng(seed)
    n = world.n
    traj_hold = world.hold[world.traj]  # (NC, n): rules firing at each step of each run
    known = 0
    reached = {rho: None for rho in rhos}
    for r in range(1, max_runs + 1):
        c0 = int(rng.integers(NC))
        j = int(rng.integers(n))
        known |= int(world.hold[world.traj[c0, j]])
        wrong = ((traj_hold & ~known) != 0).sum(axis=1)  # wrong steps of every run
        for rho in rhos:
            if reached[rho] is None and np.mean(wrong > math.floor(rho * n)) <= eps:
                reached[rho] = r
        if all(v is not None for v in reached.values()):
            break
    return reached


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    rhos = [0.0, 0.05, 0.2]
    eps = 0.02
    summary = {}
    for n in [16, 64, 256]:
        rows = []
        for s in range(40):
            world = World(seed=100 + s, n=n)
            rows.append(run_ci(world, seed=7 + s, rhos=rhos, max_runs=20000, eps=eps))
        for rho in rhos:
            vals = [row[rho] for row in rows if row[rho] is not None]
            key = f"rho{rho}_n{n}"
            summary[key] = {
                "n": n, "rho": rho, "humans": len(rows), "reached": len(vals),
                "task_mean": float(np.mean(vals)) if vals else None,
                "task_sem": float(np.std(vals, ddof=1) / math.sqrt(len(vals))) if len(vals) > 1 else None,
                "task_median": float(np.median(vals)) if vals else None,
            }
            print(json.dumps(summary[key]))
            sys.stdout.flush()
    with open(os.path.join(outdir, "robust_runs_summary.json"), "w") as f:
        json.dump(summary, f, indent=1)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
