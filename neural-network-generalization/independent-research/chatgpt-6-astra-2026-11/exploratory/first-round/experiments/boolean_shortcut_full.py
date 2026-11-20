"""Unconstrained full-network population GD for a Boolean shortcut problem.
Eight input points with weights (1+rho*x1*x2*x3)/8; label x2*x3.
Input first coordinate scaled by L (L=2 equals four identical Boolean copies
in the symmetric effective coordinates). Bias is an explicit separate option.
"""
import argparse,itertools,json,time,math
from pathlib import Path
import numpy as np
from scipy.special import expit
ROOT=Path(__file__).resolve().parents[1]
def boost(A,W,G,dt):
 """Exact frozen-gradient Lorentz flow; preserve balanced initialization."""
 norm=np.linalg.norm(G,axis=2);unit=G/np.maximum(norm[:,:,None],1e-300)
 dot=np.sum(W*unit,axis=2);angle=dt*norm
 sh=np.sinh(angle);cm=2*np.sinh(angle/2)**2
 newW=W+unit*(dot*cm+A*sh)[:,:,None]
 newA=A*(1+cm)+dot*sh
 # Remove roundoff in the homogeneous balance invariant. This correction
 # is at floating-point scale, not a model regularizer.
 newA=np.sign(newA)*np.linalg.norm(newW,axis=2)
 return newA,newW
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--bias',action='store_true');ap.add_argument('--width',type=int,default=64)
 ap.add_argument('--dt',type=float,default=.02);ap.add_argument('--time',type=float,default=750)
 ap.add_argument('--seeds',type=int,default=16);ap.add_argument('--name',default='boolean_shortcut_full')
 ap.add_argument('--loss',choices=['square','logistic'],default='square')
 ap.add_argument('--Ls',default='1,2,3');ap.add_argument('--rhos',default='.5,.7,.75,.8,.9,.99')
 ap.add_argument('--alphas',default='.0001,.01,.1')
 ap.add_argument('--seedstart',type=int,default=0)
 ap.add_argument('--method',choices=['euler','boost1','boost2'],default='euler')
 ap.add_argument('--snapshots',default='')
 args=ap.parse_args();N=args.width;assert N%2==0
 cfg=list(itertools.product(list(map(float,args.Ls.split(','))),list(map(float,args.rhos.split(','))),
       list(map(float,args.alphas.split(','))),range(args.seedstart,args.seedstart+args.seeds)))
 B=len(cfg);D=4 if args.bias else 3
 cube=np.array(list(itertools.product([-1.,1.],repeat=3)));y=cube[:,1]*cube[:,2]
 X=np.repeat(cube[None,:,:],B,axis=0);P=np.zeros((B,8))
 for i,(L,rho,alpha,seed) in enumerate(cfg):X[i,:,0]*=L;P[i]=(1+rho*cube[:,0]*y)/8
 if args.bias:X=np.concatenate((X,np.ones((B,8,1))),axis=2)
 W=np.zeros((B,N,D));A=np.zeros((B,N))
 for i,(L,rho,alpha,seed) in enumerate(cfg):
  rng=np.random.default_rng(seed);v=rng.normal(size=(N//2,D))
  if args.bias:v[:,-1]=0
  v/=np.linalg.norm(v,axis=1,keepdims=True)
  W[i]=np.r_[v,v]*alpha/math.sqrt(N);A[i]=np.r_[np.ones(N//2),-np.ones(N//2)]*alpha/math.sqrt(N)
 suffix='' if args.loss=='square' else '_logistic'
 if args.method!='euler':suffix+='_'+args.method
 out=ROOT/'results'/f'{args.name}{suffix}_bias{int(args.bias)}_n{N}_dt{args.dt:g}.jsonl'
 start=time.time();nsteps=round(args.time/args.dt)
 checkpoints=set([0,nsteps]+[int(t/args.dt) for t in np.geomspace(.1,args.time,70)])
 snapshots={round(float(t)/args.dt) for t in args.snapshots.split(',') if t}
 with out.open('w',buffering=1) as f:
  for step in range(nsteps+1):
   Z=np.einsum('bnd,bxd->bxn',W,X,optimize=True);H=np.maximum(Z,0)
   F=np.einsum('bn,bxn->bx',A,H,optimize=True)
   R=y[None,:]-F if args.loss=='square' else y[None,:]*expit(-y[None,:]*F)
   if step in snapshots:
    np.savez_compressed(ROOT/'results'/f'{args.name}{suffix}_bias{int(args.bias)}_n{N}_t{step*args.dt:g}.npz',
      W=W,A=A,cfg=np.array(cfg),cube=cube,F=F)
   if step in checkpoints:
    loss=np.sum(P*R*R,axis=1)/2 if args.loss=='square' else np.sum(P*np.logaddexp(0,-F*y[None,:]),axis=1)
    err=np.sum(P*(F*y[None,:]<=0),axis=1)
    ode=np.mean(F*y[None,:]<=0,axis=1)
    for i,(L,rho,alpha,seed) in enumerate(cfg):
     row=dict(L=L,rho=rho,alpha=alpha,seed=seed,bias=args.bias,width=N,dt=args.dt,t=step*args.dt,loss_kind=args.loss,method=args.method,
      loss=float(loss[i]),train_error=float(err[i]),ood_uniform_error=float(ode[i]),
      linear_coefficient=float(np.mean(F[i]*cube[:,0])),parity_coefficient=float(np.mean(F[i]*y)),
      balance_defect=float(np.max(np.abs(A[i]**2-np.sum(W[i]**2,axis=1)))) )
     f.write(json.dumps(row)+'\n')
    print(json.dumps(dict(t=step*args.dt,elapsed_s=time.time()-start,mean_loss=float(loss.mean()),bias=args.bias)),flush=True)
   if step==nsteps:break
   G=np.einsum('bx,bxn,bxd->bnd',P*R,Z>0,X,optimize=True)
   if args.method=='euler':
    dA=np.einsum('bx,bxn->bn',P*R,H,optimize=True)
    dW=G*A[:,:,None]
    A+=args.dt*dA;W+=args.dt*dW
   else:
    if args.method=='boost2':
     Am,Wm=boost(A,W,G,args.dt/2)
     Zm=np.einsum('bnd,bxd->bxn',Wm,X,optimize=True)
     Fm=np.einsum('bn,bxn->bx',Am,np.maximum(Zm,0),optimize=True)
     Rm=y[None,:]-Fm if args.loss=='square' else y[None,:]*expit(-y[None,:]*Fm)
     G=np.einsum('bx,bxn,bxd->bnd',P*Rm,Zm>0,X,optimize=True)
    A,W=boost(A,W,G,args.dt)
 np.savez_compressed(ROOT/'results'/f'{args.name}{suffix}_bias{int(args.bias)}_n{N}_final.npz',W=W,A=A,cfg=np.array(cfg),cube=cube)
if __name__=='__main__':main()
