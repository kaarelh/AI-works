import subprocess,time,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];dest=ROOT/'results'/'parity_relu_gauge';dest.mkdir(exist_ok=True)
start=time.time();budget=3.25*3600
configs=[(6,512,100000,2),(6,2048,100000,2),(8,512,60000,2),(8,2048,60000,2),(6,8192,100000,1),(8,8192,60000,1)]
for d,n,sweeps,seeds in configs:
 for seed in range(seeds):
  for init in ['democratic','condensed']:
   left=budget-(time.time()-start)
   if left<60:raise SystemExit
   key=f'd{d}_n{n}_seed{seed}_{init}'
   print(json.dumps(dict(status='start',name=key,seconds=time.time()-start)),flush=True)
   try:
    with (dest/(key+'.log')).open('w') as f:
     p=subprocess.run([str(ROOT/'experiments/parity_relu_gauge'),str(d),str(n),str(seed),init,str(sweeps),'100',str(dest/(key+'.jsonl')),'.5','isotropic'],stdout=f,stderr=subprocess.STDOUT,timeout=left)
   except subprocess.TimeoutExpired:
    print(json.dumps(dict(status='budget timeout',name=key,seconds=time.time()-start)),flush=True);raise SystemExit
   print(json.dumps(dict(status='done',name=key,code=p.returncode,seconds=time.time()-start)),flush=True)
