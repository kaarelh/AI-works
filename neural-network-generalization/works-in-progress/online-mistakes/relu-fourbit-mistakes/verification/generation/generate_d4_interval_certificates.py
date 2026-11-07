"""Generate exact rational lower/upper norm certificates for all222 d4 classes.

Floating SOCP solutions only propose coefficients. Rational lower bounds use
nonnegative cone-polar multipliers and an exact integer residual norm bound.
Rational upper bounds evaluate actual ReLU neurons on all16 points.
"""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
os.environ.setdefault('OMP_NUM_THREADS','1')
import sys,json,math,time
from pathlib import Path
from fractions import Fraction as F
import numpy as np

import cvxpy as cp
ROOT=Path(__file__).resolve().parent.parent;DEST=ROOT/'d4_interval_certificates';DEST.mkdir(exist_ok=True)

def run():
    a=np.load(ROOT/'d4_certificate_input.npz');X=a['X'].astype(np.int64);D=a['D'].astype(np.int64);J=len(D)
    representatives=sorted(set(map(int,a['canonical'])))
    U=cp.Variable((J,5));V=cp.Variable((J,5));label=cp.Parameter(16)
    pu=U@X.T;pv=V@X.T;z=cp.sum(cp.multiply(D,pu-pv),axis=0)
    constraints=[cp.multiply(2*D-1,pu)>=0,cp.multiply(2*D-1,pv)>=0,cp.multiply(label,z)>=.5]
    problem=cp.Problem(cp.Minimize(cp.sum(cp.norm(U,axis=1))+cp.sum(cp.norm(V,axis=1))),constraints)
    dualden=10**7;primalden=10**8
    for count,code in enumerate(representatives):
        path=DEST/f'{code}.npz'
        if path.exists():continue
        started=time.time();y=np.array([1 if code>>i&1 else -1 for i in range(16)],dtype=np.int64);label.value=y
        value=problem.solve(solver='CLARABEL',tol_gap_abs=2e-8,tol_gap_rel=2e-8,tol_feas=2e-8,max_iter=400)
        alpha=np.rint(np.maximum(constraints[2].dual_value,0)*dualden).astype(np.int64)
        qplus=np.rint(np.maximum(constraints[0].dual_value,0)*dualden).astype(np.int64)
        qminus=np.rint(np.maximum(constraints[1].dual_value,0)*dualden).astype(np.int64)
        lam=alpha*y;G=(D*lam)@X
        Rplus=G+((2*D-1)*qplus)@X;Rminus=-G+((2*D-1)*qminus)@X
        residual=np.r_[Rplus,Rminus]
        assert np.max(abs(residual))<10**9
        maxsq=max(sum(int(v)**2 for v in row)for row in residual)
        radius=math.isqrt(maxsq);radius+=int(radius*radius<maxsq)
        lower=F(int(sum(alpha)),2*radius)
        W=np.rint(np.r_[U.value,V.value]*primalden).astype(np.int64);read=np.r_[np.ones(J,dtype=np.int64),-np.ones(J,dtype=np.int64)]
        keep=np.any(W!=0,axis=1);W=W[keep];read=read[keep]
        output=np.maximum(X@W.T,0)@read;minimum=int(min(y*output));assert minimum>0
        root_sum=0
        for w in W:
            n=sum(int(v)**2 for v in w);rr=math.isqrt(n);root_sum+=rr+int(rr*rr<n)
        upper=F(root_sum,2*minimum)
        assert lower<=upper,(code,lower,upper)
        np.savez_compressed(path,code=code,alpha=alpha,qplus=qplus,qminus=qminus,dual_radius=radius,dual_max_square=maxsq,W=W,readout=read,primal_denominator=2*minimum,primal_root_sum=root_sum,lower_num=lower.numerator,lower_den=lower.denominator,upper_num=upper.numerator,upper_den=upper.denominator)
        row=dict(index=count,code=code,solver=float(value),lower=float(lower),upper=float(upper),width=len(W),seconds=time.time()-started)
        print(json.dumps(row),flush=True)
    print('ALL222_CERTIFICATES_GENERATED',flush=True)

if __name__=='__main__':run()
