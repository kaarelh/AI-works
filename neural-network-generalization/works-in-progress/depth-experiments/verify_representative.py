"""Independently recheck two complete public examples without external data."""
from pathlib import Path
import hashlib,json,os,shutil,subprocess,sys,tempfile

ROOT=Path(__file__).resolve().parent
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    with tempfile.TemporaryDirectory(prefix='depth-public-representative-') as temporary:
        dest=Path(temporary);cert=dest/'certificates';exp=dest/'experiment'
        cert.mkdir();(exp/'models').mkdir(parents=True);(exp/'records').mkdir()
        for source in (ROOT/'certificates').glob('*.py'):shutil.copy2(source,cert/source.name)
        for name in ['train.py','attacks.py']:
            shutil.copy2(ROOT/'experiment'/name,exp/name)
        for index in [105,500]:
            for sub in ['models','records']:
                source=next((ROOT/'experiment'/sub).glob(f'{index:03d}-*'))
                shutil.copy2(source,exp/sub/source.name)
        for name in ['confident-target-105.npz','confident-target-105.json']:
            shutil.copy2(ROOT/'certificates'/name,cert/name)
        shutil.copytree(ROOT/'certificates/full-cube-verified-500-c3_100',cert/'full-cube-verified-500-c3_100')
        env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1')
        logs=[]
        for command in [[sys.executable,'replay_confident_target.py'],
                        [sys.executable,'exact_boolean_cube.py','--index','500','--c','3/100','--only-global']]:
            result=subprocess.run(command,cwd=cert,env=env,capture_output=True,text=True)
            if result.returncode:
                print(result.stdout);print(result.stderr,file=sys.stderr)
                raise SystemExit(result.returncode)
            logs.append({'command':command[1:],'stdout_tail':result.stdout[-1600:]})
        negative=json.loads((cert/'confident-target-105-independent-replay.json').read_text())
        positive=json.loads((cert/'full-cube-verified-500-c3_100/certificate.json').read_text())
        assert negative['independent_replay_pass'] and negative['output_noise_exactly_zero']
        assert positive['all_boolean_inputs_certified'] and positive['input_count']==512
        assert positive['all_training_margins_interval_verified']
        output={'all_checks_passed':True,'model105_counterexample_verified':True,
                'model500_all512_inputs_verified':True,'model500_all400_training_margins_verified':True,
                'external_dataset_or_network_required':False,'committed_records_modified':False,
                'model_sha256':{str(index):sha(next((ROOT/'experiment/models').glob(f'{index:03d}-*')))for index in [105,500]},
                'qualification':'Exact rational budgets/matrix bounds and outward interval evaluations; not a Lean formalization.',
                'commands':logs}
        print(json.dumps(output,indent=2))

if __name__=='__main__':main()
