import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
import json
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
a=json.loads((ROOT/'results/rare_seed_analysis.json').read_text());out=[]
for r in a['rows']:
 if r['width']!=1024 or not r['prediction'] or r['zero_error']:continue
 z=np.load(ROOT/'results'/r['source'].replace('_t100.npz','_final.npz'));i=next(i for i,c in enumerate(z['cfg']) if int(c[-1])==r['seed'] and abs(c[-2]-r['alpha'])<1e-12)
 A=z['A'][i];W=z['W'][i];cube=z['cube'];L,rho,alpha,seed=z['cfg'][i];X=cube.copy();X[:,0]*=L;y=cube[:,1]*cube[:,2];P=(1+rho*cube[:,0]*y)/8;pre=X@W.T;F=np.maximum(pre,0)@A
 G=((P*(y-F))[:,None]*(pre>0)).T@X;grad=np.sqrt(np.sum((A[:,None]*G)**2)+np.sum(np.sum(W*G,axis=1)**2))
 active=np.linalg.norm(W,axis=1)>1e-3;patterns={}
 for j in np.where(active)[0]:
  pat=''.join(str(int(v)) for v in pre[:,j]>1e-10);key=('+' if A[j]>0 else '-')+pat;patterns[key]=patterns.get(key,0)+1
 row={**r,'scores':F.tolist(),'signed_scores':(F*y).tolist(),'gradient_norm':float(grad),'active_patterns':patterns,'risk':float(.5*np.sum(P*(y-F)**2))};out.append(row)
(ROOT/'results/rare_seed_failure_diagnostics.json').write_text(json.dumps(out,indent=2))
for r in out[:12]:print(json.dumps({k:r[k] for k in ['c','seed','continued_error'] if k in r}|{'signed_scores':np.round(r['signed_scores'],8).tolist(),'gradient_norm':r['gradient_norm'],'risk':r['risk'],'active_patterns':r['active_patterns']}))
