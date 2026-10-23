"""Minimal stagewise learner ("minimal"): greedy growth over an explicit finite gate library with a noise-law
acceptance threshold and a least-squares readout.  Built to keep most of the race model's match to the networks
while being simple enough that its sample complexity can be predicted from the target alone
(see study/MINIMAL-MODEL.md and minimal_predict.py).

Run with OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1.

LEARNED OBJECT
    wires     the d input literals x_1..x_d (+-1), and every accepted depth-1 gate as a +-1 wire 2*1[s > b] - 1.
    gate      g = relu(sum_{j in S} s_j u_j - b): fan-in f = |S| in {2,3,4}, signs s_j in {-1,+1}, threshold
              b in {f-1, f-3, ..., 1-f} (AND-like ... OR-like) or b = -f-1 (the signed sum itself).
              depth 1: S is a set of literals (f <= 4); depth 2: S is a set of f <= 3 wires from the *active pool*
              (active literals and depth-1 gates) containing at least one gate.  Depth-2 gates are not wires.
    readout   f(x) = c + sum_i a_i x_i + sum_g a_g (g - mean g)/std g: least squares over ALL literals and the accepted
              gates (tiny ridge), refitted after every acceptance; prediction sign(f).  The literals are always in the
              readout (the "order-1 unit" of the race, i.e. the network's linear/Hebbian part), so a fan-in-1 gate is
              never a move.

STATE    the accepted gates and the set A of *active* literals: a literal is active once an accepted gate reads it or
         once its own residual correlation is significant (n rho_i^2 > c N(1)).

MOVES    a candidate gate g needs k = (number of inactive literals it reads) new inputs at once.  Its significance is
              z^2 = n * rho_g^2 / N(k),      rho_g = |Cov_S(r, g)| / (std_S(r) std_S(g))
         (rho_g = the empirical correlation of the gate with the current residual r).  Noise law (search cost):
              N(0) = |pool|                 (a search over the few active wires; for depth-1 gates on active literals
                                             the pool is the active literals)
              N(k) = d * (d / a)^(k - 2)_+  (k >= 1)
         i.e. the continuous-direction noise level sqrt(d/n) of an order-1 or order-2 (spectral) search over d inputs,
         multiplied by (d/a) for every extra input that has to be found at once beyond two.  This is the race model's
         alignment law m' = k U m^(k-1) from an initial overlap m(0)^2 ~ a/d: the order-k signal along the target
         direction, k U m(0)^(k-1), must beat the frozen sampling noise ~ 1/sqrt(n) of the empirical gradient, so the
         required n grows by m(0)^(-2) = d/a per extra simultaneous input (see MINIMAL-MODEL.md, section 2).
         Alternatively law='occam' uses N(k) = log M_k with M_k the number of candidates of that type (the best-of-M
         noise level sqrt(2 log M_k / n)); kept for comparison.
    rule     accept the candidate with the largest z^2 if z^2 > c; otherwise stop.  Also stop at training error 0 or
         after gmax gates.

GLOBAL CONSTANTS (calibrated on common.CALIB only): c (acceptance level), a (initial-overlap scale of the search).
Fixed: fan-in <= 4 at depth 1 and <= 3 at depth 2, +-1 weights, gmax = 48, ridge 1e-6.
"""
import itertools, math
import numpy as np

F32 = np.float32


# ---------------------------------------------------------------- gate algebra (multilinear expansion)

def _thresholds(f):
    return [f - 1 - 2 * t for t in range(f)] + [-f - 1]


def _sym_coef(f, b):
    """Coefficients c_t, d_t (t = |T|) of the multilinear expansions of relu(sum z - b) and relu(sum z - b)^2 on {-1,1}^f."""
    Z = np.array(list(itertools.product([-1.0, 1.0], repeat=f)))
    phi = np.maximum(Z.sum(1) - b, 0.0)
    c = np.array([np.mean(phi * Z[:, :t].prod(1)) for t in range(f + 1)])
    d = np.array([np.mean(phi ** 2 * Z[:, :t].prod(1)) for t in range(f + 1)])
    return c, d


_COEF = {}


def _coef_mats(f):
    """For fan-in f: list over thresholds b of (Cmat, Dmat), each (2^f masks, 2^f signs): entry c_|T|(b) * prod_{j in T} s_j;
    plus the sign patterns."""
    if f in _COEF:
        return _COEF[f]
    masks = np.arange(2 ** f)
    signs = np.array(list(itertools.product([-1.0, 1.0], repeat=f)))         # (2^f, f)
    pop = np.array([bin(m).count("1") for m in masks])
    H = np.ones((2 ** f, 2 ** f))                                             # H[T, s]
    for T in masks:
        for j in range(f):
            if T >> j & 1:
                H[T] *= signs[:, j]
    out = []
    for b in _thresholds(f):
        c, d = _sym_coef(f, b)
        out.append((b, (c[pop][:, None] * H).astype(np.float64), (d[pop][:, None] * H).astype(np.float64)))
    _COEF[f] = (out, signs)
    return _COEF[f]


