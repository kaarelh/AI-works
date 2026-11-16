#!/usr/bin/env python3
"""Exact small checks for rehearsal-core.md (no sampling).

(1) Proposition 6.1(a): last round, non-adaptive scaffold, deterministic human:
    E beta(M^(n+1)) <= L (ln(W/w(f)) + 1)/n.   (1c) Proposition 6.1(b) for Bernoulli samplers.
(2) Proposition 12.2 (R3a, bounded damage): the condition k(1+D) + sqrt(2 L ln(1/delta)) <= eta mu L,
    against the rule that replaces the human's good answers.
(3) Theorem 13.1(a) (V1): the upper confidence bound for the rate of disagreement.
(4) Proposition 9.3(i): the tolerance of the majority scaffold.
(5) Theorems 8.4 and 8.6 on random small instances with a human who is not deterministic
    (exact enumeration of the corrupted runs; the instances are drawn with a fixed seed).
(6) Proposition 6.4 on random small classes of functions (exact dynamic programming).
"""
import itertools
import math
import random
from math import lgamma, log, exp, sqrt


def binom_pmf(n, k, p):
    if p <= 0:
        return 1.0 if k == 0 else 0.0
    if p >= 1:
        return 1.0 if k == n else 0.0
    return exp(lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) + k * log(p) + (n - k) * log(1 - p))


def binom_cdf(n, k, p):
    """Pr[Bin(n,p) <= k]."""
    if k < 0:
        return 0.0
    return min(1.0, sum(binom_pmf(n, i, p) for i in range(0, min(k, n) + 1)))


# ---------------------------------------------------------------- (1)
def last_round_disjoint(N, eps, w, n):
    """One call (L = 1); with probability N*eps the input falls in one of N regions (each eps),
    otherwise in a region where all hypotheses agree with f.  Class: f (weight w) and h_1..h_N
    (weight (1-w)/N each), h_i wrong exactly on region i.  Returns E[error of M^(n+1)] exactly,
    by the Markov chain of the number j of regions already asked."""
    dist = [0.0] * (N + 1)
    dist[0] = 1.0
    for _ in range(n):
        new = [0.0] * (N + 1)
        for j, pr in enumerate(dist):
            if pr == 0.0:
                continue
            up = eps * (N - j)
            new[j] += pr * (1 - up)
            if j < N:
                new[j + 1] += pr * up
        dist = new
    err = 0.0
    for j, pr in enumerate(dist):
        surv = (1 - w) * (N - j) / N
        err += pr * eps * (N - j) * ((1 - w) / N) / (w + surv)
    return err


def check_last_round():
    print("== (1) last round, non-adaptive scaffold, deterministic human (L = 1) ==")
    for w in (0.5, 1e-2, 1e-4, 1e-8):
        for N in (10, 100):
            worst = 0.0
            arg = None
            for n in (10, 30, 100, 300, 1000):
                for i in range(1, 60):
                    eps = min(1.0 / N, (i / 8.0) / n)
                    e = last_round_disjoint(N, eps, w, n)
                    if n * e > worst:
                        worst, arg = n * e, (n, eps)
            print(f"w(f)={w:g} N={N}: max over n, eps of n*E[error of M^(n+1)] = {worst:.4f} at n={arg[0]}, eps={arg[1]:.4g};"
                  f"  ln(1/w) = {log(1 / w):.4f};  bound ln(1/w) + 1 = {log(1 / w) + 1:.4f}")


def last_round_disjoint_np(N, eps, w, n):
    """The same computation with numpy, for large N."""
    import numpy as np
    dist = np.zeros(N + 1)
    dist[0] = 1.0
    up = eps * (N - np.arange(N + 1))
    for _ in range(n):
        mv = dist * up
        dist = dist - mv
        dist[1:] += mv[:-1]
    j = np.arange(N + 1)
    surv = (1 - w) * (N - j) / N
    return float(np.sum(dist * eps * (N - j) * ((1 - w) / N) / (w + surv)))


