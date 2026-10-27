"""Certified telescoping with Las Vegas samplers for unate CNFs.

Unate CNF: every variable occurs with one sign (a literal repeated within a
clause counts once). Let y_v = [x_v takes the value that falsifies its
literals]; a clause c is violated (event B_c) iff all its y's are 1, so
F = (no clause violated) is a down-set in y. For an active set of clauses with
D(F) > 0, heat-bath Glauber dynamics on D(.|F) is anti-monotone
(Pr[y_v = 1 | y_-v] is decreasing in y_-v), and the bounding-chain coupling
from the past of Haggstrom-Nelander gives exact samples:

    L_v <- [u < r_v] and ok(U, v),     U_v <- [u < r_v] and ok(L, v),

where ok(Y, v) = no active clause containing v has all its other y's = 1.
Starting from L = 0, U = 1 at time -T and coalescing (L = U) at time 0
yields an exact sample; T doubles until coalescence or T_max ("fail").

Telescoping: p = prod_k r_k with r_k = Pr_{pi_{k-1}}[no clause of stage k
violated], pi_{k-1} = D(. | no clause of stages < k violated). The clauses are
grouped greedily into stages whose Harris product is >= 1/2 where possible (a
clause with D(B_c) > 1/2 is a stage of its own); by Harris,
r_k >= h_k := prod_{c in stage k} (1 - D(B_c)), with h_k rounded downwards.
The guarantee of telescoping_estimate is stated in its docstring.
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
        # a repeated literal is one condition: B_c = {y_S = 1} with S the SET of variables of c
        self.clauses = [sorted({(i, b) for i, b in c}) for c in clauses]
        bad = {}
        for c in self.clauses:
            for i, b in c:
                bad[i] = 1 - b  # value of x_i that falsifies its literals
        self.bad = bad
        r = np.zeros(self.n)
        for i in range(self.n):
            r[i] = D.lit_prob(i, bad[i]) if i in bad else 0.0
        self.r = r  # Pr[y_i = 1]
        self.vars = [[i for i, _ in c] for c in self.clauses]
        self.pb = np.array([math.prod(r[i] for i in vs) for vs in self.vars])  # D(B_c), up to rounding
        # D(B_c) = 1 exactly iff every literal of c has probability exactly 0 (decided on D.q itself)
        self.sure = [all((D.q[i] == 0.0) if b else (D.q[i] == 1.0) for i, b in c) for c in self.clauses]
        # upper bounds on D(B_c): each factor of pb carries relative error <= 2^-53, the
        # product another 2^-53 per factor; w is a generous bound on the total
        w = 2.0 ** -36 * (2 + 2 * max((len(v) for v in self.vars), default=0))
        self.pb_hi = np.minimum(1.0, self.pb * (1 + w))
        # cftp_samples sets y_v = 1 with probability s_v = ceil(fl(r_v) 2^53) 2^-53 (uniforms on
        # the 2^-53 grid), |s_v - r_v| < 2^-52; so each point mass of the sampled product law is
        # within a factor e^{+-kappa} of D's (variables in no clause do not matter)
        mv = [min(float(D.q[i]), 1.0 - float(D.q[i])) for i in bad]
        ok = all(m == 0.0 or m >= 2.0 ** -40 for m in mv)
        self.kappa = sum(2.0 ** -50 / m for m in mv if m > 0) if ok else math.inf

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

    def harris_lower(self, cls) -> float:
        """A lower bound on prod_{c in cls} (1 - D(B_c)), rounded outwards; by
        Harris it is a lower bound on D(no clause of cls violated) and, for a
        stage, on its ratio r_k."""
        cls = list(cls)
        with np.errstate(divide="ignore"):
            s = float(np.sum(np.log1p(-self.pb_hi[cls]))) if cls else 0.0
        if s == -math.inf:
            return 0.0
        return max(0.0, math.exp(s) * (1 - 2.0 ** -36 * (len(cls) + 2)))

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
    """Certified telescoping for a unate CNF; the returned [lo, hi] contains p
    with probability >= 1 - delta, for every unate CNF, N and T_max.

    If some clause is false with probability 1, p = 0 and [0, 0] is returned.
    Otherwise, with stages k = 1..K and h_k <= prod_{c in k}(1 - D(B_c)) <= r_k
    (Harris), each of R repetitions (R odd, Pr[Bin(R, 1/4) >= (R+1)/2] <=
    delta/2) runs the stage-k sampler (CFTP truncated at T_max) N times and
    estimates r_k by the fraction r^_k of its n_k halted runs that satisfy
    stage k; the repetition's estimate is Z^ = prod_k r^_k. Let theta_k be the
    stage-k failure probability and r'_k the probability, under the law pi'_k
    of the halted outputs, that stage k is satisfied; d_TV(pi'_k, pi_{k-1}) <=
    theta_k, so |r'_k - r_k| <= theta_k. Guarantee:

    (1) Truncation. th_k = KL upper confidence bound on theta_k from the
        R*N runs of stage k (level delta/(2K) two-sided, so th_k >= theta_k for
        all k except with probability delta/4). If some th_k >= h_k: no verdict.
    (2) Bias. On that event r_k >= h_k > th_k >= theta_k and, with
        a_k = th_k/(h_k - th_k) and b = sum_k a_k,
            r_k/r'_k <= 1/(1 - theta_k/r_k) <= 1 + a_k <= e^{a_k},
            r_k/r'_k >= 1/(1 + theta_k/r_k) >= e^{-th_k/h_k} >= e^{-a_k},
        so p = prod_k r_k lies in [Z' e^-b, Z' e^b] with Z' = prod_k r'_k.
    (3) Variance. Given all halted counts, r^_k is a mean of n_k i.i.d.
        Bernoulli(r'_k), independent over k and repetitions, and
        r'_k >= h_k - th_k > 0, so E Z^ = Z' and
            Var Z^ / Z'^2 <= prod_k (1 + (1 - h_k + th_k)/((h_k - th_k) n_k)) - 1
                          <= v  (n_k replaced by its minimum over repetitions).
        Chebyshev with eps0 = 2 sqrt(v): Pr[|Z^/Z' - 1| > eps0] <= 1/4 for each
        repetition, so the median M of the R repetitions lies in
        [(1 - eps0) Z', (1 + eps0) Z'] except with probability delta/2.
    Hence p lies in [M e^-b/(1 + eps0), M e^b/(1 - eps0)] (upper end 1 if
    eps0 >= 1) except with probability 3 delta/4. Floating point: the sampler
    realises a product law whose point masses are within e^{+-kappa} of D's
    (UnateSystem.kappa), so (1)-(3) are applied to that law with h_k replaced
    by e^{-2 kappa} h_k, and the interval is widened by e^{+-kappa}. The lower
    end is raised to the deductive Harris bound prod_c (1 - D(B_c));
    endpoints are rounded outwards. If the median repetition contains a zero
    ratio, or the statistical upper end falls below the Harris bound, there is
    no verdict. N is an input (not eps): the width of the interval is
    data-driven, and it is wide unless N >> sum_k 1/h_k."""
    rng = np.random.default_rng() if rng is None else rng
    S = UnateSystem(clauses, D)
    if any(S.sure):
        return Estimate(0.0, 0.0, 0.0, 0, 0, delta, "a clause is false with probability 1: p = 0")

    def no_verdict(evals, why):
        return Estimate(0.0, 0.0, 1.0, evals, evals, delta, why + ": no verdict")

    if not math.isfinite(S.kappa):
        return no_verdict(0, "a marginal is too close to 0 or 1 for the floating-point sampler")
    stages = S.stages()
    K = len(stages)
    harris = S.harris_lower(range(len(S.clauses)))
    # r_k >= h_k under D, hence >= e^{-2 kappa} h_k under the law the sampler realises
    h = np.array([S.harris_lower(st) for st in stages]) * math.exp(-2 * S.kappa)
    R = _reps_for(delta / 2)
    fails = np.zeros(K, dtype=int)
    nmin = np.full(K, N)
    logs, evals = [], 0
    for _ in range(R):
        logp = 0.0
        active: list[int] = []
        for k, st in enumerate(stages):
            Y, f = cftp_samples(S, active, N, rng, T_max=T_max)
            evals += N
            fails[k] += f
            if Y.shape[0] == 0:
                return no_verdict(evals, "no coalescence")
            nmin[k] = min(nmin[k], Y.shape[0])
            rk = 1.0 - S.violated(Y, st).mean()
            logp += math.log(rk) if rk > 0 else -math.inf
            active += st
        logs.append(logp)
    # certified truncation per stage, pooling the R*N runs of that stage's sampler
    th = np.array([kl_interval(fails[k] / (R * N), R * N, delta / (2 * K))[1] for k in range(K)])
    if np.any(th >= h):
        return no_verdict(evals, "truncation not certified below the Harris guarantee")
    b = float(np.sum(th / (h - th)))
    v = math.prod(1 + (1 - h[k] + th[k]) / ((h[k] - th[k]) * nmin[k]) for k in range(K)) - 1
    eps0 = 2 * math.sqrt(v)
    med = float(np.median(logs))
    if med == -math.inf:
        return no_verdict(evals, "zero ratio in the median repetition")
    kap = S.kappa  # from the sampled law's p back to D's p
    lo = math.exp(med - math.log1p(eps0) - b - kap) * (1 - 1e-12)
    if eps0 < 1:
        hi = min(1.0, max(math.exp(med + b - math.log1p(-eps0) + kap) * (1 + 1e-12), math.ulp(0.0)))
    else:
        hi = 1.0
    lo = max(lo, harris)  # Harris lower bound is deductive
    if hi < lo:
        return no_verdict(evals, "statistical upper end below the Harris bound")
    return Estimate(math.exp(med), lo, hi, evals, evals, delta,
                    f"stages {K}, repetitions {R}, Harris bound {harris:.3g}, "
                    f"min stage guarantee {float(h.min()):.3g}, eps0 {eps0:.3g}, bias {b:.2g}")
