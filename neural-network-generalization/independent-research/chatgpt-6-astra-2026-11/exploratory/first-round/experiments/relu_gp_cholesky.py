"""Test the stronger coordinatewise-negative autoregression criterion."""
import numpy as np,json
from scipy.linalg import cholesky,solve_triangular
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
rows=[]
for d in range(2,11):
 M=2**d;ids=np.arange(M);ham=np.array([i.bit_count() for i in ids]);H=ham[ids[:,None]^ids[None,:]]
 sign=(-1.)**ham
 for bias2 in [.1,1.,float(d),float(d*d)]:
  c=np.clip((d-2*H+bias2)/(d+bias2),-1,1);K=(np.sqrt(1-c*c)+(np.pi-np.arccos(c))*c)/np.pi;K*=sign[:,None]*sign[None,:]
  try:
   L=cholesky(K,lower=True);A=solve_triangular(L,np.eye(M),lower=True);A=A/np.diag(A)[:,None];vals=A[np.tril_indices(M,-1)]
   row=dict(d=d,bias2=bias2,min_coefficient=float(vals.min()),negative=int((vals < -1e-9).sum()),positive=int((vals>1e-9).sum()),total=len(vals),min_innovation=float(np.diag(L).min()),max_coefficient=float(vals.max()))
  except Exception as e:row=dict(d=d,bias2=bias2,error=str(e))
  rows.append(row);print(json.dumps(row),flush=True)
(ROOT/'results'/'relu_gp_cholesky.json').write_text(json.dumps(rows,indent=2))
