"""Check Gaussian/Beta residual-output laws and actual Gaussian reconstruction."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
from scipy.special import betaln,expit,gammaln
from scipy.linalg import null_space
import full_label_independent as f
rng=np.random.default_rng(2026112161);s=.5
max_identity=0.;max_output=0.;records=[]
for loss in ['square','logistic']:
    lam=2/f.RHO if loss=='square' else (1+math.exp(s))/f.RHO
    for N in [256,2048,16384]:
        if loss=='square':
            v=s+rng.normal(size=100000)*math.sqrt(f.M/(N*lam))
            g=v/f.RHO+lam*(1-v)**2/2
            logdensity=-.5*np.log(2*math.pi*f.M/(N*lam))-(v-s)**2*N*lam/(2*f.M)
            targetvariance=f.M/(N*lam)
        else:
            aa=N*(lam-1/f.RHO)/f.M;bb=N/(f.M*f.RHO)
            t=rng.beta(aa,bb,size=100000);v=np.log(t)-np.log1p(-t)
            g=v/f.RHO+lam*np.logaddexp(0,-v)
            logdensity=aa*np.log(t)+bb*np.log1p(-t)-betaln(aa,bb)
            from scipy.special import polygamma
            targetvariance=float(polygamma(1,aa)+polygamma(1,bb))
        constant=logdensity+N/f.M*g
        error=float(np.max(abs(constant-constant.mean())));max_identity=max(max_identity,error)
        records.append(dict(loss=loss,N=N,samples=len(v),mean=float(v.mean()),variance=float(v.var()),exact_variance=targetvariance,
                            density_identity_error=error))
        # Condition arbitrary ordinary Gaussian readouts on outputs from this law.
        n=1024;U=rng.normal(size=(n,f.R+1));H=np.maximum(f.XBAR@U.T,0);V=H@H.T
        mean=f.CHI@H/(f.M*f.RHO);target=N*f.CHI*v[:f.M]
        exceptional=rng.normal(size=f.M)  # any fixed exceptional output is permitted in the translation
        xi=rng.normal(size=n);read=mean+xi+H.T@np.linalg.solve(V,target-exceptional-H@(mean+xi))
        max_output=max(max_output,float(np.max(abs(H@read+exceptional-target))))
assert max_identity<1e-9 and max_output<1e-7
out=dict(status='PASS',maximum_density_identity_error=max_identity,maximum_actual_output_error=max_output,results=records,
         scope='Floating-point density identities, moments and exact-output Gaussian reconstruction; not a complete neural rejection sampler.')
(f.ROOT/'results/soft_output_sampling_checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
