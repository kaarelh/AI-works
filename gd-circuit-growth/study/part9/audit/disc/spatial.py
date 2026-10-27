"""Audit: do p9_gates' pooling sets S_i(k) (k most correlated columns) recover spatial neighbourhoods?
For each active column i: grid (row, col) of i and of the other k-1 members; Chebyshev / Euclidean distances.
qd_* are stored pixel-permuted (data.py: perm = default_rng(9192).permutation(784), X = X_orig[:, perm]), so column c is
original pixel perm[c]; mnist / fashion_mnist are stored in natural order.  Training rows pool[:n] only.
usage: spatial.py ds n"""
import os, sys, importlib.util, numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("v2_learner", os.path.join(STUDY, "part9", "hyb_portfolio2", "learner.py"))
LM = importlib.util.module_from_spec(spec); spec.loader.exec_module(LM)
DATA = LM.common.SH.DATA
ds, n = sys.argv[1], int(sys.argv[2])
D = DATA.load(ds); pool, _ = DATA.splits(D, 0); X = D["X"][pool[:n]].copy(); del D
pix = np.random.default_rng(9192).permutation(784) if ds.startswith("qd_") else np.arange(784)   # column -> original pixel
rc = np.stack([pix // 28, pix % 28], 1)
rng = np.random.default_rng(0)
for k in (4, 9, 16):
    As, _ = LM.pool_sets(X, (k,)); A = As[k]
    act = np.where(X[:20000].std(0) > 1e-6)[0]
    cheb, eucl, allnear, cnt8 = [], [], [], []
    rcheb = []
    for r, i in enumerate(act):
        mem = [j for j in np.where(A[:, r] > 0)[0] if j != i]
        dd = np.abs(rc[mem] - rc[i]); ch = dd.max(1); cheb += ch.tolist(); eucl += np.sqrt((dd ** 2).sum(1)).tolist()
        allnear.append(bool(np.all(ch <= (1 if k <= 9 else 2))))
        rnd = rng.choice(act[act != i], size=len(mem), replace=False); rcheb += np.abs(rc[rnd] - rc[i]).max(1).tolist()
    cheb, rcheb = np.array(cheb), np.array(rcheb)
    print(f"{ds} n={n} k={k}: active cols {len(act)}; other members: Chebyshev dist <=1 {np.mean(cheb <= 1):.3f}, <=2 "
          f"{np.mean(cheb <= 2):.3f}, <=3 {np.mean(cheb <= 3):.3f}, median {np.median(cheb):.0f}, mean Euclid {np.mean(eucl):.2f}; "
          f"sets entirely within {'3x3' if k <= 9 else '5x5'} of i: {np.mean(allnear):.3f}  | random baseline: <=1 {np.mean(rcheb <= 1):.3f}, "
          f"<=2 {np.mean(rcheb <= 2):.3f}, median {np.median(rcheb):.0f}", flush=True)
