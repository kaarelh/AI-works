#!/usr/bin/env python3
"""Editor's checks for proofs/lower-bounds.md (16 November 2026).

Part A.  Proposition 3.10: on the block class with N = L/(2 delta), Protocol R
  with n = 4 m N rounds, deploying the mixture of a uniformly chosen round,
  has failure <= delta.  The failure is computed exactly (same state space as
  in lower-bounds_attack_budget.py, part D, written independently): for one
  block, the state is the number k of distinct asked cells while the needle is
  unasked; a resolved block (needle asked) never fails.

Part B.  Proposition 5.7 (counterexample to "failure <= majorant(L K ln2/n)"
  for a human who is not deterministic): two samplers with P(1) = 1/2 +- theta,
  prior 1/2 each, human P_-, one call.  Excess failure of the deployed mixture
  M^(T) over the human system: 2 theta * mean_t E[w_t], w_t the posterior weight
  of P_+ after t-1 answers.  Computed by dynamic programming over the number of
  ones, independently of lower-bounds_attack_sharper.py.

Part C.  Arithmetic of the corrected statements: Theorem 3.3(3) (the factor
  2 + ln 2 < 2.7), the example for Theorem 3.3(5) (7/64 < 1/9), Remark 3.5
  (2/(1 - 1/e) < 3.2), the break-even numbers of Section 7.
"""
import math
from fractions import Fraction as F


def part_a():
    print("Part A: Proposition 3.10, Protocol R on the block class, n = 4 m N rounds")
    print("     m     N    L    delta     exact failure at n = 4mN   <= delta ?   bound 4 delta mN/n")
    for (m, N, L) in [(1, 8, 1), (2, 16, 2), (8, 64, 2), (16, 128, 4), (4, 256, 8), (32, 512, 8), (3, 40, 4)]:
        delta = L / (2 * N)
        # failure of the round-t mixture for a run in a block whose needle is unasked, k cells asked
        fail_k = []
        for k in range(N):
            none_and_zero = (k / N + ((N - k - 1) / N) * (1 - 1 / (N - k))) ** L   # needle not visited, all answers 0
            fail_k.append(2 * ((1 - 1 / N) ** L - none_and_zero))
            assert fail_k[-1] <= 2 * L / N + 1e-12          # the bound used in the proof
        dist = [0.0] * N
        dist[0] = 1.0
        n = 4 * m * N
        tot = 0.0
        for t in range(1, n + 1):
            tot += sum(d * f for d, f in zip(dist, fail_k))
            new = [0.0] * N
            for k, d in enumerate(dist):
                if d == 0.0:
                    continue
                new[k] += d * (1 - 1 / m + (1 / m) * (k / N))
                if k + 1 < N:
                    new[k + 1] += d * (1 / m) * ((N - k - 1) / N)
            dist = new
        fail = tot / n
        print("  %4d %5d %4d   %.5f     %.6f                    %s        %.5f"
              % (m, N, L, delta, fail, fail <= delta, 4 * delta * m * N / n))
        assert fail <= delta + 1e-12


def excess(theta, n):
    p = 0.5 - theta
    lr = math.log((0.5 + theta) / (0.5 - theta))
    dist = [1.0]
    tot = 0.0
    for t in range(1, n + 1):
        m = t - 1
        tot += sum(pr / (1.0 + math.exp(-(2 * s - m) * lr)) for s, pr in enumerate(dist))
        new = [0.0] * (m + 2)
        for s, pr in enumerate(dist):
            new[s] += pr * (1 - p)
            new[s + 1] += pr * p
        dist = new
    return 2 * theta * tot / n


def part_b():
    print()
    print("Part B: Proposition 5.7, excess failure of M^(T) over the human system (K = 1, L = 1)")
    print("   theta      n     excess      ln2/n (candidate)   ratio    sqrt(ln2/(2n)) (Proposition 5.7)")
    for (theta, n) in [(1 / 20, 20), (1 / 20, 60), (1 / 10, 60), (0.02, 5000), (0.01, 5000)]:
        ex = excess(theta, n)
        cand = math.log(2) / n
        pin = math.sqrt(math.log(2) / (2 * n))
        print("   %.4f  %5d   %.6f    %.6f            %6.2f   %.6f" % (theta, n, ex, cand, ex / cand, pin))
        assert ex <= pin
    print("   growth of the ratio for theta = 1/(2 sqrt n):")
    last = 0.0
    for n in (100, 400, 1600):
        theta = 1 / (2 * math.sqrt(n))
        ex = excess(theta, n)
        r = ex / (math.log(2) / n)
        print("   n = %5d   theta = %.4f   ratio = %.2f   (ratio/sqrt(n) = %.3f)" % (n, theta, r, r / math.sqrt(n)))
        assert r > last
        last = r


def part_c():
    print()
    print("Part C: arithmetic")
    # Theorem 3.3(3): u/(u - log2 u) + ln 2 <= 2 + ln 2 < 2.7 for u >= 4
    worst = max(u / (u - math.log2(u)) + math.log(2) for u in [4 + 0.01 * i for i in range(20000)])
    print("   max over u in [4, 204] of u/(u - log2 u) + ln 2 = %.4f (< 2.7)" % worst)
    assert worst < 2.7
    # example for Theorem 3.3(5)
    assert F(7, 8) * F(1, 8) < F(1, 9)
    print("   (7/8)(1/8) = 7/64 = %.6f < 1/9 = %.6f" % (7 / 64, 1 / 9))
    # Remark 3.5
    print("   2/(1 - 1/e) = %.4f (< 3.2)" % (2 / (1 - 1 / math.e)))
    assert 2 / (1 - 1 / math.e) < 3.2
    # Section 7, break-even numbers for L = 1000, delta = 0.01, K = 1e9
    L, d, K = 1000, 0.01, 1e9
    r_ = L * K * math.log(2) / d
    ab = 1 + 2.7 * K * L / (d * math.log2(L / d))
    blk = (1 - 10 * d) * K * L / (8 * d * math.log2(L / (2 * d)))
    ndl = L / (4 * d) - L
    print("   L = 1000, delta = 0.01, K = 1e9: questions R %.3g, AB %.3g, block %.3g, needle %.0f" % (r_, ab, blk, ndl))
    print("   allowed failed runs at break-even: R %.3g, AB %.3g, block %.3g, needle %.2f"
          % (d * r_ / L, d * ab / L, d * blk / L, d * ndl / L))
    # Proposition 3.7: constant
    print("   ln(1.5) = %.4f (> 0.4); ln 2/0.1 = %.2f (< 7)" % (math.log(1.5), math.log(2) / 0.1))
    assert math.log(1.5) > 0.4 and math.log(2) / 0.1 < 7


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    print()
    print("all checks passed")
