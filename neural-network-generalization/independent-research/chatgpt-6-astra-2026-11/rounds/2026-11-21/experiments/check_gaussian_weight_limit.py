"""Independent covariance and exact finite-N Taylor checks for the weight limit."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
import mpmath as mp
from scipy.linalg import null_space
import full_label_independent as f
from gaussian_weight_limit import W,fast_marks
from critical_moment_importance import DEGREES
mp.mp.dps=60
rng=np.random.default_rng(2026112151)
info=json.loads((f.ROOT/'results/critical_moments_reference.json').read_text())
eigen=np.array(info['walsh_covariance_eigenvalues']);mc=info['critical_mean']
Sigma=(W*eigen[DEGREES])@W.T;alpha=(.5-mc)/(f.K*f.RHO)
patterns=f.geometry_table()['patterns'];records=[];max_cov=0.;max_geometry=0.
for loss in ['square','logistic']:
    lam=1/(f.RHO*.5) if loss=='square' else (1+math.exp(.5))/f.RHO
    g2=lam if loss=='square' else lam*math.exp(.5)/(1+math.exp(.5))**2
    gamma=g2/f.M;g3=0 if loss=='square' else lam*math.exp(.5)*(1-math.exp(.5))/(1+math.exp(.5))**3
    Qinv=np.linalg.inv(np.eye(f.M)+gamma*Sigma)
    errors={2**p:[] for p in [16,20,24,28,32,36]}
    for case in range(12):
        pat=rng.choice(patterns);eps=2*((pat>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
        z=eps[:,None]*f.BASE;A=np.maximum(f.X@z.T,0)*f.SIGMA[None,:]/math.sqrt(f.R)
        Ap=np.linalg.solve(A.T@A,A.T);P=np.eye(f.M)-A@Ap;B=null_space(A.T)
        St=Sigma-Sigma@B@np.linalg.solve(np.eye(f.K)/gamma+B.T@Sigma@B,B.T@Sigma)
        VD=np.linalg.inv(A.T@Qinv@A)/gamma
        VR=Qinv@A@VD@A.T@Qinv+Sigma@Qinv
        VDR=VD@A.T@Qinv
        checks=[VD-(Ap@St@Ap.T+np.linalg.inv(A.T@A)/gamma),
                VR-(P@St@P+ A@np.linalg.inv(A.T@A)@A.T/gamma),
                VDR-(-Ap@St@P+np.linalg.inv(A.T@A)@A.T/gamma)]
        max_cov=max(max_cov,*[float(np.max(abs(c))) for c in checks])
        D=np.linalg.cholesky(VD)@rng.normal(size=f.K)
        R=Qinv@A@D+np.linalg.cholesky(Sigma@Qinv)@rng.normal(size=f.M)
        Z=R-A@D
        v,t,_=fast_marks(rng,f.K)
        dot=z@f.X.T
        perturb=t[:,0,None]+(t[:,1:]*z)@f.X.T
        psi=np.where(dot>0,perturb,np.where(dot==0,np.maximum(perturb,0),0))*f.SIGMA[:,None]
        h=np.sum(abs(t@f.ZERO_BAR.T),axis=1)/128
        leading=-f.NU/alpha*D.sum()-(v*h).sum()/(2*f.RHO*math.sqrt(alpha))-gamma*R@psi.sum(axis=0)-g3/(6*f.M)*np.sum((f.CHI*R)**3)
        for N in errors:
            c=N*alpha+math.sqrt(N)*D
            assert c.min()>0
            root=np.sqrt(v*v+4*c);read=(root+v)/2;rad=(root-v)/2;q=read/np.sqrt(c)
            U=np.column_stack([t[:,0]/np.sqrt(c),rad[:,None]*z/math.sqrt(f.R)+(t[:,1:]*z)/np.sqrt(c)[:,None]])
            exactbig=(f.SIGMA*read)@np.maximum(U@f.XBAR.T,0)
            e=(q[:,None]*psi).sum(axis=0)
            max_geometry=max(max_geometry,float(np.max(abs(exactbig-A@c-e)))/N)
            R0=math.sqrt(N)*R-f.K*mc*f.CHI
            logratio=-f.NU*np.log1p(D/(alpha*math.sqrt(N))).sum()-.5*np.log1p(v*v/(4*c)).sum()-(np.sum(t*t,axis=1)/(2*c)).sum()-((q-1)*h/f.RHO).sum()
            if loss=='square':logratio-=gamma*(2*R0@e+e@e)/(2*N)
            else:
                # High precision evaluates the actual logistic residual, not its Taylor expansion.
                lmp=(1+mp.exp(mp.mpf('.5')))/mp.mpf(str(f.RHO));rmp=mp.mpf(str(f.RHO));smp=mp.mpf('.5')
                g=lambda y:y/rmp+lmp*mp.log(1+mp.exp(-y))
                g2mp=lmp*mp.exp(smp)/(1+mp.exp(smp))**2
                residual=mp.mpf('0')
                for rx,ex,chi in zip(R0,e,f.CHI):
                    u=mp.mpf(str(chi))*mp.mpf(str(rx+ex))/N
                    residual-=mp.mpf(N)/f.M*(g(smp+u)-g(smp))
                    residual+=g2mp/(2*f.M*N)*mp.mpf(str(rx))**2
                logratio+=float(residual)
            errors[N].append(math.sqrt(N)*logratio-leading)
    rows=[dict(N=N,rmse=float(np.sqrt(np.mean(np.array(e)**2))),max_absolute_error=float(np.max(abs(np.array(e))))) for N,e in errors.items()]
    # First-order error should shrink by about 4 for each 16-fold width increase.
    assert rows[-1]['rmse']<rows[0]['rmse']/100
    records.append(dict(loss=loss,cases=12,finite_width_taylor_errors=rows))
assert max_cov<1e-8 and max_geometry<1e-12
out=dict(status='PASS',maximum_covariance_identity_error=max_cov,maximum_relative_exact_corner_output_error=max_geometry,
         results=records,scope='Independent Gaussian covariance identities and high-precision finite-width logistic residual checks. These validate formulas, not the limiting theorem or finite-width TV.')
(f.ROOT/'results/gaussian_weight_limit_checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
