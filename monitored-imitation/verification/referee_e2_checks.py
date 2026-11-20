"""Referee checks for experiment E2 (rules on simple properties).

1. The novelty table of the note (Section 10), recomputed by an independent method.
   A property (mask M of size s, pattern c & M) is unsettled at content c iff no queried
   content agrees with c on M. Equivalently, with T the complement of M (|T| = 12 - s),
   no queried content lies in the subcube {c' : c' & ~T = c & ~T}. So c has a new property
   of size s iff for some T of size 12 - s the projection c & ~T is not the projection of
   any queried content. Same random queries as make_figures.novelty_curve (seeds 0, 1, 2).
2. MB and CS as the note describes them (Protocol MB, step 3: after the task query, run
   the same problem again, and check it again, until it passes), against the code's
   version, which moves to a fresh problem after one task query and counts one final
   check per problem. Same humans and problem seeds as property_rules.py.
3. How MB's ~15 task queries relate to the 18 rules: rules learned, rules never learned,
   queries that revealed several new rules at once.
4. CI with 40 humans per n instead of 10, to see whether the non-monotone CI column is
   noise.

Usage: python3 referee_e2_checks.py  (writes referee_e2_checks.out next to this file)
"""

import math
import os
import sys
from itertools import combinations

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "code"))
import property_rules as pr  # noqa: E402

L, NC = pr.L, pr.NC


def novelty_independent(qs=(0, 25, 50, 100, 200, 400, 800, 1600, 3200), seeds=3):
    cs = np.arange(NC, dtype=np.int64)
    full = NC - 1
    out = {s: [] for s in (3, 6, 9)}
    for q in qs:
        vals = {s: [] for s in out}
        for seed in range(seeds):
            rng = np.random.default_rng(seed)
            queried = rng.integers(NC, size=q).astype(np.int64)
            for s in out:
                novel = np.zeros(NC, bool)
                for T in combinations(range(L), L - s):
                    keep = full & ~sum(1 << i for i in T)
                    occ = np.zeros(NC, bool)
                    occ[queried & keep] = True
                    novel |= ~occ[cs & keep]
                vals[s].append(novel.mean())
        for s in out:
            out[s].append(float(np.mean(vals[s])))
    return list(qs), out


def faithful(world, proto, seed, max_problems, eps):
    """MB / CS with reruns of the same problem until its run passes the check.
    CS re-scans from x'_0 and asks again at states already in D; CS-skip does not ask at
    contents whose answer is already in D."""
    rng = np.random.default_rng(seed)
    lr = pr.Learner(world)
    asked = set()
    n = world.n
    fails = 0
    probs = 0
    for r in range(1, max_problems + 1):
        probs = r
        c0 = int(rng.integers(NC))
        traj = world.traj[c0]
        while True:
            lr.checks += 1
            bad = [j for j in range(n) if lr.mistake_at(int(traj[j]))]
            if not bad:
                break
            fails += 1
            jstar = bad[0]
            if proto in ("CS", "CS-skip"):
                for j in range(jstar + 1):
                    c = int(traj[j])
                    if proto == "CS-skip" and c in asked:
                        continue
                    asked.add(c)
                    lr.query_task(c)
            else:
                lo, hi = 0, n
                while hi - lo > 1:
                    mid = (lo + hi) // 2
                    lr.checks += 1
                    lo, hi = (mid, hi) if mid <= jstar else (lo, mid)
                assert lo == jstar
                lr.query_task(int(traj[jstar]))
        if lr.failure() <= eps:
            break
    return dict(task=lr.task, checks=lr.checks, problems=probs, failed_runs=fails,
                failure=lr.failure())


def mb_rule_stats(world, seed, eps):
    """The code's MB, recording how many new rules each task query revealed."""
    rng = np.random.default_rng(seed)
    lr = pr.Learner(world)
    n = world.n
    new_per_query = []
    for r in range(1, 20001):
        c0 = int(rng.integers(NC))
        traj = world.traj[c0]
        bad = [j for j in range(n) if lr.mistake_at(int(traj[j]))]
        if bad:
            c = int(traj[bad[0]])
            before = lr.known_rules
            lr.query_task(c)
            new_per_query.append(bin(lr.known_rules & ~before).count("1"))
        if lr.failure() <= eps:
            break
    distinct = len({(mi, pat) for mi, pat in world.rules})
    learned = bin(lr.known_rules).count("1")
    return new_per_query, learned, distinct


