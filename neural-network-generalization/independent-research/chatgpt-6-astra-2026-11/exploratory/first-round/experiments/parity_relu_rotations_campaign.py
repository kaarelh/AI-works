import subprocess,time,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];dest=ROOT/'results'/'parity_relu_rotations';dest.mkdir(exist_ok=True)
start=time.time();budget=3*3600
for n,sweeps,seeds in [(512,100000,3),(2048,100000,2),(8192,100000,1),(32768,100000,1)]:
 for prior in ['isotropic','fan-in']:
  for seed in range(seeds):
   for init in ['democratic','condensed']:
    left=budget-(time.time()-start)
    if left<60:raise SystemExit
    key=f'd6_n{n}_seed{seed}_{init}_{prior}'
    print(json.dumps(dict(status='start',name=key,seconds=time.time()-start)),flush=True)
    try:
     with (dest/(key+'.log')).open('w') as f:
      p=subprocess.run([str(ROOT/'experiments/parity_relu_rotations'),'6',str(n),str(seed),init,str(sweeps),'100',str(dest/(key+'.jsonl')),'.5',prior],stdout=f,stderr=subprocess.STDOUT,timeout=left)
    except subprocess.TimeoutExpired:
     print(json.dumps(dict(status='budget timeout',name=key,seconds=time.time()-start)),flush=True);raise SystemExit
    print(json.dumps(dict(status='done',name=key,code=p.returncode,seconds=time.time()-start)),flush=True)
