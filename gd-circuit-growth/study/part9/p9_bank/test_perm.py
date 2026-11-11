"""Pixel-permutation invariance check of the bank member (Part 9, I2).  Fits fit_bank twice with the same random seed,
once on the pixels in their stored order and once with the columns permuted by a random permutation, and compares the
class scores and predictions on 2000 held-back training-pool rows.  The member uses only Euclidean distances, inner products and per-feature
quantiles, so the two fits must agree up to floating-point summation order.
usage: python test_perm.py [dataset] [n]   (default qd_dev 2000; development data only)"""
import os, sys, numpy as np, importlib.util
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(STUDY, "standard_tasks"))
import data as DATA
spec = importlib.util.spec_from_file_location("p9_bank_learner", os.path.join(HERE, "learner.py"))
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
ds = sys.argv[1] if len(sys.argv) > 1 else "qd_dev"; n = int(sys.argv[2]) if len(sys.argv) > 2 else 2000
assert ds in ("mnist", "fashion_mnist", "qd_dev"), "development image sets only"
D = DATA.load(ds); pool, te = DATA.splits(D, 0)
X = D["X"][pool[:n]].astype(np.float32); y = D["y"][pool[:n]]; Xte = D["X"][pool[-2000:]].astype(np.float32)   # held-back pool rows, not the test set
perm = np.random.default_rng(123).permutation(X.shape[1])
out = []
for Xa, Xt in ((X, Xte), (X[:, perm].copy(), Xte[:, perm].copy())):
    m, _, _, fl, info = M.fit_bank(Xa, y, D["C"], np.arange(n), np.zeros(0, np.int64), 1000, np.random.default_rng(7), want_all=False, n_thr=3)
    out.append((m.scores(Xt), fl, info))
(S0, f0, i0), (S1, f1, i1) = out
print(f"{ds} n={n}: max |score difference| = {np.max(np.abs(S0 - S1)):.2e}; prediction agreement = {np.mean(S0.argmax(1) == S1.argmax(1)):.4f}; "
      f"same selected-feature count {i0['F'] == i1['F']}, same lambda {i0['lam'] == i1['lam']}, flops equal {f0 == f1}")
