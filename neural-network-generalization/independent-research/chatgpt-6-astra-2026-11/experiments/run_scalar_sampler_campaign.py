"""Independent proposal convergence diagnostics, with a wall-time cap."""
import datetime,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/scalar_sampler';OUT.mkdir(exist_ok=True)
start=time.monotonic();deadline=start+4.8*3600
jobs=[(n,s,rep) for n in (16,64,256,1024,4096,16384,65536,262144,1048576)
      for s in (.25,1.) for rep in range(3)]
(OUT/'campaign.json').write_text(json.dumps(dict(start_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    dimension=4,wall_budget_hours=4.8,
    scope='Independent proposals and restricted-cone importance diagnostics; not full-posterior total-variation certificates.',
    jobs=[dict(width=n,margin=s,replicate=rep) for n,s,rep in jobs]),indent=2)+'\n')
with (OUT/'status.jsonl').open('w') as status:
 for n,s,rep in jobs:
    name=f'd4_N{n}_s{s:g}_rep{rep}'
    samples=min(131072,max(512,400000000//n))
    command=[str(ROOT/'.venv/bin/python'),str(ROOT/'experiments/scalar_posterior_independent.py'),
       '--width',str(n),'--margin',str(s),'--seed',str(202611190000+n*7+rep+int(s*100)),
       '--samples',str(samples),'--output',str(OUT/(name+'.json'))]
    remaining=deadline-time.monotonic()
    if remaining<=0:row=dict(name=name,status='not_started_deadline')
    else:
       begin=time.monotonic();print(json.dumps(dict(name=name,status='started',samples=samples)),flush=True)
       with (OUT/(name+'.log')).open('w') as log:
          try:
             p=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=remaining)
             state='complete' if p.returncode==0 else f'exit_{p.returncode}'
          except subprocess.TimeoutExpired:state='timeout'
       row=dict(name=name,status=state,seconds=time.monotonic()-begin,samples=samples,command=command)
    status.write(json.dumps(row)+'\n');status.flush();print(json.dumps(row),flush=True)
print(json.dumps(dict(status='campaign_finished',seconds=time.monotonic()-start)),flush=True)
