import json,time,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];dest=ROOT/'results/critical_relu_iid';dest.mkdir(exist_ok=True);start=time.time()
for d,n in [(6,100_000_000),(8,30_000_000),(10,10_000_000),(12,3_000_000),(14,1_000_000)]:
 for seed in range(4):
  key=f'd{d}_p{n}_seed{seed}';print(json.dumps(dict(status='start',name=key,seconds=time.time()-start)),flush=True)
  left=3600-(time.time()-start)
  if left<30:raise SystemExit()
  try:
   with (dest/(key+'.jsonl')).open('w') as f:p=subprocess.run([str(ROOT/'.venv/bin/python'),str(ROOT/'experiments/critical_relu_iid.py'),'--dimension',str(d),'--proposals',str(n),'--seed',str(seed)],stdout=f,stderr=subprocess.STDOUT,timeout=left)
  except subprocess.TimeoutExpired:raise SystemExit()
  print(json.dumps(dict(status='done',name=key,code=p.returncode,seconds=time.time()-start)),flush=True)