def score_subsets(Mo, Ro, f, sr2):
    """Mo, Ro: (nS, 2^f) moments E[u^T], E[r u^T] over the sub-masks T of each candidate subset (column 0 = empty set).
    Returns best (rho^2, sign index, threshold) per subset, rho = |Cov(r,g)| / (std r std g)."""
    mats, signs = _coef_mats(f)
    best = np.full(len(Mo), -1.0); bs = np.zeros(len(Mo), int); bb = np.zeros(len(Mo))
    rbar = Ro[:, :1]
    for b, Cm, Dm in mats:
        Eg = Mo @ Cm; Eg2 = Mo @ Dm; Erg = Ro @ Cm
        var = Eg2 - Eg * Eg
        cov = Erg - rbar * Eg
        rho2 = np.where(var > 1e-6, cov * cov / np.maximum(var, 1e-12) / sr2, -1.0)
        j = np.argmax(rho2, 1); v = rho2[np.arange(len(Mo)), j]
        upd = v > best
        best[upd] = v[upd]; bs[upd] = j[upd]; bb[upd] = b
    return best, bs, bb


# ---------------------------------------------------------------- moments of products of +-1 wires (colex-indexed)

_IDX = {}


def _colex(t):
    """colex rank of a sorted tuple."""
    return sum(math.comb(c, i + 1) for i, c in enumerate(t))


def _subset_index(W, f):
    """All f-subsets of range(W) (lex order) and, for each, the positions of its 2^f sub-masks in the concatenated
    moment vector [empty | order 1 | order 2 | ... ] (each order block in colex order)."""
    key = (W, f)
    if key in _IDX:
        return _IDX[key]
    off = np.cumsum([0] + [math.comb(W, t) for t in range(0, 5)])            # block offsets for orders 0..4
    subs = np.array(list(itertools.combinations(range(W), f)), dtype=np.int64)
    idx = np.zeros((len(subs), 2 ** f), dtype=np.int64)
    for T in range(2 ** f):
        cols = [j for j in range(f) if T >> j & 1]
        t = len(cols)
        if t == 0:
            continue
        rank = np.zeros(len(subs), dtype=np.int64)
        for i, j in enumerate(cols):
            rank += np.array([math.comb(int(v), i + 1) for v in range(W)], dtype=np.int64)[subs[:, j]]
        idx[:, T] = off[t] + rank
    _IDX[key] = (subs, idx)
    return _IDX[key]


_PAIRS = {}


def _pairs(W):
    """Pairs (a<b) of range(W) in colex order, as two index arrays."""
    if W not in _PAIRS:
        a, b = [], []
        for j in range(W):
            for i in range(j):
                a.append(i); b.append(j)
        _PAIRS[W] = (np.array(a, dtype=np.int64), np.array(b, dtype=np.int64))
    return _PAIRS[W]


_TRIPLE_MAP = {}


def _higher_maps(W, order):
    """For order 3: for each triple in colex order, (pair colex index of first two, third).  For order 4: (pair(a,b), pair(c,d))."""
    key = (W, order)
    if key in _TRIPLE_MAP:
        return _TRIPLE_MAP[key]
    subs = np.array(list(itertools.combinations(range(W), order)), dtype=np.int64)
    cr = np.array([_colex(tuple(s)) for s in subs], dtype=np.int64)
    pc = lambda i, j: i + j * (j - 1) // 2
    if order == 3:
        A = pc(subs[:, 0], subs[:, 1]); B = subs[:, 2]
    else:
        A = pc(subs[:, 0], subs[:, 1]); B = pc(subs[:, 2], subs[:, 3])
    o = np.argsort(cr)
    _TRIPLE_MAP[key] = (A[o], B[o])
    return _TRIPLE_MAP[key]


def moments(U, w, maxord, chunk=8192):
    """Concatenated moment vector E[w * u^T] for all T with |T| <= maxord (colex within each order), for +-1 wires U (n, W).
    w (n,) weights (1 for plain moments, the residual for residual moments)."""
    n, W = U.shape
    out = [np.array([w.mean()])]
    out.append((U.T @ w) / n)
    if maxord >= 2:
        pa, pb = _pairs(W)
        P2 = np.zeros(len(pa)); G3 = np.zeros((len(pa), W)) if maxord >= 3 else None
        G4 = np.zeros((len(pa), len(pa))) if maxord >= 4 else None
        for s in range(0, n, chunk):
            Us = U[s:s + chunk]; ws = w[s:s + chunk].astype(F32)
            P = Us[:, pa] * Us[:, pb]
            Pw = P * ws[:, None]
            P2 += Pw.sum(0)
            if maxord >= 3:
                G3 += Pw.T @ Us
            if maxord >= 4:
                G4 += Pw.T @ P
        out.append(P2 / n)
        if maxord >= 3:
            A, B = _higher_maps(W, 3); out.append(G3[A, B] / n)
        if maxord >= 4:
            A, B = _higher_maps(W, 4); out.append(G4[A, B] / n)
    return np.concatenate(out)


