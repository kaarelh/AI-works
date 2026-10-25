"""Utility-race learner ("race"): the README's grow-and-refit race, run on a finite training set.

Run with OPENBLAS_NUM_THREADS=1 (or OMP_NUM_THREADS=1) on a shared machine: the work is many small
matrix products, and threaded BLAS under contention is ~30x slower.

LEARNED OBJECT (explicit finite library, so circuit-size / Occam bounds apply)
    wires     u_1..u_D : the d input literals (+-1), then each depth-1 gate as a +-1 wire (2g - 1).
    gate      g(x) = 1[ sum_j w_j u_j(x) > b ]: a Boolean threshold unit, the discrete version of one hidden
              ReLU unit on top of the previous layer.  Integer weights w_j in {-Q..Q}, threshold b in
              (1/2 + Z) with |b| <= Q*D.  Depth 1 = reads only literals; depth 2 = reads >= 1 depth-1 gate
              (two hidden layers, as in the networks).  Fan-in = number of nonzero w_j.
    readout   f(x) = c + sum_g a_g (g(x) - mean_S g)/std_S g, ridge least squares (penalty lam*n*|a|^2, c free),
              refitted after every firing; prediction sign(f).
    library   per gate at most (2Q+1)^D * (2QD+1) choices, D <= d + #depth-1 gates (<= 30 + 48), so a circuit
              of s gates costs <= s * (D log(2Q+1) + log(2QD+1)) nats + s+1 reals.  The found gates are sparse
              (fan-in = the target's relevant variables) when n is large and dense at small n; the returned
              'fanin' list gives the actual fan-ins, so a fan-in-aware bound can use
              log C(D, fanin) + fanin*log(2Q) + log(2Q*fanin+1) nats per gate instead.

DYNAMICS (an event-driven race of persistent dormant units, Alternating-Gradient-Flow style)
    A pool of dormant "proto-units" persists across firings, like a network's not-yet-used hidden units:
    1 unit of order 1 and P units of each order k = 2..K.  A unit has a direction v (unit vector over the
    wires it reads; orders 1-2 read all wires, orders >= 3 read literals) and a growth clock c.
    * Search (alignment).  The order-k part of a unit's small-weight utility is U_k(v) m^k with
          U_k(v) = E_S[ r * e_k(v_1 u_1, ..., v_D u_D) ],   r = y - f the training residual,
      e_k the elementary symmetric polynomial (the multilinear degree-k part of the unit's output).
      The unit is heading to v* = the end point of normalised (tensor) power iteration  v <- grad U_k(v)/|.|
      started at its current v (k = 1: the Hebbian direction E_S[r u]; k = 2: top eigenvector of the
      residual-weighted wire covariance).  Its overlap m = |v.v*| grows by the homogeneous law
      dm/dt = k U_k(v*) m^(k-1), so the time left to align is
          k = 1: (1 - m)/U_k     k = 2: log(1/m)/(2 U_k)     k >= 3: (m^-(k-2) - 1)/(k (k-2) U_k);
      a fresh random unit has m ~ D^-1/2, so a degree-k "leap" costs ~D^((k-2)/2)/U_k: the fresh-chain
      law of the README with alpha_eff = D^-1/2.  On finite data the noise in the empirical moments
      decides whether a unit reaches the true feature or a spurious (memorising) direction.
    * Growth.  v* rounded to integer weights w = round(Q v*/max|v*|), threshold b chosen to maximise the
      utility U_g = |E_S[r (g - mean g)]|/std(g) (correlation of the unit-variance gate with r).  After
      alignment the clock grows at rate U_g (log-norm growth of in-weight x out-weight); the unit fires
      when c reaches theta = log(1/alpha).
    * Race.  The unit with the smallest time-to-fire T = T_align + max(0, theta - c)/U_g fires; the race
      clock advances by T; every other unit moves along its trajectory for that time (overlap update,
      clock += U_g * time spent aligned); the fired gate joins the circuit, its unit is replaced by a
      fresh random one, the readout is refitted and the residual recomputed.
    * Stop at training sign error 0 (interpolation) or after gmax gates.

OUTPUTS  'size' = number of gates; 'time' = race-clock time at which the training error first drops to
<= 0.1 (time to fit; compared with the NN's steps-to-generalise); 'stop_time'; 'fanin', 'orders', 'trace'.

GLOBAL HYPERPARAMETERS (calibrated on common.CALIB only): theta = log(1/alpha), lam, Q.
Fixed structural constants: K = 4, P = 8, power-iteration steps per firing = 8, gmax = 48, depth <= 2.
"""
import numpy as np

