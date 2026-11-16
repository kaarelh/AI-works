#!/usr/bin/env python3
"""Checks made by the editor of proofs/hellinger-runs.md for the statements that were added or changed
after the two verification reports.  Every expectation is an exact finite sum evaluated in floating point
(no sampling of data sets), except where "random instances" are drawn to choose the instances themselves.

 (E1) Lemma 2.10: the one-step inequality for U(x) = (g/2) (m - x)_+^2 on extreme laws; the two pointwise
      identities; the three statements (a), (b), (c) on random trees with exact zeros.
 (E2) Theorem 2.7: enclosure of q0 and c* by interval arithmetic; the function r(q) is decreasing (one root).
 (E3) Theorem 3.1(d): KL(Q_P || Q_M) = E_{Q_M} sum_j KL(P || M)(x_j) when the inputs do not depend on the answers.
 (E4) Theorem 5.7: the oracle inequality in expectation for the posterior with weights w^lambda and for the
      lambda-MAP, by enumeration of all data sets.
 (E5) Example 4.6 for the averaged law (1/N) sum_t Q_{M_t}, by enumeration of all sequences of top-level inputs.
 (E6) Example 4.8: TV of the two imitators, p*om and p*om*(2 - om).
 (E7) Theorem 4.2(b), last statement: E Qhat(G) <= ln(1/w(nu*))/N + KL(Q*||Q_nu*) when Q*(G) = 0.
 (E8) Protocol R, exact, on small adaptive scaffolds: R1 and Theorem 3.1(a), (b), (c) with the final constants.
 (E9) Example 4.8, second half (B alternatives, K = 1): the excess summed over every t, for B = 4 and 16.

Run:  python3 hellinger-runs_editor_checks.py      (needs numpy, mpmath; about one minute)
"""
import itertools
import math

import mpmath as mp
import numpy as np

LN2 = math.log(2.0)
rng = np.random.default_rng(20261116)


# ----------------------------------------------------------------------------------------------------
# trees: a sequence of kernels p_i(.|history), q_i(.|history), every history with its own kernels
# ----------------------------------------------------------------------------------------------------
def random_kernel(rows, b, zero_prob):
    k = rng.gamma(rng.choice([0.2, 1.0, 5.0]), size=(rows, b)) + 1e-300
    if zero_prob > 0:
        mask = rng.random((rows, b)) < zero_prob
        mask[np.arange(rows), rng.integers(0, b, rows)] = False      # keep one positive entry per row
        k = np.where(mask, 0.0, k)
    return k / k.sum(1, keepdims=True)


def tree_quantities(ps, qs):
    """leaves' probabilities under P and Q, and sigma = E_P sum_i H^2(p_i, q_i)(history)."""
    P = np.ones(1)
    Q = np.ones(1)
    sigma = 0.0
    for p, q in zip(ps, qs):
        h = 0.5 * ((np.sqrt(p) - np.sqrt(q)) ** 2).sum(1)
        sigma += float((P * h).sum())
        P = (P[:, None] * p).reshape(-1)
        Q = (Q[:, None] * q).reshape(-1)
    return P, Q, sigma


