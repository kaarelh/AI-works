"""dfg_bits: DFG (discrete feature growth) run on a Boolean encoding of standard tabular data.

ENCODING.  Every input becomes +-1 bits: binary -> 1 bit; categorical -> one bit per value (one-hot, +-1);
continuous / ordinal -> thermometer bits [x > t_q] at the training quantiles q / (nb + 1), q = 1..nb, with
nb = clip(round(480 / #continuous inputs), 6, 12) (duplicate splits dropped; a bit needs >= min_count points on each side).  Bits of one input form a 'group'.  The standardized
continuous values z are kept as extra linear-block / spectral inputs.

DFG ROUNDS (as in study/discrete_learner/dfg.py, generalised to correlated bits and C classes).
  Y = +-1 labels (C = 2) or one-hot (C > 2).  r = Y - least-squares fit on the current features.
  The residual matrix is whitened with its own covariance (dof-corrected, SSR / (n - p)), Rw (n x k), k = rank.
  For a candidate character phi = prod_{i in S} b_i (phi^2 = 1, but no longer mean 0 / orthogonal):
      T(phi) = m * sum_q mean(Rw_q phi)^2 / max(var(phi), vfloor)        ~ chi^2_k under 'no signal'
  accepted if T > c^2 (k + 2 sqrt(k L) + 2 L), L = ln(4 K N / delta)   (Laurent-Massart chi^2 tail, union bound over N)
  Candidate classes (each with its own N):
      global   degree 1 (all bits), degree 2 (all pairs of bits from different groups), degree 3 (all triples), degree 4
               in the first round; each search on the first m points, m set by a FLOP share of the budget
      extension S u {j}, S u {j, l} for the strongest current characters S                         N = #candidates
      local    every subset (degree >= 2) of V = the bits of the strongest current characters, |V| <= local_max,
               via a Walsh transform of the residual histogram on V                                   N = C(|V|, deg)
  At most one character per group-signature (the set of inputs it touches) per round.
  BLOCKS:  linear  - all z (standardized continuous) and all remaining degree-1 bits, if a chi^2 test on the block passes
           spectral - top eigen-directions u of mean(Rw_q u u^T) on (z, non-continuous bits) above a permutation-null
                      noise edge; features (u.x)^2 (centred)
  Stop when nothing passes, room (p <= n / 2, p <= max_feats) or the FLOP budget is used up.
READOUT.  Ridge least squares on [grown features, all linear inputs (the kernel-like linear background)], ridge chosen
  by exact leave-one-out (eigendecomposition), then refined by softmax / logistic regression (majorise-minimise with
  Bohning's fixed curvature bound, sharing the same eigendecomposition), the logistic penalty and the LS-vs-logistic
  choice made on a 20% hold-out.  No gradient descent on any feature: features are discrete, only readout weights are
  continuous.
COMPUTE.  FLOPs counted for every matrix product, solve and eigendecomposition (multiply-add = 2); the budget is
  harness.mlp_flops (one MLP training run at this n).
"""
import os, sys, math, itertools
import numpy as np

_HERE = os.path.dirname(os.path.abspath(__file__))
if os.path.dirname(_HERE) not in sys.path:
    sys.path.insert(0, os.path.dirname(_HERE))
from harness import mlp_flops


def _fwht(a):
    """Walsh-Hadamard transform along the last axis of a (b, 2^L) array."""
    a = np.array(a, dtype=np.float64); b, n = a.shape; h = 1
    while h < n:
        a = a.reshape(b, -1, 2, h)
        a = np.concatenate([a[:, :, 0] + a[:, :, 1], a[:, :, 0] - a[:, :, 1]], axis=2).reshape(b, n)
        h *= 2
    return a


