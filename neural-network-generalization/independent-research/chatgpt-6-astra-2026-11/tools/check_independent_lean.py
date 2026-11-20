"""Check selected independent lemmas and audit their axiom dependencies.

Requires a built copy of neural-network-generalization/lean at the recorded
repository revision. Use --lean-project and --lean outside the collection.
No imported repository file is changed by this script.
"""
import argparse, hashlib, json, os, re, shutil, subprocess, tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser()
ap.add_argument('--lean-project',type=Path,default=os.environ.get('LEAN_PROJECT'))
ap.add_argument('--lean',default=os.environ.get('LEAN') or shutil.which('lean'))
args=ap.parse_args()
project=args.lean_project or ROOT.parents[1]/'lean'
if not (project/'.lake/packages').is_dir():
    raise SystemExit('Pass --lean-project pointing to the built repository Lean project.')
if not args.lean:raise SystemExit('Install Lean from the repository toolchain or pass --lean.')
paths=[project/'.lake/build/lib/lean']+[p/'.lake/build/lib/lean' for p in
       (project/'.lake/packages').iterdir() if (p/'.lake/build/lib/lean').exists()]
result_dir=ROOT/'results';result_dir.mkdir(exist_ok=True)
records=[];logs=[];names=[]
with tempfile.TemporaryDirectory(prefix='independent-lean-') as temporary:
    env=os.environ.copy();env['LEAN_PATH']=':'.join(map(str,[Path(temporary),*paths]))
    sources=sorted((ROOT/'lean').glob('Independent*.lean'))
    for source in sources:
        cmd=[args.lean,'-o',str(Path(temporary)/(source.stem+'.olean')),str(source)]
        p=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
        logs.append(p.stdout);print(p.stdout,end='',flush=True)
        records.append(dict(file=source.name,sha256=hashlib.sha256(source.read_bytes()).hexdigest(),returncode=p.returncode))
        if p.returncode:
            (result_dir/'independent_transfer_lean.log').write_text(''.join(logs))
            raise SystemExit(p.returncode)
        names.extend(re.findall(r'^theorem\s+(\w+)',source.read_text(),re.M))
    audit=Path(temporary)/'AxiomAudit.lean'
    audit.write_text('\n'.join('import '+s.stem for s in sources)+'\n'+
                     '\n'.join('#print axioms IndependentResearch.'+name for name in names)+'\n')
    p=subprocess.run([args.lean,str(audit)],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
    logs.append(p.stdout);print(p.stdout,end='',flush=True)
    if p.returncode:raise SystemExit(p.returncode)
    admitted=bool(re.search(r'\b(sorryAx|admit)\b',p.stdout))
    assert not admitted,'Admitted axiom found in theorem dependencies'
    axiom_names={name.strip() for block in re.findall(r'depends on axioms:\s*\[([^\]]*)\]',p.stdout)
                 for name in block.split(',') if name.strip()}
    allowed={'propext','Classical.choice','Quot.sound'}
    assert axiom_names<=allowed,('Unexpected axiom dependencies',sorted(axiom_names-allowed))
    (result_dir/'independent_transfer_lean.log').write_text(''.join(logs))
    result=dict(status='PASS',files=records,theorems=names,admitted_axioms=False,axiom_dependencies=sorted(axiom_names),
                qualification='Selected deterministic lemmas only; Bayesian conditioning and integral asymptotics are not formalized.',
                lean_version=subprocess.check_output([args.lean,'--version'],text=True).strip(),
                imported_project_revision=subprocess.check_output(['git','-C',str(project),'rev-parse','HEAD'],text=True).strip(),
                imported_source_hashes={str(p.relative_to(project)):hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [project/'NeuralGeneralization/OnlineLowerReluCoverageMinimumCoordinate.lean',
                              project/'NeuralGeneralization/OnlineLowerReluLipschitz.lean']},
                dependency_manifest_sha256=hashlib.sha256((project/'lake-manifest.json').read_bytes()).hexdigest())
    (result_dir/'independent_lean_verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(status='PASS',theorems=len(names))))
