#!/usr/bin/env python3
"""The best constant in  H2(P,Q) <= c * E_P[ sum_i H2(P_i, Q_i) ]  (Section 2.4).

Theorem 2.7 of the write-up proves the inequality with c* = 1/(1 - q0^2/2), q0 the
smallest positive root of g(q) = 1/(1 - q^2/2),
    g(q) = 1 + q exp(q^2/4) (1/sqrt 2 + (sqrt pi / 2) erf(q/2)),
by means of the potential U* = -x on [0,1], U* = c* r(x/c*)^2 - x on [1,c*],
U* = -c*/2 on [c*,oo), where, with s = 1/g(q): p = 2(1-s)/q and r = (p-q)/2.
This script evaluates c*, checks the ingredients of that proof numerically, and
computes lower bounds for the best constant.

(B) q0 and c*; the sign of g(q) - 1/(1-q^2/2) on (0, sqrt 2).
(C) The parabola condition  U*(a) <= U*(Lam) + c*(1 - a/Lam) + mu(Lam)(a^2/Lam^2 - 1),
    mu = (Lam U*'(Lam) + c*)/2, on a grid of (Lam, a); and (T): U*(x) + x >= 0.
(E) The identities d(p/s)/dq = 1/s and dr/ds = p/(2s), the inequalities (iv) and (v) of
    the proof on a grid, and a direct test of
        E[U*(Lam rho)] <= U*(Lam) + c* (1 - E[rho])
    on random laws of rho with E[rho^2] <= 1.
(D) An explicit strategy (a pair of Markov chains) whose ratio H2 / E_P sum h tends to
    c*: at level Lam = u^k either move up to u*Lam or drop to the level Lam q/p, and
    stop after a drop; the second moment of the step is 1.  This is Example 2.8(ii).
(A) Linear programme (needs scipy): restricting Lam and Lam*rho to a geometric grid G
    gives a linear programme in (U|_G, c) whose value c_G is the best constant against
    adversaries confined to the grid, hence a lower estimate of the best constant; it
    increases as the grid is refined.  The extreme laws of rho are point masses at
    r <= 1 and two-point laws with E[rho^2] = 1.
"""
import math
import sys
import numpy as np

SQ2 = math.sqrt(2.0)
SPI = math.sqrt(math.pi)


def bisect(f, lo, hi, it=200):
    flo = f(lo)
    for _ in range(it):
        mid = 0.5 * (lo + hi)
        fm = f(mid)
        if (fm > 0) == (flo > 0):
            lo, flo = mid, fm
        else:
            hi = mid
    return 0.5 * (lo + hi)


def inv_s(q):
    return 1 + q * math.exp(q * q / 4) * (1 / SQ2 + (SPI / 2) * math.erf(q / 2))


Q0 = bisect(lambda q: inv_s(q) - 1 / (1 - q * q / 2), 0.5, 1.3)
CSTAR = 1 / (1 - Q0 * Q0 / 2)


def q_of_s(s):
    return bisect(lambda q: inv_s(q) - 1 / s, 0.0, Q0 + 1e-12)


def U(x, c=CSTAR):
    if x <= 1:
        return -x
    if x >= c:
        return -c / 2
    s = x / c
    q = q_of_s(s)
    r = (1 - s) / q - q / 2
    return c * r * r - x


def xUprime(x, c=CSTAR):
    """x U'(x)."""
    if x < 1:
        return -x
    if x >= c:
        return 0.0
    s = x / c
    q = q_of_s(s)
    p = 2 * (1 - s) / q
    return c * p * p / 2 - c


def down_factor(Lam, c=CSTAR):
    s = Lam / c
    if s >= 1:
        return 0.0
    q = q_of_s(s)
    p = 2 * (1 - s) / q
    return q / p


def check_potential():
    c = CSTAR
    xs = np.concatenate([np.linspace(0, 1, 201)[:-1], np.exp(np.linspace(0, math.log(60), 1500))])
    Uv = np.array([U(x) for x in xs])
    worst = np.inf
    arg = None
    for Lam in np.exp(np.linspace(math.log(0.02), math.log(60), 1200)):
        mu = (xUprime(Lam) + c) / 2
        T = U(Lam) + c * (1 - xs / Lam) + mu * (xs * xs / Lam ** 2 - 1)
        d = T - Uv
        i = int(d.argmin())
        if d[i] < worst:
            worst, arg = d[i], (Lam, xs[i])
    termin = float(np.min(Uv + xs))          # (T): U(x) + x >= U(1) + 1 = 0
    return worst, arg, termin


