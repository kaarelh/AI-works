"""Tests for rareprob.localthr: exactness of the local tables, the Dobrushin
bounds, the samplers and the Rao-Blackwellised statistic (against brute-force
enumeration of the tilted measure), coverage of the normaliser interval and of
the estimator TG on small instances with exactly known p."""

import math

import numpy as np
import pytest

from rareprob import Circuit
from rareprob.localthr import (LTC, LocalModel, bernstein_halfwidth, brute_force_p, chain_distribution, chain_ltc,
                               ltc_from_circuit, maurer_sum_ucb, regular_ltc, tg_estimate, ti_interval)


def all_points(n):
    return ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(np.int64)


def random_overlap_ltc(rng, n=10, m=9, k=3, t=4):
    """Random scopes of size <= k (overlapping arbitrarily) and random tables."""
    scopes, tables = [], []
    for _ in range(m):
        kk = int(rng.integers(1, k + 1))
        A = tuple(int(v) for v in rng.choice(n, size=kk, replace=False))
        scopes.append(A)
        tables.append(rng.integers(0, 2, size=1 << kk))
    return LTC(n, scopes, tables, t)


def tilted(ltc, q, theta):
    X = all_points(ltc.n)
    S = ltc.S(X)
    w = np.prod(np.where(X == 1, q, 1 - q), axis=1) * np.exp(theta * S)
    return X, S, w / w.sum(), float(np.log(np.sum(np.prod(np.where(X == 1, q, 1 - q), axis=1) * np.exp(theta * S))))


def covers(e, p, tol=1e-9):
    """Interval contains p, up to the rounding of the brute-force value."""
    if p == 0:
        return e.lo == 0.0
    return e.log_lo - tol <= math.log(p) <= e.log_hi + tol


def law_of_states(X):
    n = X.shape[0]
    codes = (X.astype(np.int64) * (1 << np.arange(n))[:, None]).sum(axis=0)
    return np.bincount(codes, minlength=1 << n) / X.shape[1]


@pytest.mark.parametrize("seed", range(5))
def test_local_tables_exact(seed):
    rng = np.random.default_rng(seed)
    ltc = random_overlap_ltc(rng)
    q = rng.uniform(0.2, 0.8, ltc.n)
    M = LocalModel(ltc, q)
    X = all_points(ltc.n)
    for i in range(ltc.n):
        X1, X0 = X.copy(), X.copy()
        X1[:, i], X0[:, i] = 1, 0
        nb = M.NB[i, : M.ri[i]]
        cfg = np.zeros(len(X), dtype=np.int64)
        for b, u in enumerate(nb):
            cfg |= X[:, u] << b
        assert np.array_equal(M.LUT[i, cfg], ltc.S(X1) - ltc.S(X0))
    # colour classes are independent sets of the conflict graph
    for I in M.classes:
        Iset = set(I.tolist())
        for i in I:
            assert not (set(M.NB[i, : M.ri[i]].tolist()) & Iset)


@pytest.mark.parametrize("seed", range(4))
def test_influence_bound_dominates_and_is_monotone(seed):
    rng = np.random.default_rng(10 + seed)
    ltc = random_overlap_ltc(rng, n=9, m=8)
    q = rng.uniform(0.1, 0.9, ltc.n)
    M = LocalModel(ltc, q)
    X = all_points(ltc.n)
    prev = None
    for theta in np.linspace(0.05, 2.0, 9):
        Bn = M.influence_bound(theta)
        if prev is not None:
            assert np.all(Bn >= prev - 1e-15)
        prev = Bn
        for th2 in (theta / 3, theta / 2, theta):
            # brute force: C_il = max |P(x_i=1 | x_-i) - P(x_i=1 | x'_-i)| over x, x' differing at l
            for i in range(ltc.n):
                X1, X0 = X.copy(), X.copy()
                X1[:, i], X0[:, i] = 1, 0
                rho = 1 / (1 + np.exp(-(M.a[i] + th2 * (ltc.S(X1) - ltc.S(X0)))))
                for b, l in enumerate(M.NB[i, : M.ri[i]]):
                    flip = X.copy()
                    flip[:, l] ^= 1
                    code = (flip * (1 << np.arange(ltc.n))).sum(axis=1)
                    Cil = np.max(np.abs(rho - rho[code]))
                    assert Cil <= Bn[i, b] + 1e-12


