"""DFG: discrete feature growth.  A discrete learner built from what the networks were seen to do.

What gradient descent does on these targets (Parts 1-5 of the study): it grows features greedily, cheapest first; a
feature's cost is set by how hard its correlation with the residual is to detect against the noise of the other
directions it could have grown; features on the inputs of features it already has are cheaper (composition); and at
every plateau the network computes (the sign of) a truncated Fourier expansion of the target.  DFG does the same
things with exhaustive enumeration and explicit tests in place of the noisy continuous search:

  1. GLOBAL search.  Empirical Fourier coefficients c_S = mean(y chi_S) of every character of degree <= K over all d
     inputs (K = 4; matrix products, 2 n d^2 C(d, k-2) FLOPs for degree k).  S is kept if
         |c_S| > c * sqrt(2 ln(N / delta) / n),      N = K * C(d, |S|)
     (a union bound over the characters of that degree: the noise in c_S is 1/sqrt(n) for +-1 labels).
  2. COMPOSITION search, repeated while it finds something: with V = the inputs of the kept features,
       local:     every S inside V of degree up to L (all degrees while the count stays <= 4096), N = 4 * L * C(|V|, |S|);
       extension: S u {j} and S u {j, l} for kept S and any inputs j, l,                    N = 4 * (number of them).
     Because the candidate sets are small, the thresholds are lower: a term on inputs the learner already uses is
     cheaper to find, as for the networks.  With L = |V| this includes junta completion (the full table on V).
  3. DENSE spectral move (optional).  The pair coefficients not kept in 1-2 form a d x d matrix; its eigenvalues above
     the noise edge 2 sqrt(d / n) (with the usual shrinkage of a spiked eigenvalue) give a low-rank quadratic feature
     x^T P x / 2.  This aggregates many small pair coefficients (e.g. MAJ5 xor MAJ5: 25 pairs of 0.14) that no
     entrywise test can see; it is the discrete analogue of a network growing one direction from a sum of weak ones.
     A degree-1 'dense' option keeps every degree-1 coefficient (Hebbian), for halfspaces with many small weights.
  4. READOUT: sign( c_0 + sum_kept c_S chi_S [+ spectral feature] ), the sign of the truncated expansion.
  5. MODEL SELECTION: the multiplier c, the dense options, and the readout are chosen by F-fold cross-validation on
     the training set (F = 5).  Coefficients are accumulated per fold, so CV adds almost no compute.

Compute is counted in FLOPs (multiply-add = 2) and compared with one network run (harness.gd_flops).
"""
import itertools, math, numpy as np


def _chi(X, S):
    return np.prod(X[:, list(S)], axis=1) if S else np.ones(len(X))


