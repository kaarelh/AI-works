"""Exact rational certificate for an affine cube margin energy of 701/2.

No optimizer, floating-point arithmetic, external package, or assertion about
online mistakes is used. Numerical search only suggested this certificate.
"""
from fractions import Fraction as F
from itertools import product


def dot(u, v):
    return sum(a*b for a, b in zip(u, v))


def main():
    cube = list(product((-1, 1), repeat=8))
    seed = (13, 7, 6, 6, 4, 4, 4, 3, 2)
    optimum = tuple(map(F, (13, 7, 6, 6, 4, 4, 4))) + (F(5, 2), F(5, 2))
    rows = []
    for x in cube:
        score = dot(seed, (1, *x))
        assert score != 0
        label = 1 if score > 0 else -1
        rows.append(tuple(label*t for t in (1, *x)))
    assert all(dot(row, optimum) >= 1 for row in rows)
    active = (28, 35, 67, 96, 131, 132, 136, 144)
    multipliers = tuple(F(k, 4) for k in (145, 171, 171, 209, 373, 111, 111, 111))
    assert all(t >= 0 for t in multipliers)
    assert all(dot(rows[i], optimum) == 1 for i in active)
    assert all(sum(t*rows[i][j] for t, i in zip(multipliers, active)) == optimum[j]
               for j in range(9))
    assert dot(optimum, optimum) == F(701, 2)
    assert sum(multipliers) == F(701, 2)
    # Feasibility and this conic representation are the exact KKT certificate:
    # for any feasible v, optimum·(v-optimum) >= 0. Therefore
    # ||v||² = ||optimum||² + 2 optimum·(v-optimum) + ||v-optimum||² >= 701/2.
    print('Verified all 256 margin constraints and the exact dual certificate.')
    print('Unique minimum affine squared norm: 701/2 (not an integer).')


if __name__ == '__main__':
    main()
