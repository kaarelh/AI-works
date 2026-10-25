import sys, time, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.hybrid import Hybrid
cells = [('maj3', 512), ('maj3', 64), ('dict', 32), ('par2', 256), ('par2', 128), ('maj9', 256), ('mux', 256), ('par3', 1024)]
specs = [dict(mode='static', beta=0.0, rho=0.01, norm_util=True, t_end=te, stop_mse=None) for te in (10, 30, 100)] + \
        [dict(mode='static', beta=0.0, rho=0.03, norm_util=True, t_end=30, stop_mse=None)]
for fn, n in cells:
    Xte, yte = C.test_data(fn); nn = C.nn_fixed(fn); a = list(nn['ns']).index(n)
    out = [f'{fn} n={n} NN {nn["test_err"][a].mean():.3f}']
    for kw in specs:
        errs, gs, ag = [], [], []
        t0 = time.time()
        for s in range(3):
            X, y = C.train_data(fn, s, n)
            r = Hybrid(**kw).fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            p = r['predict'](Xte); errs.append(np.mean(p != yte)); gs.append(r['size']); ag.append(np.mean(p == nn['pred'][a, s]))
        out.append(f"rho={kw['rho']} T={kw['t_end']}: err {np.mean(errs):.3f} g {np.mean(gs):.0f} agree {np.mean(ag):.3f} ({time.time()-t0:.1f}s)")
    print(' | '.join(out), flush=True)
