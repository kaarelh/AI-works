"""Test whether two rare feature seeds explain the finite-width crossover.

Balanced midpoint Lorentz updates avoid Euler drift of a^2-||w||^2.
At time100 the network is on its shortcut plateau; saved neurons identify
which signs retain feature-sensitive gates. Predictions from those counts
can then be compared with the final outcome, without fitting to it.
"""
import argparse,json,math,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=5)
args=ap.parse_args();start=time.time();env=os.environ.copy()
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:env[k]='1'
dest=ROOT/'results'/'rare_seed_campaign';dest.mkdir(exist_ok=True)
for width,seeds in [(1024,256),(4096,128),(64,256)]:
 for seedstart in range(0,seeds,8):
  if time.time()-start>3600*args.hours:
   print(json.dumps(dict(status='wall_budget_reached',seconds=time.time()-start)),flush=True);sys.exit(0)
  name=f'rareseeds_n{width}_s{seedstart}'
  if (ROOT/'results'/f'{name}_boost2_bias0_n{width}_final.npz').exists():continue
  alphas=','.join(f'{c/math.sqrt(width):.17g}' for c in [.05,.1,.15,.2,.3,.4,.6])
  cmd=[sys.executable,str(ROOT/'experiments'/'boolean_shortcut_full.py'),'--Ls','2','--rhos','.9',
       '--alphas',alphas,'--width',str(width),'--seeds','8','--seedstart',str(seedstart),
       '--time','2000','--dt','.02','--method','boost2','--snapshots','100','--name',name]
  print(json.dumps(dict(status='starting',name=name,seconds=time.time()-start)),flush=True)
  with (dest/(name+'.log')).open('w') as f:
   result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=ROOT)
  assert result.returncode==0,(name,result.returncode)
  print(json.dumps(dict(status='finished',name=name,seconds=time.time()-start)),flush=True)
