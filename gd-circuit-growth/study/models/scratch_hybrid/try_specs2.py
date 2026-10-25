import sys, time, numpy as np, pickle, os
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid')
import common as C
from partial_eval import run_partial, summary
from models.hybrid import Hybrid
OUT = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/partial_rows'
os.makedirs(OUT, exist_ok=True)
for spec in sys.argv[1:]:
    from specparse import parse; kw = parse(spec)
    t0 = time.time()
    rows = run_partial(Hybrid(**kw), C.CALIB + C.HELDOUT)
    summary(f'{spec} ({time.time()-t0:.0f}s)', rows)
    pickle.dump([{k: v for k, v in r.items() if k not in ('yte', 'nn_pred')} for r in rows], open(f"{OUT}/{spec.replace(';','_')}.pkl", 'wb'))
