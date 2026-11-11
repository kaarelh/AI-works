"""hyb_union: unified boosting over discrete weak-learner families (see DESIGN.md).

Loss: logistic (C = 2, one logit) or softmax (C > 2, one score per class).  Model F = F0 + sum_t eta_f u_t.
F0: L2-regularised logistic / softmax regression on the standard encoding, lambda (or 'intercept only') chosen by
cross-validated log-loss (convex fit, L-BFGS).
Each boosting round computes the gradient g and diagonal Hessian h of the loss at the current F and scores one proposal
from every family by its Newton statistic  S = sum_c (G_c^2 / (H_c + lam))  (= 2 x the second-order loss decrease of a
full Newton step; under 'no signal' it is chi^2 with q degrees of freedom, since Var(g) = h), minus the union-bound
threshold of that family  pen(q, L) = q + 2 sqrt(q L) + 2 L,  L = ln(N / delta), N = number of candidates searched:
  tree    one regression tree per output fitted to (g, h) by LightGBM (histogram splits); every split must pass its own
          union-bound test (min_gain_to_split = 2 ln(N_split / delta), N_split = number of candidate thresholds), so the
          tree's score is  S - (#splits) * that threshold - K;
  parity  the best Fourier character chi_S of the +-1 bit encoding: an exhaustive search of degrees 1-4 (5-6 once, on a
          subsample; every degree's subsample size set by a FLOP share), kept in a pool that is rescored every round,
          plus every round the cheap classes (degree <= 2 on all rows, extensions S u {j} of chosen characters);
          threshold per degree with N = C(d_b, k);
  linear  a ridge Newton step on all encoded inputs at once (q = K (d + 1), N = 1);
  knn     leave-one-out k-nearest-neighbour class-vote features (k in KS; q = K, N = |KS|), honest for training points.
The best family by (S - pen) takes a step with its own shrinkage; the loop stops when no family passes, when the
validation loss (n >= n_val: 10% held out) has not improved for `patience` rounds (then truncated to its best round),
or when the FLOP budget is spent.
"""
import math, itertools, time, numpy as np
from scipy.optimize import minimize

FAMS = ("tree", "parity", "linear", "knn", "forest", "lr")


_PEN = {}


def pen(q, L):
    """the chi^2_q upper-tail quantile at level exp(-L) (exact, scipy), cached"""
    key = (int(q), round(L, 3))
    if key not in _PEN:
        from scipy.stats import chi2
        v = float(chi2.isf(math.exp(-L), q)) if L < 700 else q + 2.0 * math.sqrt(q * L) + 2.0 * L
        _PEN[key] = v if np.isfinite(v) else q + 2.0 * math.sqrt(q * L) + 2.0 * L
    return _PEN[key]


def _prob(F, K):
    if K == 1:
        return 1.0 / (1.0 + np.exp(-np.clip(F, -35, 35)))
    Z = F - F.max(1, keepdims=True); P = np.exp(Z); return P / P.sum(1, keepdims=True)


def _gh(F, Y, K):
    P = _prob(F, K); return P - Y, np.maximum(P * (1 - P), 1e-6)


def _loss(F, Y, K):
    P = np.clip(_prob(F, K), 1e-12, 1.0)
    if K == 1:
        return float(-np.mean(Y * np.log(P) + (1 - Y) * np.log(np.clip(1 - P, 1e-12, 1.0))))
    return float(-np.mean(np.sum(Y * np.log(P), 1)))


# ------------------------------------------------------------------ encodings
def enc_fit(X, types):
    """Column-wise encoders fitted on the training set: linear (standardised / +-1 / one-hot), parity bits (+-1),
    tree input (categorical codes remapped to 0..V-1), kNN scale."""
    cols = []
    for j, t in enumerate(types):
        x = X[:, j]
        if t == "categorical":
            vals = np.unique(x); cols.append(("cat", vals))
        elif t == "binary":
            cols.append(("bin", float(np.min(x))))
        else:
            m, sd = float(x.mean()), float(x.std()); cols.append(("cont", (m, sd if sd > 1e-12 else 1.0, float(np.median(x)))))
    return cols


def enc_lin(X, cols):
    out = []
    for j, (kind, p) in enumerate(cols):
        x = X[:, j]
        if kind == "cat":
            out += [np.where(x == v, 1.0, 0.0) for v in p]
        elif kind == "bin":
            out.append(np.where(x > p, 1.0, -1.0))
        else:
            out.append((x - p[0]) / p[1])
    return np.stack(out, 1)


def enc_bits(X, cols, max_cat=16):
    out = []
    for j, (kind, p) in enumerate(cols):
        x = X[:, j]
        if kind == "cat":
            if 2 < len(p) <= max_cat:
                out += [np.where(x == v, 1.0, -1.0) for v in p]
            elif len(p) == 2:
                out.append(np.where(x == p[1], 1.0, -1.0))
        elif kind == "bin":
            out.append(np.where(x > p, 1.0, -1.0))
        else:
            out.append(np.where(x > p[2], 1.0, -1.0))
    return np.stack(out, 1).astype(np.float32) if out else np.zeros((len(X), 0), np.float32)


def enc_tree(X, cols):
    Z = np.array(X, dtype=np.float64, copy=True)
    for j, (kind, p) in enumerate(cols):
        if kind == "cat":
            idx = np.searchsorted(p, X[:, j]); ok = (idx < len(p)) & (p[np.minimum(idx, len(p) - 1)] == X[:, j])
            Z[:, j] = np.where(ok, idx, np.nan)
    return Z


