#!/usr/bin/env python3
"""Exact reachable-tube and signed-remainder proofs for fixed unresolved inputs."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys,json,time,hashlib,multiprocessing
from pathlib import Path
from fractions import Fraction
import numpy as np,mpmath as mp
import exact_boolean_cube as base
import verify_reachable_tube as tube
from exact_covariance_state_point import remainder
from fast_exact_svd_bound import operator_square_upper
from exact_svd_bound import dyadic_integer_matrix,rational_record
from verify_witness import tanh_iv
ROOT=Path(__file__).resolve().parent;FOLDER=ROOT/'all-heldout-verified-105-c1_1000';EXP=ROOT.parent/'experiment'
BITS=160;S=2**BITS
def rat(a):return Fraction(int(a['numerator']),int(a['denominator']))
def rr(a):return rational_record(Fraction(a))
def ceil(v):return base.ceil_dyadic(v,80)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def interval_right(lo,hi,wi,dw):
 pos=np.maximum(wi,0);neg=np.minimum(wi,0)
 low=lo@pos+hi@neg;high=hi@pos+lo@neg
 return low//dw,-((-high)//dw)

def forward(p,x):
 unique,inverse=np.unique(np.c_[x,np.ones(len(x))],return_inverse=True)
 vals=[]
 for v in unique:
  f=Fraction.from_float(float(v));assert S%f.denominator==0;vals.append(f.numerator*(S//f.denominator))
 lo=np.asarray(vals,dtype=object)[inverse].reshape(len(x),x.shape[1]+1);hi=lo.copy();history=[];derivatives=[]
 for s,w in enumerate(p[:-1]):
  wi,dw=dyadic_integer_matrix(w);al,ah=interval_right(lo,hi,wi,dw);history.append((al,ah,S))
  nl=np.empty(al.shape,dtype=object);nh=np.empty(al.shape,dtype=object);dl=np.empty(al.shape,dtype=object);dh=np.empty(al.shape,dtype=object)
  for i in range(len(x)):
   for j in range(w.shape[1]):
    h=tanh_iv(base.bounds_iv(al[i,j],ah[i,j],S));d=1-h*h
    nl[i,j]=base.scaled_endpoint(h,False);nh[i,j]=base.scaled_endpoint(h,True)
    dl[i,j]=max(0,base.scaled_endpoint(d,False));dh[i,j]=min(S,base.scaled_endpoint(d,True))
  derivatives.append((dl,dh));lo,hi=nl,nh
  print('LOCAL-CLEAN-LAYER',s,flush=True)
 vi,dv=dyadic_integer_matrix(p[-1]);ol,oh=interval_right(lo,hi,vi,dv)
 return [Fraction(int(v),S)for v in ol],[Fraction(int(v),S)for v in oh],history,derivatives

def adjoints(p,derivatives,count):
 vi,dv=dyadic_integer_matrix(p[-1]);assert S%dv==0
 lo=np.broadcast_to(vi*(S//dv),(count,len(vi))).copy();hi=lo.copy();result=[None]*(len(p)-1);result[-1]=(lo.copy(),hi.copy())
 for s in range(len(p)-2,0,-1):
  dl,dh=derivatives[s];products=[lo*dl,lo*dh,hi*dl,hi*dh]
  pl=np.minimum.reduce(products)//S;ph=-((-np.maximum.reduce(products))//S)
  wi,dw=dyadic_integer_matrix(p[s]);lo,hi=interval_right(pl,ph,wi.T,dw);result[s-1]=(lo.copy(),hi.copy())
 return result

def one(local):
 i=INDICES[local];sub=FOLDER/f'local-input-{i:05d}';sub.mkdir(exist_ok=True);q=Fraction(1);low=Fraction(0);high=Fraction(0);layers=[]
 for s,w in enumerate(P[1:-1],1):
  al,ah,den=HISTORY[s];state=mp.iv.sqrt(base.iv(256*R2*q));d=[];remainders=[]
  for j in range(256):
   a=base.bounds_iv(al[local,j],ah[local,j],den);h=tanh_iv(a);der=1-h*h
   b=ceil(state*mp.iv.sqrt(base.iv(COLS[s-1][j])))
   aa=Fraction(int(al[local,j]),den);bb=Fraction(int(ah[local,j]),den)
   distance=Fraction(0)if aa<=0<=bb else min(abs(aa),abs(bb))
   near=max(Fraction(0),base.endpoint_fraction(base.iv(distance)-base.iv(b),False));e=mp.iv.exp(-2*base.iv(near))
   d.append(min(Fraction(1),base.ceil_dyadic(4*e/(1+e)**2)))
   rl,ru=remainder(a,h,der,b);remainders.append((rl,ru))
   gl,gh=ADJOINTS[s];glo=Fraction(int(gl[local,j]),S);ghi=Fraction(int(gh[local,j]),S)
   values=[glo*rl,glo*ru,ghi*rl,ghi*ru];low+=min(values);high+=max(values)
  ell=BOUNDS[s-1] if all(v==1 for v in d)else min(BOUNDS[s-1],tube.product_norm_bound(w,d,sub,s))
  q=1+ell*q
  layers.append(dict(layer=s,operator_squared_upper=rr(ell),prefix_gain_squared=rr(q),signed_output_remainder_lower=rr(low),signed_output_remainder_upper=rr(high)))
 norm2=Fraction(0)
 for gl,gh in ADJOINTS:
  norm2+=sum((max(abs(int(a)),abs(int(b)))**2 for a,b in zip(gl[local],gh[local])),0)/Fraction(S*S)
 linear=ceil(mp.iv.sqrt(base.iv(R2*(1+256*norm2))))
 lower=LO[local]-linear+low;upper=HI[local]+linear+high
 # Independent last-state tube bound uses the simultaneous output budget.
 raw=ceil(mp.iv.sqrt(base.iv(R2*(1+EV*q))))
 lower=max(lower,LO[local]-raw);upper=min(upper,HI[local]+raw)
 cap=Fraction(1,2);clip=lambda v:max(-cap,min(cap,v))
 change=max(clip(upper)-clip(LO[local]),clip(HI[local])-clip(lower))
 result=dict(test_index=i,clean_output_lower=rr(LO[local]),clean_output_upper=rr(HI[local]),
  perturbed_output_lower=rr(lower),perturbed_output_upper=rr(upper),linear_output_change_upper=rr(linear),
  signed_output_remainder_lower=rr(low),signed_output_remainder_upper=rr(high),
  clipped_change_upper=rr(change),certified=change<=Fraction(1,16),layers=layers,
  method='160bit outward clean/adjoint intervals, exact reachable-tube operator certificates, exact scalar Taylor extrema, signed clean-adjoint remainder sum.')
 (sub/'certificate.json').write_text(json.dumps(result,indent=2)+'\n')
 print('LOCAL-FINAL',i,result['certified'],'clip',float(change),flush=True);return result

def main():
 global P,INDICES,BOUNDS,EV,R2,LO,HI,HISTORY,ADJOINTS,COLS
 started=time.monotonic();mp.iv.dps=90;base.BITS=BITS;base.SCALE=S;tube.operator_square_upper=operator_square_upper
 globalfile=FOLDER/'global-component.json';component=json.loads(globalfile.read_text());INDICES=component['unresolved_test_indices']
 model=next((EXP/'models').glob('105-*.npz'));saved=np.load(model);P=[saved[f'w{i}']for i in range(17)]
 assert sha(model)==component['model_sha256']
 original=np.load(FOLDER/'inputs.npz')['inputs'];x=original[INDICES]
 globalnorm=json.loads((ROOT/'global-exact-verified-105.json').read_text());BOUNDS=[rat(v)for v in globalnorm['operator_squared_upper_bounds_exact']]
 EV=rat(component['readout_energy_exact']);R2=rat(component['noise_radius_squared_exact'])
 LO,HI,HISTORY,derivatives=forward(P,x);ADJOINTS=adjoints(P,derivatives,len(x));COLS=[]
 for w in P[1:-1]:
  wi,dw=dyadic_integer_matrix(w);COLS.append([Fraction(sum(int(v)*int(v)for v in wi[:,j]),dw*dw)for j in range(256)])
 with multiprocessing.get_context('fork').Pool(2)as pool:rows=pool.map(one,range(len(INDICES)))
 out=dict(model=component['model'],model_sha256=component['model_sha256'],input_archive_sha256=component['input_archive_sha256'],
  c_exact=component['c_exact'],noise_radius_squared_exact=component['noise_radius_squared_exact'],input_count=len(INDICES),
  certified=sum(v['certified']for v in rows),all_local_inputs_certified=all(v['certified']for v in rows),rows=rows,
  source_sha256=sha(Path(__file__)),dyadic_bits=BITS,interval_decimal_digits=90,elapsed_seconds=time.monotonic()-started,
  scope='The exact twelve previously unresolved official held-out inputs; every simultaneous hidden/output disturbance at c=.001.')
 (FOLDER/'local-component.json').write_text(json.dumps(out,indent=2)+'\n')
 print('LOCAL-COMPONENT-FINAL',out['certified'],'/',len(INDICES),'seconds',time.monotonic()-started,flush=True)
if __name__=='__main__':main()
