"""Paper-cluster resampling uncertainty for LM nonlinear least-squares fit."""
from pathlib import Path
import json
import numpy as np
import pandas as pd
from scipy.optimize import least_squares

here=Path(__file__).resolve().parent
d=pd.read_csv(here/'lm_processed.csv')
r=json.loads((here/'results.json').read_text())
q0=np.array(r['language_models'][0]['parameters'])
refs=d.Reference.unique();rng=np.random.default_rng(610911)
lo=np.r_[np.full(6,-8),-1,.002,-1,.002];hi=np.r_[np.full(6,8),1,2,1,2]
# Preserve exactly the same resampled papers. A separate RNG generates the six
# deterministic initializations used by the full-data fit; q0 is a seventh.
start_rng=np.random.default_rng(313)
base=np.r_[np.full(6,np.log(2.5)),.04,.1,.04,.1]
starts=[q0,base]+[base+start_rng.normal(0,.1,10) for _ in range(5)]
starts=[np.clip(v,lo+1e-5,hi-1e-5) for v in starts]
samples=[]
for i in range(200):
    sampled=rng.choice(refs,len(refs),replace=True)
    e=pd.concat([d[d.Reference==p] for p in sampled],ignore_index=True)
    b=e.benchmark.to_numpy(int);t=e.time.to_numpy();ln=e.logN.to_numpy();ld=e.logD.to_numpy();y=e.loss.to_numpy()
    def resid(q):return np.exp(q[b]-q[6]*t-q[7]*ln)+np.exp(q[3+b]-q[8]*t-q[9]*ld)-y
    candidates=[least_squares(resid,start,bounds=(lo,hi),max_nfev=3000) for start in starts]
    best_index=int(np.argmin([v.cost for v in candidates]))
    fit=candidates[best_index]
    # Refine the best basin, without changing the likelihood or constraints.
    refined=least_squares(resid,fit.x,bounds=(lo,hi),max_nfev=3000,
        ftol=1e-11,xtol=1e-11,gtol=1e-11)
    if refined.cost<fit.cost:fit=refined
    if not fit.success:
        fit=least_squares(resid,fit.x,bounds=(lo,hi),max_nfev=30000,
            ftol=1e-10,xtol=1e-10,gtol=1e-10)
    q=fit.x;s=q[6]/q[7]+q[8]/q[9]
    samples.append({'replicate_zero_based':i,'s':float(s),'success':bool(fit.success),
        'bound_hit':bool(np.any(q-lo<1e-4)|np.any(hi-q<1e-4)),
        'cost':float(fit.cost),'main_fit_start_cost':float(candidates[0].cost),
        'parameters':q.tolist(),'optimizer_message':str(fit.message),
        'selected_initialization':best_index,'initialization_costs':[float(v.cost) for v in candidates]})
    if (i+1)%25==0:print(f'Completed {i+1}/200 bootstrap replicates',flush=True)
ss=np.array([q['s'] for q in samples])
out={'replicates':200,'initializations_per_replicate':len(starts),
    'optimizer':'seven initializations, choose minimum least-squares cost, refine best basin',
    'paper_cluster_bootstrap_s_5_50_95':np.quantile(ss,[.05,.5,.95]).tolist(),
    'boundary_hits':sum(q['bound_hit'] for q in samples),'failed_fits':sum(not q['success'] for q in samples),'samples':samples}
(here/'bootstrap_results.json').write_text(json.dumps(out,indent=2))
print(json.dumps({k:v for k,v in out.items() if k!='samples'},indent=2))
