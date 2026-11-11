"""Compute audit (Part 9): work per LightGBM tree in ggbt (the gates bank) and in v1's gbt, on DEV data only (qd_dev,
fashion_mnist seed-0 training pools cached by the p9_gates builder).  Labels are used only to grow trees; nothing is
predicted on any test row.  usage: ggbt_count.py <ds> ggbt <n_all> <n_fit> <rounds> [colwise] | <ds> gbt <n_tr> <rounds>"""
import os, sys, time, json, math, numpy as np, lightgbm as lgb
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.path.insert(0, os.path.join(STUDY, "part9")); sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import hyb_portfolio2.learner as LM
CACHE = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p9_gates/cache_{}_s0.npz"

def walk(node, out):
    if "split_index" in node:
        l, r = node["left_child"], node["right_child"]
        cnt = lambda t: t.get("internal_count", t.get("leaf_count"))
        out["smaller"] += min(cnt(l), cnt(r)); walk(l, out); walk(r, out)
    else:
        out["leaves"] += 1

def tree_stats(bst):
    info = bst.dump_model()["tree_info"]; L, sm = [], []
    for ti in info:
        o = dict(smaller=0, leaves=0); walk(ti["tree_structure"], o); L.append(o["leaves"]); sm.append(o["smaller"])
    return np.array(L, float), np.array(sm, float)

def rho_cols(F):
    """share of entries outside the most frequent value, per column (upper bound on LightGBM's non-default-bin share)"""
    out = np.empty(F.shape[1])
    for j in range(F.shape[1]):
        _, c = np.unique(F[:, j], return_counts=True); out[j] = 1.0 - c.max() / len(F)
    return out

