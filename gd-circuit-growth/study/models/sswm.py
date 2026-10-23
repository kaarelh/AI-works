"""SSWM circuit learner: strong-selection / weak-mutation evolution of ONE shared Boolean circuit.

State
    A circuit of gates over the d input literals.  Gate library (fan-in <= 2, explicit and finite):
        BUF(x_i)                      reads one input literal                         (d choices)
        AND(s*u, t*v), s,t in {+1,-1} reads two wires (literals or earlier gates)    (4 sign patterns)
        XOR(u, v)                     reads two wires                                 (1 type)
    so 6 gate types; up to output negation (absorbed by the readout) the 2-input types are every
    Boolean function of two wires that depends on both.  A wire is an input literal or an earlier gate.
    Readout: f(x) = c + sum_j a_j g_j(x) over all gates, fitted by ridge least squares (penalty lam on
    the a_j, not on c) after every move; prediction sign(f).
    Description length of a circuit with m gates: each gate is one of 6 types with <= 2 inputs chosen
    among <= d + m wires, i.e. <= m * log2(6 (d+m)^2) bits plus the real readout (m+1 numbers).

Dynamics (one proposal per clock tick; 'time' counts proposals)
    Each tick draws one random local mutation of the current circuit:
        add      one fresh gate of a random type on random wires                          weight 1
        chain    two fresh gates in series, g2 = op2(op1(u, v), z)                        weight eps
        chain3   three fresh gates, op3(op1(u, v), op2(z, w))                             weight eps^2
        rewire   one input of a random leaf gate to a random (earlier) wire               weight 1/2
        retype   a random leaf gate's type                                                weight 1/4
        delete   a random leaf gate                                                       weight 1/4
    Each input slot of a new or rewired gate reads an input literal with prob 1/2 (uniform among d),
    else an existing gate (uniform among the gates), so a specific move needing k fresh gates and
    j specific wires has proposal probability ~ eps^(k-1) * (const/d)^j: the per-fresh-gate penalty
    eps plays the role of alpha in the GD race (rate ~ alpha^(k-2) per extra fresh layer).
    Selection: keep the mutation iff it lowers the fitness  F = J + theta * (#gates),
        J = min_{c,a} sum_i (y_i - f(x_i))^2 + lam * |a|^2      (readout refitted exactly),
    i.e. an added gate must lower the refitted training loss by more than theta, and a gate may be
    deleted if that raises it by less than theta.  Neutral and deleterious mutations are lost
    (strong selection, weak mutation: one mutation is resolved before the next is proposed).
    The run stops after T proposals.

Hyperparameters (global, calibrated on common.CALIB only): theta, eps, lam, T.

Implementation: exact SSWM semantics, simulated in vectorized batches.  Each batch of proposals is
screened with a lower bound on its gain (the gain if the candidate were orthogonal to the current
features, i.e. the first-order utility (r.g)^2/|g|^2), the first candidate in proposal order that passes
the screen is checked exactly (block-inverse ridge update), and the batch is discarded after an
accepted move, so every proposal is judged against the circuit current at its time.
"""
import numpy as np

# gate types: 0 BUF, 1..4 AND with sign patterns, 5 XOR.  g = c0 + c1 u + c2 v + c3 u v
_COEF = np.array([
    [0.0, 1.0, 0.0, 0.0],      # BUF(u)
    [-0.5, 0.5, 0.5, 0.5],     # AND(u, v)
    [-0.5, 0.5, -0.5, -0.5],   # AND(u, -v)
    [-0.5, -0.5, 0.5, -0.5],   # AND(-u, v)
    [-0.5, -0.5, -0.5, 0.5],   # AND(-u, -v)
    [0.0, 0.0, 0.0, 1.0],      # XOR(u, v)
], dtype=np.float32)
_NAMES = ["BUF", "AND", "AND~", "~AND", "~AND~", "XOR"]


