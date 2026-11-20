"""Margin-aware rare-seed analysis; supersedes raw sign-only success counts."""
import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
from pathlib import Path
import numpy as np,json,math
ROOT=Path(__file__).resolve().parents[1];rows=[]
for p in sorted((ROOT/'results').glob('rareseeds*_t100.npz')):
 final=p.with_name(p.name.replace('_t100.npz','_final.npz'))
 if not final.exists():continue
 z=np.load(p);end=np.load(final);W=z['W'];A=z['A'];cfg=z['cfg'];N=W.shape[1]
 for i,(L,rho,alpha,seed) in enumerate(cfg):
  P=L*np.abs(W[i,:,0]);B=np.abs(W[i,:,1]);C=np.abs(W[i,:,2]);desired=A[i]*W[i,:,1]*W[i,:,2]>0
  captured=((P<B+C)&desired)|(P<np.abs(B-C));pos=int(np.sum(captured&(A[i]>0)));neg=int(np.sum(captured&(A[i]<0)))
  final_w2_sign=np.where(desired,np.sign(W[i,:,1]),np.where(B>=C,np.sign(W[i,:,1]),np.sign(A[i])*np.sign(W[i,:,2])))
  ray_counts=[int(np.sum(captured&(A[i]>0)&(final_w2_sign>0))),int(np.sum(captured&(A[i]>0)&(final_w2_sign<0))),int(np.sum(captured&(A[i]<0)&(final_w2_sign>0))),int(np.sum(captured&(A[i]<0)&(final_w2_sign<0)))]
  X=z['cube'].copy();X[:,0]*=L;y=z['cube'][:,1]*z['cube'][:,2];Prob=(1+rho*z['cube'][:,0]*y)/8
  F=np.maximum(end['W'][i]@X.T,0).T@end['A'][i];m=F*y;loss=.5*np.sum(Prob*(F-y)**2)
  rows.append(dict(width=N,L=float(L),rho=float(rho),alpha=float(alpha),c=float(alpha*math.sqrt(N)),seed=int(seed),positive_seeds=pos,negative_seeds=neg,ray_counts=ray_counts,both_seed_prediction=pos>0 and neg>0,four_ray_prediction=all(ray_counts),raw_zero_error=bool(np.all(m>0)),robust_zero_error=bool(np.min(m)>1e-5),near_zero_risk=bool(loss<1e-8),minimum_margin=float(np.min(m)),loss=float(loss),ties_1e8=int(np.sum(abs(m)<1e-8)),tie_aware_error=float(np.mean((m< -1e-8)+.5*(abs(m)<=1e-8))),source=p.name))
summary=[]
for N in sorted({r['width'] for r in rows}):
 for c in sorted({round(r['c'],8) for r in rows if r['width']==N}):
  rr=[r for r in rows if r['width']==N and abs(r['c']-c)<1e-7];pos=np.array([r['positive_seeds'] for r in rr]);neg=np.array([r['negative_seeds'] for r in rr]);out=np.array([r['robust_zero_error'] for r in rr]);pred=(pos>0)&(neg>0);four=np.array([r['four_ray_prediction'] for r in rr]);ray=np.array([r['ray_counts'] for r in rr]);means=ray.mean(axis=0)
  summary.append(dict(width=N,c=c,n=len(rr),positive_mean=float(pos.mean()),negative_mean=float(neg.mean()),ray_means=means.tolist(),ray_variances=ray.var(axis=0).tolist(),robust_success=float(out.mean()),zero_risk_fraction=float(np.mean([r['near_zero_risk'] for r in rr])),raw_success=float(np.mean([r['raw_zero_error'] for r in rr])),both_seed_fraction=float(pred.mean()),four_ray_fraction=float(four.mean()),four_poisson_prediction=float(np.prod(1-np.exp(-means))),four_false_positive=int(np.sum(four&~out)),four_false_negative=int(np.sum(~four&out)),both_false_positive=int(np.sum(pred&~out)),both_false_negative=int(np.sum(~pred&out)),mean_tie_aware_error=float(np.mean([r['tie_aware_error'] for r in rr]))))
report=dict(status='exploratory; margin >1e-5 required; raw sign success is not reliable near stationary zero outputs',summary=summary,rows=rows)
(ROOT/'results/rare_seed_margin_analysis.json').write_text(json.dumps(report,indent=2)+'\n')
for row in summary:print(json.dumps(row))
