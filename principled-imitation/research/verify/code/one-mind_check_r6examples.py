"""Referee's checks of Examples 5.2(b) and 5.3 of research/prove-c/one-mind.md (first-consistent driver).

(A) Example 5.2(b): Pr[G_1 + ... + G_M >= n] exactly (negative binomial) for n = floor(L M / 2), M >= 40, M <= L.
(B) Example 5.3: the exact expected total number of unfaithful rounds, computed in two independent ways:
    (i) the rehearsal as an absorbing Markov chain on version spaces (the engine of one-mind_check_exact.py);
    (ii) L * sum_i Pr[the reign of g_i is not empty], with the probability by inclusion-exclusion.
    Then the expected number among the first n rounds (exact, by propagating the law of the version space),
    against sum_i min(L, n eps^i) and L (log(n/L)/log(1/eps) + 3).
(C) Referee's illustration for Remark 5.4: a chain of L hypotheses at each of several rarity levels.
Usage: python3 one-mind_check_r6examples.py
"""
import importlib.util
import itertools
import math
import os

from scipy.stats import binom

spec = importlib.util.spec_from_file_location("engine", os.path.join(os.path.dirname(os.path.abspath(__file__)), "one-mind_check_exact.py"))
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)


def part_A():
    print("(A) Example 5.2(b): Pr[round n is unfaithful] = Pr[G_1+...+G_M >= n] at n = floor(L M / 2)")
    print("       M      L        n     exact       Chebyshev bound 1 - 4/M")
    worst = 1.0
    for M in (40, 41, 50, 64, 100, 400):
        for L in (M, M + 1, 2 * M, 10 * M):
            n = (L * M) // 2
            # S >= n  iff  at most M - 1 successes in the first n - 1 trials
            pr = binom.cdf(M - 1, n - 1, 1.0 / L)
            assert pr >= 1 - 4 / M and pr >= 0.9
            worst = min(worst, pr)
            if L in (M, 10 * M):
                print(f"   {M:6d} {L:6d} {n:8d} {pr:10.6f} {1 - 4 / M:14.4f}")
    print(f"   smallest value over the grid: {worst:.6f} (the claim is >= 0.9)")
    # variance of a geometric variable with parameter 1/L (number of trials): L^2 - L <= L^2
    for L in (1, 2, 7, 50):
        p = 1.0 / L
        assert abs((1 - p) / p ** 2 - (L * L - L)) < 1e-9


def reign_nonempty(i, eps):
    """Pr[D_i > max_{d<i} D_d] for independent-in-time competing events with rates proportional to eps^d."""
    tot = 0.0
    for r in range(i):
        for S in itertools.combinations(range(1, i), r):
            tot += (-1) ** r * eps ** i / (eps ** i + sum(eps ** d for d in S))
    return tot


def build_53(M, L, eps):
    pz = [1 - sum(eps ** i for i in range(1, M + 1))] + [eps ** i for i in range(1, M + 1)]
    assert pz[0] > 0
    sc = engine.PathScaffold(M + 1, L, pz)
    # inputs are coded z*L + (j-1); g_i is 1 at the input (i, 1) only
    G = [[0] * sc.nx] + [[1 if x == i * L else 0 for x in range(sc.nx)] for i in range(1, M + 1)]
    C = engine.Det(sc, G, [1.0 / (M + 1)] * (M + 1))
    order = list(range(1, M + 1)) + [0]
    return C, order


