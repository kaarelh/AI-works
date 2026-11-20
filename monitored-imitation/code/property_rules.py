"""Experiment E2: a human whose knowledge is rules triggered by simple properties.

Content is an L-bit string c. A run on a problem c0 visits the contents
c0, pi(c0), pi(pi(c0)), ... for a fixed random permutation pi that the learner knows.
A *property* is a conjunction of r literals (a mask with r bits and a pattern on those
bits); it holds at c iff c & mask == pattern. Its prior description length grows with
r: the prior probability that the human has a rule on a given property of size r is
1/N_r, where N_r = C(L, r) 2^r is the number of such properties (one expected rule per
size).

The human has a fixed set of rules, two of each size r = 1..R. At each step it appends
to its notes one token for every rule whose property holds at the current content. The
state of a run is (c0, step, notes). A task query at a state reveals the human's tokens
at that content, which settles, for every property that holds there, whether it is a
rule. The decoder appends the tokens of the rules it knows; it makes a mistake at a
content exactly when a rule it does not know fires there.

Part A uses the perfect check V(c0, j, notes) = [notes are the human's notes after j
steps], which a real human could only evaluate by redoing the work; it shows the
bookkeeping of the protocols under the strongest possible check. Part B uses a weak check
that looks only at the tokens of half of the human's rules (one rule of each size); it is
still preserved by the human, but deviations on the other rules are invisible to it.

Protocols, as in hidden_insights.py, plus:
  NOV(s)  query at every step of a run at which some property of size <= s that holds
          there has never held at a queried content (the "first time the run has a new
          simple property" rule);
  US(g)   query at every step at which the posterior probability that the decoder's
          step is wrong is at least g.

  CS      check and scan: on a failed check, ask the human at the run's states in order,
          skipping states already asked, up to the first mistake; rerun the problem.
  MB      monitored imitation with bisection, with reruns as in the note's Protocol MB.
  MBA(b)  MB plus, after each output run, with probability b, a task query at a uniformly
          random step of it (Proposition 10).

After every problem we record the cumulative task queries and checks and two exact
failure probabilities of the current decoder on a uniformly random problem: that its run
differs from the human's, and that its run fails the check.

Usage: python3 property_rules.py OUTDIR
"""

import json
import math
import os
import sys
from itertools import combinations

import numpy as np

L = 12
R = 9
NC = 1 << L


def popcount(x):
    return bin(x).count("1")


MASKS = np.array([m for r in range(1, R + 1) for m in
                  (sum(1 << i for i in comb) for comb in combinations(range(L), r))],
                 dtype=np.int64)
MASK_R = np.array([popcount(int(m)) for m in MASKS], dtype=np.int64)
N_R = {r: math.comb(L, r) * 2 ** r for r in range(1, R + 1)}
PRIOR = np.array([1.0 / N_R[int(r)] for r in MASK_R])
LOG1M_PRIOR = np.log1p(-PRIOR)
MASK_IDX = np.arange(len(MASKS), dtype=np.int64)


def prop_ids(c):
    """Indices, in the dense table, of the properties that hold at content c."""
    return MASK_IDX * NC + (c & MASKS)


class World:
    def __init__(self, seed, n, rules_per_size=2):
        rng = np.random.default_rng(seed)
        self.perm = rng.permutation(NC)
        self.n = n
        rules = []
        for r in range(1, R + 1):
            idx = np.flatnonzero(MASK_R == r)
            for _ in range(rules_per_size):
                mi = int(rng.choice(idx))
                pat = int(rng.integers(NC)) & int(MASKS[mi])
                rules.append((mi, pat))
        self.rules = rules
        self.rule_size = np.array([int(MASK_R[mi]) for mi, _ in rules])
        # which rules hold at each content, as a bitmask over rules
        hold = np.zeros(NC, dtype=np.int64)
        cs = np.arange(NC, dtype=np.int64)
        for k, (mi, pat) in enumerate(rules):
            hold |= ((cs & MASKS[mi]) == pat).astype(np.int64) << k
        self.hold = hold
        # contents visited by the run from each start, and the OR of hold over the run
        traj = np.zeros((NC, n), dtype=np.int64)
        c = cs.copy()
        for j in range(n):
            traj[:, j] = c
            c = self.perm[c]
        self.traj = traj
        self.window = np.bitwise_or.reduce(hold[traj], axis=1)


