"""dfg_dirs: DFG on standard classification data, with a dictionary of data-derived directions.

A discrete enumerate-and-test learner.  MLP hidden units are thresholded linear directions; here the candidate units are
gates [u.z > t] (and hinges [u.z > t](u.z - t), squares (u.z)^2) on a FINITE set of axes u that the data supplies, with t
at quantiles.  Every candidate is tested against the current least-squares residual with a union-bound threshold, and
everything that passes is accepted in rounds, as in DFG.  The only continuous parameters are the readout weights.

  z = standard encoding (continuous standardized, binary +-1, categorical one-hot; constant columns dropped)
  features: intercept + LINEAR BLOCK (all coordinates, ridge set by GCV; added when a chi^2 test says the linear part
            has signal, else the ridge background carries it)
  repeat (rounds):
    LS fit of the one-hot labels Y on the features (ridge);  R = Y - fit;  whiten R over classes -> Rw (n x C', C' = C-1)
    score of a candidate f:  T(f) = ||Rw^T f_perp||^2 / ||f_perp||^2   ~ chi^2_{C'} under the null (f independent of R)
    candidate classes, each with its own size N and threshold tau(N) = c^2 chi2.isf(delta / (K N), C'):
      coord   gates (and hinges) on every coordinate axis at Q quantile cuts                         N = #cuts
      dir     gates / hinges / square on DIRECTION axes derived this round:
                - discriminant directions: the linear block's per-class weight vectors of the current fit
                - spectral directions: top eigenvectors of the residual-weighted second moment
                  M_c = Z^T diag(rw_c) Z / n, kept only above the noise edge 2 sigma sqrt(D / n) (DFG's spectral block)
                - local directions: the residual's class-mean difference INSIDE the region of an accepted gate,
                  z^T (rw_c * f_a) (top singular direction over classes)
                - prototype directions (multi-class only): the 32 centered training points with the largest
                  whitened residual (gates on u.z are halfspaces through a misfit example)          N = #cuts
      prod    products f_a * g of an accepted feature f_a (top bases by readout weight) with a gate / hinge g on any
              axis (composition: a small class per base, so a low threshold)                         N = #bases x #cuts
    marginal scores for all cuts of all axes at once from per-bin sums (one bincount over (row, axis) bins per class
    column, then cumulative sums over the <= Q + 1 bins; no per-candidate pass over the data); the top-M passing candidates are materialized, orthogonalized against the current features, and
    accepted greedily in Gram space while their *orthogonalized* score still clears their class threshold
    a gate / hinge / product candidate needs support >= 30 rows on its smaller side (the chi^2 tail is not valid on a
    handful of rows; without this, products memorize single training points)
    stop when nothing passes, at the feature cap p sqrt(C') <= n / 3 (and p <= 800: the LS readout has p C' weights),
    after 40 rounds, or when the FLOPs spent plus
    the reserved cost of the readout (below, at the next round's size) would pass 0.75 of the budget
    direction axes that no accepted feature uses are dropped from the scan one round after they were derived
  readout: multinomial logistic regression (softmax, L2) on the standardized grown features, by L-BFGS; lambda from
           {1e-1 (n <= 1000 only), 1e-2, 1e-3, 1e-4} by CV on the training set (5-fold at n <= 1000, else 3-fold; warm
           starts from the largest lambda; ties go to the larger lambda); the L-BFGS iteration cap is set so that the
           readout fits in what is left of the budget
  frozen settings (v2, chosen on the dev datasets): c = 0.8, delta = 0.1, K = 4, Q = 16 cuts per axis, up to 64 accepted
  per round from the top 512 marginal candidates, 24 product bases, hinges and squares on, inputs clipped to [-6, 6]
Compute: FLOPs counted for every product, solve, eigendecomposition, sort, cumulative sum and readout iteration
(multiply-add = 2); each fit stays within one MLP training run (harness.mlp_flops).
"""
import math, numpy as np
from scipy.stats import chi2
from scipy.optimize import minimize
import harness as H


