import sys, time, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM
for kw in [dict(), dict(mix=dict(rewire=0.0, retype=0.0))]:
    M = SSWM(**kw)
    for fn in ['thr10', 'par2']:
        X, y = C.train_data(fn, 0, 4096)
        t0 = time.time(); r = M.fit(X, y, np.random.default_rng(0)); 
        Xte, yte = C.test_data(fn)
        print(kw, fn, f"{time.time()-t0:.1f}s", r['n_accepted'], r['size'], r['time'], np.mean(r['predict'](Xte) != yte))
