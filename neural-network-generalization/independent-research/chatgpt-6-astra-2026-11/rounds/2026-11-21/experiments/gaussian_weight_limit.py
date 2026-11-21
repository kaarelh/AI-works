"""Monte Carlo of the finite-dimensional first-order importance-weight law.

Uses importance-integrated critical moments and an exactly enumerated
balanced-orientation space at r=6. Uncertainty in the estimated input
moments is separate from the displayed Monte Carlo uncertainty.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
import full_label_independent as f
from critical_moment_importance import DEGREES

W=np.array([np.prod(f.X[:,[j for j in range(f.R) if (s>>j)&1]],axis=1) for s in range(f.M)]).T/math.sqrt(f.M)
EVEN=np.flatnonzero(DEGREES%2==0);SINGLE=2**np.arange(f.R)
EH=W[:,EVEN].T@f.E
HLOW=math.sqrt(3)/16*(1-1e-12)  # exact integer certificate, rounded downward

def fast_marks(rng,count):
    found=[];accepted=0;used=0
    while accepted<count:
        batch=max(128,math.ceil((count-accepted)*9));used+=batch
        direction=rng.normal(size=(batch,f.R));direction/=np.linalg.norm(direction,axis=1)[:,None]
        h=np.sum(abs(direction@f.TRANSVERSE_ROWS.T),axis=1)/128
        assert h.min()>=HLOW
        keep=np.log(rng.random(batch))<f.R*np.log(HLOW/h)
        direction=direction[keep];h=h[keep]
        radius=rng.gamma(f.R,size=len(h))*f.RHO/h
        take=min(len(h),count-accepted);found.append(direction[:take]*radius[:take,None]);accepted+=take
    t=np.concatenate(found)@f.TBASE.T
    return rng.normal(size=count),t,used

def orientation_cdf(patterns,gamma,eigen):
    q=1/(1+gamma*eigen[DEGREES]);G0=EH.T@(q[EVEN,None]*EH);G0inv=np.linalg.inv(G0)
    weights=[]
    for first in range(0,len(patterns),4096):
        eps=2*((patterns[first:first+4096,None]>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
        L=math.sqrt(f.M)/(2*math.sqrt(f.R))*f.BASE.T[None,:,:]*(eps*f.SIGMA)[:,None,:]
        small=np.eye(f.R)[None,:,:]+q[SINGLE[0]]*(L@G0inv)@L.transpose(0,2,1)
        sign,ld=np.linalg.slogdet(small);assert np.all(sign>0)
        weights.append(np.exp(-ld/2))
    weights=np.concatenate(weights);cdf=np.cumsum(weights);cdf/=cdf[-1]
    return cdf,q,G0

def draw(rng,count,patterns,cdf,q,G0,eigen,mc,gamma,g3):
    ix=np.searchsorted(cdf,rng.random(count));pats=patterns[ix]
    eps=2*((pats[:,None]>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
    z=eps[:,:,None]*f.BASE[None,:,:]
    L=math.sqrt(f.M)/(2*math.sqrt(f.R))*f.BASE.T[None,:,:]*(eps*f.SIGMA)[:,None,:]
    gram=G0[None,:,:]+q[SINGLE[0]]*L.transpose(0,2,1)@L
    chol=np.linalg.cholesky(gram)
    D=np.linalg.solve(chol.transpose(0,2,1),rng.normal(size=(count,f.K,1)))[:,:,0]/math.sqrt(gamma)
    AD=np.zeros((count,f.M));AD[:,EVEN]=D@EH.T;AD[:,SINGLE]=np.einsum('brk,bk->br',L,D)
    RH=q*AD+rng.normal(size=(count,f.M))*np.sqrt(eigen[DEGREES]*q)
    R=RH@W.T
    v,t,used=fast_marks(rng,count*f.K);v=v.reshape(count,f.K);t=t.reshape(count,f.K,f.R+1)
    dots=np.einsum('bkr,xr->bkx',z,f.X)
    perturb=t[:,:,0,None]+np.einsum('bkr,xr->bkx',t[:,:,1:]*z,f.X)
    psi=np.where(dots>0,perturb,np.where(dots==0,np.maximum(perturb,0),0))*f.SIGMA[None,:,None]
    error=psi.sum(axis=1)
    h=np.sum(abs(t.reshape(-1,f.R+1)@f.ZERO_BAR.T),axis=1).reshape(count,f.K)/128
    alpha=(.5-mc)/(f.K*f.RHO)
    terms=np.column_stack([-f.NU/alpha*D.sum(axis=1),
                           -(v*h).sum(axis=1)/(2*f.RHO*math.sqrt(alpha)),
                           -gamma*np.sum(R*error,axis=1),
                           -g3/(6*f.M)*np.sum((R*f.CHI)**3,axis=1)])
    return terms,used

def constants(L):
    L=np.sort(L);n=len(L);s=np.r_[0.,np.cumsum(L)[:-1]];ss=np.r_[0.,np.cumsum(L*L)[:-1]]
    g=(L*L*np.arange(n)-2*L*s+ss)/n-np.mean(L*L)
    return np.array([np.mean(abs(L))/2,np.mean(abs(g))/2,np.var(L)])

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--loss',choices=['square','logistic'],required=True)
    ap.add_argument('--samples',type=int,default=100000);ap.add_argument('--seed',type=int,required=True)
    ap.add_argument('--moments',type=Path,default=f.ROOT/'results/critical_moments_reference.json');ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();moment=json.loads(args.moments.read_text());eigen=np.array(moment['walsh_covariance_eigenvalues']);mc=moment['critical_mean']
    if args.loss=='square':lam=1/(f.RHO*.5);gamma=lam/f.M;g3=0.
    else:
        lam=(1+math.exp(.5))/f.RHO;gamma=lam*math.exp(.5)/(1+math.exp(.5))**2/f.M
        g3=lam*math.exp(.5)*(1-math.exp(.5))/(1+math.exp(.5))**3
    rng=np.random.default_rng(args.seed);patterns=f.geometry_table()['patterns'];start=time.monotonic()
    cdf,q,G0=orientation_cdf(patterns,gamma,eigen);pieces=[];used=0
    for first in range(0,args.samples,256):
        terms,work=draw(rng,min(256,args.samples-first),patterns,cdf,q,G0,eigen,mc,gamma,g3)
        pieces.append(terms);used+=work
    terms=np.concatenate(pieces);rawL=terms.sum(axis=1);L=rawL-rawL.mean()
    estimate=constants(L)
    blockvalues=np.array([constants(a-a.mean()) for a in np.array_split(rawL,40)])
    stderr=blockvalues.std(axis=0,ddof=1)/math.sqrt(len(blockvalues))
    out=dict(loss=args.loss,samples=args.samples,seed=args.seed,seconds=time.monotonic()-start,
             critical_moment_input=str(args.moments),critical_mean=mc,covariance_eigenvalues=eigen.tolist(),
             C0=float(estimate[0]),C1=float(estimate[1]),variance=float(estimate[2]),
             block_standard_errors=stderr.tolist(),uncentered_mean=float(rawL.mean()),
             uncentered_mean_standard_error=float(rawL.std(ddof=1)/math.sqrt(len(rawL))),
             term_means=terms.mean(axis=0).tolist(),term_covariance=np.cov(terms.T).tolist(),
             mark_proposals=used,
             scope='Monte Carlo of the limiting formula in the Metropolis companion with numerically estimated critical moments; not a certified finite-width TV estimate.')
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(out,indent=2)+'\n')
    np.savez_compressed(args.output.with_suffix('.npz'),terms=terms)
    print(json.dumps(out,indent=2))
if __name__=='__main__':main()
