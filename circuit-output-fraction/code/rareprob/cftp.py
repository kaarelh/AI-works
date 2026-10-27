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
from .janson import _NORMAL2, check_clauses, exp_down, exp_up
from .stats import Estimate, kl_interval


class UnateSystem:
    def __init__(self, clauses, D: Product):
        # explicit check (an assert would vanish under python -O): the Harris
        # bound and the anti-monotone sampler need a unate CNF
        check_clauses(clauses, D.n)
        self.n = D.n
        # a repeated literal is one condition: B_c = {y_S = 1} with S the SET of variables of c
        self.clauses = [sorted({(int(i), int(b)) for i, b in c}) for c in clauses]
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
        # 2^-36 (|cls| + 2) bounds the rounding error of s; 0 below the normal range
        return exp_down(s, 2.0 ** -36 * (len(cls) + 2))

    def violated(self, Y: np.ndarray, cls: list[int]) -> np.ndarray:
        """Any clause in cls violated (all y = 1) for each row of Y (B, n)."""
        out = np.zeros(Y.shape[0], dtype=bool)
        for c in cls:
            out |= Y[:, self.vars[c]].all(axis=1)
        return out


def cftp_samples(sys_: UnateSystem, active: list[int], B: int, rng, T0: int | None = None,
                 T_max: int = 1 << 16, chunk: int = 1024):
    """B independent runs of bounding-chain CFTP for D(.|no active clause
    violated). Returns (samples of the halted runs as (b, n) y arrays,
    number failed).

    Only the variables A of the active clauses form the chain: the target is
    D(.|F) on A times the independent marginals elsewhere, so the other
    variables are drawn directly with the chain's own update law
    (y_v = [u < r_v]; r_v = 0 for a variable in no clause), and coalescence
    is tested on A only. The horizon starts at T0 = min(4|A|, T_max) (at
    least 1) and doubles while some run has not coalesced and T <= T_max.
    The randomness of the update at each time is fixed for every run across
    horizons, as CFTP requires; it is regenerated from per-block seeds in
    time chunks of `chunk` steps for the runs still pending, so memory is
    O(B (|A| + chunk)) instead of O(B T_max)."""
    n = sys_.n
    A = sorted({v for c in active for v in sys_.vars[c]})
    nA = len(A)
    r = sys_.r
    result = np.zeros((B, n), dtype=bool)
    rest = np.setdiff1d(np.arange(n), np.array(A, dtype=np.int64))
    if rest.size:
        result[:, rest] = rng.random((B, rest.size)) < r[rest]
    if nA == 0 or B == 0:
        return result, 0
    nbr = _local_neighbours(sys_, active, A)
    rA = r[A]
    A_arr = np.array(A, dtype=np.int64)
    T = max(1, min(int(T0) if T0 else 4 * nA, T_max))
    blocks: list[tuple[int, int, int, np.ndarray]] = []  # (start, length, seed, owners)
    covered = 0
    pending = np.arange(B)
    while pending.size and T <= T_max:
        if T > covered:  # fresh randomness for times -(covered+1) ... -T
            blocks.append((covered, T - covered, int(rng.integers(0, 2**63)), pending.copy()))
            covered = T
        b = pending.size
        L = np.zeros((b, nA + 2), dtype=bool)
        U = np.ones((b, nA + 2), dtype=bool)
        L[:, nA] = True
        U[:, nA + 1] = False
        rows = np.arange(b)
        for start, length, seed, owners in reversed(blocks):
            sel = np.searchsorted(owners, pending)  # pending is a subset of owners
            nchunks = -(-length // chunk)
            for ci in range(nchunks - 1, -1, -1):
                w = min(chunk, length - ci * chunk)
                g = np.random.Generator(np.random.PCG64(np.random.SeedSequence([seed, ci])))
                sites = g.integers(0, nA, size=(owners.size, w))[sel]
                us = g.random((owners.size, w))[sel]
                for t in range(w - 1, -1, -1):  # time -(start + ci*chunk + t + 1), earliest first
                    v = sites[:, t]
                    acc = us[:, t] < rA[v]
                    nb = nbr[v]  # (b, dmax, kmax)
                    okU = ~U[rows[:, None, None], nb].all(axis=2).any(axis=1)
                    okL = ~L[rows[:, None, None], nb].all(axis=2).any(axis=1)
                    L[rows, v] = acc & okU
                    U[rows, v] = acc & okL
        coal = (L[:, :nA] == U[:, :nA]).all(axis=1)
        result[np.ix_(pending[coal], A_arr)] = L[coal, :nA]
        pending = pending[~coal]
        T *= 2
    done = np.ones(B, dtype=bool)
    done[pending] = False
    return result[done], int(pending.size)


def _local_neighbours(sys_: UnateSystem, active: list[int], A: list[int]) -> np.ndarray:
    """nbr[j] (deg_max, k_max - 1): for the j-th variable of A, the other
    variables (as indices into A) of each active clause containing it, padded
    with column |A| (always 1); absent clauses contain column |A| + 1
    (always 0), so they never fire."""
    nA = len(A)
    pos = {v: j for j, v in enumerate(A)}
    inc: list[list[list[int]]] = [[] for _ in range(nA)]
    for c in active:
        vs = [pos[v] for v in sys_.vars[c]]
        for j in vs:
            inc[j].append([u for u in vs if u != j])
    dmax = max(1, max(len(x) for x in inc))
    kmax = max(1, max((len(o) for x in inc for o in x), default=1))
    T = np.full((nA, dmax, kmax), nA, dtype=np.int64)
    for j in range(nA):
        for d, others in enumerate(inc[j]):
            T[j, d, :len(others)] = others
        for d in range(len(inc[j]), dmax):
            T[j, d, 0] = nA + 1
    return T


def _reps_for(delta: float, fail: float = 0.25) -> int:
    """Smallest odd R with Pr[Bin(R, fail) >= (R+1)/2] <= delta (0 < fail < 1/2).

    The tail is evaluated in log space (no overflow for tiny delta) with a
    margin of 1e-9 in the log for its rounding, and the search is a
    bisection over odd R: the majority of an odd number of independent
    trials that succeed with probability 1 - fail > 1/2 errs less often as R
    grows. Its upper bracket R_H, the smallest odd R >= ln(1/delta) /
    (2 (1/2 - fail)^2), is valid by Hoeffding's inequality,
    Pr[Bin(R, fail) >= R/2] <= exp(-2 R (1/2 - fail)^2)."""
    if not 0 < fail < 0.5:
        raise ValueError("_reps_for needs 0 < fail < 1/2")
    if not delta > 0:
        raise ValueError("_reps_for needs delta > 0")
    if delta >= fail:
        return 1
    lf, l1f, ld = math.log(fail), math.log1p(-fail), math.log(delta)

    def ok(R: int) -> bool:
        lg = math.lgamma(R + 1)
        terms = [lg - math.lgamma(j + 1) - math.lgamma(R - j + 1) + j * lf + (R - j) * l1f
                 for j in range((R + 1) // 2, R + 1)]
        M = max(terms)
        return M + math.log(math.fsum(math.exp(t - M) for t in terms)) + 1e-9 <= ld

    hi = math.ceil(-ld / (2 * (0.5 - fail) ** 2))
    hi += 1 - hi % 2  # odd, and valid by Hoeffding
    lo = 1  # invalid: delta < fail = Pr[Bin(1, fail) >= 1]
    while hi - lo > 2:  # invariant: lo invalid, hi valid, both odd
        mid = (lo + hi) // 2
        mid += 1 - mid % 2
        if mid >= hi:
            mid = hi - 2
        if mid <= lo:
            break
        if ok(mid):
            hi = mid
        else:
            lo = mid
    return hi


def _stat_interval(med: float, b: float, eps0: float, kap: float) -> tuple[float, float]:
    """[e^{med - b - kap}/(1 + eps0), e^{med + b + kap}/(1 - eps0)], upper end 1 if
    eps0 >= 1, rounded outwards: med carries a relative error below 2^-50, b, eps0
    and kap are upper bounds, and 2^-48 times the sum of the magnitudes bounds the
    rounding error of each exponent."""
    l1 = math.log1p(eps0)
    lo = exp_down(med - l1 - b - kap, 2.0 ** -48 * (abs(med) + l1 + b + kap))
    if not eps0 < 1:
        return lo, 1.0
    l2 = -math.log1p(-eps0)
    hi = exp_up(med + b + l2 + kap, 2.0 ** -48 * (abs(med) + b + l2 + kap))
    return lo, min(1.0, hi)


def telescoping_estimate(clauses, D: Product, delta: float = 0.05, N: int = 2000,
                         rng=None, T_max: int = 1 << 15) -> Estimate:
    """Certified telescoping for a unate CNF; the returned [lo, hi] contains p
    with probability >= 1 - delta, for every unate CNF, N and T_max.

    With no clauses p = 1 and [1, 1] is returned; if some clause is false with
    probability 1, p = 0 and [0, 0] is returned.
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
    end is raised to the deductive Harris bound prod_c (1 - D(B_c)). Rounding:
    h_k is rounded down and b, v, eps0 up, log Z^ is summed with fsum, and
    the endpoints are rounded outwards (the lower end is 0 below the normal
    float range). If the median repetition contains a zero ratio, or the
    statistical upper end falls below the Harris bound, there is no verdict.
    N is an input (not eps): the width of the interval is data-driven, and it
    is wide unless N >> sum_k 1/h_k."""
    rng = np.random.default_rng() if rng is None else rng
    S = UnateSystem(clauses, D)
    if not S.clauses:
        return Estimate(1.0, 1.0, 1.0, 0, 0, delta, "no clauses: p = 1")
    if any(S.sure):
        return Estimate(0.0, 0.0, 0.0, 0, 0, delta, "a clause is false with probability 1: p = 0")

    def no_verdict(evals, why):
        return Estimate(0.0, 0.0, 1.0, evals, evals, delta, why + ": no verdict")

    if not math.isfinite(S.kappa):
        return no_verdict(0, "a marginal is too close to 0 or 1 for the floating-point sampler")
    stages = S.stages()
    K = len(stages)
    harris = S.harris_lower(range(len(S.clauses)))
    # r_k >= h_k under D, hence >= e^{-2 kappa} h_k under the law the sampler realises;
    # the factor 1 - 2^-50 absorbs the rounding of exp and of the products (harris_lower
    # is 0 or normal), and products below the normal range are set to 0
    h = np.array([S.harris_lower(st) for st in stages]) * (math.exp(-2 * S.kappa) * (1 - 2.0 ** -50))
    h[h < _NORMAL2] = 0.0
    R = _reps_for(delta / 2)
    fails = np.zeros(K, dtype=int)
    nmin = np.full(K, N)
    logs, evals = [], 0
    for _ in range(R):
        terms = []
        active: list[int] = []
        for k, st in enumerate(stages):
            Y, f = cftp_samples(S, active, N, rng, T_max=T_max)
            evals += N
            fails[k] += f
            nk = Y.shape[0]
            if nk == 0:
                return no_verdict(evals, "no coalescence")
            nmin[k] = min(nmin[k], nk)
            bad = int(S.violated(Y, st).sum())
            # log r^_k, r^_k = (nk - bad)/nk, with relative error below 2^-51
            if bad == nk:
                terms.append(-math.inf)
            elif 2 * bad <= nk:
                terms.append(math.log1p(-bad / nk))
            else:
                terms.append(math.log((nk - bad) / nk))
            active += st
        logs.append(math.fsum(terms))  # relative error below 2^-50
    # certified truncation per stage, pooling the R*N runs of that stage's sampler
    # (the failure fraction is a quotient of integers: relative error below 2^-52)
    th = np.array([kl_interval(fails[k] / (R * N), R * N, delta / (2 * K), rel_err=2.0 ** -52)[1]
                   for k in range(K)])
    if np.any(th >= h):
        return no_verdict(evals, "truncation not certified below the Harris guarantee")
    g = h - th
    up = 1 + 2.0 ** -48  # above the relative rounding errors (below 2^-50) of b, v and eps0
    b = math.fsum(th / g) * up
    v = math.expm1(math.fsum(np.log1p((1 - h + th) / (g * nmin))) * up) * up
    eps0 = 2 * math.sqrt(v) * up
    med = float(np.median(logs))
    if med == -math.inf:
        return no_verdict(evals, "zero ratio in the median repetition")
    lo, hi = _stat_interval(med, b, eps0, S.kappa)  # kappa: from the sampled law's p back to D's p
    lo = max(lo, harris)  # Harris lower bound is deductive
    if hi < lo:
        return no_verdict(evals, "statistical upper end below the Harris bound")
    return Estimate(math.exp(med), lo, hi, evals, evals, delta,
                    f"stages {K}, repetitions {R}, Harris bound {harris:.3g}, "
                    f"min stage guarantee {float(h.min()):.3g}, eps0 {eps0:.3g}, bias {b:.2g}")