def check_last_round_large():
    print("== (1b) the same family with many regions (N = 10^4, eps = x/n, n = 10^5): the bound has the right order ==")
    N, n = 10 ** 4, 10 ** 5
    for w in (1e-2, 1e-4, 1e-8):
        best = max((n * last_round_disjoint_np(N, x / n, w, n), x) for x in (4, 6, 7, 8, 9))
        print(f"w(f)={w:g}: max over x of n*E[error of M^(n+1)] = {best[0]:.4f} at x={best[1]};  ln(1/w) = {log(1 / w):.4f};  "
              f"bound ln(1/w) + 1 = {log(1 / w) + 1:.4f}")


def last_round_h2(ps, ws, n):
    """One input, L = 1, every round asks.  Class of Bernoulli samplers with success probabilities ps
    (all in (0,1)) and weights ws; the human is ps[0].  Returns E[H^2(P, M^(n+1))] exactly."""
    p = ps[0]
    tot = 0.0
    for k in range(n + 1):
        pr = binom_pmf(n, k, p)
        if pr == 0.0:
            continue
        logs = [log(w) + k * log(q) + (n - k) * log(1 - q) for q, w in zip(ps, ws)]
        mx = max(logs)
        post = [exp(a - mx) for a in logs]
        z = sum(post)
        m1 = sum(a / z * q for a, q in zip(post, ps))
        tot += pr * (1 - sqrt(p * m1) - sqrt((1 - p) * (1 - m1)))
    return tot


def check_last_round_stochastic():
    print("== (1c) Proposition 6.1(b): last round, one input, Bernoulli samplers, human not deterministic ==")
    for name, ps, ws in (("two far samplers", [0.5, 0.9], [0.01, 0.99]),
                         ("human of small weight among six", [0.3, 0.05, 0.2, 0.5, 0.7, 0.95], [1e-4, 0.2, 0.2, 0.2, 0.2, 0.1999]),
                         ("human close to deterministic", [0.98, 0.5, 0.8, 0.9], [1e-3, 0.4, 0.3, 0.299])):
        S = sum(sqrt(w) for w in ws)
        bound = 0.5 * log(1 / ws[0]) + log(S) + 1
        best = max((n * last_round_h2(ps, ws, n), n) for n in (1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000))
        print(f"{name}: max over n of n*E[H^2(P, M^(n+1))] = {best[0]:.4f} at n={best[1]};  "
              f"bound (1/2) ln(1/w(P)) + ln S + 1 = {bound:.4f}")


# ---------------------------------------------------------------- (2)
def check_bounded_damage():
    print("== (2) bounded damage: human step +1 w.p. (1+mu)/2, -1 otherwise; the rule replaces the first k answers +1 by a step -D ==")
    mu, D, eta = 0.2, 3.0, 0.5
    for Lc in (400, 1600, 6400):
        for delta in (0.1, 0.01):
            for label, c in (("sqrt(2 L ln(1/delta))", 2.0), ("sqrt(8 L ln(1/delta)) [note.md]", 8.0)):
                slack = eta * mu * Lc - sqrt(c * Lc * log(1 / delta))
                k = int(math.floor(slack / (1 + D))) if slack > 0 else -1
                if k < 0:
                    print(f"L={Lc} delta={delta} with {label}: the condition allows no k")
                    continue
                # total rise = (2B - L) - k(1+D) with B ~ Bin(L,(1+mu)/2), provided B >= k; good iff >= (1-eta) mu L
                need = ((1 - eta) * mu * Lc + k * (1 + D) + Lc) / 2.0      # B >= need
                bmin = math.ceil(need - 1e-12)
                fail = binom_cdf(Lc, max(bmin, k) - 1, (1 + mu) / 2)
                print(f"L={Lc} delta={delta} with {label}: largest k = {k} (fraction {k / Lc:.4f}); exact failure = {fail:.3e} <= delta")
        # without the square-root term the statement fails
        k = int(math.floor(eta * mu * Lc / (1 + D)))
        need = ((1 - eta) * mu * Lc + k * (1 + D) + Lc) / 2.0
        fail = binom_cdf(Lc, math.ceil(need - 1e-12) - 1, (1 + mu) / 2)
        print(f"L={Lc}: k = floor(eta mu L/(1+D)) = {k} (no square-root term): exact failure = {fail:.3f}")
        k2 = int(math.floor((eta * mu * Lc + 2 * sqrt(Lc)) / (1 + D)))
        need = ((1 - eta) * mu * Lc + k2 * (1 + D) + Lc) / 2.0
        fail = binom_cdf(Lc, math.ceil(need - 1e-12) - 1, (1 + mu) / 2)
        print(f"L={Lc}: k = floor((eta mu L + 2 sqrt(L))/(1+D)) = {k2}: exact failure = {fail:.3f}")


