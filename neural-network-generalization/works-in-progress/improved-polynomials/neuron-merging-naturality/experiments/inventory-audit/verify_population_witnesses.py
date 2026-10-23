#!/usr/bin/env python3
"""Independent exhaustive interval verification of two saved population witnesses.

Original binary floats and all population sums/divisions are interpreted as
exact rational numbers before outward-rounded interval evaluation of tanh.
"""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
os.environ['OMP_NUM_THREADS'] = '1'
from fractions import Fraction
import hashlib
import itertools
import json
from pathlib import Path
import time

from mpmath import iv, mp
import mpmath
import numpy as np

HERE = Path(__file__).resolve().parent
RESULTS = HERE.parent/'results-v2'
CASES = [
    ('round2-000-heldout8-majority5-H4-adam-s0-g1.1', 'raw-unsigned-balanced'),
    ('fresh-002-majority5-H4-N32-sgd-s0', 'raw-signed-unbalanced'),
]


def rational_matrix(a):
    return [[Fraction(float(x)) for x in row] for row in a]


def interval(a):
    return iv.mpf(a.numerator)/iv.mpf(a.denominator)


def exact_reduced(weights, groups, signs, q):
    """Explicit signed block sums, independent of vectorized compression code."""
    n = len(weights[-1])
    sets = [[list(np.flatnonzero(np.asarray(g) == j)) for j in range(q)] for g in groups]
    assert all(len(block) for layer in sets for block in layer)
    result = []
    w0 = rational_matrix(weights[0])
    first = [[sum((w0[i][j]*signs[0][j] for j in sets[0][b]), Fraction())/len(sets[0][b])
              for b in range(q)] for i in range(len(w0))]
    result.append(first)
    for s, w in enumerate(weights[1:-1], 1):
        wr = rational_matrix(w)
        layer = [[sum((signs[s-1][i]*wr[i][j]*signs[s][j]
                       for i in sets[s-1][a] for j in sets[s][b]), Fraction())/len(sets[s][b])
                  for b in range(q)] for a in range(q)]
        result.append(layer)
    readout = [Fraction(float(x)) for x in weights[-1]]
    result.append([sum((readout[j]*signs[-1][j] for j in sets[-1][a]), Fraction())
                   for a in range(q)])
    return result, [[len(g) for g in layer] for layer in sets]


def interval_weights(rational_weights):
    return [[[interval(a) for a in row] for row in layer] for layer in rational_weights[:-1]] + [
        [interval(a) for a in rational_weights[-1]]]


def tanh_interval(x):
    # The denominator is positive. Natural interval evaluation gives an
    # enclosure despite its dependency overestimate; 50 decimal digits make
    # that overestimate negligible for these four-layer examples.
    e = iv.exp(2*x)
    return (e-1)/(e+1)


def evaluate_interval(w, x):
    h = [iv.mpf(int(a)) for a in x] + [iv.mpf(1)]
    for layer in w[:-1]:
        h = [tanh_interval(sum((h[i]*layer[i][j] for i in range(len(h))), iv.mpf(0)))
             for j in range(len(layer[0]))]
    return sum((a*b for a,b in zip(h,w[-1])), iv.mpf(0))


def float_forward(w, x):
    h = np.column_stack((x, np.ones(len(x))))
    for a in w[:-1]:
        h = np.tanh(h@a)
    return h@w[-1]


