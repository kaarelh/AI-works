"""dfg_gates: DFG (discrete feature growth) over a dictionary of threshold / AND gates, for standard classification data.

The learner keeps DFG's core and changes its dictionary.  DFG grew parity characters chi_S of +-1 inputs; dfg_gates grows
Boolean gates, conjunctions of up to three *literals*:
  literal   [x_j > t]  (t a training-set quantile of a continuous / ordinal column), [x_j = 1] for a binary column,
            [x_j = v] for each value v of a categorical column, and each literal's negation
  gate      g = l_1 AND ... AND l_k, k <= 3   (a 0/1 feature; its column is the product of its literals' columns)

  repeat (rounds):
    least-squares fit of the one-hot labels Y on the current features (constant, linear block, gates); R = residual,
    whitened over classes (drop one class: rows of R sum to 0; R~ = R' Sigma^-1/2, Sigma = R'^T R' / n, keeping the
    eigen-directions of Sigma above 1e-3 of the largest; their number C' is the statistic's degrees of freedom)
    statistic of a candidate gate z:  T(z) = || z~^T R~ ||^2 / ||z~||^2,  z~ = z - mean(z)       (~ chi^2_{C'} if
    z carries no signal; for C = 2 this is DFG's (mean(r z) / s)^2 n / var(z))
    candidate classes, each with its own size N (a union bound per class):
      singles     every literal                                                    N = L
      pairs       every l_a AND l_b, all four polarities, on a budgeted subsample   N = 2 L^2
      extensions  g AND l, g AND NOT l for the top current gates g of degree < 3     N = 2 B L
    accept z if T(z) > c^2 * chi2.isf(delta / (4 N), C')  (c = 0.5, delta = 0.1); the passing candidates (top
    4 max_new) are taken
    greedily, each re-tested after Gram-Schmidt against the ones already taken this round (so redundant gates are not
    accepted together)
    BLOCK move: linear block = all standardized inputs at once, when ||Q^T R~||_F^2 exceeds the chi^2_{rank (C-1)}
    tail at level delta (Q an orthonormal basis of the centered inputs); round 0 only; if the encoded width exceeds
    n / 3 the block is its top n / 3 principal components (rank cap, so least squares stays below interpolation)
    stop when nothing passes, at the feature cap p <= n / 2, or at 75% of the FLOP budget
  readout: least squares on the grown features, refined by L2-regularized softmax regression (Boehning's bound:
  one Cholesky, FISTA iterations); prediction = argmax.

Model selection (like the MLP's lr selection): the features are grown on 90% of the training set; the held-out 10%
picks the readout (least squares, or softmax with ridge lambda in {0.1, 0.01, 0.001, 0.0001}; ties go to least squares
-> softmax and then to the stronger ridge); then the readout is refit on all n points.  At n <= small_n = 1000 the
growth itself is also redone on all n points (it is cheap there); above, the gates grown on the 90% are kept.
Options left off in the frozen version (tried on dev data, not better): proj (threshold literals on the directions of
the linear fit), quad (DFG's spectral block, features (u.x)^2 on eigen-directions of the residual-weighted second
moment of the whitened inputs).

Compute: every matrix product, solve, eigendecomposition and Cholesky is counted (multiply-add = 2), and the fit stops
growing at 75% of harness.mlp_flops (one MLP training run at this n).  No gradient descent on gate parameters: gates
are found only by enumeration and tests; the only continuous parameters are the readout weights (and the
standardization of the linear block).
"""
import math, os, sys, numpy as np
from scipy.stats import chi2
from scipy.linalg import cho_factor, cho_solve
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(HERE))
import harness


