"""Permutation-invariance checks of the p9_gates image member (dev data only: mnist, fashion_mnist, qd_dev).
1. The pooling sets are equivariant: for a random column permutation, the set of every pixel (as original pixel indices)
   is the same, so every pooled feature p_i(x) is the same.
2. gknn (deterministic) gives identical leave-one-out votes on permuted columns.
3. ggbt: the prototype-pair projections are the same numbers on permuted columns (pairs are drawn by row index).  LightGBM's
   feature_fraction draws feature subsets by column index, so the boosted model is invariant in distribution only (as
   for Part 8's gbt / et members); this is reported, not asserted.
usage: python test_perm.py [ds] [n]"""
import os, sys, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(HERE))
import p9_gates.learner as LM
DATA = LM.common.SH.DATA

ds = sys.argv[1] if len(sys.argv) > 1 else "qd_dev"; n = int(sys.argv[2]) if len(sys.argv) > 2 else 2000
D = DATA.load(ds); pool, _ = DATA.splits(D, 0); X = D["X"][pool[:n]]; y = D["y"][pool[:n]]
ok = True
for s in (1, 2, 3):
    perm = np.random.default_rng(s).permutation(X.shape[1]); inv = np.argsort(perm); Xp = X[:, perm]
    A, _ = LM.pool_sets(X, (9,)); Ap, _ = LM.pool_sets(Xp, (9,)); A, Ap = A[9], Ap[9]
    act = np.where(A.sum(0) > 0)[0]
    # column r of A belongs to the r-th non-constant pixel; map original pixel j -> its column in Ap
    orig_pix = np.where(X[:20000].std(0) > 1e-6)[0]; perm_pix = np.where(Xp[:20000].std(0) > 1e-6)[0]
    col = {p: r for r, p in enumerate(perm_pix)}
    m = [col[inv[j]] for j in orig_pix]
    same_sets = all(set(np.where(A[:, r])[0]) == set(perm[np.where(Ap[:, m[r]])[0]]) for r in range(A.shape[1]))
    P = X.astype(np.float32) @ A; Pp = (Xp.astype(np.float32) @ Ap)[:, m]
    H = np.arange(0, n, 7)
    V = LM.knn_votes(P, y, P[H], D["C"], (1, 3, 9), exclude_self_idx=H)
    Vp = LM.knn_votes(Pp, y, Pp[H], D["C"], (1, 3, 9), exclude_self_idx=H)
    same_votes = all(np.array_equal(V[k], Vp[k]) for k in V)
    rg1, rg2 = np.random.default_rng(5), np.random.default_rng(5)
    U = LM.pair_dirs(X, y, 50, rg1); Up = LM.pair_dirs(Xp, y, 50, rg2)
    proj = float(np.abs(X[:500].astype(np.float32) @ U.T - Xp[:500].astype(np.float32) @ Up.T).max())
    print(f"{ds} n={n} perm seed {s}: pooling sets identical {same_sets}; pooled features max diff "
          f"{float(np.abs(P - Pp).max()):.2e}; gknn LOO votes identical {same_votes}; pair projections max diff {proj:.2e}")
    ok &= same_sets and same_votes and proj < 1e-3
print("PASS" if ok else "FAIL")
