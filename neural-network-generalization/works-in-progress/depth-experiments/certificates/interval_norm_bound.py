#!/usr/bin/env python3
"""Interval-verified ALL-INPUT positive numerical-stability certificates.

For each hidden-to-hidden matrix W, verify g^2 I-W^T W positive definite
by interval LDL decomposition. Its entries are formed from EXACT integer
Gram matrices of the saved dyadic weights. The final gain/radius inequality
is checked with exact rational arithmetic. No input grid is involved.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,json,time
from pathlib import Path
from fractions import Fraction
import numpy as np
import mpmath as mp

ROOT=Path(__file__).resolve().parent
mp.iv.dps=90


def as_iv_fraction(f):
    return mp.iv.mpf(f.numerator)/mp.iv.mpf(f.denominator)


def rational_record(f):
    # Decimal integer strings preserve arbitrary-size exact values across JSON readers.
    return dict(numerator=str(f.numerator),denominator=str(f.denominator))


def operator_square_upper(w,candidate=None):
    if candidate is None:
        candidate=Fraction.from_float(float((np.linalg.norm(w,2)*(1+1e-6))**2))
    pairs=[float(v).as_integer_ratio()for v in w.flat]
    denominator=max(q for _,q in pairs)
    integer=np.array([a*(denominator//q)for a,q in pairs],dtype=object).reshape(w.shape)
    gram=integer.T@integer
    dim=w.shape[1];denom2=denominator**2
    matrix=[[mp.iv.mpf(-int(gram[i,j]))/mp.iv.mpf(denom2)
             +(as_iv_fraction(candidate) if i==j else 0)
             for j in range(dim)]for i in range(dim)]
    lower=[[mp.iv.mpf(0)for _ in range(dim)]for _ in range(dim)];diagonal=[]
    smallest=None
    for j in range(dim):
        pivot=matrix[j][j]-sum((lower[j][k]**2*diagonal[k]for k in range(j)),mp.iv.mpf(0))
        if not bool(pivot.a>0):
            raise ArithmeticError(f'Interval LDL cannot establish positive pivot at {j}: {pivot}')
        diagonal.append(pivot);lower[j][j]=mp.iv.mpf(1)
        bound=float(pivot.a)
        smallest=bound if smallest is None else min(smallest,bound)
        for i in range(j+1,dim):
            lower[i][j]=(matrix[i][j]-sum((lower[i][k]*lower[j][k]*diagonal[k]for k in range(j)),mp.iv.mpf(0)))/pivot
    return candidate,smallest


# Standalone norm helper extracted unchanged from the preceding round.
