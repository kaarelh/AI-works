"""Race + kernel background ("hybrid"): the race model's grown gates plus a kernel-regression background in the readout.

Run with OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 (see race.py).

PICTURE  a trained network = a random-feature (kernel) background + a few grown features, read out jointly.
    The background is the infinite-width NNGP kernel K of the networks' architecture at initialisation (two ReLU hidden
    layers, models/baselines.py), normalised to unit diagonal.  The grown features are the race model's gates
    (models/race.py: unchanged search / alignment / growth / firing rules and constants theta = 1.5, lam = 1e-3, Q = 3,
    gate = 'relu').

READOUT  at race time t the readout is the joint ridge fit
        min_{a, f_bg}  |y - c - F a - f_bg|^2  +  lam_g |a|^2  +  lam_bg(t) |f_bg|^2_K ,
    F the standardised gate columns (as in the race), lam_g = lam * n (the race's own readout ridge), c = mean(y).
    Equivalently kernel ridge regression with kernel K + (lam_bg / lam_g) F F^T and ridge lam_bg.  The race sees the
    residual of this joint fit, so the background competes with gate growth.

BACKGROUND SCHEDULE  (new constant 1: c_bg)
    mode 'flow' (the model):   lam_bg(t) = c_bg * n / t.
        Kernel gradient flow on the mean square loss, run on the race clock: after time t, kernel GD has fitted the
        residual's components along kernel eigenvalues kappa >~ n / (eta t) (the spectral cut-off of early-stopped kernel
        regression); to first order fixed-time kernel GD is ridge regression with lam ~ n / (eta t), and c_bg = 1 / eta is
        the background's slowness relative to the race clock.  Consequences: components with a large population
        eigenvalue (the target's degree-0/1 part) are fitted by the background early; the training-sample noise lives on
        the many small eigenvalues (kappa ~ 0.3-0.5 per training point, whatever n) and is memorised once
        t >~ c_bg * n / 0.4 -- before dense memorising gates can fire on small training sets, after the real features
        have fired on large ones.  t = 0: no background (the race's readout).
    mode 'static' (ablation):  lam_bg = rho * n ** beta, constant in time.
    mode 'none': the race model exactly (checks that the shared code reproduces models/race.py).
STOP  (new constant 2: stop_mse)  gates are grown while the joint fit's training mean squared residual is >= stop_mse
    (stop_mse = None: while the training sign error is > 0, the race's rule).  In mode 'flow' the condition is checked
    continuously in time: if the background reaches it before the next gate would fire, growth stops at that time
    (bisection in log t).  Also stop after gmax gates or when no candidate is left.  The race's sign-error rule stops
    growth too early once a background is present: the background's degree-1 fit alone often classifies the training
    set (e.g. MAJ_3), while the networks go on to grow the feature that removes the remaining square loss.
END OF TRAINING  growth has stopped but training goes on: the gate weights are kept and the background interpolates
    what is left, kernel ridge on y - c - F a with the NNGP baseline's ridge (1e-4, unit-diagonal kernel; models/baselines.py).
CALIBRATED SETTING  HYBRID_DEFAULTS: c_bg = 0.003, stop_mse = 0.03 (chosen on common.CALIB only, by CALIB per-example
    agreement minus CALIB mean |log2 n* ratio|; study/HYBRID.md section 2).

LARGE n  for n > n_exact the background kernel is replaced by M random ReLU features of a fresh two-hidden-layer
    network at initialisation (widths M, M; a Monte-Carlo approximation of the same kernel, of rank M); their random
    draws are seeded from the data, so the race's own random stream is unchanged.

ALGEBRA  K = E diag(ev) E^T (eigendecomposition once per fit; random features: from their M x M Gram matrix).  With
    w = ev / (ev + lam) and Pi = I - E diag(w) E^T  (= lam (K + lam I)^{-1}):
        a = (F^T Pi F + lam_g I)^{-1} F^T Pi y~,     training residual r = Pi (y~ - F a),
    each O(n * rank + n * m^2) given E^T F and E^T y~ (y~ = y - c);  test predictions add K(x, X) r / lam.
"""
import zlib
import numpy as np
from models.race import _order_k, _align_time, _overlap_after, _best_threshold, _best_relu
from models.baselines import nngp_table

F32 = np.float32
HYBRID_DEFAULTS = dict(mode="flow", c_bg=0.003, stop_mse=0.03)      # calibrated on CALIB (study/HYBRID.md)


