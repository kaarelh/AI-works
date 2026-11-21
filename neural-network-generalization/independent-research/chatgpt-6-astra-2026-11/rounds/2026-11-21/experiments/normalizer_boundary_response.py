"""Coupled finite-temperature test of the third-order normalizer response.

An exact fundamental-theorem-of-calculus identity localizes the difference
to one input hyperplane. Pairing its two faces subtracts the beta^-2 term
without subtracting separately estimated normalizers. The remaining
beta^3-scaled quantity should approach the positive boundary coefficient.
Monte Carlo errors are empirical, not certified enclosures.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp,zeta
import full_label_independent as f

def incoming(rng,n,shape):
    t=np.expm1(-np.log(rng.random(n))/shape)
    excess=np.zeros((n,f.R));small=t<1
    if small.any():
        tt=t[small,None]
        excess[small,1:]=-ndtri_exp(log_ndtr(-tt)+np.log(rng.random((small.sum(),f.R-1))))-tt
    ix=np.flatnonzero(~small)
    if len(ix):
        rates=np.repeat(t[ix],f.R-1);pending=np.arange(len(rates));v=np.empty(len(rates))
        while len(pending):
            u=rng.exponential(size=len(pending))/rates[pending]
            keep=np.log(rng.random(len(pending)))<-u*u/2
            v[pending[keep]]=u[keep];pending=pending[~keep]
        excess[ix,1:]=v.reshape(-1,f.R-1)
    signs=2*rng.integers(0,2,(n,f.R))-1;ss=signs.sum(1)
    layer=signs@f.X.T-ss[:,None]
    perturb=(excess*signs)@(f.X-1).T
    bias=-t*ss-np.sum(excess*signs,axis=1)
    balanced=(ss==0)&(np.max(abs(perturb),axis=1)<2*t)
    G=np.empty(n);lt=np.empty(n)
    if balanced.any():
        psi=np.where(layer[balanced]>0,perturb[balanced],
                     np.where(layer[balanced]==0,np.maximum(perturb[balanced],0),0))
        gc=psi@f.CHI/f.M
        G[balanced]=-math.sqrt(f.R)*f.RHO*t[balanced]+gc
        lt[balanced]=-math.sqrt(f.R)*t[balanced]*gc/f.RHO+.5*(gc/f.RHO)**2
    pre=t[:,None]*layer+perturb
    if (~balanced).any():
        G[~balanced]=np.maximum(pre[~balanced],0)@f.CHI/f.M
        lt[~balanced]=.5*((G[~balanced]/f.RHO)**2-f.R*t[~balanced]**2)
    assert lt.max()<1e-7
    loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
    lqt=math.log(shape)-(shape+1)*np.log1p(t)
    lw=math.log(f.R)+f.R*math.log(f.HALF)+(f.R-1)*loga+lt-bias*bias/2-.5*math.log(2*math.pi)-lqt
    return pre,G,bias,lw

def batch(rng,n,betas,shape):
    pre,G,bias,lw=incoming(rng,n,shape)
    weight=np.exp(lw)
    u=rng.exponential(size=n);v=rng.random(n)
    lu=np.logaddexp(0,-u)*np.exp(u)
    rows=[np.mean(weight*G)*math.pi**2/(6*f.RHO**2),
          np.mean(weight*(1+(G/f.RHO)**2))*zeta(3,1)/(f.M*f.RHO**2)]
    for beta in betas:
        combined=np.zeros(n)
        for sign in (-1,1):
            shift=sign*u/beta
            delta=np.where(pre>=0,np.maximum(shift[:,None],-pre),np.maximum(pre+shift[:,None],0))
            dG=delta@f.CHI/f.M
            ds=np.logaddexp(0,-beta*abs(pre+shift[:,None]))@f.CHI/(f.M*beta)
            dg=dG+v*ds
            lr=-bias*shift-shift*shift/2+(G*dg+.5*dg*dg)/f.RHO**2
            stable=abs(lr)<1
            contribution=np.empty(n)
            contribution[stable]=weight[stable]*(G[stable]*np.expm1(lr[stable])+dg[stable]*np.exp(lr[stable]))
            contribution[~stable]=(G[~stable]+dg[~stable])*np.exp(lw[~stable]+lr[~stable])-G[~stable]*weight[~stable]
            combined+=contribution
        rows.append(float(np.mean(lu*combined))*beta/f.RHO**2)
    assert np.isfinite(rows).all()
    return np.array(rows)

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--blocks',type=int,default=1200);ap.add_argument('--batch',type=int,default=8192)
    ap.add_argument('--betas',type=float,nargs='+',default=[8,32,128,512])
    ap.add_argument('--shape',type=float,default=1.);ap.add_argument('--seed',type=int,default=2026112294)
    ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();rng=np.random.default_rng(args.seed);values=[];start=time.monotonic()
    for i in range(args.blocks):
        values.append(batch(rng,args.batch,args.betas,args.shape))
        if (i+1)%50==0 or i+1==args.blocks:
            arr=np.array(values);mu=arr.mean(0);se=arr.std(0,ddof=1)/math.sqrt(len(arr))
            record=dict(status='complete' if i+1==args.blocks else 'in_progress',samples=len(arr)*args.batch,
                betas=args.betas,seed=args.seed,shape=args.shape,seconds=time.monotonic()-start,
                normalizer_beta2_coefficient=float(mu[0]),normalizer_beta3_coefficient=float(mu[1]),
                beta3_exact_remainders=mu[2:].tolist(),block_standard_errors=se.tolist(),
                scope='An exact FTC identity with paired faces estimates beta^3*(M_beta-M_ReLU-A/beta^2). Paired Monte Carlo, not an interval certificate.')
            args.output.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record),flush=True)
    np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(values))

if __name__=='__main__':main()
