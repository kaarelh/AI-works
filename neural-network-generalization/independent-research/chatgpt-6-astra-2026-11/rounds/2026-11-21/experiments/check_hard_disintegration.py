"""Check full Gaussian disintegration and exact actual-margin reconstruction."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
from scipy.linalg import null_space
import full_label_independent as f
from gaussian_weight_limit import fast_marks

rng=np.random.default_rng(2026112141);patterns=f.geometry_table()['patterns']
max_coarea=max_output=max_gaussian=0.;cases=[]
for case in range(50):
    n=2048;N=n+f.K;s=.5;broad=1.7
    incoming=rng.normal(size=(n,f.R+1));H=np.maximum(f.XBAR@incoming.T,0)
    m=(f.CHI@H)/f.M/f.RHO;V=H@H.T
    pattern=rng.choice(patterns);eps=2*((pattern>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
    z=eps[:,None]*f.BASE;A=np.maximum(f.X@z.T,0)*f.SIGMA[None,:]/math.sqrt(f.R)
    B=null_space(A.T);C=B.T@V@B;precision=A.T@np.linalg.solve(V,A)
    slack=rng.exponential(f.M*f.RHO,size=f.M);target=N*s*f.CHI+f.CHI*slack-H@m
    mean=np.linalg.solve(precision,A.T@np.linalg.solve(V,target))
    c=mean+math.sqrt(broad)*np.linalg.solve(np.linalg.cholesky(precision).T,rng.normal(size=f.K))
    assert c.min()>0
    residual=target-A@c;d=B.T@target
    def logphi(v,cov):
        ch=np.linalg.cholesky(cov);q=np.linalg.solve(ch,v)
        return -len(v)/2*math.log(2*math.pi)-np.log(np.diag(ch)).sum()-.5*q@q
    logJ=-np.log(np.diag(np.linalg.cholesky(A.T@A))).sum()
    coarea=logphi(residual,broad*V)-logJ-logphi(d,broad*C)-logphi(c-mean,broad*np.linalg.inv(precision))
    max_coarea=max(max_coarea,abs(float(coarea)))
    v,t,_=fast_marks(rng,f.K);root=np.sqrt(v*v+4*c);readout=(root+v)/2;radial=(root-v)/2
    U=np.column_stack([t[:,0]/np.sqrt(c),radial[:,None]*z/math.sqrt(f.R)+t[:,1:]*z/np.sqrt(c)[:,None]])
    actualbig=(f.SIGMA*readout)@np.maximum(U@f.XBAR.T,0)
    e=actualbig-A@c;y=N*s*f.CHI+f.CHI*slack-actualbig
    xi=rng.normal(size=n);a=m+xi+H.T@np.linalg.solve(V,y-H@(m+xi))
    actual=H@a+actualbig
    max_output=max(max_output,float(np.max(abs(actual-(N*s*f.CHI+f.CHI*slack)))))
    assert np.all(f.CHI*actual>N*s)
    gaussian=logphi(residual-e,V)-logphi(residual,broad*V)-f.M/2*math.log(broad)
    explicit=-.5*(residual-e)@np.linalg.solve(V,residual-e)+.5/broad*residual@np.linalg.solve(V,residual)
    max_gaussian=max(max_gaussian,abs(float(gaussian-explicit)))
    envelope=.5/(broad-1)*e@np.linalg.solve(V,e)
    assert explicit<=envelope+1e-10
    cases.append(dict(minimum_actual_slack=float(np.min(f.CHI*actual-N*s)),minimum_requested_slack=float(slack.min()),
                      covariance_condition_number=float(np.linalg.cond(V))))
assert max_coarea<1e-9 and max_output<1e-7 and max_gaussian<1e-9
out=dict(status='PASS',cases=len(cases),maximum_log_coarea_identity_error=max_coarea,
         maximum_actual_output_reconstruction_error=max_output,maximum_log_gaussian_ratio_error=max_gaussian,
         minimum_actual_slack=min(x['minimum_actual_slack'] for x in cases),
         maximum_covariance_condition_number=max(x['covariance_condition_number'] for x in cases),
         scope='Floating-point algebra and actual hard-margin reconstruction. Incoming test vectors are Gaussian; this is not a complete critical-law rejection-sampler implementation.')
(f.ROOT/'results/hard_disintegration_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
