import json,time,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];dest=ROOT/'results'/'biased_followup';dest.mkdir(exist_ok=True)
start=time.time();budget=2.75*3600
configs=[]
for q in [4,5,6]:configs.append(('original',q,0,32,.02,8000,['1e-4','1e-8','1e-16','1e-32']))
for q,threshold in [(4,1),(6,1),(6,3),(5,0),(5,2)]:configs.append(('matched',q,threshold,16,.02,8000,['1e-4','1e-8','1e-16']))
for mode,q,threshold,seeds,dt,T,alphas in configs:
 left=budget-(time.time()-start)
 if left<60:break
 key=f'{mode}_q{q}_threshold{threshold}_s{seeds}_dt{dt}'
 print(json.dumps(dict(status='start',name=key,seconds=time.time()-start)),flush=True)
 cmd=[str(ROOT/'.venv/bin/python'),str(ROOT/'experiments'/('full_support_biased.py' if mode=='original' else 'full_support_biased_matched.py')),'--q',str(q),'--seeds',str(seeds),'--dt',str(dt),'--time',str(T),'--alphas',*alphas]
 if mode=='matched':cmd+=['--threshold',str(threshold)]
 try:
  with (dest/(key+'.log')).open('w') as f:p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,timeout=left)
 except subprocess.TimeoutExpired:
  print(json.dumps(dict(status='timeout',name=key)),flush=True);break
 print(json.dumps(dict(status='done',name=key,code=p.returncode,seconds=time.time()-start)),flush=True)
