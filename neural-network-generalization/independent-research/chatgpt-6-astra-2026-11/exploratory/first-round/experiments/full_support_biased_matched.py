"""Full-support Boolean shortcut experiment WITH trainable biases.
Exploratory extension: the existing biasless theorem does not apply.
"""
import argparse,json,time
from pathlib import Path
import numpy as np
from scipy.special import expit
ROOT=Path(__file__).resolve().parents[1]
THRESHOLD=1.0
def data(q,rho,eps):
 X=np.array([[1 if (i>>j)&1 else -1 for j in range(q+2)] for i in range(2**(q+2))],float)
 y=X[:,-2]*X[:,-1];S=X[:,:q].sum(axis=1)
 ps=np.full(len(X),eps/len(X));dup=np.all(X[:,:q]==X[:,0,None],axis=1)
 ps[dup]+=(1-eps)/8
 mean=rho*np.sign(S)*np.maximum(np.abs(S)-THRESHOLD,0)/(q-THRESHOLD)
 p=ps*(1+mean*y)
 assert abs(p.sum()-1)<1e-12
 return X,y,p
def run(q,rho,eps,N,seeds,alphas,loss,dt,T,initialization="balanced"):
 X,y,p=data(q,rho,eps);X=np.c_[np.ones(len(X)),X];D=q+3;cfg=[(seed,alpha) for seed in seeds for alpha in alphas];B=len(cfg)
 W=[];a=[]
 for seed,alpha in cfg:
  rng=np.random.default_rng(seed)
  if initialization=="balanced":
   v=rng.normal(size=(N//2,D));v/=np.linalg.norm(v,axis=1)[:,None]
   W.append(np.repeat(v,2,axis=0)*alpha/np.sqrt(N));a.append(np.tile([1.,-1.],N//2)*alpha/np.sqrt(N))
  elif initialization=="gaussian":
   W.append(rng.normal(size=(N,D))*alpha/np.sqrt(N*D));a.append(rng.normal(size=N)*alpha/np.sqrt(N))
  else:
   v=rng.normal(size=(N,D));v/=np.linalg.norm(v,axis=1)[:,None];v*=.5*rng.random((N,1))**(1/D)
   W.append(v*alpha/np.sqrt(N));a.append(rng.choice([-1.,1.],size=N)*alpha/np.sqrt(N))
 W=np.array(W);a=np.array(a);u=np.r_[0.,np.ones(q)/np.sqrt(q),0.,0.];started=time.time();steps=round(T/dt)
 def field(a,W):
  pre=np.einsum('bnd,xd->bnx',W,X,optimize=True);act=np.maximum(pre,0);F=np.einsum('bn,bnx->bx',a,act,optimize=True)
  residual=y-F if loss=='square' else y*expit(-y*F)
  gate=(pre>0)+.5*(pre==0)
  g=np.einsum('bx,bnx,xd->bnd',residual*p,gate,X,optimize=True)
  return g,F
 def boost(a,W,g,h):
  norm=np.linalg.norm(g,axis=2);z=norm*h;ch=np.cosh(z);sh=np.sinh(z)
  unit=np.divide(g,norm[:,:,None],out=np.zeros_like(g),where=norm[:,:,None]>0)
  wg=np.sum(W*unit,axis=2);an=a*ch+wg*sh;Wn=W+unit*((ch-1)*wg+sh*a)[:,:,None]
  return an,Wn
 checks=set([0,steps]+[int(t/dt) for t in np.geomspace(.1,T,85)]);key=f'q{q}_threshold{THRESHOLD:g}_r{rho:g}_e{eps:g}_n{N}_{loss}_s{seeds[0]}-{seeds[-1]}_dt{dt:g}'+('' if initialization=='balanced' else '_'+initialization)
 out=ROOT/'results'/f'biased_matched_{key}.jsonl'
 with out.open('w',buffering=1) as f:
  for k in range(steps+1):
   g,F=field(a,W)
   if k in checks:
    err=(y*F<0)+.5*(F==0);risk=np.sum(p*(.5*(y-F)**2 if loss=='square' else np.logaddexp(0,-y*F)),axis=1)
    majority=(W@u)*np.sign(a);trans=np.sqrt(np.maximum(0,np.sum(W*W,axis=2)-(W@u)**2))
    for i,(seed,alpha) in enumerate(cfg):
     row=dict(q=q,rho=rho,eps=eps,N=N,loss=loss,initialization=initialization,trainable_bias=True,seed=seed,alpha=alpha,t=k*dt,dt=dt,risk=float(risk[i]),train_error=float(err[i]@p),ood_error=float(err[i].mean()),parity_correlation=float(F[i]@y/len(y)),shortcut_correlation=float(F[i]@(X@u)/len(y)),min_alignment=float(np.min(majority[i]/np.abs(a[i]))),max_transverse=float(np.max(trans[i]/np.abs(a[i]))),seconds=time.time()-started)
     f.write(json.dumps(row)+'\n')
    print(json.dumps(dict(status='progress',key=key,t=k*dt,mean_risk=float(risk.mean()),mean_ood=float(err.mean()),seconds=time.time()-started)),flush=True)
   if k==steps:break
   ah,Wh=boost(a,W,g,dt/2);gm,_=field(ah,Wh);a,W=boost(a,W,gm,dt)
   if initialization=="balanced":a=np.sign(a)*np.linalg.norm(W,axis=2)
 np.savez_compressed(ROOT/'results'/f'biased_matched_{key}.npz',a=a,W=W,cfg=np.array(cfg),X=X,y=y,p=p)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--q',type=int,default=5);ap.add_argument('--rho',type=float,default=.9);ap.add_argument('--eps',type=float,default=.001);ap.add_argument('--width',type=int,default=16)
 ap.add_argument('--threshold',type=float,default=1.)
 ap.add_argument('--initialization',choices=['balanced','gaussian','readout-dominant'],default='balanced')
 ap.add_argument('--seed-start',type=int,default=0);ap.add_argument('--seeds',type=int,default=8);ap.add_argument('--alphas',type=float,nargs='+',default=[1e-4,.01,.1,.5]);ap.add_argument('--loss',choices=['square','logistic'],default='square');ap.add_argument('--dt',type=float,default=.02);ap.add_argument('--time',type=float,default=1000)
 x=ap.parse_args();THRESHOLD=x.threshold;run(x.q,x.rho,x.eps,x.width,list(range(x.seed_start,x.seed_start+x.seeds)),x.alphas,x.loss,x.dt,x.time,x.initialization)
