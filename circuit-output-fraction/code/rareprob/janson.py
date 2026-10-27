"""Certified presumption of independence for unate CNFs.

Let C = AND_i clause_i be a CNF in which every variable occurs with only one
sign (unate). Put B_i = [clause_i is false], a subcube; after flipping the
variables that occur negatively, every B_i is a principal up-set, so under a
product distribution

    M := prod_i (1 - P(B_i)) <= p <= M * exp(Delta / (2 (1 - eps)))

(Harris-Kleitman for the lower bound, Janson's inequality for the upper;
Alon-Spencer, The Probabilistic Method, Thm 8.1.1), where
    Delta = sum over ordered pairs i != j with overlapping clauses of P(B_i & B_j),
    eps   = max_i P(B_i).
All three quantities are products of marginals, so this is a deterministic
poly-time interval for p, of ratio exp(Delta/(2(1-eps))): a (1 +- eps')
estimate whenever the dependent pairs carry little probability, however small
p is. This is the presumption of independence p ~ prod_i P(clause_i), with a
certificate.
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
    # P(B_i) = prod over literals of P(literal false)
    logPB = []
    for c in clauses:
        s = 0.0
        for (i, b) in c:
            s += math.log(D.lit_prob(i, 1 - b))
        logPB.append(s)
    PB = np.exp(logPB)
    eps = float(PB.max()) if len(PB) else 0.0
    logM = float(np.sum(np.log1p(-PB)))
    # Delta over ordered dependent pairs
    occ = defaultdict(list)
    for j, c in enumerate(clauses):
        for (i, b) in c:
            occ[i].append(j)
    Delta = 0.0
    for j, c in enumerate(clauses):
        nb = set()
        for (i, b) in c:
            nb.update(occ[i])
        nb.discard(j)
        vars_j = {i for i, _ in c}
        for k in nb:
            union = dict(c)
            union.update(dict(clauses[k]))
            s = 0.0
            for i, b in union.items():
                s += math.log(D.lit_prob(i, 1 - b))
            Delta += math.exp(s)
    lo = math.exp(logM)
    hi = math.exp(logM + Delta / (2 * (1 - eps)))
    val = math.sqrt(lo * hi)
    return Estimate(val, lo, hi, 0, len(clauses) ** 2, 0.0,
                    f"mu={float(PB.sum()):.4g}, Delta={Delta:.4g}, eps={eps:.3g}")


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
