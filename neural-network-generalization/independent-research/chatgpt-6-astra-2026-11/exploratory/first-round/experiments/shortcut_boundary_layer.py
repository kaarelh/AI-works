"""Rare-neuron dynamics in the limiting logistic shortcut background.

This is a derived boundary-layer model, not a simulation of the full network.
The background A(t)=rho/(1+exp(-rho*L*t)), B=0 is prescribed. Initial
directions are parametrized by xi=t_initial*exp(2*s_infinity). Their
capture interval predicts the vanishing feature mass of the full flow.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from numpy.polynomial.legendre import leggauss
from scipy.special import expit
from shortcut_continuum import corr
ROOT=Path(__file__).resolve().parents[1]
def grid(logmax,nleg,nphi):
 edges=np.r_[0.,np.geomspace(1e-6,10.**logmax,2*(logmax+6)+1)]
 xx,ww=leggauss(nleg);xi=[];q=[]
 for l,h in zip(edges[:-1],edges[1:]):
  xi.extend((l+h)/2+(h-l)/2*xx);q.extend((h-l)/2*ww)
 xi=np.array(xi);q=np.array(q);phi=(np.arange(nphi)+.371)*2*np.pi/nphi
 return np.repeat(xi,nphi),np.repeat(q/nphi,nphi),np.tile(phi,len(xi))
def run(L,rho,dt,logmax,nleg,nphi):
 xi,weight,phi=grid(logmax,nleg,nphi);k=rho*L
 tstart=-(logmax*math.log(10)+25)/k;tend=100.
 s=math.sqrt(1+math.exp(-k*tstart))
 u=xi/s;v=np.full_like(xi,s);bb=np.sqrt(xi)[:,None]*np.c_[np.cos(phi),np.sin(phi)]
 nsteps=math.ceil((tend-tstart)/dt);dt=(tend-tstart)/nsteps;start=time.time()
 def field(u,v,bb,t):
  a=(u+v)/2;W=np.c_[(u-v)/2,bb];G,grad=corr(W,L)
  A=rho*expit(k*t);r1=rho-A;r2=1-rho*A
  g=r2*grad;g[:,0]+=r1*L/2;cross=np.sum(bb*g[:,1:],axis=1)
  return g[:,0]*u+cross,-g[:,0]*v+cross,a[:,None]*g[:,1:]
 for step in range(nsteps):
  t=tstart+step*dt;du,dv,db=field(u,v,bb,t)
  du2,dv2,db2=field(u+dt*du,v+dt*dv,bb+dt*db,t+dt)
  u+=dt/2*(du+du2);v+=dt/2*(dv+dv2);bb+=dt/2*(db+db2)
  b2=np.sum(bb*bb,axis=1);small=u<=v
  u[small]=b2[small]/v[small];v[~small]=b2[~small]/u[~small]
 a=(u+v)/2;W=np.c_[(u-v)/2,bb];G,_=corr(W,L)
 capture=(G/a>1e-3)&(np.abs(W[:,0])*L<np.abs(W[:,1])+np.abs(W[:,2]))
 J=float(weight[capture].sum());delta=rho-.5-1/L**2
 exponent=1+math.sqrt(2*(L*L+2))
 row=dict(L=L,rho=rho,delta=delta,dt=dt,logmax=logmax,nleg=nleg,nphi=nphi,
          nodes=len(xi),capture_integral=J,critical_exponent=exponent,
          scaled_integral=J*delta**exponent,seconds=time.time()-start,
          largest_captured_xi=float(np.max(xi[capture])) if np.any(capture) else None)
 key=f'L{L:g}_rho{rho:g}_dt{dt:.5g}_max{logmax}_l{nleg}_f{nphi}'
 (ROOT/'results'/f'boundary_layer_{key}.json').write_text(json.dumps(row,indent=2)+'\n')
 np.savez_compressed(ROOT/'results'/f'boundary_layer_{key}.npz',xi=xi,weight=weight,phi=phi,capture=capture,W=W,a=a)
 print(json.dumps(row),flush=True);return row
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--L',type=float,default=2);ap.add_argument('--rho',type=float,default=.9)
 ap.add_argument('--dt',type=float,default=.01);ap.add_argument('--logmax',type=int,default=14)
 ap.add_argument('--nleg',type=int,default=8);ap.add_argument('--nphi',type=int,default=64)
 x=ap.parse_args();run(x.L,x.rho,x.dt,x.logmax,x.nleg,x.nphi)
