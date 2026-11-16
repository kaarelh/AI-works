"""Comparisons with the Bayes mixture (property-online.md, Section 8).

(1) Proposition 8.1 (memorisers). Questions 1..N, answers 0..A; the answer 0 is "bad"; the human
    is a function f with values in 1..A and weight 2^-K. For every set D of questions and every
    table tau: D -> {1..A} the memoriser m(D, tau) answers tau(x) on D and 0 elsewhere; its weight
    is (1/2) p^|D| (1-p)^(N-|D|) A^-|D|. Claim: after the human has answered k distinct questions,
    the mixture answers a new question with 0 with probability (1-p) mu_k,
        mu_k = (1/2)(p/A)^k / ((1/2)(p/A)^k + 2^-K).
    (1a) brute force over all hypotheses for N = 5, A = 2 against the formula;
    (1b) for larger parameters: the expected number of bad answers of the mixture on n distinct
         questions (from the formula), the lower bound (1-p) min(n, k*+1)/2 with
         k* = floor((K-1)/log2(A/p)), the upper bound K ln 2 for all errors, and the number of
         bad answers of rule NH with the test R = {answer != 0} of weight 1/2 in its family
         (bound K(R) + 2 = 3). The family of rule NH also contains the tests "answer = c",
         c = 0..A, with total weight 1/2, and the human answers a fixed random function.

(2) Proposition 8.2(a): in Example 2.3 the rule of Theorem Pr5 (eta = 1/sqrt(n)) gives
    min(floor(n/2), N*) answers that the human never gives; the Bayes mixture of the class
    {f, f'} with weights 1/2 errs at most ln 2 times in expectation (here: exactly 1/2 if f'
    differs from f at the first question).

(3) Example 7.1: a family that does not contain the property "y = x mod 2".

Usage: python3 property-online_mixture.py
"""
import itertools
import math

import numpy as np


def brute_force(N, A, p, K, f, k):
    """Posterior probability that the mixture answers 0 at question k+1 (new) after the human
    has answered questions 1..k."""
    num = den = 0.0
    for r in range(N + 1):
        for D in itertools.combinations(range(N), r):
            for tau in itertools.product(range(1, A + 1), repeat=r):
                table = dict(zip(D, tau))
                # consistent with f on questions 0..k-1 ?
                if all((x in table and table[x] == f[x]) for x in range(k)):
                    w = 0.5 * p ** r * (1 - p) ** (N - r) * A ** (-r)
                    den += w
                    if k not in table:
                        num += w
    den += 2.0 ** -K            # the human itself, which never answers 0
    return num / den


def mu(k, A, p, K):
    a = 0.5 * (p / A) ** k
    return a / (a + 2.0 ** -K)


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def rule_NH_bad_answers(A, n, rng):
    """Tests: R = {y != 0} (weight 1/2); E_c = {y = c}, c = 0..A (weight 1/(2(A+1)) each).
    The human answers f(x) in 1..A, f random; questions are distinct, so only the answers matter."""
    ny = A + 1
    tests = np.zeros((A + 2, ny))
    tests[0, 1:] = 1.0                       # R
    for c in range(ny):
        tests[1 + c, c] = 1.0
    PI = np.array([0.5] + [0.5 / ny] * ny)
    S = np.zeros(A + 2)
    V = np.zeros(A + 2)
    pure = np.ones(A + 2, dtype=bool)
    bad = 0
    for t in range(n):
        cN = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
        cH = np.where((V >= 1) & pure, np.sign(S) * 2.0 ** np.minimum(V - 1, 1000), 0.0)
        score = (PI * (0.5 * cN + 0.5 * cH)) @ tests
        a = int(np.argmin(score))            # ties: least answer, which is the bad answer 0
        y = int(rng.integers(1, ny))
        bad += a == 0
        g = tests[:, a] - tests[:, y]
        newS = S + g
        pure &= ~((g != 0) & (np.abs(newS) < V + 1))
        S, V = newS, V + (g != 0)
    return bad


if __name__ == "__main__":
    rng = np.random.default_rng(11)
    print("(1a) memorisers, brute force against the formula (N = 5, A = 2)")
    N, A = 5, 2
    f = [1, 2, 2, 1, 1]
    for (p, K) in ((0.5, 6.0), (0.1, 10.0), (0.9, 3.0)):
        errs = [abs(brute_force(N, A, p, K, f, k) - (1 - p) * mu(k, A, p, K)) for k in range(N)]
        print(f"    p = {p}, K = {K}: largest |brute force - formula| over k = 0..4: {max(errs):.2e}")
    print()
    print("(1b) expected number of bad answers on n distinct questions")
    print(f"{'K':>6} {'A':>4} {'p':>6} {'n':>6} {'k*':>5} {'mixture: bad answers':>21} {'lower bound':>12} "
          f"{'K ln 2':>8} {'rule NH: bad answers':>21} {'bound':>6}")
    for (K, A, p) in ((50, 4, 0.5), (200, 4, 0.5), (1000, 4, 0.5), (1000, 16, 0.05)):
        kstar = math.floor((K - 1) / math.log2(A / p))
        for n in (kstar + 1, 10 * (kstar + 1)):
            mix = sum((1 - p) * mu(t - 1, A, p, K) for t in range(1, n + 1))
            lower = (1 - p) * min(n, kstar + 1) / 2
            nh = rule_NH_bad_answers(A, n, rng)
            print(f"{K:6d} {A:4d} {p:6.2f} {n:6d} {kstar:5d} {mix:21.2f} {lower:12.2f} {K * math.log(2):8.1f} "
                  f"{nh:21d} {3:6d}")
    print()
    print("(2) Example 2.3: answers the human never gives, rule of Theorem Pr5 with eta = 1/sqrt(n), "
          "beta = 1/(2n), delta = 1/2; Bayes mixture of {f, f'}: 0.5 errors in expectation")
    for n in (400, 10000, 250000):
        eta, beta, delta = 1 / math.sqrt(n), 0.5 / n, 0.5
        Nstar = 0
        while beta * math.sinh(eta * Nstar) < delta * math.sinh(eta):
            Nstar += 1
        print(f"    n = {n:7d}: min(n/2, N*) = {min(n // 2, Nstar):6d},  (1/2) sqrt(n) ln n = "
              f"{0.5 * math.sqrt(n) * math.log(n):9.1f}")
    print()
    print("(3) Example 7.1: family {answer = 1}, human f(x) = x mod 2, questions 1..n, rule N")
    for n in (10, 1000):
        S, V, wrong = 0.0, 0.0, 0
        for t in range(1, n + 1):
            c = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
            a = 1 if c < 0 else 0                     # least minimiser of c * 1[y = 1]
            y = t % 2
            wrong += a != y
            g = (a == 1) - (y == 1)
            S, V = S + g, V + (g != 0)
        print(f"    n = {n:5d}: wrong answers = {wrong}, final book S_n = {S:+.0f}")
