"""Tests for rareprob.affine against brute force: GF(2) machinery, exactness
of certified ANFs, of the presolve identity, of masses and samplers, and
soundness (domination) of affine envelopes and XPT arguments on random and
adversarial inputs."""

import itertools
import math

import numpy as np
import pytest

from rareprob import Circuit, Product, exact_prob
from rareprob.affine import (FULL, Affine, LinearOrderDP, Piece, anf_all, and_spine, affine_envelope,
                             affine_envelope_estimate, balanced_connectivity, bit_list, certified_affine,
                             cut_connectivity, gf2_rank, klm_estimate, make_pieces, order_profile, parity,
                             presolve, presolve_estimate, restrict_to, solved_form, uniform_mask, xpt_check,
                             xpt_honest, xpt_verify, _pivot_weight)
from rareprob.circuit import pack_rows, unpack_bits


# ------------------------------------------------------------------ helpers
def all_points(n):
    return ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)


def gate_values(C, X):
    """Truth values of every gate on the rows of X (bool arrays)."""
    val = {}
    for v, op in enumerate(C.ops):
        a = C.args[v]
        if op == "IN":
            val[v] = X[:, v]
        elif op == "CONST":
            val[v] = np.full(len(X), bool(C.params[v]))
        elif op == "NOT":
            val[v] = ~val[a[0]]
        elif op == "AND":
            val[v] = np.logical_and.reduce([val[u] for u in a])
        elif op == "OR":
            val[v] = np.logical_or.reduce([val[u] for u in a])
        elif op == "XOR":
            val[v] = np.logical_xor.reduce([val[u] for u in a])
        elif op == "THR":
            w, t = C.params[v]
            val[v] = sum(wi * val[u] for wi, u in zip(w, a)) >= t - 1e-12
    return val


def gxor(C, a, b):
    return C.AND(C.OR(a, b), C.NOT(C.AND(a, b)))


def xor_tree(C, lits):
    cur = lits[0]
    for l in lits[1:]:
        cur = gxor(C, cur, l)
    return cur


def random_mixed_circuit(n, rng, n_checks, n_extra, native_xor=False):
    """Parity checks (gadgets or native XOR) mixed with random AND/OR/NOT/XOR
    structure, combined by a random top of ANDs and occasional ORs."""
    C = Circuit(n)
    pool = list(range(n))
    for _ in range(n_extra):
        a, b = int(rng.choice(pool)), int(rng.choice(pool))
        t = rng.random()
        if t < 0.3:
            g = C.AND(a, b)
        elif t < 0.6:
            g = C.OR(a, b)
        elif t < 0.8:
            g = C.NOT(a)
        else:
            g = gxor(C, a, b) if not native_xor else C.XOR(a, b)
        pool.append(g)
    parts = []
    for _ in range(n_checks):
        S = [int(s) for s in rng.choice(n, int(rng.integers(2, 6)), replace=False)]
        g = C.XOR(*S) if native_xor else xor_tree(C, S)
        if rng.random() < 0.5:
            g = C.NOT(g)
        parts.append(g)
    parts.append(int(rng.choice(pool[n:])) if len(pool) > n else 0)
    cur = parts[0]
    for p in parts[1:]:
        cur = C.AND(cur, p) if rng.random() < 0.8 else C.OR(cur, p)
    return C.set_output(cur)


def random_affine(n, k, rng):
    V = Affine()
    for _ in range(k):
        V.add(int(rng.integers(1, 1 << n)), int(rng.integers(0, 2)))
    return V


def members(V, n):
    return np.array([V.contains(x) for x in range(1 << n)])