# ---------------------------------------------------------------- noise law

def noise_count(k, d, a, pool, law="search", M=None):
    if law == "occam":
        return max(math.log(max(M, 2)), 1.0)
    if k == 0:
        return float(max(pool, 1))
    return float(d) * (float(d) / a) ** max(k - 2, 0)


def n_candidates(k, j, d, nact, f):
    """Number of depth-1 candidates reading k inactive and j active literals (f = k + j)."""
    return math.comb(d - nact, k) * math.comb(nact, j) * 2 ** f * (f + 1)


# ---------------------------------------------------------------- one stage of search

def search(Ulit, Mlit, r, active, gate_wires, c, a, law, fmax=4, need_score=None, d_count=None):
    """Score every depth-1 (literal subsets, f = 2..fmax) and depth-2 (pool subsets with >= 1 gate wire, f = 2..3)
    candidate on residual r.  Returns the best candidate by z^2 = n rho^2 / N(k) as a dict, or None.
    Ulit (n, d) literals, Mlit plain literal moments (precomputed, order <= fmax), active (d,) bool,
    gate_wires (n, G) +-1 wires of depth-1 gates.  d_count: the d used in the noise law (defaults to Ulit.shape[1])."""
    n, d = Ulit.shape
    dn = d_count or d
    sr2 = float(np.mean((r - r.mean()) ** 2))
    if sr2 < 1e-12:
        return None
    nact = int(active.sum())
    best = None

    def consider(z2, info):
        nonlocal best
        if best is None or z2 > best["z2"]:
            best = dict(info, z2=z2)

    # ----- depth 1: literal subsets.  Moments of order 4 are only computed when a k-new-input candidate could still win.
    Rlit2 = None
    for f in range(2, fmax + 1):
        # upper bound on z^2 for this fan-in: rho <= 1, smallest N among the k's possible for subsets of size f
        kmin = max(0, f - nact)
        Nmin = min(noise_count(k, dn, a, nact, law, n_candidates(k, f - k, dn, nact, f)) for k in range(kmin, f + 1))
        if best is not None and n / Nmin <= best["z2"]:
            continue
        if f >= 4 and Rlit2 is not None and Rlit2[1] < 4:
            Rlit2 = None
        if Rlit2 is None:
            Rlit2 = (moments(Ulit, r.astype(F32), f), f)
        Rm = Rlit2[0]
        subs, idx = _subset_index(d, f)
        Mo = Mlit[idx]; Ro = Rm[idx]
        rho2, si, bb = score_subsets(Mo, Ro, f, sr2)
        kk = (~active[subs]).sum(1)
        for k in np.unique(kk):
            sel = np.where(kk == k)[0]
            N = noise_count(int(k), dn, a, nact, law, n_candidates(int(k), f - int(k), dn, nact, f))
            i = sel[np.argmax(rho2[sel])]
            consider(n * rho2[i] / N, dict(depth=1, f=f, k=int(k), S=subs[i], sign=_coef_mats(f)[1][si[i]],
                                           b=float(bb[i]), rho2=float(rho2[i]), N=N))
    # ----- depth 2: pool = active literals + depth-1 gate wires, subsets with >= 1 gate wire, f <= 3, k = 0
    G = gate_wires.shape[1]
    if G > 0:
        act = np.where(active)[0]
        pool = np.concatenate([Ulit[:, act], gate_wires], 1)
        A = pool.shape[1]
        N0 = noise_count(0, dn, a, A, law, None)
        Mp = moments(pool, np.ones(n, F32), 3); Rp = moments(pool, r.astype(F32), 3)
        for f in (2, 3):
            if A < f:
                continue
            subs, idx = _subset_index(A, f)
            keep = (subs >= len(act)).any(1)
            subs, idx = subs[keep], idx[keep]
            if len(subs) == 0:
                continue
            rho2, si, bb = score_subsets(Mp[idx], Rp[idx], f, sr2)
            Nf = N0 if law != "occam" else noise_count(0, dn, a, A, law, len(subs) * 2 ** f * (f + 1))
            i = int(np.argmax(rho2))
            consider(n * rho2[i] / Nf, dict(depth=2, f=f, k=0, S=subs[i], pool_lits=act, sign=_coef_mats(f)[1][si[i]],
                                           b=float(bb[i]), rho2=float(rho2[i]), N=Nf))
    return best