class _Enc:
    def __init__(self, X, types, nb, min_count, zclip=6.0):
        n = len(X); J, T, E, grp, nonc = [], [], [], [], []
        zj, zm, zs = [], [], []
        for j, t in enumerate(types):
            x = X[:, j]
            if t == "categorical":
                vals, cnt = np.unique(x, return_counts=True)
                cand = [v for v, c in zip(vals, cnt) if min_count <= c <= n - min_count]
                if len(vals) <= 2:
                    cand = cand[:1]
                for v in cand:
                    J.append(j); T.append(v); E.append(True); grp.append(j); nonc.append(True)
            elif t == "binary":
                lo = x.min(); c = int(np.sum(x > lo))
                if min_count <= c <= n - min_count:
                    J.append(j); T.append(lo); E.append(False); grp.append(j); nonc.append(True)
            else:
                m, s = x.mean(), x.std()
                if s > 1e-12:
                    zj.append(j); zm.append(m); zs.append(s)
                seen = set()
                for tq in np.unique(np.quantile(x, np.arange(1, nb + 1) / (nb + 1))):
                    c = int(np.sum(x > tq))
                    if min_count <= c <= n - min_count and c not in seen:
                        seen.add(c); J.append(j); T.append(tq); E.append(False); grp.append(j); nonc.append(False)
        self.J, self.T, self.E = np.array(J, int), np.array(T, float), np.array(E, bool)
        self.grp, self.nonc = np.array(grp, int), np.array(nonc, bool)
        self.zj, self.zm, self.zs, self.zclip = np.array(zj, int), np.array(zm), np.array(zs), zclip

    def bits(self, X):
        V = X[:, self.J]
        return np.where(self.E, V == self.T, V > self.T).astype(np.float64) * 2.0 - 1.0

    def z(self, X):
        if len(self.zj) == 0:
            return np.zeros((len(X), 0))
        return np.clip((X[:, self.zj] - self.zm) / self.zs, -self.zclip, self.zclip)


