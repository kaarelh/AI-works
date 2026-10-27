"""T3: training-data-only bound on the ORIGINAL one-hidden-layer network f via
dithered compression (cgb/dither.py, Lemma 7 of the paper).

Step configuration is chosen with one dither draw on a subsample of the
training set; the reported bound uses a fresh dither drawn afterwards (from OS
entropy) and the full training set:
    err(f) <= Occam(#uncertified train points, L(g), delta) + eta / delta'.

Usage: python mnist_t3.py --data mnist --hidden 32 --epochs 20
"""
import argparse
import itertools
import json
import math
import os
import secrets
import sys
import time

import numpy as np
import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from cgb.bounds import occam_bound
from cgb.certify import dct_basis
from cgb.coded import band_ids_for
from cgb.data import load_images
from cgb.dither import DitheredNet, certificate_v2, bad_event_prob
from cgb.models import MLP, train, np_predict, deterministic_dct_init

ap = argparse.ArgumentParser()
ap.add_argument("--data", default="mnist")
ap.add_argument("--hidden", type=int, default=32)
ap.add_argument("--epochs", type=int, default=20)
ap.add_argument("--lr", type=float, default=1e-3)
ap.add_argument("--wd", type=float, default=0.0)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--basis", default="dct")
ap.add_argument("--t1", type=float, default=5.8)
ap.add_argument("--t2", type=float, default=3.9)
ap.add_argument("--delta", type=float, default=0.04)
ap.add_argument("--delta_prime", type=float, default=0.01)
ap.add_argument("--threads", type=int, default=4)
ap.add_argument("--weight_noise", type=float, default=0.0,
                help="train f with Gaussian weight noise of this std relative to each tensor's init RMS")
ap.add_argument("--code_ref", default="init", choices=["init", "zero"])
ap.add_argument("--init", default="random", choices=["random", "dct"])
ap.add_argument("--out", default="../../results/mnist/t3.jsonl")
args = ap.parse_args()
torch.set_num_threads(args.threads)
t0 = time.time()

Xtr, ytr, Xte, yte = load_images(args.data)
m = len(ytr)
widths = [784, args.hidden, 10]
f = MLP(widths, seed=args.seed)
if args.init == "dct":
    deterministic_dct_init(f)
init = f.weights()
extra = None
tr = train(f, Xtr, ytr, epochs=args.epochs, lr=args.lr, batch=128, wd=args.wd, seed=args.seed,
           weight_noise=args.weight_noise)
F = f.weights()
k_f = int(np.sum(np_predict(F, Xtr) != ytr))
test_f = float(np.mean(np_predict(F, Xte) != yte))
print(json.dumps({"hidden": args.hidden, "train_err_f": k_f / m, "test_err_f": test_f}), flush=True)

if args.basis == "dct":
    B, _ = dct_basis()
    ids = band_ids_for("dct", 784, (0, 4, 8, 14, 22, 32))
else:
    B = np.eye(784)
    ids = np.zeros(784, dtype=np.int64)
nb = int(ids.max()) + 1
rng = np.random.default_rng(0)
sub = rng.choice(m, 6000, replace=False)
Xh = Xtr[sub] @ B
bandrms = np.array([np.sqrt(np.mean(Xh[:, ids == j] ** 2)) + 1e-12 for j in range(nb)])
V = F[1][0]
alpha = np.sqrt((V ** 2).sum(0)) + 1e-12
H = args.hidden
eta = bad_event_prob(H, 10, args.t1, args.t2)


def make(gs, pb, pu, seed):
    band_exp = np.round(4 * np.log2(gs * 0.01 * (bandrms / bandrms[0]) ** (-pb))).astype(int)
    unit_exp = np.round(4 * np.log2((alpha / np.median(alpha)) ** (-pu))).astype(int)
    e_small = int(round(4 * math.log2(0.002 * gs)))
    ref = init if args.code_ref == "init" else [(0 * W, 0 * b) for W, b in init]
    return DitheredNet(F, ref, B, ids, unit_exp, band_exp, e_small, e_small, -40, seed=seed)


best = None
sel_seed = secrets.randbits(63)
for gs, pb, pu in itertools.product([0.25, 0.5, 1, 2, 4, 8], [0.5, 0.75, 1.0], [0.0, 0.5, 1.0]):
    g = make(gs, pb, pu, sel_seed)
    cert, _ = certificate_v2(g, Xtr[sub], ytr[sub], t1=args.t1, t2=args.t2)
    bits = g.description().bits
    kfail = int(round((~cert).mean() * m))
    est = occam_bound(kfail, m, bits, args.delta) + eta / args.delta_prime
    if best is None or est < best[0]:
        best = (est, gs, pb, pu)
    print(f"  gs={gs} pb={pb} pu={pu}: bits {bits:.0f} cert {cert.mean():.4f} est {est:.4f}", flush=True)

est, gs, pb, pu = best
final_seed = secrets.randbits(63)
g = make(gs, pb, pu, final_seed)
cert, slack = certificate_v2(g, Xtr, ytr, t1=args.t1, t2=args.t2)
desc = g.description()
kfail = int((~cert).sum())
bound = occam_bound(kfail, m, desc.bits, args.delta) + eta / args.delta_prime
res = {
    "data": args.data, "widths": widths, "seed": args.seed, "epochs": args.epochs, "wd": args.wd,
    "weight_noise": args.weight_noise, "code_ref": args.code_ref, "init": args.init, "params": f.num_params(), "train_err_f": k_f / m, "test_err_f": test_f,
    "basis": args.basis, "t1": args.t1, "t2": args.t2, "delta": args.delta, "delta_prime": args.delta_prime,
    "eta": eta, "chosen": {"gs": gs, "pb": pb, "pu": pu}, "dither_seed": str(final_seed),
    "bits": desc.bits, "code": desc.summary(), "cert_frac": float(cert.mean()),
    "test_err_g": float(np.mean(np_predict(g.weights(), Xte) != yte)),
    "T3_bound_f": min(1.0, bound), "secs": round(time.time() - t0, 1),
}
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print(json.dumps(res), flush=True)