def knn_prep(X, cols):
    """kNN scale: the linear encoding, except that commensurate continuous columns (image-like: >= 16 columns whose
    ranges differ by at most 4x between the 10th and 90th percentile) share one global scale instead of per-column
    standardisation; one-hot columns scaled by 1/sqrt(2) (a category mismatch costs 1)."""
    cc = [j for j, (kd, _) in enumerate(cols) if kd == "cont"]
    r = np.array([np.ptp(X[:, j]) for j in cc]) if cc else np.zeros(0); nz = r[r > 1e-12]
    img = bool(len(nz) >= 16 and np.percentile(nz, 90) / np.percentile(nz, 10) <= 4.0)
    gs = float(np.sqrt(np.mean([cols[j][1][1] ** 2 for j in cc]))) if cc else 1.0
    return dict(img=img, gs=gs)


def knn_enc(X, cols, kinfo):
    out = []
    for j, (kind, p) in enumerate(cols):
        x = X[:, j]
        if kind == "cat":
            out += [np.where(x == v, 1.0, 0.0) / math.sqrt(2) for v in p]
        elif kind == "bin":
            out.append(np.where(x > p, 1.0, -1.0))
        else:
            out.append((x - p[0]) / (kinfo["gs"] if kinfo["img"] else p[1]))
    return np.stack(out, 1)


# ------------------------------------------------------------------ stage 0: ridge logistic / softmax regression
def fit_lr(A, Y, K, lam, x0=None, maxiter=200):
    n, p = A.shape; nf = [0]

    def f(th):
        W = th[: p * K].reshape(p, K); b = th[p * K:]
        F = A @ W + b; nf[0] += 1
        if K == 1:
            Fz = F[:, 0]; l = float(np.mean(np.logaddexp(0, Fz) - Y[:, 0] * Fz)); G = (_prob(Fz, 1) - Y[:, 0])[:, None]
        else:
            Z = F - F.max(1, keepdims=True); lse = np.log(np.exp(Z).sum(1)); l = float(np.mean(lse - np.sum(Y * Z, 1)))
            G = _prob(F, K) - Y
        gW = A.T @ G / n + lam * W; gb = G.mean(0) + 1e-4 * b
        return l + 0.5 * lam * float(np.sum(W * W)) + 0.5e-4 * float(np.sum(b * b)), np.concatenate([gW.ravel(), gb])
    th0 = np.zeros(p * K + K) if x0 is None else x0
    r = minimize(f, th0, jac=True, method="L-BFGS-B", options=dict(maxiter=maxiter))
    th = r.x
    return th[: p * K].reshape(p, K), th[p * K:], th, nf[0] * (4.0 * n * p * K + 12.0 * n * K)


def fit_intercept(Y, K):
    pr = np.clip(Y.mean(0), 1e-3, 1 - 1e-3)
    return np.log(pr / (1 - pr)) if K == 1 else np.log(pr) - np.log(pr).mean()


def lr_stage(A, Y, K, rng, lams, folds, maxiter):
    """Choose lambda (or intercept only) by cross-validated log-loss; refit on all rows.  Returns (W, b, lam, flops)."""
    n = len(A); fl = 0.0
    if n * A.shape[1] * K > 2e7:                               # large: lambda on a subsample (80/20 of <= 8000 rows)
        sub = rng.permutation(n)[: min(n, max(4000, int(2e7 / (A.shape[1] * K))), 8000)]
        splits = [(sub[: int(0.8 * len(sub))], sub[int(0.8 * len(sub)):])]
    elif n >= 4000:                                            # one 80/20 holdout
        perm = rng.permutation(n); splits = [(perm[: int(0.8 * n)], perm[int(0.8 * n):])]
    else:
        fid = rng.permutation(n) % folds; splits = [(np.where(fid != f)[0], np.where(fid == f)[0]) for f in range(folds)]
    scores = {"none": 0.0}; scores.update({lam: 0.0 for lam in lams})
    oof = {k: np.zeros((n, K)) for k in scores}               # out-of-fold scores (k-fold case)
    for tr, te in splits:
        b0 = fit_intercept(Y[tr], K); Fi = np.tile(b0, (len(te), 1))
        scores["none"] += _loss(Fi, Y[te], K) * len(te); oof["none"][te] = Fi
        x0 = None
        for lam in sorted(lams, reverse=True):                 # warm start along the path, strong -> weak
            W, b, x0, f = fit_lr(A[tr], Y[tr], K, lam, x0, maxiter); fl += f
            Fl = A[te] @ W + b; scores[lam] += _loss(Fl, Y[te], K) * len(te); oof[lam][te] = Fl
    best = min(scores, key=lambda k: scores[k])
    F_oof = oof[best] if len(splits) > 1 else None
    if best == "none":
        return None, fit_intercept(Y, K), best, fl, F_oof
    W, b, _, f = fit_lr(A, Y, K, best, None, maxiter if n * A.shape[1] * K <= 2e7 else 40); fl += f
    return W, b, best, fl, F_oof


# ------------------------------------------------------------------ kNN vote features
def knn_lists(Q, R, kmax, self_excl, block=512):
    """indices of the kmax nearest rows of R for each row of Q (squared Euclidean), excluding the row itself if
    self_excl (Q is R).  float32 blocks."""
    Q = Q.astype(np.float32); R = R.astype(np.float32); sr = (R * R).sum(1)
    out = np.empty((len(Q), kmax), dtype=np.int64)
    for s in range(0, len(Q), block):
        q = Q[s: s + block]; D = sr[None, :] - 2.0 * (q @ R.T)
        if self_excl:
            D[np.arange(len(q)), np.arange(s, s + len(q))] = np.inf
        I = np.argpartition(D, kmax - 1, axis=1)[:, :kmax]
        o = np.argsort(np.take_along_axis(D, I, 1), axis=1); out[s: s + block] = np.take_along_axis(I, o, 1)
    return out


