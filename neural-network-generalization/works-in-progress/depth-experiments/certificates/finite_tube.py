#!/usr/bin/env python3
"""Scalable finite-radius certificates with reachable-state saturation.

Exact-real sufficient inequalities, evaluated in float64 with small guards;
these numerical evaluations are NOT outward-rounded interval proofs.
Cost O(H N^3) per input/radius, memory O(H N^2), without HN-column transfers.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import numpy as np


def sech2(x):
 q=np.exp(-2*np.abs(x));return 4*q/(1+q)**2


def signed_remainder(a,b):
 """Enclose R(u)=tanh(a+u)-tanh(a)-sech²(a)u for |u|<=b."""
 d=sech2(a);t=np.tanh(a)
 with np.errstate(over='ignore',invalid='ignore'):
  minus=np.tanh(a-b)-t+d*b;plus=np.tanh(a+b)-t-d*b
  critical=np.where(2*np.abs(a)<=b,-2*t+2*a*d,0.)
  guard=32*np.finfo(float).eps*(1+np.abs(t)+d*b)
  lower=np.minimum(0,np.minimum(minus,np.minimum(plus,critical)))-guard
  upper=np.maximum(0,np.maximum(minus,np.maximum(plus,critical)))+guard
  q=np.arctanh(1/np.sqrt(3));lo=a-b;hi=a+b
  hits=((lo<=q)&(hi>=q))|((lo<=-q)&(hi>=-q))
  curvature=np.maximum(2*np.abs(np.tanh(lo))*sech2(lo),2*np.abs(np.tanh(hi))*sech2(hi))
  curvature=np.where(hits,4/(3*np.sqrt(3)),curvature)
  cap=.5*curvature*b*b
  lower=np.maximum(lower,-cap);upper=np.minimum(upper,cap)
 return np.where(np.isfinite(lower),lower,-np.inf),np.where(np.isfinite(upper),upper,np.inf)


def spectral(w):
 return float(np.linalg.norm(w,2))*(1+1e-12)


class Prepared:
 def __init__(self,p):
  self.p=p;self.H=len(p)-1;self.N=len(p[-1]);self.Ev=self.N*np.sum(p[-1]**2)
  self.columnnorms=[np.linalg.norm(w,axis=0)for w in p[:-1]]
  self.norms=[spectral(w)for w in p[1:-1]]

 def clean(self,x):
  h=np.r_[x,1.];hs=[];aa=[];dd=[];ell=[]
  for s,w in enumerate(self.p[:-1]):
   a=h@w;h=np.tanh(a);aa.append(a);hs.append(h);dd.append(sech2(a))
   if s:ell.append(spectral(w*dd[-1][None,:]))
  gg=[None]*self.H;gg[-1]=self.p[-1]
  for s in range(self.H-1,0,-1):gg[s-1]=self.p[s]@(dd[s]*gg[s])
  linear_gain=np.sqrt(1+self.N*sum(np.dot(g,g)for g in gg))
  return dict(a=aa,h=hs,d=dd,ell=ell,g=gg,z=float(h@self.p[-1]),linear_gain=float(linear_gain))

 def certify(self,x,c=.001,prepared_clean=None):
  clean=self.clean(x)if prepared_clean is None else prepared_clean
  radius=c/np.sqrt(1+self.H*self.Ev);eta=np.sqrt(self.N)*radius
  a_total=0.;component=None;q_clean=0.;q_tube=0.;rem_norm=0.;out_lower=0.;out_upper=0.
  prebounds=[];lipschitz=[]
  for s,w in enumerate(self.p[:-1]):
   a=clean['a'][s]
   if s==0:
    b=np.zeros(self.N);rl=ru=np.zeros(self.N);q_clean=q_tube=1.;rem_norm=0.
    a_total=eta;component=np.full(self.N,eta);lipschitz.append(0.)
   else:
    b=np.minimum(self.columnnorms[s]*a_total,np.abs(w).T@component)
    rl,ru=signed_remainder(a,b)
    near=np.maximum(np.abs(a)-b,0.);dmax=sech2(near)
    ell=spectral(w*dmax[None,:]);lipschitz.append(ell)
    q_tube=1+ell*ell*q_tube
    q_clean=1+clean['ell'][s-1]**2*q_clean
    rem_norm=clean['ell'][s-1]*rem_norm+np.linalg.norm(np.maximum(np.abs(rl),np.abs(ru)))
    taylor_state=eta*np.sqrt(q_clean)+rem_norm
    tube_state=eta*np.sqrt(q_tube)
    a_total=min(taylor_state,tube_state)
    box_error=np.maximum(np.abs(np.tanh(a-b)-clean['h'][s]),np.abs(np.tanh(a+b)-clean['h'][s]))+eta
    component=np.minimum(box_error,a_total)
   prebounds.append(b)
   g=clean['g'][s]
   out_lower+=float(np.sum(np.where(g>=0,g*rl,g*ru)))
   out_upper+=float(np.sum(np.where(g>=0,g*ru,g*rl)))
  linear=radius*clean['linear_gain']
  lo=clean['z']-linear+out_lower;hi=clean['z']+linear+out_upper
  # A separate endpoint-state/coordinate enclosure can improve the interval.
  state_bound=min(np.linalg.norm(self.p[-1])*a_total,np.abs(self.p[-1])@component)+radius
  lo=max(lo,clean['z']-state_bound);hi=min(hi,clean['z']+state_bound)
  return dict(clean_output=clean['z'],lower=float(lo),upper=float(hi),radius=float(radius),c=float(c),
   linear_bound=float(linear),max_preactivation_tube=float(max(np.max(b)for b in prebounds)),
   per_layer_tube_norms=lipschitz,
   certificate_kind='float64 finite-tube/signed-remainder sufficient inequalities, not interval-verified')


def clipped_change(record,cap=.5):
 z=np.clip(record['clean_output'],-cap,cap)
 return float(max(abs(np.clip(record['lower'],-cap,cap)-z),abs(np.clip(record['upper'],-cap,cap)-z)))
