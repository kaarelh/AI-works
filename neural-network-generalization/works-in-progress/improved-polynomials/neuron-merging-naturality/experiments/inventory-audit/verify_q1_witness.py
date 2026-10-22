#!/usr/bin/env python3
"""Separate exact-coefficient interval certificate for the output-aware q=1 witness."""
from fractions import Fraction
import hashlib
import itertools
import json
from pathlib import Path
import time

from mpmath import iv, mp
import mpmath
import numpy as np

from verify_population_witnesses import (exact_reduced, interval_weights,
                                         evaluate_interval, rational_matrix)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
STEM = 'fresh-000-majority5-H4-N32-adam-s0'


def main():
    started = time.monotonic()
    mp.dps = 60
    iv.dps = 50
    search_path = ROOT/'q1-output-results'/f'{STEM}.json'
    baseline_path = ROOT/'results-v3'/f'{STEM}.json'
    search = json.loads(search_path.read_text())
    baseline = json.loads(baseline_path.read_text())
    witness = search['best']
    assert witness['q'] == 1 and witness['signed'] and witness['balanced']
    checkpoint = Path(search['checkpoint'])
    sha = hashlib.sha256(checkpoint.read_bytes()).hexdigest()
    assert sha == search['checkpoint_sha256'] == baseline['checkpoint_sha256']
    with np.load(checkpoint) as a:
        weights = [a[f'w{i}'].astype(float) for i in range(baseline['H']+1)]
    n, d = len(weights[-1]), weights[0].shape[0]-1
    groups = witness['groups']
    signs = [[int(s) for s in layer] for layer in witness['signs']]
    assert all(len(g)==n and set(g)=={0} for g in groups)
    assert all(s in {-1,1} for layer in signs for s in layer)
    ev = n*sum((Fraction(float(v))**2 for v in weights[-1]),Fraction())
    assert 1 <= 1+ev
    reduced, sizes = exact_reduced(weights, groups, signs, 1)
    assert sizes == [[n] for _ in range(baseline['H'])]
    original = [rational_matrix(w) for w in weights[:-1]] + [[Fraction(float(v)) for v in weights[-1]]]
    wi, ri = interval_weights(original), interval_weights(reduced)
    lower = mp.inf
    max_width = mp.mpf(0)
    per_input = []
    for index, x in enumerate(itertools.product([-1,1],repeat=d)):
        z, zr = evaluate_interval(wi,x), evaluate_interval(ri,x)
        if bool(z>iv.mpf('.5')) and bool(zr>iv.mpf('.5')):
            sign = 1
            margin = min(mp.mpf(z._mpi_[0]),mp.mpf(zr._mpi_[0]))
        elif bool(z<iv.mpf('-.5')) and bool(zr<iv.mpf('-.5')):
            sign = -1
            margin = min(-mp.mpf(z._mpi_[1]),-mp.mpf(zr._mpi_[1]))
        else:
            raise AssertionError(f'Not equally saturated at input {index}: {z}, {zr}')
        lower = min(lower, margin)
        max_width = max(max_width,*(mp.mpf(a._mpi_[1])-mp.mpf(a._mpi_[0]) for a in (z,zr)))
        per_input.append(dict(input_index=index,sign=sign,certified_minimum_absolute_output=str(margin)))
    result = dict(
        model=STEM, q=1, width=n, hidden_depth=baseline['H'], domain_size=2**d,
        scope='Signed balanced population restriction; not the original unsigned restriction.',
        certified=True, certified_maximum_clipped_difference=0,
        minimum_certified_absolute_output=str(lower),maximum_interval_width=str(max_width),
        readout_energy=float(ev),exact_energy_numerator=str(ev.numerator),exact_energy_denominator=str(ev.denominator),
        q_energy_constraint_verified_exactly=True,
        groups=groups,signs=signs,group_sizes=sizes,
        exact_reduced_weight_fractions=[[[str(a) for a in row] for row in layer] for layer in reduced[:-1]]+[[str(a) for a in reduced[-1]]],
        per_input_certificates=per_input,
        checkpoint_sha256=sha,search_result_sha256=hashlib.sha256(search_path.read_bytes()).hexdigest(),
        baseline_result_sha256=hashlib.sha256(baseline_path.read_bytes()).hexdigest(),
        search_source_sha256=hashlib.sha256((ROOT/'q1_output_search.py').read_bytes()).hexdigest(),
        helper_source_sha256=hashlib.sha256((HERE/'verify_population_witnesses.py').read_bytes()).hexdigest(),
        interval_precision_decimal_digits=iv.dps,mpmath_version=mpmath.__version__,
        elapsed_seconds=time.monotonic()-started,
        qualification='Outward-rounded interval proof using mpmath arithmetic/exp and exact rational block sums; not Lean verified. No labels used or read by this verification.'
    )
    (HERE/'certificate-fresh-000-output-aware-q1-signed-balanced.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'groups','signs','group_sizes','per_input_certificates','exact_reduced_weight_fractions'}},indent=2))


if __name__=='__main__':
    main()
