"""Context width as a parameter of the bracketing (Section 'Context width'):
the size bounds of the NNF and of the compiled DNNF, the path-decomposition
bracketing lemma, and the quotient composition rule of 'Modules and quotients'."""

import itertools
import math

import numpy as np
import pytest

from rareprob import Circuit, Product, exact_prob
from rareprob.ctxwidth import compile_ctx, context_width, path_order
from rareprob.nnf import to_nnf


def all_points(n):
    return ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)


def circuit_wires(C):
    return sum(len(C.args[g]) for g in C.cone() if C.ops[g] != "IN")


def nnf_wires(N):
    return sum(len(N.children(u)) for u in N.cone())


def dnnf_wires(E):
    return sum(len(E.data[u]) for u in E.cone() if E.kind[u] in ("SUM", "PROD"))


def random_circuit(n, gates, ops, rng):
    C = Circuit(n)
    pool = list(range(n))
    for _ in range(gates):
        op = rng.choice(ops)
        if op == "NOT":
            g = C.NOT(int(rng.choice(pool)))
        else:
            g = C.add(op, [int(t) for t in rng.choice(pool, size=int(rng.integers(2, 5)))])
        pool.append(g)
    return C.set_output(pool[-1])


def chain(C, clauses):
    """Left-deep AND-chain of the clauses (lists of (var, val)), in the given order."""
    acc = None
    for c in clauses:
        g = C.OR(*[C.lit(v, b) for v, b in c])
        acc = g if acc is None else C.AND(acc, g)
    return acc


def window_clauses(order, w, rng):
    return [[(int(v), int(rng.integers(0, 2))) for v in order[s:s + w]] for s in range(len(order) - w + 1)]


def random_path_cnf(n, k, m, rng):
    """Bags of a random path decomposition of width <= k covering range(n), and
    m random clauses, each inside a random bag."""
    order = list(rng.permutation(n))
    bags, cur, nxt = [], [], 0
    while nxt < n:
        while len(cur) < k + 1 and nxt < n:
            cur.append(order[nxt])
            nxt += 1
        bags.append(set(int(v) for v in cur))
        drop = int(rng.integers(1, len(cur) + 1))
        for v in rng.choice(cur, size=drop, replace=False):
            cur.remove(v)
    clauses = []
    for _ in range(m):
        B = sorted(bags[int(rng.integers(len(bags)))])
        s = int(rng.integers(1, len(B) + 1))
        vs = rng.choice(B, size=s, replace=False)
        clauses.append([(int(v), int(rng.integers(0, 2))) for v in vs])
    return bags, clauses


@pytest.mark.parametrize("ops,factor", [(["AND", "OR", "NOT"], 2), (["AND", "OR", "NOT", "XOR"], 12)])
def test_nnf_size(ops, factor):
    rng = np.random.default_rng(11)
    for _ in range(200):
        C = random_circuit(int(rng.integers(3, 12)), int(rng.integers(5, 40)), ops, rng)
        N = to_nnf(C, flatten=False, small_cone=0)
        assert nnf_wires(N) <= factor * circuit_wires(C)


def test_xor_chain_wires():
    for k in range(2, 12):
        C = Circuit(k + 1)
        x = C.XOR(*range(k))
        C.set_output(C.OR(C.AND(k, x), C.AND(C.NOT(k), C.NOT(x))))  # both polarities of x
        N = to_nnf(C, flatten=False, small_cone=0)
        assert nnf_wires(N) <= 12 * (k - 1) + 6


def test_dnnf_size_bound_and_equivalence():
    rng = np.random.default_rng(12)
    for _ in range(150):
        n = int(rng.integers(3, 10))
        C = random_circuit(n, int(rng.integers(5, 35)), ["AND", "OR", "NOT", "XOR"], rng)
        for flatten in (False, True):
            N = to_nnf(C, flatten=flatten, small_cone=0)
            cw = context_width(N)
            E = compile_ctx(N, max_cw=n)
            assert dnnf_wires(E) <= (nnf_wires(N) + 1) * (cw + 3) * 2 ** cw
            X = all_points(n)
            phi = E.evaluate(X)
            assert np.array_equal(phi > 0, C.eval_bits(X))
            assert (cw == 0) == N.is_decomposable()


def test_no_quadratic_blowup_on_shared_chains():
    # OR of all prefixes of an OR-chain and of an AND-chain: cw = 0, and the
    # compiled DNNF has exactly |N| wires (merging shared nodes would give ~k^2/2)
    for gate in ("OR", "AND"):
        k = 200
        C = Circuit(k + 1)
        g = C.add(gate, [0, 1])
        gs = [g]
        for i in range(2, k + 1):
            g = C.add(gate, [g, i])
            gs.append(g)
        C.set_output(C.OR(*gs))
        N = to_nnf(C, flatten=False, small_cone=0)
        assert context_width(N) == 0
        E = compile_ctx(N)
        assert dnnf_wires(E) <= nnf_wires(N) + 1


