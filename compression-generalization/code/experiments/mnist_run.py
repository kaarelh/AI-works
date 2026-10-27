"""MNIST / Fashion-MNIST: train f, compress, and bound err(f).

Bounds reported (delta = 0.05 split as stated):
  T1  Occam bound for the compressed network g itself (training data only).
  T2  bound on f: Occam(g) + Clopper-Pearson upper bound on Pr[f != g]
      measured on the 10k test IMAGES without their labels (delta/2 each).
  baselines: Occam with 32-bit parameters; VC bound with d = #params.

Usage: python mnist_run.py --data mnist --hidden 256 --epochs 20 --out ...
"""
import argparse
import copy
import json
import math
import os
import sys
import time

import numpy as np
import torch
import torch.nn.functional as F

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from cgb.bounds import occam_bound, cp_upper, vc_bound
from cgb.coded import CodedMLP, init_weights_of
from cgb.data import load_images
from cgb.models import MLP, train, np_predict, deterministic_dct_init

ap = argparse.ArgumentParser()
ap.add_argument("--data", default="mnist")
ap.add_argument("--hidden", type=int, nargs="+", default=[256])
ap.add_argument("--epochs", type=int, default=20)
ap.add_argument("--lr", type=float, default=1e-3)
ap.add_argument("--wd", type=float, default=0.0)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--init_scale", type=float, default=1.0)
ap.add_argument("--qat_epochs", type=int, default=6)
ap.add_argument("--rels", type=float, nargs="+", default=[0.5, 1.0, 2.0])
ap.add_argument("--lams", type=float, nargs="+", default=[0.3, 1.0, 3.0])
ap.add_argument("--bases", nargs="+", default=["id", "dct"])
ap.add_argument("--modes", nargs="+", default=["labels", "distill"])
ap.add_argument("--threads", type=int, default=4)
ap.add_argument("--delta", type=float, default=0.05)
ap.add_argument("--save_f", default=None)
ap.add_argument("--code_ref", default="init", choices=["init", "zero"],
                help="code the weights relative to f's initialization (free) or to zero")
ap.add_argument("--init", default="random", choices=["random", "dct"],
                help="random (seeded) init, or a deterministic one: first-layer rows = lowest-frequency DCT vectors, last layer 0")
ap.add_argument("--out", default="../../results/mnist/runs.jsonl")
args = ap.parse_args()
torch.set_num_threads(args.threads)
t0 = time.time()

Xtr, ytr, Xte, yte = load_images(args.data)
m = len(ytr)
widths = [784] + args.hidden + [10]
f = MLP(widths, init_scale=args.init_scale, seed=args.seed)
if args.init == "dct":
    deterministic_dct_init(f)
init = f.weights()
tr = train(f, Xtr, ytr, epochs=args.epochs, lr=args.lr, batch=128, wd=args.wd, seed=args.seed)
Fw = f.weights()
if args.save_f:
    np.savez(args.save_f, *[a for wb in Fw for a in wb], *[a for wb in init for a in wb])
pf_tr = np_predict(Fw, Xtr)
pf_te = np_predict(Fw, Xte)
k_f = int(np.sum(pf_tr != ytr))
W = f.num_params()
base = {
    "data": args.data, "widths": widths, "seed": args.seed, "lr": args.lr, "wd": args.wd,
    "init_scale": args.init_scale, "init": args.init, "code_ref": args.code_ref, "epochs": args.epochs, "params": W,
    "train_err_f": k_f / m, "test_err_f": float(np.mean(pf_te != yte)),
    "baseline_occam32": occam_bound(k_f, m, 32.0 * W + 64, args.delta),
    "baseline_vc_W": vc_bound(k_f, m, W, args.delta),
    "secs_train_f": round(time.time() - t0, 1),
}
print(json.dumps(base), flush=True)

Xt = torch.as_tensor(Xtr)
yt = torch.as_tensor(ytr)
with torch.no_grad():
    f_logits = f(Xt)
f_prob = F.softmax(f_logits, 1)


def qat(g, mode, lam, epochs, lr=1e-3, batch=256, seed=0):
    opt = torch.optim.Adam(g.parameters(), lr=lr)
    gen = torch.Generator().manual_seed(seed)
    steps = epochs * (m // batch)
    sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, T_max=steps)
    for ep in range(epochs):
        perm = torch.randperm(m, generator=gen)
        for s in range(0, m - batch + 1, batch):
            idx = perm[s:s + batch]
            out = g(Xt[idx])
            if mode == "labels":
                loss = F.cross_entropy(out, yt[idx])
            elif mode == "distill":
                loss = F.kl_div(F.log_softmax(out, 1), f_prob[idx], reduction="batchmean")
            else:  # "mixed": half labels, half teacher
                loss = 0.5 * F.cross_entropy(out, yt[idx]) + 0.5 * F.kl_div(
                    F.log_softmax(out, 1), f_prob[idx], reduction="batchmean")
            loss = loss + lam * g.rate_penalty() / m  # ~ lam * (#nonzero steps) per example
            opt.zero_grad()
            loss.backward()
            opt.step()
            sched.step()
    return g


os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
for basis in args.bases:
    kinds = [basis] + ["id"] * (len(widths) - 2)
    for mode in args.modes:
        for rel in args.rels:
            for lam in args.lams:
                t1 = time.time()
                ref = init if args.code_ref == "init" else [(0 * W, 0 * b) for W, b in init]
                g = CodedMLP(Fw, ref, kinds, rel_step=rel)
                qat(g, mode, lam, args.qat_epochs, seed=args.seed)
                Gw = g.weights()
                pg_tr = np_predict(Gw, Xtr)
                pg_te = np_predict(Gw, Xte)
                k_g = int(np.sum(pg_tr != ytr))
                desc = g.description()
                bits = desc.bits
                dis_k = int(np.sum(pg_te != pf_te))
                occ = occam_bound(k_g, m, bits, args.delta)
                occ2 = occam_bound(k_g, m, bits, args.delta / 2)
                cpu = cp_upper(dis_k, len(yte), args.delta / 2)
                nz = sum(int(np.count_nonzero(q)) for q, _ in g.integers())
                res = dict(base, basis=basis, mode=mode, rel=rel, lam=lam, qat_epochs=args.qat_epochs,
                           bits=bits, nonzeros=nz, code=desc.summary(),
                           train_err_g=k_g / m, test_err_g=float(np.mean(pg_te != yte)),
                           T1_bound_g=occ, dis_test_inputs=dis_k / len(yte), dis_count=dis_k, n_unlabeled=len(yte),
                           train_dis=float(np.mean(pg_tr != pf_tr)), dis_upper=cpu,
                           T2_bound_f=min(1.0, occ2 + cpu), secs=round(time.time() - t1, 1))
                with open(args.out, "a") as fh:
                    fh.write(json.dumps(res) + "\n")
                print(json.dumps({k: res[k] for k in ["basis", "mode", "rel", "lam", "bits", "nonzeros",
                                                      "train_err_g", "test_err_g", "T1_bound_g",
                                                      "dis_test_inputs", "T2_bound_f", "secs"]}), flush=True)
