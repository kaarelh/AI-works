import subprocess,time,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];dest=ROOT/'results'/'parity_relu_observables';dest.mkdir(exist_ok=True)
start=time.time();budget=3.5*3600
for n,sweeps,seeds in [(512,100000,2),(2048,100000,2),(8192,100000,1),(32768,100000,1)]:
 for algo in ['coordinate','rotation']:
  for seed in range(seeds):
   for init in ['democratic','condensed']:
    left=budget-(time.time()-start)
    if left<60:raise SystemExit
    key=f'd6_n{n}_seed{seed}_{init}_{algo}'
    print(json.dumps(dict(status='start',name=key,seconds=time.time()-start)),flush=True)
    binary='parity_relu_observables' if algo=='coordinate' else 'parity_relu_rotations_observables'
    try:
     with (dest/(key+'.log')).open('w') as f:
      p=subprocess.run([str(ROOT/'experiments'/binary),'6',str(n),str(seed),init,str(sweeps),'100',str(dest/(key+'.jsonl')),'.5','isotropic'],stdout=f,stderr=subprocess.STDOUT,timeout=left)
    except subprocess.TimeoutExpired:
     print(json.dumps(dict(status='budget timeout',name=key,seconds=time.time()-start)),flush=True);raise SystemExit
    print(json.dumps(dict(status='done',name=key,code=p.returncode,seconds=time.time()-start)),flush=True)
