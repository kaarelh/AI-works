"""hyb_portfolio: a portfolio of discrete learners combined by cross-validated stacking (Part 8, design 3).

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
HERE = os.path.dirname(os.path.abspath(__file__)); HYB = os.path.dirname(HERE); STUDY = os.path.dirname(HYB)
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
                 et_trees=100, dfg_share=(0.35, 0.5), dfg_dmax=256, lam_w=1e-2, members=None, name="hyb_portfolio"):
        self.K_small, self.K_small_n, self.lin_one_n = K_small, K_small_n, lin_one_n
        self.K, self.kfold_max, self.hold_max, self.ks, self.lin_C = K, kfold_max, hold_max, tuple(ks), tuple(lin_C)
        self.gbt_trees, self.et_trees, self.dfg_share, self.dfg_dmax, self.lam_w = gbt_trees, et_trees, dfg_share, dfg_dmax, lam_w
        self.members = members                     # None = all applicable; else a set of member families (dev ablation)
        self.name = name

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
