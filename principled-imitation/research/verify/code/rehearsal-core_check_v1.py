#!/usr/bin/env python3
"""Referee's checks of Sections 12 and 13 of research/prove-c/rehearsal-core.md (R3a and V1), and of the
corresponding statements of note.md.  Exact computations; random instances with a fixed seed.

(1) Lemma 12.1 / Proposition 12.2: exact failure probability of the rule of Remark 12.3(ii) for all k that
    (12.1) allows, over a grid of (L, mu, D, eta, delta); and the same for the note's constant 8.
    Also: the edge of the hypothesis "every run has exactly L calls" (see (1b)).
(2) Theorem 13.1(a2): exact coverage of the bound rho <= rho_hat + sqrt(2 rho_hat l/m) + 2 l/m.
(3) Theorem 13.1(a1) for a human who is NOT deterministic: the recorded disagreement rate is
    rho' = (1/L) E sum_j (1 - sum_y A(y|h_j) P(y|x_j)) >= beta(A)/L, so the certificate "no disagreement
    => beta(A) <= L ln(1/delta)/m" is valid for every human (random instances, exact).
(4) Theorem 13.1(b3): Delta(B) <= beta(A)/L with equality at B_P; and for a deterministic A the single test
    "graph of A" has Delta = beta(A)/L for every human P (so 13.1(c) needs the family to be fixed without
    regard to A).
(5) Theorem 13.1(b1): exact coverage for one test (trinomial law of the recorded pair of indicators).
(6) Corollary 13.2 and the note's phrase "with confidence 1 - delta": the certificate is issued with
    probability 1 for a bad imitator with rho <= ln(1/delta)/m ... (a numerical illustration that the
    guarantee is "a false certificate is issued with probability < delta", not "an issued certificate is
    false with probability < delta").
"""
import itertools
import random
from math import log, sqrt, exp, lgamma, floor, ceil


def binom_pmf(n, k, p):
    if p <= 0:
        return 1.0 if k == 0 else 0.0
    if p >= 1:
        return 1.0 if k == n else 0.0
    return exp(lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) + k * log(p) + (n - k) * log(1 - p))


def binom_cdf(n, k, p):
    if k < 0:
        return 0.0
    return min(1.0, sum(binom_pmf(n, i, p) for i in range(0, min(k, n) + 1)))


# ------------------------------------------------------------------ (1)
def fail_prob(L, mu, D, eta, k):
    """Human: +1 w.p. (1+mu)/2, else -1.  Rule: replace the first k answers +1 by a step -D.
    Total rise = (2B - L) - min(k, B)(1 + D), B ~ Bin(L, (1+mu)/2).  Good iff rise >= (1-eta) mu L."""
    p = (1 + mu) / 2
    thr = (1 - eta) * mu * L
    f = 0.0
    for B in range(L + 1):
        rise = (2 * B - L) - min(k, B) * (1 + D)
        if rise < thr - 1e-12:
            f += binom_pmf(L, B, p)
    return f


def check_r3a():
    print("== (1) Proposition 12.2 against the rule of Remark 12.3(ii): exact failure for every admissible k ==")
    ok = True
    worst_ratio = 0.0
    for L in (50, 200, 800, 3200):
        for mu in (0.1, 0.3, 0.8):
            for D in (0.0, 1.0, 3.0):
                for eta in (0.25, 0.5, 1.0):
                    for delta in (0.3, 0.05, 0.001):
                        slack = eta * mu * L - sqrt(2 * L * log(1 / delta))
                        if slack < 0:
                            continue
                        kmax = int(floor(slack / (1 + D) + 1e-12))
                        f = fail_prob(L, mu, D, eta, kmax)     # the failure probability increases with k
                        worst_ratio = max(worst_ratio, f / delta)
                        if f > delta + 1e-12:
                            ok = False
                            print(f"   FAIL L={L} mu={mu} D={D} eta={eta} delta={delta} k={kmax}: failure {f:.4g}")
    print(f"   largest (exact failure)/delta over the grid with the constant 2: {worst_ratio:.4f} (<= 1)  {'OK' if ok else 'FAIL'}")
    # how much room is left: could the constant 2 be lowered?  Hoeffding for +-1 steps is tight up to the
    # Gaussian tail, so sqrt(c L ln(1/delta)) with c < 2(1 - mu^2) must fail for small delta and large L.
    L, mu, D, eta = 3200, 0.3, 0.0, 1.0
    for c in (2.0, 1.5, 1.0):
        row = []
        for delta in (1e-2, 1e-4, 1e-8):
            slack = eta * mu * L - sqrt(c * L * log(1 / delta))
            k = int(floor(slack / (1 + D)))
            row.append(f"delta={delta:g}: k={k}, failure/delta = {fail_prob(L, mu, D, eta, k) / delta:.3g}")
        print(f"   L={L} mu={mu} D={D} eta={eta}, constant {c}: " + "; ".join(row))
    print("   (1b) the note's condition (constant 8) allows fewer faults; it is implied by (12.1) and never fails:")
    for L, delta in ((1600, 0.1), (6400, 0.01), (25600, 0.01)):
        mu, D, eta = 0.2, 3.0, 0.5
        for c in (2.0, 8.0):
            slack = eta * mu * L - sqrt(c * L * log(1 / delta))
            if slack < 0:
                print(f"       L={L} delta={delta} constant {c:g}: no k allowed")
            else:
                k = int(floor(slack / (1 + D)))
                print(f"       L={L} delta={delta} constant {c:g}: largest k = {k}; exact failure = {fail_prob(L, mu, D, eta, k):.3e}")
    return ok