@pytest.mark.parametrize("seed", range(6))
def test_crude_theta0_always_certified(seed):
    rng = np.random.default_rng(20 + seed)
    ltc = random_overlap_ltc(rng, n=14, m=16)
    M = LocalModel(ltc, rng.uniform(0.05, 0.95, ltc.n))
    gamma = 0.2
    theta0 = 2 * (1 - gamma) / (ltc.d * (ltc.k - 1))
    cert = M.certificate(theta0, gamma)
    assert cert.alpha_unweighted <= 1 - gamma + 1e-9
    assert cert.alpha <= 1 - gamma + 1e-9


def test_glauber_law_matches_tilted_measure():
    rng = np.random.default_rng(3)
    ltc = chain_ltc(4, 2, rng, "random")
    q = rng.uniform(0.3, 0.7, ltc.n)
    M = LocalModel(ltc, q)
    theta = 0.4
    cert = M.certificate(theta, 0.2)
    s = cert.sweeps(1e-4, ltc.n)
    _, _, mu, _ = tilted(ltc, q, theta)
    N = 100_000
    emp = law_of_states(M.glauber(np.full(N, theta), s, rng))
    tv = 0.5 * np.abs(emp - mu).sum()
    noise = 0.5 * np.sqrt(mu * (1 - mu) / N).sum()
    assert tv <= 1e-4 + 2 * noise


def test_cftp_exact_beyond_dobrushin():
    rng = np.random.default_rng(4)
    ltc = chain_ltc(4, 2, rng, "monomial")
    q = rng.uniform(0.3, 0.7, ltc.n)
    M = LocalModel(ltc, q)
    assert M.is_supermodular()
    theta = 2.5
    assert M.certificate(theta, 0.0).alpha_unweighted > 1  # outside the Dobrushin regime
    _, _, mu, _ = tilted(ltc, q, theta)
    N = 100_000
    X, _ = M.cftp(np.full(N, theta), rng)
    emp = law_of_states(X)
    tv = 0.5 * np.abs(emp - mu).sum()
    noise = 0.5 * np.sqrt(mu * (1 - mu) / N).sum()
    assert tv <= 2 * noise


def test_supermodularity_check_matches_definition():
    rng = np.random.default_rng(5)
    for kind in ("monomial", "random", "maj"):
        ltc = chain_ltc(3, 1, rng, kind)
        M = LocalModel(ltc, np.full(ltc.n, 0.5))
        X = all_points(ltc.n)
        S = ltc.S(X)
        code = lambda Y: (Y * (1 << np.arange(ltc.n))).sum(axis=1)  # noqa: E731
        sup = True
        for i in range(ltc.n):
            for l in range(ltc.n):
                if i == l:
                    continue
                Y = X[(X[:, i] == 0) & (X[:, l] == 0)]
                Yi, Yl, Yil = Y.copy(), Y.copy(), Y.copy()
                Yi[:, i] = 1
                Yl[:, l] = 1
                Yil[:, i] = Yil[:, l] = 1
                if np.any(S[code(Yil)] - S[code(Yl)] < S[code(Yi)] - S[code(Y)]):
                    sup = False
        assert sup == M.is_supermodular()


@pytest.mark.parametrize("seed", range(3))
def test_rao_blackwell_statistic_is_unbiased_and_in_range(seed):
    rng = np.random.default_rng(30 + seed)
    ltc = random_overlap_ltc(rng, n=9, m=8)
    q = rng.uniform(0.2, 0.8, ltc.n)
    M = LocalModel(ltc, q)
    for theta in (0.0, 0.3, 1.1):
        X, S, mu, _ = tilted(ltc, q, theta)
        Srb = M.S_rb_states(X.T.astype(np.uint8), theta)
        assert abs(float(mu @ Srb) - float(mu @ S)) < 1e-9
        assert Srb.min() >= ltc.S_lo - 1e-9 and Srb.max() <= ltc.S_hi + 1e-9


def test_maurer_and_bernstein_coverage():
    rng = np.random.default_rng(6)
    miss_m = miss_b = 0
    R = 400
    for _ in range(R):
        x = rng.binomial(1, 0.02, size=300) * rng.uniform(0, 5, size=300)  # skewed, range 5
        if maurer_sum_ucb(x.sum(), 5.0, 0.1) < 300 * 0.02 * 2.5:
            miss_m += 1
        y = rng.uniform(-1, 1, size=200) ** 3
        if abs(y.sum()) > bernstein_halfwidth(200 * (1 / 7), 1.0, 0.1):
            miss_b += 1
    assert miss_m <= 0.1 * R and miss_b <= 0.1 * R