# ------------------------------------------------------------ GF(2) basics
def test_affine_membership_and_canonical_form():
    rng = np.random.default_rng(0)
    n = 9
    X = pack_rows(all_points(n))
    for _ in range(60):
        V = random_affine(n, int(rng.integers(0, 6)), rng)
        m = members(V, n)
        assert m.sum() == 2 ** (n - V.rank)
        assert np.array_equal(unpack_bits(V.contains_packed(X), 1 << n), m)
        # the same subspace from a re-randomised generating set has the same key
        W = Affine()
        rows = list(V.rows.values())
        for _ in range(3 * len(rows)):
            i, j = rng.integers(0, len(rows), 2) if rows else (0, 0)
            if rows and i != j:
                rows[i] = (rows[i][0] ^ rows[j][0], rows[i][1] ^ rows[j][1])
        for r, b in rows:
            assert W.add(r, b)
        assert W.key() == V.key()
        # forms constant on V
        for _ in range(5):
            f = int(rng.integers(0, 1 << n))
            val = V.form_value(f)
            vals = {parity(f & x) for x in range(1 << n) if m[x]}
            assert (val is not None) == (len(vals) == 1)
            if val is not None:
                assert vals == {val}
        # meet and containment
        W = random_affine(n, int(rng.integers(0, 4)), rng)
        M = V.meet(W)
        mw = members(W, n)
        if M is None:
            assert not np.any(m & mw)
        else:
            assert np.array_equal(members(M, n), m & mw)
        assert V.subset_of(W) == bool(np.all(mw[m]))


def test_restrict_to_uniform_coordinates():
    rng = np.random.default_rng(1)
    n = 8
    for _ in range(40):
        V = random_affine(n, int(rng.integers(1, 6)), rng)
        U = int(rng.integers(0, 1 << n))
        W = restrict_to(V, U)
        assert W.support() & ~U == 0
        m, mw = members(V, n), members(W, n)
        assert np.all(mw[m])  # superset
        # every form on U that is constant on V is constant on W
        for f in range(1 << n):
            if f & ~U == 0 and V.form_value(f) is not None:
                assert W.form_value(f) == V.form_value(f)


def test_samplers_are_exact():
    rng = np.random.default_rng(2)
    n = 7
    pts = all_points(n)
    for trial in range(6):
        V = random_affine(n, int(rng.integers(1, 4)), rng)
        q = rng.choice([0.5, 0.2, 0.7, 0.9], n)
        if trial % 2 == 0:  # constraints on uniform coordinates only: closed form
            q[[i for i in bit_list(V.support())]] = 0.5
        D = Product(q)
        P = Piece(V, D, uniform_mask(D))
        target = D.pmf(pts) * members(V, n)
        assert math.isclose(P.mass, target.sum(), rel_tol=1e-12)
        target /= target.sum()
        N = 200_000
        S = unpack_rows(P.sample_packed(N, rng), N, n)
        idx = (S * (1 << np.arange(n))).sum(1)
        emp = np.bincount(idx, minlength=1 << n) / N
        assert np.all(emp[target == 0] == 0)
        tv = 0.5 * np.abs(emp - target).sum()
        assert tv < 0.02, tv


def unpack_rows(Xp, N, n):
    return np.stack([unpack_bits(Xp[i], N) for i in range(n)], axis=1)


def test_linear_order_dp_mass_and_width():
    rng = np.random.default_rng(3)
    n = 11
    pts = all_points(n)
    for _ in range(25):
        # banded systems (small width) and random ones
        V = Affine()
        for r in range(int(rng.integers(1, 6))):
            if rng.random() < 0.5:
                lo = int(rng.integers(0, n - 3))
                row = int(sum(1 << j for j in range(lo, lo + 4) if rng.random() < 0.7)) or 1 << lo
            else:
                row = int(rng.integers(1, 1 << n))
            V.add(row, int(rng.integers(0, 2)))
        D = Product(rng.uniform(0.05, 0.95, n))
        order = list(rng.permutation(n))
        dp = LinearOrderDP(V, D, order)
        exact = (D.pmf(pts) * members(V, n)).sum()
        assert math.isclose(dp.mass, exact, rel_tol=1e-10, abs_tol=1e-300)
        rows = [r for r, _ in V.rows.values()]
        prof = [0] + order_profile(rows, order) + [0]
        for t, (states, _) in enumerate(dp.levels):
            assert len(states) <= 2 ** prof[t]