def verify_case(stem, key):
    start = time.monotonic()
    path = RESULTS/f'{stem}.json'
    record = json.loads(path.read_text())
    witness = record['cap_witnesses'][key]
    checkpoint = Path(record['checkpoint'])
    assert hashlib.sha256(checkpoint.read_bytes()).hexdigest() == record['checkpoint_sha256']
    with np.load(checkpoint) as data:
        weights = [data[f'w{i}'].astype(float) for i in range(record['H']+1)]
    groups = witness['groups']
    signs = [[int(s) for s in ss] for ss in witness['signs']]
    assert all(s in {-1,1} for layer in signs for s in layer)
    if not witness['signed']:
        assert all(s==1 for layer in signs for s in layer)
    n, q, d = record['N'], witness['q'], record['d']
    ev = n*sum((Fraction(float(v))**2 for v in weights[-1]),Fraction())
    assert q <= 1+ev
    reduced, sizes = exact_reduced(weights, groups, signs, q)
    if witness['balanced']:
        assert all(size in {n//q, (n+q-1)//q} for layer in sizes for size in layer)
    full_projectors=[]
    for g,s in zip(groups,signs):
        b=np.zeros((n,q));b[np.arange(n),g]=s
        counts=np.bincount(g,minlength=q)
        full_projectors.append((b/counts[None,:])@b.T)
    full_projected=[weights[0]@full_projectors[0]]
    full_projected.extend(full_projectors[j-1]@weights[j]@full_projectors[j] for j in range(1,len(weights)-1))
    full_projected.append(full_projectors[-1]@weights[-1])
    x=np.asarray(list(itertools.product([-1,1],repeat=d)))
    reduced_float=[np.array(a,dtype=float) for a in reduced]
    reduction_error=float(np.max(np.abs(float_forward(reduced_float,x)-float_forward(full_projected,x))))
    originals=[rational_matrix(w) for w in weights[:-1]]+[[Fraction(float(v)) for v in weights[-1]]]
    wi,ri=interval_weights(originals),interval_weights(reduced)
    margins=[]
    lower=mp.inf
    max_interval_width=mp.mpf(0)
    for index, xx in enumerate(x):
        z,zr=evaluate_interval(wi,xx),evaluate_interval(ri,xx)
        if bool(z>iv.mpf('.5')) and bool(zr>iv.mpf('.5')):
            certified_margin=min(mp.mpf(z._mpi_[0]),mp.mpf(zr._mpi_[0]))
            direction=1
        elif bool(z<iv.mpf('-.5')) and bool(zr<iv.mpf('-.5')):
            certified_margin=min(-mp.mpf(z._mpi_[1]),-mp.mpf(zr._mpi_[1]))
            direction=-1
        else:
            raise AssertionError(f'Not jointly saturated at input {index}: original={z}, reduced={zr}')
        lower=min(lower,certified_margin)
        for value in (z,zr):
            max_interval_width=max(max_interval_width,mp.mpf(value._mpi_[1])-mp.mpf(value._mpi_[0]))
        margins.append({'input_index':index,'sign':direction,'certified_minimum_absolute_output':str(certified_margin)})
        if index%64==0:
            print(stem,index,'of',len(x),flush=True)
    result={
        'model':stem,'witness_key':key,'domain_size':len(x),'width':n,'q':q,
        'scope':'Original unsigned balanced condition' if not witness['signed'] and witness['balanced'] else 'Signed and/or unbalanced variant, not the original unsigned balanced condition',
        'certified':True,'certified_maximum_clipped_difference':0,
        'exact_readout_energy_numerator':str(ev.numerator),'exact_readout_energy_denominator':str(ev.denominator),
        'q_energy_constraint_verified_exactly':True,'group_sizes':sizes,
        'outward_rounded_interval_decimal_precision':iv.dps,'mpmath_version':mpmath.__version__,
        'minimum_certified_absolute_output':str(lower),'maximum_interval_width':str(max_interval_width),
        'independent_float_reduction_error':reduction_error,
        'checkpoint_sha256':hashlib.sha256(checkpoint.read_bytes()).hexdigest(),
        'source_result_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'groups':groups,'signs':signs,
        'per_input_certificates':margins,'elapsed_seconds':time.monotonic()-start,
        'qualification':'Numerical interval certificate relying on mpmath directed rounding and exp; not Lean verified. Exact rational population sums used before interval evaluation, not rounded NumPy averaged weights.'
    }
    (HERE/f'certificate-{stem}-{key}.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'per_input_certificates','groups','signs','group_sizes'}},indent=2),flush=True)
    return result


if __name__=='__main__':
    mp.dps=60
    iv.dps=50
    for stem,key in CASES:
        verify_case(stem,key)
