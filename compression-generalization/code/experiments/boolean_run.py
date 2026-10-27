"""One Boolean run: train f, compress it, certify bounds on err(f).

Usage: python boolean_run.py --task parity3 --n 50 --m 2000 --seed 0 [--noise 0.1]
Writes one JSON line to --out.
"""
import argparse
import json
import math
import os
import sys
import time

import numpy as np
import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from cgb.bounds import occam_bound, vc_bound
from cgb.boolean import compress, final_bound, distribution_free_bound
from cgb.data import make_target, uniform_cube, all_inputs
from cgb.models import MLP, train, np_predict
from cgb import coding

ap = argparse.ArgumentParser()
ap.add_argument("--task", required=True)
ap.add_argument("--n", type=int, default=50)
ap.add_argument("--m", type=int, default=1000)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--noise", type=float, default=0.0)
ap.add_argument("--width", type=int, default=512)
ap.add_argument("--depth", type=int, default=2)
ap.add_argument("--init_scale", type=float, default=1.0)
ap.add_argument("--lr", type=float, default=1e-3)
ap.add_argument("--wd", type=float, default=0.0)
ap.add_argument("--epochs", type=int, default=2000)
ap.add_argument("--max_steps", type=int, default=40000)
ap.add_argument("--stop_loss", type=float, default=0.01)
ap.add_argument("--delta", type=float, default=0.05)
ap.add_argument("--out", default="../results/boolean/runs.jsonl")
ap.add_argument("--quick", action="store_true")
args = ap.parse_args()
torch.set_num_threads(1)
t_train = time.time()

t0 = time.time()
n, m = args.n, args.m
target = make_target(args.task, n, seed=0)
rng = np.random.default_rng(12345 + 1000 * args.seed + m)
Xtr = uniform_cube(n, m, rng)
ytr_clean = target(Xtr)
flip = rng.random(m) < args.noise
ytr = np.where(flip, 1 - ytr_clean, ytr_clean)

widths = [n] + [args.width] * args.depth + [1]
f = MLP(widths, init_scale=args.init_scale, seed=args.seed)
tr = train(f, Xtr.astype(np.float32), ytr, epochs=args.epochs, lr=args.lr, batch=64, wd=args.wd,
           seed=args.seed, stop_train_err=0.0, stop_loss=args.stop_loss, max_steps=args.max_steps)
Fw = f.weights()
t_train = time.time() - t_train
f_predict = lambda X: np_predict(Fw, X)          # float64: used for all certified quantities
Fw32 = [(W.astype(np.float32), b.astype(np.float32)) for W, b in Fw]


def f_predict32(X):                               # float32: used only to build / select g
    h = X.astype(np.float32)
    for W, b in Fw32[:-1]:
        h = np.maximum(h @ W.T + b, 0)
    return ((h @ Fw32[-1][0].T + Fw32[-1][1])[:, 0] > 0).astype(np.int64)
W = f.num_params()

# test error of f (exact for small n; else 10^6 fresh samples)
rng_test = np.random.default_rng(999 + args.seed)
if n <= 22:
    Xall = all_inputs(n)
    yall = target(Xall)
    pf = f_predict(Xall)
    test_err_clean = float(np.mean(pf != yall))
else:
    Xt = uniform_cube(n, 300_000, rng_test)
    test_err_clean = float(np.mean(f_predict(Xt) != target(Xt)))
# with label noise eta, err on noisy labels = eta + (1-2 eta) * clean err
test_err = args.noise + (1 - 2 * args.noise) * test_err_clean
k_tr = int(np.sum(f_predict(Xtr) != ytr))

rng_c = np.random.default_rng(777 + 1000 * args.seed + m)
kw = {}
if args.quick:
    kw = dict(widths_h=(0, 2, 8), rels=(0.25, 0.0625), distill_steps=1500, qat_steps=400)
best, cands, inf = compress(f_predict32, n, Xtr, ytr, rng=rng_c, delta=args.delta, seed=args.seed,
                            log=lambda s: None, **kw)
g = best["g"]
rng_f = np.random.default_rng(4242 + 1000 * args.seed + m)
fb = final_bound(f_predict, g, n, Xtr, ytr, rng=rng_f, delta=args.delta, f_all=pf if n <= 22 else None)
res = {
    "task": args.task, "n": n, "m": m, "seed": args.seed, "noise": args.noise,
    "widths": widths, "stop_loss": args.stop_loss, "init_scale": args.init_scale, "lr": args.lr, "wd": args.wd,
    "params": W, "train": tr, "train_err_f": k_tr / m,
    "test_err_f": test_err, "test_err_f_clean": test_err_clean,
    "best_label": best["label"], **fb,
    "baseline_occam32": occam_bound(k_tr, m, 32.0 * W + 64, args.delta),
    "baseline_vc_W": vc_bound(k_tr, m, W, args.delta),
    "num_candidates": len(cands),
    "top_influences": sorted([round(float(v), 4) for v in inf], reverse=True)[:8],
    "secs": round(time.time() - t0, 1), "secs_train": round(t_train, 1),
}
if n <= 22:
    res.update(distribution_free_bound(f_predict, g, n, Xtr, ytr, delta=args.delta, f_all=pf))
# oracle reference: Occam bound for the target itself within the class of k-juntas
k_rel = len(target.coords)
if k_rel <= 20:
    bits_j = 2 + coding.subset(n, k_rel) + 2 ** k_rel
    res["ref_junta_class_bound"] = occam_bound(int(np.sum(flip)), m, bits_j, args.delta)
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print(json.dumps({k: res[k] for k in ["task", "n", "m", "seed", "test_err_f", "bound_f", "bits", "best_label", "baseline_occam32", "secs"]}))
