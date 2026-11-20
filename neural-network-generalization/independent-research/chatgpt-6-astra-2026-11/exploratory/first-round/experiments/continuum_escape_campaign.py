"""Resolve the conjectured rare-neuron escape law over many decades.

The scan is predeclared and records exact grid crossing times. Later finer
steps and quadrature resolutions test the nonsmooth integration error.
This is a deterministic population quadrature, not iid finite-width data.
"""
import argparse,json,math,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--hours',type=float,default=6)
args=ap.parse_args();start=time.time();env=os.environ.copy()
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:env[k]='1'
configs=[]
for rho in [.9,.8,.95]:
 for power in [4,8,12,16,20,24]:configs.append((2,rho,power,.02,8,64))
for power in [8,16]:
 for dt,nleg,nphi in [(.01,16,128),(.005,16,128),(.0025,16,128)]:
  configs.append((2,.9,power,dt,nleg,nphi))
for L,rho in [(3,.75),(3,.9),(4,.7)]:
 for power in [4,8,12,16]:configs.append((L,rho,power,.02,8,64))
dest=ROOT/'results'/'continuum_campaign';dest.mkdir(exist_ok=True)
for L,rho,power,dt,nleg,nphi in configs:
 if time.time()-start>3600*args.hours:
  print(json.dumps(dict(status='wall_budget_reached',seconds=time.time()-start)),flush=True);break
 alpha=10.**(-power);gridpower=2*power+8
 slope=2/(rho*L)+6*math.sqrt(2)/(1-rho*rho)
 horizon=math.ceil(slope*math.log(1/alpha)+400/(1-rho*rho)**.5)
 name=f'L{L:g}_rho{rho:g}_a{alpha:g}_dt{dt:g}_p{gridpower}_l{nleg}_f{nphi}'
 if (ROOT/'results'/f'continuum_null_{name}_events.json').exists():continue
 cmd=[sys.executable,str(ROOT/'experiments'/'shortcut_continuum.py'),'--L',str(L),'--rho',str(rho),
      '--alpha',str(alpha),'--dt',str(dt),'--time',str(horizon),'--power',str(gridpower),
      '--nleg',str(nleg),'--nphi',str(nphi)]
 print(json.dumps(dict(status='starting',name=name,horizon=horizon,seconds=time.time()-start)),flush=True)
 with (dest/(name+'.log')).open('w') as f:
  result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,cwd=ROOT,env=env)
 assert result.returncode==0,(name,result.returncode)
 print(json.dumps(dict(status='finished',name=name,seconds=time.time()-start)),flush=True)
