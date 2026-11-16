"""Proposition 3.6: the two-sided lower bound (vector balancing) against the rules of Section 3.

d tests B_k = {(x, y): y = 1[x_k = 1]} on questions x in {-1, 1}^d, answers {0, 1}, weights 1/d.
The adversary of the proof: choose x_t with |<x_t, S_{t-1}>| <= max_k |S_{t-1}(B_k)| by greedy
signs, and (a) let the human give the answer the imitator does not give, or (b) let the human
answer with a fair coin.

Reported: D = max over t <= n and k of |S_t(B_k)| for rule N, the lower bound of the
proposition, sqrt(n) / (sqrt(1 + n/d^2) + sqrt(n)/d), and the upper bound of Theorem 3.1,
sqrt((n+1)(2 ln d + ln(n+1))). For (b): the root mean square over 200 repetitions of
max_k |S_n(B_k)| at the last round, with the lower bound for max over t of the root mean square.

Usage: python3 property-online_lower.py
"""
import math

import numpy as np


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def greedy_question(S):
    x = np.ones(len(S))
    part = 0.0
    for k in range(len(S)):
        if part * S[k] > 0:
            x[k] = -1.0
        part += x[k] * S[k]
    return x


def play(d, n, coin, rng):
    S = np.zeros(d)
    V = np.zeros(d)
    D = 0.0
    for t in range(n):
        x = greedy_question(S)
        c = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0)) / d
        in1 = (x == 1).astype(float)           # membership of (x, 1) in B_k; (x, 0) is in B_k iff x_k = -1
        score0 = np.sum(c * (1 - in1))
        score1 = np.sum(c * in1)
        a = 0 if score0 <= score1 else 1
        y = int(rng.integers(2)) if coin else 1 - a
        g = np.where(a == 1, in1, 1 - in1) - np.where(y == 1, in1, 1 - in1)
        S, V = S + g, V + (g != 0)
        D = max(D, np.max(np.abs(S)))
    return D, np.max(np.abs(S))


if __name__ == "__main__":
    rng = np.random.default_rng(2)
    print("(a) the human gives the answer the imitator does not give")
    print(f"{'d':>6} {'n':>7} {'D (rule N)':>11} {'lower bound':>12} {'upper bound':>12} {'D/sqrt(n)':>10}")
    for (d, n) in ((10, 100), (32, 1000), (100, 1000), (100, 10000), (1000, 10000)):
        D, _ = play(d, n, False, rng)
        lower = math.sqrt(n) / (math.sqrt(1 + n / d ** 2) + math.sqrt(n) / d)
        upper = math.sqrt((n + 1) * (2 * math.log(d) + math.log(n + 1)))
        print(f"{d:6d} {n:7d} {D:11.0f} {lower:12.1f} {upper:12.1f} {D / math.sqrt(n):10.2f}")
    print()
    print("(b) the human answers with a fair coin (root mean square over 200 repetitions)")
    print(f"{'d':>6} {'n':>7} {'rms of max_k |S_n(B_k)|':>24} {'lower bound for max_t rms':>26}")
    for (d, n) in ((10, 100), (32, 1000), (100, 1000)):
        vals = [play(d, n, True, rng)[1] for _ in range(200)]
        lower = math.sqrt(n) / (math.sqrt(2 + n / d ** 2) + math.sqrt(n) / d)
        print(f"{d:6d} {n:7d} {math.sqrt(np.mean(np.square(vals))):24.1f} {lower:26.1f}")
