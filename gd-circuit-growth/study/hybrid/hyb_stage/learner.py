"""hyb_stage: a stagewise discrete learner.  Stage 1 = DFG-style exhaustive sparse search (characters of bit-encoded
inputs, union-bound tests on the least-squares residual, composition moves, linear/quadratic blocks), read out by an
L2-regularised softmax regression together with a linear background; stage 2 = gradient-boosted trees (LightGBM)
started from the stage-1 margins (init_score), so the trees only model what stage 1 left.  Which stages are used, the
background penalty and the number of trees are chosen by cross-validation (small n) or a hold-out split (large n).
See DESIGN.md.
"""
import os, sys, math, itertools, time
import numpy as np
from scipy.optimize import minimize

_HERE = os.path.dirname(os.path.abspath(__file__))
if os.path.dirname(_HERE) not in sys.path:
    sys.path.insert(0, os.path.dirname(_HERE))
import common


# ----------------------------------------------------------------------------------------------------------------------
def _fwht(a):
    """Walsh-Hadamard transform along the last axis of a (b, 2^L) array."""
    a = np.array(a, dtype=np.float64); b, n = a.shape; h = 1
    while h < n:
        a = a.reshape(b, -1, 2, h)
        a = np.concatenate([a[:, :, 0] + a[:, :, 1], a[:, :, 0] - a[:, :, 1]], axis=2).reshape(b, n)
        h *= 2
    return a


def _table(B, idx, k):
    T = list(itertools.combinations(idx, k)); I = np.array(T)
    Z = np.ones((len(B), len(T)))
    for q in range(k):
        Z *= B[:, I[:, q]]
    return T, Z


class _Enc:
    """z: the linear encoding (standardized continuous clipped at +-6, binary +-1, categorical one-hot 0/1);
    bits: +-1 bits for the character search (binary: 1 bit; categorical: one-hot; continuous: thermometer bits at
    training quantiles).  zb maps a z column of a binary input to its bit (they are the same column)."""

    def __init__(self, X, types, cont_bits=240, nb_max=8, min_count=3):
        n = len(X); self.spec_z, self.spec_b, grp = [], [], []
        ncont = sum(t not in ("binary", "categorical") for t in types)
        nb = int(np.clip(round(cont_bits / max(ncont, 1)), 1, nb_max))
        self.zb = {}
        for j, t in enumerate(types):
            x = X[:, j]
            if t == "categorical":
                vals, cnt = np.unique(x, return_counts=True)
                for v in vals:
                    self.spec_z.append(("eq", j, v))
                cand = [v for v, c in zip(vals, cnt) if min_count <= c <= n - min_count]
                for v in (cand[:1] if len(vals) <= 2 else cand):
                    self.spec_b.append(("eq", j, v)); grp.append(j)
            elif t == "binary":
                lo = x.min(); c = int(np.sum(x > lo))
                if c > 0:
                    self.spec_z.append(("gt", j, lo))
                if min_count <= c <= n - min_count:
                    self.zb[len(self.spec_z) - 1] = len(self.spec_b)
                    self.spec_b.append(("gt", j, lo)); grp.append(j)
            else:
                m, s = x.mean(), x.std()
                if s > 1e-12:
                    self.spec_z.append(("std", j, (m, s)))
                seen = set()
                for tq in np.unique(np.quantile(x, np.arange(1, nb + 1) / (nb + 1))):
                    c = int(np.sum(x > tq))
                    if min_count <= c <= n - min_count and c not in seen:
                        seen.add(c); self.spec_b.append(("gt", j, tq)); grp.append(j)
        self.grp = np.array(grp, int)

    @staticmethod
    def _apply(spec, X, pm):
        out = np.empty((len(X), len(spec)))
        for q, (kind, j, v) in enumerate(spec):
            x = X[:, j]
            if kind == "eq":
                out[:, q] = np.where(x == v, 1.0, -1.0 if pm else 0.0)
            elif kind == "gt":
                out[:, q] = np.where(x > v, 1.0, -1.0)
            else:
                out[:, q] = np.clip((x - v[0]) / v[1], -6.0, 6.0)
        return out

    def z(self, X):
        return self._apply(self.spec_z, X, pm=False)

    def bits(self, X):
        return self._apply(self.spec_b, X, pm=True)


def _feat_cols(feats, B, Z):
    cols = []
    for f in feats:
        if f[0] == "chi":
            cols.append(np.prod(B[:, list(f[1])], axis=1))
        elif f[0] == "lin":
            cols.append(Z[:, f[1]])
        elif f[0] == "quad":
            cols.append((Z @ f[1]) ** 2 - f[2])
    return np.stack(cols, 1) if cols else np.zeros((len(B), 0))


