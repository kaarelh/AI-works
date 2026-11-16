"""One-sided rates: tests that the human never satisfies (property-online.md, Example 2.3 and Section 3).

(1) Example 2.3. Questions 2, 3, 4, ... (x_t = t + 1); answers {0, 1, 2}; the human answers 0
    to odd questions and 2 to even ones, so never 1. Two tests:
        B = all pairs with answer 1                       (weight beta)
        D = {(x, 1): x odd} united with {(x, 2): x even}  (weight delta)
    The rule of Theorem Pr5 with rate eta (least answer among the minimisers) gives the answer 1
    exactly  min(floor(n/2), N*)  times in n rounds, with
        N* = least integer N >= 0 with  beta sinh(eta N) >= delta sinh(eta).
    The script simulates the rule and compares the count with this formula, and with the bound
    of Theorem Pr5, ln(2/beta)/eta + n eta/2. It also runs the rules N and NH of Section 3,
    whose bounds for the count are  2L + ln(2L + 4) + 2  with L = ln(1/beta)  (rule N,
    Corollary 3.2(b))  and  2 + log2(1/beta)  (rule NH, Theorem 3.3(ii)).

(2) Proposition 3.5 (lower bound). Questions 1..m, answers {0, 1}, the 2^m tests
    B_c = {(x, y): y != c(x)} with weight 2^-m each. Against the human who answers 1 - a_t(x_t),
    the test B_c with c = the human's answers is never satisfied by the human and is satisfied by
    the imitator in all m rounds. The script runs rule NH for m <= 12 and prints the count.

Usage: python3 property-online_fastrate.py
"""
import itertools
import math

import numpy as np


def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def slope(rule, S, V, pure, eta):
    if rule == "lead":
        return math.sinh(eta * S)
    cN = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
    if rule == "N":
        return cN
    cH = math.copysign(2.0 ** (V - 1), S) if (V >= 1 and pure) else 0.0
    return 0.5 * cN + 0.5 * cH


def example(rule, n, beta, delta, eta=None):
    """Returns the number of rounds with answer 1, and the final states of B and D."""
    st = {"B": [0, 0, True], "D": [0, 0, True]}          # S, V, pure
    w = {"B": beta, "D": delta}

    def member(name, x, y):
        if name == "B":
            return y == 1
        return (y == 1 and x % 2 == 1) or (y == 2 and x % 2 == 0)

    count = 0
    for t in range(1, n + 1):
        x = t + 1
        scores = []
        for y in (0, 1, 2):
            scores.append(sum(w[k] * slope(rule, st[k][0], st[k][1], st[k][2], eta) * member(k, x, y)
                              for k in ("B", "D")))
        a = int(np.argmin(scores))                         # least answer among the minimisers
        h = 0 if x % 2 == 1 else 2
        count += a == 1
        for k in ("B", "D"):
            g = member(k, x, a) - member(k, x, h)
            if g:
                S, V, pure = st[k]
                st[k] = [S + g, V + 1, pure and abs(S + g) == V + 1]
    return count, st


def n_star(beta, delta, eta):
    N = 0
    while beta * math.sinh(eta * N) < delta * math.sinh(eta):
        N += 1
    return N


def lower_bound(m):
    """Rule NH against the opposite human on the 2^m table tests."""
    cs = np.array(list(itertools.product((0, 1), repeat=m)))        # cs[k, x] = c_k(x)
    K = len(cs)
    PI = np.full(K, 2.0 ** -m)
    S = np.zeros(K)
    V = np.zeros(K)
    pure = np.ones(K, dtype=bool)
    human = []
    for x in range(m):
        cN = 0.5 * ((V + 2.0) ** -0.5) * (np.exp((S + 1) ** 2 / (2 * (V + 2))) - np.exp((S - 1) ** 2 / (2 * (V + 2))))
        cH = np.where((V >= 1) & pure, np.sign(S) * 2.0 ** (V - 1), 0.0)
        c = 0.5 * cN + 0.5 * cH
        score = [np.sum(PI * c * (cs[:, x] != y)) for y in (0, 1)]
        a = int(np.argmin(score))
        y = 1 - a
        human.append(y)
        g = (cs[:, x] != a).astype(float) - (cs[:, x] != y)
        newS = S + g
        pure &= ~((g != 0) & (np.abs(newS) < V + 1))
        S, V = newS, V + (g != 0)
    k = int(np.where((cs == np.array(human)).all(axis=1))[0][0])
    return int(S[k]), int(V[k])


if __name__ == "__main__":
    print("(1) Example 2.3: number of rounds at which the imitator gives the answer 1 (the human never does)")
    print(f"{'n':>8} {'beta':>10} {'lead: count':>12} {'formula':>9} {'Pr5 bound':>10} "
          f"{'N: count':>9} {'bound':>7} {'NH: count':>10} {'bound':>7}")
    for n in (100, 1000, 10000, 100000):
        for beta in (0.5 / math.sqrt(n), 0.5 / n, 0.5 / n ** 2):
            delta = 0.5
            eta = 1 / math.sqrt(n)
            c_lead, _ = example("lead", n, beta, delta, eta)
            formula = min(n // 2, n_star(beta, delta, eta))
            b_lead = math.log(2 / beta) / eta + n * eta / 2
            c_N, _ = example("N", n, beta, delta)
            L = math.log(1 / beta)
            b_N = 2 * L + math.log(2 * L + 4) + 2
            c_NH, _ = example("NH", n, beta, delta)
            b_NH = 2 + math.log2(1 / beta)
            print(f"{n:8d} {beta:10.2e} {c_lead:12d} {formula:9d} {b_lead:10.1f} "
                  f"{c_N:9d} {b_N:7.1f} {c_NH:10d} {b_NH:7.1f}")
    print()
    print("(2) Proposition 3.5: rule NH, 2^m table tests of weight 2^-m, the human answers 1 - a_t(x_t)")
    print(f"{'m':>4} {'count for the never-satisfied test':>36} {'bound 2 + m':>12}")
    for m in (1, 2, 4, 8, 12):
        s, v = lower_bound(m)
        print(f"{m:4d} {s:36d} {2 + m:12d}")
