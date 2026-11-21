"""Exact transitions on empirical proposal atoms, using floating weights.

These finite empirical distributions are diagnostics for the correction
mechanism; their TV distances are not full neural posterior TV distances.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
from pathlib import Path
import json
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
out=[]
for path in sorted((ROOT/'results/full_label_campaign').glob('*_rep*.jsonl')):
    if path.name=='status.jsonl':continue
    rows=[json.loads(line) for line in path.read_text().splitlines() if line.strip()]
    rows=[r for r in rows if r.get('accepted')]
    if len(rows)<10:continue
    lw=np.array([r['logweight'] for r in rows]);p=np.exp(lw-lw.max());p/=p.sum()
    n=len(p);w=p*n;q=np.ones(n)/n
    transition=np.minimum(1,w[None,:]/w[:,None])/n
    reject=1-transition.sum(axis=1);transition[np.diag_indices(n)]+=reject
    assert np.max(abs(p@transition-p))<1e-12
    current=q.copy();tv=[];bound=[]
    for k in range(5):
        tv.append(float(np.sum(abs(current-p))/2))
        bound.append(float(np.mean(np.maximum(w-1,0)*reject**k)))
        assert tv[-1]<=bound[-1]+1e-12
        current=current@transition
    out.append(dict(name=path.stem,proposal_atoms=n,total_variation_by_updates=tv,coupling_bounds=bound,
                    centered_weight_moments={str(pw):float(np.mean(abs(w-1)**pw)) for pw in (1,2,3,4,5)}))
result=dict(status='diagnostic',scope='Finite empirical atom distributions only; not posterior TV certificates.',rows=out)
(ROOT/'results/empirical_mh_analysis.json').write_text(json.dumps(result,indent=2)+'\n')
for row in out:print(row['name'],row['proposal_atoms'],['%.6g'%v for v in row['total_variation_by_updates']])
