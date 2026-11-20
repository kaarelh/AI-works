"""Experiment E1: the hidden-insight class of Theorem 3.

A human knows, for each of m problems p, a step t_p (or "never") at which it has an
insight, and the content k_p of the insight. Its run on p copies the insight forward
once it has occurred. A learner that has not located t_p cannot reproduce the run.

The posterior factorises over problems, so every protocol can be simulated exactly.
We compare four protocols:

  CI  chained imitation (the slides' protocol): one task query at a uniformly random
      step of each run;
  US  uncertainty sampling: a task query at every step of a run whose predictive
      probability of being wrong is at least gamma;
  CS  check and scan: one final check per run; on a failure, task queries along the
      run from the start until the first mistake;
  MB  monitored imitation with bisection: one final check per run; on a failure,
      binary search with checks for the step where the monitor flips, then one task
      query there.

For each protocol we record, after every run, the cumulative numbers of task queries
and checks and the exact failure probability of the current decoder on a fresh
uniformly random problem.

Usage: python3 hidden_insights.py OUTDIR
"""

import json
import os
import sys

import numpy as np


def sample_truth(rng, m, n, eta):
    triggered = rng.random(m) < eta
    t = np.where(triggered, rng.integers(0, n, size=m), n)  # n means "never"
    return t


def run_protocol(name, rng, t, n, eta, max_runs, eps_stop, gamma=None):
    m = len(t)
    found = np.zeros(m, dtype=bool)
    excluded = [set() for _ in range(m)]
    triggered = t < n
    n_unfound = int(triggered.sum())
    task = 0
    checks = 0
    log = []  # (runs, task, checks, failure)

    def failure():
        return n_unfound / m

    log.append((0, 0, 0, failure()))
    for r in range(1, max_runs + 1):
        p = rng.integers(m)
        if name == "CI":
            k = int(rng.integers(n))
            task += 1
            # The imitator's state at step k is (p, k, None) unless it has found the
            # insight and passed it; then the query carries no information.
            if not found[p]:
                if k == t[p]:
                    found[p] = True
                    n_unfound -= 1
                else:
                    excluded[p].add(k)
        elif name == "US":
            # The predictive probability of a hit at an untested step, given the set S
            # of excluded steps, is (eta/n)/(1 - eta|S|/n); it is the same at every
            # untested step and grows with S, so once above gamma it stays above.
            if not found[p]:
                S = excluded[p]
                if (eta / n) / (1.0 - eta * len(S) / n) >= gamma:
                    for k in range(n):
                        if k in S:
                            continue
                        task += 1
                        if k == t[p]:
                            found[p] = True
                            n_unfound -= 1
                            break
                        S.add(k)
        elif name == "CS":
            checks += 1
            if triggered[p] and not found[p]:
                # scan from the start, skipping positions already known not to be t_p
                for k in range(n):
                    if k in excluded[p]:
                        continue
                    task += 1
                    if k == t[p]:
                        break
                    excluded[p].add(k)
                found[p] = True
                n_unfound -= 1
                checks += 1  # the rerun of the same problem, which now passes
        elif name == "MB":
            checks += 1
            if triggered[p] and not found[p]:
                # imitator states are (p, j, None) for j = 0..n; V = 1 iff j <= t_p
                lo, hi = 0, n
                while hi - lo > 1:
                    mid = (lo + hi) // 2
                    checks += 1
                    if mid <= t[p]:
                        lo = mid
                    else:
                        hi = mid
                assert lo == t[p]
                task += 1
                found[p] = True
                n_unfound -= 1
                checks += 1  # the rerun of the same problem, which now passes
        else:
            raise ValueError(name)
        if r % max(1, max_runs // 4000) == 0 or failure() <= eps_stop:
            log.append((r, task, checks, failure()))
        if failure() <= eps_stop:
            break
    return log


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    m, eta, eps = 100, 0.5, 0.02
    ns = [16, 64, 256, 1024]
    seeds = range(10)
    summary = {}
    curves = {}
    for n in ns:
        # Theorem 3 with q -> infinity: failure >= eta (1 - 2Q/(nm)), so failure <= eps
        # needs Q >= (nm/2)(1 - eps/eta) task queries, on average over the prior.
        lower = n * m / 2 * (1 - eps / eta)
        for name, kw in [("CI", {}), ("US", {"gamma": 0.5 * eta / n}),
                         ("US-high", {"gamma": 2.0 * eta / n}), ("CS", {}), ("MB", {})]:
            proto = "US" if name.startswith("US") else name
            rows = []
            for s in seeds:
                rng = np.random.default_rng(1000 * n + s)
                t = sample_truth(rng, m, n, eta)
                rng2 = np.random.default_rng(10**6 + 1000 * n + s)
                max_runs = 400 * m * n if proto == "CI" else 200 * m
                log = run_protocol(proto, rng2, t, n, eta, max_runs, eps, **kw)
                last = log[-1]
                rows.append({"runs": last[0], "task": last[1], "checks": last[2],
                             "failure": last[3], "reached": last[3] <= eps})
                if s == 0:
                    curves[f"{name}_n{n}"] = log
            summary[f"{name}_n{n}"] = {
                "n": n, "protocol": name, "theorem3_lower_bound": lower,
                "reached_fraction": float(np.mean([r["reached"] for r in rows])),
                "runs_mean": float(np.mean([r["runs"] for r in rows])),
                "task_mean": float(np.mean([r["task"] for r in rows])),
                "checks_mean": float(np.mean([r["checks"] for r in rows])),
                "final_failure_mean": float(np.mean([r["failure"] for r in rows])),
            }
            print(json.dumps(summary[f"{name}_n{n}"]))
            sys.stdout.flush()
    with open(os.path.join(outdir, "hidden_insights_summary.json"), "w") as f:
        json.dump(summary, f, indent=1)
    with open(os.path.join(outdir, "hidden_insights_curves.json"), "w") as f:
        json.dump(curves, f)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
