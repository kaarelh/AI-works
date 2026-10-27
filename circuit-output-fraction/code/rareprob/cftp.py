"""Certified telescoping with Las Vegas samplers for unate CNFs.

Unate CNF: every variable occurs with one sign. Let y_v = [x_v takes the value
that falsifies its literals]; a clause is violated iff all its y's are 1, so
F = (no clause violated) is a down-set in y. For an active set of clauses,
heat-bath Glauber dynamics on D(.|F) is anti-monotone, and the bounding-chain
coupling from the past of Haggstrom-Nelander gives exact samples:

    L_v <- [u < r_v] and ok(U, v),     U_v <- [u < r_v] and ok(L, v),

where ok(Y, v) = no active clause containing v has all its other y's = 1.
Starting from L = 0, U = 1 at time -T and coalescing (L = U) at time 0
yields an exact sample; T doubles until coalescence or T_max ("fail").

Telescoping: order the clauses into stages whose Harris bound
prod (1 - D(B_c)) is >= 1/2, so each ratio r_k = Pr_{pi_{k-1}}[stage k
satisfied] is >= 1/2. Estimate each r_k from the halted samples. The
truncation bias is at most theta_k = Pr[fail] in total variation
(certified by a KL upper confidence bound on the failure rate), so
r_k lies in [r_hat_lo - theta_k, r_hat_hi + theta_k]; and since r_k >= 1/2
is guaranteed by Harris, the product estimator has relative variance
at most (1 + 1/N)^K - 1, which gives an (eps, delta) guarantee through a
median of independent repetitions.
"""

from __future__ import annotations

import math

import numpy as np

from .dist import Product
from .janson import is_unate
from .stats import Estimate, kl_interval


class UnateSystem:
    def __init__(self, clauses, D: Product):
        assert is_unate(clauses)
        self.n = D.n
        self.clauses = [list(c) for c in clauses]
        bad = {}
        for c in clauses:
            for i, b in c:
                bad[i] = 1 - b  # value of x_i that falsifies its literals
        self.bad = bad
        r = np.zeros(self.n)
        for i in range(self.n):
            r[i] = D.lit_prob(i, bad[i]) if i in bad else 0.0
        self.r = r  # Pr[y_i = 1]
        self.vars = [[i for i, _ in c] for c in clauses]
        self.pb = np.array([math.prod(r[i] for i in vs) for vs in self.vars])  # D(B_c)

    def stages(self) -> list[list[int]]:
        out, cur, prod = [], [], 1.0
        for c in range(len(self.clauses)):
            f = 1.0 - self.pb[c]
            if cur and prod * f < 0.5:
                out.append(cur)
                cur, prod = [], 1.0
            cur.append(c)
            prod *= f
        if cur:
            out.append(cur)
        return out

    def neighbour_table(self, active: list[int]):
        """nbr[v] (deg_max, k_max-1) indices into y extended with columns
        n (always 1) and n+1 (always 0)."""
        n = self.n
        inc = [[] for _ in range(n)]
        for c in active:
            for v in self.vars[c]:
                inc[v].append([u for u in self.vars[c] if u != v])
        dmax = max(1, max(len(x) for x in inc))
        kmax = max(1, max((len(o) for x in inc for o in x), default=1))
        T = np.full((n, dmax, kmax), n, dtype=np.int64)  # pad with the always-1 column
        for v in range(n):
            for j, others in enumerate(inc[v]):
                T[v, j, :len(others)] = others
            for j in range(len(inc[v]), dmax):
                T[v, j, 0] = n + 1  # absent clause: contains an always-0 entry, never fires
        return T

    def violated(self, Y: np.ndarray, cls: list[int]) -> np.ndarray:
        """Any clause in cls violated (all y = 1) for each row of Y (B, n)."""
        out = np.zeros(Y.shape[0], dtype=bool)
        for c in cls:
            out |= Y[:, self.vars[c]].all(axis=1)
        return out


