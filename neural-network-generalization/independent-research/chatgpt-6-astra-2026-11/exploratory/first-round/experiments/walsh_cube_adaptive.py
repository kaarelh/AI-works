import numpy as np,json
from scipy.linalg import hadamard
from scipy.optimize import linprog
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def run(k,mode):
 K=2**k;H=hadamard(K).astype(float);s=np.arange(1,K)
 if mode=='linear':w=K-s
 elif mode=='quadratic':w=(K-s)**2
 elif mode=='geometric':w=np.exp(-s/K*5)
 elif mode=='popcount':w=np.exp(-np.array([v.bit_count() for v in s])/k)+1e-6*(K-s)/K
 elif mode=='additive':w=1+sum(3.**(-j)*((s>>j)&1) for j in range(k))
 known=[];rows=[]
 for t in range(K):
  r=linprog(-w,A_ub=H[known,1:] if t else None,b_ub=-np.ones(t) if t else None,bounds=[(-1,1)]*(K-1),method='highs')
  assert r.success
  p=(1+H[:,1:]@r.x)/K;live=np.setdiff1d(np.arange(K),known);v=int(live[np.argmax(p[live])])
  rows.append(dict(t=t,v=v,p=float(p[v]),distance=float(np.linalg.norm(p-np.eye(K)[v]))));known.append(v)
 print(k,mode,'wrong',sum(r['p']>.5+1e-7 for r in rows),'min_p',min(r['p'] for r in rows),'max_dist',max(r['distance'] for r in rows),flush=True)
 return dict(k=k,mode=mode,rows=rows)
allrows=[run(k,m) for k in range(2,9) for m in ['linear','quadratic','geometric','popcount','additive']]
(ROOT/'results'/'walsh_cube_adaptive.json').write_text(json.dumps(allrows))
