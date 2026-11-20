"""Resolve rare initial directions in a symmetry-preserving population flow.

Quadrature nodes represent an actual weighted collection of four-neuron
orbits. Logarithmic intervals near the antipodal direction resolve masses
far smaller than feasible iid neuron samples. This is not an iid finite-
width experiment. Heun integration is projected onto the exact balance
invariant; independent step-size/node-resolution checks are required.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from numpy.polynomial.legendre import leggauss
ROOT=Path(__file__).resolve().parents[1]
def grid(power,nleg,nphi):
 edges=np.unique(np.r_[0.,np.geomspace(10.**(-power),.1,power+1),.2,.4,.6,.8,1.])
 xx,ww=leggauss(nleg);ts=[];qs=[]
 for low,high in zip(edges[:-1],edges[1:]):
  ts.extend((low+high)/2+(high-low)/2*xx);qs.extend((high-low)/2*ww)
 ts=np.array(ts);qs=np.array(qs);ph=(np.arange(nphi)+.371)*2*math.pi/nphi
 v1=2*ts-1;rad=2*np.sqrt(ts*(1-ts))
 W=np.stack(np.broadcast_arrays(v1[:,None],rad[:,None]*np.cos(ph),rad[:,None]*np.sin(ph)),axis=-1).reshape(-1,3)
 q=np.repeat(qs/nphi,nphi);return W,q,np.repeat(ts,nphi)
def corr(W,L):
 p=np.abs(W[:,0])*L;b=np.abs(W[:,1]);c=np.abs(W[:,2]);sg=np.sign(W)
 eta=sg[:,1]*sg[:,2]
 G=eta*(np.maximum(p,b+c)-np.maximum(p,np.abs(b-c)))/4
 grad=np.zeros_like(W)
 # Include ties in the central subgradient. At p=0,b=c this gives the
 # balanced feature gradient, rather than spuriously setting it to zero.
 central=(p<=b+c)&(p>=np.abs(b-c))
 grad[central,0]=-eta[central]*L*sg[central,0]/4
 grad[central,1]=sg[central,2]/4;grad[central,2]=sg[central,1]/4
 bdom=b>p+c;cdom=c>p+b
 grad[bdom,2]=sg[bdom,1]/2;grad[cdom,1]=sg[cdom,2]/2
 return G,grad
def run(L,rho,alpha,dt,horizon,power,nleg,nphi):
 W0,q,ts=grid(power,nleg,nphi)
 # Null coordinates retain the tiny growing mode near the antipodal ray.
 # Computing a+p by subtracting nearly equal floats would erase it.
 u=alpha*ts;v=alpha*(1-ts);bb=W0[:,1:]*alpha/2
 start=time.time();steps=round(horizon/dt)
 def field(u,v,bb):
  a=(u+v)/2;W=np.c_[(u-v)/2,bb]
  G,grad=corr(W,L);A=2*L*np.sum(q*a*W[:,0]);B=4*np.sum(q*a*G)
  r1=rho-A-rho*B;r2=1-B-rho*A
  g=r2*grad;g[:,0]+=r1*L/2
  cross=np.sum(bb*g[:,1:],axis=1)
  return g[:,0]*u+cross,-g[:,0]*v+cross,a[:,None]*g[:,1:],A,B
 checks=set([0,steps]+[int(t/dt) for t in np.geomspace(.1,horizon,100)])
 key=f'null_L{L:g}_rho{rho:g}_a{alpha:g}_dt{dt:g}_p{power}_l{nleg}_f{nphi}'
 path=ROOT/'results'/f'continuum_{key}.jsonl'
 events={};levels=[.0001,.001,.01,.1,.5,.9,.99]
 with path.open('w',buffering=1) as f:
  for k in range(steps+1):
   du,dv,db,A,B=field(u,v,bb);a=(u+v)/2;W=np.c_[(u-v)/2,bb]
   for level in levels:
    if str(level) not in events and B>=level:
     events[str(level)]=k*dt
   if 'shortcut_90percent' not in events and A>=.9*rho:events['shortcut_90percent']=k*dt
   if k in checks:
    loss=(A*A+(B-1)**2+2*rho*A*(B-1))/2
    outside=np.abs(W[:,0])*L<np.abs(W[:,1])+np.abs(W[:,2])
    mass=float(np.sum(q[outside]));energy=float(np.sum(q[outside]*a[outside]**2))
    row=dict(L=L,rho=rho,alpha=alpha,dt=dt,t=k*dt,nodes=len(q),power=power,nleg=nleg,nphi=nphi,
      A=float(A),B=float(B),loss=float(loss),nonlinear_mass=mass,nonlinear_energy=energy,
      seconds=time.time()-start)
    f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
    if loss<1e-9:break
   if k==steps:break
   du2,dv2,db2,_,_=field(u+dt*du,v+dt*dv,bb+dt*db)
   u+=dt/2*(du+du2);v+=dt/2*(dv+dv2);bb+=dt/2*(db+db2)
   b2=np.sum(bb*bb,axis=1);small=u<=v
   u[small]=b2[small]/v[small];v[~small]=b2[~small]/u[~small]
   assert np.all(u>=0) and np.all(v>=0)
  np.savez_compressed(ROOT/'results'/f'continuum_{key}.npz',W=W,a=a,q=q,initial_t=ts,W0=W0,u=u,v=v)
  eventrow=dict(L=L,rho=rho,alpha=alpha,dt=dt,power=power,nleg=nleg,nphi=nphi,
    events=events,final=row,predicted_log_slope=2/(rho*L)+6*math.sqrt(2)/(1-rho*rho))
  (ROOT/'results'/f'continuum_{key}_events.json').write_text(json.dumps(eventrow,indent=2)+'\n')
 return row
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--L',type=float,default=2)
 ap.add_argument('--rho',type=float,default=.9);ap.add_argument('--alpha',type=float,default=1e-4)
 ap.add_argument('--dt',type=float,default=.02);ap.add_argument('--time',type=float,default=1000)
 ap.add_argument('--power',type=int,default=24);ap.add_argument('--nleg',type=int,default=8);ap.add_argument('--nphi',type=int,default=64)
 x=ap.parse_args();run(x.L,x.rho,x.alpha,x.dt,x.time,x.power,x.nleg,x.nphi)
