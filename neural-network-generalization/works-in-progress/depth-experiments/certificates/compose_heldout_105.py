#!/usr/bin/env python3
"""Hash-checked exhaustive union of the global and twelve local test proofs."""
from pathlib import Path
from fractions import Fraction
import hashlib,json
import numpy as np
ROOT=Path(__file__).resolve().parent;FOLDER=ROOT/'all-heldout-verified-105-c1_1000'
def rat(v):return Fraction(int(v['numerator']),int(v['denominator']))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 gf=FOLDER/'global-component.json';lf=FOLDER/'local-component.json'
 a=json.loads(gf.read_text());b=json.loads(lf.read_text());nfile=ROOT/'global-exact-verified-105.json';norm=json.loads(nfile.read_text())
 model=next((ROOT.parent/'experiment/models').glob('105-*.npz'));inputfile=FOLDER/'inputs.npz'
 assert a['model_sha256']==b['model_sha256']==norm['model_sha256']==sha(model)
 assert a['input_archive_sha256']==b['input_archive_sha256']==sha(inputfile)
 assert a['inherited_exact_global_certificate']['sha256']==sha(nfile)
 assert a['c_exact']==b['c_exact'] and rat(a['c_exact'])==Fraction(1,1000)
 assert a['noise_radius_squared_exact']==b['noise_radius_squared_exact']
 for c,source in [(a,'exact_heldout_105.py'),(b,'exact_heldout_105_local.py')]:assert c['source_sha256']==sha(ROOT/source)
 inputs=np.load(inputfile);assert inputs['inputs'].shape==(10000,784)
 assert np.array_equal(inputs['original_indices'],np.arange(10000))
 assert len(a['rows'])==10000 and [r['test_index']for r in a['rows']]==list(range(10000))
 pending=[r['test_index']for r in a['rows']if not r['certified']]
 assert pending==a['unresolved_test_indices']
 local={r['test_index']:r for r in b['rows']}
 assert len(local)==len(b['rows'])==12 and sorted(local)==pending
 assert all(r['certified']and rat(r['clipped_change_upper'])<=Fraction(1,16)for r in local.values())
 maxima=[]
 for r in a['rows']:
  if r['certified']:assert rat(r['clipped_change_upper'])<=Fraction(1,16);maxima.append(rat(r['clipped_change_upper']))
  else:
   q=local[r['test_index']]
   assert rat(r['clean_output_lower'])<=rat(q['clean_output_upper']) and rat(q['clean_output_lower'])<=rat(r['clean_output_upper'])
   maxima.append(rat(q['clipped_change_upper']))
 result=dict(model=a['model'],model_sha256=sha(model),input_archive_sha256=sha(inputfile),c_exact=a['c_exact'],
  input_count=10000,certified=10000,all_heldout_inputs_certified=True,
  global_component_certified=9988,global_unresolved_indices_retained=pending,local_component_certified=12,
  maximum_certified_clipped_change_upper=dict(numerator=str(max(maxima).numerator),denominator=str(max(maxima).denominator)),
  maximum_certified_clipped_change_upper_approx=float(max(maxima)),
  component_certificates=[dict(path=p.name,sha256=sha(p))for p in [gf,lf]],
  source_hashes={p.name:sha(p)for p in [Path(__file__),ROOT/'exact_heldout_105.py',ROOT/'exact_heldout_105_local.py']},
  scope='Exactly all10,000 official MNIST test images under the original float32 normalization, every simultaneous hidden/output disturbance at c=.001, clip cap1/2 and tolerance1/16. Does not quantify over every possible image or prove distributional coverage.',
  qualification='Exact integer/rational and outward interval sufficient proofs, with explicit retained global unresolved cases covered by local proofs; not Lean.')
 (FOLDER/'certificate.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()
