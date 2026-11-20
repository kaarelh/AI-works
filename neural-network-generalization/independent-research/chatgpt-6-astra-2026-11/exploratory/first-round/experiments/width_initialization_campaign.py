"""Predeclared test of the conjectured N*alpha^2 shortcut crossover.
Ordinary unconstrained full networks, paired random balanced initialization.
Only the initialization scale changes with width; no quadrature or symmetry
of the learned network is imposed. Wall budget bounds computational work.
"""
import argparse,math,subprocess,sys,time,json,os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=4)
ap.add_argument('--dt',type=float,default=.02);args=ap.parse_args()
start=time.time();env=os.environ.copy()
for key in ['OPENBLAS_NUM_THREADS','VECLIB_MAXIMUM_THREADS','OMP_NUM_THREADS']:env[key]='1'
dest=ROOT/'results'/'width_campaign';dest.mkdir(exist_ok=True)
for seedstart in range(0,64,8):
 for width in [16,64,256,1024,4096,16384]:
  if time.time()-start>args.hours*3600:
   print(json.dumps(dict(status='wall_budget_reached',seconds=time.time()-start)),flush=True);sys.exit(0)
  name=f'widthscan_s{seedstart}_dt{args.dt:g}'
  filename=ROOT/'results'/f'{name}_bias0_n{width}_dt{args.dt:g}.jsonl'
  if filename.exists():continue
  alphas=','.join(f'{c/math.sqrt(width):.17g}' for c in [.05,.1,.2,.4,.8,1.6])
  cmd=[sys.executable,str(ROOT/'experiments'/'boolean_shortcut_full.py'),'--Ls','2','--rhos','.9',
       '--alphas',alphas,'--width',str(width),'--seeds','8','--seedstart',str(seedstart),
       '--time','1500','--dt',str(args.dt),'--name',name]
  print(json.dumps(dict(status='starting',width=width,seedstart=seedstart,alphas=alphas,seconds=time.time()-start)),flush=True)
  with (dest/f'n{width}_s{seedstart}_dt{args.dt:g}.log').open('w') as f:
   result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=ROOT)
  assert result.returncode==0,(width,seedstart,result.returncode)
  print(json.dumps(dict(status='finished',width=width,seedstart=seedstart,seconds=time.time()-start)),flush=True)
