#!/usr/bin/env python3
"""Separate post-v3 exploratory, label-free q=1 signed-population search."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import concurrent.futures,json,time
from pathlib import Path
import numpy as np
from compression import cube,forward

ROOT=Path(__file__).resolve().parent

def output(weights,signs,x):
    n=len(weights[-1]);a=weights[0]@signs[0]/n
    h=np.tanh(x@a[:-1]+a[-1])
    for i,w in enumerate(weights[1:-1],start=1):h=np.tanh(h*(signs[i-1]@w@signs[i]/n))
    return h*(weights[-1]@signs[-1])

def worker(path):
    record=json.loads(path.read_text());target=ROOT/'q1-output-results'/path.name
    if target.exists():return {'id':record['id'],'cached':True}
    start=time.monotonic();ar=np.load(record['checkpoint']);keys=sorted([k for k in ar.files if k.startswith('w') and k[1:].isdigit()],key=lambda k:int(k[1:]));weights=[ar[k].astype(float) for k in keys]
    x=cube(record['d']);z,hs=forward(weights,x,True);reference=np.clip(z,-.5,.5);trials=[];best=None
    for init in ['output_correlation','clipped_output_correlation']:
      for penalty in [0.,1.]:
        zz=z if init=='output_correlation' else reference
        signs=[np.where(h.T@zz>=0,1.,-1.) for h in hs]
        def evaluate():
            diff=np.abs(np.clip(output(weights,signs,x),-.5,.5)-reference)
            return float(np.mean(diff**2)+penalty*diff.max()**2),float(diff.max()),float(np.mean(diff**2))
        loss,maximum,mse=evaluate();initial={'max_difference':maximum,'mse':mse};flips=0
        for sweep in range(4):
            changed=False
            for layer in np.random.default_rng(770+sweep).permutation(len(signs)):
                for unit in np.random.default_rng(991+layer+sweep).permutation(len(signs[layer])):
                    signs[layer][unit]*=-1;candidate,cm,cs=evaluate()
                    if candidate<loss-1e-15:
                        loss,maximum,mse=candidate,cm,cs;changed=True;flips+=1
                    else:signs[layer][unit]*=-1
            if not changed:break
        trial={'initialization':init,'maximum_penalty':penalty,'initial':initial,'max_clipped_difference':maximum,'mean_squared_clipped_difference':mse,'sign_flips':flips,'passes_float64':maximum<=1/16}
        trials.append(trial)
        if best is None or maximum<best['max_clipped_difference']:
            best={**trial,'q':1,'signed':True,'balanced':True,'groups':[np.zeros(len(s),dtype=int).tolist() for s in signs],'signs':[s.tolist() for s in signs]}
    result={'id':record['id'],'checkpoint':record['checkpoint'],'checkpoint_sha256':record['checkpoint_sha256'],'scope':'Exploratory search using only network outputs and hidden activations on the full cube; target and training labels are never read. Search failure is inconclusive. Float64, not interval certified.','trials':trials,'best':best,'seconds':time.monotonic()-start}
    target.parent.mkdir(exist_ok=True);target.write_text(json.dumps(result,indent=2)+'\n')
    return {'id':record['id'],'best_max_difference':best['max_clipped_difference'],'seconds':round(result['seconds'],2)}

if __name__=='__main__':
    paths=sorted((ROOT/'results-v3').glob('fresh*.json'))
    with concurrent.futures.ProcessPoolExecutor(max_workers=3) as pool:
        for result in pool.map(worker,paths):print(json.dumps(result),flush=True)
