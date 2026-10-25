"""Algorithmic vs data randomness: refit SSWM on the SAME training set with different rngs and measure
prediction agreement on the test set; compare with agreement across the three data seeds."""
import os, sys
os.environ.setdefault("OMP_NUM_THREADS", "1")
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import numpy as np, common as C
from models.sswm import SSWM
M = SSWM()
cells = [("dict", 32), ("maj3", 64), ("maj9", 128), ("thr10", 256), ("par2", 128), ("majpar", 512), ("mux", 512),
         ("stair5", 512), ("dnf3", 256), ("parmaj", 512)]
for fn, n in cells:
    Xte, yte = C.test_data(fn); X, y = C.train_data(fn, 0, n)
    P = [M.fit(X, y, np.random.default_rng([99, k]))["predict"](Xte) for k in range(4)]
    same = np.mean([np.mean(P[i] == P[j]) for i in range(4) for j in range(i + 1, 4)])
    errs = [np.mean(p != yte) for p in P]
    nn = C.nn_fixed(fn); a = list(nn["ns"]).index(n); Q = nn["pred"][a]
    nn_same = np.nan
    print(f"{fn:8s} n={n:5d} sswm err (same data, 4 rngs) {np.mean(errs):.2f}+-{np.std(errs):.2f}  agreement same-data {same:.3f}"
          f" | NN err {nn['test_err'][a].mean():.2f}, NN-vs-sswm(seed0 data) {np.mean([np.mean(Q[0] == p) for p in P]):.3f}", flush=True)
