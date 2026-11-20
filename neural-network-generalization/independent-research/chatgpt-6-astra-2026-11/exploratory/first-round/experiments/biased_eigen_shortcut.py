"""Population square-loss test for the separate covariance-aligned biased trap.
All hidden biases train; this is not the original biasless distribution.
"""
import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
import argparse,json,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
def data(q=5,L=2.,eps=.001,rho=.9):
 X=np.array([[1 if (i>>j)&1 else -1 for j in range(q+2)] for i in range(2**(q+2))],float);s=X[:,:q].sum(axis=1);y=X[:,-2]*X[:,-1]
 ps=np.full(len(X),eps/len(X));dup=np.all(X[:,:q]==X[:,0,None],axis=1);ps[dup]+=(1-eps)/8
 c=np.sum(ps*np.abs(s));d=np.sum(ps*s*s);aa=L*L*c/q;bb=L*L*d/q-1
 beta=2*c/(bb+np.sqrt(bb*bb+4*aa*c));kappa=rho/(q+beta)
 m=kappa*(s+beta*np.sign(s));p=ps*(1+m*y)
 X[:,:q]*=L;X=np.c_[np.ones(len(X)),X]
 h=np.r_[beta,np.ones(q)/L,0.,0.];up=h/np.linalg.norm(h);um=up.copy();um[1:q+1]*=-1
 H=s>0;cov=np.einsum('x,xi,xj->ij',p*H,X,X);lam=up@cov@up
 assert np.max(np.abs(cov@up-lam*up))<1e-12
 assert p.min()>0 and abs(p.sum()-1)<1e-12
 return X,y,p,m,up,um,dict(q=q,L=L,eps=eps,rho=rho,beta=beta,kappa=kappa,c=c,d=d,eigenvalue=lam,minimum_probability=float(p.min()),predicted_risk=float(np.sum(p*(y-m)**2)/2),predicted_train_error=float(np.sum(p*(y*m<0))))
def run(args):
 X,y,p,target,up,um,meta=data();D=X.shape[1];N=args.width;cfg=[(seed,alpha) for seed in range(args.seed_start,args.seed_start+args.seeds) for alpha in args.alphas];a=[];W=[]
 for seed,alpha in cfg:
  rng=np.random.default_rng(seed);sign=np.tile([1.,-1.],N//2)
  if args.initialization=='cone':
   v=np.where(sign[:,None]>0,up,um)+args.angle*rng.normal(size=(N,D))/np.sqrt(D);v/=np.linalg.norm(v,axis=1)[:,None]
  else:v=rng.normal(size=(N,D));v/=np.linalg.norm(v,axis=1)[:,None]
  W.append(alpha/np.sqrt(N)*v);a.append(alpha/np.sqrt(N)*sign)
 a=np.array(a);W=np.array(W);initial_gates=(np.einsum('bnd,xd->bnx',W,X)>0);steps=round(args.time/args.dt);checks=set([0,steps]+[int(t/args.dt) for t in np.geomspace(.1,args.time,80)]);start=time.time()
 key=f'eigen_bias_{args.initialization}_n{N}_s{args.seed_start}-{args.seed_start+args.seeds-1}_dt{args.dt:g}_angle{args.angle:g}';out=ROOT/'results'/f'{key}.jsonl'
 def field(a,W):
  pre=np.einsum('bnd,xd->bnx',W,X,optimize=True);act=np.maximum(pre,0);F=np.einsum('bn,bnx->bx',a,act,optimize=True);g=np.einsum('bx,bnx,xd->bnd',(y-F)*p,pre>0,X,optimize=True);return g,F,pre
 def boost(a,W,g,h):
  norm=np.linalg.norm(g,axis=2);u=np.divide(g,norm[:,:,None],out=np.zeros_like(g),where=norm[:,:,None]>0);z=norm*h;ch=np.cosh(z);sh=np.sinh(z);dot=np.sum(W*u,axis=2);return a*ch+dot*sh,W+u*((ch-1)*dot+sh*a)[:,:,None]
 with out.open('w',buffering=1) as f:
  for k in range(steps+1):
   g,F,pre=field(a,W)
   if k in checks:
    for i,(seed,alpha) in enumerate(cfg):
     row=dict(meta,initialization=args.initialization,seed=seed,alpha=alpha,width=N,t=k*args.dt,dt=args.dt,angle=args.angle,risk=float(p@((y-F[i])**2)/2),ood_error=float(np.mean((y*F[i]<0)+.5*(F[i]==0))),train_error=float(p@((y*F[i]<0)+.5*(F[i]==0))),max_target_difference=float(np.max(np.abs(F[i]-target))),gate_changes=int(np.sum((pre[i]>0)!=initial_gates[i])),gradient_norm=float(np.sqrt(np.sum((a[i,:,None]*g[i])**2)+np.sum(np.sum(W[i]*g[i],axis=1)**2))),seconds=time.time()-start);f.write(json.dumps(row)+'\n')
    print(json.dumps(dict(key=key,t=k*args.dt,mean_risk=float(np.mean(np.sum(p*(y-F)**2,axis=1)/2)),max_target_difference=float(np.max(np.abs(F-target))),seconds=time.time()-start)),flush=True)
   if k==steps:break
   ah,Wh=boost(a,W,g,args.dt/2);gm,_,_=field(ah,Wh);a,W=boost(a,W,gm,args.dt);a=np.sign(a)*np.linalg.norm(W,axis=2)
 np.savez_compressed(ROOT/'results'/f'{key}.npz',a=a,W=W,X=X,y=y,p=p,target=target,cfg=np.array(cfg),**meta)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--width',type=int,default=16);ap.add_argument('--seed-start',type=int,default=0);ap.add_argument('--seeds',type=int,default=16);ap.add_argument('--alphas',type=float,nargs='+',default=[1e-4,.01,.1]);ap.add_argument('--angle',type=float,default=.03);ap.add_argument('--initialization',choices=['cone','spherical'],default='cone');ap.add_argument('--dt',type=float,default=.02);ap.add_argument('--time',type=float,default=2000.);run(ap.parse_args())