class _Background:
    """Unit-diagonal NNGP kernel on the training set, as an eigendecomposition (exact) or rank-M random features."""

    def __init__(self, X, n_exact, M, seed):
        self.X = X; n, d = X.shape; self.d = d
        self.table = (nngp_table(d) / nngp_table(d)[-1]).astype(np.float64)
        self.exact = n <= n_exact
        if self.exact:
            ev, E = np.linalg.eigh(self.gram(X))
            self.ev, self.E = np.maximum(ev, 0.0), E
        else:
            rng = np.random.default_rng(seed)
            self.W1 = rng.standard_normal((M, d)).astype(F32) / np.sqrt(d)
            self.W2 = rng.standard_normal((M, M)).astype(F32) / np.sqrt(M)
            self.scale = None
            Pf = self.feats(X); self.P = Pf
            s2, V = np.linalg.eigh(Pf.T @ Pf)
            keep = s2 > 1e-9 * s2.max()
            self.ev = s2[keep]; self.E = Pf @ (V[:, keep] / np.sqrt(self.ev))

    def gram(self, Z):
        return self.table[((np.asarray(Z, F32) @ self.X.T).astype(np.int64) + self.d) // 2]

    def feats(self, Z):
        h1 = np.maximum(np.asarray(Z, F32) @ self.W1.T, 0)
        h2 = np.maximum(h1 @ self.W2.T, 0).astype(np.float64)
        if self.scale is None:          # normalise to unit mean diagonal, like the exact kernel
            self.scale = 1.0 / np.sqrt(np.mean(np.sum(h2 * h2, 1)))
        return h2 * self.scale

    def apply(self, Z, v):
        """K(Z, X) v."""
        Z = np.asarray(Z, F32)
        if self.exact:
            return np.concatenate([self.gram(Z[i:i + 2048]) @ v for i in range(0, len(Z), 2048)])
        return self.feats(Z) @ (self.P.T @ v)


class _NoBackground:
    def __init__(self, n):
        self.ev = np.zeros(0); self.E = np.zeros((n, 0))


class _JointReadout:
    """Joint ridge readout over the background and the gates, for any background ridge lam (lam = inf: gates only)."""

    def __init__(self, bg, yt, lam_g):
        self.bg, self.yt, self.lam_g = bg, yt, lam_g
        self.ye = bg.E.T @ yt
        self.F = np.zeros((len(yt), 0)); self.Fe = np.zeros((len(bg.ev), 0))
        self.FtF = np.zeros((0, 0)); self.Fty = np.zeros(0)

    def add(self, col):
        self.FtF = np.block([[self.FtF, (self.F.T @ col)[:, None]], [(col @ self.F)[None, :], np.array([[col @ col]])]])
        self.Fty = np.append(self.Fty, col @ self.yt)
        self.F = np.column_stack([self.F, col]); self.Fe = np.column_stack([self.Fe, self.bg.E.T @ col])

    def fit(self, lam):
        """Gate weights a and training residual r = y~ - F a - f_bg at background ridge lam."""
        m = self.F.shape[1]
        if not np.isfinite(lam):
            a = np.linalg.solve(self.FtF + self.lam_g * np.eye(m), self.Fty) if m else np.zeros(0)
            return a, self.yt - self.F @ a
        w = self.bg.ev / (self.bg.ev + lam)
        if m:
            G = self.FtF - self.Fe.T @ (w[:, None] * self.Fe)
            h = self.Fty - self.Fe.T @ (w * self.ye)
            a = np.linalg.solve(G + self.lam_g * np.eye(m), h)
            ze = self.ye - self.Fe @ a
        else:
            a = np.zeros(0); ze = self.ye
        return a, (self.yt - self.F @ a) - self.bg.E @ (w * ze)


class Hybrid:
    name = "hybrid"

    def __init__(self, mode="flow", c_bg=0.003, rho=None, beta=1.0, theta=1.5, lam=1e-3, Q=3, K=4, P=8, iters=8, gmax=48,
                 depth=2, gate='relu', n_exact=2048, M=512, bisect=10, final_ridge=1e-4, stop_mse=0.03, verbose=False):
        self.mode = mode
        self.stop_mse = None if stop_mse is None else float(stop_mse)
        self.final_ridge = None if final_ridge is None else float(final_ridge)
        self.c_bg = None if c_bg is None else float(c_bg)
        self.rho = None if rho is None else float(rho)
        self.beta = float(beta)
        self.theta, self.lam, self.Q, self.K, self.P = float(theta), float(lam), int(Q), int(K), int(P)
        self.iters, self.gmax, self.depth, self.gate, self.verbose = int(iters), int(gmax), int(depth), gate, verbose
        self.n_exact, self.M, self.bisect = int(n_exact), int(M), int(bisect)

    def _lam_bg(self, t, n):
        if self.mode == "static":
            return np.inf if self.rho is None else self.rho * n ** self.beta
        if self.mode == "flow":
            return np.inf if (self.c_bg is None or t <= 0) else self.c_bg * n ** self.beta / t
        if self.mode == "none":
            return np.inf
        raise ValueError(self.mode)

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
        gates = []
        c0 = y.mean(); yt = y - c0
        use_bg = self.mode != "none" and (self.c_bg is not None if self.mode == "flow" else self.rho is not None)
        bg = _Background(X, self.n_exact, self.M, zlib.crc32(X.tobytes())) if use_bg else _NoBackground(n)
        RO = _JointReadout(bg, yt, self.lam * n)

        def state(t):
            lam_bg = self._lam_bg(t, n) if use_bg else np.inf
            a, r = RO.fit(lam_bg)
            return a, r, lam_bg, float(np.mean(np.where(y - r > 0, 1.0, -1.0) != y))

        def done(st):
            """Growth stops at training sign error 0 (stop_mse None, as in the race) or training MSE < stop_mse."""
            return st[3] == 0 if self.stop_mse is None else float(np.mean(st[1] ** 2)) < self.stop_mse

        def first_time(lo, hi, ok):
            """Earliest time in (lo, hi] at which ok(state) holds, by bisection in log t (ok(hi) assumed)."""
            for _ in range(self.bisect):
                mid = np.sqrt(lo * hi) if lo > 0 else hi / 4
                if ok(state(mid)):
                    hi = mid
                else:
                    lo = mid
            return hi

        t = 0.0
        a, r_res, lam_now, err = state(t)
        t_fit = 0.0 if err <= 0.1 else None
        trace = [(0.0, err)]
        while len(gates) < self.gmax and not done((a, r_res, lam_now, err)):
            r64 = r_res
            if np.max(np.abs(r64)) < 1e-9:
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
            if use_bg and self.mode == "flow":
                # the background keeps fitting while the next gate grows: stop if it reaches sign error 0 first
                st2 = state(t + T)
                if t_fit is None and st2[3] <= 0.1:
                    t_fit = first_time(t, t + T, lambda st: st[3] <= 0.1)
                if done(st2):
                    t = first_time(t, t + T, done)
                    a, r_res, lam_now, err = state(t)
                    trace.append((t, err))
                    break
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
            gates.append((w, b, wire, kw, sd, mu))
            RO.add((g - mu) / sd)
            a, r_res, lam_now, err = state(t)
            trace.append((t, err))
            if t_fit is None and err <= 0.1:
                t_fit = t
            if self.verbose:
                print(f"    gate {len(gates):2d} k={kw} fanin={len(nz):2d} depth={dep} U={Ug:.3f} T={T:.2f} "
                      f"t={t:.2f} lam_bg={lam_now:.3g} train_err={err:.3f}")
        G_ = [(gw, gb, gwire, gsd, gmu) for gw, gb, gwire, _, gsd, gmu in gates]
        a_, c_ = a.copy(), c0
        relu = self.gate != 'thr'
        alpha_ = r_res / lam_now if (use_bg and np.isfinite(lam_now)) else None
        if use_bg and self.mode == "flow" and self.final_ridge is not None:
            # growth has stopped; training goes on: gate weights stay, the background interpolates what is left
            # (kernel ridge with the NNGP baseline's ridge on the residual y~ - F a)
            z = yt - RO.F @ a_ if len(a_) else yt.copy()
            ze = bg.E.T @ z; lf = self.final_ridge
            alpha_ = bg.E @ (ze / (bg.ev + lf)) + (z - bg.E @ ze) / lf
            lam_now = lf

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
            if alpha_ is not None:
                out += bg.apply(Z, alpha_)
            return out

        return dict(predict=lambda Z: np.where(score(Z) > 0, 1.0, -1.0), score=score,
                    time=float(t_fit if t_fit is not None else t), stop_time=float(t), lam_bg=float(lam_now),
                    size=len(gates), trace=trace, orders=[g[3] for g in gates],
                    fanin=[int(np.count_nonzero(g[0])) for g in gates])