def cftp_samples(sys_: UnateSystem, active: list[int], B: int, rng, T0: int | None = None,
                 T_max: int = 1 << 16):
    """B independent runs of bounding-chain CFTP for D(.|no active clause
    violated). Returns (samples of the halted runs as y arrays, number failed)."""
    n = sys_.n
    nbr = sys_.neighbour_table(active)
    r = sys_.r
    T0 = T0 or 4 * n
    # randomness for times -1, -2, ...: grows as T doubles
    sites = rng.integers(0, n, size=(B, T0))
    us = rng.random((B, T0))
    T = T0
    done = np.zeros(B, dtype=bool)
    result = np.zeros((B, n), dtype=bool)
    while True:
        idx = np.nonzero(~done)[0]
        if idx.size == 0 or T > T_max:
            break
        L = np.zeros((idx.size, n + 2), dtype=bool)
        U = np.ones((idx.size, n + 2), dtype=bool)
        L[:, n] = True
        U[:, n + 1] = False
        rows = np.arange(idx.size)
        for t in range(T - 1, -1, -1):  # time -(t+1) ... -1
            v = sites[idx, t]
            u = us[idx, t]
            acc = u < r[v]
            nb = nbr[v]  # (b, dmax, kmax)
            okU = ~U[rows[:, None, None], nb].all(axis=2).any(axis=1)
            okL = ~L[rows[:, None, None], nb].all(axis=2).any(axis=1)
            L[rows, v] = acc & okU
            U[rows, v] = acc & okL
        coal = (L[:, :n] == U[:, :n]).all(axis=1)
        result[idx[coal]] = L[coal, :n]
        done[idx[coal]] = True
        # double: prepend fresh randomness for times -(T+1) ... -2T
        sites = np.concatenate([sites, rng.integers(0, n, size=(B, T))], axis=1)
        us = np.concatenate([us, rng.random((B, T))], axis=1)
        T *= 2
    return result[done], int((~done).sum())


def _reps_for(delta: float, fail: float = 0.25) -> int:
    """Smallest odd R with Pr[Bin(R, fail) >= (R+1)/2] <= delta."""
    R = 1
    while True:
        tail = sum(math.comb(R, j) * fail**j * (1 - fail) ** (R - j) for j in range((R + 1) // 2, R + 1))
        if tail <= delta:
            return R
        R += 2


def telescoping_estimate(clauses, D: Product, delta: float = 0.05, N: int = 2000,
                         rng=None, T_max: int = 1 << 15) -> Estimate:
    """Certified telescoping for a unate CNF.

    Each repetition multiplies stage ratios estimated from N CFTP runs. With
    r_k >= 1/2 (Harris) and certified truncation theta_k <= 0.1, one
    repetition has relative variance v <= (1 + 1.5/N)^K - 1 around its mean,
    which is within prod(1 +- theta_k/(1/2 - theta_k)) of p. Chebyshev with
    eps0 = 2 sqrt(v) gives probability >= 3/4 per repetition, and the median
    of R repetitions (R from delta/2) is within (1 +- eps0)(1 +- bias) of p
    except with probability delta/2; the truncation certificates (one per
    stage, pooling that stage's R*N runs) use the other delta/2. The returned interval is that guarantee."""
    rng = np.random.default_rng() if rng is None else rng
    S = UnateSystem(clauses, D)
    stages = S.stages()
    K = len(stages)
    R = _reps_for(delta / 2)
    fails = np.zeros(K, dtype=int)
    logs, evals, nmin = [], 0, N
    for _ in range(R):
        logp = 0.0
        active: list[int] = []
        for k, st in enumerate(stages):
            Y, f = cftp_samples(S, active, N, rng, T_max=T_max)
            evals += N
            fails[k] += f
            if Y.shape[0] == 0:
                return Estimate(0.0, 0.0, 1.0, evals, evals, delta, "no coalescence: no verdict")
            nmin = min(nmin, Y.shape[0])
            rk = 1.0 - S.violated(Y, st).mean()
            logp += math.log(max(rk, 1e-300))
            active += st
        logs.append(logp)
    # certified truncation per stage, pooling the R*N runs of that stage's sampler
    bias = 0.0
    for k in range(K):
        _, th = kl_interval(fails[k] / (R * N), R * N, delta / (2 * K))
        if th > 0.1:
            return Estimate(0.0, 0.0, 1.0, evals, evals, delta, "truncation not certified: no verdict")
        bias += th / (0.5 - th)
    biases = [bias]
    med = float(np.median(logs))
    v = (1 + 1.5 / nmin) ** K - 1
    eps0 = 2 * math.sqrt(v)
    b = max(biases)
    lo = math.exp(med) / ((1 + eps0) * math.exp(b))
    hi = math.exp(med) / ((1 - eps0) * math.exp(-b)) if eps0 < 1 else math.inf
    harris = math.exp(np.log1p(-S.pb).sum())
    lo = max(lo, harris)  # Harris lower bound is deductive
    return Estimate(math.exp(med), lo, hi, evals, evals, delta,
                    f"stages {K}, repetitions {R}, Harris bound {harris:.3g}, eps0 {eps0:.3g}, bias {b:.2g}")
