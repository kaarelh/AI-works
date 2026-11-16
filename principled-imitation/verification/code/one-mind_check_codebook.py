"""Referee's check for the table of Section 6 of research/prove-c/one-mind.md, cell
"stochastic human / one member for good": a class in which the HIGHEST-WEIGHT consistent member
(not only a posterior draw) is a function and so has TV(Q_s, Q_P) = 1 - (1/2)^3 = 7/8 per run of
three calls at one input (human: fair coin, eps = 1/2).

Class: P (fair coin at every input) with weight 2^-K, and a codebook of 2^m functions s_1..s_{2^m},
each with weight (1 - 2^-K) 2^-m, whose values are independent fair bits (random codebook).
After n questions at distinct inputs (any driver; distinct inputs are the generic case when the
top-level set is large) a function survives with probability 2^-n, independently of the others.
Posterior of P: 2^-K 2^-n ; of a surviving s: (1 - 2^-K) 2^-m. With m = n + K - 2 a survivor
outweighs P, and one exists with probability 1 - (1 - 2^-n)^(2^m) >= 1 - exp(-2^(K-2)).
Usage: python3 one-mind_check_codebook.py
"""
import math
import numpy as np

rng = np.random.default_rng(1)
print(" K   n   m   trials  freq(MAP is a function)  formula 1-(1-2^-n)^(2^m)  lower bd 1-exp(-2^(K-2))")
for K, n in ((3, 8), (4, 8), (4, 12), (5, 10), (6, 10)):
    m = n + K - 2
    assert (1 - 2.0 ** -K) * 2.0 ** -m > 2.0 ** -K * 2.0 ** -n
    trials, hits = 2000, 0
    for _ in range(trials):
        answers = rng.integers(0, 2, size=n)                 # the human's answers (fair coin)
        code = rng.integers(0, 2, size=(2 ** m, n), dtype=np.int8)  # codebook values at the asked inputs
        survivors = np.all(code == answers, axis=1).sum()
        hits += survivors > 0
    formula = 1 - (1 - 2.0 ** -n) ** (2 ** m)
    lb = 1 - math.exp(-2 ** (K - 2))
    assert formula >= lb - 1e-12
    print(f"{K:2d} {n:3d} {m:3d} {trials:7d} {hits / trials:20.4f} {formula:24.4f} {lb:24.4f}")
# TV between a function's run (c,c,c) and three fair coins
tv = 0.5 * (abs(1 - 1 / 8) + 7 * (1 / 8))
print("TV(Q_s, Q_P) for three calls at one input, eps = 1/2:", tv)
assert abs(tv - 7 / 8) < 1e-12
print("all assertions passed")