# ----------------------------------------------------------------------------------------------- literal dictionary
class Literals:
    """Literals from the training set: for each column a list of thresholds ('gt') or values ('eq')."""

    def __init__(self, X, types, Q, min_sup):
        self.spec = []                                            # (column, kind, value)
        n = len(X)
        for j, t in enumerate(types):
            x = X[:, j]; u, cnt = np.unique(x, return_counts=True)
            if len(u) < 2:
                continue
            if t == "binary":
                self.spec.append((j, "gt", float(u[0])))
            elif t == "categorical":
                for v, c in zip(u, cnt):
                    if min_sup <= c <= n - min_sup:
                        self.spec.append((j, "eq", float(v)))
            else:
                if len(u) <= Q + 1:
                    ts = u[:-1]
                else:
                    ts = np.unique(np.quantile(x, np.arange(1, Q + 1) / (Q + 1), method="lower"))
                for tt in ts:
                    c = int(np.sum(x > tt))
                    if min_sup <= c <= n - min_sup:
                        self.spec.append((j, "gt", float(tt)))
        self.L = len(self.spec)
        self.col = np.array([s[0] for s in self.spec], dtype=np.int64)
        self.kind_eq = np.array([s[1] == "eq" for s in self.spec])
        self.val = np.array([s[2] for s in self.spec])

    def matrix(self, X, dtype=np.float32):
        V = X[:, self.col]
        Z = np.where(self.kind_eq[None, :], V == self.val[None, :], V > self.val[None, :])
        return Z.astype(dtype)


def gate_column(Z, g):
    """g: tuple of (literal index, polarity); column = AND of the literals."""
    out = np.ones(Z.shape[0])
    for li, pol in g:
        z = Z[:, li].astype(np.float64)
        out *= z if pol else 1.0 - z
    return out


# ----------------------------------------------------------------------------------------------- readouts
def _softmax(F):
    F = F - F.max(1, keepdims=True); E = np.exp(F); return E / E.sum(1, keepdims=True)


def softmax_fit(A, Y, lam, iters, fl, W0=None):
    """L2-regularized multinomial logistic regression (intercept = column 0, unpenalized) by FISTA on Boehning's
    quadratic bound: H <= 1/2 (I - 11^T / C) (x) A^T A / n.  One Cholesky, then 4 n p C FLOPs per iteration."""
    n, p = A.shape; C = Y.shape[1]
    D = np.ones(p); D[0] = 1e-6
    H = 0.5 * (A.T @ A) / n + lam * np.diag(D); fl[0] += 2 * n * p * p + p ** 3 / 3
    try:
        cf = cho_factor(H)
    except np.linalg.LinAlgError:     # post-freeze robustness fix (coordinator): only runs if the factorization fails
        jit = 1e-6 * max(np.trace(H) / p, 1e-12)
        while True:
            try:
                cf = cho_factor(H + jit * np.eye(p)); break
            except np.linalg.LinAlgError:
                jit *= 10
    W = np.zeros((p, C)) if W0 is None else W0 - W0.mean(1, keepdims=True)
    V, tk = W.copy(), 1.0
    for _ in range(iters):
        P = _softmax(A @ V); G = A.T @ (P - Y) / n + lam * D[:, None] * V
        G -= G.mean(1, keepdims=True)
        Wn = V - cho_solve(cf, G); fl[0] += 4 * n * p * C + 2 * p * p * C + 6 * n * C
        tn = (1 + math.sqrt(1 + 4 * tk * tk)) / 2
        V = Wn + ((tk - 1) / tn) * (Wn - W); W, tk = Wn, tn
    return W


def ls_fit(A, Y, ridge, fl):
    n, p = A.shape
    D = np.ones(p); D[0] = 0.0
    G = A.T @ A + ridge * n * np.diag(D) + 1e-9 * n * np.eye(p); fl[0] += 2 * n * p * p + p ** 3 / 3 + 2 * n * p * Y.shape[1]
    return np.linalg.solve(G, A.T @ Y)


