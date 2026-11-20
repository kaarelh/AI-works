"""Explore observed-margin completion in the calibrated Fourier cube."""
import numpy as np,json
from scipy.linalg import hadamard
from scipy.optimize import linprog
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def run(k,mode):
 K=2**k;H=hadamard(K).astype(float); s=np.arange(1,K)
 if mode=='linear':w=K-s
 elif mode=='binary':w=1+.5*np.array([sum(((v>>j)&1)*3**(-j) for j in range(k)) for v in s])
 elif mode=='popcount':w=np.exp(-np.array([v.bit_count() for v in s])/k)
 elif mode=='quadratic':w=(K-s)**2
 rows=[]
 for t in range(K):
  r=linprog(-w,A_ub=H[:t,1:] if t else None,b_ub=-np.ones(t) if t else None,bounds=[(-1,1)]*(K-1),method='highs')
  assert r.success,r.message
  p=(1+H[:,1:]@r.x)/K
  # Correct target on each live coordinate is -1, so wrong means p>1/2.
  rows.append(dict(t=t,p=float(p[t]),objective=float(r.fun),star_distance=float(np.linalg.norm(p-np.eye(K)[t])),q=r.x.tolist() if K<=16 else None))
 print(k,mode,'wrong',sum(r['p']>.5+1e-7 for r in rows),'min_p',min(r['p'] for r in rows),'max_star_distance',max(r['star_distance'] for r in rows),flush=True)
 return dict(k=k,mode=mode,rows=rows)
if __name__=='__main__':
 allrows=[run(k,m) for k in range(2,8) for m in ['linear','binary','popcount','quadratic']]
 (ROOT/'results'/'walsh_cube_online.json').write_text(json.dumps(allrows))
