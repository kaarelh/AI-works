import sys, time, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM
import argparse
ap = argparse.ArgumentParser()
ap.add_argument('--fns', default='dict,maj3,par2,thr10')
ap.add_argument('--ns', default='32,64,128,256,512,1024,2048,4096')
ap.add_argument('--seeds', default='0')
ap.add_argument('--kw', default='')
ap.add_argument('--show', type=int, default=0)
a = ap.parse_args()
kw = eval('dict(' + a.kw + ')')
M = SSWM(**kw)
ns = [int(x) for x in a.ns.split(',')]; seeds = [int(x) for x in a.seeds.split(',')]
for fn in a.fns.split(','):
    Xte, yte = C.test_data(fn)
    row = []; tm = []; sz = []; secs = 0; tre = []
    for n in ns:
        e = []; 
        for s in seeds:
            X, y = C.train_data(fn, s, n)
            t0 = time.time()
            r = M.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            secs += time.time() - t0
            e.append(np.mean(r['predict'](Xte) != yte)); tm.append(r['time']); sz.append(r['size'])
            tre.append(np.mean(r['predict'](X) != y))
            if a.show and n == ns[-1] and s == seeds[0]:
                print(r['circuit'][:20], r['readout'])
        row.append(np.mean(e))
    print(f"{fn:10s} " + " ".join(f"{v:.2f}" for v in row) + f" | time {np.median(tm):.0f} size {np.median(sz):.0f} train {np.mean(tre):.2f} ({secs:.1f}s)", flush=True)
