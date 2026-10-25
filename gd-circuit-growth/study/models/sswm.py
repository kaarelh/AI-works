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
    among <= d + m wires, i.e. <= m * log2(6 (d+m)^2) bits, plus the real readout (m+1 numbers).

Dynamics (one proposal per clock tick; 'time' counts proposals)
    Each tick draws one random local mutation of the current circuit:
        add      one fresh gate of a random type on random wires                          weight 1
        chain    two fresh gates in series, g2 = op2(op1(u, v), z)                        weight eps
        chain3   three fresh gates, op3(op1(u, v), op2(z, w))                             weight eps^2
        rewire   one input of a random leaf gate to a random (earlier) wire               weight 1/4
        retype   a random leaf gate's type                                                weight 1/8
        delete   a random leaf gate                                                       weight 1/4
    Each input slot of a new or rewired gate reads an input literal with prob 1/2 (uniform among d),
    else an existing gate (uniform among the gates), so a specific move needing k fresh gates and
    j specific wires has proposal probability ~ eps^(k-1) * (const/d)^j: the per-fresh-gate penalty
    eps plays the role of alpha in the GD race (rate ~ alpha^(k-2) per extra fresh layer).

    Selection (strong selection, weak mutation): after refitting the readout exactly, the mutation is
    kept iff the refitted training objective
        J = min_{c,a} sum_i (y_i - f(x_i))^2 + lam * |a|^2
    decreases by more than  thr * (number of fresh gates it adds, floored at 0),  where
        thr = max(theta * J / n,  delta * n).
    The first term is a fixed-significance test (the gain must exceed theta times the current per-example
    residual variance, i.e. n * log(J_old / J_new) > ~theta, a likelihood-ratio test); the second is a
    drift barrier on the training MSE (selection coefficients below delta are effectively neutral).
    Below n ~ theta/delta the first term dominates and spurious gates keep being accepted until the data
    are memorized (as the networks memorize); above it, only moves with a real effect size fix.
    Rewires/retypes (no new gate) are kept iff J decreases; deletes never decrease J and so are never
    kept (no Occam pressure after the fact, like the networks, which train without weight decay).
    Neutral and deleterious mutations are lost; one mutation is resolved before the next is proposed.
    The run stops after T = 20000 proposals (the networks' number of steps; not tuned).
    fit() returns size = number of gates, and time = number of proposals until the training objective
    first came within 0.1 * J(empty circuit) of its final value (the model's time to fit).

Hyperparameters calibrated on common.CALIB only: theta = 1, delta = 0.003, eps = 0.2, lam = 0.5
    (T = 20000 and the move mix are fixed design constants).

Implementation: exact SSWM semantics, simulated in vectorized batches.  Each batch of proposals is
screened with a lower bound on its gain (for adds: the gain if the candidate were orthogonal to the
current features, i.e. the first-order utility (r.g)^2/|g|^2, computed from Fourier coefficients of the
gate), candidates that pass are checked exactly in proposal order (block-inverse ridge updates), and the
rest of the batch is discarded after an accepted move, so every proposal is judged against the circuit
current at its time.  (Candidates whose lower bound fails but whose exact gain would pass -- possible only
for candidates strongly correlated with existing gates -- are treated as rejected.)
Options kept for the record of the calibration (not used by the defaults): theta_mode "abs"/"mse",
kappa > 0 (deletes kept if they raise J by less than kappa*thr), beta (Kimura-like fixation probability
1 - exp(-2 beta gain / n)), m_max (circuit-size cap), p_buf (BUF share of 'add' proposals).
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
_KINDS = ["add", "chain", "chain3", "rewire", "retype", "delete"]


def _apply(t, U, V):
    """Gate outputs for type array t (B,) on input rows U, V (B, n)."""
    c = _COEF[t]
    return c[:, :1] + c[:, 1:2] * U + c[:, 2:3] * V + c[:, 3:4] * (U * V)


class SSWM:
    name = "sswm"
    LIB_TYPES = 6
    MAX_FANIN = 2

    def __init__(self, theta=1.0, eps=0.2, lam=0.5, T=20000, batch=256, mix=None, p_lit=0.5, m_max=None,
                 kappa=0.0, theta_mode="hybrid", delta=0.003, beta=None, p_buf=None, chain_lits=False, name=None):
        self.theta, self.eps, self.lam, self.T = float(theta), float(eps), float(lam), int(T)
        self.kappa = float(kappa)     # a delete is kept iff it raises J by less than kappa * theta
        self.theta_mode = theta_mode  # "abs": threshold theta on J;  "mse": threshold theta on J/n (i.e. theta*n on J)
        # "hybrid": threshold max(theta * J/n, delta * n): the gain must exceed theta times the per-point residual
        # variance (a likelihood-ratio / significance test) and delta in training MSE (a drift barrier)
        self.delta = float(delta)
        # beta: Kimura-like fixation probability 1 - exp(-2 beta * gain / n) for a mutation that passes the
        # threshold (selection coefficient s = beta * decrease of training MSE); None = always fixed
        self.beta = beta
        self.p_buf = p_buf            # prob. that an 'add' is a BUF (None: types uniform, i.e. 1/6)
        self.chain_lits = chain_lits  # True: fresh chains read input literals only (a chain from the inputs)
        self.batch, self.p_lit, self.m_max = batch, p_lit, m_max
        self.mix = dict(add=1.0, chain=self.eps, chain3=self.eps ** 2, rewire=0.25, retype=0.125, delete=0.25)
        if mix:
            self.mix.update(mix)
        if name:
            self.name = name

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
        self.G = np.zeros((cap, n), dtype=np.float64)            # centred feature rows, compact, Ainv order
        self.H = np.zeros((cap, n), dtype=np.float64)            # H = Ainv G (dual rows), same order
        self.Xr = None
        self.Mlit = (X.T.astype(np.float64) @ X.astype(np.float64)) / n   # pair means of literal products
        self.wmean = np.zeros(d + cap); self.wmean[:d] = X.mean(0)
        self.ybar = float(y.mean())
        self.yc = (y - self.ybar).astype(np.float64)
        self.Ainv = np.zeros((0, 0))
        self.a = np.zeros(0)
        self.r = self.yc.copy()
        self.J = float(self.yc @ self.yc)

    def _grow_slots(self):
        cap = len(self.gt); new = 2 * cap
        W = np.zeros((self.d + new, self.n), dtype=np.float32); W[:self.d + cap] = self.W; self.W = W
        for name in ("gt", "alive", "nread"):
            arr = getattr(self, name); z = np.zeros(new, dtype=arr.dtype); z[:cap] = arr; setattr(self, name, z)
        gi = np.zeros((new, 2), dtype=np.int64); gi[:cap] = self.gi; self.gi = gi
        wm = np.zeros(self.d + new); wm[:self.d + cap] = self.wmean; self.wmean = wm

    def _grow_feats(self, k):
        while len(self.feat) + k > len(self.G):
            m = len(self.feat)
            G = np.zeros((2 * len(self.G), self.n)); G[:m] = self.G[:m]; self.G = G
            H = np.zeros((2 * len(self.H), self.n)); H[:m] = self.H[:m]; self.H = H

    def _compact(self):
        """Renumber alive gates to slots 0..m-1 keeping their order (a topological order)."""
        old = np.where(self.alive[:self.nslot])[0]
        remap = np.full(self.nslot, -1, dtype=np.int64); remap[old] = np.arange(len(old))
        d = self.d
        def mapw(w):
            return np.where(w < d, w, d + remap[np.maximum(w - d, 0)])
        gi = self.gi[old].copy()
        gi[:, 0] = mapw(gi[:, 0]); gi[:, 1] = np.where(self.gt[old] == 0, gi[:, 0], mapw(gi[:, 1]))
        self.W[d:d + len(old)] = self.W[d + old]
        self.wmean[d:d + len(old)] = self.wmean[d + old]
        self.gt[:len(old)] = self.gt[old]; self.gi[:len(old)] = gi
        self.nread[:len(old)] = self.nread[old]
        self.alive[:] = False; self.alive[:len(old)] = True
        self.feat = [int(remap[s]) for s in self.feat]
        self.nslot = len(old)

    def _reserve(self, k):
        while self.nslot + k > len(self.gt):
            self._grow_slots()

    def _new_slot(self, t, u, v, vals):
        self._reserve(1)
        s = self.nslot; self.nslot += 1
        if t == 0:
            v = u
        self.gt[s] = t; self.gi[s] = (u, v); self.alive[s] = True; self.nread[s] = 0
        self.W[self.d + s] = vals
        self.wmean[self.d + s] = vals.mean(dtype=np.float64)
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

    # ------------------------------------------------------------------ ridge readout algebra
    def _gain_exact(self, C, Ainv=None, Gm=None, r=None):
        """Gain (decrease of J) of adding the centred rows C (k, n) to the readout of the given state."""
        Ainv = self.Ainv if Ainv is None else Ainv
        r = self.r if r is None else r
        m = Ainv.shape[0]
        q = C @ r
        S = C @ C.T + self.lam * np.eye(len(C))
        if m:
            V = (self.G[:len(self.feat)] @ C.T) if Gm is None else Gm
            Wm = Ainv @ V
            S = S - V.T @ Wm
        else:
            Wm = np.zeros((0, len(C)))
        try:
            Sinv = np.linalg.inv(S)
        except np.linalg.LinAlgError:
            return -np.inf, None
        alpha = Sinv @ q
        return float(q @ alpha), (C, Wm, Sinv, alpha)

    def _add_features(self, slots, aux):
        C, Wm, Sinv, alpha = aux
        m, k = len(self.feat), len(slots)
        Ainv = np.empty((m + k, m + k))
        WS = Wm @ Sinv
        Ainv[:m, :m] = self.Ainv + WS @ Wm.T
        Ainv[:m, m:] = -WS; Ainv[m:, :m] = -WS.T
        Ainv[m:, m:] = Sinv
        self.Ainv = Ainv
        D = C - Wm.T @ self.G[:m] if m else C.copy()           # new features residualized on the old ones
        SD = Sinv @ D
        self.a = np.concatenate([self.a - Wm @ alpha, alpha])
        self.r = self.r - alpha @ D
        self._grow_feats(k)
        if m:
            self.H[:m] -= Wm @ SD
        self.H[m:m + k] = SD
        self.G[m:m + k] = C
        self.feat += list(slots)
        self.J = float(self.yc @ self.r)

    def _reduced(self, p):
        """State of the readout without feature p (not committed): Ainv_o, a_o, r_o, J_o, keep-index."""
        m = len(self.feat)
        e = self.Ainv[p, p]; ap = self.a[p]
        col = self.Ainv[:, p]
        o = np.r_[0:p, p + 1:m]
        Ainv_o = self.Ainv[np.ix_(o, o)] - np.outer(col[o], col[o]) / e
        a_o = self.a[o] - col[o] * ap / e
        r_o = self.r + (ap / e) * self.H[p]
        return Ainv_o, a_o, r_o, self.J + ap * ap / e, o

    def _commit_reduced(self, p, red):
        Ainv_o, a_o, r_o, J_o, o = red
        m = len(self.feat)
        col = self.Ainv[:, p]; e = col[p]
        Hp = self.H[p].copy()
        self.H[:m] -= np.outer(col / e, Hp)
        self.Ainv, self.a, self.r = Ainv_o, a_o, r_o
        self.G[p:m - 1] = self.G[p + 1:m]
        self.H[p:m - 1] = self.H[p + 1:m]
        self.feat.pop(p)
        self.J = float(self.yc @ self.r)

    def _refit(self):
        m = len(self.feat)
        if m == 0:
            self.Ainv = np.zeros((0, 0)); self.a = np.zeros(0); self.r = self.yc.copy(); self.J = float(self.yc @ self.yc)
            return
        G = self.G[:m]
        self.Ainv = np.linalg.inv(G @ G.T + self.lam * np.eye(m))
        self.H[:m] = self.Ainv @ G
        self.a = self.Ainv @ (G @ self.yc)
        self.r = self.yc - self.a @ G
        self.J = float(self.yc @ self.r)

    # ------------------------------------------------------------------ proposals
    def _draw_wires(self, rng, B):
        """Random wires: a literal w.p. p_lit (always if no gates), else a uniformly random alive gate."""
        d = self.d
        lit = rng.integers(0, d, size=B)
        if not self._alive_list.size:
            return lit
        g = d + self._alive_list[rng.integers(0, len(self._alive_list), size=B)]
        return np.where(rng.random(B) < self.p_lit, lit, g)

    # ------------------------------------------------------------------ main loop
    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=np.float32); y = np.asarray(y, dtype=np.float64)
        self._init_state(X, y)
        n, d, lam, theta = self.n, self.d, self.lam, self.theta
        if self.theta_mode == "mse":
            theta = self.theta * n
        mixw = np.array([self.mix[k] for k in _KINDS]); mixw = mixw / mixw.sum()
        t = 0; n_acc = 0; self.Xr = None
        trace = [(0, float(np.mean(np.where(y - self.r > 0, 1.0, -1.0) != y)), self.J, 0)]
        B = 16; since_refit = 0
        while t < self.T:
            B = int(min(B, self.T - t))
            if self.nslot + 3 > len(self.gt) and self.alive[:self.nslot].sum() < 0.75 * self.nslot:
                self._compact()
            self._alive_list = np.where(self.alive[:self.nslot])[0]
            kind = rng.choice(6, size=B, p=mixw)
            m = len(self.feat)
            full = self.m_max is not None and m >= self.m_max
            r32 = self.r.astype(np.float32)
            if self.theta_mode == "hybrid":
                theta = max(self.theta * self.J / n, self.delta * n)
            if self.Xr is None or self.Xr_t != n_acc:
                Xr = self.W[:d] * r32
                self.Plit = (Xr @ self.W[:d].T).astype(np.float64)
                self.Xr = True; self.Xr_t = n_acc
                self.rw_all = None
            rw = np.zeros(d + len(self.gt))
            nw = d + self.nslot
            rw[:nw] = self.W[:nw] @ r32
            cands = []          # (proposal index, kind, lower-bound gain, payload)
            # ---------------- adds (1, 2 or 3 fresh gates)
            for code, k in ((0, 1), (1, 2), (2, 3)):
                idx = np.where(kind == code)[0]
                if not len(idx) or full:
                    continue
                L = len(idx)
                if k == 1:
                    if self.p_buf is None:
                        tt = rng.integers(0, 6, size=L)
                    else:
                        tt = np.where(rng.random(L) < self.p_buf, 0, rng.integers(1, 6, size=L))
                    u = self._draw_wires(rng, L); v = self._draw_wires(rng, L)
                    u = np.where(tt == 0, rng.integers(0, d, size=L), u)     # BUF reads a literal
                    ok = (tt == 0) | (u != v)
                    # screen from Fourier coefficients: g = c0 + c1 u + c2 v + c3 uv, r.1 = 0
                    ruv = np.zeros(L); muv = np.zeros(L)
                    both = (u < d) & (v < d)
                    ruv[both] = self.Plit[u[both], v[both]]; muv[both] = self.Mlit[u[both], v[both]]
                    oth = np.where(~both & (tt > 0))[0]
                    if len(oth):
                        prod = self.W[u[oth]] * self.W[v[oth]]
                        ruv[oth] = prod @ r32; muv[oth] = prod.mean(1, dtype=np.float64)
                    c = _COEF[tt].astype(np.float64)
                    q = c[:, 1] * rw[u] + c[:, 2] * rw[v] + c[:, 3] * ruv
                    mu = c[:, 0] + c[:, 1] * self.wmean[u] + c[:, 2] * self.wmean[v] + c[:, 3] * muv
                    lb = q * q / (lam + n * (1 - mu * mu) + 1e-9) - theta
                    for j in np.where(ok & (lb > 0))[0]:
                        vals = _apply(tt[j:j + 1], self.W[u[j:j + 1]], self.W[v[j:j + 1]])[0]
                        cands.append((idx[j], "add", lb[j], ([(int(tt[j]), int(u[j]), int(v[j]))], [vals])))
                else:
                    t1 = rng.integers(1, 6, size=L); t2 = rng.integers(1, 6, size=L)
                    draw = (lambda B: rng.integers(0, d, size=B)) if self.chain_lits else (lambda B: self._draw_wires(rng, B))
                    u = draw(L); v = draw(L); z = draw(L)
                    ok = (u != v) & (u != z) & (v != z)
                    g1 = _apply(t1, self.W[u], self.W[v])
                    if k == 2:
                        g2 = _apply(t2, g1, self.W[z]); rows = [g1, g2]
                    else:
                        t3 = rng.integers(1, 6, size=L); zz = draw(L)
                        ok &= (zz != z) & (zz != u) & (zz != v)
                        g2 = _apply(t2, self.W[z], self.W[zz]); g3 = _apply(t3, g1, g2); rows = [g1, g2, g3]
                    Cs = np.stack([R - R.mean(1, keepdims=True) for R in rows]).astype(np.float64)  # (k, L, n)
                    Q = np.einsum("kln,n->lk", Cs, self.r)
                    S = np.einsum("aln,bln->lab", Cs, Cs) + lam * np.eye(k)
                    sol = np.linalg.solve(S, Q[..., None])[..., 0]
                    lb = (Q * sol).sum(1) - k * theta
                    for j in np.where(ok & (lb > 0))[0]:
                        gates = [(int(t1[j]), int(u[j]), int(v[j]))]
                        if k == 2:
                            gates.append((int(t2[j]), -1, int(z[j])))            # -1: the previous new gate
                        else:
                            gates.append((int(t2[j]), int(z[j]), int(zz[j])))
                            gates.append((int(t3[j]), -2, -1))
                        cands.append((idx[j], "add", lb[j], (gates, [R[j] for R in rows])))
            # ---------------- leaf moves: delete (exact), rewire / retype (screened with the exact
            # residual of the circuit without the gate, so the screen is a lower bound)
            leaves = np.array([p for p, s in enumerate(self.feat) if self.nread[s] == 0], dtype=np.int64)
            idx = np.where(kind == 5)[0]
            if len(idx) and len(leaves):
                ps = leaves[rng.integers(0, len(leaves), size=len(idx))]
                dJ = self.a[ps] ** 2 / self.Ainv[ps, ps]
                for j in np.where(dJ < self.kappa * theta)[0]:
                    cands.append((idx[j], "delete", self.kappa * theta - dJ[j], int(ps[j])))
            idx = np.where((kind == 3) | (kind == 4))[0]
            if len(idx) and len(leaves):
                L = len(idx)
                ps = leaves[rng.integers(0, len(leaves), size=L)]
                slots = np.array(self.feat)[ps]
                tt = self.gt[slots]; uu = self.gi[slots, 0]; vv = self.gi[slots, 1]
                is_rew = kind[idx] == 3; buf = tt == 0
                neww = self._draw_wires(rng, L); first = rng.random(L) < 0.5
                uu_n = np.where(is_rew & buf, rng.integers(0, d, size=L), np.where(is_rew & first & ~buf, neww, uu))
                vv_n = np.where(buf, uu_n, np.where(is_rew & ~first, neww, vv))
                tt_n = np.where(~is_rew & ~buf, 1 + (tt - 1 + rng.integers(1, 5, size=L)) % 5, tt)
                ok = ((uu_n < d) | (uu_n - d < slots)) & ((vv_n < d) | (vv_n - d < slots))
                ok &= (buf | (uu_n != vv_n)) & ~(~is_rew & buf)
                if ok.any():
                    sel = np.where(ok)[0]
                    e = self.Ainv[ps[sel], ps[sel]]; ap = self.a[ps[sel]]
                    R_o = self.r[None] + (ap / e)[:, None] * self.H[ps[sel]]   # exact residual without the gate
                    vals = _apply(tt_n[sel], self.W[uu_n[sel]], self.W[vv_n[sel]])
                    mu = vals.mean(1, dtype=np.float64)
                    q = np.einsum("ln,ln->l", vals.astype(np.float64), R_o)
                    lb = q * q / (lam + n * (1 - mu * mu) + 1e-9) - ap * ap / e
                    for jj in np.where(lb > 0)[0]:
                        j = sel[jj]
                        cands.append((idx[j], "rewire", lb[jj], (int(ps[j]), int(tt_n[j]), int(uu_n[j]), int(vv_n[j]), vals[jj])))
            # ---------------- resolve in proposal order
            cands.sort(key=lambda c: c[0])
            accepted = None
            for (i, kd, lbv, payload) in cands:
                if kd == "delete":
                    p = payload; s = self.feat[p]
                    self._commit_reduced(p, self._reduced(p)); self._kill_slot(s)
                    accepted = i; break
                if kd == "add":
                    gates, rows = payload
                    C = np.stack([R.astype(np.float64) - R.mean(dtype=np.float64) for R in rows])
                    g, aux = self._gain_exact(C)
                    if g - theta * len(rows) > 0 and self._fixes(rng, g):
                        self._do_add(gates, rows, aux); accepted = i; break
                else:
                    p, tn, un, vn, vals = payload
                    red = self._reduced(p)
                    Ainv_o, a_o, r_o, J_o, o = red
                    C = (vals.astype(np.float64) - vals.mean(dtype=np.float64))[None]
                    V = (self.G[:m] @ C.T)[o]
                    g, aux = self._gain_exact(C, Ainv=Ainv_o, Gm=V, r=r_o)
                    if J_o - g < self.J - 1e-9 and self._fixes(rng, self.J - (J_o - g)):
                        s = self.feat[p]
                        self._commit_reduced(p, red); self._kill_slot(s)
                        ns = self._new_slot(tn, un, vn, vals)
                        self._add_features([ns], aux)
                        accepted = i; break
            if accepted is None:
                t += B; B = min(2 * B, self.batch)
            else:
                t += int(accepted) + 1; n_acc += 1; since_refit += 1
                B = max(16, B // 2)
                if since_refit >= 200:
                    self._refit(); since_refit = 0
                trace.append((t, float(np.mean(np.where(y - self.r > 0, 1.0, -1.0) != y)), self.J, len(self.feat)))
        self._refit()
        return self._result(trace, t, n_acc)

    def _fixes(self, rng, gain):
        if self.beta is None:
            return True
        return rng.random() < 1.0 - np.exp(-2.0 * self.beta * gain / self.n)

    def _do_add(self, gates, rows, aux):
        self._reserve(len(gates))
        slots = []
        for (tt, u, v), R in zip(gates, rows):
            uu = u if u >= 0 else self.d + slots[u]
            vv = v if v >= 0 else self.d + slots[v]
            slots.append(self._new_slot(tt, uu, vv, R))
        self._add_features(slots, aux)

    def _result(self, trace, t, n_acc):
        d = self.d
        alive = np.where(self.alive[:self.nslot])[0]
        gt, gi = self.gt[:self.nslot].copy(), self.gi[:self.nslot].copy()
        feat = list(self.feat); a = self.a.copy()
        means = np.array([self.W[d + s].mean(dtype=np.float64) for s in feat])
        c0 = self.ybar - float(a @ means) if len(feat) else self.ybar

        def predict(Z):
            Z = np.asarray(Z, dtype=np.float32)
            vals = {}
            for s in alive:
                u = Z[:, gi[s, 0]] if gi[s, 0] < d else vals[gi[s, 0] - d]
                v = Z[:, gi[s, 1]] if gi[s, 1] < d else vals[gi[s, 1] - d]
                c = _COEF[gt[s]]
                vals[s] = c[0] + c[1] * u + c[2] * v + c[3] * u * v
            f = np.full(len(Z), c0)
            for aj, s in zip(a, feat):
                f = f + aj * vals[s]
            return np.where(f > 0, 1.0, -1.0)

        tr = np.array(trace)
        J0, Jf = trace[0][2], self.J
        # time: first proposal at which the training objective came within 10% (of the initial J) of its final value
        hit = np.where(tr[:, 2] <= Jf + 0.1 * J0)[0]
        time = float(tr[hit[0], 0]) if len(hit) else float(t)
        wname = lambda w: f"x{w}" if w < d else f"g{w - d}"
        desc = [f"g{s}={_NAMES[gt[s]]}({wname(gi[s, 0])}" + ("" if gt[s] == 0 else f",{wname(gi[s, 1])}") + ")"
                for s in alive]
        return dict(predict=predict, time=time, size=int(len(alive)), trace=[tuple(x) for x in trace],
                    n_accepted=n_acc, proposals=t, circuit=desc,
                    readout={int(s): float(v) for s, v in zip(feat, a)})
