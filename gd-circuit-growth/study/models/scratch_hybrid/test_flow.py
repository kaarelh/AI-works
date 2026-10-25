import sys, time, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.hybrid import Hybrid
from models.race import Race
for fn, n in [('mux', 256), ('maj9', 64), ('sparsepoly', 1024), ('par3', 2048), ('maj9', 8192)]:
    X, y = C.train_data(fn, 1, n); Xte, yte = C.test_data(fn)
    t0 = time.time(); p1 = Race(theta=1.5, Q=3, gate='relu').fit(X, y, np.random.default_rng([1, n, C._fn_seed(fn)]))['predict'](Xte); t1 = time.time() - t0
    t0 = time.time(); p2 = Hybrid(mode='none').fit(X, y, np.random.default_rng([1, n, C._fn_seed(fn)]))['predict'](Xte); t2 = time.time() - t0
    print('exact', fn, n, np.mean(p1 == p2), f'{t1:.2f}s {t2:.2f}s', 'race err', np.mean(p1 != yte))
    for c in [0.01, 0.1, 1.0]:
        t0 = time.time(); r = Hybrid(mode='flow', c_bg=c).fit(X, y, np.random.default_rng([1, n, C._fn_seed(fn)])); p = r['predict'](Xte)
        print(f'   flow c={c}: err {np.mean(p != yte):.3f} gates {r["size"]} stop_t {r["stop_time"]:.2f} lam {r["lam_bg"]:.3g} time {r["time"]:.2f} ({time.time()-t0:.2f}s)', flush=True)
