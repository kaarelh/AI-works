"""Ablations of the race model (models/race.py).

RaceAblation(**race_kwargs, **ablation_options) re-implements Race.fit with switches for each ingredient; with all
switches at their defaults it reproduces Race.fit exactly (same random stream, same arithmetic: checked by
run_ablations.py 'base' against the saved race evaluation).  race.py itself is not modified.

Ablation options (defaults = the calibrated race model):
  align   'law'   alignment time from the homogeneous law dm/dt = k U_k m^(k-1) (default)
          'free'  no alignment cost: every unit is at its target direction v* at once (T_align = 0, all orders)
          'free3' no alignment cost for orders >= 3 only (orders 1, 2 keep the law)
          'flat'  order-independent law: every order k >= 2 aligns like k = 2, T = log(1/m)/(2 U_k)
                  (keeps a search cost but removes the D^((k-2)/2) "leap" factor)
  reset   None    dormant units keep their partial alignment and their growth clocks across firings (default)
          'clock' all growth clocks reset to 0 after every firing (overlaps persist)
          'all'   clocks reset and every dormant unit restarts from a fresh random direction after every firing
  greedy  False   race (default).  True: no clocks, no alignment times; each step adds the candidate gate of largest
                  utility U_g (stagewise).  Its clock is the stagewise saddle-to-saddle time, t += theta/U_g per gate.
  stop    'interp' stop at zero training sign error (default);  'none' run to gmax gates.
  oracle  None    (default).  Otherwise a callable (rng, n) -> (X, y) returning a fresh labelled sample: the search
                  statistics are computed on it instead of the training set.  DIAGNOSTIC ONLY - this uses the target
                  inside fit(), so it is not a learning algorithm; it measures how much of n* is set by sampling
                  noise in the search.
  noise   'align'  with an oracle: v* and U_k (direction search + alignment speed) from the fresh sample; the gate's
                   threshold b and utility U_g still from the training set.
          'search' with an oracle: v*, U_k, b and U_g all from the fresh sample (only the readout and the stopping
                   rule see the training set).
Constructor arguments of Race (theta, lam, Q, K, P, iters, gmax, depth, gate, stop_mse) are passed through.

fit() additionally returns 'supports': for each gate the set of input coordinates it depends on (through depth-1
wires), for post-hoc analysis only (true vs spurious gates); and 'gates_at_fit' (number of gates when the training
error first dropped to <= 0.1); 'columns' and 'readouts' (the circuit after every firing, so that the test error
along the trajectory can be computed after fit() has returned).
"""
import numpy as np
from models.race import Race, _order_k, _align_time, _overlap_after, _best_threshold, _best_relu, F32