z = np.load(CACHE.format(sys.argv[1])); X, y = z["X"], z["y"].astype(np.int64); C = 10
what = sys.argv[2]
if what == "ggbt":
    n_all, n_fit, R = int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]); colwise = "colwise" in sys.argv
    Xa = X[:n_all].astype(np.float64)
    t0 = time.process_time(); As, flp = LM.pool_sets(Xa, [4, 9, 16]); t_pool = time.process_time() - t0
    Ag = np.concatenate([As[k] for k in (4, 9, 16)], 1); rg = np.random.default_rng([0, 9])
    Xf, yf = Xa[:n_fit], y[:n_fit]
    U = LM.pair_dirs(Xf, yf, 300, rg); feat, m = LM.ggbt_feats(Ag, U)
    t0 = time.process_time(); F = feat(Xf); t_proj = time.process_time() - t0
    bag = 0.5 if n_fit > 20000 else 1.0; mcs = int(max(2, min(20, n_fit // 25))); ff = 0.12; Lv = 31
    t0 = time.process_time()
    dtr = lgb.Dataset(F, yf, params=dict(max_bin=63, verbose=-1, **({} if mcs >= 20 else dict(feature_pre_filter=False))), free_raw_data=False); dtr.construct()
    t_bin = time.process_time() - t0
    nbv = np.array([dtr.feature_num_bin(j) for j in range(F.shape[1])], float); nb = nbv.sum()
    rho = rho_cols(F) if n_fit <= 25000 else rho_cols(F[:25000])
    prm = dict(objective="multiclass", num_class=C, learning_rate=0.1, num_leaves=Lv, max_bin=63, feature_fraction=ff,
               bagging_fraction=bag, bagging_freq=1 if bag < 1 else 0, min_data_in_leaf=mcs, min_sum_hessian_in_leaf=1e-3,
               num_threads=1, verbose=-1, seed=0, deterministic=True)
    if colwise: prm["force_col_wise"] = True
    t0 = time.process_time(); bst = lgb.train(prm, dtr, num_boost_round=R); t_tr = time.process_time() - t0
    T = bst.num_trees(); Ls, sm = tree_stats(bst)
    n_bag = bag * n_fit; d_used = ff * F.shape[1]; B_u = ff * nb
    code = LM.lgb_tree_flops(n_fit, n_bag, d_used, B_u, Lv)
    rho_used = float(np.mean(rho))                       # columns sampled uniformly: expected rho of the used columns
    L_ = Ls.mean(); smr = sm.mean() / n_bag
    hist_hi = 2.0 * d_used * (n_bag + sm.mean()); hist_lo = hist_hi * rho_used + 2.0 * B_u * (2 * L_ - 3)
    split = 12.0 * B_u * (2 * L_ - 3); subtr = 2.0 * B_u * (L_ - 2); other = 22.0 * n_fit
    a_hi, a_lo = hist_hi + split + subtr + other, hist_lo + split + subtr + other
    a16 = hist_hi + 16.0 * B_u * (2 * L_ - 3) + subtr + other
    print(json.dumps(dict(ds=sys.argv[1], n_all=n_all, n_fit=n_fit, F=F.shape[1], pooled=int(Ag.shape[1]), colwise=colwise,
        t_pool=round(t_pool, 2), pool_flops=f"{flp:.3g}", t_proj=round(t_proj, 2), proj_flops=f"{2.0 * n_fit * 784 * m:.3g}",
        t_bin=round(t_bin, 1), bin_charge=f"{16.0 * n_fit * F.shape[1]:.3g}", mean_bins=round(nb / F.shape[1], 1),
        rho_mean=round(rho_used, 3), rho_pix=round(float(np.mean(rho[:784])), 3), rho_bank=round(float(np.mean(rho[784:])), 3),
        trees=T, ms_per_tree=round(1e3 * t_tr / T, 1), leaves=round(L_, 1), sum_min_over_nbag=round(smr, 2),
        code_per_tree=f"{code:.3g}", audit_hi=f"{a_hi:.3g}", audit_lo=f"{a_lo:.3g}", audit_cbin16=f"{a16:.3g}",
        ratio_hi=round(a_hi / code, 2), ratio_lo=round(a_lo / code, 2), ratio_cbin16=round(a16 / code, 2),
        split_share=round((split + subtr) / a_hi, 2),
        GFLOPs_code=round(code * T / t_tr / 1e9, 2), GFLOPs_audit_hi=round(a_hi * T / t_tr / 1e9, 2))), flush=True)
else:
    n_tr, R = int(sys.argv[3]), int(sys.argv[4]); Xt, yt = X[:n_tr].astype(np.float64), y[:n_tr]
    rs, cs = LM.gbt_sub(n_tr, 784); mcs = int(max(2, min(20, n_tr // 25)))
    dtr = lgb.Dataset(Xt, yt, params=dict(max_bin=255, verbose=-1), free_raw_data=False); dtr.construct()
    nbv = np.array([dtr.feature_num_bin(j) for j in range(784)], float); used = nbv > 1; Sb = nbv[used].sum()
    rho = rho_cols(Xt[:, used])
    prm = dict(objective="multiclass", num_class=C, learning_rate=0.1, num_leaves=31, min_data_in_leaf=mcs, min_sum_hessian_in_leaf=1e-3,
               bagging_fraction=rs, bagging_freq=1 if rs < 1 else 0, feature_fraction=cs, seed=0, num_threads=1, verbose=-1)
    t0 = time.process_time(); bst = lgb.train(prm, dtr, num_boost_round=R); t_tr = time.process_time() - t0
    T = bst.num_trees(); Ls, sm = tree_stats(bst); L_ = Ls.mean()
    code = 10.0 * n_tr * rs * 784 * cs + 8.0 * 31 * 784 * cs * 255
    du = used.sum() * cs; Bu = Sb * cs; nbag = rs * n_tr
    hist_hi = 2.0 * du * (nbag + sm.mean()); hist_lo = hist_hi * float(rho.mean()) + 2.0 * Bu * (2 * L_ - 3)
    split = 12.0 * Bu * (2 * L_ - 3); subtr = 2.0 * Bu * (L_ - 2); other = 22.0 * n_tr
    a_hi, a_lo = hist_hi + split + subtr + other, hist_lo + split + subtr + other
    a16 = hist_hi + 16.0 * Bu * (2 * L_ - 3) + subtr + other
    print(json.dumps(dict(ds=sys.argv[1], member="gbt(v1)", n_tr=n_tr, d_used=int(used.sum()), mean_bins=round(Sb / used.sum(), 1),
        rho=round(float(rho.mean()), 3), trees=T, ms_per_tree=round(1e3 * t_tr / T, 1), leaves=round(L_, 1),
        sum_min_over_n=round(sm.mean() / nbag, 2), code=f"{code:.3g}", audit_hi=f"{a_hi:.3g}", audit_lo=f"{a_lo:.3g}",
        ratio_hi=round(a_hi / code, 2), ratio_lo=round(a_lo / code, 2), ratio_cbin16=round(a16 / code, 2),
        GFLOPs_code=round(code * T / t_tr / 1e9, 2), GFLOPs_audit_hi=round(a_hi * T / t_tr / 1e9, 2))), flush=True)