class Learner:
    def __init__(self, c=0.8, delta=0.1, K=4, Q=16, rounds=40, max_new=64, M_top=512, max_bases=24, p_frac=1 / 3,
                 p_cap=800, hinge=True, square=True, local=True, spectral=True, disc=True, products=True, clip=6.0,
                 ridge_f=1e-3, proto="multiclass", softmax=True, cv_folds=3, lams=(1e-4, 1e-3, 1e-2, 1e-1), budget_frac=0.75, min_support=30, name="dfg_dirs-v2"):
        self.__dict__.update(dict(c=c, delta=delta, K=K, Q=Q, rounds=rounds, max_new=max_new, M_top=M_top,
                                  max_bases=max_bases, p_frac=p_frac, p_cap=p_cap, hinge=hinge, square=square, local=local,
                                  spectral=spectral, disc=disc, proto=proto, products=products, clip=clip, ridge_f=ridge_f,
                                  softmax=softmax, cv_folds=cv_folds, lams=lams, budget_frac=budget_frac,
                                  min_support=min_support))
        self.name = name

    # ------------------------------------------------------------------ encoding
    def _encoder(self, X, types):
        Z0 = H.encode_standard(X, types)
        keep = np.where(Z0.std(0) > 1e-9)[0]
        clip = self.clip

        def enc(T):
            Z = H.encode_standard(np.asarray(T, dtype=np.float64), types, ref=X)[:, keep]
            return np.clip(Z, -clip, clip) if clip else Z
        return enc

    # ------------------------------------------------------------------ fit
    def fit(self, X, y, types, C, rng):
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y); n = len(y)
        self._msup = self.min_support(n) if callable(self.min_support) else float(self.min_support)
        budget = H.mlp_flops(X, types, C, n)
        fl = [0.0]
        enc = self._encoder(X, types); Z = enc(X); D = Z.shape[1]
        Y = np.zeros((n, C)); Y[np.arange(n), y] = 1.0
        info = dict(log=[])

        # ---------- axes: coordinates first; direction axes are appended as they are derived
        axes = [("coord", j) for j in range(D)]
        P = [Z[:, j] for j in range(D)]
        min_side = max(4, int(0.005 * n))
        orders, cuts, isbin = [], [], []

        def add_axis(kind, obj, p):
            o = np.argsort(p, kind="stable"); v = p[o]; fl[0] += n * math.log2(max(n, 2))
            b = np.nonzero(v[1:] > v[:-1])[0] + 1
            b = b[(b >= min_side) & (b <= n - min_side)]
            if len(b) > self.Q:
                tg = np.arange(1, self.Q + 1) * n / (self.Q + 1)
                i = np.clip(np.searchsorted(b, tg), 1, len(b) - 1)
                i = np.where(np.abs(b[i - 1] - tg) < np.abs(b[i] - tg), i - 1, i)
                b = np.unique(b[i])
            t = (v[b - 1] + v[b]) / 2 if len(b) else np.zeros(0)
            orders.append(o); cuts.append((b, t)); isbin.append(len(np.unique(v)) <= 2)
            return len(axes) - 1

        for j in range(D):
            add_axis(*axes[j], P[j])
        axis_vec = {}                                  # axis id -> direction vector (for direction axes)

        # ---------- features: list of factor tuples; factor = (kind, axis, t)   kind in lin, step, hinge+, hinge-, sq
        def fval(fac, Pm):
            v = np.ones(len(Pm[0]))
            for kind, a, t in fac:
                p = Pm[a]
                if kind == "lin":
                    v = v * p
                elif kind == "step":
                    v = v * (p > t)
                elif kind == "hinge+":
                    v = v * np.maximum(p - t, 0.0)
                elif kind == "hinge-":
                    v = v * np.maximum(t - p, 0.0)
                elif kind == "sq":
                    v = v * (p - t) ** 2
            return v

        feats, cols, pen = [()], [np.ones(n)], [0.0]
        is_lin = [False]

        # ---------- ridge for the linear block by GCV (eigendecomposition of the centered Gram)
        Zc = Z - Z.mean(0); Yc = Y - Y.mean(0)
        G0 = Zc.T @ Zc; fl[0] += 2 * n * D * D
        ev, EV = np.linalg.eigh(G0); fl[0] += 10 * D ** 3
        ev = np.maximum(ev, 0)
        B0 = EV.T @ (Zc.T @ Yc); fl[0] += 2 * n * D * C + 2 * D * D * C
        tot = float(np.sum(Yc * Yc))
        best = None
        for lam in n * np.logspace(-4, 1, 11):
            sh = ev / (ev + lam); df = float(np.sum(sh))
            rss = tot - float(np.sum((2 * sh - sh ** 2)[:, None] * B0 ** 2 / np.maximum(ev, 1e-12)[:, None]))
            g = n * rss / max(n - df, 1.0) ** 2
            if best is None or g < best[0]:
                best = (g, lam)
        lam_lin = best[1]
        # chi^2 test for the linear block against the labels' residual (intercept only)
        R0 = Y - Y.mean(0)
        Rw0, Cp = self._whiten(R0)
        Tlin = float(np.sum((EV.T @ (Zc.T @ Rw0)) ** 2 / np.maximum(ev, 1e-9 * max(ev.max(), 1e-12))[:, None]))
        fl[0] += 2 * n * D * Cp
        k = D * Cp; tt = math.log(1 / self.delta)
        lin_on = Tlin > k + 2 * math.sqrt(k * tt) + 2 * tt
        info["lin_block"] = bool(lin_on); info["lam_lin"] = float(lam_lin / n)
        for j in range(D):                             # (if the test fails, the linear part enters as a ridge background)
            feats.append((("lin", j, 0.0),)); cols.append(Z[:, j].copy()); pen.append(lam_lin if lin_on else 10 * lam_lin)
            is_lin.append(True)

        # ---------- incremental least squares
        A = np.stack(cols, 1); Gm = A.T @ A; AY = A.T @ Y; fl[0] += 2 * n * A.shape[1] ** 2 + 2 * n * A.shape[1] * C

        def solve():
            p = A.shape[1]
            Wt = np.linalg.solve(Gm + np.diag(pen) + 1e-9 * n * np.eye(p), AY); fl[0] += 2 * p ** 3 / 3 + 2 * p * p * C
            Rr = Y - A @ Wt; fl[0] += 2 * n * p * C
            return Wt, Rr

        Wt, R = solve()
        p_max = int(min(self.p_cap, max(D + 1, self.p_frac * n / math.sqrt(max(C - 1, 1)))))   # p sqrt(C') <= n / 3
        folds = (5 if n <= 1000 else 3) if self.cv_folds > 1 else 1
        lam_grid = [l for l in self.lams if n <= 1000 or l < 0.05]          # the largest lambda only at n <= 1000
        n_fits = 1 + (folds - 1) * len(lam_grid) if folds > 1 else 1       # fold fits use (folds-1)/folds of the data
        per_eval = lambda p: 4 * n * p * C + 12 * n * C + 60 * p * C
        readout_cost = lambda p: (n_fits * 100 * per_eval(p) + 2 * n * p * C * len(lam_grid)) if self.softmax else 0.0
        rounds_done = 0
        for rnd in range(self.rounds):
            if fl[0] + readout_cost(A.shape[1] + self.max_new) > self.budget_frac * budget or A.shape[1] >= p_max:
                break
            Rw, Cp = self._whiten(R); fl[0] += 2 * n * C * C + 2 * n * C * Cp
            tau = lambda N: self.c ** 2 * float(chi2.isf(self.delta / (self.K * max(N, 1)), Cp))
            Pm = P                                     # list of axis value arrays
            # ---- new direction axes for this round
            new_dirs = []
            if self.disc and rnd == 0 and lin_on:
                Wl = Wt[1:D + 1]                          # D x C per-class linear scores
                for cc in range(C if C > 2 else 1):
                    new_dirs.append(("disc", Wl[:, cc] - Wl.mean(1) if C > 2 else Wl[:, 0] - Wl[:, 1]))
            if self.spectral and n >= 2 * D:
                sig = math.sqrt(float(np.mean((Rw ** 2).sum(1) / Cp * (np.sum(Z * Z, 1) / D) ** 2)))
                edge = 2 * sig * math.sqrt(D / n) * (1 + math.sqrt(2 * math.log(1 / self.delta) / D))
                for cc in range(Cp):
                    Mc = (Z * Rw[:, cc:cc + 1]).T @ Z / n; fl[0] += 2 * n * D * D + n * D
                    lam, U = np.linalg.eigh(Mc); fl[0] += 10 * D ** 3
                    for q in np.argsort(-np.abs(lam))[:2]:
                        if abs(lam[q]) > edge:
                            new_dirs.append(("spec", U[:, q].copy()))
            n_proto = (32 if C > 2 else 0) if self.proto == "multiclass" else int(self.proto)
            if n_proto:
                # prototype directions: the training points with the largest whitened residual (centered encoding)
                rn = np.sum(Rw * Rw, 1); fl[0] += 2 * n * Cp
                for i in np.argsort(-rn)[: n_proto]:
                    new_dirs.append(("proto", Zc[i].copy()))
            bases = []
            if self.products or self.local:
                wn = np.linalg.norm(Wt, axis=1)
                cand_b = [i for i in range(len(feats)) if not is_lin[i] and feats[i] and feats[i][0][0] != "sq"]
                bases = sorted(cand_b, key=lambda i: -wn[i] * np.std(cols[i]))[: self.max_bases]
            if self.local and bases:
                for i in bases[: max(1, self.max_bases // 3)]:
                    f = cols[i]
                    V = Z.T @ (Rw * f[:, None]) / n; fl[0] += 2 * n * D * Cp + n * Cp
                    u, sv, _ = np.linalg.svd(V, full_matrices=False); fl[0] += 4 * D * Cp * Cp
                    new_dirs.append(("local", u[:, 0].copy()))
            n_dir0 = len(axes)
            for kind, u in new_dirs:
                u = u / max(np.linalg.norm(u), 1e-12)
                ok = True
                for a, w in axis_vec.items():
                    if abs(float(u @ w)) > 0.98:
                        ok = False; break
                if not ok:
                    continue
                p = Z @ u; fl[0] += 2 * n * D
                axes.append(("dir", kind)); P.append(p); axis_vec[len(axes) - 1] = u
                add_axis("dir", kind, p)
            new_axes = list(range(n_dir0, len(axes)))
            # ---- candidate scan
            kinds = ["step"] + (["hinge+", "hinge-"] if self.hinge else [])
            cand = []                                    # (z, cls, base, axis, kind, t, T)
            ncut = lambda ax: sum(len(cuts[a][0]) * (1 if isbin[a] else len(kinds)) for a in ax)
            coord_ax = [a for a in range(D) if not isbin[a]]
            used_ax = set(fa for fac in feats for _, fa, _ in fac)
            all_ax = list(range(D)) + [a for a in range(D, len(axes)) if a in used_ax or a in new_axes]
            classes = [("coord", None, coord_ax, tau(max(ncut(coord_ax), 1)))] if coord_ax else []
            if new_axes:
                Nd = ncut(new_axes) + (len(new_axes) if self.square else 0)
                classes.append(("dir", None, new_axes, tau(max(Nd, 1))))
            if self.products and bases:
                Np = len(bases) * ncut(all_ax)
                for b in bases:
                    classes.append(("prod", b, all_ax, tau(max(Np, 1))))
            act = np.array(all_ax, dtype=np.int64); pos = {int(a): i for i, a in enumerate(act)}   # active axes only
            nA = len(act); Qm = max(1, max(len(cuts[a][0]) for a in act))
            Tk = np.full((nA, Qm), np.inf); Vk = np.zeros((nA, Qm), bool)
            for i, a in enumerate(act):
                bb, tt_ = cuts[a]; Tk[i, :len(bb)] = tt_; Vk[i, :len(bb)] = True
            Pall = np.stack([P[a] for a in act], 1); binv = np.array([isbin[a] for a in act])
            # bin of every (row, axis): number of the axis's cut thresholds below the value; flat index for bincount
            IDX = np.empty((n, nA), np.int64)
            for i in range(nA):
                IDX[:, i] = np.searchsorted(Tk[i], Pall[:, i]) + i * (Qm + 1)
            IDX = IDX.ravel(); fl[0] += n * nA * math.log2(Qm + 1)
            seg = lambda w: np.cumsum(np.bincount(IDX, weights=w.ravel(), minlength=nA * (Qm + 1)).reshape(nA, Qm + 1), 1)
            for cname, b, ax, th in classes:
                f = np.ones(n) if b is None else cols[b]
                Wf = Rw * f[:, None]; fl[0] += n * Cp
                S2 = float(np.sum(f * f))
                used = set(fa for _, fa, _ in feats[b]) if b is not None else set()
                axa = np.array([pos[a] for a in ax if a not in used and Vk[pos[a]].any()], dtype=np.int64)
                if len(axa) == 0:
                    continue
                f2 = f * f; ones = np.ones((1, nA))
                cw = np.stack([seg(Wf[:, c:c + 1] * ones) for c in range(Cp)], -1)[axa]      # (g, Qm+1, Cp)
                cf = seg(f2[:, None] * ones)[axa]; fl[0] += 2 * n * nA * (Cp + 1)
                tq = Tk[axa]; val = Vk[axa]
                cwb, cfb = cw[:, :Qm], cf[:, :Qm]
                num = cw[:, -1:, :] - cwb
                s2a = cf[:, -1:] - cfb
                tq0 = np.where(val, tq, 0.0)
                self._pushv(cand, num, s2a - s2a ** 2 / max(S2, 1e-12), val, th, cname, b, act[axa], "step", tq0, n,
                            np.minimum(s2a, S2 - s2a))
                hz = val & ~binv[axa][:, None]
                if self.hinge and hz.any():
                    cwp = np.stack([seg(Wf[:, c:c + 1] * Pall) for c in range(Cp)], -1)[axa]
                    fP = f2[:, None] * Pall
                    cfp = seg(fP)[axa]; cfpp = seg(fP * Pall)[axa]; fl[0] += 4 * n * nA * (Cp + 2)
                    cwpb, cfpb, cfppb = cwp[:, :Qm], cfp[:, :Qm], cfpp[:, :Qm]
                    numr = (cwp[:, -1:, :] - cwpb) - tq0[..., None] * num
                    s1 = cfp[:, -1:] - cfpb; s2 = cfpp[:, -1:] - cfppb
                    q2 = s2 - 2 * tq0 * s1 + tq0 ** 2 * s2a; q1 = s1 - tq0 * s2a
                    self._pushv(cand, numr, q2 - q1 ** 2 / max(S2, 1e-12), hz, th, cname, b, act[axa], "hinge+", tq0, n, s2a)
                    numl = tq0[..., None] * cwb - cwpb
                    q2 = tq0 ** 2 * cfb - 2 * tq0 * cfpb + cfppb; q1 = tq0 * cfb - cfpb
                    self._pushv(cand, numl, q2 - q1 ** 2 / max(S2, 1e-12), hz, th, cname, b, act[axa], "hinge-", tq0, n, cfb)
                if cname == "dir" and self.square:
                    for a in ax:
                        mu = float(np.mean(P[a])); g = (P[a] - mu) ** 2; gc = g - g.mean()
                        num = (Rw.T @ g)[None, :]; den = np.array([float(gc @ gc)]); fl[0] += 2 * n * Cp + 4 * n
                        self._push(cand, num, den, th, cname, None, a, "sq", np.array([mu]), n)
            if not cand:
                break
            cand.sort(key=lambda c: -c[0])
            top = cand[: self.M_top]
            # ---- materialize, orthogonalize against the current features, greedy acceptance in Gram space
            Fm = np.stack([self._cand_col(c, cols, P, fval) for c in top], 1); m = Fm.shape[1]
            fl[0] += n * m * 3
            Bc = np.linalg.solve(Gm + np.diag(pen) + 1e-9 * n * np.eye(A.shape[1]), A.T @ Fm)
            fl[0] += 2 * n * A.shape[1] * m + 2 * A.shape[1] ** 2 * m
            Fp = Fm - A @ Bc; fl[0] += 2 * n * A.shape[1] * m
            Hh = Fp.T @ Rw; Kk = Fp.T @ Fp; fl[0] += 2 * n * m * Cp + 2 * n * m * m
            ths = np.array([c[2] for c in top]); alive = np.ones(m, bool); acc = []
            nrm = np.sum((Fm - Fm.mean(0)) ** 2, 0) + 1e-300
            room = min(self.max_new, p_max - A.shape[1])
            while len(acc) < room:
                kd = np.diag(Kk).copy()
                sc = np.where(alive & (kd > 1e-4 * nrm), np.sum(Hh * Hh, 1) / np.maximum(kd, 1e-300), -1.0)
                j = int(np.argmax(sc / ths))
                if sc[j] <= ths[j]:
                    break
                acc.append(j); alive[j] = False
                kj = Kk[:, j].copy(); hj = Hh[j].copy(); kjj = kj[j]
                Hh -= np.outer(kj / kjj, hj); Kk -= np.outer(kj, kj) / kjj; fl[0] += 4 * m * m + 4 * m * Cp
            if not acc:
                break
            newcols = []
            for j in acc:
                cc = top[j]; feats.append(self._cand_fac(cc, feats)); newcols.append(Fm[:, j]); pen.append(self.ridge_f * n)
                is_lin.append(False)
            Fn = np.stack(newcols, 1)
            Gx = A.T @ Fn; Gn = Fn.T @ Fn; fl[0] += 2 * n * A.shape[1] * len(acc) + 2 * n * len(acc) ** 2
            Gm = np.block([[Gm, Gx], [Gx.T, Gn]]); AY = np.vstack([AY, Fn.T @ Y]); fl[0] += 2 * n * len(acc) * C
            A = np.hstack([A, Fn]); cols.extend(newcols)
            Wt, R = solve(); rounds_done = rnd + 1
            info["log"].append(dict(round=rnd, n_new=len(acc), p=A.shape[1], n_dirs=len(new_axes),
                                    classes=dict((k_, sum(1 for j in acc if top[j][1] == k_)) for k_ in ("coord", "dir", "prod")),
                                    train_err=float(np.mean(np.argmax(A @ Wt, 1) != y))))
        info["rounds"] = rounds_done; info["p"] = A.shape[1]
        # ---------- readout: softmax with L2, lambda by CV
        Wfin, mode = Wt, "ls"
        if self.softmax and n >= 30:
            sd = A.std(0); sd[0] = 1.0; sd[sd < 1e-12] = 1.0
            As = A / sd
            lams = sorted(lam_grid, reverse=True)                        # largest lambda first: ties go to it
            # hard cap: every L-BFGS run gets at most its share of what is left of the budget
            left = 0.97 * budget - fl[0] - 2 * n * A.shape[1] * C * len(lams)
            mi = int(max(5, min(120, left / (n_fits * per_eval(A.shape[1])))))
            info["readout_maxiter"] = mi
            if len(lams) > 1 and folds > 1:
                fold = rng.permutation(n) % folds; errs = np.zeros(len(lams))
                for f_ in range(folds):
                    tr, te = fold != f_, fold == f_
                    W0 = None
                    for li, lam in enumerate(lams):
                        W0 = self._softmax(As[tr], y[tr], C, lam, W0, fl, mi)
                        errs[li] += np.sum(np.argmax(As[te] @ W0, 1) != y[te])
                    fl[0] += 2 * n * A.shape[1] * C * len(lams) / folds
                lam = lams[int(np.argmin(errs))]; info["cv_errs"] = errs.tolist()
            else:
                lam = lams[0]
            Ws = self._softmax(As, y, C, lam, None, fl, mi)
            Wfin = Ws / sd[:, None]; mode = f"softmax{lam:g}"
        info["readout"] = mode; info["flops_frac"] = fl[0] / budget
        F_ = list(feats); W_ = Wfin; avec = dict(axis_vec)

        def predict(T):
            Zt = enc(T)
            Pt = [Zt[:, j] for j in range(D)] + [Zt @ avec[a] for a in range(D, len(axes))]
            S = np.zeros((len(Zt), C))
            for fac, w in zip(F_, W_):
                S += np.outer(fval(fac, Pt), w)
            return np.argmax(S, 1)

        info["train_err"] = float(np.mean(np.argmax(A @ Wfin, 1) != y))
        return dict(predict=predict, flops=fl[0], info=info)

    # ------------------------------------------------------------------ helpers
    @staticmethod
    def _whiten(R):
        n = len(R); S = R.T @ R / n
        ev, V = np.linalg.eigh(S); keep = ev > 1e-9 * max(ev.max(), 1e-300)
        Rw = R @ (V[:, keep] / np.sqrt(ev[keep]))
        return Rw, int(keep.sum())

    @staticmethod
    def _push(cand, num, den, th, cname, b, a, kind, ts, n):
        T = np.sum(num * num, 1) / np.maximum(den, 1e-300)
        T = np.where(den > 1e-6 * n * 1e-3, T, 0.0)
        for i in np.nonzero(T > th)[0]:
            cand.append((T[i] / th, cname, th, b, a, kind, float(ts[i]), float(T[i])))

    def _pushv(self, cand, num, den, valid, th, cname, b, ch, kind, tq, n, sup=None):
        T = np.sum(num * num, -1) / np.maximum(den, 1e-300)
        ok = valid & (den > 1e-9 * n) & (T > th)
        if sup is not None:                            # minimum support: the chi^2 tail is not valid on a handful of rows
            ok &= sup >= self._msup
        gi, qi = np.nonzero(ok)
        if len(gi) > self.M_top:
            sel = np.argsort(-T[gi, qi])[: self.M_top]; gi, qi = gi[sel], qi[sel]
        for g_, q_ in zip(gi, qi):
            cand.append((T[g_, q_] / th, cname, th, b, int(ch[g_]), kind, float(tq[g_, q_]), float(T[g_, q_])))

    @staticmethod
    def _cand_fac(c, feats):
        _, cname, th, b, a, kind, t, T = c
        fac = (kind, a, t)
        return (fac,) if b is None else tuple(feats[b]) + (fac,)

    def _cand_col(self, c, cols, P, fval):
        _, cname, th, b, a, kind, t, T = c
        v = fval(((kind, a, t),), P)
        return v if b is None else cols[b] * v

    @staticmethod
    def _softmax(A, y, C, lam, W0, fl, maxiter=150):
        n, p = A.shape
        Y = np.zeros((n, C)); Y[np.arange(n), y] = 1.0
        mask = np.ones((p, C)); mask[0] = 0.0
        cnt = [0]

        def fg(w):
            W = w.reshape(p, C); Sx = A @ W; Sx -= Sx.max(1, keepdims=True)
            E = np.exp(Sx); Z = E.sum(1, keepdims=True); Pr = E / Z
            loss = -np.mean(np.sum(Y * (Sx - np.log(Z)), 1)) + 0.5 * lam * np.sum(mask * W * W)
            g = A.T @ (Pr - Y) / n + lam * mask * W
            cnt[0] += 1
            return loss, g.ravel()
        w0 = np.zeros(p * C) if W0 is None else W0.ravel()
        res = minimize(fg, w0, jac=True, method="L-BFGS-B", options=dict(maxiter=maxiter, maxfun=int(maxiter * 1.25) + 1))
        fl[0] += cnt[0] * (4 * n * p * C + 12 * n * C + 60 * p * C)
        return res.x.reshape(p, C)