@pytest.mark.parametrize("window", [None, 3.0])
def test_ti_interval_coverage_with_exact_samples(window):
    rng = np.random.default_rng(7)
    ltc = chain_ltc(4, 3, rng, "random")
    q = rng.uniform(0.3, 0.7, ltc.n)
    M = LocalModel(ltc, q)
    theta, L = 1.0, 200
    grid = theta * np.arange(1, L + 1) / L
    laws = [tilted(ltc, q, th)[2] for th in grid]
    X = all_points(ltc.n)
    logZ = tilted(ltc, q, theta)[3]
    mus = np.array([float(law @ ltc.S(X)) for law in laws])
    miss, R = 0, 150
    for _ in range(R):
        idx = [rng.choice(len(law), p=law) for law in laws]
        Y = M.S_rb_states(X[idx].T.astype(np.uint8), grid)
        if window is None:
            lo, hi, _ = ti_interval(Y, theta, M.mu0, ltc.S_lo, ltc.S_hi, 0.03, 0.03)
        else:
            lo, hi, _ = ti_interval(Y, theta, M.mu0, ltc.S_lo, ltc.S_hi, 0.03, 0.03, 0.03, mus, window * 0.5)
        miss += not (lo <= logZ <= hi)
    assert miss <= 0.1 * R


@pytest.mark.parametrize("seed", range(4))
def test_tg_glauber_contains_p(seed):
    rng = np.random.default_rng(40 + seed)
    ltc = chain_ltc(6, 0, rng, "random")
    q = rng.uniform(0.3, 0.7, ltc.n)
    for t in range(ltc.S_lo, ltc.S_hi + 2):
        ltc.t = t
        p = brute_force_p(ltc, q)
        e = tg_estimate(ltc, q, eps=0.3, delta=0.1, L=600, max_is=6000, rng=rng, pilot_chains=64)
        assert covers(e, p), (t, p, e.lo, e.hi, e.note)


def test_tg_overlapping_scopes_and_tiny_budgets():
    rng = np.random.default_rng(50)
    for rep in range(6):
        ltc = random_overlap_ltc(rng, n=12, m=12, t=0)
        q = rng.uniform(0.25, 0.75, ltc.n)
        ltc.t = int(math.ceil(ltc.mean_S(q))) + 2
        p = brute_force_p(ltc, q)
        for L, IS in ((2, 50), (400, 4000)):  # sound at any budget
            e = tg_estimate(ltc, q, eps=0.3, delta=0.1, L=L, max_is=IS, rng=rng, pilot_chains=32)
            assert covers(e, p), (rep, L, p, e.lo, e.hi, e.note)


def test_tg_cftp_contains_p():
    rng = np.random.default_rng(60)
    ltc = chain_ltc(6, 0, rng, "monomial")
    q = rng.uniform(0.3, 0.7, ltc.n)
    for t in (2, 4, 6):
        ltc.t = t
        p = brute_force_p(ltc, q)
        e = tg_estimate(ltc, q, eps=0.3, delta=0.1, sampler="cftp", L=600, max_is=6000, rng=rng,
                        pilot_chains=64)
        assert covers(e, p), (t, p, e.lo, e.hi, e.note)
    rnd = chain_ltc(4, 2, rng, "random")
    if not LocalModel(rnd, np.full(rnd.n, 0.5)).is_supermodular():
        e = tg_estimate(rnd, np.full(rnd.n, 0.5), sampler="cftp", rng=rng)
        assert e.lo == 0.0 and e.hi == 1.0 and "no verdict" in e.note


def test_tg_with_side_condition():
    rng = np.random.default_rng(70)
    ltc = chain_ltc(6, 4, rng, "random")
    q = rng.uniform(0.3, 0.7, ltc.n)
    H = Circuit(ltc.n)
    H.set_output(H.OR(H.XOR(1, 3, 8), H.AND(H.NOT(2), 10)))
    ltc.H = H
    for t in (3, 4, 5):
        ltc.t = t
        p = brute_force_p(ltc, q)
        e = tg_estimate(ltc, q, eps=0.3, delta=0.1, L=600, max_is=6000, rng=rng, pilot_chains=64)
        assert covers(e, p), (t, p, e.lo, e.hi, e.note)


def test_recognition_round_trip():
    rng = np.random.default_rng(80)
    ltc = random_overlap_ltc(rng, n=10, m=8, t=3)
    H = Circuit(ltc.n)
    H.set_output(H.XOR(0, 5, 7))
    ltc.H = H
    C = ltc.to_circuit()
    X = all_points(ltc.n)
    assert np.array_equal(C.eval_bits(X.astype(bool)), ltc.C(X))
    back = ltc_from_circuit(C)
    assert back is not None and back.t == ltc.t and back.m == ltc.m
    assert np.array_equal(back.C(X), ltc.C(X))
    assert np.array_equal(back.S(X), ltc.S(X))


