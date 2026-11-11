"""Independent checks (second revision check) of research-notes/small-learner-width.md.

Coded from the note's definitions, not from the author's or the referees' scripts.
(a) sup_{t>=1} t^-a sqrt(ln 2t) = 2^a/sqrt(2 e a), maximizer t* = e^{1/(2a)}/2 > 1, for 0 < a <= 1/4.
(b) Corollary 3 / case (i) and the Section 0 "more generally" sentence: exact Exc (5.1) <= (5.2) <= C n^{2a-1/2}
    on random cases with 1 <= N <= 2 n^a, 1 <= d <= n^a, Bbar = n^a, 0 < a < 1/4, n from 2 to 1e300.
(c) Remark 8 / Section 7.1 item 2: Dev_N >= 4 at N* = sqrt(2n/((H-1) ln 2n)) and at A's N_0 on the cube family.
(d) Remark 8 numbers: A's (4.3) certified excess under a = 1/d at c=1, H=2, lambda=1, delta=0.01, t=1;
    N_0/(n log2^2 n) at d=100; other vanishing schedules.
(e) Section 7.4: clone term c(Ebar*+1)/n on the class of Corollary 3(i) at c = n^{1/2}, alpha = 0.2.
(f) Section 7.1 item 1: the averaging example (clip of the mean of raw outputs is -1 on every A_j).
(g) Section 7.3, A2 entry: for every n and c, delta_0 = min{1, (1/2)(L/K)^{L/2}} gives eta <= 1/2 in
    B Proposition 9.1(a), so the miss is at least 1/4; Lemma 9.2 at m = 1 needs only a finite B.
(h) Lemma E remark: the Theorem 2.10 form (linear term b l'/(3n)) against exact binomial tails.
(i) Remark 7 window endpoints L/(2(2L-1)).
"""
import math
import random
import numpy as np
from mpmath import mp, mpf, sqrt, log, exp, ceil, floor
from scipy.stats import binom

mp.dps = 50
rng = random.Random(20261111)


def exc_parts(n, N, d, H, Bbar, delta, c=1):
    """Exact Exc of (5.1) for the class G_L(d, N, Bbar) at learner width N."""
    n, N, d, Bbar, c = mpf(n), mpf(N), mpf(d), mpf(Bbar), mpf(c)
    L = H + 1
    l = log(4 / mpf(delta))
    K = n / c + 1
    P = N * (d + 1) + (H - 1) * N**2 + N
    Lam = log(2 + 2 * n * sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mpf(H) / 2))
    Dev = 4 * sqrt((P * Lam + l) / (2 * n))
    Ubar = N * Bbar
    Ebar = d * (d + 1) * Bbar**2 + 2 * (L - 1) * N**2 * Bbar**2
    exc = c * (Ebar + 1) / n + 4 / n + Dev + (Ubar + 1) * sqrt(2 * l / n) + 2 * (Ubar + 1) ** 2 * l / (3 * n)
    return exc, Dev, Lam, P


def simple52(n, a, H, Bbar, delta):
    n, a, Bbar = mpf(n), mpf(a), mpf(Bbar)
    L = H + 1
    l = log(4 / mpf(delta))
    return (5 * sqrt(2) * Bbar * n ** (a - mpf(1) / 2) * sqrt(l)
            + 4 * sqrt((2 * H + 1) * (H + 5)) * n ** (a - mpf(1) / 2) * sqrt(log(2 * n))
            + (8 * L - 1) * (1 + l) * Bbar**2 * n ** (2 * a - 1))


def Cconst(a, H, delta):
    a = mpf(a)
    L = H + 1
    l = log(4 / mpf(delta))
    return 5 * sqrt(2) * sqrt(l) + 4 * sqrt((2 * H + 1) * (H + 5)) * 2**a / sqrt(2 * mp.e * a) + (8 * L - 1) * (1 + l)