def s_of_q(q):
    return 1 / inv_s(q)


def p_of_q(q):
    return 2 * (1 - s_of_q(q)) / q


def r_of_q(q):
    return (p_of_q(q) - q) / 2


def check_ingredients():
    out = {}
    # sign changes of g - k on (0, sqrt 2)
    qs = np.linspace(1e-4, 1.41, 141001)
    gk = np.array([inv_s(q) - 1 / (1 - q * q / 2) for q in qs])
    out["roots"] = qs[np.where(np.diff(np.sign(gk)) != 0)[0]]
    out["gk_1151"] = inv_s(1.151) - 1 / (1 - 1.151 ** 2 / 2)
    out["gk_1152"] = inv_s(1.152) - 1 / (1 - 1.152 ** 2 / 2)
    # derivative identities by central differences
    worst_a = worst_b = 0.0
    e = 1e-6
    for q in np.linspace(0.05, Q0 - 0.01, 60):
        dps = (p_of_q(q + e) / s_of_q(q + e) - p_of_q(q - e) / s_of_q(q - e)) / (2 * e)
        drds = (r_of_q(q + e) - r_of_q(q - e)) / (s_of_q(q + e) - s_of_q(q - e))
        worst_a = max(worst_a, abs(dps - 1 / s_of_q(q)))
        worst_b = max(worst_b, abs(drds - p_of_q(q) / (2 * s_of_q(q))))
    out["id_a"], out["id_b"] = worst_a, worst_b
    # (iv) and (v) on a grid
    qg = np.linspace(1e-4, Q0, 1500)
    S = np.array([s_of_q(q) for q in qg]); Pp = np.array([p_of_q(q) for q in qg])
    Rr = np.maximum((Pp - qg) / 2, 0.0)
    sp = np.linspace(1.0, 60.0, 6000)
    w4 = w5 = np.inf
    for i in range(len(qg)):
        w4 = min(w4, float(np.min(Pp[i] * S - S[i] * qg[i] - 2 * S[i] * Rr)))
        w5 = min(w5, float(np.min(Pp[i] * sp - S[i] * qg[i] - 2 * S[i] * np.sqrt(sp - 0.5))))
    out["iv"], out["v"] = w4, w5
    # direct random test of (S) for U*
    rng = np.random.default_rng(1)
    worst = -np.inf
    for _ in range(40000):
        k = rng.integers(2, 5)
        pp = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        qq = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        if rng.random() < 0.3:
            j = rng.integers(k); pp = pp.copy(); pp[j] = 0.0; pp /= pp.sum()
        if rng.random() < 0.3:
            j = rng.integers(k); qq = qq.copy(); qq[j] = 0.0; qq /= qq.sum()
        m = pp > 0
        rho = np.zeros(k); rho[m] = np.sqrt(qq[m] / pp[m])
        Lam = float(np.exp(rng.uniform(-2, 2.5)))
        lhs = sum(pp[i] * U(Lam * rho[i]) for i in range(k))
        rhs = U(Lam) + CSTAR * (1 - float(np.sum(pp * rho)))
        worst = max(worst, lhs - rhs)
    out["S"] = worst
    return out


def strategy_ratio(u, top, d0_exp=0.01):
    """Exact H2 and E_P sum h (sums over the levels) for the strategy of (D), truncated
    when Lam exceeds `top` (after that both laws coincide)."""
    A = B = 0.0
    R = 1.0
    k = 0
    while True:
        Lam = u ** k
        if Lam > top:
            break
        d = down_factor(Lam) if k > 0 else u ** (-d0_exp)
        pi = (u * u - 1) / (u * u - d * d)
        h = 1 - pi * d - (1 - pi) * u
        A += R * Lam * h
        B += R * h
        R *= (1 - pi)
        k += 1
    return A / B, A, B, k