@pytest.mark.parametrize("T", [3.0, 3 + 5e-10, 3 - 5e-10, 3 + 1e-13, 3 - 1e-13, 2.5, 3.5 - 1e-15, 0.0, -2.0,
                               7.0, 7 + 1e-6, 1e6])
def test_recognised_threshold_matches_evaluator(T):
    """Regression: the integer threshold is read off the evaluator, so thresholds
    just above or below an integer (inside or outside the evaluator's rounding
    tolerance) are recognised exactly; the recognised LTC computes C."""
    n = 8
    C = Circuit(n)
    kids = [C.AND(i, i + 1) for i in range(n - 1)]
    C.set_output(C.THR(kids, [1.0] * len(kids), T))
    X = all_points(n)
    ltc = ltc_from_circuit(C)
    assert ltc is not None
    assert np.array_equal(ltc.C(X), C.eval_bits(X.astype(bool))), (T, ltc.t)
    q = np.full(n, 0.5)
    p = float(C.eval_bits(X.astype(bool)).mean())
    assert brute_force_p(ltc, q) == pytest.approx(p, abs=1e-15)
    e = tg_estimate(ltc, q, eps=0.2, delta=0.1, L=200, max_is=4000, rng=np.random.default_rng(5), pilot_chains=32)
    assert covers(e, p), (T, p, e.lo, e.hi, e.note)


def test_recognised_threshold_with_side_condition_and_large_fanin():
    """THR gate under an AND (side condition H), threshold k + 5e-10, and a
    fan-in above the full-enumeration limit (bisection path)."""
    n = 10
    C = Circuit(n)
    kids = [C.OR(C.AND(i, (i + 1) % n), C.NOT((i + 3) % n)) for i in range(n)]
    thr = C.THR(kids, [1.0] * n, 6 + 5e-10)
    C.set_output(C.AND(thr, C.XOR(0, 4)))
    X = all_points(n)
    ltc = ltc_from_circuit(C)
    assert ltc is not None and ltc.t == 7 and ltc.H is not None
    assert np.array_equal(ltc.C(X), C.eval_bits(X.astype(bool)))
    from rareprob.localthr import _thr_count_threshold
    m = 5000
    for T, want in [(17 + 5e-10, 18), (17.0, 17), (17 - 5e-10, 17), (-1.0, 0), (m + 0.5, m + 1)]:
        assert _thr_count_threshold(((1.0,) * m, T), m) == want
        assert _thr_count_threshold(((1.0,) * 40, T if T < 40 else 41.0), 40) == min(want, 41)


def test_ltc_threshold_is_rounded_up_not_truncated():
    rng = np.random.default_rng(81)
    ltc = random_overlap_ltc(rng, n=8, m=6, t=2)
    X = all_points(8)
    for t in (2.5, 2.0000001, np.float64(1.5), np.int64(3)):
        L = LTC(8, ltc.scopes, ltc.tables, t)
        assert L.t == math.ceil(t)
        assert np.array_equal(L.C(X), ltc.S(X) >= t)
    with pytest.raises((ValueError, OverflowError)):
        LTC(8, ltc.scopes, ltc.tables, float("nan"))


def test_chain_transfer_matrix_exact():
    rng = np.random.default_rng(90)
    ltc = chain_ltc(6, 0, rng, "random")
    q = rng.uniform(0.2, 0.8, ltc.n)
    dist = chain_distribution(ltc, q)
    X = all_points(ltc.n)
    w = np.prod(np.where(X == 1, q, 1 - q), axis=1)
    exact = np.bincount(ltc.S(X), weights=w, minlength=len(dist))
    assert np.allclose(dist[: len(exact)], exact, rtol=1e-12, atol=1e-15)


def test_trivial_thresholds_and_regular_family():
    rng = np.random.default_rng(100)
    ltc = regular_ltc(8, 0, rng)
    assert ltc.d == 3 and ltc.k == 3
    q = np.full(ltc.n, 0.5)
    ltc.t = ltc.S_hi + 1
    assert tg_estimate(ltc, q, rng=rng).hi == 0.0
    ltc.t = ltc.S_lo
    e = tg_estimate(ltc, q, rng=rng)
    assert e.lo == e.hi == 1.0
