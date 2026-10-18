#!/usr/bin/env python3
"""Exact shared reachable tubes over a finite partition of all Boolean inputs.

The partition is only a proof-search choice. Every clean preactivation interval
in a group enters its common derivative upper bound; all512 vertices must pass.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,sys,json,time,hashlib,pickle
from fractions import Fraction
from pathlib import Path
import numpy as np,mpmath as mp
import exact_boolean_cube as base
import verify_reachable_tube as point
from fast_exact_svd_bound import operator_square_upper as fast_norm
from exact_svd_bound import dyadic_integer_matrix,rational_record
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment'
point.operator_square_upper=fast_norm

def shared_tube(p,ids,history,r2,ev,folder,bounds,cols):
 N=len(p[-1]);q=Fraction(1);layers=[]
 for s,w in enumerate(p[1:-1],1):
  al,ah,den=history[s];state=mp.iv.sqrt(base.iv(N*r2*q));ds=[]
  for j in range(N):
   distance=min((Fraction(0)if int(al[i,j])<=0<=int(ah[i,j]) else min(abs(Fraction(int(al[i,j]),den)),abs(Fraction(int(ah[i,j]),den))))for i in ids)
   near=max(Fraction(0),base.endpoint_fraction(base.iv(distance)-state*mp.iv.sqrt(base.iv(cols[s-1][j])),False));e=mp.iv.exp(-2*base.iv(near))
   ds.append(min(Fraction(1),base.ceil_dyadic(4*e/(1+e)**2)))
  if all(d==1 for d in ds):g=bounds[s-1];method='global matrix norm, all derivative caps one'
  else:g=min(bounds[s-1],point.product_norm_bound(w,ds,folder,s));method='minimum of global norm and exact quantized-SVD tube norm'
  q=1+g*q;layers.append(dict(layer=s,operator_squared_upper=rational_record(g),prefix_gain_squared=rational_record(q),method=method))
 return base.ceil_dyadic(mp.iv.sqrt(base.iv(r2*(1+ev*q))),base.BITS),layers

def floating_partition(p,x,c,ev):
 h=np.c_[x,np.ones(len(x))];aa=[]
 for w in p[:-1]:a=h@w;aa.append(a);h=np.tanh(a)
 z=h@p[-1];N=len(p[-1]);H=len(p)-1;r=float(c)/(1+H*float(ev))**.5;norms=[np.linalg.norm(w,2)for w in p[1:-1]];cols=[np.linalg.norm(w,axis=0)for w in p[1:-1]]
 def bound(ids):
  q=1.
  for s,w in enumerate(p[1:-1],1):
   near=np.maximum(0,np.min(abs(aa[s][ids]),axis=0)-r*np.sqrt(N*q)*cols[s-1]);e=np.exp(-2*near);d=4*e/(1+e)**2
   g=min(norms[s-1],np.linalg.norm(w*d[None,:],2));q=1+g*g*q
  return r*np.sqrt(1+float(ev)*q)
 pending=[np.flatnonzero((x>0).sum(axis=1)==k).tolist()for k in range(10)];groups=[]
 while pending:
  ids=pending.pop(0);b=bound(ids);margin=float(np.min(abs(z[ids])))-.5
  if b<=.8*margin or len(ids)==1:groups.append(ids)
  else:mid=len(ids)//2;pending.extend([ids[:mid],ids[mid:]])
 return groups

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--index',type=int,default=504);ap.add_argument('--c',default='1/1000');ap.add_argument('--time-limit',type=float,default=2400);ap.add_argument('--reuse-clean-cache',action='store_true');args=ap.parse_args();start=time.monotonic()
 base.BITS=320;base.SCALE=2**320;mp.iv.dps=120;c=Fraction(args.c)
 model=next((EXP/'models').glob(f'{args.index:03d}-*.npz'));rec=json.loads(next((EXP/'records').glob(f'{args.index:03d}-*.json')).read_text());saved=np.load(model)
 if rec['config'].get('input_mode')!='enumerated_boolean':raise ValueError('Declared finite Boolean cohort only.')
 p=[saved[k]for k in sorted([k for k in saved.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]))];N=len(p[-1]);H=len(p)-1;d=p[0].shape[0]-1
 if d!=9:raise ValueError('Dimension must be9.')
 x=(2*((np.arange(512)[:,None]>>np.arange(9))&1)-1).astype(float);folder=ROOT/f'full-cube-partition-verified-{args.index:03d}-c{args.c.replace("/","_")}';folder.mkdir(exist_ok=True)
 bounds,q,ev=base.norm_data(p,folder);r2=c*c/(1+H*ev);raw_global=base.ceil_dyadic(mp.iv.sqrt(base.iv(r2*(1+ev*q))),base.BITS)
 cache=Path(f'/tmp/clean-cube-{args.index:03d}-320bit.pkl');modelhash=hashlib.sha256(model.read_bytes()).hexdigest()
 if args.reuse_clean_cache and cache.exists():
  oldhash,lo,hi,history=pickle.loads(cache.read_bytes());assert oldhash==modelhash
 else:
  lo,hi,history=base.forward_batch(p,x,True);cache.write_bytes(pickle.dumps((modelhash,lo,hi,history)))
 columns=[]
 for w in p[1:-1]:
  wi,dw=dyadic_integer_matrix(w);columns.append([Fraction(sum(int(t)*int(t)for t in wi[:,j]),dw*dw)for j in range(N)])
 proposed=floating_partition(p,x,c,ev);print('PARTITION',len(proposed),'group sizes',[len(i)for i in proposed],flush=True)
 rows=[dict(input_index=i,output_lower=rational_record(lo[i]),output_upper=rational_record(hi[i]),certified=False)for i in range(512)];groups=[];queue=proposed.copy()
 while queue and time.monotonic()-start<args.time_limit:
  ids=queue.pop(0);number=len(groups);sub=folder/f'group-{number:03d}';sub.mkdir(exist_ok=True)
  raw,layers=shared_tube(p,ids,history,r2,ev,sub,bounds,columns)
  changes=[base.clipped_change(lo[i],hi[i],raw)for i in ids];passed=all(v<=Fraction(1,16)for v in changes)
  groups.append(dict(group_id=number,input_indices=ids,raw_change_upper=rational_record(raw),all_group_vertices_certified=passed,layers=layers))
  for i,change in zip(ids,changes):
   if change<=Fraction(1,16):rows[i].update(certified=True,group_id=number,raw_change_upper=rational_record(raw),clipped_change_upper=rational_record(change))
  if not passed and len(ids)>1:
   failed=[i for i,change in zip(ids,changes)if change>Fraction(1,16)];mid=max(1,len(failed)//2);queue.extend([a for a in [failed[:mid],failed[mid:]]if a])
  print('GROUP',number,len(ids),'raw',float(raw),'pass',passed,'total',sum(v['certified']for v in rows),'seconds',time.monotonic()-start,flush=True)
  (folder/'partial.json').write_text(json.dumps(dict(rows=rows,groups=groups,remaining_groups=len(queue)),indent=2)+'\n')
 sys.path.insert(0,str(EXP));import train
 xt,yt,it,xte,yte,ite=train.dataset(rec['config'],dtype=np.float64);training=[];correct=0;targetrows=[]
 for xx,yy in zip(np.concatenate([xt,xte]),np.concatenate([yt,yte])):
  if not np.all((xx==-1)|(xx==1)):raise ValueError('Training/test input must be Boolean.')
  i=sum(int(v>0)*2**j for j,v in enumerate(xx));lower=lo[i]if yy>0 else -hi[i];entry=dict(input_index=i,label=int(yy),signed_output_lower=rational_record(lower),margin_above_half=lower>Fraction(1,2));targetrows.append(entry)
  if len(targetrows)<=len(xt):training.append(entry)
  if lower>0:correct+=1
 out=dict(model=model.stem,model_sha256=modelhash,dimension=9,width=N,hidden_depth=H,c_exact=rational_record(c),readout_energy_exact=rational_record(ev),noise_radius_squared_exact=rational_record(r2),global_raw_change_upper=rational_record(raw_global),global_raw_sufficient=raw_global<=Fraction(1,16),input_count=512,certified=sum(v['certified']for v in rows),all_boolean_inputs_certified=all(v['certified']for v in rows),all_training_margins_interval_verified=all(v['margin_above_half']for v in training),interval_verified_correct_vertices=correct,training_checks=training,target_checks=targetrows,rows=rows,groups=groups,remaining_groups=queue,dyadic_bits=base.BITS,interval_decimal_digits=mp.iv.dps,elapsed_seconds=time.monotonic()-start,scope='All512 Boolean vertices and every joint hidden/output disturbance at the stated radius; primary cap1/2,tolerance1/16.',qualification='Exact integer/rational matrix bounds and outward interval tanh; finite partition is only a proof-search device. A full-domain claim requires all_boolean_inputs_certified=true. Not Lean.')
 (folder/'certificate.json').write_text(json.dumps(out,indent=2)+'\n');print('FINAL',out['certified'],out['all_boolean_inputs_certified'],out['all_training_margins_interval_verified'],'correct',correct,flush=True)
if __name__=='__main__':main()
