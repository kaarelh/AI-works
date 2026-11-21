"""Finite-dimensional quarter-power weight law for the softplus proposal.

This computes the conditional-pilot limiting proposal diagnostic. It is not
an exact TV constant for the mixture over estimated pilots or a certified
finite-width posterior bound.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
import full_label_independent as f
import gaussian_weight_limit as g
import softplus_corrected_proposal as sp
from critical_moment_importance import DEGREES

def draw(rng,count,patterns,cdf,q,G0,eigen,alpha,gamma):
    pats=patterns[np.searchsorted(cdf,rng.random(count))]
    eps=2*((pats[:,None]>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
    z=eps[:,:,None]*f.BASE[None,:,:]
    L=math.sqrt(f.M)/(2*math.sqrt(f.R))*f.BASE.T[None,:,:]*(eps*f.SIGMA)[:,None,:]
    gram=G0[None,:,:]+q[g.SINGLE[0]]*L.transpose(0,2,1)@L
    chol=np.linalg.cholesky(gram)
    D=np.linalg.solve(chol.transpose(0,2,1),rng.normal(size=(count,f.K,1)))[:,:,0]/math.sqrt(gamma)
    AD=np.zeros((count,f.M));AD[:,g.EVEN]=D@g.EH.T;AD[:,g.SINGLE]=np.einsum('brk,bk->br',L,D)
    RH=q*AD+rng.normal(size=(count,f.M))*np.sqrt(eigen[DEGREES]*q)
    R=RH@g.W.T
    tc=rng.normal(size=(count*f.K,f.R))@sp.TCHOL.T
    t=(tc@f.TBASE.T).reshape(count,f.K,f.R+1)
    dots=np.einsum('bkr,xr->bkx',z,f.X)
    perturb=t[:,:,0,None]+np.einsum('bkr,xr->bkx',t[:,:,1:]*z,f.X)
    B=alpha**.25*np.sum(f.SIGMA[None,:,None]*((dots>0)+.5*(dots==0))*perturb,axis=1)
    assert np.max(abs(B@f.CHI))<1e-10
    return -gamma*np.sum(R*B,axis=1)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--loss',choices=['square','logistic'],default='square')
    ap.add_argument('--samples',type=int,default=2000000);ap.add_argument('--seed',type=int,required=True)
    ap.add_argument('--moments',type=Path,default=f.ROOT/'results/softplus_critical_moments_beta1.json')
    ap.add_argument('--output',type=Path,required=True);args=ap.parse_args()
    info=json.loads(args.moments.read_text());eigen=np.array(info['walsh_covariance_eigenvalues']);mc=info['critical_mean']
    alpha=(.5-mc)/(f.K*f.RHO)
    lam=1/(f.RHO*.5) if args.loss=='square' else (1+math.exp(.5))/f.RHO
    gamma=lam/f.M if args.loss=='square' else lam*math.exp(.5)/(1+math.exp(.5))**2/f.M
    patterns=f.geometry_table()['patterns'];start=time.monotonic();cdf,q,G0=g.orientation_cdf(patterns,gamma,eigen)
    rng=np.random.default_rng(args.seed);parts=[]
    for first in range(0,args.samples,256):
        parts.append(draw(rng,min(256,args.samples-first),patterns,cdf,q,G0,eigen,alpha,gamma))
        if len(parts)%1000==0:print(json.dumps(dict(samples=sum(map(len,parts)),seconds=time.monotonic()-start)),flush=True)
    L=np.concatenate(parts);centered=L-L.mean();est=g.constants(centered)
    block=np.array([g.constants(v-v.mean()) for v in np.array_split(L,40)]);se=block.std(0,ddof=1)/math.sqrt(40)
    out=dict(loss=args.loss,beta=sp.BETA,samples=len(L),seed=args.seed,seconds=time.monotonic()-start,
             moment_input=str(args.moments),C0_conditional_limit=float(est[0]),C1_conditional_limit=float(est[1]),variance=float(est[2]),
             block_standard_errors=se.tolist(),uncentered_mean=float(L.mean()),uncentered_mean_standard_error=float(L.std(ddof=1)/math.sqrt(len(L))),
             scope='Monte Carlo of the quarter-power limiting weight formula in the softplus sampling paper, using estimated critical moments; not a certified finite-width total-variation estimate.')
    args.output.parent.mkdir(exist_ok=True,parents=True);args.output.write_text(json.dumps(out,indent=2)+'\n')
    np.savez_compressed(args.output.with_suffix('.npz'),L=L);print(json.dumps(out,indent=2))
if __name__=='__main__':main()
