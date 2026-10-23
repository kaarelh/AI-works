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
    readout   f(x) = c + a_0 h(x) + sum_g a_g (g - mean g)/std g: least squares over the Hebbian feature
              h(x) = sum_i h_i x_i, h = E_S[(y - ybar) x] (the race's order-1 unit: one dense linear unit whose weights are
              the empirical input-label correlations, with their sampling noise) and the accepted gates (tiny ridge),
              refitted after every acceptance; prediction sign(f).  Fan-in-1 gates are not moves.

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

_BINOM = np.array([[math.comb(m, t) for t in range(6)] for m in range(256)], dtype=np.int64)   # _BINOM[m, t] = C(m, t)
_COLEX = {}


def _colex_subsets(W, f):
    """All f-subsets of range(W), each sorted ascending, in colex order.  Colex order is prefix-closed: the subsets of
    range(W) are the first C(W, f) rows of the table for any larger W, so one table serves every W."""
    have = _COLEX.get(f)
    if have is None or have[0] < W:
        Wb = max(W, 2 * (have[0] if have else 0), 32)
        if f == 1:
            T = np.arange(Wb, dtype=np.int64)[:, None]
        else:
            prev = _colex_subsets(Wb - 1, f - 1)
            T = np.concatenate([np.concatenate([prev[:_BINOM[m, f - 1]], np.full((_BINOM[m, f - 1], 1), m)], 1)
                                for m in range(f - 1, Wb)], 0)
        _COLEX[f] = (Wb, T)
        have = _COLEX[f]
    return have[1][:_BINOM[W, f]]


def _rank(cols):
    """colex ranks of the rows of an (m, t) array of ascending tuples."""
    return sum(_BINOM[cols[:, i], i + 1] for i in range(cols.shape[1]))


_IDX = {}


def _subset_index(W, f):
    """All f-subsets of range(W) (colex order) and, for each, the positions of its 2^f sub-masks in the concatenated
    moment vector [empty | order 1 | order 2 | ...] (each order block in colex order)."""
    key = (W, f)
    if key in _IDX:
        return _IDX[key]
    off = np.cumsum([0] + [math.comb(W, t) for t in range(0, 5)])            # block offsets for orders 0..4
    subs = _colex_subsets(W, f)
    idx = np.zeros((len(subs), 2 ** f), dtype=np.int64)
    for T in range(1, 2 ** f):
        cols = [j for j in range(f) if T >> j & 1]
        idx[:, T] = off[len(cols)] + _rank(subs[:, cols])
    if len(_IDX) > 64:
        _IDX.clear()
    _IDX[key] = (subs, idx)
    return _IDX[key]


def _pairs(W):
    """Pairs (a<b) of range(W) in colex order, as two index arrays."""
    s = _colex_subsets(W, 2)
    return s[:, 0], s[:, 1]


def _higher_maps(W, order):
    """For each order-3 subset (colex): (pair index of its first two elements, third element); for order 4:
    (pair index of (a,b), pair index of (c,d))."""
    s = _colex_subsets(W, order)
    pc = lambda i, j: i + j * (j - 1) // 2
    if order == 3:
        return pc(s[:, 0], s[:, 1]), s[:, 2]
    return pc(s[:, 0], s[:, 1]), pc(s[:, 2], s[:, 3])


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