def ci_runs(world, seed, eps, max_runs=20000):
    rng = np.random.default_rng(seed)
    lr = pr.Learner(world)
    for r in range(1, max_runs + 1):
        c0 = int(rng.integers(NC))
        j = int(rng.integers(world.n))
        lr.query_task(int(world.traj[c0][j]))
        if lr.failure() <= eps:
            return r
    return max_runs


def main():
    out = []
    eps = 0.02
    # 1. novelty table
    qs, nov = novelty_independent()
    note = {3: [100, 91, 29, 0, 0, 0, 0, 0, 0], 6: [100, 99, 99, 98, 94, 50, 1, 0, 0],
            9: [100, 99, 99, 98, 95, 91, 82, 66, 20]}
    out.append("## 1. Novelty table, independent recomputation\n")
    out.append("| size | " + " | ".join(str(q) for q in qs) + " |")
    out.append("|---|" + "---|" * len(qs))
    ok = True
    for s in (3, 6, 9):
        cells = [f"{100*v:.0f}%" for v in nov[s]]
        out.append(f"| <= {s} | " + " | ".join(cells) + " |")
        ok &= all(round(100 * v) == t for v, t in zip(nov[s], note[s]))
    out.append(f"\nMatches the note's table cell by cell: {ok}.\n")

    # 2. faithful MB / CS vs the code's
    out.append("## 2. MB and CS with reruns (as Protocol MB is written) vs the code\n")
    out.append("Means over the same 10 humans and seeds as property_rules.py.\n")
    out.append("| n | protocol | code: task / checks / problems | with reruns: task / checks / problems / failed runs | final failure (reruns) |")
    out.append("|---|---|---|---|---|")
    import json
    summ = json.load(open(os.path.join(HERE, "..", "results", "property_rules_summary.json")))
    for n in [4, 16, 64]:
        for proto in ["MB", "CS", "CS-skip"]:
            rows = [faithful(pr.World(seed=100 + s, n=n), proto, 7 + s, 20000, eps) for s in range(10)]
            sv = summ[f"{proto.split('-')[0]}_n{n}"]
            out.append(f"| {n} | {proto} | {sv['task_mean']:.1f} / {sv['checks_mean']:.1f} / {sv['runs_mean']:.1f} | "
                       f"{np.mean([r['task'] for r in rows]):.1f} / {np.mean([r['checks'] for r in rows]):.1f} / "
                       f"{np.mean([r['problems'] for r in rows]):.1f} / {np.mean([r['failed_runs'] for r in rows]):.1f} | "
                       f"{np.mean([r['failure'] for r in rows]):.3f} |")
    out.append("")

    # 3. rule statistics for the code's MB
    out.append("## 3. MB's task queries and the 18 rules (code's MB)\n")
    out.append("| n | mean task queries | mean distinct rules | mean rules learned | queries revealing >= 2 new rules (mean) |")
    out.append("|---|---|---|---|---|")
    for n in [4, 16, 64]:
        st = [mb_rule_stats(pr.World(seed=100 + s, n=n), 7 + s, eps) for s in range(10)]
        out.append(f"| {n} | {np.mean([len(a) for a, _, _ in st]):.1f} | {np.mean([d for _, _, d in st]):.1f} | "
                   f"{np.mean([l for _, l, _ in st]):.1f} | {np.mean([sum(1 for x in a if x >= 2) for a, _, _ in st]):.1f} |")
    out.append("")

    # 4. CI with more humans
    out.append("## 4. CI task queries with 40 humans per n (seeds 100..139, problem seeds 7..46)\n")
    out.append("| n | mean (first 10 humans) | mean (40 humans) | standard error (40) |")
    out.append("|---|---|---|---|")
    for n in [4, 16, 64]:
        v = np.array([ci_runs(pr.World(seed=100 + s, n=n), 7 + s, eps) for s in range(40)], float)
        out.append(f"| {n} | {v[:10].mean():.1f} | {v.mean():.1f} | {v.std(ddof=1)/math.sqrt(len(v)):.1f} |")
    out.append("")

    text = "\n".join(out)
    print(text)
    with open(os.path.join(HERE, "referee_e2_checks.out"), "w") as f:
        f.write(text + "\n")


if __name__ == "__main__":
    main()
