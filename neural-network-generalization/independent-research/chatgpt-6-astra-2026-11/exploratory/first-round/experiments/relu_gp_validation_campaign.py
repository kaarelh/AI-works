"""Replicate signs of GP posterior majority predictions; no theorem implied."""
import os,subprocess,sys,time,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];env=os.environ.copy()
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:env[k]='1'
cfg=[(6,16384,256,1,'lex'),(8,16384,256,1,'lex'),(6,8192,128,2,'random'),
     (6,8192,128,2,'gray'),(8,16384,512,2,'lex'),(9,8192,128,0,'lex')]
dest=ROOT/'results'/'relu_gp_validation';dest.mkdir(exist_ok=True);start=time.time()
for d,p,s,seed,order in cfg:
 name=f'd{d}_p{p}_s{s}_seed{seed}_{order}'
 print(json.dumps(dict(status='start',name=name,seconds=time.time()-start)),flush=True)
 cmd=[sys.executable,str(ROOT/'experiments'/'general_gp_orthants.py'),'--d',str(d),'--particles',str(p),
      '--sweeps',str(s),'--seed',str(seed),'--order',order]
 with (dest/(name+'.log')).open('w') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=ROOT)
 assert r.returncode==0,(name,r.returncode)
 print(json.dumps(dict(status='done',name=name,seconds=time.time()-start)),flush=True)
