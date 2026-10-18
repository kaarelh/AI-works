#!/usr/bin/env python3
"""Exact dyadic/interval full-cube verification; numerical proposals are never trusted.

Batched integer interval propagation encloses all clean trajectories. Tanh is
outward interval evaluated and endpoints rounded outward to a fixed dyadic grid.
Then global spectral noise enclosures, or reachable local tubes, certify scores.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,json,time,hashlib,sys
sys.set_int_max_str_digits(0)
from pathlib import Path
from fractions import Fraction
import numpy as np
import mpmath as mp
from exact_svd_bound import dyadic_integer_matrix,rational_record,operator_square_upper
from verify_reachable_tube import iv,endpoint_fraction,ceil_dyadic,product_norm_bound
from verify_witness import tanh_iv
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment'
BITS=160;SCALE=2**BITS

def scaled_endpoint(v,upper):
 sign,man,exponent,bc=v._mpi_[int(upper)];n=(-1 if sign else 1)*int(man);e=int(exponent)+BITS
 if e>=0:return n*(2**e)
 den=2**(-e)
 return -((-n)//den) if upper else n//den

def bounds_iv(lo,hi,den):
 a=mp.iv.mpf(int(lo))/mp.iv.mpf(int(den));b=mp.iv.mpf(int(hi))/mp.iv.mpf(int(den))
 return mp.iv.mpf([a.a,b.b])

def forward_batch(p,x,save_hidden=False):
 if not np.all((x==-1)|(x==1)):raise ValueError("Exact Boolean inputs required; no rounding of continuous inputs is allowed.")
 lo=np.array(np.rint(np.c_[x,np.ones(len(x))]).astype(np.int64),dtype=object)*SCALE;hi=lo.copy();history=[]
 for layer,w in enumerate(p[:-1]):
  wi,dw=dyadic_integer_matrix(w);pos=np.maximum(wi,0);neg=np.minimum(wi,0)
  al=lo@pos+hi@neg;ah=hi@pos+lo@neg;den=SCALE*dw
  if save_hidden:history.append((al,ah,den))
  nl=np.empty(al.shape,dtype=object);nh=np.empty(al.shape,dtype=object)
  for i in range(al.shape[0]):
   for j in range(al.shape[1]):
    out=tanh_iv(bounds_iv(al[i,j],ah[i,j],den));nl[i,j]=scaled_endpoint(out,False);nh[i,j]=scaled_endpoint(out,True)
  lo,hi=nl,nh
  print('clean-layer',layer,'vertices',len(x),'maxwidth',float(max(int(b)-int(a)for a,b in zip(lo.flat,hi.flat))/SCALE),flush=True)
 vi,dv=dyadic_integer_matrix(p[-1]);vp=np.maximum(vi,0);vn=np.minimum(vi,0)
 ol=lo@vp+hi@vn;oh=hi@vp+lo@vn;den=SCALE*dv
 return [Fraction(int(a),den)for a in ol],[Fraction(int(a),den)for a in oh],history

def clipped_change(lo,hi,r,cap=Fraction(1,2)):
 clip=lambda v:max(-cap,min(cap,v))
 return max(clip(hi+r)-clip(lo),clip(hi)-clip(lo-r))

def norm_data(p,folder):
 bounds=[];N=len(p[-1]);H=len(p)-1
 for s,w in enumerate(p[1:-1],1):
  path=folder/f'global-w{s}-factors.npz';g,record=operator_square_upper(w,factor_path=path,existing_factor_path=path if path.exists() else None)
  (folder/f'global-w{s}.json').write_text(json.dumps(record,indent=2)+'\n');bounds.append(g)
 q=Fraction(1)
 for g in bounds:q=1+g*q
 ev=N*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0))
 return bounds,q,ev

def local_tube(p,index,history,r2,ev,folder,global_bounds,column_norms):
 N=len(p[-1]);q=Fraction(1);layers=[]
 for s,w in enumerate(p[1:-1],1):
  al,ah,den=history[s];state=mp.iv.sqrt(iv(N*r2*q));d=[]
  for j in range(N):
   col2=column_norms[s-1][j]
   b=state*mp.iv.sqrt(iv(col2));aa=Fraction(int(al[index,j]),den);bb=Fraction(int(ah[index,j]),den)
   distance=Fraction(0)if aa<=0<=bb else min(abs(aa),abs(bb))
   near=max(Fraction(0),endpoint_fraction(iv(distance)-b,False));e=mp.iv.exp(-2*iv(near))
   d.append(min(Fraction(1),ceil_dyadic(4*e/(1+e)**2)))
  if all(dd==1 for dd in d):ell=global_bounds[s-1]
  else:ell=min(global_bounds[s-1],product_norm_bound(w,d,folder,s))
  q=1+ell*q
  layers.append({'layer':s,'operator_squared_upper':rational_record(ell),'prefix_gain_squared':rational_record(q)})
 return ceil_dyadic(mp.iv.sqrt(iv(r2*(1+ev*q))),BITS),layers

def main():
 global BITS,SCALE
 ap=argparse.ArgumentParser();ap.add_argument('--index',type=int,required=True);ap.add_argument('--c',required=True);ap.add_argument('--time-limit',type=float,default=1800);ap.add_argument('--only-global',action='store_true');args=ap.parse_args()
 mp.iv.dps=90;start=time.monotonic();c=Fraction(args.c)
 model=next((EXP/'models').glob(f'{args.index:03d}-*.npz'));record=json.loads(next((EXP/'records').glob(f'{args.index:03d}-*.json')).read_text());saved=np.load(model)
 keys=sorted([k for k in saved.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]));p=[saved[k]for k in keys];H=len(p)-1;N=len(p[-1]);d=p[0].shape[0]-1
 if H>=32:BITS=320;SCALE=2**BITS;mp.iv.dps=120
 if d!=9 or record['config'].get('input_mode')!='enumerated_boolean':raise ValueError('This predeclared verifier is for the d=9 exhaustive Boolean cohort.')
 x=(2*((np.arange(2**d)[:,None]>>np.arange(d))&1)-1).astype(float)
 folder=ROOT/f'full-cube-verified-{args.index:03d}-c{args.c.replace("/","_")}';folder.mkdir(exist_ok=True)
 bounds,q,ev=norm_data(p,folder);r2=c*c/(1+H*ev);global_r=ceil_dyadic(mp.iv.sqrt(iv(r2*(1+ev*q))),BITS)
 lo,hi,history=forward_batch(p,x,save_hidden=True)
 column_norms=[]
 for w in p[1:-1]:
  wi,dw=dyadic_integer_matrix(w);column_norms.append([Fraction(sum(int(t)*int(t)for t in wi[:,j]),dw*dw)for j in range(N)])
 rows=[];pending=[]
 for i in range(len(x)):
  change=clipped_change(lo[i],hi[i],global_r);cert=change<=Fraction(1,16)
  rows.append(dict(input_index=i,output_lower=rational_record(lo[i]),output_upper=rational_record(hi[i]),method='global raw noise bound plus exact clean output clipping',raw_change_upper=rational_record(global_r),clipped_change_upper=rational_record(change),certified=cert))
  if not cert:pending.append(i)
 print('GLOBAL-CLIP',len(x)-len(pending),'/',len(x),'raw-bound',float(global_r),flush=True)
 # Training convention is determined by the same saved predeclared dataset helper.
 import sys
 sys.path.insert(0,str(EXP));import train
 xt,yt,it,xte,yte,ite=train.dataset(record['config'],dtype=np.float64)
 if not np.all((xt==-1)|(xt==1)):raise ValueError('Saved training domain must be Boolean.')
 training_checks=[]
 for xx,yy in zip(xt,yt):
  idx=sum(int(v>0)*(2**j)for j,v in enumerate(xx));lower=lo[idx]if yy>0 else -hi[idx]
  training_checks.append(dict(input_index=idx,label=int(yy),signed_output_lower=rational_record(lower),margin_above_half=lower>Fraction(1,2)))
 for i in pending:
  if args.only_global or time.monotonic()-start>args.time_limit:break
  sub=folder/f'input-{i:03d}';sub.mkdir(exist_ok=True)
  raw,layers=local_tube(p,i,history,r2,ev,sub,bounds,column_norms);change=clipped_change(lo[i],hi[i],raw)
  if change< Fraction(int(rows[i]['clipped_change_upper']['numerator']),int(rows[i]['clipped_change_upper']['denominator'])):
   rows[i].update(method='exact reachable Lipschitz tube with interval clean trajectory',raw_change_upper=rational_record(raw),clipped_change_upper=rational_record(change),certified=change<=Fraction(1,16),layers=layers)
  print('LOCAL',i,rows[i]['certified'],'raw',float(raw),'clip',float(change),flush=True)
  (folder/'partial.json').write_text(json.dumps(dict(rows=rows,elapsed_seconds=time.monotonic()-start),indent=2)+'\n')
 out=dict(model=model.stem,model_sha256=hashlib.sha256(model.read_bytes()).hexdigest(),dyadic_bits=BITS,interval_decimal_digits=mp.iv.dps,c_exact=rational_record(c),dimension=d,width=N,hidden_depth=H,readout_energy_exact=rational_record(ev),noise_radius_squared_exact=rational_record(r2),global_raw_change_upper=rational_record(global_r),global_raw_sufficient=global_r<=Fraction(1,16),input_count=len(x),certified=sum(row['certified']for row in rows),all_boolean_inputs_certified=all(row['certified']for row in rows),all_training_margins_interval_verified=all(row['margin_above_half']for row in training_checks),training_checks=training_checks,rows=rows,elapsed_seconds=time.monotonic()-start,scope='Every one of the 512 Boolean vertices, with every simultaneous hidden/output disturbance in the stated radius; clip cap1/2 and tolerance1/16.',qualification='Exact Python integer/rational matrix arithmetic and outward mpmath intervals, not Lean. Global conclusion holds only when all_boolean_inputs_certified is true.')
 (folder/'certificate.json').write_text(json.dumps(out,indent=2)+'\n');print('FINAL',out['certified'],out['all_boolean_inputs_certified'],out['all_training_margins_interval_verified'],flush=True)
if __name__=='__main__':main()