def _apply(t, U, V):
    """Gate outputs for type array t (B,) on input rows U, V (B, n)."""
    c = _COEF[t]
    return c[:, :1] + c[:, 1:2] * U + c[:, 2:3] * V + c[:, 3:4] * (U * V)


class SSWM:
    name = "sswm"
    LIB_TYPES = 6
    MAX_FANIN = 2

    def __init__(self, theta=1.0, eps=0.05, lam=0.5, T=20000, batch=256, mix=None, verbose=False):
        self.theta, self.eps, self.lam, self.T = float(theta), float(eps), float(lam), int(T)
        self.batch = batch
        # relative weights of move kinds: add, chain, chain3, rewire, retype, delete
        self.mix = mix or dict(add=1.0, chain=self.eps, chain3=self.eps ** 2, rewire=0.5, retype=0.25, delete=0.25)
        self.verbose = verbose

    # ------------------------------------------------------------------ circuit bookkeeping
    def _init_state(self, X, y):
        n, d = X.shape
        self.n, self.d = n, d
        cap = 64
        self.W = np.zeros((d + cap, n), dtype=np.float32)      # wire values (rows): literals then gate slots
        self.W[:d] = X.T
        self.gt = np.zeros(cap, dtype=np.int64)                  # gate type per slot
        self.gi = np.zeros((cap, 2), dtype=np.int64)             # input wires per slot
        self.alive = np.zeros(cap, dtype=bool)
        self.nread = np.zeros(cap, dtype=np.int64)               # number of alive gates reading this slot
        self.nslot = 0
        self.feat = []                                           # slot of each readout feature (Ainv order)
        self.G = np.zeros((cap, n), dtype=np.float32)            # centred feature rows, compact, Ainv order
        self.gmean = np.zeros(cap, dtype=np.float64)
        self.ybar = float(y.mean())
        self.yc = (y - self.ybar).astype(np.float64)
        self.Ainv = np.zeros((0, 0))
        self.a = np.zeros(0)
        self.r = self.yc.copy()
        self.J = float(self.yc @ self.yc)

    def _grow(self):
        cap = len(self.gt)
        new = 2 * cap
        W = np.zeros((self.d + new, self.n), dtype=np.float32); W[:self.d + cap] = self.W; self.W = W
        G = np.zeros((new, self.n), dtype=np.float32); G[:cap] = self.G; self.G = G
        for name in ("gt", "alive", "nread", "gmean"):
            arr = getattr(self, name); z = np.zeros(new, dtype=arr.dtype); z[:cap] = arr; setattr(self, name, z)
        gi = np.zeros((new, 2), dtype=np.int64); gi[:cap] = self.gi; self.gi = gi

    def _compact(self):
        """Renumber alive gates to slots 0..m-1 keeping their order (a topological order)."""
        old = np.where(self.alive[:self.nslot])[0]
        remap = np.full(self.nslot, -1, dtype=np.int64); remap[old] = np.arange(len(old))
        d = self.d
        def mapw(w):
            return np.where(w < d, w, d + remap[np.maximum(w - d, 0)])
        gi = self.gi[old].copy()
        gi[:, 0] = mapw(gi[:, 0]); gi[:, 1] = np.where(self.gt[old] == 0, gi[:, 1], mapw(gi[:, 1]))
        self.W[d:d + len(old)] = self.W[d + old]
        self.gt[:len(old)] = self.gt[old]; self.gi[:len(old)] = gi
        self.nread[:len(old)] = self.nread[old]
        self.alive[:] = False; self.alive[:len(old)] = True
        self.feat = [int(remap[s]) for s in self.feat]
        self.nslot = len(old)

    def _new_slot(self, t, u, v, vals):
        if self.nslot >= len(self.gt):
            if self.alive[:self.nslot].sum() < 0.75 * self.nslot:
                self._compact()
            if self.nslot >= len(self.gt):
                self._grow()
        s = self.nslot; self.nslot += 1
        self.gt[s] = t; self.gi[s] = (u, v); self.alive[s] = True; self.nread[s] = 0
        self.W[self.d + s] = vals
        for w in ((u,) if t == 0 else (u, v)):
            if w >= self.d:
                self.nread[w - self.d] += 1
        return s

    def _kill_slot(self, s):
        self.alive[s] = False
        t, (u, v) = self.gt[s], self.gi[s]
        for w in ((u,) if t == 0 else (u, v)):
            if w >= self.d:
                self.nread[w - self.d] -= 1

    # ------------------------------------------------------------------ ridge readout updates
    def _gain_exact(self, C):
        """C: (k, n) centred candidate rows.  Returns (gain, aux) for adding all k as features."""
        m = len(self.feat)
        q = C.astype(np.float64) @ self.r
        S = C.astype(np.float64) @ C.T.astype(np.float64) + self.lam * np.eye(len(C))
        if m:
            V = (self.G[:m].astype(np.float64) @ C.T.astype(np.float64))          # (m, k)
            Wm = self.Ainv @ V
            S = S - V.T @ Wm
        else:
            V = Wm = np.zeros((0, len(C)))
        try:
            Sinv = np.linalg.inv(S)
        except np.linalg.LinAlgError:
            return -np.inf, None
        alpha = Sinv @ q
        return float(q @ alpha), (C, Wm, Sinv, alpha)

    def _add_features(self, slots, aux):
        C, Wm, Sinv, alpha = aux
        m, k = len(self.feat), len(slots)
        Ainv = np.zeros((m + k, m + k))
        Ainv[:m, :m] = self.Ainv + Wm @ Sinv @ Wm.T
        Ainv[:m, m:] = -Wm @ Sinv; Ainv[m:, :m] = Ainv[:m, m:].T
        Ainv[m:, m:] = Sinv
        self.Ainv = Ainv
        self.a = np.concatenate([self.a - Wm @ alpha, alpha])
        # residual: r -= sum_j alpha_j (c_j - G^T Wm_j)
        dr = alpha @ C.astype(np.float64)
        if m:
            dr -= (Wm @ alpha) @ self.G[:m].astype(np.float64)
        self.r = self.r - dr
        while m + k > len(self.G):
            self._grow()
        self.G[m:m + k] = C
        self.feat += list(slots)
        self.J = float(self.yc @ self.r)

    def _remove_feature(self, p, commit=True):
        """Remove readout feature at position p.  Returns new J (and commits if asked)."""
        e = self.Ainv[p, p]; ap = self.a[p]
        Jn = self.J + ap * ap / e
        if not commit:
            return Jn
        m = len(self.feat)
        col = self.Ainv[:, p].copy()
        self.r = self.r + (ap / e) * (col @ self.G[:m].astype(np.float64))
        o = np.r_[0:p, p + 1:m]
        self.a = self.a[o] - col[o] * ap / e
        self.Ainv = self.Ainv[np.ix_(o, o)] - np.outer(col[o], col[o]) / e
        self.G[p:m - 1] = self.G[p + 1:m]
        self.feat.pop(p)
        self.J = float(self.yc @ self.r)
        return self.J

    def _refit(self):
        """Exact recomputation (guards against drift)."""
        m = len(self.feat)
        if m == 0:
            self.Ainv = np.zeros((0, 0)); self.a = np.zeros(0); self.r = self.yc.copy(); self.J = float(self.yc @ self.yc)
            return
        G = self.G[:m].astype(np.float64)
        A = G @ G.T + self.lam * np.eye(m)
        self.Ainv = np.linalg.inv(A)
        self.a = self.Ainv @ (G @ self.yc)
        self.r = self.yc - self.a @ G
        self.J = float(self.yc @ self.r)

    # ------------------------------------------------------------------ proposals
    def _draw_wires(self, rng, B, limit=None):
        """Random wires: a literal w.p. 1/2 (or always if no gates), else an alive gate (slot < limit)."""
        d = self.d
        alive = np.where(self.alive[:self.nslot])[0]
        lit = rng.integers(0, d, size=B)
        if len(alive) == 0:
            return lit
        g = d + alive[rng.integers(0, len(alive), size=B)]
        use_g = rng.random(B) < 0.5
        if limit is not None:
            use_g &= (g - d) < limit
        return np.where(use_g, g, lit)

    def _propose_batch(self, rng, B):
        kinds = np.array(["add", "chain", "chain3", "rewire", "retype", "delete"])
        w = np.array([self.mix[k] for k in kinds]); w = w / w.sum()
        kind = rng.choice(len(kinds), size=B, p=w)
        return kind

    # ------------------------------------------------------------------ main loop
    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=np.float32); y = np.asarray(y, dtype=np.float64)
        self._init_state(X, y)
        n, d, lam, theta = self.n, self.d, self.lam, self.theta
        t = 0; n_acc = 0; trace = [(0, float(np.mean(np.sign(y - self.r + 1e-12) != y)), self.J, 0)]
        B = 16
        since_refit = 0
        while t < self.T:
            B = int(min(B, self.T - t))
            kind = self._propose_batch(rng, B)
            m = len(self.feat)
            leaves = [p for p, s in enumerate(self.feat) if self.nread[s] == 0]
            # ---- build candidate rows and screening gains (lower bounds) for every proposal
            gain_lb = np.full(B, -np.inf)            # screened improvement of F (positive = better)
            info = [None] * B
            # adds
            for code, k in ((0, 1), (1, 2), (2, 3)):
                idx = np.where(kind == code)[0]
                if len(idx) == 0:
                    continue
                L = len(idx)
                if k == 1:
                    tt = rng.integers(0, 6, size=L)
                    u = self._draw_wires(rng, L); v = self._draw_wires(rng, L)
                    u = np.where(tt == 0, rng.integers(0, d, size=L), u)     # BUF reads a literal
                    bad = (tt > 0) & (u == v)
                    vals = _apply(tt, self.W[u], self.W[v])
                    mu = vals.mean(1)
                    q = vals @ self.r.astype(np.float32)
                    lb = q.astype(np.float64) ** 2 / (lam + n * (1 - mu.astype(np.float64) ** 2) + 1e-9) - theta
                    lb[bad] = -np.inf
                    for j, i in enumerate(idx):
                        gain_lb[i] = lb[j]; info[i] = ("add", [(int(tt[j]), int(u[j]), int(v[j]))], vals[j])
                else:
                    t1 = rng.integers(1, 6, size=L); t2 = rng.integers(1, 6, size=L)
                    u = self._draw_wires(rng, L); v = self._draw_wires(rng, L); z = self._draw_wires(rng, L)
                    bad = (u == v) | (u == z) | (v == z)
                    g1 = _apply(t1, self.W[u], self.W[v])
                    if k == 2:
                        g2 = _apply(t2, g1, self.W[z])
                        rows = [g1, g2]
                    else:
                        t3 = rng.integers(1, 6, size=L); zz = self._draw_wires(rng, L)
                        bad |= (zz == z) | (zz == u) | (zz == v)
                        g2 = _apply(t2, self.W[z], self.W[zz])
                        g3 = _apply(t3, g1, g2)
                        rows = [g1, g2, g3]
                    Cs = [R - R.mean(1, keepdims=True) for R in rows]
                    # lower bound: gain of the k new features ignoring the existing span
                    Q = np.stack([R @ self.r.astype(np.float32) for R in Cs], 1).astype(np.float64)   # (L, k)
                    S = np.einsum("aln,bln->lab", np.stack(Cs), np.stack(Cs)).astype(np.float64) + lam * np.eye(k)
                    try:
                        sol = np.linalg.solve(S, Q[..., None])[..., 0]
                        lb = (Q * sol).sum(1) - k * theta
                    except np.linalg.LinAlgError:
                        lb = np.full(L, -np.inf)
                    lb[bad] = -np.inf
                    for j, i in enumerate(idx):
                        gates = [(int(t1[j]), int(u[j]), int(v[j]))]
                        if k == 2:
                            gates.append((int(t2[j]), -1, int(z[j])))            # -1: reads the previous new gate
                        else:
                            gates.append((int(t2[j]), int(z[j]), int(zz[j])))
                            gates.append((int(t3[j]), -2, -1))                  # reads both new gates
                        gain_lb[i] = lb[j]; info[i] = ("chain", gates, [R[j] for R in rows])
            # deletes (exact)
            idx = np.where(kind == 5)[0]
            if len(idx) and leaves:
                ps = np.array(leaves)[rng.integers(0, len(leaves), size=len(idx))]
                for j, i in enumerate(idx):
                    p = int(ps[j])
                    dJ = self.a[p] ** 2 / self.Ainv[p, p]
                    gain_lb[i] = theta - dJ
                    info[i] = ("delete", p, None)
            # rewire / retype of leaf gates (screened with the residual of the circuit without the gate)
            idx = np.where((kind == 3) | (kind == 4))[0]
            if len(idx) and leaves:
                L = len(idx)
                ps = np.array(leaves)[rng.integers(0, len(leaves), size=L)]
                slots = np.array(self.feat)[ps]
                tt = self.gt[slots].copy(); uu = self.gi[slots, 0].copy(); vv = self.gi[slots, 1].copy()
                is_rew = kind[idx] == 3
                neww = self._draw_wires(rng, L, limit=None)
                slot_pick = rng.random(L) < 0.5
                # rewire: replace one input (BUF: its literal)
                buf = tt == 0
                newlit = rng.integers(0, d, size=L)
                uu_n = np.where(is_rew & buf, newlit, np.where(is_rew & slot_pick & ~buf, neww, uu))
                vv_n = np.where(is_rew & ~slot_pick & ~buf, neww, vv)
                # must read earlier gates only
                ok_u = (uu_n < d) | (uu_n - d < slots); ok_v = buf | (vv_n < d) | (vv_n - d < slots)
                # retype: new 2-input type different from the old one (BUF cannot be retyped)
                shift = rng.integers(1, 5, size=L)
                tt_n = np.where(~is_rew & ~buf, 1 + (tt - 1 + shift) % 5, tt)
                bad = ~(ok_u & ok_v) | ((tt_n > 0) & (uu_n == vv_n)) | (~is_rew & buf)
                vals = _apply(tt_n, self.W[uu_n], self.W[np.where(buf, uu_n, vv_n)])
                mu = vals.mean(1)
                for j, i in enumerate(idx):
                    if bad[j]:
                        continue
                    p = int(ps[j])
                    e = self.Ainv[p, p]; ap = self.a[p]
                    Jo = self.J + ap * ap / e
                    r_o = self.r + ap * self.G[p]            # first-order residual without the gate
                    qq = float(vals[j] @ r_o)
                    lb = qq * qq / (lam + n * (1 - float(mu[j]) ** 2)) - (Jo - self.J)
                    gain_lb[i] = lb
                    info[i] = ("rewire", p, (int(tt_n[j]), int(uu_n[j]), int(vv_n[j]), vals[j]))
            # ---- scan in proposal order: first candidate that passes the screen and the exact test
            accepted = None
            for i in np.where(gain_lb > 0)[0]:
                kd, payload, vals = info[i]
                if kd == "delete":
                    accepted = i; self._do_delete(payload); break
                if kd == "add" or kd == "chain":
                    rows = [vals] if kd == "add" else vals
                    C = np.stack([R - R.mean() for R in rows]).astype(np.float32)
                    g, aux = self._gain_exact(C)
                    if g - theta * len(rows) > 0:
                        accepted = i; self._do_add(payload, rows, C, aux); break
                if kd == "rewire":
                    if self._try_rewire(payload, vals):
                        accepted = i; break
            if accepted is None:
                t += B; B = min(2 * B, self.batch)
            else:
                t += int(accepted) + 1; n_acc += 1; since_refit += 1
                B = max(16, B // 2)
                if since_refit >= 100:
                    self._refit(); since_refit = 0
                trace.append((t, float(np.mean(np.sign(y - self.ybar - (self.yc - self.r) + 1e-12 + self.ybar) != y)),
                              self.J, len(self.feat)))
        self._refit()
        return self._result(trace, t, n_acc)

    def _do_add(self, gates, rows, C, aux):
        slots = []
        for (tt, u, v), R in zip(gates, rows):
            uu = u if u >= 0 else self.d + slots[u]
            vv = v if v >= 0 else self.d + slots[v]
            slots.append(self._new_slot(tt, uu, vv, R))
        self._add_features(slots, aux)

    def _do_delete(self, p):
        s = self.feat[p]
        self._remove_feature(p, commit=True)
        self._kill_slot(s)

    def _try_rewire(self, p, payload):
        tt, u, v, vals = payload
        # exact: remove feature p, then add the new column
        saved = (self.Ainv.copy(), self.a.copy(), self.r.copy(), self.J, list(self.feat), self.G[:len(self.feat)].copy())
        J0 = self.J
        s = self.feat[p]
        self._remove_feature(p, commit=True)
        C = (vals - vals.mean())[None].astype(np.float32)
        g, aux = self._gain_exact(C)
        if self.J - g < J0:
            self._kill_slot(s)
            ns = self._new_slot(tt, u, v, vals)
            self._add_features([ns], aux)
            return True
        self.Ainv, self.a, self.r, self.J, self.feat, Gs = saved
        self.G[:len(self.feat)] = Gs
        return False

    def _result(self, trace, t, n_acc):
        d = self.d
        alive = np.where(self.alive[:self.nslot])[0]
        gt, gi = self.gt[:self.nslot].copy(), self.gi[:self.nslot].copy()
        feat = list(self.feat); a = self.a.copy()
        means = np.array([self.W[d + s].mean() for s in feat], dtype=np.float64)
        c0 = self.ybar - float(a @ means) if len(feat) else self.ybar
        order = alive  # slot order is topological

        def predict(Z):
            Z = np.asarray(Z, dtype=np.float32)
            vals = {}
            def wire(w):
                return Z[:, w] if w < d else vals[w - d]
            for s in order:
                u = wire(gi[s, 0]); v = u if gt[s] == 0 else wire(gi[s, 1])
                c = _COEF[gt[s]]
                vals[s] = c[0] + c[1] * u + c[2] * v + c[3] * u * v
            f = np.full(len(Z), c0)
            for aj, s in zip(a, feat):
                f = f + aj * vals[s]
            return np.where(f > 0, 1.0, -1.0)

        tr = np.array(trace)
        J_final = self.J
        # time: first proposal at which the training objective came within 10% (of the initial J) of its final value
        J0 = trace[0][2]
        hit = np.where(tr[:, 2] <= J_final + 0.1 * J0)[0]
        time = float(tr[hit[0], 0]) if len(hit) else float(t)
        desc = [f"g{s}={_NAMES[gt[s]]}({'x%d' % gi[s,0] if gi[s,0] < d else 'g%d' % (gi[s,0]-d)}"
                + ("" if gt[s] == 0 else f",{'x%d' % gi[s,1] if gi[s,1] < d else 'g%d' % (gi[s,1]-d)}") + ")"
                for s in alive]
        return dict(predict=predict, time=time, size=int(len(alive)), trace=[tuple(x) for x in trace],
                    n_accepted=n_acc, proposals=t, circuit=desc, readout=dict(zip([int(s) for s in feat], a.tolist())))