def _gate_out(Ulit, gate_wires, g):
    """Evaluate gate g (dict) on literal matrix Ulit and depth-1 gate wires.  Returns (relu output, firing indicator)."""
    if g["depth"] == 1:
        src = Ulit[:, g["S"]]
    else:
        pool = np.concatenate([Ulit[:, g["pool_lits"]], gate_wires[:, :g["nwires"]]], 1)
        src = pool[:, g["S"]]
    s = src @ g["sign"].astype(F32)
    return np.maximum(s - g["b"], 0.0).astype(np.float64), (s > g["b"])


# ---------------------------------------------------------------- the learner

class Minimal:
    name = "minimal"

    def __init__(self, c=4.0, a=16.0, law="search", fmax=4, gmax=48, ridge=1e-6, verbose=False):
        self.c, self.a, self.law, self.fmax, self.gmax, self.ridge = float(c), float(a), law, int(fmax), int(gmax), ridge
        self.verbose = verbose

    def fit(self, X, y, rng=None):
        X = np.asarray(X, dtype=F32); y = np.asarray(y, dtype=np.float64)
        n, d = X.shape
        c, a, law = self.c, self.a, self.law
        Mlit = moments(X, np.ones(n, F32), self.fmax)
        active = np.zeros(d, bool)
        gates, cols = [], []
        GW = np.zeros((n, 0), F32)
        Xs = X.astype(np.float64)
        trace = []

        def refit():
            F = np.concatenate([Xs] + ([np.stack(cols, 1)] if cols else []), 1)
            F1 = np.concatenate([np.ones((n, 1)), F], 1)
            A_ = F1.T @ F1 + self.ridge * n * np.diag(np.r_[0.0, np.ones(F.shape[1])])
            w = np.linalg.solve(A_, F1.T @ y)
            return w, F1 @ w

        w, fhat = refit()
        err = float(np.mean(np.where(fhat > 0, 1.0, -1.0) != y))
        t_fit = 0 if err <= 0.1 else None
        trace.append((0, err))
        while len(gates) < self.gmax and err > 0:
            r = y - fhat
            sr2 = float(np.mean((r - r.mean()) ** 2))
            if sr2 < 1e-12:
                break
            # literal activation by its own residual correlation (order-1 significance)
            rho_lit2 = ((X.T @ (r - r.mean()).astype(F32)) / n) ** 2 / sr2
            N1 = noise_count(1, d, a, int(active.sum()), law, n_candidates(1, 0, d, int(active.sum()), 1))
            active |= n * rho_lit2 / N1 > c
            best = search(X, Mlit, r, active, GW, c, a, law, self.fmax)
            if best is None or best["z2"] <= c:
                break
            g = dict(best, nwires=GW.shape[1])
            out, ind = _gate_out(X, GW, g)
            if out.std() < 1e-9:
                break
            cols.append((out - out.mean()) / out.std())
            gates.append(g)
            if g["depth"] == 1:
                active[g["S"]] = True
                if 0 < ind.mean() < 1:
                    GW = np.concatenate([GW, (2.0 * ind - 1.0).astype(F32)[:, None]], 1)
                    g["wire"] = GW.shape[1] - 1
            w, fhat = refit()
            err = float(np.mean(np.where(fhat > 0, 1.0, -1.0) != y))
            trace.append((len(gates), err))
            if t_fit is None and err <= 0.1:
                t_fit = len(gates)
            if self.verbose:
                print(f"    gate {len(gates):2d} depth={g['depth']} f={g['f']} k={g['k']} S={list(g['S'])} b={g['b']} "
                      f"rho2={g['rho2']:.3f} N={g['N']:.1f} z2={g['z2']:.1f} train_err={err:.3f}")
        G_ = [dict(gg) for gg in gates]
        w_ = w.copy()
        mus = [None] * len(G_)
        # store normalisation of each gate column on the training set
        for i, gg in enumerate(G_):
            nw = gg["nwires"]
            out, _ = _gate_out(X, GW, gg)
            gg["mu"], gg["sd"] = out.mean(), out.std()

        def predict(Z):
            Z = np.asarray(Z, dtype=F32)
            m = len(Z)
            GWz = np.zeros((m, 0), F32)
            out = w_[0] + Z.astype(np.float64) @ w_[1:d + 1]
            for i, gg in enumerate(G_):
                o, ind = _gate_out(Z, GWz, gg)
                out += w_[d + 1 + i] * (o - gg["mu"]) / gg["sd"]
                if "wire" in gg:
                    GWz = np.concatenate([GWz, (2.0 * ind - 1.0).astype(F32)[:, None]], 1)
            return np.where(out > 0, 1.0, -1.0)

        return dict(predict=predict, time=float(t_fit if t_fit is not None else len(gates)), size=len(gates),
                    trace=trace, gates=[(g["depth"], g["f"], g["k"]) for g in gates])
