"""Like-for-like comparison of the trajectory models with network-to-network variability.

score.py compares a model with the 3-seed MEAN of the networks. Here every comparison is against SINGLE seeds:
  model vs seed      mean over seeds i of traj(model, seed i)
  seed vs seed       mean over pairs i != j of traj(seed i, seed j)
so a model that predicts as well as an independent rerun of the network scores the same as 'seed vs seed'.
(Equivalently, the irreducible error of the 3-seed-mean reference is about (seed vs seed)/6.)  Prints traj only.
"""
import os, sys, json, itertools, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from score import CONDS, interp_logstep
from analyze_traj import S_DIR, target_on_cube

PRED = {"fourier": os.path.join(HERE, "models/fourier/preds"), "gates": os.path.join(HERE, "models/gates/preds"),
        "flow": os.path.join(HERE, "models/flow/preds")}
PH = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/pred_heldout"
CAL = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]; HELD = ["andxor", "dlist5", "parmaj", "dnf3", "rand1", "rand3"]


def single_seeds(fn, cond):
    tag, prefix = CONDS[cond]
    z = np.load(os.path.join(S_DIR, f"traj_{tag}_{fn}.npz")); idx = [k for k, nm in enumerate(z["nets"]) if nm == prefix]
    y = target_on_cube(fn, z["pats"].astype(float), list(z["R"]))
    return z["steps"].astype(float), z["f_mean"][:, idx, :].astype(float), np.var(y)


def traj(a, b, m, vy):
    return float(np.mean(np.mean((a[m] - b[m]) ** 2, 1)) / vy)


out = {}
for split, fns in (("calibration", CAL), ("held-out", HELD)):
    for cond in CONDS:
        ss, ms = [], {m: [] for m in PRED}
        for fn in fns:
            steps, F, vy = single_seeds(fn, cond); msk = steps >= 1
            ss += [traj(F[:, i], F[:, j], msk, vy) for i, j in itertools.permutations(range(F.shape[1]), 2)]
            for m in PRED:
                d = PRED[m] if split == "calibration" else os.path.join(PH, m)
                z = np.load(os.path.join(d, f"{fn}__{cond}.npz"))
                fm = interp_logstep(z["steps"].astype(float), z["f"].astype(float), steps)
                ms[m] += [traj(fm, F[:, i], msk, vy) for i in range(F.shape[1])]
        out[f"{split}/{cond}"] = dict(seed_vs_seed=float(np.mean(ss)), **{m: float(np.mean(v)) for m, v in ms.items()})
print(f"{'split/cond':22s} {'seed-vs-seed':>12s} " + " ".join(f"{m:>8s}" for m in PRED))
for k, v in out.items():
    print(f"{k:22s} {v['seed_vs_seed']:12.4f} " + " ".join(f"{v[m]:8.4f}" for m in PRED))
json.dump(out, open(os.path.join(HERE, "fair_scores.json"), "w"), indent=1)
