"""Exact matrix checks and direct finite-ReLU tests of raw task transfer.

Rational matrix identities are exact; network projections, singular values,
and risk measurements are floating-point diagnostics. No posterior mixing
or probability theorem is certified by this script.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,itertools,time
from pathlib import Path
import numpy as np
import sympy as sp
ROOT=Path(__file__).resolve().parents[1];rng=np.random.default_rng(2026111832)
start=time.monotonic();exact_cases=0;records=[]
for n in range(2,11):
 for rank in range(1,min(n,4)):
  V=sp.Matrix([[int(x) for x in row] for row in rng.integers(-3,4,(rank,n))])
  if V.rank()!=rank:continue
  P=sp.eye(n)-V.T*(V*V.T).inv()*V;J=sp.eye(n).col_join(sp.zeros(2,n))
  L=V.col_join(sp.zeros(n+2-rank,n));E=sp.Matrix(rng.integers(-3,4,(n+2,n)))/17
  C=sp.Matrix(rng.integers(-3,4,(n+3,n)))/11
  sq=lambda A:sp.trace(A.T*A)
  assert P.T==P and P*P==P and L*P==sp.zeros(n+2,n)
  assert sq((J+L+E)*P-J)==rank+sq(E*P)
  assert sq(E*P)+sq(E*(sp.eye(n)-P))==sq(E)
  assert sq(C*P)<=sq(C);exact_cases+=1
for r in (6,8,10):
 X=2*((np.arange(1<<r)[:,None]>>np.arange(r))&1)-1;target=np.prod(X,axis=1);rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r));br=rho*(-1)**((r-2)//2);s=.5
 for k in (1,2):
  j=r-2*k;bj=rho*(-1)**((j-2)//2)*math.comb((r-2)//2,(j-2)//2)/math.comb(r-2,j-2)
  A=list(itertools.combinations(range(r),2*k));M=len(A);J=np.stack([target*np.prod(X[:,a],axis=1) for a in A],axis=1)
  # A monomial orientation sector with exact source balance.
  S=list(range(j+1 if k>=2 else j-1));Z=X[np.prod(X[:,S],axis=1)==1];N=len(Z);scale=math.sqrt(s/rho)
  Ubase=np.column_stack([np.zeros(N),Z/math.sqrt(r)])*scale
  abase=scale*np.sign(br)*np.prod(Z,axis=1)
  for perturbation in (0.,1e-6,1e-4):
   U=Ubase+perturbation*rng.normal(size=Ubase.shape);a=abase+perturbation*rng.normal(size=N)
   H=np.maximum(U[:,0,None]+U[:,1:]@X.T,0).T/math.sqrt(N)
   F=H@a/math.sqrt(N);energy=(np.dot(a,a)+np.sum(U*U))/(2*N)
   eps=max(0.,energy*rho/s-1);hinge=float(np.maximum(0,s-target*F).mean())
   u=math.sqrt((s+energy*math.sqrt(r+1))*(eps*s+2*hinge));v=math.sqrt(2*energy*(eps*s+hinge)/rho)
   alpha=br/(s*bj);Delta=abs(alpha)*((1+(r-1)**k)*v+(r-1)**k*u);Bsq=2*energy*alpha**2
   signs=np.where(U[:,1:]>=0,1,-1);mod=np.stack([np.prod(signs[:,aa],axis=1) for aa in A],axis=1)
   C=alpha*a[:,None]*mod/math.sqrt(N)
   Lcoef=(alpha/(2*N*math.sqrt(r)))*(signs.T@(a[:,None]*np.linalg.norm(U,axis=1)[:,None]*mod))
   _,sv,Vh=np.linalg.svd(Lcoef,full_matrices=False);rank=int(np.sum(sv>max(1e-10,sv[0]*1e-12)))
   P=np.eye(M)-Vh[:rank].T@Vh[:rank]
   Q=H@C;L=X@Lcoef;err=Q-J-L;fit=Q@P
   mse=np.mean((fit-J)**2,axis=0);errors=np.mean(err**2,axis=0);normsq=np.sum((C@P)**2,axis=0)
   hs_identity=abs(float(mse.sum())-(rank+np.sum((err@P)**2)/(1<<r)))
   assert hs_identity<1e-8
   assert np.max(np.sqrt(errors))<=Delta+2e-11
   assert mse.mean()<=r/M+Delta**2+1e-9
   assert normsq.mean()<=Bsq+1e-7
   rec=dict(r=r,k=k,N=N,tasks=M,perturbation=perturbation,contamination_rank=rank,
      actual_source_hinge=hinge,energy=energy,energy_excess=eps,proved_error_bound=Delta,
      maximum_column_remainder=float(np.sqrt(errors.max())),average_raw_mse=float(mse.mean()),
      average_projected_coefficient_norm_squared=float(normsq.mean()),coefficient_norm_budget=Bsq,
      rank_error_term=rank/M,trace_identity_discrepancy=hs_identity)
   if perturbation==0:
    # A direct raw least-squares fit, independent of the constructed P.
    pred=H@np.linalg.lstsq(H,J,rcond=1e-12)[0];risk=np.mean((pred-J)**2,axis=0)
    selected=[i for i,aa in enumerate(A) if set(range(r))-set(aa) in [set(S)-{l} for l in S]] if k>=2 else [i for i,aa in enumerate(A) if set(S)<=(set(range(r))-set(aa))]
    expected=1/(1+4*r*bj*bj)
    assert len(selected)==(j+1 if k>=2 else 2*k+1)
    assert max(abs(risk[selected]-expected))<2e-10
    rec.update(sharp_obstructed_tasks=len(selected),exact_formula_obstructed_mse=expected,
      mean_optimal_raw_mse=float(risk.mean()),maximum_sharp_formula_discrepancy=float(max(abs(risk[selected]-expected))))
   records.append(rec);print(json.dumps({key:rec[key] for key in ('r','k','perturbation','average_raw_mse','contamination_rank')}),flush=True)
result=dict(status='PASS',exact_rational_matrix_cases=exact_cases,actual_network_cases=len(records),rows=records,
 seconds=time.monotonic()-start,qualification='Exact rational abstract-matrix identities; direct-network, SVD, and least-squares checks use floating-point arithmetic. The full posterior theorem is not checked by these calculations.')
(ROOT/'results/low_rank_transfer_checks.json').write_text(json.dumps(result,indent=2)+'\n')
