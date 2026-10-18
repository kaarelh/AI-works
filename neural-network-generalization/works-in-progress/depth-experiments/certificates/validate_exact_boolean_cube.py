#!/usr/bin/env python3
"""Independent scalar-interval cross-check of the batched exact clean forward."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
import json
import numpy as np,mpmath as mp
from exact_boolean_cube import forward_batch,endpoint_fraction
from verify_witness import interval,tanh_iv
mp.iv.dps=90;rng=np.random.default_rng(171026)
p=[rng.normal(size=(10,8))*.2,rng.normal(size=(8,8))*.2,rng.normal(size=(8,8))*.2,rng.normal(size=8)*.2]
x=(2*((np.arange(512)[:,None]>>np.arange(9))&1)-1).astype(float)
lo,hi,_=forward_batch(p,x)
indices=[0,1,7,31,127,255,256,510,511]
for i in indices:
 h=[interval(v)for v in np.r_[x[i],1.]]
 for w in p[:-1]:h=[tanh_iv(sum((h[k]*interval(w[k,j])for k in range(len(h))),mp.iv.mpf(0)))for j in range(w.shape[1])]
 output=sum((v*interval(w)for v,w in zip(h,p[-1])),mp.iv.mpf(0))
 assert lo[i]<=endpoint_fraction(output,False)<=endpoint_fraction(output,True)<=hi[i]
try:forward_batch(p,np.zeros((1,9)))
except ValueError:guard=True
else:raise AssertionError('Continuous inputs silently accepted.')
out=dict(seed=171026,vertices=512,width=8,hidden_depth=3,independent_scalar_interval_indices=indices,all_scalar_enclosures_contained=True,continuous_input_guard=guard)
(Path(__file__).resolve().parent/'exact-full-cube-validation.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out))
