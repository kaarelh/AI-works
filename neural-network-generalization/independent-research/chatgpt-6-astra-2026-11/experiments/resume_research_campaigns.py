"""Resume incomplete jobs, preserving completed records and interrupted files."""
import argparse,concurrent.futures,datetime,hashlib,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('campaign',choices=['cold_transfer','mitm_campaign','universal_smoothing','scalar_sampler']);ap.add_argument('--hours',type=float,default=8);args=ap.parse_args()
out=ROOT/'results'/args.campaign;original=json.loads((out/'campaign.json').read_text());stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
statusfile=out/('status.jsonl' if args.campaign=='scalar_sampler' else 'job_status.jsonl')
old=[json.loads(line) for line in statusfile.read_text().splitlines()];done={r['name'] for r in old if r['status']=='complete'}
jobs=[]
for index,row in enumerate(original['jobs']):
 if args.campaign=='cold_transfer':
  s,m,d,mode=row['scale'],row['draws'],row['data_seed'],row['initialization'];name=f'd8_N1024_tau{s:g}_m{m}_data{d}_{mode}'
  command=[str(ROOT/'tools/parity_relu_cold_transfer'),'8','1024',str(7000+index),mode,'300000','1000',str(out/(name+'.jsonl')),'0.5',f'cold-{s}',str(m),str(d)]
 elif args.campaign=='scalar_sampler':
  n,s,rep=row['width'],row['margin'],row['replicate'];name=f'd4_N{n}_s{s:g}_rep{rep}'
  command=[str(ROOT/'.venv/bin/python'),str(ROOT/'experiments/scalar_posterior_independent.py'),'--width',str(n),'--margin',str(s),'--seed',str(202611190000+n*7+rep+int(s*100)),'--samples',str(min(131072,max(512,400000000//n))),'--output',str(out/(name+'.json'))]
 else:name,command=row['name'],row['command']
 if name not in done:jobs.append(dict(name=name,command=command))
record=dict(resume_utc=stamp,wall_budget_hours=args.hours,completed_jobs_preserved=len(done),jobs=jobs,original_manifest_sha256=hashlib.sha256((out/'campaign.json').read_bytes()).hexdigest())
(out/('resume-'+stamp+'.json')).write_text(json.dumps(record,indent=2)+'\n')
start=time.monotonic();deadline=start+args.hours*3600

def run(job):
 name=job['name'];remaining=deadline-time.monotonic()
 if remaining<=0:return dict(name=name,status='not_started_resume_deadline')
 interrupted=out/('interrupted-'+stamp)
 for p in list(out.glob(name+'.*')):
  if p.is_file():interrupted.mkdir(exist_ok=True);p.rename(interrupted/p.name)
 begin=time.monotonic();print(json.dumps(dict(name=name,status='started',resume=stamp)),flush=True)
 with (out/(name+'.resume.log')).open('w') as log:
  try:
   p=subprocess.run(job['command'],stdout=log,stderr=subprocess.STDOUT,timeout=remaining,env={**os.environ,'OMP_NUM_THREADS':'1'})
   state='complete' if p.returncode==0 else f'exit_{p.returncode}'
  except subprocess.TimeoutExpired:state='partial_resume_deadline'
 return dict(name=name,status=state,seconds=time.monotonic()-begin,resume=stamp,command=job['command'])
with statusfile.open('a') as status:
 with concurrent.futures.ThreadPoolExecutor(max_workers=2 if args.campaign=='cold_transfer' else 1) as pool:
  for future in concurrent.futures.as_completed([pool.submit(run,j) for j in jobs]):
   row=future.result();status.write(json.dumps(row)+'\n');status.flush();print(json.dumps(row),flush=True)
print(json.dumps(dict(status='resumption_finished',seconds=time.monotonic()-start)),flush=True)
