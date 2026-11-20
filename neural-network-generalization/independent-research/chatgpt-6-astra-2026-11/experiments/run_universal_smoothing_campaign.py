"""Bounded independent finite-cube diagnostics for non-Gaussian smoothing.

No samples from this campaign enter the analytic proof. Every noise law
has variance one. A job stopped at the wall-clock cap remains partial.
"""
import json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/universal_smoothing'
OUT.mkdir(exist_ok=True);jobs=[]
for r,samples in ((16,10000),(24,20000),(32,15000),(40,4000),(44,2000),(48,1200)):
 for A in (.5,1.,2.):
  for noise in ('uniform','laplace'):
   name=f'{noise}_r{r}_A{A:g}';seed=202611181000+len(jobs)
   command=[str(ROOT/'tools/parity_fourier_universal'),str(r),str(A),str(samples),str(seed),str(OUT/(name+'.jsonl')),noise]
   jobs.append(dict(name=name,r=r,A=A,noise=noise,samples=samples,seed=seed,command=command))
start=time.monotonic();deadline=start+6.4*3600
(OUT/'campaign.json').write_text(json.dumps(dict(jobs=jobs,wall_cap_hours=6.4,
 qualification='Floating-point exact finite-cube summation before Monte Carlo averaging; no interval or mixing claim.'),indent=2)+'\n')
for job in jobs:
 remaining=deadline-time.monotonic()
 if remaining<30:break
 before=time.monotonic()
 try:
  p=subprocess.run(job['command'],timeout=remaining,check=False)
  status='complete' if p.returncode==0 else 'failed'
 except subprocess.TimeoutExpired:status='partial_wall_cap'
 record=dict(name=job['name'],status=status,seconds=time.monotonic()-before,elapsed_seconds=time.monotonic()-start)
 with (OUT/'job_status.jsonl').open('a') as f:f.write(json.dumps(record)+'\n')
 print(json.dumps(record),flush=True)
 if status!='complete':break
