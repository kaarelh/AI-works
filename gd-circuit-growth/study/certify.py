"""Distillation certificates: bound a trained network's test error without labelled hold-out data.

For a trained network h (trained on S, |S| = n), search a fixed hierarchy of small "circuit" classes for a predictor g
that agrees with h on unlabelled inputs.  Then, with probability >= 1 - delta over S and the unlabelled sample,
simultaneously for every g in the hierarchy and every candidate considered,

    test_err(h) <= test_err(g) + P_x[g(x) != h(x)]
                <= klinv( train_err_S(g), (ln 1/prior(g) + ln(2/delta)) / n )                  (Occam / Chernoff)
                 + disagree_B(g, h) + sqrt( ln(2 * n_candidates / delta) / (2 m_B) )          (Hoeffding on fresh inputs)

prior(g) = prior(class index) / |class|.  The unlabelled inputs are split: A (fit g to h's predictions) and B
(estimate disagreement), so B is independent of g.  Labels of the unlabelled points are never used.

Classes (d = 30 coordinates), each indexed by its parameters and given equal prior weight over a fixed index list:
  junta(r):        a set R of r coordinates and an arbitrary truth table on R          |H| = C(d, r) * 2^(2^r)
  chars(r, k, T):  a set R of r coordinates, T characters chi_S with S subset of R and |S| <= k, integer weights in
                   {-q..q}, g = sign(sum_j w_j chi_Sj) with sign(0) := +1             |H| = C(d,r) * C(D_k(r), T) * (2q+1)^T
"""
import itertools, math, numpy as np

D = 30
Q = 4                      # weight grid {-Q..Q}
R_MAX, K_MAX, T_MAX = 12, 4, 48


def kl(p, q):
    p = min(max(p, 0.0), 1.0); q = min(max(q, 1e-15), 1 - 1e-15)
    a = p * math.log(p / q) if p > 0 else 0.0
    b = (1 - p) * math.log((1 - p) / (1 - q)) if p < 1 else 0.0
    return a + b


def klinv_upper(p_hat, eps):
    """Largest q >= p_hat with kl(p_hat || q) <= eps (binary search)."""
    lo, hi = p_hat, 1.0
    for _ in range(60):
        mid = (lo + hi) / 2
        if kl(p_hat, mid) > eps:
            hi = mid
        else:
            lo = mid
    return hi


N_CLASS_INDICES = (R_MAX + 1) + (R_MAX + 1) * K_MAX * T_MAX   # junta(r) for r<=R_MAX, chars(r,k,T)


def ln_class_size(kind, r, k=None, T=None):
    lnC = math.lgamma(D + 1) - math.lgamma(r + 1) - math.lgamma(D - r + 1)
    if kind == "junta":
        return lnC + (2 ** r) * math.log(2)
    Dk = sum(math.comb(r, j) for j in range(0, k + 1))
    lnchoose = math.lgamma(Dk + 1) - math.lgamma(T + 1) - math.lgamma(Dk - T + 1) if T <= Dk else float("inf")
    return lnC + lnchoose + T * math.log(2 * Q + 1)


def _cells(B, R):
    w = 2 ** np.arange(len(R))
    return (B[:, list(R)] * w).sum(-1) if len(R) else np.zeros(len(B), dtype=np.int64)


def truth_table(XA, hA, R):
    B = (XA > 0).astype(np.int64); c = _cells(B, R); ncell = 2 ** len(R)
    tot = np.bincount(c, minlength=ncell); pos = np.bincount(c, weights=(hA > 0), minlength=ncell)
    default = 1.0 if hA.mean() >= 0 else -1.0
    table = np.where(tot > 0, np.where(2 * pos >= tot, 1.0, -1.0), default)
    return lambda Z: table[_cells((Z > 0).astype(np.int64), R)]


