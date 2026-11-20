"""Finite-neural posterior versus width, with independent inference checks.

Prior and likelihood are fixed across widths. Larger dimensions test whether
the width scale needed to approach the Gaussian-process failure grows rapidly.
The sampling experiment is exploratory; the mathematical lower bound is in
the separate proof note and does not depend on these estimates.
"""
import argparse,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=6)
args=ap.parse_args();start=time.time();env=os.environ.copy()
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:env[k]='1'
configs=[]
for seed in range(4):
 for n in [1,2,4,8,16,32,64,128,256,512]:configs.append((4,n,2048,32,seed,0))
for seed in range(4):
 for n in [1,2,4,8,16,32,64,128,256,512]:configs.append((6,n,2048,32,seed,0))
for seed in [4,5]:
 for n in [1,16,256]:configs.append((4,n,8192,64,seed,0))
for seed in range(2):
 for n in [1,4,16,64,256,512]:configs.append((8,n,1024,32,seed,0))
for seed in range(4):
 for n in [1,4,16,64]:configs.append((4,n,2048,32,seed,.5))
dest=ROOT/'results'/'cosine_campaign';dest.mkdir(exist_ok=True)
for d,n,p,s,seed,m in configs:
 if time.time()-start>3600*args.hours:
  print(json.dumps(dict(status='wall_budget_reached',seconds=time.time()-start)),flush=True);break
 key=f'd{d}_n{n}_p{p}_s{s}_seed{seed}_m{m:g}'
 if (ROOT/'results'/'cosine_smc'/f'{key}.npz').exists():continue
 print(json.dumps(dict(status='starting',key=key,seconds=time.time()-start)),flush=True)
 cmd=[sys.executable,str(ROOT/'experiments'/'cosine_posterior_smc.py'),'--d',str(d),'--width',str(n),
      '--particles',str(p),'--sweeps',str(s),'--seed',str(seed),'--margin',str(m)]
 with (dest/(key+'.log')).open('w') as f:
  result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=ROOT)
 if result.returncode:
  print(json.dumps(dict(status='failed',key=key,code=result.returncode)),flush=True)
 else:print(json.dumps(dict(status='finished',key=key,seconds=time.time()-start)),flush=True)
