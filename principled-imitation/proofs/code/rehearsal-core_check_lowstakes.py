#!/usr/bin/env python3
"""Referee's exact checks of Sections 8 and 9 of research/prove-c/rehearsal-core.md (low stakes),
written independently of the prover's scripts.  Random instances are drawn with a fixed seed and
then evaluated exactly by enumeration.

(1) Theorem 8.4 for an answerer A that depends on the whole history (the prover's check uses kernels):
        Q_A(not G) <= delta_k(A) + Pr[N >= k+1] <= delta_k(A) + beta(A)/(k+1),
    where the corrupted run by r^A and by the budgeted rule r^{A,<=k} are enumerated call by call from
    the maximal couplings; also: the corrupted run by r^A has the law Q_A, and E[N] = beta(A).
(2) Theorem 8.6 for arbitrary replacement rules in R_all (random rules that see z, all earlier human
    answers, their own earlier outputs and the current human answer):  E c(tau^r) <= E_{Q_P} c + mu E[N],
    with mu the smallest constant satisfying (8.1).
(3) Proposition 8.3(d): sup of prod e_j subject to sum e_j = beta equals (beta/L)^L (random search).
(4) Example 8.5(c): the worst budgeted stateless rule on the scaffold of the example (grid search over
    its replacement probabilities) fails with probability at most k/(L-1).
(5) Theorem 9.2 against a concrete protocol (equal split of the questions, sign of the majority):
    the average of beta over the class is at least L theta/2.
(6) Proposition 9.3(ii): the hypothesis gamma <= 1/2 is needed (the trivial protocol with n = 0).
"""
import itertools
import random
from math import log, sqrt, exp, lgamma

Y = (0, 1, 2)
Lh = 3


def nxt(z, ys):
    """Scaffold of horizon 3 with inputs in {0,1,2} that depend on the answers, and runs of length 2 or 3
    (and of length 1 when z = 1 and y_1 = 2)."""
    j = len(ys) + 1
    if j == 1:
        return z
    if j > Lh:
        return None
    if z == 1 and ys[-1] == 2:
        return None
    return (z + sum(ys)) % 3


def all_histories():
    """All (z, ys) at which a call is made."""
    out = []
    for z in (0, 1):
        stack = [()]
        while stack:
            ys = stack.pop()
            if nxt(z, ys) is None:
                continue
            out.append((z, ys))
            for y in Y:
                stack.append(ys + (y,))
    return out


def rand_dist(rng, zeros=False):
    v = [rng.random() ** 2 for _ in Y]
    if zeros and rng.random() < 0.4:
        v[rng.randrange(3)] = 0.0
    s = sum(v)
    return tuple(a / s for a in v)


def max_coupling(a, b):
    t = 0.5 * sum(abs(x - y) for x, y in zip(a, b))
    g = {}
    for y in Y:
        for y2 in Y:
            if y == y2:
                g[(y, y2)] = min(a[y], b[y])
            else:
                g[(y, y2)] = max(a[y] - b[y], 0) * max(b[y2] - a[y2], 0) / t if t > 0 else 0.0
    return g, t


def instance(rng):
    P = {x: rand_dist(rng, zeros=True) for x in range(3)}
    hist = all_histories()
    A = {h: rand_dist(rng) for h in hist}
    pz = rng.random() * 0.8 + 0.1
    D0 = {0: pz, 1: 1 - pz}
    runs = []
    for z in (0, 1):
        stack = [()]
        while stack:
            ys = stack.pop()
            if nxt(z, ys) is None:
                runs.append((z, ys))
            else:
                for y in Y:
                    stack.append(ys + (y,))
    G = {r for r in runs if rng.random() < 0.6}
    return P, A, D0, G, runs


def law_direct(answer_law, D0):
    """Run law for an answerer given as a function (z, ys) -> distribution."""
    out = {}
    for z, pz in D0.items():
        stack = [(pz, ())]
        while stack:
            pr, ys = stack.pop()
            x = nxt(z, ys)
            if x is None:
                out[(z, ys)] = out.get((z, ys), 0.0) + pr
                continue
            d = answer_law(z, ys)
            for y in Y:
                if d[y] > 0:
                    stack.append((pr * d[y], ys + (y,)))
    return out


def corrupted(P, A, D0, budget):
    """Run of the human system corrupted by r^A with a budget (None = no budget).  Returns
    (law of the run, distribution of the number of replacements)."""
    law, ndist = {}, {}
    for z, pz in D0.items():
        stack = [(pz, (), 0)]
        while stack:
            pr, ys, N = stack.pop()
            x = nxt(z, ys)
            if x is None:
                law[(z, ys)] = law.get((z, ys), 0.0) + pr
                ndist[N] = ndist.get(N, 0.0) + pr
                continue
            if budget is not None and N >= budget:
                for y2 in Y:                       # the human's answer is passed unchanged
                    if P[x][y2] > 0:
                        stack.append((pr * P[x][y2], ys + (y2,), N))
            else:
                g, _ = max_coupling(A[(z, ys)], P[x])
                for (y, y2), pg in g.items():
                    if pg > 0:
                        stack.append((pr * pg, ys + (y,), N + (1 if y != y2 else 0)))
    return law, ndist


