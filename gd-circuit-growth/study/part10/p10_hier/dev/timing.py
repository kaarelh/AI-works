import sys, time, numpy as np, lightgbm as lgb
sys.path.insert(0, "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p10_hier")
from feats import *
n = 20000; R = 15
X, y, Xv, yv, C = load("qd_dev", n, nval=10)
act, S = neigh(X, 49)
X32 = X.astype(np.float32)
P4, P9, P16 = (pooled(X, act, S, k) for k in (4, 9, 16))
rng = np.random.default_rng(5); a = rng.integers(n, size=300); b = rng.integers(n, size=300)
U = X32[a] - X32[b]
Fv2 = np.concatenate([X32, P4, P9, P16, X32 @ U.T], 1)
Fm3 = np.concatenate([X32, P4, P9, P16, maxpool(P4, S, 9), maxpool(P9, S, 16), maxpool(P16, S, 49)], 1)
for nm, F, cw in (("v2bank_auto", Fv2, False), ("v2bank_colwise", Fv2, True), ("m3_colwise", Fm3, True)):
    params = dict(objective="multiclass", num_class=C, learning_rate=0.1, num_leaves=31, max_bin=63, feature_fraction=0.12,
                  min_data_in_leaf=20, min_sum_hessian_in_leaf=1e-3, num_threads=1, verbose=-1, seed=0, deterministic=True)
    if cw:
        params["force_col_wise"] = True
    t0 = time.process_time(); d = lgb.Dataset(F, y, params=dict(max_bin=63, verbose=-1)); d.construct(); t1 = time.process_time()
    bst = lgb.train(params, d, num_boost_round=R); t2 = time.process_time()
    print(f"{nm}: cols {F.shape[1]} binning {t1 - t0:.1f}s, {1000 * (t2 - t1) / (R * C):.1f} ms per tree", flush=True)
