"""Exact finite checks for the three-bit tanh posterior counterexample.

Standard library only. This checks the enumerated table, projections,
quadratic energies and Gaussian prefactor; asymptotic claims are proved
in the accompanying paper.
"""
from fractions import Fraction as F
from itertools import permutations, product
from math import prod

A = [(1,) + x for x in product((-1, 1), repeat=3)]
g = (-1, 1, 1, -1, -1, -1, -1, 1)
h = (1, 1, 1, -1, -1, -1, -1, 1)

def dot(x, y):
    return sum(a*b for a, b in zip(x, y))

def projection_coefficients(x):
    return tuple(sum(row[j]*xi for row, xi in zip(A, x)) for j in range(4))

def precision(x):
    coeff = projection_coefficients(x)
    return tuple(3*xi-F(3, 10)*dot(row, coeff) for row, xi in zip(A, x))

v, w = precision(g), precision(h)
assert projection_coefficients(g) == (-2, -2, 2, 2)
assert projection_coefficients(h) == (0, -4, 0, 0)
assert dot(g, v) == dot(h, w) == F(96, 5)
assert all(gi*vi > 0 for gi, vi in zip(g, v))
assert all(hi*wi > 0 for hi, wi in zip(h, w))
assert prod(hi*wi for hi, wi in zip(h, w))/prod(gi*vi for gi, vi in zip(g, v)) == F(189, 125)

specifications = [
    ((10, 3, 2, 1), (8, 8, 1, F(1296, 625), F(5184, 625))),
    ((10, 8, 4, 3), (64, 6, 4, F(964224, 625), F(1174176, 625))),
    ((8, 7, 6, 2), (32, 6, 0, F(1174176, 625), F(754272, 625))),
]
orbits = []
fourth_moments = []
for representative, expected in specifications:
    orbit = set()
    for perm in permutations(representative):
        for signs in product((-1, 1), repeat=4):
            coeff = tuple(x*s for x, s in zip(perm, signs))
            values = [dot(row, coeff) for row in A]
            assert 0 not in values
            orbit.add(tuple(1 if value > 0 else -1 for value in values))
    size = len(orbit)
    projection_lengths = {F(dot(projection_coefficients(x), projection_coefficients(x)), 8) for x in orbit}
    assert len(projection_lengths) == 1
    positive = sum(all(x[i] == 1 for i in (1, 2, 4, 7)) for x in orbit)
    mv = sum(dot(v, x)**4 for x in orbit)/size
    mw = sum(dot(w, x)**4 for x in orbit)/size
    row = (size, projection_lengths.pop(), positive, mv, mw)
    assert row == expected, (row, expected)
    print(row)
    orbits.append(orbit)
    fourth_moments.append((mv, mw))
assert len(set.union(*orbits)) == 104
delta = sum(mv-mw for mv, mw in fourth_moments)/3
assert delta == F(68688, 625)
assert delta/8 == F(8586, 625)
print("All exact finite checks passed; quartic log-odds coefficient =", delta/8)