def part_B():
    print("(B) Example 5.3: expected total number of unfaithful rounds, first-consistent driver")
    print("       M   L    eps     Markov chain    L*sum_i Pr[reign nonempty]    L M (1-2eps)     L M")
    for M, L, eps in ((1, 3, 0.25), (3, 1, 0.25), (3, 4, 0.25), (5, 3, 0.1), (6, 5, 0.25), (8, 2, 0.2), (8, 6, 0.05)):
        C, order = build_53(M, L, eps)
        V0 = (1 << C.m) - 1
        tot = C.total(V0, lambda V: C.step_first(V, order), "first")[0]
        formula = L * sum(reign_nonempty(i, eps) for i in range(1, M + 1))
        assert abs(tot - formula) < 1e-6 * max(1.0, formula)
        assert L * M * (1 - 2 * eps) - 1e-9 <= tot <= L * M + 1e-9
        for i in range(2, M + 1):                                   # the bound used for the empty reign
            assert 1 - reign_nonempty(i, eps) <= eps / (1 - eps) + 1e-12 <= 2 * eps + 1e-12
        print(f"   {M:6d} {L:3d} {eps:6.2f} {tot:14.5f} {formula:22.5f} {L * M * (1 - 2 * eps):20.3f} {L * M:8d}")
    print("   expected number of unfaithful rounds among the first n (exact law of the version space, round by round):")
    print("       M   L    eps        n     exact     sum_i min(L, n eps^i)    L(log(n/L)/log(1/eps) + 3)    E[D_M] = L eps^-M")
    for M, L, eps, ns in ((6, 4, 0.25, (4, 40, 400, 4000)), (8, 3, 0.2, (3, 30, 300, 3000)), (5, 5, 0.1, (5, 500, 5000))):
        C, order = build_53(M, L, eps)
        law = {(1 << C.m) - 1: 1.0}
        cache = {}
        acc, t = 0.0, 0
        for n in ns:
            while t < n:
                new = {}
                for V, p in law.items():
                    if V not in cache:
                        cache[V] = C.step_first(V, order)
                    (ubar, _), trans = cache[V]
                    acc += p * ubar
                    for V2, q in trans.items():
                        new[V2] = new.get(V2, 0.0) + p * q
                law = new
                t += 1
            b1 = sum(min(L, n * eps ** i) for i in range(1, M + 1))
            b2 = L * (math.log(n / L) / math.log(1 / eps) + 3)
            assert acc <= b1 + 1e-9 and b1 <= b2 + 1e-9
            print(f"   {M:6d} {L:3d} {eps:6.2f} {n:8d} {acc:9.4f} {b1:18.4f} {b2:26.4f} {L * eps ** (-M):24.1f}")




def part_C():
    """Referee's illustration for Remark 5.4: a chain of L hypotheses (as in Example 5.2) at each of I rarity levels
    (as in Example 5.3). g_{i,j} is wrong at the single input (i, j); Pr[z = i] = eps^i; enumeration level by level.
    The exact expected total number of unfaithful rounds of the first-consistent driver is close to L^2 * I when
    eps is small compared with 1/L."""
    print("(C) chains at several rarity levels (referee's illustration for Remark 5.4), first-consistent driver, exact")
    print("       L   I    eps     total     L^2 I    | expected number among the first n rounds:  n = 10       100      1000     10000")
    for L, I, eps in ((2, 3, 0.05), (3, 3, 0.02), (3, 3, 0.2), (4, 2, 0.02)):
        pz = [1 - sum(eps ** i for i in range(1, I + 1))] + [eps ** i for i in range(1, I + 1)]
        sc = engine.PathScaffold(I + 1, L, pz)
        G = [[0] * sc.nx]
        for i in range(1, I + 1):
            for j in range(1, L + 1):
                G.append([1 if x == i * L + (j - 1) else 0 for x in range(sc.nx)])
        C = engine.Det(sc, G, [1.0 / len(G)] * len(G))
        order = list(range(1, len(G))) + [0]
        tot = C.total((1 << C.m) - 1, lambda V: C.step_first(V, order), "first")[0]
        assert tot <= L * (len(G) - 1) + 1e-9                         # Proposition 5.1
        law = {(1 << C.m) - 1: 1.0}
        cache = {}
        acc, t, row = 0.0, 0, []
        for n in (10, 100, 1000, 10000):
            while t < n:
                new = {}
                for V, p in law.items():
                    if V not in cache:
                        cache[V] = C.step_first(V, order)
                    (ubar, _), trans = cache[V]
                    acc += p * ubar
                    for V2, q in trans.items():
                        new[V2] = new.get(V2, 0.0) + p * q
                law = new
                t += 1
            row.append(f"{acc:9.2f}")
        print(f"   {L:6d} {I:3d} {eps:6.2f} {tot:9.4f} {L * L * I:8d}    |                                      " + " ".join(row))


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    print("all assertions passed")