# ------------------------------------------------------------------ (2)
def check_a2():
    print("== (2) Theorem 13.1(a2): exact Pr[rho > rho_hat + sqrt(2 rho_hat l/m) + 2 l/m], l = ln(1/delta) ==")
    ok = True
    for delta in (0.2, 0.05, 0.001):
        for m in (5, 30, 200, 1000):
            l = log(1 / delta)
            ubs = [k / m + sqrt(2 * (k / m) * l / m) + 2 * l / m for k in range(m + 1)]
            worst = 0.0
            for i in range(1, 2000):
                rho = i / 2000
                pr = 0.0
                for k in range(m + 1):
                    if ubs[k] < rho:
                        pr += binom_pmf(m, k, rho)
                    else:
                        break
                worst = max(worst, pr)
            ok &= worst <= delta
            print(f"   delta={delta} m={m}: worst miscoverage over rho = {worst:.5f} <= delta  {'OK' if worst <= delta else 'FAIL'}")
    return ok


# ------------------------------------------------------------------ (3), (4)
Y3 = (0, 1, 2)


def nxt(z, ys):
    j = len(ys) + 1
    if j == 1:
        return z
    if j > 3:
        return None
    if z == 1 and ys[-1] == 2:
        return None
    return (z + sum(ys)) % 3


def rand_dist(rng, k=3, sparse=False):
    v = [rng.random() ** 2 for _ in range(k)]
    if sparse and rng.random() < 0.5:
        v[rng.randrange(k)] = 0.0
    s = sum(v)
    return tuple(a / s for a in v)


