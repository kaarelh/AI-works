#!/usr/bin/env python3
"""Fixed continuation of both deep-SGD seeds; originals remain unchanged."""
from pathlib import Path
import datetime,json
ROOT=Path(__file__).resolve().parent
configs=[]
for original,index in [(8,300),(9,301)]:
    rec=json.loads(next((ROOT/'records').glob(f'{original:03d}-*.json')).read_text())
    c=dict(rec['config']);oldid=c['id']
    c.update(index=index,id=f"{index:03d}-mnist3vs8-continuous-H32-N128-sgd-continuation-s{c['seed']}",
             cohort='deep-sgd-continuation',epochs=180,initial_model_id=oldid,
             shuffle_skip_epochs=60,learning_rate=.002,
             learning_rate_schedule=[[120,.002],[180,.0004]])
    configs.append(c)
record=dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            status='Fixed after both original runs and some of their attack outcomes were visible; before any continuation training.',
            motivation='Test whether both deep vanilla-SGD seeds reach every training margin after more optimization. No seed selection: continue BOTH008/009. All failures retained.',
            continuation='Saved raw float32 weights, same vanilla SGD and weight decay, shuffle sequence continues after60epochs,180additionalepochs at fixed .002 for120 then.0004 for60. No output rescaling or checkpoint selection.',
            comparisons='Originals remain separate. Same predeclared certificate/attack/quantization protocols apply.',configs=configs)
p=ROOT/'predeclared-continuation.json'
if p.exists():raise RuntimeError('Already declared.')
p.write_text(json.dumps(record,indent=2)+'\n');print(p)
