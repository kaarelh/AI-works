"""p9_bank: the Part 8 portfolio hyb_portfolio (hybrid/hyb_portfolio/learner.py, md5 063bcd91e0b221c948760ec1ba28e042)
plus one image member, 'bank' (Part 9, builder I2): a bank of discrete prototype-pair threshold bits with a convex
(ridge) readout, active only when every column is continuous and d >= 256.  Changes against the Part 8 file: the
file-location constants, the bank member (functions below the kNN section; its block in fit() after the logistic
members; its refit in the final-members loop), three constructor arguments, the default name.  Every other member, the
stacker and the stacking set are the Part 8 code unchanged; the bank uses its own random stream, so the other members'
fits are identical to Part 8's.

BANK (see DESIGN.md): phi_j(x) = [(x_a - x_b) . x > t_j], a and b training points of different classes (b the nearest
other-class point to a in a reference sample), t_j a random quantile of the projection; F of them (F <= 4000, from the
FLOP budget) chosen from a pool of 6F candidates by forward screening on the ridge residual; ridge readout on the
centred bits, penalty and softmax temperature chosen on an internal validation split.

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
            sp2 = importlib.util.spec_from_file_location("hp_dfg", os.path.join(STUDY, "discrete_learner", "dfg.py"))
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


# ------------------------------------------------------------------------------------------- bank member (Part 9, I2)
# A bank of discrete binary features phi_j(x) = [ (x_a - x_b) . x > t_j ]: a, b two training points of different classes
# (b = the nearest point of another class to a, among a random reference sample), t_j a quantile of the projection over
# training points (n_thr stratified random quantiles per direction).  The bank is built in rounds by forward screening:
# each round draws a fresh pool of candidate bits, scores each by its squared standardized correlation with the current
# multi-output ridge residual (summed over classes) and keeps the best; the readout is ridge regression on the centred
# bits with one-hot targets (closed form, convex), the penalty and a softmax temperature chosen on an internal
# validation split.  Only Euclidean distances, inner products and per-feature quantiles are used: invariant to any fixed
# permutation of the pixels.
def _bank_quantiles(P, q):
    """Threshold per (column j, level q[j, l]): the midpoint between the order statistic of P[:, j] at level q[j, l] and
    the next larger distinct value (so no sample point lies at a threshold: bits do not depend on floating-point
    summation order, which keeps the member invariant to a permutation of the pixels in practice, not only in exact
    arithmetic).  P: (m, U); q: (U, L).  Returns (U, L) float64."""
    m, U = P.shape; Ps = np.sort(P, axis=0); cols = np.arange(U)[:, None]
    lo = np.floor(q * (m - 1)).astype(np.int64); v = Ps[lo, cols]                          # (U, L)
    nle = np.stack([(Ps <= v[None, :, l]).sum(0) for l in range(q.shape[1])], 1)           # rank of the next larger value
    w = Ps[np.minimum(nle, m - 1), cols]
    return np.where(nle < m, 0.5 * (v + w), v)


def _bank_pairs(Xs, ys, U, rng, nb=4000, chunk=512):
    """U prototype pairs (a, b): a uniform over the rows of Xs, b = nearest row of another class within a random
    reference sample of <= nb rows.  Returns indices into Xs and the FLOPs."""
    ns, d = Xs.shape; ia = rng.integers(ns, size=U)
    samp = rng.choice(ns, min(ns, nb), replace=False); Xr = Xs[samp]; yr = ys[samp]
    rr = np.einsum("ij,ij->i", Xr, Xr); ib = np.empty(U, np.int64)
    for a in range(0, U, chunk):
        A = Xs[ia[a:a + chunk]]; D = rr[None, :] - 2.0 * (A @ Xr.T)
        D[ys[ia[a:a + chunk]][:, None] == yr[None, :]] = np.inf
        j = np.argmin(D, 1); ok = np.isfinite(D[np.arange(len(A)), j])
        ib[a:a + chunk] = np.where(ok, samp[j], -1)
    for t in np.where(ib < 0)[0]:                      # no other-class point in the sample: any other-class row
        other = np.where(ys != ys[ia[t]])[0]; ib[t] = rng.choice(other) if len(other) else ia[t]
    return ia, ib, 2.0 * U * len(samp) * d + 3.0 * U * len(samp)


def _bank_bits(A, W, thr, dmap, gates=None, chunk=4000):
    """float32 bits: first layer [(A @ W)[:, dmap] > thr] (projections in float64; W: the distinct directions; dmap:
    bit -> direction), then the second-layer gates AND(bit gi, bit gj) of first-layer bits (gates = (gi, gj))."""
    F1 = len(thr); ng = 0 if gates is None else len(gates[0]); out = np.empty((len(A), F1 + ng), np.float32)
    for a in range(0, len(A), chunk):
        B1 = (np.asarray(A[a:a + chunk], np.float64) @ W)[:, dmap] > thr; out[a:a + chunk, :F1] = B1
        if ng:
            out[a:a + chunk, F1:] = B1[:, gates[0]] & B1[:, gates[1]]
    return out


def bank_cost(nT, nH, d, C, F, pool_mult=6, ns_max=15000, rounds=8, nb=4000, mq=2000, n_lams=6, n_thr=3, v_frac=0.15, v_max=5000, gates=0.0):
    """Projected FLOPs of one bank fit: the terms fit_bank charges, with every selected bit counted as its own
    direction (an upper bound on the projections); n_lams = ridge solves in the penalty search (grid + 2 refinements)."""
    nv = min(v_max, max(C, round(v_frac * nT))); ns = min(nT - nv, ns_max); per = max(1, F // rounds); c = 0.0; s = 0
    for r in range(rounds):
        k = min(per, F - s)
        if k <= 0:
            break
        Ud = max(1, int(math.ceil(pool_mult * k / n_thr))); Fc = Ud * n_thr; mqq = min(ns, mq)
        c += 2.0 * Ud * min(ns, nb) * d + 3.0 * Ud * min(ns, nb) + Ud * d + 2.0 * ns * d * Ud      # pairs, directions, projections
        ng = int(gates * Fc) if r > 0 else 0
        c += mqq * math.log2(max(mqq, 2)) * Fc + 2.0 * ns * Fc + 2.0 * ns * Fc * C               # thresholds, bits, rates, scores
        c += ns * ng + 2.0 * ns * ng * C + 2.0 * ns * ng                                          # second-layer candidates
        c += 2.0 * ns * s * k + 2.0 * ns * k * k + 2.0 * ns * k * C                               # Gram blocks, cross with targets
        s += k
        if r < rounds - 1 and s < F:
            c += s ** 3 / 3.0 + 4.0 * s * s * C + 2.0 * ns * s * C + ns * C                      # ridge, residual
    N = nT + nH
    c += 2.0 * N * d * F + 2.0 * N * F + 2.0 * N * F * F + 2.0 * N * F * C                        # final bits, Gram, cross
    c += (n_lams + 2) * (2.0 * F * F + F ** 3 / 3.0 + 4.0 * F * F * C) + (n_lams * nv + 2 * nH) * 2.0 * F * C + n_lams * 6.0 * nv * C * 40
    return c


class _BankModel:
    def __init__(s, W, thr, dmap, gates, m, Wr, b0, tau, C):
        s.W, s.thr, s.dmap, s.gates, s.m, s.Wr, s.b0, s.tau, s.C = W, thr, dmap, gates, m, Wr, b0, tau, C

    def scores(s, A, chunk=4000):
        A = np.asarray(A, np.float64); S = np.empty((len(A), s.C), np.float32)
        for a in range(0, len(A), chunk):
            S[a:a + chunk] = (_bank_bits(A[a:a + chunk], s.W, s.thr, s.dmap, s.gates) - s.m) @ s.Wr + s.b0
        return S

    def proba(s, A):
        Z = s.tau * s.scores(A).astype(np.float64); Z -= Z.max(1, keepdims=True); P = np.exp(Z)
        return P / P.sum(1, keepdims=True)


def _softmax_ce(Z, y):
    Z = Z - Z.max(1, keepdims=True); return float(np.mean(np.log(np.exp(Z).sum(1)) - Z[np.arange(len(y)), y]))


def fit_bank(X, y, C, T, H, F, rng, n_thr=3, pool_mult=6, rounds=8, ns_max=15000, lam_screen=10.0,
             lams=(1.0, 10.0, 100.0, 1000.0), v_frac=0.15, v_max=5000, nb=4000, mq=2000, qlo=0.1, min_rate=0.01,
             gates=0.0, want_all=True):
    """Bank member.  X: raw float32 inputs; T: training rows, H: rows to predict out of fold (may be empty).
    Features are chosen on a subsample S of T minus a validation split V; the ridge penalty and the temperature are
    chosen on V (model fitted on T - V; the grid lams, then the best value x 3 and / 3); the reported model is refitted on T (and, if want_all, on T + H with the same
    features: the bank's Gram matrix is a sum over rows).  Returns (model_T, P_H, model_all, flops, info)."""
    from scipy.linalg import cho_factor, cho_solve
    from scipy.optimize import minimize_scalar
    d = X.shape[1]; fl = 0.0; info = {}
    T = np.asarray(T); H = np.asarray(H, dtype=np.int64)
    perm = T[rng.permutation(len(T))]; nv = int(min(v_max, max(C, round(v_frac * len(T)))))
    V, Tm = perm[:nv], perm[nv:]
    S = Tm[:min(len(Tm), ns_max)]; Xs = np.asarray(X[S], np.float64); ys = y[S]; ns = len(S)
    Y = np.zeros((ns, C), np.float32); Y[np.arange(ns), ys] = 1.0; Yc = Y - Y.mean(0)
    # ---- forward screening in rounds: a fresh candidate pool per round, scored against the current ridge residual
    per = max(1, F // rounds); dirs, tsel, dsel, gsel = [], [], [], []
    Bc = np.zeros((ns, 0), np.float32); G = np.zeros((0, 0)); RY = np.zeros((0, C)); R = Yc
    B1s = np.zeros((ns, 0), np.bool_); d1 = np.zeros(0, np.int64)       # selected first-layer bits on S, their directions
    for r in range(rounds):
        k = min(per, F - len(tsel) - len(gsel))
        if k <= 0:
            break
        Ud = max(1, int(math.ceil(pool_mult * k / n_thr))); Fc = Ud * n_thr
        ia, ib, f0 = _bank_pairs(Xs, ys, Ud, rng, nb=nb); fl += f0
        W = (Xs[ia] - Xs[ib]).T.copy(); fl += Ud * d
        P = Xs @ W; fl += 2.0 * ns * d * Ud
        kk = np.tile(np.arange(n_thr), Ud); q = (qlo + (1 - 2 * qlo) * (kk + rng.random(Fc)) / n_thr).reshape(Ud, n_thr)
        mqq = min(ns, mq); thr2 = _bank_quantiles(P[:mqq], q); thr = thr2.ravel()             # bit j = direction j // n_thr
        Bp = (P[:, :, None] > thr2[None, :, :]).reshape(ns, Fc); del P
        fl += mqq * math.log2(max(mqq, 2)) * Fc + 2.0 * ns * Fc
        ng = int(gates * Fc) if (r > 0 and B1s.shape[1] >= 2) else 0
        if ng:                                         # second-layer candidates: AND of two selected bits of different directions
            gi = rng.integers(B1s.shape[1], size=ng); gj = rng.integers(B1s.shape[1], size=ng)
            for _ in range(5):
                bad = d1[gi] == d1[gj]
                if not bad.any():
                    break
                gj[bad] = rng.integers(B1s.shape[1], size=int(bad.sum()))
            Bp = np.concatenate([Bp, B1s[:, gi] & B1s[:, gj]], 1); fl += ns * ng
        Fa = Fc + ng
        mp = Bp.mean(0, dtype=np.float64); sdp = (np.sqrt(mp * (1 - mp)) + 1e-3).astype(np.float32)
        sc = np.empty(Fa, np.float32)
        for a in range(0, Fa, 4000):
            sc[a:a + 4000] = (((Bp[:, a:a + 4000].astype(np.float32).T @ R) / ns / sdp[a:a + 4000, None]) ** 2).sum(1)
        fl += 2.0 * ns * Fa * C + 2.0 * ns * ng
        sc[(mp < min_rate) | (mp > 1 - min_rate)] = -1.0
        new = np.argsort(-sc, kind="stable")[:k]
        Nc = Bp[:, new].astype(np.float32) - mp[new].astype(np.float32)
        newg = new[new >= Fc] - Fc; new = new[new < Fc]
        if len(newg):
            gsel.extend(zip(gi[newg].tolist(), gj[newg].tolist()))
        B1s = np.concatenate([B1s, Bp[:, new]], 1); d1 = np.concatenate([d1, new // n_thr + 10 ** 9 * r]); del Bp   # (round, direction) ids
        X12 = (Bc.T @ Nc).astype(np.float64); G22 = (Nc.T @ Nc).astype(np.float64)
        fl += 2.0 * ns * Bc.shape[1] * k + 2.0 * ns * k * k + 2.0 * ns * k * C
        G = np.block([[G, X12], [X12.T, G22]]); RY = np.vstack([RY, (Nc.T @ Yc).astype(np.float64)])
        Bc = np.concatenate([Bc, Nc], 1); del Nc, X12, G22
        dirs.append(W[:, np.unique(new // n_thr)]); base = sum(D_.shape[1] for D_ in dirs[:-1])
        loc = np.searchsorted(np.unique(new // n_thr), new // n_thr)
        dsel.append(base + loc); tsel.extend(thr[new].tolist())
        if r < rounds - 1 and len(tsel) + len(gsel) < F:
            s_ = len(G)
            Wr = cho_solve(cho_factor(G + lam_screen * ns / 1000.0 * np.eye(s_)), RY).astype(np.float32)
            R = Yc - Bc @ Wr; fl += s_ ** 3 / 3.0 + 4.0 * s_ * s_ * C + 2.0 * ns * s_ * C + ns * C
    del Bc, G, RY
    Ws = np.concatenate(dirs, 1); dmap = np.concatenate(dsel).astype(np.int64); ts = np.asarray(tsel, np.float64)
    gts = (np.array([g[0] for g in gsel], np.int64), np.array([g[1] for g in gsel], np.int64)) if gsel else None
    Fs = len(ts) + len(gsel); U = Ws.shape[1]
    info["F"] = Fs; info["dirs"] = U; info["gates"] = len(gsel); info["ns"] = ns

    # ---- readout: accumulate (uncentred) Gram, sums and cross-products over row groups
    def acc(rows, keep=False):
        Gq = np.zeros((Fs, Fs), np.float32); s = np.zeros(Fs); BY = np.zeros((Fs, C), np.float32); cnt = np.bincount(y[rows], minlength=C).astype(np.float64)
        kept = [] if keep else None
        for a in range(0, len(rows), 4000):
            B = _bank_bits(X[rows[a:a + 4000]], Ws, ts, dmap, gts); Gq += B.T @ B; s += B.sum(0, dtype=np.float64)
            Yb = np.zeros((len(B), C), np.float32); Yb[np.arange(len(B)), y[rows[a:a + 4000]]] = 1.0; BY += B.T @ Yb
            if keep:
                kept.append(B)
        f = 2.0 * len(rows) * d * U + 2.0 * len(rows) * Fs + 2.0 * len(rows) * Fs * Fs + 2.0 * len(rows) * Fs * C
        return (Gq, s, BY, cnt, float(len(rows))), (np.concatenate(kept) if keep and kept else None), f

    def add(a, b):
        return tuple(a[i] + b[i] for i in range(5))

    def solve(a, lam):
        Gq, s, BY, cnt, N = a; m = s / N; yb = cnt / N
        Gc = Gq.astype(np.float64) - N * np.outer(m, m); Rc = BY.astype(np.float64) - np.outer(s, yb)
        Gc[np.diag_indices(Fs)] += lam * N / 1000.0
        Wr = cho_solve(cho_factor(Gc, overwrite_a=True), Rc); del Gc
        return m.astype(np.float32), Wr.astype(np.float32), yb.astype(np.float32), 2.0 * Fs * Fs + Fs ** 3 / 3.0 + 4.0 * Fs * Fs * C

    aM, _, f1 = acc(Tm); aV, BV, f2 = acc(V, keep=True); fl += f1 + f2
    best = None; grid = list(lams); done = set()
    while grid:
        lam = grid.pop(0); done.add(lam)
        m, Wr, yb, f = solve(aM, lam); fl += f
        Sv = ((BV - m) @ Wr + yb).astype(np.float64); fl += 2.0 * len(V) * Fs * C
        rr = minimize_scalar(lambda lt: _softmax_ce(np.exp(lt) * Sv, y[V]), bounds=(np.log(0.1), np.log(1000.0)), method="bounded",
                             options=dict(xatol=1e-3))
        fl += 6.0 * len(V) * C * rr.nfev
        ce = float(rr.fun); err = float(np.mean(np.argmax(Sv, 1) != y[V]))
        info.setdefault("val", {})[lam] = (round(err, 4), round(ce, 4))
        if best is None or ce < best[0]:
            best = (ce, lam, float(np.exp(rr.x)))
        if not grid and len(done) == len(lams):          # refine around the best grid value
            grid = [v for v in (best[1] / 3.0, best[1] * 3.0) if v not in done]
    _, lam, tau = best; info["lam"], info["tau"] = lam, round(tau, 3)
    aT = add(aM, aV); del aM, aV
    m, Wr, yb, f = solve(aT, lam); fl += f
    model_T = _BankModel(Ws, ts, dmap, gts, m, Wr, yb, tau, C)
    PH, model_all = None, None
    if len(H):
        aH, BH, f3 = acc(H, keep=True); fl += f3
        Z = tau * ((BH - m) @ Wr + yb).astype(np.float64); fl += 2.0 * len(H) * Fs * C
        Z -= Z.max(1, keepdims=True); PH = np.exp(Z); PH /= PH.sum(1, keepdims=True)
        if want_all:
            aT = add(aT, aH); del aH
            m2, Wr2, yb2, f = solve(aT, lam); fl += f
            model_all = _BankModel(Ws, ts, dmap, gts, m2, Wr2, yb2, tau, C)
    return model_T, PH, model_all, fl, info


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
                 et_trees=100, dfg_share=(0.35, 0.5), dfg_dmax=256, lam_w=1e-2, members=None, name="p9_bank",
                 bank_share=0.6, bank_Fmax=8000, bank_dmin=256, bank_fcap=5.0, bank_lams=(1.0, 10.0, 100.0, 1000.0),
                 bank_nthr=3, bank_gbt_reserve=0.7):
        self.K_small, self.K_small_n, self.lin_one_n = K_small, K_small_n, lin_one_n
        self.K, self.kfold_max, self.hold_max, self.ks, self.lin_C = K, kfold_max, hold_max, tuple(ks), tuple(lin_C)
        self.gbt_trees, self.et_trees, self.dfg_share, self.dfg_dmax, self.lam_w = gbt_trees, et_trees, dfg_share, dfg_dmax, lam_w
        self.members = members                     # None = all applicable; else a set of member families (dev ablation)
        self.name = name
        self.bank_share, self.bank_Fmax, self.bank_dmin, self.bank_fcap, self.bank_lams = bank_share, bank_Fmax, bank_dmin, bank_fcap, tuple(bank_lams)
        self.bank_nthr, self.bank_gbt_reserve = bank_nthr, bank_gbt_reserve

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

        # bank of prototype-pair threshold bits (Part 9): images only (every column continuous, d >= bank_dmin)
        bank_ok = self._use("bank") and all(t == "continuous" for t in types) and d >= self.bank_dmin and len(np.unique(y)) > 1
        if bank_ok:
            Xb = X; enc_bank = lambda A: np.asarray(A, dtype=np.float64)          # float64 projections (see _bank_quantiles)
            rng_b = np.random.default_rng([seed, 9209]); kf = len(splits) > 1
            # allowance: at most bank_share of the budget, and what is left below 0.9 after reserving bank_gbt_reserve x the
            # LightGBM charge (the compute audit found that charge up to 1.7x low on Fashion-MNIST at n_tr ~ 800-27000)
            alw = min(self.bank_share * budget, 0.9 * budget - spent[0] - self.bank_gbt_reserve * info["flops"].get("gbt", 0.0))

            def bank_proj(F):
                c = sum(bank_cost(len(tr), len(te), d, C, F, n_lams=len(self.bank_lams) + 2, n_thr=self.bank_nthr) for tr, te in splits)
                return c + (bank_cost(n, 0, d, C, F, n_lams=len(self.bank_lams) + 2, n_thr=self.bank_nthr) if kf else 0.0)
            Fb = None
            for F in (8000, 7000, 6000, 5500, 5000, 4500, 4000, 3500, 3000, 2500, 2000, 1500, 1000, 750, 500, 250):
                ns_b = min(len(splits[0][0]) - int(min(5000, max(C, round(0.15 * len(splits[0][0]))))), 15000)
                if F <= self.bank_Fmax and F <= max(250, self.bank_fcap * ns_b) and bank_proj(F) <= alw:
                    Fb = F; break
            if Fb is not None:
                if not kf:
                    tr, te = splits[0]
                    mT, PH, mA, fl, binfo = fit_bank(Xb, y, C, tr, te, Fb, rng_b, lams=self.bank_lams, n_thr=self.bank_nthr); charge("bank", fl)
                    oof["bank"] = _logp(PH); fitters["bank"] = ("done", mA, enc_bank)
                else:
                    P = np.zeros((len(H), C))
                    for tr, te in splits:
                        mT, PH, _, fl, binfo = fit_bank(Xb, y, C, tr, te, Fb, rng_b, lams=self.bank_lams, n_thr=self.bank_nthr, want_all=False); charge("bank", fl)
                        P[pos[te]] = PH
                    oof["bank"] = _logp(P); fitters["bank"] = ("bank_refit", Fb, Xb, enc_bank, rng_b)
                info["bank"] = dict(binfo, F_budget=Fb)

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
            elif isinstance(f, tuple) and f[0] == "bank_refit":
                mB, _, _, fl, _ = fit_bank(f[2], y, C, np.arange(n), np.zeros(0, np.int64), f[1], f[4], lams=self.bank_lams, n_thr=self.bank_nthr, want_all=False); charge(nm, fl)
                finals.append((w[i], lambda A, m=mB, enc=f[3]: m.proba(enc(A))))
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
