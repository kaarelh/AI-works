import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
from pathlib import Path
import numpy as np,json
from scipy.optimize import brentq
ROOT=Path(__file__).resolve().parents[1]
names=['mean_parity','parity_kernel','readout_energy','incoming_energy','readout_p_energy','incoming_p_energy']
def fit(data):
 z=data[:,0]
 def stats(t):
  l=(t-29)*z;l-=l.max();w=np.exp(l);w/=w.sum();return w@data
 t=brentq(lambda t:stats(t)[0]-.5,28,31)
 s=stats(t);return np.r_[t,s]
rows=[]
for seed in [2,3,4,5,6,7]:
 path=ROOT/f'results/quartic_ordinary_pt_d6_seed{seed}.bin';a=np.fromfile(path,dtype=np.float64).reshape(-1,6)
 central=fit(a);block=np.array([fit(x) for x in np.array_split(a,99)])
 row=dict(seed=seed,saved_samples=len(a),tilt_reference=29,target_mean=.5,blocks=99,tilt=central[0],estimates=dict(zip(names,central[1:])),block_sd=dict(zip(['tilt']+names,block.std(axis=0,ddof=1))),block_estimated_se=dict(zip(['tilt']+names,block.std(axis=0,ddof=1)/np.sqrt(len(block)))))
 row['readout_identity_rhs']=(1+central[0]*.5)/4;row['gauge_p_difference']=central[-1]-central[-2];rows.append(row);print(json.dumps(row),flush=True)
(ROOT/'results/quartic_ordinary_analysis.json').write_text(json.dumps(rows,indent=2))
