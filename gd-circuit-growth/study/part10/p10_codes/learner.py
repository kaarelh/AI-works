"""p10_codes (Part 10, image builder I2): v2 = hyb_portfolio2 (part9/hyb_portfolio2/learner.py, md5 e38af404...) with one
change, in its image member 'gates' (ggbt's feature bank and LightGBM layout); everything else is v2's code, unchanged.

THE CHANGE (see DESIGN.md).  ggbt's bank [x, pooled sums at k = 4, 9, 16, 300 prototype-pair projections] becomes
  [x, pooled sums at k = 4, 9, 16, BARS],  with no prototype pairs and a smaller per-tree column fraction,
where the bars are discrete local codes on the data-recovered topology: every non-constant pixel i has 8 most-correlated
pixels (ranks 2..9 of the same ranked correlation lists that give v2's pooling sets); they are paired into 4 'axes' by
least mutual correlation (on a grid: opposite neighbours), and the bar of (i, axis) is the straight run of pixels through
i along that axis, continued by the same pairing rule at the next pixel ('go straight on'), BAR_L steps each way.  A bar
feature is the subset sum of the pixels on it (weights in {0, 1}); 4 bars per pixel per length.  Split thresholds are
LightGBM histogram bins (data quantiles), as before.  Every object is built from training-row statistics only (rounded
correlations, fingerprint tie-breaks): a column permutation permutes the bars exactly (test_perm.py).  LightGBM runs with
force_col_wise=True (bit-identical to the automatic layout on v2's bank, Part 9; checked again here) and the bank is
built separately for the booster's fitting and inner-validation rows (memory).  gknn and every other member: v2's.

v2's docstring follows.

hyb_portfolio2 (Part 9): the Part 8 portfolio with (i) its DFG member switched to DFG v1.2 = DFG v1.1 + sum-feature
blocks (part9/p9_sum/dfg12.py, md5 4ff2e0c9c324f0f1be93f604734b4a69) and (ii) the image member of p9_gates
(part9/p9_gates/learner.py, md5 2728ac2b80597d9e559dedca6a70cb7c), chosen by the integration rule of PROTOCOL.md.
This file is p9_gates/learner.py with two changes: the DFG module path and the default name; plus one post-freeze
crash fix in fit_ggbt (feature_pre_filter off when min_data_in_leaf < 20, i.e. member training sets below 500 points).

p9_gates (Part 9, builder I1): the Part 8 portfolio hyb_portfolio, unchanged, plus one discrete, pixel-permutation-
invariant IMAGE member family, 'gates', active only when every input column is continuous and d >= 256 (images).
Everything below the Part 8 docstring is identical to hyb_portfolio/learner.py (md5 063bcd91...) except the paths, the
constructor's new arguments and name, and the block marked 'p9_gates' in fit().

THE GATES FAMILY (see DESIGN.md).  Two discrete objects are built from the training data only:
  pooling sets  S_i(k) = the k columns most correlated with column i (i over the non-constant columns; k in 4, 9, 16),
                computed from the training matrix (a data statistic; no pixel adjacency or 28 x 28 layout is used:
                permuting the columns permutes the sets exactly).  Pooled feature p_i(x) = sum_{j in S_i(k)} x_j (a
                signed subset sum with all signs +1).
  prototype pairs  (a, b): 300 training points pairs of different classes, drawn at random; feature (x_a - x_b) . x.
Members:
  gknn_<k>  k-nearest-neighbour votes (k in 1, 3, 9, 27) in the pooled representation p(x) at scale 9 (Euclidean);
            leave-one-out votes are the out-of-fold predictions (as for knn).
  ggbt      LightGBM on [x, p(x) at scales 4, 9, 16, (x_a - x_b) . x]: every split is a gate [u . x > t] with u a pixel,
            a pooling set or a prototype pair, and t a data quantile (histogram bin); 31 leaves, lr 0.1, 63 bins, 12% of
            the columns per tree; 100 rounds, or (training set >= 5000 points) early stopping on the error of an inner
            validation split (patience 50, 150 to 400 rounds).
Both give class probabilities to the same stacker as every other member.

Part 8 docstring follows.
hyb_portfolio: a portfolio of discrete learners combined by cross-validated stacking (Part 8, design 3).

MEMBERS (each a discrete learner; each gives class probabilities):
  dfg     DFG v1.1 (discrete_learner/dfg.py, readout='logit'): exhaustive search over Fourier characters with union-bound
          tests, extensions, local Walsh search, linear / spectral blocks, LS + logistic readout.  Only when every input
          column is binary or categorical (encoded as +-1 bits) and C = 2: the toy targets, chess / DNA-like tables.
  gbt     gradient-boosted trees (LightGBM: axis-aligned threshold splits, 31 leaves, lr 0.1, 100 rounds; categorical
          columns as categorical; min_child_samples scaled down at small n).
  et      extremely randomised trees (sklearn ExtraTrees, 100 trees, bootstrap): random axis-aligned thresholds, averaged;
          out-of-bag probabilities serve as its out-of-fold predictions (no refit).
  knn     nearest-neighbour votes (k in {1, 3, 9, 27}) under two metrics: 'std' (the MLP's encoding: z-scored
          continuous, +-1 binary, one-hot categorical) and 'raw' (every column numeric, one common scale - the natural
          metric for pixel data); leave-one-out votes serve as out-of-fold predictions.
  lin     multinomial L2 logistic regression on the 'std' encoding (C_reg in {0.05, 1}) - the convex readout alone.
COMBINATION: every member's out-of-fold log-probabilities L_m (n x C) on a stacking set; the combined score is
  s_c(x) = b_c + sum_m w_m L_m(x)_c,  w_m >= 0,
  fitted by L2-regularised multinomial log-loss (convex; L-BFGS-B).  This contains selection (one w_m > 0) and
  log-linear pooling.  Members with w_m = 0 are not refitted.  Stacking set: 5-fold cross-validation for n <= 3000; above
  that a stratified holdout of min(n / 5, 6000) points (members refitted on all n afterwards).
COMPUTE: FLOPs counted for everything (multiply-add = 2): DFG's own counter; kNN 2 q n d (distances) + q n (selection);
  logistic 5 n p C per L-BFGS iteration (function + gradient + line search); LightGBM 10 n d per tree (histogram passes
  over <= 5 levels with the subtraction trick, 2 FLOPs per row-feature) + split search 8 * leaves * d * bins per tree;
  ExtraTrees 4 * mtry * (samples reaching the node) summed over the internal nodes of every tree (min/max scan,
  random threshold, partition); stacker 6 h M C per iteration.  Each member is skipped if its projected cost exceeds
  what is left of the budget.  Prediction is not counted (as for the networks); kNN's test-time cost is 2 n d per query.
"""
import os, sys, math, importlib.util, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
HYB = os.path.join(STUDY, "hybrid")
if HYB not in sys.path:
    sys.path.insert(0, HYB)
