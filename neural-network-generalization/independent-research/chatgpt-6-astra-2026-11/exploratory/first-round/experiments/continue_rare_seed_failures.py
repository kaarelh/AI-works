"""Longer-time test of the two-sign seed sufficiency conjecture.
Select failures using the already saved time-100 criterion and time-2000 outcomes.
"""
import json,time,math
from pathlib import Path
import numpy as np
from boolean_shortcut_full import boost
ROOT=Path(__file__).resolve().parents[1];analysis=json.loads((ROOT/'results/rare_seed_analysis.json').read_text());selected=[]
for c,limit in [(.1,4),(.2,8),(.3,12),(.4,8)]:
 candidates=[r for r in analysis['rows'] if r['width']==1024 and abs(r['c']-c)<1e-7 and r['prediction'] and not r['zero_error']]
 selected+=sorted(candidates,key=lambda r:r['seed'])[:limit]
W=[];A=[];cfg=[]
for r in selected:
 p=ROOT/'results'/r['source'].replace('_t100.npz','_final.npz');z=np.load(p)
 index=next(i for i,(L,rho,alpha,seed) in enumerate(z['cfg']) if int(seed)==r['seed'] and abs(alpha-r['alpha'])<1e-12)
 W.append(z['W'][index]);A.append(z['A'][index]);cfg.append(z['cfg'][index])
W=np.array(W);A=np.array(A);cfg=np.array(cfg);cube=z['cube'];B=len(A);N=A.shape[1];X=np.repeat(cube[None],B,axis=0);P=np.empty((B,8));y=cube[:,1]*cube[:,2]
for i,(L,rho,alpha,seed) in enumerate(cfg):X[i,:,0]*=L;P[i]=(1+rho*cube[:,0]*y)/8
start=time.time();dt=.02;steps=round(18000/dt);checks={0,steps}|{round(t/dt) for t in np.geomspace(1,18000,100)}
def field(A,W):
 Z=np.einsum('bnd,bxd->bxn',W,X,optimize=True);F=np.einsum('bn,bxn->bx',A,np.maximum(Z,0),optimize=True)
 G=np.einsum('bx,bxn,bxd->bnd',P*(y-F),Z>0,X,optimize=True)
 return G,F
with (ROOT/'results/rare_seed_long_continuation.jsonl').open('w',buffering=1) as f:
 for k in range(steps+1):
  G,F=field(A,W)
  if k in checks or (k%1000==0 and time.time()-start>5400):
   err=np.mean((y*F<0)+.5*(F==0),axis=1);risk=.5*np.sum(P*(y-F)**2,axis=1)
   for i,r in enumerate(selected):
    row={**r,'t':2000+k*dt,'dt':dt,'continued_error':float(err[i]),'continued_loss':float(risk[i]),'wall_seconds':time.time()-start};f.write(json.dumps(row)+'\n')
   print(json.dumps(dict(t=2000+k*dt,mean_error=float(err.mean()),success=int(np.sum(err==0)),n=B,seconds=time.time()-start)),flush=True)
  if k==steps or (k%1000==0 and time.time()-start>5400):break
  Am,Wm=boost(A,W,G,dt/2);Gm,_=field(Am,Wm);A,W=boost(A,W,Gm,dt)
np.savez_compressed(ROOT/'results/rare_seed_long_continuation.npz',A=A,W=W,cfg=cfg,cube=cube,selected=np.array([json.dumps(r) for r in selected]))
