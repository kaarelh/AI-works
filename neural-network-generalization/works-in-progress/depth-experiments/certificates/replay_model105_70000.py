#!/usr/bin/env python3
"""Single read-only replay entry for the complete70,000-image model105 claim.

All generated tables, local proofs and replay logs go into temporary folders.
Canonical model, data, table, factor and certificate files are hash-checked.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,json,subprocess,sys,tempfile,shutil,time
from pathlib import Path
from fractions import Fraction
import numpy as np
import exact_heldout_105 as fixed
from exact_svd_bound import operator_square_upper
ROOT=Path(__file__).resolve().parent
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);ap.add_argument('--check-artifacts-only',action='store_true');args=ap.parse_args();start=time.monotonic()
 test=ROOT/'all-heldout-verified-105-c1_1000';train=ROOT/'all-training-verified-105';model=next((ROOT.parent/'experiment/models').glob('105-*.npz'))
 normfile=ROOT/'global-exact-verified-105.json';norm=json.loads(normfile.read_text());tc=json.loads((test/'certificate.json').read_text());tr=json.loads((train/'certificate.json').read_text())
 assert norm['model_sha256']==tc['model_sha256']==tr['model_sha256']==fixed.sha(model)
 for folder,cert in [(test,tc),(train,tr)]:assert cert['input_archive_sha256']==fixed.sha(folder/'inputs.npz')
 for rec in tc['component_certificates']:assert rec['sha256']==fixed.sha(test/rec['path'])
 for name,digest in tc['source_hashes'].items():assert digest==fixed.sha(ROOT/name)
 for name,digest in tr['source_hashes'].items():assert digest==fixed.sha(ROOT/name)
 assert tc['all_heldout_inputs_certified']and tc['input_count']==10000
 assert tr['all_training_margins_verified']and tr['all_training_inputs_stable_at_c001']and tr['input_count']==60000
 global_factors=[ROOT/'exact-global-factors'/f'{model.stem}-w{s}.npz'for s in range(1,16)]
 tracked=[model,normfile]+global_factors+sorted(test.rglob('*'))+sorted(train.rglob('*'))
 tracked=[p for p in tracked if p.is_file()];before={str(p):fixed.sha(p)for p in tracked}
 details={}
 if not args.check_artifacts_only:
  saved=np.load(model)
  ev=256*sum((Fraction.from_float(float(v))**2 for v in saved['w16']),Fraction(0))
  assert ev==fixed.rat(norm['readout_energy_exact'])
  for s,wanted in enumerate(norm['operator_squared_upper_bounds_exact'],1):
   factor=ROOT/'exact-global-factors'/f'{model.stem}-w{s}.npz'
   got,_=operator_square_upper(saved[f'w{s}'],existing_factor_path=factor)
   assert got==fixed.rat(wanted)
   print('GLOBAL-NORM-REPLAY',s,flush=True)
  with tempfile.TemporaryDirectory(prefix='model105-70000-replay-')as directory:
   temporary=Path(directory)
   for split in ['test','training']:
    output=temporary/f'{split}.json'
    subprocess.run([sys.executable,str(ROOT/'replay_fixedpoint_dataset.py'),'--split',split,'--output',str(output)],check=True)
    details[split]=json.loads(output.read_text())
   import exact_heldout_105_local as local
   copied=temporary/'local';copied.mkdir()
   for name in ['global-component.json','inputs.npz']:shutil.copy2(test/name,copied/name)
   for source in test.glob('local-input-*'):shutil.copytree(source,copied/source.name)
   local.FOLDER=copied;local.main()
   replay=json.loads((copied/'local-component.json').read_text());original=json.loads((test/'local-component.json').read_text())
   assert replay['rows']==original['rows']and replay['all_local_inputs_certified']
   details['local_exact_rows_replayed']=len(replay['rows'])
 # Exact label comparisons use the saved independently bounded clean intervals.
 labels=np.load(test/'inputs.npz')['labels'];rows=json.loads((test/'global-component.json').read_text())['rows'];correct=wrong=ambiguous=0
 for row,label in zip(rows,labels):
  lo=fixed.rat(row['clean_output_lower']);hi=fixed.rat(row['clean_output_upper']);sl,sh=(lo,hi)if label>0 else(-hi,-lo)
  correct+=sl>0;wrong+=sh<0;ambiguous+=sl<=0<=sh
 assert (correct,wrong,ambiguous)==(9892,108,0)
 assert all(fixed.rat(row['signed_output_lower'])>Fraction(1,2)for row in tr['training_checks'])
 assert before=={str(p):fixed.sha(p)for p in tracked},'Canonical artifact mutation.'
 result=dict(status='PASS',mode='artifact checks only'if args.check_artifacts_only else'full exact recomputation',
  training_images=60000,test_images=10000,test_correct=int(correct),test_incorrect=int(wrong),test_ambiguous=int(ambiguous),
  canonical_artifact_hashes_unchanged=True,model_sha256=fixed.sha(model),source_sha256=fixed.sha(Path(__file__)),
  component_replays=details,elapsed_seconds=time.monotonic()-start)
 args.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
if __name__=='__main__':main()
