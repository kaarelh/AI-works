"""Race + kernel background ("hybrid"): the race model's grown gates plus a kernel-regression background in the readout.

Run with OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 (see race.py).

PICTURE  a trained network = a fixed random-feature (kernel) background + a few grown features, all read out jointly.
    The background is the infinite-width NNGP kernel of the networks' architecture at initialisation (two ReLU hidden
    layers, models/baselines.py), normalised to unit diagonal.  The grown features are the race model's gates
    (models/race.py, unchanged search / alignment / growth / firing rules and constants theta, lam, Q).

READOUT  after every firing, the readout is the joint ridge fit
        min_{a, f_bg}  |y - c - F a - f_bg|^2  +  lam_g |a|^2  +  lam_bg |f_bg|^2_K ,
    F the standardised gate columns (as in the race), lam_g = lam * n (the race's own readout ridge), lam_bg = rho * n,
    c = mean(y).  Equivalently kernel ridge regression with kernel K + (lam_bg / lam_g) F F^T and ridge lam_bg.  It is
    computed by one Cholesky factorisation of K + lam_bg I and a rank-(#gates) Woodbury update per firing.
    The race sees the residual of this joint fit, so the background competes with gate growth: on small training sets
    it absorbs (memorises) most of the residual and fewer gates fire; on large ones it cannot, and the race proceeds.
    Stop at training sign error 0 or after gmax gates, as in the race.

LARGE n  for n > n_exact the background kernel is replaced by M random ReLU features of a fresh 2-hidden-layer
    network at initialisation (widths M, M), an unbiased Monte-Carlo approximation of the same kernel; the
    algebra is unchanged (Woodbury in the M-dimensional primal space).

NEW GLOBAL CONSTANTS (calibrated on common.CALIB only; see study/HYBRID.md)
    rho   the background's ridge per training point (relative to the unit-diagonal kernel), i.e. how cheaply the
          background can fit the residual compared with a grown gate (whose ridge is the race's lam).
    tau   (optional, default None = static background) time constant of the background's fit on the race clock:
          lam_bg(t) = rho * n * (1 + tau) / (1 + tau + t)... see `_lam_bg`; kept for the ablation in HYBRID.md.
All race constants are the race's calibrated values (theta = 1.5, lam = 1e-3, Q = 3, gate = 'relu').
"""
import zlib
import numpy as np
from scipy.linalg import cho_factor, cho_solve
from models.race import _order_k, _align_time, _overlap_after, _best_threshold, _best_relu
from models.baselines import nngp_table

F32 = np.float32


