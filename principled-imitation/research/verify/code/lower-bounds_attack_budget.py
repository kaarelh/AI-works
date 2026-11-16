#!/usr/bin/env python3
"""Numbers for the budget test and for the 'failure budget' form of the
conclusion (Theorem 7.1 of research/prove/lower-bounds.md), as quoted in
research/verify/lower-bounds-attack.md.

Part A.  The bounds of the file for a few (L, delta, K): necessary and
  sufficient numbers of questions, and the expected number F* = delta * r* of
  unfaithful runs that the per-run guarantee allows at the break-even point
  r* = n/L (the number of runs after which the questions spent equal the human
  answers replaced).
Part B.  Exact check of the 'failure budget' form on the needle class: for the
  protocol of Proposition 2.3 (ask a random half of the cells) the ratio
  (human answers replaced)/(answers spent) against 4F/(1 - 4F/r).
Part D.  Protocol R on the block class of Theorem 3.1, exactly: the least number
  of rounds for failure <= delta is a constant times m N, so on this class random
  questions are within a constant factor of the lower bound.
Part C.  Bayes risk with NO questions on the needle class when the prior gives
  the needles total weight eta (the rest on the zero function): eta * p.  The
  worst-case bound of N2 is not a statement about this quantity.
"""
import math
from fractions import Fraction as F


def part_a():
    print("Part A: questions (deterministic human, no fault tolerance)")
    print("   'needle' : necessary for the needle class, L/(4 delta) - L                (Corollary 2.2(1))")
    print("   'block'  : necessary for the block class, (1-10 delta) K L/(8 delta log2(L/(2 delta)))   (Theorem 3.1)")
    print("   'AB'     : sufficient, 1 + 2.7 K L/(delta log2(L/delta))                    (Theorem 3.3)")
    print("   'R'      : sufficient, L K ln2/delta                                         (R1 / Lemma 5.1')")
    print("   F*       : delta * (questions)/L = expected unfaithful runs allowed by the guarantee at break-even")
    print()
    print("        L    delta          K |     needle        block           AB            R | F*(needle)  F*(block)     F*(AB)      F*(R)")
    for (L, d, K) in [(1000, 0.01, None), (1000, 0.01, 1e3), (1000, 0.01, 1e6), (1000, 0.01, 1e9),
                      (10 ** 6, 0.001, None), (10 ** 6, 0.001, 1e9)]:
        Kmin = math.log2(L / (2 * d) + 1)
        k = Kmin if K is None else K
        needle = L / (4 * d) - L
        block = (1 - 10 * d) * k * L / (8 * d * math.log2(L / (2 * d)))
        ab = 1 + 2.7 * k * L / (d * math.log2(L / d))
        r = L * k * math.log(2) / d
        print("  %7d  %7.4f  %9.3g | %10.3g   %10.3g   %10.3g   %10.3g | %9.3g  %9.3g  %9.3g  %9.3g"
              % (L, d, k, needle, block, ab, r, d * needle / L, d * block / L, d * ab / L, d * r / L))
    print("   (rows with K = %.1f or %.1f are the needle class itself, K = log2(L/(2 delta) + 1))" % (math.log2(1000 / 0.02 + 1), math.log2(1e6 / 0.002 + 1)))


def part_b():
    print()
    print("Part B: needle class with N0 = rL/(2F) cells, r runs of the OR scaffold with L calls;")
    print("   protocol of Proposition 2.3 with n = N0/2 questions: expected failed runs among r, and amplification rL/n")
    print("     r    L      F     N0      n   exact E[failed runs] (worst member)   rL/n    4F/(1-4F/r) (upper limit for every protocol)")
    for (r, L, Fb) in [(1, 10, F(1, 20)), (10, 10, F(1, 2)), (100, 10, F(5)), (1000, 10, F(50)), (1000, 10, F(1, 4))]:
        N0 = F(r * L) / (2 * Fb)
        assert N0.denominator == 1
        N0 = int(N0)
        n = N0 // 2
        p = 1 - (1 - F(1, N0)) ** L
        failed = r * (1 - F(n, N0)) * p            # every needle: (1 - n/N0) p per run; zero function: 0
        amp = F(r * L, n)
        limit = 4 * Fb / (1 - 4 * Fb / r) if 4 * Fb < r else None
        print("  %5d %4d  %5s %6d %6d   %.4f (budget F = %s)                  %7.3f   %s"
              % (r, L, Fb, N0, n, float(failed), Fb, float(amp), "%.3f" % float(limit) if limit else "none"))
        assert failed <= Fb
        if limit:
            assert amp <= limit
    print("   (the protocol stays inside the budget F and its amplification is 4F, just below the limit)")


