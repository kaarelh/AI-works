"""Check the same condensation prediction under two ordinary Gaussian scalings.

Exact coordinate updates, finite-run MCMC only; no mixing certificate.
The two starts share a canonical orientation hemisphere.
"""
import argparse,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=4.75);args=ap.parse_args()
start=time.time();dest=ROOT/'results'/'parity_relu_prior_gibbs';dest.mkdir(exist_ok=True)
cfg=[]
for n,seeds,sweeps in [(512,3,100000),(2048,2,100000),(8192,1,100000),(32768,1,100000)]:
 for profile in ['isotropic','fan-in']:
  for seed in range(seeds):
   for mode in ['condensed','democratic']:cfg.append((6,n,seed,mode,sweeps,profile))
for d,n,seed,mode,sweeps,profile in cfg:
 remaining=args.hours*3600-(time.time()-start)
 if remaining<=0:break
 name=f'd{d}_n{n}_seed{seed}_{mode}_{profile}'
 print(json.dumps(dict(status='starting',name=name,seconds=time.time()-start)),flush=True)
 cmd=[str(ROOT/'experiments'/'parity_relu_prior_gibbs'),str(d),str(n),str(seed),mode,str(sweeps),'100',str(dest/(name+'.jsonl')),'0.5',profile]
 try:
  with (dest/(name+'.log')).open('w') as f:r=subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT,timeout=remaining)
 except subprocess.TimeoutExpired:
  print(json.dumps(dict(status='time_limit_partial',name=name,seconds=time.time()-start)),flush=True);break
 assert r.returncode==0,(name,r.returncode)
 print(json.dumps(dict(status='finished',name=name,seconds=time.time()-start)),flush=True)
