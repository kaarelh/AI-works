#!/usr/bin/env python3
"""Exact-rational operator bounds from arbitrary approximate SVD factors.

No accuracy or orthogonality claim about floating-point SVD is trusted.
For exact stored dyadic U,s,Vh and W, calculate
 A=||U.T U||_infinity, B=||Vh Vh.T||_infinity,
 R2=||W-U diag(s) Vh||_F^2, t=max|s|.
Then for every rational eps>0,
 ||W||_op^2 <= (1+eps)*t^2*A*B + (1+1/eps)*R2.
The Gram matrices and residual are exact integer GEMMs after common dyadic
scaling; all final arithmetic is Fraction arithmetic. Saved factors allow
replay without calling an SVD routine. This is not a Lean formalization.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,hashlib,json,time
from fractions import Fraction
from pathlib import Path
import numpy as np

DEFAULT_EPSILON=Fraction(1,10**7)

def rational_record(q):
    return dict(numerator=str(q.numerator),denominator=str(q.denominator))

def dyadic_integer_matrix(x):
    x=np.asarray(x)
    # Saved models/factors use binary16/32/64. Reject extended precision
    # rather than silently round it through Python float in an exact proof.
    if x.dtype.kind not in 'biuf' or (x.dtype.kind=='f' and x.dtype.itemsize>8):
        raise ValueError('Use integer or binary16/32/64 entries; extended precision is unsupported.')
    if not np.isfinite(x).all():raise ValueError('Finite dyadic entries required.')
    pairs=([(int(v),1) for v in x.flat] if x.dtype.kind in 'biu'
           else [float(v).as_integer_ratio() for v in x.flat])
    denominator=max((b for a,b in pairs),default=1)
    # Every denominator of a binary floating-point number is a power of two.
    assert denominator>0 and denominator&(denominator-1)==0
    integers=np.array([a*(denominator//b) for a,b in pairs],dtype=object).reshape(x.shape)
    return integers,denominator

def max_abs_row_sum(x):
    return max((sum(abs(int(v)) for v in row) for row in x),default=0)

def bound_from_factors(w,u,s,vh,epsilon=DEFAULT_EPSILON):
    epsilon=Fraction(epsilon)
    if epsilon<=0:raise ValueError('epsilon must be positive.')
    if u.ndim!=2 or vh.ndim!=2 or s.ndim!=1:raise ValueError('Bad factor dimensions.')
    if u.shape[1]!=len(s) or vh.shape[0]!=len(s) or w.shape!=(u.shape[0],vh.shape[1]):raise ValueError('Nonconforming factorization.')
    started=time.monotonic()
    wi,dw=dyadic_integer_matrix(w);ui,du=dyadic_integer_matrix(u)
    si,ds=dyadic_integer_matrix(s);vi,dv=dyadic_integer_matrix(vh)
    gu=ui.T@ui;gv=vi@vi.T
    a=Fraction(max_abs_row_sum(gu),du*du);b=Fraction(max_abs_row_sum(gv),dv*dv)
    product=(ui*si[None,:])@vi;dp=du*ds*dv;den=max(dw,dp)
    assert den%dw==0 and den%dp==0
    residual=wi*(den//dw)-product*(den//dp)
    r2=Fraction(sum(int(q)*int(q) for q in residual.flat),den*den)
    smax=max((abs(Fraction.from_float(float(q))) for q in s),default=Fraction(0))
    upper=(1+epsilon)*smax*smax*a*b+(1+1/epsilon)*r2
    return dict(operator_squared_upper=upper,left_gram_infinity=a,right_gram_infinity=b,
                maximum_absolute_diagonal=smax,residual_frobenius_squared=r2,epsilon=epsilon,
                elapsed_seconds=time.monotonic()-started)

def operator_square_upper(w,factor_path=None,existing_factor_path=None,epsilon=DEFAULT_EPSILON):
    start=time.monotonic()
    if existing_factor_path is not None:
        saved=np.load(existing_factor_path);u=saved['u'];s=saved['s'];vh=saved['vh'];mode='Replay stored factors; no SVD invoked.'
        factor_path=Path(existing_factor_path)
    else:
        u,s,vh=np.linalg.svd(np.asarray(w,dtype=np.float64),full_matrices=False);mode='Floating SVD proposes factors; exact arithmetic checks their resulting bound.'
        if factor_path is not None:
            factor_path=Path(factor_path);factor_path.parent.mkdir(parents=True,exist_ok=True)
            np.savez_compressed(factor_path,u=u,s=s,vh=vh)
    result=bound_from_factors(np.asarray(w),u,s,vh,epsilon=epsilon)
    metadata={k:rational_record(v) if isinstance(v,Fraction) else v for k,v in result.items()}
    metadata.update(method=mode,operator_squared_upper_approx=float(result['operator_squared_upper']),
                    total_elapsed_seconds=time.monotonic()-start,
                    qualification='Exact Python-integer/rational certificate of the saved dyadic matrix; mathematical norm inequalities are not Lean-formalized.')
    if factor_path is not None:
        metadata.update(factor_file=str(factor_path),factor_sha256=hashlib.sha256(factor_path.read_bytes()).hexdigest())
    return result['operator_squared_upper'],metadata

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--model',required=True);ap.add_argument('--layers',default='1');ap.add_argument('--output-directory',required=True);ap.add_argument('--replay',action='store_true');args=ap.parse_args()
    model=Path(args.model);out=Path(args.output_directory);out.mkdir(parents=True,exist_ok=True);saved=np.load(model)
    for layer in map(int,args.layers.split(',')):
        factor=out/f'{model.stem}-w{layer}-factors.npz'
        bound,record=operator_square_upper(saved[f'w{layer}'],factor_path=factor,
                                           existing_factor_path=factor if args.replay else None)
        target=out/f'{model.stem}-w{layer}.json';target.write_text(json.dumps(record,indent=2)+'\n')
        print(json.dumps(dict(model=model.stem,layer=layer,bound=float(bound),seconds=record['total_elapsed_seconds'],record=str(target))),flush=True)

if __name__=='__main__':main()
