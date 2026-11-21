"""Importance checks for the conditional softplus corner marks at fixed c.

The reference is the derived Gaussian mark law. The exact corner density
ratio is evaluated using stable nonzero-preactivation corrections. These
are conditional-c finite-dimensional diagnostics, not posterior TV claims.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
import numpy as np
import full_label_independent as f

def run(beta,c,count,rng):
    p0=math.comb(f.R,f.R//2)/f.M;kappa=p0*math.log(2)/(beta*f.RHO)
    Q=f.TBASE.T@(f.ZERO_BAR.T@f.ZERO_BAR/f.M)@f.TBASE
    covariance=4*f.RHO/beta*np.linalg.inv(Q);ch=np.linalg.cholesky(covariance)
    weights=[];moments=[];invalid=0;max_identity=0.
    for first in range(0,count,4096):
        n=min(4096,count-first);v=rng.normal(-kappa/2,1,size=n);tc=rng.normal(size=(n,f.R))@ch.T
        transverse=tc@f.TBASE.T;u=transverse/c**.25
        root=np.sqrt(v*v+4*c);A=(root+v)/2;R=(root-v)/2
        linear=R[:,None]*(f.X.sum(axis=1)/math.sqrt(f.R))[None,:]+u@f.XBAR.T
        good=(np.max(abs(u@f.XBAR.T),axis=1)<R/math.sqrt(f.R)) & (np.linalg.norm(u,axis=1)<.3*R)
        zero=u@f.ZERO_BAR.T
        hdiff=np.logaddexp(beta*zero/2,-beta*zero/2).sum(axis=1)/(beta*f.M)-len(f.ZERO_BAR)*math.log(2)/(beta*f.M)
        quadratic=beta/(8*f.RHO)*np.sum((tc@Q)*tc,axis=1)
        nonzero=f.X.sum(axis=1)!=0
        delta=(np.logaddexp(0,-beta*abs(linear[:,nonzero]))@f.CHI[nonzero])/(beta*f.M)
        sigma=(-1)**(f.R//2+1);delta*=sigma
        balance_remainder=v*v/(2*(root+2*math.sqrt(c)))
        logw=-.5*np.log1p(v*v/(4*c))-.5*np.sum(u*u,axis=1)-kappa*balance_remainder-A/f.RHO*hdiff+quadratic+A/f.RHO*delta
        # Check the stable exponent against a direct exact softplus evaluation on moderate c.
        if c<=1024:
            incoming=R[:,None]*np.r_[0.,np.ones(f.R)/math.sqrt(f.R)]+u
            G=np.logaddexp(0,beta*(incoming@f.XBAR.T))@f.CHI/(beta*f.M)
            D=.5*(A*A+np.sum(incoming*incoming,axis=1))-sigma*A*G/f.RHO
            direct=-.5*np.log1p(v*v/(4*c))-D+kappa*math.sqrt(c)+v*v/2+kappa*v/2+quadratic
            max_identity=max(max_identity,float(np.max(abs(direct[good]-logw[good]))))
        invalid+=int((~good).sum());logw[~good]=-np.inf
        weights.append(np.exp(logw));moments.append(np.column_stack([v,np.sum(tc*tc,axis=1)]))
    w=np.concatenate(weights);m=np.concatenate(moments);wn=w/w.mean()
    return dict(beta=beta,c=c,samples=count,reference_mass_outside_corner=invalid/count,relative_radial_factor=float(w.mean()),
                empirical_normalized_weight_discrepancy=float(np.mean(abs(wn-1))/2),
                weighted_balance_mean=float(np.mean(wn*m[:,0])),limiting_balance_mean=-kappa/2,
                weighted_scaled_transverse_norm2=float(np.mean(wn*m[:,1])),limiting_scaled_transverse_norm2=float(np.trace(covariance)),
                maximum_exact_exponent_identity_error=max_identity)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--samples',type=int,default=200000);ap.add_argument('--seed',type=int,default=2026112181);args=ap.parse_args()
    rng=np.random.default_rng(args.seed);start=time.monotonic();rows=[]
    for beta in [.5,1.,2.]:
        for c in [16,64,256,1024,4096,16384,65536]:
            row=run(beta,c,args.samples,rng);rows.append(row);print(json.dumps(row),flush=True)
    assert max(r['maximum_exact_exponent_identity_error'] for r in rows)<1e-8
    out=dict(status='PASS',seed=args.seed,seconds=time.monotonic()-start,results=rows,
             scope='Conditional-c corner importance diagnostics. No full-posterior sampler or certified TV estimate is claimed.')
    (f.ROOT/'results/softplus_corner_limit.json').write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
