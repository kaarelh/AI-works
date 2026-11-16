#!/usr/bin/env python3
"""Referee's random sweep over the parameters of Propositions 6.2 and 6.3 of
research/prove-c/rehearsal-core.md, using the exact recursions of rehearsal-core_check_lastround.py.
(Parameters are drawn with a fixed seed; every instance is evaluated exactly.)"""
import importlib.util
import os
import random

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("lr", os.path.join(here, "rehearsal-core_check_lastround.py"))
lr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(lr)

rng = random.Random(123)
worst, bad, tight = 1e9, 0, None
for _ in range(400):
    L = rng.randint(2, 40); n = rng.randint(L, 60 * L); N = rng.randint(1, 25); lam = rng.uniform(0.01, 12)
    r = lr.example_63(L, n, N, lam, cmax=n)
    if r['Ebet'] < r['rhs61'] - 1e-12 or r['avgBet'] > L * r['Kln2'] / n + 1e-12:
        bad += 1
        print("VIOLATION of 6.3", L, n, N, lam, r['Ebet'], r['rhs61'])
    if r['rhs61'] > 0 and r['Ebet'] / r['rhs61'] < worst:
        worst, tight = r['Ebet'] / r['rhs61'], (L, n, N, round(lam, 3))
print(f"Proposition 6.3, inequality (6.1): 400 random (L, n, N, lambda) with 2 <= L <= 40, L <= n <= 60 L, 1 <= N <= 25, 0 < lambda <= 12: "
      f"violations: {bad}; smallest E beta(M^(n+1)) / (right side of (6.1)) where the right side is positive: {worst:.3f} at {tight}")
bad2, w2 = 0, 1e9
for _ in range(200):
    L = rng.randint(2, 30); n = rng.randint(L, 400 * L)
    r = lr.example_62(L, n)
    b = L * r['Kln2'] / n
    if r['ELam'] < (L - 1) / 8 * b or r['avgLam'] > b + 1e-12 or r['p_early'] < 0.6208:
        bad2 += 1
        print("VIOLATION of 6.2", L, n)
    w2 = min(w2, r['ELam'] / ((L - 1) / 8 * b))
print(f"Proposition 6.2: 200 random (L, n) with 2 <= L <= 30, L <= n <= 400 L: violations: {bad2}; "
      f"smallest E Lambda(M^(n+1)) / [((L-1)/8) L K ln2/n]: {w2:.3f}")
print("ALL CHECKS PASSED" if bad == 0 and bad2 == 0 else "SOME CHECK FAILED")
