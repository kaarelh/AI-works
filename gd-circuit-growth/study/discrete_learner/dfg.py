"""DFG: discrete feature growth.  A discrete learner built from what the networks were seen to do.

What gradient descent does on these targets (Parts 1-5 of the study): it grows features greedily, cheapest first; a
feature's cost is set by how hard its correlation with the *residual* is to detect against the noise of the other
directions it could have grown; features on the inputs of features it already has are cheaper (composition); a kernel
background (all linear directions at once) is fit from the start; and at every plateau the network computes the sign of a
least-squares fit on the features grown so far.  DFG does the same with exhaustive enumeration and explicit tests:

  repeat (rounds):
    r = y - (least-squares fit of y on the current features);  s = rms(r)
    candidate classes, each with its own count N (a union bound per class):
      global     every character chi_S, |S| <= K, over all d inputs (K = 4 in the first round, 3 after)  N = C(d, |S|)
      extension  S u {j} and S u {j, l} for current features S (any inputs j, l)                       N = #candidates
      local      every S inside V = inputs of the current features, |V| <= 12 (all degrees: junta completion)  N = C(|V|, |S|)
    accept S if |mean(r chi_S)| > c * s * sqrt(2 ln(4 K N / delta) / n)    (the noise of mean(r chi_S) is s / sqrt(n))
    BLOCK moves, for signal spread over many small coefficients that no single test sees:
      linear     all d inputs at once, if n |c_1|^2 / s^2 exceeds the chi^2_d tail at level delta          (halfspaces)
      quadratic  the top eigen-directions u of the residual pair matrix mean(r x x^T) (diagonal removed) whose
                 eigenvalue clears the noise edge 2 s sqrt(d / n); features (u.x)^2 - |u|^2         (e.g. MAJ5 xor MAJ5)
    stop when nothing is accepted, or when the fit already has every training label's sign right
  predict sign(least-squares fit)

The noise level s falls as features are fit, so later (weaker) features become detectable: the 'noise-limited greedy
growth' picture.  The readout is least squares, not the raw coefficients: on MAJ9 at n = 128 this alone takes the test
error from 0.16 to 0.08, because the residual, not the label, sets the estimation noise.

SMALL n.  With few points the union-bound test passes nothing (at n = 16 even a perfect single-input target fails it),
and predicting a constant is worse than a guess.  For n <= 512, four variants are compared by 5-fold cross-validation:
the default; 'forced' (if nothing passes, take the best-scoring global character anyway, at most twice); forced with
c x 0.6; forced with all d linear inputs from the start (the kernel-like background).  The cost is included.

COMPUTE BUDGET.  The exhaustive searches are run on the first m training points, with m set so that each stays within a
fixed fraction of one network run (harness.gd_flops): degree 4 in 25%, degree 3 in 3% per round, the two-input
extensions in 3% per round (thresholds use m).  At d = 30 this never binds (m = n); at d = 60 and 120 it does.  A
parity needs only ~2 ln(N) / rho^2 points to be found, so subsampling the search costs little there.
Compute is counted in FLOPs (multiply-add = 2) and compared with one network run.
"""
import itertools, math, numpy as np
from harness import gd_flops


def _chi(X, S):
    return np.prod(X[:, list(S)], axis=1) if S else np.ones(len(X))


def _fwht(a):
    a = np.array(a, dtype=np.float64); n = a.shape[-1]; h = 1
    while h < n:
        a = a.reshape(-1, 2, h)
        a = np.concatenate([a[:, 0] + a[:, 1], a[:, 0] - a[:, 1]], axis=1).reshape(-1)
        h *= 2
    return a


