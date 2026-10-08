"""Build a jobs file.

usage: python3 make_jobs.py <out.jsonl> --models haiku,sonnet --conds all --tasks all --reps 0-9
Replicate r uses item-order seed 1000+r in every condition (blocking).
"""
import argparse
import json
import random

import task_code
import task_memo
import task_sched
import task_whip
from conditions import CONDITIONS, system_prompt

SCHED_INST = task_sched.make_instance()

BUILD = {
    "sched": lambda cond, seed: task_sched.build_prompt(SCHED_INST, cond, seed),
    "whip": task_whip.build_prompt,
    "memo": task_memo.build_prompt,
    "code": task_code.build_prompt,
}
TASKS = list(BUILD)


def rep_range(s):
    if "-" in s:
        a, b = s.split("-")
        return list(range(int(a), int(b) + 1))
    return [int(x) for x in s.split(",")]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("--models", default="haiku,sonnet,opus,fable")
    ap.add_argument("--conds", default="all")
    ap.add_argument("--tasks", default="all")
    ap.add_argument("--reps", default="0")
    ap.add_argument("--tag", default="")
    a = ap.parse_args()
    conds = CONDITIONS if a.conds == "all" else a.conds.split(",")
    tasks = TASKS if a.tasks == "all" else a.tasks.split(",")
    jobs = []
    for m in a.models.split(","):
        for t in tasks:
            for c in conds:
                for r in rep_range(a.reps):
                    jobs.append(dict(id=f"{a.tag}{t}__{c}__{m}__r{r:02d}", model=m, cond=c, task=t, rep=r,
                                     system=system_prompt(c), prompt=BUILD[t](c, 1000 + r)))
    random.Random(0).shuffle(jobs)  # interleave conditions in time
    with open(a.out, "w") as f:
        for j in jobs:
            f.write(json.dumps(j) + "\n")
    print(len(jobs), "jobs ->", a.out)


if __name__ == "__main__":
    main()
