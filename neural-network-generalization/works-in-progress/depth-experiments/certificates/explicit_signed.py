#!/usr/bin/env python3
"""More costly refinement with exact clean transfers and signed remainder ranges.

Both preactivation displacement intervals and propagated tanh remainders are
signed. This refines the earlier symmetric absolute-remainder bound. Real
inequalities are rigorous; float64 evaluation is a numerical sufficient test.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import numpy as np
from finite_tube import sech2,clipped_change


def remainder_range(a,lo,hi):
 # Callers guarantee lo <= 0 <= hi. The curvature cap requires this.
 d=sech2(a);t=np.tanh(a)
 with np.errstate(over='ignore',invalid='ignore'):
  v0=np.tanh(a+lo)-t-d*lo;v1=np.tanh(a+hi)-t-d*hi
  critical=np.where((lo<=-2*a)&(-2*a<=hi),-2*t+2*a*d,0.)
  guard=32*np.finfo(float).eps*(1+np.abs(t)+d*np.maximum(np.abs(lo),np.abs(hi)))
  lower=np.minimum(0,np.minimum(v0,np.minimum(v1,critical)))-guard
  upper=np.maximum(0,np.maximum(v0,np.maximum(v1,critical)))+guard
  q=np.arctanh(1/np.sqrt(3));left=a+lo;right=a+hi
  hits=((left<=q)&(right>=q))|((left<=-q)&(right>=-q))
  curvature=np.maximum(2*np.abs(np.tanh(left))*sech2(left),2*np.abs(np.tanh(right))*sech2(right))
  curvature=np.where(hits,4/(3*np.sqrt(3)),curvature)
  cap=.5*curvature*np.maximum(np.abs(lo),np.abs(hi))**2
 return np.maximum(lower,-cap),np.minimum(upper,cap)


def certificate(p,x,c=.001):
 n=len(p[-1]);H=len(p)-1;ev=n*np.dot(p[-1],p[-1]);radius=c/np.sqrt(1+H*ev)
 h=np.r_[x,1.];tr=np.empty((len(h),0));remlo=np.empty(0);remhi=np.empty(0);ident=np.sqrt(n)*np.eye(n)
 max_tube=0.
 with np.errstate(over='ignore',invalid='ignore'):
  for w in p[:-1]:
   a=h@w;pre=w.T@tr;pos=np.maximum(pre,0);neg=np.minimum(pre,0);lin=radius*np.linalg.norm(pre,axis=1)
   lower=-lin+(pos@remlo+neg@remhi)/np.sqrt(n)
   upper=lin+(pos@remhi+neg@remlo)/np.sqrt(n)
   max_tube=max(max_tube,float(np.max(np.maximum(np.abs(lower),np.abs(upper)))))
   rl,ru=remainder_range(a,lower,upper)
   tr=np.concatenate((sech2(a)[:,None]*pre,ident),axis=1);remlo=np.r_[remlo,rl];remhi=np.r_[remhi,ru];h=np.tanh(a)
  out=p[-1]@tr;positive=np.maximum(out,0);negative=np.minimum(out,0);linear=radius*np.sqrt(1+np.dot(out,out));z=float(h@p[-1])
  lower=z-linear+(positive@remlo+negative@remhi)/np.sqrt(n)
  upper=z+linear+(positive@remhi+negative@remlo)/np.sqrt(n)
 if not np.isfinite(lower):lower=-np.inf
 if not np.isfinite(upper):upper=np.inf
 return dict(clean_output=z,lower=float(lower),upper=float(upper),c=c,radius=float(radius),linear_bound=float(linear),max_preactivation_tube=max_tube,
             certificate_kind='Explicit signed clean-transfer finite-radius inequality; float64 evaluation, not interval verified.')