def check_E1():
    print("(E1) Lemma 2.10")
    # one-step inequality on the extreme laws: point masses at r <= 1 and two-point laws with E r^2 = 1
    worst = -1e9
    for _ in range(400):
        m = float(rng.uniform(0.05, 4.0))
        g = float(rng.uniform(0.1, 5.0))
        U = lambda x: 0.5 * g * np.maximum(m - x, 0.0) ** 2
        for Lam in np.concatenate([np.linspace(0, 3 * m, 61), [m, m * (1 + 1e-9), m * (1 - 1e-9)]]):
            r = np.linspace(0, 1, 201)                                           # point masses
            worst = max(worst, float(np.max(U(Lam * r) - U(Lam) - g * m * m * (1 - r))))
            a = np.linspace(0, 1, 81)[:, None]                                   # two-point laws: a < 1 < b
            b = np.concatenate([np.linspace(1.0, 3.0, 41), np.geomspace(3.0, 1e4, 40)])[None, :]
            with np.errstate(divide="ignore", invalid="ignore"):
                wb = np.where(b > a, (1 - a * a) / (b * b - a * a), 0.0)         # weight of b; E r^2 = 1
            Er = (1 - wb) * a + wb * b
            val = (1 - wb) * U(Lam * a) + wb * U(Lam * b) - U(Lam) - g * m * m * (1 - Er)
            worst = max(worst, float(np.max(val)))
    print(f"     one step, max of E U(Lam r) - U(Lam) - g m^2 (1 - E r) over extreme laws: {worst:.3e}  (must be <= 0 up to rounding)")
    # pointwise identities
    x = np.linspace(0, 1, 100001)
    w1 = 0.0
    w2 = 0.0
    for eta in [0.1, 0.5, 1.0, 3.0, 50.0]:
        g = 2 * (1 + eta) / eta
        w1 = max(w1, float(np.max(np.abs(0.5 * g * (1 - x) ** 2 - (1 - (1 + eta) * x * x) - (1 - (1 + eta) * x) ** 2 / eta))))
    for m in [1.001, 1.1, 1.5, 2.0, 7.0]:
        g = 2 / (m * m - 1)
        w2 = max(w2, float(np.max(np.abs(0.5 * g * (m - x) ** 2 - (1 - x * x) - (1 - m * x) ** 2 / (m * m - 1)))))
    print(f"     identities U - (1-(1+eta)x^2) = (1-(1+eta)x)^2/eta and U - (1-x^2) = (1-mx)^2/(m^2-1): max error {w1:.1e}, {w2:.1e}")
    # the optimisation in (c)
    w3 = 0.0
    for sg in [1e-6, 1e-3, 0.01, 0.1, 0.25, 1.0]:
        v = sg + math.sqrt(sg * sg + 2 * sg)
        vv = np.geomspace(1e-6, 1e3, 200001)
        F = (vv * vv + 2 * sg * (1 + vv) ** 2) / (vv * (vv + 2))
        w3 = max(w3, abs(float(F.min()) - v) / v)
        assert (v * v + 2 * sg * (1 + v) ** 2) / (v * (v + 2)) - v < 1e-12 * max(1, v)
    print(f"     min over v of [v^2 + 2 sigma (1+v)^2]/(v(v+2)) equals sigma + sqrt(sigma^2 + 2 sigma): relative error on a grid {w3:.1e}")
    # statements on random trees
    ra = {0.25: 0.0, 1.0: 0.0, 4.0: 0.0, 100.0: 0.0}
    rb = 0.0
    rc = 0.0
    rh = 0.0
    ntrees = 0
    for _ in range(6000):
        b = int(rng.choice([2, 3]))
        depth = int(rng.integers(1, 6 if b == 2 else 5))
        zp = float(rng.choice([0.0, 0.0, 0.2, 0.5]))
        scale = float(rng.choice([1.0, 0.3, 0.05]))
        ps, qs = [], []
        for i in range(depth):
            p = random_kernel(b ** i, b, zp)
            q = random_kernel(b ** i, b, zp)
            q = (1 - scale) * p + scale * q                # laws at different distances
            if zp > 0:
                q = np.where(rng.random(q.shape) < 0.15, 0.0, q)
                q = np.where(q.sum(1, keepdims=True) > 0, q, p)
                q = q / q.sum(1, keepdims=True)
            ps.append(p)
            qs.append(q)
        P, Q, sigma = tree_quantities(ps, qs)
        if sigma < 1e-12:
            continue
        ntrees += 1
        for eta in ra:
            ra[eta] = max(ra[eta], float(np.maximum(P - (1 + eta) * Q, 0).sum()) / (2 * (1 + 1 / eta) * sigma))
        rb = max(rb, float(P[Q == 0].sum()) / (2 * sigma))
        tv = 0.5 * float(np.abs(P - Q).sum())
        rc = max(rc, tv / min(1.0, sigma + math.sqrt(sigma * sigma + 2 * sigma)))
        rh = max(rh, (1 - float(np.sqrt(P * Q).sum())) / sigma)
    print(f"     {ntrees} random trees (depth <= 5 binary, <= 4 ternary, exact zeros): largest ratio of the two sides")
    print("       (a) sup_G [P(G) - (1+eta) Q(G)] / [2(1+1/eta) sigma]: " + ", ".join(f"eta={e:g}: {v:.4f}" for e, v in ra.items()))
    print(f"       (b) P(q = 0) / (2 sigma): {rb:.4f}     (c) TV / min(1, sigma + sqrt(sigma^2 + 2 sigma)): {rc:.4f}     (all must be <= 1)")
    print(f"       for comparison, largest H^2 / sigma: {rh:.4f}  (Theorem 2.1(c): <= 4; Theorem 2.7: <= c*)")
    # the constants of a single call
    a = 1e-8
    eta = 1.0
    p = np.array([1 - a, a])
    q = np.array([1 - a / (1 + eta) ** 2, a / (1 + eta) ** 2])
    h = 0.5 * ((np.sqrt(p) - np.sqrt(q)) ** 2).sum()
    print(f"       one call, p = (1-a, a), q = (1 - a/4, a/4), a = 1e-8: [P(G) - 2 Q(G)] / h = {(p[1] - 2 * q[1]) / h:.6f}  (constant 4 = 2(1+1/eta) at eta = 1)")
    t = 1e-4
    p = np.array([0.5 + t, 0.5 - t])
    q = p[::-1]
    h = 0.5 * ((np.sqrt(p) - np.sqrt(q)) ** 2).sum()
    print(f"       one call, p = (1/2+t, 1/2-t), q reversed, t = 1e-4: TV / sqrt(2h) = {2 * t / math.sqrt(2 * h):.6f}")


