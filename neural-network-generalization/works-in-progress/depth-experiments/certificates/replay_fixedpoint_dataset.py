#!/usr/bin/env python3
"""Reproduce saved fixed-point proofs using archived inputs, without downloads."""
import argparse,json,tempfile,time
from pathlib import Path
from fractions import Fraction
import numpy as np,mpmath as mp
import exact_heldout_105 as verifier
ROOT=Path(__file__).resolve().parent
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--split',choices=['training','test'],required=True);ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();started=time.monotonic();mp.iv.dps=90
 folder=ROOT/('all-training-verified-105'if args.split=='training'else'all-heldout-verified-105-c1_1000')
 certificate=folder/('certificate.json'if args.split=='training'else'global-component.json');old=json.loads(certificate.read_text())
 inputs=np.load(folder/'inputs.npz');x=inputs['inputs'];y=inputs['labels']
 model=next((ROOT.parent/'experiment/models').glob('105-*.npz'));saved=np.load(model);p=[saved[f'w{i}']for i in range(17)]
 assert old['model_sha256']==verifier.sha(model)and old['input_archive_sha256']==verifier.sha(folder/'inputs.npz')
 normpath=ROOT/'global-exact-verified-105.json';norm=json.loads(normpath.read_text());assert norm['model_sha256']==verifier.sha(model)
 assert old['inherited_exact_global_certificate']['sha256']==verifier.sha(normpath)
 bounds=[verifier.rat(v)for v in norm['operator_squared_upper_bounds_exact']];ev=verifier.rat(norm['readout_energy_exact']);r2=Fraction(1,1000**2)/(1+16*ev)
 with tempfile.TemporaryDirectory(prefix='fixedpoint-dataset-replay-')as temporary:
  verifier.FOLDER=Path(temporary)
  rows,pending,details=verifier.global_clean_pass(p,x,bounds,ev,r2)
  if args.split=='test':assert rows==old['rows'];assert pending==old['unresolved_test_indices']
  else:
   assert len(rows)==60000 and np.array_equal(inputs['original_indices'],np.arange(60000))
   for row,previous,label in zip(rows,old['training_checks'],y):
    assert row['clean_output_lower']==previous['clean_output_lower']and row['clean_output_upper']==previous['clean_output_upper']
    signed=verifier.rat(row['clean_output_lower'])if label>0 else-verifier.rat(row['clean_output_upper'])
    assert verifier.rr(signed)==previous['signed_output_lower']and previous['label']==int(label)
    assert previous['margin_above_half']==(signed>Fraction(1,2))
    assert row['certified']==previous['stability_certified']and row['clipped_change_upper']==previous['clipped_change_upper']
   assert pending==old['unresolved_training_stability_indices']
  for key in details:
   if key!='elapsed_seconds':assert details[key]==old['global_clean_details'][key],key
 result=dict(status='PASS',split=args.split,input_count=len(rows),all_exact_rows_match=True,certificate_sha256=verifier.sha(certificate),model_sha256=verifier.sha(model),input_archive_sha256=verifier.sha(folder/'inputs.npz'),source_hashes={p.name:verifier.sha(p)for p in [Path(__file__),ROOT/'exact_heldout_105.py']},elapsed_seconds=time.monotonic()-started,scope='Read-only replay from archived inputs; all computations and temporary proof artifacts use a separate temporary directory.')
 args.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
if __name__=='__main__':main()