def lp_value(u, x_lo, x_hi):
    from scipy.optimize import linprog
    from scipy.sparse import coo_matrix
    klo = int(np.floor(np.log(x_lo) / np.log(u)))
    khi = int(np.ceil(np.log(x_hi) / np.log(u)))
    ks = np.arange(klo, khi + 1)
    xs = np.concatenate([[0.0], u ** ks.astype(float)])
    N = len(xs)
    i1 = 1 + int(np.where(ks == 0)[0][0])
    R, C, V = [], [], []
    r = 0
    for i in range(1, N):
        xi = xs[i]
        js = np.arange(0, i)
        m = len(js)
        rr = r + np.arange(m)                       # point masses at x_j/x_i <= 1
        R += [rr, rr, rr]; C += [js, np.full(m, i), np.full(m, N)]
        V += [np.ones(m), -np.ones(m), -(1 - xs[js] / xi)]
        r += m
        kk = np.arange(i + 1, N)
        if len(kk) == 0:
            continue
        J, K = np.meshgrid(js, kk, indexing="ij")
        J = J.ravel(); K = K.ravel()
        xj = xs[J]; xk = xs[K]
        pi = (xk * xk - xi * xi) / (xk * xk - xj * xj)     # weight on x_j
        mean = (pi * xj + (1 - pi) * xk) / xi
        m = len(J); rr = r + np.arange(m)
        R += [rr, rr, rr, rr]; C += [J, K, np.full(m, i), np.full(m, N)]
        V += [pi, 1 - pi, -np.ones(m), -(1 - mean)]
        r += m
    A = coo_matrix((np.concatenate(V), (np.concatenate(R), np.concatenate(C))), shape=(r, N + 1)).tocsr()
    bounds = [(-xs[i], None) for i in range(N)] + [(0, None)]
    bounds[i1] = (-1.0, -1.0)
    cost = np.zeros(N + 1); cost[N] = 1.0
    res = linprog(cost, A_ub=A, b_ub=np.zeros(r), bounds=bounds, method="highs")
    return res.x[N], r


if __name__ == "__main__":
    print(f"(B) q0 = {Q0:.12f},  c* = {CSTAR:.12f}")
    ing = check_ingredients()
    print(f"    sign changes of g(q) - 1/(1-q^2/2) on (0, 1.41) at q ~ {ing['roots']};"
          f" values at q = 1.151 and 1.152: {ing['gk_1151']:+.6f}, {ing['gk_1152']:+.6f};"
          f" 1/(1-1.152^2/2) = {1 / (1 - 1.152 ** 2 / 2):.5f}")
    print(f"(E) max |d(p/s)/dq - 1/s| = {ing['id_a']:.2e}, max |dr/ds - p/(2s)| = {ing['id_b']:.2e}"
          f" (central differences); min of (iv) on the grid = {ing['iv']:.2e}, min of (v) = {ing['v']:.2e};"
          f" direct test of (S) for U*, 40000 random laws: max lhs - rhs = {ing['S']:.2e}")
    worst, arg, termin = check_potential()
    print(f"(C) min over the grid of [tangent parabola - U] = {worst:.3e} at (Lam, a) = ({arg[0]:.4f}, {arg[1]:.4f});"
          f" min of U(x)+x = {termin:.3e}  (both must be >= 0 up to rounding)")
    print("(D) explicit strategy: ratio H2 / E_P sum h")
    for u, top in [(1.1, 1e6), (1.01, 1e6), (1.001, 1e3), (1.001, 1e6), (1.0001, 1e6)]:
        ratio, A, B, k = strategy_ratio(u, top)
        print(f"    u={u:<7} top={top:g}: levels={k:6d}  H2={A:.6e}  E_P sum h={B:.6e}  ratio={ratio:.5f}")
    try:
        import scipy  # noqa: F401
    except ImportError:
        print("(A) scipy not available: linear programme skipped")
        sys.exit(0)
    print("(A) linear programme on geometric grids: u, range, constraints, c_G")
    configs = [(1.5, 0.6, 60), (1.2, 0.6, 60), (1.1, 0.6, 60), (1.05, 0.6, 60), (1.035, 0.6, 60)]
    if len(sys.argv) > 1 and sys.argv[1] == "fine":
        configs += [(1.025, 0.6, 60), (1.018, 0.7, 60)]
    for u, lo, hi in configs:
        c, ncon = lp_value(u, lo, hi)
        print(f"    u={u:<6} x in [{lo},{hi}]  constraints={ncon:>8}  c_G={c:.5f}")
