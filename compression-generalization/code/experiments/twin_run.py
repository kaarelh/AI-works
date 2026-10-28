"""Bound a trained network by a twin trained on part of its own training set.

f is trained on all of S.  A twin f_s is trained, with the same algorithm and
hyperparameters (and the same seed unless --twin_seed other), on a subset S_I of
s training points fixed before the data are seen (the first s points for Boolean
tasks, a fixed random permutation for images).  Then

    err(f) <= err(f_s) + Pr_x[f(x) != f_s(x)],

err(f_s) is bounded by its errors on the m - s held-out points S \\ I (which f_s
never saw; exact binomial tail), and Pr[f != f_s] is bounded by a
Clopper-Pearson interval on fresh inputs from the known input distribution
(Boolean tasks) or on unlabeled test inputs (images; these are assumed to be
i.i.d. from the training input distribution, as in Theorem 2's experiments).
Each row (one fraction) is a valid bound on its own; frac = 0.5 is the
pre-registered choice and the other fractions are diagnostics (reporting the
best of several would need a union bound).  No description length
and no search: the training algorithm plays the role of the decoder, and
fixing I in advance removes the union bound of sample compression.

Usage:
  python twin_run.py boolean --task parity3 --m 16000 --fracs 0.5 --out ...
  python twin_run.py images --data mnist --hidden 256 --fracs 0.5 --out ...
"""
import argparse
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
from cgb.bounds import binom_upper, cp_upper, occam_bound  # noqa: E402
from cgb.data import make_target, uniform_cube, load_images  # noqa: E402
from cgb.models import MLP, train, np_predict  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("kind", choices=["boolean", "images"])
ap.add_argument("--task", default="parity3")
ap.add_argument("--data", default="mnist")
ap.add_argument("--n", type=int, default=50)
ap.add_argument("--m", type=int, default=16000)
ap.add_argument("--noise", type=float, default=0.0)
ap.add_argument("--width", type=int, default=512)
ap.add_argument("--depth", type=int, default=2)
ap.add_argument("--hidden", type=int, default=256)
ap.add_argument("--epochs", type=int, default=20)
ap.add_argument("--fracs", default="0.25,0.5,0.75")
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--twin_seed", default="same", choices=["same", "other"])
ap.add_argument("--delta", type=float, default=0.05)
ap.add_argument("--threads", type=int, default=1)
ap.add_argument("--out", required=True)
args = ap.parse_args()
torch.set_num_threads(args.threads)
T0 = time.time()
fracs = [float(x) for x in args.fracs.split(",")]


def run_key(r):
    common = (r["kind"], r["seed"], r["twin_seed"], tuple(t["frac"] for t in r["twins"]))
    return common + ((r["task"], r["noise"], r["m"]) if r["kind"] == "boolean" else (r["data"], r["widths"][1]))


# Skip a configuration that already has a result (lets several runners share one job list).
my_key = (args.kind, args.seed, args.twin_seed, tuple(fracs)) + (
    (args.task, args.noise, args.m) if args.kind == "boolean" else (args.data, args.hidden))
if os.path.exists(args.out) and any(run_key(json.loads(l)) == my_key for l in open(args.out) if l.strip()):
    print("exists:", my_key)
    sys.exit(0)
d1 = d2 = args.delta / 2
tseed = args.seed if args.twin_seed == "same" else args.seed + 100

