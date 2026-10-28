"""MNIST: is a wide trained network close to a short surrogate found by subsampling?

Trains f = 784-N-10 (Adam, 20 epochs), then builds surrogates g with k << N
hidden units in three ways and codes each with the init-relative, DCT-banded
quantized code of the main paper (cgb.coded.CodedMLP), fine-tuned through the
quantizer by distillation from f with a rate penalty:

  topk / maurey  keep k units of f (top importance or Maurey sampling), refit
                 the output layer by least squares on f's logits, then code;
                 the kept units are coded relative to their (free) init rows,
                 plus the index set
  scratch        a k-unit network trained from its own seeded init to match f
                 (distillation from scratch), then coded the same way
  full           the CodedMLP of f itself (k = N), as in the main paper

The bound is Theorem 2 with Pr[f != g] measured on the 10,000 test images
without their labels, union-bounded over all K configurations tried for this f
(accounting.t2_bound).

Usage: python mnist_subsample.py --data mnist --hidden 1024 --out ...
"""
import argparse
import json
import math
import os
import sys
import time

import numpy as np
import torch
import torch.nn.functional as F

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
from accounting import t1_bound, t2_bound  # noqa: E402
from cgb import coding  # noqa: E402
from cgb.bounds import occam_bound, vc_bound  # noqa: E402
from cgb.coded import CodedMLP  # noqa: E402
from cgb.data import load_images  # noqa: E402
from cgb.models import MLP, train, np_predict, np_forward  # noqa: E402
from cgb import subsample as ss  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--data", default="mnist")
ap.add_argument("--hidden", type=int, default=1024)
ap.add_argument("--epochs", type=int, default=20)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--ks", default="32,64,128,256")
ap.add_argument("--methods", default="topk,maurey,scratch,full")
ap.add_argument("--rels", default="1,2")
ap.add_argument("--lams", default="3,10,30")
ap.add_argument("--qat_epochs", type=int, default=3)
ap.add_argument("--scratch_epochs", type=int, default=10)
ap.add_argument("--threads", type=int, default=1)
ap.add_argument("--out", required=True)
args = ap.parse_args()
torch.set_num_threads(args.threads)
T0 = time.time()
ks = [int(k) for k in args.ks.split(",")]
rels = [float(r) for r in args.rels.split(",")]
lams = [float(r) for r in args.lams.split(",")]
methods = args.methods.split(",")

Xtr, ytr, Xte, yte = load_images(args.data)
m, N = len(ytr), args.hidden
f = MLP([784, N, 10], seed=args.seed)
Iw = f.weights()
train(f, Xtr, ytr, epochs=args.epochs, lr=1e-3, batch=128, seed=args.seed)
Fw = f.weights()
pf_tr, pf_te = np_predict(Fw, Xtr), np_predict(Fw, Xte)
k_f = int(np.sum(pf_tr != ytr))
P = f.num_params()
base = {"data": args.data, "width": N, "seed": args.seed, "params": P, "train_err_f": k_f / m,
        "test_err_f": float(np.mean(pf_te != yte)),
        "baseline_occam32": occam_bound(k_f, m, 32.0 * P + 64, 0.05), "baseline_vc_W": vc_bound(k_f, m, P, 0.05)}
print(json.dumps(base), flush=True)

Xt = torch.as_tensor(Xtr)
with torch.no_grad():
    zf = f(Xt)
f_prob = F.softmax(zf, 1)
zf_np = zf.double().numpy()
rng_fit = np.random.default_rng(5 + args.seed)
fit_idx = rng_fit.choice(m, 20_000, replace=False)
Xfit, zfit = Xtr[fit_idx].astype(np.float64), zf_np[fit_idx]

(W1, b1), (V, c) = Fw
(W10, b10), (V0, c0) = Iw
Phi = ss.relu_features(W1, b1, Xfit)
imp = ss.unit_importance(V, Phi)
info = {"path_norm_A": float(imp.sum()), "eff_units": float(imp.sum() ** 2 / (imp ** 2).sum())}
print(json.dumps(info), flush=True)


