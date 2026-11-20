"""Independent starts and increasing widths for exact-coordinate posterior MCMC.

All conditionals are exact; finite-run convergence is not certified.
The two initializations test, but cannot prove absence of, metastability.
"""
import os,sys,time,json,subprocess,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=5);args=ap.parse_args()
start=time.time();dest=ROOT/'results'/'softplus_gibbs';dest.mkdir(exist_ok=True)
cfg=[]
for n in [1024,4096,16384]:
 for seed in range(4):
  for mode in ['condensed','democratic']:cfg.append((n,seed,mode,100000))
for n in [65536,262144]:
 for seed in range(2):
  for mode in ['condensed','democratic']:cfg.append((n,seed,mode,100000))
for n,seed,mode,sweeps in cfg:
 if time.time()-start>args.hours*3600:break
 name=f'n{n}_seed{seed}_{mode}'
 print(json.dumps(dict(status='starting',name=name,seconds=time.time()-start)),flush=True)
 cmd=[str(ROOT/'experiments'/'softplus_posterior_gibbs'),str(n),str(seed),mode,str(sweeps),'100',str(dest/(name+'.jsonl'))]
 with (dest/(name+'.log')).open('w') as f:r=subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
 assert r.returncode==0,(name,r.returncode)
 print(json.dumps(dict(status='finished',name=name,seconds=time.time()-start)),flush=True)
