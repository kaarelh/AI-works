"""Population GD on x1 + epsilon*x2*x3 on the entire three-bit cube.
Balanced paired initialization, no bias; six ReLU neurons represent the target.
Uses manual derivatives, exact eight-point expectations, and tracks gate cones.
This is a finite-step GD experiment, not by itself a gradient-flow theorem.
"""
import argparse,itertools,json,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--width',type=int,default=64)
 ap.add_argument('--dt',type=float,default=.01);ap.add_argument('--time',type=float,default=800)
 ap.add_argument('--seeds',type=int,default=12);ap.add_argument('--name',default='starvation')
 ap.add_argument('--alphas',default='.1,.03,.01,.003,.001,.0001,.000001,.00000001')
 ap.add_argument('--epsilons',default='.125,.25,.5,.75,1')
 a=ap.parse_args();assert a.width%2==0
 cfg=list(itertools.product(map(float,a.epsilons.split(',')),map(float,a.alphas.split(',')),range(a.seeds)))
 B=len(cfg); N=a.width;X=np.array(list(itertools.product([-1.,1.],repeat=3)))
 Y=np.array([X[:,0]+eps*X[:,1]*X[:,2] for eps,alpha,seed in cfg])
 W=np.zeros((B,N,3));A=np.zeros((B,N))
 for i,(eps,alpha,seed) in enumerate(cfg):
  rng=np.random.default_rng(seed)
  v=rng.normal(size=(N//2,3));v/=np.linalg.norm(v,axis=1,keepdims=True)
  W[i]=np.concatenate((v,v),axis=0)*alpha/np.sqrt(N)
  A[i]=np.r_[np.ones(N//2),-np.ones(N//2)]*alpha/np.sqrt(N)
 start=time.time();out=ROOT/'results'/f'{a.name}_n{N}_dt{a.dt:g}.jsonl'
 checkpoints=sorted(set([0]+[int(t/a.dt) for t in np.geomspace(.1,a.time,90)]+[round(a.time/a.dt)]))
 ck=set(checkpoints);max_balance=np.zeros(B)
 with out.open('w',buffering=1) as f:
  for step in range(round(a.time/a.dt)+1):
   Z=np.einsum('bnd,xd->bxn',W,X,optimize=True);H=np.maximum(Z,0)
   F=np.einsum('bn,bxn->bx',A,H,optimize=True);R=Y-F
   if step in ck:
    bal=np.max(np.abs(A*A-np.sum(W*W,axis=2)),axis=1);max_balance=np.maximum(max_balance,bal)
    mass=A*A+np.sum(W*W,axis=2)
    cone=(np.sign(A)*W[:,:,0]>np.sum(np.abs(W[:,:,1:]),axis=2))
    for i,(eps,alpha,seed) in enumerate(cfg):
     z=dict(epsilon=eps,alpha=alpha,seed=seed,width=N,dt=a.dt,t=step*a.dt,
            loss=float(np.mean(R[i]**2)/2),linear_floor=eps**2/2,
            learned_linear=float(np.mean(F[i]*X[:,0])),
            learned_pair=float(np.mean(F[i]*X[:,1]*X[:,2])),
            cone_count=int(cone[i].sum()),cone_mass_fraction=float(np.sum(mass[i]*cone[i])/np.sum(mass[i])),
            balance_error=float(bal[i]),mass=float(mass[i].sum()))
     f.write(json.dumps(z)+'\n')
    print(json.dumps(dict(t=step*a.dt,elapsed_s=round(time.time()-start,1),width=N,
                         runs=B,mean_loss=float(np.mean(R**2)/2))),flush=True)
   if step==round(a.time/a.dt):break
   dA=np.einsum('bx,bxn->bn',R,H,optimize=True)/8
   dW=np.einsum('bx,bxn,xd->bnd',R,Z>0,X,optimize=True)/8*A[:,:,None]
   A+=a.dt*dA;W+=a.dt*dW
 np.savez_compressed(ROOT/'results'/f'{a.name}_n{N}_dt{a.dt:g}_final.npz',W=W,A=A,X=X,Y=Y,cfg=np.array(cfg))
if __name__=='__main__':main()
