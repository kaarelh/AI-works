"""Can fresh neurons escape an exact full-support Boolean shortcut minimum?

Starts at the analytically known shortcut optimum. Random paired additions
have exactly zero initial output. This is an intervention experiment, not
a test of ordinary random initialization. Midpoint Lorentz integration.
"""
import argparse,json,time
from pathlib import Path
import numpy as np
from full_support_shortcut import data
ROOT=Path(__file__).resolve().parents[1]

def run(mode,seeds,alphas,dt,T,freeze_old=False):
 X,y,p=data(5,.9,.001);D=7;Nold=16;u=np.r_[np.ones(5)/np.sqrt(5),0.,0.]
 bstar=.999*np.sqrt(5)*.9/(5*.999+.001)
 added={'none':0,'random2':2,'random4':4,'random8':8,'planted1':1,'planted4':4}[mode]
 N=Nold+added;cfg=[(s,a) for s in seeds for a in alphas];B=len(cfg)
 W=np.zeros((B,N,D));a=np.zeros((B,N));oldsign=np.tile([1.,-1.],Nold//2)
 W[:,:Nold]=oldsign[None,:,None]*u[None,None,:]*np.sqrt(bstar/(Nold/2))
 a[:,:Nold]=oldsign[None,:]*np.sqrt(bstar/(Nold/2))
 for i,(seed,alpha) in enumerate(cfg):
  rng=np.random.default_rng(seed)
  if mode.startswith('random'):
   v=rng.normal(size=(added//2,D));v/=np.linalg.norm(v,axis=1)[:,None]
   W[i,Nold:]=np.repeat(v,2,axis=0)*alpha/np.sqrt(added)
   a[i,Nold:]=np.tile([1.,-1.],added//2)*alpha/np.sqrt(added)
  elif added:
   signs=np.array([[1,1],[-1,-1],[1,-1],[-1,1]])[:added]
   W[i,Nold:,-2:]=signs*alpha/np.sqrt(2*added)
   a[i,Nold:]=signs.prod(axis=1)*alpha/np.sqrt(added)
 def field(aa,ww):
  pre=np.einsum('bnd,xd->bnx',ww,X,optimize=True);act=np.maximum(pre,0)
  F=np.einsum('bn,bnx->bx',aa,act,optimize=True)
  gate=(pre>0)+.5*(pre==0)
  g=np.einsum('bx,bnx,xd->bnd',(y-F)*p,gate,X,optimize=True)
  if freeze_old:g[:,:Nold]=0
  return g,F
 def boost(aa,ww,g,h):
  norm=np.linalg.norm(g,axis=2);unit=np.divide(g,norm[:,:,None],out=np.zeros_like(g),where=norm[:,:,None]>0)
  z=norm*h;ch=np.cosh(z);sh=np.sinh(z);wg=np.sum(ww*unit,axis=2)
  return aa*ch+wg*sh,ww+unit*((ch-1)*wg+sh*aa)[:,:,None]
 dest=ROOT/'results'/'full_support_renewal';dest.mkdir(exist_ok=True)
 key=f'{mode}_s{seeds[0]}-{seeds[-1]}_dt{dt:g}_freeze{int(freeze_old)}'
 checks=set([0,round(T/dt)]+[round(t/dt) for t in np.geomspace(.1,T,110)])
 start=time.time()
 with (dest/(key+'.jsonl')).open('w',buffering=1) as f:
  for k in range(round(T/dt)+1):
   g,F=field(a,W)
   if k in checks:
    err=(y*F<0)+.5*(F==0);risk=.5*np.sum(p*(y-F)**2,axis=1)
    for i,(seed,alpha) in enumerate(cfg):
     row=dict(mode=mode,freeze_old=freeze_old,seed=seed,alpha=alpha,N=N,t=k*dt,dt=dt,
       risk=float(risk[i]),train_error=float(err[i]@p),ood_error=float(err[i].mean()),
       parity=float(F[i]@y/len(y)),shortcut=float(F[i]@(X@u)/len(y)),seconds=time.time()-start)
     f.write(json.dumps(row)+'\n')
    print(json.dumps(dict(mode=mode,t=k*dt,mean_risk=float(risk.mean()),mean_ood=float(err.mean()),seconds=time.time()-start)),flush=True)
   if k==round(T/dt):break
   ah,Wh=boost(a,W,g,dt/2);gm,_=field(ah,Wh);a,W=boost(a,W,gm,dt)
   a=np.sign(a)*np.linalg.norm(W,axis=2)
 np.savez_compressed(dest/(key+'.npz'),a=a,W=W,cfg=np.array(cfg),X=X,y=y,p=p)

if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--mode',choices=['none','random2','random4','random8','planted1','planted4'],default='random4')
 ap.add_argument('--seeds',type=int,default=32);ap.add_argument('--seed-start',type=int,default=0)
 ap.add_argument('--alphas',type=float,nargs='+',default=[1e-4,.01,.1]);ap.add_argument('--dt',type=float,default=.02)
 ap.add_argument('--time',type=float,default=2000);ap.add_argument('--freeze-old',action='store_true')
 q=ap.parse_args();run(q.mode,range(q.seed_start,q.seed_start+q.seeds),q.alphas,q.dt,q.time,q.freeze_old)
