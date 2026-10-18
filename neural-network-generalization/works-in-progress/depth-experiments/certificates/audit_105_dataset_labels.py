#!/usr/bin/env python3
"""Exact label comparisons from the already certified complete-dataset outputs."""
import json,hashlib
from pathlib import Path
from fractions import Fraction
import numpy as np
ROOT=Path(__file__).resolve().parent
def f(v):return Fraction(int(v['numerator']),int(v['denominator']))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 test=ROOT/'all-heldout-verified-105-c1_1000';globalfile=test/'global-component.json';a=json.loads(globalfile.read_text());archive=test/'inputs.npz';data=np.load(archive)
 assert sha(archive)==a['input_archive_sha256']and np.array_equal(data['original_indices'],np.arange(10000))
 correct=incorrect=ambiguous=0;wrong=[]
 for row,label in zip(a['rows'],data['labels']):
  assert label in [-1,1]
  lo=f(row['clean_output_lower']);hi=f(row['clean_output_upper']);sl,sh=(lo,hi)if label>0 else(-hi,-lo)
  if sl>0:correct+=1
  elif sh<0:incorrect+=1;wrong.append(row['test_index'])
  else:ambiguous+=1
 training=ROOT/'all-training-verified-105';certificate=training/'certificate.json';b=json.loads(certificate.read_text());trainarchive=training/'inputs.npz';td=np.load(trainarchive)
 assert sha(trainarchive)==b['input_archive_sha256']and a['model_sha256']==b['model_sha256']
 assert np.array_equal(td['original_indices'],np.arange(60000))and len(b['training_checks'])==60000
 minimum=None
 for i,(row,label)in enumerate(zip(b['training_checks'],td['labels'])):
  assert row['training_index']==i and row['label']==label and label in [-1,1]
  signed=f(row['clean_output_lower'])if label>0 else-f(row['clean_output_upper'])
  assert signed==f(row['signed_output_lower'])and signed>Fraction(1,2)
  minimum=signed if minimum is None else min(minimum,signed)
 assert minimum==f(b['minimum_signed_output_lower'])
 out=dict(model_sha256=a['model_sha256'],test_correct=correct,test_incorrect=incorrect,test_ambiguous=ambiguous,test_count=10000,wrong_test_indices=wrong,
  all_60000_training_margins_verified=True,minimum_training_signed_output_lower_approx=float(minimum),
  source_sha256=sha(Path(__file__)),component_hashes={str(p.relative_to(ROOT)):sha(p)for p in [globalfile,certificate,archive,trainarchive]},
  method='Exact Fraction sign/margin comparisons against every archived official parity label, using already verified rational clean-output enclosures.')
 (ROOT/'model105-exact-dataset-label-audit.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:v for k,v in out.items()if k!='wrong_test_indices'}))
if __name__=='__main__':main()