if args.kind == "boolean":
    n, m = args.n, args.m
    target = make_target(args.task, n, seed=0)
    rng = np.random.default_rng(12345 + 1000 * args.seed + m)   # same training sets as the main grid
    Xtr = uniform_cube(n, m, rng)
    yclean = target(Xtr)
    flip = rng.random(m) < args.noise
    ytr = np.where(flip, 1 - yclean, yclean)
    widths = [n] + [args.width] * args.depth + [1]

    def fit(X, y, seed):
        net = MLP(widths, seed=seed)
        tr = train(net, X.astype(np.float32), y, epochs=100000, lr=1e-3, batch=64, seed=seed,
                   stop_train_err=0.0, stop_loss=0.01, max_steps=40000)
        return net.weights(), tr

    Fw, trf = fit(Xtr, ytr, args.seed)
    Xt = uniform_cube(n, 300_000, np.random.default_rng(999 + args.seed))
    yt = target(Xt)
    err_clean = lambda w: float(np.mean(np_predict(w, Xt) != yt))
    test_f = args.noise + (1 - 2 * args.noise) * err_clean(Fw)
    rows = []
    for frac in fracs:
        s = int(round(frac * m))
        Tw, trt = fit(Xtr[:s], ytr[:s], tseed)
        k_out = int(np.sum(np_predict(Tw, Xtr[s:]) != ytr[s:]))
        cert_seed = secrets.randbits(63)
        Xc = uniform_cube(n, 200_000, np.random.default_rng(cert_seed))
        dis_k = int(np.sum(np_predict(Fw, Xc) != np_predict(Tw, Xc)))
        e_up = binom_upper(k_out, m - s, math.log(d1))
        d_up = cp_upper(dis_k, 200_000, d2)
        rows.append({"frac": frac, "s": s, "heldout_errors": k_out, "heldout_n": m - s, "err_twin_upper": e_up,
                     "dis_count": dis_k, "n_cert": 200_000, "dis_upper": d_up, "bound_f": min(1.0, e_up + d_up),
                     "test_err_twin": args.noise + (1 - 2 * args.noise) * err_clean(Tw), "cert_seed": str(cert_seed),
                     "train_twin": trt})
        print(json.dumps({x: rows[-1][x] for x in ["frac", "heldout_errors", "err_twin_upper", "dis_upper",
                                                    "bound_f", "test_err_twin"]}), flush=True)
    res = {"kind": "boolean", "task": args.task, "n": n, "m": m, "noise": args.noise, "widths": widths,
           "seed": args.seed, "twin_seed": args.twin_seed, "test_err_f": test_f, "train_f": trf, "twins": rows}
else:
    Xtr, ytr, Xte, yte = load_images(args.data)
    m = len(ytr)
    perm = np.random.default_rng(31).permutation(m)        # fixed in advance, data-independent
    widths = [784, args.hidden, 10]

    def fit(idx, seed):
        net = MLP(widths, seed=seed)
        train(net, Xtr[idx], ytr[idx], epochs=args.epochs, lr=1e-3, batch=128, seed=seed)
        return net.weights()

    Fw = fit(np.arange(m), args.seed)
    pf_te = np_predict(Fw, Xte)
    test_f = float(np.mean(pf_te != yte))
    rows = []
    for frac in fracs:
        s = int(round(frac * m))
        I, R = perm[:s], perm[s:]
        Tw = fit(np.sort(I), tseed)
        k_out = int(np.sum(np_predict(Tw, Xtr[R]) != ytr[R]))
        pt = np_predict(Tw, Xte)
        dis_k = int(np.sum(pt != pf_te))                       # test images used without their labels
        e_up = binom_upper(k_out, m - s, math.log(d1))
        d_up = cp_upper(dis_k, len(yte), d2)
        rows.append({"frac": frac, "s": s, "heldout_errors": k_out, "heldout_n": m - s, "err_twin_upper": e_up,
                     "dis_count": dis_k, "n_unlabeled": len(yte), "dis_upper": d_up, "bound_f": min(1.0, e_up + d_up),
                     "test_err_twin": float(np.mean(pt != yte))})
        print(json.dumps({x: rows[-1][x] for x in ["frac", "heldout_errors", "err_twin_upper", "dis_upper",
                                                    "bound_f", "test_err_twin"]}), flush=True)
    res = {"kind": "images", "data": args.data, "widths": widths, "epochs": args.epochs, "seed": args.seed,
           "twin_seed": args.twin_seed, "test_err_f": test_f, "twins": rows}
res["delta"] = args.delta
res["secs"] = round(time.time() - T0, 1)
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print(f"test err f {res['test_err_f']:.4f}; done in {res['secs']:.0f}s")