# ----------------------------------------------------------------------------------------------------
def check_E2():
    print("(E2) Theorem 2.7: the root q0 and the constant c*")
    mp.mp.dps = 40
    g = lambda q: 1 + q * mp.exp(q * q / 4) * (1 / mp.sqrt(2) + mp.sqrt(mp.pi) / 2 * mp.erf(q / 2))
    k = lambda q: 1 / (1 - q * q / 2)
    q0 = mp.findroot(lambda q: g(q) - k(q), mp.mpf("1.15"))
    print("     q0 =", mp.nstr(q0, 30), "  c* =", mp.nstr(k(q0), 30))
    # interval arithmetic: erf by its power series with a rigorous tail bound
    iv = mp.iv
    iv.dps = 40

    def erf_iv(x):                       # x an interval in [0, 1]
        s = iv.mpf(0)
        term = x
        nmax = 60
        for n in range(nmax):
            s += term / (2 * n + 1)
            term = -term * x * x / (n + 1)
        tail = abs(term) / (2 * nmax + 1)          # alternating series with decreasing terms on [0, 1]
        return (s + iv.mpf([-tail.b, tail.b])) * 2 / iv.sqrt(iv.pi)

    def gk_iv(qs):
        q = iv.mpf(qs)
        gg = 1 + q * iv.exp(q * q / 4) * (1 / iv.sqrt(2) + iv.sqrt(iv.pi) / 2 * erf_iv(q / 2))
        return gg - 1 / (1 - q * q / 2), 1 / (1 - q * q / 2)

    lo, klo = gk_iv("1.15120357")
    hi, khi = gk_iv("1.15120358")
    f = lambda z: mp.nstr(mp.mpf(z), 12)
    print(f"     g - k at q = 1.15120357 lies in [{f(lo.a.mid)}, {f(lo.b.mid)}] (positive);  at q = 1.15120358 in [{f(hi.a.mid)}, {f(hi.b.mid)}] (negative)")
    print(f"     hence 1.15120357 < q0 < 1.15120358 and {f(klo.a.mid)} < c* < {f(khi.b.mid)}")
    # r(q) = (p - q)/2 with s = 1/g, p = 2(1-s)/q is strictly decreasing: grid check of the sign of r and of its monotonicity
    mp.mp.dps = 30
    qs = [mp.mpf(i) / 1000 for i in range(1, 3001)]
    rv = [((2 * (1 - 1 / g(q)) / q) - q) / 2 for q in qs]
    dec = all(rv[i + 1] < rv[i] for i in range(len(rv) - 1))
    changes = [float(qs[i]) for i in range(len(rv) - 1) if (rv[i] > 0) != (rv[i + 1] > 0)]
    print(f"     r(q) on the grid q = 0.001 (0.001) 3: strictly decreasing: {dec}; sign changes between q = {changes} and the next grid point; r(0.001) = {mp.nstr(rv[0], 8)} (1/sqrt 2 = 0.70710678)")
    print("     c*/2 =", mp.nstr(k(q0) / 2, 8), "  2 c* =", mp.nstr(2 * k(q0), 8), "  sqrt(2 c*) =", mp.nstr(mp.sqrt(2 * k(q0)), 8))


