"""Check the antithetic raw-bank construction, including nonzero biases.

The algebra holds for arbitrary banks. Exact critical banks additionally
check the simultaneous nearby-parity transfer conclusion. This is a finite
floating-point implementation check, not a posterior or sampling certificate.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import itertools,json,math
import numpy as np
import full_label_independent as f
rng=np.random.default_rng(2026112261)
deleted=list(itertools.combinations(range(f.R),2))
target=np.stack([f.CHI*f.X[:,i]*f.X[:,j] for i,j in deleted])
neg=np.array([np.where(np.all(f.X==-x,axis=1))[0][0] for x in f.X])
max_identity=max_likelihood=max_energy=max_exact=max_cost=0.;ratios=[]
for trial in range(120):
    if trial<60:
        pat=int(rng.choice(f.geometry_table()['patterns']))
        eps=2*((pat>>np.arange(f.K))&1)-1
        z=eps[:,None]*f.BASE
        w=z/math.sqrt(f.R*f.RHO);b=np.zeros(f.K);read=f.SIGMA/math.sqrt(f.RHO)
        if trial>=30:
            w=w+rng.normal(scale=.015,size=w.shape);b=rng.normal(scale=.02,size=f.K)
    else:
        w=rng.normal(size=(f.K,f.R));b=rng.normal(size=f.K);read=rng.normal(size=f.K)
    source=np.maximum(f.X@w.T+b,0)@read/f.K
    reflected=np.maximum(-f.X@w.T+b,0)@read/f.K
    max_identity=max(max_identity,float(np.max(abs(reflected-source[neg]))))
    max_energy=max(max_energy,abs(float(np.sum(w*w)+np.sum(b*b)+np.sum(read*read))-
                                    float(np.sum((-w)**2)+np.sum(b*b)+np.sum(read*read))))
    for loss in (lambda y:.5*(1-y)**2,lambda y:np.logaddexp(0,-y)):
        max_likelihood=max(max_likelihood,abs(float(np.mean(loss(f.CHI*source)))-
                                                 float(np.mean(loss(f.CHI*reflected)))))
    signs=np.where(w>=0,1.,-1.)
    mod=np.stack([signs[:,i]*signs[:,j] for i,j in deleted])
    coef=-3*mod*read[None,:]/f.K
    phi=np.maximum(f.X@w.T+b,0)
    phiref=np.maximum(-f.X@w.T+b,0)
    q=coef@phi.T;qref=coef@phiref.T
    ell=-3*np.einsum('tk,k,kr->tr',mod,read*np.sqrt(np.sum(w*w,axis=1)+b*b),signs)/(2*f.K*math.sqrt(f.R))
    error=q-target-ell@f.X.T
    g=.5*(q+qref)
    max_identity=max(max_identity,float(np.max(abs(g-target-.5*(error+error[:,neg])))))
    before=np.sum(error**2,axis=1);after=np.sum((g-target)**2,axis=1)
    assert np.max(after-before)<1e-10
    ratios.extend((after/np.maximum(before,1e-30)).tolist())
    # K=(phi phi^T)/K, concatenated Kanti=(K+Kref)/2.
    original_coef=math.sqrt(f.K)*coef
    stacked=np.concatenate([original_coef,original_coef],axis=1)/math.sqrt(2)
    max_cost=max(max_cost,float(np.max(abs(np.sum(stacked**2,axis=1)-np.sum(original_coef**2,axis=1)))))
    if trial<30:max_exact=max(max_exact,float(np.max(abs(g-target))))
assert max_identity<1e-11 and max_exact<1e-11 and max_likelihood<1e-10 and max_cost<1e-10
out=dict(status='PASS',banks=120,tasks_per_bank=len(deleted),exact_critical_banks=30,
         perturbed_critical_banks=30,arbitrary_biased_banks=60,
         maximum_reflection_and_cancellation_error=max_identity,
         maximum_source_likelihood_difference=max_likelihood,maximum_energy_difference=max_energy,
         maximum_exact_target_error=max_exact,maximum_direct_sum_cost_error=max_cost,
         maximum_squared_error_ratio=max(ratios),
         scope='Finite floating-point reflection, cancellation, norm and likelihood checks. No posterior sampling or population generalization claim is inferred.')
(f.ROOT/'results/antithetic_transfer_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