def test_dp_handles_deterministic_coordinates():
    n = 6
    V = Affine.single(0b000111, 1)
    D = Product([1.0, 0.0, 0.3, 0.5, 0.5, 0.5])
    dp = LinearOrderDP(V, D)
    pts = all_points(n)
    assert math.isclose(dp.mass, (D.pmf(pts) * members(V, n)).sum(), rel_tol=1e-12)
    S = dp.sample(1000, np.random.default_rng(0))
    assert np.all(S[:, 0]) and not np.any(S[:, 1])


# ------------------------------------------------------------- certified ANF
def test_anf_is_exact_on_every_certified_gate():
    rng = np.random.default_rng(4)
    n = 8
    X = all_points(n)
    for _ in range(40):
        C = random_mixed_circuit(n, rng, int(rng.integers(0, 4)), int(rng.integers(3, 20)))
        A = anf_all(C, cap=16)
        val = gate_values(C, X)
        for v, a in A.items():
            if a is None:
                continue
            ev = np.zeros(len(X), dtype=bool)
            for mono in a.monomials():
                term = np.ones(len(X), dtype=bool)
                for i in bit_list(mono):
                    term &= X[:, i]
                ev ^= term
            assert np.array_equal(ev, val[v]), (v, C.ops[v])


def test_gadget_parities_are_certified():
    C = Circuit(12)
    g = xor_tree(C, list(range(12)))
    C.set_output(g)
    aff = certified_affine(C)
    assert aff[g] == ((1 << 12) - 1, 0)


def test_solved_form_certificates_are_true():
    rng = np.random.default_rng(5)
    n = 8
    X = all_points(n)
    found = 0
    for _ in range(150):
        C = random_mixed_circuit(n, rng, 0, int(rng.integers(3, 14)), native_xor=bool(rng.random() < 0.5))
        # plant some x_i XOR f(rest) structure
        if rng.random() < 0.5:
            i = int(rng.integers(0, n))
            f = int(rng.integers(n, len(C.ops)))
            C.set_output(gxor(C, i, f))
        sup = C.supports()
        val = gate_values(C, X)
        for g in C.cone():
            for i in bit_list(sup[g]):
                if solved_form(C, g, i, sup):
                    found += 1
                    flipped = X.copy()
                    flipped[:, i] ^= True
                    assert np.array_equal(val[g] ^ gate_values(C, flipped)[g], np.ones(len(X), bool))
    assert found > 10


def test_spine_is_an_identity():
    rng = np.random.default_rng(6)
    n = 8
    X = all_points(n)
    for _ in range(40):
        C = random_mixed_circuit(n, rng, int(rng.integers(0, 4)), int(rng.integers(2, 12)))
        val = gate_values(C, X)
        conj = and_spine(C)
        acc = np.ones(len(X), dtype=bool)
        for g, b in conj:
            acc &= val[g] == bool(b)
        assert np.array_equal(acc, val[C.output])


# ------------------------------------------------------------------ presolve
def test_presolve_identity_uniform():
    rng = np.random.default_rng(7)
    n = 10
    for _ in range(60):
        C = random_mixed_circuit(n, rng, int(rng.integers(1, 5)), int(rng.integers(2, 12)))
        P = presolve(C)
        p = exact_prob(C)
        if P.infeasible:
            assert p == 0
            continue
        assert not P.nonuniform
        q = exact_prob(P.reduced)
        assert math.isclose(p, 2.0 ** P.log2_M * q, rel_tol=1e-12, abs_tol=1e-15)
        # the reduced circuit does not read the pivots
        sup = P.reduced.supports()[P.reduced.output]
        for piv in list(P.rref) + [i for _, _, i in P.solved]:
            assert not (sup >> piv) & 1


