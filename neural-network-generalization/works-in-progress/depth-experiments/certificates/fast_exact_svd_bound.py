#!/usr/bin/env python3
"""Small-matrix version of exact_svd_bound with checked int64 products.

Quantized SVD factors are proposals. Integer GEMMs are int64 only if the
entrywise worst-case sum bound proves no overflow; otherwise Python integers
are used. All final Gram/residual/Young bounds are exact rationals.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import time,hashlib
from pathlib import Path
from fractions import Fraction
import numpy as np
from exact_svd_bound import dyadic_integer_matrix,rational_record
LIMIT=2**63-1;BITS=18;DEN=2**BITS

def maxabs(a):return max((abs(int(v))for v in a.flat),default=0)

def exact_gemm(a,b):
 bound=a.shape[1]*maxabs(a)*maxabs(b)
 if bound<=LIMIT and maxabs(a)<=LIMIT and maxabs(b)<=LIMIT:return np.asarray(a,dtype=np.int64)@np.asarray(b,dtype=np.int64),True
 return np.asarray(a,dtype=object)@np.asarray(b,dtype=object),False

def row_bound(a):return max((sum(abs(int(v))for v in row)for row in a),default=0)

def operator_square_upper(w,factor_path=None,existing_factor_path=None,epsilon=Fraction(1,10000)):
 epsilon=Fraction(epsilon)
 if epsilon<=0:raise ValueError("Positive exact epsilon required.")
 start=time.monotonic();w=np.asarray(w);path=Path(existing_factor_path or factor_path)if (existing_factor_path or factor_path)else None
 if existing_factor_path is not None:
  f=np.load(existing_factor_path);u,s,vh=f['u'],f['s'],f['vh']
 else:
  u,s,vh=np.linalg.svd(w.astype(float),full_matrices=False)
  u=np.rint(u*DEN)/DEN;s=np.rint(s*DEN)/DEN;vh=np.rint(vh*DEN)/DEN
  if path is not None:path.parent.mkdir(exist_ok=True,parents=True);np.savez_compressed(path,u=u,s=s,vh=vh)
 if u.ndim!=2 or vh.ndim!=2 or s.ndim!=1 or u.shape[1]!=len(s) or vh.shape[0]!=len(s) or w.shape!=(u.shape[0],vh.shape[1]):raise ValueError("Conforming factor dimensions required.")
 for a in [u,s,vh]:
  if not np.isfinite(a).all()or not np.all(a*DEN==np.rint(a*DEN)):raise ValueError('Expected finite quantized factor proposal.')
 def integers(a):
  b=np.array([int(v*DEN)for v in a.flat],dtype=object).reshape(a.shape)
  return b.astype(np.int64)if maxabs(b)<=LIMIT else b
 ui,si,vi=integers(u),integers(s),integers(vh)
 if maxabs(ui)*maxabs(si)>LIMIT:us=ui.astype(object)*si.astype(object)[None,:]
 else:us=ui*si[None,:]
 gu,fastu=exact_gemm(ui.T,ui);gv,fastv=exact_gemm(vi,vi.T);product,fastp=exact_gemm(us,vi)
 a=Fraction(row_bound(gu),DEN**2);b=Fraction(row_bound(gv),DEN**2);wi,dw=dyadic_integer_matrix(w);dp=DEN**3;dd=max(dw,dp)
 residual=wi*(dd//dw)-product.astype(object)*(dd//dp);r2=Fraction(sum(int(v)*int(v)for v in residual.flat),dd*dd)
 sm=Fraction(maxabs(si),DEN);upper=(1+epsilon)*sm*sm*a*b+(1+1/epsilon)*r2
 out={k:rational_record(v)for k,v in dict(operator_squared_upper=upper,left_gram_infinity=a,right_gram_infinity=b,maximum_absolute_diagonal=sm,residual_frobenius_squared=r2,epsilon=epsilon).items()}
 out.update(method='18-bit dyadic SVD proposals; exact Gram/residual arithmetic with separately checked int64 GEMM overflow bounds.',factor_quantization_bits=BITS,checked_int64_gemms=[fastu,fastv,fastp],operator_squared_upper_approx=float(upper),total_elapsed_seconds=time.monotonic()-start)
 if path is not None:out.update(factor_file=str(path),factor_sha256=hashlib.sha256(path.read_bytes()).hexdigest())
 return upper,out
