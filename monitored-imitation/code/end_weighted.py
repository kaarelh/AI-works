"""Experiment E3: where in a run to ask, without any check.

Two versions of the hidden-insight class of Theorem 3 (m problems; problem p has an
insight k_p at step t_p with probability eta, else none):

  silent    the human writes its insight only at step t_p (Theorem 3's class): on a
            state that lacks the insight at a later step, it carries on without it;
  catch-up  the human writes its insight at any step j >= t_p at which the state
            lacks it: what it knows keeps showing in its later work.

A run succeeds if its final state is the human's final state. Protocols, each making
one task query per run and no checks:

  CI    chained imitation: a uniformly random step;
  LAST  the last step;
  EW    end-weighted: with probability 1/2 a uniform step, otherwise the step at
        distance d from the end with probability proportional to 1/(d+1);
  BIS   LAST, and when the last step is a mistake, binary search with task queries
        for the first step at which the human would write the insight (catch-up
        class only, where "the human writes at (p, j, None)" is monotone in j).

Posteriors are exact (the class prior; problems are independent). After every run we
record task queries and the exact probability that the decoder's run on a fresh
problem ends in the wrong state, and at the end also the probability that the run
differs from the human's anywhere.

Usage: python3 end_weighted.py OUTDIR
"""

import json
import os
import sys

import numpy as np


class Problem:
    """Exact posterior over (t_p, k_p) for one problem."""

    def __init__(self, n):
        self.n = n
        self.k_known = False
        self.lo = -1        # catch-up: largest j answered "no insight" (t > lo)
        self.hi = n         # catch-up: smallest j answered "insight" (t <= hi), n if none
        self.excluded = set()  # silent: steps answered "no insight"
        self.t_known = None    # silent: the insight step, once hit


def decoder_write_step(pr, cls):
    """Step at which the majority decoder writes the insight, or None."""
    if not pr.k_known:
        return None  # an unknown k_p: every particular content has small mass
    if cls == "silent":
        return pr.t_known
    # catch-up: t uniform on (lo, hi]; write at the first j with Pr[t <= j] > 1/2
    return int(np.floor(pr.lo + (pr.hi - pr.lo) / 2.0)) + 1


def query(pr, t, j, cls):
    """Task query at the decoder's state at step j. Returns True if it was a mistake."""
    w = decoder_write_step(pr, cls)
    if w is not None and j > w:
        return False  # the state carries the insight; human and decoder copy it
    decoder_writes = (w == j)
    human_writes = (j == t) if cls == "silent" else (j >= t)
    if cls == "silent":
        if human_writes:
            pr.k_known, pr.t_known = True, t
        else:
            pr.excluded.add(j)
    else:
        if human_writes:
            pr.k_known = True
            pr.hi = min(pr.hi, j)
        else:
            pr.lo = max(pr.lo, j)
    return decoder_writes != human_writes


def probe_bottom(pr, t, j):
    """Catch-up class: task query at the synthetic state (p, j, None), a state of the
    run made before k_p was known. The human writes iff j >= t."""
    if j >= t:
        pr.k_known = True
        pr.hi = min(pr.hi, j)
    else:
        pr.lo = max(pr.lo, j)


def run_ok(pr, t, n, cls):
    """(final state right, whole run right) for the decoder's run on this problem."""
    w = decoder_write_step(pr, cls)
    final_ok = (w is not None) == (t < n)
    exact_ok = (w == t) if t < n else (w is None)
    return final_ok, exact_ok


def end_weights_cdf(n):
    h = 1.0 / np.arange(1, n + 1)
    w = h[::-1] / h.sum()  # weight of step j is proportional to 1/(n - j)
    return np.cumsum(w)


def simulate(cls, proto, t, n, rng, max_runs, eps):
    m = len(t)
    probs = [Problem(n) for _ in range(m)]
    cdf = end_weights_cdf(n)
    task = 0
    mistakes = 0
    bad = sum(1 for p in range(m) if t[p] < n)  # problems whose final state is wrong
    log = [(0, 0, bad / m)]
    for r in range(1, max_runs + 1):
        p = int(rng.integers(m))
        pr = probs[p]
        before = run_ok(pr, t[p], n, cls)[0]
        if proto == "CI":
            j = int(rng.integers(n))
        elif proto in ("LAST", "BIS"):
            j = n - 1
        elif proto == "EW":
            j = int(rng.integers(n)) if rng.random() < 0.5 else min(n - 1, int(np.searchsorted(cdf, rng.random(), side='right')))
        else:
            raise ValueError(proto)
        task += 1
        mis = query(pr, t[p], j, cls)
        mistakes += mis
        if proto == "BIS" and mis and cls == "catch-up":
            # binary search, by task queries at the old run's states (p, j, None), for
            # the first step at which the human writes; each probe at j >= t_p is a step
            # where the old decoder (which never wrote) was wrong
            while pr.hi - pr.lo > 1:
                mid = (pr.lo + pr.hi) // 2
                task += 1
                probe_bottom(pr, t[p], mid)
        after = run_ok(pr, t[p], n, cls)[0]
        bad += int(before) - int(after)
        log.append((r, task, bad / m))
        if bad / m <= eps:
            break
    exact_fail = sum(1 for p in range(m) if not run_ok(probs[p], t[p], n, cls)[1]) / m
    return log, task, bad / m, exact_fail, mistakes


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    m, eta, eps = 100, 0.5, 0.02
    summary, curves = {}, {}
    for cls in ["silent", "catch-up"]:
        for n in [16, 64, 256, 1024]:
            for proto in ["CI", "EW", "LAST", "BIS"]:
                if proto == "BIS" and cls == "silent":
                    continue
                rows = []
                for s in range(10):
                    rng = np.random.default_rng(1000 * n + s)
                    trig = rng.random(m) < eta
                    t = np.where(trig, rng.integers(0, n, size=m), n)
                    rng2 = np.random.default_rng(10**6 + 1000 * n + s)
                    max_runs = 100 * m * n if proto in ("CI", "EW") else 200 * m
                    log, task, fail, exact_fail, mistakes = simulate(cls, proto, t, n, rng2, max_runs, eps)
                    rows.append((task, fail, exact_fail, mistakes, log[-1][0]))
                    if s == 0:
                        curves[f"{cls}_{proto}_n{n}"] = log[:: max(1, len(log) // 2000)] + [log[-1]]
                key = f"{cls}_{proto}_n{n}"
                summary[key] = {
                    "class": cls, "protocol": proto, "n": n,
                    "reached": int(sum(r[1] <= eps for r in rows)), "humans": len(rows),
                    "task_mean": float(np.mean([r[0] for r in rows])),
                    "runs_mean": float(np.mean([r[4] for r in rows])),
                    "final_failure_mean": float(np.mean([r[1] for r in rows])),
                    "run_differs_mean": float(np.mean([r[2] for r in rows])),
                    "mistakes_queried_mean": float(np.mean([r[3] for r in rows])),
                }
                print(json.dumps(summary[key]))
                sys.stdout.flush()
    with open(os.path.join(outdir, "end_weighted_summary.json"), "w") as f:
        json.dump(summary, f, indent=1)
    with open(os.path.join(outdir, "end_weighted_curves.json"), "w") as f:
        json.dump(curves, f)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
