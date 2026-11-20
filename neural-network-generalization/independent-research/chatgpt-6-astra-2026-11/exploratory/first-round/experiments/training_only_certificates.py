"""Generate exact integer certificates for observed-margin ReLU mistakes.
Floating optimization proposes witnesses; a separate checker will verify them.
The next correct prediction is constrained only to have nonnegative sign.
"""
import json,math,time,itertools
from pathlib import Path
from fractions import Fraction
import numpy as np
import cvxpy as cp
from scipy.optimize import linprog
ROOT=Path(__file__).resolve().parents[1]
REPO=Path(__file__).resolve().parents[6]
SOURCE=REPO/'neural-network-generalization/works-in-progress/online-mistakes/relu-fourbit-mistakes/verification/d4_certificate_input.npz'
a=np.load(SOURCE);X=a['X'].astype(np.int64);D=a['D'].astype(np.int64)
y=(X[:,1]*X[:,2]*np.where(np.all(X[:,3:]==1,axis=1),1,-1)).astype(np.int64)
DEST=ROOT/'results'/'observed_margin_certificates';DEST.mkdir(exist_ok=True)
def ceilroot(n):
 q=math.isqrt(n);return q+int(q*q<n)
def solve_pair(history,query):
 name='_'.join(map(str,history))+'__'+str(query);path=DEST/(name+'.npz')
 if path.exists():
  a=np.load(path);lo=Fraction(int(a['lower_num']),int(a['lower_den']));up=Fraction(int(a['upper_num']),int(a['upper_den']))
  return lo>up,dict(history=history,query=query,lower=float(lo),upper=float(up),gap=float(lo-up),file=path.name)
 ids=history+[query];Xs=X[ids];Ds=np.unique(D[:,ids],axis=0);Ds=Ds[Ds.sum(axis=1)>0];J=len(Ds)
 U=cp.Variable((J,5));V=cp.Variable((J,5));pu=U@Xs.T;pv=V@Xs.T
 z=cp.sum(cp.multiply(Ds,pu-pv),axis=0);norm=cp.sum(cp.norm(U,axis=1))+cp.sum(cp.norm(V,axis=1))
 cone=[cp.multiply(2*Ds-1,pu)>=0,cp.multiply(2*Ds-1,pv)>=0]
 histcon=cp.multiply(y[history],z[:-1])>=.5
 opts=dict(solver='CLARABEL',tol_gap_abs=1e-8,tol_gap_rel=1e-8,tol_feas=1e-9,max_iter=400)
 histprob=cp.Problem(cp.Minimize(norm),cone+[histcon]);val=histprob.solve(**opts)
 assert U.value is not None,(history,query,histprob.status)
 # Compress the proposed history solution to <=len(history) actual neurons.
 W=np.r_[U.value,V.value];sign=np.r_[np.ones(J),-np.ones(J)]
 keep=np.linalg.norm(W,axis=1)>1e-7;W=W[keep];sign=sign[keep]
 tab=np.maximum(X@W.T,0)*sign
 lp=linprog(np.linalg.norm(W,axis=1),A_ub=-y[history,None]*tab[history],b_ub=-np.ones(len(history))*.5,bounds=(0,None),method='highs')
 assert lp.success,lp.message
 keep=lp.x>1e-9;W=W[keep]*lp.x[keep,None];sign=sign[keep].astype(np.int64)
 Wint=np.rint(W*10**10).astype(np.int64);out=np.maximum(X@Wint.T,0)@sign
 minmargin=min(int(q) for q in y[history]*out[history]);assert minmargin>0
 rootsum=sum(ceilroot(sum(int(t)**2 for t in w)) for w in Wint)
 up=Fraction(rootsum,2*minmargin)
 # Correct-event dual: observed margins1/2, next margin0.
 margin=np.r_[np.ones(len(history))*.5,0.]
 correct=cp.multiply(y[ids],z)>=margin
 prob=cp.Problem(cp.Minimize(norm),cone+[correct]);cval=prob.solve(**opts)
 assert correct.dual_value is not None,(history,query,prob.status)
 den=10**9
 alpha=np.rint(np.maximum(correct.dual_value,0)*den).astype(np.int64)
 qp=np.rint(np.maximum(cone[0].dual_value,0)*den).astype(np.int64)
 qm=np.rint(np.maximum(cone[1].dual_value,0)*den).astype(np.int64)
 G=(Ds*(alpha*y[ids]))@Xs
 res=np.r_[G+((2*Ds-1)*qp)@Xs,-G+((2*Ds-1)*qm)@Xs]
 maxsq=max(sum(int(v)**2 for v in row) for row in res);radius=ceilroot(maxsq)
 lo=Fraction(sum(int(v) for v in alpha[:-1]),2*radius)
 np.savez_compressed(path,history=np.array(history),query=query,X=Xs,D=Ds,y=y[ids],
  alpha=alpha,qplus=qp,qminus=qm,radius=radius,W=Wint,readout=sign,primal_denominator=2*minmargin,
  lower_num=lo.numerator,lower_den=lo.denominator,upper_num=up.numerator,upper_den=up.denominator)
 row=dict(history=history,query=query,lower=float(lo),upper=float(up),gap=float(lo-up),
          history_solver=float(val),correct_solver=float(cval),width=len(Wint),file=path.name)
 print(json.dumps(row),flush=True)
 return lo>up,row
def main():
 prefix=[15,14,13,11,10,9,7,6,3,5,2,8];rows=[]
 for t in range(1,len(prefix)):
  good,row=solve_pair(prefix[:t],prefix[t]);rows.append(row)
  assert good,row
 def dfs(hist):
  if len(hist)==16:return hist,[]
  for q in [4,12,1,0]:
   if q in hist:continue
   good,row=solve_pair(hist,q)
   if good:
    ans=dfs(hist+[q])
    if ans:return ans[0],[row]+ans[1]
  return None
 result=dfs(prefix)
 if result:
  order,tail=result;data=dict(order=order,certificates=rows+tail,strict_mistakes=15)
 else:data=dict(order=prefix,certificates=rows,strict_mistakes=len(rows),tail_search='no all-wrong continuation found')
 (ROOT/'results'/'observed_margin_mistake_path.json').write_text(json.dumps(data,indent=2)+'\n')
 print(json.dumps({k:v for k,v in data.items() if k!='certificates'}),flush=True)
if __name__=='__main__':main()
