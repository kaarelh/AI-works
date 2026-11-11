"""Finish an MLP variant's image learning curve at n = 60000 one seed at a time (the 3-seed vmapped run of the l2 / l2unit
variants - 4 configurations x 3 seeds, each with its own copy of the data - exceeds the 14 GB memory limit there).
Same training and selection code as mlp.py (mlp.run with seeds = (s,) and the grid restricted to the missing sizes);
rows are merged into results/<variant>__<dataset>.json.  usage: MLP_VARIANT=l2unit python mlp_large.py <dataset> [...]"""
import os, sys, json
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import mlp, data as DATA
from harness import RES
TAG = mlp.TAG
for ds in sys.argv[1:]:
    path = os.path.join(RES, f"{TAG}__{ds}.json"); base = json.load(open(path))
    D = DATA.load(ds); full = DATA.grid(D); missing = full[len(base["err"]):]
    assert base["ns"][:len(base["err"])] == full[:len(base["err"])]
    real_grid = DATA.grid
    for n in missing:
        rows = []
        for s in base["seeds"]:
            mlp.TAG = f"{TAG}-tmp{s}"; DATA.grid = lambda D, n=n: [n]
            rows.append(mlp.run(ds, seeds=(s,)))
            os.remove(os.path.join(RES, f"{mlp.TAG}__{ds}.json"))
        DATA.grid = real_grid
        for k in ("err", "flops", "flops_total", "cpu_seconds", "chosen_lr", "chosen_wd", "chosen_step"):
            base[k].append([r[k][0][0] for r in rows])
        base["ns"] = full; base["note"] = f"n >= {missing[0]}: one seed per run (memory), mlp_large.py"
        json.dump(base, open(path, "w")); print(ds, n, base["err"][-1], flush=True)