class Learner:
    """Exact posterior bookkeeping. `visible` is the set of rules (bitmask) whose tokens
    the human's check looks at; by default all of them (the perfect check)."""

    def __init__(self, world, visible=None):
        self.w = world
        self.visible = (1 << len(world.rules)) - 1 if visible is None else visible
        self.resolved = np.zeros(len(MASKS) * NC, dtype=bool)
        self.known_rules = 0  # bitmask over the human's rules
        self.queried = set()  # contents whose answer is in the data
        self.task = 0
        self.checks = 0

    def query_task(self, c):
        self.task += 1
        self.queried.add(c)
        self.resolved[prop_ids(c)] = True
        self.known_rules |= int(self.w.hold[c])

    def failure(self):
        """Probability that the decoder's run on a random problem differs from the human's."""
        unknown = ~self.known_rules
        return float(np.mean((self.w.window & unknown) != 0))

    def check_failure(self):
        """Probability that the decoder's run on a random problem fails the check."""
        unknown = ~self.known_rules & self.visible
        return float(np.mean((self.w.window & unknown) != 0))

    def mistake_at(self, c):
        return (int(self.w.hold[c]) & ~self.known_rules) != 0

    def visible_mistake_at(self, c):
        return (int(self.w.hold[c]) & ~self.known_rules & self.visible) != 0

    def uncertainty(self, c):
        ids = prop_ids(c)
        un = ~self.resolved[ids]
        return 1.0 - math.exp(float(LOG1M_PRIOR[un].sum()))

    def novel(self, c, s):
        """Is there an unsettled property of size <= s at c? (An unsettled property of size
        r < s extends to an unsettled one of size s, so this is the same as size exactly s
        whenever s <= L.)"""
        ids = prop_ids(c)
        un = ~self.resolved[ids]
        return bool(np.any(un & (MASK_R <= s)))


def run(world, proto, seed, max_runs, eps, param=None, track_novelty=None, visible=None):
    """Run a protocol until the decoder's run failure (difference from the human's run)
    is at most eps, or for max_runs problems. Log after each problem:
    (problems, task queries, checks, run failure, check failure)."""
    rng = np.random.default_rng(seed)
    lr = Learner(world, visible)
    n = world.n
    log = [(0, 0, 0, lr.failure(), lr.check_failure())]
    nov_log = []
    for r in range(1, max_runs + 1):
        c0 = int(rng.integers(NC))
        traj = world.traj[c0]
        if track_novelty is not None and r % 10 == 0:
            frac = {s: float(np.mean([lr.novel(int(c), s) for c in traj])) for s in track_novelty}
            nov_log.append((lr.task, frac))
        if proto == "CI":
            j = int(rng.integers(n))
            lr.query_task(int(traj[j]))
        elif proto == "US":
            for c in traj:
                c = int(c)
                if lr.uncertainty(c) >= param:
                    lr.query_task(c)
        elif proto == "NOV":
            for c in traj:
                c = int(c)
                if lr.novel(c, param):
                    lr.query_task(c)
        elif proto in ("CS", "MB", "MBA"):
            # Protocol MB as written: check the final state; on a failure, locate a
            # mistake, ask the human there, and rerun the same problem until it passes.
            while True:
                lr.checks += 1
                bad = [j for j in range(n) if lr.visible_mistake_at(int(traj[j]))]
                if not bad:
                    break
                jstar = bad[0]  # the check passes states 0..jstar and fails after
                if proto == "CS":
                    first = next(j for j in range(n) if lr.mistake_at(int(traj[j])))
                    for j in range(first + 1):  # scan, skipping states already asked
                        c = int(traj[j])
                        if c not in lr.queried:
                            lr.query_task(c)
                else:
                    lo, hi = 0, n  # V(state j) = 1 iff j <= jstar
                    while hi - lo > 1:
                        mid = (lo + hi) // 2
                        lr.checks += 1
                        if mid <= jstar:
                            lo = mid
                        else:
                            hi = mid
                    assert lo == jstar
                    lr.query_task(int(traj[jstar]))
            if proto == "MBA" and rng.random() < param:  # audit of the output run
                lr.query_task(int(traj[int(rng.integers(n))]))
        else:
            raise ValueError(proto)
        f = lr.failure()
        log.append((r, lr.task, lr.checks, f, lr.check_failure()))
        if f <= eps:
            break
    return log, nov_log


