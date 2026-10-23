"""Full evaluation of the calibrated race model (21 fns x 11 ns x 3 seeds) and comparisons."""
import os, sys, json, time
sys.path.insert(0, '.')
import numpy as np, common as C
from models.race import Race
OUT = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals'
kw = eval(sys.argv[1]) if len(sys.argv) > 1 else {}
M = Race(**kw)
t0 = time.time()
res = C.evaluate(M)
print('total seconds', time.time() - t0, flush=True)
C.save_eval(res, f'{OUT}/race.npz')
json.dump(dict(kw=kw, secs=time.time() - t0), open('models/scratch_race/full_eval_meta.json', 'w'))
print('saved')
