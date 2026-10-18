#!/usr/bin/env python3
"""Verify all60,000 training margins using the audited exact fixed-point pass."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import json,time,hashlib
from pathlib import Path
from fractions import Fraction
import numpy as np,mpmath as mp
import exact_heldout_105 as verifier
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';FOLDER=ROOT/'all-training-verified-105'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 start=time.monotonic();mp.iv.dps=90;FOLDER.mkdir(exist_ok=True);verifier.FOLDER=FOLDER
 model=next((EXP/'models').glob('105-*.npz'));saved=np.load(model);p=[saved[f'w{i}']for i in range(17)]
 record=json.loads(next((EXP/'records').glob('105-*.json')).read_text())
 x,y,original,_,_,_=verifier.train.dataset(record['config'],dtype=np.float64)
 assert x.shape==(60000,784)and np.array_equal(original,np.arange(60000))
 assert np.all(np.isin(y,[-1,1]))
 archive=FOLDER/'inputs.npz';np.savez_compressed(archive,inputs=x,labels=y,original_indices=original)
 normpath=ROOT/'global-exact-verified-105.json';norm=json.loads(normpath.read_text());assert norm['model_sha256']==sha(model)
 bounds=[verifier.rat(v)for v in norm['operator_squared_upper_bounds_exact']]
 ev=256*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0));assert ev==verifier.rat(norm['readout_energy_exact'])
 r2=Fraction(1,1000**2)/(1+16*ev)
 rows,pending,details=verifier.global_clean_pass(p,x,bounds,ev,r2)
 training=[];minimum=None
 for i,(row,label)in enumerate(zip(rows,y)):
  lo=verifier.rat(row['clean_output_lower']);hi=verifier.rat(row['clean_output_upper'])
  signed=lo if label>0 else-hi;minimum=signed if minimum is None else min(minimum,signed)
  training.append(dict(training_index=i,label=int(label),signed_output_lower=verifier.rr(signed),margin_above_half=signed>Fraction(1,2),
   clean_output_lower=row['clean_output_lower'],clean_output_upper=row['clean_output_upper'],stability_certified=row['certified'],clipped_change_upper=row['clipped_change_upper']))
 out=dict(model=model.stem,model_sha256=sha(model),input_archive_sha256=sha(archive),input_count=60000,
  all_training_margins_verified=all(v['margin_above_half']for v in training),minimum_signed_output_lower=verifier.rr(minimum),
  minimum_signed_output_lower_approx=float(minimum),all_training_inputs_stable_at_c001=not pending,
  unresolved_training_stability_indices=pending,training_checks=training,global_clean_details=details,
  inherited_exact_global_certificate=dict(path=normpath.name,sha256=sha(normpath)),
  source_hashes={q.name:sha(q)for q in [Path(__file__),ROOT/'exact_heldout_105.py']},elapsed_seconds=time.monotonic()-start,
  scope='All60,000 official MNIST training images and parity labels under the original float32 normalization; exact clean-margin likelihood eligibility. Stability statement, if true, is only at these same training inputs and c=.001.',
  qualification='Guarded exact integer/table computation with certified quantization errors and exact norm bounds; no trusted floating BLAS or libm accuracy, not Lean.')
 (FOLDER/'certificate.json').write_text(json.dumps(out,indent=2)+'\n')
 print('TRAINING-FINAL',out['all_training_margins_verified'],'minimum',float(minimum),'allstable',not pending,'seconds',time.monotonic()-start,flush=True)
if __name__=='__main__':main()