def search(Ulit, Mlit, r, active, gate_wires, c, a, law, fmax=4, n_eff=None, d_count=None, dense2=True):
    """Score every candidate gate on residual r and return the best by z^2 = n rho^2 / N(k) (a dict), or None.
      * pool candidates (k = 0): subsets of the active pool (active literals + depth-1 gate wires) of fan-in 2-3, and
        fan-in-4 subsets of active literals; literal-only subsets are depth 1, subsets with a gate wire are depth 2;
      * the order-2 spectral candidate (dense, k = 2, see below);
      * depth-1 literal subsets of fan-in 2..fmax reading k >= 1 inactive literals (searched only while a k >= 1
        candidate can still beat the best z^2 found so far: rho <= 1, so z^2 <= n / N(k)).
    Ulit (n, d) literals, Mlit(order) -> plain literal moments up to that order, active (d,) bool,
    gate_wires (n, G) +-1 wires of depth-1 gates.  d_count: the d of the noise law (default Ulit.shape[1]); n_eff: the n
    in z^2 (default the number of rows; the analytic predictor passes the cube of relevant variables and a hypothetical n)."""
    n_rows, d = Ulit.shape
    n = n_eff or n_rows
    dn = d_count or d
    rc = r - r.mean()
    sr2 = float(np.mean(rc ** 2))
    if sr2 < 1e-12:
        return None
    act = np.where(active)[0]
    nact = len(act)
    best = None

    def consider(z2, info):
        nonlocal best
        if best is None or z2 > best["z2"]:
            best = dict(info, z2=z2)

    rf = r.astype(F32)
    # ----- pool candidates (k = 0)
    G = gate_wires.shape[1]
    if nact + G >= 2:
        pool = np.concatenate([Ulit[:, act], gate_wires], 1)
        A = pool.shape[1]
        mo = 4 if nact >= 4 and fmax >= 4 else 3
        Mp = moments(pool[:, :nact], np.ones(n_rows, F32), mo) if mo == 4 else None
        Rp4 = moments(pool[:, :nact], rf, mo) if mo == 4 else None
        Mp3 = moments(pool, np.ones(n_rows, F32), 3); Rp3 = moments(pool, rf, 3)
        for f in (2, 3, 4):
            if f == 4:
                if Mp is None:
                    continue
                subs, idx = _subset_index(nact, 4)
                M_, R_ = Mp, Rp4
            else:
                if A < f:
                    continue
                subs, idx = _subset_index(A, f)
                M_, R_ = Mp3, Rp3
            rho2, si, bb = score_subsets(M_[idx], R_[idx], f, sr2)
            has_gate = (subs >= nact).any(1)
            for dep in (1, 2):
                sel = np.where(has_gate == (dep == 2))[0]
                if len(sel) == 0:
                    continue
                if law == "occam":
                    Nf = noise_count(0, dn, a, A, law, len(sel) * 2 ** f * (f + 1))
                else:
                    Nf = noise_count(0, dn, a, nact if dep == 1 else A, law)
                i = sel[np.argmax(rho2[sel])]
                info = dict(f=f, k=0, sign=_coef_mats(f)[1][si[i]], b=float(bb[i]), rho2=float(rho2[i]), N=Nf)
                if dep == 1:
                    info.update(depth=1, S=act[subs[i]])
                else:
                    info.update(depth=2, S=subs[i], pool_lits=act)
                consider(n * rho2[i] / Nf, info)
    # ----- the order-2 (spectral) unit: the extreme eigenvectors of the residual-weighted literal covariance
    #       M_ij = E[r x_i x_j] (i != j), rounded to {-1, 0, 1} (keep |v_i| >= max|v| / 2); one dense candidate per sign of
    #       the eigenvalue, any fan-in.  It is an order-2 search over all d literals, so its noise count is N(2) = d.
    N2 = noise_count(2, dn, a, nact, law, n_candidates(2, 0, dn, nact, 2))
    Rcache = {}
    if dense2 and d >= 3 and (best is None or n / N2 > best["z2"]):
        Rcache[3] = moments(Ulit, rf, 3)
        o2 = 1 + d
        pa, pb = _pairs(d)
        Mm = np.zeros((d, d)); Mm[pa, pb] = Rcache[3][o2:o2 + len(pa)]; Mm += Mm.T
        lam, vec = np.linalg.eigh(Mm)
        for j in (0, d - 1):
            v = vec[:, j]
            S = np.where(np.abs(v) >= 0.5 * np.abs(v).max())[0]
            if len(S) < 3:
                continue
            f = len(S)
            for sg in (1.0, -1.0):
                w = sg * np.sign(v[S])
                s = Ulit[:, S].astype(np.float64) @ w
                for b in _thresholds(f):
                    g = np.maximum(s - b, 0.0)
                    vg = g.var()
                    if vg < 1e-9:
                        continue
                    rho2 = float(np.mean(rc * (g - g.mean())) ** 2 / vg / sr2)
                    consider(n * rho2 / N2, dict(depth=1, f=f, k=2, S=S, sign=w, b=float(b), rho2=rho2, N=N2, dense=True))
    # ----- depth-1 literal subsets with k >= 1 new inputs
    for f in range(2, fmax + 1):
        ks = [k for k in range(1, f + 1) if f - k <= nact and k <= d - nact]
        Nk = {k: noise_count(k, dn, a, nact, law, n_candidates(k, f - k, dn, nact, f)) for k in ks}
        ks = [k for k in ks if best is None or n / Nk[k] > best["z2"]]
        if not ks:
            continue
        mo = 3 if f <= 3 else 4
        if mo not in Rcache:
            Rcache[mo] = moments(Ulit, rf, mo)
        subs, idx = _subset_index(d, f)
        kk = (~active[subs]).sum(1)
        keep = np.isin(kk, ks)
        subs, idx, kk = subs[keep], idx[keep], kk[keep]
        rho2, si, bb = score_subsets(Mlit(mo)[idx], Rcache[mo][idx], f, sr2)
        for k in ks:
            sel = np.where(kk == k)[0]
            if len(sel) == 0:
                continue
            i = sel[np.argmax(rho2[sel])]
            consider(n * rho2[i] / Nk[k], dict(depth=1, f=f, k=int(k), S=subs[i], sign=_coef_mats(f)[1][si[i]],
                                               b=float(bb[i]), rho2=float(rho2[i]), N=Nk[k]))
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

    def __init__(self, c=4.0, a=16.0, law="search", fmax=4, gmax=48, ridge=1e-6, dense2=True, verbose=False):
        self.c, self.a, self.law, self.fmax, self.gmax, self.ridge = float(c), float(a), law, int(fmax), int(gmax), ridge
        self.dense2 = dense2
        self.verbose = verbose

    def fit(self, X, y, rng=None):
        X = np.asarray(X, dtype=F32); y = np.asarray(y, dtype=np.float64)
        n, d = X.shape
        c, a, law = self.c, self.a, self.law
        _mc = {}

        def Mlit(order):           # plain literal moments, computed lazily (order-4 only if a fan-in-4 search happens)
            if order not in _mc:
                _mc[order] = moments(X, np.ones(n, F32), order)
            return _mc[order]
        active = np.zeros(d, bool)
        gates, cols = [], []
        GW = np.zeros((n, 0), F32)
        Xs = X.astype(np.float64)
        trace = []

        # the order-1 (Hebbian) unit: one dense linear feature h(x) = sum_i h_i x_i with h = E_S[(y - ybar) x]
        hvec = (Xs.T @ (y - y.mean())) / n
        hcol = Xs @ hvec
        hsd = hcol.std() if hcol.std() > 1e-12 else 1.0
        hcol = hcol / hsd

        def refit():
            F = np.stack([hcol] + cols, 1)
            F1 = np.concatenate([np.ones((n, 1)), F], 1)
            A_ = F1.T @ F1 + self.ridge * n * np.diag(np.r_[0.0, np.ones(F.shape[1])])
            w = np.linalg.solve(A_, F1.T @ y)
            return w, F1 @ w

        w, fhat = refit()
        err = float(np.mean(np.where(fhat > 0, 1.0, -1.0) != y))
        t_fit = 0 if err <= 0.1 else None
        # literals found by the order-1 unit: significant label correlation at the order-1 noise level
        vy = float(np.var(y))
        if vy > 1e-12:
            N1 = noise_count(1, d, a, 0, law, n_candidates(1, 0, d, 0, 1))
            active |= n * hvec ** 2 / vy / N1 > c
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
            best = search(X, Mlit, r, active, GW, c, a, law, self.fmax, dense2=self.dense2)
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
            out = w_[0] + w_[1] * (Z.astype(np.float64) @ hvec) / hsd
            for i, gg in enumerate(G_):
                o, ind = _gate_out(Z, GWz, gg)
                out += w_[2 + i] * (o - gg["mu"]) / gg["sd"]
                if "wire" in gg:
                    GWz = np.concatenate([GWz, (2.0 * ind - 1.0).astype(F32)[:, None]], 1)
            return np.where(out > 0, 1.0, -1.0)

        return dict(predict=predict, time=float(t_fit if t_fit is not None else len(gates)), size=len(gates),
                    trace=trace, gates=[(g["depth"], g["f"], g["k"]) for g in gates])
