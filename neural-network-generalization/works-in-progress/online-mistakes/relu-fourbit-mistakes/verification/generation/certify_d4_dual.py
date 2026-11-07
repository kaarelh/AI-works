"""Exact Q(sqrt(15)) verification of the chi2*AND2 ReLU dual.

NNLS identifies active faces only. Every final inequality is checked exactly.
Activation-cone completeness is checked separately by certify_d4_cones.py.
"""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
import json,math,sys
from pathlib import Path
from fractions import Fraction as F
import numpy as np
import sympy as sp
from scipy.optimize import nnls,linprog
ROOT=Path(__file__).resolve().parent.parent

def sign(a,b):
    """Sign of rational a+b*sqrt(15), with no floating comparison."""
    a=F(a);b=F(b)
    if not b:return (a>0)-(a<0)
    if not a:return (b>0)-(b<0)
    if a>0 and b>0:return 1
    if a<0 and b<0:return -1
    delta=a*a-15*b*b
    return ((delta>0)-(delta<0))*(1 if a>0 else -1)

def run():
    a=np.load(ROOT/'d4_certificate_input.npz')
    X=a['X'].astype(int);D=a['D'].astype(int)
    chi=X[:,1]*X[:,2];gate=np.all(X[:,3:]==1,axis=1)
    la=np.array([F(int(c),3)if g else F(0)for c,g in zip(chi,gate)],dtype=object)
    lb=np.array([F(int(c),6)if g else F(-int(c),12)for c,g in zip(chi,gate)],dtype=object)
    lam=math.sqrt(2)*(la.astype(float)+math.sqrt(15)*lb.astype(float))
    cache={};certs=[];maxval=0.;tight=0;fallbacks=0
    for j,d in enumerate(D):
        A=(2*d-1)[:,None]*X
        for sg in [1,-1]:
            ga=sg*(X.T@(d*la));gb=sg*(X.T@(d*lb))
            g=math.sqrt(2)*(ga.astype(float)+math.sqrt(15)*gb.astype(float))
            q,_=nnls(A.T.astype(float),-g,maxiter=10000)
            def from_support(S):
                if S not in cache:
                    T=sp.Matrix(X[list(S)].tolist()) if S else sp.zeros(0,5)
                    if S:
                        assert (T*T.T).det()!=0
                        Q=-(T*T.T).inv()*T
                    else:Q=sp.zeros(0,5)
                    cache[S]=np.array(Q.tolist(),dtype=object).reshape(len(S),5)
                Q=cache[S]
                qa=(Q@ga)*((2*d[list(S)]-1)if S else np.array([],dtype=int))
                qb=(Q@gb)*((2*d[list(S)]-1)if S else np.array([],dtype=int))
                pa=ga+A[list(S)].T@qa if S else ga
                pb=gb+A[list(S)].T@qb if S else gb
                assert all(sign(u,v)>=0 for u,v in zip(qa,qb)),('multiplier',j,sg,S)
                assert all(sign(u,v)>=0 for u,v in zip(A@pa,A@pb)),('primal',j,sg,S)
                return pa,pb
            S=tuple(np.flatnonzero(q>1e-9).tolist())
            try:pa,pb=from_support(S)
            except AssertionError:
                # Degenerate NNLS bases are replaced by a QP face and an LP
                # basic multiplier solution. The resulting check is still exact.
                fallbacks+=1

                import cvxpy as cp
                w=cp.Variable(5);prob=cp.Problem(cp.Minimize(cp.sum_squares(w-g)),[A@w>=0])
                prob.solve(solver='CLARABEL',tol_gap_abs=1e-11,tol_feas=1e-11,tol_gap_rel=1e-11)
                success=False
                for tol in [1e-7,1e-6,1e-5,1e-4]:
                    Z=np.flatnonzero(abs(A@w.value)<tol)
                    T=sp.Matrix(X[Z].tolist());ind=T.T.rref()[1];T=T[list(ind),:]
                    P=sp.eye(5)-T.T*(T*T.T).inv()*T if len(ind)else sp.eye(5)
                    pp=np.array(P.tolist(),dtype=float)@g
                    lp=linprog(np.zeros(len(Z)),A_eq=A[Z].T,b_eq=pp-g,bounds=(0,None),method='highs')
                    if not lp.success:continue
                    S=tuple(sorted(Z[lp.x>1e-8].tolist()))
                    try:pa,pb=from_support(S);success=True;break
                    except AssertionError:continue
                assert success,('fallback',j,sg)
            u=2*sum(t*t+15*s*s for t,s in zip(pa,pb));v=4*sum(t*s for t,s in zip(pa,pb))
            assert sign(1-u,-v)>=0,('norm',j,sg,S,u,v)
            if sign(1-u,-v)==0:tight+=1
            val=float(u)+float(v)*math.sqrt(15);maxval=max(maxval,val)
            certs.append(dict(cone=j,readout_sign=sg,active=list(S),norm_square=[str(u),str(v)]))
    out=dict(scope='Exact dual inequality on every listed closed activation cone; completeness checked separately',cones=len(D),signed_checks=len(certs),exact_tight=tight,distinct_faces=len(cache),numerical_basis_fallbacks=fallbacks,dual_cost='5*sqrt(30)/6 + 2*sqrt(2)/3',value=5*math.sqrt(30)/6+2*math.sqrt(2)/3,certificates=certs)
    (ROOT/'d4_exact_dual_certificate.json').write_text(json.dumps(out,indent=2))
    print(json.dumps({k:v for k,v in out.items()if k!='certificates'}))

if __name__=='__main__':run()
