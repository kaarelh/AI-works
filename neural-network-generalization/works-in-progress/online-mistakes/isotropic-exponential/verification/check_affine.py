#!/usr/bin/env python3
"""Exact finite checks of the paper's affine minimizers.

The general proof is in the manuscript. These checks generate rational
nonnegative KKT certificates for selected instances, without trusting the
floating-point LP used to locate the certificate's support.
"""
import itertools
import json
from pathlib import Path

import numpy as np
import sympy as sp
from scipy.optimize import linprog


def calibration(k):
    diagonals = [(1,) * k]
    for i in range(k):
        row = [1] * k
        row[i] = -1
        diagonals.append(tuple(row))
    examples = {}
    for row in diagonals:
        for sign in (-1, 1):
            x = tuple(sign * a for a in row)
            examples[x + x + (-1,)] = 1
    for i in range(k):
        for upper in (-1, 1):
            x = tuple(1 if j < i else -1 if j == i else upper for j in range(k))
            y = tuple(-1 if j < i else 1 if j == i else upper for j in range(k))
            examples[x + y + (-1,)] = -1
    return examples


def query(k, t):
    return tuple(1 if t >> i & 1 else -1 for i in range(k)) + (-1,) * k + (1,)


def certificate(k, t):
    examples = calibration(k)
    examples[query(k, t)] = -1
    weights = [-t] + [2**i for i in range(k)] + [-2**i for i in range(k)] + [-t-1]
    rows = [[label * v for v in (1,) + x] for x, label in examples.items()]
    margins = [sum(a*b for a, b in zip(row, weights)) for row in rows]
    assert min(margins) >= 1
    active = [row for row, margin in zip(rows, margins) if margin == 1]
    A = np.array(active, dtype=float).T
    result = linprog(np.zeros(A.shape[1]), A_eq=A, b_eq=weights, bounds=(0, None), method='highs')
    assert result.success, result.message
    support = [i for i, v in enumerate(result.x) if v > 1e-7]
    B = sp.Matrix([active[i] for i in support]).T
    target = sp.Matrix(weights)
    assert B.rank() == B.cols
    dual = (B.T * B).inv() * B.T * target
    assert B * dual == target
    assert all(v >= 0 for v in dual)
    # Exact full-cube check for these finite instances.
    for x in itertools.product((-1, 1), repeat=2*k+1):
        score = sum(a*b for a, b in zip(weights, (1,) + x))
        assert score % 2 == 1 and abs(score) >= 1
    if t + 1 < 2**k:
        assert sum(a*b for a, b in zip(weights, (1,) + query(k, t+1))) == 1
    norm = sum(a*a for a in weights)
    assert norm == 2*(4**k-1)//3 + t*t + (t+1)**2
    # For any feasible v, <weights,v-weights> is nonnegative by
    # the certified active nonnegative conic combination. Expanding
    # ||v||^2 then proves uniqueness of this instance's minimizer.
    return {'k': k, 't': t, 'calibration_count': len(examples)-1,
            'norm_squared': norm, 'coefficients': weights,
            'active_rows': [active[i] for i in support],
            'dual': [str(v) for v in dual], 'exact_checks_passed': True}


if __name__ == '__main__':
    records = []
    for k in range(3, 8):
        for t in sorted({k, k+1, 2**k-2, 2**k-1}):
            records.append(certificate(k, t))
    out = Path(__file__).with_name('affine-certificates.json')
    out.write_text(json.dumps(records, indent=2) + '\n')
    print(json.dumps({'instances': len(records), 'exact_checks_passed': True}))
