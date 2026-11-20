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

"At most floor(rho n) steps differ from the human's" is the strongest rho-robust
property, so these rows measure the union of all rho-robust properties. We record
Theorem 1's own quantity, the expected number of rounds (on i.i.d. problems) whose run
loses the property, summed until every rule is known; and, as a cost measure, the first
round at which the failure probability is at most 2% (an oracle stopping rule).

Caveat: in E2 mistakes never change the content sequence, and the decoder's runs visit
the human's contents, so mistakes are placed by the permutation, independently of the
decoder: the favourable, random-placement regime.

Usage: python3 robust_runs.py OUTDIR
"""

import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from property_rules import NC, World  # noqa: E402


def run_ci(world, seed, rhos, eps):
    """Chained imitation until every rule is known (after that no run fails under any
    rho). Returns, for each rho, the first round at which the exact failure probability
    is at most eps, and the sum over rounds of the failure probability of the decoder in
    use: the expected number of rounds, on i.i.d. problems, whose run has more than
    floor(rho n) wrong steps (Theorem 1's quantity)."""
    rng = np.random.default_rng(seed)
    n = world.n
    traj_hold = world.hold[world.traj]  # (NC, n): rules firing at each step of each run
    all_rules = (1 << len(world.rules)) - 1
    known = 0
    reached = {rho: None for rho in rhos}
    bad_rounds = {rho: 0.0 for rho in rhos}
    r = 0
    while known != all_rules:
        r += 1
        wrong = ((traj_hold & ~known) != 0).sum(axis=1)  # wrong steps of every run
        for rho in rhos:
            f = float(np.mean(wrong > math.floor(rho * n)))
            bad_rounds[rho] += f  # this round's problem is fresh: Pr[bad round] = f
            if reached[rho] is None and f <= eps:
                reached[rho] = r - 1
        c0 = int(rng.integers(NC))
        j = int(rng.integers(n))
        known |= int(world.hold[world.traj[c0, j]])
    for rho in rhos:
        if reached[rho] is None:
            reached[rho] = r
    return reached, bad_rounds


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    rhos = [0.0, 0.05, 0.2]
    eps = 0.02
    humans, seeds = 40, 5
    summary = {}
    for n in [16, 64, 256]:
        rows = []
        for h in range(humans):
            world = World(seed=100 + h, n=n)  # the same 40 humans at every n
            for q in range(seeds):
                rows.append(run_ci(world, seed=7 + h + 1000 * q, rhos=rhos, eps=eps))
        for rho in rhos:
            first = np.array([row[0][rho] for row in rows], dtype=float)
            bad = np.array([row[1][rho] for row in rows], dtype=float)
            key = f"rho{rho}_n{n}"
            summary[key] = {
                "n": n, "rho": rho, "humans": humans, "query_seeds": seeds,
                "first_passage_mean": float(first.mean()),
                "first_passage_sem": float(first.std(ddof=1) / math.sqrt(len(first))),
                "first_passage_median": float(np.median(first)),
                "bad_rounds_mean": float(bad.mean()),
                "bad_rounds_sem": float(bad.std(ddof=1) / math.sqrt(len(bad))),
            }
            print(json.dumps(summary[key]))
            sys.stdout.flush()
    with open(os.path.join(outdir, "robust_runs_summary.json"), "w") as f:
        json.dump(summary, f, indent=1)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
