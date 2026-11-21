"""Independent finite-width density-ratio check for the softplus sampler.

Compares Gaussian proposal densities and the actual critical exponent with
the cancellation-stable implementation formula, across different ray sets.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
import mpmath as mp
import full_label_independent as f
import softplus_corrected_proposal as sp
from gaussian_weight_limit import W
from critical_moment_importance import DEGREES
mp.mp.dps=50
rng=np.random.default_rng(2026112256);patterns=f.geometry_table()['patterns']
info=json.loads((f.ROOT/'results/softplus_critical_moments_beta1.json').read_text())
Sigma=(W*np.array(info['walsh_covariance_eigenvalues'])[DEGREES])@W.T
Schol=np.linalg.cholesky(Sigma);records=[];maxparity=0.
def logphi(x,V):
    ch=np.linalg.cholesky(V);u=np.linalg.solve(ch,x)
    return -len(x)/2*math.log(2*math.pi)-np.log(np.diag(ch)).sum()-.5*u@u
for loss in ['square','logistic']:
 for N in [4096,65536,1048576]:
    s=.5;mc_hat=.0006;alpha_hat=(s-mc_hat)/(f.K*f.RHO);tau=sp.KAPPA/(2*math.sqrt(alpha_hat))
    lam=1/(f.RHO*(1-s)) if loss=='square' else (1+math.exp(s))/f.RHO
    gamma=lam/f.M if loss=='square' else lam*math.exp(s)/(1+math.exp(s))**2/f.M
    mu=-tau/(gamma*f.K*f.M*f.RHO**2);offsets=[]
    for case in range(20):
        pat=rng.choice(patterns);sign=2*((pat>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1;z=sign[:,None]*f.BASE
        dots=z@f.X.T;A=np.maximum(dots.T,0)*f.SIGMA[None,:]/math.sqrt(f.R);gram=A.T@A
        Ap=np.linalg.solve(gram,A.T);Y=(N-f.K)*info['critical_mean']*f.CHI+math.sqrt(N)*Schol@rng.normal(size=f.M)
        PY=Y-A@(Ap@Y);eta=mu+np.linalg.solve(np.linalg.cholesky(gram).T,rng.normal(size=f.K))/math.sqrt(gamma)
        c=N*s/(f.K*f.RHO)-Ap@Y+math.sqrt(N)*(sp.KAPPA*math.sqrt(alpha_hat)+eta)
        assert c.min()>0
        v=rng.normal(-sp.KAPPA/2,1,size=f.K);tc=rng.normal(size=(f.K,f.R))@sp.TCHOL.T;t=tc@f.TBASE.T
        root=np.sqrt(v*v+4*c);read=(root+v)/2;rad=(root-v)/2
        u=np.column_stack([t[:,0],t[:,1:]*z])/c[:,None]**.25
        U=np.column_stack([np.zeros(f.K),rad[:,None]*z/math.sqrt(f.R)])+u
        pre=U@f.XBAR.T;phi=np.logaddexp(0,pre);G=phi@f.CHI/f.M
        aa=f.SIGMA*read;big=aa@phi;actual=Y+big;signed=f.CHI*actual/N
        if loss=='square':logW=-gamma*np.sum((actual-N*s*f.CHI)**2)/(2*N)
        else:
            lmp=mp.mpf(str(lam));rmp=mp.mpf(str(f.RHO));sm=mp.mpf('.5')
            gg=lambda y:y/rmp+lmp*mp.log(1+mp.exp(-y))
            logW=-N/f.M*float(sum(gg(mp.mpf(str(y)))-gg(sm) for y in signed))
        ordinary=-tau*(Y@f.CHI/f.M)/(f.RHO*math.sqrt(N))
        macro=-.5*(aa*aa+np.sum(U*U,axis=1))+aa*G/f.RHO-f.R/4*np.log(c)-np.log(root)
        logq=-.5*np.linalg.slogdet(gram)[1]-gamma*PY@PY/(2*N)
        logq+=logphi(eta-mu,np.linalg.inv(gram)/gamma)-f.K/2*math.log(N)
        logq+=sum(logphi(np.array([a+sp.KAPPA/2]),np.eye(1)) for a in v)
        logq+=sum(logphi(a,sp.TCOV) for a in tc)
        direct=macro.sum()+ordinary+logW-logq
        zero=(t/c[:,None]**.25)@f.ZERO_BAR.T
        hdiff=np.logaddexp(zero/2,-zero/2).sum(axis=1)/f.M-sp.P0*math.log(2)
        quadratic=np.sum((tc@sp.Q)*tc,axis=1)/(8*f.RHO)
        delta=np.sum(f.CHI[None,:]*f.SIGMA[:,None]*np.logaddexp(0,-abs(pre))*(dots!=0),axis=1)/f.M
        rem=v*v/(2*(root+2*np.sqrt(c)))
        corner=-.5*np.log1p(v*v/(4*c))-.5*np.sum(u*u,axis=1)-sp.KAPPA*rem-read/f.RHO*hdiff+quadratic+read/f.RHO*delta
        logmacro=-sp.NU*np.log(c/N).sum()-sp.KAPPA*np.sum((c-N*alpha_hat)/(np.sqrt(c)+math.sqrt(N*alpha_hat)))+corner.sum()
        stable=logmacro+ordinary+tau*(N-f.K)*mc_hat/(f.RHO*math.sqrt(N))+logW+gamma*PY@PY/(2*N)+gamma*np.sum((A@(eta-mu))**2)/2
        offsets.append(direct-stable)
        B=np.sum((c/N)[:,None]**.25*f.SIGMA[:,None]*((dots>0)+.5*(dots==0))*(np.column_stack([t[:,0],t[:,1:]*z])@f.XBAR.T),axis=0)
        maxparity=max(maxparity,abs(float(B@f.CHI)))
    spread=float(np.ptp(offsets));assert spread<2e-7,(loss,N,spread)
    records.append(dict(loss=loss,N=N,cases=20,common_log_ratio_offset_spread=spread))
assert maxparity<1e-10
out=dict(status='PASS',cases=records,maximum_common_observable_parity_error=maxparity,
         scope='Floating-point cross-state density identities, using actual Gaussian proposal densities and high-precision logistic residuals; not a proof of posterior TV.')
(f.ROOT/'results/softplus_proposal_density_checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