F32 = np.float32


def _esym(Z, P3, s2, s4, k):
    """Elementary symmetric polynomials e_1..e_k of (v_i u_i) for +-1 wires, via Newton's identities.
    Z = U V = p1 (n,P); P3 = U V^3 = p3; s2 = sum v^2 = p2 (P,); s4 = sum v^4 = p4."""
    e = [None, Z]
    if k >= 2:
        e.append((Z * Z - s2) * F32(0.5))
    if k >= 3:
        e.append((e[2] * Z - Z * s2 + P3) * F32(1 / 3))
    if k >= 4:
        e.append((e[3] * Z - e[2] * s2 + Z * P3 - s4) * F32(0.25))
    return e


def _order_k(U, r, V, k, h, rbar, need_grad=True):
    """U_k(V) (P,) and its gradient (D,P) for +-1 wires U (n,D), residual r (n,).
    grad_i = sum_j (-1)^j v_i^j E[r u_i^(j+1) e_(k-1-j)],  u_i^(j+1) = u_i (j even) or 1 (j odd)."""
    n = U.shape[0]
    Z = U @ V
    s2 = np.sum(V * V, 0)
    P3 = U @ (V ** 3) if k >= 3 else None
    s4 = np.sum(V ** 4, 0) if k >= 4 else None
    e = _esym(Z, P3, s2, s4, k)
    rc = r[:, None]
    Uk = (rc * e[k]).mean(0)
    if not need_grad:
        return Uk, None
    G = np.zeros_like(V)
    for j in range(k):
        m = k - 1 - j
        if j % 2 == 0:
            A = h[:, None] if m == 0 else (U.T @ (rc * e[m])) * F32(1.0 / n)
        else:
            A = F32(rbar) if m == 0 else (rc * e[m]).mean(0)[None, :]
        G += ((-1) ** j) * (V ** j) * A if j else A
    return Uk, G


def _align_time(k, lam, m):
    lam = max(float(lam), 1e-12)
    m = float(np.clip(m, 1e-6, 1.0))
    if m >= 1.0:
        return 0.0
    if k == 1:
        return (1 - m) / lam
    if k == 2:
        return np.log(1 / m) / (2 * lam)
    return (m ** (-(k - 2)) - 1) / (k * (k - 2) * lam)


def _overlap_after(k, lam, m, dt):
    m = float(np.clip(m, 1e-6, 1.0))
    x = k * lam * dt
    if k == 1:
        return min(1.0, m + lam * dt)
    if k == 2:
        return min(1.0, m * np.exp(min(2 * lam * dt, 50.0)))
    q = m ** (-(k - 2)) - (k - 2) * x
    return 1.0 if q <= 1.0 else q ** (-1.0 / (k - 2))