# ---------------------------------------------------------------- (3)
def check_certificate():
    print("== (3) validation certificate, part (a): Pr[rho > rho_hat + sqrt(2 rho_hat ln(1/delta)/m) + 2 ln(1/delta)/m] ==")
    for delta in (0.1, 0.01):
        for m in (20, 100, 500):
            worst = 0.0
            for i in range(1, 400):
                rho = i / 400.0
                # the event: the bound computed from k disagreements is below rho
                pr = 0.0
                for k in range(0, m + 1):
                    rh = k / m
                    ub = rh + sqrt(2 * rh * log(1 / delta) / m) + 2 * log(1 / delta) / m
                    if ub < rho:
                        pr += binom_pmf(m, k, rho)
                    else:
                        break
                worst = max(worst, pr)
            zero = max((1 - r / 1000.0) ** m for r in range(1, 1000) if r / 1000.0 > log(1 / delta) / m) if log(1 / delta) / m < 0.999 else 0.0
            print(f"delta={delta} m={m}: worst coverage failure over rho = {worst:.4f} <= delta;  "
                  f"rule 'no disagreement => rho <= ln(1/delta)/m': worst failure = {zero:.4f} <= delta")


# ---------------------------------------------------------------- (4)
def check_majority_tolerance():
    print("== (4) majority scaffold: Pr[Bin(L, 1/2 + th) <= L/2 + k] against exp(-2 (th L - k)^2 / L) ==")
    for Lc, th in ((101, 0.2), (401, 0.1), (1601, 0.05)):
        for frac in (0.0, 0.25, 0.5):
            k = int(frac * th * Lc)
            ex = binom_cdf(Lc, int(math.floor(Lc / 2 + k)), 0.5 + th)
            print(f"L={Lc} theta'={th} k={k}: exact = {ex:.3e} <= bound = {exp(-2 * (th * Lc - k) ** 2 / Lc):.3e}")