# ----------------------------------------------------------------------------------------------------
def check_E3():
    print("(E3) Theorem 3.1(d): inputs that do not depend on the answers")
    worst = 0.0
    for _ in range(300):
        nx, ny, L, nom = 3, 3, 3, 4
        mu0 = rng.dirichlet(np.ones(nom))
        length = rng.integers(0, L + 1, nom)                      # number of calls, a function of omega0
        inputs = rng.integers(0, nx, (nom, L))                    # inputs, functions of omega0
        P = rng.dirichlet(np.ones(ny) * 0.7, nx)
        M = rng.dirichlet(np.ones(ny) * 0.7, nx)
        kl_run = 0.0
        e_sum = 0.0
        for om in range(nom):
            xs = inputs[om, :length[om]]
            # KL between the two product laws given omega0, by enumeration of the answers
            for ys in itertools.product(range(ny), repeat=len(xs)):
                qp = float(np.prod([P[x, y] for x, y in zip(xs, ys)]))
                qm = float(np.prod([M[x, y] for x, y in zip(xs, ys)]))
                kl_run += mu0[om] * qp * math.log(qp / qm)
            e_sum += mu0[om] * sum(float((P[x] * np.log(P[x] / M[x])).sum()) for x in xs)
        worst = max(worst, abs(kl_run - e_sum))
    print(f"     300 random instances: max |KL(Q_P||Q_M) - E_(Q_M) sum_j KL(P||M)(x_j)| = {worst:.2e}")


