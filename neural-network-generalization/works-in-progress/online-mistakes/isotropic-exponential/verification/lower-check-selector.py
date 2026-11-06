#!/usr/bin/env python3
"""Exact finite-instance checks for the selector construction; not a general proof."""
from fractions import Fraction
from itertools import product


def binary(bits):
    return sum((1 << i) * ((bit + 1) // 2) for i, bit in enumerate(bits))


def target(x, y, z):
    return 1 if z == -1 and binary(x) >= binary(y) else -1


def calibration(k):
    result = set()
    plus = (1,) * k
    vectors = [plus]
    for i in range(k):
        vectors.append(tuple(-1 if j == i else 1 for j in range(k)))
    for v in vectors:
        result.add((v, v, -1))
        neg = tuple(-a for a in v)
        result.add((neg, neg, -1))
    for i in range(k):
        for upper in (-1, 1):
            x = tuple(1 if j < i else -1 if j == i else upper for j in range(k))
            y = tuple(-1 if j < i else 1 if j == i else upper for j in range(k))
            result.add((x, y, -1))
    return sorted(result)


def query(k, t):
    x = tuple(1 if (t >> i) & 1 else -1 for i in range(k))
    return x, (-1,) * k, 1


def score(t, x, y, z):
    return -t - (t + 1) * z + sum((1 << i) * (a - b) for i, (a, b) in enumerate(zip(x, y)))


def norm(k, t):
    return t * t + (t + 1) ** 2 + 2 * sum(4 ** i for i in range(k))


for k in range(3, 7):
    cal = calibration(k)
    assert len(cal) <= 4 * k + 2
    cube = list(product((-1, 1), repeat=k))
    for t in range(k, 2 ** k):
        assert norm(k, t) == Fraction(1 + (2*t+1)**2, 2) + 2 * sum(4 ** i for i in range(k))
        assert all(target(x,y,z) * score(t,x,y,z) >= 1 for x,y,z in cal)
        assert all(score(t, *query(k,j)) <= -1 for j in range(k,t+1))
        if t + 1 < 2 ** k:
            assert score(t, *query(k,t+1)) == 1
            assert target(*query(k,t+1)) == -1
        for x in cube:
            for y in cube:
                for z in (-1,1):
                    value = score(t,x,y,z)
                    assert abs(value) >= 1 and value % 2 == 1
                    if t == 2 ** k - 1:
                        assert value * target(x,y,z) >= 1
    t = 2 ** k - 1
    q = norm(k,t)
    assert q == Fraction(8,3)*4**k - 2**(k+1) + Fraction(1,3)
    first_norm = Fraction(q,4**k)
    assert first_norm < Fraction(8,3)
    tanh_teacher_energy = (2*k+1)*first_norm + 8*k + 1
    assert tanh_teacher_energy < Fraction(40*k+11,3)
    mistake_count = 2**k-k-1
    assert mistake_count >= 2**(k-1)
    print(f"k={k}: {len(cal)} calibration inputs, {mistake_count} forced rounds; all exact checks passed")
