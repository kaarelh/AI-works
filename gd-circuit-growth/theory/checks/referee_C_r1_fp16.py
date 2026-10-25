"""Referee C r1: do the float16-saved final parameters reproduce the saved final test-set sign predictions?
The C1 certificates (c1_fourier_cert.py) certify the network rebuilt from params_fixed_adam_*.npz, which nn_train.py
stores as float16.  This compares that network's signs on the 4096 saved test inputs with the saved 'pred' at the
last checkpoint (computed in float32 during training)."""
import os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import nn_train as nt
RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")

def fwd(p, X):
    h1 = np.maximum(X @ p["W1"].T + p["b1"], 0)
    h2 = np.maximum(h1 @ p["W2"].T + p["b2"], 0)
    return h2 @ p["a"]

for fn in ["dict", "and3", "maj3", "maj9", "thr10", "par2", "par3", "par4", "dnf3", "majpar", "mux", "parmaj", "stair5"]:
    P = np.load(os.path.join(RESULTS, f"params_fixed_adam_{fn}.npz"))
    Z = np.load(os.path.join(RESULTS, f"fixed_adam_{fn}.npz"))
    Xte, yte = nt.make_test(fn)
    worst = 0.0; worst_err_gap = 0.0
    for i in range(len(Z["net_n"])):
        p = {k: P[k][i].astype(np.float32) for k in ["W1", "b1", "W2", "b2", "a"]}
        h16 = np.where(fwd(p, Xte) >= 0, 1.0, -1.0)
        pr = Z["pred"][-1, i, :].astype(np.float32); pr = np.where(pr == 0, 1.0, pr)
        dis = float(np.mean(h16 != pr))
        worst = max(worst, dis)
        worst_err_gap = max(worst_err_gap, abs(float(np.mean(h16 != yte)) - float(np.mean(pr != yte))))
    print(f"{fn:7s} nets={len(Z['net_n'])}  max disagreement(fp16 net, saved fp32 preds) = {worst:.5f}   "
          f"max |test err gap| = {worst_err_gap:.5f}   last step = {int(Z['step'][-1])}")
