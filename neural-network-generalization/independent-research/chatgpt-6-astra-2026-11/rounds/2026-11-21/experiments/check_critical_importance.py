"""Independent density/transform checks and critical rejection normalizer."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp
import full_label_independent as f
import critical_moment_importance as ci

rng=np.random.default_rng(2026112105)
walsh=np.array([np.prod(f.X[:,[j for j in range(f.R) if (s>>j)&1]],axis=1) for s in range(f.M)]).T
vals=rng.normal(size=(100,f.M))
transform_error=float(np.max(abs(ci.walsh(vals)-vals@walsh/f.M)))
assert transform_error<1e-14

shape=1.;bias_scale=4.;t=np.exp(rng.uniform(-5,4,1000))
u=-ndtri_exp(log_ndtr(-t[:,None])+np.log(rng.random((len(t),f.R-1))))-t[:,None]
w=np.column_stack([t,t[:,None]+u]);scale=bias_scale/(1+t);bias=rng.laplace(size=len(t))*scale
phi=np.maximum(bias[:,None]+w@f.X.T,0);G=phi@f.CHI/f.M
logqt=math.log(shape)-(shape+1)*np.log1p(t)
logqb=-np.log(2*scale)-abs(bias)/scale
logprior=math.log(f.R)+f.R*math.log(f.HALF)-np.sum(w*w,axis=1)/2-bias*bias/2-.5*math.log(2*math.pi)
logconditional=(f.R-1)*math.log(f.HALF)-np.sum(w[:,1:]**2,axis=1)/2-(f.R-1)*(math.log(2)+log_ndtr(-t))
direct=logprior+G*G/(2*f.RHO*f.RHO)-logqt-logqb-logconditional
loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
stable=math.log(f.R)+f.R*math.log(f.HALF)+(f.R-1)*loga+.5*((G/f.RHO)**2-f.R*t*t)-bias*bias/2-.5*math.log(2*math.pi)-logqt-logqb
density_error=float(np.max(abs(direct-stable)))
assert density_error<1e-10

# Independent bounded-probability estimator from the original rejection
# envelope; draw the first-stage coin and integrate its second-stage coin.
blocks=[];N=1000*16384
for block in range(1000):
    size=16384;t=np.expm1(-np.log(rng.random(size))/(f.R-2))/f.HALF
    loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
    first=np.log(rng.random(size))<(f.R-1)*(math.log(f.HALF)+loga+np.log1p(f.HALF*t))
    t=t[first];w=-ndtri_exp(log_ndtr(-t)[:,None]+np.log(rng.random((len(t),f.R))))
    w[:,0]=t;b=rng.normal(size=len(t));g=np.maximum(b[:,None]+w@f.X.T,0)@f.CHI/f.M
    penalty=.5*(f.R*t*t-(g/f.RHO)**2)
    assert penalty.min()>-1e-7
    contribution=np.exp(-np.maximum(penalty,0)).sum()/size
    blocks.append(f.R/(f.R-2)*contribution)
out=dict(status='PASS',maximum_walsh_error=transform_error,maximum_log_density_error=density_error,
         rejection_proposals=N,rejection_normalizer_estimate=float(np.mean(blocks)),
         rejection_block_standard_error=float(np.std(blocks,ddof=1)/math.sqrt(len(blocks))),
         hoeffding_99_percent_radius=f.R/(f.R-2)*math.sqrt(math.log(200)/(2*N)),
         scope='Floating-point identities plus an independent bounded rejection-normalizer estimator. Statistical radius assumes exact arithmetic.')
(f.ROOT/'results/critical_importance_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
