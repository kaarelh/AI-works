"""Model-free job file replicating study 1 for non-Claude models (the Astra handoff).

usage: python3 handoff/make_s1_jobs.py handoff/jobs_study1.jsonl --reps 0-5
Same prompts as study 1 (replicate r uses item-order seed 1000+r). Job ids carry no model name;
astra_runner.py stores each record under <outdir>/<model-slug>/ and sets job["model"].
"""
import argparse
import json
import os
import random
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from conditions import CONDITIONS, system_prompt  # noqa: E402
from make_jobs import BUILD, rep_range  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("out")
ap.add_argument("--reps", default="0-5")
ap.add_argument("--tasks", default="sched,whip,memo,code,loop")
a = ap.parse_args()
jobs = [dict(id=f"s1_{t}__{c}__r{r:02d}", study=1, cond=c, task=t, rep=r, system=system_prompt(c), prompt=BUILD[t](c, 1000 + r))
        for t in a.tasks.split(",") for c in CONDITIONS for r in rep_range(a.reps)]
rng = random.Random(0)
jobs = [j for _, j in sorted(((j["rep"], rng.random()), j) for j in jobs)]
with open(a.out, "w") as f:
    for j in jobs:
        f.write(json.dumps(j) + "\n")
print(len(jobs), "jobs ->", a.out)
