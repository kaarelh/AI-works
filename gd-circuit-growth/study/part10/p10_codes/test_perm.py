"""Permutation check for p10_codes' new object (the bars): building them from a column-permuted training matrix gives
the same bars, as sets of original columns, and the pooling sets stay identical (as in v2).  Dev data only."""
import sys, os, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(STUDY, "hybrid")); sys.path.insert(0, os.path.dirname(HERE))
import common
from p10_codes import learner as Lm
DATA = common.SH.DATA


def bar_family(X, L):
    As, _, topo = Lm.pool_sets_topo(X, [4, 9, 16]); B, _ = Lm.bar_sets(topo, X.shape[1], L)
    bars = [frozenset(np.where(B[:, c] > 0)[0].tolist()) for c in range(B.shape[1])]
    pools = {k: [frozenset(np.where(As[k][:, c] > 0)[0].tolist()) for c in range(As[k].shape[1])] for k in As}
    return bars, pools


for ds, n in (("qd_dev", 2000), ("fashion_mnist", 2000)):
    D = DATA.load(ds); pool, _ = DATA.splits(D, 0); X = D["X"][pool[:n]]
    for L in (2, 4):
        b0, p0 = bar_family(X, L)
        for s in range(2):
            perm = np.random.default_rng(100 + s).permutation(X.shape[1])          # new column j = old column perm[j]
            b1, p1 = bar_family(X[:, perm], L)
            b1 = [frozenset(int(perm[j]) for j in b) for b in b1]
            p1 = {k: [frozenset(int(perm[j]) for j in b) for b in v] for k, v in p1.items()}
            same_b = sorted(map(sorted, b0)) == sorted(map(sorted, b1))
            same_p = all(sorted(map(sorted, p0[k])) == sorted(map(sorted, p1[k])) for k in p0)
            print(ds, n, "L", L, "perm", s, "bars identical:", same_b, " pooling sets identical:", same_p, " (bars: %d)" % len(b0), flush=True)
