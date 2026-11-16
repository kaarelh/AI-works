#!/usr/bin/env python3
"""Referee check (key: hellinger-runs), part 2: the two potentials of Section 2, numerically.

Independent of the prover's scripts.  Convention H2(p,q) = 1 - sum sqrt(p q).

(N1) q0 and c* to 30 digits; rigorous enclosure of the sign of g - k near q0 by interval
     arithmetic (erf by its alternating series with the first omitted term as error);
     uniqueness of the root (r is strictly decreasing in q).
(N2) Lemma 2.2(ii) on the extreme laws of r (point masses at r <= 1; two-point laws with
     second moment exactly 1), fine grid; the best constant for this U.
(N3) Theorem 2.7, Step 2: V(a) <= tau_Lambda(a) on a fine grid, tau computed from its
     definition with the multiplier mu of the proof.
(N4) Theorem 2.7, Step 3: E U*(Lambda r) <= U*(Lambda) + c*(1 - E r) on the extreme laws.
(N5) (iv) and (v) of Step 0 on a grid; continuity of V and p(s0) = q(s0) = q0.
(N6) Example 2.8(ii): the ratio H2 / E_P sum h in 30-digit arithmetic, computed in two
     ways (the formula of Theorem 2.1(a), and directly from the two laws of the runs).
(N7) Theorems 2.1 and 2.7 on random trees by exhaustive enumeration, and drift-and-drop
     strategies with random and with locally optimised drop factors: no ratio above c*.
(N8) Example 2.8(i): the maximum of the limit ratio.
Needs numpy, scipy (erf) and mpmath.
"""
import itertools
import math
import sys

import mpmath as mp
import numpy as np
from scipy.special import erf as np_erf

mp.mp.dps = 40
SQ2 = math.sqrt(2.0)
SPI = math.sqrt(math.pi)


# ------------------------------------------------------------------ the functions of Theorem 2.7
def g_mp(q):
    q = mp.mpf(q)
    return 1 + q * mp.exp(q * q / 4) * (1 / mp.sqrt(2) + mp.sqrt(mp.pi) / 2 * mp.erf(q / 2))


def k_mp(q):
    q = mp.mpf(q)
    return 1 / (1 - q * q / 2)


def g_np(q):
    return 1 + q * np.exp(q * q / 4) * (1 / SQ2 + (SPI / 2) * np_erf(q / 2))


def s_np(q):
    return 1 / g_np(q)


def p_np(q):
    """p = 2(1-s)/q = 2 exp(q^2/4)(1/sqrt2 + sqrt(pi)/2 erf(q/2)) / g, finite at q = 0."""
    return 2 * np.exp(q * q / 4) * (1 / SQ2 + (SPI / 2) * np_erf(q / 2)) / g_np(q)


Q0_MP = mp.findroot(lambda q: g_mp(q) - k_mp(q), mp.mpf("1.15"))
C_MP = k_mp(Q0_MP)
Q0 = float(Q0_MP)
C = float(C_MP)
S0 = 1 / C


def q_of_s(s):
    """Inverse of s(q) = 1/g(q) on [s0, 1] (vectorised Newton with bisection safeguard)."""
    s = np.asarray(s, dtype=float)
    lo = np.zeros_like(s)
    hi = np.full_like(s, Q0 + 1e-9)
    q = np.clip((1 - s) * SQ2, 1e-12, Q0)
    for _ in range(80):
        f = s_np(q) - s
        lo = np.where(f > 0, q, lo)          # s decreasing in q
        hi = np.where(f <= 0, q, hi)
        ds = -(s_np(q) / (2 * np.maximum(q, 1e-300))) * (2 * (1 - s_np(q)) + q * q)
        qn = q - f / ds
        bad = ~((qn > lo) & (qn < hi))
        q = np.where(bad, 0.5 * (lo + hi), qn)
    return q


