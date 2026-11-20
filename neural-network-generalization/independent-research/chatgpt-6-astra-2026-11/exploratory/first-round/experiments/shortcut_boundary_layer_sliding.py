"""Boundary layer with exact resolution of the attracting ReLU gate.

After the bulk passes its grazing time, positive-correlation neurons are
permanently captured. Negative-correlation neurons can slide along the
negative shortcut gate. Their eventual escape is determined analytically
from the remaining bulk clock; ordinary fixed-step integration chatters
at this gate and is unreliable for very small rho-rho_c.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import expit
from shortcut_continuum import corr
from shortcut_boundary_layer_adaptive import quadrature
ROOT=Path(__file__).resolve().parents[1]
def run(L,rho,dt,nleg,angular_nleg):
 delta=rho-.5-1/L**2;k=rho*L;kap=math.sqrt(2*(L*L+2));D1=2*L*L-rho*(L*L+2)
 Ag=2*L*L*delta/D1;tg=math.log(Ag/(rho-Ag))/k
 logmax=math.ceil((1+2*kap)*math.log10(1/delta)+5)
 xi,qx=quadrature(np.r_[0.,np.geomspace(1e-6,10.**logmax,2*(logmax+6)+1)],nleg)
 phip,qp=quadrature([0.,np.pi/4],4*angular_nleg)
 mineps=max(1e-14,delta*1e-6);ninterval=math.ceil(2*math.log10((np.pi/4)/mineps))
 eps,qn=quadrature(np.r_[0.,np.geomspace(mineps,np.pi/4,ninterval+1)],angular_nleg)
 phi=np.r_[phip,3*np.pi/4-eps];qphi=np.r_[qp,qn]*2/np.pi
 allxi=np.repeat(xi,len(phi));allphi=np.tile(phi,len(xi));weight=np.repeat(qx,len(phi))*np.tile(qphi,len(xi))
 tstart=-(logmax*math.log(10)+25)/k;tend=120.;steps=math.ceil((tend-tstart)/dt);dt=(tend-tstart)/steps
 z=np.sqrt(allxi/(1+math.exp(-k*tstart)))[:,None]*np.c_[np.cos(allphi),np.sin(allphi)]
 ids=np.arange(len(z));captured=[];sliding_capture=0;sliding_trap=0;start=time.time();lastlog=0
 def field(z,t):
  rr=np.sum(z*z,axis=1);W=np.c_[(rr-1)/2,z];_,grad=corr(W,L)
  A=rho*expit(k*t);g=(1-rho*A)*grad;g[:,0]+=(rho-A)*L/2
  return g[:,0,None]*z+(1+rr)[:,None]/2*g[:,1:]-z*np.sum(z*g[:,1:],axis=1)[:,None]
 def slides(W,t):
  # W is on the negative gate, after tg. Only ratios matter.
  S=np.abs(W[:,1:]).sum(axis=1);d=np.abs(np.abs(W[:,1])-np.abs(W[:,2]));c=math.sqrt(L*L+2)/L
  need=np.arcsinh(np.divide(c*S,d,out=np.full_like(d,np.inf),where=d>0))-math.asinh(c)
  available=np.logaddexp(0,-k*np.asarray(t))/math.sqrt(2*(L*L+2))
  return need<available
 for step in range(steps):
  t=tstart+step*dt
  if len(ids)==0:break
  rr=np.sum(z*z,axis=1);W=np.c_[(rr-1)/2,z];h=np.abs(z).sum(axis=1)-L*np.abs(W[:,0]);eta=z[:,0]*z[:,1]
  remove=np.zeros(len(ids),bool)
  # Every positive shortcut gate is absorbing, at every time.
  remove|=(W[:,0]>=0)&(h<=0)
  if t>=tg:
   good=(eta>0)&(h>0);captured.extend(ids[good]);remove|=good
   outside=(W[:,0]<0)&(h<=0)&~remove
   if np.any(outside):
    zz=z[outside];r=np.sum(zz*zz,axis=1);c0=np.abs(zz).sum(axis=1)
    factor=L/(np.sqrt(c0*c0+L*L*r)+c0)
    sexp=(1+math.exp(-k*t))/(factor*factor)-1
    enters=sexp>0;good2=np.zeros(len(zz),bool)
    positive=zz[:,0]*zz[:,1]>0;good2[enters&positive]=True
    neg=enters&~positive
    if np.any(neg):
     ze=zz[neg]*factor[neg,None];We=np.c_[(np.sum(ze*ze,axis=1)-1)/2,ze];te=-np.log(sexp[neg])/k
     good2[neg]=slides(We,te);sliding_capture+=int(good2[neg].sum());sliding_trap+=int((~good2[neg]).sum())
    captured.extend(ids[outside][good2]);remove|=outside
  ids=ids[~remove];z=z[~remove];W=W[~remove];h=h[~remove];eta=eta[~remove]
  if len(ids)==0:break
  dz=field(z,t);dz2=field(z+dt*dz,t+dt);zn=z+dt/2*(dz+dz2)
  rn=np.sum(zn*zn,axis=1);Wn=np.c_[(rn-1)/2,zn];hn=np.abs(zn).sum(axis=1)-L*np.abs(Wn[:,0])
  # Resolve a negative-correlation central-to-gate hit after the threshold.
  hit=(t+dt>=tg)&(eta<0)&(W[:,0]<0)&(h>0)&(hn<=0)
  if np.any(hit):
   frac=h[hit]/(h[hit]-hn[hit]);We=W[hit]+frac[:,None]*(Wn[hit]-W[hit]);normal=np.c_[np.full(hit.sum(),L),np.sign(We[:,1:])]
   We-=normal*np.sum(We*normal,axis=1)[:,None]/(L*L+2)
   tt=np.maximum(tg,t+dt*frac);good=slides(We,tt);captured.extend(ids[hit][good]);sliding_capture+=int(good.sum());sliding_trap+=int((~good).sum())
  ids=ids[~hit];z=zn[~hit]
  if time.time()-lastlog>30:
   print(json.dumps(dict(status='progress',L=L,rho=rho,t=t,active=len(ids),captured=len(captured),seconds=time.time()-start)),flush=True);lastlog=time.time()
 captured=np.array(captured,dtype=int);J=float(weight[captured].sum());pos=np.cos(allphi[captured])*np.sin(allphi[captured])>0
 row=dict(L=L,rho=rho,delta=delta,dt=dt,nleg=nleg,angular_nleg=angular_nleg,nodes=len(allxi),capture_integral=J,positive_initial_integral=float(weight[captured[pos]].sum()),negative_initial_integral=float(weight[captured[~pos]].sum()),scaled_single=J*delta**(1+kap),scaled_double=J*delta**(2*kap),largest_captured_xi=float(allxi[captured].max()) if len(captured) else None,sliding_capture=sliding_capture,sliding_trap=sliding_trap,unresolved=len(ids),t_end=t,seconds=time.time()-start)
 key=f'L{L:g}_rho{rho:g}_dt{dt:.5g}_l{nleg}_a{angular_nleg}'
 (ROOT/'results'/f'boundary_sliding_{key}.json').write_text(json.dumps(row,indent=2)+'\n');np.savez_compressed(ROOT/'results'/f'boundary_sliding_{key}.npz',xi=allxi,phi=allphi,weight=weight,captured=captured,unresolved=ids)
 print(json.dumps(row),flush=True);return row
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--L',type=float,default=2);ap.add_argument('--rho',type=float,default=.76);ap.add_argument('--dt',type=float,default=.01);ap.add_argument('--nleg',type=int,default=8);ap.add_argument('--angular-nleg',type=int,default=6)
 x=ap.parse_args();run(x.L,x.rho,x.dt,x.nleg,x.angular_nleg)
