"""Compare a plateau-only frozen-field seed criterion with later network outcomes.
No final outcome is used to define the seed criterion or fit its rate.
"""
from pathlib import Path
import numpy as np,json,collections,math
ROOT=Path(__file__).resolve().parents[1];rows=[]
for p in sorted((ROOT/'results').glob('rareseeds*_t100.npz')):
 final=p.with_name(p.name.replace('_t100.npz','_final.npz'))
 if not final.exists():continue
 z=np.load(p);end=np.load(final);W=z['W'];A=z['A'];cfg=z['cfg'];N=W.shape[1]
 for i,(L,rho,alpha,seed) in enumerate(cfg):
  P=L*np.abs(W[i,:,0]);B=np.abs(W[i,:,1]);C=np.abs(W[i,:,2])
  desired=A[i]*W[i,:,1]*W[i,:,2]>0
  captured=((P<B+C)&desired)|(P<np.abs(B-C))
  pos=int(np.sum(captured&(A[i]>0)));neg=int(np.sum(captured&(A[i]<0)))
  X=z['cube'].copy();X[:,0]*=L;y=z['cube'][:,1]*z['cube'][:,2]
  F=np.maximum(end['W'][i]@X.T,0).T@end['A'][i]
  err=float(np.mean((F*y<0)+.5*(F==0)))
  rows.append(dict(width=N,L=float(L),rho=float(rho),alpha=float(alpha),c=float(alpha*math.sqrt(N)),seed=int(seed),positive_seeds=pos,negative_seeds=neg,prediction=pos>0 and neg>0,zero_error=err==0,error=err,source=p.name))
summary=[]
for N in sorted({r['width'] for r in rows}):
 for c in sorted({round(r['c'],8) for r in rows if r['width']==N}):
  rr=[r for r in rows if r['width']==N and abs(r['c']-c)<1e-7];pos=np.array([r['positive_seeds'] for r in rr]);neg=np.array([r['negative_seeds'] for r in rr]);out=np.array([r['zero_error'] for r in rr]);pred=(pos>0)&(neg>0)
  summary.append(dict(width=N,c=c,n=len(rr),positive_mean=float(pos.mean()),negative_mean=float(neg.mean()),positive_variance=float(pos.var()),negative_variance=float(neg.var()),positive_negative_covariance=float(np.mean((pos-pos.mean())*(neg-neg.mean()))),observed_success=float(out.mean()),both_seed_fraction=float(pred.mean()),poisson_prediction=float((1-np.exp(-pos.mean()))*(1-np.exp(-neg.mean()))),false_positive=int(np.sum(pred&~out)),false_negative=int(np.sum(~pred&out)),mean_error=float(np.mean([r['error'] for r in rr]))))
report=dict(status='numerical exploratory; plateau at time 100, final horizon 2000; criterion from frozen residual field',summary=summary,rows=rows)
(ROOT/'results/rare_seed_analysis.json').write_text(json.dumps(report,indent=2)+'\n')
for row in summary:print(json.dumps(row))
