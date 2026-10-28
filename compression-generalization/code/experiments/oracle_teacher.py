"""The search gap on teacher targets: how good would the bound be if the search
found the target itself?

For each saved network f trained on a teacherK task (subsample_run.py saves f to
$CGB_NETS, default ~/.cache/cgb_nets), code the true teacher network as a
quantized QuantMLP at several step sizes and compute Theorem 2 for it: its
training errors, its description length, and its disagreement with f on 2x10^5
fresh inputs.  This is a description no search was given; it upper-bounds what
an unlimited search over this description language could certify, and so
measures how far the polynomial-time searches are from it.

Usage: python oracle_teacher.py --out ../../results/search/oracle_teacher.jsonl
"""
import argparse
import glob
import json
import math
import os
import secrets
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
from accounting import boolean_bound  # noqa: E402
from cgb.codec import QuantMLP  # noqa: E402
from cgb.data import make_target, uniform_cube  # noqa: E402
from cgb.models import np_forward  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--out", required=True)
ap.add_argument("--n", type=int, default=50)
ap.add_argument("--m", type=int, default=16000)
args = ap.parse_args()
n, m = args.n, args.m
save_dir = os.environ.get("CGB_NETS", os.path.expanduser("~/.cache/cgb_nets"))
out = []
for path in sorted(glob.glob(os.path.join(save_dir, "teacher*_m%d.npz" % m))):
    name = os.path.basename(path)[:-4]
    task, param, width, depth, seed = name.split("_")[:5]
    seed = int(seed[1:])
    z = np.load(path)
    arrs = [z[f"arr_{i}"] for i in range(len(z.files))]
    L = len(arrs) // 2
    Fw = [(arrs[2 * i], arrs[2 * i + 1]) for i in range(L // 2)]
    target = make_target(task, n, seed=0)
    U, v, t = target.table
    rng = np.random.default_rng(12345 + 1000 * seed + m)       # the training set of subsample_run.py
    Xtr = uniform_cube(n, m, rng)
    ytr = target(Xtr)
    cert_seed = secrets.randbits(63)
    Xc = uniform_cube(n, 200_000, np.random.default_rng(cert_seed))
    fc = (np_forward(Fw, Xc)[:, 0] > 0).astype(np.int64)
    rows = []
    for rel in (0.25, 0.125, 0.0625, 0.03125, 0.015625, 0.0078125, 0.00390625):
        eU = int(round(4 * math.log2(rel * np.sqrt(np.mean(U ** 2)))))
        ev = int(round(4 * math.log2(rel)))
        et = int(round(4 * math.log2(rel * max(abs(t), 1e-3))))
        qU = np.round(U / QuantMLP.step_value(eU)).astype(np.int64)
        qv = np.round(v[None, :] / QuantMLP.step_value(ev)).astype(np.int64)
        qt = np.round(np.array([-t]) / QuantMLP.step_value(et)).astype(np.int64)
        g = QuantMLP(n, np.arange(n), [(qU, np.zeros(len(v), dtype=np.int64)), (qv, qt)], [(eU, eU), (ev, et)])
        k_err = int(np.sum(g.predict(Xtr) != ytr))
        dis = int(np.sum(g.predict(Xc) != fc))
        r = {"m": m, "bits": g.bits + 3.0, "train_err_g": k_err, "dis_count": dis, "n_cert": 200_000}
        rows.append({"rel": rel, "bits": r["bits"], "train_err_g": k_err, "dis_hat": dis / 2e5,
                     "target_err_of_g": float(np.mean(g.predict(Xc) != target(Xc))), "bound_f": boolean_bound(r)})
    best = min(rows, key=lambda x: x["bound_f"])
    rec = {"net": name, "task": task, "param": param, "width": int(width), "depth": int(depth[1:]), "seed": seed,
           "test_err_f_vs_target": float(np.mean(fc != target(Xc))), "oracle": rows, "best": best,
           "cert_seed": str(cert_seed)}
    out.append(rec)
    print(name, json.dumps(best), flush=True)
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "w") as fh:
    for r in out:
        fh.write(json.dumps(r) + "\n")