class _Background:
    """Kernel K (unit diagonal) on the training set with fast solves against K + lam I, exact or random-feature."""

    def __init__(self, X, lam, n_exact, M, rng):
        self.X = X; n, d = X.shape; self.d = d; self.lam = lam
        self.table = (nngp_table(d) / nngp_table(d)[-1]).astype(np.float64)
        self.exact = n <= n_exact
        if self.exact:
            K = self.gram(X)
            self.cf = cho_factor(K + lam * np.eye(n))
        else:
            self.W1 = rng.standard_normal((M, d)).astype(F32) / np.sqrt(d)
            self.W2 = rng.standard_normal((M, M)).astype(F32) / np.sqrt(M)
            self.scale = None
            P = self.feats(X)
            self.P = P
            self.cfm = cho_factor(P.T @ P + lam * np.eye(P.shape[1]))

    def gram(self, Z):
        return self.table[((np.asarray(Z, F32) @ self.X.T).astype(np.int64) + self.d) // 2]

    def feats(self, Z):
        h1 = np.maximum(np.asarray(Z, F32) @ self.W1.T, 0)
        h2 = np.maximum(h1 @ self.W2.T, 0).astype(np.float64)
        if self.scale is None:          # normalise to unit mean diagonal, like the exact kernel
            self.scale = 1.0 / np.sqrt(np.mean(np.sum(h2 * h2, 1)))
        return h2 * self.scale

    def solve(self, v):
        """(K + lam I)^{-1} v."""
        if self.exact:
            return cho_solve(self.cf, v)
        return (v - self.P @ cho_solve(self.cfm, self.P.T @ v)) / self.lam

    def apply(self, Z, alpha):
        """K(Z, X) alpha."""
        if self.exact:
            out = np.zeros(len(Z))
            for i in range(0, len(Z), 2048):
                out[i:i + 2048] = self.gram(Z[i:i + 2048]) @ alpha
            return out
        return self.feats(Z) @ (self.P.T @ alpha)


class Hybrid:
    name = "hybrid"

    def __init__(self, rho=0.03, theta=1.5, lam=1e-3, Q=3, K=4, P=8, iters=8, gmax=48, depth=2, gate='relu',
                 n_exact=4096, M=512, tau=None, verbose=False):
        self.rho = None if rho is None else float(rho)
        self.theta, self.lam, self.Q, self.K, self.P = float(theta), float(lam), int(Q), int(K), int(P)
        self.iters, self.gmax, self.depth, self.gate, self.verbose = int(iters), int(gmax), int(depth), gate, verbose
        self.n_exact, self.M, self.tau = int(n_exact), int(M), tau

    def _rand_dir(self, rng, D, P):
        V = rng.standard_normal((D, P)).astype(F32)
        return V / np.linalg.norm(V, axis=0)

    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=F32); y = np.asarray(y, dtype=np.float64)
        n, d = X.shape
        K, P, Q = self.K, self.P, self.Q
        Uw = np.zeros((n, d + self.gmax), dtype=F32)
        Uw[:, :d] = X
        D = d
        pool = {1: dict(V=self._rand_dir(rng, d, 1), c=np.zeros(1), sgn=np.ones(1))}
        for k in range(2, K + 1):
            pool[k] = dict(V=self._rand_dir(rng, d, P), c=np.zeros(P),
                           sgn=np.ones(P) if k % 2 else np.where(np.arange(P) % 2 == 0, 1.0, -1.0))
        gates, cols = [], []
        c0 = y.mean(); yt = y - c0
        # ---- background (its random features, if any, are seeded from the data so the race's own random draws are unchanged)
        lam_g = self.lam * n
        if self.rho is not None:
            lam_bg = self.rho * n
            bg = _Background(X, lam_bg, self.n_exact, self.M, np.random.default_rng(zlib.crc32(X.tobytes())))
            u = bg.solve(yt); Bs, Vs_ = [], []
            cg = np.sqrt(lam_bg / lam_g)
            alpha = u.copy(); a = np.zeros(0)
            f = y - lam_bg * alpha
        else:
            Gm = np.zeros((0, 0)); Fy = np.zeros(0); a = np.zeros(0)
            f = np.full(n, c0)
        t = 0.0
        err = float(np.mean(np.where(f > 0, 1.0, -1.0) != y))
        t_fit = 0.0 if err <= 0.1 else None
        trace = [(0.0, err)]
        while len(gates) < self.gmax:
            r64 = y - f
            if np.max(np.abs(r64)) < 1e-9 or err == 0:
                break
            r = r64.astype(F32); rbar = float(r.mean())
            U = Uw[:, :D]
            h = (U.T @ r) * F32(1.0 / n)
            cand = []
            for k in range(1, K + 1):
                pk = pool[k]
                Dk = D if k <= 2 else d
                V = pk["V"]
                if V.shape[0] < Dk:
                    V = np.vstack([V, np.zeros((Dk - V.shape[0], V.shape[1]), F32)]); pk["V"] = V
                Uk_ = U[:, :Dk]; hk = h[:Dk]
                if k == 1:
                    lam1 = float(np.linalg.norm(hk))
                    if lam1 <= 0:
                        continue
                    Vs = (hk / lam1)[:, None]; lamv = np.array([lam1])
                else:
                    Vs = V.copy()
                    for _ in range(self.iters):
                        _, G = _order_k(Uk_, r, Vs, k, hk, rbar)
                        G = G * pk["sgn"].astype(F32)
                        nr = np.linalg.norm(G, axis=0); nr[nr == 0] = 1.0
                        Vs = G / nr
                    Ukv, _ = _order_k(Uk_, r, Vs, k, hk, rbar, need_grad=False)
                    lamv = np.abs(Ukv)
                dots = np.sum(V * Vs, 0)
                Vs = Vs * np.where(dots < 0, -1.0, 1.0).astype(F32)
                mv = np.abs(dots)
                for p in range(Vs.shape[1]):
                    v = Vs[:, p]
                    mx = float(np.max(np.abs(v)))
                    if mx == 0:
                        continue
                    w = np.rint(Q * v / mx).astype(np.int64)
                    if not w.any():
                        continue
                    s = U[:, :Dk] @ w.astype(F32)
                    Ug, b = (_best_threshold if self.gate == 'thr' else _best_relu)(np.rint(s).astype(np.int64), r64 - r64.mean())
                    if b is None or Ug <= 1e-9:
                        continue
                    Tal = _align_time(k, lamv[p], mv[p])
                    T = Tal + max(0.0, self.theta - pk["c"][p]) / Ug
                    cand.append((T, k, p, w, b, Ug, Tal, float(lamv[p]), float(mv[p]), v))
            if not cand:
                break
            best = min(cand, key=lambda z: z[0])
            T, kw, pw, w, b, Ug, *_ = best
            t += T
            for (Tc, k, p, wc, bc, Ugc, Tal, lam_, m, vstar) in cand:
                pk = pool[k]
                if k == kw and p == pw:
                    continue
                if T >= Tal:
                    pk["V"][:, p] = vstar
                    pk["c"][p] += Ugc * (T - Tal)
                else:
                    m2 = _overlap_after(k, lam_, m, T)
                    v = pk["V"][:, p]
                    perp = v - (v @ vstar) * vstar
                    pn = np.linalg.norm(perp)
                    pk["V"][:, p] = m2 * vstar + (np.sqrt(max(0.0, 1 - m2 * m2)) * perp / pn if pn > 0 else 0)
            Dk = D if kw <= 2 else d
            pool[kw]["V"][:, pw] = self._rand_dir(rng, pool[kw]["V"].shape[0], 1)[:, 0]
            pool[kw]["c"][pw] = 0.0
            sg = np.rint(Uw[:, :Dk] @ w.astype(F32)).astype(np.float64)
            ind = (sg > b).astype(np.float64)
            g = ind if self.gate == 'thr' else np.maximum(sg - b, 0.0)
            nz = np.nonzero(w)[0]
            dep = 1 if nz.max() < d else 2
            wire = None
            if dep < self.depth and D < Uw.shape[1] and 0 < ind.mean() < 1:
                Uw[:, D] = 2 * ind - 1; wire = D; D += 1
            mu, sd = g.mean(), g.std()
            col = (g - mu) / sd
            gates.append((w, b, wire, kw, sd, mu))
            if self.rho is not None:
                # joint ridge readout: alpha = (K + lam_bg I + cg^2 F F^T)^{-1} yt by Woodbury; a = cg^2 F^T alpha
                Bs.append(cg * col); Vs_.append(bg.solve(cg * col))
                Bm = np.stack(Bs, 1); Vm = np.stack(Vs_, 1)
                S = np.eye(len(Bs)) + Bm.T @ Vm
                alpha = u - Vm @ np.linalg.solve(S, Bm.T @ u)
                a = cg * (Bm.T @ alpha)
                f = y - lam_bg * alpha
            else:
                if cols:
                    F = np.stack(cols, 1)
                    gv = F.T @ col
                    Gm = np.block([[Gm, gv[:, None]], [gv[None, :], np.array([[col @ col]])]])
                else:
                    Gm = np.array([[col @ col]])
                Fy = np.append(Fy, col @ (y - c0))
                cols.append(col)
                a = np.linalg.solve(Gm + self.lam * n * np.eye(len(cols)), Fy)
                f = c0 + np.stack(cols, 1) @ a
            err = float(np.mean(np.where(f > 0, 1.0, -1.0) != y))
            trace.append((t, err))
            if t_fit is None and err <= 0.1:
                t_fit = t
            if self.verbose:
                print(f"    gate {len(gates):2d} k={kw} fanin={len(nz):2d} depth={dep} U={Ug:.3f} T={T:.2f} "
                      f"t={t:.2f} train_err={err:.3f}")
        G_ = [(gw, gb, gwire, gsd, gmu) for gw, gb, gwire, _, gsd, gmu in gates]
        a_, c_ = a.copy(), c0
        relu = self.gate != 'thr'
        alpha_ = alpha.copy() if self.rho is not None else None
        bg_ = bg if self.rho is not None else None

        def score(Z):
            Z = np.asarray(Z, dtype=F32)
            W = np.zeros((len(Z), d + len(G_)), dtype=F32); W[:, :d] = Z
            Dz = d
            out = np.full(len(Z), c_)
            for j, (gw, gb, gwire, gsd, gmu) in enumerate(G_):
                sz = np.rint(W[:, :len(gw)] @ gw.astype(F32)).astype(np.float64)
                ind = (sz > gb).astype(np.float64)
                gv = np.maximum(sz - gb, 0.0) if relu else ind
                if gwire is not None:
                    W[:, Dz] = 2 * ind - 1; Dz += 1
                out += a_[j] * (gv - gmu) / gsd
            if bg_ is not None:
                out += bg_.apply(Z, alpha_)
            return out

        return dict(predict=lambda Z: np.where(score(Z) > 0, 1.0, -1.0), score=score,
                    time=float(t_fit if t_fit is not None else t), stop_time=float(t),
                    size=len(gates), trace=trace, orders=[g[3] for g in gates],
                    fanin=[int(np.count_nonzero(g[0])) for g in gates])
