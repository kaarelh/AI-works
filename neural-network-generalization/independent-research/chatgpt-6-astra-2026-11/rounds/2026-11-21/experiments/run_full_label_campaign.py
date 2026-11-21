"""Bounded numerical campaign; partial jobs remain explicitly partial."""
import datetime,json,subprocess,time,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
PYTHON=Path(sys.executable)
OUT=ROOT/'results/full_label_campaign';OUT.mkdir(exist_ok=True)
start=time.monotonic();deadline=start+8*3600
jobs=[]
for rep in range(3):
    for loss in ('square','logistic'):
        for n in (1024,4096,16384,65536,262144,1048576,4194304):
            jobs.append(dict(width=n,loss=loss,replicate=rep,proposals=min(10000,max(1000,16000000//n))))
(OUT/'campaign.json').write_text(json.dumps(dict(start_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),wall_budget_hours=8,jobs=jobs,
    scope='Independent proposals with restricted-cone importance diagnostics. No full-posterior TV certificate.'),indent=2)+'\n')
with (OUT/'status.jsonl').open('w',buffering=1) as status:
    for job in jobs:
        n=job['width'];loss=job['loss'];rep=job['replicate'];name=f'{loss}_N{n}_rep{rep}'
        remain=deadline-time.monotonic()
        if remain<=0:
            row=dict(name=name,status='not_started_deadline',**job)
        else:
            command=[str(PYTHON),str(ROOT/'experiments/full_label_independent.py'),'--width',str(n),'--loss',loss,
                     '--seed',str(202611200000+n*11+rep+int(loss=='logistic')*100000000),'--proposals',str(job['proposals']),
                     '--output',str(OUT/(name+'.json'))]
            print(json.dumps(dict(name=name,status='started',**job)),flush=True);begin=time.monotonic()
            with (OUT/(name+'.log')).open('w') as log:
                try:
                    result=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=remain)
                    state='complete' if result.returncode==0 else f'exit_{result.returncode}'
                except subprocess.TimeoutExpired:state='timeout_partial'
            row=dict(name=name,status=state,seconds=time.monotonic()-begin,command=command,**job)
        status.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
print(json.dumps(dict(status='campaign_finished',seconds=time.monotonic()-start)),flush=True)
