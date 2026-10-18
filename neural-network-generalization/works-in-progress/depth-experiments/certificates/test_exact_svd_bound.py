#!/usr/bin/env python3
"""Small exact-regression checks; these do not replace the norm-bound proof."""
import tempfile
from fractions import Fraction
from pathlib import Path
import numpy as np
from exact_svd_bound import bound_from_factors,dyadic_integer_matrix,operator_square_upper

def main():
    eps=Fraction(1,10**7)
    w=np.diag([1.,2.,3.]);identity=np.eye(3)
    r=bound_from_factors(w,identity,np.array([1.,2.,3.]),identity)
    assert r['residual_frobenius_squared']==0
    assert r['operator_squared_upper']==9*(1+eps)
    # Deliberately nonorthogonal but exact factors: orthogonality is not assumed.
    r=bound_from_factors(np.eye(3),2*identity,np.ones(3)*.5,identity)
    assert r['left_gram_infinity']==4 and r['operator_squared_upper']==1+eps
    # Completely useless proposed factors still yield a valid residual bound.
    r=bound_from_factors(w,np.zeros((3,1)),np.zeros(1),np.zeros((1,3)))
    assert r['residual_frobenius_squared']==14
    assert r['operator_squared_upper']==14*(1+1/eps)
    integer=np.array([[2**63+3]],dtype=np.uint64)
    values,den=dyadic_integer_matrix(integer)
    assert int(values[0,0])==2**63+3 and den==1
    for dtype in [np.float16,np.float32,np.float64]:
        values,den=dyadic_integer_matrix(np.array([[-.125,.5]],dtype=dtype))
        assert list(values.flat)==[-1,4] and den==8
    if np.dtype(np.longdouble).itemsize>8:
        try:dyadic_integer_matrix(np.ones(1,dtype=np.longdouble))
        except ValueError:pass
        else:raise AssertionError('Extended precision was silently rounded.')
    with tempfile.TemporaryDirectory() as tmp:
        path=Path(tmp)/'factors.npz'
        first,_=operator_square_upper(w,factor_path=path)
        second,_=operator_square_upper(w,existing_factor_path=path)
        assert first==second
    print('Exact-factor regression checks passed, including replay without SVD.')

if __name__=='__main__':main()
