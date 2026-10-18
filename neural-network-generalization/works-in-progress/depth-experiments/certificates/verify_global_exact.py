#!/usr/bin/env python3
"""All-input finite-noise certificates from exact rational spectral bounds."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,json,time,hashlib,sys
sys.set_int_max_str_digits(0)
from pathlib import Path
from fractions import Fraction
import numpy as np
from exact_svd_bound import operator_square_upper,rational_record
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment'

def one(index,c,replay=False):
 path=next((EXP/'models').glob(f'{index:03d}-*.npz'));saved=np.load(path)
 keys=sorted([k for k in saved.files if k.startswith('w') and k[1:].isdigit()],key=lambda k:int(k[1:]));p=[saved[k].astype(float)for k in keys]
 start=time.monotonic();N=len(p[-1]);H=len(p)-1;bounds=[];layers=[]
 for layer,w in enumerate(p[1:-1],1):
  cache=ROOT/'exact-global-factors'/f'{path.stem}-w{layer}.json';cache.parent.mkdir(exist_ok=True)
  factor=cache.with_suffix('.npz')
  if cache.exists() and not replay:
   rec=json.loads(cache.read_text());g=Fraction(int(rec['operator_squared_upper']['numerator']),int(rec['operator_squared_upper']['denominator']))
  else:
   g,rec=operator_square_upper(w,factor_path=factor,existing_factor_path=factor if factor.exists() else None)
   rec['matrix_sha256']=hashlib.sha256(w.tobytes()).hexdigest();cache.write_text(json.dumps(rec,indent=2)+'\n')
  assert rec['matrix_sha256']==hashlib.sha256(w.tobytes()).hexdigest()
  bounds.append(g);layers.append(rec)
  print('layer',index,layer,float(g),flush=True)
 ev=N*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0))
 suffix=Fraction(1);total=Fraction(1)
 for g in reversed(bounds):suffix*=g;total+=suffix
 ratio=256*c*c*(1+ev*total)/(1+H*ev)
 out=dict(model=path.stem,model_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),hidden_depth=H,width=N,c=float(c),c_exact=rational_record(c),operator_squared_upper_bounds_exact=[rational_record(g)for g in bounds],layer_certificates=layers,readout_energy_exact=rational_record(ev),squared_fraction_of_allowed_output_change_exact=rational_record(ratio),exact_final_inequality_pass=bool(ratio<=1),all_internal_operator_norms_at_most_one=bool(all(g<=1 for g in bounds)),certified_raw_output_change_approx=float(ratio)**.5/16,scope='Every real input and every simultaneous hidden/output disturbance at normalized radius c/sqrt(1+H Ev); raw-output bound implies either clipped-score condition.',method='Exact dyadic Gram/residual arithmetic with saved approximate SVD factors; exact rational Young and final gain inequalities.',qualification='Exact Python integer-rational norm certificate, no trusted floating SVD and no interval numerical norm assumptions; mathematical inequalities not Lean-formalized.',elapsed_seconds=time.monotonic()-start)
 target=ROOT/f'global-exact-verified-{index:03d}.json';target.write_text(json.dumps(out,indent=2)+'\n');print('FINAL',index,out['exact_final_inequality_pass'],out['certified_raw_output_change_approx'],flush=True)
 return out

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--indices',required=True);ap.add_argument('--c',default='.003');ap.add_argument('--replay',action='store_true',help='Recompute exact norm bounds from saved factors without rerunning SVD.');args=ap.parse_args()
 for index in map(int,args.indices.split(',')):one(index,Fraction(args.c),replay=args.replay)
if __name__=='__main__':main()
