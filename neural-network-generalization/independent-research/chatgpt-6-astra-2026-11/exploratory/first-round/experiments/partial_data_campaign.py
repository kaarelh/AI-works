"""Bounded exploratory partial-data posterior campaign; no mixing guarantee."""
from pathlib import Path
import concurrent.futures,subprocess,time,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/parity_relu_partial';OUT.mkdir(exist_ok=True)
start=time.monotonic();deadline=start+25*60
jobs=[(draws,data,mode) for draws in [16,32,64,128] for data in [1,2] for mode in ['condensed','prior_fit']]
def run(job):
    draws,data,mode=job;name=f'd6_N512_draws{draws}_data{data}_{mode}'
    command=[str(ROOT/'experiments/parity_relu_partial'),'6','512',str(100+data),mode,'30000','20',str(OUT/(name+'.jsonl')),'.5','isotropic',str(draws),str(data)]
    remaining=deadline-time.monotonic()
    if remaining<=0:return dict(name=name,status='not_started_deadline')
    t=time.monotonic()
    with (OUT/(name+'.log')).open('w') as log:
        try:r=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=min(300,remaining));status='complete' if r.returncode==0 else f'exit_{r.returncode}'
        except subprocess.TimeoutExpired:status='timeout'
    return dict(name=name,status=status,seconds=time.monotonic()-t,command=command)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    for row in pool.map(run,jobs):print(json.dumps(row),flush=True)
