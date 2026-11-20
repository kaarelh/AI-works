"""Resolve the additional narrow angular layer near unfavorable parity seeds.

Stereographic coordinates encode balance exactly and permit discarding
neurons that enter the permanently absorbing positive shortcut gate.
The phi quadrature concentrates near 3*pi/4, where the frozen critical
flow has an additional slow passage. A uniform angular grid misses it.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from numpy.polynomial.legendre import leggauss
from scipy.special import expit
from shortcut_continuum import corr
ROOT=Path(__file__).resolve().parents[1]
def quadrature(edges,n):
 x,w=leggauss(n);z=[];q=[]
 for l,h in zip(edges[:-1],edges[1:]):z.extend((l+h)/2+(h-l)/2*x);q.extend((h-l)/2*w)
 return np.array(z),np.array(q)
def run(L,rho,dt,nleg,angular_nleg):
 delta=rho-.5-1/L**2;k=rho*L;kap=math.sqrt(2*(L*L+2))
 logmax=math.ceil((1+2*kap)*math.log10(1/delta)+5)
 xi,qx=quadrature(np.r_[0.,np.geomspace(1e-6,10.**logmax,2*(logmax+6)+1)],nleg)
 phip,qp=quadrature([0.,np.pi/4],4*angular_nleg)
 mineps=max(1e-14,delta*1e-6);ninterval=math.ceil(2*math.log10((np.pi/4)/mineps))
 eps,qn=quadrature(np.r_[0.,np.geomspace(mineps,np.pi/4,ninterval+1)],angular_nleg)
 phi=np.r_[phip,3*np.pi/4-eps];qphi=np.r_[qp,qn]*2/np.pi
 # The two sectors and their sign/swap symmetries cover the entire circle.
 assert abs(qphi.sum()-1)<1e-12
 allxi=np.repeat(xi,len(phi));allphi=np.tile(phi,len(xi));weight=np.repeat(qx,len(phi))*np.tile(qphi,len(xi))
 tstart=-(logmax*math.log(10)+25)/k;tend=40.;steps=math.ceil((tend-tstart)/dt);dt=(tend-tstart)/steps
 z=np.sqrt(allxi/(1+math.exp(-k*tstart)))[:,None]*np.c_[np.cos(allphi),np.sin(allphi)]
 ids=np.arange(len(z));start=time.time();lastlog=0
 def field(z,t):
  rr=np.sum(z*z,axis=1);W=np.c_[(rr-1)/2,z];_,grad=corr(W,L)
  A=rho*expit(k*t);g=(1-rho*A)*grad;g[:,0]+=(rho-A)*L/2
  return g[:,0,None]*z+(1+rr)[:,None]/2*g[:,1:]-z*np.sum(z*g[:,1:],axis=1)[:,None]
 for step in range(steps):
  t=tstart+step*dt;dz=field(z,t);dz2=field(z+dt*dz,t+dt);z+=dt/2*(dz+dz2)
  exited=L*(np.sum(z*z,axis=1)-1)/2>=np.abs(z).sum(axis=1)
  if np.any(exited):ids=ids[~exited];z=z[~exited]
  if time.time()-lastlog>30:
   print(json.dumps(dict(status='progress',L=L,rho=rho,t=t,active=len(ids),total=len(allxi),seconds=time.time()-start)),flush=True);lastlog=time.time()
 rr=np.sum(z*z,axis=1);W=np.c_[(rr-1)/2,z];G,_=corr(W,L);a=(1+rr)/2
 side=np.abs(np.abs(z[:,0])-np.abs(z[:,1]))>L*np.abs(W[:,0])+1e-10*a
 positive=(G/a>1e-8)
 captured=ids[side|positive];J=float(weight[captured].sum())
 positive_initial=np.cos(allphi[captured])*np.sin(allphi[captured])>0
 Jpos=float(weight[captured[positive_initial]].sum());Jneg=J-Jpos
 row=dict(L=L,rho=rho,delta=delta,dt=dt,nleg=nleg,angular_nleg=angular_nleg,nodes=len(allxi),
    capture_integral=J,positive_initial_integral=Jpos,negative_initial_integral=Jneg,
    single_pass_exponent=1+kap,double_pass_candidate_exponent=2*kap,
    scaled_single=J*delta**(1+kap),scaled_double=J*delta**(2*kap),
    logmax=logmax,largest_captured_xi=float(allxi[captured].max()) if len(captured) else None,seconds=time.time()-start)
 key=f'L{L:g}_rho{rho:g}_dt{dt:.5g}_l{nleg}_a{angular_nleg}'
 (ROOT/'results'/f'boundary_adaptive_{key}.json').write_text(json.dumps(row,indent=2)+'\n')
 np.savez_compressed(ROOT/'results'/f'boundary_adaptive_{key}.npz',xi=allxi,phi=allphi,weight=weight,captured=captured)
 print(json.dumps(row),flush=True);return row
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--L',type=float,default=2);ap.add_argument('--rho',type=float,default=.76)
 ap.add_argument('--dt',type=float,default=.01);ap.add_argument('--nleg',type=int,default=6);ap.add_argument('--angular-nleg',type=int,default=4)
 x=ap.parse_args();run(x.L,x.rho,x.dt,x.nleg,x.angular_nleg)