class DFG:
    def __init__(self, K=4, F=5, cgrid=(0.35, 0.5, 0.7, 1.0), delta=0.1, dense=True, max_feats=400, rounds=3,
                 local_cap=4096, name=None):
        self.K, self.F, self.cgrid, self.delta, self.dense = K, F, tuple(cgrid), delta, dense
        self.max_feats, self.rounds, self.local_cap = max_feats, rounds, local_cap
        self.name = name or f"dfg-K{K}" + ("" if dense else "-sparse")

    # ------------------------------------------------------------------ coefficient tables, accumulated per fold
    def _tables(self, X, y, fold):
        n, d = X.shape; F = self.F; fl = 0.0
        idx = [np.where(fold == f)[0] for f in range(F)]
        T = {}
        part = lambda A: np.stack([A[i].sum(0) for i in idx])          # per-fold sums of the rows of A
        T[1] = part(X * y[:, None]); fl += 2 * n * d                      # (F, d)
        if self.K >= 2:
            M = np.stack([(X[i] * y[i, None]).T @ X[i] for i in idx]); fl += 2 * n * d * d + n * d
            T[2] = M                                                    # (F, d, d)
        if self.K >= 3:
            C3 = np.zeros((F, d, d, d))
            for a in range(d):
                W = X * (y * X[:, a])[:, None]
                for f, i in enumerate(idx):
                    C3[f, a] = W[i].T @ X[i]
            fl += d * (2 * n * d * d + 2 * n * d); T[3] = C3
        if self.K >= 4:
            C4 = {}
            for a, b in itertools.combinations(range(d), 2):
                W = X * (y * X[:, a] * X[:, b])[:, None]
                C4[(a, b)] = np.stack([W[i].T @ X[i] for i in idx])     # (F, d, d), entries (c, e) with b < c < e used
            fl += math.comb(d, 2) * (2 * n * d * d + 3 * n * d); T[4] = C4
        return T, idx, fl

    def _lookup(self, T, S):
        """per-fold partial sums (F,) of y chi_S for |S| <= K from the tables."""
        k = len(S)
        if k == 1:
            return T[1][:, S[0]]
        if k == 2:
            return T[2][:, S[0], S[1]]
        if k == 3:
            return T[3][:, S[0], S[1], S[2]]
        return T[4][(S[0], S[1])][:, S[2], S[3]]

    # ------------------------------------------------------------------ one selection run on a training subset
    def _select(self, ctx, c, train_mask, dense1, spectral):
        """train_mask: boolean (F,), the folds used for training.  Returns (features dict S -> coef, quad matrix or None)."""
        X, d, n_f, K = ctx["X"], ctx["d"], ctx["n_f"], self.K
        ntr = float(n_f[train_mask].sum())
        if ntr < 2:
            return {(): 0.0}, None
        coef = lambda S: float(self._partial(ctx, S)[train_mask].sum() / ntr)
        thr = lambda N: c * math.sqrt(2 * math.log(max(N, 1) / self.delta) / ntr)
        kept = {}
        G = ctx["glob"]                                            # list per degree: (tuples, partial sums (F, N))
        for k in range(1, K + 1):
            tups, Pk = G[k]
            ck = Pk[train_mask].sum(0) / ntr
            t = 0.0 if (k == 1 and dense1) else thr(K * math.comb(d, k))
            for j in np.where(np.abs(ck) > t)[0]:
                kept[tups[j]] = float(ck[j])
        kept = self._cap(kept)
        for _ in range(self.rounds):
            V = sorted(set(v for S in kept for v in S))
            new = {}
            # local: subsets of V
            if V:
                Ls, tot = [], 0
                for k in range(1, len(V) + 1):
                    tot += math.comb(len(V), k)
                    if tot > self.local_cap:
                        break
                    Ls.append(k)
                L = len(Ls)
                for k in Ls:
                    t = thr(4 * L * math.comb(len(V), k))
                    for S in itertools.combinations(V, k):
                        if S not in kept:
                            v = coef(S)
                            if abs(v) > t:
                                new[S] = v
            # extensions of kept features by one or two inputs
            base = [S for S in kept if S]
            if base:
                ext1 = set(); ext2 = set()
                for S in base:
                    rest = [j for j in range(d) if j not in S]
                    for j in rest:
                        ext1.add(tuple(sorted(S + (j,))))
                    if len(base) * len(rest) ** 2 / 2 <= 20000:
                        for j, l in itertools.combinations(rest, 2):
                            ext2.add(tuple(sorted(S + (j, l))))
                for E in (ext1, ext2):
                    t = thr(4 * max(len(E), 1))
                    for S in E:
                        if S not in kept and S not in new:
                            v = coef(S)
                            if abs(v) > t:
                                new[S] = v
            if not new:
                break
            kept.update(new); kept = self._cap(kept)
        kept[()] = float(ctx["T0"][train_mask].sum() / ntr)
        Q = None
        if spectral:
            M = ctx["T"][2][train_mask].sum(0) / ntr
            M = (M + M.T) / 2; np.fill_diagonal(M, 0.0)
            for S in kept:
                if len(S) == 2:
                    M[S[0], S[1]] = M[S[1], S[0]] = 0.0
            lam, U = np.linalg.eigh(M)
            edge = 2 * math.sqrt(d / ntr) * 1.15
            P = np.zeros((d, d))
            for q in np.where(np.abs(lam) > edge)[0]:
                l = lam[q]; lt = (l + math.copysign(math.sqrt(max(l * l - edge * edge, 0.0)), l)) / 2
                P += lt * np.outer(U[:, q], U[:, q])
            if np.any(P):
                Q = P
        return kept, Q

    def _cap(self, kept):
        if len(kept) <= self.max_feats:
            return kept
        top = sorted(kept.items(), key=lambda kv: -abs(kv[1]))[: self.max_feats]
        return dict(top)

    def _partial(self, ctx, S):
        cache = ctx["cache"]
        if S in cache:
            return cache[S]
        if len(S) <= self.K:
            p = self._lookup(ctx["T"], S)
        else:
            z = ctx["y"] * _chi(ctx["X"], S); ctx["flops"][0] += 2 * ctx["n"] * len(S)
            p = np.array([z[i].sum() for i in ctx["idx"]])
        cache[S] = p
        return p

    @staticmethod
    def _value(X, kept, Q):
        f = np.zeros(len(X))
        for S, v in kept.items():
            f += v * _chi(X, S)
        if Q is not None:
            f += 0.5 * np.einsum("ni,ij,nj->n", X, Q, X) - 0.5 * np.trace(Q)
        return f

    # ------------------------------------------------------------------ fit
    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y, dtype=np.float64); n, d = X.shape
        F = self.F if n >= 2 * self.F else 2
        self_F = self.F; self.F = F
        fold = rng.permutation(n) % F
        T, idx, fl = self._tables(X, y, fold)
        n_f = np.array([len(i) for i in idx], dtype=float)
        glob = {}
        for k in range(1, self.K + 1):
            tups = list(itertools.combinations(range(d), k))
            if k == 1:
                P = T[1]
            elif k == 2:
                a, b = np.triu_indices(d, 1); P = T[2][:, a, b]
            elif k == 3:
                tt = np.array(tups); P = T[3][:, tt[:, 0], tt[:, 1], tt[:, 2]]
            else:
                P = np.stack([T[4][(S[0], S[1])][:, S[2], S[3]] for S in tups], 1)
            glob[k] = (tups, P)
        ctx = dict(X=X, y=y, n=n, d=d, idx=idx, n_f=n_f, T=T, glob=glob, cache={}, flops=[fl],
                   T0=np.array([y[i].sum() for i in idx]))
        configs = [(c, d1, sp) for c in self.cgrid for d1 in ((False, True) if self.dense else (False,))
                   for sp in ((False, True) if self.dense else (False,))]
        cv = []
        for cfg in configs:
            wrong = 0.0
            for f in range(F):
                mask = np.ones(F, bool); mask[f] = False
                kept, Q = self._select(ctx, cfg[0], mask, cfg[1], cfg[2])
                Xf = X[idx[f]]; pred = np.where(self._value(Xf, kept, Q) > 0, 1.0, -1.0)
                ctx["flops"][0] += 2 * len(Xf) * (sum(max(len(S), 1) for S in kept) + (2 * d * d if Q is not None else 0))
                wrong += float(np.sum(pred != y[idx[f]]))
            cv.append(wrong / n)
        best = min(range(len(cv)), key=lambda i: (cv[i], -configs[i][0], configs[i][1], configs[i][2]))  # ties -> sparser
        cfg = configs[best]
        kept, Q = self._select(ctx, cfg[0], np.ones(F, bool), cfg[1], cfg[2])
        self.F = self_F
        flops = ctx["flops"][0]

        def predict(Z):
            return np.where(self._value(np.asarray(Z, dtype=np.float64), kept, Q) > 0, 1.0, -1.0)

        return dict(predict=predict, flops=flops,
                    info=dict(c=cfg[0], dense1=cfg[1], spectral=cfg[2], size=len(kept), cv=min(cv),
                              rank=0 if Q is None else int(np.linalg.matrix_rank(Q, 1e-9))))