def knn_lists_ref(Q, R, kmax, pos, block=512):
    """like knn_lists(Q, R) but row i of Q is excluded from its own neighbours when it is reference row pos[i] >= 0"""
    Q = Q.astype(np.float32); R = R.astype(np.float32); sr = (R * R).sum(1)
    out = np.empty((len(Q), kmax), dtype=np.int64)
    for s in range(0, len(Q), block):
        q = Q[s: s + block]; D = sr[None, :] - 2.0 * (q @ R.T); p = pos[s: s + block]; ok = p >= 0
        D[np.where(ok)[0], p[ok]] = np.inf
        I = np.argpartition(D, kmax - 1, axis=1)[:, :kmax]
        o = np.argsort(np.take_along_axis(D, I, 1), axis=1); out[s: s + block] = np.take_along_axis(I, o, 1)
    return out


def knn_feats(nb, ylab, C, K, k, a=0.5):
    cnt = np.zeros((len(nb), C))
    for c in range(C):
        cnt[:, c] = np.sum(ylab[nb[:, :k]] == c, 1)
    if K == 1:
        return np.log((cnt[:, 1:2] + a) / (cnt[:, 0:1] + a))
    return np.log((cnt + a) / (k + C * a))


# ------------------------------------------------------------------ exhaustive character search
def _combos(d, k):
    return np.array(list(itertools.combinations(range(d), k)), dtype=np.int64).reshape(-1, k)


def char_search(Xb, G, Hs, ks, ms, topT, fl, thr):
    """Newton statistics sum_c (sum_i g_ic chi_S(x_i))^2 / Hs_c of every character of degree k in ks on the first ms[k]
    rows (float32).  Returns {k: list of (S, stat_on_m)}: the topT per degree for k <= 2, and for k >= 3 those above
    thr[k] (at most topT)."""
    db = Xb.shape[1]; K = G.shape[1]; out = {}
    Xb = Xb.astype(np.float32); G = G.astype(np.float32)
    for k in ks:
        m = ms.get(k, 0)
        if m < 32 or db < k or math.comb(db, k) > 2e6:          # (very wide bit sets: no enumeration of that degree)
            continue
        Xm, Gm = Xb[:m], G[:m]; Hm = Hs[k]
        Hm = np.asarray(Hm, dtype=np.float32)
        if k == 1:
            V = Xm.T @ Gm; fl[0] += 2.0 * m * db * K
            st = (V * V / Hm).sum(1); keys = [(j,) for j in range(db)]
        elif k == 2:
            st = np.zeros((db, db))
            for c in range(K):
                M = (Xm * Gm[:, c:c + 1]).T @ Xm; st += M * M / Hm[c]
            fl[0] += K * (2.0 * m * db * db + m * db)
            iu = np.triu_indices(db, 1); st = st[iu]; keys = list(zip(iu[0].tolist(), iu[1].tolist()))
        elif k in (3, 4):
            pre = _combos(db, k - 2); sts, keys = [], []
            for P in pre:
                lo = P[-1] + 1
                if lo >= db - 1:
                    continue
                w = np.prod(Xm[:, P], 1); acc = np.zeros((db - lo, db - lo))
                for c in range(K):
                    M = (Xm[:, lo:] * (Gm[:, c] * w)[:, None]).T @ Xm[:, lo:]; acc += M * M / Hm[c]
                fl[0] += K * (2.0 * m * (db - lo) ** 2 + 2 * m * (db - lo)) + m * (k - 2)
                iu = np.triu_indices(db - lo, 1); v = acc[iu]; hit = np.nonzero(v > thr[k])[0]
                sts.append(v[hit]); keys += [tuple(P.tolist()) + (lo + int(iu[0][q]), lo + int(iu[1][q])) for q in hit]
            st = np.concatenate(sts) if sts else np.zeros(0)
        elif m < 64:
            continue
        else:                                                  # k = 5, 6: products of degree-ceil(k/2), floor(k/2) tables
            k1, k2 = (k + 1) // 2, k // 2; T1, T2 = _combos(db, k1), _combos(db, k2)
            Z1 = np.ones((m, len(T1)), np.float32); Z2 = np.ones((m, len(T2)), np.float32); Xm = Xm.astype(np.float32)
            for q in range(k1):
                Z1 *= Xm[:, T1[:, q]]
            for q in range(k2):
                Z2 *= Xm[:, T2[:, q]]
            acc = np.zeros((len(T1), len(T2)), np.float32)
            for c in range(K):
                M = (Z1 * Gm[:, c:c + 1].astype(np.float32)).T @ Z2; acc += M * M / np.float32(Hm[c])
            fl[0] += K * 2.0 * m * len(T1) * len(T2) + m * (len(T1) * k1 + len(T2) * k2)
            a_ = acc.ravel(); flat = np.nonzero(a_ > thr[k])[0]
            flat = flat[np.argsort(-a_[flat])][: 40 * topT]; seen = {}
            for f in flat:
                a, b = divmod(int(f), len(T2)); S = tuple(sorted(set(T1[a].tolist()) | set(T2[b].tolist())))
                if len(S) == k and S not in seen:
                    seen[S] = float(acc[a, b])
            out[k] = sorted(seen.items(), key=lambda kv: -kv[1])[:topT]
            continue
        if len(st):
            top = np.argsort(-st)[:topT]; out[k] = [(keys[i], float(st[i])) for i in top]
    return out