class DFG:
    def __init__(self, K=4, K_later=3, c=1.0, delta=0.1, rounds=8, max_new=64, max_feats=256, max_ext_bases=32,
                 local_max=12, blocks=True, ridge=1e-3, budget=(0.25, 0.03, 0.03), noise="residual", readout="ls",
                 small_n=True, cv_n=512, name=None):
        self.K, self.K_later, self.c, self.delta, self.rounds = K, K_later, c, delta, rounds
        self.max_new, self.max_feats, self.max_ext_bases, self.local_max = max_new, max_feats, max_ext_bases, local_max
        self.blocks, self.ridge, self.budget, self.noise, self.readout = blocks, ridge, budget, noise, readout
        self.small_n, self.cv_n = small_n, cv_n
        self.name = name or f"dfg-c{c}" + ("" if blocks else "-noblocks")

    def fit(self, X, y, rng=None):
        """At n <= cv_n the fallbacks for small samples are compared by 5-fold cross-validation (see SMALL n)."""
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y, dtype=np.float64); n = len(y)
        variants = [(self.c, False, False), (self.c, True, False), (0.6 * self.c, True, False), (self.c, True, True)]
        if n > self.cv_n or not self.small_n:
            return self._fit(X, y, *variants[0])
        rng = rng if rng is not None else np.random.default_rng(0)
        F = 5; fold = rng.permutation(n) % F; errs, fl = [], 0.0
        for v in variants:
            e = 0
            for f in range(F):
                tr, te = fold != f, fold == f
                o = self._fit(X[tr], y[tr], *v); fl += o["flops"]; e += int(np.sum(o["predict"](X[te]) != y[te]))
            errs.append(e)
        best = min(range(len(variants)), key=lambda i: (errs[i], i))
        out = self._fit(X, y, *variants[best]); out["flops"] += fl
        out["info"].update(variant=best, cv_errs=errs)
        return out

    def _fit(self, X, y, c, force, lin0):
        n, d = X.shape
        fl = [0.0]; GD = gd_flops(d); forced = [0]
        feats = [("chi", ())]; cols = [np.ones(n)]; have = {()}
        info = dict(rounds=0, log=[])

        def lsfit():
            A = np.stack(cols, 1); p = A.shape[1]
            G = A.T @ A + self.ridge * n * np.diag([0.0] + [1.0] * (p - 1)) + 1e-9 * np.eye(p)
            w = np.linalg.solve(G, A.T @ y); fl[0] += 2 * n * p * p + p ** 3 / 3 + 4 * n * p
            return w, y - A @ w

        w, r = lsfit()
        for rnd in range(self.rounds):
            s = math.sqrt(max(np.mean(r * r), 1e-12))
            if s < 1e-6 or (rnd > 0 and np.all(np.sign(y - r) == y)):    # exact fit, or every training sign right
                break
            if self.noise == "label":                                   # ablation: noise taken as that of the labels
                s = 1.0
            thr = lambda N: c * s * math.sqrt(2 * math.log(4 * self.K * max(N, 1) / self.delta) / n)
            thr_m = lambda N, m: thr(N) * math.sqrt(n / m) * (math.sqrt(np.mean(r[:m] ** 2)) / s if m < n else 1.0)
            cand = {}                                                   # S -> (z-score, coefficient)
            top = [0.0, None, 0.0]                                       # best global candidate, passed or not

            def offer(S, v, t):
                if S not in have and abs(v) / t > top[0]:
                    top[:] = [abs(v) / t, S, v]
                if S not in have and abs(v) > t:
                    z = abs(v) / t
                    if S not in cand or cand[S][0] < z:
                        cand[S] = (z, v)

            # ---- global characters of degree <= K on the residual
            K = self.K if rnd == 0 else self.K_later
            c1 = X.T @ r / n; fl[0] += 2 * n * d
            t = thr(d)
            for i in range(d):
                offer((i,), c1[i], t)
            M = (X * r[:, None]).T @ X / n; fl[0] += 2 * n * d * d + n * d
            if K >= 2:
                t = thr(math.comb(d, 2))
                Mu = np.abs(np.triu(M, 1)); q = np.unravel_index(np.argmax(Mu), Mu.shape)
                for i, j in list(zip(*np.where(Mu > t))) + [q]:
                    offer((int(i), int(j)), M[i, j], t)
            if K >= 3:
                m = min(n, max(32, int(self.budget[1] * GD / (d * (2 * d * d + 2 * d)))))
                Xm, rm, tm = X[:m], r[:m], thr_m(math.comb(d, 3), m)
                for a in range(d - 2):
                    Ma = (Xm * (rm * Xm[:, a])[:, None]).T @ Xm / m; fl[0] += 2 * m * d * d + 2 * m * d
                    Ma = np.triu(Ma, 1); Ma[: a + 1] = 0; t = tm
                    q = np.unravel_index(np.argmax(np.abs(Ma)), Ma.shape)
                    for i, j in list(zip(*np.where(np.abs(Ma) > t))) + [q]:
                        if i > a and j > i:
                            offer((a, int(i), int(j)), Ma[i, j], t)
            if K >= 4:
                m = min(n, max(32, int(self.budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d)))))
                Xm, rm, t = X[:m], r[:m], thr_m(math.comb(d, 4), m)
                for a, b in itertools.combinations(range(d), 2):
                    if b >= d - 2:
                        continue
                    Mab = (Xm * (rm * Xm[:, a] * Xm[:, b])[:, None]).T @ Xm / m; fl[0] += 2 * m * d * d + 3 * m * d
                    Mab = np.triu(Mab, 1); Mab[: b + 1] = 0
                    q = np.unravel_index(np.argmax(np.abs(Mab)), Mab.shape)
                    for i, j in list(zip(*np.where(np.abs(Mab) > t))) + [q]:
                        if i > b and j > i:
                            offer((a, b, int(i), int(j)), Mab[i, j], t)
            # ---- extensions of current character features by one or two inputs
            base = [(k, abs(wi)) for (kind, k), wi in zip(feats, w) if kind == "chi" and k]
            base = [k for k, _ in sorted(base, key=lambda kv: -kv[1])][: self.max_ext_bases]
            if base:
                m = min(n, max(32, int(self.budget[2] * GD / (len(base) * (2 * d * d + 3 * d)))))
                Xm = X[:m]; t1, t2 = thr(len(base) * d), thr_m(len(base) * math.comb(d, 2), m)
                for S in base:
                    rs = r * _chi(X, S); fl[0] += n * (len(S) + 1)
                    e1 = X.T @ rs / n; fl[0] += 2 * n * d
                    for j in np.where(np.abs(e1) > t1)[0]:
                        if j not in S:
                            offer(tuple(sorted(S + (int(j),))), e1[j], t1)
                    E2 = np.triu((Xm * rs[:m, None]).T @ Xm / m, 1); fl[0] += 2 * m * d * d + m * d
                    for j, l in zip(*np.where(np.abs(E2) > t2)):
                        if j not in S and l not in S:
                            offer(tuple(sorted(S + (int(j), int(l)))), E2[j, l], t2)
            # ---- local: every subset of the inputs in use (Walsh transform of the residual on V)
            V = sorted(set(v for kind, k in feats if kind == "chi" for v in k))
            if 2 <= len(V) <= self.local_max:
                L = len(V); bits = (X[:, V] < 0).astype(np.int64) @ (1 << np.arange(L)); fl[0] += n * L
                h = _fwht(np.bincount(bits, weights=r, minlength=1 << L)) / n; fl[0] += n + L * (1 << L)
                tl = {k: thr(math.comb(L, k)) for k in range(1, L + 1)}
                for m in np.where(np.abs(h) > min(tl.values()))[0]:
                    if m == 0:
                        continue
                    S = tuple(V[q] for q in range(L) if m >> q & 1)
                    offer(S, h[m], tl[len(S)])
            # ---- block moves
            blk = []
            if self.blocks:
                lin = [i for i in range(d) if (i,) not in have and (i,) not in cand]
                if lin:
                    T1 = n * float(np.sum(c1[lin] ** 2)) / s ** 2; k = len(lin); tt = math.log(1 / self.delta)
                    if T1 > k + 2 * math.sqrt(k * tt) + 2 * tt or (lin0 and rnd == 0):
                        blk.append(("linear", lin))
                Ms = (M + M.T) / 2; np.fill_diagonal(Ms, 0.0)
                for S in list(have) + list(cand):
                    if len(S) == 2:
                        Ms[S[0], S[1]] = Ms[S[1], S[0]] = 0.0
                lam, U = np.linalg.eigh(Ms); fl[0] += 10 * d ** 3
                edge = 2 * s * math.sqrt(d / n) * (1 + math.sqrt(2 * math.log(1 / self.delta) / d))
                qs = [q for q in np.argsort(-np.abs(lam)) if abs(lam[q]) > edge][:4]
                if qs:
                    blk.append(("quad", [U[:, q].copy() for q in qs]))
            new = sorted(cand.items(), key=lambda kv: -kv[1][0])[: self.max_new]
            if force and not new and not blk and forced[0] < 2 and top[1] is not None:
                new = [(top[1], (top[0], top[2]))]; forced[0] += 1       # nothing passed: take the best guess
            room = self.max_feats - len(feats)
            if (not new and not blk) or room <= 0:
                break
            for S, _ in new[:room]:
                feats.append(("chi", S)); cols.append(_chi(X, S)); have.add(S); fl[0] += n * len(S)
            for kind, obj in blk:
                if kind == "linear":
                    for i in obj:
                        if (i,) not in have:
                            feats.append(("chi", (i,))); cols.append(X[:, i].copy()); have.add((i,))
                else:
                    for u in obj:
                        feats.append(("quad", u)); cols.append((X @ u) ** 2 - u @ u); fl[0] += 2 * n * d
            info["log"].append(dict(round=rnd, s=round(s, 4), new=[S for S, _ in new[:room]][:20], n_new=len(new[:room]),
                                    blocks=[k for k, _ in blk]))
            w, r = lsfit(); info["rounds"] = rnd + 1
        F, W = list(feats), np.array(w)
        if self.readout == "coef":                                      # ablation: raw coefficients, no least squares
            W = np.array([float(np.mean(y * cl) / max(np.mean(cl * cl), 1e-12)) for cl in cols])

        def value(Z):
            Z = np.asarray(Z, dtype=np.float64); f = np.zeros(len(Z))
            for (kind, k), wi in zip(F, W):
                f += wi * (_chi(Z, k) if kind == "chi" else (Z @ k) ** 2 - k @ k)
            return f

        info["size"] = len(F); info["train_err"] = float(np.mean(np.where(value(X) > 0, 1, -1) != y))
        return dict(predict=lambda Z: np.where(value(Z) > 0, 1.0, -1.0), flops=fl[0], info=info)
