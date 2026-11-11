"""Final (held-out) evaluation of a frozen Part 8 learner.
usage: python run_heldout.py <module:Class[:kwargs]> <part,...>    parts: toy, tab, img, img:<dataset>
  toy: the toy suites random, dlheld, dlheld2, dlheld3 (eval_toy.py, full grid and seeds)
  tab: every tabular dataset of data.HELDOUT and data.HELDOUT2 (3 seeds, full grid)
  img: mnist, fashion_mnist - 3 seeds for n <= 10000, seed 0 only at n = 30000 and 60000 (as for the Part 7 learners)
Results: study/hybrid/results/toy__<learner>__<suite>.json and study/standard_tasks/results/<learner>__<dataset>.json."""
import os, sys, json, subprocess
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common
SH = common.SH; DATA = SH.DATA
IMG = ["mnist", "fashion_mnist"]
spec, parts = sys.argv[1], sys.argv[2].split(",")
L = common.load_learner(spec)
if "toy" in parts:
    for suite in ("random", "dlheld", "dlheld2", "dlheld3"):
        subprocess.run([sys.executable, os.path.join(HERE, "eval_toy.py"), spec, suite], check=True)
if "tab" in parts:
    SH.evaluate(L, [d for d in DATA.HELDOUT + DATA.HELDOUT2 if d not in IMG])
imgs = IMG if "img" in parts else [p.split(":", 1)[1] for p in parts if p.startswith("img:")]
if imgs:
    for ds in imgs:
        a = SH.evaluate(L, [ds], ns=[100, 300, 1000, 3000, 10000], seeds=(0, 1, 2))[ds]
        b = SH.evaluate(L, [ds], ns=[30000, 60000], seeds=(0,), tag=L.name + "-large")[ds]
        nan = float("nan")
        r = dict(learner=L.name, dataset=ds, ns=a["ns"] + b["ns"], seeds=[0, 1, 2],
                 err=a["err"] + [[e[0], nan, nan] for e in b["err"]], flops=a["flops"] + [[f[0], nan, nan] for f in b["flops"]],
                 cpu_seconds=a["cpu_seconds"] + [[c[0], nan, nan] for c in b["cpu_seconds"]], note="n >= 30000: seed 0 only")
        json.dump(r, open(os.path.join(SH.RES, f"{L.name}__{ds}.json"), "w"))
        os.remove(os.path.join(SH.RES, f"{L.name}-large__{ds}.json"))
        print(ds, "done", flush=True)