# ---------------------------------------------------------------- (5)
def check_low_stakes(trials=200, seed=7):
    """Scaffold with L = 3 calls, inputs 0/1, answers 0/1/2: call 1 at input 0; call j+1 at input
    (y_j mod 2).  Human P and kernel C are random; G is a random set of answer sequences.
    Checks, for k = 0, 1, 2:  Q_C(not G) <= delta_k + Pr[N >= k+1] <= delta_k + beta/(k+1)   (Theorem 8.4)
    and Q_C(not G) <= Q_P(not G) + mu * beta                                                (Theorem 8.6)."""
    import itertools
    import random
    rng = random.Random(seed)
    Lc, Y, X = 3, (0, 1, 2), (0, 1)

    def rand_dist(sparse):
        v = [rng.random() if (not sparse or rng.random() < 0.7) else 0.0 for _ in Y]
        if sum(v) == 0:
            v[rng.randrange(3)] = 1.0
        t = sum(v)
        return [a / t for a in v]

    def coupling(c, p):
        tv = 0.5 * sum(abs(a - b) for a, b in zip(c, p))
        g = [[0.0] * 3 for _ in Y]
        for y in Y:
            g[y][y] = min(c[y], p[y])
            for y2 in Y:
                if y2 != y and tv > 0:
                    g[y][y2] = max(c[y] - p[y], 0) * max(p[y2] - c[y2], 0) / tv
        return g, tv

    def nxt(ys):
        return 0 if not ys else ys[-1] % 2

    worst84a = worst84b = worst86 = -1.0
    print("== (5) Theorems 8.4 and 8.6, random instances with a stochastic human (L = 3, three answers) ==")
    for _ in range(trials):
        P = [rand_dist(True) for _ in X]
        C = [rand_dist(False) for _ in X]
        good = {ys: rng.random() < 0.6 for ys in itertools.product(Y, repeat=Lc)}
        gam = [coupling(C[x], P[x]) for x in X]

        def corrupted(budget):
            """law of (passed answers, number of replacements) under kappa_C with the given budget (None = no budget)"""
            out = {}

            def rec(ys, nrep, pr):
                if len(ys) == Lc:
                    out[(tuple(ys), nrep)] = out.get((tuple(ys), nrep), 0.0) + pr
                    return
                x = nxt(ys)
                g, _ = gam[x]
                for yp in Y:
                    if P[x][yp] == 0:
                        continue
                    if budget is not None and nrep >= budget:
                        rec(ys + [yp], nrep, pr * P[x][yp])
                    else:
                        for y in Y:
                            if g[y][yp] > 0:
                                rec(ys + [y], nrep + (y != yp), pr * g[y][yp])
            rec([], 0, 1.0)
            return out

        full = corrupted(None)
        # the corrupted run has the law Q_C
        qc = {}

        def recq(ys, pr):
            if len(ys) == Lc:
                qc[tuple(ys)] = pr
                return
            x = nxt(ys)
            for y in Y:
                if C[x][y] > 0:
                    recq(ys + [y], pr * C[x][y])
        recq([], 1.0)
        marg = {}
        for (ys, nrep), pr in full.items():
            marg[ys] = marg.get(ys, 0.0) + pr
        assert all(abs(marg.get(ys, 0.0) - qc.get(ys, 0.0)) < 1e-12 for ys in set(marg) | set(qc))
        fail_c = sum(pr for (ys, nrep), pr in full.items() if not good[ys])
        beta = sum(pr * nrep for (ys, nrep), pr in full.items())
        for k in (0, 1, 2):
            bud = corrupted(k)
            assert max(nrep for (ys, nrep) in bud) <= k
            delta_k = sum(pr for (ys, nrep), pr in bud.items() if not good[ys])
            tail = sum(pr for (ys, nrep), pr in full.items() if nrep >= k + 1)
            worst84a = max(worst84a, fail_c - (delta_k + tail))
            worst84b = max(worst84b, tail - beta / (k + 1))
        # Theorem 8.6: v by backward recursion under P, mu = largest one-step difference

        def v(ys):
            if len(ys) == Lc:
                return 0.0 if good[tuple(ys)] else 1.0
            x = nxt(ys)
            return sum(P[x][y] * v(ys + [y]) for y in Y if P[x][y] > 0)
        mu = 0.0
        for j in range(Lc):
            for ys in itertools.product(Y, repeat=j):
                x = nxt(list(ys))
                vals = [v(list(ys) + [y]) for y in Y]
                lo = min(vals[y] for y in Y if P[x][y] > 0)
                mu = max(mu, max(vals) - lo)
        worst86 = max(worst86, fail_c - (v([]) + mu * beta))
    print(f"{trials} instances: max of Q_C(not G) - (delta_k + Pr[N >= k+1]) = {worst84a:.2e} (should be <= 0);  "
          f"max of Pr[N >= k+1] - beta/(k+1) = {worst84b:.2e} (<= 0);  "
          f"max of Q_C(not G) - (Q_P(not G) + mu beta) = {worst86:.2e} (<= 0)")


