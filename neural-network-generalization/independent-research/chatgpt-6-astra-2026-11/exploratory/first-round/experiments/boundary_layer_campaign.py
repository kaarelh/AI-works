"""Predeclared critical-intensity test; independent of tiny-alpha simulations."""
import argparse,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=4)
x=ap.parse_args();start=time.time();env=os.environ.copy()
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:env[key]='1'
configs=[(2,r,.01,8,64) for r in [.95,.9,.85,.8,.78,.77,.76,.755,.752,.751,.7505]]
configs +=[(2,r,.005,16,128) for r in [.9,.8,.76,.752,.7505]]
for L in [3,4]:
 for delta in [.1,.05,.02,.01,.005,.002]:configs.append((L,.5+1/L**2+delta,.01,8,64))
dest=ROOT/'results'/'boundary_layer_campaign';dest.mkdir(exist_ok=True)
for L,r,dt,nleg,nphi in configs:
 if time.time()-start>3600*x.hours:break
 key=f'L{L:g}_rho{r:g}_dt{dt:g}_l{nleg}_f{nphi}'
 print(json.dumps(dict(status='starting',key=key,seconds=time.time()-start)),flush=True)
 cmd=[sys.executable,str(ROOT/'experiments'/'shortcut_boundary_layer.py'),'--L',str(L),'--rho',str(r),
      '--dt',str(dt),'--nleg',str(nleg),'--nphi',str(nphi),'--logmax','18']
 with (dest/(key+'.log')).open('w') as f:
  result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=ROOT)
 assert result.returncode==0,(key,result.returncode)
 print(json.dumps(dict(status='finished',key=key,seconds=time.time()-start)),flush=True)