def _best_threshold(s, r):
    """s (n,) integer gate pre-activations, r (n,) centred residual.  Best b for g = 1[s > b] maximising
    |E[r g]|/std(g).  Returns (U_g, b)."""
    n = len(s)
    lo = int(s.min())
    idx = (s - lo).astype(np.int64)
    cnt = np.bincount(idx)
    if len(cnt) < 2:
        return 0.0, None
    rs = np.bincount(idx, weights=r)
    c = np.cumsum(cnt[::-1])[::-1][1:].astype(float)      # #(idx >= t), t = 1..
    sr = np.cumsum(rs[::-1])[::-1][1:]
    p = c / n
    ok = (c > 0) & (c < n)
    util = np.where(ok, np.abs(sr) / n / np.sqrt(np.maximum(p * (1 - p), 1e-12)), -1.0)
    t = int(np.argmax(util))
    if util[t] <= 0:
        return 0.0, None
    return float(util[t]), lo + t + 0.5


def _best_relu(s, r):
    """Best b for g = relu(s - b), b in {lo - 1/2, lo + 1/2, ..., hi - 1/2} (b < lo: the linear unit s),
    maximising |E[r g]|/std(g).  s integer (n,), r centred residual (n,).  Returns (U_g, b)."""
    n = len(s)
    lo = int(s.min())
    idx = (s - lo).astype(np.int64)
    sv = s.astype(np.float64)
    cnt = np.bincount(idx).astype(float)
    if len(cnt) < 2:
        return 0.0, None
    L = len(cnt)
    def top(wt):                      # top[t] = sum over idx >= t, t = 0..L-1
        return np.cumsum(np.bincount(idx, weights=wt, minlength=L)[::-1])[::-1]
    C = np.cumsum(cnt[::-1])[::-1]; S1 = top(sv); S2 = top(sv * sv); A0 = top(r); A1 = top(r * sv)
    b = lo + np.arange(L) - 0.5       # active iff idx >= t  <=>  s > b_t
    cov = (A1 - b * A0) / n
    var = (S2 - 2 * b * S1 + b * b * C) / n - ((S1 - b * C) / n) ** 2
    ok = (C > 0) & (var > 1e-9)
    util = np.where(ok, np.abs(cov) / np.sqrt(np.maximum(var, 1e-12)), -1.0)
    t = int(np.argmax(util))
    if util[t] <= 0:
        return 0.0, None
    return float(util[t]), float(b[t])