def best_sets(XA, hA, r_exhaustive=4, r_max=R_MAX):
    """Nested coordinate sets R_1 ⊂ R_2 ⊂ ... chosen to make a truth table on R agree with h on A:
    exhaustive search for |R| <= r_exhaustive, then greedy extension."""
    B = (XA > 0).astype(np.int64); m = len(XA); hb = (hA > 0).astype(np.int64)
    def score_many(subsets):
        k = subsets.shape[1]; w = 2 ** np.arange(k); ncell = 2 ** k
        cells = (B[:, subsets] * w).sum(-1).T  # (S, m)
        flat = (np.arange(len(subsets))[:, None] * ncell + cells).ravel()
        tot = np.bincount(flat, minlength=len(subsets) * ncell).reshape(-1, ncell)
        pos = np.bincount(flat, weights=np.tile(hb, len(subsets)), minlength=len(subsets) * ncell).reshape(-1, ncell)
        return np.minimum(pos, tot - pos).sum(1)  # disagreements of the best truth table
    out = {}
    best = None
    for k in range(1, r_exhaustive + 1):
        subs = np.array(list(itertools.combinations(range(D), k)), dtype=np.int64)
        errs = np.concatenate([score_many(ch) for ch in np.array_split(subs, max(1, len(subs) * m // 3_000_000 + 1))])
        j = int(np.argmin(errs)); out[k] = tuple(subs[j]); best = out[k]
    R = list(best)
    for k in range(r_exhaustive + 1, r_max + 1):
        cand = [i for i in range(D) if i not in R]
        errs = score_many(np.array([R + [i] for i in cand], dtype=np.int64))
        R = R + [cand[int(np.argmin(errs))]]; out[k] = tuple(R)
    return out


def _chi(Z, sets):
    M = np.ones((len(Z), len(sets)), dtype=np.float32)
    for c, S in enumerate(sets):
        for i in S:
            M[:, c] *= Z[:, i]
    return M


def certify(X_train, y_train, X_unlab, h_unlab, delta=0.05, r_values=tuple(range(1, 11)), kmax=K_MAX, Tmax=32):
    """X_unlab: unlabelled inputs, h_unlab: the network's +-1 predictions on them (labels never used); the first half
    is used to fit candidate circuits g, the second half to estimate P[g != h].  Returns (best row, all rows)."""
    n = len(X_train); m = len(X_unlab) // 2
    XA, hA, XB, hB = X_unlab[:m], h_unlab[:m].astype(np.float64), X_unlab[m:], h_unlab[m:]
    sets = best_sets(XA, hA, r_max=max(r_values))
    cands = []  # (kind, r, k, T, train_pred, B_pred)
    for r in r_values:
        R = sets[r]
        g = truth_table(XA, hA, R)
        cands.append(("junta", r, None, None, g(X_train), g(XB)))
        sets_all = [S for j in range(0, kmax + 1) for S in itertools.combinations(R, j)]
        PA, PT, PB = _chi(XA, sets_all), _chi(X_train, sets_all), _chi(XB, sets_all)
        deg = np.array([len(S) for S in sets_all])
        for k in range(1, kmax + 1):
            cols = np.where(deg <= k)[0]
            chosen, resid = [], hA.copy()
            for T in range(1, min(Tmax, len(cols)) + 1):
                sc = np.abs(PA[:, cols].T @ resid); sc[chosen] = -1
                chosen.append(int(np.argmax(sc)))
                sel = cols[chosen]
                w, *_ = np.linalg.lstsq(PA[:, sel].astype(np.float64), hA, rcond=None)
                resid = hA - PA[:, sel] @ w
                wq = np.round(Q * w / max(np.abs(w).max(), 1e-12))
                cands.append(("chars", r, k, T, np.where(PT[:, sel] @ wq >= 0, 1.0, -1.0),
                              np.where(PB[:, sel] @ wq >= 0, 1.0, -1.0)))
                if np.all(np.where(PA[:, sel] @ wq >= 0, 1.0, -1.0) == hA):
                    break
    ln_index = math.log(N_CLASS_INDICES)
    hoeff = math.sqrt(math.log(2 * len(cands) / delta) / (2 * len(XB)))
    best, rows = None, []
    for kind, r, k, T, ptr, pB in cands:
        tr = float(np.mean(ptr != y_train)); dis = float(np.mean(pB != hB))
        lnH = ln_class_size(kind, r, k, T)
        occam = klinv_upper(tr, (lnH + ln_index + math.log(2 / delta)) / n)
        row = dict(kind=kind, r=r, k=k, T=T, train_err_g=tr, disagree=dis, ln_class=lnH, occam=occam,
                   hoeffding=hoeff, bound=min(occam + dis + hoeff, 1.0))
        rows.append(row)
        if best is None or row["bound"] < best["bound"]:
            best = row
    return best, rows


if __name__ == "__main__":
    import sys, time, common as C
    fn, n = (sys.argv[1], int(sys.argv[2])) if len(sys.argv) > 2 else ("par3", 2048)
    nn = C.nn_fixed(fn)
    a = list(nn["ns"]).index(n)
    Xte, yte = C.test_data(fn)
    for s in range(3):
        X, y = C.train_data(fn, s, n)
        t0 = time.time()
        best, rows = certify(X, y, Xte, nn["pred"][a, s].astype(float))
        print(f"{fn} n={n} seed={s}: NN test err {nn['test_err'][a, s]:.3f}  certificate {best['bound']:.3f}  via {best}"
              f"  ({time.time()-t0:.1f}s)")
