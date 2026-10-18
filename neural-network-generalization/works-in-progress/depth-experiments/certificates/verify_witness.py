#!/usr/bin/env python3
"""Exact dyadic budget and outward interval output verification of attacks."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys
from pathlib import Path
from fractions import Fraction
import numpy as np
import mpmath as mp
# Local copies of the exact-input primitives used in the preceding research
# round, kept here so the current certificate archive is self-contained.
def rational(value):
 return Fraction.from_float(float(value))

def interval(value):
 a,b=float(value).as_integer_ratio()
 return mp.iv.mpf(a)/mp.iv.mpf(b)

def tanh_iv(value):
 q=mp.iv.exp(2*value)
 return (q-1)/(q+1)


def clip_iv(value,cap):
 cc=mp.iv.mpf(str(cap))
 if bool(value.b<=-cc):return -cc
 if bool(value.a>=cc):return cc
 low=value.a if bool(value.a>=-cc)else -cc
 high=value.b if bool(value.b<=cc)else cc
 return mp.iv.mpf([low,high])


def margin_band_iv(value):
 """Monotone U(z)=sign(z) min(1/4,(|z|-1/4)_+)."""
 quarter=mp.iv.mpf(1)/4;half=mp.iv.mpf(1)/2
 def endpoint(v):
  if bool(v<=-half):return -quarter
  if bool(v<-quarter):return v+quarter
  if bool(v<=quarter):return mp.iv.mpf(0)
  if bool(v<half):return v-quarter
  return quarter
 low=endpoint(value.a);high=endpoint(value.b)
 return mp.iv.mpf([low.a,high.b])


def forward_exact_input(p,input_rationals,eta=None,return_diagnostics=False):
 h=[mp.iv.mpf(v.numerator)/mp.iv.mpf(v.denominator)for v in input_rationals]+[mp.iv.mpf(1)]
 inside=True;outside=False;largest=0.
 for s,w in enumerate(p[:-1]):
  h=[tanh_iv(sum((h[i]*interval(w[i,j])for i in range(len(h))),mp.iv.mpf(0)))for j in range(w.shape[1])]
  if eta is not None:h=[v+interval(eta[s,j])for j,v in enumerate(h)]
  inside=inside and all(bool(v.a>=-1 and v.b<=1)for v in h)
  outside=outside or any(bool(v.a>1 or v.b<-1)for v in h)
  largest=max(largest,max(max(abs(float(v.a)),abs(float(v.b)))for v in h))
 output=sum((v*interval(w)for v,w in zip(h,p[-1])),mp.iv.mpf(0))
 diagnostics=dict(interval_verified_all_disturbed_hidden_states_inside_unit_box=inside,
                  interval_verified_some_disturbed_hidden_state_outside_unit_box=outside,
                  maximum_hidden_absolute_interval_endpoint_approx=largest)
 return (output,diagnostics)if return_diagnostics else output


def verify(p,x,eta,c,output_noise=0.,input_rationals=None):
 mp.iv.dps=100;H=len(p)-1;N=len(p[-1])
 ev=N*sum((rational(v)**2 for v in p[-1]),Fraction(0))
 sq=sum((rational(v)**2 for v in eta.flat),Fraction(0))/N+rational(output_noise)**2
 budget=sq*(1+H*ev);cc=Fraction(str(c))
 if input_rationals is None:input_rationals=[rational(v)for v in x]
 clean=forward_exact_input(p,input_rationals)
 noisy,diagnostics=forward_exact_input(p,input_rationals,eta,return_diagnostics=True)
 noisy+=interval(output_noise)
 gap_violations=[]
 for label in [-1,1]:
  yc=label*clean;yn=label*noisy
  if bool(yc.a>=mp.iv.mpf(1)/2 and yn.b<mp.iv.mpf(7)/16):gap_violations.append(dict(label=label,case="clean signed output at least1/2 but noisy below7/16"))
  if bool(yc.b<=mp.iv.mpf(1)/4 and yn.a>mp.iv.mpf(5)/16):gap_violations.append(dict(label=label,case="clean signed output at most1/4 but noisy above5/16"))
 clips={}
 for cap in [.5,1.]:
  difference=clip_iv(noisy,cap)-clip_iv(clean,cap)
  clips[str(cap)]=dict(signed_change_interval=str(difference),violation=bool(difference.a>mp.iv.mpf(1)/16 or difference.b<-mp.iv.mpf(1)/16))
 return dict(exact_rational_budget_pass=bool(budget<=cc*cc),
  normalized_squared_norm_approx=float(budget),budget_numerator=str(budget.numerator),budget_denominator=str(budget.denominator),
  c_exact_numerator=str(cc.numerator),c_exact_denominator=str(cc.denominator),
  clean_output_interval=str(clean),perturbed_output_interval=str(noisy),clipped=clips,hidden_state_diagnostics=diagnostics,
  optional_one_sided_gap=dict(violation=bool(gap_violations),violations=gap_violations),
  optional_margin_band=dict(signed_change_interval=str(margin_band_iv(noisy)-margin_band_iv(clean)),violation=bool((margin_band_iv(noisy)-margin_band_iv(clean)).a>mp.iv.mpf(1)/16 or (margin_band_iv(noisy)-margin_band_iv(clean)).b<-mp.iv.mpf(1)/16)),
  input_is_boolean=bool(np.all(np.isin(x,[-1,1]))),input_in_continuous_box=bool(np.all(np.abs(x)<=1)),
  qualification='Exact integer-rational noise budget and100decimal outward interval real-network evaluation. Trusts mpmath; not Lean formalization.')