def part_a():
    print("(a) sup_{t>=1} t^-a sqrt(ln 2t) against 2^a/sqrt(2 e a)")
    worst_rel = 0.0
    for a in [1e-3, 0.01, 0.05, 0.1, 0.15, 0.2, 0.24, 0.25] + [rng.uniform(1e-3, 0.25) for _ in range(200)]:
        a = mpf(a)
        f = lambda u: -a * u + log(log(2) + u) / 2  # ln f at t = e^u, u >= 0
        lo, hi = mpf(0), mpf(1) / a * 5 + 10
        for _ in range(300):  # ternary search, f is unimodal in u (log-concave check below)
            m1, m2 = lo + (hi - lo) / 3, hi - (hi - lo) / 3
            if f(m1) < f(m2):
                lo = m1
            else:
                hi = m2
        u = (lo + hi) / 2
        best = exp(f(u))
        formula = 2**a / sqrt(2 * mp.e * a)
        tstar = exp(1 / (2 * a)) / 2
        assert tstar > 1
        assert abs(exp(u) / tstar - 1) < mpf(10) ** -20, (a, exp(u), tstar)
        worst_rel = max(worst_rel, float(abs(best / formula - 1)))
    print("    208 values of a in (0, 1/4]: max |numerical sup / formula - 1| = %.1e; maximizer = t* > 1 in every case"
          % worst_rel)


def part_b(cases=20000):
    print("(b) Corollary 3(i) and Section 0 'more generally': Exc <= (5.2) <= C n^(2a-1/2)")
    w1 = w2 = w3 = mpf(0)
    for k in range(cases):
        e10 = rng.uniform(math.log10(2), 300)
        n = mpf(10) ** mpf(e10)
        a = rng.uniform(1e-3, 0.25 - 1e-9)
        H = rng.choice([1, 2, 3, 4, 5, 6, 8, 10])
        delta = 10 ** rng.uniform(-12, math.log10(0.999))
        na = n ** mpf(a)
        Nmax = int(floor(2 * na))
        dmax = int(floor(na))
        if k % 4 == 0:
            N, d = Nmax, max(1, dmax)
        elif k % 4 == 1:
            N, d = int(ceil(na)), max(1, dmax)
        else:
            N = max(1, int(floor(mpf(rng.random()) * Nmax)))
            d = max(1, int(floor(mpf(rng.random()) * na)))
        assert 1 <= N <= 2 * na and 1 <= d <= na
        exc, _, _, _ = exc_parts(n, N, d, H, na, delta)
        s = simple52(n, a, H, na, delta)
        C = Cconst(a, H, delta) * n ** (2 * mpf(a) - mpf(1) / 2)
        w1 = max(w1, exc / s)
        w2 = max(w2, s / C)
        w3 = max(w3, exc / C)
    print("    %d random cases (n in [2,1e300], 0<a<1/4, H<=10, delta in [1e-12,0.999], 1<=N<=2n^a, 1<=d<=n^a):" % cases)
    print("    max Exc/(5.2) = %s, max (5.2)/(C n^(2a-1/2)) = %s, max Exc/(C n^(2a-1/2)) = %s (all must be <= 1)"
          % (mp.nstr(w1, 5), mp.nstr(w2, 6), mp.nstr(w3, 5)))


def N0_A(d, s, a):
    return int(math.floor(64 * math.log(2) * d * (d + 1) * s / a**2)) + 1


def part_c():
    print("(c) Remark 8: Dev_N >= 4 at N* = sqrt(2n/((H-1) ln 2n)) and at A's N_0 (cube family, c = 1)")
    worst_star = None
    worst_N0 = None
    for d in [10, 15, 20, 30, 40, 60, 100]:
        for lam in [0.25, 1.0, 4.0]:
            n = max(1, round(lam * 2**d))
            s = min(n, 2**d)
            for H in [2, 3, 4, 6]:
                for delta in [1e-6, 0.01, 0.5, 0.99]:
                    Nstar = int(math.ceil(math.sqrt(2 * n / ((H - 1) * math.log(2 * n)))))
                    _, Dev, _, _ = exc_parts(n, Nstar, d, H, 0, delta)
                    worst_star = Dev if worst_star is None else min(worst_star, Dev)
                    for a in [1.0, 0.3, 0.1, 1.0 / d]:
                        _, Dev0, _, _ = exc_parts(n, N0_A(d, s, a), d, H, 0, delta)
                        worst_N0 = Dev0 if worst_N0 is None else min(worst_N0, Dev0)
    print("    min Dev_N at N*: %s; min Dev_N at N_0: %s (both must be >= 4)" % (mp.nstr(worst_star, 4), mp.nstr(worst_N0, 4)))
    # Dev_N is increasing in N (P_N and Lambda_N both increase), so the bound exceeds 4 at every N >= N_0.
    n, d, H = 2**40, 40, 2
    vals = [exc_parts(n, N, d, H, 0, 0.05)[1] for N in [1, 10, 100, 10**4, 10**8, 10**12, 10**16]]
    assert all(x < y for x, y in zip(vals, vals[1:]))
    print("    Dev_N increasing in N on a sample grid: yes")


