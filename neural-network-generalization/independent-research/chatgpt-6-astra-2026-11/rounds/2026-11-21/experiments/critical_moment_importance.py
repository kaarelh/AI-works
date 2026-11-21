"""Rao--Blackwell importance integration of critical ReLU moments, r=6.

The minimum absolute incoming coordinate has a Lomax proposal. The other
coordinates are exact truncated half-normals, and the bias has a narrow
Laplace proposal. Conditional Gaussian readout moments are integrated out.
The heavy minimum-coordinate proposal stabilizes fourth parameter moments.
This is floating-point integration with block standard errors, not a
certified enclosure or a posterior sampler.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp
import full_label_independent as f

DEGREES=np.array([int(i).bit_count() for i in range(f.M)])
BASE_PHI=np.maximum(f.X.sum(axis=1),0)

def walsh(values):
    out=values.copy()
    h=1
    while h<f.M:
        block=out.reshape(len(out),-1,2*h)
        a=block[:,:,:h].copy();b=block[:,:,h:].copy()
        block[:,:,:h]=a+b;block[:,:,h:]=a-b;h*=2
    # X uses bits 0 -> -1, so this Walsh convention differs by degree sign.
    return out/f.M*((-1.)**DEGREES)

BASE_HAT=walsh(BASE_PHI[None,:])[0]

def batch(rng,count,shape=1.,bias_scale=4.):
    t=np.expm1(-np.log(rng.random(count))/shape)
    excess=np.zeros((count,f.R))
    small=t<1
    if small.any():
        tt=t[small,None]
        excess[small,1:]=-ndtri_exp(log_ndtr(-tt)+np.log(rng.random((small.sum(),f.R-1))))-tt
    large=np.flatnonzero(~small)
    if len(large):
        rates=np.repeat(t[large],f.R-1);vals=np.empty(len(rates));pending=np.arange(len(rates))
        while len(pending):
            u=rng.exponential(size=len(pending))/rates[pending]
            ok=np.log(rng.random(len(pending)))<-u*u/2
            vals[pending[ok]]=u[ok];pending=pending[~ok]
        excess[large,1:]=vals.reshape(-1,f.R-1)
    scale=bias_scale/(1+t);bias=rng.laplace(size=count)*scale
    perturb=bias[:,None]+excess@f.X.T
    cone=np.max(abs(perturb),axis=1)<2*t
    hat=np.empty((count,f.M));gcorrection=np.empty(count)
    if cone.any():
        signs=f.X.sum(axis=1)
        psi=np.where(signs>0,perturb[cone],np.where(signs==0,np.maximum(perturb[cone],0),0))
        psihat=walsh(psi)
        hat[cone]=t[cone,None]*BASE_HAT+psihat
        gcorrection[cone]=psihat[:,-1]
        assert gcorrection[cone].max()<1e-10
    if (~cone).any():
        phi=np.maximum(t[~cone,None]*f.X.sum(axis=1)+perturb[~cone],0)
        hat[~cone]=walsh(phi)
    G=hat[:,-1]
    logtilt=np.empty(count)
    logtilt[cone]=math.sqrt(f.R)*t[cone]*(gcorrection[cone]/f.RHO)+.5*(gcorrection[cone]/f.RHO)**2
    logtilt[~cone]=.5*((G[~cone]/f.RHO)**2-f.R*t[~cone]**2)
    assert logtilt.max()<1e-7
    loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
    logqt=math.log(shape)-(shape+1)*np.log1p(t)
    logqb=-np.log(2*scale)-abs(bias)/scale
    logweight=math.log(f.R)+f.R*math.log(f.HALF)+(f.R-1)*loga+logtilt-bias*bias/2-.5*math.log(2*math.pi)-logqt-logqb
    weight=np.exp(logweight)
    a2=1+(G/f.RHO)**2
    spectral=np.column_stack([f.M*np.mean(hat[:,DEGREES==j]**2,axis=1)*a2 for j in range(f.R+1)])
    rows=np.column_stack([weight,weight*G*G/f.RHO,weight[:,None]*spectral])
    return rows.mean(axis=0),dict(maximum_weight=float(weight.max()),maximum_min_coordinate=float(t.max()),
                                 cone_fraction=float(cone.mean()),maximum_weighted_moment=float(rows.max()))

def summarize(blocks,meta,args,elapsed):
    values=np.array(blocks);means=values.mean(0)
    Mstar=means[0];mc=means[1]/Mstar
    eigen=means[2:]/Mstar;eigen[-1]-=f.M*mc*mc
    # Delete-one-block jackknife for ratio and covariance standard errors.
    if len(values)>2:
        loo=(values.sum(0)-values)/(len(values)-1)
        estimates=np.column_stack([loo[:,0],loo[:,1]/loo[:,0],loo[:,2:]/loo[:,:1]])
        estimates[:,-1]-=f.M*estimates[:,1]**2
        se=np.sqrt((len(values)-1)*np.mean((estimates-estimates.mean(0))**2,axis=0))
    else:se=np.full(9,np.nan)
    return dict(samples=len(values)*args.batch,blocks=len(values),batch=args.batch,seed=args.seed,
                proposal_shape=args.shape,bias_scale=args.bias_scale,seconds=elapsed,
                Mstar=float(Mstar),critical_mean=float(mc),walsh_covariance_eigenvalues=eigen.tolist(),
                jackknife_standard_errors=se.tolist(),
                max_weight=max(x['maximum_weight'] for x in meta),max_min_coordinate=max(x['maximum_min_coordinate'] for x in meta),
                maximum_weighted_moment=max(x['maximum_weighted_moment'] for x in meta),
                scope='Floating-point importance integration; block uncertainty estimates are not certified error bounds.')

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--blocks',type=int,default=200);ap.add_argument('--batch',type=int,default=16384)
    ap.add_argument('--seed',type=int,default=2026112104);ap.add_argument('--shape',type=float,default=1.)
    ap.add_argument('--bias-scale',type=float,default=4.);ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();rng=np.random.default_rng(args.seed);blocks=[];meta=[];start=time.monotonic()
    for i in range(args.blocks):
        value,info=batch(rng,args.batch,args.shape,args.bias_scale);blocks.append(value);meta.append(info)
        if (i+1)%20==0 or i+1==args.blocks:
            result=summarize(blocks,meta,args,time.monotonic()-start)
            result['status']='complete' if i+1==args.blocks else 'in_progress'
            args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,indent=2)+'\n')
            np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(blocks))
            print(json.dumps({k:result[k] for k in ['samples','Mstar','critical_mean','seconds']}),flush=True)
if __name__=='__main__':main()