def check_any_human(trials=300, seed=2):
    rng = random.Random(seed)
    Lc = 3
    worst = 1e9
    worst_b = -1e9
    eq_b = 0.0
    eq_graph = 0.0
    for it in range(trials):
        P = {x: rand_dist(rng, sparse=True) for x in range(3)}
        hist = []
        for z in (0, 1):
            st = [()]
            while st:
                ys = st.pop()
                if nxt(z, ys) is None:
                    continue
                hist.append((z, ys))
                for y in Y3:
                    st.append(ys + (y,))
        kernel = (it % 3 == 0)                      # a kernel in a third of the instances
        determ = (it % 3 == 1)                      # a deterministic answerer in another third
        if kernel:
            C = {x: rand_dist(rng) for x in range(3)}
            A = {h: C[nxt(*h)] for h in hist}
        elif determ:
            A = {}
            for h in hist:
                d = [0.0, 0.0, 0.0]; d[rng.randrange(3)] = 1.0
                A[h] = tuple(d)
        else:
            A = {h: rand_dist(rng) for h in hist}
        pz = 0.3 + 0.4 * rng.random()
        D0 = {0: pz, 1: 1 - pz}
        beta = dis = 0.0
        visit = {}                                  # for kernels: expected number of visits of each input
        for z, p0 in D0.items():
            st = [(p0, ())]
            while st:
                pr, ys = st.pop()
                x = nxt(z, ys)
                if x is None:
                    continue
                d = A[(z, ys)]
                beta += pr * 0.5 * sum(abs(a - b) for a, b in zip(d, P[x]))
                dis += pr * (1 - sum(a * b for a, b in zip(d, P[x])))
                visit[x] = visit.get(x, 0.0) + pr
                for y in Y3:
                    if d[y] > 0:
                        st.append((pr * d[y], ys + (y,)))
        worst = min(worst, dis - beta)
        if determ:
            eq_graph = max(eq_graph, abs(dis - beta))        # for a deterministic A the two coincide
        if kernel:
            # Delta(B) for all 2^9 tests B subset of X x Y: (1/L) sum_x visit(x) (C(B_x|x) - P(B_x|x))
            best = -1e9
            for mask in range(1 << 9):
                dlt = 0.0
                for x in range(3):
                    for y in range(3):
                        if mask >> (3 * x + y) & 1:
                            dlt += visit.get(x, 0.0) * (C[x][y] - P[x][y])
                best = max(best, dlt / Lc)
            worst_b = max(worst_b, best - beta / Lc)
            dP = sum(visit.get(x, 0.0) * (C[x][y] - P[x][y]) for x in range(3) for y in range(3) if C[x][y] > P[x][y]) / Lc
            eq_b = max(eq_b, abs(dP - beta / Lc))
    ok = worst >= -1e-12 and worst_b <= 1e-12 and eq_b < 1e-12 and eq_graph < 1e-12
    print(f"== (3) any human: min over {trials} instances of [L * (rate of recorded disagreement) - beta(A)] = {worst:.3e} (>= 0) ==")
    print("       so 'no disagreement in m rounds => beta(A) <= L ln(1/delta)/m' has error probability < delta for every human;")
    print("       for a human who is not deterministic the certificate is valid but is (almost) never issued.")
    print(f"== (4) 13.1(b3): max over all 512 tests of Delta(B) - beta(A)/L = {worst_b:.2e} (<= 0); |Delta(B_P) - beta(A)/L| = {eq_b:.1e} ==")
    print(f"       deterministic A, any human: |L * rate of disagreement - beta(A)| = {eq_graph:.1e}: the single test 'graph of A' measures beta(A)/L  {'OK' if ok else 'FAIL'}")
    return ok


# ------------------------------------------------------------------ (5)
def check_b1():
    print("== (5) Theorem 13.1(b1), one test (pi = 1): exact Pr[|Delta - (a_hat - h_hat)| > sqrt(2 ln(2/delta)/m)] ==")
    ok = True
    # one round gives g in {-1, 0, +1} with probabilities (pm, p0, pp); Delta = pp - pm
    for pp, pm in ((0.5, 0.5), (0.3, 0.1), (0.05, 0.0), (0.45, 0.45), (0.9, 0.05)):
        for m in (10, 50, 200):
            for delta in (0.3, 0.05):
                t = sqrt(2 * log(2 / delta) / m)
                Dl = pp - pm
                # distribution of S = sum g_i by convolution
                dist = {0: 1.0}
                for _ in range(m):
                    nd = {}
                    for s, pr in dist.items():
                        for g, pg in ((1, pp), (-1, pm), (0, 1 - pp - pm)):
                            if pg > 0:
                                nd[s + g] = nd.get(s + g, 0.0) + pr * pg
                    dist = nd
                bad = sum(pr for s, pr in dist.items() if abs(s / m - Dl) > t + 1e-12)
                ok &= bad <= delta
                if m == 200 or bad > delta:
                    print(f"   p(+1)={pp} p(-1)={pm} m={m} delta={delta}: exact = {bad:.5f} <= delta  {'OK' if bad <= delta else 'FAIL'}")
    return ok


# ------------------------------------------------------------------ (6)
def check_wording():
    print("== (6) what 'confidence 1 - delta' means for the certificate of 13.1(a1) ==")
    m, delta = 100, 0.05
    thr = log(1 / delta) / m
    print(f"   m = {m}, delta = {delta}: the certificate claims rho <= {thr:.4f}.")
    for rho in (0.5 * thr, thr, 1.01 * thr, 2 * thr, 5 * thr):
        print(f"   an imitator with rho = {rho:.4f}: certificate issued with probability {(1 - rho) ** m:.4f}; the claim is {'true' if rho <= thr else 'FALSE'}")
    print("   If the imitators submitted to validation all have rho = 1.01 * thr, every issued certificate is false,")
    print("   although each is issued with probability < delta.  So 'whenever it is issued it is false with probability")
    print("   less than delta' (Corollary 13.2) must read 'a false certificate is issued with probability less than delta'.")
    return True


if __name__ == "__main__":
    ok = check_r3a()
    ok &= check_a2()
    ok &= check_any_human()
    ok &= check_b1()
    ok &= check_wording()
    print()
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")
