"""Exploratory SMC for the exact finite-width cosine Bayesian prior.

Adaptive splitting prevents particle extinction at rare new-label events.
Hard-likelihood elliptical slice transitions preserve each intermediate
posterior. This is an approximate inference experiment, not a certificate:
independent seeds, particle counts, and mutation budgets must be compared.
No frozen-feature or Gaussian-process approximation is imposed.
"""
import argparse,itertools,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import ndtr
ROOT=Path(__file__).resolve().parents[1]
def outputs(state,X,sigma):
 phase=2*np.pi*ndtr(state[:,:,-1])
 z=sigma*np.einsum('pnd,xd->pxn',state[:,:,1:-1],X,optimize=True)+phase[:,None,:]
 return np.einsum('pn,pxn->px',state[:,:,0],np.cos(z),optimize=True)/math.sqrt(state.shape[1])
def systematic(weights,rng):
 c=np.cumsum(weights/weights.sum());c[-1]=1
 return np.searchsorted(c,(rng.random()+np.arange(len(c)))/len(c))
def mutate(state,F,X,y,threshold,sigma,sweeps,rng):
 P=len(state);evaluations=0;maxshrink=0;fallback=0
 for sweep in range(sweeps):
  noise=rng.normal(size=state.shape);angle=rng.uniform(0,2*np.pi,size=P)
  lo=angle-2*np.pi;hi=angle.copy();todo=np.arange(P)
  for attempt in range(300):
   if not len(todo):break
   theta=angle[todo];prop=state[todo]*np.cos(theta)[:,None,None]+noise[todo]*np.sin(theta)[:,None,None]
   fp=outputs(prop,X,sigma);valid=np.all(fp*y[None,:]>threshold[None,:],axis=1)
   evaluations+=len(todo);accepted=todo[valid]
   state[accepted]=prop[valid];F[accepted]=fp[valid]
   rejected=todo[~valid];ang=angle[rejected]
   lo[rejected]=np.where(ang<0,ang,lo[rejected]);hi[rejected]=np.where(ang>=0,ang,hi[rejected])
   angle[rejected]=rng.uniform(lo[rejected],hi[rejected]);todo=rejected
   maxshrink=max(maxshrink,attempt)
  fallback+=len(todo)
 return state,F,dict(likelihood_evaluations=evaluations,max_shrink_steps=maxshrink,fallbacks=fallback)
def run(args):
 rng=np.random.default_rng(args.seed);d=args.d;N=args.width;P=args.particles
 X=np.array(list(itertools.product([1.,-1.],repeat=d)));y=np.prod(X,axis=1)
 state=rng.normal(size=(P,N,d+2));F=outputs(state,X,args.sigma)
 # The internal output is sqrt(N)*F_meanfield. A fixed physical training
 # margin therefore scales by sqrt(N); zero-margin signs are unchanged.
 margin=args.margin*math.sqrt(N);logZ=0.;start=time.time();rows=[]
 key=f'd{d}_n{N}_p{P}_s{args.sweeps}_seed{args.seed}_m{args.margin:g}'
 path=ROOT/'results'/'cosine_smc'/f'{key}.jsonl';path.parent.mkdir(exist_ok=True)
 with path.open('w',buffering=1) as out:
  for j in range(len(X)):
   loginc=0.;level=-math.inf;levels=0;total_evals=0;maxshrink=0;fallback=0
   rawsign=float(np.mean(F[:,j]*y[j]>0))
   while level<margin:
    scores=F[:,j]*y[j]
    nextlevel=min(margin,float(np.quantile(scores,.5)))
    assert nextlevel>level,(j,level,nextlevel)
    survivors=scores>nextlevel;fraction=float(survivors.mean())
    assert fraction>0,(j,level,nextlevel)
    loginc+=math.log(fraction);ids=systematic(survivors.astype(float),rng)
    state=state[ids].copy();F=F[ids].copy();level=nextlevel;levels+=1
    thresholds=np.r_[np.full(j,margin),level]
    state,Fpart,diag=mutate(state,F[:,:j+1].copy(),X[:j+1],y[:j+1],thresholds,args.sigma,args.sweeps,rng)
    # Refresh all query outputs after the mutation of the full parameter state.
    F=outputs(state,X,args.sigma)
    total_evals+=diag['likelihood_evaluations'];maxshrink=max(maxshrink,diag['max_shrink_steps']);fallback+=diag['fallbacks']
    if levels>args.max_levels:raise RuntimeError(('too_many_splitting_levels',key,j,levels))
   logZ+=loginc
   row=dict(d=d,width=N,particles=P,sweeps=args.sweeps,seed=args.seed,sigma=args.sigma,margin=args.margin,
     query=j,correct_training_probability=math.exp(loginc),raw_sign_probability=rawsign,
     log_evidence=logZ,splitting_levels=levels,likelihood_evaluations=total_evals,
     max_shrink_steps=maxshrink,fallbacks=fallback,seconds=time.time()-start)
   out.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True);rows.append(row)
 np.savez_compressed(path.with_suffix('.npz'),state=state,F=F,X=X,y=y)
 return rows
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--d',type=int,default=4);ap.add_argument('--width',type=int,default=1)
 ap.add_argument('--particles',type=int,default=2048);ap.add_argument('--sweeps',type=int,default=16)
 ap.add_argument('--seed',type=int,default=0);ap.add_argument('--sigma',type=float,default=math.sqrt(math.log(2)/2))
 ap.add_argument('--margin',type=float,default=0);ap.add_argument('--max-levels',type=int,default=20000)
 run(ap.parse_args())