# ---------------------------------------------------------------- (6)
def check_last_round_adaptive(trials=40, seed=3, verbose=True):
    """Proposition 6.4.  Scaffold with L = 3 calls and 6 inputs, answers bits: z = 1 with a small random
    probability pz; call 1 at x = z; call 2 at 2 + y_1; call 3 at 4 + y_2.  Class: all 64 functions on the
    6 inputs with random heavy-tailed weights; the human f is one of them, with a small weight.  For a deterministic human and a class of functions the posterior
    depends only on the set of inputs asked so far, so E u(M^(t)) and E beta(M^(t)) are computed
    exactly by dynamic programming over the 64 sets."""
    rng = random.Random(seed)
    L, NX = 3, 6
    funcs = list(itertools.product((0, 1), repeat=NX))
    worst = 0.0
    worst_ratio_avg = 0.0
    for trial in range(trials):
        f = funcs[rng.randrange(64)]
        # heavy-tailed random weights; the human gets a small weight
        w = [math.exp(rng.gauss(0, 3)) for _ in funcs]
        fi = funcs.index(f)
        w[fi] = min(w) * rng.random()
        tot = sum(w); w = [a / tot for a in w]
        lw = math.log(1 / w[fi])
        pz = 10 ** (-rng.uniform(0.3, 3.5))

        def mixture(mask):
            alive = [(wi, h) for wi, h in zip(w, funcs) if all(h[x] == f[x] for x in range(NX) if mask >> x & 1)]
            t = sum(wi for wi, h in alive)
            return [sum(wi for wi, h in alive if h[x] == 1) / t for x in range(NX)]

        def analyse(M):
            """returns u, beta, and the law of the asked input of a round driven by M"""
            u = beta = 0.0
            ask = {}
            for z in (0, 1):
                for ys in itertools.product((0, 1), repeat=L):
                    xs = [z, 2 + ys[0], 4 + ys[1]]
                    pr = pz if z == 1 else 1 - pz
                    for x, y in zip(xs, ys):
                        pr *= M[x] if y else 1 - M[x]
                    if pr == 0:
                        continue
                    wrong = sum(1 for x, y in zip(xs, ys) if y != f[x])
                    u += pr * (wrong > 0); beta += pr * wrong
                    for x in xs:
                        ask[x] = ask.get(x, 0.0) + pr / L
            return u, beta, ask

        info = {mask: analyse(mixture(mask)) for mask in range(64)}
        dist = {0: 1.0}
        us, betas = [], []
        nmax = 4000
        for t in range(1, nmax + 2):
            us.append(sum(pr * info[m][0] for m, pr in dist.items()))
            betas.append(sum(pr * info[m][1] for m, pr in dist.items()))
            new = {}
            for m, pr in dist.items():
                for x, q in info[m][2].items():
                    new[m | (1 << x)] = new.get(m | (1 << x), 0.0) + pr * q
            dist = new
        for n in (50, 100, 200, 500, 1000, 2000, 4000):
            B0 = L * lw / n
            if 2 * B0 >= 1:
                continue
            bound = 2 * L * B0 * (1 + math.log(1 / (2 * B0))) + 2 * B0 + 2 * L / n
            worst = max(worst, us[n] / bound)                    # us[n] = E u(M^(n+1))
            avg = sum(us[:n]) / n
            if avg > 0:
                worst_ratio_avg = max(worst_ratio_avg, us[n] / B0)
            assert sum(betas[:n]) <= L * lw + 1e-9
    if verbose:
        print("== (6) Proposition 6.4: last round on a scaffold whose inputs depend on the answers (exact, random classes of functions) ==")
        print(f"{trials} random classes: max over classes and n of E u(M^(n+1)) / (bound of Proposition 6.4) = {worst:.4f} (<= 1);  "
              f"max of E u(M^(n+1)) / (L ln(1/w(f))/n) = {worst_ratio_avg:.4f}")
    return worst


if __name__ == "__main__":
    check_last_round()
    check_last_round_large()
    check_last_round_stochastic()
    check_bounded_damage()
    check_certificate()
    check_majority_tolerance()
    check_low_stakes()
    check_last_round_adaptive()