# ----------------------------------------------------------------------------------------------------
def check_E4():
    print("(E4) Theorem 5.7: oracle inequality in expectation for the weights w^lambda (posterior and lambda-MAP)")
    worst_post = 0.0
    worst_map = 0.0
    count = 0
    for _ in range(1500):
        ny = int(rng.integers(2, 4))                    # a run is one answer from a set of ny answers
        nh = int(rng.integers(2, 6))
        N = int(rng.integers(1, 7 if ny == 2 else 5))
        lam = float(rng.choice([1.0, 1.05, 1.5, 2.0, 3.0, 5.0]))
        w = rng.dirichlet(np.ones(nh)) * float(rng.uniform(0.3, 1.0))        # Kraft weights, sum <= 1
        Qs = rng.dirichlet(np.ones(ny) * float(rng.choice([0.3, 1.0, 4.0])), nh)
        if rng.random() < 0.4:                                               # hypotheses with zeros
            z = rng.random(Qs.shape) < 0.3
            z[np.arange(nh), rng.integers(0, ny, nh)] = False
            Qs = np.where(z, 0.0, Qs)
            Qs = Qs / Qs.sum(1, keepdims=True)
        inside = rng.random() < 0.5
        Qstar = Qs[0].copy() if inside else rng.dirichlet(np.ones(ny))
        with np.errstate(divide="ignore", invalid="ignore"):
            KLs = np.array([float(np.sum(np.where(Qstar > 0, Qstar * (np.log(Qstar) - np.log(Qs[i])), 0.0))) for i in range(nh)])
        rhs = float(np.min(np.log(1 / w) / N + KLs / lam))
        if not math.isfinite(rhs):
            continue
        al = 1.0 / lam
        with np.errstate(divide="ignore", invalid="ignore"):
            A = np.array([float(np.sum(np.where(Qstar > 0, Qstar ** (1 - al) * Qs[i] ** al, 0.0))) for i in range(nh)])
            negl = np.where(A > 0, -np.log(np.where(A > 0, A, 1.0)), np.inf)
        e_post = 0.0
        e_map = 0.0
        for data in itertools.product(range(ny), repeat=N):
            pr = float(np.prod(Qstar[list(data)]))
            if pr == 0:
                continue
            lik = np.prod(Qs[:, list(data)], axis=1)
            score = w ** lam * lik
            post = score / score.sum()
            e_post += pr * float(np.sum(np.where(post > 0, post * np.where(np.isfinite(negl), negl, 0.0), 0.0)))
            best = np.flatnonzero(score >= score.max() * (1 - 1e-12))
            e_map += pr * float(np.max(negl[best]))                          # the worst tie-breaking
        count += 1
        worst_post = max(worst_post, e_post / rhs)
        worst_map = max(worst_map, e_map / rhs)
    print(f"     {count} random instances (human inside or outside, lambda from 1 to 5, N <= 6, all data sets enumerated):")
    print(f"     largest E[posterior mean of -ln A_(1/lambda)] / rhs = {worst_post:.4f};  largest E[-ln A_(1/lambda)(MAP)] / rhs = {worst_map:.4f}   (must be <= 1)")


# ----------------------------------------------------------------------------------------------------
def check_E5():
    print("(E5) Example 4.6 for the averaged law (1/N) sum_t Q_{M_t}, B = 2N, exact enumeration of the top-level inputs")
    print("     N  L | E KL(Q_f || average)   L/(8N)   ln2/N | E TV(average, Q_f)   (1/2)(1 - exp(-L/(4N)))   sqrt(ln2/(2N))")
    ok = True
    for N in [1, 2, 3, 4]:
        B = 2 * N
        for L in [1, 3, 6, 10, 40]:
            ekl = 0.0
            etv = 0.0
            for zs in itertools.product(range(B), repeat=N):
                # omega_t = 1/(2B - v_t), v_t = number of distinct values among the first t-1 inputs
                zero_prob = np.zeros(B)          # probability of the run "all zeros" given z, under the average law
                for t in range(1, N + 1):
                    seen = set(zs[:t - 1])
                    om = 1.0 / (2 * B - len(seen))
                    for z in range(B):
                        zero_prob[z] += (1.0 if z in seen else (1 - om) ** L) / N
                ekl += float(np.mean(-np.log(zero_prob))) / B ** N
                etv += float(np.mean(1 - zero_prob)) / B ** N
            lowkl = L / (8 * N)
            lowtv = 0.5 * (1 - math.exp(-L / (4 * N)))
            ok = ok and ekl >= lowkl - 1e-12 and etv >= lowtv - 1e-12
            print(f"     {N}  {L:2d} | {ekl:.5f}   {lowkl:.5f}   {LN2 / N:.5f} | {etv:.5f}   {lowtv:.5f}   {math.sqrt(LN2 / (2 * N)):.5f}")
    print("     both lower bounds hold in every row:", ok)


