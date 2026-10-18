#!/usr/bin/env python3
"""Rebuild the parity supplement and public gates after a successful main rebuild."""
from pathlib import Path
import argparse,json,os,shutil,subprocess,sys
from datetime import datetime,timezone
from rebuild_main import MAINS,digest,write_json,project_closure,package_state,package_artifacts,run_logged

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--project',type=Path,default=Path(__file__).resolve().parents[2])
p.add_argument('--destination',type=Path,required=True)
p.add_argument('--toolchain-bin',type=Path)
p.add_argument('--cpu-list',help='Optional Linux taskset CPU list')
a=p.parse_args(); source=a.project.resolve(); destination=a.destination.resolve()
evidence=destination/'verification'
main=json.loads((evidence/'result.json').read_text())
if main['status']!='PASS': raise SystemExit('The independent main gate must pass first.')
if {t[0] for t in main['targets']} != {t[0] for t in MAINS.values()}:
 raise SystemExit('Run rebuild_main.py --main all before the aggregate supplement check.')
core=json.loads((evidence/'source-before.json').read_text())
for path,sha in core.items():
 if digest(source/path)!=sha or digest(destination/path)!=sha:
  raise SystemExit('A checked main source changed: '+path)
closure=project_closure(source,['NeuralGeneralization.SubcriticalCircuitCorollary'])
extras=[str(q) for q in closure if str(q) not in core]
for path in extras:
 artifact=destination/'.lake/build/lib/lean'/Path(path).with_suffix('.olean')
 if artifact.exists(): raise SystemExit('Supplement object already exists: '+str(artifact))
controls=['NeuralGeneralization.lean','Audit.lean','CheckMain.lean','CheckParity.lean','CheckRobust.lean']
paths=sorted(set(core)|set(extras)|set(controls))
before={q:digest(source/q) for q in paths}
for path in extras+controls:
 target=destination/path; target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source/path,target)
if any(digest(destination/q)!=sha for q,sha in before.items()):
 raise SystemExit('Snapshot source mismatch')
write_json(evidence/'supplement-source-before.json',before)
manifest=json.loads((source/'lake-manifest.json').read_text())
deps_before=package_state(source,manifest)
packages=destination/manifest.get('packagesDir','.lake/packages')
external_before=package_artifacts(packages)
write_json(evidence/'supplement-external-before.json',external_before)
env=dict(os.environ);env.pop('LEAN_PATH',None)
if a.toolchain_bin:env['PATH']=str(a.toolchain_bin.resolve())+os.pathsep+env.get('PATH','')
lake=shutil.which('lake',path=env['PATH'])
if not lake:raise SystemExit('Lake unavailable')
lean=shutil.which('lean',path=env['PATH'])
if not lean or digest(Path(lean).resolve())!=main['lean_executable_sha256'] or digest(Path(lake).resolve())!=main['lake_executable_sha256']:
 raise SystemExit('Use the same Lean and Lake executables as the main rebuild')
prefix=['taskset','-c',a.cpu_list] if a.cpu_list else []
summary={'status':'IN_PROGRESS','started_utc':datetime.now(timezone.utc).isoformat(),
 'additional_modules':extras,'source_count':len(paths),'project_object_cache_reused_for_new_modules':False,
 'main_result_sha256':digest(evidence/'result.json'),'verifier_sha256':digest(Path(__file__).resolve())}
write_json(evidence/'supplement-result.json',summary)
commands=[('supplement-build.log',[*prefix,lake,'--no-cache','build','NeuralGeneralization']),
 ('aggregate-audit.log',[*prefix,lake,'env','lean','-j1','Audit.lean']),
 ('main-gate.log',[*prefix,lake,'env','lean','-j1','CheckMain.lean']),
 ('parity-gate.log',[*prefix,lake,'env','lean','-j1','CheckParity.lean']),
 ('robust-gate.log',[*prefix,lake,'env','lean','-j1','CheckRobust.lean'])]
codes={}
for log,command in commands:
 print('Running '+log,flush=True)
 codes[log]=run_logged(command,destination,env,evidence/log)
 if codes[log]!=0:break
after={q:digest(source/q) for q in paths}
snapshot_after={q:digest(destination/q) for q in paths}
write_json(evidence/'supplement-source-after.json',after)
write_json(evidence/'supplement-snapshot-after.json',snapshot_after)
external_after=package_artifacts(packages)
write_json(evidence/'supplement-external-after.json',external_after)
unchanged=(before==after==snapshot_after and deps_before==package_state(source,manifest)
 and all(external_after.get(q)==sha for q,sha in external_before.items()))
passed=len(codes)==len(commands) and all(c==0 for c in codes.values()) and unchanged
summary.update(status='PASS' if passed else 'FAIL',exit_codes=codes,
 source_and_dependency_state_unchanged=unchanged,completed_utc=datetime.now(timezone.utc).isoformat())
write_json(evidence/'supplement-result.json',summary)
print(summary['status']+': '+str(evidence/'supplement-result.json'),flush=True)
if not passed:sys.exit(1)
