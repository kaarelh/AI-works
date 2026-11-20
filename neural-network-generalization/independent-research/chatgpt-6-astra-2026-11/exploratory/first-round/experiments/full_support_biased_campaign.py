import json,time,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];dest=ROOT/'results'/'full_support_biased';dest.mkdir(exist_ok=True)
start=time.time();budget=3*3600
configs=[(4,'balanced',16,.05,5000),(5,'balanced',16,.05,5000),(6,'balanced',16,.05,5000),(4,'gaussian',16,.05,5000),(6,'gaussian',16,.05,5000),(4,'balanced',8,.02,5000),(6,'balanced',8,.02,5000)]
for q,init,seeds,dt,T in configs:
 left=budget-(time.time()-start)
 if left<60:break
 key=f'q{q}_{init}_s{seeds}_dt{dt}'
 print(json.dumps(dict(status='start',name=key,seconds=time.time()-start)),flush=True)
 try:
  with (dest/(key+'.log')).open('w') as f:
   p=subprocess.run([str(ROOT/'.venv/bin/python'),str(ROOT/'experiments/full_support_biased.py'),'--q',str(q),'--initialization',init,'--seeds',str(seeds),'--dt',str(dt),'--time',str(T),'--alphas','.0001','.01','.1'],stdout=f,stderr=subprocess.STDOUT,timeout=left)
 except subprocess.TimeoutExpired:
  print(json.dumps(dict(status='budget timeout',name=key,seconds=time.time()-start)),flush=True);break
 print(json.dumps(dict(status='done',name=key,code=p.returncode,seconds=time.time()-start)),flush=True)
