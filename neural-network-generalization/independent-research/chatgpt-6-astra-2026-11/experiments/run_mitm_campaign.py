"""Wall-clock-bounded, single-process Fourier Monte Carlo campaign.

The integrals are the proof; these finite-cube measurements independently
diagnose their finite-dimensional meaning. A timed-out job remains partial.
"""
import json, subprocess, time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'results/mitm_campaign';OUT.mkdir(exist_ok=True)
jobs=[]
for r,samples in ((16,10000),(24,20000),(32,20000),(40,5000),(44,3000),(48,2500)):
    for A in (.25,.5,1.,2.):
        seed=2026111800+len(jobs)
        name=f'r{r}_A{A:g}'
        cmd=[str(ROOT/'tools/parity_fourier_mitm'),str(r),str(A),str(samples),str(seed),str(OUT/(name+'.jsonl'))]
        jobs.append(dict(name=name,r=r,A=A,samples=samples,seed=seed,command=cmd))
start=time.monotonic();deadline=start+7.4*3600
(OUT/'campaign.json').write_text(json.dumps(dict(jobs=jobs,wall_cap_hours=7.4,
    qualification='Floating-point finite-cube Monte Carlo; no interval certificate or population proof.'),indent=2)+'\n')
for job in jobs:
    remaining=deadline-time.monotonic()
    if remaining<30:break
    before=time.monotonic()
    try:
        p=subprocess.run(job['command'],timeout=remaining,check=False)
        status='complete' if p.returncode==0 else 'failed'
    except subprocess.TimeoutExpired:
        status='partial_wall_cap'
    record=dict(name=job['name'],status=status,seconds=time.monotonic()-before,
                elapsed_seconds=time.monotonic()-start)
    with (OUT/'job_status.jsonl').open('a') as f:f.write(json.dumps(record)+'\n')
    print(json.dumps(record),flush=True)
    if status!='complete':break
