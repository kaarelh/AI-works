"""Exploratory five-bit variation-norm column generation.

The activation-pattern list is exhaustive and separately certified. This
script uses floating LP/NNLS arithmetic; its numerical cost gaps are not
exact certificates. Each NNLS nonnegative multiplier gives a global
polar upper bound, whether or not the projection is perfectly optimized.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS'):os.environ[key]='1'
import argparse,itertools,json,time
from pathlib import Path
import numpy as np
from scipy.optimize import linprog,nnls
ROOT=Path(__file__).resolve().parents[1]
data=np.load(ROOT/'results/fivebit_cones/activation_patterns.npz')
X=data['X'].astype(float);D=data['D'];M=len(X);r=5

def initial_dictionary():
    incoming=[]
    for w in itertools.product((-1,0,1),repeat=r):
        for b in range(-5,6):
            v=np.array((b,*w),float);length=np.linalg.norm(v)
            if length:incoming.append(v/length)
    V=np.array(incoming)
    H=np.maximum(X@V.T,0)
    return V,H

def separate(alpha,ids,labels,return_active=False):
    xs=X[ids];ds=np.unique(D[:,ids],axis=0);signed=alpha*labels
    gradient=(ds*signed[None,:])@xs
    norms=[];vectors=[];active=[];failed=0
    started=time.monotonic()
    for j,d in enumerate(ds):
        cone=(2*d.astype(float)-1)[:,None]*xs
        for sign in (-1,1):
            g=sign*gradient[j]
            try:q,_=nnls(cone.T,-g,maxiter=300)
            except RuntimeError:q=np.zeros(len(ids));failed+=1
            assert np.min(q)>=0
            residual=g+cone.T@q
            norms.append(np.linalg.norm(residual));vectors.append(residual)
            if return_active:active.append(np.flatnonzero(q>1e-9).tolist())
    norms=np.array(norms);vectors=np.array(vectors)
    top=np.argsort(norms)[-32:][::-1]
    result=dict(bound=float(norms[top[0]]),vectors=vectors[top],
        patterns=len(ds),seconds=time.monotonic()-started,failed_projections=failed)
    if return_active:result.update(all_norms=norms,active=active,patterns_array=ds)
    return result

def solve(ids,labels,margins,V,H,tol=2e-6,maxiter=35,log=None):
    for iteration in range(maxiter):
        hh=np.column_stack([H[ids],-H[ids]])
        p=linprog(np.ones(hh.shape[1]),A_ub=-labels[:,None]*hh,b_ub=-margins,bounds=(0,None),method='highs')
        assert p.success,p.message
        alpha=-p.ineqlin.marginals
        oracle=separate(alpha,ids,labels)
        scale=max(oracle['bound'],1.)
        lower=float(alpha@margins/scale);upper=float(p.fun)
        row=dict(iteration=iteration,upper=upper,lower=lower,gap=upper-lower,
            dictionary=len(V),separation_bound=oracle['bound'],
            cone_patterns=oracle['patterns'],oracle_seconds=oracle['seconds'],
            failed_projections=oracle['failed_projections'])
        if log:log.write(json.dumps(row)+'\n');log.flush()
        print(json.dumps(row),flush=True)
        if upper-lower <= tol*max(1,upper):
            coefficients=p.x[:len(V)]-p.x[len(V):]
            return dict(upper=upper,lower=lower,alpha=alpha,
                coefficients=coefficients,predictions=H@coefficients,V=V,H=H,
                separation_bound=oracle['bound'],iterations=iteration+1)
        new=oracle['vectors'];lengths=np.linalg.norm(new,axis=1);new=new[lengths>0]/lengths[lengths>0,None]
        # Include the actual ReLU atoms, even if a numerical NNLS residual
        # is slightly outside the cone that produced its bound.
        V=np.r_[V,new];H=np.column_stack([H,np.maximum(X@new.T,0)])
    raise RuntimeError('Column-generation convergence tolerance not reached')

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--prefix',type=int,default=16)
    ap.add_argument('--order',choices=['lex','recursive','weight'],default='recursive')
    ap.add_argument('--target',choices=['gate','parity'],default='gate')
    ap.add_argument('--mode',choices=['history','correct','wrong'],default='history')
    ap.add_argument('--maxiter',type=int,default=35);ap.add_argument('--tolerance',type=float,default=2e-6)
    args=ap.parse_args()
    if args.target=='gate':y=np.prod(X[:,1:4],axis=1)*np.where(np.all(X[:,4:]==1,axis=1),1,-1)
    else:y=np.prod(X[:,1:],axis=1)
    if args.order=='lex':order=list(range(M))
    elif args.order=='weight':order=sorted(range(M),key=lambda i:(i.bit_count(),i))
    else:
        old=[15,14,13,11,10,9,7,6,3,5,2,8,1,12,4,0]
        # old bits are most-significant first. Embed the old four
        # coordinates into coordinates2..5, and fix coordinate1 first+1.
        rev=lambda q:sum(((q>>(3-j))&1)<<j for j in range(4))
        order=[1+2*rev(q) for q in old]+[2*rev(q) for q in old]
    ids=order[:args.prefix];margins=np.full(len(ids),.5)
    labels=y[ids].copy()
    if args.mode!='history':
        ids=order[:args.prefix+1];margins=np.r_[margins,0.];labels=y[ids].copy()
        if args.mode=='wrong':labels[-1]*=-1
    name=f'{args.target}_{args.order}_prefix{args.prefix}_{args.mode}'
    out=ROOT/'results/fivebit_variation';out.mkdir(exist_ok=True)
    V,H=initial_dictionary();started=time.monotonic()
    with (out/(name+'.log')).open('w') as log:
        result=solve(ids,labels,margins,V,H,args.tolerance,args.maxiter,log)
    np.savez_compressed(out/(name+'.npz'),**{k:v for k,v in result.items() if isinstance(v,np.ndarray)},
       ids=ids,labels=labels,margins=margins,order=order,target=y)
    record={k:v for k,v in result.items() if not isinstance(v,np.ndarray)}
    record.update(name=name,seconds=time.monotonic()-started,query=order[args.prefix] if args.prefix<M else None,
        next_signed_prediction=float(y[order[args.prefix]]*result['predictions'][order[args.prefix]]) if args.prefix<M else None,
        qualification='Floating column-generation and exhaustive cone-polar bounds; not an exact certificate.')
    (out/(name+'.json')).write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record),flush=True)

if __name__=='__main__':main()
