"""Certified presumption of independence for unate CNFs.

Let C = AND_i clause_i be a CNF in which every variable occurs with only one
sign (unate). Put B_i = [clause_i is false], a subcube; after flipping the
variables that occur positively, every B_i = {y_{S_i} = 1} is a principal
up-set, so under a product distribution, with b_i = P(B_i), the clauses
ordered by decreasing b_i, and d_i = sum_{j < i, j ~ i} P(B_i & B_j),

    M := prod_i (1 - b_i) <= p <= prod_i (1 - b_i + d_i)
                              <= M * exp(sum_i d_i / (1 - b_i))

(Harris-Kleitman for the lower bound; the Boppana-Spencer proof of Janson's
inequality, Alon-Spencer Thm 8.1.1, for the upper). The product form stays
finite and tight when some b_i is close to 1, unlike the textbook form
M exp(Delta / (1 - max_i b_i)), Delta = sum_i d_i the sum over unordered
dependent pairs. All quantities are products of marginals, so this is a
deterministic poly-time interval for p: a (1 +- eps') estimate whenever the
dependent pairs carry little probability, however small p is. This is the
presumption of independence p ~ prod_i P(clause_i), with a certificate.
Floating-point errors are bounded and the interval is rounded outwards
(exp_down, exp_up).
"""

from __future__ import annotations

import math
from collections import defaultdict

import numpy as np

from .circuit import Circuit
from .dist import Product
from .stats import Estimate

_NORMAL2 = 2.0 ** -1021  # twice the smallest positive normal float


def exp_down(s: float, err: float = 0.0) -> float:
    """A lower bound on e^t for every t >= s - err (err >= 0 bounds the error
    of s). Below the normal range exp and products have absolute rather than
    relative rounding errors, so there it returns 0."""
    t = s - err - 2.0 ** -50 * (abs(s) + err)  # covers the rounding of this line
    y = math.exp(t) * (1 - 2.0 ** -50)  # math.exp is faithful: relative error < 2^-52
    return y if y >= _NORMAL2 else 0.0


def exp_up(s: float, err: float = 0.0) -> float:
    """An upper bound on e^t for every t <= s + err, positive unless s = -inf.
    Below the normal range it adds 4 ulps of 0, more than the absolute rounding
    errors of exp and of the product there."""
    if s == -math.inf:
        return 0.0
    t = s + err + 2.0 ** -50 * (abs(s) + err)
    if not t <= 709.0:
        return math.inf
    y = math.exp(t) * (1 + 2.0 ** -50)
    return y if y >= _NORMAL2 else y + 4 * math.ulp(0.0)


def is_unate(clauses) -> bool:
    sign: dict[int, int] = {}
    for c in clauses:
        for (i, b) in c:
            if sign.setdefault(i, b) != b:
                return False
    return True


def check_clauses(clauses, n: int) -> None:
    """Raise ValueError unless every literal is (i, b) with an integer
    0 <= i < n and b in {0, 1} and the CNF is unate."""
    for c in clauses:
        for lit in c:
            i, b = lit
            if int(i) != i or not 0 <= i < n or b not in (0, 1):
                raise ValueError(f"bad literal {lit!r}: need (i, b) with 0 <= i < {n} and b in {{0, 1}}")
    if not is_unate(clauses):
        raise ValueError("the CNF is not unate: a variable occurs with both signs")


def janson_interval(clauses, D: Product) -> Estimate:
    """clauses: list of lists of literals (i, b) meaning [x_i == b]. Raises
    ValueError unless the literals are well formed and the CNF is unate (the
    Harris and Janson bounds need it; an explicit check, since an assert
    would vanish under python -O)."""
    check_clauses(clauses, D.n)
    # a literal repeated within a clause is one condition: count it once in P(B_i)
    clauses = [sorted({(int(i), int(b)) for (i, b) in c}) for c in clauses]
    m = len(clauses)

    def log_false(lits) -> float:  # log P(all literals false)
        s = 0.0
        for (i, b) in lits:
            q = D.lit_prob(i, 1 - b)
            if q <= 0:
                return -math.inf
            s += math.log(q)
        return s

    logPB = [log_false(c) for c in clauses]
    PB = np.exp(logPB)
    order = sorted(range(m), key=lambda j: -PB[j])
    rank = {j: r for r, j in enumerate(order)}
    occ = defaultdict(list)
    for j, c in enumerate(clauses):
        for (i, b) in c:
            occ[i].append(j)
    d = np.zeros(m)  # d_j = sum over earlier dependent clauses k of P(B_j & B_k)
    Delta = 0.0  # sum over unordered dependent pairs (= sum_j d_j)
    for j, c in enumerate(clauses):
        nb = set()
        for (i, b) in c:
            nb.update(occ[i])
        nb.discard(j)
        for k in nb:
            union = dict(c)
            union.update(dict(clauses[k]))
            v = math.exp(log_false(union.items()))
            if rank[k] < rank[j]:
                d[j] += v
                Delta += v
    # outward rounding: relative error of each b_j, d_j is below w
    w = 2.0 ** -36 * (2 + max((len(c) for c in clauses), default=0) * 2)
    b_lo, b_hi = PB * (1 - w), np.minimum(1.0, PB * (1 + w))
    d_hi = d * (1 + w)
    with np.errstate(divide="ignore"):
        logM = float(np.sum(np.log1p(-b_hi)))
        log_up = float(np.sum(np.log1p(np.minimum(0.0, -b_lo + d_hi))))
    # absolute error bound on logM and log_up (rounding of log1p and of the sums)
    slack = 2.0 ** -36 * (m + 2)
    lo = exp_down(logM, slack)
    hi = min(1.0, exp_up(log_up, slack))
    val = math.exp(0.5 * (math.log(lo) + math.log(hi))) if lo > 0 else hi / 2
    return Estimate(val, lo, hi, 0, m ** 2, 0.0,
                    f"mu={float(PB.sum()):.4g}, Delta={Delta:.4g}, eps={float(PB.max()) if m else 0.0:.3g}")


def cnf_circuit(n: int, clauses) -> Circuit:
    C = Circuit(n)
    cs = [C.OR(*[C.lit(i, b) for i, b in c]) for c in clauses]
    return C.set_output(C.AND(*cs))


def random_unate_cnf(n: int, m: int, k: int, rng: np.random.Generator, sign=None):
    sign = rng.integers(0, 2, size=n) if sign is None else sign
    out = []
    for _ in range(m):
        S = rng.choice(n, size=k, replace=False)
        out.append([(int(i), int(sign[i])) for i in S])
    return out