def test_presolve_identity_product():
    rng = np.random.default_rng(8)
    n = 10
    pts = all_points(n)
    Xp = pack_rows(pts)
    for _ in range(40):
        C = random_mixed_circuit(n, rng, int(rng.integers(1, 5)), int(rng.integers(2, 12)))
        q = rng.choice([0.5, 0.5, 0.3, 0.8], n)
        D = Product(q)
        P = presolve(C, D)
        p = exact_prob(C, D)
        if P.infeasible:
            assert p == 0
            continue
        N = 1 << n
        W = unpack_bits(P.reduced.eval_packed(Xp), N) * _pivot_weight(P, D, Xp, N)
        EW = (D.pmf(pts) * W).sum()
        assert W.max() <= 1 + 1e-12
        assert math.isclose(p, 2.0 ** P.log2_M * EW, rel_tol=1e-10, abs_tol=1e-15)


def feistel_circuit(k, extra, rng, t=None):
    """[L_0 XOR f(R_0) = t] AND G(R_0, extra), each f_j a random nonlinear
    function of R_0 (an OR of random 2-literal terms): a triangular
    (solved-form) system."""
    n = 2 * k + extra
    C = Circuit(n)
    L = list(range(k))
    Rv = list(range(k, 2 * k))
    t = rng.integers(0, 2, k) if t is None else t

    def lit(i):
        return i if rng.random() < 0.5 else C.NOT(i)

    conj = []
    for j in range(k):
        terms = [C.AND(lit(int(a)), lit(int(b))) for a, b in
                 (rng.choice(Rv, 2, replace=False) for _ in range(3))]
        f = C.OR(*terms)
        g = gxor(C, L[j], f)
        conj.append(g if t[j] else C.NOT(g))
    side = C.OR(*[C.AND(int(rng.choice(Rv)), int(rng.integers(2 * k, n))) for _ in range(3)])
    return C.set_output(C.AND(*conj, side))


def test_presolve_triangular_feistel():
    rng = np.random.default_rng(9)
    solved = 0
    for _ in range(10):
        C = feistel_circuit(4, 3, rng)
        P = presolve(C)
        assert P.rank == 4  # affine rows when f_j happens to be affine, solved forms otherwise
        solved += len(P.solved)
        p = exact_prob(C)
        assert math.isclose(p, 2.0 ** -4 * exact_prob(P.reduced), rel_tol=1e-12)
    assert solved >= 10
    # with the ANF cap at 1, nonlinear round functions are opaque atoms: still solved form
    C = feistel_circuit(4, 3, rng)
    P = presolve(C, anf_cap=1)
    assert P.rank == 4


def test_presolve_inconsistent_is_zero():
    C = Circuit(6)
    a = xor_tree(C, [0, 1, 2])
    b = xor_tree(C, [3, 4])
    c = xor_tree(C, [0, 1, 2, 3, 4])
    C.set_output(C.AND(a, b, c))  # a = b = 1 forces c = 0
    P = presolve(C)
    assert P.infeasible and exact_prob(C) == 0
    e = presolve_estimate(C)
    assert e.lo == e.hi == 0
    assert affine_envelope(C) == []


# ---------------------------------------------------------- affine envelopes
@pytest.mark.parametrize("cap", [2, 4, 16])
def test_affine_envelope_dominates(cap):
    rng = np.random.default_rng(10 + cap)
    n = 10
    X = all_points(n)
    for _ in range(120):
        C = random_mixed_circuit(n, rng, int(rng.integers(0, 5)), int(rng.integers(0, 14)),
                                 native_xor=bool(rng.random() < 0.3))
        env = affine_envelope(C, cap=cap)
        y = C.eval_bits(X)
        cov = np.zeros(len(X), dtype=bool)
        for V in env:
            cov |= members(V, n)
        assert np.all(cov[y]), "envelope misses a satisfying input"


