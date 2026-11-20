"""Exploratory exhaustive-cone sequence scan; all numerical gaps are provisional."""
import contextlib,json,time
from pathlib import Path
import numpy as np
import fivebit_variation_search as s
OUT=s.ROOT/'results/fivebit_variation';OUT.mkdir(exist_ok=True)
old=[15,14,13,11,10,9,7,6,3,5,2,8,1,12,4,0]
rev=lambda q:sum(((q>>(3-j))&1)<<j for j in range(4))
order=[1+2*rev(q) for q in old]+[2*rev(q) for q in old]
y=np.prod(s.X[:,1:4],axis=1)*np.where(np.all(s.X[:,4:]==1,axis=1),1,-1)
V,H=s.initial_dictionary();started=time.monotonic();rows=[]
for prefix in range(1,32):
    ids=order[:prefix];labels=y[ids].copy();margins=np.full(prefix,.5)
    name=f'gate_recursive_prefix{prefix}_history'
    with (OUT/(name+'.log')).open('w') as log,contextlib.redirect_stdout(log):
        result=s.solve(ids,labels,margins,V,H,tol=1e-6,maxiter=70)
    V,H=result['V'],result['H'];pred=float(y[order[prefix]]*result['predictions'][order[prefix]])
    np.savez_compressed(OUT/(name+'.npz'),**{k:v for k,v in result.items() if isinstance(v,np.ndarray)},ids=ids,labels=labels,margins=margins,order=order,target=y)
    row={k:v for k,v in result.items() if not isinstance(v,np.ndarray)}
    row.update(prefix=prefix,query=order[prefix],signed_prediction=pred)
    if pred < -1e-5:
        name=f'gate_recursive_prefix{prefix}_correct'
        ids=order[:prefix+1];labels=y[ids];margins=np.r_[margins,0.]
        with (OUT/(name+'.log')).open('w') as log,contextlib.redirect_stdout(log):
            cor=s.solve(ids,labels,margins,V,H,tol=1e-6,maxiter=70)
        V,H=cor['V'],cor['H']
        np.savez_compressed(OUT/(name+'.npz'),**{k:v for k,v in cor.items() if isinstance(v,np.ndarray)},ids=ids,labels=labels,margins=margins,order=order,target=y)
        row.update(correct_upper=cor['upper'],correct_lower=cor['lower'],gap=cor['lower']-result['upper'])
    rows.append(row);print(json.dumps(row),flush=True)
    (OUT/'recursive_campaign.json').write_text(json.dumps(dict(rows=rows,seconds=time.monotonic()-started,qualification='Floating global cone-polar bounds; not an exact certificate.'),indent=2)+'\n')