def qat(g, lam, epochs, lr=1e-3, batch=256, seed=0):
    opt = torch.optim.Adam(g.parameters(), lr=lr)
    gen = torch.Generator().manual_seed(seed)
    steps = epochs * (m // batch)
    sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, T_max=max(1, steps))
    for ep in range(epochs):
        perm = torch.randperm(m, generator=gen)
        for s in range(0, m - batch + 1, batch):
            idx = perm[s:s + batch]
            loss = F.kl_div(F.log_softmax(g(Xt[idx]), 1), f_prob[idx], reduction="batchmean")
            loss = loss + lam * g.rate_penalty() / m
            opt.zero_grad()
            loss.backward()
            opt.step()
            sched.step()
    return g


def scratch_student(k, seed):
    st = MLP([784, k, 10], seed=1000 + seed + k)
    init = st.weights()
    opt = torch.optim.Adam(st.parameters(), lr=1e-3)
    gen = torch.Generator().manual_seed(seed)
    for ep in range(args.scratch_epochs):
        perm = torch.randperm(m, generator=gen)
        for s in range(0, m - 127, 128):
            idx = perm[s:s + 128]
            loss = F.kl_div(F.log_softmax(st(Xt[idx]), 1), f_prob[idx], reduction="batchmean")
            opt.zero_grad()
            loss.backward()
            opt.step()
    return st.weights(), init


rows = []
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)


def run_config(method, k, gw, ref, extra_bits, rel, lam):
    t1 = time.time()
    g = CodedMLP(gw, ref, ["dct", "id"], rel_step=rel)
    qat(g, lam, args.qat_epochs, seed=args.seed)
    Gw = g.weights()
    pg_tr, pg_te = np_predict(Gw, Xtr), np_predict(Gw, Xte)
    desc = g.description()
    for name, b in extra_bits.items():
        desc.add(name, b)
    r = dict(base, method=method, k=k, rel=rel, lam=lam, bits=desc.bits, code=desc.summary(),
             train_err_g=float(np.mean(pg_tr != ytr)), test_err_g=float(np.mean(pg_te != yte)),
             dis_count=int(np.sum(pg_te != pf_te)), n_unlabeled=len(yte), dis_test_inputs=float(np.mean(pg_te != pf_te)),
             train_dis=float(np.mean(pg_tr != pf_tr)), secs=round(time.time() - t1, 1), info=info)
    r["T1_bound_g"] = t1_bound(r)
    rows.append(r)
    print(json.dumps({x: r[x] for x in ["method", "k", "rel", "lam", "bits", "train_err_g", "dis_test_inputs",
                                         "T1_bound_g", "secs"]}), flush=True)


for method in methods:
    for k in (ks if method != "full" else [N]):
        if method == "full":
            gw, ref, extra = Fw, Iw, {}
        elif method == "scratch":
            gw, ref = scratch_student(k, args.seed)
            extra = {"student seed / width": coding.elias_delta(k)}
            ref = [ref[0], (0 * ref[1][0], 0 * ref[1][1])]
        else:
            gw_, idx, _ = ss.subsample_one_layer(Fw, k, Xfit, np.random.default_rng(10_000 * k), method, refit=True)
            gw = gw_
            ref = [(W10[idx], b10[idx]), (0 * gw_[1][0], 0 * gw_[1][1])]
            extra = {"unit indices": coding.elias_delta(N) + coding.elias_delta(len(idx)) + coding.subset(N, len(idx))}
            fd = float(np.mean(np_predict(gw, Xte) != pf_te))
            print(json.dumps({"method": method, "k": k, "unique": int(len(idx)), "float_refit_dis_test": fd}), flush=True)
        for rel in rels:
            for lam in lams:
                run_config(method, k, gw, ref, extra, rel, lam)

K = len(rows)
for r in rows:
    r["K"] = K
    r["T2_bound_f"] = t2_bound(r, K)
best = min(rows, key=lambda r: r["T2_bound_f"])
with open(args.out, "a") as fh:
    for r in rows:
        fh.write(json.dumps(r) + "\n")
print("best", json.dumps({x: best[x] for x in ["method", "k", "rel", "lam", "bits", "dis_test_inputs", "T2_bound_f"]}))
for meth in methods:
    rr = [r for r in rows if r["method"] == meth]
    if rr:
        b = min(rr, key=lambda r: r["T2_bound_f"])
        print(meth, json.dumps({x: b[x] for x in ["k", "rel", "lam", "bits", "dis_test_inputs", "T2_bound_f"]}))
print(f"done in {time.time() - T0:.0f}s")