def summarize(n, label, logs, eps):
    rows = []
    for log in logs:
        last = log[-1]
        first_ck = next((e for e in log if e[4] <= eps), None)
        rows.append({"runs": last[0], "task": last[1], "checks": last[2], "failure": last[3],
                     "check_failure": last[4], "reached": last[3] <= eps,
                     "check_reached": first_ck is not None,
                     "task_at_check": first_ck[1] if first_ck else None,
                     "checks_at_check": first_ck[2] if first_ck else None})
    ck = [r for r in rows if r["check_reached"]]
    return {
        "n": n, "protocol": label, "n_humans": len(rows),
        "reached": int(sum(r["reached"] for r in rows)),
        "runs_mean": float(np.mean([r["runs"] for r in rows])),
        "task_mean": float(np.mean([r["task"] for r in rows])),
        "checks_mean": float(np.mean([r["checks"] for r in rows])),
        "task_sem": float(np.std([r["task"] for r in rows], ddof=1) / math.sqrt(len(rows))),
        "final_failure_mean": float(np.mean([r["failure"] for r in rows])),
        "final_check_failure_mean": float(np.mean([r["check_failure"] for r in rows])),
        "check_reached": len(ck),
        "task_at_check_mean": float(np.mean([r["task_at_check"] for r in ck])) if ck else None,
        "checks_at_check_mean": float(np.mean([r["checks_at_check"] for r in ck])) if ck else None,
    }


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    eps = 0.02
    summary = {}
    curves = {}
    # Part A: the perfect check (the human's notes are exactly right so far).
    protos = [("CI", None, 40, 20000), ("US", 0.01, 10, 3000), ("US", 0.001, 10, 3000),
              ("NOV", 3, 10, 3000), ("NOV", 6, 10, 3000), ("NOV", 9, 10, 3000),
              ("CS", None, 40, 20000), ("MB", None, 40, 20000)]
    for n in [4, 16, 64]:
        for name, param, humans, max_runs in protos:
            label = name if param is None else f"{name}({param})"
            logs = []
            for s in range(humans):
                world = World(seed=100 + s, n=n)
                track = [3, 6, 9] if (name == "CI" and s == 0 and n == 16) else None
                log, nov = run(world, name, seed=7 + s, max_runs=max_runs, eps=eps,
                               param=param, track_novelty=track)
                logs.append(log)
                if s == 0:
                    curves[f"{label}_n{n}"] = log
                if nov:
                    curves[f"novelty_CI_n{n}"] = nov
            summary[f"{label}_n{n}"] = summarize(n, label, logs, eps)
            print(json.dumps(summary[f"{label}_n{n}"]))
            sys.stdout.flush()
    # Part B: a weak check that sees the tokens of only one rule of each size (the
    # rules with even index); the other half of the human's rules are invisible to it.
    n = 16
    for name, param, max_runs in [("CI", None, 20000), ("MB", None, 5000),
                                  ("MBA", 0.1, 20000), ("MBA", 1.0, 20000)]:
        label = ("weak-" + name) if param is None else f"weak-{name}({param})"
        logs = []
        for s in range(20):
            world = World(seed=100 + s, n=n)
            visible = sum(1 << k for k in range(0, len(world.rules), 2))
            log, _ = run(world, name, seed=7 + s, max_runs=max_runs, eps=eps,
                         param=param, visible=visible)
            logs.append(log)
            if s == 0:
                curves[f"{label}_n{n}"] = log
        summary[f"{label}_n{n}"] = summarize(n, label, logs, eps)
        print(json.dumps(summary[f"{label}_n{n}"]))
        sys.stdout.flush()
    with open(os.path.join(outdir, "property_rules_summary.json"), "w") as f:
        json.dump(summary, f, indent=1)
    with open(os.path.join(outdir, "property_rules_curves.json"), "w") as f:
        json.dump(curves, f)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
