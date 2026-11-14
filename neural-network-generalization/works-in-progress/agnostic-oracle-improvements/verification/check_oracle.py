#!/usr/bin/env python3
"""Finite-dictionary sanity checks; these are not a proof of the paper."""
import itertools
import json
import math
import random

rng = random.Random(20261114)
eta = 1 / 20


def normalize(xs):
    total = sum(xs)
    return [x / total for x in xs]


def compositions(n, k):
    if k == 1:
        yield (n,)
    else:
        for i in range(n + 1):
            for tail in compositions(n - i, k - 1):
                yield (i,) + tail


worst_tilting_gap = -math.inf
for _ in range(10000):
    values = [rng.uniform(-1, 1) for _ in range(6)]
    q = normalize([rng.expovariate(1) for _ in values])
    y = rng.uniform(-1, 1)
    losses = [(a - y) ** 2 for a in values]
    p = normalize([qi * math.exp(-eta * li) for qi, li in zip(q, losses)])
    left = (sum(qi * a for qi, a in zip(q, values)) - y) ** 2
    right = sum(pi * li for pi, li in zip(p, losses))
    gap = left - right
    assert gap <= 1e-12, gap
    worst_tilting_gap = max(worst_tilting_gap, gap)

worst_oracle_gap = -math.inf
case_count = 0
# All possible datasets are summed by multinomial counts, rather than sampled.
outcomes = list(itertools.product(range(2), [-1.0, 1.0]))
for _ in range(80):
    probabilities = normalize([rng.expovariate(1) for _ in outcomes])
    predictors = [[rng.uniform(-1, 1) for _ in range(2)] for _ in range(5)]
    prior = normalize([rng.expovariate(1) for _ in predictors])
    losses = [[(f[x] - y) ** 2 for x, y in outcomes] for f in predictors]
    risks = [sum(p * l for p, l in zip(probabilities, ls)) for ls in losses]
    for n in range(9):
        expected_risk = 0.0
        total_mass = 0.0
        for counts in compositions(n, len(outcomes)):
            mass = float(math.factorial(n))
            for p, count in zip(probabilities, counts):
                mass *= p ** count / math.factorial(count)
            posterior = normalize([
                pi * math.exp(-eta * sum(c * l for c, l in zip(counts, ls)))
                for pi, ls in zip(prior, losses)
            ])
            mean = [sum(p * f[x] for p, f in zip(posterior, predictors)) for x in range(2)]
            risk = sum(p * (mean[x] - y) ** 2 for p, (x, y) in zip(probabilities, outcomes))
            expected_risk += mass * risk
            total_mass += mass
        assert abs(total_mass - 1) < 1e-10
        oracle = -math.log(sum(pi * math.exp(-eta * (n + 1) * r)
                               for pi, r in zip(prior, risks))) / (eta * (n + 1))
        gap = expected_risk - oracle
        assert gap <= 1e-10, (n, gap)
        worst_oracle_gap = max(worst_oracle_gap, gap)
        case_count += 1

print(json.dumps({
    "seed": 20261114,
    "inverse_temperature": eta,
    "tilting_cases": 10000,
    "worst_tilting_left_minus_right": worst_tilting_gap,
    "exact_expected_oracle_cases": case_count,
    "worst_expected_risk_minus_variational_oracle": worst_oracle_gap,
    "status": "passed; numerical sanity checks, not formal verification"
}, indent=2))
