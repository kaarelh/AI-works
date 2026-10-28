"""Does more search close the gap on dense targets?  Random restarts of a small student.

For a saved network f trained on a teacherK task (subsample_run.py saves f), train R
students of width k from independent random initializations, each for `steps` Adam
steps on f's soft labels over fresh inputs together with the training set (f's labels
there are the true labels).  Keep the restart with the best estimated bound on a
selection sample, quantize it (three step sizes), and certify it on 2x10^5 fresh
inputs (Theorem 2, the design charge, a 4-bit family prefix).  Also records, for
every restart, its training error and its disagreement with f and with the target,
so the success probability of a single restart can be read off.

Usage: python restarts_run.py --task teacher4 --param std --width 512 --k 4 --restarts 32 --out ...
"""
import argparse
import copy
import json
import math
import os
import secrets
import sys
import time

import numpy as np
import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
from accounting import DESIGN_BITS, DESIGN_FACTOR  # noqa: E402
from cgb.bounds import occam_bound, cp_upper  # noqa: E402
from cgb.codec import QuantMLP, distill  # noqa: E402
from cgb.data import make_target, uniform_cube  # noqa: E402
from cgb.models import MLP, np_forward  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--task", required=True)
ap.add_argument("--param", default="std")
ap.add_argument("--width", type=int, default=512)
ap.add_argument("--depth", type=int, default=1)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--k", type=int, default=4)
ap.add_argument("--restarts", type=int, default=32)
ap.add_argument("--steps", type=int, default=6000)
ap.add_argument("--qat_steps", type=int, default=600)
ap.add_argument("--out", required=True)
args = ap.parse_args()
torch.set_num_threads(1)
T0 = time.time()
n, m = 50, 16000
save_dir = os.environ.get("CGB_NETS", os.path.expanduser("~/.cache/cgb_nets"))
z = np.load(os.path.join(save_dir, f"{args.task}_{args.param}_{args.width}_d{args.depth}_s{args.seed}_m{m}.npz"))
arrs = [z[f"arr_{i}"] for i in range(len(z.files))]
L2 = len(arrs) // 2
Fw = [(arrs[2 * i], arrs[2 * i + 1]) for i in range(L2 // 2)]
f_logits = lambda X: np_forward(Fw, X)[:, 0]
target = make_target(args.task, n, seed=0)
rng = np.random.default_rng(12345 + 1000 * args.seed + m)       # the training set of subsample_run.py
Xtr = uniform_cube(n, m, rng)
ytr = target(Xtr)
rp = np.random.default_rng(777 + 1000 * args.seed + m)          # the same pools as subsample_run.py
Xfit = uniform_cube(n, 10_000, rp)
Xdis = uniform_cube(n, 100_000, rp)
Xsel = uniform_cube(n, 30_000, rp)
zdis, zsel = f_logits(Xdis), f_logits(Xsel)
ysel = (zsel > 0).astype(np.int64)
pdis = 1.0 / (1.0 + np.exp(-np.clip(zdis, -50, 50)))
reps = max(1, int(round(len(Xdis) / m)))
Xmix = np.concatenate([Xdis] + [Xtr] * reps).astype(np.float32)
ymix = np.concatenate([pdis] + [ytr.astype(np.float64)] * reps)
Xt = uniform_cube(n, 100_000, np.random.default_rng(999))
yt = target(Xt)


def predict(w, X):
    return (np_forward(w, X)[:, 0] > 0).astype(np.int64)


def estimate(w, bits):
    k_err = int(np.sum(predict(w, Xtr) != ytr))
    return occam_bound(k_err, m, bits + DESIGN_BITS + 4.0, 0.025) + float(np.mean(predict(w, Xsel) != ysel)), k_err


rows = []
best = None
for r in range(args.restarts):
    st = MLP([n, args.k, 1], seed=10_000 + 97 * r + args.k)
    distill(st, Xmix, ymix, steps=args.steps, lr=3e-3, seed=r, soft=True)
    w = st.weights()
    row = {"restart": r, "train_err": float(np.mean(predict(w, Xtr) != ytr)),
           "dis_f_sel": float(np.mean(predict(w, Xsel) != ysel)), "err_target": float(np.mean(predict(w, Xt) != yt))}
    for rel in (1.0, 0.5, 0.25):
        s2 = copy.deepcopy(st)
        exps = [(int(round(4 * math.log2(rel * float(np.sqrt(np.mean(W ** 2)))))),
                 int(round(4 * math.log2(rel * max(float(np.sqrt(np.mean(b ** 2))), float(np.sqrt(np.mean(W ** 2))))))))
                for W, b in s2.weights()]
        distill(s2, Xmix, ymix, steps=args.qat_steps, lr=1e-3, seed=r + 1000, qat_steps_exp=exps, soft=True)
        q = [(np.round(W / QuantMLP.step_value(eW)).astype(np.int64), np.round(b / QuantMLP.step_value(eb)).astype(np.int64))
             for (W, b), (eW, eb) in zip(s2.weights(), exps)]
        g = QuantMLP(n, np.arange(n), q, exps)
        est, k_err = estimate(g.weights(), g.bits)
        row[f"est_rel{rel}"] = est
        if best is None or est < best[0]:
            best = (est, g, r, rel, k_err)
    rows.append(row)
    print(json.dumps(row), flush=True)

est, g, r, rel, k_err = best
cert_seed = secrets.randbits(63)
Xc = uniform_cube(n, 200_000, np.random.default_rng(cert_seed))
dis = int(np.sum(g.predict(Xc) != (f_logits(Xc) > 0).astype(np.int64)))
bound = min(1.0, occam_bound(k_err, m, g.bits + DESIGN_BITS + 4.0, 0.025) + cp_upper(dis, 200_000, 0.025 / DESIGN_FACTOR))
res = {"task": args.task, "param": args.param, "width": args.width, "depth": args.depth, "seed": args.seed, "k": args.k,
       "restarts": args.restarts, "steps": args.steps, "rows": rows,
       "best": {"restart": r, "rel": rel, "bits": g.bits, "train_err_g": k_err, "dis_count": dis, "n_cert": 200_000,
                "bound_f": bound}, "cert_seed": str(cert_seed), "secs": round(time.time() - T0, 1)}
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print("best", json.dumps(res["best"]), f"{res['secs']:.0f}s")