# ----------------------------------------------------------------------------------------------------
def check_E6():
    print("(E6) Example 4.8: total variation of the two imitators while the alternative is alive")
    worst = 0.0
    for _ in range(1000):
        p = float(rng.uniform(0.001, 0.999))
        om = float(rng.uniform(0.0, 1.0))
        QP = np.array([1 - p, p, 0.0])                                   # runs (0), (1,1), (1,0)
        Qhat = (1 - om) * QP + om * np.array([1.0, 0.0, 0.0])            # one draw per run
        m0 = p * (1 - om)
        QM = np.array([1 - m0, m0 * (1 - om), m0 * om])                  # per-call mixture
        worst = max(worst, abs(0.5 * np.abs(Qhat - QP).sum() - p * om), abs(0.5 * np.abs(QM - QP).sum() - p * om * (2 - om)))
    print(f"     max error of TV(Qhat_t, Q_P) = p om and TV(Q_(M_t), Q_P) = p om (2 - om) over 1000 random (p, om): {worst:.1e}")


# ----------------------------------------------------------------------------------------------------
def check_E7():
    print("(E7) Theorem 4.2(b): events of probability zero under Q*")
    worst = 0.0
    cnt = 0
    for _ in range(800):
        ny = 3
        nh = int(rng.integers(2, 5))
        N = int(rng.integers(1, 6))
        w = rng.dirichlet(np.ones(nh)) * float(rng.uniform(0.3, 1.0))
        Qs = rng.dirichlet(np.ones(ny), nh)
        Qstar = rng.dirichlet(np.ones(ny))
        dead = int(rng.integers(0, ny))
        Qstar[dead] = 0.0
        Qstar /= Qstar.sum()                               # G := {dead}, Q*(G) = 0
        if rng.random() < 0.5:
            Qs[0] = Qstar
        with np.errstate(divide="ignore", invalid="ignore"):
            KLs = np.array([float(np.sum(np.where(Qstar > 0, Qstar * (np.log(Qstar) - np.log(Qs[i])), 0.0))) for i in range(nh)])
        rate = float(np.min(np.log(1 / w) / N + KLs))
        val = 0.0
        for t in range(1, N + 1):                          # Qhat_t(G) averaged over the data before round t
            for data in itertools.product(range(ny), repeat=t - 1):
                pr = float(np.prod(Qstar[list(data)])) if data else 1.0
                if pr == 0:
                    continue
                lik = np.prod(Qs[:, list(data)], axis=1) if data else np.ones(nh)
                post = w * lik / (w * lik).sum()
                val += pr * float(post @ Qs[:, dead]) / N
        cnt += 1
        worst = max(worst, val / rate)
    print(f"     {cnt} random instances: largest E Qhat(G) / [min_nu ln(1/w(nu))/N + KL(Q*||Q_nu)] = {worst:.4f}  (must be <= 1)")


# ----------------------------------------------------------------------------------------------------
# Protocol R, exact
# ----------------------------------------------------------------------------------------------------
class Scaffold:
    """Binary answers, horizon 2 or 3, inputs = nodes of a tree of histories (adaptive), optional stops."""

    def __init__(self, L, nx, adaptive=True, stops=True):
        self.L = L
        self.runs = []          # list of runs: tuple of (input, answer)
        self.nx = nx

        def grow(prefix):
            j = len(prefix)
            if j == L or (stops and j >= 1 and rng.random() < 0.25):
                self.runs.append(tuple(prefix))
                return
            x = int(rng.integers(0, nx)) if adaptive else self.fixed[j]
            for y in (0, 1):
                grow(prefix + [(x, y)])

        self.fixed = [int(rng.integers(0, nx)) for _ in range(L)]
        grow([])

    def run_law(self, S):       # S[x, y]: sampler
        return np.array([float(np.prod([S[x, y] for x, y in run])) if run else 1.0 for run in self.runs])


