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

v1.2 (Part 9, part9/p9_sum): SUM-FEATURE BLOCKS.  A block is (S, s, fold): a subset S of the inputs, signs s_i in
{-1, +1}, and t(x) = sum_{i in S} s_i x_i (or |t| if fold).  Its features are the indicators of contiguous groups of
values of t (each group >= max(3, 0.005 n) training points), so every function of t - every symmetric function of the
signed inputs in S - is a linear combination of them.  Variants: modulated, chi_T(x) * [t in group] for a current
character chi_T (inputs of T not in S); product, the joint cells of two blocks with disjoint supports.  Additive and
modulated blocks on one (S, s) represent any g(t + w chi_T) with integer w.
  test     T = |projection of r onto the group indicators|^2 / s^2 = sum_v n_v mean_v(r)^2 / s^2 > m + 2 sqrt(m t) + 2 t
           (chi^2_m tail, m = occupied groups - 1), t = ln(4 K C(d, k) 2^(k-1) * 2 * (1 + #modulators) * k_max / delta):
           a union bound over EVERY (S, s) of size k, both fold variants, every modulator and size, so the adaptive
           search below is covered.  Products: the sum of the two blocks' t.
  search   (_block_search; uses only the residual) prefixes of the inputs ordered by the top eigenvectors of the residual
           pair matrix M (an even symmetric function has pair coefficients a2 s_i s_j on S) and by the degree-1
           coefficients; greedy growth by T from the strongest pairs and single inputs; local refinement (add / remove /
           flip a sign) of the 3 best; the best is tested on all n.
  accept   a candidate is searched on the round's residual r and accepted only if it also passes the same test on
           r projected off this round's accepted characters and the constant (what it adds beyond them); no block
           search when those characters already explain r (mean square < 1e-4 s^2).
  per round  up to 2 additive blocks (the residual deflated by each candidate); a product A x B with B searched over
           the joint cells with A (and a 'split' of a mixed-sign candidate into its + and - parts), accepted only if it
           beats the additive block's margin; one modulated block per top-4 current character; products of accepted
           additive blocks.  (sum_force=True, off by default: in the forced variant force the best block candidate
           instead of a character; it cost accuracy on andxor at n = 32 in development and gained nothing.)
"""
import itertools, math, numpy as np, time as _time
AUD = dict(sum_fl=0.0, sum_cpu=0.0, tot_fl=0.0, tot_cpu=0.0, fits=0, mt_elems=0.0, stat_fl=0.0, rounds=0, max_round_sum=0.0, max_round_sum_rel=0.0, readout_fl=0.0, overshoot=0.0)
from harness import gd_flops


# ------------------------------------------------------------------------------------------- v1.2: sum-feature blocks
def _chi2_thr(m, t):
    """Laurent-Massart: P(chi^2_m > m + 2 sqrt(m t) + 2 t) <= exp(-t)."""
    return m + 2.0 * math.sqrt(m * t) + 2.0 * t


def _edges(t, mc):
    """Boundaries of contiguous groups of the integer values t, each group holding >= mc training points (rare tail
    values merged inward).  Group of a value: np.searchsorted(edges, value)."""
    vals, cnt = np.unique(t, return_counts=True)
    E, acc = [], 0
    for v, c in zip(vals, cnt):
        acc += c
        if acc >= mc:
            E.append(float(v) + 0.5); acc = 0
    if E and acc < mc:
        E.pop()
    return np.array(E, dtype=np.float64)


def _multi_T(I, r, L):
    """For each column c of the integer level matrix I (m x C, values in [0, L)): sum over levels v of
    (sum of r over the points at level v)^2 / (their count) = the squared norm of the projection of r onto the level
    indicators of column c; and the number of occupied levels."""
    m, C = I.shape; AUD["mt_elems"] += m * C
    flat = (I + L * np.arange(C)[None, :]).ravel()
    sm = np.bincount(flat, weights=np.broadcast_to(r[:, None], (m, C)).ravel(), minlength=L * C).reshape(C, L)
    ct = np.bincount(flat, minlength=L * C).reshape(C, L)
    nz = ct > 0
    T = np.where(nz, sm ** 2 / np.maximum(ct, 1), 0.0).sum(1)
    return T, nz.sum(1)


class SumBlock:
    """A block of sum features: phi_v(x) = chi_mod(x) * [ t(x) in group v ],  t(x) = sum_{i in S} s_i x_i  (or |.| if
    fold), groups = contiguous value sets (edges); with `other`, the groups are the joint cells of two blocks (a product
    block).  Every function of t (times chi_mod) is a linear combination of the block's features."""

    def __init__(self, S, sg, fold, mod, edges, other=None):
        self.S, self.sg = np.asarray(S, dtype=np.int64), np.asarray(sg, dtype=np.float64)
        self.fold, self.mod, self.edges, self.other = bool(fold), tuple(mod), np.asarray(edges), other

    def stat(self, Z):
        t = np.asarray(Z, dtype=np.float64)[:, self.S] @ self.sg; AUD["stat_fl"] += 2.0 * len(t) * len(self.S) + len(t)
        return np.abs(t) if self.fold else t

    def ngroups(self):
        return (len(self.edges) + 1) * (self.other.ngroups() if self.other is not None else 1)

    def group(self, Z):
        g = np.searchsorted(self.edges, self.stat(Z))
        if self.other is not None:
            g = g * self.other.ngroups() + self.other.group(Z)
        return g

    def key(self):
        o = None if self.other is None else self.other.key()
        sg = self.sg * (self.sg[0] if len(self.sg) else 1.0)       # global sign is irrelevant
        return (tuple(int(i) for i in self.S), tuple(int(v) for v in sg), self.fold, self.mod, o)

    def desc(self):
        sgn = "".join("+" if v > 0 else "-" for v in self.sg)
        a = f"{'|' if self.fold else ''}sum{list(int(i) for i in self.S)}{sgn}{'|' if self.fold else ''}"
        if self.mod:
            a = f"chi{list(self.mod)}*" + a
        return a + ("" if self.other is None else " x " + self.other.desc())


def _block_search(X, rt, s2, Mt, excl, tk, mc, gcap=2048, kmax=24, npair=3, neig=2, nsingle=2, patience=5, fl=None,
                  base=None, init=()):
    """Discrete search for one (S, s) block on the residual-like vector rt (r, or r * chi_mod).
    Candidates: (a) inputs ordered by |u_i| for the top-neig eigenvectors u of the off-diagonal pair matrix Mt
    (s = sign(u)), every prefix; (a') inputs ordered by the degree-1 coefficients |mean(rt x_i)| (s = their signs);
    (b) greedy growth from the npair strongest pairs of Mt (both relative signs) and from the nsingle strongest single
    inputs, adding at each step the input and sign that maximise the block statistic T; every prefix of every path,
    folded (|t|) and unfolded.  The 3 best are refined by a local search (add / remove / flip-sign moves).  Prefix
    scores use the first min(n, gcap) points.  The best candidate is then tested on all n:
    T = |projection of rt onto the block's level indicators|^2 / s^2 > chi^2 threshold at exp(-tk(k)) (tk includes the
    union bound over every (S, s) of size k, both fold variants and every modulator, so the adaptive search is covered).
    base = (g, G): a fixed partition of the points (the groups of another block); T is then computed over the joint
    cells (base group, level), i.e. for the product block, and init: extra starting candidates [(S, sg, fold)].
    Returns (best candidate block or None, T, threshold, accepted)."""
    n, d = X.shape
    mg = min(n, gcap); Xg, rg = X[:mg], rt[:mg]; scale = n / mg
    if base is None:
        _mT = _multi_T
    else:
        gb, Gb = base; gbg = gb[:mg]

        def _mT(I, r_, L):
            return _multi_T(gbg[:, None] * L + I, r_, Gb * L)
    allowed = np.ones(d, bool); allowed[list(excl)] = False
    if allowed.sum() < 2:
        return None, 0.0, 0.0, False
    kmax = int(min(kmax, allowed.sum()))
    best = {}                                                   # key -> (margin, S, sg, fold)

    def margin(T, lev, k):
        m = max(int(lev) - 1, 1); Te = (T / s2 - m) * scale + m
        return Te - _chi2_thr(m, tk(k))

    def prefixes(order, sg):
        order = np.asarray(order); sg = np.asarray(sg, dtype=np.float64); K = len(order)
        Cs = np.cumsum(Xg[:, order] * sg[None, :], axis=1); ks = np.arange(1, K + 1)
        Iu = np.rint((Cs + ks[None, :]) / 2).astype(np.int64); If = np.rint(np.abs(Cs)).astype(np.int64)
        Tu, lu = _mT(Iu, rg, K + 1); Tf, lf = _mT(If, rg, K + 1)
        if fl is not None:
            fl[0] += 8.0 * mg * K
        for k in range(2, K + 1):
            for fold, T, lev in ((False, Tu[k - 1], lu[k - 1]), (True, Tf[k - 1], lf[k - 1])):
                mgn = margin(T, lev, k)
                S = tuple(int(i) for i in order[:k]); sv = sg[:k] * sg[0]
                key = (tuple(sorted(zip(S, sv.astype(int).tolist()))), fold)
                if key not in best or best[key][0] < mgn:
                    best[key] = (mgn, S, tuple(sv), fold)

    Ms = (Mt + Mt.T) / 2.0; np.fill_diagonal(Ms, 0.0); Ms[~allowed] = 0.0; Ms[:, ~allowed] = 0.0
    lam, U = np.linalg.eigh(Ms)
    if fl is not None:
        fl[0] += 10.0 * d ** 3
    for q in np.argsort(-np.abs(lam))[:neig]:
        u = U[:, q]; order = [int(i) for i in np.argsort(-np.abs(u)) if allowed[i]][:kmax]
        prefixes(order, np.where(u[order] >= 0, 1.0, -1.0))
    c1 = X.T @ rt / n; c1[~allowed] = 0.0
    if fl is not None:
        fl[0] += 2.0 * n * d
    order = [int(i) for i in np.argsort(-np.abs(c1)) if allowed[i]][:kmax]
    prefixes(order, np.where(c1[order] >= 0, 1.0, -1.0))
    Mu = np.abs(np.triu(Ms, 1)); top = np.argsort(-Mu.ravel())[:npair]
    seeds = []
    for p in top:
        i, j = divmod(int(p), d)
        if Mu[i, j] > 0:
            seeds += [([i, j], [1.0, 1.0]), ([i, j], [1.0, -1.0])]
    for i in [int(i) for i in np.argsort(-np.abs(c1)) if allowed[i]][:nsingle]:
        seeds.append(([i], [1.0]))
    for S0, sg0 in seeds:
        S, sg = list(S0), list(sg0); cur = Xg[:, S] @ np.asarray(sg); bestm, bestk = -np.inf, len(S)
        for k in range(len(S) + 1, kmax + 1):
            inS = np.zeros(d, bool); inS[S] = True; L = np.where(allowed & ~inS)[0]
            if len(L) == 0:
                break
            NS = np.concatenate([cur[:, None] + Xg[:, L], cur[:, None] - Xg[:, L]], axis=1)
            T, lev = _mT(np.rint((NS + k) / 2).astype(np.int64), rg, k + 1)
            if fl is not None:
                fl[0] += 8.0 * mg * NS.shape[1]
            c = int(np.argmax(T)); l = int(L[c % len(L)]); sl = 1.0 if c < len(L) else -1.0
            S.append(l); sg.append(sl); cur = cur + sl * Xg[:, l]
            mk = margin(T[c], lev[c], k)
            if mk > bestm:
                bestm, bestk = mk, k
            elif k - bestk >= patience:
                break
        prefixes(S, sg)
    for S0, sg0, fold0 in init:                                 # extra starting candidates (scored as they are)
        S0 = [int(i) for i in S0 if allowed[i]]
        if len(S0) >= 2:
            sv = np.asarray(sg0, dtype=np.float64)[: len(S0)]; cur = Xg[:, S0] @ sv; k = len(S0)
            I = np.rint(np.abs(cur) if fold0 else (cur + k) / 2).astype(np.int64)[:, None]
            T, lev = _mT(I, rg, k + 1); key = (tuple(sorted(zip(S0, (sv * sv[0]).astype(int).tolist()))), bool(fold0))
            best[key] = (margin(T[0], lev[0], k), tuple(S0), tuple(sv * sv[0]), bool(fold0))
    if not best:
        return None, 0.0, 0.0, False

    def refine(mgn, S, sg, fold):
        """Discrete local search on the block margin: remove an input, add an input (either sign), or flip a sign;
        take the best improving move until none improves (at most 3 kmax moves)."""
        S, sg = list(S), [float(v) for v in sg]
        for _ in range(3 * kmax):
            k = len(S); cur = Xg[:, S] @ np.asarray(sg); inS = np.zeros(d, bool); inS[S] = True
            L = np.where(allowed & ~inS)[0]
            cols, ks, moves = [], [], []
            if k > 2:
                cols.append(cur[:, None] - Xg[:, S] * np.asarray(sg)[None, :]); ks += [k - 1] * k; moves += [("rm", q) for q in range(k)]
            cols.append(cur[:, None] - 2 * Xg[:, S] * np.asarray(sg)[None, :]); ks += [k] * k; moves += [("fl", q) for q in range(k)]
            if len(L) and k < kmax:
                cols += [cur[:, None] + Xg[:, L], cur[:, None] - Xg[:, L]]; ks += [k + 1] * (2 * len(L))
                moves += [("add", (int(l), 1.0)) for l in L] + [("add", (int(l), -1.0)) for l in L]
            Cs = np.concatenate(cols, axis=1); ka = np.asarray(ks)
            I = np.rint(np.abs(Cs) if fold else (Cs + ka[None, :]) / 2).astype(np.int64)
            T, lev = _mT(I, rg, kmax + 2)
            if fl is not None:
                fl[0] += 8.0 * mg * Cs.shape[1]
            M_ = np.array([margin(T[c], lev[c], ka[c]) for c in range(len(ka))]); c = int(np.argmax(M_))
            if M_[c] <= mgn + 1e-9:
                break
            mgn = float(M_[c]); kind, a = moves[c]
            if kind == "rm":
                S.pop(a); sg.pop(a)
            elif kind == "fl":
                sg[a] = -sg[a]
            else:
                S.append(a[0]); sg.append(a[1])
        return mgn, tuple(S), tuple(sg), fold

    tops = sorted(best.values(), key=lambda v: -v[0])[:3]
    mgn, S, sg, fold = max((refine(*c) for c in tops), key=lambda v: v[0])
    blk = SumBlock(S, sg, fold, (), [])
    t = blk.stat(X); blk.edges = _edges(t, mc); g = np.searchsorted(blk.edges, t); G = len(blk.edges) + 1
    if base is not None:
        g, G = base[0] * G + g, base[1] * G
    T, lev = _multi_T(g[:, None], rt, G); T = float(T[0]) / s2; m = max(int(lev[0]) - 1, 1)
    if fl is not None:
        fl[0] += 2.0 * n * len(S) + 4.0 * n
    thr = _chi2_thr(m, tk(len(S)))
    return blk, T, thr, T > thr


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
                 small_n=True, cv_n=512, K_hi=6, budget_hi=0.03, background=True, logit_lam=1e-4, name=None,
                 sums=True, sum_kmax=24, sum_mod=4, sum_add=2, sum_gcap=2048, sum_mc=0.005, sum_prod=True, sum_nmin=32,
                 sum_force=False, sum_seeds=(2, 3, 2)):
        self.K, self.K_later, self.c, self.delta, self.rounds = K, K_later, c, delta, rounds
        self.max_new, self.max_feats, self.max_ext_bases, self.local_max = max_new, max_feats, max_ext_bases, local_max
        self.blocks, self.ridge, self.budget, self.noise, self.readout = blocks, ridge, budget, noise, readout
        self.small_n, self.cv_n, self.K_hi, self.budget_hi, self.background = small_n, cv_n, K_hi, budget_hi, background
        self.logit_lam = logit_lam
        self.sums, self.sum_kmax, self.sum_mod, self.sum_add, self.sum_gcap = sums, sum_kmax, sum_mod, sum_add, sum_gcap
        self.sum_mc, self.sum_prod, self.sum_nmin, self.sum_force = sum_mc, sum_prod, sum_nmin, sum_force
        self.sum_seeds = tuple(sum_seeds)                               # (eigenvectors, pairs, single inputs)
        self.name = name or ("dfg-v1.2" if readout == "logit" else f"dfg-v1.2-{readout}")

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
        blocks, have_blk = [], set()                                    # v1.2: accepted sum blocks
        info = dict(rounds=0, log=[], blocks=[])

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
            _f0 = fl[0]; _c0 = _time.process_time()
            # ---- v1.2: sum-feature blocks (S, s): additive (up to sum_add per round, the residual deflated in between),
            #      modulated by a current character chi_T (inputs of T excluded from S), and products of two accepted
            #      additive blocks.  One union bound over every (S, s) of size k, fold variant and modulator.
            sum_top = [0.0, None]                                       # best additive candidate (T / threshold)
            if self.sums and n >= self.sum_nmin and d >= 3:
                nb = [k for k, _ in sorted([(k, abs(wi)) for (kind, k), wi in zip(feats, w) if kind == "chi" and k],
                                           key=lambda kv: -kv[1])][: self.sum_mod]
                nmod = 1 + len(nb); KM = self.sum_kmax
                tk = lambda k, nmod=nmod: math.log(4 * self.K * math.comb(d, k) * 2.0 ** (k - 1) * 2 * nmod * KM / self.delta)
                mc = max(3, int(self.sum_mc * n))
                kw = dict(gcap=self.sum_gcap, kmax=KM, fl=fl, neig=self.sum_seeds[0], npair=self.sum_seeds[1],
                          nsingle=self.sum_seeds[2])
                # blocks are searched on the round's residual r, but accepted only if they also pass the test on rS = r
                # projected off this round's accepted characters (what they add beyond them); same threshold
                new0 = [S for S, _ in sorted(cand.items(), key=lambda kv: -kv[1][0])[: self.max_new]]
                rS = r
                if new0:
                    A0 = np.stack([np.ones(n)] + [_chi(X, S) for S in new0], 1); q0 = A0.shape[1]
                    rS = r - A0 @ np.linalg.lstsq(A0, r, rcond=None)[0]
                    fl[0] += 2 * n * q0 * q0 + 4 * n * q0 + q0 ** 3
                s2, s2S = s * s, float(np.mean(rS * rS))
                live = s2S > 1e-4 * s2                      # else the round's characters already explain the residual

                def tS(b, vec):                             # block statistic of b on vec, in units of s2S
                    g = b.group(X); T_, lev_ = _multi_T(g[:, None], vec, b.ngroups()); fl[0] += 4.0 * n
                    return float(T_[0]) / s2S
                rr, rrS, Mc, cands, mg0 = r, rS, M, [], -np.inf
                for it in range(self.sum_add if live else 0):   # additive blocks; residuals deflated by each candidate
                    b_, T_, th_, ok = _block_search(X, rr, s2, Mc, (), tk, mc, **kw)
                    if b_ is None:
                        break
                    TS = tS(b_, rrS); ok = ok and TS > th_
                    cands.append(b_)
                    if it == 0 and th_ > 0:
                        sum_top[:] = [T_ / th_, b_]; mg0 = TS - th_
                    if ok and b_.key() not in have_blk:
                        blk.append(("sum", b_)); have_blk.add(b_.key())
                    if it + 1 < self.sum_add:
                        g = b_.group(X); G = b_.ngroups(); cnt = np.maximum(np.bincount(g, minlength=G), 1)
                        rr = rr - (np.bincount(g, weights=rr, minlength=G) / cnt)[g]
                        rrS = rrS - (np.bincount(g, weights=rrS, minlength=G) / cnt)[g]
                        Mc = (X * rr[:, None]).T @ X / n; fl[0] += 2 * n * d * d + 8 * n
                okb, prods = False, []                      # product candidates (margin, block)
                if self.sum_prod and len(cands) >= 2:       # product A x B: B searched over the joint cells with A
                    a_ = cands[0]; gA, GA = a_.group(X), a_.ngroups()
                    tkp = lambda k, kA=len(a_.S): tk(kA) + tk(k)
                    b2, Tb, thb, ok2 = _block_search(X, r, s2, Mc, set(a_.S.tolist()), tkp, mc, base=(gA, GA),
                                                     init=[(c.S, c.sg, c.fold) for c in cands[1:]], **kw)
                    if ok2:
                        P = SumBlock(b2.S, b2.sg, b2.fold, (), b2.edges, other=a_); TS = tS(P, rS)
                        if TS > thb:
                            prods.append((TS - thb, P))
                if self.sum_prod and cands:                 # split move: a block with mixed signs may be |t_A - t_B|
                    c0 = cands[0]; pos = c0.S[c0.sg > 0].tolist(); neg = c0.S[c0.sg < 0].tolist()
                    if len(pos) >= 2 and len(neg) >= 2:
                        Ap = SumBlock(pos, [1.0] * len(pos), c0.fold, (), [])
                        Ap.edges = _edges(Ap.stat(X), mc); gA, GA = Ap.group(X), Ap.ngroups()
                        tkp = lambda k, kA=len(pos): tk(kA) + tk(k)
                        b2, Tb, thb, ok2 = _block_search(X, r, s2, Mc, set(pos), tkp, mc, base=(gA, GA),
                                                         init=[(neg, [1.0] * len(neg), c0.fold)], **kw)
                        if ok2:
                            P = SumBlock(b2.S, b2.sg, b2.fold, (), b2.edges, other=Ap); TS = tS(P, rS)
                            if TS > thb:
                                prods.append((TS - thb, P))
                if prods and max(v[0] for v in prods) > mg0:     # only if it beats the first additive block alone
                    P = max(prods, key=lambda v: v[0])[1]; okb = True
                    if P.key() not in have_blk:
                        blk.append(("sum", P)); have_blk.add(P.key())
                if self.sum_prod and live:
                    for a_, b2 in ([] if okb else itertools.combinations(cands, 2)):
                        if set(a_.S.tolist()) & set(b2.S.tolist()):
                            continue
                        P = SumBlock(a_.S, a_.sg, a_.fold, (), a_.edges, other=b2)
                        if P.key() in have_blk:
                            continue
                        g = P.group(X); Tp, lev = _multi_T(g[:, None], rS, P.ngroups()); fl[0] += 4.0 * n * (len(a_.S) + len(b2.S))
                        m_ = max(int(lev[0]) - 1, 1)
                        if float(Tp[0]) / s2S > _chi2_thr(m_, tk(len(a_.S)) + tk(len(b2.S))):
                            blk.append(("sum", P)); have_blk.add(P.key())
                for T in (nb if live else []):
                    ct = _chi(X, T); rt = r * ct
                    Mt = (X * rt[:, None]).T @ X / n; fl[0] += 2 * n * d * d + n * (d + len(T))
                    b_, T_, th_, ok = _block_search(X, rt, s2, Mt, set(T), tk, mc, **kw)
                    if ok and tS(b_, rS * ct) > th_:
                        b_.mod = tuple(T)
                        if b_.key() not in have_blk:
                            blk.append(("sum", b_)); have_blk.add(b_.key())
                if self.sum_prod and live:
                    add_ = [b for b in blocks if not b.mod and b.other is None]
                    for a_, b2 in itertools.combinations(add_, 2):
                        if set(a_.S.tolist()) & set(b2.S.tolist()):
                            continue
                        P = SumBlock(a_.S, a_.sg, a_.fold, (), a_.edges, other=b2)
                        if P.key() in have_blk:
                            continue
                        g = P.group(X); G = P.ngroups()
                        Tp, lev = _multi_T(g[:, None], rS, G); fl[0] += 4.0 * n * (len(a_.S) + len(b2.S))
                        m_ = max((len(a_.edges)) * (len(b2.edges)), 1)
                        tp = tk(len(a_.S)) + tk(len(b2.S))
                        if float(Tp[0]) / s2S > _chi2_thr(m_, tp):
                            blk.append(("sum", P)); have_blk.add(P.key())
            _df = fl[0] - _f0; AUD['sum_fl'] += _df; AUD['sum_cpu'] += _time.process_time() - _c0; AUD['rounds'] += 1
            AUD['max_round_sum'] = max(AUD['max_round_sum'], _df); AUD['max_round_sum_rel'] = max(AUD['max_round_sum_rel'], _df / GD)
            new = sorted(cand.items(), key=lambda kv: -kv[1][0])[: self.max_new]
            if force and not new and not blk and forced[0] < 2:          # nothing passed: take the best guess
                if self.sum_force and sum_top[1] is not None and sum_top[0] > top[0] ** 2:
                    blk = [("sum", sum_top[1])]; have_blk.add(sum_top[1].key()); forced[0] += 1   # v1.2: a block
                elif top[1] is not None:
                    new = [(top[1], (top[0], top[2]))]; forced[0] += 1
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
                elif kind == "sum":
                    g = obj.group(X); G = obj.ngroups(); cnt = np.bincount(g, minlength=G); cm = _chi(X, obj.mod)
                    use = [v for v in range(G) if cnt[v] > 0 and v != int(np.argmax(cnt))]
                    if len(use) > min(self.max_feats, n // 2) - len(feats):
                        continue
                    bid = len(blocks); blocks.append(obj); info["blocks"].append(obj.desc())
                    for v in use:
                        feats.append(("sum", (bid, v))); cols.append((g == v) * cm)
                    fl[0] += n * (len(obj.S) + 2 * len(use))
                else:
                    for u in obj:
                        feats.append(("quad", u)); cols.append((X @ u) ** 2 - u @ u); fl[0] += 2 * n * d
            info["log"].append(dict(round=rnd, s=round(s, 4), new=[S for S, _ in new[:room]][:20], n_new=len(new[:room]),
                                    blocks=[k if k != "sum" else o.desc() for k, o in blk]))
            w, r = lsfit(); info["rounds"] = rnd + 1
        AUD['overshoot'] = max(AUD['overshoot'], fl[0] / GD); _fr = fl[0]
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

        B = list(blocks)

        def value(Z):
            Z = np.asarray(Z, dtype=np.float64); f = np.zeros(len(Z)); cache = {}
            for (kind, k), wi in zip(F, W):
                if kind == "chi":
                    f += wi * _chi(Z, k)
                elif kind == "quad":
                    f += wi * ((Z @ k) ** 2 - k @ k)
                else:
                    bid, v = k
                    if bid not in cache:
                        cache[bid] = (B[bid].group(Z), _chi(Z, B[bid].mod))
                    g, cm = cache[bid]; f += wi * (g == v) * cm
            return f + Z @ bg

        AUD['readout_fl'] += fl[0] - _fr; AUD['tot_fl'] += fl[0]; AUD['fits'] += 1
        info["size"] = len(F); info["train_err"] = float(np.mean(np.where(value(X) > 0, 1, -1) != y))
        return dict(predict=lambda Z: np.where(value(Z) > 0, 1.0, -1.0), flops=fl[0], info=info)
