"""Finite numerical check of raw critical-feature ensemble cancellation.

Uses exact full-parity critical representations in six dimensions, with
independent uniform balanced orientations. It checks the comparator
identities and bounded convex weights, not the finite-data posterior law.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import itertools,json,math
import numpy as np
from scipy.optimize import linprog
import full_label_independent as f

rng=np.random.default_rng(2026112103)
table=f.geometry_table();patterns=table['patterns']
deleted=list(itertools.combinations(range(f.R),2))
targets=np.stack([f.CHI*f.X[:,a]*f.X[:,b] for a,b in deleted])
alpha=-3.;records=[];max_source=max_decomposition=max_cancel=max_error=0.
for banks in (4,8,12,16,24,32,48,64,128):
    feasible=0;total=0;factors=[];maxcaps=[]
    for trial in range(40):
        pats=rng.choice(patterns,banks)
        eps=2*((pats[:,None]>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
        z=eps[:,:,None]*f.BASE[None,:,:]
        # Original incoming features and source readouts at optimal energy.
        features=np.maximum(np.einsum('xr,lkr->lxk',f.X,z),0)/math.sqrt(f.R*f.RHO)
        source=np.einsum('lxk,k->lx',features,f.SIGMA)/(f.K*math.sqrt(f.RHO))
        max_source=max(max_source,float(np.max(abs(source-f.CHI))))
        modulation=np.stack([z[:,:,a]*z[:,:,b] for a,b in deleted],axis=1)
        q=alpha*np.einsum('lxk,ltk,k->ltx',features,modulation,f.SIGMA)/(f.K*math.sqrt(f.RHO))
        ell=alpha*np.einsum('ltk,k,lkr->ltr',modulation,f.SIGMA,z)/(2*f.K*f.RHO*math.sqrt(f.R))
        max_decomposition=max(max_decomposition,float(np.max(abs(q-targets[None,:,:]-ell@f.X.T))))
        for task in range(len(deleted)):
            total+=1
            result=linprog(np.zeros(banks),A_eq=np.vstack([np.ones(banks),ell[:,task,:].T]),
                           b_eq=np.r_[1.,np.zeros(f.R)],bounds=[(0,4/banks)]*banks,method='highs')
            if not result.success:continue
            feasible+=1;beta=result.x
            max_cancel=max(max_cancel,float(np.linalg.norm(beta@ell[:,task,:])))
            max_error=max(max_error,float(np.max(abs(beta@q[:,task,:]-targets[task]))))
            factors.append(float(banks*(beta@beta)));maxcaps.append(float(banks*beta.max()))
            assert abs(beta.sum()-1)<1e-7 and beta.min()>-1e-7 and beta.max()<=4/banks+1e-7
            assert factors[-1]<=4+1e-7
    records.append(dict(banks=banks,trials=40,tasks_per_trial=len(deleted),feasible=feasible,total=total,
                        maximum_norm_factor=max(factors,default=None),mean_norm_factor=np.mean(factors) if factors else None))
assert max_source<1e-12 and max_decomposition<1e-12 and max_cancel<1e-7 and max_error<1e-7
out=dict(status='PASS',seed=2026112103,records=records,maximum_source_error=max_source,
         maximum_decomposition_error=max_decomposition,maximum_cancellation_error=max_cancel,
         maximum_target_error=max_error,
         scope='Finite floating-point identities and LP feasibility on uniform balanced critical representations; not a posterior-probability certificate.')
(f.ROOT/'results/ensemble_balancing_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
