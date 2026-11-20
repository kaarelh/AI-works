"""Gate-resolved critical capture scans; numerical conjecture testing only."""
import argparse,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=3);args=ap.parse_args()
env=os.environ.copy();start=time.time()
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:env[key]='1'
cfg=[(2,r,.005,10,8) for r in [.9,.8,.77,.76,.755,.752,.751,.7505,.7502,.7501,.75005,.75002,.75001]]
cfg +=[(2,r,.0025,16,12) for r in [.76,.752,.7505,.7501,.75002]]
for L in [3,4]:
 for delta in [.05,.02,.01,.005,.002,.001,.0005,.0002,.0001]:cfg.append((L,.5+1/L**2+delta,.005,10,8))
dest=ROOT/'results'/'entry_boundary_campaign';dest.mkdir(exist_ok=True)
for L,r,dt,nleg,aleg in cfg:
 if time.time()-start>args.hours*3600:break
 name=f'L{L:g}_rho{r:g}_dt{dt:g}_l{nleg}_a{aleg}'
 if (ROOT/'results'/f'boundary_entry_{name}.json').exists():continue
 print(json.dumps(dict(status='starting',name=name,seconds=time.time()-start)),flush=True)
 cmd=[sys.executable,str(ROOT/'experiments'/'shortcut_boundary_layer_entry.py'),'--L',str(L),'--rho',str(r),
      '--dt',str(dt),'--nleg',str(nleg),'--angular-nleg',str(aleg)]
 with (dest/(name+'.log')).open('w') as f:rtn=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=ROOT)
 assert rtn.returncode==0,(name,rtn.returncode)
 print(json.dumps(dict(status='finished',name=name,seconds=time.time()-start)),flush=True)
