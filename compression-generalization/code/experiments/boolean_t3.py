"""Training-data-only bound (Theorem 5 + Lemma 7) for a one-hidden-layer
network trained on a Boolean task, compared with the known-input-distribution
bound (Theorem 2) on the same network.

The T3 bound uses only the training sample: it is valid for whatever input
distribution generated it (here uniform, so the two bounds can be compared).

Usage: python boolean_t3.py --task maj5 --n 50 --m 16000 --width 32
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
from cgb.boolean import compress, final_bound
from cgb.data import make_target, uniform_cube
from cgb.dither import DitheredNet, certificate_v2, bad_event_prob
from cgb.models import MLP, train, np_predict

ap = argparse.ArgumentParser()
ap.add_argument("--task", default="maj5")
ap.add_argument("--n", type=int, default=50)
ap.add_argument("--m", type=int, default=16000)
ap.add_argument("--width", type=int, default=32)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--weight_noise", type=float, default=0.0)
ap.add_argument("--t1", type=float, default=5.8)
ap.add_argument("--t2", type=float, default=3.9)
ap.add_argument("--delta", type=float, default=0.04)
ap.add_argument("--delta_prime", type=float, default=0.01)
ap.add_argument("--out", default="../../results/boolean/t3.jsonl")
args = ap.parse_args()
torch.set_num_threads(1)
t0 = time.time()
n, m, H = args.n, args.m, args.width
target = make_target(args.task, n)
rng = np.random.default_rng(555 + args.seed)
Xtr = uniform_cube(n, m, rng)
ytr = target(Xtr)
f = MLP([n, H, 1], seed=args.seed)
init = f.weights()
tr = train(f, Xtr.astype(np.float32), ytr, epochs=3000, lr=1e-3, batch=64, seed=args.seed,
           stop_train_err=0.0, stop_loss=0.01, max_steps=60000, weight_noise=args.weight_noise)
F = f.weights()
fp = lambda X: np_predict(F, X)
Xt = uniform_cube(n, 300_000, np.random.default_rng(9))
test_err = float(np.mean(fp(Xt) != target(Xt)))
k_f = int(np.sum(fp(Xtr) != ytr))

B = np.eye(n)
ids = np.zeros(n, dtype=np.int64)
V = F[1][0]
alpha = np.abs(V[0]) + 1e-12
eta = bad_event_prob(H, 2, args.t1, args.t2)
Xtr64 = Xtr.astype(np.float64)


def make(gs, pu, seed):
    unit_exp = np.round(4 * np.log2(gs * 0.01 * (alpha / np.median(alpha)) ** (-pu))).astype(int)
    e_small = int(round(4 * math.log2(0.002 * gs)))
    return DitheredNet(F, init, B, ids, unit_exp, np.zeros(1, dtype=int), e_small, e_small, -40, seed=seed)


sel = secrets.randbits(63)
sub = np.random.default_rng(1).choice(m, min(m, 6000), replace=False)
best = None
for gs, pu in itertools.product([0.25, 0.5, 1, 2, 4, 8, 16, 32], [0.0, 0.5, 1.0]):
    g = make(gs, pu, sel)
    cert, _ = certificate_v2(g, Xtr64[sub], ytr[sub], t1=args.t1, t2=args.t2)
    bits = g.description().bits
    est = occam_bound(int(round((~cert).mean() * m)), m, bits, args.delta) + eta / args.delta_prime
    if best is None or est < best[0]:
        best = (est, gs, pu)
_, gs, pu = best
fin = secrets.randbits(63)
g = make(gs, pu, fin)
cert, _ = certificate_v2(g, Xtr64, ytr, t1=args.t1, t2=args.t2)
desc = g.description()
t3 = min(1.0, occam_bound(int((~cert).sum()), m, desc.bits, args.delta) + eta / args.delta_prime)

# known-distribution bound on the same f (Theorem 2), for comparison
f32 = [(W.astype(np.float32), b.astype(np.float32)) for W, b in F]
fp32 = lambda X: np_predict(f32, X)
bestd, _, _ = compress(fp32, n, Xtr, ytr, rng=np.random.default_rng(3), delta=0.05, log=lambda s: None)
cert_seed = secrets.randbits(63)
fb = final_bound(fp, bestd["g"], n, Xtr, ytr, rng=np.random.default_rng(cert_seed), delta=0.05)

res = {"task": args.task, "n": n, "m": m, "width": H, "seed": args.seed, "weight_noise": args.weight_noise,
       "params": f.num_params(), "train": tr, "train_err_f": k_f / m, "test_err_f": test_err,
       "t1": args.t1, "t2": args.t2, "eta": eta, "chosen": {"gs": gs, "pu": pu}, "dither_seed": str(fin),
       "t3_bits": desc.bits, "t3_code": desc.summary(), "cert_frac": float(cert.mean()), "T3_bound_f_anyD": t3,
       "T2known_bound_f": fb["bound_f"], "T2known_bits": fb["bits"], "T2known_label": bestd["label"],
       "T2known": fb, "m_train": m,
       "secs": round(time.time() - t0, 1)}
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print(json.dumps({k: res[k] for k in ["task", "m", "width", "weight_noise", "test_err_f", "cert_frac", "t3_bits",
                                      "T3_bound_f_anyD", "T2known_bound_f", "secs"]}))
