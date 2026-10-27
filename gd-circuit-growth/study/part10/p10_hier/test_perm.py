"""Permutation checks of p10_hier's image bank (dev data only: qd_dev, fashion_mnist, mnist).
For a random column permutation: (1) the pooling sets and the ranked neighbour lists used by the level-2 pooling are the
same sets of original pixels; (2) every column of ggbt's bank (pixels, pooled sums, level-2 max-pooled maps) is the same
function of the image, i.e. the bank on permuted columns is a column permutation of the bank on the original columns
(checked as: identical multisets of columns, matched by the original pixel each column belongs to).  LightGBM's
feature_fraction draws feature subsets by column index, so the boosted model itself is invariant in distribution only (as
v2's ggbt).
usage: python test_perm.py [ds] [n]"""
import os, sys, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(HERE))
import p10_hier.learner as LM
DATA = LM.common.SH.DATA

ds = sys.argv[1] if len(sys.argv) > 1 else "qd_dev"; n = int(sys.argv[2]) if len(sys.argv) > 2 else 2000
L = LM.Learner(); ks = L.gates_ks; l2 = L.gates_l2; kmax = max([K for (_, _, K) in l2], default=0)
D = DATA.load(ds); pool, _ = DATA.splits(D, 0); X = D["X"][pool[:n]]
ok = True
for s in (1, 2, 3):
    perm = np.random.default_rng(s).permutation(X.shape[1]); Xp = X[:, perm]
    As, _, Sa = LM.pool_sets(X, ks, kmax=kmax); Asp, _, Sap = LM.pool_sets(Xp, ks, kmax=kmax)
    act = np.where(X[:20000].std(0) > 1e-6)[0]; actp = np.where(Xp[:20000].std(0) > 1e-6)[0]
    # original pixel of every active column, in both runs
    o, op = act, perm[actp]
    col = {p: r for r, p in enumerate(op)}; m = np.array([col[p] for p in o])      # column r (orig) <-> column m[r] (perm)
    same_lists = all(np.array_equal(o[Sa[r]], op[Sap[m[r]]]) for r in range(len(o)))
    na = len(o); blocks = {k: slice(i * na, (i + 1) * na) for i, k in enumerate(ks)}
    Ag = np.concatenate([As[k] for k in ks], 1); Agp = np.concatenate([Asp[k] for k in ks], 1)
    f, _, _ = LM.ggbt_feats(Ag, np.zeros((0, X.shape[1])), Sa, l2, blocks)
    fp, _, _ = LM.ggbt_feats(Agp, np.zeros((0, X.shape[1])), Sap, l2, blocks)
    Q = X[:300]; F = f(Q); Fp = fp(Q[:, perm])
    d = X.shape[1]; nb = len(ks) + len(l2)
    # pixels: column j of Fp is pixel perm[j]; derived blocks: column m[r] of each block of Fp <-> column r of F's block
    pix = np.abs(F[:, perm] - Fp[:, :d]).max()
    der = max(np.abs(F[:, d + b * na: d + (b + 1) * na] - Fp[:, d + b * na: d + (b + 1) * na][:, m]).max() for b in range(nb))
    print(f"{ds} n={n} perm seed {s}: neighbour lists identical {same_lists}; pixel block max diff {pix:.2e}; "
          f"pooled + level-2 blocks ({nb} blocks of {na}) max diff {der:.2e}")
    ok &= bool(same_lists) and pix == 0 and der < 1e-4
print("PASS" if ok else "FAIL")