import common

SH = common.SH
_DFG = None


def _dfg_module():
    """dfg.py does 'from harness import gd_flops' (the toy harness), but 'harness' here is the standard-task harness:
    load it with the toy harness bound to that name for the duration of the import."""
    global _DFG
    if _DFG is None:
        sp = importlib.util.spec_from_file_location("hp_toy_harness", os.path.join(STUDY, "discrete_learner", "harness.py"))
        th = importlib.util.module_from_spec(sp); sp.loader.exec_module(th)
        saved = sys.modules.get("harness"); sys.modules["harness"] = th
        try:
            sp2 = importlib.util.spec_from_file_location("hp_dfg12", os.path.join(STUDY, "part9", "p9_sum", "dfg12.py"))
            m = importlib.util.module_from_spec(sp2); sp2.loader.exec_module(m)
        finally:
            if saved is not None:
                sys.modules["harness"] = saved
            else:
                del sys.modules["harness"]
        _DFG = (m, th)
    return _DFG


def _logp(P, eps=1e-5):
    P = np.clip(np.asarray(P, dtype=np.float64), eps, None)
    return np.log(P / P.sum(1, keepdims=True))


def _folds(y, K, rng):
    """Stratified fold labels 0..K-1."""
    f = np.empty(len(y), np.int64)
    for c in np.unique(y):
        idx = np.where(y == c)[0]; idx = idx[rng.permutation(len(idx))]
        f[idx] = (np.arange(len(idx)) + rng.integers(K)) % K
    return f


# ----------------------------------------------------------------------------------------------------------- members
def _full_proba(model_classes, P, C):
    out = np.zeros((P.shape[0], C)); out[:, np.asarray(model_classes, dtype=np.int64)] = P
    return out


class _Const:
    def __init__(self, y, C):
        self.p = (np.bincount(y, minlength=C) + 1.0) / (len(y) + C)

    def proba(self, Z):
        return np.tile(self.p, (len(Z), 1))


def fit_lin(Z, y, C, Creg, seed):
    from sklearn.linear_model import LogisticRegression
    if len(np.unique(y)) < 2:
        return _Const(y, C), 0.0
    m = LogisticRegression(C=Creg, max_iter=200, tol=1e-4)
    m.fit(Z, y)
    it = int(np.max(m.n_iter_)); p = Z.shape[1] + 1; k = 1 if len(m.classes_) == 2 else len(m.classes_)
    fl = 5.0 * Z.shape[0] * p * k * max(it, 1)

    class M:
        def proba(self, A):
            return _full_proba(m.classes_, m.predict_proba(A), C)
    return M(), fl


def lin_cost(n, p, C, it=200):
    return 5.0 * n * (p + 1) * (1 if C == 2 else C) * it


def gbt_sub(n, d):
    """(row, column) subsampling: none, except on large inputs (n d > 1e7, e.g. MNIST), where a full-data booster would
    take ~5 CPU minutes per fit: rows 0.5 per tree, columns 0.25 per tree."""
    return (0.5, 0.25) if n * d > 1e7 else (1.0, 1.0)