def test_estimators_contain_p():
    rng = np.random.default_rng(11)
    n = 12
    misses, runs = 0, 0
    for trial in range(40):
        C = random_mixed_circuit(n, rng, int(rng.integers(1, 5)), int(rng.integers(2, 12)))
        q = np.full(n, 0.5) if trial % 2 == 0 else rng.choice([0.5, 0.25, 0.75], n)
        D = Product(q)
        p = exact_prob(C, D)
        for est in (presolve_estimate(C, D, eps=0.1, delta=0.05, rng=rng, max_samples=200_000),
                    affine_envelope_estimate(C, D, eps=0.1, delta=0.05, rng=rng, max_samples=200_000)):
            runs += 1
            misses += not (est.lo <= p <= est.hi)
    assert misses <= 4, (misses, runs)


def test_klm_interval_coverage():
    rng = np.random.default_rng(12)
    n = 14
    C = random_mixed_circuit(n, rng, 4, 10)
    while exact_prob(C) == 0:
        C = random_mixed_circuit(n, rng, 4, 10)
    p = exact_prob(C)
    D = Product.uniform(n)
    pieces, _ = make_pieces(affine_envelope(C), D)
    miss = 0
    for _ in range(200):
        e = klm_estimate(C, D, pieces, eps=0.2, delta=0.1, rng=rng)
        miss += not (e.lo <= p <= e.hi)
        assert e.hi <= sum(P.mass for P in pieces) * (1 + 1e-9)
    assert miss <= 35  # expected <= 20 at delta = 0.1


def test_parity_with_dense_residual_is_fast_and_tight():
    rng = np.random.default_rng(13)
    n, m = 60, 25
    C = Circuit(n)
    checks = []
    for _ in range(m):
        S = [int(s) for s in rng.choice(n, 6, replace=False)]
        g = C.XOR(*S)
        checks.append(g if rng.random() < 0.5 else C.NOT(g))
    R = C.OR(C.AND(0, 1), C.AND(2, C.NOT(3)), 4)
    C.set_output(C.AND(R, *checks))
    for f in (presolve_estimate, affine_envelope_estimate):
        e = f(C, eps=0.05, delta=0.01, rng=rng)
        assert e.lo > 0 and e.hi <= 1.06 * e.lo and e.samples <= 300_000


def test_nonuniform_affine_envelope_uses_dp():
    rng = np.random.default_rng(14)
    n = 12
    C = Circuit(n)
    a = xor_tree(C, [0, 1, 2, 3])
    b = C.NOT(xor_tree(C, [3, 4, 5]))
    c = xor_tree(C, [6, 7, 8, 9, 10, 11])
    C.set_output(C.AND(a, b, C.OR(c, C.AND(0, 11))))
    D = Product(rng.uniform(0.1, 0.4, n))
    p = exact_prob(C, D)
    e = affine_envelope_estimate(C, D, eps=0.05, delta=0.01, rng=rng)
    assert e.lo <= p <= e.hi and e.hi <= 1.06 * e.lo


# --------------------------------------------------------------- XPT (Part 2)
def random_argument(C, rng, depth):
    if depth == 0 or rng.random() < 0.2:
        r = rng.random()
        if r < 0.05:
            return {"split": ["gate", 10**6], "children": []}  # malformed
        return {"leaf": "closed" if rng.random() < 0.6 else "open"}
    if rng.random() < 0.5:
        sp = ["gate", int(rng.integers(0, len(C.ops)))]
    else:
        sp = ["form", [int(i) for i in rng.choice(C.n, int(rng.integers(1, 4)), replace=False)],
              int(rng.integers(0, 2))]
    return {"split": sp, "children": [random_argument(C, rng, depth - 1) for _ in range(2)]}


def random_threshold_circuit(n, rng):
    C = Circuit(n)
    pool = list(range(n))
    for _ in range(int(rng.integers(3, 12))):
        r = rng.random()
        a = [int(x) for x in rng.choice(pool, int(rng.integers(2, 4)))]
        if r < 0.3:
            g = C.THR(a, [float(rng.integers(-2, 4)) for _ in a], float(rng.integers(-1, 4)))
        elif r < 0.5:
            g = C.XOR(*a)
        elif r < 0.7:
            g = C.AND(*a)
        elif r < 0.85:
            g = C.OR(*a)
        else:
            g = C.NOT(a[0])
        pool.append(g)
    return C.set_output(pool[-1])


