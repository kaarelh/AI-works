"""Run a frozen learner on mnist / fashion_mnist: 3 seeds for n <= 10000, seed 0 only for n = 30000 and 60000 (compute);
merged into results/<learner>__<dataset>.json with NaN for the seeds not run.  usage: python run_images.py <module> [ds...]"""
import sys, os, json, importlib, numpy as np
import harness as H, data as DATA
mod = sys.argv[1]; L = importlib.import_module(mod + ".learner").Learner()
large_only = os.environ.get("LARGE_ONLY")          # reuse an existing small-n result file (after an interrupted run)
for ds in (sys.argv[2:] or ["mnist", "fashion_mnist"]):
    if large_only:
        a = json.load(open(os.path.join(H.RES, f"{L.name}__{ds}.json")))
        assert a["ns"] == [100, 300, 1000, 3000, 10000]
    else:
        a = H.evaluate(L, [ds], ns=[100, 300, 1000, 3000, 10000], seeds=(0, 1, 2))[ds]
    b = H.evaluate(L, [ds], ns=[30000, 60000], seeds=(0,), tag=L.name + "-large")[ds]
    err = a["err"] + [[e[0], float("nan"), float("nan")] for e in b["err"]]
    fl = a["flops"] + [[f[0], float("nan"), float("nan")] for f in b["flops"]]
    cpu = a["cpu_seconds"] + [[c[0], float("nan"), float("nan")] for c in b["cpu_seconds"]]
    r = dict(learner=L.name, dataset=ds, ns=a["ns"] + b["ns"], seeds=[0, 1, 2], err=err, flops=fl, cpu_seconds=cpu,
             note="n >= 30000: seed 0 only")
    json.dump(r, open(os.path.join(H.RES, f"{L.name}__{ds}.json"), "w"))
    os.remove(os.path.join(H.RES, f"{L.name}-large__{ds}.json"))
    print(ds, "done", flush=True)
