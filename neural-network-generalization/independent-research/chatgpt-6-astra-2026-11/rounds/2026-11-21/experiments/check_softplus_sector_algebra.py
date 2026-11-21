"""Independent checks of softplus orientation, Gaussian shifts and quarter-scale error."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
import full_label_independent as f
from gaussian_weight_limit import W
from critical_moment_importance import DEGREES
rng=np.random.default_rng(2026112211);patterns=f.geometry_table()['patterns']
info=json.loads((f.ROOT/'results/critical_moments_reference.json').read_text())
# Any positive Walsh-diagonal covariance tests these algebraic identities.
Sigma=(W*np.array(info['walsh_covariance_eigenvalues'])[DEGREES])@W.T;Si=np.linalg.inv(Sigma)
mc=info['critical_mean'];s=.5;alpha=(s-mc)/(f.K*f.RHO);beta=1.;p0=len(f.ZERO)/f.M
kappa=p0*math.log(2)/(beta*f.RHO);tau=kappa/(2*math.sqrt(alpha));h0=f.K*f.RHO*kappa*math.sqrt(alpha)
lam=2/f.RHO;gamma=lam/f.M;Qinv=np.linalg.inv(np.eye(f.M)+gamma*Sigma);lchi=float(f.CHI@Sigma@f.CHI/f.M)
Q=f.TBASE.T@(f.ZERO_BAR.T@f.ZERO_BAR/f.M)@f.TBASE;tcov=4*f.RHO/beta*np.linalg.inv(Q)
max_zero=max_derivative=max_mean=max_norm=max_cov=0.;hard_norms=[];soft_norms=[];errors={2**p:[] for p in [12,16,20,24,28,32]}
for case in range(30):
    pat=rng.choice(patterns);eps=2*((pat>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
    z=eps[:,None]*f.BASE;dots=z@f.X.T
    A=np.maximum(dots.T,0)*f.SIGMA[None,:]/math.sqrt(f.R)
    Ap=np.linalg.solve(A.T@A,A.T);P=np.eye(f.M)-A@Ap
    max_zero=max(max_zero,float(np.max(abs(f.SIGMA@(dots==0)+f.K*p0*f.CHI))))
    derivative=(dots>0)+.5*(dots==0)
    grad=(derivative*f.CHI)@f.XBAR*f.SIGMA[:,None]/f.M
    max_derivative=max(max_derivative,float(np.max(abs(grad-f.RHO*np.column_stack([np.zeros(f.K),z/math.sqrt(f.R)])))))
    H=A.T@Si@A;linear=A.T@Si@(h0*f.CHI)-tau
    mean=np.linalg.solve(H,linear);expected=kappa*math.sqrt(alpha)-tau*lchi/(f.K*f.M*f.RHO**2)
    max_mean=max(max_mean,float(np.max(abs(mean-expected))))
    hard_norms.append(float(.5*linear@mean-.5*h0*h0*f.CHI@Si@f.CHI))
    precision=np.block([[Si+gamma*np.eye(f.M),gamma*A],[gamma*A.T,gamma*A.T@A]])
    linear=np.r_[gamma*h0*f.CHI,gamma*h0*A.T@f.CHI-tau]
    mean=np.linalg.solve(precision,linear)
    expectedZ=tau*lchi/(f.M*f.RHO)*f.CHI
    expectedD=kappa*math.sqrt(alpha)-tau*(lchi+1/gamma)/(f.K*f.M*f.RHO**2)
    max_mean=max(max_mean,float(np.max(abs(mean[:f.M]-expectedZ))),float(np.max(abs(mean[f.M:]-expectedD))))
    soft_norms.append(float(.5*linear@mean-.5*gamma*h0*h0*f.M))
    VD=np.linalg.inv(A.T@Qinv@A)/gamma
    D=np.full(f.K,expectedD)+np.linalg.cholesky(VD)@rng.normal(size=f.K)
    # Complete the conditional Gaussian square for Z given D.
    Z=-gamma*Sigma@Qinv@(A@D-h0*f.CHI)+np.linalg.cholesky(Sigma@Qinv)@rng.normal(size=f.M)
    R=Z+A@D-h0*f.CHI
    v=rng.normal(-kappa/2,1,size=f.K);tc=rng.normal(size=(f.K,f.R))@np.linalg.cholesky(tcov).T
    t=tc@f.TBASE.T;rotated=np.column_stack([t[:,0],t[:,1:]*z])
    B=alpha**.25*np.sum(f.SIGMA[:,None]*derivative*(rotated@f.XBAR.T),axis=0)
    assert abs(f.CHI@B)<1e-10
    leading=-gamma*R@B
    mu=-tau/(gamma*f.K*f.M*f.RHO**2)
    limitconstant=-tau*h0/f.RHO+tau*tau/(2*gamma*f.M*f.RHO**2)
    for N in errors:
        c=N*alpha+math.sqrt(N)*D
        if c.min()<=0:continue
        root=np.sqrt(v*v+4*c);read=(root+v)/2;rad=(root-v)/2;u=rotated/c[:,None]**.25
        incoming=np.column_stack([np.zeros(f.K),rad[:,None]*z/math.sqrt(f.R)])+u
        pre=incoming@f.XBAR.T
        if np.any(np.max(abs(u@f.XBAR.T),axis=1)>rad/math.sqrt(f.R)):continue
        actualbig=np.sum((f.SIGMA*read)[:,None]*np.logaddexp(0,beta*pre)/beta,axis=0)
        Y=(N-f.K)*mc*f.CHI+math.sqrt(N)*Z
        actualres=Y+actualbig-N*s*f.CHI
        c0=N*s/(f.K*f.RHO)-Ap@Y
        eta=(c-c0)/math.sqrt(N)-kappa*math.sqrt(alpha)
        proxy=gamma*np.sum((P@Y)**2)/(2*N)+gamma*np.sum((A@(eta-mu))**2)/2
        logloss=-gamma*np.sum(actualres*actualres)/(2*N)
        # Exact critical corner ratio, evaluated without subtracting O(N) energies.
        tbase=tc@f.TBASE.T;ubase=tbase/c[:,None]**.25;zero=ubase@f.ZERO_BAR.T
        hdiff=np.logaddexp(beta*zero/2,-beta*zero/2).sum(axis=1)/(beta*f.M)-p0*math.log(2)/beta
        quadratic=beta/(8*f.RHO)*np.sum((tc@Q)*tc,axis=1)
        delta=np.sum(f.CHI[None,:]*f.SIGMA[:,None]*np.logaddexp(0,-beta*abs(pre))*(dots!=0),axis=1)/(beta*f.M)
        rem=v*v/(2*(root+2*np.sqrt(c)))
        corner=-.5*np.log1p(v*v/(4*c))-.5*np.sum(u*u,axis=1)-kappa*rem-read/f.RHO*hdiff+quadratic+read/f.RHO*delta
        logmacro=-kappa*np.sum((c-N*alpha)/(np.sqrt(c)+math.sqrt(N*alpha)))-(f.R+2)/4*np.log(c/(N*alpha)).sum()+corner.sum()
        logratio=logmacro-tau*(f.CHI@Z)/(f.M*f.RHO)+logloss+proxy-limitconstant
        errors[N].append(N**.25*logratio-leading)
max_norm=max(np.ptp(hard_norms),np.ptp(soft_norms))
assert max_zero<1e-12 and max_derivative<1e-12 and max_mean<1e-8 and max_norm<1e-8
rows=[dict(N=N,cases=len(e),rmse=float(np.sqrt(np.mean(np.array(e)**2))),maximum_error=float(np.max(abs(np.array(e))))) for N,e in errors.items()]
assert rows[-1]['rmse']<rows[1]['rmse']/10
out=dict(status='PASS',maximum_zero_layer_identity_error=max_zero,maximum_transverse_parity_gradient_error=max_derivative,
         maximum_gaussian_mean_identity_error=max_mean,maximum_orientation_normalization_shift_spread=max_norm,
         quarter_order_density_ratio_errors=rows,
         scope='Finite-dimensional algebra and asymptotic formula checks using an arbitrary positive Walsh covariance. These do not implement or certify a softplus posterior sampler.')
(f.ROOT/'results/softplus_sector_algebra_checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
