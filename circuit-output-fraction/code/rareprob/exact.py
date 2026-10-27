"""Exact output probabilities by enumeration (small n), for testing.

The circuit evaluator is exact (threshold gates in integer arithmetic), so
these are the exact probabilities of the function the circuit defines.
eval_reference is an independent gate-by-gate evaluator in Python integers,
for cross-checking the vectorised one."""

from __future__ import annotations

import numpy as np

from .circuit import Circuit, const_value, thr_param, thr_value, unpack_bits
from .dist import Product


def eval_reference(C: Circuit, x) -> int:
    """C(x) gate by gate in Python integers (no numpy, no packing)."""
    val: dict[int, int] = {}
    for v in C.cone():
        op, a = C.ops[v], C.args[v]
        if op == "IN":
            val[v] = int(bool(x[v]))
        elif op == "CONST":
            val[v] = const_value(C.params[v])
        elif op == "NOT":
            val[v] = 1 - val[a[0]]
        elif op == "AND":
            val[v] = int(all(val[u] for u in a))
        elif op == "OR":
            val[v] = int(any(val[u] for u in a))
        elif op == "XOR":
            val[v] = sum(val[u] for u in a) & 1
        elif op == "THR":
            w, t = thr_param(C.params[v])
            val[v] = thr_value(w, t, [val[u] for u in a])
        else:
            raise ValueError(op)
    return val[C.output]


def all_inputs_packed(n: int) -> np.ndarray:
    """Packed (n, 2^n/64) array enumerating {0,1}^n (n >= 6)."""
    if n < 6:
        raise ValueError("all_inputs_packed needs n >= 6")
    N = 1 << n
    idx = np.arange(N, dtype=np.uint64)
    rows = []
    for i in range(n):
        bits = ((idx >> np.uint64(i)) & np.uint64(1)).astype(bool)
        rows.append(np.packbits(bits.reshape(-1, 64), axis=1, bitorder="little").view(np.uint64).ravel())
    return np.stack(rows)


def exact_prob(C: Circuit, D: Product | None = None, max_n: int = 26) -> float:
    n = C.n
    if n > max_n:
        raise ValueError("enumeration too large")
    if n < 6:
        X = ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)
        y = C.eval_bits(X)
        w = np.ones(len(X)) / len(X) if D is None else D.pmf(X)
        return float((w * y).sum())
    out = C.eval_packed(all_inputs_packed(n))
    N = 1 << n
    if D is None or np.all(D.q == 0.5):
        return int(np.unpackbits(out.view(np.uint8)).sum()) / N
    y = unpack_bits(out, N)
    ids = np.nonzero(y)[0]
    X = ((ids[:, None] >> np.arange(n)) & 1).astype(bool)
    return float(D.pmf(X).sum())


def exact_prob_rational(C: Circuit, D: Product | None = None, max_n: int = 22):
    """Pr_D[C = 1] as an exact Fraction (each float marginal taken at its exact
    binary value), for checking interval coverage without rounding artefacts.
    Every marginal in [2^-7, 1] is an integer multiple of 2^-60; smaller ones
    are handled through their exact Fraction."""
    from fractions import Fraction

    n = C.n
    if n > max_n:
        raise ValueError("enumeration too large")
    X = ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)
    y = C.eval_bits(X)
    if D is None or np.all(D.q == 0.5):
        return Fraction(int(y.sum()), 1 << n)
    q1 = [Fraction(float(v)) for v in D.q]
    den = 1
    for v in q1:
        den = max(den, v.denominator)
    # integer weights w_b[i] = den * Pr[x_i = b]; the weight of x is prod_i w_{x_i}[i]
    W = np.array([1], dtype=object)
    for v in q1:
        w1 = int(v * den)
        w0 = den - w1
        W = np.concatenate([W * w0, W * w1])  # index bit i <-> variable i
    return Fraction(int(W[y].sum()), den ** n)


def dnf_prob_rational(terms, D: Product | None = None):
    """Pr_D[OR of the terms] as an exact Fraction, by inclusion-exclusion over
    the consistent subsets of terms (each term a list of (var, val); each
    marginal at its exact binary value). For reference values (m <= ~22)."""
    from fractions import Fraction

    if len(terms) > 22:
        raise ValueError("dnf_prob_rational: inclusion-exclusion needs at most 22 terms")

    def lit(i, b):
        q = Fraction(1, 2) if D is None else Fraction(float(D.q[i]))
        return q if b else 1 - q

    tot = Fraction(0)

    def rec(j, lits, pr, sign):
        nonlocal tot
        for k in range(j, len(terms)):
            new, npr = dict(lits), pr
            for i, b in terms[k]:
                if i in new:
                    if new[i] != b:
                        break
                    continue
                new[i] = b
                npr *= lit(i, b)
            else:
                tot += npr if sign > 0 else -npr
                rec(k + 1, new, npr, -sign)

    rec(0, {}, Fraction(1), 1)
    return tot


def poisson_binomial_tail_rational(ps, ws, t):
    """Pr[sum_j w_j B_j >= t] as an exact Fraction, for independent
    Bernoulli(p_j) (each p_j at its exact binary value, or a Fraction),
    nonnegative integer weights and a rational (or infinite) threshold."""
    import math
    from fractions import Fraction

    from .circuit import as_rational

    ps = [as_rational(p) for p in ps]
    wr = [as_rational(w) for w in ws]
    if any(w.denominator != 1 or w < 0 for w in wr) or any(not 0 <= p <= 1 for p in ps):
        raise ValueError("poisson_binomial_tail_rational: weights must be nonnegative integers, p in [0, 1]")
    ws = [int(w) for w in wr]
    if isinstance(t, float) and math.isinf(t):
        return Fraction(0) if t > 0 else Fraction(1)
    t = math.ceil(as_rational(t))
    tot = sum(ws)
    if t > tot:
        return Fraction(0)
    if t <= 0:
        return Fraction(1)
    # integer DP on numerators over the common denominator prod_j den_j
    dist, den = [1] + [0] * tot, 1
    for p, w in zip(ps, ws):
        a, d = p.numerator, p.denominator
        new = [x * (d - a) for x in dist]
        if a:
            for s in range(tot + 1 - w):
                if dist[s]:
                    new[s + w] += dist[s] * a
        dist, den = new, den * d
    return Fraction(sum(dist[t:]), den)
