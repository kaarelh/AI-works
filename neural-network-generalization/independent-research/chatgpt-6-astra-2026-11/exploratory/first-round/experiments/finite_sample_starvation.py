"""Full-batch GD robustness study; no claims of infinite-time failure from timeouts.
Exact empirical objective and full-cube cone test; separate random test data.
Campaign has an explicit wall-time budget and records every completed/failed case.
"""
import argparse,itertools,json,math,time,traceback
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]

def run(d,n,width,alpha,eps,seed,bias=False,T=250,dt=.025):
 rng=np.random.default_rng(seed)
 X=(2*rng.integers(0,2,size=(n,d),dtype=np.int8)-1).astype(np.float64)
 y=X[:,0]+eps*X[:,1]*X[:,2]
 if bias:X=np.c_[X,np.ones(n)]
 D=X.shape[1]
 v=rng.normal(size=(width//2,D))
 if bias:v[:,-1]=0
 v/=np.linalg.norm(v,axis=1,keepdims=True)
 W=np.r_[v,v]*alpha/math.sqrt(width)
 a=np.r_[np.ones(width//2),-np.ones(width//2)]*alpha/math.sqrt(width)
 tick=time.time();check=[];stop='time_budget';nsteps=round(T/dt)
 gram=[];rhs=[]
 for s in [1,-1]:
  idx=X[:,0]==s;gram.append(X[idx].T@X[idx]/n);rhs.append(X[idx].T@y[idx]/n)
 for step in range(nsteps+1):
  cone=np.abs(W[:,0])>np.sum(np.abs(W[:,1:]),axis=1)
  if np.all(cone):
   plus=W[:,0]>0
   V=[a[plus]@W[plus],a[~plus]@W[~plus]]
   gradV=[rhs[j]-gram[j]@V[j] for j in range(2)]
   dA=np.zeros(width);dW=np.zeros_like(W)
   for j,mask in enumerate([plus,~plus]):
    dA[mask]=W[mask]@gradV[j];dW[mask]=a[mask,None]*gradV[j]
   f=np.where(X[:,0]>0,X@V[0],X@V[1]) if step%100==0 else None
  else:
   Z=X@W.T;H=np.maximum(Z,0);f=H@a;r=y-f
   dA=H.T@r/n;dW=((r[:,None]*(Z>0)).T@X/n)*a[:,None]
  if step%100==0 or step==nsteps:
   if f is None:f=np.maximum(X@W.T,0)@a
   loss=float(np.mean((y-f)**2)/2);gn=float(np.sqrt(np.sum(dA*dA)+np.sum(dW*dW)))
   check.append(dict(t=step*dt,loss=loss,gradient_norm=gn,cone_fraction=float(cone.mean())))
   if loss<1e-8:stop='interpolated';break
   if np.all(cone) and gn<1e-9:stop='stationary_in_full_cube_linear_cones';break
  if step==nsteps:break
  a+=dt*dA;W+=dt*dW
 test_rng=np.random.default_rng(seed+923000)
 Xt=(2*test_rng.integers(0,2,size=(32768,d),dtype=np.int8)-1).astype(float)
 yt=Xt[:,0]+eps*Xt[:,1]*Xt[:,2];pair=Xt[:,1]*Xt[:,2]
 if bias:Xt=np.c_[Xt,np.ones(len(Xt))]
 ft=np.maximum(Xt@W.T,0)@a
 return dict(d=d,n=n,width=width,alpha=alpha,epsilon=eps,seed=seed,bias=bias,dt=dt,
   max_training_time=T,training_time=step*dt,stop=stop,train_loss=loss,gradient_norm=gn,
   full_cube_cone_fraction=float(cone.mean()),test_loss=float(np.mean((yt-ft)**2)/2),
   test_pair_coefficient=float(np.mean(ft*pair)),test_linear_coefficient=float(np.mean(ft*Xt[:,0])),
   elapsed_s=time.time()-tick,checkpoints=check)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=6)
 ap.add_argument('--pilot',action='store_true');ap.add_argument('--name',default='finite_sample_campaign')
 args=ap.parse_args();out=ROOT/'results'/f'{args.name}.jsonl'
 # Preregistered order: cover dimensions/ratios/initializations before adding seeds.
 jobs=[]
 for seed in range(8):
  for eps in [.5,.75]:
   for bias in [False,True]:
    for d in [16,64,128]:
     for factor in [.25,1,4]:
      for alpha in [.0001,.03,.3]:
       jobs.append((d,round(factor*d*d),64,alpha,eps,seed,bias))
 if args.pilot:jobs=[(64,4096,64,.0001,.5,0,False)]
 done=set()
 if out.exists():
  for line in out.open():
   z=json.loads(line)
   if 'error' not in z:done.add((z['d'],z['n'],z['width'],z['alpha'],z['epsilon'],z['seed'],z['bias']))
 start=time.time()
 with out.open('a',buffering=1) as f:
  for cfg in jobs:
   if cfg in done:continue
   if time.time()-start>args.hours*3600:break
   try:z=run(*cfg,T=250)
   except Exception as e:z=dict(config=cfg,error=str(e),traceback=traceback.format_exc())
   f.write(json.dumps(z)+'\n');print(json.dumps({k:v for k,v in z.items() if k!='checkpoints'}),flush=True)
 print(json.dumps(dict(campaign_elapsed_s=time.time()-start,finished=True)),flush=True)
if __name__=='__main__':main()