class Race:
    name = "race"

    def __init__(self, theta=3.0, lam=1e-3, Q=3, K=4, P=8, iters=8, gmax=48, depth=2, stop_mse=None, gate='thr', verbose=False,
                 csq=None):
        # csq (optional, default off): an order-k >= 2 unit can follow its aligned direction only if the signal of the
        # empirical utility at its current overlap, lam * m^(k-1), exceeds the sampling noise csq / sqrt(n) along it.
        # From m ~ D^-1/2 this is the correlational-SQ law n >~ csq^2 D^(k-1) / lam^2 (see study/DSCALE.md).
        self.csq = None if csq is None else float(csq)
        self.theta, self.lam, self.Q, self.K, self.P = float(theta), float(lam), int(Q), int(K), int(P)
        self.iters, self.gmax, self.depth, self.verbose = int(iters), int(gmax), int(depth), verbose
        self.stop_mse = stop_mse
        self.gate = gate

    def _rand_dir(self, rng, D, P):
        V = rng.standard_normal((D, P)).astype(F32)
        return V / np.linalg.norm(V, axis=0)

    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=F32); y = np.asarray(y, dtype=np.float64)
        n, d = X.shape
        K, P, Q = self.K, self.P, self.Q
        Uw = np.zeros((n, d + self.gmax), dtype=F32)       # all wires (literals, depth-1 gates)
        Uw[:, :d] = X
        D = d                                              # number of wires in use
        # proto-unit pool: list of dicts per order
        pool = {1: dict(V=self._rand_dir(rng, d, 1), c=np.zeros(1), sgn=np.ones(1))}
        for k in range(2, K + 1):
            pool[k] = dict(V=self._rand_dir(rng, d, P), c=np.zeros(P),
                           sgn=np.ones(P) if k % 2 else np.where(np.arange(P) % 2 == 0, 1.0, -1.0))
        gates, cols = [], []
        Gm = np.zeros((0, 0)); Fy = np.zeros(0)
        c0 = y.mean(); a = np.zeros(0)
        f = np.full(n, c0)
        t = 0.0
        err = float(np.mean(np.where(f > 0, 1.0, -1.0) != y))
        t_fit = 0.0 if err <= 0.1 else None
        trace = [(0.0, err)]
        while len(gates) < self.gmax:
            r64 = y - f
            if np.max(np.abs(r64)) < 1e-9:
                break
            if (err == 0) if self.stop_mse is None else (np.mean(r64 ** 2) < self.stop_mse):
                break
            r = r64.astype(F32); rbar = float(r.mean())
            U = Uw[:, :D]
            h = (U.T @ r) * F32(1.0 / n)
            cand = []    # (T, k, p, w, b, Ug, Tal, lam, m, vstar)
            for k in range(1, K + 1):
                pk = pool[k]
                Dk = D if k <= 2 else d
                V = pk["V"]
                if V.shape[0] < Dk:            # new wires appeared: extend directions with zeros
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
                    if self.csq is not None and k >= 2 and lamv[p] * mv[p] ** (k - 1) < self.csq / np.sqrt(n):
                        continue
                    Tal = _align_time(k, lamv[p], mv[p])
                    T = Tal + max(0.0, self.theta - pk["c"][p]) / Ug
                    cand.append((T, k, p, w, b, Ug, Tal, float(lamv[p]), float(mv[p]), v))
            if not cand:
                break
            best = min(cand, key=lambda z: z[0])
            T, kw, pw, w, b, Ug, *_ = best
            t += T
            # move every unit along its trajectory for time T
            for (Tc, k, p, wc, bc, Ugc, Tal, lam, m, vstar) in cand:
                pk = pool[k]
                if k == kw and p == pw:
                    continue
                if T >= Tal:
                    pk["V"][:, p] = vstar
                    pk["c"][p] += Ugc * (T - Tal)
                else:
                    m2 = _overlap_after(k, lam, m, T)
                    v = pk["V"][:, p]
                    perp = v - (v @ vstar) * vstar
                    pn = np.linalg.norm(perp)
                    pk["V"][:, p] = m2 * vstar + (np.sqrt(max(0.0, 1 - m2 * m2)) * perp / pn if pn > 0 else 0)
            # winner: becomes a gate; its unit is replaced by a fresh one
            Dk = D if kw <= 2 else d
            pool[kw]["V"][:, pw] = self._rand_dir(rng, pool[kw]["V"].shape[0], 1)[:, 0]
            pool[kw]["c"][pw] = 0.0
            sg = np.rint(Uw[:, :Dk] @ w.astype(F32)).astype(np.float64)
            ind = (sg > b).astype(np.float64)                # Boolean firing pattern (wire for depth 2)
            g = ind if self.gate == 'thr' else np.maximum(sg - b, 0.0)
            nz = np.nonzero(w)[0]
            dep = 1 if nz.max() < d else 2
            wire = None
            if dep < self.depth and D < Uw.shape[1] and 0 < ind.mean() < 1:
                Uw[:, D] = 2 * ind - 1; wire = D; D += 1
            mu, sd = g.mean(), g.std()
            col = (g - mu) / sd
            # incremental Gram update
            if cols:
                F = np.stack(cols, 1)
                gv = F.T @ col
                Gm = np.block([[Gm, gv[:, None]], [gv[None, :], np.array([[col @ col]])]])
            else:
                Gm = np.array([[col @ col]])
            Fy = np.append(Fy, col @ (y - c0))
            cols.append(col)
            gates.append((w, b, wire, kw, sd, mu))
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

        return dict(predict=predict, time=float(t_fit if t_fit is not None else t), stop_time=float(t),
                    size=len(gates), trace=trace, orders=[g[3] for g in gates],
                    fanin=[int(np.count_nonzero(g[0])) for g in gates])
