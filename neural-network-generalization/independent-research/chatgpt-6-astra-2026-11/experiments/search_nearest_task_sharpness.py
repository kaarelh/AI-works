"""Exploratory search for the worst average nearest-task raw obstruction.

The exact six-bit sector list is used; matrix solves and extrema are
floating point. This is not an asymptotic proof or a theorem certificate.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];started=time.monotonic()
r=6;K=32
patterns=np.fromfile(ROOT/'results/relu_balanced_orientations_d6.bin',dtype='<u4')
U=2*((np.arange(K)[:,None]>>np.arange(r-1))&1)-1
masks=np.arange(K);degrees=np.array([int(i).bit_count() for i in masks]);even=degrees+(degrees%2)
W=np.stack([np.prod(U[:,[i for i in range(r-1) if mask>>i&1]],axis=1) for mask in masks],axis=1)
beta=np.array([15/16 if j==0 else 3/16 if j in (2,6) else -1/16 for j in even])
indices=np.array([0,1,2,4,8,16])[:,None]^masks[None,:]
best=(-1,None);smallest=(100,None);sum_value=0.;hist={}
for first in range(0,len(patterns),4096):
    eps=2*((patterns[first:first+4096,None]>>np.arange(K,dtype=np.uint32))&1).astype(np.int64)-1
    eh=eps@W/K
    L=eh[:,indices]/(2*beta[None,None,:])
    A=np.eye(r)[None,:,:]+L@L.transpose(0,2,1)
    near=L[:,:,even==4]
    solved=np.linalg.solve(A,near)
    total=np.einsum('bij,bij->b',near,solved)
    high=int(np.argmax(total));low=int(np.argmin(total))
    if total[high]>best[0]:best=(float(total[high]),int(patterns[first+high]))
    if total[low]<smallest[0]:smallest=(float(total[low]),int(patterns[first+low]))
    sum_value+=float(total.sum())
    for v,c in zip(*np.unique(np.round(total,9),return_counts=True)):hist[str(float(v))]=hist.get(str(float(v)),0)+int(c)
out=dict(status='complete',dimension=r,patterns=len(patterns),tasks=int(sum(even==4)),
    maximum_total_squared_error=best,minimum_total_squared_error=smallest,
    mean_total_squared_error=sum_value/len(patterns),
    monomial_total_squared_error=3*64/65,histogram=hist,seconds=time.monotonic()-started,
    qualification='Exploratory exhaustive floating-point calculation. No general upper-bound theorem is asserted.')
(ROOT/'results/nearest_task_sharpness_search.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k!='histogram'}))
