#!/usr/bin/env python3
"""Complete the independently initialized, source-only two-phase proof rebuild."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
from datetime import datetime, timezone

project = Path('/workspace/robustness-lean')
destination = Path('/workspace/robustness-release-check')
verifier = Path('/workspace/nnbayes-public-release/neural-network-generalization/lean/review/verification/rebuild_main.py')
spec = importlib.util.spec_from_file_location('rebuild', verifier)
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)
evidence = destination/'verification'
assert (evidence/'phase-a-exit-code.txt').read_text().strip() == '0'
assert (evidence/'toolchain.json').exists()
targets = list(v.MAINS.values())
closure = v.project_closure(project, ['NeuralGeneralization'])
paths = sorted([*closure, *(Path(n) for n in v.CONFIGS),
                *(Path(n) for n in ('Audit.lean','CheckMain.lean','CheckParity.lean','CheckRobust.lean'))])
before = {str(p):v.digest(project/p) for p in paths}
phase_a = json.loads((evidence/'phase-a-sources.json').read_text())
refresh = {'added': [p for p in before if p not in phase_a],
           'changed': [p for p in before if p in phase_a and before[p] != phase_a[p]],
           'no_project_objects_copied': True}
v.write_json(evidence/'phase-b-source-refresh.json', refresh)
v.write_json(evidence/'source-before.json', before)
v.write_json(evidence/'project-import-closure.json', [str(p) for p in closure])
for p in paths:
    (destination/p).parent.mkdir(parents=True, exist_ok=True)
    if not (destination/p).exists() or v.digest(destination/p) != before[str(p)]:
        shutil.copy2(project/p, destination/p)
assert {str(p):v.digest(destination/p) for p in paths} == before
audit = destination/'ExactMainAudit.lean'
audit.write_text(v.audit_source(targets))
manifest = json.loads((project/'lake-manifest.json').read_text())
dependencies_before = json.loads((evidence/'dependencies-before.json').read_text())
assert v.package_state(project,manifest) == dependencies_before
artifact_before = json.loads((evidence/'external-artifacts-before.json').read_text())
env = dict(os.environ)
env.pop('LEAN_PATH',None)
env['PATH'] = '/workspace/lean-toolchains/lean-4.32.0-linux/bin:' + env.get('PATH','')
lake = shutil.which('lake',path=env['PATH'])
summary = {'status':'IN_PROGRESS','started_phase_b_utc':datetime.now(timezone.utc).isoformat(),
           'project_source_count':len(closure),'targets':targets,
           'project_object_cache_copied':False,
           'external_dependencies':'shared pinned package cache',
           'rebuild_mode':'two phases in one independently initialized source-only project; final sources refreshed before exact gates',
           'phase_a_build_exit_code':0,'verifier_sha256':v.digest(verifier),
           'phase_b_driver_sha256':v.digest(Path(__file__)),
           'exact_audit_sha256':v.digest(audit),
           'external_artifacts_before_count':len(artifact_before)}
v.write_json(evidence/'result.json',summary)
print(f'Building final aggregate from {len(closure)} project modules',flush=True)
build_code = v.run_logged([lake,'--no-cache','build','NeuralGeneralization'],destination,env,evidence/'phase-b-build.log')
checks = {}
if build_code == 0:
    for name in ['ExactMainAudit.lean','CheckMain.lean','CheckParity.lean','CheckRobust.lean','Audit.lean']:
        print(f'Checking {name}',flush=True)
        checks[name] = v.run_logged([lake,'env','lean','-j1',name],destination,env,evidence/(Path(name).stem+'.log'))
after = {str(p):v.digest(project/p) for p in paths}
snapshot = {str(p):v.digest(destination/p) for p in paths}
dependencies_after = v.package_state(project,manifest)
artifacts_after = v.package_artifacts(destination/manifest.get('packagesDir','.lake/packages'))
stable_artifacts = all(artifacts_after.get(p)==h for p,h in artifact_before.items())
stable_sources = before == after == snapshot
stable_dependencies = dependencies_before == dependencies_after
for name,data in [('source-after',after),('snapshot-after',snapshot),
                  ('dependencies-after',dependencies_after),('external-artifacts-after',artifacts_after)]:
    v.write_json(evidence/(name+'.json'),data)
passed = build_code==0 and len(checks)==5 and all(x==0 for x in checks.values()) and stable_artifacts and stable_sources and stable_dependencies
summary.update(status='PASS' if passed else 'FAIL',phase_b_build_exit_code=build_code,
               exact_and_aggregate_checks=checks,source_snapshot_unchanged=stable_sources,
               dependencies_unchanged=stable_dependencies,existing_external_artifacts_unchanged=stable_artifacts,
               external_artifacts_after_count=len(artifacts_after),
               completed_utc=datetime.now(timezone.utc).isoformat())
v.write_json(evidence/'result.json',summary)
print(json.dumps(summary,indent=2),flush=True)
sys.exit(0 if passed else 1)