def protocol_R_exact(sc, hyps, w, n):
    """Returns sum_t E[E_{Q_M(t)} sum_j KL(P||M(t))(x_j)], E H^2, E TV, E of sup_G [Q_M(G) - (1+eta) Q_P(G)] for eta = 1/4, 1, 4,
    E Q_M(zero set of Q_P), all for the deployed M^(T) (expectation over data and T).  hyps[0] is the human."""
    P = hyps[0]
    QP = sc.run_law(P)
    acc = dict(kl=0.0, h2=0.0, tv=0.0, ev={0.25: 0.0, 1.0: 0.0, 4.0: 0.0}, zero=0.0, tvjensen=0.0)

    def rec(t, post, prob):
        M = np.einsum("h,hxy->xy", post, hyps)
        QM = sc.run_law(M)
        # statistics of the mixture of round t (deployed with probability 1/n)
        with np.errstate(divide="ignore", invalid="ignore"):
            klx = np.array([float(np.sum(np.where(P[x] > 0, P[x] * (np.log(P[x]) - np.log(M[x])), 0.0))) for x in range(sc.nx)])
        kl_sum = sum(QM[i] * sum(klx[x] for x, _ in run) for i, run in enumerate(sc.runs))
        acc["kl"] += prob * kl_sum
        acc["h2"] += prob * (1 - float(np.sqrt(QM * QP).sum())) / n
        acc["tv"] += prob * 0.5 * float(np.abs(QM - QP).sum()) / n
        for eta in acc["ev"]:
            acc["ev"][eta] += prob * float(np.maximum(QM - (1 + eta) * QP, 0).sum()) / n
        acc["zero"] += prob * float(QM[QP == 0].sum()) / n
        if t == n:
            return
        # the round: run of M, J uniform on 1..L, the human's answer at call J
        for i, run in enumerate(sc.runs):
            if QM[i] == 0:
                continue
            for J in range(1, sc.L + 1):
                pj = prob * QM[i] / sc.L
                if J > len(run):
                    rec(t + 1, post, pj)
                    continue
                x = run[J - 1][0]
                for y in (0, 1):
                    if P[x, y] == 0:
                        continue
                    newpost = post * hyps[:, x, y]
                    rec(t + 1, newpost / newpost.sum(), pj * P[x, y])

    rec(1, w / w.sum(), 1.0)
    return acc


