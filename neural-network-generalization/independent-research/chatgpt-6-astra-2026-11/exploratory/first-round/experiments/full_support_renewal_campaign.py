import subprocess,time,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
configs=[('none',1,.02,2000),('planted1',1,.02,2000),('planted4',1,.02,2000),('random2',64,.02,2000),('random8',64,.02,2000),('random4',16,.01,3000),('random4',16,.005,3000)]
start=time.time()
for mode,seeds,dt,T in configs:
 key=f'{mode}_s{seeds}_dt{dt}_t{T}'
 print(json.dumps(dict(status='start',key=key,elapsed=time.time()-start)),flush=True)
 with (ROOT/'results'/'full_support_renewal'/(key+'.log')).open('w') as f:
  p=subprocess.run([str(ROOT/'.venv/bin/python'),str(ROOT/'experiments/full_support_renewal.py'),'--mode',mode,'--seeds',str(seeds),'--dt',str(dt),'--time',str(T)],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
 print(json.dumps(dict(status='done',key=key,code=p.returncode,elapsed=time.time()-start)),flush=True)
