"""Online ablations of the model's ingredients (width 64, 3 seeds, the four calibration targets with r <= 6).

    python ablate.py <variant,variant,...>
"""
import os, sys, shutil, tempfile
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); TR = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE); sys.path.insert(0, TR)
import flow
from score import score_one

FNS = ["sparsepoly", "stair5", "mux", "majpar"]
VARIANTS = {
    "full": ({}, {}),
    "no_noise_in_v": ({"noise_v": 0.0}, {}),                  # Adam's v sees only the expected gradient
    "no_irrelevant_inputs": ({"off": 0.0}, {}),               # off-R weights zero: no irrelevant noise at all
    "no_cancellation": ({"cancel": 0.0}, {}),                 # linear part of Var(f | x_R) as if units independent
    "no_hermite_part": ({"hermite": 0.0}, {}),                # drop the non-linear part of the units' variance
    "offweight_diffusion": ({}, {"diffuse": ("Woff",)}),      # add the minibatch random walk of the off-R weights
}
tmp = tempfile.mkdtemp(prefix="flow_ablate_")
for name in sys.argv[1].split(","):
    abl, consts = VARIANTS[name]
    abl0 = dict(flow.ABL); flow.ABL.update(abl)
    res = []
    for fn in FNS:
        steps, out = flow.run(fn, conds=("online",), N=64, seeds=3, consts=consts)
        p = os.path.join(tmp, f"{fn}__online.npz"); np.savez(p, steps=steps / flow.width_dilation(64), f=out["online"].mean(0))
        s = score_one(fn, "online", p); res.append((s["traj"], s["onset"]))
        print(f"  {name:22s} {fn:10s} traj {s['traj']:.4f} onset {s['onset']:.3f}", flush=True)
    flow.ABL.clear(); flow.ABL.update(abl0)
    print(f"{name:22s} MEAN traj {np.mean([a for a, b in res]):.4f} onset {np.mean([b for a, b in res]):.3f}", flush=True)
shutil.rmtree(tmp, ignore_errors=True)