def check_E8():
    print("(E8) Protocol R, exact (expectation over all data sets and T): ratios to the bounds of R1 and Theorem 3.1")
    worst = dict(r1=0.0, a=0.0, b=0.0, bsmall=0.0, c={0.25: 0.0, 1.0: 0.0, 4.0: 0.0}, zero=0.0)
    rows = 0
    for trial in range(120):
        L = int(rng.choice([2, 2, 3]))
        n = int(rng.choice([1, 2, 3])) if L == 3 else int(rng.choice([1, 2, 3, 4]))
        nx = int(rng.integers(1, 4))
        sc = Scaffold(L, nx, adaptive=bool(rng.random() < 0.8), stops=bool(rng.random() < 0.5))
        nh = int(rng.integers(2, 5))
        kind = rng.choice(["stoch", "zeros", "funcs"])
        hyps = rng.dirichlet(np.ones(2) * float(rng.choice([0.3, 1.0, 3.0])), (nh, nx))
        if kind == "zeros":
            hyps = np.where(rng.random(hyps.shape) < 0.3, 0.0, hyps)
            hyps = np.where(hyps.sum(2, keepdims=True) > 0, hyps, 0.5)
            hyps = hyps / hyps.sum(2, keepdims=True)
        if kind == "funcs":
            hyps = (hyps > 0.5).astype(float)
            hyps[:, :, 1] = 1 - hyps[:, :, 0]
        w = rng.dirichlet(np.ones(nh) * float(rng.choice([0.3, 1.0])))
        if rng.random() < 0.5:
            w0 = float(rng.choice([0.5, 0.9, 0.99]))
            w = np.concatenate([[w0], (1 - w0) * w[1:] / max(w[1:].sum(), 1e-300)])
        K = math.log2(1 / w[0])
        acc = protocol_R_exact(sc, hyps, w, n)
        s = L * K * LN2 / (2 * n)
        rows += 1
        if K * LN2 > 1e-9:
            worst["r1"] = max(worst["r1"], acc["kl"] / (L * K * LN2))
            worst["a"] = max(worst["a"], acc["h2"] / (4 * s))
            worst["b"] = max(worst["b"], acc["tv"] / min(1.0, s + math.sqrt(s * s + 2 * s)))
            if s <= 0.125:
                worst["bsmall"] = max(worst["bsmall"], acc["tv"] / (s + math.sqrt(s * s + 2 * s)))
            for eta in worst["c"]:
                worst["c"][eta] = max(worst["c"][eta], acc["ev"][eta] / ((1 + 1 / eta) * 2 * s))
            worst["zero"] = max(worst["zero"], acc["zero"] / (2 * s))
    print(f"     {rows} random instances (L = 2 or 3, adaptive scaffolds with stops, classes of 2 to 4 samplers, n <= 4):")
    print(f"     R1: sum_t E[E sum_j KL] / (L K ln2) <= {worst['r1']:.4f}")
    print(f"     3.1(a): E H^2 / (2 L K ln2 / n) <= {worst['a']:.4f}")
    print(f"     3.1(b): E TV / min(1, s + sqrt(s^2 + 2s)), s = L K ln2/(2n): <= {worst['b']:.4f}  (on the instances with s <= 1/8: <= {worst['bsmall']:.4f})")
    print("     3.1(c): E sup_G [Q_M(G) - (1+eta) Q_P(G)] / ((1 + 1/eta) L K ln2 / n): " + ", ".join(f"eta={e:g}: {v:.4f}" for e, v in worst["c"].items()))
    print(f"     3.1(c): E Q_M(runs of Q_P-probability zero) / (L K ln2 / n) <= {worst['zero']:.4f}     (every ratio must be <= 1)")


# ----------------------------------------------------------------------------------------------------
def check_E9():
    print("(E9) Example 4.8, second half: excess of the frozen per-call mixture over the draw per run, summed over every t <= cut-off")

    def excess(B, p, tmax):
        r = (1 - p + p / B) / (1 - p)                       # likelihood ratio of a surviving alternative per run that answered 0
        occ = [[0.0] * (B + 1) for _ in range(tmax + 1)]    # occ[b][v]: v distinct branches among b uniform draws
        occ[0][0] = 1.0
        for b in range(1, tmax + 1):
            for v in range(B + 1):
                occ[b][v] = occ[b - 1][v] * v / B + (occ[b - 1][v - 1] * (B - v + 1) / B if v >= 1 else 0.0)
        total = 0.0
        for t in range(1, tmax + 1):
            nprev = t - 1
            for b in range(nprev + 1):
                pb = math.comb(nprev, b) * p ** b * (1 - p) ** (nprev - b)
                lr = r ** (nprev - b)
                for v in range(min(b, B) + 1):
                    alive = B - v
                    if alive == 0 or occ[b][v] == 0.0:
                        continue
                    om = lr / (B + alive * lr)              # posterior weight of each surviving alternative
                    total += pb * occ[b][v] * alive * (p / B) * (-math.log1p(-om))
        return total

    for B, tmax in [(4, 76), (16, 542)]:
        print(f"     B = {B:3d}, t <= {tmax}: {excess(B, 0.5, tmax):.4f}   (first verifier: {'1.7855' if B == 4 else '2.4939'};  L K ln2 = {2 * LN2:.4f})")


if __name__ == "__main__":
    check_E1()
    check_E2()
    check_E3()
    check_E4()
    check_E5()
    check_E6()
    check_E7()
    check_E8()
    check_E9()
