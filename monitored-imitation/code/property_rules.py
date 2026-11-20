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
content exactly when a rule it does not know fires there. The monitor is
V(c0, j, notes) = [notes are the human's notes after j steps]; it is preserved by the
human.

Protocols, as in hidden_insights.py, plus:
  NOV(s)  query at every step of a run at which some property of size <= s that holds
          there has never held at a queried content (the "first time the run has a new
          simple property" rule);
  US(g)   query at every step at which the posterior probability that the decoder's
          step is wrong is at least g.

After every run we record the cumulative task queries and checks and the exact
failure probability of the current decoder on a uniformly random problem.

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
    def __init__(self, world):
        self.w = world
        self.resolved = np.zeros(len(MASKS) * NC, dtype=bool)
        self.known_rules = 0  # bitmask over the human's rules
        self.task = 0
        self.checks = 0

    def query_task(self, c):
        self.task += 1
        self.resolved[prop_ids(c)] = True
        self.known_rules |= int(self.w.hold[c])

    def failure(self):
        unknown = ~self.known_rules
        return float(np.mean((self.w.window & unknown) != 0))

    def mistake_at(self, c):
        return (int(self.w.hold[c]) & ~self.known_rules) != 0

    def uncertainty(self, c):
        ids = prop_ids(c)
        un = ~self.resolved[ids]
        return 1.0 - math.exp(float(LOG1M_PRIOR[un].sum()))

    def novel(self, c, s):
        ids = prop_ids(c)
        un = ~self.resolved[ids]
        return bool(np.any(un & (MASK_R <= s)))


def run(world, proto, seed, max_runs, eps, param=None, track_novelty=None):
    rng = np.random.default_rng(seed)
    lr = Learner(world)
    n = world.n
    log = [(0, 0, 0, lr.failure())]
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
        elif proto in ("CS", "MB"):
            lr.checks += 1
            bad = [j for j in range(n) if lr.mistake_at(int(traj[j]))]
            if bad:
                jstar = bad[0]  # notes are correct up to step jstar and wrong after
                if proto == "CS":
                    for j in range(jstar + 1):
                        lr.query_task(int(traj[j]))
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
        else:
            raise ValueError(proto)
        f = lr.failure()
        log.append((r, lr.task, lr.checks, f))
        if f <= eps:
            break
    return log, nov_log


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    eps = 0.02
    summary = {}
    curves = {}
    protos = [("CI", None), ("US", 0.01), ("US", 0.001), ("NOV", 3), ("NOV", 6),
              ("NOV", 9), ("CS", None), ("MB", None)]
    for n in [4, 16, 64]:
        for name, param in protos:
            label = name if param is None else f"{name}({param})"
            rows = []
            for s in range(10):
                world = World(seed=100 + s, n=n)
                max_runs = 20000 if name in ("CI", "CS", "MB") else 3000
                track = [3, 6, 9] if (name == "CI" and s == 0 and n == 16) else None
                log, nov = run(world, name, seed=7 + s, max_runs=max_runs, eps=eps,
                               param=param, track_novelty=track)
                last = log[-1]
                rows.append({"runs": last[0], "task": last[1], "checks": last[2],
                             "failure": last[3], "reached": last[3] <= eps})
                if s == 0:
                    curves[f"{label}_n{n}"] = log
                if nov:
                    curves[f"novelty_CI_n{n}"] = nov
            summary[f"{label}_n{n}"] = {
                "n": n, "protocol": label,
                "reached_fraction": float(np.mean([r["reached"] for r in rows])),
                "runs_mean": float(np.mean([r["runs"] for r in rows])),
                "task_mean": float(np.mean([r["task"] for r in rows])),
                "checks_mean": float(np.mean([r["checks"] for r in rows])),
                "final_failure_mean": float(np.mean([r["failure"] for r in rows])),
            }
            print(json.dumps(summary[f"{label}_n{n}"]))
            sys.stdout.flush()
    with open(os.path.join(outdir, "property_rules_summary.json"), "w") as f:
        json.dump(summary, f, indent=1)
    with open(os.path.join(outdir, "property_rules_curves.json"), "w") as f:
        json.dump(curves, f)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
