import sys, time, numpy as np, os
os.environ.setdefault("OMP_NUM_THREADS", "1")
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM
kw = eval('dict(' + sys.argv[1] + ')')
M = SSWM(**kw)
for fn in sys.argv[2].split(','):
    for n in [int(x) for x in sys.argv[3].split(',')]:
        X, y = C.train_data(fn, 0, n); Xte, yte = C.test_data(fn)
        t0 = time.time(); r = M.fit(X, y, np.random.default_rng(0)); el = time.time() - t0
        print(f"{fn} n={n} {el:.1f}s acc={r['n_accepted']} size={r['size']} time={r['time']:.0f} test={np.mean(r['predict'](Xte) != yte):.3f}", flush=True)
