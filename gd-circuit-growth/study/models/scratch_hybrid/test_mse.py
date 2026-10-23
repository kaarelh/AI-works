import sys, time, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.hybrid import Hybrid
for fn, n in [('maj3', 512), ('maj3', 64), ('dict', 32), ('par2', 256), ('andxor', 512), ('thr10', 1024), ('mux', 256)]:
    Xte, yte = C.test_data(fn)
    nn = C.nn_fixed(fn); a = list(nn['ns']).index(n)
    out = [f'{fn} n={n} NN {nn["test_err"][a].mean():.3f}']
    for kw in [dict(c_bg=0.01), dict(c_bg=0.01, stop_mse=0.01), dict(c_bg=0.01, stop_mse=0.03), dict(c_bg=0.03, stop_mse=0.03), dict(c_bg=0.1, stop_mse=0.03)]:
        errs, gs = [], []
        for s in range(3):
            X, y = C.train_data(fn, s, n)
            r = Hybrid(mode='flow', **kw).fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            errs.append(np.mean(r['predict'](Xte) != yte)); gs.append(r['size'])
        out.append(f"{kw}: {np.mean(errs):.3f} ({np.mean(gs):.1f} g)")
    print(' | '.join(out), flush=True)