def walsh_local(Xb, G, Hs, V, fl):
    """Newton statistic of every character inside the input set V (|V| <= 12): per class a Walsh transform of the
    gradient summed per cell of the 2^|V| cube.  Returns list of (S, stat)."""
    L = len(V); K = G.shape[1]
    bits = (Xb[:, V] < 0).astype(np.int64) @ (1 << np.arange(L)); fl[0] += len(Xb) * L
    st = np.zeros(1 << L)
    for c in range(K):
        h = np.bincount(bits, weights=G[:, c], minlength=1 << L).astype(np.float64); hh = 1
        while hh < len(h):
            h = h.reshape(-1, 2, hh); h = np.concatenate([h[:, 0] + h[:, 1], h[:, 0] - h[:, 1]], axis=1).reshape(-1); hh *= 2
        st += h * h / Hs[c]; fl[0] += len(Xb) + L * (1 << L)
    out = []
    for mask in np.argsort(-st)[:24]:
        if mask:
            out.append((tuple(V[q] for q in range(L) if mask >> q & 1), float(st[mask])))
    return out


def _chi(Xb, S):
    return np.prod(Xb[:, list(S)], 1)


# ------------------------------------------------------------------ the learner
class Learner:
    def __init__(self, eta_tree=0.1, eta=1.0, leaves=31, delta=0.1, split_gamma=1.0, split_gamma_val=0.2, grow_gamma_val=0.0, max_rounds=600, patience=40,
                 n_val=1000, lams=(1e-3, 1e-2, 1e-1, 1.0), knn_ks=(1, 3, 7, 15, 31), kmax=4, k_hi=6,
                 search_share=0.04, hi_share=0.03, max_bin=63, lam_tree=1.0, lam_par=1.0, max_lin=300,
                 families=FAMS, time_limit=480.0, oof=True, rf_trees=100, knn_cap=2.5e11, rf_cv_n=2000, stack=True, name="hyb_union"):
        self.__dict__.update(dict(eta_tree=eta_tree, eta=eta, leaves=leaves, delta=delta, split_gamma=split_gamma, split_gamma_val=split_gamma_val, grow_gamma_val=grow_gamma_val,
                                  max_rounds=max_rounds, patience=patience, n_val=n_val, lams=lams, knn_ks=knn_ks,
                                  kmax=kmax, k_hi=k_hi, search_share=search_share, hi_share=hi_share, max_bin=max_bin,
                                  lam_tree=lam_tree, lam_par=lam_par, max_lin=max_lin, families=families, oof=oof, rf_trees=rf_trees, knn_cap=knn_cap, rf_cv_n=rf_cv_n, stack=stack,
                                  time_limit=time_limit))
        self.name = name

    def fit(self, X, y, types, C, rng, budget=None):
        import lightgbm as lgb
        t_start = time.time()
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y).astype(np.int64); n, d = X.shape
        if budget is None:
            import common
            budget = common.budget_real(X, types, C, n)
        K = 1 if C == 2 else C
        Yall = (y[:, None] == 1).astype(float) if K == 1 else np.eye(C)[y]
        fl = [0.0]; info = dict(rounds=0, picks={f: 0 for f in FAMS})
        cols = enc_fit(X, types)
        A = enc_lin(X, cols); Bt = enc_bits(X, cols); Tz = enc_tree(X, cols)
        dl, db = A.shape[1], Bt.shape[1]
        # validation split (n >= n_val): 10% held out for early stopping
        perm = rng.permutation(n)
        if n >= self.n_val:
            nv = max(int(0.1 * n), 50); va, tr = np.sort(perm[:nv]), np.sort(perm[nv:])
        else:
            va, tr = np.zeros(0, np.int64), np.arange(n)
        ntr = len(tr); Y, Yv = Yall[tr], Yall[va]

        # ---- stage 0: linear model (lambda by CV)
        W0, b0, lam0, f, F_oof = lr_stage(A[tr], Y, K, rng, self.lams, 5, 200 if n < 20000 else 60)
        fl[0] += f; info["lr_lambda"] = lam0; info["t_lr"] = round(time.time() - t_start, 2)
        lin0 = lambda Z, W0=W0, b0=b0: (Z @ W0 + b0) if W0 is not None else np.tile(b0, (len(Z), 1))
        F, Fv = lin0(A[tr]), lin0(A[va])
        if F_oof is not None and self.oof:                     # honest stacking: boost on out-of-fold linear scores
            F = F_oof.copy()
        lr_tr, lr_va = F - F.mean(0), Fv - F.mean(0)              # the 'lr' block rescales the (centred) linear scores
        lr_mu = F.mean(0); use_lrs = "lr" in self.families and W0 is not None
        comps = []                                            # (family, params, coef(K,) or W, eta)

        # ---- kNN lists (honest LOO for training rows), budget share <= 25%
        knn = None
        if "knn" in self.families:
            kinfo = knn_prep(X, cols); Xk = knn_enc(X, cols, kinfo)
            # feature subset (highest variance) so that the n^2 distance cost stays within 20% of the budget
            # distance cost 2 n_q n_ref d_k <= kcap: first at most 128 (highest-variance) columns, then a random
            # reference subset of the training rows (training rows outside it are still honest: never their own neighbour)
            dk = Xk.shape[1]; kcap = min(0.2 * budget, self.knn_cap)
            dsel = dk if 2.0 * ntr * ntr * dk <= kcap else min(dk, 128)
            keep = np.arange(dk) if dsel >= dk else np.sort(np.argsort(-Xk[tr].var(0))[:dsel])
            nref = int(min(ntr, kcap / (2.0 * n * len(keep))))
            if nref >= 200:
                kmax = min(max(self.knn_ks), nref - 1)
                Xk = Xk[:, keep]; ref = np.sort(rng.permutation(ntr)[:nref]) if nref < ntr else np.arange(ntr)
                pos = np.full(ntr, -1); pos[ref] = np.arange(nref)
                nb_tr = knn_lists_ref(Xk[tr], Xk[tr][ref], kmax, pos)
                fl[0] += 2.0 * ntr * nref * len(keep) + 6.0 * ntr * nref
                nb_va = knn_lists(Xk[va], Xk[tr][ref], kmax, False) if len(va) else np.zeros((0, kmax), np.int64)
                fl[0] += 2.0 * len(va) * nref * len(keep) + 6.0 * len(va) * nref
                yref = y[tr][ref]
                ks = [k for k in self.knn_ks if k <= kmax]
                kf = {k: (knn_feats(nb_tr, yref, C, K, k), knn_feats(nb_va, yref, C, K, k)) for k in ks}
                for k in ks:                                   # centre on the training mean
                    mu = kf[k][0].mean(0); kf[k] = (kf[k][0] - mu, kf[k][1] - mu, mu)
                # prediction-time reference: all training rows (validation included) up to nref rows
                pref = np.sort(rng.permutation(n)[:nref]) if nref < n else np.arange(n)
                knn = dict(Xk=Xk[pref], yk=y[pref], keep=keep, ks=ks, kf=kf, kmax=kmax, kinfo=kinfo)
                info["knn_ref"] = int(nref)
                info["knn_dims"] = int(len(keep)); info["knn_img_scale"] = bool(kinfo["img"])

        info["t_knn"] = round(time.time() - t_start, 2)
        # ---- random forest out-of-bag vote features (honest for training rows)
        forest = None
        if "forest" in self.families and ntr >= 30:
            from sklearn.ensemble import ExtraTreesClassifier
            ntrees = int(max(30, min(self.rf_trees, self.rf_trees * 2e6 / (ntr * d))))
            mtry = max(1, int(math.sqrt(A.shape[1])))
            cv_fit = ntr < self.rf_cv_n                        # small n: 5-fold cross-fitted votes (OOB votes are pessimistic)
            ntcv = max(30, ntrees // 2)                        # trees per cross-fit fold
            rf_cost = 4.0 * ntr * mtry * math.log2(max(ntr, 2)) ** 2 * (ntrees + (0.8 * 5 * ntcv if cv_fit else 0))
            if rf_cost < 0.15 * budget:
                seed = int(rng.integers(1 << 30))
                rf = ExtraTreesClassifier(n_estimators=ntrees, max_features=mtry, oob_score=not cv_fit, bootstrap=not cv_fit,
                                          n_jobs=1, random_state=seed).fit(A[tr], y[tr])
                fl[0] += rf_cost + 2.0 * ntrees * n * math.log2(max(ntr, 2)) * (2 if cv_fit else 1)   # (+ votes)
                def rf_feat(Pr, cl):
                    Pf = np.zeros((len(Pr), C)); Pf[:, cl] = Pr
                    return (np.log((Pf[:, 1:2] + 0.02) / (Pf[:, 0:1] + 0.02)) if K == 1 else np.log(Pf + 0.02))
                prior = np.bincount(y[tr], minlength=C) / ntr
                if cv_fit:
                    fid = rng.permutation(ntr) % 5; ftr = np.zeros((ntr, K))
                    for f_ in range(5):
                        a_, b_ = fid != f_, fid == f_
                        m_ = ExtraTreesClassifier(n_estimators=ntcv, max_features=mtry, n_jobs=1,
                                                  random_state=seed + 1 + f_).fit(A[tr][a_], y[tr][a_])
                        ftr[b_] = rf_feat(m_.predict_proba(A[tr][b_]), m_.classes_)
                else:
                    Po = rf.oob_decision_function_; bad = ~np.isfinite(Po).all(1)
                    Po = np.where(bad[:, None], prior[rf.classes_], Po); ftr = rf_feat(Po, rf.classes_)
                mu = ftr.mean(0)
                fva = rf_feat(rf.predict_proba(A[va]), rf.classes_) if len(va) else np.zeros((0, K))
                forest = dict(rf=rf, feat=lambda Pr, rf=rf: rf_feat(Pr, rf.classes_), tr=ftr - mu, va=fva - mu, mu=mu)
                info["rf_trees"] = ntrees
        info["t_rf"] = round(time.time() - t_start, 2)
        # ---- LightGBM booster (trees fitted to our gradient)
        booster = None
        if "tree" in self.families:
            nbins = [min(self.max_bin, len(np.unique(Tz[tr, j][~np.isnan(Tz[tr, j])]))) for j in range(d)]
            Nsplit = max(sum(max(b - 1, 0) for b in nbins), 1)
            tau = (self.split_gamma if not len(va) else self.split_gamma_val) * 2.0 * math.log(Nsplit / self.delta)
            tau_grow = tau if not len(va) else self.grow_gamma_val * 2.0 * math.log(Nsplit / self.delta)
            cat_idx = [j for j, (kd, _) in enumerate(cols) if kd == "cat"]
            ff = 1.0 if d <= 200 else max(0.2, 200.0 / d)
            params = dict(objective="none", num_class=K, num_leaves=self.leaves, learning_rate=self.eta_tree,
                          min_data_in_leaf=int(max(3, min(20, ntr // 25))), min_sum_hessian_in_leaf=1e-3,
                          lambda_l2=self.lam_tree, min_gain_to_split=tau_grow, max_bin=self.max_bin, feature_fraction=ff,
                          feature_fraction_seed=int(rng.integers(1 << 30)), verbose=-1, num_threads=1,
                          boost_from_average=False, max_cat_to_onehot=8, cat_smooth=10, deterministic=True)
            ds = lgb.Dataset(Tz[tr], categorical_feature=cat_idx if cat_idx else "auto", free_raw_data=False,
                             params=dict(max_bin=self.max_bin, verbose=-1, min_data_in_bin=1, feature_pre_filter=False))
            try:
                booster = lgb.Booster(params=params, train_set=ds)
            except Exception:                                  # (LightGBM refuses degenerate data: no tree family)
                booster = None
            fl[0] += 10.0 * ntr * d                            # binning
            info["tau_split"] = round(tau, 2)
            tree_cost = lambda: 2.0 * ntr * d * ff * (1 + math.ceil(math.log2(self.leaves))) * K + 10.0 * d * self.max_bin * self.leaves * K

        # ---- parity search setup
        use_par = "parity" in self.families and db >= 1
        pool, chis, chosen = {}, {}, []                       # pool: S -> lnN of its class
        lnNk = {k: math.log(max(math.comb(db, k), 1)) + math.log(max(self.k_hi, self.kmax)) for k in range(1, 7)}
        last_full, n_full, par_since, last_pick = -999, 0, False, -999

        def ms_for(share, ks):
            out = {}
            for k in ks:
                if k <= 4:
                    per_row = K * {1: 2.0 * db, 2: 2.0 * db * db, 3: 2.0 * db ** 3 / 3, 4: 2.0 * db ** 4 / 12}[k]
                else:
                    k1, k2 = (k + 1) // 2, k // 2; per_row = K * 2.0 * math.comb(db, k1) * math.comb(db, k2) + math.comb(db, k1) * k1
                out[k] = int(min(ntr, share * budget / max(per_row, 1.0)))
            return out

        # ---- linear block (ridge Newton step)
        use_lin = "linear" in self.families and K * (dl + 1) <= self.max_lin
        A1 = np.hstack([A, np.ones((n, 1))]) if use_lin else None

        # ---- stacking init: joint ridge-Newton fit of the honest blocks' weights (linear-start rescale, forest votes,
        #      best-k kNN votes), per class, 8 iterations; these are a handful of convex stacking weights, no search
        blocks = []
        if use_lrs:
            blocks.append(("lr", None, lr_tr, lr_va))
        if forest is not None:
            blocks.append(("forest", None, forest["tr"], forest["va"]))
        if knn is not None:
            G0, H0 = _gh(F, Y, K); G0, H0 = G0.reshape(ntr, K), H0.reshape(ntr, K)
            kb = max(knn["ks"], key=lambda k: float(np.sum(np.sum(G0 * knn["kf"][k][0], 0) ** 2 /
                                                           (np.sum(H0 * knn["kf"][k][0] ** 2, 0) + self.lam_par))))
            blocks.append(("knn", kb, knn["kf"][kb][0], knn["kf"][kb][1]))
        if self.stack and len(blocks) >= 1:
            Vt = np.stack([b[2] for b in blocks], 2); Vv = np.stack([b[3] for b in blocks], 2)   # (n, K, B)
            Bn = Vt.shape[2]; Wst = np.zeros((K, Bn)); F_base, Fv_base = F.copy(), Fv.copy()
            for _ in range(8):
                Fc = F_base + np.einsum("nkb,kb->nk", Vt, Wst)
                G0, H0 = _gh(Fc, Y, K); G0, H0 = G0.reshape(ntr, K), H0.reshape(ntr, K)
                for c in range(K):
                    Vc = Vt[:, c, :]; Hm = (Vc * H0[:, c:c + 1]).T @ Vc + self.lam_par * np.eye(Bn)
                    gr = Vc.T @ G0[:, c] + self.lam_par * Wst[c]; Wst[c] -= np.linalg.solve(Hm, gr)
                fl[0] += 8.0 * K * (2.0 * ntr * Bn * Bn + 4.0 * ntr * Bn) + 30.0 * ntr * K
            F = F_base + np.einsum("nkb,kb->nk", Vt, Wst); Fv = Fv_base + np.einsum("nkb,kb->nk", Vv, Wst)
            for j, (fam, k, _, _) in enumerate(blocks):
                comps.append((fam, k, Wst[:, j].copy()))
            info["stack_w"] = {b[0]: np.round(Wst[:, j], 2).tolist() for j, b in enumerate(blocks)}
        best_v, best_round, since = _loss(Fv, Yv, K) if len(va) else np.inf, 0, 0
        n_stack = len(comps)
        hist = []                                             # per round: len(comps), booster trees
        for rnd in range(self.max_rounds):
            if fl[0] > 0.9 * budget or time.time() - t_start > self.time_limit:
                info["stop"] = "budget"; break
            G, H = _gh(F, Y, K); fl[0] += 14.0 * ntr * K
            if K == 1:
                G, H = G.reshape(-1, 1), H.reshape(-1, 1)
            Hs = H.sum(0)
            cands = []
            # -- tree
            if booster is not None:
                fl[0] += tree_cost()
                g_, h_ = (G[:, 0], H[:, 0]) if K == 1 else (G, H)
                try:
                    booster.update(fobj=lambda preds, data, g_=g_, h_=h_: (g_, h_)); ok = True
                except Exception:
                    ok = False
            if booster is not None and not ok and booster.current_iteration() == 0:
                booster = None                                 # degenerate data: drop the tree family
            if booster is not None and ok:
                it = booster.current_iteration() - 1
                u = booster.predict(Tz[tr], start_iteration=it, num_iteration=1, raw_score=True).reshape(ntr, K)
                fl[0] += 2.0 * ntr * K * math.log2(self.leaves)
                S = -float(np.sum(G * u)) / self.eta_tree
                dump = booster.dump_model(start_iteration=it, num_iteration=1)["tree_info"]
                nspl = sum(t["num_leaves"] - 1 for t in dump)
                if nspl > 0:
                    cands.append((S - nspl * tau - K, "tree", None, u))
                else:
                    booster.rollback_one_iter()
            # -- parity
            if use_par:
                full = rnd == 0 or (rnd - last_full >= 10 and n_full < 5 and par_since)
                active = rnd < 10 or rnd - last_pick <= 20      # cheap per-round classes only while parities are in use
                ks = (list(range(1, self.kmax + 1)) if rnd == 0 else [1, 2, 3]) if full else ([1, 2] if active else [])
                ms = ms_for((self.search_share / max(self.kmax - 2, 1)) if full else 0.0005, ks)
                if rnd == 0 and self.k_hi > self.kmax and db <= 32:
                    ks += list(range(self.kmax + 1, self.k_hi + 1)); ms.update(ms_for(self.hi_share, range(self.kmax + 1, self.k_hi + 1)))
                Hsk = {k: H[: ms.get(k, 0)].sum(0) + self.lam_par for k in ks}
                thr_k = {k: pen(K, lnNk[k] + math.log(1 / self.delta)) for k in range(1, 7)}
                found = char_search(Bt[tr], G, Hsk, ks, ms, 16, fl, thr_k)
                if full:
                    last_full, n_full, par_since = rnd, n_full + 1, False
                for k, lst in found.items():
                    thr = pen(K, lnNk[k] + math.log(1 / self.delta))
                    for S_, st in lst:
                        if st > thr or (k <= 2 and ms[k] >= ntr):
                            pool.setdefault(S_, k)
                V = sorted(set(v for S_ in chosen for v in S_))
                if 2 <= len(V) <= 12 and (active or full):                              # local: every character inside the inputs in use
                    for S_, st in walsh_local(Bt[tr], G, Hs + self.lam_par, V, fl):
                        lnl = math.log(max(math.comb(len(V), len(S_)), 1)) + math.log(len(V))
                        if S_ not in pool and st > pen(K, lnl + math.log(1 / self.delta)):
                            pool[S_] = ("loc", lnl)
                n_ext = int(min(16, 0.0005 * budget / (2.0 * ntr * db * K + 1)))  # extension bases this round (FLOP cap)
                for S_ in (chosen[-n_ext:] if (active or full) and n_ext > 0 else []):   # extensions S u {j}
                    cs = chis[S_][0] if S_ in chis else _chi(Bt[tr], S_)
                    V = Bt[tr].T @ (G * cs[:, None]); fl[0] += 2.0 * ntr * db * K
                    st = (V * V / (Hs + self.lam_par)).sum(1)
                    thr = pen(K, math.log(db * max(len(chosen), 1)) + math.log(1 / self.delta))
                    for j in np.argsort(-st)[:4]:
                        if st[j] > thr and j not in S_:
                            T_ = tuple(sorted(S_ + (int(j),)))
                            if T_ not in pool:
                                pool[T_] = ("ext", math.log(db * max(len(chosen), 1)))
                bestp = None
                for S_, tag in pool.items():
                    if S_ not in chis:
                        chis[S_] = (_chi(Bt[tr], S_), _chi(Bt[va], S_) if len(va) else np.zeros(0)); fl[0] += n * len(S_)
                    c_ = chis[S_][0]; V = c_ @ G; fl[0] += 2.0 * ntr * K
                    st = float(np.sum(V * V / (Hs + self.lam_par)))
                    L = (tag[1] if isinstance(tag, tuple) else lnNk[tag]) + math.log(1 / self.delta)
                    sc = st - pen(K, L)
                    if bestp is None or sc > bestp[0]:
                        bestp = (sc, S_, V)
                if bestp is not None:
                    sc, S_, V = bestp; coef = -V / (Hs + self.lam_par)
                    cands.append((sc, "parity", (S_, coef), chis[S_][0][:, None] * coef[None, :]))
            # -- linear block
            if use_lin:
                Atr = A1[tr]; W = np.zeros((dl + 1, K)); S = 0.0
                for c in range(K):
                    Hm = (Atr * H[:, c:c + 1]).T @ Atr + self.lam_par * np.eye(dl + 1); b_ = -Atr.T @ G[:, c]
                    w_ = np.linalg.solve(Hm, b_); W[:, c] = w_; S += float(b_ @ w_)
                fl[0] += K * (2.0 * ntr * (dl + 1) ** 2 + 4.0 * ntr * (dl + 1) + (dl + 1) ** 3 / 3)
                cands.append((S - pen(K * (dl + 1), math.log(1 / self.delta)), "linear", W, Atr @ W))
            # -- kNN blocks
            if knn is not None:
                best_k = None
                for k in knn["ks"]:
                    v = knn["kf"][k][0]; num = np.sum(G * v, 0); den = np.sum(H * v * v, 0) + self.lam_par
                    fl[0] += 4.0 * ntr * K
                    st = float(np.sum(num * num / den)); coef = -num / den
                    sc = st - pen(K, math.log(len(knn["ks"]) / self.delta))
                    if best_k is None or sc > best_k[0]:
                        best_k = (sc, k, coef)
                sc, k, coef = best_k
                cands.append((sc, "knn", (k, coef), knn["kf"][k][0] * coef[None, :]))
            # -- forest block
            if forest is not None:
                v = forest["tr"]; num = np.sum(G * v, 0); den = np.sum(H * v * v, 0) + self.lam_par; fl[0] += 4.0 * ntr * K
                coef = -num / den
                cands.append((float(np.sum(num * num / den)) - pen(K, math.log(1 / self.delta)), "forest", coef, v * coef[None, :]))
            # -- lr block: per-class rescaling of the linear start
            if use_lrs:
                v = lr_tr; num = np.sum(G * v, 0); den = np.sum(H * v * v, 0) + self.lam_par; fl[0] += 4.0 * ntr * K
                coef = -num / den
                cands.append((float(np.sum(num * num / den)) - pen(K, math.log(1 / self.delta)), "lr", coef, v * coef[None, :]))
            # -- pick
            cands.sort(key=lambda c: -c[0])
            if rnd < 3 or rnd % 25 == 0:
                info.setdefault("cand_log", []).append((rnd, [(c[1], round(c[0], 1)) for c in cands]))
            if not cands or (cands[0][0] <= 0 and not (len(va) and any(c[1] == "tree" for c in cands))):
                if booster is not None and any(c[1] == "tree" for c in cands):
                    booster.rollback_one_iter()
                info["stop"] = "no family passes"; break
            if cands[0][0] <= 0:                               # (validation runs) nothing passes: a tree step
                cands = [c for c in cands if c[1] == "tree"]
            sc, fam, par, u = cands[0]
            if fam != "tree" and booster is not None and any(c[1] == "tree" for c in cands):
                booster.rollback_one_iter()
            info["picks"][fam] += 1
            if fam == "tree":
                F = F + u
                if len(va):
                    it = booster.current_iteration() - 1
                    Fv = Fv + booster.predict(Tz[va], start_iteration=it, num_iteration=1, raw_score=True).reshape(len(va), K)
            else:
                e = self.eta
                F = F + e * u
                if fam == "parity":
                    S_, coef = par; comps.append(("parity", S_, coef * e)); par_since = True; last_pick = rnd
                    if S_ not in chosen:
                        chosen.append(S_)
                    if len(va):
                        Fv = Fv + e * chis[S_][1][:, None] * coef[None, :]
                elif fam == "lr":
                    comps.append(("lr", None, par * e))
                    if len(va):
                        Fv = Fv + e * lr_va * par[None, :]
                elif fam == "forest":
                    comps.append(("forest", None, par * e))
                    if len(va):
                        Fv = Fv + e * forest["va"] * par[None, :]
                elif fam == "linear":
                    comps.append(("linear", None, par * e))
                    if len(va):
                        Fv = Fv + e * (A1[va] @ par)
                else:
                    k, coef = par; comps.append(("knn", k, coef * e))
                    if len(va):
                        Fv = Fv + e * knn["kf"][k][1] * coef[None, :]
            hist.append((len(comps), booster.current_iteration() if booster is not None else 0))
            info["rounds"] = rnd + 1
            if len(va):
                lv = _loss(Fv, Yv, K); fl[0] += 14.0 * len(va) * K
                pred_tr = (F[:, 0] > 0) if K == 1 else np.argmax(F, 1); pred_va = (Fv[:, 0] > 0) if K == 1 else np.argmax(Fv, 1)
                if np.all(pred_tr == y[tr]) and np.all(pred_va == y[va]):    # every label right (DFG's stop)
                    best_v, best_round = lv, rnd + 1; info["stop"] = "all labels right"; break
                if lv < best_v - 1e-6:
                    best_v, best_round, since = lv, rnd + 1, 0
                else:
                    since += 1
                    if since >= self.patience:
                        info["stop"] = "validation"; break
        # ---- truncate to the best validation round
        if len(va) and info["rounds"] > 0:
            nc, nt = hist[best_round - 1] if best_round > 0 else (n_stack, 0)
            comps = comps[:nc]
            while booster is not None and booster.current_iteration() > nt:
                booster.rollback_one_iter()
            info["best_round"] = best_round
        info["n_comps"] = len(comps); info["n_trees"] = booster.current_iteration() if booster is not None else 0
        info["seconds"] = round(time.time() - t_start, 1); info["flops_frac"] = fl[0] / budget

        # ---- predictor (kNN reference set at prediction time: all n training points)
        Xk_all = knn["Xk"] if knn is not None else None
        par_comps = [(S_, c) for f_, S_, c in comps if f_ == "parity"]
        lin_W = sum((c for f_, _, c in comps if f_ == "linear"), np.zeros((dl + 1, K)))
        knn_W = {}
        for f_, k, c in comps:
            if f_ == "knn":
                knn_W[k] = knn_W.get(k, 0) + c
        nt_final = booster.current_iteration() if booster is not None else 0
        rf_W = sum((c for f_, _, c in comps if f_ == "forest"), np.zeros(K))
        lr_W = sum((c for f_, _, c in comps if f_ == "lr"), np.zeros(K))

        def predict(Z):
            Z = np.asarray(Z, dtype=np.float64); Az = enc_lin(Z, cols); Fz = lin0(Az)
            if np.any(lr_W):
                Fz = Fz + (Fz - lr_mu) * lr_W[None, :]
            if par_comps:
                Bz = enc_bits(Z, cols)
                for S_, c in par_comps:
                    Fz = Fz + _chi(Bz, S_)[:, None] * c[None, :]
            if use_lin and np.any(lin_W):
                Fz = Fz + np.hstack([Az, np.ones((len(Z), 1))]) @ lin_W
            if knn_W:
                Zk = knn_enc(Z, cols, knn["kinfo"])[:, knn["keep"]]
                nb = knn_lists(Zk, Xk_all, knn["kmax"], False)
                for k, c in knn_W.items():
                    v = knn_feats(nb, knn["yk"], C, K, k) - knn["kf"][k][2]
                    Fz = Fz + v * c[None, :]
            if np.any(rf_W):
                Fz = Fz + (forest["feat"](forest["rf"].predict_proba(Az)) - forest["mu"]) * rf_W[None, :]
            if nt_final > 0:
                Fz = Fz + booster.predict(enc_tree(Z, cols), raw_score=True).reshape(len(Z), K)
            return (Fz[:, 0] > 0).astype(np.int64) if K == 1 else np.argmax(Fz, 1)
        return dict(predict=predict, flops=fl[0], info=info)
