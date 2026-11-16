"""Referee's checks of Proposition 2.5 and Remark 2.6 of research/prove-c/one-mind.md.

(1) The series S(L, K) on a grid, against the stated lower bounds and the bound (2.2) of Theorem 2.1.
(2) The chain behind the series, recomputed as a Markov chain (expected number of unfaithful rounds per level
    by direct summation over the number of rounds spent at the level), and the mixture's count of Remark 2.6.
(3) An independent simulation of the rehearsal itself on the class of Proposition 2.5: the posterior is kept
    as the list of asked positions per top-level input; the driver is drawn from the posterior.
Usage: python3 one-mind_check_series.py
"""
import math
import random

LN2 = math.log(2)


def S_series(L, K):
    """S(L, K) = sum_k u_k / (1 - u_k (L-1)/(2L)), u_k = R_k/(1+R_k), R_k = (2^K - 1)(1 - 1/L)^k.
    Summed in log space so that K = 200 bits does not overflow."""
    logR = math.log(2.0) * K + math.log1p(-2.0 ** (-K))            # ln(2^K - 1)
    step = math.log1p(-1.0 / L)
    S = Smix = 0.0
    k = 0
    while logR > -36.0:
        u = 1.0 / (1.0 + math.exp(-logR))
        S += u / (1.0 - u * (L - 1) / (2.0 * L))
        Smix += u
        logR += step
        k += 1
    # tail: for R < e^-36 the terms are < R; the remaining sum is < R * L
    return S, Smix


def part1():
    print("(1) S(L,K) on a grid: L in 45 values from 2 to 300, K in 45 values from 0.05 to 200 bits")
    Ls = sorted(set(list(range(2, 31)) + [35, 40, 50, 60, 75, 100, 125, 150, 175, 200, 225, 250, 275, 290, 295, 300]))
    Ks = [0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1, 1.25, 1.5, 2, 2.5, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 25, 30, 35,
          40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200]
    worst_low1 = worst_low2 = math.inf
    worst_up = 0.0
    n = 0
    for L in Ls:
        for K in Ks:
            S, _ = S_series(L, K)
            c = (L + 1) / (2.0 * L)
            lam = math.log(L / (L - 1.0))
            # ln(1 + c(2^K - 1)) computed stably
            low1 = math.log1p(c * math.expm1(K * LN2)) / (c * lam) if K < 500 else None
            low2 = 2.0 * L * (L - 1) / (L + 1) * (K - 1) * LN2
            up = 2.0 * L * L / (L + 1) * K * LN2
            assert S >= low1 - 1e-9 and low1 >= low2 - 1e-9 and S <= up + 1e-9, (L, K, S, low1, low2, up)
            worst_low1 = min(worst_low1, S / low1)
            if low2 > 0:
                worst_low2 = min(worst_low2, low1 / low2)
            worst_up = max(worst_up, S / up)
            n += 1
    print(f"   {n} pairs: lower bound 1 <= S <= upper bound in all; lower bound 2 <= lower bound 1 in all")
    print(f"   min S/(lower bound 1) = {worst_low1:.5f};  min (lower bound 1)/(lower bound 2) over K > 1 = {worst_low2:.5f};"
          f"  max S/((2L^2/(L+1)) K ln2) = {worst_up:.5f}")
    print("     L      K        S(L,K)    S/(L K ln2)   lower bound 2     upper bound   mixture: sum_k u_k   (sum_k u_k)/(L K ln2)")
    for L, K in ((2, 100), (5, 100), (20, 100), (100, 100), (100, 1), (300, 200), (2, 0.5)):
        S, Smix = S_series(L, K)
        print(f"   {L:4d} {K:6.1f} {S:13.2f} {S / (L * K * LN2):10.4f} {2.0 * L * (L - 1) / (L + 1) * (K - 1) * LN2:15.2f}"
              f" {2.0 * L * L / (L + 1) * K * LN2:15.2f} {Smix:14.2f} {Smix / (L * K * LN2):14.4f}")


