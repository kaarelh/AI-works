#!/usr/bin/env python3
"""Read-only independent replay of the saved hidden-only confident-input witness."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
from fractions import Fraction
import hashlib,json,time
import numpy as np
from verify_witness import verify

ROOT=Path(__file__).resolve().parent
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 started=time.monotonic()
 model=next((ROOT.parent/'experiment/models').glob('105-*.npz'))
 witness=ROOT/'confident-target-105.npz'
 previous=json.loads((ROOT/'confident-target-105.json').read_text())
 m=np.load(model);p=[m[f'w{i}'] for i in range(len([k for k in m.files if k.startswith('w')]))]
 w=np.load(witness);pixels=w['pixels'];eta=w['hidden_noise']
 assert pixels.dtype==np.uint8 and pixels.shape==(784,)
 assert float(w['output_noise'])==0
 xx=(pixels.astype(np.float32)/np.float32(127.5)-np.float32(1)).astype(np.float64)
 assert np.array_equal(xx,w['original_float32_input'])
 results={
  'ideal_rational_pixel_verification':verify(p,w['input'],eta,.001,0.,[Fraction(2*int(v)-255,255) for v in pixels]),
  'original_float32_feature_verification':verify(p,xx,eta,.001,0.)}
 for key,r in results.items():
  assert r['exact_rational_budget_pass'] and r['clipped']['0.5']['violation']
  assert r['optional_one_sided_gap']['violations']==[dict(label=1,case='clean signed output at least1/2 but noisy below7/16')]
  assert r['hidden_state_diagnostics']['interval_verified_all_disturbed_hidden_states_inside_unit_box']
  assert r==previous[key],key
 output=dict(independent_replay_pass=True,model_sha256=digest(model),witness_sha256=digest(witness),
  source_hashes={n:digest(ROOT/n) for n in ['replay_confident_target.py','verify_witness.py']},
  output_noise_exactly_zero=True,results=results,elapsed_seconds=time.monotonic()-started,
  scope='Read-only saved-witness replay; no search, optimization, training, or original-artifact mutation.')
 (ROOT/'confident-target-105-independent-replay.json').write_text(json.dumps(output,indent=2)+'\n')
 print(json.dumps(dict(pass_=True,seconds=output['elapsed_seconds'])),flush=True)
if __name__=='__main__':main()
