#!/usr/bin/env python3
"""Exact fixed-point clean enclosures for all 10,000 saved MNIST test inputs.

Integer matrix products are guarded against int64 overflow. A uniformly
certified piecewise-linear tanh table replaces any trust in floating libm.
Quantization errors are propagated using previously exact spectral bounds.
Unresolved inputs remain explicit and receive separate exact local proofs.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys,json,time,hashlib,argparse
from pathlib import Path
from fractions import Fraction
import numpy as np,mpmath as mp
import exact_boolean_cube as base
import verify_reachable_tube as tube
from exact_svd_bound import dyadic_integer_matrix,rational_record
from fast_exact_svd_bound import operator_square_upper
from verify_witness import tanh_iv
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP));import train
QH=2**24;QW=2**30;GRID=4096;EXTENT=12;LIMIT=2**63-1
FOLDER=ROOT/'all-heldout-verified-105-c1_1000'
def rat(v):return Fraction(int(v['numerator']),int(v['denominator']))
def rr(v):return rational_record(Fraction(v))
def ceil(v):return base.ceil_dyadic(v,80)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def int_matrix_product(a,b):
 a=np.asarray(a,dtype=np.int64);b=np.asarray(b,dtype=np.int64)
 assert a.shape[-1]==b.shape[0]
 aa=max(abs(int(a.min())),abs(int(a.max())))
 if b.ndim==1:column_sum=sum(abs(int(v)) for v in b)
 else:column_sum=max(sum(abs(int(v))for v in b[:,j])for j in range(b.shape[1]))
 assert aa*column_sum<=LIMIT,'Possible integer product overflow.'
 return a@b

def quantize(w):
 wi,dw=dyadic_integer_matrix(w)
 qi=(wi*QW+dw//2)//dw
 assert all(abs(int(v))<=LIMIT for v in qi.flat)
 denominator=max(dw,QW)
 residual=wi*(denominator//dw)-qi*(denominator//QW)
 square=Fraction(sum(int(v)*int(v)for v in residual.flat),denominator**2)
 return np.asarray(qi,dtype=np.int64),residual,denominator,square

def make_table():
 values=np.empty(2*EXTENT*GRID+1,dtype=np.int64);error=Fraction(0)
 for index,j in enumerate(range(-EXTENT*GRID,EXTENT*GRID+1)):
  value=tanh_iv(mp.iv.mpf(j)/GRID)
  proposal=int(round(float(value.mid)*QH))
  assert -QH<=proposal<=QH
  delta=value-base.iv(Fraction(proposal,QH))
  error=max(error,abs(base.endpoint_fraction(delta,False)),abs(base.endpoint_fraction(delta,True)))
  values[index]=proposal
 assert np.all(values[1:]>=values[:-1])
 table_error=ceil(base.iv(error))
 interpolation_error=Fraction(1,8*GRID**2)
 rounding_error=Fraction(1,2*QH)
 tail_error=ceil(2*mp.iv.exp(-2*EXTENT))
 total=max(table_error+interpolation_error+rounding_error,tail_error)
 np.savez_compressed(FOLDER/'tanh-table.npz',values=values)
 info=dict(grid=GRID,extent=EXTENT,state_denominator=QH,
  table_entry_error_upper=rr(table_error),linear_interpolation_error_upper=rr(interpolation_error),
  integer_rounding_error_upper=rr(rounding_error),tail_error_upper=rr(tail_error),total_coordinate_error_upper=rr(total))
 (FOLDER/'tanh-table-certificate.json').write_text(json.dumps(info,indent=2)+'\n')
 return values,total

def table_tanh(pre,table):
 denominator=QH*QW;cell=denominator//GRID;edge=EXTENT*denominator
 out=np.empty_like(pre);low=pre<=-edge;high=pre>=edge;inside=~(low|high)
 out[low]=-QH;out[high]=QH
 z=pre[inside]
 assert edge<=LIMIT//2
 shifted=z+edge;index=shifted//cell;remainder=shifted%cell
 left=table[index];difference=table[index+1]-left
 assert int(difference.max(initial=0))*cell+cell//2<=LIMIT
 out[inside]=left+(difference*remainder+cell//2)//cell
 assert np.all(np.abs(out)<=QH)
 return out

def exact_input_integers(x):
 unique,inverse=np.unique(x,return_inverse=True)
 fractions=[Fraction.from_float(float(v))for v in unique]
 den=max(v.denominator for v in fractions)
 assert den&(den-1)==0
 integers=np.array([v.numerator*(den//v.denominator)for v in fractions],dtype=np.int64)
 true=integers[inverse].reshape(x.shape)
 approximate=np.asarray((true.astype(object)*QH+den//2)//den,dtype=np.int64)
 assert den%QH==0
 residual=true-approximate*(den//QH)
 assert np.all(np.abs(approximate)<=QH)
 return approximate,residual,den

def global_clean_pass(p,x,bounds,ev,r2):
 start=time.monotonic();table,tanherror=make_table();n=len(p[-1]);layers=[]
 augmented=np.c_[x,np.ones(len(x))]
 assert np.all(np.abs(augmented)<=1)
 assert len(bounds)==len(p)-2
 h,initial_residual,inputden=exact_input_integers(augmented)
 error=Fraction(0)
 for s,w in enumerate(p[:-1]):
  qw,residual,den,residual2=quantize(w)
  if s==0:
   # xW - xqWq = x(W-Wq) + (x-xq)Wq, with |x_i|<=1.
   exact_residual_product=int_matrix_product(initial_residual,qw)
   max_input_residual=np.max(np.abs(exact_residual_product),axis=0)
   columns=[Fraction(sum(abs(int(v))for v in residual[:,j]),den)+Fraction(int(max_input_residual[j]),inputden*QW)for j in range(n)]
   preerror=ceil(mp.iv.sqrt(base.iv(sum((v*v for v in columns),Fraction(0)))))
  else:
   preerror=ceil(mp.iv.sqrt(base.iv(bounds[s-1]))*base.iv(error)+mp.iv.sqrt(base.iv(n*residual2)))
  pre=int_matrix_product(h,qw);h=table_tanh(pre,table)
  error=ceil(base.iv(preerror)+mp.iv.sqrt(n)*base.iv(tanherror))
  layers.append(dict(layer=s,weight_residual_squared=rr(residual2),preactivation_error_norm_upper=rr(preerror),hidden_error_norm_upper=rr(error)))
  print('FIXED-POINT-LAYER',s,'uniform_state_error',float(error),'seconds',time.monotonic()-start,flush=True)
 qv,residual,den,residual2=quantize(p[-1])
 approximate=int_matrix_product(h,qv);outden=QH*QW
 readout_residual=Fraction(sum(abs(int(v))for v in residual),den)
 error=ceil(mp.iv.sqrt(base.iv(ev/n))*base.iv(error)+base.iv(readout_residual))
 gain=Fraction(1)
 for b in bounds:gain=1+b*gain
 raw=ceil(mp.iv.sqrt(base.iv(r2*(1+ev*gain))))
 rows=[];pending=[]
 for i,v in enumerate(approximate):
  center=Fraction(int(v),outden);lo=center-error;hi=center+error
  change=base.clipped_change(lo,hi,raw);passed=change<=Fraction(1,16)
  rows.append(dict(test_index=i,clean_output_lower=rr(lo),clean_output_upper=rr(hi),raw_change_upper=rr(raw),clipped_change_upper=rr(change),certified=passed,method='exact fixed-point clean enclosure plus exact global noise bound'))
  if not passed:pending.append(i)
 return rows,pending,dict(state_denominator=QH,weight_denominator=QW,table_coordinate_error_upper=rr(tanherror),layers=layers,readout_residual_l1_upper=rr(readout_residual),clean_output_uniform_error_upper=rr(error),global_raw_noise_change_upper=rr(raw),elapsed_seconds=time.monotonic()-start)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--global-only',action='store_true');args=ap.parse_args()
 start=time.monotonic();mp.iv.dps=90;FOLDER.mkdir(exist_ok=True)
 model=next((EXP/'models').glob('105-*.npz'));saved=np.load(model);p=[saved[f'w{i}']for i in range(17)]
 record=json.loads(next((EXP/'records').glob('105-*.json')).read_text())
 _,_,_,x,y,original=train.dataset(record['config'],dtype=np.float64)
 assert x.shape==(10000,784)
 if (FOLDER/'inputs.npz').exists():
  archived=np.load(FOLDER/'inputs.npz')
  assert np.array_equal(archived['inputs'],x)
  assert np.array_equal(archived['labels'],y)
  assert np.array_equal(archived['original_indices'],original)
 else:np.savez_compressed(FOLDER/'inputs.npz',inputs=x,labels=y,original_indices=original)
 source=ROOT/'global-exact-verified-105.json';globalcert=json.loads(source.read_text())
 assert globalcert['model_sha256']==sha(model)
 bounds=[rat(v)for v in globalcert['operator_squared_upper_bounds_exact']]
 ev=256*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0));assert ev==rat(globalcert['readout_energy_exact'])
 r2=Fraction(1,1000**2)/(1+16*ev)
 rows,pending,details=global_clean_pass(p,x,bounds,ev,r2)
 output=dict(model=model.stem,model_sha256=sha(model),input_archive_sha256=sha(FOLDER/'inputs.npz'),
  c_exact=rr(Fraction(1,1000)),readout_energy_exact=rr(ev),noise_radius_squared_exact=rr(r2),
  inherited_exact_global_certificate=dict(path=source.name,sha256=sha(source)),
  input_count=10000,certified=sum(r['certified']for r in rows),all_heldout_inputs_certified=not pending,
  unresolved_test_indices=pending,rows=rows,global_clean_details=details,
  source_sha256=sha(Path(__file__)),elapsed_seconds=time.monotonic()-start,
  scope='Exactly all10,000 official held-out MNIST images, with the original float32 feature map and every allowed simultaneous internal/output disturbance at c=.001. This is not a global image-domain certificate.',
  qualification='Exact guarded integer matrix products, rigorously bounded quantization/table errors, previously exact spectral bounds, and outward interval square roots. No trusted floating BLAS or libm output; not Lean.')
 (FOLDER/'global-component.json').write_text(json.dumps(output,indent=2)+'\n')
 print('GLOBAL-FINAL',output['certified'],'pending',pending,'cleanerror',float(rat(details['clean_output_uniform_error_upper'])),'seconds',time.monotonic()-start,flush=True)
if __name__=='__main__':main()
