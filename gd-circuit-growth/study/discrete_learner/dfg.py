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
                 and in the first round degrees 5 and 6 on a subsample whose size the compute budget sets
      extension  S u {j} and S u {j, l} for current features S (any inputs j, l)                       N = #candidates
      local      every S inside V = inputs of the current features, |V| <= 12 (all degrees: junta completion)  N = C(|V|, |S|)
    accept S if |mean(r chi_S)| > c * s * sqrt(2 ln(4 K N / delta) / n)    (the noise of mean(r chi_S) is s / sqrt(n))
    BLOCK moves, for signal spread over many small coefficients that no single test sees:
      linear     all d inputs at once, if n |c_1|^2 / s^2 exceeds the chi^2_d tail at level delta          (halfspaces)
      quadratic  the top eigen-directions u of the residual pair matrix mean(r x x^T) (diagonal removed) whose
                 eigenvalue clears the noise edge 2 s sqrt(d / n) (a Wigner edge, so only for n >= 4 d);
                 features (u.x)^2 - |u|^2                                                          (e.g. MAJ5 xor MAJ5)
    stop when nothing is accepted, or when the fit already has every training label's sign right
  predict sign(least-squares fit + kernel background, below)
  v1.1 (readout="logit", added after the held-out evaluation of v1): the least-squares weights are refined by 15 Newton
  steps of L2-regularised logistic regression (lambda = 1e-4) when n >= 8 p.  Square loss is the wrong readout for
  halfspaces: sign(LS) of a dense threshold function stays a few % off, and the logistic fit tends to the max-margin
  separator in the grown features.

The noise level s falls as features are fit, so later (weaker) features become detectable: the 'noise-limited greedy
growth' picture.  The readout is least squares, not the raw coefficients: on MAJ9 at n = 128 this alone takes the test
error from 0.16 to 0.08, because the residual, not the label, sets the estimation noise.