class Learner:
    def __init__(self, nb="auto", c=1.0, delta=0.1, K=4, rounds=12, max_new=64, max_feats=1200, min_count=3,
                 vfloor=0.05, share_pair=0.03, share_tri=0.03, share_four=0.08, share_ext2=0.02, share_spec=0.02,
                 max_ext_bases=24, local_max=10, spectral=True, max_quad=8, readout="softmax", logit_facs=(1.0, 0.1, 0.01),
                 iters=30, name="dfg_bits-v1"):
        self.nb, self.c, self.delta, self.K, self.rounds, self.max_new = nb, c, delta, K, rounds, max_new
        self.max_feats, self.min_count, self.vfloor = max_feats, min_count, vfloor
        self.share_pair, self.share_tri, self.share_four, self.share_ext2 = share_pair, share_tri, share_four, share_ext2
        self.share_spec, self.max_ext_bases, self.local_max, self.spectral = share_spec, max_ext_bases, local_max, spectral
        self.max_quad, self.readout, self.name = max_quad, readout, name
        self.logit_facs, self.iters = tuple(logit_facs), iters

    # ------------------------------------------------------------------------------------------------------------------
    def fit(self, X, y, types, C, rng=None):
        rng = rng if rng is not None else np.random.default_rng(0)
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y).astype(int); n = len(y)
        GD = mlp_flops(X, types, C, n); fl = [0.0]
        ncont = sum(t not in ("binary", "categorical") for t in types)
        nb = int(np.clip(round(480 / max(ncont, 1)), 6, 12)) if self.nb == "auto" else int(self.nb)
        enc = _Enc(X, types, nb, self.min_count)
        B = enc.bits(X); Z = enc.z(X); db, dz = B.shape[1], Z.shape[1]; grp = enc.grp
        fl[0] += 2 * n * math.log2(max(n, 2)) * X.shape[1] + n * (db + 2 * dz)
        U = np.hstack([Z, B[:, enc.nonc]]); du = U.shape[1]
        Y = (2.0 * y - 1.0)[:, None] if C == 2 else np.eye(C)[y]
        Cy = Y.shape[1]
        mB = B.mean(0); fl[0] += n * db
        info = dict(db=db, dz=dz, nb=nb, log=[])
        cap = int(min(self.max_feats, n // 2))
        pmax = cap + 1                       # rounds never hold more than cap columns (blocks and new characters fit the room)
        A = np.empty((n, pmax)); G = np.zeros((pmax, pmax)); AtY = np.zeros((pmax, Cy))
        feats = []; have = set(); st = dict(p=0)
        ridge = 1e-3

        def add(cols, descs):
            p = st["p"]; q = cols.shape[1]
            if q == 0:
                return
            A[:, p:p + q] = cols
            Gn = A[:, :p + q].T @ cols; G[:p + q, p:p + q] = Gn; G[p:p + q, :p] = Gn[:p].T
            AtY[p:p + q] = cols.T @ Y
            fl[0] += 2 * n * (p + q) * q + 2 * n * q * Cy
            feats.extend(descs); st["p"] = p + q
            for dsc in descs:
                have.add(dsc[1] if dsc[0] == "chi" else (dsc[0], dsc[1]) if dsc[0] == "z" else None)

        def lsfit():
            p = st["p"]; Gr = G[:p, :p] + ridge * n * np.diag([0.0] + [1.0] * (p - 1)) + 1e-9 * n * np.eye(p)
            W = np.linalg.solve(Gr, AtY[:p]); R = Y - A[:, :p] @ W
            fl[0] += 2 * p ** 3 / 3 + 2 * p * p * Cy + 2 * n * p * Cy
            return W, R

        add(np.ones((n, 1)), [("one", ())])
        W, R = lsfit()
        Gm_cache = {}

        def gram_m(m):                       # means of pairwise products b_i b_j on the first m points
            if m not in Gm_cache:
                Gm_cache[m] = B[:m].T @ B[:m] / m; fl[0] += 2 * m * db * db
            return Gm_cache[m]

        L_ = lambda N: math.log(4 * self.K * max(N, 1) / self.delta)
        same = grp[:, None] == grp[None, :]
        last = 0.0
        for rnd in range(self.rounds):
            p = st["p"]; dof = n - p; f0 = fl[0]
            if dof < 8 or p >= cap:
                break
            nbg = sum((i,) not in have for i in range(db)) + sum(("z", j) not in have for j in range(dz))
            if fl[0] + 1.2 * last + self._readout_cost(n, p + self.max_new + nbg, C) > 0.92 * GD:
                break
            Sig = R.T @ R / dof; ev, EV = np.linalg.eigh(Sig); keep = ev > 1e-9 * max(ev.max(), 1e-300)
            if not np.any(keep) or ev.max() < 1e-12:
                break
            Wh = EV[:, keep] / np.sqrt(ev[keep]); Rw = R @ Wh; k = Rw.shape[1]; fl[0] += 2 * n * Cy * k + 2 * n * Cy * Cy
            thr = lambda N: self.c ** 2 * (k + 2 * math.sqrt(k * L_(N)) + 2 * L_(N))
            cand = {}                                         # signature -> (ratio, S)

            def offer(S, T, t):
                if S in have or T <= t:
                    return
                sig = tuple(sorted(set(int(grp[i]) for i in S)))
                if sig not in cand or cand[sig][0] < T / t:
                    cand[sig] = (T / t, S)

            def offer_mat(T, valid, t, mk, top=4 * self.max_new):
                idx = np.flatnonzero((T > t) & valid)
                if len(idx) > top:
                    idx = idx[np.argpartition(-T.flat[idx], top)[:top]]
                for f in idx:
                    offer(mk(f), T.flat[f], t)

            # ---- global degree 1
            c1 = B.T @ Rw / n; fl[0] += 2 * n * db * k
            v1 = np.maximum(1 - mB ** 2, self.vfloor); T1 = n * np.sum(c1 ** 2, 1) / v1
            t = thr(db)
            for i in np.flatnonzero(T1 > t):
                offer((int(i),), T1[i], t)
            # ---- global degree 2 (pairs of bits from different groups) on the first m points
            m = min(n, int(self.share_pair * GD / (2 * db * db * (k + 1))))
            iu = np.triu(np.ones((db, db), bool), 1) & ~same
            npair = int(iu.sum())
            if m >= 32 and npair:
                Bm = B[:m]; Gm = gram_m(m); T2 = np.zeros((db, db))
                for q in range(k):
                    M = (Bm * Rw[:m, q:q + 1]).T @ Bm / m; T2 += M * M
                fl[0] += 2 * m * db * db * k + m * db * k
                T2 *= m / np.maximum(1 - Gm ** 2, self.vfloor)
                offer_mat(T2, iu, thr(npair), lambda f: (int(f // db), int(f % db)))
            # ---- global degree 3 (anchor a < i < j), budgeted
            m = min(n, int(self.share_tri * GD / (2 / 3 * db ** 3 * (k + 1) + 1)))
            if m >= 64 and db >= 3:
                Bm = B[:m]; Rm = Rw[:m]; t = thr(math.comb(db, 3))
                for a in range(db - 2):
                    Bo = Bm[:, a + 1:]; Ba = Bo * Bm[:, a:a + 1]; do = Bo.shape[1]
                    Mm = Ba.T @ Bo / m; T3 = np.zeros((do, do))
                    for q in range(k):
                        M = (Ba * Rm[:, q:q + 1]).T @ Bo / m; T3 += M * M
                    fl[0] += 2 * m * do * do * (k + 1) + m * do * (k + 1)
                    T3 *= m / np.maximum(1 - Mm ** 2, self.vfloor)
                    go = grp[a + 1:]
                    val = np.triu(np.ones((do, do), bool), 1) & (go[:, None] != go[None, :]) & (go[:, None] != grp[a]) & (go[None, :] != grp[a])
                    offer_mat(T3, val, t, lambda f, a=a, do=do: (a, a + 1 + int(f // do), a + 1 + int(f % do)))
            # ---- global degree 4 (first round only; anchor pair a < b < i < j), budgeted
            if rnd == 0 and self.K >= 4 and db >= 4:
                m = min(n, int(self.share_four * GD / (math.comb(db, 2) * (2 * db * db / 2 * (k + 1)) + 1)))
                if m >= 64:
                    Bm = B[:m]; Rm = Rw[:m]; t = thr(math.comb(db, 4))
                    for a, b in itertools.combinations(range(db - 2), 2):
                        if grp[a] == grp[b] or b >= db - 2:
                            continue
                        Bo = Bm[:, b + 1:]; Bab = Bo * (Bm[:, a] * Bm[:, b])[:, None]; do = Bo.shape[1]
                        Mm = Bab.T @ Bo / m; T4 = np.zeros((do, do))
                        for q in range(k):
                            M = (Bab * Rm[:, q:q + 1]).T @ Bo / m; T4 += M * M
                        fl[0] += 2 * m * do * do * (k + 1) + 2 * m * do * (k + 1)
                        T4 *= m / np.maximum(1 - Mm ** 2, self.vfloor)
                        go = grp[b + 1:]
                        val = (np.triu(np.ones((do, do), bool), 1) & (go[:, None] != go[None, :])
                               & (go[:, None] != grp[a]) & (go[None, :] != grp[a]) & (go[:, None] != grp[b]) & (go[None, :] != grp[b]))
                        offer_mat(T4, val, t, lambda f, a=a, b=b, do=do: (a, b, b + 1 + int(f // do), b + 1 + int(f % do)))
            # ---- extensions of the strongest current characters by one or two bits
            pw = st["p"]
            wn = np.sqrt(np.sum(W[:pw] ** 2, 1))
            base = sorted([(wn[i], f[1]) for i, f in enumerate(feats) if f[0] == "chi"], key=lambda z: -z[0])
            base = [S for _, S in base][: self.max_ext_bases]
            if base:
                nbs = len(base); t1 = thr(nbs * db)
                m = min(n, int(self.share_ext2 * GD / (nbs * 2 * db * db * (k + 1) + 1)))
                t2 = thr(nbs * npair)
                for S in base:
                    chS = np.prod(B[:, list(S)], 1); fl[0] += n * len(S)
                    RS = Rw * chS[:, None]
                    e1 = B.T @ np.hstack([RS, chS[:, None]]) / n; fl[0] += 2 * n * db * (k + 1)
                    TE = n * np.sum(e1[:, :k] ** 2, 1) / np.maximum(1 - e1[:, k] ** 2, self.vfloor)
                    gS = set(int(grp[i]) for i in S)
                    for j in np.flatnonzero(TE > t1):
                        if int(grp[j]) not in gS:
                            offer(tuple(sorted(S + (int(j),))), TE[j], t1)
                    if m >= 64:
                        Bm = B[:m]; BS = Bm * chS[:m, None]; Mm = BS.T @ Bm / m; TT = np.zeros((db, db))
                        for q in range(k):
                            M = (BS * Rw[:m, q:q + 1]).T @ Bm / m; TT += M * M
                        fl[0] += 2 * m * db * db * (k + 1) + m * db * (k + 1)
                        TT *= m / np.maximum(1 - Mm ** 2, self.vfloor)
                        okg = ~np.isin(grp, list(gS))
                        val = iu & okg[:, None] & okg[None, :]
                        offer_mat(TT, val, t2, lambda f, S=S: tuple(sorted(S + (int(f // db), int(f % db)))))
            # ---- local: every subset of the bits V of the strongest characters (Walsh transform on V)
            V = []
            for S in base:
                if len(set(V) | set(S)) <= self.local_max:
                    V = sorted(set(V) | set(S))
            Lv = len(V)
            if Lv >= 2:
                code = (B[:, V] < 0).astype(np.int64) @ (1 << np.arange(Lv)); fl[0] += 2 * n * Lv
                H = np.stack([np.bincount(code, weights=Rw[:, q], minlength=1 << Lv) for q in range(k)]
                             + [np.bincount(code, minlength=1 << Lv).astype(float)])
                H = _fwht(H) / n; fl[0] += n * (k + 1) + (k + 1) * Lv * (1 << Lv)
                masks = np.arange(1 << Lv); deg = np.array([bin(x).count("1") for x in masks])
                Tl = n * np.sum(H[:k] ** 2, 0) / np.maximum(1 - H[k] ** 2, self.vfloor)
                tl = {dg: thr(math.comb(Lv, dg)) for dg in range(2, Lv + 1)}
                for mk in np.flatnonzero(deg >= 2):
                    if Tl[mk] > tl[deg[mk]]:
                        S = tuple(V[q] for q in range(Lv) if mk >> q & 1)
                        if len(set(int(grp[i]) for i in S)) == len(S):
                            offer(S, Tl[mk], tl[deg[mk]])
            # ---- blocks
            blk = []
            lin_b = [i for i in range(db) if (i,) not in have and not any(cv[1] == (i,) for cv in cand.values())]
            lin_z = [j for j in range(dz) if ("z", j) not in have]
            room = cap - st["p"]
            for kind, idx, Mt in (("zlin", lin_z, Z), ("blin", lin_b, B)):
                if not idx:
                    continue
                cz = Mt[:, idx].T @ Rw / n; fl[0] += 2 * n * len(idx) * k
                Tb = n * float(np.sum(cz ** 2)); kk = len(idx) * k; tt = math.log(1 / self.delta)
                if Tb > kk + 2 * math.sqrt(kk * tt) + 2 * tt and len(idx) <= room:
                    blk.append((kind, idx)); room -= len(idx)
            if self.spectral and du >= 2:
                m = min(n, int((self.share_spec * GD - 20 * du ** 3 * k) / (4 * du * du * k + 1)))
                if m >= 2 * du:
                    Um = U[:m]; Rm = Rw[:m]; Rp = Rm[rng.permutation(m)]; qd = []; edge = 0.0
                    for q in range(k):
                        M0 = (Um * Rp[:, q:q + 1]).T @ Um / m; edge = max(edge, float(np.max(np.abs(np.linalg.eigvalsh(M0)))))
                        M = (Um * Rm[:, q:q + 1]).T @ Um / m; lam, Ev = np.linalg.eigh(M)
                        for j in range(du):
                            qd.append((abs(lam[j]), Ev[:, j].copy()))
                    fl[0] += 4 * m * du * du * k + 20 * du ** 3 * k
                    qd = [(a, u) for a, u in qd if a > 1.1 * edge]
                    qd = sorted(qd, key=lambda z: -z[0])[: self.max_quad * k]
                    if qd and len(qd) <= room:
                        blk.append(("quad", [u for _, u in qd])); room -= len(qd)
            new = sorted(cand.values(), key=lambda z: -z[0])[: max(0, min(self.max_new, room))]
            if not new and not blk:
                break
            cols, descs = [], []
            for _, S in new:
                cols.append(np.prod(B[:, list(S)], 1)); descs.append(("chi", S)); fl[0] += n * len(S)
            for kind, obj in blk:
                if kind == "zlin":
                    for j in obj:
                        cols.append(Z[:, j]); descs.append(("z", j))
                elif kind == "blin":
                    for i in obj:
                        cols.append(B[:, i]); descs.append(("chi", (i,)))
                else:
                    for u in obj:
                        v = (U @ u) ** 2; mu = float(v.mean()); sd = float(v.std()) + 1e-12
                        cols.append((v - mu) / sd); descs.append(("quad", u, mu, sd)); fl[0] += 2 * n * du
            add(np.stack(cols, 1), descs)
            info["log"].append(dict(round=rnd, k=k, n_chi=len(new), blocks=[b[0] for b in blk], p=st["p"],
                                    degs=np.bincount([len(S) for _, S in new], minlength=5).tolist() if new else []))
            W, R = lsfit(); last = fl[0] - f0
        # ---- readout: ridge LS on [grown features, linear background], LOO ridge; then softmax / logistic refinement
        p = st["p"]
        bgb = [i for i in range(db) if (i,) not in have]; bgz = [j for j in range(dz) if ("z", j) not in have]
        descs = list(feats[1:]) + [("chi", (i,)) for i in bgb] + [("z", j) for j in bgz]
        F = np.hstack([A[:, 1:p], B[:, bgb], Z[:, bgz]]) if len(descs) else np.zeros((n, 0))
        del A, G
        out = self._readout(F, Y, y, C, fl, rng)
        info.update(p=len(descs), rounds=len(info["log"]), **out["info"])
        mu, Wf, b0, kind = out["mu"], out["W"], out["b"], out["kind"]

        def featurize(Xn):
            Xn = np.asarray(Xn, dtype=np.float64); Bn = enc.bits(Xn); Zn = enc.z(Xn)
            Un = np.hstack([Zn, Bn[:, enc.nonc]]); cs = []
            for dsc in descs:
                if dsc[0] == "chi":
                    cs.append(np.prod(Bn[:, list(dsc[1])], 1))
                elif dsc[0] == "z":
                    cs.append(Zn[:, dsc[1]])
                else:
                    cs.append(((Un @ dsc[1]) ** 2 - dsc[2]) / dsc[3])
            return np.stack(cs, 1) if cs else np.zeros((len(Xn), 0))

        def predict(Xn):
            S = (featurize(Xn) - mu) @ Wf + b0
            if S.shape[1] == 1:
                return (S[:, 0] > 0).astype(int)
            return np.argmax(S, 1)

        info["flops_frac"] = fl[0] / GD
        return dict(predict=predict, flops=fl[0], info=info)

    def _readout_cost(self, n, P, C):
        Cy = 1 if C == 2 else C
        if P > n or n < 200 or self.readout != "softmax":
            return 2 * n * n * P + 10 * n ** 3 + 40 * n * n * Cy if P > n else 4 * n * P * P + 10 * P ** 3 + 40 * n * P * (Cy + 1)
        nt = 0.8 * n; it = self.iters
        return (4 * n * P * P + 10 * P ** 3 + 40 * n * P * (Cy + 1) + 2 * nt * P * P + 10 * P ** 3
                + (len(self.logit_facs) * nt + n) * it * 4 * P * Cy + (len(self.logit_facs) + 1) * it * 4 * P * P * Cy)

    # ------------------------------------------------------------------------------------------------------------------
    def _ridge_loo(self, Fc, Yc, fl, ycls, binary):
        """Exact LOO for ridge on centred Fc over a grid of ridges; returns the eigen-basis and the chosen ridge."""
        n, P = Fc.shape; Cy = Yc.shape[1]
        if P <= n:
            Gc = Fc.T @ Fc; lam, V = np.linalg.eigh(Gc); lam = np.maximum(lam, 0); Pm = Fc @ V
            PY = Pm.T @ Yc; P2 = Pm * Pm
            fl[0] += 2 * n * P * P + 10 * P ** 3 + 2 * n * P * P + 2 * n * P * Cy + n * P
            dual = False
        else:
            Kc = Fc @ Fc.T; lam, V = np.linalg.eigh(Kc); lam = np.maximum(lam, 0); Pm = V
            PY = V.T @ Yc; P2 = V * V; c0 = int(np.argmax(np.abs(V.sum(0))))
            fl[0] += 2 * n * n * P + 10 * n ** 3 + 2 * n * n * Cy + n * n
            dual = True
        scale = max(float(lam.sum()) / max(len(lam), 1), 1e-12)
        best = None
        for e in np.arange(-4, 3.01, 0.5):
            a = scale * 10.0 ** e
            if dual:      # LOO residual = [(K + a)^-1 Yc]_i / [(K + a)^-1]_ii  (stable for small a)
                f = 1.0 / (lam + a); f[c0] = 0.0          # drop the constant direction (unpenalised intercept)
                E = (Pm @ (PY * f[:, None])) / np.maximum(P2 @ f, 1e-300)[:, None]
            else:
                f = 1.0 / (lam + a); Yh = Pm @ (PY * f[:, None]); h = np.minimum(P2 @ f + 1.0 / n, 1 - 1e-6)
                E = (Yc - Yh) / (1 - h)[:, None]
            fl[0] += 2 * n * len(lam) * Cy + 2 * n * len(lam)
            Yl = Yc - E
            pl = (Yl[:, 0] > self._b_thr) if binary else np.argmax(Yl, 1)
            err = float(np.mean(pl != ycls)); mse = float(np.mean((Yc - Yl) ** 2))
            if best is None or (err, mse) < best[:2]:
                best = (err, mse, a)
        return dict(lam=lam, V=V, PY=PY, Pm=Pm, dual=dual, a=best[2], loo_err=best[0])

    def _readout(self, F, Y, y, C, fl, rng):
        n, P = F.shape; binary = C == 2
        mu = F.mean(0); Fc = F - mu; ym = Y.mean(0); Yc = Y - ym; fl[0] += 2 * n * P
        self._b_thr = -ym[0] if binary else 0.0
        if P == 0:
            return dict(mu=mu, W=np.zeros((0, Y.shape[1])), b=ym, kind="const", info={})
        e = self._ridge_loo(Fc, Yc, fl, y, binary)
        a = e["a"]
        if e["dual"]:
            Wls = Fc.T @ (e["V"] @ (e["PY"] / (e["lam"] + a)[:, None])); fl[0] += 2 * n * n * Y.shape[1] + 2 * n * P * Y.shape[1]
        else:
            Wls = e["V"] @ (e["PY"] / (e["lam"] + a)[:, None]); fl[0] += 2 * P * P * Y.shape[1]
        info = dict(ridge=a, loo_err=e["loo_err"], dual=e["dual"])
        res = dict(mu=mu, W=Wls, b=ym, kind="ls", info=info)
        if self.readout != "softmax" or e["dual"] or n < 200:
            return res
        # softmax / logistic refinement: choose the penalty (or plain LS) on a 20% hold-out, then refit on all n
        hold = rng.permutation(n) < int(0.2 * n); tr = ~hold
        Ft, Fh = Fc[tr], Fc[hold]; yt, yh = y[tr], y[hold]
        lamt, Vt = np.linalg.eigh(Ft.T @ Ft); lamt = np.maximum(lamt, 0); fl[0] += 2 * tr.sum() * P * P + 10 * P ** 3
        Yt = Yc[tr]; Wt = Vt @ ((Vt.T @ (Ft.T @ Yt)) / (lamt + a * tr.mean())[:, None]); fl[0] += 2 * tr.sum() * P * Y.shape[1] + 4 * P * P * Y.shape[1]
        Sh = Fh @ Wt + ym; fl[0] += 2 * hold.sum() * P * Y.shape[1]
        ls_err = float(np.mean(((Sh[:, 0] > 0).astype(int) if binary else np.argmax(Sh, 1)) != yh))
        best = (ls_err, None)
        nt = int(tr.sum())
        for lfac in self.logit_facs:
            lam_pen = lfac * a / n
            Wsm, bsm = self._softmax(Ft, yt, C, lamt, Vt, lam_pen, Wt, fl)
            Sh = Fh @ Wsm + bsm; fl[0] += 2 * hold.sum() * P * Wsm.shape[1]
            er = float(np.mean(((Sh[:, 0] > 0).astype(int) if binary else np.argmax(Sh, 1)) != yh))
            if er < best[0] - 1e-12:
                best = (er, lfac)
        info.update(hold_ls=ls_err, hold_best=best[0], logit_fac=best[1])
        if best[1] is None:
            return res
        Wsm, bsm = self._softmax(Fc, y, C, e["lam"], e["V"], best[1] * a / n, Wls, fl)
        return dict(mu=mu, W=Wsm, b=bsm, kind="softmax", info=info)

    def _softmax(self, Fc, y, C, lam, V, pen, W0, fl):
        """L2-penalised logistic (C = 2, one output) or softmax regression by majorise-minimise with Bohning's bound
        H <= c_b F^T F / n (c_b = 1/4 logistic, 1/2 softmax); the bound's inverse uses the eigenbasis V of F^T F."""
        n, P = Fc.shape; binary = C == 2
        cb = 0.25 if binary else 0.5
        dinv = 1.0 / (cb * lam / n + pen)
        if binary:
            t = y.astype(float)
            W = W0.copy(); b = np.zeros(1)
            S0 = Fc @ W0; fl[0] += 2 * n * P
            # scale the LS direction by a 1-D search on the training log-loss
            best = None
            for sc in (1, 2, 4, 8):
                z = sc * S0[:, 0]; ll = np.mean(np.logaddexp(0, z) - t * z)
                if best is None or ll < best[0]:
                    best = (ll, sc)
            W = W0 * best[1]
            for _ in range(self.iters):
                z = Fc @ W[:, 0] + b[0]; pr = 1 / (1 + np.exp(-z)); g = pr - t
                gW = Fc.T @ g / n + pen * W[:, 0]
                W[:, 0] -= V @ (dinv * (V.T @ gW)); b[0] -= g.mean() / cb
                fl[0] += 4 * n * P + 4 * P * P + 6 * n
            return W, b
        Yo = np.eye(C)[y]
        S0 = Fc @ W0; fl[0] += 2 * n * P * C
        best = None
        for sc in (1, 2, 4, 8, 16):
            z = sc * S0; z = z - z.max(1, keepdims=True); ll = np.mean(np.log(np.exp(z).sum(1)) - (z * Yo).sum(1))
            if best is None or ll < best[0]:
                best = (ll, sc)
        W = W0 * best[1]; b = np.zeros(C)
        for _ in range(self.iters):
            z = Fc @ W + b; z -= z.max(1, keepdims=True); pz = np.exp(z); pz /= pz.sum(1, keepdims=True)
            g = pz - Yo; gW = Fc.T @ g / n + pen * W
            W -= V @ (dinv[:, None] * (V.T @ gW)); b -= g.mean(0) / cb
            fl[0] += 4 * n * P * C + 4 * P * P * C + 6 * n * C
        return W, b
