"""Checks of the model's constants and ablations, scored against the networks with score.py's score_one.

    python fit.py <N> <seeds> '<json list of configs>' <tag> [fns] [conds]

A config is {"c_mem": .., "c_cap": .., "abl": {switch: value}, "diffuse": [...]}; missing keys take the defaults of
flow.py.  Results go to fit_<tag>.json (one entry per config: mean traj and onset, per condition and per target).
The width-48 model is used for rmaj9 (as in predict.py).  No constant is fitted here: the runs recorded in MODEL.md
bracket the derived values c_mem = c_cap = 1 and switch ingredients off one at a time.
"""
import os, sys, json, time, shutil, tempfile
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); TR = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE); sys.path.insert(0, TR)
import flow
from score import score_one

N, seeds = int(sys.argv[1]), int(sys.argv[2])
grid, tag = json.loads(sys.argv[3]), sys.argv[4]
fns = sys.argv[5].split(",") if len(sys.argv) > 5 else ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]
conds = tuple(sys.argv[6].split(",")) if len(sys.argv) > 6 else ("16384", "2048", "512")
out_json = os.path.join(HERE, f"fit_{tag}.json")
res = json.load(open(out_json)) if os.path.exists(out_json) else {}
tmp = tempfile.mkdtemp(prefix="flow_fit_")
for cfg in grid:
    key = json.dumps(cfg, sort_keys=True)
    if key in res:
        continue
    t0 = time.time(); sc = {}
    abl0 = dict(flow.ABL); flow.ABL.update(cfg.get("abl", {}))
    consts = {k: v for k, v in cfg.items() if k in ("c_mem", "c_cap")}
    if "diffuse" in cfg:
        consts["diffuse"] = tuple(cfg["diffuse"])
    for fn in fns:
        Nf = N if fn != "rmaj9" else min(N, 48)
        steps, out = flow.run(fn, conds=conds, N=Nf, seeds=seeds, consts=consts)
        steps = steps / flow.width_dilation(Nf)
        for c in conds:
            p = os.path.join(tmp, f"{fn}__{c}.npz"); np.savez(p, steps=steps, f=out[c].mean(0))
            sc[f"{fn}__{c}"] = score_one(fn, c, p)
    flow.ABL.clear(); flow.ABL.update(abl0)
    tr = np.mean([s["traj"] for s in sc.values()]); on = np.mean([s["onset"] for s in sc.values()])
    per = {c: (np.mean([sc[f"{fn}__{c}"]["traj"] for fn in fns]), np.mean([sc[f"{fn}__{c}"]["onset"] for fn in fns]))
           for c in conds}
    res[key] = dict(traj=tr, onset=on, per=per, all=sc, N=N, seeds=seeds)
    json.dump(res, open(out_json, "w"), indent=1)
    print(f"{key}: traj {tr:.4f} onset {on:.3f} | " + " ".join(f"{c}:{per[c][0]:.4f}/{per[c][1]:.3f}" for c in conds)
          + f"  ({time.time() - t0:.0f}s)", flush=True)
shutil.rmtree(tmp, ignore_errors=True)