def test_xpt_is_sound_against_random_arguments():
    rng = np.random.default_rng(15)
    n = 9
    X = all_points(n)
    for trial in range(300):
        if trial % 2:
            C = random_threshold_circuit(n, rng)
        else:
            C = random_mixed_circuit(n, rng, int(rng.integers(0, 4)), int(rng.integers(2, 14)),
                                     native_xor=bool(rng.random() < 0.3))
        y = C.eval_bits(X)
        arg = random_argument(C, rng, int(rng.integers(1, 6)))
        leaves, st = xpt_check(C, arg)
        cov = np.zeros(len(X), dtype=bool)
        for S, _ in leaves:
            cov |= members(S, n)
        assert np.all(cov[y])


def mux_checksum(n_body, k, rng):
    """(mode ? [H1 x = s1] : [H2 x = s2]) AND R, mode = MAJ(x_a, x_b, x_c)
    hidden behind AND/OR gates, so that no fixed rule sees the affine pieces."""
    n = k + n_body + 3
    C = Circuit(n)
    a, b, c = n - 3, n - 2, n - 1
    mode = C.OR(C.AND(a, b), C.AND(a, c), C.AND(b, c))
    def check(rows):
        gs = []
        for _ in range(rows):
            S = [int(s) for s in rng.choice(k, 5, replace=False)]
            g = xor_tree(C, S)
            gs.append(g if rng.random() < 0.5 else C.NOT(g))
        return C.AND(*gs)
    c1, c2 = check(6), check(7)
    sel = C.NOT(C.AND(C.NOT(C.AND(mode, c1)), C.NOT(C.AND(C.NOT(mode), c2))))
    body = list(range(k, k + n_body))
    R = C.OR(C.AND(body[0], body[1]), C.AND(C.NOT(body[2]), body[3]))
    C.set_output(C.AND(sel, R))
    return C, mode


def test_xpt_completeness_on_multiplexed_checksums():
    rng = np.random.default_rng(16)
    C, mode = mux_checksum(5, 12, rng)
    p = exact_prob(C)
    assert p > 0
    arg = xpt_honest(C, [("gate", mode)])
    leaves, st = xpt_check(C, arg)
    assert st["open"] == 2 and st["downgraded"] == 0
    e = xpt_verify(C, None, arg, eps=0.05, delta=0.01, rng=rng)
    assert e.lo <= p <= e.hi and e.hi <= 1.06 * e.lo


# ------------------------------------------------------- barrier quantities
def test_connectivity_is_symmetric_and_dual_invariant():
    rng = np.random.default_rng(17)
    n = 8
    full = (1 << n) - 1
    for _ in range(30):
        rows = [int(rng.integers(1, 1 << n)) for _ in range(int(rng.integers(1, 5)))]
        # dual: basis of the orthogonal complement of the row space
        dual = [x for x in range(1, 1 << n) if all(parity(x & r) == 0 for r in rows)]
        Y = int(rng.integers(0, 1 << n))
        lam = cut_connectivity(rows, Y, n)
        assert lam == cut_connectivity(rows, full ^ Y, n)
        assert lam == cut_connectivity(dual, Y, n) if dual else True
        # lambda_V(Y) = dim proj_Y V + dim proj_Z V - dim V for V = ker H
        ker = [x for x in range(1 << n) if all(parity(x & r) == 0 for r in rows)]
        dV = int(math.log2(len(ker)))
        dY = int(math.log2(len({x & Y for x in ker})))
        dZ = int(math.log2(len({x & (full ^ Y) for x in ker})))
        assert lam == dY + dZ - dV


def test_random_checks_have_large_balanced_connectivity():
    rng = np.random.default_rng(18)
    n, m = 18, 3
    vals = [balanced_connectivity([int(rng.integers(1, 1 << n)) for _ in range(m)], n) for _ in range(5)]
    assert max(vals) >= 2