# ----------------------------------------------------------------------------------------------- the learner
class Learner:
    def __init__(self, Q=16, c=0.5, delta=0.1, rounds=40, max_new=24, max_deg=3, ext_bases=24, max_feats=1500,
                 min_sup=5, pair_share=(0.10, 0.02), lin_block=True, ridge=1e-4, lams=(1e-1, 1e-2, 1e-3, 1e-4),
                 iters=60, val_frac=0.1, small_n=1000, cap=0.75, proj=0, quad=0, max_quad=200, name="dfg_gates-v1"):
        self.Q, self.c, self.delta, self.rounds, self.max_new, self.max_deg = Q, c, delta, rounds, max_new, max_deg
        self.ext_bases, self.max_feats, self.min_sup, self.pair_share = ext_bases, max_feats, min_sup, pair_share
        self.lin_block, self.ridge, self.lams, self.iters, self.val_frac = lin_block, ridge, lams, iters, val_frac
        self.small_n, self.cap, self.name, self.proj, self.quad, self.max_quad = small_n, cap, name, proj, quad, max_quad

    # ------------------------------------------------------------------ public API
    def fit(self, X, y, types, C, rng):
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y, dtype=np.int64); n = len(y)
        types = [t if t in ("binary", "categorical") else "continuous" for t in types]
        budget = harness.mlp_flops(X, types, C, n)
        fl = [0.0]
        Y = np.eye(C)[y]
        perm = rng.permutation(n); nv = max(10, int(round(self.val_frac * n)))
        va, tr = perm[:nv], perm[nv:]
        # 1. grow on the fit part, recording checkpoints
        g1 = self._grow(X[tr], Y[tr], types, C, budget * (0.45 if n <= self.small_n else 0.8), fl)
        # 2. choose (checkpoint, readout) on the held-out part
        A_tr, A_va = self._design(g1, X[tr]), self._design(g1, X[va])
        k = A_tr.shape[1]
        W = ls_fit(A_tr, Y[tr], self.ridge, fl)
        best = (float(np.mean(np.argmax(A_va @ W, 1) != y[va])), k, "ls", None); W0 = None
        for lam in self.lams:
            if fl[0] > 0.9 * budget:
                break
            W0 = softmax_fit(A_tr[:, :k], Y[tr], lam, self.iters, fl, W0)
            e = np.mean(np.argmax(A_va[:, :k] @ W0, 1) != y[va])
            if e < best[0] - 1e-12 or (best[2] == "ls" and e <= best[0] + 1e-12):   # ties: stronger ridge
                best = (e, k, "softmax", lam)
        # 3. final model on all n points
        if n <= self.small_n:
            g = self._grow(X, Y, types, C, budget * 0.4, fl)
            kk = g["checkpoints"][-1]
        else:
            g, kk = g1, k
        A = self._design(g, X)[:, :kk]
        if best[2] == "ls":
            W = ls_fit(A, Y, self.ridge, fl)
        else:
            W = softmax_fit(A, Y, best[3], self.iters, fl)
        gates = g["gates"]; lits = g["lits"]; lin = g["lin"]
        info = dict(n_gates=len(gates), p=int(kk), lin=bool(lin is not None), readout=best[2], lam=best[3],
                    val_err=float(best[0]), rounds=g["rounds"], L=lits.L, budget=budget, flops_frac=fl[0] / budget,
                    deg_hist=np.bincount([0 if isinstance(q[0], str) else len(q) for q in gates[: max(0, kk - g["p0"])]],
                                         minlength=4).tolist())

        def predict(Xn):
            An = self._design(g, np.asarray(Xn, dtype=np.float64))[:, :kk]
            return np.argmax(An @ W, 1)
        return dict(predict=predict, flops=fl[0], info=info)

    # ------------------------------------------------------------------ design matrix of a grown model
    def _design(self, g, X):
        cols = [np.ones((len(X), 1))]
        if g["lin"] is not None:
            m, sd, P = g["lin"]
            cols.append(((harness.encode_standard(X, g["types"], ref=g["Xref"], domain=g["dom"]) - m) / sd) @ P)
        if g["gates"]:
            Z = g["lits"].matrix(self._augment(g["proj"], X, g["types"], g["Xref"], g["dom"]))
            Xw = None
            if g["quads"]:
                m_, sd_, _ = g["lin"]
                Xw = ((harness.encode_standard(X, g["types"], ref=g["Xref"], domain=g["dom"]) - m_) / sd_) @ g["wh"]
            cols.append(np.stack([(Xw @ g["quads"][q[1]]) ** 2 - 1.0 if isinstance(q[0], str) else gate_column(Z, q)
                                  for q in g["gates"]], 1))
        return np.concatenate(cols, 1)

    @staticmethod
    def _augment(proj, X, types, Xref, dom):
        if proj is None:
            return X
        m_, sd_, U = proj
        return np.concatenate([X, ((harness.encode_standard(X, types, ref=Xref, domain=dom) - m_) / sd_) @ U], 1)

    # ------------------------------------------------------------------ growth
    def _grow(self, X, Y, types, C, budget, fl, max_rounds=None):
        n, d = X.shape; Cp = max(C - 1, 1)
        dom = {j: np.unique(X[:, j]) for j, t in enumerate(types) if t == "categorical"}
        proj = None
        if self.proj:
            # directions of the least-squares fit on the linear block (class scores and, for C > 2, their pairwise
            # differences): their threshold literals [u.x > t] join the dictionary (DFG's block -> feature move)
            E = harness.encode_standard(X, types, ref=X, domain=dom); m_, sd_ = E.mean(0), E.std(0) + 1e-12
            Es = (E - m_) / sd_; A1 = np.concatenate([np.ones((n, 1)), Es], 1)
            Wl = ls_fit(A1, Y, 1e-2, fl)[1:]
            U = [Wl[:, k] for k in range(C)] if C > 2 else [Wl[:, 1] - Wl[:, 0]]
            if C > 2 and self.proj >= 2:
                U += [Wl[:, a] - Wl[:, b] for a in range(C) for b in range(a + 1, C)]
            U = np.stack(U, 1); U /= np.linalg.norm(U, axis=0) + 1e-12
            proj = (m_, sd_, U)
        Xa = self._augment(proj, X, types, X, dom); ta = types + ["continuous"] * (Xa.shape[1] - d)
        if proj is not None:
            fl[0] += 2 * n * U.shape[0] * U.shape[1]
        lits = Literals(Xa, ta, self.Q, self.min_sup); L = lits.L
        Z = lits.matrix(Xa); fl[0] += n * L
        start = fl[0]
        tail = lambda N, df: self.c ** 2 * chi2.isf(self.delta / (4.0 * max(N, 1)), df)
        A = np.ones((n, 1)); gates, have, quads = [], set(), []; Xw = wh = None
        lin = None; checkpoints, ck_round = [], []
        p_cap = min(self.max_feats, n // 2)
        rounds_done = 0; ylab = np.argmax(Y, 1)
        R_lim = self.rounds if max_rounds is None else max_rounds
        for rnd in range(R_lim + 1):
            # ---- least squares and whitened residual
            W = ls_fit(A, Y, self.ridge, fl); R = Y - A @ W; fl[0] += 2 * n * A.shape[1] * C
            checkpoints.append(A.shape[1]); ck_round.append(rnd)
            if rnd == R_lim or fl[0] - start > self.cap * budget or A.shape[1] >= p_cap:
                break
            Rp = R[:, :Cp]; S = Rp.T @ Rp / n
            ev, U = np.linalg.eigh(S + 1e-12 * np.eye(Cp)); fl[0] += 2 * n * Cp * Cp + 10 * Cp ** 3
            keep = ev > 1e-3 * ev.max() + 1e-300; Cq = int(keep.sum())    # drop near-null class directions
            Wh = U[:, keep] / np.sqrt(ev[keep])
            Rt = Rp @ Wh; Rt -= Rt.mean(0); fl[0] += 2 * n * Cp * Cp
            Rt32 = Rt.astype(np.float32)
            cand = []                                             # (ratio, T, thr, key, column-maker)
            # ---- linear block
            if self.lin_block and rnd == 0:
                E = harness.encode_standard(X, types, ref=X, domain=dom)
                m_, sd_ = E.mean(0), E.std(0) + 1e-12; Es = (E - m_) / sd_
                Qm, Rr = np.linalg.qr(Es); fl[0] += 4 * n * Es.shape[1] ** 2
                rank = int(np.sum(np.abs(np.diag(Rr)) > 1e-8 * np.abs(Rr).max()))
                T1 = float(np.sum((Qm.T @ Rt) ** 2)); fl[0] += 2 * n * Es.shape[1] * Cp
                df = rank * Cq; tt = math.log(1 / self.delta)
                kl = min(Es.shape[1], max(1, n // 3))
                if kl < Es.shape[1]:                              # rank cap: the top n/3 principal components
                    ev_, V_ = np.linalg.eigh(Es.T @ Es / n); fl[0] += 2 * n * Es.shape[1] ** 2 + 10 * Es.shape[1] ** 3
                    P_ = V_[:, np.argsort(-ev_)[:kl]]
                else:
                    P_ = np.eye(Es.shape[1])
                if T1 > df + 2 * math.sqrt(df * tt) + 2 * tt and A.shape[1] + kl <= p_cap:
                    lin = (m_, sd_, P_)
                    if self.quad:                                 # whitened inputs for the spectral block
                        ev_, V_ = np.linalg.eigh(Es.T @ Es / n); fl[0] += 2 * n * Es.shape[1] ** 2 + 10 * Es.shape[1] ** 3
                        keep = ev_ > 1e-6 * ev_.max(); wh = V_[:, keep] / np.sqrt(ev_[keep]); Xw = Es @ wh
                        fl[0] += 2 * n * Es.shape[1] * wh.shape[1]
            # ---- singles
            pz = Z.mean(0).astype(np.float64)
            num = (Z.T @ Rt32).astype(np.float64); fl[0] += 2 * n * L * Cp
            den = n * pz * (1 - pz) + 1e-12
            T = np.sum(num ** 2, 1) / den
            thr = tail(L, Cq)
            for a in np.where(T > thr)[0]:
                cand.append((T[a] / thr, thr, ((int(a), 1),)))
            # ---- pairs of literals, all four polarities, on a budgeted subsample
            share = self.pair_share[0] if rnd == 0 else self.pair_share[1]
            m = min(n, int(share * budget / (2.0 * L * L * (Cp + 1) + 1)))
            if m >= 50 and L >= 2:
                Zm = Z[:m]; Rm = Rt32[:m] - Rt32[:m].mean(0)
                P = (Zm.T @ Zm) / m; pa = Zm.mean(0)
                sa = Zm.T @ Rm                                    # (L, Cp)
                fl[0] += 2 * m * L * L * (Cp + 1) + 2 * m * L * Cp
                Tp = np.zeros((4, L, L), np.float32)
                for k in range(Cq):
                    Mk = (Zm * Rm[:, k:k + 1]).T @ Zm
                    s_a = sa[:, k]
                    Tp[0] += Mk ** 2                                       # a and b
                    Tp[1] += (s_a[:, None] - Mk) ** 2                      # a and not b
                    Tp[2] += (s_a[None, :] - Mk) ** 2                      # not a and b
                    Tp[3] += (Mk - s_a[:, None] - s_a[None, :]) ** 2       # not a and not b
                pp = np.stack([P, pa[:, None] - P, pa[None, :] - P, 1 - pa[:, None] - pa[None, :] + P])
                ok = (pp * m >= self.min_sup) & ((1 - pp) * m >= self.min_sup)
                Tp = np.where(ok, Tp / (m * pp * (1 - pp) + 1e-9), 0.0)
                same = lits.col[:, None] == lits.col[None, :]
                Tp[:, same & ~np.eye(L, dtype=bool)] *= 1.0               # intervals on one column are allowed
                iu = np.triu(np.ones((L, L), bool), 1)
                Tp *= iu[None]
                thr = tail(2 * L * L, Cq)
                pols = [(1, 1), (1, 0), (0, 1), (0, 0)]
                hit = np.argwhere(Tp > thr)
                if len(hit) > 2000:
                    vals = Tp[hit[:, 0], hit[:, 1], hit[:, 2]]
                    hit = hit[np.argsort(-vals)[:2000]]
                for q, a, b in hit:
                    pa_, pb_ = pols[q]
                    cand.append((Tp[q, a, b] / thr, thr, tuple(sorted(((int(a), pa_), (int(b), pb_))))))
            # ---- extensions of current gates by one literal
            if gates:
                imp = np.linalg.norm(W[-len(gates):], axis=1) * np.sqrt(np.maximum(A[:, -len(gates):].var(0), 0))
                order = [i for i in np.argsort(-imp) if not isinstance(gates[i][0], str)
                         and len(gates[i]) < self.max_deg][: self.ext_bases]
                B = len(order)
                if B:
                    thr = tail(2 * B * L, Cq)
                    for i in order:
                        gv = A[:, A.shape[1] - len(gates) + i].astype(np.float32)
                        Rg = Rt32 * gv[:, None]
                        n1 = (Z.T @ Rg).astype(np.float64); p1 = (Z.T @ gv).astype(np.float64) / n
                        n0 = Rg.sum(0)[None, :] - n1; p0 = gv.mean() - p1
                        fl[0] += 2 * n * L * (Cp + 1) + 2 * n * Cp
                        used = {li for li, _ in gates[i]}
                        for nn, pp_, pol in ((n1, p1, 1), (n0, p0, 0)):
                            ok = (pp_ * n >= self.min_sup) & ((1 - pp_) * n >= self.min_sup)
                            Te = np.where(ok, np.sum(nn ** 2, 1) / (n * pp_ * (1 - pp_) + 1e-12), 0.0)
                            for a in np.where(Te > thr)[0]:
                                if int(a) in used:
                                    continue
                                cand.append((Te[a] / thr, thr, tuple(sorted(gates[i] + ((int(a), pol),)))))
            # ---- greedy acceptance with Gram-Schmidt inside the round
            new_cols, new_gates = [], []
            short = []
            if cand:
                cand.sort(key=lambda t: -t[0])
                seen = set()
                for ratio, thr, key in cand:
                    if key in have or key in seen:
                        continue
                    seen.add(key); short.append((thr, key))
                    if len(short) >= 4 * self.max_new:
                        break
            if short:
                Zc = np.stack([gate_column(Z, key) for _, key in short], 1); fl[0] += n * len(short) * 3
                Zc -= Zc.mean(0); nrm0 = np.sum(Zc * Zc, 0) + 1e-12
                thr_s = np.array([t for t, _ in short]); Rw = Rt.copy()
                alive = np.ones(len(short), bool)
                room = p_cap - A.shape[1] - (lin[2].shape[1] if lin is not None and rnd == 0 else 0)
                for _ in range(min(self.max_new, max(0, room))):
                    nr = np.sum(Zc * Zc, 0)
                    sc = np.sum((Zc.T @ Rw) ** 2, 1) / (nr + 1e-12); fl[0] += 2 * n * len(short) * (Cp + 1)
                    sc[~alive | (nr < 0.05 * nrm0)] = 0.0
                    j = int(np.argmax(sc / thr_s))
                    if sc[j] <= thr_s[j]:
                        break
                    qv = Zc[:, j] / math.sqrt(nr[j]); alive[j] = False
                    new_gates.append(short[j][1]); new_cols.append(gate_column(Z, short[j][1]))
                    Rw -= np.outer(qv, qv @ Rw)
                    Zc -= np.outer(qv, qv @ Zc); fl[0] += 4 * n * len(short) + 4 * n * Cp
            # ---- spectral block (DFG's quadratic move): eigen-directions u of the residual-weighted second moment
            #      Xw^T diag(r~_k) Xw / n of the whitened inputs, above the noise edge; features (u.xw)^2 - 1
            if Xw is not None and rnd > 0 and len(quads) < self.max_quad:
                rw = Xw.shape[1]
                if n >= 4 * rw:
                    edge = 2 * math.sqrt(rw / n) * (1 + math.sqrt(2 * math.log(Cp / self.delta) / rw))
                    got = []
                    for k in range(Cq):
                        Mk = (Xw * Rt[:, k:k + 1]).T @ Xw / n; fl[0] += 2 * n * rw * rw + n * rw + 10 * rw ** 3
                        lam_, U_ = np.linalg.eigh(Mk)
                        for q in [q for q in np.argsort(-np.abs(lam_)) if abs(lam_[q]) > edge][: self.quad]:
                            got.append((abs(lam_[q]) / edge, U_[:, q]))
                    got.sort(key=lambda t: -t[0]); taken = []
                    for _, u in got:
                        if len(quads) + len(taken) >= self.max_quad:
                            break
                        if all(abs(u @ v) < 0.9 for v in taken + quads[-4 * Cp:]):
                            taken.append(u)
                    for u in taken:
                        new_gates.append(("Q", len(quads))); quads.append(u)
                        new_cols.append((Xw @ u) ** 2 - 1.0); fl[0] += 2 * n * rw + 2 * n
            if not new_gates and not (lin is not None and rnd == 0):
                break
            # insert the linear block (round 0 only) right after the constant
            if lin is not None and rnd == 0:
                m_, sd_, P_ = lin
                Es = ((harness.encode_standard(X, types, ref=X, domain=dom) - m_) / sd_) @ P_
                A = np.concatenate([A[:, :1], Es, A[:, 1:]], 1)
            if new_gates:
                gates += new_gates; have.update(new_gates)
                A = np.concatenate([A, np.stack(new_cols, 1)], 1)
            rounds_done = rnd + 1
        p0 = 1 + (0 if lin is None else lin[2].shape[1])
        return dict(lits=lits, gates=gates, lin=lin, types=types, Xref=X, dom=dom, proj=proj, quads=quads, wh=wh, checkpoints=checkpoints, ck_round=ck_round,
                    rounds=rounds_done, p0=p0)
