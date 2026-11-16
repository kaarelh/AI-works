"""Checks of the variants: Propositions 2.4, 3.8, 4.3, 5.1 and Theorem 3.1 for tests with values
in [0, 1] (property-online.md).

Tests are random functions b_k: X x Y -> [0, 1] (half of them are sets), with weights
proportional to 2^-k. One test, "zero", has value 0 at the last answer of every question, and
in the sequence "constant" the human always gives the last answer: the human's value under this
test is always 0. (The rules break ties by the least answer, so they do not start with the
human's answer.)

Rules and the bounds checked at every round t <= n and for every test:
  N (Theorem 3.1)         S^2 <= (V+1)(2 ln(1/pi) + ln(V+1)),  V = number of rounds with g != 0
  decr (Proposition 2.4)  |S| <= sqrt(t) (ln(2/pi) + (1 + ln t)/2)          (c = 1)
  quad (Proposition 5.1)  sum_k pi_k S_k^2 <= sum over rounds of sum_k pi_k g_k^2
  prod (Proposition 3.8)  |S| <= min_i [ln(2 i (i+1)/pi)/eta_i + eta_i Q],  Q = sum of g^2;
                          and for the test "zero" on the sequence "constant":
                          sum_t b(x_t, a_t(x_t)) <= 4 ln(4/pi)
  trunc (Proposition 4.3) rule N on the first M_t = 2^t - 1 tests in round t:
                          |S_t(B_k)| <= (t_k - 1) + sqrt((V'+1)(2 ln(1/pi_k) + ln(V'+1))),
                          V' counted from the round t_k = ceil(log2(k+1)) in which B_k enters

Reported: the largest (left side)/(bound) over rounds and tests (must be <= 1).

Usage: python3 property-online_variants.py
"""
import math

import numpy as np

ETA = 2.0 ** -np.arange(1, 31)                   # eta_i = 2^-i, i = 1..30
RHO = 1.0 / (np.arange(1, 31) * np.arange(2, 32.0))


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def run(rule, tests, PI, n, human, rng):
    K, nx, ny = tests.shape
    S = np.zeros(K)
    V = np.zeros(K)
    Q = np.zeros(K)
    up = np.ones((K, len(ETA)))                    # prod (1 + eta_i g)
    um = np.ones((K, len(ETA)))                    # prod (1 - eta_i g)
    tk = np.ceil(np.log2(np.arange(1, K + 1) + 1.0))   # entry rounds for 'trunc'
    S2, V2 = np.zeros(K), np.zeros(K)              # books counted from entry
    quad_rhs = 0.0
    zero_total = 0.0
    worst = 0.0
    for t in range(1, n + 1):
        if rule == "N":
            c = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
        elif rule == "decr":
            c = np.sinh(S / math.sqrt(t))
        elif rule == "quad":
            c = S.copy()
        elif rule == "prod":
            c = (RHO * ETA * (up - um) / 2).sum(axis=1)
        elif rule == "trunc":
            c = np.where(tk <= t - 1, 0.5 * (G(V2 + 1, S2 + 1.0) - G(V2 + 1, S2 - 1.0)), 0.0)
        x = int(rng.integers(nx))
        a = int(np.argmin((PI * c) @ tests[:, x, :]))
        y = human(x, a)
        g = tests[:, x, a] - tests[:, x, y]
        S, V, Q = S + g, V + (g != 0), Q + g * g
        up *= 1 + ETA[None, :] * g[:, None]
        um *= 1 - ETA[None, :] * g[:, None]
        entered = tk <= t
        S2 = np.where(entered, S2 + g, 0.0)
        V2 = np.where(entered, V2 + (g != 0), 0.0)
        quad_rhs += np.sum(PI * g * g)
        zero_total += tests[0, x, a]
        if rule == "N":
            r = np.max(S * S / ((V + 1) * (2 * np.log(1 / PI) + np.log(V + 1.0)) + 1e-300))
        elif rule == "decr":
            r = np.max(np.abs(S) / (math.sqrt(t) * (np.log(2 / PI) + (1 + math.log(t)) / 2)))
        elif rule == "quad":
            r = np.sum(PI * S * S) / max(quad_rhs, 1e-300)
        elif rule == "prod":
            b = (np.log(2 / (PI[:, None] * RHO[None, :])) / ETA[None, :] + ETA[None, :] * Q[:, None]).min(axis=1)
            r = np.max(np.abs(S) / b)
        elif rule == "trunc":
            b = (tk - 1) + np.sqrt((V2 + 1) * (2 * np.log(1 / PI) + np.log(V2 + 1.0)))
            r = np.max(np.abs(S) / b)
        worst = max(worst, r)
    return worst, zero_total, S


if __name__ == "__main__":
    rng = np.random.default_rng(4)
    K, nx, ny, n = 24, 10, 5, 3000
    tests = rng.random((K, nx, ny))
    tests[::2] = (tests[::2] < 0.4)                 # every second test is a set
    tests[0] = rng.random((nx, ny))                 # the test "zero": values in [0, 1], 0 at the last answer
    tests[0, :, ny - 1] = 0.0
    w = 2.0 ** -np.arange(1, K + 1)
    PI = w / w.sum()
    P = rng.dirichlet(np.ones(ny), size=nx)
    humans = {
        "random": lambda x, a: int(rng.choice(ny, p=P[x])),
        "opposite": lambda x, a: (a + 1 + int(rng.integers(ny - 1))) % ny,
        "constant": lambda x, a: ny - 1,
    }
    print(f"{K} tests with values in [0, 1] (weights proportional to 2^-k), |X| = {nx}, |Y| = {ny}, n = {n}")
    print(f"{'human':<10}" + "".join(f"{r:>10}" for r in ("N", "decr", "quad", "prod", "trunc")))
    for hname, h in humans.items():
        row = f"{hname:<10}"
        extra = ""
        for rule in ("N", "decr", "quad", "prod", "trunc"):
            worst, zero_total, S = run(rule, tests, PI, n, h, rng)
            row += f"{worst:10.3f}"
            if rule == "prod" and hname == "constant":
                extra = (f"    prod, test 'zero' (human value always 0): sum of the imitator's values = "
                         f"{zero_total:.3f}, bound 4 ln(4/pi) = {4 * math.log(4 / PI[0]):.3f}")
        print(row)
        if extra:
            print(extra)
