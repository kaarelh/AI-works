"""The ablations' parity noise-floor rule (models/ablation_diagnostics.py floor) at d = 120, for x1x2 and x1x2x3 only:
n at which the true direction's order-k utility on the training set reaches 1 / 1.5 / 2 x the largest order-k utility
that power iteration (32 starts x 40 steps) finds on random labels, 3 seeds, sqrt(2)-spaced n.
Run: DIM=120 NS_MAX=65536 FLOOR_NMAX=16384 OPENBLAS_NUM_THREADS=1 python3 floor_d120.py"""
import os, sys
import numpy as np
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
import common as C
from models.race import _order_k, F32
from models.ablation_diagnostics import _power_max

nmax = int(os.environ.get("FLOOR_NMAX", 16384))
ns = [int(round(2 ** (e / 2))) for e in range(10, int(2 * np.log2(nmax)) + 1)]
print(f"d = {C.D}; n grid {ns[0]}..{ns[-1]}")
for fn, k in [("par2", 2), ("par3", 3)]:
    rat = []
    for n in ns:
        v = []
        for s in range(3):
            X, y = C.train_data(fn, s, n)
            U = X.astype(F32); r = (y - y.mean()).astype(F32)
            vt = np.zeros((C.D, 1), F32); vt[:k, 0] = 1 / np.sqrt(k)
            Ut = abs(float(_order_k(U, r, vt, k, (U.T @ r) / n, float(r.mean()), need_grad=False)[0][0]))
            yr = np.random.default_rng(100 + s).choice([-1.0, 1.0], n); rr = (yr - yr.mean()).astype(F32)
            v.append(Ut / _power_max(U, rr, k, np.random.default_rng(s)))
        rat.append(np.mean(v)); print(f"  {fn} n={n} ratio {rat[-1]:.2f}", flush=True)
    rat = np.array(rat); ln = np.log2(ns); cross = []
    for c in (1.0, 1.5, 2.0):
        i = np.where(rat >= c)[0]
        if len(i) == 0 or i[0] == 0:
            cross.append(np.nan); continue
        i = i[0]; f = (c - rat[i - 1]) / (rat[i] - rat[i - 1]); cross.append(2 ** (ln[i - 1] + f * (ln[i] - ln[i - 1])))
    print(f"| {fn} | " + " | ".join(f"{x:.0f}" for x in cross) + " |", flush=True)