def check_84(trials=300, seed=11):
    rng = random.Random(seed)
    worst1 = worst2 = worst_law = worst_beta = -1.0
    slack_min = 1.0
    for _ in range(trials):
        P, A, D0, G, runs = instance(rng)
        QA = law_direct(lambda z, ys: A[(z, ys)], D0)
        lawA, nd = corrupted(P, A, D0, None)
        worst_law = max(worst_law, max(abs(QA.get(r, 0) - lawA.get(r, 0)) for r in runs))
        # beta(A) = E_{Q_A} sum TV
        beta = 0.0
        for z, pz in D0.items():
            stack = [(pz, ())]
            while stack:
                pr, ys = stack.pop()
                x = nxt(z, ys)
                if x is None:
                    continue
                d = A[(z, ys)]
                beta += pr * 0.5 * sum(abs(a - b) for a, b in zip(d, P[x]))
                for y in Y:
                    if d[y] > 0:
                        stack.append((pr * d[y], ys + (y,)))
        EN = sum(k * p for k, p in nd.items())
        worst_beta = max(worst_beta, abs(EN - beta))
        fail = sum(p for r, p in QA.items() if r not in G)
        for k in (0, 1, 2, 3):
            lawk, ndk = corrupted(P, A, D0, k)
            assert max(ndk) <= k
            dk = sum(p for r, p in lawk.items() if r not in G)
            tail = sum(p for N, p in nd.items() if N >= k + 1)
            worst1 = max(worst1, fail - (dk + tail))
            worst2 = max(worst2, tail - beta / (k + 1))
            slack_min = min(slack_min, dk + tail - fail)
    ok = worst1 <= 1e-12 and worst2 <= 1e-12 and worst_law < 1e-12 and worst_beta < 1e-12
    print(f"== (1) Theorem 8.4, history-dependent answerers, human not deterministic, {trials} instances ==")
    print(f"   max |law of the run corrupted by r^A - Q_A| = {worst_law:.1e};  max |E N - beta(A)| = {worst_beta:.1e}")
    print(f"   max of Q_A(not G) - (delta_k(A) + Pr[N >= k+1]) = {worst1:.2e} (<= 0);  max of Pr[N >= k+1] - beta/(k+1) = {worst2:.2e} (<= 0)  {'OK' if ok else 'FAIL'}")
    return ok


def check_86(trials=200, seed=5):
    """Theorem 8.6 for random rules in R_all."""
    rng = random.Random(seed)
    worst = -1.0
    tight = 0.0
    for _ in range(trials):
        P, A, D0, G, runs = instance(rng)
        cost = lambda z, ys: 0.0 if (z, ys) in G else 1.0
        # v(z, ys) = expected cost if the human answers from here on
        memo = {}

        def v(z, ys):
            key = (z, ys)
            if key not in memo:
                x = nxt(z, ys)
                memo[key] = cost(z, ys) if x is None else sum(P[x][y] * v(z, ys + (y,)) for y in Y if P[x][y] > 0)
            return memo[key]

        mu = 0.0
        for (z, ys) in all_histories():
            x = nxt(z, ys)
            for y in Y:
                for y2 in Y:
                    if P[x][y2] > 0:
                        mu = max(mu, v(z, ys + (y,)) - v(z, ys + (y2,)))
        EP = sum(pz * v(z, ()) for z, pz in D0.items())
        # a random rule in R_all: context = (z, human answers so far incl. current, passed answers so far)
        rule = {}

        def r(z, yps, ys):
            key = (z, yps, ys)
            if key not in rule:
                if rng.random() < 0.5:
                    d = [0.0, 0.0, 0.0]; d[yps[-1]] = 1.0          # pass the human's answer
                    rule[key] = tuple(d)
                else:
                    rule[key] = rand_dist(rng)
            return rule[key]

        Ec = EN = 0.0
        for z, pz in D0.items():
            stack = [(pz, (), (), 0)]
            while stack:
                pr, ys, yps, N = stack.pop()
                x = nxt(z, ys)
                if x is None:
                    Ec += pr * cost(z, ys); EN += pr * N
                    continue
                for y2 in Y:
                    if P[x][y2] > 0:
                        d = r(z, yps + (y2,), ys)
                        for y in Y:
                            if d[y] > 0:
                                stack.append((pr * P[x][y2] * d[y], ys + (y,), yps + (y2,), N + (1 if y != y2 else 0)))
        worst = max(worst, Ec - (EP + mu * EN))
        if mu * EN > 0:
            tight = max(tight, (Ec - EP) / (mu * EN))
    ok = worst <= 1e-12
    print(f"== (2) Theorem 8.6, random rules in R_all, {trials} instances ==")
    print(f"   max of E c(tau^r) - (E_QP c + mu E N) = {worst:.2e} (<= 0);  largest (E c - E_QP c)/(mu E N) = {tight:.3f} (<= 1)  {'OK' if ok else 'FAIL'}")
    return ok


