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
M exp(Delta / (2 (1 - max_i b_i))). All quantities are products of
marginals, so this is a deterministic poly-time interval for p: a
(1 +- eps') estimate whenever the dependent pairs carry little probability,
however small p is. This is the presumption of independence
p ~ prod_i P(clause_i), with a certificate. Floating-point errors are
bounded and the interval is rounded outwards.
"""

from __future__ import annotations

import math
from collections import defaultdict

import numpy as np

from .circuit import Circuit
from .dist import Product
from .stats import Estimate


def is_unate(clauses) -> bool:
    sign: dict[int, int] = {}
    for c in clauses:
        for (i, b) in c:
            if sign.setdefault(i, b) != b:
                return False
    return True


def janson_interval(clauses, D: Product) -> Estimate:
    """clauses: list of lists of literals (i, b) meaning [x_i == b]."""
    assert is_unate(clauses), "Janson/Harris sandwich needs a unate CNF"
    # a literal repeated within a clause is one condition: count it once in P(B_i)
    clauses = [sorted({(i, b) for (i, b) in c}) for c in clauses]
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
    Delta = 0.0
    for j, c in enumerate(clauses):
        nb = set()
        for (i, b) in c:
            nb.update(occ[i])
        nb.discard(j)
        for k in nb:
            union = dict(c)
            union.update(dict(clauses[k]))
            v = math.exp(log_false(union.items()))
            Delta += v
            if rank[k] < rank[j]:
                d[j] += v
    # outward rounding: relative error of each b_j, d_j is below w
    w = 2.0 ** -36 * (2 + max((len(c) for c in clauses), default=0) * 2)
    b_lo, b_hi = PB * (1 - w), np.minimum(1.0, PB * (1 + w))
    d_hi = d * (1 + w)
    with np.errstate(divide="ignore"):
        logM = float(np.sum(np.log1p(-b_hi)))
        log_up = float(np.sum(np.log1p(np.minimum(0.0, -b_lo + d_hi))))
    slack = 2.0 ** -36 * (m + 2)
    lo = max(0.0, math.exp(logM) * (1 - slack)) if logM > -math.inf else 0.0
    if log_up > -math.inf:
        hi = min(1.0, max(math.exp(log_up) * (1 + slack), math.ulp(0.0)))
    else:
        hi = 0.0
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
