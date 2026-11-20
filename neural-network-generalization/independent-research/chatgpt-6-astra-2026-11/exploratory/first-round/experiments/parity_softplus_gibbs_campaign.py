"""Finite-width diagnostics for the exponential-condensation theorem.

Exact coordinate conditionals do not certify mixing. Both starts use the
same canonical orientation hemisphere; they test coarsening, not all modes.
"""
import argparse,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=4.75);args=ap.parse_args()
start=time.time();dest=ROOT/'results'/'parity_softplus_gibbs';dest.mkdir(exist_ok=True)
cfg=[]
for n,seeds,sweeps in [(128,4,20000),(512,4,20000),(2048,2,50000),(8192,1,100000)]:
 for seed in range(seeds):
  for mode in ['condensed','democratic']:cfg.append((6,n,seed,mode,sweeps))
for n in [512,2048]:
 for mode in ['condensed','democratic']:cfg.append((8,n,0,mode,20000))
for d,n,seed,mode,sweeps in cfg:
 remaining=args.hours*3600-(time.time()-start)
 if remaining<=0:break
 name=f'd{d}_n{n}_seed{seed}_{mode}'
 print(json.dumps(dict(status='starting',name=name,seconds=time.time()-start)),flush=True)
 cmd=[str(ROOT/'experiments'/'parity_softplus_gibbs'),str(d),str(n),str(seed),mode,str(sweeps),'100',str(dest/(name+'.jsonl'))]
 try:
  with (dest/(name+'.log')).open('w') as f:r=subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT,timeout=remaining)
 except subprocess.TimeoutExpired:
  print(json.dumps(dict(status='time_limit_partial',name=name,seconds=time.time()-start)),flush=True);break
 assert r.returncode==0,(name,r.returncode)
 print(json.dumps(dict(status='finished',name=name,seconds=time.time()-start)),flush=True)