class RaceAblation(Race):
    def __init__(self, align="law", reset=None, greedy=False, stop="interp", oracle=None, noise="align",
                 name=None, **kw):
        super().__init__(**kw)
        assert align in ("law", "free", "free3", "flat") and reset in (None, "clock", "all")
        assert stop in ("interp", "none") and noise in ("align", "search")
        self.align, self.reset, self.greedy, self.stop, self.oracle, self.noise = align, reset, greedy, stop, oracle, noise
        self.name = name or "race-ablation"
        self._nfit = 0

    def _tal(self, k, lam, m):
        if self.greedy or self.align == "free" or (self.align == "free3" and k >= 3):
            return 0.0
        if self.align == "flat" and k >= 2:
            return _align_time(2, lam, m)
        return _align_time(k, lam, m)

    def _ov(self, k, lam, m, dt):
        if self.align == "flat" and k >= 2:
            return _overlap_after(2, lam, m, dt)
        return _overlap_after(k, lam, m, dt)

    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=F32); y = np.asarray(y, dtype=np.float64)
        n, d = X.shape
        K, P, Q = self.K, self.P, self.Q
        best_gate = _best_threshold if self.gate == 'thr' else _best_relu
        Uw = np.zeros((n, d + self.gmax), dtype=F32)
        Uw[:, :d] = X
        D = d
        orc = self.oracle is not None
        if orc:      # fresh labelled sample for the search statistics (separate random stream)
            self._nfit += 1
            Xf, yf = self.oracle(np.random.default_rng([4242, n, self._nfit]), n)
            Xf = np.asarray(Xf, dtype=F32); yf = np.asarray(yf, dtype=np.float64)
            nf = len(Xf)
            Uwf = np.zeros((nf, d + self.gmax), dtype=F32); Uwf[:, :d] = Xf
            colsf = []
        pool = {1: dict(V=self._rand_dir(rng, d, 1), c=np.zeros(1), sgn=np.ones(1))}
        for k in range(2, K + 1):
            pool[k] = dict(V=self._rand_dir(rng, d, P), c=np.zeros(P),
                           sgn=np.ones(P) if k % 2 else np.where(np.arange(P) % 2 == 0, 1.0, -1.0))
        gates, cols, supports, readouts = [], [], [], []
        wire_support = [frozenset([i]) for i in range(d)]
        Gm = np.zeros((0, 0)); Fy = np.zeros(0)
        c0 = y.mean(); a = np.zeros(0)
        f = np.full(n, c0)
        t = 0.0
        err = float(np.mean(np.where(f > 0, 1.0, -1.0) != y))
        t_fit = 0.0 if err <= 0.1 else None
        g_fit = 0 if err <= 0.1 else None
        trace = [(0.0, err)]
        while len(gates) < self.gmax:
            r64 = y - f
            if np.max(np.abs(r64)) < 1e-9:
                break
            if self.stop == "interp":
                if (err == 0) if self.stop_mse is None else (np.mean(r64 ** 2) < self.stop_mse):
                    break
            r = r64.astype(F32); rbar = float(r.mean())
            U = Uw[:, :D]
            h = (U.T @ r) * F32(1.0 / n)
            if orc:      # search statistics on the fresh sample
                ff = c0 + (np.stack(colsf, 1) @ a if colsf else 0.0)
                rf64 = yf - ff; rf = rf64.astype(F32)
                Us, rs, rsbar = Uwf[:, :D], rf, float(rf.mean())
                hs = (Us.T @ rf) * F32(1.0 / nf)
            else:
                Us, rs, rsbar, hs = U, r, rbar, h
            if orc and self.noise == "search":
                Ug_U, Ug_r = Uwf, rf64 - rf64.mean()
            else:
                Ug_U, Ug_r = Uw, r64 - r64.mean()
            cand = []
            for k in range(1, K + 1):
                pk = pool[k]
                Dk = D if k <= 2 else d
                V = pk["V"]
                if V.shape[0] < Dk:
                    V = np.vstack([V, np.zeros((Dk - V.shape[0], V.shape[1]), F32)]); pk["V"] = V
                Uk_ = Us[:, :Dk]; hk = hs[:Dk]
                if k == 1:
                    lam1 = float(np.linalg.norm(hk))
                    if lam1 <= 0:
                        continue
                    Vs = (hk / lam1)[:, None]; lamv = np.array([lam1])
                else:
                    Vs = V.copy()
                    for _ in range(self.iters):
                        _, G = _order_k(Uk_, rs, Vs, k, hk, rsbar)
                        G = G * pk["sgn"].astype(F32)
                        nr = np.linalg.norm(G, axis=0); nr[nr == 0] = 1.0
                        Vs = G / nr
                    Ukv, _ = _order_k(Uk_, rs, Vs, k, hk, rsbar, need_grad=False)
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
                    s = Ug_U[:, :Dk] @ w.astype(F32)
                    Ug, b = best_gate(np.rint(s).astype(np.int64), Ug_r)
                    if b is None or Ug <= 1e-9:
                        continue
                    Tal = self._tal(k, lamv[p], mv[p])
                    if self.greedy:
                        T = self.theta / Ug
                    else:
                        T = Tal + max(0.0, self.theta - pk["c"][p]) / Ug
                    cand.append((T, k, p, w, b, Ug, Tal, float(lamv[p]), float(mv[p]), v))
            if not cand:
                break
            best = min(cand, key=lambda z: z[0])
            T, kw, pw, w, b, Ug, *_ = best
            t += T
            for (Tc, k, p, wc, bc, Ugc, Tal, lam, m, vstar) in cand:
                pk = pool[k]
                if k == kw and p == pw:
                    continue
                if self.greedy or T >= Tal:
                    pk["V"][:, p] = vstar
                    pk["c"][p] += Ugc * (T - Tal)
                else:
                    m2 = self._ov(k, lam, m, T)
                    v = pk["V"][:, p]
                    perp = v - (v @ vstar) * vstar
                    pn = np.linalg.norm(perp)
                    pk["V"][:, p] = m2 * vstar + (np.sqrt(max(0.0, 1 - m2 * m2)) * perp / pn if pn > 0 else 0)
            Dk = D if kw <= 2 else d
            pool[kw]["V"][:, pw] = self._rand_dir(rng, pool[kw]["V"].shape[0], 1)[:, 0]
            pool[kw]["c"][pw] = 0.0
            if self.reset is not None:
                for k in pool:
                    pool[k]["c"][:] = 0.0
                    if self.reset == "all":
                        pool[k]["V"] = self._rand_dir(rng, pool[k]["V"].shape[0], pool[k]["V"].shape[1])
            sg = np.rint(Uw[:, :Dk] @ w.astype(F32)).astype(np.float64)
            ind = (sg > b).astype(np.float64)
            g = ind if self.gate == 'thr' else np.maximum(sg - b, 0.0)
            nz = np.nonzero(w)[0]
            dep = 1 if nz.max() < d else 2
            sup = frozenset().union(*[wire_support[j] for j in nz])
            wire = None
            if dep < self.depth and D < Uw.shape[1] and 0 < ind.mean() < 1:
                Uw[:, D] = 2 * ind - 1; wire = D; D += 1
                wire_support.append(sup)
            mu, sd = g.mean(), g.std()
            col = (g - mu) / sd
            if orc:
                sgf = np.rint(Uwf[:, :Dk] @ w.astype(F32)).astype(np.float64)
                indf = (sgf > b).astype(np.float64)
                gf = indf if self.gate == 'thr' else np.maximum(sgf - b, 0.0)
                if wire is not None:
                    Uwf[:, wire] = 2 * indf - 1
                colsf.append((gf - mu) / sd)
            if cols:
                F = np.stack(cols, 1)
                gv = F.T @ col
                Gm = np.block([[Gm, gv[:, None]], [gv[None, :], np.array([[col @ col]])]])
            else:
                Gm = np.array([[col @ col]])
            Fy = np.append(Fy, col @ (y - c0))
            cols.append(col)
            gates.append((w, b, wire, kw, sd, mu))
            supports.append(sup)
            a = np.linalg.solve(Gm + self.lam * n * np.eye(len(cols)), Fy)
            f = c0 + np.stack(cols, 1) @ a
            readouts.append(a.copy())
            err = float(np.mean(np.where(f > 0, 1.0, -1.0) != y))
            trace.append((t, err))
            if t_fit is None and err <= 0.1:
                t_fit = t; g_fit = len(gates)
        G_ = [(gw, gb, gwire, gsd, gmu) for gw, gb, gwire, _, gsd, gmu in gates]
        a_, c_ = a.copy(), c0
        relu = self.gate != 'thr'

        def predict(Z):
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
            return np.where(out > 0, 1.0, -1.0)

        def columns(Z):
            """Standardised gate outputs (m, #gates) on Z: with readouts[j] they give the circuit after j+1 gates."""
            Z = np.asarray(Z, dtype=F32)
            W = np.zeros((len(Z), d + len(G_)), dtype=F32); W[:, :d] = Z
            Dz = d; out = np.zeros((len(Z), len(G_)))
            for j, (gw, gb, gwire, gsd, gmu) in enumerate(G_):
                sz = np.rint(W[:, :len(gw)] @ gw.astype(F32)).astype(np.float64)
                ind = (sz > gb).astype(np.float64)
                gv = np.maximum(sz - gb, 0.0) if relu else ind
                if gwire is not None:
                    W[:, Dz] = 2 * ind - 1; Dz += 1
                out[:, j] = (gv - gmu) / gsd
            return out

        return dict(predict=predict, time=float(t_fit if t_fit is not None else t), stop_time=float(t),
                    columns=columns, readouts=readouts, c0=c_,
                    size=len(gates), trace=trace, orders=[g[3] for g in gates],
                    fanin=[int(np.count_nonzero(g[0])) for g in gates], supports=supports,
                    gates_at_fit=g_fit if g_fit is not None else len(gates))