def part2():
    print("(2) the chain recomputed level by level, and Remark 2.6")
    for L, K in ((3, 4), (10, 10), (50, 20)):
        R = 2.0 ** K - 1.0
        tot_draw = tot_mix_calls = tot_mix_runs = 0.0
        while R > 1e-14:
            u = R / (1.0 + R)
            # posterior draw: the level is left with probability s per round
            s = (1 - u) + u * sum((1.0 / L) * (a / L) for a in range(1, L + 1))     # Pr[J <= a(z)], a uniform
            assert abs(s - (1 - u * (L - 1) / (2.0 * L))) < 1e-12
            # expected number of unfaithful rounds at the level: sum_i Pr[at least i rounds] * u
            tot_draw += u / s
            # mixture: per call on the main path the fresh draw deviates with probability u/L
            on_path = sum((1 - u / L) ** (J - 1) for J in range(1, L + 1)) / L        # question on the main path
            p_unf_run = -math.expm1(L * math.log1p(-u / L))                          # 1 - (1 - u/L)^L, computed stably
            assert abs(on_path - p_unf_run / u) < 1e-9
            tot_mix_calls += p_unf_run / on_path                                     # at most one unfaithful call per run
            tot_mix_runs += p_unf_run / on_path
            R *= 1 - 1.0 / L
        S, Smix = S_series(L, K)
        assert abs(tot_draw - S) < 1e-6 * S and abs(tot_mix_calls - Smix) < 1e-6 * Smix
        print(f"   L = {L:3d}, K = {K:3d}: posterior draw {tot_draw:10.3f} (series {S:10.3f});  mixture, unfaithful calls "
              f"{tot_mix_calls:10.3f} = sum_k u_k = {Smix:10.3f};  ratio {tot_draw / tot_mix_calls:.4f}")
    for L in (10, 100, 1000):
        print(f"   L = {L:5d}: Pr[mixture's question on the main path | u = 1] = {1 - (1 - 1.0 / L) ** L:.4f};  "
              f"posterior draw (L+1)/(2L) = {(L + 1) / (2.0 * L):.4f};  ratio {(1 - (1 - 1.0 / L) ** L) / ((L + 1) / (2.0 * L)):.4f}")


def simulate(L, K, nz, n, rng):
    """One rehearsal of n rounds with the posterior-draw driver on the class of Proposition 2.5.
    State: asked[z] = set of positions asked at (z, .); wrong mass relative to f is R0 * prod_z (L - |asked[z]|)/L."""
    asked = {}
    logR = math.log(2.0 ** K - 1.0)
    dead = False                                # some z has all positions asked: every g_a is refuted
    tot = 0.0
    for _ in range(n):
        u = 0.0 if dead else 1.0 / (1.0 + math.exp(-logR))
        tot += u                                # every g_a deviates on every z
        z = rng.randrange(nz)
        J = rng.randint(1, L)
        A = asked.setdefault(z, set())
        if rng.random() < u:                    # the driver is some g_a; a(z) is uniform on the unasked positions
            a = rng.choice([j for j in range(1, L + 1) if j not in A])
            question_on_path = J <= a
        else:
            question_on_path = True
        if question_on_path and J not in A:
            left = L - len(A)
            if left == 1:
                dead = True
            else:
                logR += math.log((left - 1.0) / left)
            A.add(J)
    return tot


def part3():
    print("(3) simulation of the rehearsal on the class of Proposition 2.5 (N_z = 10^6 top-level inputs, 400 rehearsals)")
    print("     L    K   rounds   sum_t E[u_t] simulated    S(L,K)    (2L^2/(L+1)) K ln2")
    rng = random.Random(7)
    for L, K, n in ((2, 6, 200), (4, 8, 400), (8, 6, 600), (16, 4, 800)):
        sims = [simulate(L, K, 10 ** 6, n, rng) for _ in range(400)]
        mean = sum(sims) / len(sims)
        se = (sum((x - mean) ** 2 for x in sims) / (len(sims) - 1)) ** 0.5 / len(sims) ** 0.5
        S, _ = S_series(L, K)
        up = 2.0 * L * L / (L + 1) * K * LN2
        assert abs(mean - S) < 5 * se + 0.02 * S and mean <= up
        print(f"   {L:4d} {K:4d} {n:7d} {mean:14.3f} +- {se:.3f} {S:12.3f} {up:14.3f}")


if __name__ == "__main__":
    part1()
    part2()
    part3()
    print("all assertions passed")