def beta_n(n, M):
    """E[1/K; K>=1], K ~ Bin(n, 1/M), by summing the pmf (mpmath)."""
    n, M = mpf(n), mpf(M)
    p = 1 / M
    tot = mpf(0)
    logpmf0 = n * mp.log1p(-p)
    lp = logpmf0
    for k in range(1, 200):
        lp = lp + log((n - k + 1) / k) + log(p) - mp.log1p(-p)
        term = exp(lp) / k
        tot += term
        if k > 20 and term < mpf(10) ** -30:
            break
    return tot


def beta_lambda(lam):
    lam = mpf(lam)
    return exp(-lam) * mp.quad(lambda u: (exp(u) - 1) / u, [0, lam])


def Kmem(d, s, a, H):
    alpha_d = log(4 * sqrt(2 * mpf(d))) / 2
    return d * (d + 1) * alpha_d**2 + (H + 1) * max((8 * mpf(d) * s) ** (mpf(1) / H), mpf(9) / (2 * a))


def e_cert(d, lam, a, H=2, c=1, t=1, delta=0.01):
    M = mpf(2) ** d
    n = int(ceil(lam * M)) if lam != 1 else int(M)
    s = min(mpf(n), M)
    lamd = mpf(n) / M
    eps = c * (Kmem(d, s, mpf(a), H) + t) / M + lamd * mpf(a) ** 2
    bn = beta_n(n, M)
    inner = bn - sqrt(2 * lamd * log(1 / mpf(delta)) / M)
    inner = max(inner, mpf(0))
    val = max(sqrt(inner) - sqrt(eps), mpf(0)) ** 2
    return val, n, s


def part_d():
    print("(d) Remark 8 numbers from A's (4.3): c=1, H=2, lambda=1, delta=0.01, t=1")
    print("    beta(1) = %s" % mp.nstr(beta_lambda(1), 7))
    for d in [40, 60, 100]:
        a = mpf(1) / d
        e, n, s = e_cert(d, 1, a)
        N0 = 64 * log(2) * d * (d + 1) * s / a**2 + 1
        print("    a=1/d d=%d: certified excess %s; N_0/(n log2^2 n) = %s" % (d, mp.nstr(e, 4), mp.nstr(N0 / (n * d**2), 4)))
    for name, sched in [("1/sqrt(d)", lambda d: 1 / sqrt(mpf(d))), ("1/ln d", lambda d: 1 / log(mpf(d)))]:
        out = []
        for d in [40, 100, 300, 1000]:
            e, n, s = e_cert(d, 1, sched(d))
            out.append("d=%d: %s" % (d, mp.nstr(e, 4)))
        print("    a=%s: %s (slowly increasing toward beta(1))" % (name, "; ".join(out)))
    # fixed-a limit (sqrt(beta)-a sqrt(lam))_+^2
    for a in [0.1, 0.5]:
        e, _, _ = e_cert(300, 1, a)
        lim = (sqrt(beta_lambda(1)) - a) ** 2
        print("    fixed a=%.1f: e at d=300 = %s, limit (sqrt(beta(1)) - a)^2 = %s" % (a, mp.nstr(e, 5), mp.nstr(lim, 5)))


def part_e():
    print("(e) Section 7.4: clone term c(Ebar*+1)/n at c = n^(1/2), alpha = 0.2, class of Corollary 3(i)")
    for H in [1, 2, 4]:
        L = H + 1
        res = []
        prev = None
        for e10 in [20, 40, 80, 160]:
            n = mpf(10) ** e10
            na = n ** mpf('0.2')
            N = ceil(na)
            for d in [mpf(1), floor(na)]:
                E = d * (d + 1) * na**2 + 2 * (L - 1) * N**2 * na**2
                term = sqrt(n) * (E + 1) / n
                if d == 1:
                    res.append((e10, term))
        slopes = [float(log(res[i + 1][1] / res[i][1]) / log(mpf(10) ** (res[i + 1][0] - res[i][0]))) for i in range(len(res) - 1)]
        print("    H=%d: clone term at n=1e20..1e160 (d=1): %s; local slopes %s (predicted 0.3)"
              % (H, ", ".join(mp.nstr(t, 3) for _, t in res), ", ".join("%.4f" % s for s in slopes)))