def V_np(x):
    x = np.asarray(x, dtype=float)
    out = np.zeros_like(x)
    mid = (x > 1) & (x < C)
    if np.any(mid):
        qq = q_of_s(x[mid] / C)
        rr = (p_np(qq) - qq) / 2
        out[mid] = C * rr * rr
    top = x >= C
    out[top] = x[top] - C / 2
    return out


def U_np(x):
    return V_np(x) - np.asarray(x, dtype=float)


# ------------------------------------------------------------------ (N1)
def iv_erf(x):
    """Enclosure of erf(x) for an interval 0 <= x <= 1 by the alternating Maclaurin series."""
    iv = mp.iv
    total = iv.mpf(0)
    n = 0
    while True:
        term = x ** (2 * n + 1) / (iv.mpf(math.factorial(n)) * (2 * n + 1))
        if term.b < mp.mpf(10) ** (-45):
            # terms decrease in modulus (x <= 1): the tail is bounded by the first omitted term
            total = total + iv.mpf([-term.b, term.b])
            break
        total = total + (term if n % 2 == 0 else -term)
        n += 1
    return 2 / iv.sqrt(iv.pi) * total


def iv_g_minus_k(qstr):
    iv = mp.iv
    q = iv.mpf(qstr)
    gg = 1 + q * iv.exp(q * q / 4) * (1 / iv.sqrt(2) + iv.sqrt(iv.pi) / 2 * iv_erf(q / 2))
    kk = 1 / (1 - q * q / 2)
    return gg - kk, kk


def part_n1():
    print("(N1) the root q0 of g = k and the constant c* = k(q0)")
    print("     q0 =", mp.nstr(Q0_MP, 30))
    print("     c* =", mp.nstr(C_MP, 30), "  c*/2 =", mp.nstr(C_MP / 2, 12), "  sqrt(c*) =", mp.nstr(mp.sqrt(C_MP), 12))
    print("     s0 = 1/c* =", mp.nstr(1 / C_MP, 20), "  check q0^2 - 2(c*-1)/c* =", mp.nstr(Q0_MP ** 2 - 2 * (C_MP - 1) / C_MP, 5))
    for qq in ["1.151", "1.152"]:
        print(f"     g - k at q = {qq}: {mp.nstr(g_mp(qq) - k_mp(qq), 10)};  k = {mp.nstr(k_mp(qq), 10)}")
    mp.iv.dps = 40
    for qq in ["1.15120357", "1.15120358"]:
        dgk, kk = iv_g_minus_k(qq)
        lo, hi = mp.make_mpf(dgk._mpi_[0]), mp.make_mpf(dgk._mpi_[1])
        klo, khi = mp.make_mpf(kk._mpi_[0]), mp.make_mpf(kk._mpi_[1])
        print(f"     interval arithmetic, q = {qq}: g - k in [{mp.nstr(lo, 10)}, {mp.nstr(hi, 10)}],"
              f" k in [{mp.nstr(klo, 12)}, {mp.nstr(khi, 12)}]")
    # uniqueness: r(q) = (1-s)/q - q/2 has dr/dq = -(1-s)(q^2+2(1-s))/(2q^2) < 0 for all q > 0
    qs = np.linspace(1e-6, 1.4142, 400001)
    rr = (p_np(qs) - qs) / 2
    print("     r(q) on (0, sqrt 2): r(0+) =", f"{rr[0]:.8f}", "(1/sqrt2 = 0.70710678), strictly decreasing on the grid:",
          bool(np.all(np.diff(rr) < 0)), "; number of sign changes of g - k on the grid:",
          int(np.sum(np.diff(np.sign(g_np(qs) - 1 / (1 - qs * qs / 2))) != 0)))