# ----------------------------------------------------------------------------------------------------------------------
class Learner:
    def __init__(self, K=4, K_later=3, K_hi=6, c=1.0, delta=0.1, rounds=8, max_new=64, max_feats=256, max_ext_bases=32,
                 local_max=12, ridge=1e-3, shares=(0.03, 0.03, 0.12, 0.03, 0.03), search_cap=4e10, lam_f=1e-3,
                 lam_grid=(0.1, 0.01, 1e-3, 1e-4), n_cv=1000, force_n=128, lr=0.1, tmax=600,
                 patience=40, min_delta=2e-4, ll_w=0.1, stage2=True, nn=True, nn_ks=(1, 3, 9, 27), nn_share=0.3,
                 nn_keep=96, nn_pmax=4096, name="hyb_stage"):
        self.K, self.K_later, self.K_hi, self.c, self.delta, self.rounds = K, K_later, K_hi, c, delta, rounds
        self.max_new, self.max_feats, self.max_ext_bases, self.local_max = max_new, max_feats, max_ext_bases, local_max
        self.ridge, self.shares, self.search_cap, self.lam_f, self.lam_grid = ridge, shares, search_cap, lam_f, lam_grid
        self.n_cv, self.force_n, self.lr, self.tmax, self.patience, self.ll_w = n_cv, force_n, lr, tmax, patience, ll_w
        self.stage2, self.name, self.min_delta = stage2, name, min_delta
        self.nn, self.nn_ks, self.nn_share, self.nn_keep, self.nn_pmax = nn, tuple(nn_ks), nn_share, nn_keep, nn_pmax

    # ================================================================== stage 1: DFG-style search
    def _grow(self, B, grp, Zl, zb, Y, GD, force=False, binary_inputs=False):
        n, db = B.shape; dz = Zl.shape[1]; Cy = Y.shape[1]
        fl = [0.0]; GD = min(GD, self.search_cap)
        feats, cols, have = [], [np.ones(n)], set()
        same = grp[:, None] == grp[None, :]
        ridge = self.ridge

        def lsfit():
            A = np.stack(cols, 1); p = A.shape[1]
            G = A.T @ A + ridge * n * np.diag([0.0] + [1.0] * (p - 1)) + 1e-9 * n * np.eye(p)
            W = np.linalg.solve(G, A.T @ Y); fl[0] += 2 * n * p * p + p ** 3 / 3 + 4 * n * p * Cy
            return W, Y - A @ W

        W, R = lsfit()
        Lf = lambda N: math.log(4 * self.K * max(N, 1) / self.delta)
        if Cy == 1:
            thr = lambda N: self.c ** 2 * 2 * Lf(N)
        else:
            thr = lambda N: self.c ** 2 * (Cy + 2 * math.sqrt(Cy * Lf(N)) + 2 * Lf(N))
        yarg = Y.argmax(1) if Cy > 1 else None
        forced, log = 0, []
        for rnd in range(self.rounds):
            s = np.sqrt(np.maximum((R * R).mean(0), 1e-12))
            if s.max() < 1e-6:
                break
            if rnd > 0:
                Fv = Y - R
                if (np.all(np.sign(Fv[:, 0]) == Y[:, 0]) if Cy == 1 else np.all(Fv.argmax(1) == yarg)):
                    break
            if fl[0] > 0.75 * GD:
                break
            Rn = R / s

            def sub(m):
                Rm = R[:m]
                return Rm / np.sqrt(np.maximum((Rm * Rm).mean(0), 1e-12))

            cand, top = {}, [0.0, None]

            def offer(S, T, t):
                if S in have:
                    return
                z = T / t
                if z > top[0]:
                    top[:] = [z, S]
                if T > t and (S not in cand or cand[S] < z):
                    cand[S] = z

            def offer_mat(Tm, t, mk, valid=None):
                M = Tm if valid is None else np.where(valid, Tm, 0.0)
                q = int(np.argmax(M)); offer(mk(q), float(M.flat[q]), t)
                idx = np.flatnonzero(M > t)
                if len(idx) > 4 * self.max_new:
                    idx = idx[np.argpartition(-M.flat[idx], 4 * self.max_new)[:4 * self.max_new]]
                for f in idx:
                    offer(mk(int(f)), float(M.flat[f]), t)

            K = self.K if rnd == 0 else self.K_later
            # ---- degree 1
            c1 = B.T @ Rn / n; fl[0] += 2 * n * db * Cy
            offer_mat(n * (c1 ** 2).sum(1), thr(db), lambda f: (f,))
            base2 = np.triu(~same, 1); npair = int(base2.sum())
            # ---- degree 2
            if K >= 2 and npair:
                m = min(n, int(self.shares[0] * GD / (2 * db * db * Cy + 1)))
                if m >= 32:
                    Bm, Rm = B[:m], sub(m); T2 = np.zeros((db, db))
                    for q in range(Cy):
                        Mq = (Bm * Rm[:, q:q + 1]).T @ Bm / m; T2 += Mq * Mq
                    fl[0] += 2 * m * db * db * Cy + m * db * Cy
                    offer_mat(m * T2, thr(npair), lambda f: (f // db, f % db), base2)
            # ---- degrees 3 and 4: anchors (a) or (a < b) from different inputs, then every pair i < j above the anchor,
            #      batched over chunks of anchors: M[anchor, i, j] = mean(r * chi_anchor * b_i * b_j)
            def anchored(anc, m, t):
                Bm, Rm = B[:m], sub(m); A_ = len(anc)
                Pa = np.prod(np.stack([Bm[:, [x[k] for x in anc]] for k in range(len(anc[0]))]), axis=0)   # m x A
                La = np.array([x[-1] for x in anc]); ar = np.arange(db)
                ch = max(1, int(1.5e7 // (m * db)))
                for s0 in range(0, A_, ch):
                    sl = slice(s0, min(s0 + ch, A_)); Ac = sl.stop - sl.start
                    T = np.zeros((Ac, db, db))
                    for q in range(Cy):
                        Wq = Rm[:, q:q + 1] * Pa[:, sl]
                        for a_ in range(Ac):
                            Mq = (Bm * Wq[:, a_:a_ + 1]).T @ Bm; T[a_] += Mq * Mq
                    T /= m * m
                    fl[0] += Cy * (2 * m * Ac * db * db + 2 * m * Ac * db)
                    Rk = ar[None, :] > La[sl, None]
                    for k in range(len(anc[0])):
                        Rk &= grp[None, :] != grp[np.array([x[k] for x in anc[sl]])][:, None]
                    v = base2[None] & Rk[:, :, None] & Rk[:, None, :]
                    Tv = np.where(v, m * T, 0.0)
                    q = int(np.argmax(Tv)); qa, qi, qj = np.unravel_index(q, Tv.shape)
                    offer(tuple(int(x) for x in anc[sl.start + qa]) + (int(qi), int(qj)), float(Tv[qa, qi, qj]), t)
                    hit = np.argwhere(Tv > t)
                    if len(hit) > 4 * self.max_new:
                        vals = Tv[hit[:, 0], hit[:, 1], hit[:, 2]]; hit = hit[np.argpartition(-vals, 4 * self.max_new)[:4 * self.max_new]]
                    for qa, qi, qj in hit:
                        offer(tuple(int(x) for x in anc[sl.start + qa]) + (int(qi), int(qj)), float(Tv[qa, qi, qj]), t)

            if K >= 3 and db >= 3:
                m = min(n, int(self.shares[1] * GD / (2 * db ** 3 * Cy + 1)))
                if m >= 32:
                    anchored([(a_,) for a_ in range(db - 2)], m, thr(math.comb(db, 3)))
            if K >= 4 and db >= 4:
                m = min(n, int(self.shares[2] * GD / (npair * (2 * db * db * Cy + 3 * db * Cy) + 1)))
                if m >= 32:
                    anchored([(int(a_), int(b_)) for a_, b_ in zip(*np.where(base2)) if b_ < db - 2], m, thr(math.comb(db, 4)))
            # ---- higher degrees (first round, few bits only): chi_{T1 u T2} via character tables
            if rnd == 0 and db <= 40:
                for k in range(self.K + 1, self.K_hi + 1):
                    k1, k2 = (k + 1) // 2, k // 2; N1, N2 = math.comb(db, k1), math.comb(db, k2)
                    m = min(n, int(self.shares[4] * GD / ((2 * N1 * N2 + N1 * k1 + N2 * k2) * Cy + 1)))
                    if m < 64:
                        continue
                    T1, Z1 = _table(B[:m], range(db), k1); T2_, Z2 = (T1, Z1) if k2 == k1 else _table(B[:m], range(db), k2)
                    Rm = sub(m); Gs = np.zeros((N1, N2))
                    for q in range(Cy):
                        Gq = (Z1 * Rm[:, q:q + 1]).T @ Z2 / m; Gs += Gq * Gq
                    fl[0] += (2 * m * N1 * N2 + m * (N1 * k1 + N2 * k2)) * Cy
                    t = thr(math.comb(db, k))
                    for p_, q_ in zip(*np.where(m * Gs > t)):
                        S = set(T1[p_]) | set(T2_[q_])
                        if len(S) == k and len(set(grp[list(S)])) == k:
                            offer(tuple(sorted(S)), float(m * Gs[p_, q_]), t)
            # ---- extensions of current characters by one or two bits
            chis = [(i, f[1]) for i, f in enumerate(feats) if f[0] == "chi"]
            if chis:
                wn = np.linalg.norm(W[1:], axis=1)
                base = [S for i, S in sorted(chis, key=lambda iv: -wn[iv[0]])][: self.max_ext_bases]
                m = min(n, int(self.shares[3] * GD / (len(base) * (2 * db * db * Cy + 3 * db * Cy) + 1)))
                t1, t2 = thr(len(base) * db), thr(len(base) * npair)
                Rm = sub(m) if m >= 32 else None
                for S in base:
                    ch = np.prod(B[:, list(S)], axis=1); fl[0] += n * (len(S) + 1)
                    gS = set(grp[list(S)])
                    okj = np.array([g not in gS for g in grp])
                    e1 = B.T @ (Rn * ch[:, None]) / n; fl[0] += 2 * n * db * Cy
                    offer_mat(n * (e1 ** 2).sum(1), t1, lambda f, S=S: tuple(sorted(S + (f,))), okj)
                    if Rm is None:
                        continue
                    Bm = B[:m]; E2 = np.zeros((db, db))
                    for q in range(Cy):
                        Mq = (Bm * (Rm[:, q] * ch[:m])[:, None]).T @ Bm / m; E2 += Mq * Mq
                    fl[0] += 2 * m * db * db * Cy + m * db * Cy
                    offer_mat(m * E2, t2, lambda f, S=S: tuple(sorted(S + (f // db, f % db))),
                              base2 & okj[:, None] & okj[None, :])
            # ---- local: every subset of the bits in use (Walsh transform of the residual on V)
            V = sorted(set(v for f in feats if f[0] == "chi" for v in f[1]))
            if 2 <= len(V) <= self.local_max:
                L = len(V); idx = (B[:, V] < 0).astype(np.int64) @ (1 << np.arange(L)); fl[0] += n * L
                H = _fwht(np.stack([np.bincount(idx, weights=Rn[:, q], minlength=1 << L) for q in range(Cy)])) / n
                fl[0] += Cy * (n + L * (1 << L))
                Tl = n * (H ** 2).sum(0)
                tl = {k: thr(math.comb(L, k)) for k in range(1, L + 1)}
                for mk in np.where(Tl > min(tl.values()))[0]:
                    if mk == 0:
                        continue
                    S = tuple(V[q] for q in range(L) if mk >> q & 1)
                    if len(set(grp[list(S)])) == len(S):
                        offer(S, float(Tl[mk]), tl[len(S)])
            # ---- block moves (on the linear encoding Zl)
            blk = []
            lin = [j for j in range(dz) if ("lin", j) not in have and not (j in zb and ((zb[j],) in have or (zb[j],) in cand))]
            if lin:
                cz = Zl[:, lin].T @ Rn / n; fl[0] += 2 * n * len(lin) * Cy
                Tz = n * float(np.sum(cz ** 2)); k = len(lin) * Cy; tt = math.log(1 / self.delta)
                if Tz > k + 2 * math.sqrt(k * tt) + 2 * tt and n >= 2 * (len(feats) + 1 + len(lin)):
                    blk.append(("linear", lin))
            if n >= 4 * dz and 2 <= dz <= 256:
                ev_all = []
                for q in range(Cy):
                    Mq = (Zl * Rn[:, q:q + 1]).T @ Zl / n; Mq = (Mq + Mq.T) / 2; np.fill_diagonal(Mq, 0.0)
                    if binary_inputs:
                        for S in list(have) + list(cand):
                            if isinstance(S, tuple) and len(S) == 2 and isinstance(S[0], (int, np.integer)):
                                Mq[S[0], S[1]] = Mq[S[1], S[0]] = 0.0
                    lam, U = np.linalg.eigh(Mq); fl[0] += 2 * n * dz * dz + 10 * dz ** 3
                    edge = 2 * math.sqrt(dz / n) * (1 + math.sqrt(2 * math.log(1 / self.delta) / dz))
                    if not binary_inputs:               # correlated inputs: a permutation null instead of Wigner's edge
                        pr = np.random.default_rng(rnd * 7 + q).permutation(n)
                        Mp = (Zl * Rn[pr, q:q + 1]).T @ Zl / n; Mp = (Mp + Mp.T) / 2; np.fill_diagonal(Mp, 0.0)
                        edge = max(edge, 1.1 * float(np.max(np.abs(np.linalg.eigvalsh(Mp)))))
                        fl[0] += 2 * n * dz * dz + 10 * dz ** 3
                    for i in np.argsort(-np.abs(lam)):
                        if abs(lam[i]) > edge:
                            ev_all.append((abs(lam[i]) / edge, U[:, i].copy()))
                ev_all.sort(key=lambda t: -t[0])
                if ev_all:
                    blk.append(("quad", [u for _, u in ev_all[:4]]))
            # ---- accept (at most one character per input signature per round)
            bysig = {}
            for S, z in cand.items():
                sg = tuple(sorted(set(int(g) for g in grp[list(S)])))
                if sg not in bysig or bysig[sg][1] < z:
                    bysig[sg] = (S, z)
            new = [S for S, z in sorted(bysig.values(), key=lambda t: -t[1])][: self.max_new]
            if force and not new and not blk and forced < 2 and top[1] is not None:
                new = [top[1]]; forced += 1
            room = min(self.max_feats, n // 2) - len(feats)
            if (not new and not blk) or room <= 0:
                break
            for S in new[:room]:
                feats.append(("chi", S)); cols.append(np.prod(B[:, list(S)], axis=1)); have.add(S); fl[0] += n * len(S)
            for kind, obj in blk:
                if kind == "linear":
                    for j in obj:
                        feats.append(("lin", j)); cols.append(Zl[:, j].copy()); have.add(("lin", j))
                        if j in zb:
                            have.add((zb[j],))
                else:
                    for u in obj:
                        v = (Zl @ u) ** 2; feats.append(("quad", u, float(v.mean()))); cols.append(v - v.mean())
                        fl[0] += 2 * n * dz
            log.append(dict(round=rnd, new=len(new[:room]), blocks=[k for k, _ in blk]))
            W, R = lsfit()
        return feats, fl[0], log

    # ================================================================== stage-1 readout: softmax regression
    @staticmethod
    def _logit_newton(A, y, pen, W0=None, maxiter=40):
        """C = 2: penalised logistic regression by damped Newton; returned in the softmax layout (W = [0, w], b = [0, c])."""
        n, p = A.shape; t = y.astype(np.float64); fl = 0.0
        Ab = np.hstack([A, np.ones((n, 1))]); pv = np.r_[pen, 0.0] + np.r_[np.zeros(p), 1e-8]
        w = np.zeros(p + 1) if W0 is None else np.r_[W0[:2 * p].reshape(p, 2)[:, 1] - W0[:2 * p].reshape(p, 2)[:, 0], W0[-1] - W0[-2]]
        def loss(w):
            z = Ab @ w
            return float(np.mean(np.logaddexp(0.0, z) - t * z) + 0.5 * np.sum(pv * w * w)), z
        L, z = loss(w)
        for it in range(maxiter):
            pr = 1.0 / (1.0 + np.exp(-z)); g = Ab.T @ (pr - t) / n + pv * w
            H = (Ab * (pr * (1 - pr))[:, None]).T @ Ab / n + np.diag(pv)
            step = np.linalg.solve(H, g); fl += 2 * n * (p + 1) ** 2 + (p + 1) ** 3 / 3 + 8 * n * (p + 1)
            a = 1.0
            while True:
                Ln, zn = loss(w - a * step); fl += 2 * n * (p + 1)
                if Ln <= L or a < 1e-4:
                    break
                a *= 0.5
            w, dL, L, z = w - a * step, L - Ln, Ln, zn
            if dL < 1e-10 or np.max(np.abs(a * step)) < 1e-7:
                break
        Wm = np.zeros((p, 2)); Wm[:, 1] = w[:p]
        return np.concatenate([Wm.ravel(), [0.0, w[p]]]), fl

    def _softmax(self, A, y, C, pen, W0=None, maxiter=300):
        if C == 2:
            return self._logit_newton(A, y, pen, W0)
        n, p = A.shape; Yo = np.eye(C)[y]; nf = [0]

        def f(th):
            W = th[: p * C].reshape(p, C); b = th[p * C:]
            S = A @ W + b; S -= S.max(1, keepdims=True); E = np.exp(S); Z = E.sum(1, keepdims=True); P = E / Z
            ll = -np.mean(np.log(np.maximum(P[np.arange(n), y], 1e-300)))
            G = (P - Yo) / n; nf[0] += 1
            val = ll + 0.5 * float(np.sum(pen[:, None] * W * W))
            gW = A.T @ G + pen[:, None] * W
            return val, np.concatenate([gW.ravel(), G.sum(0)])

        th0 = np.zeros(p * C + C) if W0 is None else W0
        r = minimize(f, th0, jac=True, method="L-BFGS-B", options=dict(maxiter=maxiter, gtol=1e-6))
        th = r.x
        return th, nf[0] * (4.0 * n * p * C + 12.0 * n * C)

    @staticmethod
    def _margins(th, A, C):
        p = A.shape[1]
        return A @ th[: p * C].reshape(p, C) + th[p * C:]

    # ================================================================== stage 2: boosted trees on the margins
    def _gb_params(self, n_tr, d, C, rng):
        leaves = int(np.clip(n_tr // 25, 4, 31))
        big = getattr(self, "_big", False)
        p = dict(objective="binary" if C == 2 else "multiclass", learning_rate=0.2 if big else self.lr, num_leaves=leaves,
                 min_data_in_leaf=int(np.clip(n_tr // 50, 2, 20)), lambda_l2=1.0,
                 feature_fraction=0.2 if big else 0.8 if d <= 100 else 0.3, bagging_fraction=0.5 if big else 0.8, bagging_freq=1, max_bin=63 if d > 200 else 255, num_threads=1, verbose=-1,
                 seed=int(rng.integers(1 << 30)), min_sum_hessian_in_leaf=1e-3)
        if C > 2:
            p["num_class"] = C
        return p

    def _tree_flops(self, p, n_tr, d, C, trees_built):
        lv = max(1, math.ceil(math.log2(p["num_leaves"])))
        per = 2.0 * n_tr * p["bagging_fraction"] * d * p["feature_fraction"] * lv + 4.0 * p["max_bin"] * d * p["num_leaves"]
        return per * trees_built * (1 if C == 2 else C)

    @staticmethod
    def _to_init(S, C):
        return (S[:, 1] - S[:, 0]) if C == 2 else S

    def _gb_run(self, Xtr, ytr, Str, Xva, yva, Sva, C, cat, rng, rounds, early=True):
        import lightgbm as lgb
        n_tr, d = Xtr.shape; p = self._gb_params(n_tr, d, C, rng)
        dtr = lgb.Dataset(Xtr, ytr, init_score=self._to_init(Str, C), categorical_feature=cat or "auto",
                          free_raw_data=False, params=dict(max_bin=p["max_bin"], verbose=-1))
        rec = {}; cbs = [lgb.record_evaluation(rec)]
        vs = []
        if Xva is not None:
            dva = lgb.Dataset(Xva, yva, init_score=self._to_init(Sva, C), reference=dtr)
            vs = [dva]
            p["metric"] = ["binary_logloss", "binary_error"] if C == 2 else ["multi_logloss", "multi_error"]
            if early:
                cbs.append(lgb.early_stopping(self.patience, first_metric_only=True, verbose=False, min_delta=self.min_delta))
        else:
            p["metric"] = "None"
        bst = lgb.train(p, dtr, num_boost_round=rounds, valid_sets=vs, callbacks=cbs)
        built = bst.current_iteration()
        fl = self._tree_flops(p, n_tr, d, C, built)
        if Xva is not None:
            v = rec["valid_0"]; ks = list(v.keys()); ll, er = np.array(v[ks[0]]), np.array(v[ks[1]])
            if ks[0].endswith("error"):
                ll, er = er, ll
            fl += 2.0 * len(Xva) * built * (1 if C == 2 else C) * math.log2(p["num_leaves"] + 1)
            return bst, fl, ll, er
        return bst, fl, None, None

    @staticmethod
    def _raw(bst, X, T, C):
        r = bst.predict(X, raw_score=True, num_iteration=T)
        return np.stack([np.zeros(len(X)), r], 1) if C == 2 else r

    # ================================================================== helpers
    @staticmethod
    def _eval(S, y):
        S = S - S.max(1, keepdims=True); P = np.exp(S); P /= P.sum(1, keepdims=True)
        ll = -np.log(np.maximum(P[np.arange(len(y)), y], 1e-15))
        return (S.argmax(1) != y).astype(float), ll

    def _stage1(self, X, y, types, C, GD, force, enc=None):
        """Search on (X, y) and build the readout design; returns (enc, feats, A-builder, flops)."""
        enc = enc or _Enc(X, types)
        B, Z = enc.bits(X), enc.z(X)
        Y = (2.0 * y - 1.0)[:, None] if C == 2 else np.eye(C)[y] - np.bincount(y, minlength=C) / len(y)
        binary_inputs = all(t == "binary" for t in types)
        feats, fl, log = self._grow(B, enc.grp, Z, enc.zb, Y, GD, force=force, binary_inputs=binary_inputs)
        fl += 2.0 * X.shape[0] * (B.shape[1] + Z.shape[1])
        return enc, feats, fl, log

    @staticmethod
    def _design(enc, feats, X):
        """[grown features, background z columns not already grown], and the per-column 'is grown feature' mask."""
        B, Z = enc.bits(X), enc.z(X)
        Fc = _feat_cols(feats, B, Z)
        used = set(f[1] for f in feats if f[0] == "lin")
        usedb = set(f[1][0] for f in feats if f[0] == "chi" and len(f[1]) == 1)
        bg = [j for j in range(Z.shape[1]) if j not in used and not (j in enc.zb and enc.zb[j] in usedb)]
        A = np.hstack([Fc, Z[:, bg]])
        isf = np.r_[np.array([f[0] == "chi" for f in feats], bool), np.zeros(len(bg), bool)]   # only tested characters
        return A, isf

    def _prior(self, y, C, m):
        f = (np.bincount(y, minlength=C) + 1.0) / (len(y) + C)
        return np.tile(np.log(f), (m, 1))

    # ================================================================== stage-1 nearest-neighbour block
    @staticmethod
    def _knn(Qm, Pm, k, self_rows=False):
        """Indices (sorted by distance) of the k nearest of the prototypes Pm for each row of Qm; with self_rows, row i
        of Qm is prototype i (when i < len(Pm)) and is excluded."""
        m, P = len(Qm), len(Pm); k = min(k, P - (1 if self_rows else 0))
        pn = (Pm * Pm).sum(1); out = np.empty((m, k), np.int64); ch = max(1, int(4e7 // P))
        for s in range(0, m, ch):
            q = Qm[s:s + ch]; D = pn[None, :] - 2.0 * (q @ Pm.T)
            if self_rows:
                r = np.arange(s, min(s + ch, m)); ok = r < P; D[np.flatnonzero(ok), r[ok]] = np.inf
            if k < P:
                part = np.argpartition(D, k - 1, axis=1)[:, :k]
                o = np.argsort(np.take_along_axis(D, part, 1), axis=1); out[s:s + ch] = np.take_along_axis(part, o, 1)
            else:
                out[s:s + ch] = np.argsort(D, axis=1)[:, :k]
        return out

    def _votes(self, nb, allowed, yP, C):
        ok = allowed[nb]; rank = np.cumsum(ok, 1); lab = yP[nb]; out = []
        for k in self.nn_ks:
            sel = ok & (rank <= k)
            cnt = np.stack([(sel & (lab == c)).sum(1) for c in range(C)], 1).astype(np.float64)
            out.append(np.log((cnt + 0.5) / (cnt.sum(1, keepdims=True) + 0.5 * C)))
        return np.hstack(out)

    def _nn_prep(self, X, y, C, enc, budget):
        """Metric (standardized z, or all columns at one pooled scale) chosen by leave-one-out 3-NN error on the first
        <= 1000 points; prototypes = the first P training points, P set by a FLOP share of the budget."""
        n = len(X); fl = 0.0
        mu = X.mean(0); S = math.sqrt(max(float(np.mean(X.var(0))), 1e-12))
        mets = {"z": lambda Z: enc.z(Z).astype(np.float32), "raw": lambda Z: ((Z - mu) / S).astype(np.float32)}
        Q = min(n, 1000); errs = {}
        for nm, f in mets.items():
            M = f(X[:Q]); nb = self._knn(M, M, 3, self_rows=True); fl += 2.0 * Q * Q * M.shape[1]
            v = np.stack([(y[nb] == c).sum(1) for c in range(C)], 1)
            errs[nm] = float(np.mean(v.argmax(1) != y[:Q]))
        met = min(errs, key=errs.get); fm = mets[met]; M = fm(X); dm = M.shape[1]
        P = int(min(n, self.nn_pmax, self.nn_share * budget / (2.0 * n * dm + 1)))
        if P < 20:
            return None, fl
        K = min(P - 1, self.nn_keep)
        nb = self._knn(M, M[:P], K, self_rows=True); fl += 2.0 * n * P * dm
        return dict(f=fm, Pm=M[:P].copy(), P=P, nb=nb, yP=y[:P].copy(), met=met, errs=errs), fl

    # ================================================================== fit
    def fit(self, X, y, types, C, rng=None, budget=None):
        t0 = time.time()
        rng = rng if rng is not None else np.random.default_rng(0)
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y).astype(np.int64); n, d = X.shape
        types = [t if t in ("binary", "categorical") else "continuous" for t in types]
        budget = common.budget_real(X, types, C, n) if budget is None else float(budget)
        cat = [j for j, t in enumerate(types) if t == "categorical" and np.all(X[:, j] >= 0) and np.all(X[:, j] == np.round(X[:, j]))]
        fl = 0.0; info = {}
        sc = lambda e, l: float(np.mean(e) + self.ll_w * np.mean(l))
        idx = rng.permutation(n); order = idx[np.argsort(y[idx], kind="stable")]
        if n <= self.n_cv:
            F = 10 if n <= 64 else 5 if n <= 200 else 3
            fold = np.empty(n, int); fold[order] = np.arange(n) % F
            variants = [False, True] if n <= self.force_n else [False]
            GDf = 0.3 * budget / (F * len(variants)); folds = list(range(F))
        else:
            F = 1
            fold = np.zeros(n, int); fold[order[::5]] = 1          # a 20% hold-out
            variants = [False]; GDf = 0.4 * budget; folds = [1]
        # ---- nearest-neighbour block (prototypes = training points; votes of the k nearest, k in nn_ks)
        enc_all = _Enc(X, types)
        NN, f0 = self._nn_prep(X, y, C, enc_all, budget) if self.nn else (None, 0.0); fl += f0
        nnopts = [False, True] if NN is not None else [False]
        if NN is not None:
            info.update(nn_metric=NN["met"], nn_P=NN["P"])
        # large problems (n d C > 5e7, e.g. MNIST-sized): 2 penalties, 100 L-BFGS iterations, faster trees, no trees-alone
        self._big = big = n * enc_all.z(X[:1]).shape[1] * C > 5e7
        lams = self.lam_grid[-2:] if big else self.lam_grid; mi = 100 if big else 300
        tmax = 200 if big else self.tmax
        if big and NN is not None:
            nnopts = [True]
        nl = len(lams)
        cfgs = [(v, o) for v in variants for o in nnopts]
        E = {c: [np.zeros(n) for _ in range(nl)] for c in cfgs}; Lg = {c: [np.zeros(n) for _ in range(nl)] for c in cfgs}
        keep = {}; vm = np.zeros(n, bool)
        # ---- stage 1 on each fold: errors / logloss per (search variant, nn on/off, lambda); margins kept for stage 2
        for f in folds:
            va = fold == f; tr = ~va; vm |= va
            enc = _Enc(X[tr], types)
            if NN is not None:
                allowed = np.zeros(NN["P"], bool); allowed[:] = tr[:NN["P"]]
                Vtr, Vva = self._votes(NN["nb"][tr], allowed, NN["yP"], C), self._votes(NN["nb"][va], allowed, NN["yP"], C)
            for v in variants:
                enc, feats, f1, log = self._stage1(X[tr], y[tr], types, C, GDf, v, enc); fl += f1
                Atr, isf = self._design(enc, feats, X[tr]); Ava, _ = self._design(enc, feats, X[va])
                for o in nnopts:
                    A1, A2, isf1 = (np.hstack([Atr, Vtr]), np.hstack([Ava, Vva]), np.r_[isf, np.zeros(Vtr.shape[1], bool)]) if o else (Atr, Ava, isf)
                    th = None
                    for li, lam in enumerate(lams):
                        pen = np.where(isf1, min(self.lam_f, lam), lam)
                        th, f2 = self._softmax(A1, y[tr], C, pen, th, mi); fl += f2
                        Sva = self._margins(th, A2, C); e, l = self._eval(Sva, y[va])
                        E[(v, o)][li][va], Lg[(v, o)][li][va] = e, l
                        keep[(f, v, o, li)] = (self._margins(th, A1, C), Sva, enc if F == 1 else None, feats if F == 1 else None, th)
        best = {}
        for c in cfgs:
            s = [sc(E[c][li][vm], Lg[c][li][vm]) for li in range(nl)]; li = int(np.argmin(s)); best[c] = (s[li], li)
        info["cfg"] = {f"{int(c[0])}{int(c[1])}": [round(float(np.mean(E[c][li][vm])), 3) for li in range(nl)] for c in cfgs}
        vstar = False
        if True in variants:                                   # forced search only if it wins a paired (McNemar) test
            c0 = min([c for c in cfgs if not c[0]], key=lambda c: best[c][0]); c1 = min([c for c in cfgs if c[0]], key=lambda c: best[c][0])
            e0, e1 = E[c0][best[c0][1]][vm], E[c1][best[c1][1]][vm]
            b_, c_ = int(np.sum((e0 > 0) & (e1 == 0))), int(np.sum((e0 == 0) & (e1 > 0)))
            vstar = bool(b_ - c_ > 2 * math.sqrt(b_ + c_))
        cstar = min([c for c in cfgs if c[0] == vstar], key=lambda c: best[c][0]); ostar = cstar[1]
        li = best[cstar][1]; lam = lams[li]
        s1_err, s1_ll = E[cstar][li][vm], Lg[cstar][li][vm]
        cands = {"s1": (sc(s1_err, s1_ll), 0)}
        info.update(F=F, variant=int(vstar), nn=int(ostar), lam=lam, s1_err=float(np.mean(s1_err)))
        # ---- stage 2: trees on the stage-1 margins, and trees alone; number of trees by validation logloss
        if self.stage2 and np.mean(s1_err) > 0:
            for fam in (("s12",) if big else ("s12", "s2")):
                LL = np.zeros(tmax); ER = np.zeros(tmax); nv = 0
                for f in folds:
                    va = fold == f; tr = ~va
                    if fam == "s12":
                        Str, Sva = keep[(f, vstar, ostar, li)][:2]
                    else:
                        Str, Sva = self._prior(y[tr], C, tr.sum()), self._prior(y[tr], C, va.sum())
                    _, f3, ll, er = self._gb_run(X[tr], y[tr], Str, X[va], y[va], Sva, C, cat, rng, tmax)
                    fl += f3; k = va.sum(); nv += k
                    pad = lambda a: np.r_[a, np.full(tmax - len(a), a[-1])]
                    LL += k * pad(ll); ER += k * pad(er)
                LL /= nv; ER /= nv; T = int(np.argmin(LL)) + 1
                cands[fam] = (float(ER[T - 1] + self.ll_w * LL[T - 1]), T)
                info[fam + "_err"] = float(ER[T - 1]); info[fam + "_T"] = T
        choice = min(cands, key=lambda k: cands[k][0]); T = cands[choice][1]
        info.update(choice=choice)
        # ---- final fit on all n
        use_s1 = choice in ("s1", "s12")
        if use_s1:
            if F > 1:
                enc, feats, f1, log = self._stage1(X, y, types, C, 0.3 * budget, vstar); fl += f1
                th0 = keep[(0, vstar, ostar, li)][4]
            else:
                _, _, enc, feats, th0 = keep[(1, vstar, ostar, li)]
            A, isf = self._design(enc, feats, X)
            if ostar:
                V = self._votes(NN["nb"], np.ones(NN["P"], bool), NN["yP"], C)
                A = np.hstack([A, V]); isf = np.r_[isf, np.zeros(V.shape[1], bool)]
            pen = np.where(isf, min(self.lam_f, lam), lam)
            th, f2 = self._softmax(A, y, C, pen, th0 if len(th0) == (A.shape[1] + 1) * C else None, mi); fl += f2
            S = self._margins(th, A, C)
            info.update(n_feats=len(feats), feats=[(f[0], f[1]) if f[0] != "quad" else ("quad",) for f in feats][:30])
        else:
            S = self._prior(y, C, n)
        bst = None
        if choice in ("s12", "s2"):
            Tf = max(1, int(round(T * (1.1 if F == 1 else F / (F - 1.0)))))
            bst, f3, _, _ = self._gb_run(X, y, S, None, None, None, C, cat, rng, Tf); fl += f3; T = Tf
        info.update(T=T, budget_frac=fl / budget, wall=time.time() - t0)
        prior = self._prior(y, C, 1)[0]
        kmax = max(self.nn_ks)

        def predict(Z):
            Z = np.asarray(Z, dtype=np.float64)
            if use_s1:
                A_, _ = self._design(enc, feats, Z)
                if ostar:
                    nbq = self._knn(NN["f"](Z), NN["Pm"], kmax)
                    A_ = np.hstack([A_, self._votes(nbq, np.ones(NN["P"], bool), NN["yP"], C)])
                M = self._margins(th, A_, C)
            else:
                M = np.tile(prior, (len(Z), 1))
            if bst is not None:
                M = M + self._raw(bst, Z, T, C) if C > 2 else M + self._raw(bst, Z, T, C)
            return M.argmax(1)

        return dict(predict=predict, flops=float(fl), info=info)