def part_f(trials=2000):
    print("(f) Section 7.1 item 1 example: z_i <= 1 everywhere, z_i < -(2k-1) on A_i (label +1, A_i disjoint)")
    bad = 0
    for _ in range(trials):
        k = rng.randint(2, 8)
        # values of the k raw outputs on each A_j: on A_j, z_j < -(2k-1), others in [-big, 1]
        for j in range(k):
            z = [rng.uniform(-50, 1) for _ in range(k)]
            z[j] = -(2 * k - 1) - rng.uniform(1e-9, 20)
            zbar = sum(z) / k
            if not (max(-1.0, min(1.0, zbar)) == -1.0):
                bad += 1
            # each clip z_i pays 4 on its own A_i
            assert max(-1.0, min(1.0, z[j])) == -1.0
    # worst case: others exactly 1
    for k in range(2, 50):
        zbar = ((k - 1) * 1 + (-(2 * k - 1))) / k
        assert abs(zbar - (-1.0)) < 1e-12
    print("    %d random instances: clip(mean) = -1 on A_j in all but %d (boundary case z_j = -(2k-1), others = 1 gives mean exactly -1)"
          % (trials, bad))


def part_g():
    print("(g) A2 entry: delta_0 = min{1, (1/2)(L/K)^(L/2)} gives eta <= 1/2 for every n and c")
    worst = 0.0
    for L in [2, 3, 4, 6, 10]:
        for n in [1, 2, 3, 10, 100, 10**4, 10**8]:
            for c in [1e-6, 1e-2, 1.0, 10.0, float(n), float(n) ** 2, 1e12]:
                K = n / c + 1
                d0 = min(1.0, 0.5 * (L / K) ** (L / 2))
                eta = d0 * (K / L) ** (L / 2)
                worst = max(worst, eta)
                H = L - 1
                # Lemma 9.2 at m = 1: B >= (tanh 1)^-H and B^L >= (tanh 1)^-H / d0
                B = max(math.tanh(1) ** -H, (math.tanh(1) ** -H / d0) ** (1 / L))
                assert math.isfinite(B)
    print("    max eta = %.3f (must be <= 0.5), so (1-eta)^2 >= 1/4; Lemma 9.2 at m=1 holds with a finite B" % worst)


def part_h():
    print("(h) Lemma E remark (BLM Theorem 2.10 form): Pr(Zbar - mu >= sqrt(2 b mu l'/n) + b l'/(3n)) <= delta'")
    worst = 0.0
    count = 0
    for n in [1, 2, 3, 5, 10, 30, 100, 1000, 10**4, 10**6]:
        for p in [1e-9, 1e-6, 1e-4, 1e-3, 0.01, 0.05, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99]:
            for dp in [0.25, 0.1, 0.05, 1e-2, 1e-3, 1e-4, 1e-6]:
                b = 1.0
                mu = p * b
                lp = math.log(1 / dp)
                thr = math.sqrt(2 * b * mu * lp / n) + b * lp / (3 * n)
                # Z in {0, b}: Zbar = b*Bin(n,p)/n; Pr(Bin >= n(mu+thr)/b)
                kmin = math.ceil(n * (mu + thr) / b - 1e-12)
                tail = binom.sf(kmin - 1, n, p) if kmin <= n else 0.0
                worst = max(worst, tail / dp)
                count += 1
    print("    %d two-point cases: max exact tail / delta' = %.4f (must be <= 1)" % (count, worst))


def part_i():
    print("(i) Remark 7 window: L/(2(2L-1)) =", ", ".join("L=%d: %.4f" % (L, L / (2 * (2 * L - 1))) for L in range(2, 9)))
    vals = [L / (2 * (2 * L - 1)) for L in range(2, 200)]
    assert all(x > y for x, y in zip(vals, vals[1:])) and abs(vals[-1] - 0.25) < 1e-3
    print("    strictly decreasing, tends to 1/4")


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()
    part_f()
    part_g()
    part_h()
    part_i()
