"""Initialization study on Boolean tasks: the init-kernel codec (theory Prop. 9)
versus function-space distillation, in lazy and rich training regimes.

f = v . relu(W x + b) + c on {-1,1}^n.  theta0 = its initialization (free).
Init-kernel codec: F0 = E_x[J(x)^T J(x)] under uniform x (estimated from
N_mc fresh inputs, a function of theta0 only), U_r its top-r eigenvectors;
g_r has parameters theta0 + U_r q_r * step with q_r = round(U_r^T Delta / step).
Its description: r, the step, and the r integers.  The bound on f is
Theorem 2 with Pr[f != g_r] estimated on fresh uniform inputs.

Usage: python init_kernel.py --task maj5 --n 30 --m 2000 --regime lazy
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
from cgb import coding
from cgb.bounds import occam_bound, cp_upper
from cgb.boolean import compress, final_bound
from cgb.data import make_target, uniform_cube
from cgb.models import MLP, train, np_predict, np_forward

ap = argparse.ArgumentParser()
ap.add_argument("--task", default="maj5")
ap.add_argument("--n", type=int, default=30)
ap.add_argument("--m", type=int, default=2000)
ap.add_argument("--width", type=int, default=1024)
ap.add_argument("--regime", default="lazy", choices=["lazy", "rich", "standard"])
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--n_mc", type=int, default=6000)
ap.add_argument("--delta", type=float, default=0.05)
ap.add_argument("--out", default="../../results/init/init_kernel.jsonl")
args = ap.parse_args()
torch.set_num_threads(int(os.environ.get("OMP_NUM_THREADS", "4")))
t0 = time.time()
n, m, H = args.n, args.m, args.width
target = make_target(args.task, n)
rng = np.random.default_rng(100 + args.seed)
Xtr = uniform_cube(n, m, rng)
ytr = target(Xtr)

if args.regime == "lazy":
    init_scale, opt, lr = 2.0, "sgd", 0.02
elif args.regime == "rich":
    init_scale, opt, lr = 0.1, "adam", 1e-3
else:
    init_scale, opt, lr = 1.0, "adam", 1e-3
f = MLP([n, H, 1], init_scale=init_scale, seed=args.seed)
th0 = f.weights()
tr = train(f, Xtr.astype(np.float32), ytr, epochs=3000, lr=lr, batch=64, opt=opt, seed=args.seed,
           stop_train_err=0.0, stop_loss=0.05, max_steps=60000)
th = f.weights()
fp = lambda X: np_predict(th, X)
Xt = uniform_cube(n, 200_000, np.random.default_rng(7))
test_err = float(np.mean(fp(Xt) != target(Xt)))


def flat(ws):
    return np.concatenate([np.concatenate([W.ravel(), b.ravel()]) for W, b in ws])


def unflat(vec, like):
    out, i = [], 0
    for W, b in like:
        Wn = vec[i:i + W.size].reshape(W.shape); i += W.size
        bn = vec[i:i + b.size]; i += b.size
        out.append((Wn, bn))
    return out


def jacobian(ws, X):
    """J (N x P) of the scalar output w.r.t. (W, b, v, c), in flat order."""
    (W, b), (v, c) = ws
    U = X @ W.T + b
    act = (U > 0).astype(np.float64)
    gW = (act * v[0])[:, :, None] * X[:, None, :]          # N x H x n
    gb = act * v[0]
    gv = np.maximum(U, 0)
    gc = np.ones((X.shape[0], 1))
    return np.concatenate([gW.reshape(X.shape[0], -1), gb, gv, gc], axis=1)


def jvp(ws, X, Dvec):
    """J(x) Dvec for each row of X without forming J."""
    (W, b), (v, c) = ws
    (dW, db), (dv, dc) = unflat(Dvec, ws)
    U = X @ W.T + b
    act = (U > 0).astype(np.float64)
    return (act * (X @ dW.T + db)) @ v[0] + np.maximum(U, 0) @ dv[0] + dc[0]


D = flat(th) - flat(th0)
rel_move = float(np.linalg.norm(D) / np.linalg.norm(flat(th0)))
Xmc = uniform_cube(n, args.n_mc, np.random.default_rng(11)).astype(np.float64)
J = jacobian(th0, Xmc) / math.sqrt(args.n_mc)
# top eigenvectors of F0 = J^T J via the SVD of J
_, sv, Vt = np.linalg.svd(J, full_matrices=False)
# linearization quality
f0 = np_forward(th0, Xt[:50_000])[:, 0]
flin = f0 + jvp(th0, Xt[:50_000].astype(np.float64), D)
lin_dis = float(np.mean((flin > 0) != (np_forward(th, Xt[:50_000])[:, 0] > 0)))

Xsel = uniform_cube(n, 30_000, np.random.default_rng(13))
ysel = fp(Xsel)
results = []
best = None
for r in [8, 16, 31, 64, 128, 256, 466, 1024, 2048, 4526]:
    if r > Vt.shape[0]:
        break
    coef = Vt[:r] @ D
    for rel in [0.5, 0.25, 0.125, 0.0625]:
        step_e = int(round(4 * math.log2(rel * (np.sqrt(np.mean(coef ** 2)) + 1e-12))))
        step = 2.0 ** (step_e / 4)
        q = np.round(coef / step).astype(np.int64)
        g = unflat(flat(th0) + Vt[:r].T @ (q * step), th0)
        bits = 32 + coding.elias_delta(r) + coding.signed_int(step_e) + coding.best_tensor_code(q) + 2
        k_err = int(np.sum(np_predict(g, Xtr) != ytr))
        dis = float(np.mean(np_predict(g, Xsel) != ysel))
        est = occam_bound(k_err, m, bits, args.delta / 2) + dis
        results.append({"r": r, "rel": rel, "bits": bits, "train_err_g": k_err / m, "sel_dis": dis, "est": est})
        if best is None or est < best["est"]:
            best = dict(results[-1], g=g)
# final certification for the best init-kernel g on fresh inputs
Xc = uniform_cube(n, 200_000, np.random.default_rng(17))
dk = int(np.sum(fp(Xc) != np_predict(best["g"], Xc)))
k_err = int(round(best["train_err_g"] * m))
kernel_bound = min(1.0, occam_bound(k_err, m, best["bits"], args.delta / 2) + cp_upper(dk, len(Xc), args.delta / 2))

# function-space distillation codec on the same f, for comparison
fp32 = lambda X: np_predict(th, X)
bestd, _, _ = compress(fp32, n, Xtr, ytr, rng=np.random.default_rng(19), delta=args.delta, log=lambda s: None)
fb = final_bound(fp, bestd["g"], n, Xtr, ytr, rng=np.random.default_rng(23), delta=args.delta)

res = {"task": args.task, "n": n, "m": m, "width": H, "regime": args.regime, "seed": args.seed,
       "init_scale": init_scale, "opt": opt, "lr": lr, "train": tr, "test_err_f": test_err,
       "rel_param_move": rel_move, "lin_disagreement": lin_dis,
       "kernel_spectrum_top": [float(x) for x in sv[:12] ** 2],
       "kernel_codec": {k: v for k, v in best.items() if k != "g"}, "kernel_bound_f": kernel_bound,
       "kernel_sweep": results,
       "distill_bound_f": fb["bound_f"], "distill_bits": fb["bits"], "distill_label": bestd["label"],
       "secs": round(time.time() - t0, 1)}
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print(json.dumps({k: res[k] for k in ["task", "regime", "m", "test_err_f", "rel_param_move", "lin_disagreement",
                                      "kernel_bound_f", "distill_bound_f", "distill_bits", "secs"]}),
      json.dumps(res["kernel_codec"]))
