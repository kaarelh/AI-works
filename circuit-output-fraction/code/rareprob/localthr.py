"""Local threshold circuits: tilted heat-bath sampling with a Dobrushin
certificate, and the sound estimator TG of the paper (Section "Local
threshold circuits", thm:local).

Model. C(x) = [S(x) >= t] (optionally AND H(x) for an arbitrary circuit H),
S(x) = sum_j g_j(x_{A_j}), where every scope A_j has at most k variables,
every variable lies in at most d scopes, and the g_j are arbitrary Boolean
sub-circuits, given by their truth tables. D is a product distribution with
marginals q_i in (0, 1).

Identity. For theta >= 0 let mu_theta ~ D exp(theta S) be the tilted (Gibbs)
measure and Z(theta) = E_D exp(theta S). Then, because mu_theta has full
support,

    p = Z(theta) e^{-theta t} V(theta),
    V(theta) = E_{mu_theta}[ U ],  U = C(X) exp(-theta (S(X) - t)) in [0, 1].

Estimator TG.
  * Sampler: systematic-scan heat-bath Glauber dynamics (colour classes of
    sites that share no factor are updated simultaneously), started at the
    all-zeros state. A Dobrushin certificate, computed by local enumeration,
    bounds its distance from mu_theta: if sum_l B_il w_l <= alpha w_i for all
    i, where B_il bounds the influence of x_l on the conditional law of x_i,
    then after s sweeps the total variation distance is at most
    (sum_i w_i / min_i w_i) alpha^s. The bound B_il used here is monotone in
    theta, so one check at theta* covers every theta in [0, theta*].
    Alternatively, for supermodular S, monotone coupling from the past gives
    exact samples with no certificate (prop:local-cftp); a run that times out
    makes the whole procedure return "no verdict".
  * Normaliser: log Z(theta*) = int_0^theta* mu(u) du with mu(u) = E_u S
    nondecreasing, so log Z lies between the lower and upper Riemann sums on
    any grid. One sample per grid point estimates the upper sum; its
    variance is bounded from the data (pairs of neighbouring grid points and
    Maurer's lower-tail inequality for nonnegative variables), and
    Bernstein's inequality gives the interval.
  * Importance sampling: the KL sequential interval of stats.sequential_mean
    for V(theta*), U in [0, 1].
  * Every sample is coupled to an exact sample except with probability
    eta = delta / (4 N_tot) (Dobrushin bound plus a floating-point term), so
    every returned interval contains p with probability >= 1 - delta, on
    every input. The choice of theta* (a pilot run) does not affect this.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field

import numpy as np
from scipy.special import expit

from .circuit import Circuit
from .stats import Estimate, kl_interval, sequential_mean

FLOAT_TV_PER_UPDATE = 2.0 ** -48  # per site update: rounding of the update probability + 53-bit uniforms


# ---------------------------------------------------------------- the circuit class
@dataclass
class LTC:
    """C(x) = [sum_j g_j(x_{A_j}) >= t] AND H(x).

    tables[j][c] = g_j at the assignment with x_{A_j[b]} = bit b of c.
    """

    n: int
    scopes: list
    tables: list
    t: int
    H: Circuit | None = None

    def __post_init__(self):
        self.scopes = [tuple(int(v) for v in A) for A in self.scopes]
        self.tables = [np.asarray(T, dtype=np.int64).ravel() for T in self.tables]
        assert len(self.scopes) == len(self.tables)
        for A, T in zip(self.scopes, self.tables):
            assert len(set(A)) == len(A) and all(0 <= v < self.n for v in A), "bad scope"
            assert T.shape == (1 << len(A),) and np.all((T == 0) | (T == 1)), "bad table"
        self.t = int(self.t)
        if self.H is not None:
            assert self.H.n == self.n

    @property
    def m(self) -> int:
        return len(self.scopes)

    @property
    def k(self) -> int:
        return max((len(A) for A in self.scopes), default=0)

    @property
    def d(self) -> int:
        deg = np.zeros(self.n, dtype=int)
        for A in self.scopes:
            for v in A:
                deg[v] += 1
        return int(deg.max(initial=0))

    @property
    def S_lo(self) -> int:
        return int(sum(T.min() for T in self.tables))

    @property
    def S_hi(self) -> int:
        return int(sum(T.max() for T in self.tables))

    def mean_S(self, q) -> float:
        """E_D S, exactly (up to rounding), by enumerating each scope."""
        q = np.asarray(q, dtype=float)
        tot = 0.0
        for A, T in zip(self.scopes, self.tables):
            c = np.arange(1 << len(A))
            w = np.ones(len(c))
            for b, v in enumerate(A):
                w *= np.where((c >> b) & 1, q[v], 1 - q[v])
            tot += float((w * T).sum())
        return tot

    def S(self, X: np.ndarray) -> np.ndarray:
        """S on an (N, n) 0/1 array."""
        X = np.asarray(X, dtype=np.int64)
        s = np.zeros(X.shape[0], dtype=np.int64)
        for A, T in zip(self.scopes, self.tables):
            idx = np.zeros(X.shape[0], dtype=np.int64)
            for b, v in enumerate(A):
                idx |= X[:, v] << b
            s += T[idx]
        return s

    def C(self, X: np.ndarray) -> np.ndarray:
        out = self.S(X) >= self.t
        if self.H is not None:
            out &= self.H.eval_bits(np.asarray(X, dtype=bool))
        return out

    def to_circuit(self) -> Circuit:
        """An explicit circuit: a unit-weight THR gate over DNFs of the tables
        (AND H). ltc_from_circuit recognises it again."""
        C = Circuit(self.n)
        kids = []
        for A, T in zip(self.scopes, self.tables):
            terms = []
            for c in np.nonzero(T)[0]:
                lits = [C.lit(v, (int(c) >> b) & 1) for b, v in enumerate(A)]
                terms.append(C.AND(*lits) if lits else C.const(1))
            if not terms:
                kids.append(C.const(0))
            elif len(terms) == 1:
                kids.append(terms[0])
            else:
                kids.append(C.OR(*terms))
        if not kids:
            kids.append(C.const(0))
        thr = C.THR(kids, [1.0] * len(kids), float(self.t))
        if self.H is None:
            return C.set_output(thr)
        h = _copy_into(C, self.H)
        return C.set_output(C.AND(thr, h))


def _copy_into(C: Circuit, H: Circuit) -> int:
    """Copy H's gates into C (same inputs); return the gate of H's output."""
    m = list(range(H.n))
    for v in range(H.n, len(H.ops)):
        m.append(C.add(H.ops[v], [m[a] for a in H.args[v]], H.params[v]))
    return m[H.output]


def ltc_from_subcircuits(n, scopes, subcircuits, t, H=None) -> LTC:
    """g_j given as Circuits on |A_j| inputs (input b <-> variable A_j[b])."""
    tables = []
    for A, g in zip(scopes, subcircuits):
        k = len(A)
        pts = ((np.arange(1 << k)[:, None] >> np.arange(k)) & 1).astype(bool)
        tables.append(g.eval_bits(pts).astype(np.int64) if k > 0 else np.array([g(np.zeros(0, dtype=bool))]))
    return LTC(n, scopes, tables, t, H)


def ltc_from_circuit(C: Circuit, kmax: int = 12) -> LTC | None:
    """Syntactic recognition: the output gate is a unit-weight THR gate whose
    children have supports of size <= kmax, or an AND with such a THR child
    (the other children form H). Truth tables of the children are computed by
    enumerating their supports. Returns None if C has no such form."""
    out = C.output
    op = C.ops[out]
    thr, rest = None, []
    if op == "THR":
        thr = out
    elif op == "AND":
        for a in C.args[out]:
            if thr is None and C.ops[a] == "THR" and all(w == 1.0 for w in C.params[a][0]):
                thr = a
            else:
                rest.append(a)
    if thr is None or not all(w == 1.0 for w in C.params[thr][0]):
        return None
    sup = C.supports()
    scopes, tables = [], []
    for g in C.args[thr]:
        A = [v for v in range(C.n) if (sup[g] >> v) & 1]
        if len(A) > kmax:
            return None
        k = len(A)
        pts = np.zeros((1 << k, C.n), dtype=bool)
        pts[:, A] = ((np.arange(1 << k)[:, None] >> np.arange(k)) & 1).astype(bool)
        from .circuit import pack_rows, unpack_bits
        val = unpack_bits(C.eval_packed(pack_rows(pts), gates=C.cone(g)), 1 << k)
        scopes.append(tuple(A))
        tables.append(val.astype(np.int64))
    t = int(math.ceil(C.params[thr][1] - 1e-9))
    H = None
    if rest:
        H = Circuit(C.n)
        H.ops, H.args, H.params = list(C.ops), list(C.args), list(C.params)
        H.output = rest[0] if len(rest) == 1 else H.AND(*rest)
    return LTC(C.n, scopes, tables, t, H)


def brute_force_p(ltc: LTC, q) -> float:
    """Exact p by enumeration (n <= 22)."""
    n = ltc.n
    assert n <= 22
    q = np.asarray(q, dtype=float)
    X = ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(np.int64)
    w = np.prod(np.where(X == 1, q, 1 - q), axis=1)
    return float(w[ltc.C(X)].sum())


# ---------------------------------------------------------------- the tilted model
@dataclass
class Certificate:
    """Verified Dobrushin-type bound at theta (valid for all theta' <= theta):
    sum_l B_il w_l <= alpha w_i for all i, hence after s sweeps the systematic
    scan is within F alpha^s of mu_theta' in total variation, F = sum w / min w."""

    theta: float
    alpha: float
    F: float
    weighted: bool
    alpha_unweighted: float

    def sweeps(self, eta: float, n: int) -> int | None:
        """Smallest s with F alpha^s + s n 2^-48 <= eta (None if impossible)."""
        if self.alpha >= 1:
            return None
        if self.alpha <= 0:
            s = 1
        else:
            s = max(1, math.ceil(math.log(self.F / (eta / 2)) / -math.log(self.alpha)))
        if self.F * self.alpha ** s + s * n * FLOAT_TV_PER_UPDATE > eta:
            return None
        return s


class LocalModel:
    """Neighbourhood tables, colour classes, Dobrushin bounds and samplers for
    the tilted measures mu_theta of an LTC under a product distribution."""

    def __init__(self, ltc: LTC, q, rmax: int = 14):
        n = ltc.n
        q = np.asarray(q, dtype=float)
        if not np.all((q > 0) & (q < 1)):
            raise ValueError("marginals must lie in (0, 1)")
        self.ltc, self.n, self.q = ltc, n, q
        self.a = np.log(q) - np.log1p(-q)
        inc = [[] for _ in range(n)]
        for j, A in enumerate(ltc.scopes):
            for b, v in enumerate(A):
                inc[v].append((j, b))
        nbrs = [sorted({u for j, _ in inc[i] for u in ltc.scopes[j] if u != i}) for i in range(n)]
        self.ri = np.array([len(nb) for nb in nbrs], dtype=int)
        r = int(self.ri.max(initial=0))
        if r > rmax:
            raise ValueError(f"neighbourhood of size {r} > {rmax}")
        self.r = r
        R = 1 << r
        NB = np.full((n, max(r, 1)), n, dtype=np.intp)  # pad with the dummy site n (always 0)
        LUT = np.zeros((n, R), dtype=np.int64)
        for i in range(n):
            nb = nbrs[i]
            pos = {u: b for b, u in enumerate(nb)}
            c = np.arange(1 << len(nb))
            delta = np.zeros(len(c), dtype=np.int64)
            for j, bi in inc[i]:
                A, T = ltc.scopes[j], ltc.tables[j]
                idx = np.zeros(len(c), dtype=np.int64)
                for b, u in enumerate(A):
                    if u != i:
                        idx |= ((c >> pos[u]) & 1) << b
                delta += T[idx | (1 << bi)] - T[idx]
            LUT[i, : len(c)] = delta
            NB[i, : len(nb)] = nb
        self.NB, self.LUT = NB, LUT
        self.dmax = int(np.abs(LUT).max(initial=0))
        # greedy colouring of the conflict graph (sites sharing a factor)
        colour = -np.ones(n, dtype=int)
        for i in np.argsort(-self.ri, kind="stable"):
            used = {colour[u] for u in nbrs[i]}
            c = 0
            while c in used:
                c += 1
            colour[i] = c
        self.classes = [np.nonzero(colour == c)[0] for c in range(int(colour.max(initial=-1)) + 1)]
        # update-probability types (distinct marginals)
        ua, typ = np.unique(self.a, return_inverse=True)
        self.types = ua if len(ua) <= 16 else None
        W = 2 * self.dmax + 1
        self._cls = []
        for I in self.classes:
            rows = None
            if self.types is not None:
                rows = (typ[I][:, None] * W + LUT[I] + self.dmax).ravel()
            self._cls.append(dict(I=I, NB=[NB[I, b] for b in range(max(r, 1))],
                                  rowbase=(np.arange(len(I), dtype=np.intp) << r)[:, None],
                                  lut=LUT[I].ravel(), rows=rows, a=self.a[I][:, None]))
        # factor tables for S on states
        k = ltc.k
        self._A = np.full((ltc.m, max(k, 1)), n, dtype=np.intp)
        self._T = np.zeros((ltc.m, 1 << k), dtype=np.int64)
        for j, (A, T) in enumerate(zip(ltc.scopes, ltc.tables)):
            self._A[j, : len(A)] = A
            self._T[j, : len(T)] = T  # dummy bits are 0, so padding is never read
        self.mu0 = ltc.mean_S(q)

    # ------------------------------------------------------------ influences
    def _pairs(self, theta: float, exact: bool, sites=None):
        """(len(sites), r) array of influence bounds B_il (or exact C_il)."""
        n, r = self.n, self.r
        sites = np.arange(n) if sites is None else np.asarray(sites)
        out = np.zeros((len(sites), max(r, 1)))
        if r == 0:
            return out
        c = np.arange(1 << r)
        for s0 in range(0, len(sites), max(1, 2 ** 20 >> r)):
            ch = sites[s0: s0 + max(1, 2 ** 20 >> r)]
            L = self.LUT[ch].astype(float)
            a = self.a[ch][:, None]
            ri = self.ri[ch][:, None]
            for b in range(r):
                c0 = c[((c >> b) & 1) == 0]
                c1 = c0 | (1 << b)
                D0, D1 = L[:, c0], L[:, c1]
                valid = (c1[None, :] < (1 << ri)) & (b < ri)
                if exact:
                    val = np.abs(expit(a + theta * D1) - expit(a + theta * D0))
                else:
                    lo = a + theta * np.minimum(np.minimum(D0, D1), 0.0)
                    hi = a + theta * np.maximum(np.maximum(D0, D1), 0.0)
                    zc = np.minimum(np.maximum(0.0, lo), hi)
                    val = theta * np.abs(D1 - D0) * expit(zc) * expit(-zc)
                out[s0: s0 + len(ch), b] = np.where(valid, val, 0.0).max(axis=1)
        return out

    def influence_bound(self, theta: float) -> np.ndarray:
        """B_il(theta) >= sup_{0 <= theta' <= theta} C_il(theta'), where C_il is
        the largest change of P(x_i = 1 | x_-i) when x_l alone changes (mean value
        theorem on the hull of the two logits and the base logit). Column b of
        row i refers to site NB[i, b]."""
        return self._pairs(theta, exact=False)

    def influence_exact(self, theta: float) -> np.ndarray:
        return self._pairs(theta, exact=True)

    def certificate(self, theta: float, gamma: float = 0.0, iters: int = 3000) -> Certificate:
        """Best of the unweighted (row sums) and a weighted (resolvent vector)
        Dobrushin bound at theta; the inequality is verified explicitly."""
        n = self.n
        Bn = self.influence_bound(theta)
        alpha_u = float(Bn.sum(axis=1).max(initial=0.0))
        best = Certificate(theta, alpha_u, float(n), False, alpha_u)
        lam = 1.0 - gamma if gamma > 0 else max(alpha_u, 1e-9)
        w = np.ones(n + 1)
        w[n] = 0.0
        for _ in range(iters):
            new = 1.0 + (Bn * w[self.NB]).sum(axis=1) / lam
            if new.max() > 1e9:
                break
            done = np.max(np.abs(new - w[:n])) <= 1e-10 * new.max()
            w[:n] = new
            if done:
                break
        ww = w[:n]
        if ww.min() > 0 and ww.max() <= 1e9:
            alpha_w = float(((Bn * w[self.NB]).sum(axis=1) / ww).max(initial=0.0))
            F = float(ww.sum() / ww.min())
            cand = Certificate(theta, alpha_w * (1 + 1e-12), F, True, alpha_u)
            if cand.alpha < 1 and (best.alpha >= 1 or
                                   math.log(cand.F * 1e10) / -math.log(max(cand.alpha, 1e-300)) <
                                   math.log(best.F * 1e10) / -math.log(max(best.alpha, 1e-300))):
                best = cand
        best.alpha = best.alpha * (1 + 1e-12)  # rounding margin
        return best

    def theta_max(self, gamma: float, hi: float = 8.0, tol: float = 1e-3) -> float:
        """Largest theta (to tol) whose certificate has alpha <= 1 - gamma."""
        ok = lambda th: self.certificate(th, gamma).alpha <= 1 - gamma  # noqa: E731
        if not ok(tol):
            return 0.0
        lo_, hi_ = tol, hi
        if ok(hi_):
            return hi_
        while hi_ - lo_ > tol:
            mid = (lo_ + hi_) / 2
            if ok(mid):
                lo_ = mid
            else:
                hi_ = mid
        return lo_

    def is_supermodular(self) -> bool:
        """Delta_i nondecreasing in every neighbour bit (so the heat-bath update is
        monotone for theta >= 0)."""
        c = np.arange(1 << self.r)
        for b in range(self.r):
            c0 = c[((c >> b) & 1) == 0]
            c1 = c0 | (1 << b)
            valid = (c1[None, :] < (1 << self.ri[:, None])) & (b < self.ri[:, None])
            if np.any(valid & (self.LUT[:, c1] < self.LUT[:, c0])):
                return False
        return True

    # ------------------------------------------------------------ dynamics
    def _rt(self, thetas: np.ndarray) -> np.ndarray:
        """Flat table of update probabilities, rows (type, Delta), columns chains."""
        W = 2 * self.dmax + 1
        z = self.types[:, None, None] + np.arange(-self.dmax, self.dmax + 1)[None, :, None] * thetas[None, None, :]
        return expit(z).reshape(len(self.types) * W * len(thetas))

    def sweep(self, X: np.ndarray, thetas: np.ndarray, rt=None, U=None, rng=None, col=None):
        """One systematic heat-bath sweep, in place. X has shape (n+1, B), row n
        is the dummy site (0). U (n, B) gives the uniforms (else drawn from rng)."""
        B = X.shape[1]
        if self.types is not None and rt is None:
            rt = self._rt(thetas)
        if col is None:
            col = np.arange(B, dtype=np.intp)[None, :]
        for cl in self._cls:
            I = cl["I"]
            cfg = X[cl["NB"][0]].astype(np.intp)
            for b in range(1, self.r):
                cfg |= X[cl["NB"][b]].astype(np.intp) << b
            cfg |= cl["rowbase"]
            if self.types is not None:
                k = np.take(cl["rows"], cfg, mode="clip")
                k *= B
                k += col
                rho = np.take(rt, k, mode="clip")
            else:
                rho = expit(cl["a"] + np.take(cl["lut"], cfg, mode="clip") * thetas[None, :])
            u = U[I] if U is not None else rng.random((len(I), B))
            X[I] = u < rho

    def glauber(self, thetas, sweeps: int, rng, batch: int = 2048) -> np.ndarray:
        """Independent chains from the all-zeros state, one per entry of thetas,
        each run for `sweeps` sweeps. Returns states, shape (n, len(thetas))."""
        thetas = np.asarray(thetas, dtype=float)
        out = np.zeros((self.n, len(thetas)), dtype=np.uint8)
        for s0 in range(0, len(thetas), batch):
            th = thetas[s0: s0 + batch]
            X = np.zeros((self.n + 1, len(th)), dtype=np.uint8)
            rt = self._rt(th) if self.types is not None else None
            col = np.arange(len(th), dtype=np.intp)[None, :]
            for _ in range(sweeps):
                self.sweep(X, th, rt=rt, rng=rng, col=col)
            out[:, s0: s0 + len(th)] = X[: self.n]
        return out

    def cftp(self, thetas, rng, T_max: int = 1 << 10, batch: int = 1024):
        """Monotone coupling from the past (sweeps as time steps), one exact
        sample per entry of thetas (all >= 0; S must be supermodular). Returns
        (states (n, len) , total sweeps) or (None, sweeps) if some run did not
        coalesce within T_max sweeps."""
        assert np.all(np.asarray(thetas) >= 0)
        thetas = np.asarray(thetas, dtype=float)
        n = self.n
        out = np.zeros((n, len(thetas)), dtype=np.uint8)
        total = 0
        for s0 in range(0, len(thetas), batch):
            th_all = thetas[s0: s0 + batch]
            Bt = len(th_all)
            seed = int(rng.integers(2 ** 62))
            done = np.zeros(Bt, dtype=bool)
            T = 1
            while not done.all():
                if T > T_max:
                    return None, total
                idx = np.nonzero(~done)[0]
                th = th_all[idx]
                rt = self._rt(th) if self.types is not None else None
                col = np.arange(len(idx), dtype=np.intp)[None, :]
                top = np.ones((n + 1, len(idx)), dtype=np.uint8)
                top[n] = 0
                bot = np.zeros((n + 1, len(idx)), dtype=np.uint8)
                for s in range(T, 0, -1):  # the sweep at time -s, same uniforms every time
                    U = np.random.Generator(np.random.PCG64([seed, s])).random((n, Bt))[:, idx]
                    self.sweep(top, th, rt=rt, U=U, col=col)
                    self.sweep(bot, th, rt=rt, U=U, col=col)
                    total += 2 * len(idx)
                coal = np.all(top[:n] == bot[:n], axis=0)
                out[:, s0 + idx[coal]] = top[:n, coal]
                done[idx[coal]] = True
                T *= 2
        return out, total

    # ------------------------------------------------------------ statistics on states
    def S_states(self, X: np.ndarray) -> np.ndarray:
        """S for states X of shape (n, B) (or (n+1, B))."""
        Xp = np.zeros((self.n + 1, X.shape[1]), dtype=np.int64)
        Xp[: self.n] = X[: self.n]
        idx = np.zeros((self.ltc.m, X.shape[1]), dtype=np.int64)
        for b in range(self._A.shape[1]):
            idx |= Xp[self._A[:, b]] << b
        return np.take_along_axis(self._T, idx, axis=1).sum(axis=0)

    def S_rb_states(self, X: np.ndarray, thetas) -> np.ndarray:
        """Rao-Blackwellised S: the average over colour classes I of
        E_theta[S | x_{-I}] = S + sum_{i in I} Delta_i (rho_i - x_i), which is exact
        because the sites of a class share no factor (so, given x_{-I}, they are
        independent with P(x_i = 1) = rho_i). Values lie in [S_lo, S_hi] and the
        mean under mu_theta is E_theta S."""
        B = X.shape[1]
        thetas = np.broadcast_to(np.asarray(thetas, dtype=float), (B,))
        Xp = np.zeros((self.n + 1, B), dtype=np.uint8)
        Xp[: self.n] = X[: self.n]
        corr = np.zeros(B)
        for cl in self._cls:
            I = cl["I"]
            cfg = Xp[cl["NB"][0]].astype(np.intp)
            for b in range(1, self.r):
                cfg |= Xp[cl["NB"][b]].astype(np.intp) << b
            cfg |= cl["rowbase"]
            dl = np.take(cl["lut"], cfg, mode="clip")
            rho = expit(cl["a"] + dl * thetas[None, :])
            corr += (dl * (rho - Xp[I])).sum(axis=0)
        return self.S_states(X) + corr / len(self._cls)

    def U_states(self, X: np.ndarray, theta: float) -> np.ndarray:
        S = self.S_states(X)
        c = S >= self.ltc.t
        if self.ltc.H is not None:
            c &= self.ltc.H.eval_bits(X[: self.n].T.astype(bool))
        return np.where(c, np.exp(-theta * (S - self.ltc.t)), 0.0)


# ---------------------------------------------------------------- interval tools
def maurer_sum_ucb(sum_x: float, range_x: float, delta: float) -> float:
    """Upper confidence bound on E[sum_r X_r] for independent X_r in [0, range_x]:
    Maurer's inequality P(E sum - sum <= -tau) <= exp(-tau^2 / (2 sum E X_r^2))
    with E X_r^2 <= range_x E X_r gives, w.p. >= 1 - delta,
    E sum <= sum + c sqrt(E sum) with c = sqrt(2 range_x ln(1/delta)), i.e.
    sqrt(E sum) <= (c + sqrt(c^2 + 4 sum)) / 2."""
    c = math.sqrt(2 * range_x * math.log(1 / delta))
    y = (c + math.sqrt(c * c + 4 * max(sum_x, 0.0))) / 2
    return y * y


def bernstein_halfwidth(var_bound: float, b: float, delta: float) -> float:
    """u with P(|sum (Y_l - E Y_l)| >= u) <= delta for independent Y_l with
    |Y_l - E Y_l| <= b and sum Var Y_l <= var_bound (Bernstein)."""
    ell = math.log(2 / delta)
    c = b * ell / 3
    return c + math.sqrt(c * c + 2 * var_bound * ell)


def ti_interval(S_vals: np.ndarray, theta: float, mu0: float, S_lo: int, S_hi: int,
                delta_b: float, delta_m: float):
    """Interval for log Z(theta) from one sample S_l ~ mu_{theta_l} per grid point
    theta_l = l theta / L, l = 1..L (L even). Returns (lo, hi, info)."""
    S_vals = np.asarray(S_vals, dtype=np.int64)
    L = len(S_vals)
    assert L >= 2 and L % 2 == 0
    h = theta / L
    RS = float(S_hi - S_lo)
    That = h * float(S_vals.sum())
    Dsum = float(((S_vals[0::2] - S_vals[1::2]).astype(float) ** 2).sum() / 2)
    # sum_l Var_l <= 2 sum_r E D_r (pairs (2r-1, 2r)); D_r in [0, RS^2 / 2]
    Vsum = min(2 * maurer_sum_ucb(Dsum, RS * RS / 2, delta_m), L * RS * RS / 4)
    u = bernstein_halfwidth(h * h * Vsum, h * RS, delta_b)
    gap = h * (S_hi - mu0)  # upper minus lower Riemann sum <= h (mu(theta) - mu(0))
    return That - u - gap, That + u, dict(T=That, u=u, gap=gap, Vsum=Vsum, L=L)


# ---------------------------------------------------------------- the estimator TG
@dataclass
class LocalEstimate:
    """Interval for p in natural-log coordinates (p may underflow doubles)."""

    log_lo: float
    log_hi: float
    log_value: float
    theta: float
    samples_ti: int = 0
    samples_is: int = 0
    sweeps: int = 0
    site_updates: float = 0.0
    delta: float = 0.05
    note: str = ""
    info: dict = field(default_factory=dict)

    @property
    def lo(self) -> float:
        return math.exp(self.log_lo) if self.log_lo > -745 else 0.0

    @property
    def hi(self) -> float:
        return math.exp(min(self.log_hi, 0.0))

    @property
    def value(self) -> float:
        return math.exp(self.log_value) if self.log_value > -745 else 0.0

    @property
    def log10_lo(self) -> float:
        return self.log_lo / math.log(10)

    @property
    def log10_hi(self) -> float:
        return self.log_hi / math.log(10)

    @property
    def ratio(self) -> float:
        return math.exp(self.log_hi - self.log_lo) if self.log_lo > -math.inf else math.inf

    def contains_log(self, log_p: float) -> bool:
        return self.log_lo <= log_p <= self.log_hi

    def contains(self, p: float) -> bool:
        if p == 0:
            return self.log_lo == -math.inf
        return self.contains_log(math.log(p))

    def to_estimate(self) -> Estimate:
        return Estimate(self.value, self.lo, self.hi, self.samples_ti + self.samples_is,
                        self.samples_ti + self.samples_is, self.delta, self.note)


def _exact(log_p: float, note: str) -> LocalEstimate:
    return LocalEstimate(log_p, log_p, log_p, 0.0, note=note)


def tg_estimate(ltc: LTC, q, eps: float = 0.2, delta: float = 0.05, gamma: float = 0.2,
                sampler: str = "glauber", theta: float | None = None, L: int | None = None,
                max_is: int = 200_000, theta_cap: float = 4.0, pilot_points: int = 12,
                pilot_chains: int = 64, rng=None, batch: int = 2048, verbose: bool = False) -> LocalEstimate:
    """Sound interval for p = Pr_D[C = 1] for a local threshold circuit.

    sampler: "glauber" (Dobrushin certificate at theta, margin gamma) or "cftp"
    (exact samples; requires supermodular S, no certificate). theta: the tilt
    (default: chosen by a pilot run so that E_theta S ~ t). L: number of grid
    points for the normaliser (default from eps). The interval contains p with
    probability >= 1 - delta whatever theta, L, budgets and the pilot do."""
    rng = np.random.default_rng() if rng is None else rng
    q = np.asarray(q, dtype=float)
    t = ltc.t
    if t > ltc.S_hi:
        return _exact(-math.inf, "t > max S: p = 0")
    if t <= ltc.S_lo and ltc.H is None:
        return _exact(0.0, "t <= min S: p = 1")
    model = LocalModel(ltc, q)
    n = model.n
    mu0 = model.mu0
    d_b, d_m, d_v, d_c = delta / 4, delta / 4, delta / 4, delta / 4
    note = []

    # ---- tilt and sampler
    cert = None
    if sampler == "glauber":
        th_max = model.theta_max(gamma, hi=theta_cap)
    elif sampler == "cftp":
        if not model.is_supermodular():
            return LocalEstimate(-math.inf, 0.0, -math.inf, 0.0, note="cftp needs supermodular S: no verdict")
        th_max = theta_cap
    else:
        raise ValueError(sampler)
    if mu0 >= t:
        th = 0.0
    elif theta is not None:
        th = float(min(max(theta, 0.0), th_max))
    else:
        th = _pilot(model, t, th_max, sampler, gamma, pilot_points, pilot_chains, rng)
    if th > 0 and sampler == "glauber":
        cert = model.certificate(th, gamma)
        if cert.alpha >= 1:
            th = 0.0
            note.append("certificate failed: theta = 0")

    # ---- budgets and the coupling level
    if th == 0.0:
        L = 0
    elif L is None:
        L = _default_L(th, ltc, eps)
    L += L % 2
    N_tot = L + max_is
    eta = d_c / max(N_tot, 1)
    sweeps = 0
    if th > 0 and sampler == "glauber":
        sweeps = cert.sweeps(eta, n)
        if sweeps is None:
            return LocalEstimate(-math.inf, 0.0, -math.inf, th, note="certificate too weak for eta: no verdict")
    cftp_sweeps = 0

    def draw_states(thetas):
        nonlocal cftp_sweeps
        thetas = np.asarray(thetas, dtype=float)
        if np.all(thetas == 0):
            return (rng.random((n, len(thetas))) < q[:, None]).astype(np.uint8)
        if sampler == "glauber":
            return model.glauber(thetas, sweeps, rng, batch=batch)
        X, s = model.cftp(thetas, rng)
        cftp_sweeps += s
        if X is None:
            raise _Timeout()
        return X

    try:
        # ---- normaliser: log Z(th) in [zlo, zhi]
        if th > 0:
            grid = th * np.arange(1, L + 1) / L
            Svals = np.concatenate([model.S_states(draw_states(grid[s0: s0 + batch]))
                                    for s0 in range(0, L, batch)])
            zlo, zhi, ti = ti_interval(Svals, th, mu0, ltc.S_lo, ltc.S_hi, d_b, d_m)
        else:
            zlo = zhi = 0.0
            ti = dict(u=0.0, gap=0.0, Vsum=0.0, L=0)
        # ---- importance sampling: V(th) = E_th[U]
        def draw(k):
            return np.concatenate([model.U_states(draw_states(np.full(min(batch, k - s0), th)), th)
                                   for s0 in range(0, k, batch)])

        est = sequential_mean(draw, eps / 3, d_v, max_samples=max_is, first=min(batch, max_is))
    except _Timeout:
        return LocalEstimate(-math.inf, 0.0, -math.inf, th, note="CFTP timeout: no verdict")
    widen = 1e-9
    log_lo = (zlo - th * t + math.log(est.lo) - widen) if est.lo > 0 else -math.inf
    log_hi = min(0.0, zhi - th * t + (math.log(est.hi) if est.hi > 0 else -math.inf) + widen)
    zmid = (zlo + zhi) / 2
    log_val = zmid - th * t + math.log(est.value) if est.value > 0 else -math.inf
    log_val = min(max(log_val, log_lo), log_hi)
    upd = (L + est.samples) * n * (sweeps if sampler == "glauber" else 0) + cftp_sweeps * n
    note.append(f"theta={th:.4g}, L={L}, IS={est.samples}, sweeps={sweeps}, "
                f"logZ in [{zlo:.4f},{zhi:.4f}], V in [{est.lo:.4g},{est.hi:.4g}]")
    if cert is not None:
        note.append(f"alpha={cert.alpha:.4f} ({'weighted' if cert.weighted else 'unweighted'}; "
                    f"unweighted {cert.alpha_unweighted:.4f})")
    return LocalEstimate(log_lo, log_hi, log_val, th, L, est.samples, sweeps, float(upd), delta, "; ".join(note),
                         info=dict(ti=ti, V=(est.lo, est.hi, est.value), mu0=mu0, theta_max=th_max,
                                   alpha=None if cert is None else cert.alpha,
                                   F=None if cert is None else cert.F))


class _Timeout(Exception):
    pass


def _default_L(th: float, ltc: LTC, eps: float) -> int:
    """Grid size so that the range and discretisation terms are small next to
    eps (the variance term is governed by the data)."""
    RS = max(ltc.S_hi - ltc.S_lo, 1)
    return int(min(max(2000, 60 * th * RS / eps), 400_000))


def _pilot(model: LocalModel, t: int, th_max: float, sampler: str, gamma: float, points: int, chains: int,
           rng) -> float:
    """theta with E_theta S ~ t, by a coarse pilot (does not affect soundness)."""
    if th_max <= 0:
        return 0.0
    grid = np.linspace(0, th_max, points + 1)[1:]
    mus = [model.mu0]
    for th in grid:
        if sampler == "glauber":
            cert = model.certificate(th, gamma)
            s = cert.sweeps(1e-3, model.n) or 1
            X = model.glauber(np.full(chains, th), s, rng)
        else:
            X, _ = model.cftp(np.full(chains, th), rng)
            if X is None:
                break
        mus.append(float(model.S_states(X).mean()))
    ths = np.concatenate([[0.0], grid[: len(mus) - 1]])
    mus = np.maximum.accumulate(np.array(mus))
    if mus[-1] < t:
        return float(ths[-1])
    j = int(np.argmax(mus >= t))
    if j == 0:
        return 0.0
    f = (t - mus[j - 1]) / max(mus[j] - mus[j - 1], 1e-12)
    return float(ths[j - 1] + f * (ths[j] - ths[j - 1]))


# ---------------------------------------------------------------- families
def _rand_table(rng, kind: str, k: int = 3, piv: float = 0.5) -> np.ndarray:
    """A random truth table on k inputs (last input private), with the private
    input pivotal with probability >= piv under the uniform distribution."""
    c = np.arange(1 << k)
    while True:
        if kind == "random":
            T = rng.integers(0, 2, size=1 << k)
        elif kind == "monotone":
            # random monotone function: up-closure of random minimal terms
            T = np.zeros(1 << k, dtype=np.int64)
            for _ in range(int(rng.integers(1, 4))):
                mt = int(rng.integers(1, 1 << k))
                T |= ((c & mt) == mt).astype(np.int64)
        elif kind == "maj":
            T = (np.array([bin(int(v)).count("1") for v in c]) * 2 > k).astype(np.int64)
        elif kind == "monomial":
            T = (c == (1 << k) - 1).astype(np.int64)
        else:
            raise ValueError(kind)
        T = np.asarray(T, dtype=np.int64)
        top = 1 << (k - 1)
        pv = np.mean(T[c[c < top]] != T[c[c < top] | top])
        deps = all(np.any(T[c[(c >> b) & 1 == 0]] != T[c[(c >> b) & 1 == 0] | (1 << b)]) for b in range(k))
        if kind in ("maj", "monomial") or (pv >= piv and deps):
            return T


def chain_ltc(m: int, t: int, rng, kind: str = "random", piv: float = 0.5) -> LTC:
    """z_0..z_m, y_1..y_m (n = 2m+1); factor j is g_j(z_{j-1}, z_j, y_j) with y_j
    private. Treewidth 2, so p is computable exactly (chain_tail)."""
    scopes = [(j - 1, j, m + j) for j in range(1, m + 1)]
    tables = [_rand_table(rng, kind, 3, piv) for _ in range(m)]
    return LTC(2 * m + 1, scopes, tables, t)


def chain_distribution(ltc: LTC, q) -> np.ndarray:
    """Exact law of S for a chain_ltc (transfer matrix over (z_j, partial sum))."""
    m = ltc.m
    q = np.asarray(q, dtype=float)
    f = np.zeros((2, m + 1))
    f[0, 0], f[1, 0] = 1 - q[0], q[0]
    for j in range(1, m + 1):
        A, T = ltc.scopes[j - 1], ltc.tables[j - 1]
        g = np.zeros((2, m + 1))
        for z0 in (0, 1):
            for z1 in (0, 1):
                for y in (0, 1):
                    w = (q[A[1]] if z1 else 1 - q[A[1]]) * (q[A[2]] if y else 1 - q[A[2]])
                    v = int(T[z0 | (z1 << 1) | (y << 2)])
                    if v:
                        g[z1, 1:] += w * f[z0, :-1]
                    else:
                        g[z1] += w * f[z0]
        f = g
    return f.sum(axis=0)


def chain_log_tail(ltc: LTC, q, t: int | None = None) -> float:
    """log Pr[S >= t] for a chain_ltc, exactly (the law of S is exact in floating
    point: all terms are nonnegative)."""
    t = ltc.t if t is None else t
    dist = chain_distribution(ltc, q)
    return math.log(dist[t:].sum()) if dist[t:].sum() > 0 else -math.inf


def regular_ltc(N: int, t: int, rng, kind: str = "random", deg: int = 3, piv: float = 0.5) -> LTC:
    """Vertices x_0..x_{N-1} of a random deg-regular graph; one factor per edge
    e = {u, v}, g_e(x_u, x_v, y_e) with a private y_e. Treewidth Theta(N) whp."""
    import networkx as nx
    G = nx.random_regular_graph(deg, N, seed=int(rng.integers(2 ** 31)))
    E = sorted(tuple(sorted(e)) for e in G.edges())
    scopes = [(u, v, N + e) for e, (u, v) in enumerate(E)]
    tables = [_rand_table(rng, kind, 3, piv) for _ in E]
    return LTC(N + len(E), scopes, tables, t)
