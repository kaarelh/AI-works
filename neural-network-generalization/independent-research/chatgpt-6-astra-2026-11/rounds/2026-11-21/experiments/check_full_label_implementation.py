"""Numerical implementation checks, independent of posterior accuracy claims."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
import full_label_independent as f

rng=np.random.default_rng(2026112002);table=f.geometry_table()
max_geometry=max_corner=max_density=0.
for _ in range(40):
    ix=int(rng.integers(len(table['patterns'])));pattern=table['patterns'][ix]
    eps=2*((pattern>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
    z=eps[:,None]*f.BASE
    A=np.maximum(f.X@z.T,0)*f.SIGMA[None,:]/math.sqrt(f.R)
    max_geometry=max(max_geometry,float(np.max(abs(A@np.ones(f.K)-f.K*f.RHO*f.CHI))))
    direct=np.exp(np.log(np.diag(np.linalg.cholesky(f.GE))).sum()
                  -np.log(np.diag(np.linalg.cholesky(A.T@A))).sum())
    assert abs(direct-table['weights'][ix])<1e-12
    v,t,_=f.marks(rng,f.K);c=np.exp(rng.uniform(math.log(1e5),math.log(1e6),f.K))
    root=np.sqrt(v*v+4*c);a=(root+v)/2;rad=(root-v)/2
    U=np.column_stack([t[:,0]/np.sqrt(c),rad[:,None]*z/math.sqrt(f.R)+t[:,1:]*z/np.sqrt(c)[:,None]])
    phi=np.maximum(U@f.XBAR.T,0);G=phi@f.CHI/f.M
    h=np.sum(abs(t@f.ZERO_BAR.T),axis=1)/128
    predicted=f.SIGMA*(f.RHO*rad-h/np.sqrt(c))
    max_corner=max(max_corner,float(np.max(abs(G-predicted))))
    D=(a*a+np.sum(U*U,axis=1))/2-f.SIGMA*a*G/f.RHO
    local=v*v/2+np.sum(t*t,axis=1)/(2*c)+a/np.sqrt(c)*h/f.RHO
    max_density=max(max_density,float(np.max(abs(D-local))))
assert max_geometry<1e-12
assert max_corner<1e-11
assert max_density<1e-7
v,t,used=f.marks(rng,4000)
gamma=np.sum(abs(t@f.ZERO_BAR.T),axis=1)/128/f.RHO
assert abs(gamma.mean()-f.R)<.15
report=dict(status='PASS',geometry_cases=40,corner_and_density_cases=40*f.K,
            maximum_geometry_error=max_geometry,maximum_corner_error=max_corner,
            maximum_exponent_error=max_density,mark_samples=len(v),
            normalized_mark_radius_mean=float(gamma.mean()),expected_radius_mean=f.R,
            normalized_mark_radius_variance=float(gamma.var()),expected_radius_variance=f.R,
            mark_elementary_proposals=used,
            scope='Floating-point identities and distribution sanity check, not a proof of exact sampling or total-variation accuracy.')
(f.ROOT/'results/full_label_implementation_checks.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