def test_window_cnf_cw_depends_on_bracketing():
    rng = np.random.default_rng(13)
    n, w = 30, 3
    cls = window_clauses(list(range(n)), w, rng)
    C = Circuit(n)
    C.set_output(chain(C, cls))
    assert context_width(to_nnf(C, flatten=False, small_cone=0)) == w
    assert context_width(to_nnf(C, flatten=True, small_cone=0)) == n - 2
    C2 = Circuit(n)
    C2.set_output(C2.AND(*[C2.OR(*[C2.lit(v, b) for v, b in c]) for c in cls]))
    assert context_width(to_nnf(C2, flatten=False, small_cone=0)) == n - 2


@pytest.mark.parametrize("k", [0, 1, 2, 3, 4])
def test_path_decomposition_bracketing(k):
    rng = np.random.default_rng(100 + k)
    for trial in range(40):
        n = int(rng.integers(k + 2, 13))
        bags, clauses = random_path_cnf(n, k, int(rng.integers(1, 3 * n)), rng)
        rng.shuffle(clauses)
        ordered = [clauses[i] for i in path_order(clauses, bags)]
        C = Circuit(n)
        C.set_output(chain(C, ordered))
        for sc in (0, 10):
            N = to_nnf(C, flatten=False, small_cone=sc)
            assert context_width(N) <= k + 1
        N = to_nnf(C, flatten=False, small_cone=0)
        E = compile_ctx(N, max_cw=k + 1)
        X = all_points(n)
        assert np.array_equal(E.evaluate(X) > 0, C.eval_bits(X))
        D = Product(rng.uniform(0.1, 0.9, n))
        assert math.isclose(E.mass(D), float((D.pmf(X) * E.evaluate(X)).sum()), rel_tol=1e-9)


def test_or_of_path_cnfs():
    rng = np.random.default_rng(14)
    n, k, t = 40, 2, 4
    C = Circuit(n)
    tops = []
    for _ in range(t):
        bags, clauses = random_path_cnf(n, k, 2 * n, rng)
        rng.shuffle(clauses)
        tops.append(chain(C, [clauses[i] for i in path_order(clauses, bags)]))
    C.set_output(C.OR(*tops))
    N = to_nnf(C, flatten=False, small_cone=0)
    assert context_width(N) <= k + 1
    assert compile_ctx(N, max_cw=k + 1) is not None


def test_path_order_rejects_uncovered_clause():
    with pytest.raises(ValueError):
        path_order([[(0, 1), (2, 1)]], [{0, 1}, {1, 2}])


def test_or_of_window_cnfs_exact_small():
    rng = np.random.default_rng(15)
    n, t, w = 12, 3, 3
    C = Circuit(n)
    C.set_output(C.OR(*[chain(C, window_clauses(list(rng.permutation(n)), w, rng)) for _ in range(t)]))
    N = to_nnf(C, flatten=False, small_cone=0)
    assert context_width(N) <= w
    D = Product(rng.uniform(0.2, 0.8, n))
    # every OR here is a clause or the top OR: the envelope counts derivations,
    # so its mass is >= p, and phi > 0 exactly on C^{-1}(1)
    E = compile_ctx(N)
    assert E.mass(D) >= exact_prob(C, D) * (1 - 1e-12)


def _F(tab, q):
    return sum(math.prod(q[j] if y[j] else 1 - q[j] for j in range(len(q)))
               for y, v in tab.items() if v)


def test_quotient_composition_rule():
    """q_j in [L_j, U_j] on the rarer side of 1/2; qhat_j = sqrt(L_j U_j) (or the
    same for 1 - q_j) gives F(q) in e^{+-sum xi_j} F(qhat), xi_j = log(U_j/L_j)/2."""
    rng = np.random.default_rng(16)
    for _ in range(2000):
        k = int(rng.integers(1, 5))
        tab = {y: int(rng.integers(0, 2)) for y in itertools.product((0, 1), repeat=k)}
        q = rng.uniform(0, 1, k)
        qh, xi = np.empty(k), np.empty(k)
        for j in range(k):
            r = min(q[j], 1 - q[j])  # the rarer side, in [L, U] with U <= 1/2
            lo = r * math.exp(-rng.uniform(0, 0.7))
            hi = min(0.5, r * math.exp(rng.uniform(0, 0.7)))
            s = math.sqrt(lo * hi)
            qh[j] = s if q[j] <= 0.5 else 1 - s
            xi[j] = 0.5 * math.log(hi / lo)
        f, fh = _F(tab, q), _F(tab, qh)
        if f == 0:
            assert fh == 0
            continue
        assert abs(math.log(fh / f)) <= xi.sum() + 1e-12
