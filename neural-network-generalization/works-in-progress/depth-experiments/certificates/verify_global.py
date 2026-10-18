#!/usr/bin/env python3
"""Selected ALL-REAL-INPUT certificates for actual MNIST-trained models."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys,json,time
from pathlib import Path
from fractions import Fraction
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment'
from interval_norm_bound import operator_square_upper,rational_record


def main():
 for index,c in [(0,Fraction(1,100)),(2,Fraction(1,1000)),(3,Fraction(1,1000)),
                 (4,Fraction(1,1000)),(5,Fraction(1,1000)),(28,Fraction(1,1000)),
                 (29,Fraction(1,1000))]:
  target=ROOT/f'global-verified-{index:03d}.json'
  if target.exists():continue
  start=time.monotonic();path=next((EXP/'models').glob(f'{index:03d}-*.npz'));saved=np.load(path)
  keys=sorted([k for k in saved.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]));p=[saved[k].astype(float)for k in keys]
  N=len(p[-1]);H=len(p)-1;bounds=[];pivots=[]
  for w in p[1:-1]:
   g,pivot=operator_square_upper(w);bounds.append(g);pivots.append(pivot)
  ev=N*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0))
  suffix=Fraction(1);total=Fraction(1)
  for g in reversed(bounds):suffix*=g;total+=suffix
  ratio=256*c*c*(1+ev*total)/(1+H*ev)
  assert ratio<1
  out=dict(model=path.stem,hidden_depth=H,width=N,c=float(c),c_exact=rational_record(c),
   operator_squared_upper_bounds_exact=[rational_record(g)for g in bounds],smallest_interval_LDL_pivots=pivots,
   readout_energy_exact=rational_record(ev),squared_fraction_of_allowed_output_change_exact=rational_record(ratio),
   exact_final_inequality_pass=True,certified_raw_output_change_approx=float(ratio)**.5/16,
   scope='Every real input and every simultaneous hidden/output disturbance in radiusc/sqrt(1+H Ev). Therefore both clipped-score conventions satisfy the condition globally.',
   method='Exact dyadic Gram entries;90decimal interval LDL verifies each operator upper bound; exact rational final inequality.',
   qualification='Trusts mpmath interval arithmetic, not Lean. Raw saved trained weights, no rescaling.',elapsed_seconds=time.monotonic()-start)
  target.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:out[k]for k in ['model','c','certified_raw_output_change_approx','elapsed_seconds']}),flush=True)

if __name__=='__main__':main()