def part_c():
    print()
    print("Part C: Bayes failure with no questions, needle class with N0 = L/(2 delta), prior weight eta on the needles together")
    print("        L   delta    eta     Bayes failure eta*p    delta")
    for (L, d, eta) in [(100, 0.01, 0.5), (100, 0.01, 0.1), (100, 0.01, 0.01), (1000, 0.001, 0.1)]:
        N0 = int(round(L / (2 * d)))
        p = 1 - (1 - 1 / N0) ** L
        print("   %6d  %6.4f  %5.2f    %.5f                %.5f" % (L, d, eta, eta * p, d))
    print("   (eta < 1/2 already gives Bayes failure below delta without a question; the uniform prior has eta = N0/(N0+1))")


def part_d():
    """Protocol R on the block class of Theorem 3.1 (N = L/(2 delta)), exactly.
    The inputs of the block scaffold do not depend on the answers, so the question
    of a round is a uniformly chosen cell among the m N cells, independent of the
    past.  For one block: state k = number of distinct asked cells while the needle
    is unasked.  The mixture answers 1 at an unasked cell with probability 1/(N-k).
    A run in that block then fails with probability 2((1-1/N)^L - A_k),
    A_k = (k/N + ((N-k-1)/N)(1 - 1/(N-k)))^L  (see the report, Finding M2)."""
    print()
    print("Part D: Protocol R on the block class, exact (deployed mixture of a uniformly chosen round)")
    print("     m     N    L    delta     least n with failure <= delta    n/(mN)    Thm 3.1 lower bound    2.7 K L/(delta log2(L/delta))")
    for (m, N, L) in [(8, 64, 2), (16, 128, 4), (32, 512, 8), (4, 256, 8)]:
        delta = L / (2 * N)
        fail_k = []
        for k in range(N):
            A = (k / N + ((N - k - 1) / N) * (1 - 1 / (N - k))) ** L
            fail_k.append(2 * ((1 - 1 / N) ** L - A))
        dist = [0.0] * N            # dist[k] = Pr[needle unasked, k distinct cells asked]
        dist[0] = 1.0
        tot = 0.0
        n = 0
        while True:
            n += 1
            tot += sum(d * f for d, f in zip(dist, fail_k))     # failure of the mixture of round n
            if tot / n <= delta:
                break
            new = [0.0] * N
            for k, d in enumerate(dist):
                if d == 0.0:
                    continue
                stay = 1 - 1 / m + (1 / m) * (k / N)
                new[k] += d * stay
                if k + 1 < N:
                    new[k + 1] += d * (1 / m) * ((N - k - 1) / N)
                # with probability (1/m)(1/N) the needle is asked: the block is resolved
            dist = new
            if n > 200 * m * N:
                raise RuntimeError("no convergence")
        K = m * math.log2(N)
        lower = (1 - 10 * delta) * m * L / (8 * delta)
        ab = 1 + 2.7 * K * L / (delta * math.log2(L / delta))
        print("  %4d %5d %4d   %.5f     %8d                       %5.2f      %10.1f             %10.1f"
              % (m, N, L, delta, n, n / (m * N), lower, ab))
        assert 3.0 <= n / (m * N) <= 4.5
    print("   (the estimate of the report is n = 3.9 m N; the check report's simulation gave 3.4 to 3.8 m N)")


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    print("all checks passed")