# ------------------------------------------------------------------ (N2)
def extreme_laws(n1=241, n2=260):
    """Support points of the extreme laws of r >= 0 with E r^2 <= 1:
    two-point laws {r1 < 1 < r2} with weight pi on r1 such that the second moment is 1."""
    r1 = np.linspace(0.0, 1.0, n1, endpoint=False)
    r2 = 1 + np.concatenate([np.logspace(-6, 0, n2 // 2), np.logspace(0, 3.5, n2 // 2)[1:]])
    R1, R2 = np.meshgrid(r1, r2, indexing="ij")
    PI = (R2 * R2 - 1) / (R2 * R2 - R1 * R1)
    return R1, R2, PI


def part_n2():
    print("(N2) Lemma 2.2(ii): E U(Lam r) - U(Lam) - 4(1 - E r) on the extreme laws (must be <= 0)")
    U = lambda x: 0.5 * np.maximum(2.0 - x, 0.0) ** 2
    R1, R2, PI = extreme_laws()
    r_pm = np.linspace(0.0, 1.0, 2001)
    worst = -np.inf
    best_ratio = 0.0
    arg = None
    for Lam in np.concatenate([np.logspace(-3, 3, 601), np.linspace(1.5, 2.5, 401)]):
        Er = PI * R1 + (1 - PI) * R2
        lhs = PI * U(Lam * R1) + (1 - PI) * U(Lam * R2) - U(Lam)
        d2 = lhs - 4 * (1 - Er)
        d1 = U(Lam * r_pm) - U(Lam) - 4 * (1 - r_pm)
        w = max(float(d2.max()), float(d1.max()))
        if w > worst:
            worst, arg = w, Lam
        with np.errstate(divide="ignore", invalid="ignore"):
            rat2 = np.where(1 - Er > 1e-9, lhs / (1 - Er), 0.0)
            rat1 = np.where(1 - r_pm > 1e-9, (U(Lam * r_pm) - U(Lam)) / (1 - r_pm), 0.0)
        best_ratio = max(best_ratio, float(rat2.max()), float(rat1.max()))
    print(f"     max over the grid = {worst:.3e} (at Lam = {arg:.4f});"
          f" largest [E U(Lam r) - U(Lam)]/(1 - E r) found = {best_ratio:.5f} (the constant 4 is the best one for this U)")


# ------------------------------------------------------------------ (N3)
def tau_def(Lam, a):
    """tau_Lambda(a) from its definition, with the multiplier mu chosen in the proof."""
    if Lam <= 1:
        mu = (C - Lam) / 2
        ULam = -Lam
    elif Lam < C:
        qq = float(q_of_s(np.array([Lam / C]))[0])
        pp = float(p_np(np.array([qq]))[0])
        rr = (pp - qq) / 2
        mu = C * pp * pp / 4
        ULam = C * rr * rr - Lam
    else:
        mu = C / 2
        ULam = -C / 2
    return ULam + C * (1 - a / Lam) + mu * (a * a / Lam ** 2 - 1) + a, mu


def part_n3():
    print("(N3) Theorem 2.7, Step 2: min over a grid of tau_Lambda(a) - V(a) (must be >= 0 up to rounding)")
    a = np.concatenate([np.linspace(0, 1, 801), np.linspace(1, C, 4001)[1:], C * np.logspace(0, 4, 3001)[1:]])
    Va = V_np(a)
    Lams = np.concatenate([np.logspace(-4, 0, 400), np.linspace(1, C, 1501)[1:-1], C * np.logspace(0, 4, 400)])
    worst = np.inf
    arg = None
    min_mu = np.inf
    for Lam in Lams:
        t, mu = tau_def(float(Lam), a)
        min_mu = min(min_mu, mu)
        dmin = t - Va
        i = int(dmin.argmin())
        if dmin[i] < worst:
            worst, arg = float(dmin[i]), (float(Lam), float(a[i]))
    print(f"     min = {worst:.3e} at (Lam, a) = ({arg[0]:.5f}, {arg[1]:.5f}); smallest multiplier mu = {min_mu:.4f} (must be >= 0);"
          f" grid: {len(Lams)} values of Lam x {len(a)} values of a")


# ------------------------------------------------------------------ (N4)
def part_n4():
    print("(N4) Theorem 2.7, Step 3: E U*(Lam r) - U*(Lam) - c*(1 - E r) on the extreme laws (must be <= 0)")
    R1, R2, PI = extreme_laws(n1=161, n2=200)
    r_pm = np.linspace(0.0, 1.0, 1001)
    Er = PI * R1 + (1 - PI) * R2
    worst = -np.inf
    arg = None
    best_ratio = 0.0
    arg_ratio = None
    Lams = np.concatenate([np.logspace(-2, 0, 60), np.linspace(1, C, 181), C * np.logspace(0, 3, 60)[1:]])
    for Lam in Lams:
        ULam = float(U_np(np.array([Lam]))[0])
        lhs = PI * U_np(Lam * R1) + (1 - PI) * U_np(Lam * R2) - ULam
        d2 = lhs - C * (1 - Er)
        d1 = U_np(Lam * r_pm) - ULam - C * (1 - r_pm)
        w = max(float(d2.max()), float(d1.max()))
        if w > worst:
            worst, arg = w, float(Lam)
        with np.errstate(divide="ignore", invalid="ignore"):
            rat2 = np.where(1 - Er > 1e-7, lhs / (1 - Er), 0.0)
        if float(rat2.max()) > best_ratio:
            best_ratio = float(rat2.max())
            i, j = np.unravel_index(int(rat2.argmax()), rat2.shape)
            arg_ratio = (float(Lam), float(R1[i, j]), float(R2[i, j]))
    print(f"     max over the grid = {worst:.3e} (at Lam = {arg:.4f}); largest [E U*(Lam r) - U*(Lam)]/(1 - E r) found ="
          f" {best_ratio:.6f} at (Lam, r1, r2) = ({arg_ratio[0]:.4f}, {arg_ratio[1]:.4f}, {arg_ratio[2]:.6f});  c* = {C:.6f}")


def part_n4b():
    """Continuous search (Nelder-Mead from random starts) for a violation of the one-step
    inequalities, over two-point laws with second moment 1 and over point masses."""
    from scipy.optimize import minimize
    rng = np.random.default_rng(5)
    Usimple = lambda x: 0.5 * np.maximum(2.0 - x, 0.0) ** 2

    def gap(par, Ufun, c):
        Lam = math.exp(min(max(par[0], -20.0), 20.0))
        r1 = 1 / (1 + math.exp(-min(max(par[1], -25.0), 25.0)))      # in (0, 1)
        r2 = 1 + math.exp(min(max(par[2], -25.0), 12.0))             # > 1
        pi = (r2 * r2 - 1) / (r2 * r2 - r1 * r1)
        vals = Ufun(np.array([Lam * r1, Lam * r2, Lam]))
        return float(pi * vals[0] + (1 - pi) * vals[1] - vals[2] - c * (1 - pi * r1 - (1 - pi) * r2))

    def gap_pm(par, Ufun, c):
        Lam = math.exp(min(max(par[0], -20.0), 20.0))
        r = 1 / (1 + math.exp(-min(max(par[1], -25.0), 25.0)))
        vals = Ufun(np.array([Lam * r, Lam]))
        return float(vals[0] - vals[1] - c * (1 - r))

    out = []
    for name, Ufun, c in (("U of Lemma 2.2, constant 4", Usimple, 4.0), ("U* of Theorem 2.7, constant c*", U_np, C)):
        best = -np.inf
        for _ in range(250):
            x0 = np.array([rng.uniform(-3, 4), rng.uniform(-6, 6), rng.uniform(-12, 5)])
            res = minimize(lambda z: -gap(z, Ufun, c), x0, method="Nelder-Mead", options={"xatol": 1e-10, "fatol": 1e-15, "maxiter": 4000})
            best = max(best, -res.fun)
            res = minimize(lambda z: -gap_pm(z, Ufun, c), x0[:2], method="Nelder-Mead", options={"xatol": 1e-10, "fatol": 1e-15, "maxiter": 2000})
            best = max(best, -res.fun)
        out.append((name, best))
    print("(N4b) continuous search for a violation of the one-step inequalities (500 Nelder-Mead runs each):")
    for name, best in out:
        print(f"     {name}: largest value of E U(Lam r) - U(Lam) - c (1 - E r) found = {best:.3e} (must be <= 0 up to rounding)")


# ------------------------------------------------------------------ (N5)
def part_n5():
    print("(N5) Step 0 (iv), (v); continuity of V; end points")
    qg = np.linspace(0.0, Q0, 3001)
    S = s_np(qg)
    P = p_np(qg)
    Rr = (P - qg) / 2
    w4 = np.inf
    w5 = np.inf
    sp_ = np.concatenate([np.linspace(1, 3, 2001), np.logspace(math.log10(3), 5, 2000)])
    for i in range(len(qg)):
        w4 = min(w4, float(np.min(P[i] * S - S[i] * qg[i] - 2 * S[i] * Rr)))
        w5 = min(w5, float(np.min(P[i] * sp_ - S[i] * qg[i] - 2 * S[i] * np.sqrt(sp_ - 0.5))))
    print(f"     min of phi(s,s') on the grid = {w4:.3e}, min of psi(s,s') = {w5:.3e} (both must be >= 0 up to rounding)")
    print(f"     p(s0) = {P[-1]:.12f}, q0 = {Q0:.12f}, r(s0) = {Rr[-1]:.3e}; p(1) = {P[0]:.12f} (sqrt 2 = {SQ2:.12f}), r(1) = {Rr[0]:.12f}")
    print(f"     p/s is increasing in q (decreasing in s) on the grid: {bool(np.all(np.diff(P / S) > 0))};"
          f" r >= 0 on [0, q0]: {bool(np.all(Rr > -1e-13))}")
    eps = 1e-9
    print(f"     V(1-) = {float(V_np(np.array([1 - eps]))[0]):.2e}, V(1+) = {float(V_np(np.array([1 + eps]))[0]):.2e};"
          f" V(c*-) - c*/2 = {float(V_np(np.array([C - eps]))[0]) - C / 2:.2e}, V(c*+) - c*/2 = {float(V_np(np.array([C + eps]))[0]) - C / 2:.2e}")


# ------------------------------------------------------------------ (N6)
def q_of_s_mp(s, guess):
    f = lambda q: 1 / g_mp(q) - s
    return mp.findroot(f, guess)


def strategy_mp(beta_str, top=mp.mpf(10) ** 6, d0_exp=mp.mpf("0.01")):
    """Example 2.8(ii) in 30-digit arithmetic.  Returns the ratio computed from the formula
    of Theorem 2.1(a), the ratio computed from the two laws of the runs, the two sums, the
    number of levels, and the total S'-probability of the listed runs (must be 1)."""
    mp.mp.dps = 30
    beta = mp.mpf(beta_str)
    c = +C_MP
    A = mp.mpf(0)          # sum_k R_k beta^k h_k
    Bsum = mp.mpf(0)       # sum_k R_k h_k
    BC = mp.mpf(0)         # sum over runs of sqrt(Q_S Q_S')
    tot2 = mp.mpf(0)       # total S'-probability
    R = mp.mpf(1)
    R2 = mp.mpf(1)         # S'-probability of reaching the level
    Lam = mp.mpf(1)
    k = 0
    guess = +Q0_MP
    while Lam <= top:
        if k == 0:
            d = beta ** (-d0_exp)
        elif Lam < c:
            s = Lam / c
            qq = q_of_s_mp(s, guess)
            guess = qq
            pp = 2 * (1 - s) / qq
            d = qq / pp
        else:
            d = mp.mpf(0)
        pi = (beta * beta - 1) / (beta * beta - d * d)
        h = 1 - pi * d - (1 - pi) * beta
        A += R * Lam * h
        Bsum += R * h
        BC += mp.sqrt(R * pi * R2 * pi * d * d)         # the run "k ups, then drop"
        tot2 += R2 * pi * d * d
        R *= (1 - pi)
        R2 *= (1 - pi) * beta * beta
        Lam *= beta
        k += 1
    BC += mp.sqrt(R * R2)                               # truncated runs (identical continuation)
    tot2 += R2
    mp.mp.dps = 40
    return A / Bsum, (1 - BC) / Bsum, A, Bsum, k, tot2


def strategy_float(beta, top=1e6, d0_exp=0.01):
    """The same example in double precision, vectorised (for beta very close to 1)."""
    K = int(math.floor(math.log(top) / math.log(beta))) + 1
    k = np.arange(K)
    Lam = np.exp(k * math.log(beta))
    d = np.zeros(K)
    mid = (Lam < C) & (k > 0)
    qq = q_of_s(Lam[mid] / C)
    d[mid] = qq / p_np(qq)
    d[0] = beta ** (-d0_exp)
    pi = (beta * beta - 1) / (beta * beta - d * d)
    h = 1 - pi * d - (1 - pi) * beta
    logR = np.concatenate([[0.0], np.cumsum(np.log1p(-pi))[:-1]])
    R = np.exp(logR)
    return math.fsum(R * Lam * h) / math.fsum(R * h), K


def part_n6(fine):
    print("(N6) Example 2.8(ii), 30-digit arithmetic: ratio by Theorem 2.1(a), ratio from the run laws, levels")
    betas = ["1.1", "1.01", "1.001"] + (["1.0001"] if fine else [])
    for b in betas:
        r1, r2, A, Bs, k, tot2 = strategy_mp(b)
        print(f"     beta = {b:<7} levels = {k:6d}  H2 = {mp.nstr(A, 8)}  E_P sum h = {mp.nstr(Bs, 8)}"
              f"  ratio = {mp.nstr(r1, 9)}  (from run laws: {mp.nstr(r2, 9)}; total S'-mass - 1 = {mp.nstr(tot2 - 1, 3)})"
              f"  c* - ratio = {mp.nstr(C_MP - r1, 4)}")
    print("     the same in double precision (vectorised), to follow beta -> 1:")
    for b in [1.001, 1.0001] + ([1.00001, 1.000001] if fine else []):
        r, K = strategy_float(b)
        print(f"     beta = {b:<9} levels = {K:8d}  ratio = {r:.6f}  c* - ratio = {C - r:.3e}")


# ------------------------------------------------------------------ (N7)
def tree_eval(P, Q, n, kk):
    level = {(): (1.0, 1.0)}
    sigP = sigQ = ident = 0.0
    for dpt in range(n):
        nxt = {}
        for hist, (pp, qq) in level.items():
            p, q = P[hist], Q[hist]
            h = 1.0 - float(np.sum(np.sqrt(p * q)))
            sigP += pp * h
            sigQ += qq * h
            ident += math.sqrt(pp * qq) * h
            for x in range(kk):
                nxt[hist + (x,)] = (pp * p[x], qq * q[x])
        level = nxt
    bc = sum(math.sqrt(pp * qq) for pp, qq in level.values())
    return 1.0 - bc, sigP, sigQ, ident


def drift_drop_ratio(beta, d):
    """Ratio for the drift-and-drop pair with drop factors d[0..K-1] (truncated after K levels)."""
    pi = (beta * beta - 1) / (beta * beta - d * d)
    h = 1 - pi * d - (1 - pi) * beta
    R = np.concatenate([[1.0], np.cumprod(1 - pi)[:-1]])
    Lam = beta ** np.arange(len(d))
    return float(np.sum(R * Lam * h) / np.sum(R * h))


def part_n7():
    print("(N7) random experiments")
    rng = np.random.default_rng(7)
    worst_ratio = 0.0
    worst_a = worst_b = 0.0
    for _ in range(3000):
        n = int(rng.integers(1, 5))
        kk = int(rng.integers(2, 4))
        P, Q = {}, {}
        for dpt in range(n):
            for hist in itertools.product(range(kk), repeat=dpt):
                p = rng.dirichlet(np.ones(kk) * rng.choice([0.1, 1.0, 6.0]))
                q = rng.dirichlet(np.ones(kk) * rng.choice([0.1, 1.0, 6.0]))
                if rng.random() < 0.25:
                    j = rng.integers(kk); p = p.copy(); p[j] = 0.0; p /= p.sum()
                if rng.random() < 0.25:
                    j = rng.integers(kk); q = q.copy(); q[j] = 0.0; q /= q.sum()
                if rng.random() < 0.2:
                    q = p.copy()
                P[hist], Q[hist] = p, q
        h2, sigP, sigQ, ident = tree_eval(P, Q, n, kk)
        worst_a = max(worst_a, abs(h2 - ident))
        worst_b = max(worst_b, h2 - 0.5 * (sigP + sigQ))
        if sigP > 1e-12:
            worst_ratio = max(worst_ratio, h2 / sigP)
    print(f"     3000 random trees (depth <= 4): max |H2 - E_P sum Lam h| = {worst_a:.2e}; max of H2 - (E_P + E_Q)/2 = {worst_b:.2e};"
          f" max ratio H2/E_P sum h = {worst_ratio:.4f}")
    best = 0.0
    for beta in [2.0, 1.5, 1.2, 1.1, 1.05]:
        K = int(math.log(1e5) / math.log(beta)) + 1
        for _ in range(4000):
            d = rng.random(K) ** rng.choice([0.3, 1.0, 3.0])
            d = np.minimum(d, 1 - 1e-9)
            best = max(best, drift_drop_ratio(beta, d))
    print(f"     20000 drift-and-drop pairs with random drop factors: largest ratio = {best:.4f}")
    for beta in [1.5, 1.1]:
        K = int(math.log(1e5) / math.log(beta)) + 1
        Lam = beta ** np.arange(K)
        d = np.where(Lam < C, 0.5, 0.0)
        cur = drift_drop_ratio(beta, d)
        step = 0.2
        for sweep in range(60):
            for i in range(K):
                for cand in (d[i] + step, d[i] - step):
                    if 0.0 <= cand < 1.0:
                        old = d[i]
                        d[i] = cand
                        val = drift_drop_ratio(beta, d)
                        if val > cur:
                            cur = val
                        else:
                            d[i] = old
            step *= 0.8
        print(f"     beta = {beta}: coordinate ascent over the {K} drop factors: ratio = {cur:.5f}  (c* = {C:.5f})")


# ------------------------------------------------------------------ (N8)
def part_n8():
    bs = np.linspace(1.5, 20, 1850001)
    v = 2 * (bs ** 2 + 1) / (bs ** 2 + 3 - 2 * np.log(bs))
    print(f"(N8) Example 2.8(i): max over b of 2(b^2+1)/(b^2+3-2 ln b) = {v.max():.6f} at b = {bs[v.argmax()]:.4f};"
          f" Example 2.6: (2+sqrt2)/2 = {(2 + SQ2) / 2:.6f}; 2/prod_(i>=1)(1-2^-i) = {2 / float(mp.qp(mp.mpf(1) / 2)):.5f}")


if __name__ == "__main__":
    fine = len(sys.argv) > 1 and sys.argv[1] == "fine"
    part_n1()
    part_n2()
    part_n3()
    part_n4()
    part_n4b()
    part_n5()
    part_n7()
    part_n8()
    part_n6(fine)