def check_83d(seed=3):
    rng = random.Random(seed)
    ok = True
    print("== (3) Proposition 8.3(d): sup of prod_j e_j over sum_j e_j <= beta is (beta/L)^L ==")
    for Lc in (2, 3, 5):
        for beta in (0.3, 1.0, Lc - 0.5):
            best = 0.0
            for _ in range(20000):
                v = [rng.random() for _ in range(Lc)]
                s = sum(v)
                e_ = [min(1.0, a * beta / s) for a in v]
                pr = 1.0
                for a in e_:
                    pr *= a
                best = max(best, pr)
            val = (beta / Lc) ** Lc
            ok &= best <= val + 1e-12
            print(f"   L={Lc} beta={beta}: random search {best:.5f} <= (beta/L)^L = {val:.5f}; chord beta/L = {beta / Lc:.5f}")
    return ok


def check_85c():
    """Scaffold of Example 8.5(c): z uniform on {1..L-1}; call 1 at a_z, calls 2..L at x0; bad iff the
    answer at call 1+z is replaced.  A budgeted stateless rule: replacement probability q_z at a_z and q0 at x0."""
    print("== (4) Example 8.5(c): budgeted stateless rules against G = {y_(1+z) = 0} ==")
    ok = True
    for Lc, k in ((3, 1), (4, 1), (4, 2), (6, 2), (6, 3)):
        worst = 0.0
        grid = [i / 20 for i in range(21)]
        # by symmetry in z only the vector (q_z)_z and q0 matter; q_z in {0, 1} are the extreme points
        # for fixed q0 (the failure probability is affine in each q_z), so search q_z in {0,1} and q0 on a grid.
        for q0 in grid:
            for qz in itertools.product((0.0, 1.0), repeat=Lc - 1):
                fail = 0.0
                for z in range(1, Lc):
                    for first, pf in ((1, qz[z - 1]), (0, 1 - qz[z - 1])):
                        if pf == 0:
                            continue
                        b = k - first                      # budget left for calls 2..L
                        # Pr[call 1+z is replaced] = Pr[coin at position z shows replacement and fewer than b
                        # replacements among positions 1..z-1]   (positions = calls 2..L)
                        if b <= 0:
                            continue
                        pr = 0.0
                        for c in range(0, min(b, z)):       # c replacements among the first z-1 positions
                            if c > z - 1:
                                break
                            comb = exp(lgamma(z) - lgamma(c + 1) - lgamma(z - c))
                            pr += comb * q0 ** c * (1 - q0) ** (z - 1 - c)
                        fail += (1 / (Lc - 1)) * pf * pr * q0
                worst = max(worst, fail)
        good = worst <= k / (Lc - 1) + 1e-12
        ok &= good
        print(f"   L={Lc} k={k}: worst failure over the grid = {worst:.4f} <= k/(L-1) = {k / (Lc - 1):.4f}  {'OK' if good else 'FAIL'}")
    return ok


def binom_pmf(n, k, p):
    return exp(lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) + k * log(p) + (n - k) * log(1 - p))


def check_92():
    print("== (5) Theorem 9.2 against the protocol 'ask every input n/K times, answer with the sign of the majority' ==")
    ok = True
    for K, per in ((1, 8), (2, 16), (4, 50), (8, 200), (3, 1)):
        n = K * per
        th = sqrt(K / (32 * n))
        # the kernel A(1|i) = 1/2 + th * sign(majority - 1/2) (1/2 if tied) has TV to P_sigma at i equal to
        # 2 th if the sign is wrong, th if tied, 0 if right; the scaffold has L independent uniform inputs.
        perr = sum(binom_pmf(per, j, 0.5 + th) * (1.0 if 2 * j < per else (0.5 if 2 * j == per else 0.0)) for j in range(per + 1))
        avg_beta_per_L = 2 * th * perr
        good = avg_beta_per_L >= th / 2 - 1e-15
        ok &= good
        print(f"   K={K} n={n} theta={th:.4f}: average of beta/L for this protocol = {avg_beta_per_L:.5f} >= theta/2 = {th / 2:.5f}; "
              f"Protocol R's bound sqrt(K ln2/(2n)) = {sqrt(K * log(2) / (2 * n)):.5f}  {'OK' if good else 'FAIL'}")
    return ok


def check_93():
    print("== (6) Proposition 9.3(ii): the conclusion needs gamma <= 1/2 ==")
    print("   The protocol that asks nothing (n = 0) and answers every call with a fair coin has failure probability")
    print("   Pr[maj != sigma_z] = 1/2 for odd L, for every sigma.  With gamma = 1/2 the stated bound is n >= 0: true.")
    print("   With gamma = 0.9 the stated bound reads n >= K (1 - 1.8)^2/(8 theta'^2) = 0.08 K/theta'^2 > 0, which this")
    print("   protocol violates (failure 1/2 <= 0.9, n = 0).  So (ii) must assume gamma <= 1/2.")
    return True


if __name__ == "__main__":
    ok = check_84()
    ok &= check_86()
    ok &= check_83d()
    ok &= check_85c()
    ok &= check_92()
    ok &= check_93()
    print()
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")
