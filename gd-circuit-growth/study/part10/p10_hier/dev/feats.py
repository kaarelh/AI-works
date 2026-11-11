"""Dev-only feature-bank experiments for p10_hier (validation rows of the seed-0 training pool)."""
import os, sys, math, time, json, numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import common
SH = common.SH; DATA = SH.DATA


def neigh(X, kmax, rows=20000, tol=1e-6):
    """v2's ranking: S[i] = active-index list of the kmax columns most correlated with active column i (i first)."""
    Xs = np.asarray(X[:rows], np.float64); sd = Xs.std(0); act = np.where(sd > tol)[0]
    Z = (Xs[:, act] - Xs[:, act].mean(0)) / sd[act]
    R = np.round(Z.T @ Z / len(Z), 9)
    fp = Xs[:, act].T @ np.random.default_rng(77).standard_normal(len(Xs))
    S = np.lexsort((np.broadcast_to(-fp, R.shape), -R), axis=1)[:, :kmax]     # active-index space
    return act, S


def pooled(X, act, S, k):
    Xa = np.asarray(X, np.float32)[:, act]
    out = np.zeros((len(X), len(act)), np.float32)
    for t in range(k):
        out += Xa[:, S[:, t]]
    return out


def maxpool(P, S, K):
    out = P[:, S[:, 0]].copy()
    for t in range(1, K):
        np.maximum(out, P[:, S[:, t]], out=out)
    return out


def countpool(G, S, K):
    out = np.zeros(G.shape, np.float32)
    for t in range(K):
        out += G[:, S[:, t]]
    return out


def load(ds, n, nval=10000):
    D = DATA.load(ds); pool, te = DATA.splits(D, 0)
    tr = pool[:n]; va = pool[50000:50000 + nval]
    return D["X"][tr], D["y"][tr], D["X"][va], D["y"][va], D["C"]


def lgb_curve(F, y, Fv, yv, C, rounds=300, ff=0.12, bins=63, lr=0.1, leaves=31, seed=0, every=25, colwise=True):
    import lightgbm as lgb
    n = len(y); bag = 0.5 if n > 20000 else 1.0; mcs = int(max(2, min(20, n // 25)))
    params = dict(objective="multiclass", num_class=C, learning_rate=lr, num_leaves=leaves, max_bin=bins,
                  feature_fraction=ff, bagging_fraction=bag, bagging_freq=1 if bag < 1 else 0, min_data_in_leaf=mcs,
                  min_sum_hessian_in_leaf=1e-3, num_threads=1, verbose=-1, seed=seed, deterministic=True,
                  metric="multi_error")
    if colwise:
        params["force_col_wise"] = True
    t0 = time.process_time()
    dtr = lgb.Dataset(F, y, params=dict(max_bin=bins, verbose=-1, **({} if mcs >= 20 else dict(feature_pre_filter=False))))
    dva = lgb.Dataset(Fv, yv, reference=dtr)
    ev = {}
    bst = lgb.train(params, dtr, num_boost_round=rounds, valid_sets=[dva], valid_names=["v"],
                    callbacks=[lgb.record_evaluation(ev)])
    e = np.array(ev["v"]["multi_error"])
    cpu = time.process_time() - t0
    return {r: float(e[r - 1]) for r in range(every, rounds + 1, every)}, float(e.min()), int(e.argmin() + 1), cpu