def fit_gbt(Xt, y, C, cat_idx, seed, n_trees=100):
    import lightgbm as lgb
    n, d = Xt.shape
    if len(np.unique(y)) < 2:
        return _Const(y, C), 0.0
    mcs = int(max(2, min(20, n // 25))); rs, cs = gbt_sub(n, d)
    m = lgb.LGBMClassifier(n_estimators=n_trees, learning_rate=0.1, num_leaves=31, min_child_samples=mcs,
                           min_child_weight=1e-3, subsample_for_bin=200000, random_state=seed, n_jobs=1, verbose=-1,
                           subsample=rs, subsample_freq=1 if rs < 1 else 0, colsample_bytree=cs)
    m.fit(Xt, y, categorical_feature=cat_idx if cat_idx else "auto")
    k = len(m.classes_); trees = m.n_estimators * (1 if k == 2 else k)
    fl = trees * (10.0 * n * rs * d * cs + 8.0 * 31 * d * cs * 255) + 2.0 * n * d * 8   # + binning

    class M:
        def proba(self, A):
            return _full_proba(m.classes_, m.predict_proba(A), C)
    return M(), fl


def gbt_cost(n, d, C, n_trees=100):
    rs, cs = gbt_sub(n, d)
    return n_trees * (1 if C == 2 else C) * (10.0 * n * rs * d * cs + 8.0 * 31 * d * cs * 255)


def fit_et(Z, y, C, seed, n_trees=100):
    from sklearn.ensemble import ExtraTreesClassifier
    if len(np.unique(y)) < 2:
        c = _Const(y, C); return c, np.log(c.proba(Z)), 0.0
    m = ExtraTreesClassifier(n_estimators=n_trees, max_features="sqrt", bootstrap=True, oob_score=True, n_jobs=1,
                             random_state=seed, min_samples_leaf=1)
    import warnings
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        m.fit(Z, y)
    mtry = max(1, int(math.sqrt(Z.shape[1])))
    fl = 0.0
    for t in m.estimators_:
        tr = t.tree_; internal = tr.children_left >= 0
        fl += 4.0 * mtry * float(np.sum(tr.n_node_samples[internal]))
    oob = np.nan_to_num(m.oob_decision_function_, nan=1.0 / len(m.classes_))
    oob = _full_proba(m.classes_, oob, C)

    class M:
        def proba(self, A):
            return _full_proba(m.classes_, m.predict_proba(A), C)
    return M(), oob, fl


def et_cost(n, d, n_trees=100):
    return n_trees * 4.0 * max(1, int(math.sqrt(d))) * n * 2 * max(1.0, math.log2(max(n, 2)))


def knn_votes(Zref, yref, Zq, C, ks, exclude_self_idx=None, chunk=None):
    """Class-vote fractions of the k nearest reference points for each query (squared Euclidean), for every k in ks.
    exclude_self_idx: for leave-one-out, the reference index of each query (its own distance is set to +inf)."""
    Zref = np.asarray(Zref, np.float32); Zq = np.asarray(Zq, np.float32)
    kmax = min(max(ks), len(Zref) - (1 if exclude_self_idx is not None else 0))
    rn = np.einsum("ij,ij->i", Zref, Zref)
    chunk = chunk or int(max(32, min(2048, 2.5e7 // max(len(Zref), 1))))      # distance blocks of <= 100 MB
    out = {k: np.zeros((len(Zq), C)) for k in ks}
    for a in range(0, len(Zq), chunk):
        q = Zq[a:a + chunk]
        D = rn[None, :] - 2.0 * (q @ Zref.T)
        if exclude_self_idx is not None:
            D[np.arange(len(q)), exclude_self_idx[a:a + chunk]] = np.inf
        if kmax < D.shape[1]:
            nb = np.argpartition(D, kmax - 1, axis=1)[:, :kmax]
        else:
            nb = np.tile(np.arange(D.shape[1]), (len(q), 1))
        dd = np.take_along_axis(D, nb, 1); o = np.argsort(dd, axis=1, kind="stable"); nb = np.take_along_axis(nb, o, 1)
        lab = yref[nb]
        for k in ks:
            kk = min(k, kmax)
            cnt = np.zeros((len(q), C))
            for c in range(C):
                cnt[:, c] = np.sum(lab[:, :kk] == c, axis=1)
            out[k][a:a + chunk] = cnt / kk
    return out


def knn_cost(q, n, d):
    return 2.0 * q * n * d + 3.0 * q * n


# ------------------------------------------------------------------------------------- p9_gates: the image member
def is_image(types, d, dmin=256):
    """The gates family runs only on images: every column continuous and d >= 256."""
    return d >= dmin and all(t == "continuous" for t in types)


def pool_sets(X, ks, rows=20000, tol=1e-6):
    """Pooling sets from the training matrix only: for every non-constant column i, S_i(k) = the k columns with the
    largest correlation with column i over the first `rows` training rows (i itself first: corr = 1), for each k in ks.
    Returns {k: the 0/1 pooling matrix A_k (d x n_active, A_k[S_i(k), i] = 1; pooled features = X @ A_k)} and the
    FLOPs.  No pixel adjacency or layout is
    used; a permutation of the columns permutes the sets exactly: correlations are rounded to 1e-9 (BLAS rounding can
    depend on the column order) and ties are broken by a column fingerprint (the column's inner product with fixed
    pseudo-random row weights), never by column index."""
    Xs = np.asarray(X[:rows], np.float64); sd = Xs.std(0); act = np.where(sd > tol)[0]
    Z = (Xs[:, act] - Xs[:, act].mean(0)) / sd[act]
    R = np.round(Z.T @ Z / len(Z), 9)
    fp = Xs[:, act].T @ np.random.default_rng(77).standard_normal(len(Xs))
    S = act[np.lexsort((np.broadcast_to(-fp, R.shape), -R), axis=1)[:, :max(ks)]]
    As = {}
    for k in ks:
        A = np.zeros((X.shape[1], len(act)), np.float32)
        A[S[:, :k].ravel(), np.repeat(np.arange(len(act)), k)] = 1.0
        As[k] = A
    na = len(act)
    fl = 2.0 * len(Z) * na * na + 4.0 * len(Z) * na + 2.0 * na * na * max(1.0, math.log2(max(na, 2)))   # corr + sort
    return As, fl


def pool_sets_topo(X, ks, rows=20000, tol=1e-6, kmax=16):
    """p10_codes: pool_sets (the same pooling matrices A_k, bit for bit: the same statistics, ranking and tie-breaks) and
    the recovered topology it rests on: the active columns act, the rounded correlation matrix R among them and every
    active column's ranked list of its kmax most correlated active columns (local indices, rank 1 = itself).  FLOPs as
    pool_sets (the ranking is the same full sort)."""
    Xs = np.asarray(X[:rows], np.float64); sd = Xs.std(0); act = np.where(sd > tol)[0]
    Z = (Xs[:, act] - Xs[:, act].mean(0)) / sd[act]
    R = np.round(Z.T @ Z / len(Z), 9)
    fp = Xs[:, act].T @ np.random.default_rng(77).standard_normal(len(Xs))
    O = np.lexsort((np.broadcast_to(-fp, R.shape), -R), axis=1)[:, :max(max(ks), kmax)]
    S = act[O[:, :max(ks)]]
    As = {}
    for k in ks:
        A = np.zeros((X.shape[1], len(act)), np.float32)
        A[S[:, :k].ravel(), np.repeat(np.arange(len(act)), k)] = 1.0
        As[k] = A
    na = len(act)
    fl = 2.0 * len(Z) * na * na + 4.0 * len(Z) * na + 2.0 * na * na * max(1.0, math.log2(max(na, 2)))   # corr + sort
    return As, fl, dict(act=act, R=R, fp=fp, S=O)


def _match_axes(R, nb):
    """Pair a pixel's 8 most correlated pixels nb (ranks 2..9, local indices) into 4 axes, greedily: the least
    correlated remaining pair first (on a grid: opposite neighbours).  Returns opp: rank position -> its partner.
    Ties (R is rounded) go to the earlier rank position; rank positions are themselves permutation-invariant."""
    C = R[np.ix_(nb, nb)].copy(); np.fill_diagonal(C, np.inf); opp = -np.ones(len(nb), np.int64)
    for _ in range(len(nb) // 2):
        p = int(np.argmin(C)); a, b = divmod(p, len(nb))
        opp[a], opp[b] = b, a; C[[a, b], :] = np.inf; C[:, [a, b]] = np.inf
    return opp


def bar_sets(topo, d, L=2):
    """p10_codes: discrete 'bars' on the recovered topology.  Every active pixel i has 4 axes (its 8 most correlated
    pixels paired by _match_axes, in the canonical order of the rank of each axis' first end); the bar of (i, axis) is
    i, the two ends of the axis, and then up to L - 1 further steps in each direction, where the step from j (reached
    from i') is the partner of i' in j's own pairing (go straight on; the bar stops if i' is not among j's 8).  Returns the
    0/1 matrix B (d x 4 n_active; bar sums = X @ B) and FLOPs (negligible: a few list operations per pixel).  Built from
    the ranked correlation lists only: permuting the columns permutes the bars exactly."""
    act, R, S = topo["act"], topo["R"], topo["S"]; a = len(act); NB = S[:, 1:9]
    AX = np.zeros((a, 4, 2), np.int64); opp_of = []
    for k in range(a):
        opp = _match_axes(R, NB[k]); seen = []; dct = {}
        for p in range(8):
            if p not in seen:
                seen += [p, int(opp[p])]; AX[k, len(seen) // 2 - 1] = (NB[k, p], NB[k, opp[p]])
            dct[int(NB[k, p])] = int(NB[k, opp[p]])
        opp_of.append(dct)
    B = np.zeros((d, 4 * a), np.float32)
    for i in range(a):
        for t in range(4):
            mem = {i}
            for end in AX[i, t]:
                prev, cur = i, int(end)
                for s in range(L):
                    mem.add(cur)
                    nxt = opp_of[cur].get(prev, -1)
                    if nxt < 0 or s == L - 1:
                        break
                    prev, cur = cur, nxt
            B[act[sorted(mem)], 4 * i + t] = 1.0
    return B, 200.0 * a


def pair_dirs(X, y, m, rng):
    """m prototype pairs (a, b), a and b training points of different classes, drawn uniformly; direction x_a - x_b."""
    a = rng.integers(len(X), size=m); b = rng.integers(len(X), size=m)
    for _ in range(100):
        bad = y[a] == y[b]
        if not bad.any():
            break
        b[bad] = rng.integers(len(X), size=int(bad.sum()))
    keep = y[a] != y[b]
    return (np.asarray(X[a[keep]], np.float32) - np.asarray(X[b[keep]], np.float32))


def ggbt_feats(A, U):
    """Feature map of ggbt: [x, x @ A (pooled sums; p10_codes: and bar sums), x @ U^T (prototype-pair projections)], float32."""
    M = np.concatenate([A, U.T], 1).astype(np.float32)

    def f(Xr):
        Xr = np.asarray(Xr, np.float32)
        return np.concatenate([Xr, Xr @ M], 1)
    return f, M.shape[1]


def lgb_tree_flops(n_fit, n_bag, d_used, bins_used, leaves=31):
    """Audit-style count of one LightGBM tree (compute audit F1): histograms for the root and the smaller child of each
    split at 2 FLOPs per stored row-feature entry, with sum min(n_left, n_right) <= 1.6 n; split search ~12 FLOPs per
    bin per leaf evaluation (2L - 3 of them); histogram subtraction 2 per bin per split; gradients, partition, score
    update ~22 per row."""
    return 2.0 * d_used * n_bag * 2.6 + 12.0 * bins_used * (2 * leaves - 3) + 2.0 * bins_used * (leaves - 2) + 22.0 * n_fit


def _es_error(patience, min_rounds):
    """Early stopping on the validation error (multi_error; ties go to the later round), never before min_rounds.
    (Stopping on the validation log-loss stopped far too early on dev: the boosted probabilities become over-confident
    long before the error stops falling, and the stacker can temper them.)"""
    import lightgbm as lgb
    st = dict(best=np.inf, it=0)

    def cb(env):
        e = env.evaluation_result_list[0][2]; i = env.iteration + 1
        if e <= st["best"]:
            st["best"], st["it"] = e, i
        if i >= min_rounds and i - st["it"] >= patience:
            raise lgb.callback.EarlyStopException(st["it"] - 1, env.evaluation_result_list)
    cb.order = 30
    return cb, st


def fit_ggbt(Xr, y, C, A, rng, seed, n_pairs=300, max_rounds=400, ff=0.12, bins=63, lr=0.1, leaves=31, es_min=5000,
             es_patience=50, es_min_rounds=150, fixed_rounds=None, col_wise=True):
    """LightGBM on the gate bank.  Rounds: fixed_rounds if given; else early stopping on the error of a stratified inner
    validation split (min(10%, 5000) points; patience 50, at least 150 rounds) when len(y) >= es_min, up to max_rounds;
    else 100 rounds.  Returns (model, flops, rounds used).
    p10_codes: col_wise = LightGBM's force_col_wise (the same model as the automatic layout - Part 9 checked bit-identical
    predictions - 2-3x faster on this bank); the bank is built for the fitting rows and the inner-validation rows
    separately (no full-size copy: less memory)."""
    import lightgbm as lgb
    n, d = Xr.shape
    if len(np.unique(y)) < 2:
        return _Const(y, C), 0.0, 0
    U = pair_dirs(Xr, y, n_pairs, rng); feat, m = ggbt_feats(A, U)
    fl = 2.0 * n * d * m                                              # projections of the training rows
    tr = np.arange(n); va = None
    if fixed_rounds is None and n >= es_min:
        h = int(min(5000, 0.1 * n)); f = _folds(y, max(2, int(round(n / h))), rng); va = np.where(f == 0)[0]; tr = np.where(f != 0)[0]
    rounds = int(fixed_rounds) if fixed_rounds is not None else (max_rounds if va is not None else 100)
    n_fit = len(tr); bag = 0.5 if n_fit > 20000 else 1.0
    mcs = int(max(2, min(20, n_fit // 25)))
    params = dict(objective="multiclass", num_class=C, learning_rate=lr, num_leaves=leaves, max_bin=bins,
                  feature_fraction=ff, bagging_fraction=bag, bagging_freq=1 if bag < 1 else 0, min_data_in_leaf=mcs,
                  min_sum_hessian_in_leaf=1e-3, num_threads=1, verbose=-1, seed=seed, deterministic=True,
                  **(dict(force_col_wise=True) if col_wise else {}))
    # post-freeze crash fix (27 Oct; PROTOCOL.md): LightGBM refuses min_data_in_leaf below the Dataset's construction value
    # (20) when features were pre-filtered; below 20 (n_fit < 500) pre-filtering is switched off.  Unchanged for n_fit >= 500.
    F = feat(Xr[tr]); nF = F.shape[1]
    dtr = lgb.Dataset(F, y[tr], params=dict(max_bin=bins, verbose=-1, **({} if mcs >= 20 else dict(feature_pre_filter=False))),
                      free_raw_data=True); dtr.construct(); del F
    nb = float(sum(dtr.feature_num_bin(j) for j in range(nF)))
    fl += 16.0 * n_fit * nF                                             # binning
    cb = []
    vs = []
    if va is not None:
        dva = lgb.Dataset(feat(Xr[va]), y[va], reference=dtr); vs = [dva]; es, est = _es_error(es_patience, min(es_min_rounds, rounds)); cb = [es]
        params["metric"] = "multi_error"
    bst = lgb.train(params, dtr, num_boost_round=rounds, valid_sets=vs, callbacks=cb)
    trees = bst.num_trees()
    fl += trees * lgb_tree_flops(n_fit, bag * n_fit, ff * nF, ff * nb, leaves)
    if va is not None:
        fl += trees * 20.0 * len(va)                                    # validation scores, one tree at a time
    best = int(est["it"]) if (va is not None and est["it"] > 0) else rounds
    bst.free_dataset(); del dtr, vs                                    # p10_codes: free the binned bank (memory)

    class M:
        def proba(self, Q):
            P = bst.predict(feat(Q), num_iteration=best)
            return P if P.ndim == 2 else np.stack([1 - P, P], 1)
    return M(), fl, best


def ggbt_cost(n, d, C, m, rounds, ff=0.12, bins=63):
    nb = 0.5 if n > 20000 else 1.0
    return 2.0 * n * d * m + 16.0 * n * (d + m) + rounds * C * lgb_tree_flops(n, nb * n, ff * (d + m), ff * (d + m) * bins)


# ---------------------------------------------------------------------------------------------------------- stacker
def fit_stacker(Ls, y, C, lam_w=1e-3, lam_b=1e-3):
    """min over w >= 0, b of mean CE(softmax(b + sum_m w_m L_m)) + lam_w |w|^2 + lam_b |b|^2."""
    from scipy.optimize import minimize
    L = np.stack(Ls, 0)                       # (M, h, C)
    M, h, _ = L.shape; Y = np.zeros((h, C)); Y[np.arange(h), y] = 1.0

    def f(theta):
        w, b = theta[:M], theta[M:]
        S = np.tensordot(w, L, 1) + b[None, :]
        S -= S.max(1, keepdims=True); P = np.exp(S); P /= P.sum(1, keepdims=True)
        loss = -np.mean(np.sum(Y * np.log(np.clip(P, 1e-300, None)), 1)) + lam_w * w @ w + lam_b * b @ b
        G = (P - Y) / h
        gw = np.einsum("mhc,hc->m", L, G) + 2 * lam_w * w
        gb = G.sum(0) + 2 * lam_b * b
        return loss, np.concatenate([gw, gb])

    th0 = np.concatenate([np.full(M, 1.0 / M), np.zeros(C)])
    r = minimize(f, th0, jac=True, method="L-BFGS-B", bounds=[(0, None)] * M + [(None, None)] * C,
                 options=dict(maxiter=500))
    fl = 6.0 * h * M * C * (r.nit + r.nfev)
    return r.x[:M], r.x[M:], fl


# ---------------------------------------------------------------------------------------------------------- learner
class Learner:
    def __init__(self, K=5, K_small=10, K_small_n=500, lin_one_n=10000, kfold_max=3000, hold_max=6000, ks=(1, 3, 9, 27), lin_C=(0.05, 1.0), gbt_trees=100,
                 et_trees=100, dfg_share=(0.35, 0.5), dfg_dmax=256, lam_w=1e-2, members=None, name="p10_codes",
                 gates_k=9, gates_ks=(4, 9, 16), gates_pairs=300, gates_rounds=400, gates_ff=0.12, gates_dmin=256,
                 codes_bars=(2,), codes_pairs=0, codes_ff=0.07, codes_mode="both", gates_col_wise=True):
        self.K_small, self.K_small_n, self.lin_one_n = K_small, K_small_n, lin_one_n
        self.K, self.kfold_max, self.hold_max, self.ks, self.lin_C = K, kfold_max, hold_max, tuple(ks), tuple(lin_C)
        self.gbt_trees, self.et_trees, self.dfg_share, self.dfg_dmax, self.lam_w = gbt_trees, et_trees, dfg_share, dfg_dmax, lam_w
        self.members = members                     # None = all applicable; else a set of member families (dev ablation)
        self.name = name
        # p9_gates: the image member family 'gates' (sub-families 'gknn', 'ggbt')
        self.gates_k, self.gates_pairs, self.gates_rounds, self.gates_ff, self.gates_dmin = gates_k, gates_pairs, gates_rounds, gates_ff, gates_dmin
        self.gates_ks = tuple(gates_ks)              # pooling scales of ggbt's bank; gknn uses the scale gates_k
        # p10_codes: bar half-lengths of ggbt's bar bank (() = none) and LightGBM's column-wise layout
        self.codes_bars, self.gates_col_wise = tuple(codes_bars), bool(gates_col_wise)
        self.codes_pairs, self.codes_ff, self.codes_mode = int(codes_pairs), float(codes_ff), codes_mode   # the bar member

    def _use(self, fam):
        return self.members is None or fam in self.members

    def fit(self, X, y, types, C, rng, budget=None):
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y, dtype=np.int64); n, d = X.shape
        budget = common.budget_real(X, types, C, n) if budget is None else float(budget)
        seed = int(rng.integers(1 << 30))
        spent = [0.0]; info = dict(members={}, flops={})

        import time as _t
        info["times"] = {}; clock = [_t.process_time()]

        def charge(name, fl):
            spent[0] += fl; info["flops"][name] = info["flops"].get(name, 0.0) + fl
            now = _t.process_time(); info["times"][name] = round(info["times"].get(name, 0.0) + now - clock[0], 2); clock[0] = now
            if os.environ.get("HP_VERBOSE"):
                print(f"   [hp] {name} {fl:.3g} flops, {info['times'][name]}s", flush=True)

        # ---- encodings (training statistics only)
        dom = [np.unique(X[:, j]) if t == "categorical" else None for j, t in enumerate(types)]
        enc_std = lambda A: SH.encode_standard(A, types, ref=X, domain=dom)
        big = n * d > 1e7                              # large inputs: float32 copies (memory)
        if big:
            enc_std0 = enc_std; enc_std = lambda A: enc_std0(A).astype(np.float32)
        Zs = enc_std(X)
        mu = X.mean(0); sd = X.std(0); sd[sd < 1e-12] = 1.0
        cont = [j for j, t in enumerate(types) if t not in ("binary", "categorical")]
        g = float(np.sqrt(np.mean(sd[cont] ** 2))) if cont else 1.0
        cat_or_bin = [j for j, t in enumerate(types) if t in ("binary", "categorical")]
        # 'raw' metric: every column numeric with one common scale; only differs from 'std' if continuous scales differ
        # or categorical codes are ordinal-looking (it is offered and the stacker decides)
        raw_scale = np.full(d, g); raw_scale[cat_or_bin] = np.where(sd[cat_or_bin] > 0, sd[cat_or_bin], 1.0)
        enc_raw = lambda A: ((np.asarray(A, np.float64) - mu) / raw_scale).astype(np.float32 if big else np.float64)
        use_raw = bool(cont) and (np.max(sd[cont]) / max(np.min(sd[cont]), 1e-12) > 1.5 or any(t == "categorical" for t in types))
        # trees: raw columns, categorical columns as category ranks
        cat_idx = [j for j, t in enumerate(types) if t == "categorical"]

        def enc_tree(A):
            A = np.array(A, dtype=np.float64)
            for j in cat_idx:
                v = np.searchsorted(dom[j], A[:, j]); ok = (v < len(dom[j])) & (dom[j][np.minimum(v, len(dom[j]) - 1)] == A[:, j])
                A[:, j] = np.where(ok, v, -1)
            return A
        if not cat_idx:
            enc_tree = lambda A: np.asarray(A, dtype=np.float64)
        Xt = enc_tree(X)
        # DFG view: every column binary / categorical -> +-1 bits
        dfg_ok = self._use("dfg") and C == 2 and len(cat_or_bin) == d and Zs.shape[1] <= self.dfg_dmax
        enc_pm = (lambda A: np.where(enc_std(A) > 0, 1.0, -1.0)) if dfg_ok else None

        # ---- stacking set
        if n <= self.kfold_max:
            K = self.K if n > self.K_small_n else self.K_small; fold = _folds(y, K, rng); H = np.arange(n)
            splits = [(np.where(fold != f)[0], np.where(fold == f)[0]) for f in range(K) if np.any(fold == f)]
        else:
            h = int(min(self.hold_max, n // 5)); fold = _folds(y, max(2, int(round(n / h))), rng)
            Hm = fold == 0; H = np.where(Hm)[0]; splits = [(np.where(~Hm)[0], H)]
        yH = y[H]; pos = np.full(n, -1); pos[H] = np.arange(len(H))
        oof, fitters = {}, {}

        def kfold_member(name, fitfn, Zall, reuse=False):
            P = np.zeros((len(H), C))
            for tr, te in splits:
                m, fl = fitfn(Zall[tr], y[tr]); charge(name, fl)
                P[pos[te]] = m.proba(Zall[te])
            oof[name] = _logp(P)
            # reuse: the holdout-trained model is also the final one (no refit on all n)
            fitters[name] = ("done", m, enc_tree if name == "gbt" else enc_std) if reuse else (fitfn, Zall)

        # DFG (first: the toy budget is mostly its share)
        if dfg_ok:
            dfgm, th = _dfg_module(); Zpm = enc_pm(X); gdf = th.gd_flops(Zpm.shape[1])
            fold_share = self.dfg_share[0] / len(splits)

            proto = dfgm.DFG(readout="logit")

            class ScaledDFG(dfgm.DFG):
                def __init__(s, mult):
                    super().__init__(readout="logit"); s.mult = mult

                def _fit(s, A, b, c, force, lin0, ridge, hi=True, scale=1.0):
                    return super()._fit(A, b, c, force, lin0, ridge, hi=hi, scale=scale * s.mult)

            def fit_dfg(A, yy, share, force):
                """One DFG v1.1 fit (its _fit: default variant, or with force=True the 'forced' small-n variant that
                takes the best-scoring character when nothing passes the test, at most twice); readout='logit'."""
                if len(np.unique(yy)) < 2:
                    return _Const(yy, 2), 0.0
                out = ScaledDFG(share * budget / gdf)._fit(A, np.where(yy == 1, 1.0, -1.0), proto.c, force, False,
                                                            proto.ridge, hi=True, scale=1.0)
                pr = out["predict"]; cl = dict(zip(pr.__code__.co_freevars, pr.__closure__ or ()))
                val = cl["value"].cell_contents

                class M:
                    def proba(self, Z):
                        v = 4.0 * np.asarray(val(Z), dtype=np.float64)
                        p1 = 1.0 / (1.0 + np.exp(-np.clip(v, -30, 30)))
                        return np.stack([1 - p1, p1], 1)
                return M(), out["flops"]
            # DFG's two variants are two members (DFG itself chooses between them by cross-validation at n <= 512;
            # here the stacker does); the out-of-fold fits share dfg_share[0] of the budget, the final fits dfg_share[1]
            variants = [("dfg", False)] + ([("dfg_forced", True)] if n <= proto.cv_n else [])
            for nm, force in variants:
                kfold_member(nm, lambda A, yy, force=force: fit_dfg(A, yy, fold_share / len(variants), force), Zpm)
                fitters[nm] = ("dfg", force, fit_dfg, Zpm)

        # kNN: leave-one-out votes for the stacking points against all n
        if self._use("knn"):
            for metric, Zm in (("std", Zs),) + ((("raw", enc_raw(X)),) if use_raw else ()):
                cost = knn_cost(len(H), n, Zm.shape[1])
                if spent[0] + cost > 0.9 * budget:
                    continue
                V = knn_votes(Zm, y, Zm[H], C, self.ks, exclude_self_idx=H); charge("knn_" + metric, cost)
                for k in self.ks:
                    if k < n:
                        oof[f"knn_{metric}_{k}"] = _logp(0.9 * V[k] + 0.1 / C)
                        fitters[f"knn_{metric}_{k}"] = ("knn", metric, k)
                fitters["_knn_" + metric] = (Zm, {"std": enc_std, "raw": enc_raw}[metric])

        # gradient-boosted trees
        if self._use("gbt"):
            ntr = len(splits[0][0]); cost = gbt_cost(ntr, d, C, self.gbt_trees) * (len(splits) + 1)
            if spent[0] + cost <= 0.9 * budget:
                # on large inputs (n d > 1e7, holdout regime) the booster is not refitted: one LightGBM fit there takes
                # ~2.5 CPU minutes at MNIST size; the final booster is then trained on n - h points (90% at n = 60000)
                reuse = big and len(splits) == 1
                if reuse:
                    cost = gbt_cost(ntr, d, C, self.gbt_trees)
                kfold_member("gbt", lambda A, yy: fit_gbt(A, yy, C, cat_idx, seed, self.gbt_trees), Xt, reuse=reuse)

        # extra trees: out-of-bag
        if self._use("et"):
            cost = et_cost(n, Zs.shape[1], self.et_trees)
            if spent[0] + cost <= 0.9 * budget:
                m, ob, fl = fit_et(Zs, y, C, seed, self.et_trees); charge("et", fl)
                oof["et"] = _logp(ob[H]); fitters["et"] = ("done", m, enc_std)

        # logistic regression
        if self._use("lin"):
            for Cr in (self.lin_C if n <= self.lin_one_n else self.lin_C[-1:]):
                ntr = len(splits[0][0]); cost = lin_cost(ntr, Zs.shape[1], C) * (len(splits) + 1)
                if spent[0] + cost > 0.95 * budget:
                    continue
                kfold_member(f"lin_{Cr}", lambda A, yy, Cr=Cr: fit_lin(A, yy, C, Cr, seed), Zs)

        # ---- p9_gates: the image member family (only when every column is continuous and d >= 256)
        if self._use("gates") and is_image(types, d, self.gates_dmin):
            rg = np.random.default_rng([seed, 9])
            As, fl, topo = pool_sets_topo(X, sorted(set(self.gates_ks) | {self.gates_k})); charge("g_pool", fl)
            A = As[self.gates_k]                                            # gknn's pooled representation
            Bs = []                                                         # p10_codes: bars on the recovered topology
            for L in self.codes_bars:
                Bm, fl = bar_sets(topo, d, L); Bs.append(Bm); charge("g_bars", fl)
            Ag = np.concatenate([As[k] for k in self.gates_ks], 1)          # ggbt's pooled sums, every scale
            info["ggbt_bank"] = dict(pooled=int(Ag.shape[1]), bars=int(sum(b.shape[1] for b in Bs)), mode=self.codes_mode)
            enc_pool = lambda Q, A=A: np.asarray(Q, np.float32) @ A
            if self._use("gknn"):
                cost = knn_cost(len(H), n, A.shape[1]) + 2.0 * n * d * A.shape[1]
                if spent[0] + cost <= 0.9 * budget:
                    Zp = enc_pool(X); charge("g_pool", 2.0 * n * d * A.shape[1])
                    V = knn_votes(Zp, y, Zp[H], C, self.ks, exclude_self_idx=H); charge("gknn", knn_cost(len(H), n, A.shape[1]))
                    for k in self.ks:
                        if k < n:
                            oof[f"gknn_{k}"] = _logp(0.9 * V[k] + 0.1 / C)
                            fitters[f"gknn_{k}"] = ("knn", "pool", k)
                    fitters["_knn_pool"] = (Zp, enc_pool)
            # p10_codes: the boosted members.  'replace': one member 'ggbt' on [x, pooled sums, bars] (codes_pairs pairs,
            # column fraction codes_ff).  'both': v2's 'ggbt' unchanged (pooled sums + gates_pairs pairs, gates_ff, its
            # generator rg: bit-identical to v2's member) and a second member 'cgbt' on [x, pooled sums, bars]
            # (codes_pairs pairs, codes_ff, its own generator); the stacker weights both.
            Ab = np.concatenate([Ag] + Bs, 1)                               # pooled sums + bars
            if self.codes_mode == "replace" or not Bs:
                specs = [("ggbt", Ab, self.codes_pairs if Bs else self.gates_pairs, self.codes_ff if Bs else self.gates_ff, rg)]
            else:
                specs = [("ggbt", Ag, self.gates_pairs, self.gates_ff, rg),
                         ("cgbt", Ab, self.codes_pairs, self.codes_ff, np.random.default_rng([seed, 10]))]
            for gname, Abank, npairs, gff, gen in specs:
                if not self._use(gname):
                    continue
                ntr = len(splits[0][0]); m_g = Abank.shape[1] + npairs
                refit = len(splits) > 1 or not big
                cost = ggbt_cost(ntr, d, C, m_g, self.gates_rounds if ntr >= 5000 else 100, gff) * (len(splits) + (1 if refit else 0))
                if spent[0] + cost <= 0.9 * budget:
                    P = np.zeros((len(H), C)); used = []
                    for tr, te in splits:
                        mg, fl, r = fit_ggbt(X[tr], y[tr], C, Abank, gen, seed, npairs, self.gates_rounds, gff,
                                             col_wise=self.gates_col_wise)
                        # + its out-of-fold predictions: projections, and ~10 FLOPs per tree per row for the traversal
                        charge(gname, fl + 2.0 * len(te) * d * m_g + 10.0 * r * C * len(te)); P[pos[te]] = mg.proba(X[te]); used.append(r)
                    oof[gname] = _logp(P); info[gname + "_rounds"] = used
                    # refit on all n (k-fold regime: the same fixed rounds; holdout regime with n d <= 1e7: the early-
                    # stopped round count); on large inputs the holdout-trained booster is the final one (as for gbt)
                    fitters[gname] = ("ggbt", int(max(used)), Abank, npairs, gff, gen) if refit else ("done", mg, lambda Q: Q)

        # ---- stacker
        names = sorted(oof)
        w, b, fl = fit_stacker([oof[k] for k in names], yH, C, lam_w=self.lam_w); charge("stack", fl)
        keep = [i for i in range(len(names)) if w[i] > 1e-3 * max(w.max(), 1e-12)]
        info["weights"] = {names[i]: round(float(w[i]), 3) for i in keep}
        Shat = np.tensordot(w, np.stack([oof[k] for k in names], 0), 1) + b
        info["stack_oof_err"] = float(np.mean(np.argmax(Shat, 1) != yH))
        info["member_oof_err"] = {k: round(float(np.mean(np.argmax(oof[k], 1) != yH)), 4) for k in names}

        # ---- final members (refit on all n where needed)
        finals = []
        knn_need = {}
        for i in keep:
            nm = names[i]; f = fitters[nm]
            if isinstance(f, tuple) and f[0] == "knn":
                knn_need.setdefault(f[1], []).append((f[2], w[i]))
            elif isinstance(f, tuple) and f[0] == "dfg":
                # the final DFG fit(s) share dfg_share[1] of the budget, less if little is left
                nd = sum(1 for j in keep if names[j].startswith("dfg"))
                share = min(self.dfg_share[1], 0.9 * (budget - spent[0]) / budget) / nd
                m, fl = f[2](f[3], y, share, f[1]); charge(nm, fl)
                finals.append((w[i], lambda A, m=m: m.proba(enc_pm(A))))
            elif isinstance(f, tuple) and f[0] == "ggbt":                  # p9_gates: refit of ggbt (p10_codes: or cgbt) on all n
                m, fl, _ = fit_ggbt(X, y, C, f[2], f[5], seed, f[3], self.gates_rounds, f[4], fixed_rounds=f[1],
                                    col_wise=self.gates_col_wise)
                charge(nm, fl); finals.append((w[i], lambda Q, m=m: m.proba(Q)))
            elif isinstance(f, tuple) and f[0] == "done":
                m, enc = f[1], f[2]; finals.append((w[i], lambda A, m=m, enc=enc: m.proba(enc(A))))
            else:
                fitfn, Zall = f; m, fl = fitfn(Zall, y); charge(nm, fl)
                enc = enc_pm if nm.startswith("dfg") else enc_tree if nm == "gbt" else enc_std
                finals.append((w[i], lambda A, m=m, enc=enc: m.proba(enc(A))))
        for metric, lst in knn_need.items():
            Zm, enc = fitters["_knn_" + metric]; ks = [k for k, _ in lst]; ws = [wi for _, wi in lst]

            def kp(A, Zm=Zm, enc=enc, ks=ks, ws=ws):
                V = knn_votes(Zm, y, enc(A), C, ks)
                return sum(wi * _logp(0.9 * V[k] + 0.1 / C) for k, wi in zip(ks, ws))
            finals.append((None, kp))
        info["budget_frac"] = spent[0] / budget

        def score(A):
            A = np.asarray(A, dtype=np.float64); S = np.tile(b, (len(A), 1))
            for wi, fn in finals:
                S = S + (fn(A) if wi is None else wi * _logp(fn(A)))
            return S

        return dict(predict=lambda A: np.argmax(score(A), 1), flops=spent[0], info=info)