SMALL n.  Two things keep DFG at least as good as the networks when n is tiny.  (i) A kernel background: the final
predictor adds sum_i mean(r x_i) x_i, one Hebbian step on the residual over all d inputs (the networks' near-kernel
part).  With no features this is the Hebbian classifier; once the features fit, it is ~0.  Least squares is kept to
p <= n / 2 features (the linear block only if it fits), so it never sits at its interpolation peak.  (ii) With few
points the union-bound test passes nothing (at n = 16 even a perfect single-input target fails it).  For n <= 512 a
'forced' variant (if nothing passes, take the best-scoring global character anyway, at most twice) is compared with the
default by cross-validation (10-fold for n <= 64, else 5-fold; forced is taken only if it is right on more held-out
points than the default by over 2 sqrt(#points where they differ), a paired McNemar test; the folds skip the degree-5/6 search, the final fit does
it).  The cost of the cross-validation is included.

COMPUTE BUDGET.  The exhaustive searches are run on the first m training points, with m set so that each stays within a
fixed fraction of one network run (harness.gd_flops): degree 4 in 15% (25% in the frozen v1), degree 3 in 3% per round, the two-input
extensions in 3% per round, degrees 5 and 6 (first round) in 3% each (thresholds use m).  At d = 30 this binds only
for degrees 5 and 6 (m ~ 1400 and ~150); at d = 60 and 120 it binds for degree 4 too.  A parity needs only
~2 ln(N) / rho^2 points to be found, so subsampling the search costs little there.
A search whose m would fall below 32 is skipped.  With the small-n cross-validation the final fit gets half of the
budget and the 2F fold fits share the other half (v1.1; in v1 every fold fit had the whole budget, which at d = 120 cost
up to 2.7 network runs per fit).  A round starts only while the fit has spent less than 0.75 of its budget.
Compute is counted in FLOPs (multiply-add = 2) and compared with one network run.
"""
import itertools, math, numpy as np
from harness import gd_flops


def _chi(X, S):
    return np.prod(X[:, list(S)], axis=1) if S else np.ones(len(X))


def _table(X, d, k):
    T = list(itertools.combinations(range(d), k)); I = np.array(T)
    Z = np.ones((len(X), len(T)))
    for q in range(k):
        Z *= X[:, I[:, q]]
    return T, Z


def m_tab_cost(d, k1, k2):
    return math.comb(d, k1) * k1 + math.comb(d, k2) * k2


def _fwht(a):
    a = np.array(a, dtype=np.float64); n = a.shape[-1]; h = 1
    while h < n:
        a = a.reshape(-1, 2, h)
        a = np.concatenate([a[:, 0] + a[:, 1], a[:, 0] - a[:, 1]], axis=1).reshape(-1)
        h *= 2
    return a


class DFG:
    def __init__(self, K=4, K_later=3, c=1.0, delta=0.1, rounds=8, max_new=64, max_feats=256, max_ext_bases=32,
                 local_max=12, blocks=True, ridge=1e-3, budget=(0.15, 0.03, 0.03), noise="residual", readout="ls",
                 small_n=True, cv_n=512, K_hi=6, budget_hi=0.03, background=True, logit_lam=1e-4, name=None):
        self.K, self.K_later, self.c, self.delta, self.rounds = K, K_later, c, delta, rounds
        self.max_new, self.max_feats, self.max_ext_bases, self.local_max = max_new, max_feats, max_ext_bases, local_max
        self.blocks, self.ridge, self.budget, self.noise, self.readout = blocks, ridge, budget, noise, readout
        self.small_n, self.cv_n, self.K_hi, self.budget_hi, self.background = small_n, cv_n, K_hi, budget_hi, background
        self.logit_lam = logit_lam
        self.name = name or (f"dfg-c{c}" if readout != "logit" else "dfg-v1.1")

    def fit(self, X, y, rng=None):
        """At n <= cv_n the fallbacks for small samples are compared by 5-fold cross-validation (see SMALL n)."""
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y, dtype=np.float64); n = len(y)
        R = self.ridge
        variants = [(self.c, False, False, R), (self.c, True, False, R)]
        F = 10 if n <= 64 else 5
        # the budget is shared: the final fit gets half, the 2F fold fits the other half
        run = lambda v, A, b, hi=False, sc=1.0: self._hebb(A, b) if v == "hebb" else self._fit(A, b, *v, hi=hi, scale=sc)
        if n > self.cv_n or not self.small_n:
            out = self._fit(X, y, *variants[0]); out["info"].update(variant=0); return out
        rng = rng if rng is not None else np.random.default_rng(0)
        fold = rng.permutation(n) % F; wrong, fl = [], 0.0
        for v in variants:
            e = np.zeros(n, bool)
            for f in range(F):
                tr, te = fold != f, fold == f
                o = run(v, X[tr], y[tr], False, 1 / (4 * F)); fl += o["flops"]; e[te] = o["predict"](X[te]) != y[te]
            wrong.append(e)
        b, c_ = int(np.sum(wrong[0] & ~wrong[1])), int(np.sum(~wrong[0] & wrong[1]))
        best = 1 if b - c_ > 2 * math.sqrt(b + c_) else 0              # forced only if it wins a paired (McNemar) test
        errs = [int(w.sum()) for w in wrong]
        out = run(variants[best], X, y, True, 0.5); out["flops"] += fl
        out["info"].update(variant=best, cv_errs=errs)
        return out

    @staticmethod
    def _hebb(X, y):
        """The kernel-like background alone: sign(mean(y) + sum_i mean(y x_i) x_i)."""
        n, d = X.shape; w = X.T @ y / n; b = float(y.mean())
        return dict(predict=lambda Z: np.where(np.asarray(Z, dtype=np.float64) @ w + b > 0, 1.0, -1.0), flops=2.0 * n * d,
                    info=dict(size=d + 1, rounds=0, log=[]))

    def _fit(self, X, y, c, force, lin0, ridge, hi=True, scale=1.0):
        n, d = X.shape
        fl = [0.0]; GD = gd_flops(d) * scale; forced = [0]
        feats = [("chi", ())]; cols = [np.ones(n)]; have = {()}
        info = dict(rounds=0, log=[])

        def lsfit():
            A = np.stack(cols, 1); p = A.shape[1]
            G = A.T @ A + ridge * n * np.diag([0.0] + [1.0] * (p - 1)) + 1e-9 * np.eye(p)
            w = np.linalg.solve(G, A.T @ y); fl[0] += 2 * n * p * p + p ** 3 / 3 + 4 * n * p
            return w, y - A @ w

        w, r = lsfit()
        for rnd in range(self.rounds):
            s = math.sqrt(max(np.mean(r * r), 1e-12))
            if s < 1e-6 or (rnd > 0 and np.all(np.sign(y - r) == y)):    # exact fit, or every training sign right
                break
            if fl[0] > 0.75 * GD:                                        # hard cap: stay within one network run
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
                m = min(n, int(self.budget[1] * GD / (d * (2 * d * d + 2 * d))))
                Xm, rm, tm = X[:m], r[:m], thr_m(math.comb(d, 3), max(m, 1))
                for a in range(d - 2 if m >= 32 else 0):
                    Ma = (Xm * (rm * Xm[:, a])[:, None]).T @ Xm / m; fl[0] += 2 * m * d * d + 2 * m * d
                    Ma = np.triu(Ma, 1); Ma[: a + 1] = 0; t = tm
                    q = np.unravel_index(np.argmax(np.abs(Ma)), Ma.shape)
                    for i, j in list(zip(*np.where(np.abs(Ma) > t))) + [q]:
                        if i > a and j > i:
                            offer((a, int(i), int(j)), Ma[i, j], t)
            if K >= 4:
                m = min(n, int(self.budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d))))
                Xm, rm, t = X[:m], r[:m], thr_m(math.comb(d, 4), max(m, 1))
                for a, b in (itertools.combinations(range(d), 2) if m >= 32 else []):
                    if b >= d - 2:
                        continue
                    Mab = (Xm * (rm * Xm[:, a] * Xm[:, b])[:, None]).T @ Xm / m; fl[0] += 2 * m * d * d + 3 * m * d
                    Mab = np.triu(Mab, 1); Mab[: b + 1] = 0
                    q = np.unravel_index(np.argmax(np.abs(Mab)), Mab.shape)
                    for i, j in list(zip(*np.where(np.abs(Mab) > t))) + [q]:
                        if i > b and j > i:
                            offer((a, b, int(i), int(j)), Mab[i, j], t)
            # ---- higher degrees K < k <= K_hi (first round): coefficients of chi_{T1 u T2} for disjoint T1, T2 of degrees
            #      ceil(k/2), floor(k/2), as one product of character tables on the first m points (m set by the budget)
            if rnd == 0 and hi:
                for k in range(self.K + 1, self.K_hi + 1):
                    k1, k2 = (k + 1) // 2, k // 2; N1, N2 = math.comb(d, k1), math.comb(d, k2)
                    m = min(n, int(self.budget_hi * GD / (2 * N1 * N2 + m_tab_cost(d, k1, k2))))
                    if m < 64:
                        continue
                    T1, Z1 = _table(X[:m], d, k1); T2, Z2 = (T1, Z1) if k2 == k1 else _table(X[:m], d, k2)
                    G = (Z1 * r[:m, None]).T @ Z2 / m; fl[0] += 2 * m * N1 * N2 + m * (N1 * k1 + N2 * k2)
                    t = thr_m(math.comb(d, k), m)
                    for p, q in zip(*np.where(np.abs(G) > t)):
                        S = set(T1[p]) | set(T2[q])
                        if len(S) == k:
                            offer(tuple(sorted(S)), G[p, q], t)
            # ---- extensions of current character features by one or two inputs
            base = [(k, abs(wi)) for (kind, k), wi in zip(feats, w) if kind == "chi" and k]
            base = [k for k, _ in sorted(base, key=lambda kv: -kv[1])][: self.max_ext_bases]
            if base:
                m = min(n, int(self.budget[2] * GD / (len(base) * (2 * d * d + 3 * d))))
                Xm = X[:max(m, 1)]; t1, t2 = thr(len(base) * d), thr_m(len(base) * math.comb(d, 2), max(m, 1))
                for S in base:
                    rs = r * _chi(X, S); fl[0] += n * (len(S) + 1)
                    e1 = X.T @ rs / n; fl[0] += 2 * n * d
                    for j in np.where(np.abs(e1) > t1)[0]:
                        if j not in S:
                            offer(tuple(sorted(S + (int(j),))), e1[j], t1)
                    if m < 32:
                        continue
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
                    if (T1 > k + 2 * math.sqrt(k * tt) + 2 * tt or (lin0 and rnd == 0)) and n >= 2 * (len(feats) + k):
                        blk.append(("linear", lin))                       # (else the background carries it)
                Ms = (M + M.T) / 2; np.fill_diagonal(Ms, 0.0)
                for S in list(have) + list(cand):
                    if len(S) == 2:
                        Ms[S[0], S[1]] = Ms[S[1], S[0]] = 0.0
                lam, U = np.linalg.eigh(Ms); fl[0] += 10 * d ** 3
                edge = 2 * s * math.sqrt(d / n) * (1 + math.sqrt(2 * math.log(1 / self.delta) / d))
                qs = [q for q in np.argsort(-np.abs(lam)) if abs(lam[q]) > edge][:4] if n >= 4 * d else []
                if qs:
                    blk.append(("quad", [U[:, q].copy() for q in qs]))
            new = sorted(cand.items(), key=lambda kv: -kv[1][0])[: self.max_new]
            if force and not new and not blk and forced[0] < 2 and top[1] is not None:
                new = [(top[1], (top[0], top[2]))]; forced[0] += 1       # nothing passed: take the best guess
            room = min(self.max_feats, n // 2) - len(feats)          # least squares with p <= n / 2
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
        if self.readout == "logit" and n >= 8 * len(cols):              # v1.1: refine the weights with logistic loss
            A = np.stack(cols, 1); p = A.shape[1]; v = 4.0 * W; lam = self.logit_lam
            for _ in range(15):
                z = A @ v; pr = 1 / (1 + np.exp(-y * z)); g = -(A.T @ (y * (1 - pr))) / n + lam * v
                Hs = (A * (pr * (1 - pr))[:, None]).T @ A / n + lam * np.eye(p); v = v - np.linalg.solve(Hs, g)
                fl[0] += 2 * n * p * p + p ** 3 / 3 + 8 * n * p
            W = v * (np.linalg.norm(A @ W) / max(np.linalg.norm(A @ v), 1e-12))
        bg = X.T @ r / n if self.background else np.zeros(d); fl[0] += 2 * n * d   # kernel background on the residual
        if self.readout == "coef":                                      # ablation: raw coefficients, no least squares
            W = np.array([float(np.mean(y * cl) / max(np.mean(cl * cl), 1e-12)) for cl in cols])

        def value(Z):
            Z = np.asarray(Z, dtype=np.float64); f = np.zeros(len(Z))
            for (kind, k), wi in zip(F, W):
                f += wi * (_chi(Z, k) if kind == "chi" else (Z @ k) ** 2 - k @ k)
            return f + Z @ bg

        info["size"] = len(F); info["train_err"] = float(np.mean(np.where(value(X) > 0, 1, -1) != y))
        return dict(predict=lambda Z: np.where(value(Z) > 0, 1.0, -1.0), flops=fl[0], info=info)
